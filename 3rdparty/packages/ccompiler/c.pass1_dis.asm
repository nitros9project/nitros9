                    nam       c.pass1
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $05

                    mod       eom,name,tylg,atrv,_start,size

u0000               rmb       3987
size                equ       .

name                equ       *
                    fcs       /c.pass1/
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
L0026               decb
L0027               bne       L0024
L0029               ldx       ,s
L002B               leau      ,x
L002D               leax      $0813,x
L0031               pshs      x
L0033               leay      L794C,pcr
L0037               ldx       ,y++
L0039               beq       L003F
L003B               bsr       copybytes
L003D               ldu       $02,s
L003F               leau      >$0076,u
L0043               ldx       ,y++
L0045               beq       L004A
L0047               bsr       copybytes
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
                    stx       $02C4,u
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
                    ldd       $02C0,u
                    pshs      d
                    leay      ,u
                    bsr       stkinit
                    lbsr      main
                    clr       ,-s
                    clr       ,-s
                    lbsr      exit
stkinit             leax      $0813,y
                    stx       $02CE,y
                    sts       $02C2,y
                    sts       $02D0,y
                    ldd       #$FF82
stkcheck            leax      d,s
                    cmpx      $02D0,y
                    bcc       L0122
                    cmpx      $02CE,y
                    bcs       L013C
                    stx       $02D0,y
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
                    lbsr      L7946
L0151               ldd       $02C2,y
                    subd      $02D0,y
                    rts
                    ldd       $02D0,y
                    subd      $02CE,y
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

L017D               pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    ldd       L0043
                    std       $02,s
                    beq       L0192
                    ldx       $02,s
                    ldd       $10,x
                    std       L0043
                    bra       L019E

L0192               ldd       #$0012
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    std       $02,s
L019E               ldd       #$0012
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    stu       $08,s
                    pshs      u
                    bsr       L01F6
                    leas      $06,s
                    ldd       #$0009
                    std       ,s
                    bra       L01BA

L01B6               clra
                    clrb
                    std       ,u++
L01BA               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bne       L01B6
                    ldd       $02,s
                    ldx       $04,s
                    std       $0e,x
                    lbra      L03D6

L01CF               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $0e,u
                    std       ,s
                    ldd       #$0012
                    pshs      d
                    pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L01F6
                    leas      $06,s
                    ldd       L0043
                    ldx       ,s
                    std       $10,x
                    ldd       ,s
                    std       L0043
                    lbra      L03B0

L01F6               pshs      u
                    ldu       $04,s
                    bra       L0206

L01FC               ldb       ,u+
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    stb       -$01,x
L0206               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L01FC
                    puls      pc,u
L0214               pshs      u
                    leax      $03EE,y
                    pshs      x
                    leax      L0520,pcr
                    pshs      x
                    lbsr      L034A
                    lbra      L038F

L0228               pshs      u
                    ldd       $04,s
                    pshs      d
                    bsr       L024B
                    leas      $02,s
                    leax      $01CE,y
                    pshs      x
                    lbsr      L702C
                    lbra      L0343

L023E               pshs      u
                    leax      L0526,pcr
                    pshs      x
                    bsr       L024B
                    lbra      L03B0

L024B               pshs      u
                    ldd       L003F
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      $060C,y
                    pshs      x
                    ldd       $0063
                    bra       L02A8

L025F               pshs      u
                    leas      -$32,s
                    leax      L053A,pcr
                    pshs      x
                    leax      $02,s
                    pshs      x
                    lbsr      L7311
                    leas      $04,s
                    ldd       $38,s
                    pshs      d
                    leax      $02,s
                    pshs      x
                    lbsr      L7329
                    leas      $04,s
                    leax      ,s
                    pshs      x
                    ldd       $38,s
                    pshs      d
                    bsr       L0293
                    leas      $04,s
                    leas      $32,s
                    puls      pc,u
L0293               pshs      u
                    ldu       $04,s
                    ldd       $0e,u
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    leax      $060C,y
                    pshs      x
                    ldd       $10,u
L02A8               subd      ,s++
                    pshs      d
                    bsr       L02B1
                    lbra      L03D6

L02B1               pshs      u
                    ldu       $04,s
                    lbsr      L0214
                    ldd       $08,s
                    pshs      d
                    leax      L054C,pcr
                    pshs      x
                    lbsr      L034A
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    leax      L0556,pcr
                    pshs      x
                    lbsr      L034A
                    leas      $04,s
                    ldd       $08,s
                    cmpd      L0027
                    bne       L02EC
                    leax      $060C,y
                    pshs      x
                    lbsr      L0365
                    leas      $02,s
                    leax      ,s
                    bra       L0303

L02EC               ldd       L0027
                    addd      #$FFFF
                    cmpd      $08,s
                    bne       L0323
                    leax      $070C,y
                    pshs      x
                    lbsr      L0365
                    leas      $02,s
                    bra       L0313

L0303               leas      ,x
                    bra       L0313

L0307               ldd       #$0020
                    pshs      d
                    lbsr      L037F
                    leas      $02,s
                    leau      -$01,u
L0313               cmpu      #$0000
                    bgt       L0307
                    leax      L0566,pcr
                    pshs      x
                    bsr       L0365
                    leas      $02,s
L0323               ldd       L0029
                    addd      #$0001
                    std       L0029
                    cmpd      #_start
                    ble       L0348
                    leax      $01CE,y
                    pshs      x
                    lbsr      L702C
                    leas      $02,s
                    leax      L0568,pcr
                    pshs      x
                    bsr       L0365
L0343               leas      $02,s
                    lbsr      L68C1
L0348               puls      pc,u
L034A               pshs      u
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    leax      $01CE,y
                    pshs      x
                    lbsr      fprintf
                    leas      $08,s
                    puls      pc,u
L0365               pshs      u
                    leax      $01CE,y
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      L6E61
                    leas      $04,s
                    ldd       #$000D
                    pshs      d
                    bsr       L037F
                    bra       L03B0

L037F               pshs      u
                    leax      $01CE,y
                    pshs      x
                    ldb       $07,s
                    sex
                    pshs      d
                    lbsr      L6F01
L038F               leas      $04,s
                    puls      pc,u
L0393               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L03B2
                    ldd       $0a,u
                    pshs      d
                    bsr       L0393
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L0393
                    leas      $02,s
                    pshs      u
                    bsr       L03B4
L03B0               leas      $02,s
L03B2               puls      pc,u
L03B4               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L03C2
                    ldd       L002D
                    std       $0a,u
                    stu       L002D
L03C2               puls      pc,u
L03C4               pshs      u
                    ldd       #$0016
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L01F6
L03D6               leas      $06,s
                    puls      pc,u
L03DA               pshs      u
                    ldd       $005F
                    cmpd      #$0033
                    bne       L0428
                    ldx       $0061
                    cmpx      #$0001
                    lbeq      L04FA
                    cmpx      #$0002
                    lbeq      L04FA
                    cmpx      #$0007
                    lbeq      L04FA
                    cmpx      #$000A
                    lbeq      L04FA
                    cmpx      #$0008
                    lbeq      L04FA
                    cmpx      #$0004
                    lbeq      L04FA
                    cmpx      #$0003
                    lbeq      L04FA
                    cmpx      #$0006
                    lbeq      L04FA
                    cmpx      #$0005
                    lbeq      L04FA
                    lbra      L04C8

L0428               ldd       $005F
                    cmpd      #$0034
                    lbne      L04C8
                    ldx       $0061
                    ldd       $08,x
                    cmpd      #_start
                    bra       L0470

L043C               pshs      u
                    ldd       $005F
                    cmpd      #$0033
                    lbne      L04C8
                    ldx       $0061
                    cmpx      #$000E
                    lbeq      L04FA
                    cmpx      #$000D
                    lbeq      L04FA
                    cmpx      #_start
                    lbeq      L04FA
                    cmpx      #$0010
                    lbeq      L04FA
                    cmpx      #$000F
                    lbeq      L04FA
                    cmpx      #$0021
L0470               lbeq      L04FA
                    lbra      L04C8

L0477               pshs      u
                    ldd       $04,s
                    asra
                    rorb
                    asra
                    rorb
                    andb      #$F0
                    bra       L0490

L0483               pshs      u
                    ldd       $04,s
                    andb      #$F0
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0010
L0490               pshs      d
                    ldd       $06,s
                    clra
                    andb      #$0f
                    addd      ,s++
                    puls      pc,u
L049B               pshs      u
                    ldu       $04,s
                    cmpu      #$004C
                    blt       L04C8
                    cmpu      #$0063
                    bgt       L04C8
                    ldd       #$0001
                    bra       L04CA

L04B0               pshs      u
                    ldu       $04,s
                    stu       -$02,s
                    beq       L04C8
                    ldd       $02,u
                    bra       L04CA

L04BC               pshs      u
                    ldd       $005F
                    cmpd      $04,s
                    bne       L04CC
                    lbsr      L552B
L04C8               clra
                    clrb
L04CA               puls      pc,u
L04CC               ldu       #$0000
                    bra       L04E3

L04D1               tfr       u,d
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    sex
                    cmpd      $04,s
                    beq       L04E9
                    leau      $01,u
L04E3               cmpu      #$0080
                    blt       L04D1
L04E9               tfr       u,d
                    stb       >$0076,y
                    leax      >$0076,y
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L04FA               ldd       #$0001
                    puls      pc,u
L04FF               pshs      u
                    bra       L0506

L0503               lbsr      L552B
L0506               ldd       $005F
                    cmpd      #$0028
                    beq       L051E
                    ldd       $005F
                    cmpd      #$002A
                    beq       L051E
                    ldd       $005F
                    cmpd      #$FFFF
                    bne       L0503
L051E               puls      pc,u
L0520               fcc       /%s : /
                    fcb       $00
L0526               fcc       /multiple definition/
                    fcb       $00
L053A               fcc       /compiler error - /
                    fcb       $00
L054C               fcc       /line %d  /
                    fcb       $00
L0556               fcc       /****  %s  ****/
                    fcb       $0D,$00
L0566               fcb       $5E
                    fcb       $00
L0568               fcc       /too many errors - ABORT/
                    fcb       $00
L0580               pshs      u
                    ldd       #$FFA2
                    lbsr      stkcheck
                    leas      -$0e,s
                    lbsr      L0694
                    std       $0C,s
                    lbne      L0679
                    clra
                    clrb
                    lbra      L0690
                    lbra      L0679

L059B               ldd       $005F
                    std       $0a,s
                    ldd       $0061
                    std       $08,s
                    std       ,s
                    ldd       L003F
                    std       $04,s
                    ldd       $0063
                    std       $02,s
                    lbsr      L552B
                    ldx       $0a,s
                    bra       L05CD

L05B4               ldd       $0a,s
                    cmpd      #$00A0
                    blt       L05C4
                    ldd       $0a,s
                    cmpd      #$00A9
                    ble       L05D9
L05C4               ldd       $08,s
                    addd      #$0001
                    std       ,s
                    bra       L05D9

L05CD               cmpx      #$0064
                    beq       L05D9
                    cmpx      #$0078
                    beq       L05D9
                    bra       L05B4

L05D9               ldd       ,s
                    pshs      d
                    lbsr      L0580
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    lbeq      L066E
                    ldd       $0a,s
                    cmpd      #$0064
                    lbne      L064D
                    ldd       #$002F
                    pshs      d
                    lbsr      L04BC
                    std       ,s++
                    bne       L0642
                    ldd       $0063
                    std       $02,s
                    ldd       L003F
                    std       $04,s
                    ldd       #$0003
                    pshs      d
                    lbsr      L0580
                    leas      $02,s
                    std       $06,s
                    beq       L0637
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
                    lbsr      L0DD3
                    leas      $0C,s
                    tfr       d,u
                    bra       L064D

L0637               leax      L0E97,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L0642               pshs      u
                    lbsr      L0393
                    leas      $02,s
                    leax      $0e,s
                    bra       L068C

L064D               ldd       $02,s
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
                    lbsr      L0DD3
                    leas      $0C,s
                    std       $0C,s
                    bra       L0679

L066E               leax      L0EB0,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L0679               lbsr      L0A9B
                    std       -$02,s
                    beq       L068E
                    ldd       $12,s
                    cmpd      $0061
                    lble      L059B
                    bra       L068E

L068C               leas      -$0e,x
L068E               ldd       $0C,s
L0690               leas      $0e,s
                    puls      pc,u
L0694               pshs      u
                    ldd       #$FFA4
                    lbsr      stkcheck
                    leas      -$0C,s
                    ldu       #$0000
                    ldx       $005F
                    lbra      L07FC

L06A6               ldd       $0063
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
                    lbsr      L0DD3
                    leas      $0C,s
                    tfr       d,u
                    lbsr      L552B
                    lbra      L085E

L06CB               lbsr      L552B
                    lbsr      L03DA
                    std       -$02,s
                    beq       L06F9
                    lbsr      L0D47
                    tfr       d,u
                    ldd       #$002E
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    bsr       L0694
                    std       $0a,u
                    lbne      L085E
                    pshs      u
                    lbsr      L03B4
                    leas      $02,s
                    ldu       #$0000
                    lbra      L085E

L06F9               clra
                    clrb
                    pshs      d
                    lbsr      L0580
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L072F
                    bra       L070C

L070A               leas      -$0C,x
L070C               lbsr      L0E15
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
                    lbsr      L0DD3
                    leas      $0C,s
                    tfr       d,u
L072F               ldd       #$002E
                    pshs      d
                    lbsr      L04BC
                    lbra      L07F8

L073A               ldd       $005F
                    std       $08,s
                    ldd       L003F
                    std       $06,s
                    ldd       $0063
                    std       $04,s
                    lbsr      L552B
                    lbsr      L0694
                    std       $0a,s
                    beq       L0775
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
                    lbsr      L0DD3
                    leas      $0C,s
                    tfr       d,u
                    lbra      L085E

L0775               leax      L0EC1,pcr
                    pshs      x
                    lbsr      L024B
                    lbra      L07F8

L0781               ldd       L003F
                    std       $06,s
                    ldd       $0063
                    std       $04,s
                    lbsr      L552B
                    ldd       $005F
                    cmpd      #$002D
                    bne       L07C3
                    lbsr      L552B
                    lbsr      L03DA
                    std       -$02,s
                    beq       L07A5
                    lbsr      L0D47
                    std       $0a,s
                    bra       L07B7

L07A5               clra
                    clrb
                    pshs      d
                    lbsr      L0580
                    leas      $02,s
                    std       $0a,s
                    bne       L07B7
                    leax      $0C,s
                    lbra      L070A

L07B7               ldd       #$002E
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    bra       L07C8

L07C3               lbsr      L0694
                    std       $0a,s
L07C8               ldd       $0a,s
                    std       ,s
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L0E29
                    std       ,s
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0036
                    pshs      d
                    lbsr      L0DD3
                    leas      $0C,s
                    tfr       d,u
                    ldd       ,s
                    pshs      d
                    lbsr      L0393
L07F8               leas      $02,s
                    bra       L085E

L07FC               cmpx      #$0037
                    lbeq      L06A6
                    cmpx      #$0034
                    lbeq      L06A6
                    cmpx      #$004A
                    lbeq      L06A6
                    cmpx      #$004B
                    lbeq      L06A6
                    cmpx      #$0036
                    lbeq      L06A6
                    cmpx      #$002D
                    lbeq      L06CB
                    cmpx      #$0040
                    lbeq      L073A
                    cmpx      #$0043
                    lbeq      L073A
                    cmpx      #$0044
                    lbeq      L073A
                    cmpx      #$0042
                    lbeq      L073A
                    cmpx      #$003D
                    lbeq      L073A
                    cmpx      #$003C
                    lbeq      L073A
                    cmpx      #$0041
                    lbeq      L073A
                    cmpx      #$003B
                    lbeq      L0781
L085E               cmpu      #$0000
                    bne       L0869
                    clra
                    clrb
                    lbra      L09F0

L0869               ldx       $005F
                    lbra      L098F

L086E               ldd       $0063
                    std       $04,s
                    ldd       L003F
                    std       $06,s
                    lbsr      L552B
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       #$000F
                    pshs      d
                    lbsr      L09F4
                    pshs      d
                    pshs      u
                    ldd       #$0065
                    pshs      d
                    lbsr      L0DD3
                    leas      $0C,s
                    tfr       d,u
                    ldd       #$002E
                    lbra      L0915

L089F               lbsr      L552B
                    ldd       #$0002
                    pshs      d
                    lbsr      L0580
                    leas      $02,s
                    std       $0a,s
                    bne       L08D3
                    lbsr      L0E15
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
                    lbsr      L0DD3
                    leas      $0C,s
                    std       $0a,s
L08D3               ldd       $0063
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
                    lbsr      L0DD3
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
                    lbsr      L0DD3
                    leas      $0C,s
                    tfr       d,u
                    ldd       #$002C
L0915               pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    lbra      L0869

L091F               ldd       $005F
                    std       $08,s
                    ldd       L003F
                    std       $06,s
                    ldd       $0063
                    std       $04,s
                    ldd       $0041
                    addd      #$0001
                    std       $0041
                    lbsr      L552B
                    ldd       $0041
                    addd      #$FFFF
                    std       $0041
                    ldd       $005F
                    cmpd      #$0034
                    beq       L094A
                    lbsr      L42DF
                    lbra      L09AB

L094A               ldd       $0063
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
                    lbsr      L0DD3
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
                    lbsr      L0DD3
                    leas      $0C,s
                    tfr       d,u
                    lbsr      L552B
                    lbra      L0869

L098F               cmpx      #$002D
                    lbeq      L086E
                    cmpx      #$002B
                    lbeq      L089F
                    cmpx      #$0045
                    lbeq      L091F
                    cmpx      #$0046
                    lbeq      L091F
L09AB               ldx       $005F
                    bra       L09E4

L09AF               ldd       #$003E
                    std       $005F
                    leax      $0C,s
                    bra       L09BF

L09B8               ldd       #$003F
                    std       $005F
                    bra       L09C1

L09BF               leas      -$0C,x
L09C1               ldd       $0063
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
                    lbsr      L0DD3
                    leas      $0C,s
                    tfr       d,u
                    lbsr      L552B
                    bra       L09EE

L09E4               cmpx      #$003C
                    beq       L09AF
                    cmpx      #$003D
                    beq       L09B8
L09EE               tfr       u,d
L09F0               leas      $0C,s
                    puls      pc,u
L09F4               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    leas      -$02,s
                    ldu       #$0000
                    bra       L0A03

L0A03               ldd       $005F
                    cmpd      #$002E
                    beq       L0A4B
                    ldd       #$0002
                    pshs      d
                    lbsr      L0580
                    leas      $02,s
                    std       ,s
                    beq       L0A3E
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
                    lbsr      L0DD3
                    leas      $0C,s
                    std       ,s
                    ldu       ,s
L0A3E               ldd       $005F
                    cmpd      #$0030
                    bne       L0A4B
                    lbsr      L552B
                    bra       L0A03

L0A4B               tfr       u,d
                    bra       L0A97

L0A4F               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    leas      -$02,s
                    ldd       $06,s
                    pshs      d
                    lbsr      L0580
                    std       ,s
                    lbsr      L0F18
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0A7B
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L0A7B
                    ldd       $08,u
                    std       ,s
                    bra       L0A8A

L0A7B               clra
                    clrb
                    std       ,s
                    leax      L0ED2,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L0A8A               stu       -$02,s
                    beq       L0A95
                    pshs      u
                    lbsr      L0393
                    leas      $02,s
L0A95               ldd       ,s
L0A97               leas      $02,s
                    puls      pc,u
L0A9B               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldx       $005F
                    bra       L0AF4

L0AA7               ldd       #$0057
                    std       $005F
                    ldd       #$0008
                    bra       L0AC3

L0AB1               ldd       #$0052
                    std       $005F
                    ldd       #$000D
                    bra       L0AC3

L0ABB               ldd       #$0051
                    std       $005F
                    ldd       #$000C
L0AC3               std       $0061
L0AC5               ldd       #$0001
                    puls      pc,u
L0ACA               ldd       $005F
                    cmpd      #$0047
                    blt       L0ADA
                    ldd       $005F
                    cmpd      #$005F
                    ble       L0AEE
L0ADA               ldd       $005F
                    cmpd      #$00A0
                    lblt      L0C8F
                    ldd       $005F
                    cmpd      #$00A9
                    lbgt      L0C8F
L0AEE               ldd       #$0001
                    lbra      L0C91

L0AF4               cmpx      #$0041
                    beq       L0AA7
                    cmpx      #$0042
                    beq       L0AB1
                    cmpx      #$0043
                    beq       L0ABB
                    cmpx      #$0030
                    beq       L0AC5
                    cmpx      #$0078
                    lbeq      L0AC5
                    cmpx      #$0064
                    lbeq      L0AC5
                    cmpx      #$002F
                    lbeq      L0C8F
                    bra       L0ACA
                    puls      pc,u
L0B21               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldx       $04,s
                    lbra      L0C93

L0B2E               ldd       $06,s
                    addd      $08,s
                    puls      pc,u
L0B34               ldd       $06,s
                    subd      $08,s
                    puls      pc,u
L0B3A               ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      L753F
                    puls      pc,u
L0B45               ldd       $08,s
                    beq       L0B63
                    ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      L75F3
                    bra       L0B61

L0B54               ldd       $08,s
                    beq       L0B63
                    ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      L75A0
L0B61               puls      pc,u
L0B63               lbsr      L136D
                    lbra      L0C8F

L0B69               ldd       $06,s
                    anda      $08,s
                    andb      $09,s
                    puls      pc,u
L0B71               ldd       $06,s
                    ora       $08,s
                    orb       $09,s
                    puls      pc,u
L0B79               ldd       $06,s
                    eora      $08,s
                    eorb      $09,s
                    puls      pc,u
L0B81               ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      L7680
                    puls      pc,u
L0B8C               ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    lbsr      L765D
                    puls      pc,u
L0B97               ldd       $06,s
                    cmpd      $08,s
                    lbne      L0C8F
                    ldd       #$0001
                    lbra      L0C91

L0BA6               ldd       $06,s
                    cmpd      $08,s
                    lbeq      L0C8F
                    ldd       #$0001
                    lbra      L0C91

L0BB5               ldd       $06,s
                    cmpd      $08,s
                    lble      L0C8F
                    ldd       #$0001
                    lbra      L0C91

L0BC4               ldd       $06,s
                    cmpd      $08,s
                    lbge      L0C8F
                    ldd       #$0001
                    lbra      L0C91

L0BD3               ldd       $06,s
                    cmpd      $08,s
                    lblt      L0C8F
                    ldd       #$0001
                    lbra      L0C91

L0BE2               ldd       $06,s
                    cmpd      $08,s
                    lbgt      L0C8F
                    ldd       #$0001
                    lbra      L0C91

L0BF1               ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    puls      pc,u
L0BF9               ldd       $06,s
                    lbne      L0C8F
                    ldd       #$0001
                    lbra      L0C91

L0C05               ldd       $06,s
                    coma
                    comb
                    puls      pc,u
L0C0B               ldd       $06,s
                    lbeq      L0C8F
                    ldd       $08,s
                    lbeq      L0C8F
                    ldd       #$0001
                    lbra      L0C91

L0C1D               ldd       $06,s
                    bne       L0C27
                    ldd       $08,s
                    lbeq      L0C8F
L0C27               ldd       #$0001
                    lbra      L0C91

L0C2D               leas      -$04,s
                    ldd       $0C,s
                    std       $02,s
                    ldd       $0a,s
                    std       ,s
                    ldx       $08,s
                    bra       L0C71

L0C3B               ldd       ,s
                    cmpd      $02,s
                    bhi       L0C6B
                    ldd       #$0001
                    bra       L0C6D

L0C47               ldd       ,s
                    cmpd      $02,s
                    bcc       L0C6B
                    ldd       #$0001
                    bra       L0C6D

L0C53               ldd       ,s
                    cmpd      $02,s
                    bcs       L0C6B
                    ldd       #$0001
                    bra       L0C6D

L0C5F               ldd       ,s
                    cmpd      $02,s
                    bls       L0C6B
                    ldd       #$0001
                    bra       L0C6D

L0C6B               clra
                    clrb
L0C6D               leas      $04,s
                    puls      pc,u
L0C71               cmpx      #$0060
                    beq       L0C3B
                    cmpx      #$0061
                    beq       L0C47
                    cmpx      #$0062
                    beq       L0C53
                    bra       L0C5F
                    leas      $04,s
L0C84               leax      L0EE4,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L0C8F               clra
                    clrb
L0C91               puls      pc,u
L0C93               cmpx      #$0050
                    lbeq      L0B2E
                    cmpx      #$0051
                    lbeq      L0B34
                    cmpx      #$0052
                    lbeq      L0B3A
                    cmpx      #$0053
                    lbeq      L0B45
                    cmpx      #$0054
                    lbeq      L0B54
                    cmpx      #$0057
                    lbeq      L0B69
                    cmpx      #$0058
                    lbeq      L0B71
                    cmpx      #$0059
                    lbeq      L0B79
                    cmpx      #$0056
                    lbeq      L0B81
                    cmpx      #$0055
                    lbeq      L0B8C
                    cmpx      #$005A
                    lbeq      L0B97
                    cmpx      #$005B
                    lbeq      L0BA6
                    cmpx      #$005F
                    lbeq      L0BB5
                    cmpx      #$005D
                    lbeq      L0BC4
                    cmpx      #$005E
                    lbeq      L0BD3
                    cmpx      #$005C
                    lbeq      L0BE2
                    cmpx      #$0043
                    lbeq      L0BF1
                    cmpx      #$0040
                    lbeq      L0BF9
                    cmpx      #$0044
                    lbeq      L0C05
                    cmpx      #$0047
                    lbeq      L0C0B
                    cmpx      #$0048
                    lbeq      L0C1D
                    cmpx      #$0060
                    lbeq      L0C2D
                    cmpx      #$0061
                    lbeq      L0C2D
                    cmpx      #$0062
                    lbeq      L0C2D
                    cmpx      #$0063
                    lbeq      L0C2D
                    lbra      L0C84
                    puls      pc,u
L0D47               pshs      u
                    ldd       #$FFA2
                    lbsr      stkcheck
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
                    lbsr      L3C35
                    leas      $06,s
                    std       $08,s
                    pshs      d
                    leax      $0C,s
                    pshs      x
                    leax      $0a,s
                    pshs      x
                    lbsr      L3F8A
                    leas      $06,s
                    std       $08,s
                    leax      >$0047,y
                    pshs      x
                    lbsr      L4204
                    leas      $02,s
                    ldd       $06,s
                    beq       L0D98
                    leax      L0EF6,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L0D98               ldd       $02,s
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
                    bsr       L0DD3
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
                    lbsr      L4100
                    leas      $06,s
                    ldd       $06,s
                    leas      $0e,s
                    puls      pc,u
L0DD3               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       L002D
                    beq       L0DE7
                    ldu       L002D
                    ldd       $0a,u
                    std       L002D
                    bra       L0DF3

L0DE7               ldd       #$0016
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    tfr       d,u
L0DF3               ldd       $04,s
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
L0E15               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    leax      L0F05,pcr
                    pshs      x
                    lbsr      L024B
                    lbra      L0E78

L0E29               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldu       [$04,s]
                    ldx       $06,u
                    bra       L0E7C

L0E38               pshs      u
                    lbsr      L0F18
                    leas      $02,s
                    std       [$04,s]
                    tfr       d,u
                    leax      ,s
                    bra       L0E58

L0E48               ldd       [$08,u]
                    std       ,u
                    pshs      u
                    lbsr      L24D3
                    leas      $02,s
                    ldu       $08,u
                    bra       L0E5A

L0E58               leas      ,x
L0E5A               ldd       $04,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       ,u
                    pshs      d
                    lbsr      L418A
                    leas      $06,s
                    puls      pc,u
L0E6D               pshs      u
                    ldd       #$000C
                    addd      ,s++
                    pshs      d
                    bsr       L0E29
L0E78               leas      $02,s
                    puls      pc,u
L0E7C               cmpx      #$0034
                    beq       L0E48
                    cmpx      #$0020
                    beq       L0E5A
                    cmpx      #$0045
                    beq       L0E6D
                    cmpx      #$0046
                    lbeq      L0E6D
                    lbra      L0E38
                    puls      pc,u
L0E97               fcc       /third expression missing/
                    fcb       $00
L0EB0               fcc       /operand expected/
                    fcb       $00
L0EC1               fcc       /primary expected/
                    fcb       $00
L0ED2               fcc       /constant required/
                    fcb       $00
L0EE4               fcc       /constant operator/
                    fcb       $00
L0EF6               fcc       /name in a cast/
                    fcb       $00
L0F05               fcc       /expression missing/
                    fcb       $00
L0F18               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$0C,s
                    stu       -$02,s
                    lbeq      L0FFF
                    ldd       $0a,u
                    pshs      d
                    bsr       L0F18
                    leas      $02,s
                    std       $0a,u
                    ldd       $0C,u
                    pshs      d
                    lbsr      L0F18
                    leas      $02,s
                    std       $0C,u
                    pshs      u
                    lbsr      L1382
                    leas      $02,s
                    tfr       d,u
                    pshs      u
                    lbsr      L1323
                    std       ,s++
                    beq       L0F56
                    leax      $0C,s
                    lbra      L0FFD

L0F56               pshs      u
                    lbsr      L1005
                    leas      $02,s
                    tfr       d,u
                    ldd       $0a,u
                    std       $0a,s
                    ldd       $0C,u
                    std       $08,s
                    ldd       $06,u
                    std       $04,s
                    cmpd      #$0064
                    bne       L0FB4
                    ldx       $0a,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L0FB4
                    ldx       $0a,s
                    ldd       $08,x
                    beq       L0F8D
                    ldx       $08,s
                    ldd       $0a,x
                    std       $02,s
                    ldx       $08,s
                    ldd       $0C,x
                    bra       L0F97

L0F8D               ldx       $08,s
                    ldd       $0C,x
                    std       $02,s
                    ldx       $08,s
                    ldd       $0a,x
L0F97               pshs      d
                    lbsr      L0393
                    leas      $02,s
                    ldd       $08,s
                    pshs      d
                    lbsr      L03B4
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L03B4
                    leas      $02,s
                    pshs      u
                    bra       L0FF4

L0FB4               ldd       $04,s
                    cmpd      #$0042
                    bne       L0FC6
                    ldx       $0a,s
                    ldd       $06,x
                    cmpd      #$0041
                    beq       L0FD8
L0FC6               ldd       $04,s
                    cmpd      #$0041
                    bne       L0FFF
                    ldx       $0a,s
                    ldd       $06,x
                    cmpd      #$0042
                    bne       L0FFF
L0FD8               ldx       $0a,s
                    ldd       $0a,x
                    std       $02,s
                    ldd       ,u
                    std       [$02,s]
                    ldd       $02,u
                    ldx       $02,s
                    std       $02,x
                    pshs      u
                    lbsr      L03B4
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
L0FF4               lbsr      L03B4
                    leas      $02,s
                    ldu       $02,s
                    bra       L0FFF

L0FFD               leas      -$0C,x
L0FFF               tfr       u,d
                    leas      $0C,s
                    puls      pc,u
L1005               pshs      u
                    ldd       #$FFA8
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$0e,s
                    stu       -$02,s
                    bne       L101A
                    clra
                    clrb
                    lbra      L131F

L101A               ldd       $0a,u
                    std       $0C,s
                    ldd       $0C,u
                    std       $0a,s
                    ldd       $06,u
                    std       $06,s
                    pshs      d
                    lbsr      L049B
                    std       ,s++
                    bne       L1041
                    ldd       $06,s
                    cmpd      #$0047
                    beq       L1041
                    ldd       $06,s
                    cmpd      #$0048
                    lbne      L1258
L1041               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1050
                    ldd       #$0001
                    bra       L1052

L1050               clra
                    clrb
L1052               std       $02,s
                    pshs      d
                    ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L1065
                    ldd       #$0001
                    bra       L1067

L1065               clra
                    clrb
L1067               std       $02,s
                    anda      ,s+
                    andb      ,s+
                    std       -$02,s
                    beq       L1076
                    leax      $0e,s
                    lbra      L1269

L1076               ldd       $02,s
                    beq       L10B6
                    ldx       $06,s
                    bra       L1095

L107E               ldd       $0C,s
                    std       $08,s
                    ldd       $0a,s
                    std       $0C,s
                    std       $0a,u
                    ldd       $08,s
                    std       $0a,s
                    std       $0C,u
                    ldd       #$0001
                    std       ,s
                    bra       L10B6

L1095               cmpx      #$0050
                    beq       L107E
                    cmpx      #$0052
                    lbeq      L107E
                    cmpx      #$0057
                    lbeq      L107E
                    cmpx      #$0058
                    lbeq      L107E
                    cmpx      #$0059
                    lbeq      L107E
L10B6               ldx       $06,s
                    lbra      L1224

L10BB               ldd       ,s
                    lbeq      L131D
                    ldx       $0a,s
                    ldd       $08,x
                    lbeq      L11E9
                    lbra      L131D

L10CC               ldd       ,s
                    lbeq      L131D
                    ldx       $0a,s
                    ldd       $08,x
                    lbeq      L11E9
                    ldx       $0C,s
                    ldx       $06,x
                    lbra      L1133

L10E1               ldx       $0C,s
                    ldx       $0a,x
                    ldd       $14,x
                    leax      $14,x
                    pshs      x,d
                    ldx       $0e,s
                    ldd       $08,x
                    addd      ,s++
                    std       [,s++]
                    bra       L10F9

L10F7               leas      -$0e,x
L10F9               ldd       $0C,s
                    std       $08,s
                    pshs      u
                    lbsr      L03B4
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L03B4
                    leas      $02,s
                    ldu       $08,s
                    lbra      L131D

L1112               ldx       $0C,s
                    ldx       $0C,x
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L131D
                    ldx       $0C,s
                    ldx       $0C,x
                    ldd       $08,x
                    leax      $08,x
                    pshs      x,d
                    ldx       $0e,s
                    ldd       $08,x
                    addd      ,s++
                    lbra      L11CC

L1133               cmpx      #$0041
                    lbeq      L10E1
                    cmpx      #$0050
                    beq       L1112
                    lbra      L131D

L1142               ldd       ,s
                    beq       L1161
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
                    lbsr      L1005
                    leas      $02,s
                    lbra      L131F

L1161               ldd       $02,s
                    lbeq      L131D
                    ldx       $0C,s
                    ldd       $08,x
                    lbne      L131D
                    ldd       #$0043
                    std       $06,u
                    ldd       $0a,s
                    std       $0a,u
                    clra
                    clrb
                    std       $0C,u
                    ldd       $0C,s
                    lbra      L121A

L1181               ldd       ,s
                    lbeq      L131D
                    ldx       $0a,s
                    ldd       $08,x
                    beq       L119C
                    lbra      L131D

L1190               ldd       ,s
                    lbeq      L131D
                    ldx       $0a,s
                    ldx       $08,x
                    bra       L11D0

L119C               leax      $0e,s
                    lbra      L11FE

L11A1               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0052
                    lbne      L131D
                    ldx       $0C,s
                    ldx       $0C,x
                    ldd       $06,x
                    cmpd      #$0036
                    lbne      L131D
                    ldx       $0C,s
                    ldx       $0C,x
                    ldd       $08,x
                    leax      $08,x
                    pshs      x,d
                    ldx       $0e,s
                    ldd       $08,x
                    lbsr      L753F
L11CC               std       [,s++]
                    bra       L11E9

L11D0               stx       -$02,s
                    beq       L119C
                    cmpx      #$0001
                    beq       L11E9
                    bra       L11A1

L11DB               ldd       ,s
                    beq       L11EE
                    ldx       $0a,s
                    ldd       $08,x
                    cmpd      #$0001
                    bne       L11EE
L11E9               leax      $0e,s
                    lbra      L10F7

L11EE               ldd       $02,s
                    lbeq      L131D
                    ldx       $0C,s
                    ldd       $08,x
                    lbne      L131D
                    bra       L1200

L11FE               leas      -$0e,x
L1200               ldd       #$0036
                    std       $06,u
                    clra
                    clrb
L1207               std       $08,u
                    clra
                    clrb
                    std       $0C,u
                    std       $0a,u
                    ldd       $0C,s
                    pshs      d
                    lbsr      L03B4
                    leas      $02,s
                    ldd       $0a,s
L121A               pshs      d
                    lbsr      L03B4
L121F               leas      $02,s
                    lbra      L131D

L1224               cmpx      #$0058
                    lbeq      L10BB
                    cmpx      #$0059
                    lbeq      L10BB
                    cmpx      #$0050
                    lbeq      L10CC
                    cmpx      #$0051
                    lbeq      L1142
                    cmpx      #$0057
                    lbeq      L1181
                    cmpx      #$0052
                    lbeq      L1190
                    cmpx      #$0053
                    lbeq      L11DB
                    lbra      L131D

L1258               ldx       $06,s
                    lbra      L1308

L125D               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$0036
                    bne       L128D
                    bra       L126B

L1269               leas      -$0e,x
L126B               ldd       #$0036
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
                    lbsr      L0B21
                    leas      $06,s
                    lbra      L1207

L128D               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$004A
                    bne       L12DC
                    leas      -$02,s
                    ldx       $0e,s
                    ldd       $08,x
                    std       ,s
                    bne       L12AD
                    ldd       #$0004
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    std       ,s
L12AD               ldx       $08,s
                    bra       L12CA

L12B1               ldx       ,s
                    pshs      x
                    ldx       $02,s
                    lbsr      L7493
                    bra       L12C5

L12BC               ldx       ,s
                    pshs      x
                    ldx       $02,s
                    lbsr      L74A7
L12C5               lbsr      L74D3
                    bra       L12D4

L12CA               cmpx      #$0043
                    beq       L12B1
                    cmpx      #$0044
                    beq       L12BC
L12D4               ldd       ,s
                    ldx       $0e,s
                    std       $08,x
                    bra       L12FC

L12DC               ldx       $0C,s
                    ldd       $06,x
                    cmpd      #$004B
                    bne       L131D
                    leas      -$02,s
                    ldx       $0e,s
                    ldd       $08,x
                    std       ,s
                    beq       L12FC
                    ldx       ,s
                    pshs      x
                    ldx       $02,s
                    lbsr      L6973
                    lbsr      L69FF
L12FC               pshs      u
                    lbsr      L03B4
                    leas      $02,s
                    ldu       $0e,s
                    lbra      L121F

L1308               cmpx      #$0040
                    lbeq      L125D
                    cmpx      #$0044
                    lbeq      L125D
                    cmpx      #$0043
                    lbeq      L125D
L131D               tfr       u,d
L131F               leas      $0e,s
                    puls      pc,u
L1323               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldu       $04,s
                    stu       -$02,s
                    beq       L1369
                    ldx       $06,u
                    bra       L133A

L1335               ldd       #$0001
                    puls      pc,u
L133A               cmpx      #$0076
                    beq       L1335
                    cmpx      #$006F
                    lbeq      L1335
                    cmpx      #$0036
                    lbeq      L1335
                    cmpx      #$004A
                    lbeq      L1335
                    cmpx      #$004B
                    lbeq      L1335
                    cmpx      #$0034
                    lbeq      L1335
                    cmpx      #$0037
                    lbeq      L1335
L1369               clra
                    clrb
                    puls      pc,u
L136D               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    leax      L2675,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    puls      pc,u
L1382               pshs      u
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
                    lbra      L1E49

L13B6               ldx       $18,s
                    ldd       $08,x
                    std       $10,s
                    ldx       $10,s
                    ldd       $08,x
                    cmpd      #_start
                    bne       L13E6
                    leax      L2684,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0293
                    leas      $04,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L25E6
                    leas      $02,s
                    lbra      L1F6B

L13E6               ldd       [$10,s]
                    std       $0C,s
                    ldx       $10,s
                    ldd       $04,x
                    std       $06,s
                    ldd       $0C,s
                    clra
                    andb      #$0f
                    cmpd      #$000A
                    bne       L1427
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
                    lbsr      L4100
                    leas      $06,s
                    leas      $02,s
L1427               ldx       $10,s
                    ldd       $02,x
                    std       $0a,s
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L1446
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    lbne      L14A9
L1446               ldu       $18,s
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
                    lbsr      L0DD3
                    leas      $0C,s
                    std       $18,s
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L1494
                    ldd       $06,s
                    pshs      d
                    lbsr      L04B0
                    leas      $02,s
                    std       $06,s
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0477
                    leas      $02,s
                    bra       L1496

L1494               ldd       $0C,s
L1496               std       ,u
                    pshs      d
                    lbsr      L0483
                    leas      $02,s
                    std       $0C,s
                    ldd       #$0001
                    std       $12,u
                    bra       L14D0

L14A9               ldx       $10,s
                    ldd       $08,x
                    std       $04,s
                    tfr       d,x
                    bra       L14C4

L14B4               ldd       $04,s
                    ldx       $18,s
                    std       $06,x
                    clra
                    clrb
                    ldx       $18,s
                    std       $08,x
                    bra       L14D0

L14C4               cmpx      #$0076
                    beq       L14B4
                    cmpx      #$006F
                    lbeq      L14B4
L14D0               ldd       #$0001
                    bra       L14D7

L14D5               clra
                    clrb
L14D7               std       $08,s
                    lbra      L1F6B

L14DC               ldd       #$0008
                    std       $0C,s
                    ldd       #$0001
                    std       $08,s
                    ldd       #$0004
                    lbra      L1641

L14EC               ldd       #$0006
                    std       $0C,s
                    ldd       #$0001
                    std       $08,s
                    ldd       #$0008
                    lbra      L1641

L14FC               ldd       #$0012
                    std       $0C,s
                    ldd       #$0001
                    lbra      L1641

L1507               pshs      u
                    lbsr      L24D3
                    leas      $02,s
                    ldd       [$18,s]
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L1527
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L1542
L1527               leax      L269D,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0293
                    leas      $04,s
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0483
                    leas      $02,s
                    std       $0C,s
L1542               ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L155B
                    ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    bra       L1568

L155B               ldd       $0C,s
                    pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    std       $0C,s
L1568               ldx       $18,s
                    ldd       $04,x
                    std       $06,s
                    ldx       $18,s
                    ldd       $02,x
                    std       $0a,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L03B4
                    leas      $02,s
                    stu       $18,s
                    lbra      L1F6B

L1586               ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L2463
                    leas      $04,s
                    ldd       $06,u
                    cmpd      #$0076
                    beq       L15A2
                    ldd       $06,u
                    cmpd      #$006F
                    bne       L15B9
L15A2               leax      L26A9,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0293
                    leas      $04,s
                    pshs      u
                    lbsr      L25E6
                    leas      $02,s
L15B9               ldd       $12,u
                    std       $08,s
                    ldd       $02,u
                    std       $0a,s
                    ldd       ,u
                    pshs      d
                    lbsr      L0483
                    leas      $02,s
                    std       $0C,s
                    ldd       $04,u
                    std       $06,s
                    lbra      L1F6B

L15D4               ldd       $04,u
                    std       $06,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1618
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0477
                    leas      $02,s
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L163A
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0477
                    std       ,s
                    lbsr      L0483
                    leas      $02,s
                    std       $0C,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L03B4
                    leas      $02,s
                    stu       $18,s
                    bra       L163A

L1618               leax      L26BC,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0293
                    leas      $04,s
                    pshs      u
                    lbsr      L25E6
                    leas      $02,s
                    ldd       #$0011
                    std       ,u
                    ldd       #$0001
                    std       $0C,s
                    clra
                    clrb
                    std       $06,s
L163A               ldd       $12,u
                    std       $08,s
                    ldd       $02,u
L1641               std       $0a,s
                    lbra      L1F6B

L1646               leax      ,s
                    pshs      x
                    leax      $0e,s
                    pshs      x
                    ldd       $16,s
                    pshs      d
                    lbsr      L2502
                    leas      $06,s
                    std       $0a,s
                    ldx       $12,s
                    ldd       $04,x
                    std       $06,s
                    ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L2463
                    leas      $04,s
                    ldx       $12,s
                    ldd       $08,x
                    bne       L169A
                    ldd       ,s
                    bne       L169A
                    ldd       $12,s
                    pshs      d
                    lbsr      L03B4
                    leas      $02,s
                    ldd       $18,s
                    pshs      d
                    lbsr      L03B4
                    leas      $02,s
                    stu       $18,s
                    ldx       $18,s
                    ldd       $12,x
                    std       $08,s
                    lbra      L16FD

L169A               ldd       $12,u
                    std       $08,s
                    ldd       $06,u
                    cmpd      #$0042
                    bne       L16BF
                    ldd       $0a,u
                    std       $10,s
                    pshs      u
                    lbsr      L03B4
                    leas      $02,s
                    ldu       $10,s
                    tfr       u,d
                    ldx       $18,s
                    std       $0a,x
                    bra       L16F2

L16BF               ldd       ,u
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
                    lbsr      L0DD3
                    leas      $0C,s
                    ldx       $18,s
                    std       $0a,x
                    tfr       d,u
                    ldd       $04,s
                    pshs      d
                    lbsr      L0483
                    leas      $02,s
                    std       ,u
L16F2               ldd       $08,s
                    std       $12,u
                    leax      $14,s
                    lbra      L175B

L16FD               lbra      L1F6B

L1700               leax      ,s
                    pshs      x
                    leax      $0e,s
                    pshs      x
                    ldd       $16,s
                    pshs      d
                    lbsr      L2502
                    leas      $06,s
                    std       $0a,s
                    ldx       $12,s
                    ldd       $04,x
                    std       $06,s
                    ldd       ,u
                    std       $04,s
                    cmpd      #$0001
                    beq       L1754
                    ldd       $04,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1735
                    ldd       #$0001
                    bra       L1737

L1735               clra
                    clrb
L1737               bne       L1754
                    leax      L26CD,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0293
                    leas      $04,s
                    ldd       #$0036
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
                    clra
                    clrb
                    std       $12,u
L1754               ldd       $12,u
                    std       $08,s
                    bra       L175E

L175B               leas      -$14,x
L175E               ldd       #$0050
                    ldx       $18,s
                    std       $06,x
                    ldd       $18,s
                    pshs      d
                    lbsr      L1005
                    leas      $02,s
                    std       $18,s
                    ldd       ,s
                    bne       L17BB
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0483
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
                    lbsr      L0DD3
                    leas      $0C,s
                    std       $18,s
L17BB               lbra      L1F6B

L17BE               ldd       ,u
                    std       $0C,s
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L17FA
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0477
                    leas      $02,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L17FA
                    ldd       $0a,u
                    ldx       $18,s
                    std       $0a,x
                    std       $10,s
                    pshs      u
                    lbsr      L03B4
                    leas      $02,s
                    ldd       [$10,s]
L17F0               pshs      d
                    lbsr      L0477
                    leas      $02,s
                    lbra      L185E

L17FA               ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L1809
                    ldd       $0C,s
                    bra       L17F0

L1809               ldd       $0C,s
                    bne       L184C
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
                    lbsr      L01F6
                    leas      $06,s
                    ldd       #$0001
                    bra       L185E

L184C               leax      L26E9,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0293
                    leas      $04,s
                    ldd       $0C,s
                    clra
                    andb      #$0f
L185E               std       $0C,s
                    ldd       $04,u
                    std       $06,s
                    ldd       $02,u
                    std       $0a,s
L1868               pshs      u
                    lbsr      L24D3
                    leas      $02,s
                    pshs      u
                    lbsr      L25B5
                    leas      $02,s
                    ldx       ,u
                    bra       L188D

L187A               ldd       #$0001
                    bra       L1882

L187F               ldd       #$0006
L1882               pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    bra       L1897

L188D               cmpx      #$0002
                    beq       L187A
                    cmpx      #$0005
                    beq       L187F
L1897               lbra      L1F6B

L189A               ldx       $12,s
                    ldd       $02,x
                    std       $0a,s
                    ldd       [$12,s]
                    std       $0C,s
                    ldx       $12,s
                    ldd       $04,x
                    std       $06,s
                    lbra      L1F6B

L18B0               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L18C2
                    pshs      u
                    lbsr      L1FBC
                    leas      $02,s
L18C2               ldd       #$0001
                    lbra      L1E0D

L18C8               pshs      u
                    lbsr      L1FBC
                    leas      $02,s
                    lbra      L1E0D

L18D2               pshs      u
                    lbsr      L1FBC
                    leas      $02,s
                    std       $0C,s
                    cmpd      #$0006
                    lbne      L19C3
                    pshs      u
                    lbsr      L265C
                    leas      $02,s
                    pshs      u
                    lbra      L19BE

L18EF               clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L2463
                    leas      $04,s
                    ldd       $02,u
                    std       $0a,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    beq       L1920
                    ldd       $04,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L0477
                    std       ,s
                    lbsr      L418A
                    leas      $06,s
                    bra       L1923

L1920               ldd       #$0001
L1923               ldx       $18,s
                    std       $08,x
                    ldd       $12,u
                    std       $08,s
                    ldd       $06,u
                    cmpd      #$0042
                    lbne      L1AA7
                    ldd       $08,s
                    addd      #$0001
                    lbra      L1AA5

L193F               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1951
                    pshs      u
                    lbsr      L1FBC
                    leas      $02,s
L1951               ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbeq      L19C3
                    ldd       $12,s
                    pshs      d
                    lbsr      L1FBC
                    bra       L19C1

L1969               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2340
                    leas      $04,s
                    std       $0C,s
                    cmpd      #$0006
                    bne       L1982
                    leax      $14,s
                    bra       L19A6

L1982               lbra      L1F6B

L1985               pshs      u
                    lbsr      L1FBC
                    leas      $02,s
                    std       $0C,s
                    cmpd      #$0006
                    beq       L19A9
                    ldd       $12,s
                    pshs      d
                    lbsr      L1FBC
                    leas      $02,s
                    cmpd      #$0006
                    bne       L19C6
                    bra       L19A9

L19A6               leas      -$14,x
L19A9               leax      L26F8,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0293
                    leas      $04,s
                    ldd       $18,s
                    pshs      d
L19BE               lbsr      L25E6
L19C1               leas      $02,s
L19C3               lbra      L1F6B

L19C6               ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L2027
                    lbra      L1A4F

L19D6               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L19ED
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L19FF
L19ED               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2340
                    leas      $04,s
                    cmpd      #$0007
                    bne       L1A09
L19FF               ldd       $0e,s
                    addd      #$0004
                    ldx       $18,s
                    std       $06,x
L1A09               lbra      L1F6B

L1A0C               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1A45
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1A28
                    ldd       #$0001
                    bra       L1A2A

L1A28               clra
                    clrb
L1A2A               bne       L1A51
                    ldd       $12,s
                    pshs      d
                    lbsr      L1FBC
                    leas      $02,s
                    ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L2027
                    bra       L1A4F

L1A45               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2340
L1A4F               leas      $04,s
L1A51               lbra      L1F6B

L1A54               ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1A73
                    leas      -$02,s
                    stu       ,s
                    ldu       $14,s
                    ldd       ,s
                    std       $14,s
                    leas      $02,s
                    ldx       $18,s
                    stu       $0a,x
L1A73               ldd       $02,u
                    std       $0a,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1A8E
                    ldd       $04,u
                    std       $06,s
                    leax      $14,s
                    lbra      L1B8D

L1A8E               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2340
                    leas      $04,s
                    std       $0C,s
                    ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
L1AA5               std       $08,s
L1AA7               lbra      L1F6B

L1AAA               ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
                    std       $08,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L1E01
                    ldd       $02,u
                    std       $0a,s
                    ldd       $04,u
                    std       $06,s
                    ldd       [$12,s]
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L1B90
                    ldd       $08,s
                    ldx       $18,s
                    std       $12,x
                    ldd       $0C,s
                    cmpd      [$12,s]
                    bne       L1AF4
                    ldd       $0a,s
                    ldx       $12,s
                    cmpd      $02,x
                    beq       L1B07
L1AF4               leax      L270E,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0293
                    leas      $04,s
                    lbra      L1B7E

L1B07               ldd       $0C,s
                    pshs      d
                    lbsr      L0477
                    leas      $02,s
                    std       $0C,s
                    ldd       $06,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L418A
                    leas      $06,s
                    std       $0a,s
                    cmpd      #$0001
                    lbeq      L1B7E
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
                    lbsr      L0DD3
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
                    lbsr      L0DD3
                    leas      $0C,s
                    std       $18,s
L1B7E               ldd       #$0002
                    std       $0a,s
                    clra
                    clrb
                    std       $06,s
                    ldd       #$0001
                    lbra      L1E0D

L1B8D               leas      -$14,x
L1B90               ldd       $12,s
                    pshs      d
                    lbsr      L1FBC
                    leas      $02,s
                    ldd       [$12,s]
                    pshs      d
                    lbsr      L262D
                    std       ,s++
                    bne       L1BBA
                    ldd       $12,s
                    pshs      d
                    lbsr      L265C
                    leas      $02,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L25E6
                    leas      $02,s
L1BBA               ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L2027
                    leas      $04,s
                    ldd       $12,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    lbsr      L23C4
                    leas      $08,s
                    ldx       $18,s
                    std       $0C,x
                    ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
                    std       $08,s
                    lbra      L1F6B

L1BF4               clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L2463
                    leas      $04,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L24D3
                    leas      $02,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L25B5
                    leas      $02,s
                    std       $02,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1C3A
                    ldd       $02,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1C3A
                    ldd       $02,s
                    pshs      d
                    lbsr      L262D
                    std       ,s++
                    lbeq      L1CBA
L1C3A               ldd       $02,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1C5D
                    ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L1C5D
                    ldd       $0C,s
                    pshs      d
                    lbsr      L262D
                    std       ,s++
                    lbeq      L1CBA
L1C5D               ldd       $0C,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L2027
                    leas      $04,s
                    leax      $14,s
                    lbra      L1D4F

L1C71               leas      -$14,x
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L2463
                    leas      $04,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L1FBC
                    leas      $02,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L25B5
                    leas      $02,s
                    std       $02,s
                    ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1CCE
                    ldx       $0e,s
                    bra       L1CC0

L1CA6               ldd       #$0001
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L2027
                    leas      $04,s
                    leax      $14,s
                    bra       L1CF0

L1CBA               leax      $14,s
                    lbra      L1D66

L1CC0               cmpx      #$00A1
                    beq       L1CA6
                    cmpx      #$00A0
                    lbeq      L1CA6
                    bra       L1CBA

L1CCE               ldx       $0e,s
                    lbra      L1D40

L1CD3               ldd       $0C,s
                    cmpd      #$0005
                    bne       L1CE0
                    ldd       #$0006
                    bra       L1CE2

L1CE0               ldd       $0C,s
L1CE2               pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L2027
                    leas      $04,s
                    bra       L1CF3

L1CF0               leas      -$14,x
L1CF3               ldd       $0e,s
                    addd      #$FFB0
                    ldx       $18,s
                    std       $06,x
                    ldd       $18,s
                    pshs      d
                    lbsr      L1382
                    leas      $02,s
                    std       $18,s
                    ldd       $0C,s
                    cmpd      #$0002
                    bne       L1D2A
                    ldd       $0a,u
                    ldx       $18,s
                    std       $0a,x
                    pshs      u
                    lbsr      L03B4
                    leas      $02,s
                    ldx       $18,s
                    ldu       $0a,x
                    ldd       #$0001
                    std       $0C,s
L1D2A               ldd       $0e,s
                    addd      #$FFB0
                    ldx       $18,s
                    cmpd      $06,x
                    bne       L1D52
                    ldd       $0e,s
                    ldx       $18,s
                    std       $06,x
                    bra       L1D52

L1D40               cmpx      #$00A6
                    beq       L1CF3
                    cmpx      #$00A5
                    lbeq      L1CF3
                    lbra      L1CD3

L1D4F               leas      -$14,x
L1D52               ldd       $02,u
                    std       $0a,s
                    ldd       $12,u
                    ldx       $12,s
                    addd      $12,x
                    std       $08,s
                    ldd       $04,u
                    lbra      L1E23

L1D66               leas      -$14,x
                    leax      L271F,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0293
                    lbra      L1E44

L1D7A               ldd       ,u
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1DD9
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
                    bne       L1DCC
                    ldd       $0C,s
                    cmpd      [$12,s]
                    bne       L1DB2
                    ldd       $02,u
                    ldx       $12,s
                    cmpd      $02,x
                    beq       L1DC5
L1DB2               leax      L272D,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L0293
                    leas      $04,s
                    lbra      L1F6B

L1DC5               clra
                    clrb
                    std       $06,s
                    lbra      L1F6B

L1DCC               ldd       $12,s
                    pshs      d
L1DD1               lbsr      L1F8E
                    leas      $02,s
                    lbra      L1F6B

L1DD9               ldd       [$12,s]
                    std       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L1E01
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
                    bra       L1DD1

L1E01               ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L2340
                    leas      $04,s
L1E0D               std       $0C,s
                    lbra      L1F6B

L1E12               ldd       [$12,s]
                    std       $0C,s
                    ldx       $12,s
                    ldd       $02,x
                    std       $0a,s
                    ldx       $12,s
                    ldd       $04,x
L1E23               std       $06,s
                    lbra      L1F6B

L1E28               ldd       $0e,s
                    cmpd      #$00A0
                    blt       L1E36
                    leax      $14,s
                    lbra      L1C71

L1E36               leax      L273E,pcr
                    pshs      x
                    ldd       $1a,s
                    pshs      d
                    lbsr      L025F
L1E44               leas      $04,s
                    lbra      L1F6B

L1E49               cmpx      #$0034
                    lbeq      L13B6
                    cmpx      #$0036
                    lbeq      L14D5
                    cmpx      #$004A
                    lbeq      L14DC
                    cmpx      #$004B
                    lbeq      L14EC
                    cmpx      #$0037
                    lbeq      L14FC
                    cmpx      #$0020
                    lbeq      L1507
                    cmpx      #$0041
                    lbeq      L1586
                    cmpx      #$0042
                    lbeq      L15D4
                    cmpx      #$0045
                    lbeq      L1646
                    cmpx      #$0046
                    lbeq      L1700
                    cmpx      #$0065
                    lbeq      L17BE
                    cmpx      #$000B
                    lbeq      L1868
                    cmpx      #$0030
                    lbeq      L189A
                    cmpx      #$0040
                    lbeq      L18B0
                    cmpx      #$0043
                    lbeq      L18C8
                    cmpx      #$0044
                    lbeq      L18D2
                    cmpx      #$003C
                    lbeq      L18EF
                    cmpx      #$003E
                    lbeq      L18EF
                    cmpx      #$003D
                    lbeq      L18EF
                    cmpx      #$003F
                    lbeq      L18EF
                    cmpx      #$0047
                    lbeq      L193F
                    cmpx      #$0048
                    lbeq      L193F
                    cmpx      #$0053
                    lbeq      L1E01
                    cmpx      #$0052
                    lbeq      L1E01
                    cmpx      #$0057
                    lbeq      L1969
                    cmpx      #$0058
                    lbeq      L1969
                    cmpx      #$0059
                    lbeq      L1969
                    cmpx      #$0054
                    lbeq      L1969
                    cmpx      #$0056
                    lbeq      L1985
                    cmpx      #$0055
                    lbeq      L1985
                    cmpx      #$005D
                    lbeq      L19D6
                    cmpx      #$005F
                    lbeq      L19D6
                    cmpx      #$005C
                    lbeq      L19D6
                    cmpx      #$005E
                    lbeq      L19D6
                    cmpx      #$005A
                    lbeq      L1A0C
                    cmpx      #$005B
                    lbeq      L1A0C
                    cmpx      #$0050
                    lbeq      L1A54
                    cmpx      #$0051
                    lbeq      L1AAA
                    cmpx      #$0078
                    lbeq      L1BF4
                    cmpx      #$002F
                    lbeq      L1D7A
                    cmpx      #$0064
                    lbeq      L1E12
                    lbra      L1E28

L1F6B               ldd       $0C,s
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
L1F8E               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L1FA4
                    ldd       $08,u
                    beq       L1FBA
L1FA4               leax      L2749,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0293
                    leas      $04,s
                    ldd       #$0036
                    std       $06,u
                    clra
                    clrb
                    std       $08,u
L1FBA               puls      pc,u
L1FBC               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$02,s
                    pshs      u
                    lbsr      L24D3
                    leas      $02,s
                    ldd       ,u
                    std       ,s
                    tfr       d,x
                    bra       L1FFF

L1FD7               ldd       #$0001
                    bra       L1FDF

L1FDC               ldd       #$0006
L1FDF               std       ,s
                    pshs      d
                    pshs      u
                    bsr       L2027
                    leas      $04,s
                    bra       L201F

L1FEB               leax      L2758,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0293
                    leas      $04,s
                    ldd       #$0001
                    std       ,s
                    bra       L201F

L1FFF               cmpx      #$0002
                    beq       L1FD7
                    cmpx      #$0005
                    beq       L1FDC
                    cmpx      #$0006
                    beq       L201F
                    cmpx      #$0008
                    beq       L201F
                    cmpx      #$0001
                    beq       L201F
                    cmpx      #$0007
                    beq       L201F
                    bra       L1FEB

L201F               ldd       ,s
                    std       ,u
                    leas      $02,s
                    puls      pc,u
L2027               pshs      u
                    ldd       #$FFAC
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       ,u
                    lbra      L22D6

L203C               ldx       $0a,s
                    bra       L2072

L2040               ldd       #$0085
                    bra       L2053

L2045               ldd       #$0001
                    pshs      d
                    pshs      u
                    bsr       L2027
                    leas      $04,s
                    ldd       #$0083
L2053               std       ,s
                    lbra      L2303

L2058               ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    lbra      L2303

L2072               cmpx      #$0001
                    beq       L2040
                    cmpx      #$0007
                    lbeq      L2040
                    cmpx      #$0008
                    beq       L2045
                    cmpx      #$0006
                    beq       L2058
                    cmpx      #$0005
                    lbeq      L2058
                    lbra      L2303

L2092               ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L2303
L209F               ldx       $0a,s
                    lbra      L2137

L20A4               ldd       $06,u
                    cmpd      #$0036
                    bne       L20DF
                    ldd       #$0004
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    std       $02,s
                    ldd       $08,u
                    ldx       $02,s
                    std       $02,x
                    bge       L20C5
                    ldd       #$FFFF
                    bra       L20C7

L20C5               clra
                    clrb
L20C7               std       [$02,s]
                    ldd       $02,s
                    std       $08,u
                    bra       L20D2

L20D0               leas      -$04,x
L20D2               ldd       #$004A
                    std       $06,u
                    ldd       #$0004
L20DA               std       $02,u
                    lbra      L2303

L20DF               ldd       #$0083
                    bra       L2132

L20E4               ldd       #$0001
                    std       $0a,s
                    lbra      L2303

L20EC               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    ldd       #$008D
                    bra       L2132

L20FD               ldd       $06,u
                    cmpd      #$0036
                    bne       L212F
                    ldd       #$0008
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    std       $02,s
                    ldx       $02,s
                    pshs      x
                    ldd       $08,u
                    lbsr      L6A1C
                    lbsr      L69FF
                    bra       L2121

L211F               leas      -$04,x
L2121               ldd       $02,s
                    std       $08,u
                    ldd       #$004B
                    std       $06,u
                    ldd       #$0008
                    bra       L20DA

L212F               ldd       #$008E
L2132               std       ,s
                    lbra      L2303

L2137               cmpx      #$0008
                    lbeq      L20A4
                    cmpx      #$0002
                    lbeq      L20E4
                    cmpx      #$0005
                    beq       L20EC
                    cmpx      #$0006
                    beq       L20FD
                    lbra      L2303

L2152               ldx       $0a,s
                    bra       L217C

L2156               ldd       #$0086
                    bra       L216F

L215B               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    ldd       #$008D
                    bra       L216F

L216C               ldd       #$0092
L216F               std       ,s
                    lbra      L2303

L2174               ldd       #$0001
                    std       $0a,s
                    lbra      L2303

L217C               cmpx      #$0008
                    beq       L2156
                    cmpx      #$0005
                    beq       L215B
                    cmpx      #$0006
                    beq       L216C
                    cmpx      #$0002
                    beq       L2174
                    lbra      L2303

L2193               ldx       $0a,s
                    lbra      L220B

L2198               ldd       $0a,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    lbne      L2303
L21A5               ldd       $06,u
                    cmpd      #$004A
                    bne       L21C8
                    ldd       $08,u
                    std       $02,s
                    ldx       $02,s
                    ldd       $02,x
                    std       $08,u
                    bra       L21BB

L21B9               leas      -$04,x
L21BB               ldd       #$0036
                    std       $06,u
                    ldd       #$0002
                    std       $02,u
                    lbra      L2303

L21C8               ldd       #$0084
                    bra       L2206

L21CD               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    ldd       #$008D
                    bra       L2206

L21DE               ldd       $06,u
                    cmpd      #$004A
                    bne       L2203
                    ldd       #$0008
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    std       $02,s
                    ldx       $02,s
                    pshs      x
                    ldx       $08,u
                    lbsr      L6A3C
                    lbsr      L69FF
                    leax      $04,s
                    lbra      L211F

L2203               ldd       #$0090
L2206               std       ,s
                    lbra      L2303

L220B               cmpx      #$0001
                    lbeq      L21A5
                    cmpx      #$0007
                    lbeq      L21A5
                    cmpx      #$0002
                    lbeq      L21A5
                    cmpx      #$0005
                    beq       L21CD
                    cmpx      #$0006
                    beq       L21DE
                    lbra      L2198

L222D               ldx       $0a,s
                    bra       L2253

L2231               ldd       #$0006
                    pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    lbra      L2303

L224B               ldd       #$008C
                    std       ,s
                    lbra      L2303

L2253               cmpx      #$0008
                    beq       L2231
                    cmpx      #$0007
                    lbeq      L2231
                    cmpx      #$0002
                    lbeq      L2231
                    cmpx      #$0001
                    lbeq      L2231
                    cmpx      #$0006
                    beq       L224B
                    lbra      L2303

L2275               ldx       $0a,s
                    bra       L22B7

L2279               ldd       $06,u
                    cmpd      #$004B
                    bne       L228D
                    ldx       $08,u
                    lbsr      L697C
                    std       $08,u
                    leax      $04,s
                    lbra      L21B9

L228D               ldd       #$008F
                    bra       L22B3

L2292               ldd       $06,u
                    cmpd      #$004B
                    bne       L22AB
                    ldx       $08,u
                    pshs      x
                    ldx       $08,u
                    lbsr      L6981
                    lbsr      L74D3
                    leax      $04,s
                    lbra      L20D0

L22AB               ldd       #$0091
                    bra       L22B3

L22B0               ldd       #$008D
L22B3               std       ,s
                    bra       L2303

L22B7               cmpx      #$0002
                    beq       L2279
                    cmpx      #$0007
                    lbeq      L2279
                    cmpx      #$0001
                    lbeq      L2279
                    cmpx      #$0008
                    beq       L2292
                    cmpx      #$0005
                    beq       L22B0
                    bra       L2303

L22D6               cmpx      #$0002
                    lbeq      L203C
                    cmpx      #$0001
                    lbeq      L209F
                    cmpx      #$0007
                    lbeq      L2152
                    cmpx      #$0008
                    lbeq      L2193
                    cmpx      #$0005
                    lbeq      L222D
                    cmpx      #$0006
                    lbeq      L2275
                    lbra      L2092

L2303               ldd       ,s
                    beq       L233B
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
                    lbsr      L0DD3
                    leas      $0C,s
                    std       $02,s
                    pshs      d
                    pshs      u
                    lbsr      L03C4
                    leas      $04,s
                    ldd       ,s
                    std       $06,u
                    ldd       $02,s
                    std       $0a,u
                    clra
                    clrb
                    std       $0C,u
L233B               ldd       $0a,s
                    lbra      L23B9

L2340               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$04,s
                    pshs      u
                    lbsr      L1FBC
                    leas      $02,s
                    std       $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L1FBC
                    leas      $02,s
                    std       ,s
                    ldd       $02,s
                    cmpd      #$0006
                    bne       L236D
                    ldd       #$0006
                    bra       L2385

L236D               ldd       ,s
                    cmpd      #$0006
                    bne       L237A
                    ldd       #$0006
                    bra       L2398

L237A               ldd       $02,s
                    cmpd      #$0008
                    bne       L238D
                    ldd       #$0008
L2385               pshs      d
                    ldd       $0C,s
                    pshs      d
                    bra       L239C

L238D               ldd       ,s
                    cmpd      #$0008
                    bne       L23A3
                    ldd       #$0008
L2398               pshs      d
                    pshs      u
L239C               lbsr      L2027
                    leas      $04,s
                    bra       L23C0

L23A3               ldd       $02,s
                    cmpd      #$0007
                    beq       L23B3
                    ldd       ,s
                    cmpd      #$0007
                    bne       L23BD
L23B3               ldd       #$0007
                    std       [$0a,s]
L23B9               std       ,u
                    bra       L23C0

L23BD               ldd       #$0001
L23C0               leas      $04,s
                    puls      pc,u
L23C4               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
                    ldd       $08,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L0477
                    std       ,s
                    lbsr      L418A
                    leas      $06,s
                    std       $04,s
                    cmpd      #$0001
                    bne       L23EE
                    ldd       $0a,s
                    puls      pc,u
L23EE               ldx       $0a,s
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
                    lbsr      L0DD3
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
                    lbsr      L0DD3
                    leas      $0C,s
                    pshs      d
                    lbsr      L1005
                    leas      $02,s
                    tfr       d,u
                    ldd       $06,u
                    cmpd      #$0036
                    bne       L244F
                    clra
                    clrb
                    bra       L2452

L244F               ldd       #$0002
L2452               std       $12,u
                    ldd       #$0001
                    std       ,u
                    ldd       #$0002
                    std       $02,u
                    tfr       u,d
                    puls      pc,u
L2463               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    std       ,s
                    tfr       d,x
                    cmpx      #$0076
                    lbeq      L25B1
                    cmpx      #$006F
                    lbeq      L25B1
                    cmpx      #$0042
                    lbeq      L25B1
                    ldd       ,s
                    cmpd      #$0034
                    bne       L24BC
                    pshs      u
                    bsr       L24D3
                    leas      $02,s
                    ldd       $08,s
                    lbne      L25B1
                    ldd       ,u
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L24AE
                    ldd       #$0001
                    bra       L24B0

L24AE               clra
                    clrb
L24B0               bne       L24BC
                    ldd       ,u
                    cmpd      #$0004
                    lbne      L25B1
L24BC               leax      L2763,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0293
                    leas      $04,s
                    pshs      u
                    lbsr      L25E6
                    leas      $02,s
                    lbra      L25B1

L24D3               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       $06,u
                    cmpd      #$0034
                    lbne      L25B3
                    ldd       ,u
                    lbne      L25B3
                    leax      L2773,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0293
                    leas      $04,s
                    pshs      u
                    lbsr      L25E6
                    lbra      L25B1

L2502               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$02,s
                    ldd       ,u
                    std       [$08,s]
                    ldd       $06,u
                    cmpd      #$0041
                    bne       L2541
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
                    lbsr      L03C4
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L03B4
                    leas      $02,s
                    bra       L2546

L2541               clra
                    clrb
                    std       [$0a,s]
L2546               pshs      u
                    lbsr      L24D3
                    leas      $02,s
                    ldd       $06,u
                    cmpd      #$0034
                    bne       L2586
                    ldd       $08,u
                    std       ,s
                    ldx       ,s
                    ldd       $08,x
                    cmpd      #$0011
                    beq       L2567
                    leax      $02,s
                    bra       L2584

L2567               ldd       #$0036
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
                    bra       L25B1
                    bra       L2586

L2584               leas      -$02,x
L2586               leax      L2787,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0293
                    leas      $04,s
                    pshs      u
                    lbsr      L25E6
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
L25B1               leas      $02,s
L25B3               puls      pc,u
L25B5               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       ,u
                    cmpd      #$0004
                    beq       L25CF
                    ldd       ,u
                    cmpd      #$0003
                    bne       L25E2
L25CF               leax      L279E,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0293
                    leas      $04,s
                    pshs      u
                    bsr       L25E6
                    leas      $02,s
L25E2               ldd       ,u
                    puls      pc,u
L25E6               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       #$0006
                    pshs      d
                    pshs      u
                    leax      $018b,y
                    pshs      x
                    lbsr      L01F6
                    leas      $06,s
                    ldd       #$0001
                    std       $12,u
                    ldd       $0a,u
                    pshs      d
                    lbsr      L0393
                    leas      $02,s
                    ldd       $0C,u
                    pshs      d
                    lbsr      L0393
                    leas      $02,s
                    clra
                    clrb
                    std       $0C,u
                    std       $0a,u
                    ldd       #$0034
                    std       $06,u
                    leax      $018b,y
                    stx       $08,u
                    puls      pc,u
L262D               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldx       $04,s
                    bra       L263E

L2639               ldd       #$0001
                    puls      pc,u
L263E               cmpx      #$0001
                    beq       L2639
                    cmpx      #$0002
                    lbeq      L2639
                    cmpx      #$0008
                    lbeq      L2639
                    cmpx      #$0007
                    lbeq      L2639
                    clra
                    clrb
                    puls      pc,u
L265C               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    leax      L27BF,pcr
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      L0293
                    leas      $04,s
                    puls      pc,u
L2675               fcc       /divide by zero/
                    fcb       $00
L2684               fcc       /typedef - not a variable/
                    fcb       $00
L269D               fcc       /cannot cast/
                    fcb       $00
L26A9               fcc       /can't take address/
                    fcb       $00
L26BC               fcc       /pointer required/
                    fcb       $00
L26CD               fcc       /pointer or integer required/
                    fcb       $00
L26E9               fcc       /not a function/
                    fcb       $00
L26F8               fcc       /both must be integral/
                    fcb       $00
L270E               fcc       /pointer mismatch/
                    fcb       $00
L271F               fcc       /type mismatch/
                    fcb       $00
L272D               fcc       /pointer mismatch/
                    fcb       $00
L273E               fcc       /type check/
                    fcb       $00
L2749               fcc       /should be NULL/
                    fcb       $00
L2758               fcc       /type error/
                    fcb       $00
L2763               fcc       /lvalue required/
                    fcb       $00
L2773               fcc       /undeclared variable/
                    fcb       $00
L2787               fcc       /struct member required/
                    fcb       $00
L279E               fcc       /structure or union inappropriate/
                    fcb       $00
L27BF               fcc       /must be integral/
                    fcb       $00
L27D0               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       $005F
                    cmpd      #$0028
                    beq       L27E8
                    clra
                    clrb
                    std       L004F
                    bra       L27E8

L27E6               leas      ,x
L27E8               ldx       $005F
                    lbra      L28E7

L27ED               ldx       $0061
                    bra       L2843

L27F1               lbsr      L2917
                    puls      pc,u
L27F6               lbsr      L29DA
                    puls      pc,u
L27FB               lbsr      L2E93
                    lbra      L290B

L2801               lbsr      L2BF1
                    puls      pc,u
L2806               lbsr      L2A8A
                    puls      pc,u
L280B               lbsr      L2F21
                    lbra      L290B

L2811               lbsr      L2F60
                    lbra      L290B

L2817               lbsr      L2C59
                    puls      pc,u
L281C               lbsr      L2D5A
                    puls      pc,u
L2821               lbsr      L2CAC
                    lbra      L290B

L2827               lbsr      L2F9E
                    lbra      L290B

L282D               leax      L316A,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    lbsr      L552B
                    lbra      L2897

L283E               leax      ,s
                    lbra      L28A0

L2843               cmpx      #$0013
                    beq       L27F1
                    cmpx      #$0014
                    beq       L27F6
                    cmpx      #$0012
                    beq       L27FB
                    cmpx      #$0017
                    beq       L2801
                    cmpx      #$0016
                    beq       L2806
                    cmpx      #$0018
                    beq       L280B
                    cmpx      #$0019
                    beq       L2811
                    cmpx      #$001B
                    beq       L2817
                    cmpx      #$001C
                    beq       L281C
                    cmpx      #$001A
                    beq       L2821
                    cmpx      #$001D
                    beq       L2827
                    cmpx      #$0015
                    beq       L282D
                    bra       L283E

L2881               lbsr      L3A4C
                    lbsr      L552B
                    puls      pc,u
L2889               puls      pc,u
L288B               lbsr      L6345
                    ldb       $0065
                    cmpb      #$3a
                    bne       L289C
                    lbsr      L2FE9
L2897               leax      ,s
                    lbra      L27E6

L289C               leax      ,s
                    bra       L28C8

L28A0               leas      ,x
L28A2               lbsr      L043C
                    std       -$02,s
                    bne       L28B0
                    lbsr      L03DA
                    std       -$02,s
                    beq       L28CA
L28B0               leax      L317D,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L28BB               lbsr      L552B
                    ldd       $005F
                    cmpd      #$0028
                    bne       L28BB
                    bra       L290B

L28C8               leas      ,x
L28CA               clra
                    clrb
                    pshs      d
                    lbsr      L3082
                    std       ,s++
                    bne       L290B
                    leax      L3191,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    lbsr      L04FF
                    puls      pc,u
                    bra       L290B

L28E7               cmpx      #$0028
                    beq       L290B
                    cmpx      #$0033
                    lbeq      L27ED
                    cmpx      #$0029
                    lbeq      L2881
                    cmpx      #$FFFF
                    lbeq      L2889
                    cmpx      #$0034
                    lbeq      L288B
                    lbra      L28A2

L290B               ldd       #$0028
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    puls      pc,u
L2917               pshs      u
                    ldd       #$FFAE
                    lbsr      stkcheck
                    leas      -$06,s
                    lbsr      L552B
                    lbsr      L30E7
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
                    bne       L2966
                    lbsr      L552B
                    clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      L3140
                    leas      $08,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4AC4
                    leas      $02,s
                    stu       $02,s
                    bra       L2988

L2966               ldd       #$0001
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      L3140
                    leas      $08,s
                    pshs      u
                    lbsr      L4AC4
                    leas      $02,s
                    lbsr      L27D0
                    ldd       $04,s
                    std       $02,s
L2988               ldd       $005F
                    cmpd      #$0033
                    bne       L29CD
                    ldd       $0061
                    cmpd      #$0015
                    bne       L29CD
                    lbsr      L552B
                    ldd       $005F
                    cmpd      #$0028
                    beq       L29CD
                    cmpu      $02,s
                    beq       L29CA
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
                    lbsr      L4B5E
                    leas      $06,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4AC4
                    leas      $02,s
L29CA               lbsr      L27D0
L29CD               ldd       $02,s
                    pshs      d
                    lbsr      L4AC4
                    leas      $02,s
                    leas      $06,s
                    puls      pc,u
L29DA               pshs      u
                    ldd       #$FFAA
                    lbsr      stkcheck
                    leas      -$0a,s
                    ldd       L0053
                    std       $08,s
                    ldd       L0055
                    std       $06,s
                    ldd       $02D6,y
                    std       $04,s
                    ldd       $02D8,y
                    std       $02,s
                    lbsr      L552B
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
                    lbsr      L30E7
                    std       ,s
                    ldd       $005F
                    cmpd      #$0028
                    bne       L2A28
                    ldu       L0055
                    bra       L2A4D

L2A28               clra
                    clrb
                    pshs      d
                    ldd       L0055
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    tfr       d,u
                    pshs      u
                    lbsr      L4AC4
                    leas      $02,s
                    lbsr      L27D0
L2A4D               ldd       L0055
                    pshs      d
                    lbsr      L4AC4
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L0053
                    pshs      d
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      L3140
                    leas      $08,s
                    ldd       L0053
                    pshs      d
                    lbsr      L4AC4
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
L2A8A               pshs      u
                    ldd       #$FFA8
                    lbsr      stkcheck
                    leas      -$0e,s
                    lbsr      L552B
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
                    lbsr      L04BC
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      L0580
                    std       ,s
                    lbsr      L0F18
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L2B3E
                    pshs      u
                    lbsr      L24D3
                    leas      $02,s
                    ldx       ,u
                    bra       L2B16

L2AF8               ldd       #$0001
                    pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    bra       L2B2E

L2B06               pshs      u
                    lbsr      L265C
                    leas      $02,s
                    pshs      u
                    lbsr      L25E6
                    leas      $02,s
                    bra       L2B2E

L2B16               cmpx      #$0002
                    beq       L2AF8
                    cmpx      #$0008
                    lbeq      L2AF8
                    cmpx      #$0001
                    beq       L2B2E
                    cmpx      #$0007
                    beq       L2B2E
                    bra       L2B06

L2B2E               pshs      u
                    lbsr      L4C1B
                    leas      $02,s
                    pshs      u
                    lbsr      L0393
                    leas      $02,s
                    bra       L2B41

L2B3E               lbsr      L0E15
L2B41               ldd       #$002E
                    pshs      d
                    lbsr      L04BC
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
                    lbsr      L4B5E
                    leas      $06,s
                    lbsr      L27D0
                    ldd       L004F
                    bne       L2B7D
                    clra
                    clrb
                    pshs      d
                    ldd       L0053
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
L2B7D               ldd       $06,s
                    pshs      d
                    lbsr      L4AC4
                    leas      $02,s
                    ldu       L0059
                    bra       L2BA8

L2B8A               ldd       ,u
                    std       $04,s
                    ldd       $02,u
                    pshs      d
                    ldd       $04,u
                    pshs      d
                    ldd       #$007D
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
                    ldd       L0045
                    std       ,u
                    stu       L0045
                    ldu       $04,s
L2BA8               stu       -$02,s
                    bne       L2B8A
                    ldd       $02D4,y
                    beq       L2BC6
                    clra
                    clrb
                    pshs      d
                    ldd       $02D4,y
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
L2BC6               ldd       L0053
                    pshs      d
                    lbsr      L4AC4
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
                    lbra      L2E8F

L2BF1               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    leas      -$02,s
                    lbsr      L552B
                    clra
                    clrb
                    pshs      d
                    lbsr      L0A4F
                    leas      $02,s
                    std       ,s
                    ldd       #$002F
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    ldd       L0057
                    beq       L2C55
                    ldu       L0045
                    beq       L2C21
                    ldd       ,u
                    std       L0045
                    bra       L2C2D

L2C21               ldd       #$0006
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    tfr       d,u
L2C2D               ldd       L0059
                    beq       L2C37
                    stu       [$005B,y]
                    bra       L2C39

L2C37               stu       L0059
L2C39               stu       $005B
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
                    lbsr      L4AC4
                    leas      $02,s
                    bra       L2CA8

L2C55               bsr       L2C97
                    bra       L2CA8

L2C59               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    lbsr      L552B
                    ldd       L0057
                    bne       L2C6A
                    bsr       L2C97
L2C6A               ldd       $02D4,y
                    beq       L2C7B
                    leax      L319E,pcr
                    pshs      x
                    lbsr      L024B
                    bra       L2C8B

L2C7B               ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $02D4,y
                    pshs      d
                    lbsr      L4AC4
L2C8B               leas      $02,s
                    ldd       #$002F
L2C90               pshs      d
                    lbsr      L04BC
                    bra       L2CA8

L2C97               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    leax      L31B0,pcr
                    pshs      x
                    lbsr      L024B
L2CA8               leas      $02,s
                    puls      pc,u
L2CAC               pshs      u
                    ldd       #$FFAA
                    lbsr      stkcheck
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
                    lbsr      L552B
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $04,s
                    pshs      d
                    lbsr      L4AC4
                    leas      $02,s
                    lbsr      L27D0
                    ldd       $005F
                    cmpd      #$0033
                    bne       L2D0C
                    ldd       $0061
                    cmpd      #$0014
                    beq       L2D17
L2D0C               leax      L31C4,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L2D17               lbsr      L552B
                    ldd       L0055
                    pshs      d
                    lbsr      L4AC4
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L0053
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L30E7
                    pshs      d
                    lbsr      L3140
                    leas      $08,s
                    ldd       L0053
                    pshs      d
                    lbsr      L4AC4
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
L2D5A               pshs      u
                    ldd       #$FFA6
                    lbsr      stkcheck
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
                    lbsr      L552B
                    ldd       #$002D
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      L3082
                    leas      $02,s
                    ldd       #$0028
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    ldd       $005F
                    cmpd      #$0028
                    beq       L2DE0
                    lbsr      L310E
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
                    lbsr      L4B5E
                    leas      $06,s
L2DE0               ldd       #$0028
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      L0580
                    std       ,s
                    lbsr      L0F18
                    leas      $02,s
                    std       ,s
                    beq       L2E0E
                    ldd       ,s
                    pshs      d
                    lbsr      L24D3
                    leas      $02,s
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    bra       L2E10

L2E0E               ldd       $0a,s
L2E10               std       L0055
                    ldd       #$002E
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L4AC4
                    leas      $02,s
                    lbsr      L27D0
                    ldd       ,s
                    beq       L2E3E
                    ldd       L0055
                    pshs      d
                    lbsr      L4AC4
                    leas      $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L30AB
                    leas      $02,s
L2E3E               ldd       $02,s
                    beq       L2E62
                    ldd       $08,s
                    pshs      d
                    lbsr      L4AC4
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
                    lbsr      L3140
                    leas      $08,s
                    bra       L2E74

L2E62               clra
                    clrb
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
L2E74               ldd       L0053
                    pshs      d
                    lbsr      L4AC4
                    leas      $02,s
                    stu       L0053
                    ldd       $0C,s
                    std       L0055
                    ldd       $06,s
                    std       $02D6,y
                    ldd       $04,s
                    std       $02D8,y
L2E8F               leas      $0e,s
                    puls      pc,u
L2E93               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    lbsr      L552B
                    ldd       $005F
                    cmpd      #$0028
                    lbeq      L2F00
                    clra
                    clrb
                    pshs      d
                    lbsr      L0580
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L2F00
                    pshs      u
                    lbsr      L0F18
                    leas      $02,s
                    tfr       d,u
                    pshs      u
                    lbsr      L24D3
                    leas      $02,s
                    pshs      u
                    lbsr      L25B5
                    leas      $02,s
                    ldd       L004D
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L2EDE
                    ldd       #$0001
                    bra       L2EE0

L2EDE               ldd       L004D
L2EE0               pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
                    ldd       L004D
                    pshs      d
                    pshs      u
                    ldd       #$0012
                    pshs      d
                    lbsr      L4C68
                    leas      $06,s
                    pshs      u
                    lbsr      L0393
                    leas      $02,s
L2F00               clra
                    clrb
                    pshs      d
                    lbsr      L4B30
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0012
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
                    ldd       #$0012
                    lbra      L2FE5

L2F21               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    lbsr      L552B
                    ldd       L0053
                    bne       L2F3D
                    leax      L31D3,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    bra       L2F5A

L2F3D               ldd       $02D6,y
                    pshs      d
                    lbsr      L4B30
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L0053
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
L2F5A               ldd       #$0018
                    lbra      L2FE5

L2F60               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    lbsr      L552B
                    ldd       L0055
                    bne       L2F7C
                    leax      L31DF,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    bra       L2F99

L2F7C               ldd       $02D8,y
                    pshs      d
                    lbsr      L4B30
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    ldd       L0055
                    pshs      d
                    ldd       #$007C
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
L2F99               ldd       #$0019
                    bra       L2FE5

L2F9E               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    lbsr      L552B
                    ldd       $005F
                    cmpd      #$0034
                    beq       L2FBE
                    leax      L31EE,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    bra       L2FE2

L2FBE               lbsr      L302B
                    tfr       d,u
                    stu       -$02,s
                    beq       L2FDF
                    clra
                    clrb
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$001D
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
                    ldd       $0a,u
                    orb       #$02
                    std       $0a,u
L2FDF               lbsr      L552B
L2FE2               ldd       #$001D
L2FE5               std       L004F
                    puls      pc,u
L2FE9               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    bsr       L302B
                    tfr       d,u
                    stu       -$02,s
                    beq       L3023
                    ldd       $08,u
                    cmpd      #$000F
                    bne       L3006
                    lbsr      L023E
                    bra       L3023

L3006               ldd       #$000F
                    std       $08,u
                    clra
                    clrb
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    ldd       #$0009
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
                    ldd       $0a,u
                    orb       #$01
                    std       $0a,u
L3023               lbsr      L552B
                    lbsr      L552B
                    puls      pc,u
L302B               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldu       $0061
                    ldd       ,u
                    cmpd      #$0009
                    lbeq      L313C
                    ldd       ,u
                    beq       L305D
                    ldd       $0C,u
                    beq       L3056
                    leax      L31FD,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    clra
                    clrb
                    puls      pc,u
L3056               pshs      u
                    lbsr      L017D
                    leas      $02,s
L305D               ldd       #$0009
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
                    lbra      L313C

L3082               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    lbsr      L0580
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    lbeq      L313C
                    pshs      u
                    lbsr      L0F18
                    std       ,s
                    bsr       L30AB
                    leas      $02,s
                    tfr       d,u
                    lbra      L313C

L30AB               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldu       $04,s
                    pshs      u
                    lbsr      L24D3
                    leas      $02,s
                    ldx       $06,u
                    bra       L30CC

L30C0               ldd       #$003C
                    bra       L30C8

L30C5               ldd       #$003D
L30C8               std       $06,u
                    bra       L30D6

L30CC               cmpx      #$003E
                    beq       L30C0
                    cmpx      #$003F
                    beq       L30C5
L30D6               pshs      u
                    lbsr      L4C4F
                    leas      $02,s
                    tfr       d,u
                    pshs      u
                    lbsr      L0393
                    lbra      L313A

L30E7               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    leas      -$02,s
                    ldd       #$002D
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    bsr       L310E
                    std       ,s
                    ldd       #$002E
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    ldd       ,s
                    lbra      L3166

L310E               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    clra
                    clrb
                    pshs      d
                    lbsr      L0580
                    std       ,s
                    lbsr      L0F18
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L3131
                    pshs      u
                    lbsr      L24D3
                    bra       L313A

L3131               leax      L3216,pcr
                    pshs      x
                    lbsr      L024B
L313A               leas      $02,s
L313C               tfr       u,d
                    puls      pc,u
L3140               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    stu       -$02,s
                    beq       L3168
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L4C2C
                    leas      $08,s
                    pshs      u
                    lbsr      L0393
L3166               leas      $02,s
L3168               puls      pc,u
L316A               fcc       /no 'if' for 'else'/
                    fcb       $00
L317D               fcc       /illegal declaration/
                    fcb       $00
L3191               fcc       /syntax error/
                    fcb       $00
L319E               fcc       /multiple defaults/
                    fcb       $00
L31B0               fcc       /no switch statement/
                    fcb       $00
L31C4               fcc       /while expected/
                    fcb       $00
L31D3               fcc       /break error/
                    fcb       $00
L31DF               fcc       /continue error/
                    fcb       $00
L31EE               fcc       /label required/
                    fcb       $00
L31FD               fcc       /already a local variable/
                    fcb       $00
L3216               fcc       /condition needed/
                    fcb       $00
L3227               pshs      u
                    ldd       #$FFA2
                    lbsr      stkcheck
                    leas      -$14,s
                    bra       L3242

L3234               leax      L42F4,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    lbsr      L552B
L3242               ldd       $005F
                    cmpd      #$002A
                    beq       L3234
                    ldd       $005F
                    cmpd      #$0029
                    bne       L3277
                    leax      L4306,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    clra
                    clrb
                    pshs      d
                    lbsr      L3A4C
                    leas      $02,s
                    leax      >$0049,y
                    pshs      x
                    lbsr      L4204
                    leas      $02,s
                    lbsr      L552B
                    lbra      L34D1

L3277               lbsr      L3BE6
                    std       $0a,s
                    tfr       d,x
                    bra       L3292

L3280               leax      L431E,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L328B               ldd       #$000C
                    std       $0a,s
                    bra       L32A2

L3292               cmpx      #$0010
                    beq       L3280
                    cmpx      #$000D
                    lbeq      L3280
                    stx       -$02,s
                    beq       L328B
L32A2               leax      ,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    leax      $16,s
                    pshs      x
                    lbsr      L3C35
                    leas      $06,s
                    std       $08,s
                    bne       L32BD
                    ldd       #$0001
                    std       $08,s
L32BD               ldd       $04,s
                    std       $0C,s
                    ldd       $08,s
                    pshs      d
                    leax      $0e,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      L3F8A
                    leas      $06,s
                    std       $06,s
                    ldu       $02,s
                    bne       L32F1
                    ldd       $06,s
                    cmpd      #$0004
                    beq       L32EB
                    ldd       $06,s
                    cmpd      #$0003
                    beq       L32EB
                    lbsr      L42DF
L32EB               leax      $14,s
                    lbra      L34B1

L32F1               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L3316
                    ldd       $005F
                    cmpd      #$0030
                    beq       L330C
                    ldd       $005F
                    cmpd      #$0028
                    bne       L3311
L330C               ldd       #$000E
                    bra       L3318

L3311               ldd       #$000C
                    bra       L3318

L3316               ldd       $0a,s
L3318               std       $0e,s
                    ldd       ,u
                    beq       L3364
                    ldd       ,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
                    lbsr      L387B
                    leas      $06,s
                    std       -$02,s
                    lbne      L3438
                    ldd       $0e,s
                    cmpd      #$000E
                    lbeq      L3438
                    ldd       $08,u
                    cmpd      #$000E
                    beq       L3353
                    ldd       $08,u
                    cmpd      #$0022
                    beq       L3353
                    lbsr      L023E
                    lbra      L3438

L3353               ldd       $0e,s
                    std       $08,u
                    ldd       $0C,s
                    std       $04,u
                    ldd       ,s
                    std       $0a,u
                    leax      $14,s
                    bra       L3376

L3364               ldd       $06,s
                    std       ,u
                    clra
                    clrb
                    std       $0C,u
                    ldd       $0e,s
                    std       $08,u
                    ldd       ,s
                    std       $0a,u
                    bra       L3379

L3376               leas      -$14,x
L3379               ldd       $12,s
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    pshs      u
                    lbsr      L4100
                    leas      $06,s
                    std       $10,s
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    lbeq      L3438
                    ldd       $005F
                    cmpd      #$0078
                    bne       L33B4
                    ldd       $06,s
                    pshs      d
                    ldd       $10,s
                    pshs      d
                    pshs      u
                    lbsr      L4432
L33AF               leas      $06,s
                    lbra      L341E

L33B4               ldd       $10,s
                    bne       L33C7
                    ldd       $0e,s
                    cmpd      #$000E
                    beq       L33C7
                    lbsr      L42D1
                    lbra      L341E

L33C7               ldx       $0e,s
                    bra       L3406

L33CB               ldd       $0e,s
                    cmpd      #$0023
                    bne       L33D8
                    ldd       #$0001
                    bra       L33DA

L33D8               clra
                    clrb
L33DA               pshs      d
                    ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L66F8
                    bra       L33AF

L33E8               ldd       $0e,s
                    cmpd      #$0021
                    bne       L33F5
                    ldd       #$0001
                    bra       L33F7

L33F5               clra
                    clrb
L33F7               pshs      d
                    ldd       $12,s
                    pshs      d
                    pshs      u
                    lbsr      L66E8
                    lbra      L33AF

L3406               cmpx      #$0023
                    beq       L33CB
                    cmpx      #$000F
                    lbeq      L33CB
                    cmpx      #$0021
                    beq       L33E8
                    cmpx      #$000C
                    lbeq      L33E8
L341E               ldd       $0e,s
                    cmpd      #$000F
                    bne       L342B
                    ldd       #$000C
                    bra       L3436

L342B               ldd       $0e,s
                    cmpd      #$0023
                    bne       L3438
                    ldd       #$0021
L3436               std       $08,u
L3438               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    lbne      L34B4
                    ldd       $06,s
                    pshs      d
                    lbsr      L0477
                    leas      $02,s
                    std       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L3474
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L3474
                    ldd       $06,s
                    cmpd      #$0004
                    beq       L3474
                    ldd       $06,s
                    cmpd      #$0003
                    bne       L3489
L3474               leax      L432C,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    ldd       #$0031
                    std       ,u
                    ldd       #$0001
                    std       $06,s
L3489               ldd       $0e,s
                    cmpd      #$000E
                    bne       L349E
                    leax      >$0047,y
                    pshs      x
                    lbsr      L4204
                    leas      $02,s
                    bra       L34B4

L349E               ldd       $06,s
                    std       L004D
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L3904
                    leas      $04,s
                    bra       L34D1
                    bra       L34B4

L34B1               leas      -$14,x
L34B4               ldd       $005F
                    cmpd      #$0030
                    bne       L34C2
                    lbsr      L552B
                    lbra      L32BD

L34C2               ldd       #$0028
                    pshs      d
                    lbsr      L04BC
                    std       ,s++
                    beq       L34D1
                    lbsr      L04FF
L34D1               leas      $14,s
                    puls      pc,u
L34D6               pshs      u
                    ldd       #$FFA4
                    lbsr      stkcheck
                    leas      -$12,s
                    lbsr      L3BE6
                    std       $10,s
                    tfr       d,x
                    bra       L34FE

L34EB               leax      L4340,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L34F6               ldd       #$000D
                    std       $10,s
                    bra       L3509

L34FE               stx       -$02,s
                    beq       L34F6
                    cmpx      #$0010
                    beq       L3509
                    bra       L34EB

L3509               leax      ,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    lbsr      L3C35
                    leas      $06,s
                    std       $0e,s
                    bne       L3523
                    ldd       #$0001
                    std       $0e,s
L3523               ldd       $0a,s
                    std       $0C,s
                    ldd       $0e,s
                    pshs      d
                    leax      $0e,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      L3F8A
                    leas      $06,s
                    std       $04,s
                    ldu       $02,s
                    ldd       $04,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L3557
                    ldd       $04,s
                    cmpd      #$0004
                    beq       L3557
                    ldd       $04,s
                    cmpd      #$000A
                    bne       L3564
L3557               leax      L4351,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    bra       L3595

L3564               ldd       $04,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L357F
                    ldd       $04,s
                    pshs      d
                    lbsr      L0477
                    std       ,s
                    lbsr      L0483
                    leas      $02,s
                    bra       L358A

L357F               ldd       $04,s
                    cmpd      #$0005
                    bne       L358C
                    ldd       #$0006
L358A               std       $04,s
L358C               cmpu      #$0000
                    bne       L359B
                    lbsr      L42DF
L3595               leax      $12,s
                    lbra      L35F8

L359B               ldd       $04,s
                    pshs      d
                    ldd       $12,s
                    pshs      d
                    lbsr      L38AF
                    leas      $04,s
                    std       $06,s
                    ldx       $08,u
                    bra       L35E5

L35AF               ldd       $04,s
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
                    lbsr      L4100
                    leas      $06,s
                    std       -$02,s
                    bne       L35FB
                    lbsr      L42D1
                    bra       L35FB

L35D3               lbsr      L023E
                    bra       L35FB

L35D8               leax      L4360,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    bra       L35FB

L35E5               cmpx      #$000B
                    beq       L35AF
                    cmpx      #$000D
                    beq       L35D3
                    cmpx      #$0010
                    lbeq      L35D3
                    bra       L35D8

L35F8               leas      -$12,x
L35FB               ldd       $005F
                    cmpd      #$0078
                    bne       L3606
                    lbsr      L497D
L3606               ldd       $005F
                    cmpd      #$0030
                    bne       L3614
                    lbsr      L552B
                    lbra      L3523

L3614               ldd       #$0028
                    pshs      d
                    lbsr      L04BC
                    std       ,s++
                    lbeq      L3876
                    lbsr      L04FF
                    lbra      L3876

L3628               pshs      u
                    ldd       #$FF9E
                    lbsr      stkcheck
                    leas      -$12,s
                    lbsr      L3BE6
                    std       $10,s
                    tfr       d,x
                    bra       L3650

L363D               leax      L4370,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L3648               ldd       #$000D
                    std       $10,s
                    bra       L3659

L3650               cmpx      #$0021
                    beq       L363D
                    stx       -$02,s
                    beq       L3648
L3659               leax      $02,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    leax      $0C,s
                    pshs      x
                    lbsr      L3C35
                    leas      $06,s
                    std       $0e,s
                    bne       L3673
                    ldd       #$0001
                    std       $0e,s
L3673               leas      -$06,s
                    ldd       $10,s
                    std       ,s
                    ldd       $14,s
                    pshs      d
                    leax      $02,s
                    pshs      x
                    leax      $0e,s
                    pshs      x
                    lbsr      L3F8A
                    leas      $06,s
                    std       $12,s
                    ldu       $0a,s
                    bne       L36AF
                    ldd       $12,s
                    cmpd      #$0004
                    lbeq      L371A
                    ldd       $12,s
                    cmpd      #$0003
                    lbeq      L371A
                    lbsr      L42DF
                    lbra      L371A

L36AF               ldd       $12,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    beq       L36C4
                    ldd       $16,s
                    cmpd      #$000E
                    bne       L36FB
L36C4               ldd       ,u
                    bne       L36E9
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
                    lbsr      L4100
                    bra       L36F7

L36E9               ldd       $08,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    pshs      u
                    lbsr      L387B
L36F7               leas      $06,s
                    bra       L371A

L36FB               ldd       $12,s
                    pshs      d
                    ldd       $18,s
                    pshs      d
                    lbsr      L38AF
                    leas      $04,s
                    std       $04,s
                    ldd       ,u
                    beq       L3727
                    ldd       $0C,u
                    cmpd      L0051
                    bne       L3720
                    lbsr      L023E
L371A               leax      $18,s
                    lbra      L3855

L3720               pshs      u
                    lbsr      L017D
                    leas      $02,s
L3727               ldd       $12,s
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
                    lbsr      L4100
                    leas      $06,s
                    std       $02,s
                    bne       L375D
                    ldd       $005F
                    cmpd      #$0078
                    beq       L375D
                    lbsr      L42D1
L375D               ldx       $04,s
                    bra       L3776

L3761               ldd       L0031
                    subd      $02,s
                    std       L0031
                    ldd       L0031
                    bra       L3772

L376B               ldd       L002B
                    addd      #$0001
                    std       L002B
L3772               std       $06,u
                    bra       L3787

L3776               cmpx      #$000D
                    beq       L3761
                    cmpx      #$0023
                    beq       L376B
                    cmpx      #$000F
                    lbeq      L376B
L3787               ldd       $005F
                    cmpd      #$0078
                    lbne      L3824
                    ldd       $04,s
                    cmpd      #$000F
                    beq       L37A1
                    ldd       $04,s
                    cmpd      #$0023
                    bne       L37B4
L37A1               ldd       $12,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L4432
L37AF               leas      $06,s
                    lbra      L3858

L37B4               lbsr      L552B
                    ldd       $12,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    lbeq      L381F
                    ldd       $12,s
                    cmpd      #$0004
                    lbeq      L381F
                    ldd       #$0002
                    pshs      d
                    lbsr      L0580
                    leas      $02,s
                    std       $0C,s
                    beq       L381F
                    ldd       $0009
                    beq       L37F3
                    ldd       $0009
                    std       $06,s
                    tfr       d,x
                    ldd       ,x
                    std       $0009
                    clra
                    clrb
                    std       [$06,s]
                    bra       L37FF

L37F3               ldd       #$0006
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    std       $06,s
L37FF               ldd       $0C,s
                    ldx       $06,s
                    std       $02,x
                    ldx       $06,s
                    stu       $04,x
                    ldd       $0005
                    beq       L3815
                    ldd       $06,s
                    std       [$0007,y]
                    bra       L3819

L3815               ldd       $06,s
                    std       $0005
L3819               ldd       $06,s
                    std       $0007
                    bra       L3858

L381F               lbsr      L497D
                    bra       L3858

L3824               ldx       $04,s
                    bra       L3847

L3828               ldd       $04,s
                    cmpd      #$0023
                    bne       L3835
                    ldd       #$0001
                    bra       L3837

L3835               clra
                    clrb
L3837               pshs      d
                    ldd       $04,s
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    lbsr      L66BE
                    lbra      L37AF

L3847               cmpx      #$000F
                    beq       L3828
                    cmpx      #$0023
                    lbeq      L3828
                    bra       L3858

L3855               leas      -$18,x
L3858               ldd       $005F
                    cmpd      #$0030
                    beq       L3864
                    leas      $06,s
                    bra       L386C

L3864               lbsr      L552B
                    leas      $06,s
                    lbra      L3673

L386C               ldd       #$0028
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
L3876               leas      $12,s
                    puls      pc,u
L387B               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       ,u
                    cmpd      $06,s
                    bne       L389B
                    ldd       $06,s
                    cmpd      #$0004
                    bne       L38AB
                    ldd       $0a,u
                    cmpd      $08,s
                    beq       L38AB
L389B               leax      L437E,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    ldd       #$0001
                    puls      pc,u
L38AB               clra
                    clrb
                    puls      pc,u
L38AF               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldd       $04,s
                    cmpd      #$0010
                    bne       L3900
                    ldd       $0003
                    cmpd      #$0001
                    bge       L38FB
                    ldx       $06,s
                    bra       L38ED

L38CB               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L38FB
L38D6               ldd       $0003
                    addd      #$0001
                    std       $0003
                    cmpd      #$0001
                    bne       L38E8
                    ldd       #$006F
                    bra       L38EB

L38E8               ldd       #$0076
L38EB               puls      pc,u
L38ED               cmpx      #$0001
                    beq       L38D6
                    cmpx      #$0007
                    lbeq      L38D6
                    bra       L38CB

L38FB               ldd       #$000D
                    puls      pc,u
L3900               ldd       $04,s
                    puls      pc,u
L3904               pshs      u
                    ldd       #$FFAC
                    lbsr      stkcheck
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
                    bra       L3924

L3921               lbsr      L34D6
L3924               ldd       $005F
                    cmpd      #$0029
                    bne       L3921
                    ldd       $0e,s
                    addd      #$0014
                    std       $02,s
                    ldd       L0037
                    beq       L394B
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       ,s
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L679C
                    leas      $04,s
L394B               ldd       ,s
                    pshs      d
                    ldd       $12,s
                    cmpd      #$000F
                    beq       L395D
                    ldd       #$0001
                    bra       L395F

L395D               clra
                    clrb
L395F               pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L673F
                    leas      $06,s
                    ldu       L0047
                    ldd       #$0004
                    std       $08,s
                    lbra      L39E8

L3974               leas      -$02,s
                    ldd       $0a,s
                    std       $06,u
                    ldx       ,u
                    bra       L3996

L397E               ldd       #$0004
                    bra       L3992

L3983               ldd       #$0008
                    bra       L3992

L3988               ldd       $06,u
                    addd      #$0001
                    std       $06,u
L398F               ldd       #$0002
L3992               std       ,s
                    bra       L39AE

L3996               cmpx      #$0008
                    beq       L397E
                    cmpx      #$0005
                    lbeq      L397E
                    cmpx      #$0006
                    beq       L3983
                    cmpx      #$0002
                    beq       L3988
                    bra       L398F

L39AE               ldd       $08,u
                    std       $08,s
                    tfr       d,x
                    bra       L39CC

L39B6               ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L4B5E
                    leas      $04,s
                    bra       L39DD

L39C5               ldd       #$000D
                    std       $08,u
                    bra       L39DD

L39CC               cmpx      #$006F
                    beq       L39B6
                    cmpx      #$0076
                    lbeq      L39B6
                    cmpx      #$000B
                    beq       L39C5
L39DD               ldd       $0a,s
                    addd      ,s
                    std       $0a,s
                    ldu       $10,u
                    leas      $02,s
L39E8               stu       -$02,s
                    lbne      L3974
                    ldd       L0047
                    std       $04,s
                    clra
                    clrb
                    std       L0047
                    lbsr      L3A4C
                    leax      $04,s
                    pshs      x
                    lbsr      L4204
                    leas      $02,s
                    leax      >$0049,y
                    pshs      x
                    lbsr      L4204
                    leas      $02,s
                    ldd       L004F
                    cmpd      #$0012
                    beq       L3A27
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       #$0012
                    pshs      d
                    lbsr      L4B5E
                    leas      $06,s
L3A27               clra
                    clrb
                    std       L004F
                    lbsr      L67CE
                    clra
                    clrb
                    std       L0051
                    ldd       $005F
                    cmpd      #$FFFF
                    bne       L3A45
                    leax      L4393,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L3A45               lbsr      L552B
                    leas      $0a,s
                    puls      pc,u
L3A4C               pshs      u
                    ldd       #$FFAA
                    lbsr      stkcheck
                    leas      -$06,s
                    ldd       $004B
                    std       $02,s
                    clra
                    clrb
                    std       $004B
                    lbsr      L552B
                    ldd       L0051
                    addd      #$0001
                    std       L0051
                    ldd       L0031
                    std       ,s
                    bra       L3A71

L3A6E               lbsr      L3628
L3A71               lbsr      L043C
                    std       -$02,s
                    bne       L3A6E
                    lbsr      L03DA
                    std       -$02,s
                    lbne      L3A6E
                    ldd       L003B
                    cmpd      L0031
                    ble       L3A8C
                    ldd       L0031
                    std       L003B
L3A8C               ldd       L0031
                    pshs      d
                    lbsr      L4B30
                    leas      $02,s
                    std       $002F
                    lbra      L3B0A

L3A9A               ldd       $0005
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
                    lbsr      L0DD3
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
                    lbsr      L0DD3
                    leas      $0C,s
                    tfr       d,u
                    pshs      u
                    lbsr      L0F18
                    std       ,s
                    lbsr      L4C4F
                    std       ,s
                    lbsr      L0393
                    leas      $02,s
                    ldd       [$04,s]
                    std       $04,s
                    ldd       $0009
                    std       [$0005,y]
                    ldd       $0005
                    std       $0009
                    ldd       $04,s
                    std       $0005
L3B0A               ldd       $0005
                    lbne      L3A9A
                    bra       L3B15

L3B12               lbsr      L27D0
L3B15               ldd       $005F
                    cmpd      #$002A
                    beq       L3B25
                    ldd       $005F
                    cmpd      #$FFFF
                    bne       L3B12
L3B25               leax      >$004b,y
                    pshs      x
                    lbsr      L4204
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
                    beq       L3B52
                    ldd       ,s
                    pshs      d
                    lbsr      L4B30
                    leas      $02,s
                    bra       L3B54

L3B52               ldd       ,s
L3B54               std       $002F
                    leas      $06,s
                    puls      pc,u
L3B5A               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    leas      -$02,s
                    clra
                    clrb
                    std       [$06,s]
L3B69               lbsr      L552B
                    ldd       $005F
                    cmpd      #$002E
                    lbeq      L3BDA
                    ldd       $005F
                    cmpd      #$0034
                    bne       L3BCD
                    ldu       $0061
                    ldd       $08,u
                    cmpd      #$000B
                    bne       L3B93
                    leax      L43A7,pcr
                    pshs      x
                    lbsr      L024B
                    bra       L3B9C

L3B93               ldd       ,u
                    beq       L3B9E
                    pshs      u
                    lbsr      L017D
L3B9C               leas      $02,s
L3B9E               ldd       #$0001
                    std       ,u
                    ldd       #$000B
                    std       $08,u
                    ldd       #$0001
                    std       $0C,u
                    ldd       #$0002
                    std       $02,u
                    ldd       [$06,s]
                    beq       L3BBE
                    ldx       ,s
                    stu       $10,x
                    bra       L3BC1

L3BBE               stu       [$06,s]
L3BC1               clra
                    clrb
                    std       $10,u
                    stu       ,s
                    lbsr      L552B
                    bra       L3BD0

L3BCD               lbsr      L42DF
L3BD0               ldd       $005F
                    cmpd      #$0030
                    lbeq      L3B69
L3BDA               ldd       #$002E
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    bra       L3C31

L3BE6               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    leas      -$02,s
                    lbsr      L043C
                    std       -$02,s
                    beq       L3C2F
                    ldd       $0061
                    std       ,s
                    lbsr      L552B
                    ldd       $005F
                    cmpd      #$0033
                    bne       L3C2B
                    ldd       $0061
                    cmpd      #$0021
                    bne       L3C2B
                    ldx       ,s
                    bra       L3C1E

L3C12               ldd       #$0023
                    bra       L3C1A

L3C17               ldd       #$0022
L3C1A               std       ,s
                    bra       L3C28

L3C1E               cmpx      #$000F
                    beq       L3C12
                    cmpx      #$000E
                    beq       L3C17
L3C28               lbsr      L552B
L3C2B               ldd       ,s
                    bra       L3C31

L3C2F               clra
                    clrb
L3C31               leas      $02,s
                    puls      pc,u
L3C35               pshs      u
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
                    ldd       $005F
                    cmpd      #$0033
                    lbne      L3F51
                    ldd       $0061
                    std       $02,s
                    tfr       d,x
                    lbra      L3F0F

L3C61               ldd       #$0001
                    std       $02,s
L3C66               lbsr      L552B
                    ldd       $005F
                    cmpd      #$0033
                    lbne      L3F79
                    ldd       $0061
                    cmpd      #$0001
                    lbne      L3F79
                    bra       L3CB7

L3C7F               ldd       #$0001
                    bra       L3CB5

L3C84               lbsr      L552B
                    ldd       #$0004
                    std       ,s
                    ldd       $005F
                    cmpd      #$0033
                    lbne      L3F79
                    ldd       $0061
                    cmpd      #$0001
                    beq       L3CB7
                    ldd       $0061
                    cmpd      #$0005
                    lbne      L3F79
L3CA8               ldd       #$0006
                    std       $02,s
                    ldd       #$0008
                    bra       L3CB5

L3CB2               ldd       #$0004
L3CB5               std       ,s
L3CB7               lbsr      L552B
                    lbra      L3F79

L3CBD               clra
                    clrb
                    std       $02,s
                    lbra      L3F79

L3CC4               clra
                    clrb
                    std       $16,s
                    std       ,s
                    ldd       $0041
                    addd      #$0001
                    std       $0041
                    clra
                    clrb
                    std       $18,s
                    lbsr      L552B
                    ldd       $0041
                    addd      #$FFFF
                    std       $0041
                    ldd       $005F
                    cmpd      #$0034
                    lbne      L3D5D
                    ldd       $0061
                    std       $18,s
                    ldd       [$18,s]
                    bne       L3D05
                    ldd       #$000A
                    std       [$18,s]
                    ldd       #$0008
                    ldx       $18,s
                    std       $08,x
                    bra       L3D1B

L3D05               ldx       $18,s
                    ldd       $08,x
                    cmpd      #$0008
                    beq       L3D1B
                    leax      L43B3,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L3D1B               lbsr      L552B
                    ldd       $005F
                    cmpd      #$0029
                    beq       L3D51
                    ldd       [$18,s]
                    cmpd      #$0004
                    bne       L3D45
                    ldx       $18,s
                    ldd       $02,x
                    std       [$1e,s]
                    ldx       $18,s
                    ldd       $0a,x
                    std       [$22,s]
                    ldd       #$0004
                    lbra      L3F85

L3D45               ldd       $18,s
                    std       [$1e,s]
                    ldd       #$000A
                    lbra      L3F85

L3D51               ldd       [$18,s]
                    cmpd      #$0004
                    bne       L3D5D
                    lbsr      L023E
L3D5D               ldd       $005F
                    cmpd      #$0029
                    beq       L3D73
                    leax      L43BE,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    lbra      L3F79

L3D73               ldd       $0041
                    addd      #$0001
                    std       $0041
L3D7A               ldd       $0041
                    std       $10,s
                    clra
                    clrb
                    std       $0041
                    lbsr      L552B
                    ldd       $10,s
                    std       $0041
                    ldd       $005F
                    cmpd      #$002A
                    lbeq      L3EE2
                    leax      $04,s
                    pshs      x
                    leax      $0e,s
                    pshs      x
                    leax      $18,s
                    pshs      x
                    lbsr      L3C35
                    leas      $06,s
                    std       $12,s
                    bra       L3DAC

L3DAC               leas      -$04,s
                    ldd       $10,s
                    std       $02,s
                    ldd       $005F
                    cmpd      #$0028
                    lbeq      L3ECC
                    ldd       L0051
                    addd      #$0001
                    std       L0051
                    ldd       $16,s
                    pshs      d
                    leax      $04,s
                    pshs      x
                    leax      $04,s
                    pshs      x
                    lbsr      L3F8A
                    leas      $06,s
                    std       $12,s
                    ldu       ,s
                    ldd       L0051
                    addd      #$FFFF
                    std       L0051
                    cmpu      #$0000
                    bne       L3DF1
                    lbsr      L42DF
                    leax      $1e,s
                    lbra      L3EC1

L3DF1               ldd       ,u
                    beq       L3E26
                    ldd       $0C,u
                    cmpd      L0051
                    bne       L3E1F
                    ldd       ,u
                    cmpd      $12,s
                    bne       L3E14
                    ldd       $08,u
                    cmpd      #$0011
                    bne       L3E14
                    ldd       $06,u
                    cmpd      $1a,s
                    beq       L3E26
L3E14               leax      L43CC,pcr
                    pshs      x
                    lbsr      L024B
                    bra       L3E24

L3E1F               pshs      u
                    lbsr      L017D
L3E24               leas      $02,s
L3E26               ldd       $12,s
                    cmpd      #$000A
                    bne       L3E3A
                    leax      L43E3,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
L3E3A               ldd       $12,s
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
                    lbsr      L4100
                    leas      $06,s
                    std       $0e,s
                    beq       L3E84
                    ldd       $06,s
                    cmpd      #$0004
                    bne       L3E73
                    ldd       $1a,s
                    addd      $0e,s
                    std       $1a,s
                    bra       L3E80

L3E73               ldd       $0e,s
                    cmpd      $04,s
                    ble       L3E7E
                    ldd       $0e,s
                    bra       L3E80

L3E7E               ldd       $04,s
L3E80               std       $04,s
                    bra       L3E87

L3E84               lbsr      L42D1
L3E87               ldd       L0051
                    std       $0C,u
                    ldd       $004B
                    std       $10,u
                    stu       $004B
                    ldd       $06,s
                    cmpd      #$0004
                    bne       L3EC4
                    ldd       #$0004
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    std       $0C,s
                    ldx       $0C,s
                    stu       $02,x
                    ldd       [$26,s]
                    beq       L3EB6
                    ldd       $0C,s
                    std       [$0a,s]
                    bra       L3EBB

L3EB6               ldd       $0C,s
                    std       [$26,s]
L3EBB               ldd       $0C,s
                    std       $0a,s
                    bra       L3EC4

L3EC1               leas      -$1e,x
L3EC4               ldd       $005F
                    cmpd      #$0030
                    beq       L3ED0
L3ECC               leas      $04,s
                    bra       L3ED8

L3ED0               lbsr      L552B
                    leas      $04,s
                    lbra      L3DAC

L3ED8               ldd       $005F
                    cmpd      #$0028
                    lbeq      L3D7A
L3EE2               ldd       $0041
                    addd      #$FFFF
                    std       $0041
                    ldd       $18,s
                    beq       L3F03
                    ldd       ,s
                    ldx       $18,s
                    std       $02,x
                    ldd       #$0004
                    std       [$18,s]
                    ldd       [$22,s]
                    ldx       $18,s
                    std       $0a,x
L3F03               ldd       #$002A
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    bra       L3F79

L3F0F               cmpx      #$000A
                    lbeq      L3C61
                    cmpx      #$0007
                    lbeq      L3C66
                    cmpx      #$0002
                    lbeq      L3C7F
                    cmpx      #$0001
                    lbeq      L3CB7
                    cmpx      #$0008
                    lbeq      L3C84
                    cmpx      #$0006
                    lbeq      L3CA8
                    cmpx      #$0005
                    lbeq      L3CB2
                    cmpx      #$0003
                    lbeq      L3CC4
                    cmpx      #$0004
                    lbeq      L3CC4
                    lbra      L3CBD

L3F51               ldd       $005F
                    cmpd      #$0034
                    bne       L3F79
                    ldu       $0061
                    ldd       $08,u
                    cmpd      #_start
                    bne       L3F79
                    ldd       $02,u
                    std       [$1e,s]
                    ldd       $04,u
                    std       [$20,s]
                    ldd       $0a,u
                    std       [$22,s]
                    lbsr      L552B
                    ldd       ,u
                    bra       L3F85

L3F79               ldd       ,s
                    std       [$1e,s]
                    clra
                    clrb
                    std       [$20,s]
                    ldd       $02,s
L3F85               leas      $1a,s
                    puls      pc,u
L3F8A               pshs      u
                    ldd       #$FFAA
                    lbsr      stkcheck
                    leas      -$0C,s
                    clra
                    clrb
                    std       [$10,s]
                    std       $0a,s
                    bra       L3FAB

L3F9D               ldd       $0a,s
                    pshs      d
                    lbsr      L0483
                    leas      $02,s
                    std       $0a,s
                    lbsr      L552B
L3FAB               ldd       $005F
                    cmpd      #$0042
                    beq       L3F9D
                    ldd       $005F
                    cmpd      #$0034
                    bne       L3FC5
                    ldd       $0061
                    std       [$10,s]
                    lbsr      L552B
                    bra       L3FFF

L3FC5               ldd       $005F
                    cmpd      #$002D
                    bne       L3FFF
                    lbsr      L552B
                    ldd       L0051
                    addd      #$0001
                    std       L0051
                    ldd       $14,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    ldd       $14,s
                    pshs      d
                    lbsr      L3F8A
                    leas      $06,s
                    std       $14,s
                    ldd       L0051
                    addd      #$FFFF
                    std       L0051
                    ldd       #$002E
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
L3FFF               ldd       $005F
                    cmpd      #$002D
                    bne       L4036
                    ldd       $0a,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0030
                    std       $0a,s
                    ldd       L0051
                    bne       L4021
                    leax      >$0047,y
                    pshs      x
                    lbsr      L3B5A
                    bra       L4031

L4021               leax      ,s
                    pshs      x
                    lbsr      L3B5A
                    leas      $02,s
                    leax      ,s
                    pshs      x
                    lbsr      L4204
L4031               leas      $02,s
                    lbra      L40B9

L4036               clra
                    clrb
                    std       $06,s
                    std       $04,s
                    std       $02,s
                    ldd       $0041
                    std       $08,s
                    clra
                    clrb
                    std       $0041
                    lbra      L409D

L4049               ldd       $0a,s
                    aslb
                    rola
                    aslb
                    rola
                    addd      #$0020
                    std       $0a,s
                    lbsr      L552B
                    ldd       #$0004
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    tfr       d,u
                    ldd       $04,s
                    bne       L4073
                    ldd       $005F
                    cmpd      #$002C
                    bne       L4073
                    clra
                    clrb
                    bra       L407C

L4073               clra
                    clrb
                    pshs      d
                    lbsr      L0A4F
                    leas      $02,s
L407C               std       ,u
                    ldd       $06,s
                    beq       L4088
                    ldx       $06,s
                    stu       $02,x
                    bra       L408A

L4088               stu       $02,s
L408A               stu       $06,s
                    ldd       #$002C
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    ldd       $04,s
                    addd      #$0001
                    std       $04,s
L409D               ldd       $005F
                    cmpd      #$002B
                    lbeq      L4049
                    ldd       $08,s
                    std       $0041
                    ldd       $02,s
                    beq       L40B9
                    ldd       [$12,s]
                    std       $02,u
                    ldd       $02,s
                    std       [$12,s]
L40B9               ldd       $0a,s
                    pshs      d
                    ldd       $16,s
                    pshs      d
                    bsr       L40CA
                    leas      $04,s
                    leas      $0C,s
                    puls      pc,u
L40CA               pshs      u
                    ldd       #$FFBC
                    lbsr      stkcheck
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
                    bra       L40F2

L40DA               ldd       ,s
                    pshs      d
                    ldd       #$0002
                    lbsr      L765D
                    std       ,s
                    ldd       $08,s
                    pshs      d
                    ldd       #$0002
                    lbsr      L7680
                    std       $08,s
L40F2               ldd       ,s
                    clra
                    andb      #$30
                    bne       L40DA
                    ldd       $06,s
                    addd      $08,s
                    lbra      L42F0

L4100               pshs      u
                    ldd       #$FFB2
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$04,s
                    ldd       ,u
                    std       $02,s
                    clra
                    andb      #$0f
                    tfr       d,x
                    bra       L4135

L4117               ldd       #$0001
                    bra       L4131

L411C               ldd       #$0002
                    bra       L4131

L4121               ldd       #$0004
                    bra       L4131

L4126               ldd       #$0008
                    bra       L4131

L412B               ldd       $0C,s
                    bra       L4131

L412F               clra
                    clrb
L4131               std       ,s
                    bra       L4168

L4135               cmpx      #$0002
                    beq       L4117
                    cmpx      #$0001
                    beq       L411C
                    cmpx      #$0007
                    lbeq      L411C
                    cmpx      #$0008
                    beq       L4121
                    cmpx      #$0005
                    lbeq      L4121
                    cmpx      #$0006
                    beq       L4126
                    cmpx      #$0003
                    beq       L412B
                    cmpx      #$0004
                    lbeq      L412B
                    cmpx      #$000A
                    beq       L412F
L4168               ldd       ,s
                    beq       L4170
                    ldd       ,s
                    bra       L4172

L4170               ldd       $0C,s
L4172               std       $02,u
                    ldd       $0a,s
                    std       $04,u
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    bsr       L418A
                    leas      $06,s
                    leas      $04,s
                    puls      pc,u
L418A               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldu       $08,s
                    leas      -$02,s
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L41AC
                    ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0030
                    bne       L41B2
L41AC               ldd       #$0002
                    lbra      L42F0

L41B2               ldd       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L41FF
                    ldd       #$0001
                    std       ,s
L41C2               ldd       ,s
                    pshs      d
                    ldd       ,u
                    lbsr      L753F
                    std       ,s
                    ldu       $02,u
                    ldd       $06,s
                    pshs      d
                    lbsr      L0477
                    leas      $02,s
                    std       $06,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L41C2
                    ldd       ,s
                    pshs      d
                    ldd       $08,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L41F7
                    ldd       #$0002
                    bra       L41F9

L41F7               ldd       $0a,s
L41F9               lbsr      L753F
                    lbra      L42F0

L41FF               ldd       $08,s
                    lbra      L42F0

L4204               pshs      u
                    ldd       #$FF74
                    lbsr      stkcheck
                    leas      -$40,s
                    ldu       [$44,s]
                    lbra      L42C1

L4215               ldd       $10,u
                    std       $3C,s
                    ldd       ,u
                    cmpd      #$0009
                    bne       L4255
                    ldd       $0a,u
                    clra
                    andb      #$01
                    bne       L4255
                    ldd       #$0008
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    leax      L43F7,pcr
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      L7311
                    leas      $04,s
                    pshs      d
                    lbsr      L7409
                    leas      $06,s
                    pshs      d
                    lbsr      L024B
                    leas      $02,s
L4255               ldx       $08,u
                    bra       L4262

L4259               ldd       $0003
                    addd      #$FFFF
                    std       $0003
                    bra       L426E

L4262               cmpx      #$006F
                    beq       L4259
                    cmpx      #$0076
                    lbeq      L4259
L426E               ldd       $0e,u
                    std       $3e,s
                    cmpd      L0066
                    bls       L4289
                    ldd       $3e,s
                    cmpd      $0068
                    bcc       L4289
                    pshs      u
                    lbsr      L01CF
                    leas      $02,s
                    bra       L42BE

L4289               cmpu      [$3e,s]
                    bne       L4297
                    ldd       $12,u
                    std       [$3e,s]
                    bra       L42B7

L4297               ldd       [$3e,s]
                    bra       L42A2

L429C               ldx       $3e,s
                    ldd       $12,x
L42A2               std       $3e,s
                    ldx       $3e,s
                    cmpu      $12,x
                    bne       L429C
                    ldd       $12,u
                    ldx       $3e,s
                    std       $12,x
L42B7               ldd       L0019
                    std       $12,u
                    stu       L0019
L42BE               ldu       $3C,s
L42C1               stu       -$02,s
                    lbne      L4215
                    clra
                    clrb
                    std       [$44,s]
                    leas      $40,s
                    puls      pc,u
L42D1               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    leax      L440A,pcr
                    bra       L42EB

L42DF               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    leax      L441F,pcr
L42EB               pshs      x
                    lbsr      L024B
L42F0               leas      $02,s
                    puls      pc,u
L42F4               fcc       /too many brackets/
                    fcb       $00
L4306               fcc       /function header missing/
                    fcb       $00
L431E               fcc       /storage error/
                    fcb       $00
L432C               fcc       /function type error/
                    fcb       $00
L4340               fcc       /argument storage/
                    fcb       $00
L4351               fcc       /argument error/
                    fcb       $00
L4360               fcc       /not an argument/
                    fcb       $00
L4370               fcc       /storage error/
                    fcb       $00
L437E               fcc       /declaration mismatch/
                    fcb       $00
L4393               fcc       /function unfinished/
                    fcb       $00
L43A7               fcc       /named twice/
                    fcb       $00
L43B3               fcc       /name clash/
                    fcb       $00
L43BE               fcc       /struct syntax/
                    fcb       $00
L43CC               fcc       /struct member mismatch/
                    fcb       $00
L43E3               fcc       /undefined structure/
                    fcb       $00
L43F7               fcc       /label undefined : /
                    fcb       $00
L440A               fcc       /cannot evaluate size/
                    fcb       $00
L441F               fcc       /identifier missing/
                    fcb       $00
L4432               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$04,s
                    ldx       $0a,s
                    bra       L4458

L4442               lbsr      L497D
                    lbra      L456C

L4448               ldd       #$0001
                    bra       L444F

L444D               clra
                    clrb
L444F               pshs      d
                    lbsr      L6811
                    leas      $02,s
                    bra       L4479

L4458               cmpx      #_start
                    beq       L4442
                    cmpx      #$000E
                    lbeq      L4442
                    cmpx      #$0022
                    lbeq      L4442
                    cmpx      #$0021
                    beq       L4448
                    cmpx      #$0023
                    lbeq      L4448
                    bra       L444D

L4479               ldd       L0051
                    bne       L44AB
                    leax      $14,u
                    stx       $02,s
                    ldd       $0a,s
                    cmpd      #$000F
                    beq       L4497
                    ldd       $0a,s
                    cmpd      #$0023
                    beq       L4497
                    ldd       #$0001
                    bra       L449E

L4497               ldd       #$000C
                    std       $08,u
                    clra
                    clrb
L449E               pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L4A20
                    leas      $04,s
                    bra       L44BA

L44AB               lbsr      L4BEC
                    ldd       $06,u
                    pshs      d
                    lbsr      L4B01
                    leas      $02,s
                    lbsr      L4A74
L44BA               ldd       $0C,s
                    cmpd      #$0022
                    bne       L450E
                    ldd       #$0001
                    std       $000B
                    lbsr      L552B
                    ldd       $005F
                    cmpd      #$0037
                    bne       L4507
                    ldd       $04,u
                    std       $02,s
                    ldd       [$02,s]
                    bne       L44E2
                    ldd       L0017
                    std       [$02,s]
                    bra       L44FF

L44E2               ldd       [$02,s]
                    subd      L0017
                    std       ,s
                    blt       L44F4
                    ldd       ,s
                    pshs      d
                    lbsr      L603C
                    bra       L44FD

L44F4               leax      L49BE,pcr
                    pshs      x
                    lbsr      L024B
L44FD               leas      $02,s
L44FF               lbsr      L552B
                    leax      $04,s
                    lbra      L4563

L4507               ldd       #$0002
                    std       $000B
                    bra       L4516

L450E               ldd       #$0002
                    std       $000B
                    lbsr      L552B
L4516               ldd       $0C,s
                    cmpd      #$0004
                    bne       L4533
                    clra
                    clrb
                    pshs      d
                    ldd       $0a,u
L4524               pshs      d
                    pshs      u
                    ldd       $12,s
                    pshs      d
                    bsr       L4570
                    leas      $08,s
                    bra       L4565

L4533               ldd       $0C,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    bne       L4546
                    clra
                    clrb
                    pshs      d
                    ldd       $04,u
                    bra       L4524

L4546               ldd       #$0001
                    pshs      d
                    ldd       $04,u
                    pshs      d
                    pshs      u
                    ldd       $12,s
                    pshs      d
                    bsr       L4570
                    leas      $08,s
                    std       -$02,s
                    bne       L4565
                    lbsr      L4994
                    bra       L4565

L4563               leas      -$04,x
L4565               lbsr      L6821
                    clra
                    clrb
                    std       $000B
L456C               leas      $04,s
                    puls      pc,u
L4570               pshs      u
                    ldd       #$FFA8
                    lbsr      stkcheck
                    ldu       $06,s
                    leas      -$0C,s
                    ldd       $16,s
                    bne       L458D
                    ldd       #$0029
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
                    bra       L45A3

L458D               ldd       $005F
                    cmpd      #$0029
                    bne       L459F
                    ldd       #$0001
                    std       $0a,s
                    lbsr      L552B
                    bra       L45A3

L459F               clra
                    clrb
                    std       $0a,s
L45A3               ldd       $10,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    lbne      L4691
                    ldd       [$14,s]
                    std       $02,s
                    bne       L45BD
                    ldd       #$FFFF
                    std       $02,s
L45BD               ldd       $10,s
                    pshs      d
                    lbsr      L0477
                    leas      $02,s
                    std       $08,s
                    cmpd      #$0004
                    bne       L45D3
                    ldd       $0a,u
                    bra       L45D8

L45D3               ldx       $14,s
                    ldd       $02,x
L45D8               std       $04,s
                    clra
                    clrb
                    std       $06,s
                    bra       L4616

L45E0               ldd       $16,s
                    addd      #$0001
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       $0e,s
                    pshs      d
                    lbsr      L4570
                    leas      $08,s
                    std       -$02,s
                    lbeq      L4748
                    ldd       $06,s
                    addd      #$0001
                    std       $06,s
                    cmpd      $02,s
                    bcc       L461E
                    ldd       $005F
                    cmpd      #$0030
                    bne       L461E
                    lbsr      L552B
                    bra       L4616

L4616               ldd       $005F
                    cmpd      #$002A
                    bne       L45E0
L461E               ldd       $02,s
                    cmpd      #$FFFF
                    bne       L462D
                    ldd       $06,s
                    std       [$14,s]
                    bra       L465C

L462D               ldd       $06,s
                    cmpd      $02,s
                    bcc       L465C
                    ldx       $14,s
                    ldd       $02,x
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    lbsr      L418A
                    leas      $06,s
                    pshs      d
                    ldd       $04,s
                    subd      $08,s
                    lbsr      L753F
                    pshs      d
                    lbsr      L474E
                    leas      $02,s
                    bra       L465C

L465A               leas      -$0C,x
L465C               ldd       $16,s
                    beq       L4667
                    ldd       $0a,s
                    lbeq      L4735
L4667               ldd       $005F
                    cmpd      #$0030
                    bne       L4672
                    lbsr      L552B
L4672               ldd       $005F
                    cmpd      #$002A
                    bne       L4680
                    lbsr      L552B
                    lbra      L4735

L4680               leax      L49C7,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    lbsr      L4994
                    lbra      L4735

L4691               ldd       $10,s
                    cmpd      #$0004
                    lbne      L471C
                    ldd       $14,s
                    std       ,s
                    bne       L46EA
                    leax      L49D9,pcr
                    lbra      L473E

L46AA               ldx       ,s
                    ldu       $02,x
                    ldd       $16,s
                    addd      #$0001
                    pshs      d
                    ldd       ,u
                    cmpd      #$0004
                    bne       L46C2
                    ldd       $0a,u
                    bra       L46C4

L46C2               ldd       $04,u
L46C4               pshs      d
                    pshs      u
                    ldd       ,u
                    pshs      d
                    lbsr      L4570
                    leas      $08,s
                    std       -$02,s
                    lbeq      L4748
                    ldd       [,s]
                    std       ,s
                    beq       L4713
                    ldd       $005F
                    cmpd      #$0030
                    bne       L4713
                    lbsr      L552B
                    bra       L46EA

L46EA               ldd       $005F
                    cmpd      #$002A
                    bne       L46AA
                    bra       L4713

L46F4               ldx       ,s
                    ldu       $02,x
                    ldd       $04,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       ,u
                    pshs      d
                    lbsr      L418A
                    leas      $06,s
                    pshs      d
                    bsr       L474E
                    leas      $02,s
                    ldd       [,s]
                    std       ,s
L4713               ldd       ,s
                    bne       L46F4
                    leax      $0C,s
                    lbra      L465A

L471C               ldd       $10,s
                    pshs      d
                    bsr       L4772
                    std       ,s++
                    beq       L473A
                    ldd       $0a,s
                    beq       L4735
                    ldd       #$002A
                    pshs      d
                    lbsr      L04BC
                    leas      $02,s
L4735               ldd       #$0001
                    bra       L474A

L473A               leax      L49EC,pcr
L473E               pshs      x
                    lbsr      L024B
                    leas      $02,s
                    lbsr      L4994
L4748               clra
                    clrb
L474A               leas      $0C,s
                    puls      pc,u
L474E               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    lbsr      L4BEC
                    leax      L4A09,pcr
                    pshs      x
                    lbsr      L4A44
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4AB1
                    leas      $02,s
                    lbsr      L4A74
                    puls      pc,u
L4772               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
                    leas      -$08,s
                    ldd       #$0002
                    pshs      d
                    lbsr      L0580
                    std       ,s
                    lbsr      L0F18
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L4796
                    clra
                    clrb
                    lbra      L490F

L4796               clra
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
                    bne       L47D5
                    ldx       ,s
                    bra       L47C4

L47B2               ldd       #$0001
                    bra       L47FE

L47B7               ldd       ,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    beq       L4807
                    bra       L47EB

L47C4               cmpx      #$0008
                    beq       L47B2
                    cmpx      #$0001
                    beq       L4807
                    cmpx      #$0007
                    beq       L4807
                    bra       L47B7

L47D5               ldd       ,s
                    clra
                    andb      #$30
                    cmpd      #$0010
                    bne       L47EF
                    ldd       $0C,s
                    pshs      d
                    lbsr      L262D
                    std       ,s++
                    bne       L4807
L47EB               leax      $08,s
                    bra       L4827

L47EF               ldd       $0C,s
                    cmpd      #$0005
                    bne       L47FC
                    ldd       #$0006
                    bra       L47FE

L47FC               ldd       $0C,s
L47FE               pshs      d
                    pshs      u
                    lbsr      L2027
                    leas      $04,s
L4807               ldd       $06,u
                    cmpd      #$0050
                    beq       L4817
                    ldd       $06,u
                    cmpd      #$0051
                    bne       L4860
L4817               ldd       $0C,u
                    std       $06,s
                    tfr       d,x
                    ldd       $06,x
                    cmpd      #$0036
                    beq       L4832
                    bra       L4829

L4827               leas      -$08,x
L4829               clra
                    clrb
                    std       $02,s
                    leax      $08,s
                    lbra      L4904

L4832               ldd       $06,u
                    cmpd      #$0051
                    bne       L4844
                    ldx       $06,s
                    ldd       $08,x
                    nega
                    negb
                    sbca      #$00
                    bra       L4848

L4844               ldx       $06,s
                    ldd       $08,x
L4848               std       $04,s
                    ldd       $06,s
                    pshs      d
                    lbsr      L0393
                    leas      $02,s
                    stu       $06,s
                    ldu       $0a,u
                    ldd       $06,s
                    pshs      d
                    lbsr      L03B4
                    leas      $02,s
L4860               ldd       $06,u
                    cmpd      #$0041
                    bne       L48B7
                    ldd       $0a,u
                    std       $06,s
                    tfr       d,x
                    ldx       $08,x
                    ldx       $08,x
                    bra       L4894

L4874               clra
                    clrb
                    std       $02,s
                    lbra      L4906

L487B               ldd       #$0001
                    std       $000D
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L509E
                    leas      $04,s
                    clra
                    clrb
                    std       $000D
                    lbra      L4906

L4894               cmpx      #$000F
                    beq       L487B
                    cmpx      #$000E
                    lbeq      L487B
                    cmpx      #$000C
                    lbeq      L487B
                    cmpx      #$0021
                    lbeq      L487B
                    cmpx      #$0022
                    lbeq      L487B
                    bra       L4874

L48B7               ldx       $06,u
                    bra       L48EB

L48BB               ldd       $0C,s
                    cmpd      #$0005
                    bne       L48CF
                    ldx       $08,u
                    pshs      x
                    ldx       $08,u
                    lbsr      L6959
                    lbsr      L69FF
L48CF               ldd       $0C,s
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    bsr       L4913
                    leas      $04,s
                    bra       L4906

L48DD               lbsr      L67EF
                    ldd       $08,u
                    pshs      d
                    lbsr      L4AE8
                    leas      $02,s
                    bra       L4906

L48EB               cmpx      #$004B
                    beq       L48BB
                    cmpx      #$0036
                    beq       L48CF
                    cmpx      #$004A
                    lbeq      L48CF
                    cmpx      #$0037
                    beq       L48DD
                    lbra      L4874

L4904               leas      -$08,x
L4906               pshs      u
                    lbsr      L0393
                    leas      $02,s
                    ldd       $02,s
L490F               leas      $08,s
                    puls      pc,u
L4913               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$02,s
                    ldx       $08,s
                    bra       L4949

L4923               lbsr      L67E4
                    pshs      u
                    lbsr      L4AB1
                    leas      $02,s
                    lbsr      L4A74
                    bra       L4979

L4932               ldd       #$0001
                    bra       L493A

L4937               ldd       #$0002
L493A               std       ,s
                    bra       L496E

L493E               ldd       $08,s
                    pshs      d
                    pshs      u
                    lbsr      L5066
                    bra       L4977

L4949               cmpx      #$0002
                    beq       L4923
                    cmpx      #$0001
                    beq       L4932
                    cmpx      #$0007
                    lbeq      L4932
                    cmpx      #$0008
                    beq       L4937
                    cmpx      #$0005
                    beq       L493E
                    cmpx      #$0006
                    lbeq      L493E
                    lbra      L4932

L496E               ldd       ,s
                    pshs      d
                    pshs      u
                    lbsr      L4FDE
L4977               leas      $04,s
L4979               leas      $02,s
                    puls      pc,u
L497D               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    leax      L4A0E,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    bsr       L4994
                    puls      pc,u
L4994               pshs      u
                    ldd       #$FFBC
                    lbsr      stkcheck
L499C               ldx       $005F
                    bra       L49A7

L49A0               puls      pc,u
L49A2               lbsr      L552B
                    bra       L499C

L49A7               cmpx      #$0030
                    beq       L49A0
                    cmpx      #$0028
                    lbeq      L49A0
                    cmpx      #$FFFF
                    lbeq      L49A0
                    bra       L49A2
                    puls      pc,u
L49BE               fcc       /too long/
                    fcb       $00
L49C7               fcc       /too many elements/
                    fcb       $00
L49D9               fcc       /unions not allowed/
                    fcb       $00
L49EC               fcc       /constant expression required/
                    fcb       $00
L4A09               fcc       /rzb /
                    fcb       $00
L4A0E               fcc       /cannot initialize/
                    fcb       $00
L4A20               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    lbsr      L4BEC
                    ldd       $04,s
                    pshs      d
                    lbsr      L4B1D
                    leas      $02,s
                    ldd       $06,s
                    lbeq      L4AFC
                    ldd       #$003A
                    pshs      d
                    bsr       L4A85
                    lbra      L4AFA

L4A44               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldd       $0025
                    pshs      d
                    ldd       #$0020
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       $04,s
                    pshs      d
                    bsr       L4A9B
                    lbra      L5062
                    pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    bsr       L4A44
                    lbra      L4AFA

L4A74               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldd       $0025
                    pshs      d
                    ldd       #$000D
                    bra       L4A93

L4A85               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldd       $0025
                    pshs      d
                    ldd       $06,s
L4A93               pshs      d
                    lbsr      L6F01
                    lbra      L4BC1

L4A9B               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    ldd       $0025
                    pshs      d
                    lbsr      fprintf
                    lbra      L4BC1

L4AB1               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    leax      L50BE,pcr
                    lbra      L4C0F

L4AC4               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldd       #$006C
                    pshs      d
                    bsr       L4A85
                    leas      $02,s
                    ldd       $0025
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    clra
                    clrb
                    std       L004F
                    puls      pc,u
L4AE8               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    clra
                    clrb
                    std       L004F
                    ldd       $04,s
                    pshs      d
                    bsr       L4B01
L4AFA               leas      $02,s
L4AFC               lbsr      L4A74
                    puls      pc,u
L4B01               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       #$005F
                    pshs      d
                    lbsr      L4A85
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    lbsr      L4AB1
                    lbra      L5062

L4B1D               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    leax      L50C1,pcr
                    lbra      L4C0F

L4B30               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    leas      -$02,s
                    ldd       $06,s
                    subd      $002F
                    std       ,s
                    beq       L4B59
                    ldd       #$004D
                    pshs      d
                    lbsr      L4A85
                    leas      $02,s
                    ldd       $0025
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
L4B59               ldd       $06,s
                    lbra      L5062

L4B5E               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldu       $0025
                    ldx       $04,s
                    lbra      L4BC5

L4B6D               ldd       #$004A
                    pshs      d
                    lbsr      L4A85
                    leas      $02,s
                    pshs      u
                    ldd       $0a,s
                    bra       L4BA0

L4B7D               ldd       #$0072
                    lbra      L4BF7

L4B83               ldd       #$0047
                    bra       L4BB1

L4B88               ldd       #$006A
                    bra       L4BB1

L4B8D               ldd       #$0044
                    pshs      d
                    lbsr      L4A85
                    leas      $02,s
                    pshs      u
                    ldd       L002B
                    addd      #$0001
                    std       L002B
L4BA0               pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    bra       L4BB8

L4BA9               ldd       #$0059
                    bra       L4BB1

L4BAE               ldd       #$0055
L4BB1               pshs      d
                    lbsr      L4A85
                    leas      $02,s
L4BB8               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L6FA6
L4BC1               leas      $04,s
                    puls      pc,u
L4BC5               cmpx      #$007D
                    lbeq      L4B6D
                    cmpx      #$0012
                    beq       L4B7D
                    cmpx      #$001D
                    beq       L4B83
                    cmpx      #$007C
                    beq       L4B88
                    cmpx      #$0009
                    beq       L4B8D
                    cmpx      #$0076
                    beq       L4BA9
                    cmpx      #$006F
                    beq       L4BAE
                    puls      pc,u
L4BEC               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       #$002A
L4BF7               pshs      d
                    lbsr      L4A85
                    lbra      L5062

L4BFF               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    leax      L50C6,pcr
L4C0F               pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      fprintf
                    lbra      L4E15

L4C1B               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    ldd       #$0001
                    bra       L4C5E

L4C2C               pshs      u
                    ldd       #$FFB2
                    lbsr      stkcheck
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
                    bsr       L4C68
                    leas      $0a,s
                    bra       L4C64

L4C4F               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    ldd       #$0004
L4C5E               pshs      d
                    bsr       L4C68
                    leas      $04,s
L4C64               ldd       $04,s
                    puls      pc,u
L4C68               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldu       $0025
                    pshs      u
                    ldd       #$0054
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    pshs      u
                    ldd       $06,s
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    pshs      u
                    ldd       L002B
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    pshs      u
                    ldd       $002F
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    ldx       $04,s
                    bra       L4CD7

L4CA3               pshs      u
                    ldd       $0a,s
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    pshs      u
                    ldd       $0C,s
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    pshs      u
                    ldd       $0e,s
                    pshs      d
                    lbsr      L6F01
                    bra       L4CD3

L4CC4               pshs      u
                    ldd       $000D
                    bra       L4CCE

L4CCA               pshs      u
                    ldd       $0a,s
L4CCE               pshs      d
                    lbsr      L6FA6
L4CD3               leas      $04,s
                    bra       L4CE6

L4CD7               cmpx      #$0002
                    beq       L4CA3
                    cmpx      #$0005
                    beq       L4CC4
                    cmpx      #$0012
                    beq       L4CCA
L4CE6               ldd       L002B
                    pshs      d
                    ldd       $06,s
                    cmpd      #$0002
                    bne       L4CF7
                    ldd       #$0001
                    bra       L4CF9

L4CF7               clra
                    clrb
L4CF9               pshs      d
                    ldd       $0a,s
                    pshs      d
                    bsr       L4D0C
                    leas      $04,s
                    addd      ,s++
                    std       L002B
                    ldd       $06,s
                    lbra      L4E39

L4D0C               pshs      u
                    ldd       #$FFB0
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$06,s
                    stu       -$02,s
                    lbeq      L4E13
                    ldx       $06,u
                    lbra      L4D7E

L4D23               ldd       $0C,s
                    beq       L4D2C
                    ldd       #$0001
                    bra       L4D2F

L4D2C               ldd       #$0004
L4D2F               std       $04,s
                    ldd       #$0001
                    bra       L4D6B

L4D36               ldd       #$0003
                    std       $04,s
                    ldd       #$0001
                    bra       L4D6D

L4D40               ldd       $0C,s
                    beq       L4D48
                    clra
                    clrb
                    bra       L4D4B

L4D48               ldd       #$0003
L4D4B               std       $04,s
                    clra
                    clrb
                    bra       L4D6B

L4D51               ldd       #$0003
                    std       $04,s
                    ldd       #$0001
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    lbra      L4DF1

L4D62               ldd       #$0001
                    std       $04,s
                    clra
                    clrb
                    std       $0C,s
L4D6B               std       ,s
L4D6D               std       $02,s
                    lbra      L4DF1

L4D72               clra
                    clrb
                    std       $0C,s
                    std       ,s
                    std       $02,s
                    std       $04,s
                    bra       L4DF1

L4D7E               cmpx      #$0047
                    lbeq      L4D23
                    cmpx      #$0048
                    lbeq      L4D23
                    cmpx      #$0040
                    lbeq      L4D36
                    cmpx      #$005A
                    lbeq      L4D40
                    cmpx      #$005B
                    lbeq      L4D40
                    cmpx      #$005C
                    lbeq      L4D40
                    cmpx      #$005D
                    lbeq      L4D40
                    cmpx      #$005E
                    lbeq      L4D40
                    cmpx      #$005F
                    lbeq      L4D40
                    cmpx      #$0060
                    lbeq      L4D40
                    cmpx      #$0061
                    lbeq      L4D40
                    cmpx      #$0062
                    lbeq      L4D40
                    cmpx      #$0063
                    lbeq      L4D40
                    cmpx      #$0064
                    lbeq      L4D51
                    cmpx      #$004B
                    lbeq      L4D62
                    cmpx      #$004A
                    lbeq      L4D62
                    lbra      L4D72

L4DF1               ldd       $02,s
                    pshs      d
                    ldd       $0a,u
                    pshs      d
                    lbsr      L4D0C
                    leas      $04,s
                    addd      $04,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       $0C,u
                    pshs      d
                    lbsr      L4D0C
                    leas      $04,s
                    addd      ,s++
                    bra       L4E15

L4E13               clra
                    clrb
L4E15               leas      $06,s
                    puls      pc,u
L4E19               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldu       $04,s
                    stu       -$02,s
                    lbeq      L5064
                    pshs      u
                    bsr       L4E41
                    leas      $02,s
                    ldd       $0a,u
                    pshs      d
                    bsr       L4E19
                    leas      $02,s
                    ldd       $0C,u
L4E39               pshs      d
                    lbsr      L4E19
                    lbra      L5062

L4E41               pshs      u
                    ldd       #$FFAA
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $0a,u
                    beq       L4E5A
                    ldd       $0C,u
                    beq       L4E5A
                    ldd       #$0042
                    bra       L4E6F

L4E5A               ldd       $0a,u
                    beq       L4E63
                    ldd       #$004C
                    bra       L4E6F

L4E63               ldd       $0C,u
                    beq       L4E6C
                    ldd       #$0052
                    bra       L4E6F

L4E6C               ldd       #$004E
L4E6F               std       ,s
                    ldd       $0025
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       ,u
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $06,u
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $0e,u
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    leax      $060C,y
                    pshs      x
                    ldd       $10,u
                    subd      ,s++
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $12,u
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $14,u
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    ldd       $06,u
                    cmpd      #$0034
                    lbne      L4F4F
                    ldu       $08,u
                    ldd       $0025
                    pshs      d
                    ldd       ,u
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldx       $08,u
                    bra       L4F33

L4F0E               pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    lbsr      L4B1D
                    leas      $02,s
                    ldd       $0025
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L6F01
                    lbra      L4FD9

L4F2A               ldd       $0025
                    pshs      d
                    ldd       $06,u
                    lbra      L4FD4

L4F33               cmpx      #$000E
                    beq       L4F0E
                    cmpx      #$000C
                    lbeq      L4F0E
                    cmpx      #$0021
                    lbeq      L4F0E
                    cmpx      #$0022
                    lbeq      L4F0E
                    bra       L4F2A

L4F4F               ldd       $06,u
                    cmpd      #$004A
                    bne       L4F8B
                    leas      -$04,s
                    leax      ,s
                    pshs      x
                    bsr       L4F63
                    fcb       $00,$00,$00,$00
L4F63               puls      x
                    lbsr      L74D3
                    ldd       $0025
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0004
                    pshs      d
                    ldu       $08,u
                    beq       L4F7E
                    tfr       u,d
                    bra       L4F82

L4F7E               leax      $06,s
                    tfr       x,d
L4F82               pshs      d
                    lbsr      $6EB7
                    leas      $08,s
                    bra       L4FD9

L4F8B               ldd       $06,u
                    cmpd      #$004B
                    bne       L4FCE
                    leas      -$08,s
                    leax      ,s
                    pshs      x
                    bsr       L4FA3
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
L4FA3               puls      x
                    lbsr      L69FF
                    ldd       $0025
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0008
                    pshs      d
                    ldu       $08,u
                    beq       L4FBE
                    tfr       u,d
                    bra       L4FC2

L4FBE               leax      $06,s
                    tfr       x,d
L4FC2               pshs      d
                    lbsr      $6EB7
                    leas      $08,s
                    leas      $08,s
                    lbra      L5062

L4FCE               ldd       $0025
                    pshs      d
                    ldd       $08,u
L4FD4               pshs      d
                    lbsr      L6FA6
L4FD9               leas      $04,s
                    lbra      L5062

L4FDE               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$02,s
                    lbsr      L67EF
                    ldd       $08,s
                    cmpd      #$0001
                    bne       L4FFF
                    pshs      u
                    lbsr      L4AB1
L4FFA               leas      $02,s
                    lbra      L505F

L4FFF               cmpu      #$0000
                    bne       L5030
                    ldd       #$0001
                    std       ,s
                    bra       L5017

L500C               leax      L50CB,pcr
                    pshs      x
                    lbsr      L4A9B
                    leas      $02,s
L5017               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      $08,s
                    blt       L500C
                    ldd       #$0030
                    pshs      d
                    lbsr      L4A85
                    bra       L4FFA

L5030               clra
                    clrb
                    bra       L5056

L5034               ldd       ,u++
                    pshs      d
                    lbsr      L4AB1
                    leas      $02,s
                    ldd       $08,s
                    addd      #$FFFF
                    cmpd      ,s
                    beq       L5051
                    ldd       #$002C
                    pshs      d
                    lbsr      L4A85
                    leas      $02,s
L5051               ldd       ,s
                    addd      #$0001
L5056               std       ,s
                    ldd       ,s
                    cmpd      $08,s
                    blt       L5034
L505F               lbsr      L4A74
L5062               leas      $02,s
L5064               puls      pc,u
L5066               pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       #$0066
                    pshs      d
                    lbsr      L4A85
                    leas      $02,s
                    ldd       $0025
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0008
                    pshs      d
                    pshs      u
                    lbsr      $6EB7
                    leas      $08,s
                    puls      pc,u
L509E               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldu       $04,s
                    ldd       $14,u
                    addd      $06,s
                    std       $14,u
                    pshs      u
                    ldd       #$0005
                    pshs      d
                    lbsr      L4C68
                    leas      $04,s
                    puls      pc,u
L50BE               fcb       $25,$64
                    fcb       $00
L50C1               fcc       /%.8s/
                    fcb       $00
L50C6               fcb       $46,$25,$73
                    fcb       $0D,$00
L50CB               fcb       $30,$2C
                    fcb       $00
L50CE               pshs      u
                    leax      $01C1,y
                    stx       $000F
                    ldd       #$0001
                    std       copybytes
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
                    bra       L50F4

fprintf             pshs      u
                    ldd       $04,s
                    std       $000F
                    ldd       #$0001
                    std       copybytes
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L50F4               pshs      d
                    bsr       doprnt
                    leas      $04,s
                    puls      pc,u
L50FC               pshs      u
                    ldd       $04,s
                    std       $000F
                    ldd       #$0002
                    std       copybytes
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    bsr       doprnt
                    leas      $04,s
                    clra
                    clrb
                    stb       [$000F,y]
                    puls      pc,u
doprnt              pshs      u
                    ldu       $04,s
                    leas      -$0b,s
                    bra       L5133

L5123               ldb       $08,s
                    lbeq      L5291
                    ldb       $08,s
                    sex
                    pshs      d
                    lbsr      L5470
                    leas      $02,s
L5133               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L5123
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2d
                    bne       L5156
                    ldd       #$0001
                    std       $0011
                    ldb       ,u+
                    stb       $08,s
                    bra       L515A

L5156               clra
                    clrb
                    std       $0011
L515A               ldb       $08,s
                    cmpb      #$30
                    bne       L5165
                    ldd       #$0030
                    bra       L5168

L5165               ldd       #$0020
L5168               std       $0013
                    bra       L5186

L516C               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L753F
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L5186               ldb       $08,s
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L516C
                    ldb       $08,s
                    cmpb      #$2e
                    bne       L51CD
                    ldd       #$0001
                    std       $04,s
                    bra       L51B8

L51A2               ldd       $02,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L753F
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L51B8               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L51A2
                    bra       L51D1

L51CD               clra
                    clrb
                    std       $04,s
L51D1               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L5273

L51D9               ldd       $06,s
                    pshs      d
                    ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L5295
                    bra       L5201

L51EE               ldd       $06,s
                    pshs      d
                    ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L5356
L5201               std       ,s
                    lbra      L525E

L5206               ldx       $11,s
                    leax      $02,x
                    stx       $11,s
                    ldd       -$02,x
                    lbra      L5269

L5213               ldx       $11,s
                    leax      $02,x
                    stx       $11,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L5256
                    ldd       $09,s
                    std       $04,s
                    bra       L5235

L5229               ldb       [$09,s]
                    beq       L5241
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L5235               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L5229
L5241               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    subd      $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L5415
                    leas      $06,s
                    bra       L5263

L5256               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    pshs      d
L525E               lbsr      L53B5
                    leas      $04,s
L5263               lbra      L5133

L5266               ldb       $08,s
                    sex
L5269               pshs      d
                    lbsr      L5470
                    leas      $02,s
                    lbra      L5133

L5273               cmpx      #$0064
                    lbeq      L51D9
                    cmpx      #$0078
                    lbeq      L51EE
                    cmpx      #$0063
                    lbeq      L5206
                    cmpx      #$0073
                    lbeq      L5213
                    bra       L5266

L5291               leas      $0b,s
                    puls      pc,u
L5295               pshs      u,d
                    leax      $02DA,y
                    stx       ,s
                    ldd       $06,s
                    bge       L52CA
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L52BF
                    leax      L5495,pcr
                    pshs      x
                    leax      $02DA,y
                    pshs      x
                    lbsr      L7311
                    leas      $04,s
                    lbra      L546C

L52BF               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L52CA               ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    bsr       L52DF
                    leas      $04,s
                    leax      $02DA,y
                    tfr       x,d
                    lbra      L546C

L52DF               pshs      u,y,x,d
                    ldu       $0a,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    bra       L52FC

L52ED               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      $0081,y
                    std       $0C,s
L52FC               ldd       $0C,s
                    blt       L52ED
                    leax      $0081,y
                    stx       $04,s
                    bra       L533E

L5308               ldd       ,s
                    addd      #$0001
                    std       ,s
L530F               ldd       $0C,s
                    subd      [$04,s]
                    std       $0C,s
                    bge       L5308
                    ldd       $0C,s
                    addd      [$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L5328
                    ldd       #$0001
                    std       $02,s
L5328               ldd       $02,s
                    beq       L5333
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L5333               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L533E               ldd       $04,s
                    cmpd      $0001
                    bne       L530F
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0a,s
                    leas      $06,s
                    puls      pc,u
L5356               pshs      u,x,d
                    leax      $02DA,y
                    stx       $02,s
                    leau      $02E4,y
L5362               ldd       $08,s
                    clra
                    andb      #$0f
                    std       ,s
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L5378
                    ldd       #$0057
                    bra       L537B

L5378               ldd       #$0030
L537B               addd      ,s++
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
                    bne       L5362
                    bra       L539B

L5391               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L539B               leau      -$01,u
                    pshs      u
                    leax      $02E4,y
                    cmpx      ,s++
                    bls       L5391
                    clra
                    clrb
                    stb       [$02,s]
                    leax      $02DA,y
                    tfr       x,d
                    lbra      L5491

L53B5               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    pshs      d
                    lbsr      L7300
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    leau      d,u
                    ldd       $0011
                    bne       L53EC
                    bra       L53D9

L53D0               ldd       $0013
                    pshs      d
                    lbsr      L5470
                    leas      $02,s
L53D9               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bgt       L53D0
                    bra       L53EC

L53E3               ldd       ,s
                    pshs      d
                    lbsr      L5470
                    leas      $02,s
L53EC               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    sex
                    std       ,s
                    bne       L53E3
                    ldd       $0011
                    lbeq      L546C
                    bra       L540A

L5401               ldd       $0013
                    pshs      d
                    lbsr      L5470
                    leas      $02,s
L540A               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bgt       L5401
                    lbra      L546C

L5415               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $0a,s
                    subd      $08,s
                    std       ,s
                    ldd       $0011
                    bne       L5446
                    bra       L542F

L5427               ldd       $0013
                    pshs      d
                    bsr       L5470
                    leas      $02,s
L542F               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bgt       L5427
                    bra       L5446

L543D               ldb       ,u+
                    sex
                    pshs      d
                    bsr       L5470
                    leas      $02,s
L5446               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L543D
                    ldd       $0011
                    beq       L546C
                    bra       L5460

L5458               ldd       $0013
                    pshs      d
                    bsr       L5470
                    leas      $02,s
L5460               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bgt       L5458
L546C               leas      $02,s
                    puls      pc,u
L5470               pshs      u
                    ldd       copybytes
                    cmpd      #$0002
                    bne       L5486
                    ldd       $04,s
                    ldx       $000F
                    leax      $01,x
                    stx       $000F
                    stb       -$01,x
                    bra       L5493

L5486               ldd       $000F
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L6F01
L5491               leas      $04,s
L5493               puls      pc,u
L5495               blt       $54CA
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
                    bcs       L5525
                    asl       $06,x
                    rol       $05,x
                    rol       $04,x
                    rol       $03,x
                    rol       $02,x
                    rol       $01,x
                    rol       ,x
                    bcs       L5525
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
                    bcs       L5525
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
                    bcs       L5525
                    leas      $08,s
                    clra
                    clrb
                    rts

L5525               ldd       #$0001
                    leas      $08,s
                    rts

L552B               pshs      u
                    leas      -$15,s
                    lbsr      L6345
                    ldb       $0065
                    sex
                    cmpd      #$FFFF
                    bne       L5546
                    ldd       #$FFFF
                    std       $005F
                    leas      $15,s
                    puls      pc,u
L5546               ldd       $006A
                    addd      #$FFFF
                    std       $0063
                    ldd       L0027
                    std       L003F
                    bra       L5565

L5553               leax      L61E9,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    lbsr      L635B
                    ldd       $006A
                    std       $0063
L5565               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    sex
                    std       $005F
                    beq       L5553
                    ldb       $0065
                    sex
                    leax      $0109,y
                    leax      d,x
                    ldb       ,x
                    sex
                    std       $0061
                    ldx       $005F
                    lbra      L5873

L5588               leax      $0a,s
                    pshs      x
                    lbsr      L5ABC
                    leas      $02,s
                    leax      $0a,s
                    pshs      x
                    lbsr      L5B33
                    leas      $02,s
                    tfr       d,u
                    ldd       ,u
                    std       $005F
                    cmpd      #$0033
                    bne       L55BF
                    ldd       $08,u
                    std       $0061
                    cmpd      #$003B
                    lbne      L5892
                    ldd       #$003B
                    std       $005F
                    ldd       #$000E
                    std       $0061
                    lbra      L5892

L55BF               ldd       #$0034
                    std       $005F
                    stu       $0061
                    lbra      L5892

L55C9               leax      ,s
                    pshs      x
                    ldd       #$0001
                    pshs      d
                    lbsr      L5C59
                    leas      $04,s
                    std       $13,s
                    bra       L55DF

L55DC               leas      -$15,x
L55DF               leax      ,s
                    stx       $08,s
                    ldx       $13,s
                    bra       L563D

L55E8               ldd       [$08,s]
                    bra       L5633

L55ED               ldd       #$0004
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    tfr       d,u
                    leax      ,u
                    pshs      x
                    ldx       $0a,s
                    lbsr      L74D3
                    stu       $0061
                    ldd       #$004A
                    bra       L5638

L5609               ldd       #$0008
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    tfr       d,u
                    leax      ,u
                    pshs      x
                    ldx       $0a,s
                    lbsr      L69FF
                    stu       $0061
                    ldd       #$004B
                    bra       L5638

L5625               leax      L61F7,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    ldd       #$0001
L5633               std       $0061
                    ldd       #$0036
L5638               std       $005F
                    lbra      L5892

L563D               cmpx      #$0001
                    beq       L55E8
                    cmpx      #$0008
                    beq       L55ED
                    cmpx      #$0006
                    beq       L5609
                    bra       L5625

L564E               lbsr      L5F00
                    ldd       #$0036
                    bra       L565C

L5656               lbsr      L5F30
                    ldd       #$0037
L565C               std       $005F
                    lbra      L5892

L5661               lbsr      L635B
                    ldx       $005F
                    lbra      L5816

L5669               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    lbne      L5892
                    leax      ,s
                    pshs      x
                    ldd       #$0006
                    pshs      d
                    lbsr      L5C59
                    leas      $04,s
                    std       $13,s
                    leax      $15,s
                    lbra      L55DC

L5691               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L56B0

L5698               ldd       #$0047
                    std       $005F
                    lbsr      L635B
                    ldd       #$0005
                    bra       L56EF

L56A5               ldd       #$00A7
                    std       $005F
                    ldd       #$0002
                    lbra      L57FC

L56B0               cmpx      #$0026
                    beq       L5698
                    cmpx      #$003D
                    beq       L56A5
                    lbra      L5892

L56BD               ldb       $0065
                    cmpb      #$3d
                    lbne      L5892
                    ldd       #$005A
                    std       $005F
                    ldd       #$0009
                    lbra      L57FC

L56D0               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L56F4

L56D7               ldd       #$0048
                    std       $005F
                    lbsr      L635B
                    ldd       #$0004
                    bra       L56EF

L56E4               ldd       #$00A8
L56E7               std       $005F
                    lbsr      L635B
                    ldd       #$0002
L56EF               std       $0061
                    lbra      L5892

L56F4               cmpx      #$007C
                    beq       L56D7
                    cmpx      #$003D
                    beq       L56E4
                    lbra      L5892

L5701               ldb       $0065
                    cmpb      #$3d
                    lbne      L5892
                    ldd       #$005B
                    std       $005F
                    lbsr      L635B
                    ldd       #$0009
                    bra       L56EF

L5716               ldb       $0065
                    cmpb      #$3d
                    lbne      L5892
                    ldd       #$00A2
                    bra       L56E7

L5723               ldb       $0065
                    cmpb      #$3d
                    lbne      L5892
                    ldd       $005F
                    addd      #$0050
                    lbra      L56E7

L5733               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L5765

L573A               ldd       #$0056
                    std       $005F
                    ldd       #$000B
                    std       $0061
                    lbsr      L635B
                    ldb       $0065
                    cmpb      #$3d
                    lbne      L5892
                    ldd       #$00A6
                    std       $005F
                    ldd       #$0002
                    lbra      L57FC

L575A               ldd       #$005C
                    std       $005F
                    ldd       #$000A
                    lbra      L57FC

L5765               cmpx      #$003C
                    beq       L573A
                    cmpx      #$003D
                    beq       L575A
                    lbra      L5892

L5772               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L57A4

L5779               ldd       #$0055
                    std       $005F
                    ldd       #$000B
                    std       $0061
                    lbsr      L635B
                    ldb       $0065
                    cmpb      #$3d
                    lbne      L5892
                    ldd       #$00A5
                    std       $005F
                    ldd       #$0002
                    lbra      L57FC

L5799               ldd       #$005E
                    std       $005F
                    ldd       #$000A
                    lbra      L57FC

L57A4               cmpx      #$003E
                    beq       L5779
                    cmpx      #$003D
                    beq       L5799
                    lbra      L5892

L57B1               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L57CC

L57B8               ldd       #$003C
                    std       $005F
                    ldd       #$000E
                    bra       L57FC

L57C2               ldd       #$00A0
                    std       $005F
                    ldd       #$0002
                    bra       L57FC

L57CC               cmpx      #$002B
                    beq       L57B8
                    cmpx      #$003D
                    beq       L57C2
                    lbra      L5892

L57D9               ldb       $0065
                    sex
                    tfr       d,x
                    bra       L5804

L57E0               ldd       #$003D
                    std       $005F
                    ldd       #$000E
                    bra       L57FC

L57EA               ldd       #$00A1
                    std       $005F
                    ldd       #$0002
                    bra       L57FC

L57F4               ldd       #$0046
                    std       $005F
                    ldd       #$000F
L57FC               std       $0061
                    lbsr      L635B
                    lbra      L5892

L5804               cmpx      #$002D
                    beq       L57E0
                    cmpx      #$003D
                    beq       L57EA
                    cmpx      #$003E
                    beq       L57F4
                    lbra      L5892

L5816               cmpx      #$0045
                    lbeq      L5669
                    cmpx      #$0041
                    lbeq      L5691
                    cmpx      #$0078
                    lbeq      L56BD
                    cmpx      #$0058
                    lbeq      L56D0
                    cmpx      #$0040
                    lbeq      L5701
                    cmpx      #$0042
                    lbeq      L5716
                    cmpx      #$0053
                    lbeq      L5723
                    cmpx      #$0054
                    lbeq      L5723
                    cmpx      #$0059
                    lbeq      L5723
                    cmpx      #$005D
                    lbeq      L5733
                    cmpx      #$005F
                    lbeq      L5772
                    cmpx      #$0050
                    lbeq      L57B1
                    cmpx      #$0043
                    lbeq      L57D9
                    bra       L5892

L5873               cmpx      #$006A
                    lbeq      L5588
                    cmpx      #$006B
                    lbeq      L55C9
                    cmpx      #$0068
                    lbeq      L564E
                    cmpx      #$0069
                    lbeq      L5656
                    lbra      L5661

L5892               leas      $15,s
                    puls      pc,u
L5897               pshs      u
                    ldd       #$0006
                    pshs      d
                    leax      L6209,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0005
                    pshs      d
                    leax      L6210,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #_start
                    pshs      d
                    leax      L6216,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$000F
                    pshs      d
                    leax      L621E,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$003B
                    pshs      d
                    leax      L6225,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0001
                    pshs      d
                    leax      L622C,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0001
                    std       $0041
                    ldd       #$0001
                    pshs      d
                    leax      L6230,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0005
                    pshs      d
                    leax      L6234,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    clra
                    clrb
                    std       $0041
                    ldd       #$0002
                    pshs      d
                    leax      L623A,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$000A
                    pshs      d
                    leax      L623F,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$000D
                    pshs      d
                    leax      L6245,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$000E
                    pshs      d
                    leax      L624A,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0021
                    pshs      d
                    leax      L6251,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0010
                    pshs      d
                    leax      L6258,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$001D
                    pshs      d
                    leax      L6261,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0012
                    pshs      d
                    leax      L6266,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0013
                    pshs      d
                    leax      L626D,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0014
                    pshs      d
                    leax      L6270,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0015
                    pshs      d
                    leax      L6276,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0016
                    pshs      d
                    leax      L627B,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0017
                    pshs      d
                    leax      L6282,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0018
                    pshs      d
                    leax      L6287,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0019
                    pshs      d
                    leax      L628D,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$001A
                    pshs      d
                    leax      L6296,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$001B
                    pshs      d
                    leax      L6299,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$001C
                    pshs      d
                    leax      L62A1,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0004
                    pshs      d
                    leax      L62A5,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0003
                    pshs      d
                    leax      L62AC,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0007
                    pshs      d
                    leax      L62B2,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    ldd       #$0008
                    pshs      d
                    leax      L62BB,pcr
                    pshs      x
                    lbsr      L5BD5
                    leas      $04,s
                    leax      L62C0,pcr
                    pshs      x
                    lbsr      L5B33
                    leas      $02,s
                    tfr       d,u
                    ldd       #$0001
                    std       ,u
                    ldd       #$000E
                    std       $08,u
                    ldd       #$0002
                    std       $02,u
                    leax      L62C6,pcr
                    pshs      x
                    lbsr      L5B33
                    leas      $02,s
                    tfr       d,u
                    ldd       #$0038
                    std       ,u
                    ldd       #$000C
                    std       $08,u
                    ldd       #$0004
                    std       $02,u
                    puls      pc,u
L5ABC               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       #$0001
                    bra       L5AD3

L5AC7               ldb       $0065
                    stb       ,u+
                    lbsr      L635B
                    ldd       ,s
                    addd      #$0001
L5AD3               std       ,s
                    ldb       $0065
                    sex
                    pshs      d
                    bsr       L5B0C
                    std       ,s++
                    beq       L5AE8
                    ldd       ,s
                    cmpd      #$0008
                    ble       L5AC7
L5AE8               ldd       ,s
                    cmpd      #$0002
                    bne       L5AF5
                    ldd       #$005F
                    stb       ,u+
L5AF5               clra
                    clrb
                    stb       ,u
                    bra       L5AFE

L5AFB               lbsr      L635B
L5AFE               ldb       $0065
                    sex
                    pshs      d
                    bsr       L5B0C
                    std       ,s++
                    bne       L5AFB
                    lbra      L5C55

L5B0C               pshs      u
                    ldd       $04,s
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6a
                    beq       L5B2A
                    ldd       $04,s
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    bne       L5B2F
L5B2A               ldd       #$0001
                    bra       L5B31

L5B2F               clra
                    clrb
L5B31               puls      pc,u
L5B33               pshs      u,y,x,d
                    ldd       $0041
                    beq       L5B3F
                    leax      $050C,y
                    bra       L5B43

L5B3F               leax      $040C,y
L5B43               tfr       x,d
                    std       $02,s
                    ldd       $0a,s
                    pshs      d
                    lbsr      L5C07
                    leas      $02,s
                    aslb
                    rola
                    addd      $02,s
                    std       $04,s
                    ldu       [$04,s]
                    bra       L5B88

L5B5B               ldb       $14,u
                    sex
                    pshs      d
                    ldb       [$0C,s]
                    sex
                    cmpd      ,s++
                    bne       L5B85
                    ldd       #$0008
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    ldd       $0e,s
                    pshs      d
                    lbsr      L73C4
                    leas      $06,s
                    std       -$02,s
                    beq       L5BCF
L5B85               ldu       $12,u
L5B88               stu       -$02,s
                    bne       L5B5B
                    ldu       L0019
                    beq       L5B97
                    ldd       $12,u
                    std       L0019
                    bra       L5BA3

L5B97               ldd       #$001C
                    pshs      d
                    lbsr      L5C27
                    leas      $02,s
                    tfr       d,u
L5BA3               ldd       #$0008
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    pshs      u
                    ldd       #$0014
                    addd      ,s++
                    pshs      d
                    lbsr      L7387
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
L5BCF               tfr       u,d
                    leas      $06,s
                    puls      pc,u
L5BD5               pshs      u
                    leas      -$09,s
                    ldd       #$0008
                    pshs      d
                    ldd       $0f,s
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L7387
                    leas      $06,s
                    clra
                    clrb
                    stb       $08,s
                    leax      ,s
                    pshs      x
                    lbsr      L5B33
                    leas      $02,s
                    tfr       d,u
                    ldd       #$0033
                    std       ,u
                    ldd       $0f,s
                    std       $08,u
                    leas      $09,s
                    puls      pc,u
L5C07               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L5C15

L5C11               ldd       $02,s
                    addd      ,s
L5C15               std       $02,s
                    ldb       ,u+
                    sex
                    std       ,s
                    bne       L5C11
                    ldd       $02,s
                    clra
                    andb      #$7f
                    leas      $04,s
                    puls      pc,u
L5C27               pshs      u,d
                    ldd       $06,s
                    pshs      d
                    lbsr      L7847
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L5C45
                    leax      L62CC,pcr
                    pshs      x
                    lbsr      L0228
                    leas      $02,s
L5C45               ldd       L0066
                    bne       L5C4D
                    ldd       ,s
                    std       L0066
L5C4D               ldd       ,s
                    addd      $06,s
                    std       $0068
                    ldd       ,s
L5C55               leas      $02,s
                    puls      pc,u
L5C59               pshs      u
                    ldu       $06,s
                    leas      -$10,s
                    clra
                    clrb
                    std       $02,s
                    leax      $08,s
                    pshs      x
                    bsr       L5C71
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
L5C71               puls      x
                    lbsr      L69FF
                    leax      $08,s
                    stx       ,s
                    ldd       $14,s
                    cmpd      #$0006
                    bne       L5C89
                    leax      $10,s
                    lbra      L5DC4

L5C89               ldb       $0065
                    cmpb      #$30
                    lbne      L5D96
                    leas      -$06,s
                    lbsr      L635B
                    ldb       $0065
                    cmpb      #$2e
                    bne       L5CA5
                    lbsr      L635B
                    leax      $16,s
                    lbra      L5DC4

L5CA5               leax      $02,s
                    pshs      x
                    bsr       L5CAF
                    fcb       $00,$00,$00,$00
L5CAF               puls      x
                    lbsr      L74D3
                    ldb       $0065
                    cmpb      #$78
                    beq       L5CC2
                    ldb       $0065
                    cmpb      #$58
                    lbne      L5D38
L5CC2               leas      -$02,s
                    bra       L5CFB

L5CC6               leax      $04,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    ldd       #$0004
                    lbsr      L74E9
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $06,s
                    cmpd      #$0041
                    blt       L5CE9
                    ldd       #$0037
                    bra       L5CEC

L5CE9               ldd       #$0030
L5CEC               pshs      d
                    ldd       $08,s
                    subd      ,s++
                    lbsr      L74BA
                    lbsr      L7469
                    lbsr      L74D3
L5CFB               lbsr      L635B
                    ldb       $0065
                    sex
                    pshs      d
                    lbsr      L61BC
                    leas      $02,s
                    std       ,s
                    bne       L5CC6
                    leas      $02,s
                    bra       L5D44

L5D10               leax      $02,s
                    pshs      x
                    leax      $04,s
                    pshs      x
                    ldd       #$0003
                    lbsr      L74E9
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldb       $0065
                    sex
                    addd      #$FFD0
                    lbsr      L74BA
                    lbsr      L7469
                    lbsr      L74D3
                    lbsr      L635B
L5D38               ldb       $0065
                    sex
                    pshs      d
                    lbsr      L61A9
                    std       ,s++
                    bne       L5D10
L5D44               leax      $02,s
                    stx       ,s
                    ldb       $0065
                    cmpb      #$4C
                    beq       L5D54
                    ldb       $0065
                    cmpb      #$6C
                    bne       L5D5C
L5D54               lbsr      L635B
                    leax      $16,s
                    bra       L5D6B

L5D5C               ldd       [,s]
                    bne       L5D6E
                    ldd       $04,s
                    std       ,u
                    ldd       #$0001
                    bra       L5D7A
                    bra       L5D6E

L5D6B               leas      -$16,x
L5D6E               leax      ,u
                    pshs      x
                    leax      $04,s
                    lbsr      L74D3
                    ldd       #$0008
L5D7A               leas      $16,s
                    puls      pc,u
                    bra       L5D96

L5D81               ldb       $0065
                    sex
                    pshs      d
                    leax      $0a,s
                    pshs      x
                    lbsr      $549C
                    leas      $04,s
                    std       -$02,s
                    bne       L5DDA
                    lbsr      L635B
L5D96               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L5D81
                    ldb       $0065
                    cmpb      #$2e
                    beq       L5DB9
                    ldb       $0065
                    cmpb      #$65
                    beq       L5DB9
                    ldb       $0065
                    cmpb      #$45
                    lbne      L5E95
L5DB9               ldb       $0065
                    cmpb      #$2e
                    bne       L5DF9
                    lbsr      L635B
                    bra       L5DEA

L5DC4               leas      -$10,x
                    bra       L5DEA

L5DC8               ldb       $0065
                    sex
                    pshs      d
                    leax      $0a,s
                    pshs      x
                    lbsr      $549C
                    leas      $04,s
                    std       -$02,s
                    beq       L5DE0
L5DDA               lbsr      L635B
                    lbra      L5EA5

L5DE0               lbsr      L635B
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
L5DEA               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L5DC8
L5DF9               ldb       $0065
                    cmpb      #$45
                    beq       L5E07
                    ldb       $0065
                    cmpb      #$65
                    lbne      L5E75
L5E07               ldd       #$0001
                    std       $04,s
                    lbsr      L635B
                    ldb       $0065
                    cmpb      #$2b
                    bne       L5E1A
                    lbsr      L635B
                    bra       L5E27

L5E1A               ldb       $0065
                    cmpb      #$2d
                    bne       L5E27
                    lbsr      L635B
                    clra
                    clrb
                    std       $04,s
L5E27               clra
                    clrb
                    std       $06,s
                    bra       L5E46

L5E2D               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L753F
                    pshs      d
                    ldb       $0065
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    lbsr      L635B
L5E46               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L5E2D
                    ldd       $06,s
                    cmpd      #$0028
                    lbge      L5EA5
                    ldd       $02,s
                    pshs      d
                    ldd       $06,s
                    beq       L5E6F
                    ldd       $08,s
                    nega
                    negb
                    sbca      #$00
                    bra       L5E71

L5E6F               ldd       $08,s
L5E71               addd      ,s++
                    std       $02,s
L5E75               ldd       $02,s
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
                    lbsr      L69FF
                    ldd       #$0006
                    lbra      L5EFB

L5E95               ldb       [,s]
                    bne       L5EA5
                    ldx       ,s
                    ldb       $01,x
                    bne       L5EA5
                    ldx       ,s
                    ldb       $02,x
                    beq       L5EAA
L5EA5               clra
                    clrb
                    lbra      L5EFB

L5EAA               ldb       $0065
                    cmpb      #$6C
                    beq       L5EB6
                    ldb       $0065
                    cmpb      #$4C
                    bne       L5ED5
L5EB6               leas      -$02,s
                    lbsr      L635B
                    bra       L5EC0

L5EBD               leas      -$12,x
L5EC0               ldd       $02,s
                    addd      #$0003
                    std       ,s
                    leax      ,u
                    pshs      x
                    ldx       $02,s
                    lbsr      L74D3
                    ldd       #$0008
                    bra       L5EF6

L5ED5               ldx       ,s
                    ldb       $03,x
                    bne       L5EE1
                    ldx       ,s
                    ldb       $04,x
                    beq       L5EE6
L5EE1               leax      $10,s
                    bra       L5EBD

L5EE6               leas      -$02,s
                    ldd       $02,s
                    addd      #$0005
                    std       ,s
                    ldd       [,s]
                    std       ,u
                    ldd       #$0001
L5EF6               leas      $12,s
                    puls      pc,u
L5EFB               leas      $10,s
                    puls      pc,u
L5F00               pshs      u
                    lbsr      L635B
                    ldb       $0065
                    cmpb      #$5C
                    bne       L5F12
                    lbsr      L6056
                    std       $0061
                    bra       L5F1A

L5F12               ldb       $0065
                    sex
                    std       $0061
                    lbsr      L635B
L5F1A               ldb       $0065
                    cmpb      #$27
                    lbeq      L6005
                    leax      L62DA,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    lbra      L6008

L5F30               pshs      u
                    ldx       $000B
                    bra       L5F64

L5F36               ldd       $006C
                    bne       L5F5A
                    leax      L62FA,pcr
                    pshs      x
                    leax      $01A9,y
                    pshs      x
                    lbsr      L6DED
                    leas      $04,s
                    std       $006C
                    bne       L5F5A
                    leax      L62FD,pcr
                    pshs      x
                    lbsr      L0228
                    leas      $02,s
L5F5A               ldd       $006C
                    bra       L5F60

L5F5E               ldd       $0025
L5F60               std       L001B
                    bra       L5F74

L5F64               stx       -$02,s
                    beq       L5F36
                    cmpx      #$0002
                    lbeq      L5F36
                    cmpx      #$0001
                    beq       L5F5E
L5F74               clra
                    clrb
                    std       L0017
                    ldd       $000B
                    cmpd      #$0001
                    beq       L5FA2
                    ldd       L001B
                    pshs      d
                    ldd       #$006C
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       L001B
                    pshs      d
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    std       $0061
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
L5FA2               lbsr      L635B
                    ldd       L001B
                    pshs      d
                    ldd       #$0073
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    bra       L5FEB

L5FB5               leax      $060C,y
                    pshs      x
                    ldd       $006A
                    subd      ,s++
                    bne       L5FCE
                    leax      L6315,pcr
                    pshs      x
                    lbsr      L024B
                    leas      $02,s
                    bra       L5FF1

L5FCE               ldb       $0065
                    cmpb      #$5C
                    bne       L5FDF
                    lbsr      L6056
                    pshs      d
                    bsr       L600A
                    leas      $02,s
                    bra       L5FEB

L5FDF               ldb       $0065
                    sex
                    pshs      d
                    bsr       L600A
                    leas      $02,s
                    lbsr      L635B
L5FEB               ldb       $0065
                    cmpb      #$22
                    bne       L5FB5
L5FF1               ldd       L001B
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       L0017
                    addd      #$0001
                    std       L0017
L6005               lbsr      L635B
L6008               puls      pc,u
L600A               pshs      u
                    ldd       $04,s
                    beq       L6018
                    ldd       $04,s
                    cmpd      #$005C
                    bne       L6026
L6018               ldd       L001B
                    pshs      d
                    ldd       #$005C
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
L6026               ldd       L001B
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       L0017
                    addd      #$0001
                    std       L0017
                    puls      pc,u
L603C               pshs      u
                    lbsr      L4BEC
                    ldd       $04,s
                    pshs      d
                    leax      L6329,pcr
                    pshs      x
                    ldd       L001B
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    puls      pc,u
L6056               pshs      u,d
                    lbsr      L635B
                    ldb       $0065
                    sex
                    tfr       d,u
                    lbsr      L635B
                    leax      ,u
                    bra       L6091

L6067               ldd       #$000A
                    lbra      L61A5

L606D               ldd       #$0009
                    lbra      L61A5

L6073               ldd       #$0008
                    lbra      L61A5

L6079               ldd       #$000B
                    lbra      L61A5

L607F               ldd       #$000D
                    lbra      L61A5

L6085               ldd       #$000C
                    lbra      L61A5

L608B               ldd       #$0020
                    lbra      L61A5

L6091               cmpx      #$006E
                    beq       L607F
                    cmpx      #$006C
                    beq       L6067
                    cmpx      #$0074
                    beq       L606D
                    cmpx      #$0062
                    beq       L6073
                    cmpx      #$0076
                    beq       L6079
                    cmpx      #$0072
                    lbeq      L607F
                    cmpx      #$0066
                    beq       L6085
                    cmpx      #$000D
                    beq       L608B
                    cmpu      #$0078
                    lbne      L6117
                    leas      -$02,s
                    clra
                    clrb
                    std       $02,s
                    tfr       d,u
                    bra       L60F4

L60CD               tfr       u,d
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
                    bge       L60E8
                    ldd       $02,s
                    addd      #$FFD0
                    bra       L60ED

L60E8               ldd       $02,s
                    addd      #$FFC9
L60ED               addd      ,s++
                    tfr       d,u
                    lbsr      L635B
L60F4               ldb       $0065
                    sex
                    pshs      d
                    lbsr      L61BC
                    leas      $02,s
                    std       ,s
                    beq       L6112
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
                    subd      #$0001
                    cmpd      #$0002
                    blt       L60CD
L6112               leas      $02,s
                    lbra      L61A3

L6117               cmpu      #$0064
                    bne       L615F
                    clra
                    clrb
                    std       ,s
                    tfr       d,u
                    bra       L613C

L6125               pshs      u
                    ldd       #$000A
                    lbsr      L753F
                    pshs      d
                    ldb       $0065
                    sex
                    addd      ,s++
                    addd      #$FFD0
                    tfr       d,u
                    lbsr      L635B
L613C               ldb       $0065
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    lbne      L61A3
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0003
                    blt       L6125
                    bra       L61A3

L615F               pshs      u
                    lbsr      L61A9
                    std       ,s++
                    beq       L61A3
                    leau      -$30,u
                    clra
                    clrb
                    std       ,s
                    bra       L6188

L6171               tfr       u,d
                    aslb
                    rola
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
                    lbsr      L635B
L6188               ldb       $0065
                    sex
                    pshs      d
                    bsr       L61A9
                    std       ,s++
                    beq       L61A3
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0003
                    blt       L6171
L61A3               tfr       u,d
L61A5               leas      $02,s
                    puls      pc,u
L61A9               pshs      u
                    ldb       $05,s
                    cmpb      #$37
                    bgt       L61E5
                    ldb       $05,s
                    cmpb      #$30
                    blt       L61E5
                    ldd       #$0001
                    bra       L61E7

L61BC               pshs      u
                    ldb       $05,s
                    sex
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L61E0
                    ldb       $05,s
                    clra
                    andb      #$5f
                    stb       $05,s
                    cmpd      #$0041
                    blt       L61E5
                    ldb       $05,s
                    cmpb      #$46
                    bgt       L61E5
L61E0               ldb       $05,s
                    sex
                    bra       L61E7

L61E5               clra
                    clrb
L61E7               puls      pc,u
L61E9               fcc       /bad character/
                    fcb       $00
L61F7               fcc       /constant overflow/
                    fcb       $00
L6209               fcc       /double/
                    fcb       $00
L6210               fcc       /float/
                    fcb       $00
L6216               fcc       /typedef/
                    fcb       $00
L621E               fcc       /static/
                    fcb       $00
L6225               fcc       /sizeof/
                    fcb       $00
L622C               fcb       $69,$6E,$74
                    fcb       $00
L6230               fcb       $69,$6E,$74
                    fcb       $00
L6234               fcc       /float/
                    fcb       $00
L623A               fcc       /char/
                    fcb       $00
L623F               fcc       /short/
                    fcb       $00
L6245               fcc       /auto/
                    fcb       $00
L624A               fcc       /extern/
                    fcb       $00
L6251               fcc       /direct/
                    fcb       $00
L6258               fcc       /register/
                    fcb       $00
L6261               fcc       /goto/
                    fcb       $00
L6266               fcc       /return/
                    fcb       $00
L626D               fcb       $69,$66
                    fcb       $00
L6270               fcc       /while/
                    fcb       $00
L6276               fcc       /else/
                    fcb       $00
L627B               fcc       /switch/
                    fcb       $00
L6282               fcc       /case/
                    fcb       $00
L6287               fcc       /break/
                    fcb       $00
L628D               fcc       /continue/
                    fcb       $00
L6296               fcb       $64,$6F
                    fcb       $00
L6299               fcc       /default/
                    fcb       $00
L62A1               fcb       $66,$6F,$72
                    fcb       $00
L62A5               fcc       /struct/
                    fcb       $00
L62AC               fcc       /union/
                    fcb       $00
L62B2               fcc       /unsigned/
                    fcb       $00
L62BB               fcc       /long/
                    fcb       $00
L62C0               fcc       /errno/
                    fcb       $00
L62C6               fcc       /lseek/
                    fcb       $00
L62CC               fcc       /out of memory/
                    fcb       $00
L62DA               fcc       /unterminated character constant/
                    fcb       $00
L62FA               fcb       $77,$2B
                    fcb       $00
L62FD               fcc       /can't open strings file/
                    fcb       $00
L6315               fcc       /unterminated string/
                    fcb       $00
L6329               fcc       / rzb %d/
                    fcb       $0D,$00
L6332               pshs      u
                    leax      $060C,y
                    stx       $006A
                    clra
                    clrb
                    stb       $060C,y
                    ldd       #$0020
                    bra       L636B

L6345               pshs      u
                    bra       L634B

L6349               bsr       L635B
L634B               ldb       $0065
                    cmpb      #$20
                    beq       L6349
                    ldb       $0065
                    cmpb      #$09
                    lbeq      L6349
                    puls      pc,u
L635B               pshs      u
                    ldx       $006A
                    leax      $01,x
                    stx       $006A
                    ldb       -$01,x
                    stb       $0065
                    bne       L636D
                    bsr       L636F
L636B               stb       $0065
L636D               puls      pc,u
L636F               pshs      u
                    leas      -$08,s
                    ldd       L001D
                    bne       L6385
                    ldd       #$0001
                    std       L001D
                    leax      L6631,pcr
                    stx       $006A
                    lbra      L6566

L6385               clra
                    clrb
                    std       L001D
                    leax      $060C,y
                    pshs      x
                    leax      $070C,y
                    pshs      x
                    lbsr      L7311
                    leas      $04,s
L639A               lbsr      L65A3
                    std       $006A
                    lbeq      L64A4
                    ldb       [$006A,y]
                    cmpb      #$23
                    lbne      L655F
                    ldx       $006A
                    ldb       $01,x
                    sex
                    std       $04,s
                    lbsr      L65A3
                    std       -$02,s
                    lbeq      L64A4
                    ldx       $04,s
                    lbra      L652B

L63C2               leax      $060C,y
                    pshs      x
                    lbsr      L656D
                    leas      $02,s
                    std       L0027
                    bra       L639A

L63D1               lbsr      L6800
L63D4               lbsr      L4BEC
                    leax      $060C,y
                    pshs      x
                    leax      L6632,pcr
                    lbra      L6456

L63E4               leax      $060C,y
                    pshs      x
                    leax      $03EE,y
                    pshs      x
                    lbsr      L7311
                    leas      $04,s
                    leax      $03EE,y
                    pshs      x
                    lbsr      L4BFF
                    leas      $02,s
                    lbsr      L65A3
                    std       -$02,s
                    lbne      L639A
                    lbra      L64A4

L640C               leax      $060C,y
                    pshs      x
                    leax      $02EE,y
                    pshs      x
                    lbsr      L7311
                    leas      $04,s
                    lbsr      L65A3
                    std       -$02,s
                    lbeq      L64A4
                    lbsr      L4BEC
                    leax      $060C,y
                    pshs      x
                    lbsr      L656D
                    std       ,s
                    leax      $02EE,y
                    pshs      x
                    leax      L6636,pcr
                    pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      fprintf
                    leas      $08,s
                    lbsr      L4BEC
                    leax      $02EE,y
                    pshs      x
                    leax      L664C,pcr
L6456               pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    lbra      L639A

L6464               leax      $060C,y
                    pshs      x
                    leax      $02EE,y
                    pshs      x
                    lbsr      L7311
                    leas      $04,s
                    lbsr      L65A3
                    std       -$02,s
                    beq       L64A4
                    leax      $060C,y
                    pshs      x
                    lbsr      L656D
                    leas      $02,s
                    std       $06,s
                    lbsr      L65A3
                    std       -$02,s
                    beq       L64A4
                    leax      $060C,y
                    pshs      x
                    lbsr      L656D
                    leas      $02,s
                    std       $02,s
                    lbsr      L65A3
                    std       -$02,s
                    bne       L64AA
L64A4               ldd       #$FFFF
                    lbra      L6569

L64AA               ldd       $06,s
                    beq       L64C5
                    ldd       $06,s
                    pshs      d
                    leax      $03EE,y
                    pshs      x
                    leax      L6655,pcr
                    pshs      x
                    lbsr      L50CE
                    leas      $06,s
                    bra       L64D0

L64C5               leax      L6663,pcr
                    pshs      x
                    lbsr      L50CE
                    leas      $02,s
L64D0               leax      $060C,y
                    pshs      x
                    leax      L666F,pcr
                    pshs      x
                    lbsr      L50CE
                    leas      $04,s
                    ldb       $02EE,y
                    beq       L651B
                    leax      $02EE,y
                    pshs      x
                    lbsr      L6E3F
                    leas      $02,s
                    bra       L6504

L64F4               leax      $01C1,y
                    pshs      x
                    ldd       #$0020
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
L6504               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L64F4
                    leax      L667D,pcr
                    pshs      x
                    lbsr      L6E3F
                    leas      $02,s
L651B               ldd       $04,s
                    cmpd      #$0031
                    lbne      L639A
                    lbsr      L68C1
                    lbra      L639A

L652B               cmpx      #$0035
                    lbeq      L63C2
                    cmpx      #$0036
                    lbeq      L63D1
                    cmpx      #$0032
                    lbeq      L63D4
                    cmpx      #$0037
                    lbeq      L63E4
                    cmpx      #$0050
                    lbeq      L640C
                    cmpx      #$0030
                    lbeq      L6464
                    cmpx      #$0031
                    lbeq      L6464
                    lbra      L639A

L655F               ldd       L0027
                    addd      #$0001
                    std       L0027
L6566               ldd       #$0020
L6569               leas      $08,s
                    puls      pc,u
L656D               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L658A

L6577               ldd       ,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L753F
                    pshs      d
                    ldd       $04,s
                    addd      #$FFD0
                    addd      ,s++
L658A               std       ,s
                    ldb       ,u+
                    sex
                    std       $02,s
                    leax      $0089,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$6b
                    beq       L6577
                    ldd       ,s
                    leas      $04,s
                    puls      pc,u
L65A3               pshs      u,d
                    leau      $060C,y
                    ldd       L0023
                    pshs      d
                    lbsr      L711C
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    lbne      L660C
                    ldx       L0023
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L65D9
                    leax      $01CE,y
                    pshs      x
                    leax      L667F,pcr
                    pshs      x
                    lbsr      L6E61
                    leas      $04,s
                    lbsr      L68C1
L65D9               clra
                    clrb
                    bra       L662D

L65DD               ldx       ,s
                    bra       L65FE

L65E1               clra
                    clrb
                    stb       ,u
                    leax      $060C,y
                    tfr       x,d
                    bra       L662D

L65ED               ldd       ,s
                    stb       ,u+
                    ldd       L0023
                    pshs      d
                    lbsr      L711C
                    leas      $02,s
                    std       ,s
                    bra       L660C

L65FE               cmpx      #$000D
                    beq       L65E1
                    cmpx      #$FFFF
                    lbeq      L65E1
                    bra       L65ED

L660C               cmpu      $0189,y
                    bne       L65DD
                    ldd       L0027
                    addd      #$0001
                    std       L0027
                    std       L003F
                    leax      $060C,y
                    stx       $0063
                    leax      >L66A2,pcr
                    pshs      x
                    lbsr      L0228
                    leas      $02,s
L662D               leas      $02,s
                    puls      pc,u
L6631               fcb       $00
L6632               fcb       $25,$73
                    fcb       $0D,$00
L6636               fcc       / psect %s,0,0,%d,0,0/
                    fcb       $0D,$00
L664C               fcc       / nam %s/
                    fcb       $0D,$00
L6655               fcc       /%s : line %d /
                    fcb       $00
L6663               fcc       /argument : /
                    fcb       $00
L666F               fcc       /**** %s ****/
                    fcb       $0D,$00
L667D               fcb       $5E
                    fcb       $00
L667F               fcc       /INPUT FILE ERROR : TEMPORARY FILE/
                    fcb       $0D,$00
L66A2               fcc       /input line too long/
                    fcb       $00
L66B6               pshs      u
                    lbsr      L686D
                    lbra      L6714

L66BE               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L6811
                    leas      $02,s
                    lbsr      L4BEC
                    ldd       $04,s
                    pshs      d
                    lbsr      L4B01
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    leax      L691A,pcr
                    pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      fprintf
                    bra       L6712

L66E8               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L6811
                    leas      $02,s
                    ldd       #$003A
                    bra       L6706

L66F8               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L6811
                    leas      $02,s
                    ldd       #$0020
L6706               pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    bsr       L6719
L6712               leas      $06,s
L6714               lbsr      L6821
                    puls      pc,u
L6719               pshs      u
                    lbsr      L4BEC
                    ldd       $06,s
                    pshs      d
                    ldb       $0b,s
                    sex
                    pshs      d
                    ldd       $08,s
                    addd      #$0014
                    pshs      d
                    leax      L6923,pcr
                    pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      fprintf
                    leas      $0a,s
                    puls      pc,u
L673F               pshs      u
                    ldd       $0025
                    pshs      d
                    ldd       #$0053
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       $0025
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       $0035
                    bne       L6772
                    ldd       $0025
                    pshs      d
                    ldd       L002B
                    addd      #$0001
                    std       L002B
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
L6772               clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      L6932,pcr
                    pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      fprintf
                    leas      $08,s
                    ldd       L0037
                    lbeq      L67E2
                    ldd       $0025
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L6FA6
                    bra       L67E0

L679C               pshs      u
                    ldd       #$0070
                    pshs      d
                    lbsr      L4A85
                    leas      $02,s
                    ldd       $0025
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L6FA6
                    leas      $04,s
                    clra
                    clrb
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      L6939,pcr
                    pshs      x
                    ldd       $0025
                    pshs      d
                    lbsr      fprintf
                    leas      $08,s
                    puls      pc,u
L67CE               pshs      u
                    ldd       $0035
                    bne       L67E2
                    ldd       $0025
                    pshs      d
                    ldd       #$0045
                    pshs      d
                    lbsr      L6F01
L67E0               leas      $04,s
L67E2               puls      pc,u
L67E4               pshs      u
                    lbsr      L4BEC
                    leax      L6940,pcr
                    bra       L67F8

L67EF               pshs      u
                    lbsr      L4BEC
                    leax      L6945,pcr
L67F8               pshs      x
                    lbsr      L4A44
                    lbra      L6916

L6800               pshs      u
                    lbsr      L4BEC
                    leax      L694A,pcr
                    pshs      x
                    lbsr      L4A9B
                    lbra      L6916

L6811               pshs      u
                    ldd       $04,s
                    beq       L681C
                    ldd       #$0064
                    bra       L6826

L681C               ldd       #$0076
                    bra       L6826

L6821               pshs      u
                    ldd       #$0065
L6826               pshs      d
                    lbsr      L4A85
                    lbra      L6916

L682E               pshs      u
                    ldd       $04,s
                    pshs      d
                    lbsr      L702C
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
                    lbsr      L77E0
                    leas      $08,s
                    ldd       $02C8,y
                    puls      pc,u
L686D               pshs      u
                    ldd       $006C
                    lbeq      L6918
                    ldd       $006C
                    pshs      d
                    bsr       L682E
                    leas      $02,s
                    bra       L688A

L687F               ldd       $0025
                    pshs      d
                    pshs      u
                    lbsr      L6F01
                    leas      $04,s
L688A               ldd       $006C
                    pshs      d
                    lbsr      L711C
                    leas      $02,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L687F
                    ldx       $006C
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L68AD
                    leax      L694D,pcr
                    ldd       $06,x
                    clra
                    andb      #$20
L68AD               ldd       $006C
                    pshs      d
                    lbsr      L6FF2
                    leas      $02,s
                    leax      $01A9,y
                    pshs      x
                    lbsr      L7771
                    bra       L6916

L68C1               pshs      u,d
                    ldd       $02D2,y
                    beq       L68CF
                    ldd       $02D2,y
                    bra       L68D2

L68CF               ldd       #$0001
L68D2               std       ,s
                    leax      $01C1,y
                    pshs      x
                    lbsr      L702C
                    leas      $02,s
                    ldd       $006C
                    beq       L68F7
                    ldd       $006C
                    pshs      d
                    lbsr      L6FF2
                    leas      $02,s
                    leax      $01A9,y
                    pshs      x
                    lbsr      L7771
                    leas      $02,s
L68F7               ldd       $001F
                    beq       L690D
                    ldd       L0023
                    pshs      d
                    lbsr      L6FF2
                    leas      $02,s
                    ldd       $001F
                    pshs      d
                    lbsr      L7771
                    leas      $02,s
L690D               ldd       ,s
                    pshs      d
                    lbsr      L7946
                    leas      $02,s
L6916               leas      $02,s
L6918               puls      pc,u
L691A               fcc       / rmb %d/
                    fcb       $0D,$00
L6923               fcc       /%.8s%c rmb %d/
                    fcb       $0D,$00
L6932               fcc       /%.8s%c/
                    fcb       $00
L6939               fcc       /%.8s%c/
                    fcb       $00
L6940               fcc       /fcb /
                    fcb       $00
L6945               fcc       /fdb /
                    fcb       $00
L694A               fcb       $2A,$20
                    fcb       $00
L694D               fcc       /dumpstrings/
                    fcb       $00
L6959               pshs      u
                    leau      $02C6,y
                    ldd       ,x
                    std       ,u
                    ldd       $02,x
                    std       $02,u
                    ldd       $04,x
                    std       $04,u
                    ldd       $06,x
                    std       $06,u
                    tfr       u,x
                    puls      pc,u
L6973               bsr       L6959
                    lda       ,x
                    eora      #$80
                    sta       ,x
                    rts

L697C               bsr       L6981
                    ldd       $02,x
                    rts

L6981               lda       ,x
                    pshs      a
                    bsr       L6959
                    bsr       L6993
                    leax      $03,x
                    lda       ,s+
                    bpl       L6992
                    lbra      L7496

L6992               rts

L6993               lda       $07,x
                    blt       L69C1
                    pshs      x
                    leax      $07,x
                    pshs      x,a
                    bra       L69B9

L699F               ldx       $01,s
                    ldb       #$06
                    pshs      b
                    clra
L69A6               pshs      a
                    lda       #$0a
                    ldb       ,-x
                    mul
                    addb      ,s+
                    adca      #$00
                    stb       ,x
                    dec       ,s
                    bpl       L69A6
                    leas      $01,s
L69B9               dec       ,s
                    bge       L699F
                    leas      $03,s
                    puls      pc,x
L69C1               pshs      u,x,a
                    leau      $07,x
                    pshs      u
L69C7               cmpx      ,s
                    bcc       L69FB
                    lda       ,x+
                    beq       L69C7
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
L69DF               asl       ,x
                    rolb
                    cmpb      #$0a
                    bcs       L69EA
                    subb      #$0a
                    inc       ,x
L69EA               deca
                    bne       L69DF
                    lda       #$08
                    leax      $01,x
                    cmpx      $02,s
                    bcs       L69DF
                    puls      x
                    inc       $02,s
                    bne       L69C7
L69FB               leas      $03,s
                    puls      pc,u,x
L69FF               pshs      u
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
                    rts

L6A1C               leax      $02C6,y
                    std       -$02,s
                    bpl       L6A37
                    nega
                    negb
                    sbca      #$00
                    std       $05,x
                    lda       #$80
L6A2C               sta       ,x
                    clra
                    clrb
                    std       $01,x
                    std       $03,x
                    sta       $07,x
                    rts

L6A37               std       $05,x
                    clra
                    bra       L6A2C

L6A3C               pshs      u
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
                    bpl       L6A6C
                    lda       #$80
                    sta       ,u
                    ldd       #$0000
                    subd      $05,u
                    std       $05,u
                    ldd       #$0000
                    sbcb      $04,u
                    sbca      $03,u
                    std       $03,u
L6A6C               tfr       u,x
                    puls      pc,u
main                pshs      u
                    leax      L68C1,pcr
                    pshs      x
                    lbsr      L7910
                    leas      $02,s
                    leax      $01A9,y
                    pshs      x
                    lbsr      L6E81
                    leas      $02,s
                    leax      L6C15,pcr
                    pshs      x
                    ldd       $01A7,y
                    pshs      d
                    lbsr      L7311
                    leas      $04,s
                    lbsr      L5897
                    leax      $01B4,y
                    stx       L0023
                    leax      $01C1,y
                    stx       $0025
                    lbra      L6B9D

L6AAB               ldx       $06,s
                    leax      $02,x
                    stx       $06,s
                    ldu       ,x
                    ldb       ,u
                    cmpb      #$2d
                    lbne      L6B68
                    lbra      L6B5A

L6ABE               ldb       ,u
                    sex
                    tfr       d,x
                    lbra      L6B37

L6AC6               ldd       #$0001
                    std       $0021
                    lbra      L6B5A

L6ACE               ldd       #$0001
                    std       $0035
                    lbra      L6B5A

L6AD6               ldd       L0039
                    addd      #$0001
                    std       L0039
                    lbra      L6B5A

L6AE0               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L6B11
                    leax      L6C1D,pcr
                    pshs      x
                    leau      $01,u
                    pshs      u
                    lbsr      L6DED
                    leas      $04,s
                    std       $0025
                    bne       L6B11
                    pshs      u
                    leax      L6C1F,pcr
                    pshs      x
                    leax      $01CE,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    lbsr      L6BFA
L6B11               leax      ,s
                    bra       L6B64

L6B15               ldd       #$0001
                    std       L0037
                    bra       L6B5A

L6B1C               ldb       ,u
                    sex
                    pshs      d
                    leax      L6C2E,pcr
                    pshs      x
                    leax      $01CE,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    lbsr      L6BFA
                    bra       L6B5A

L6B37               cmpx      #$0065
                    lbeq      L6AC6
                    cmpx      #$0073
                    lbeq      L6ACE
                    cmpx      #$006E
                    lbeq      L6AD6
                    cmpx      #$006F
                    lbeq      L6AE0
                    cmpx      #$0070
                    beq       L6B15
                    bra       L6B1C

L6B5A               leau      $01,u
                    ldb       ,u
                    lbne      L6ABE
                    bra       L6B9D

L6B64               leas      ,x
                    bra       L6B9D

L6B68               ldd       $0072
                    bne       L6B9D
                    ldd       $0072
                    addd      #$0001
                    std       $0072
                    leax      $01B4,y
                    pshs      x
                    leax      L6C42,pcr
                    pshs      x
                    ldd       [$0a,s]
                    pshs      d
                    lbsr      L6E0C
                    leas      $06,s
                    std       L0023
                    bne       L6B98
                    leax      L6C44,pcr
                    pshs      x
                    lbsr      L0228
                    leas      $02,s
L6B98               ldd       [$06,s]
                    std       $001F
L6B9D               ldd       $04,s
                    addd      #$FFFF
                    std       $04,s
                    lbgt      L6AAB
                    lbsr      L6332
                    lbsr      L552B
                    bra       L6BB3

L6BB0               lbsr      L3227
L6BB3               ldd       $005F
                    cmpd      #$FFFF
                    bne       L6BB0
                    lbsr      L66B6
                    ldx       $0025
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L6BD2
                    leax      L6C5A,pcr
                    pshs      x
                    lbsr      L0228
                    leas      $02,s
L6BD2               leax      $01C1,y
                    pshs      x
                    lbsr      L702C
                    leas      $02,s
                    ldd       L0029
                    beq       L6BF8
                    ldd       L0029
                    pshs      d
                    leax      L6C7B,pcr
                    pshs      x
                    leax      $01CE,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    bsr       L6BFA
L6BF8               puls      pc,u
L6BFA               pshs      u
                    ldd       $001F
                    beq       L6C09
                    ldd       $001F
                    pshs      d
                    lbsr      L7771
                    leas      $02,s
L6C09               ldd       #$0001
                    pshs      d
                    lbsr      exit
                    leas      $02,s
                    puls      pc,u
L6C15               fcc       /_dummy_/
                    fcb       $00
L6C1D               fcb       $77
                    fcb       $00
L6C1F               fcc       /can't open %s/
                    fcb       $0D,$00
L6C2E               fcc       /unknown flag : -%c/
                    fcb       $0D,$00
L6C42               fcb       $72
                    fcb       $00
L6C44               fcc       /can't open input file/
                    fcb       $00
L6C5A               fcc       /error writing assembly code file/
                    fcb       $00
L6C7B               fcc       /errors in compilation : %d/
                    fcb       $0D,$00
L6C97               pshs      u
                    leau      $01B4,y
L6C9D               ldd       $06,u
                    clra
                    andb      #$03
                    lbeq      L6D0E
                    leau      $0d,u
                    pshs      u
                    leax      $0284,y
                    cmpx      ,s++
                    bhi       L6C9D
                    ldd       #$00C8
                    std       $02D2,y
                    lbra      L6D12
                    puls      pc,u
L6CBE               pshs      u
                    ldu       $08,s
                    bne       L6CC8
                    bsr       L6C97
                    tfr       d,u
L6CC8               stu       -$02,s
                    beq       L6D12
                    ldd       $04,s
                    std       $08,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2b
                    beq       L6CE0
                    ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L6CE6
L6CE0               ldd       $06,u
                    orb       #$03
                    bra       L6D04

L6CE6               ldd       $06,u
                    pshs      d
                    ldb       [$08,s]
                    cmpb      #$72
                    beq       L6CF8
                    ldb       [$08,s]
                    cmpb      #$64
                    bne       L6CFD
L6CF8               ldd       #$0001
                    bra       L6D00

L6CFD               ldd       #$0002
L6D00               ora       ,s+
                    orb       ,s+
L6D04               std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
L6D0E               tfr       u,d
                    puls      pc,u
L6D12               clra
                    clrb
                    puls      pc,u
L6D16               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0a,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L6D47

L6D29               ldx       $0a,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L6D36
                    ldd       #$0007
                    bra       L6D3E

L6D36               ldd       #$0004
                    bra       L6D3E

L6D3B               ldd       #$0003
L6D3E               std       ,s
                    bra       L6D57

L6D42               leax      $04,s
                    lbra      L6DAF

L6D47               stx       -$02,s
                    beq       L6D57
                    cmpx      #$0078
                    beq       L6D29
                    cmpx      #$002B
                    beq       L6D3B
                    bra       L6D42

L6D57               ldb       [$0a,s]
                    sex
                    tfr       d,x
                    lbra      L6DBC

L6D60               ldd       ,s
                    orb       #$01
                    bra       L6DA2

L6D66               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L770A
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L6D91
                    ldd       #$0002
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L77E0
                    leas      $08,s
                    bra       L6DD6

L6D91               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L772B
                    bra       L6DA9

L6D9E               ldd       ,s
                    orb       #$81
L6DA2               pshs      d
                    pshs      u
                    lbsr      L770A
L6DA9               leas      $04,s
                    std       $02,s
                    bra       L6DD6

L6DAF               leas      -$04,x
L6DB1               ldd       #$00CB
                    std       $02D2,y
                    clra
                    clrb
                    bra       L6DD8

L6DBC               cmpx      #$0072
                    lbeq      L6D60
                    cmpx      #$0061
                    lbeq      L6D66
                    cmpx      #$0077
                    beq       L6D91
                    cmpx      #$0064
                    beq       L6D9E
                    bra       L6DB1

L6DD6               ldd       $02,s
L6DD8               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L6E38

L6DED               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L6D16
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L6E08
                    clra
                    clrb
                    bra       L6E3D

L6E08               clra
                    clrb
                    bra       L6E30

L6E0C               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L6FF2
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L6D16
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L6E2E
                    clra
                    clrb
                    bra       L6E3D

L6E2E               ldd       $08,s
L6E30               pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
L6E38               lbsr      L6CBE
                    leas      $06,s
L6E3D               puls      pc,u
L6E3F               pshs      u
                    leax      $01C1,y
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    bsr       L6E61
                    leas      $04,s
                    leax      $01C1,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    puls      pc,u
L6E61               pshs      u
                    ldu       $04,s
                    leas      -$01,s
                    bra       L6E77

L6E69               ldd       $07,s
                    pshs      d
                    ldb       $02,s
                    sex
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
L6E77               ldb       ,u+
                    stb       ,s
                    bne       L6E69
                    leas      $01,s
                    puls      pc,u
L6E81               pshs      u,d
                    ldu       $06,s
                    bra       L6E89

L6E87               leau      $01,u
L6E89               ldb       ,u
                    sex
                    std       ,s
                    beq       L6E98
                    ldd       ,s
                    cmpd      #$0058
                    bne       L6E87
L6E98               ldd       ,s
                    beq       L6EAE
                    lbsr      L78CB
                    pshs      d
                    leax      >L6EB4,pcr
                    pshs      x
                    pshs      u
                    lbsr      L50FC
                    leas      $06,s
L6EAE               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
L6EB4               bcs       L6F1A
                    neg       $0034
                    nega
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L6EF2

L6EC1               clra
                    clrb
                    std       ,s
                    bra       L6EDE

L6EC7               ldd       $0e,s
                    pshs      d
                    ldb       ,u+
                    sex
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldx       $0e,s
                    ldd       $06,x
                    clra
                    andb      #$20
                    bne       L6EFB
L6EDE               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      $0a,s
                    blt       L6EC7
                    ldd       $02,s
                    addd      #$0001
L6EF2               std       $02,s
                    ldd       $02,s
                    cmpd      $0C,s
                    blt       L6EC1
L6EFB               ldd       $02,s
                    leas      $04,s
                    puls      pc,u
L6F01               pshs      u
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L6F25
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
L6F1A               lbne      L703D
                    pshs      u
                    lbsr      L7270
                    leas      $02,s
L6F25               ldd       $06,u
                    clra
                    andb      #$04
                    beq       L6F61
                    ldd       #$0001
                    pshs      d
                    leax      $07,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L6F46
                    leax      L77D0,pcr
                    bra       L6F4A

L6F46               leax      L77B7,pcr
L6F4A               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L6FA2
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      L703D

L6F61               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L6F71
                    pshs      u
                    lbsr      L705A
                    leas      $02,s
L6F71               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L6F97
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L6FA2
                    ldd       $04,s
                    cmpd      #$000D
                    bne       L6FA2
L6F97               pshs      u
                    lbsr      L705A
                    std       ,s++
                    lbne      L703D
L6FA2               ldd       $04,s
                    puls      pc,u
L6FA6               pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      L7669
                    pshs      d
                    lbsr      L6F01
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L6F01
                    lbra      L7114

L6FC9               pshs      u,d
                    leau      $01B4,y
                    clra
                    clrb
                    std       ,s
                    bra       L6FDF

L6FD5               tfr       u,d
                    leau      $0d,u
                    pshs      d
                    bsr       L6FF2
                    leas      $02,s
L6FDF               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L6FD5
                    lbra      L7056

L6FF2               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L7002
                    ldd       $06,u
                    bne       L7008
L7002               ldd       #$FFFF
                    lbra      L7056

L7008               ldd       $06,u
                    clra
                    andb      #$02
                    beq       L7017
                    pshs      u
                    bsr       L702C
                    leas      $02,s
                    bra       L7019

L7017               clra
                    clrb
L7019               std       ,s
                    ldd       $08,u
                    pshs      d
                    lbsr      L7719
                    leas      $02,s
                    clra
                    clrb
                    std       $06,u
                    ldd       ,s
                    bra       L7056

L702C               pshs      u
                    ldu       $04,s
                    beq       L703D
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L7042
L703D               ldd       #$FFFF
                    puls      pc,u
L7042               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L7052
                    pshs      u
                    lbsr      L7270
                    leas      $02,s
L7052               pshs      u
                    bsr       L705A
L7056               leas      $02,s
                    puls      pc,u
L705A               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L708C
                    ldd       ,u
                    cmpd      $04,u
                    beq       L708C
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L7118
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L77E0
                    leas      $08,s
L708C               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      L7104
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L7104
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L70DB
                    ldd       $02,u
                    bra       L70D3

L70AC               ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L77D0
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L70C9
                    leax      $04,s
                    bra       L70F3

L70C9               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L70D3               std       ,u
                    ldd       $02,s
                    bne       L70AC
                    bra       L7104

L70DB               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L77B7
                    leas      $06,s
                    cmpd      $02,s
                    beq       L7104
                    bra       L70F5

L70F3               leas      -$04,x
L70F5               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L7114

L7104               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
L7114               leas      $04,s
                    puls      pc,u
L7118               pshs      u
                    puls      pc,u
L711C               pshs      u
                    ldu       $04,s
                    beq       L7168
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L7168
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L7144
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    lbra      L726E

L7144               pshs      u
                    lbsr      L71B7
                    lbra      L726C
                    pshs      u
                    ldu       $06,s
                    beq       L7168
                    ldd       $06,u
                    clra
                    andb      #$01
                    beq       L7168
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       L7168
                    ldd       ,u
                    cmpd      $02,u
                    bhi       L716D
L7168               ldd       #$FFFF
                    puls      pc,u
L716D               ldd       ,u
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
                    lbsr      L711C
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L71A2
                    pshs      u
                    lbsr      L711C
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L71A7
L71A2               ldd       #$FFFF
                    bra       L71B3

L71A7               ldd       $02,s
                    pshs      d
                    ldd       #$0008
                    lbsr      L7680
                    addd      ,s
L71B3               leas      $04,s
                    puls      pc,u
L71B7               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       L71DD
                    ldd       $06,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    lbne      L7256
                    pshs      u
                    lbsr      L7270
                    leas      $02,s
L71DD               leax      $01B4,y
                    pshs      x
                    cmpu      ,s++
                    bne       L71FA
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L71FA
                    leax      $01C1,y
                    pshs      x
                    lbsr      L702C
                    leas      $02,s
L71FA               ldd       $06,u
                    clra
                    andb      #$08
                    beq       L7226
                    ldd       $0b,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L721A
                    leax      L77A7,pcr
                    bra       L721E

L721A               leax      L7786,pcr
L721E               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       L7238

L7226               ldd       #$0001
                    pshs      d
                    leax      $0a,u
                    stx       $02,u
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    lbsr      L7786
L7238               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       L725B
                    ldd       $06,u
                    pshs      d
                    ldd       $02,s
                    beq       L724D
                    ldd       #$0020
                    bra       L7250

L724D               ldd       #$0010
L7250               ora       ,s+
                    orb       ,s+
                    std       $06,u
L7256               ldd       #$FFFF
                    bra       L726C

L725B               ldd       $02,u
                    addd      #$0001
                    std       ,u
                    ldd       $02,u
                    addd      ,s
                    std       $04,u
                    ldb       [$02,u]
                    clra
L726C               leas      $02,s
L726E               puls      pc,u
L7270               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       L72A8
                    leas      -$20,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L769B
                    leas      $06,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       L729C
                    ldd       #$0040
                    bra       L729F

L729C               ldd       #$0080
L729F               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $20,s
L72A8               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       L72B5
                    puls      pc,u
L72B5               ldd       $0b,u
                    bne       L72CA
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L72C5
                    ldd       #$0080
                    bra       L72C8

L72C5               ldd       #$0100
L72C8               std       $0b,u
L72CA               ldd       $02,u
                    bne       L72DF
                    ldd       $0b,u
                    pshs      d
                    lbsr      L789E
                    leas      $02,s
                    std       $02,u
                    cmpd      #$FFFF
                    beq       L72E7
L72DF               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       L72F6

L72E7               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
L72F6               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    puls      pc,u
L7300               pshs      u
                    ldu       $04,s
L7304               ldb       ,u+
                    bne       L7304
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u
L7311               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L731B               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L731B
                    bra       L7350

L7329               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L7333               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L7333
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L7344               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L7344
L7350               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    bra       L736C

L735C               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L736A
                    clra
                    clrb
                    puls      pc,u
L736A               leau      $01,u
L736C               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L735C
                    ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u
L7387               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L7391               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L73B5
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L7391
                    bra       L73B5

L73AB               clra
                    clrb
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L73B5               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L73AB
                    lbra      L7444

L73C4               pshs      u
                    ldu       $04,s
                    bra       L73DA

L73CA               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L73D8
                    clra
                    clrb
                    puls      pc,u
L73D8               leau      $01,u
L73DA               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    ble       L73F4
                    ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L73CA
L73F4               ldd       $08,s
                    bge       L73FC
                    clra
                    clrb
                    bra       L7407

L73FC               ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
L7407               puls      pc,u
L7409               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L7413               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L7413
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L7424               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L743C
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L7424
L743C               ldd       $0a,s
                    bge       L7444
                    clra
                    clrb
                    stb       [,s]
L7444               ldd       $06,s
                    leas      $02,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
L744E               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
                    bgt       L744E
                    ldb       -$01,u
                    clra
                    andb      #$7f
                    stb       -$01,u
                    clra
                    clrb
                    stb       ,u
                    ldd       $04,s
                    puls      pc,u
L7469               ldd       $04,s
                    addd      $02,x
                    std       $02C8,y
                    ldd       $02,s
                    adcb      $01,x
                    adca      ,x
                    std       $02C6,y
                    lbra      L7521
                    ldd       $04,s
                    subd      $02,x
                    std       $02C8,y
                    ldd       $02,s
                    sbcb      $01,x
                    sbca      ,x
                    std       $02C6,y
                    lbra      L7521

L7493               lbsr      L7530
L7496               ldd       #$0000
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,x
                    sbca      ,x
                    std       ,x
                    rts

L74A7               ldd       ,x
                    coma
                    comb
                    std       $02C6,y
                    ldd       $02,x
                    coma
                    comb
                    leax      $02C6,y
                    std       $02,x
                    rts

L74BA               leax      $02C6,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    leax      $02C6,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
                    rts

L74D3               pshs      y
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

L74E9               ldx       $02,s
                    pshs      b
                    lbsr      L7530
                    puls      b
                    tstb
                    beq       L7500
L74F5               asl       $03,x
                    rol       $02,x
                    rol       $01,x
                    rol       ,x
                    decb
                    bne       L74F5
L7500               puls      d
                    std       ,s
                    rts
                    ldx       $02,s
                    pshs      b
                    lbsr      L7530
                    puls      b
                    tstb
                    beq       L751C
L7511               asr       ,x
                    ror       $01,x
                    ror       $02,x
                    ror       $03,x
                    decb
                    bne       L7511
L751C               puls      d
                    std       ,s
                    rts

L7521               tfr       cc,a
                    puls      x
                    stx       $02,s
                    leas      $02,s
                    leax      $02C6,y
                    tfr       a,cc
                    rts

L7530               ldd       ,x
                    std       $02C6,y
                    ldd       $02,x
                    leax      $02C6,y
                    std       $02,x
                    rts

L753F               tsta
                    bne       L7554
                    tst       $02,s
                    bne       L7554
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
L7554               pshs      d
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
                    bcc       L7571
                    inc       ,s
L7571               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L757E
                    inc       ,s
L757E               lda       $04,s
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
                    leax      >L75DA,pcr
                    stx       $080d,y
                    bra       L75B4

L75A0               leax      >L75F3,pcr
                    stx       $080d,y
                    clr       $080C,y
                    tst       $02,s
                    bpl       L75B4
                    inc       $080C,y
L75B4               subd      #$0000
                    bne       L75BF
                    puls      x
                    ldd       ,s++
                    jmp       ,x

L75BF               ldx       $02,s
                    pshs      x
                    jsr       [$080d,y]
                    ldd       ,s
                    std       $02,s
                    tfr       x,d
                    tst       $080C,y
                    beq       L75D7
                    nega
                    negb
                    sbca      #$00
L75D7               std       ,s++
                    rts

L75DA               subd      #$0000
                    beq       L75E9
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    bra       L7617

L75E9               puls      d
                    std       ,s
                    ldd       #$002D
                    lbra      L768C

L75F3               subd      #$0000
                    beq       L75E9
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    tsta
                    bpl       L760B
                    nega
                    negb
                    sbca      #$00
                    inc       $01,s
                    std       $02,s
L760B               ldd       $06,s
                    bpl       L7617
                    nega
                    negb
                    sbca      #$00
                    com       $01,s
                    std       $06,s
L7617               lda       #$01
L7619               inca
                    asl       $03,s
                    rol       $02,s
                    bpl       L7619
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
L7628               subd      $02,s
                    bcc       L7632
                    addd      $02,s
                    andcc     #$FE
                    bra       L7634

L7632               orcc      #$01
L7634               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       L7628
                    std       $02,s
                    tst       $01,s
                    beq       L764E
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L764E               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
                    leas      $06,s
                    rts

L765D               tstb
                    beq       L7673
L7660               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L7660
                    bra       L7673

L7669               tstb
                    beq       L7673
L766C               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L766C
L7673               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts

L7680               tstb
                    beq       L7673
L7683               asl       $03,s
                    rol       $02,s
                    decb
                    bne       L7683
                    bra       L7673

L768C               std       $02D2,y
                    pshs      y,b
                    os9       F$ID
                    puls      y,b
                    os9       F$Send
                    rts

L769B               lda       $05,s
                    ldb       $03,s
                    beq       L76CE
                    cmpb      #$01
                    beq       L76D0
                    cmpb      #$06
                    beq       L76D0
                    cmpb      #$02
                    beq       L76B6
                    cmpb      #$05
                    beq       L76B6
                    ldb       #$D0
                    lbra      L7932

L76B6               pshs      u
                    os9       I$GetStt
                    bcc       L76C2
                    puls      u
                    lbra      L7932

L76C2               stx       [$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

L76CE               ldx       $06,s
L76D0               os9       I$GetStt
                    lbra      L793B
                    lda       $05,s
                    ldb       $03,s
                    beq       L76E5
                    cmpb      #$02
                    beq       L76ED
                    ldb       #$D0
                    lbra      L7932

L76E5               ldx       $06,s
                    os9       I$SetStt
                    lbra      L793B

L76ED               pshs      u
                    ldx       $08,s
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u
                    lbra      L793B
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       L7707
                    os9       I$Close
L7707               lbra      L793B

L770A               ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      L7932
                    tfr       a,b
                    clra
                    rts

L7719               lda       $03,s
                    os9       I$Close
                    lbra      L793B
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      L793B

L772B               ldx       $02,s
                    lda       $05,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0b
                    os9       I$Create
                    bcs       L773E
L773A               tfr       a,b
                    clra
                    rts

L773E               cmpb      #$DA
                    lbne      L7932
                    lda       $05,s
                    bita      #$80
                    lbne      L7932
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      L7932
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L773A
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      L7932

L7771               ldx       $02,s
                    os9       I$Delete
                    lbra      L793B
                    lda       $03,s
                    os9       I$Dup
                    lbcs      L7932
                    tfr       a,b
                    clra
                    rts

L7786               pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
L7794               bcc       L77A3
                    cmpb      #$D3
                    bne       L779E
                    clra
                    clrb
                    puls      pc,y,x
L779E               puls      y,x
                    lbra      L7932

L77A3               tfr       y,d
                    puls      pc,y,x
L77A7               pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
                    bra       L7794

L77B7               pshs      y
                    ldy       $08,s
                    beq       L77CC
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
L77C5               bcc       L77CC
                    puls      y
                    lbra      L7932

L77CC               tfr       y,d
                    puls      pc,y
L77D0               pshs      y
                    ldy       $08,s
                    beq       L77CC
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
                    bra       L77C5

L77E0               pshs      u
                    ldd       $0a,s
                    bne       L77EE
                    ldu       #$0000
                    ldx       #$0000
                    bra       L7822

L77EE               cmpd      #$0001
                    beq       L7819
                    cmpd      #$0002
                    beq       L780E
                    ldb       #$F7
L77FC               clra
                    std       $02D2,y
                    ldd       #$FFFF
                    leax      $02C6,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
L780E               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L77FC
                    bra       L7822

L7819               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L77FC
L7822               tfr       u,d
                    addd      $08,s
                    std       $02C8,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L77FC
                    tfr       d,x
                    std       $02C6,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       L77FC
                    leax      $02C6,y
                    puls      pc,u
L7847               ldd       $02C4,y
                    pshs      d
                    ldd       $04,s
                    cmpd      $080f,y
                    bcs       L787B
                    addd      $02C4,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       L786D
                    ldd       #$FFFF
                    leas      $02,s
                    rts

L786D               std       $02C4,y
                    addd      $080f,y
                    subd      ,s
                    std       $080f,y
L787B               leas      $02,s
                    ldd       $080f,y
                    pshs      d
                    subd      $04,s
                    std       $080f,y
                    ldd       $02C4,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
L7894               sta       ,x+
                    cmpx      $02C4,y
                    bcs       L7894
                    puls      pc,d
L789E               ldd       $02,s
                    addd      $02CE,y
                    bcs       L78C7
                    cmpd      $02D0,y
                    bcc       L78C7
                    pshs      d
                    ldx       $02CE,y
                    clra
L78B4               cmpx      ,s
                    bcc       L78BC
                    sta       ,x+
                    bra       L78B4

L78BC               ldd       $02CE,y
                    puls      x
                    stx       $02CE,y
                    rts

L78C7               ldd       #$FFFF
                    rts

L78CB               pshs      y
                    os9       F$ID
                    puls      y
                    bcc       L78D8
                    lbcs      L7932
L78D8               tfr       a,b
                    clra
                    rts

L78DC               pshs      y
                    os9       F$ID
                    bcc       L78E8
L78E3               puls      y
                    lbra      L7932

L78E8               tfr       y,d
                    puls      pc,y
                    pshs      y
                    bsr       L78DC
                    std       -$02,s
                    beq       L78F8
                    ldb       #$D6
                    bra       L78E3

L78F8               ldy       $04,s
                    os9       F$SUser
                    bcc       L790C
                    cmpb      #$D0
                    bne       L78E3
                    tfr       y,d
                    ldy       >$004B
                    std       $09,y
L790C               clra
                    clrb
                    puls      pc,y
L7910               pshs      u
                    tfr       y,u
                    ldx       $04,s
                    stx       $0811,y
                    leax      >L7926,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      L793B

L7926               tfr       u,y
                    clra
                    pshs      d
                    jsr       [$0811,y]
                    leas      $02,s
                    rti

L7932               clra
                    std       $02D2,y
                    ldd       #$FFFF
                    rts

L793B               bcs       L7932
                    clra
                    clrb
                    rts

exit                lbsr      L794B
                    lbsr      L6FC9
L7946               ldd       $02,s
                    os9       F$Exit
L794B               rts

* ------------------------------------------------------------------
* L794C - cc1-style init image for the work block (see _start):
* rts stub + count/block table + relocation dirs + module-name string.
* ------------------------------------------------------------------
L794C               fcb       $00,$03,$00,$00,$89,$02,$0E init table / work-block image
                    fcc       /x expected/
                    fcb       $00
                    fcb       $27
                    fcb       $10,$03,$E8,$00
                    fcb       $64
                    fcb       $00,$0A,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00
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
                    fcb       $00,$07,$0B,$00,$01,$00,$02,$00
                    fcb       $00,$00,$00,$00,$0C,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$01
                    fcb       $9F
                    fcc       /cstr.XXXXX/
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
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
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$03,$00,$01,$01,$89,$01,$A7
                    fcc       /c.pass1/
                    fcb       $00
                    emod
eom                 equ       *
                    end
