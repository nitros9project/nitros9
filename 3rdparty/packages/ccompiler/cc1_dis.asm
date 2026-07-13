                    nam       cc1
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $04

                    mod       eom,name,tylg,atrv,_start,size

u0000               rmb       2401
size                equ       .

name                equ       *
                    fcs       /cc1/
                    fcb       edition

copybytes           lda       ,y+
L0013               sta       ,u+
L0015               leax      -$01,x
L0017               bne       copybytes
L0019               rts

_start              pshs      y
                    pshs      u
                    clra
L001F               clrb
L0020               sta       ,u+
                    decb
L0023               bne       L0020
L0025               ldx       ,s
L0027               leau      ,x
L0029               leax      $05E1,x
L002D               pshs      x
L002F               leay      L1DAC,pcr
                    ldx       ,y++
                    beq       L003B
                    bsr       copybytes
                    ldu       $02,s
L003B               leau      >$002d,u
                    ldx       ,y++
L0041               beq       L0046
L0043               bsr       copybytes
L0045               clra
L0046               cmpu      ,s
                    beq       L004F
L004B               sta       ,u+
L004D               bra       L0046

L004F               ldu       $02,s
                    ldd       ,y++
L0053               beq       L005C
                    leax      >$0000,pcr
                    lbsr      L015F
L005C               ldd       ,y++
                    beq       L0065
                    leax      ,u
                    lbsr      L015F
L0065               leas      $04,s
L0067               puls      x
L0069               stx       $01FF,u
L006D               sty       $01BF,u
L0072               ldd       #$0001
L0075               std       $01FB,u
                    leay      $01C1,u
                    leax      ,s
                    lda       ,x+
L0081               ldb       $01FC,u
                    cmpb      #$1d
                    beq       L00DD
L0089               cmpa      #$0d
                    beq       L00DD
                    cmpa      #$20
                    beq       L0095
                    cmpa      #$2C
                    bne       L0099
L0095               lda       ,x+
                    bra       L0089

L0099               cmpa      #$22
                    beq       L00A1
                    cmpa      #$27
                    bne       L00BF
L00A1               stx       ,y++
                    inc       $01FC,u
                    pshs      a
L00A9               lda       ,x+
                    cmpa      #$0d
                    beq       L00B3
                    cmpa      ,s
                    bne       L00A9
L00B3               puls      b
                    clr       -$01,x
                    cmpa      #$0d
                    beq       L00DD
                    lda       ,x+
                    bra       L0081

L00BF               leax      -$01,x
                    stx       ,y++
                    leax      $01,x
                    inc       $01FC,u
L00C9               cmpa      #$0d
L00CB               beq       L00D9
                    cmpa      #$20
                    beq       L00D9
                    cmpa      #$2C
                    beq       L00D9
                    lda       ,x+
                    bra       L00C9

L00D9               clr       -$01,x
                    bra       L0081

L00DD               leax      $01BF,u
                    pshs      x
                    ldd       $01FB,u
                    pshs      d
                    leay      ,u
                    bsr       stkinit
                    lbsr      main
                    clr       ,-s
                    clr       ,-s
                    lbsr      exit
stkinit             leax      $05E1,y
                    stx       $0209,y
                    sts       $01FD,y
                    sts       $020b,y
                    ldd       #$FF82
stkcheck            leax      d,s
                    cmpx      $020b,y
                    bcc       L011E
                    cmpx      $0209,y
                    bcs       L0138
                    stx       $020b,y
L011E               rts
L011F               fcc       /**** STACK OVERFLOW ****/
                    fcb       $0d       carriage return terminator
L0138               leax      L011F,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
                    os9       I$WritLn
                    clr       ,-s
                    lbsr      _exit
                    ldd       $01FD,y
                    subd      $020b,y
                    rts
                    ldd       $020b,y
                    subd      $0209,y
                    rts

L015F               pshs      x
                    leax      d,y
                    leax      d,x
                    pshs      x
L0167               ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      $02,s
                    std       ,x
                    cmpy      ,s
                    bne       L0167
                    leas      $04,s
                    rts

main                pshs      u
                    ldd       #$FFA1
                    lbsr      stkcheck
                    leas      -$0f,s
                    leax      L0D1A,pcr
                    pshs      x
                    ldd       >$005f,y
                    pshs      d
                    leax      $0088,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    clra
                    clrb
                    std       $08,s
                    leax      >$002d,y
                    pshs      x
                    lbsr      L1156
                    leas      $02,s
                    leax      L0D26,pcr
                    pshs      x
                    leax      >$0041,y
                    pshs      x
                    lbsr      L1104
                    leas      $04,s
                    std       $002B
                    lbne      L043E
                    leax      $0D28,pcr
                    pshs      x
                    lbsr      L0C17
                    leas      $02,s
                    lbra      L043E

L01CE               ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       ,x
                    std       $0C,s
                    tfr       d,x
                    ldb       ,x
                    cmpb      #$2d
                    lbne      L03CA
                    lbra      L03B6

L01E7               ldb       [$0C,s]
                    clra
                    andb      #$DF
                    tfr       d,x
                    lbra      L0359

L01F2               ldx       $0C,s
                    ldb       $01,x
                    lbeq      L0341
                    ldd       #$002D
                    ldx       $0C,s
                    leax      -$01,x
                    stx       $0C,s
                    stb       ,x
                    ldd       #$0044
                    ldx       $0C,s
                    stb       $01,x
                    ldd       L0027
                    addd      #$0001
                    std       L0027
                    subd      #$0001
                    aslb
                    rola
                    leax      $0343,y
                    lbra      L033B

L021F               ldd       #$002D
                    ldx       $0C,s
                    leax      -$01,x
                    stx       $0C,s
                    stb       ,x
                    ldd       $0C,s
                    std       L0023
                    lbra      L0341

L0231               ldd       #$0001
                    std       L0019
                    lbra      L03B6

L0239               ldd       #$0001
                    std       $0007
                    lbra      L03B6

L0241               ldd       #$0001
                    std       $0001
                    lbra      L03B6

L0249               ldd       #$0001
                    std       L0015
                    lbra      L03B6

L0251               ldd       #$0001
                    std       copybytes
                    lbra      L03B6

L0259               ldd       #$0001
                    std       $000B
                    lbra      L03B6

L0261               ldd       #$0001
                    std       $000D
                    lbra      L03B6

L0269               leax      >$0021,y
                    stx       $0a,s
                    leax      $0f,s
                    bra       L027B

L0273               leax      >$001f,y
                    stx       $0a,s
                    bra       L027D

L027B               leas      -$0f,x
L027D               ldb       [$0C,s]
                    clra
                    andb      #$5f
                    stb       [$0C,s]
                    ldx       $0C,s
                    ldb       $01,x
                    lbeq      L0341
                    ldd       #$002D
                    ldx       $0C,s
                    leax      -$01,x
                    stx       $0C,s
                    stb       ,x
                    ldd       $0C,s
                    std       [$0a,s]
                    lbra      L0341

L02A1               ldx       $0C,s
                    leax      $01,x
                    stx       $0C,s
                    ldb       ,x
                    cmpb      #$3d
                    lbne      L0341
                    ldd       $0C,s
                    addd      #$0001
                    pshs      d
                    leax      $0537,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    ldb       $0537,y
                    lbeq      L0341
                    ldd       $0003
                    addd      #$0001
                    std       $0003
                    leax      $0537,y
                    pshs      x
                    lbsr      L0C72
                    leas      $02,s
                    stb       $0e,s
                    cmpb      #$63
                    beq       L02F3
                    ldb       $0e,s
                    cmpb      #$72
                    beq       L02F3
                    ldb       $0e,s
                    cmpb      #$43
                    beq       L02F3
                    ldb       $0e,s
                    cmpb      #$52
                    bne       L0341
L02F3               ldb       $0e,s
                    sex
                    pshs      d
                    leax      $0D46,pcr
                    pshs      x
                    lbsr      L0C17
                    leas      $04,s
                    bra       L0341

L0305               ldx       $0C,s
                    ldb       $01,x
                    cmpb      #$3d
                    bne       L0341
                    ldd       L0017
                    cmpd      #$0004
                    bne       L0320
                    leax      $0D6A,pcr
                    pshs      x
                    lbsr      L0C17
                    leas      $02,s
L0320               ldd       #$002D
                    ldx       $0C,s
                    leax      -$01,x
                    stx       $0C,s
                    stb       ,x
                    ldd       L0017
                    addd      #$0001
                    std       L0017
                    subd      #$0001
                    aslb
                    rola
                    leax      $020f,y
L033B               leax      d,x
                    ldd       $0C,s
                    std       ,x
L0341               leax      $0f,s
                    lbra      L03C5

L0346               ldb       [$0C,s]
                    sex
                    pshs      d
                    leax      $0D7D,pcr
                    pshs      x
                    lbsr      L0C17
                    leas      $04,s
                    bra       L03B6

L0359               cmpx      #$0044
                    lbeq      L01F2
                    cmpx      #$004E
                    lbeq      L021F
                    cmpx      #$0058
                    lbeq      L0231
                    cmpx      #$0053
                    lbeq      L0239
                    cmpx      #$0043
                    lbeq      L0241
                    cmpx      #$0050
                    lbeq      L0249
                    cmpx      #$004F
                    lbeq      L0251
                    cmpx      #$0052
                    lbeq      L0259
                    cmpx      #$0041
                    lbeq      L0261
                    cmpx      #$0045
                    lbeq      L0269
                    cmpx      #$004D
                    lbeq      L0273
                    cmpx      #$0046
                    lbeq      L02A1
                    cmpx      #$004C
                    lbeq      L0305
                    bra       L0346

L03B6               ldx       $0C,s
                    leax      $01,x
                    stx       $0C,s
                    ldb       ,x
                    lbne      L01E7
                    lbra      L043E

L03C5               leas      -$0f,x
                    lbra      L043E

L03CA               ldd       [$15,s]
                    pshs      d
                    lbsr      L0C72
                    leas      $02,s
                    stb       $0e,s
                    sex
                    tfr       d,x
                    bra       L0416

L03DB               ldd       #$0001
                    std       L0029
L03E0               ldd       L0025
                    leax      $02DF,y
                    leax      d,x
                    ldb       $0e,s
                    stb       ,x
                    ldd       L0025
                    aslb
                    rola
                    leax      $0217,y
                    leax      d,x
                    ldd       [$15,s]
                    std       ,x
                    ldd       L0025
                    addd      #$0001
                    std       L0025
                    bra       L043E

L0404               ldd       [$15,s]
                    pshs      d
                    leax      L0D91,pcr
                    pshs      x
                    lbsr      L0C17
                    leas      $04,s
                    bra       L043E

L0416               cmpx      #$0052
                    beq       L03DB
                    cmpx      #$0072
                    lbeq      L03DB
                    cmpx      #$0041
                    beq       L03E0
                    cmpx      #$0043
                    lbeq      L03E0
                    cmpx      #$0061
                    lbeq      L03E0
                    cmpx      #$0063
                    lbeq      L03E0
                    bra       L0404

L043E               ldd       $13,s
                    addd      #$FFFF
                    std       $13,s
                    ble       L0458
                    ldd       $08,s
                    addd      #$0001
                    std       $08,s
                    cmpd      #$0064
                    lblt      L01CE
L0458               ldd       L0025
                    bne       L0476
                    leax      $0DAB,pcr
                    pshs      x
                    leax      $0088,y
                    pshs      x
                    lbsr      fprintf
                    leas      $04,s
                    clra
                    clrb
                    pshs      d
                    lbsr      exit
                    leas      $02,s
L0476               ldd       $000D
                    addd      $000B
                    cmpd      #$0001
                    ble       L048F
                    clra
                    clrb
                    pshs      d
                    leax      $0DB6,pcr
                    pshs      x
                    lbsr      L0C17
                    leas      $04,s
L048F               ldd       $0003
                    beq       L04B4
                    ldd       L0025
                    cmpd      #$0001
                    ble       L04B4
                    ldd       $000D
                    bne       L04A3
                    ldd       $000B
                    beq       L04B4
L04A3               leax      $0537,y
                    pshs      x
                    leax      $0DC9,pcr
                    pshs      x
                    lbsr      L0C17
                    leas      $04,s
L04B4               ldd       $0003
                    bne       L04D9
                    ldd       L0025
                    cmpd      #$0001
                    bne       L04C8
                    ldd       $0217,y
                    pshs      d
                    bra       L04CE

L04C8               leax      $0DE9,pcr
                    pshs      x
L04CE               leax      $0537,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
L04D9               leax      >$002d,y
                    pshs      x
                    leax      $0447,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    leax      $0DF0,pcr
                    pshs      x
                    leax      $0447,y
                    pshs      x
                    lbsr      L19AB
                    leas      $04,s
                    leax      >$002d,y
                    pshs      x
                    leax      $0483,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    leax      L0DF3,pcr
                    pshs      x
                    leax      $0483,y
                    pshs      x
                    lbsr      L19AB
                    leas      $04,s
                    clra
                    clrb
                    std       $08,s
                    lbra      L09BE

L0524               leax      $0DF6,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $08,s
                    aslb
                    rola
                    leax      $0217,y
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0DFD,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $08,s
                    leax      $02DF,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$43
                    beq       L056B
                    ldd       $08,s
                    leax      $02DF,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$63
                    lbne      L07F7
L056B               ldd       #$0001
                    std       ,s
                    leax      $0447,y
                    pshs      x
                    leax      $04BF,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    ldd       #$006D
                    pshs      d
                    leax      $04BF,y
                    pshs      x
                    lbsr      L0C4C
                    leas      $04,s
                    leax      $0E00,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0E11,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $0001
                    beq       L05B6
                    leax      L0E19,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L05B6               ldd       $0021
                    beq       L05CE
                    ldd       $0021
                    pshs      d
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0E1D,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L05CE               clra
                    clrb
                    std       $04,s
                    bra       L05FA

L05D4               ldd       $04,s
                    addd      #$0001
                    std       $04,s
                    subd      #$0001
                    aslb
                    rola
                    leax      $0343,y
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0E1F,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L05FA               ldd       $04,s
                    cmpd      L0027
                    blt       L05D4
                    ldd       $08,s
                    aslb
                    rola
                    leax      $0217,y
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0E21,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04BF,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04BF,y
                    pshs      x
                    leax      $04FB,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    leax      $0E24,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0E36,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04FB,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       L0013
                    beq       L066B
                    leax      $0E3F,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L066B               ldd       $0007
                    beq       L067A
                    leax      L0E43,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L067A               ldd       L0015
                    beq       L0689
                    leax      L0E48,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L0689               leax      $0447,y
                    pshs      x
                    leax      $04BF,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    ldd       #$0069
                    pshs      d
                    leax      $04BF,y
                    pshs      x
                    lbsr      L0C4C
                    leas      $04,s
                    leax      L0E4D,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04BF,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       L0013
                    bne       L06E7
                    leax      $0E52,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04FB,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0E58,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    bra       L06F8

L06E7               leax      $04FB,y
                    pshs      x
                    leax      $0573,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
L06F8               leax      $0E5A,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0E69,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04BF,y
                    pshs      x
                    leax      $04FB,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    leax      $04FB,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $0007
                    beq       L0739
                    leax      $0E72,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L0739               ldd       L0015
                    beq       L0748
                    leax      L0E77,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L0748               ldd       L0013
                    beq       L0762
                    leax      L0E7C,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0573,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L0762               ldd       $000D
                    beq       L0794
                    ldd       $0003
                    beq       L077B
                    leax      $0537,y
                    pshs      x
                    leax      $04BF,y
                    pshs      x
                    lbsr      L1991
                    bra       L07A2

L077B               ldd       $08,s
                    aslb
                    rola
                    leax      $0217,y
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    leax      $04BF,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
L0794               ldd       #$0061
                    pshs      d
                    leax      $04BF,y
                    pshs      x
                    lbsr      L0C4C
L07A2               leas      $04,s
                    leax      L0E7E,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04BF,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0E83,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04FB,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       L0013
                    beq       L07EA
                    leax      $0E89,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0573,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L07EA               leax      $0E8B,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    bra       L07FB

L07F7               clra
                    clrb
                    std       ,s
L07FB               ldd       $000D
                    lbne      L09B7
                    ldd       $08,s
                    leax      $02DF,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$52
                    lbeq      L09B7
                    ldd       $08,s
                    leax      $02DF,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$72
                    lbeq      L09B7
                    ldd       $08,s
                    leax      $02DF,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$41
                    beq       L083D
                    ldd       $08,s
                    leax      $02DF,y
                    leax      d,x
                    ldb       ,x
                    cmpb      #$61
                    bne       L084D
L083D               ldd       $08,s
                    aslb
                    rola
                    leax      $0217,y
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    bra       L0853

L084D               leax      $04BF,y
                    pshs      x
L0853               leax      $04FB,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    ldd       copybytes
                    lbne      L08FD
                    leax      $0E8D,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0E9A,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04FB,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0447,y
                    pshs      x
                    leax      $04BF,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    ldd       #$006F
                    pshs      d
                    leax      $04BF,y
                    pshs      x
                    lbsr      L0C4C
                    leas      $04,s
                    leax      L0EA1,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04BF,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0EA3,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       ,s
                    beq       L08EC
                    leax      L0EA5,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04FB,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0EAA,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L08EC               leax      $04BF,y
                    pshs      x
                    leax      $04FB,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
L08FD               leax      $0EAC,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0EB9,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04FB,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       L0025
                    cmpd      #$0001
                    bne       L0932
                    ldd       $000B
                    bne       L0932
                    leax      $0483,y
L092E               pshs      x
                    bra       L0966

L0932               ldd       $0003
                    beq       L0940
                    ldd       $000B
                    beq       L0940
                    leax      $0537,y
                    bra       L092E

L0940               ldd       #$0072
                    pshs      d
                    ldd       $0a,s
                    aslb
                    rola
                    leax      $0217,y
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    lbsr      L0C4C
                    leas      $04,s
                    ldd       $08,s
                    aslb
                    rola
                    leax      $0217,y
                    leax      d,x
                    ldd       ,x
                    pshs      d
L0966               leax      $04BF,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    leax      L0EC0,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04BF,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0EC5,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       ,s
                    beq       L09B7
                    leax      $0EC7,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04FB,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0ECC,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L09B7               ldd       $08,s
                    addd      #$0001
                    std       $08,s
L09BE               ldd       $08,s
                    cmpd      L0025
                    lblt      L0524
                    ldd       $000D
                    lbne      L0B2A
                    ldd       $000B
                    lbne      L0B2A
                    ldd       $0003
                    bne       L09E6
                    clra
                    clrb
                    pshs      d
                    leax      $0537,y
                    pshs      x
                    lbsr      L0C4C
                    leas      $04,s
L09E6               leax      $0ECE,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0EDC,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0EE4,pcr
                    stx       $0C,s
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0CB8
                    leas      $02,s
                    leax      L0EE8,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       L0025
                    cmpd      #$0001
                    bne       L0A48
                    ldb       $02DF,y
                    cmpb      #$52
                    beq       L0A48
                    ldb       $02DF,y
                    cmpb      #$72
                    beq       L0A48
                    leax      $0EF6,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $04BF,y
                    stx       $001D
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    bra       L0A7C

L0A48               clra
                    clrb
                    bra       L0A6F

L0A4C               leax      $0EF8,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $08,s
                    aslb
                    rola
                    leax      $0217,y
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $08,s
                    addd      #$0001
L0A6F               std       $08,s
                    ldd       $08,s
                    cmpd      L0025
                    blt       L0A4C
                    clra
                    clrb
                    std       $001D
L0A7C               leax      $0EFA,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0537,y
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    clra
                    clrb
                    bra       L0AB9

L0A96               leax      $0EFF,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $06,s
                    aslb
                    rola
                    leax      $020f,y
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $06,s
                    addd      #$0001
L0AB9               std       $06,s
                    ldd       $06,s
                    cmpd      L0017
                    blt       L0A96
                    leax      $0F01,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $0C,s
                    pshs      d
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0F06,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       L0023
                    pshs      d
                    lbsr      L0BF5
                    leas      $02,s
                    ldd       $0021
                    pshs      d
                    lbsr      L0BF5
                    leas      $02,s
                    ldd       L001F
                    pshs      d
                    lbsr      L0BF5
                    leas      $02,s
                    leax      L0F13,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $001D
                    beq       L0B2A
                    leax      L0F15,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
                    ldd       $001D
                    pshs      d
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0F1A,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L0B2A               ldd       $002B
                    pshs      d
                    lbsr      L1780
                    leas      $02,s
                    ldd       L0019
                    lbne      L0BA0
                    leax      $0F1C,pcr
                    pshs      x
                    leax      $040b,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    leax      >$006e,y
                    pshs      x
                    leax      L0F23,pcr
                    pshs      x
                    leax      >$0041,y
                    pshs      x
                    lbsr      L1123
                    leas      $06,s
                    std       -$02,s
                    bne       L0B76
                    leax      >$0041,y
                    pshs      x
                    leax      $0F25,pcr
                    pshs      x
                    lbsr      L0C17
                    leas      $04,s
L0B76               clra
                    clrb
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    leax      $040b,y
                    pshs      x
                    leax      $040b,y
                    pshs      x
                    lbsr      L1980
                    std       ,s
                    leax      L0F37,pcr
                    pshs      x
                    lbsr      L1D13
                    leas      $0C,s
L0BA0               leas      $0f,s
                    puls      pc,u
                    pshs      u
                    ldd       #$FFB4
                    lbsr      stkcheck
                    leas      -$02,s
                    clra
                    clrb
                    pshs      d
                    ldd       #$0004
                    pshs      d
                    leax      $0F3D,pcr
                    pshs      x
                    lbsr      L1C31
                    leas      $06,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L0BCF
                    lbsr      L0F48
                    bra       L0BF1

L0BCF               pshs      u
                    ldd       $09,u
                    addd      ,s++
                    std       ,s
                    pshs      d
                    leax      $05A5,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    pshs      u
                    lbsr      L1C5A
                    leas      $02,s
                    leax      $05A5,y
                    tfr       x,d
L0BF1               puls      pc,u,x
                    puls      pc,u,x
L0BF5               pshs      u
                    ldd       #$FFBA
                    lbsr      stkcheck
                    ldd       $04,s
                    beq       L0C15
                    ldd       $04,s
                    pshs      d
                    lbsr      L0CB8
                    leas      $02,s
                    leax      $0F46,pcr
                    pshs      x
                    lbsr      L0CB8
                    leas      $02,s
L0C15               puls      pc,u
L0C17               pshs      u
                    ldd       #$FFB6
                    lbsr      stkcheck
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      $0088,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    leax      $0088,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      fputc
                    leas      $04,s
                    ldd       #$0001
                    pshs      d
                    lbsr      exit
                    puls      pc,u,x
L0C4C               pshs      u
                    ldd       #$FFC0
                    lbsr      stkcheck
                    ldu       $04,s
L0C56               ldb       ,u+
                    bne       L0C56
                    ldb       -$03,u
                    cmpb      #$2e
                    beq       L0C62
                    puls      pc,u
L0C62               ldb       $07,s
                    bne       L0C6C
                    clra
                    clrb
                    stb       -$03,u
                    bra       L0C70

L0C6C               ldb       $07,s
                    stb       -$02,u
L0C70               puls      pc,u
L0C72               pshs      u
                    ldd       #$FFBD
                    lbsr      stkcheck
                    ldu       $04,s
                    leas      -$03,s
L0C7E               clra
                    clrb
                    bra       L0C8D

L0C82               ldb       ,s
                    cmpb      #$2f
                    beq       L0C7E
                    ldd       $01,s
                    addd      #$0001
L0C8D               std       $01,s
                    ldb       ,u+
                    stb       ,s
                    bne       L0C82
                    ldd       $01,s
                    cmpd      #$001D
                    bgt       L0CB2
                    ldd       $01,s
                    cmpd      #$0002
                    ble       L0CB2
                    ldb       -$03,u
                    cmpb      #$2e
                    bne       L0CB2
                    ldb       -$02,u
                    sex
                    orb       #$40
                    bra       L0CB4

L0CB2               clra
                    clrb
L0CB4               leas      $03,s
                    puls      pc,u
L0CB8               pshs      u
                    ldd       #$FFB8
                    lbsr      stkcheck
                    ldd       $04,s
                    pshs      d
                    ldd       $002B
                    pshs      d
                    lbsr      fprintf
                    leas      $04,s
                    puls      pc,u
* ------------------------------------------------------------------
* String pool for the cc1 compiler driver: the sign-on banner, error
* messages, and the shell command-line fragments used to build the
* pass invocations (c.prep, c.pass1, ... c.link).  Referenced by the
* driver code via leax <label>,pcr; the banner (L0CCF) is reached
* indirectly through the relocated work-block pointer at base+$5f.
* ------------------------------------------------------------------
L0CCF               fcc       /CC1 VERSION %s/    sign-on banner, %s = version string
                    fcb       $0D
                    fcc       /COPYRIGHT 1983 MICROWARE/
                    fcb       $0D
                    fcc       /REPRODUCED UNDER LICENSE/
                    fcb       $0D
                    fcc       /TO TANDY/
                    fcb       $0D,$00
L0D1A               fcc       /RS 01.00.00/
                    fcb       $00
L0D26               fcc       /w/
                    fcb       $00
                    fcc       /can't open shell command file/
                    fcb       $00
                    fcc       /Suffix '.%c' not allowed for output/
                    fcb       $00
                    fcc       /Too many libraries/
                    fcb       $00
                    fcc       /unknown flag : -%c/
                    fcb       $0D,$00
L0D91               fcc       /%s : no recognized suffix/
                    fcb       $00
                    fcc       /no files!/
                    fcb       $0D,$00
                    fcc       /incompatible flags/
                    fcb       $00
                    fcc       /%s : output name not applicable/
                    fcb       $00
                    fcc       /output/
                    fcb       $00
                    fcc       /.m/
                    fcb       $00
L0DF3               fcc       /.r/
                    fcb       $00
                    fcc       /echo '/
                    fcb       $00
L0DFD               fcc       /'/
                    fcb       $0D,$00
                    fcc       /-x/
                    fcb       $0D
                    fcc       /echo c.prep:/
                    fcb       $0D,$00
                    fcc       /C.PREP /
                    fcb       $00
L0E19               fcc       /-l /
                    fcb       $00
L0E1D               fcc       / /
                    fcb       $00
L0E1F               fcc       / /
                    fcb       $00
L0E21               fcc       / >/
                    fcb       $00,$0D
                    fcc       /x/
                    fcb       $0D
                    fcc       /echo c.pass1:/
                    fcb       $0D,$00
L0E36               fcc       /C.PASS1 /
                    fcb       $00
                    fcc       /-e /
                    fcb       $00
L0E43               fcc       / -s /
                    fcb       $00
L0E48               fcc       / -p /
                    fcb       $00
L0E4D               fcc       / -o=/
                    fcb       $00,$0D
                    fcc       /del /
                    fcb       $00,$0D,$00
                    fcc       /echo c.pass2:/
                    fcb       $0D,$00
L0E69               fcc       /C.PASS2 /
                    fcb       $00
                    fcc       / -s /
                    fcb       $00
L0E77               fcc       / -p /
                    fcb       $00
L0E7C               fcc       / /
                    fcb       $00
L0E7E               fcc       / -o=/
                    fcb       $00,$0D
                    fcc       /del /
                    fcb       $00
                    fcc       / /
                    fcb       $00,$0D,$00
                    fcc       /echo c.opt:/
                    fcb       $0D,$00
                    fcc       /C.OPT /
                    fcb       $00
L0EA1               fcc       / /
                    fcb       $00
L0EA3               fcb       $0D,$00
L0EA5               fcc       /del /
                    fcb       $00,$0D,$00
                    fcc       /echo c.asm:/
                    fcb       $0D,$00
L0EB9               fcc       /C.ASM /
                    fcb       $00
L0EC0               fcc       / -o=/
                    fcb       $00,$0D,$00
                    fcc       /del /
                    fcb       $00,$0D,$00
                    fcc       /echo c.link:/
                    fcb       $0D,$00
L0EDC               fcc       /C.LINK /
                    fcb       $00
L0EE4               fcc       |/dd|
                    fcb       $00
L0EE8               fcc       |/lib/cstart.r|
                    fcb       $00
                    fcc       / /
                    fcb       $00
                    fcc       / /
                    fcb       $00
                    fcc       / -o=/
                    fcb       $00
                    fcc       / /
                    fcb       $00
                    fcc       / -l=/
                    fcb       $00
                    fcc       |/lib/clib.l |
                    fcb       $00
L0F13               fcb       $0D,$00
L0F15               fcc       /del /
                    fcb       $00,$0D,$00
                    fcc       /-t -p/
                    fcb       $0D,$00
L0F23               fcc       /r/
                    fcb       $00
                    fcc       /can't reopen '%s'/
                    fcb       $00
L0F37               fcc       /shell/
                    fcb       $00
                    fcc       /ccdevice/
                    fcb       $00
                    fcc       / /
                    fcb       $00
L0F48               pshs      u
                    leas      -$07,s
                    clra
                    clrb
                    pshs      d
                    ldd       #$000C
                    pshs      d
                    leax      >L0FA9,pcr
L0F59               pshs      x
                    lbsr      L1C31
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    beq       L0FA3
                    ldd       ,s
                    ldx       ,s
L0F6C               addd      $10,x
L0F6F               std       $05,s
                    leau      $05B9,y
                    bra       L0F7B

L0F77               ldb       $04,s
                    stb       ,u+
L0F7B               ldx       $05,s
L0F7D               leax      $01,x
                    stx       $05,s
                    ldb       -$01,x
                    stb       $04,s
                    bgt       L0F77
                    ldb       $04,s
                    clra
                    andb      #$7f
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       ,s
                    pshs      d
                    lbsr      L1C5A
                    leas      $02,s
                    leax      $05B9,y
                    tfr       x,d
                    bra       L0FA5

L0FA3               clra
                    clrb
L0FA5               leas      $07,s
                    puls      pc,u
L0FA9               fcc       /Init/              "Init" string constant
                    fcb       $00
L0FAE               pshs      u
                    leau      >$006e,y
L0FB4               ldd       $06,u
                    clra
                    andb      #$03
                    lbeq      L1025
                    leau      $0d,u
                    pshs      u
                    leax      $013e,y
                    cmpx      ,s++
                    bhi       L0FB4
                    ldd       #$00C8
                    std       $020d,y
                    lbra      L1029
                    puls      pc,u
L0FD5               pshs      u
                    ldu       $08,s
                    bne       L0FDF
                    bsr       L0FAE
                    tfr       d,u
L0FDF               stu       -$02,s
                    beq       L1029
                    ldd       $04,s
                    std       $08,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2b
                    beq       L0FF7
                    ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L0FFD
L0FF7               ldd       $06,u
                    orb       #$03
                    bra       L101B

L0FFD               ldd       $06,u
                    pshs      d
                    ldb       [$08,s]
                    cmpb      #$72
                    beq       L100F
                    ldb       [$08,s]
                    cmpb      #$64
                    bne       L1014
L100F               ldd       #$0001
                    bra       L1017

L1014               ldd       #$0002
L1017               ora       ,s+
                    orb       ,s+
L101B               std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
L1025               tfr       u,d
                    puls      pc,u
L1029               clra
                    clrb
                    puls      pc,u
L102D               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0a,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L105E

L1040               ldx       $0a,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L104D
                    ldd       #$0007
                    bra       L1055

L104D               ldd       #$0004
                    bra       L1055

L1052               ldd       #$0003
L1055               std       ,s
                    bra       L106E

L1059               leax      $04,s
                    lbra      L10C6

L105E               stx       -$02,s
                    beq       L106E
                    cmpx      #$0078
                    beq       L1040
                    cmpx      #$002B
                    beq       L1052
                    bra       L1059

L106E               ldb       [$0a,s]
                    sex
                    tfr       d,x
                    lbra      L10D3

L1077               ldd       ,s
                    orb       #$01
                    bra       L10B9

L107D               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L1AF8
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L10A8
                    ldd       #$0002
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L1BCA
                    leas      $08,s
                    bra       L10ED

L10A8               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L1B19
                    bra       L10C0

L10B5               ldd       ,s
                    orb       #$81
L10B9               pshs      d
                    pshs      u
                    lbsr      L1AF8
L10C0               leas      $04,s
                    std       $02,s
                    bra       L10ED

L10C6               leas      -$04,x
L10C8               ldd       #$00CB
                    std       $020d,y
                    clra
                    clrb
                    bra       L10EF

L10D3               cmpx      #$0072
                    lbeq      L1077
                    cmpx      #$0061
                    lbeq      L107D
                    cmpx      #$0077
                    beq       L10A8
                    cmpx      #$0064
                    beq       L10B5
                    bra       L10C8

L10ED               ldd       $02,s
L10EF               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L114F

L1104               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L102D
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L111F
                    clra
                    clrb
                    bra       L1154

L111F               clra
                    clrb
                    bra       L1147

L1123               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L1780
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L102D
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L1145
                    clra
                    clrb
                    bra       L1154

L1145               ldd       $08,s
L1147               pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
L114F               lbsr      L0FD5
                    leas      $06,s
L1154               puls      pc,u
L1156               pshs      u,d
                    ldu       $06,s
                    bra       L115E

L115C               leau      $01,u
L115E               ldb       ,u
                    sex
                    std       ,s
                    beq       L116D
                    ldd       ,s
                    cmpd      #$0058
                    bne       L115C
L116D               ldd       ,s
                    beq       L1183
                    lbsr      L1D4D
                    pshs      d
                    leax      >L1187,pcr
                    pshs      x
                    pshs      u
                    lbsr      sprintf
                    leas      $06,s
L1183               ldd       $06,s
                    puls      pc,u,x
L1187               fcc       /%d/                integer format string
                    fcb       $00
L118A               pshs      u
                    leax      >$007b,y
                    stx       $05C5,y
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
                    bra       L11AA

fprintf             pshs      u
                    ldd       $04,s
                    std       $05C5,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L11AA               pshs      d
                    leax      L1664,pcr
                    pshs      x
                    bsr       doprnt
                    leas      $06,s
                    puls      pc,u
sprintf             pshs      u
                    ldd       $04,s
                    std       $05C5,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    leax      L1677,pcr
                    pshs      x
                    bsr       doprnt
                    leas      $06,s
                    clra
                    clrb
                    stb       [>$05C5,y]
                    ldd       $04,s
                    puls      pc,u
doprnt              pshs      u
                    ldu       $06,s
                    leas      -$0b,s
                    bra       L11F4

L11E4               ldb       $08,s
                    lbeq      L1425
                    ldb       $08,s
                    sex
L11ED               pshs      d
                    jsr       [$11,s]
                    leas      $02,s
L11F4               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L11E4
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2d
                    bne       L1219
                    ldd       #$0001
                    std       $05DB,y
                    ldb       ,u+
                    stb       $08,s
                    bra       L121F

L1219               clra
                    clrb
                    std       $05DB,y
L121F               ldb       $08,s
                    cmpb      #$30
                    bne       L122A
                    ldd       #$0030
                    bra       L122D

L122A               ldd       #$0020
L122D               std       $05DD,y
                    bra       L124D

L1233               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L1A07
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L124D               ldb       $08,s
                    sex
                    leax      $013f,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L1233
                    ldb       $08,s
                    cmpb      #$2e
                    bne       L1296
                    ldd       #$0001
                    std       $04,s
                    bra       L1280

L126A               ldd       $02,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L1A07
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L1280               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      $013f,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L126A
                    bra       L129A

L1296               clra
                    clrb
                    std       $04,s
L129A               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L13C8

L12A2               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L1429
                    bra       L12CA

L12B7               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L14EA
L12CA               std       ,s
                    lbra      L13AE

L12CF               ldd       $06,s
                    pshs      d
                    ldb       $0a,s
                    sex
                    leax      $013f,y
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
                    lbsr      L1530
                    lbra      L13AA

L12F5               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    leax      $05C7,y
                    pshs      x
                    lbsr      L1471
                    lbra      L13AA

L1311               ldd       $04,s
                    bne       L131A
                    ldd       #$0006
                    std       $02,s
L131A               ldd       $06,s
                    pshs      d
                    leax      $15,s
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    ldb       $0e,s
                    sex
                    pshs      d
                    lbsr      L1975
                    leas      $06,s
                    lbra      L13AC

L1334               ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    lbra      L13BE

L1341               ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L1389
                    ldd       $09,s
                    std       $04,s
                    bra       L1363

L1357               ldb       [$09,s]
                    beq       L136F
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L1363               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L1357
L136F               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    subd      $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $15,s
                    pshs      d
                    lbsr      L159B
                    leas      $08,s
                    bra       L13B8

L1389               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    bra       L13AC

L1391               ldb       ,u+
                    stb       $08,s
                    bra       L1399
                    leas      -$0b,x
L1399               ldd       $06,s
                    pshs      d
                    leax      $15,s
                    pshs      x
                    ldb       $0C,s
                    sex
                    pshs      d
                    lbsr      L1937
L13AA               leas      $04,s
L13AC               pshs      d
L13AE               ldd       $13,s
                    pshs      d
                    lbsr      L15FD
                    leas      $06,s
L13B8               lbra      L11F4

L13BB               ldb       $08,s
                    sex
L13BE               pshs      d
                    jsr       [$11,s]
                    leas      $02,s
                    lbra      L11F4

L13C8               cmpx      #$0064
                    lbeq      L12A2
                    cmpx      #$006F
                    lbeq      L12B7
                    cmpx      #$0078
                    lbeq      L12CF
                    cmpx      #$0058
                    lbeq      L12CF
                    cmpx      #$0075
                    lbeq      L12F5
                    cmpx      #$0066
                    lbeq      L1311
                    cmpx      #$0065
                    lbeq      L1311
                    cmpx      #$0067
                    lbeq      L1311
                    cmpx      #$0045
                    lbeq      L1311
                    cmpx      #$0047
                    lbeq      L1311
                    cmpx      #$0063
                    lbeq      L1334
                    cmpx      #$0073
                    lbeq      L1341
                    cmpx      #$006C
                    lbeq      L1391
                    bra       L13BB

L1425               leas      $0b,s
                    puls      pc,u
L1429               pshs      u,d
                    leax      $05C7,y
                    stx       ,s
                    ldd       $06,s
                    bge       L145D
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L1452
                    leax      L1689,pcr
                    pshs      x
                    leax      $05C7,y
                    pshs      x
                    lbsr      L1991
                    leas      $04,s
                    puls      pc,u,x
L1452               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L145D               ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    bsr       L1471
                    leas      $04,s
                    leax      $05C7,y
                    tfr       x,d
                    puls      pc,u,x
L1471               pshs      u,y,x,d
                    ldu       $0a,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    bra       L148E

L147F               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      >$0061,y
                    std       $0C,s
L148E               ldd       $0C,s
                    blt       L147F
                    leax      >$0061,y
                    stx       $04,s
                    bra       L14D0

L149A               ldd       ,s
                    addd      #$0001
                    std       ,s
L14A1               ldd       $0C,s
                    subd      [$04,s]
                    std       $0C,s
                    bge       L149A
                    ldd       $0C,s
                    addd      [$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L14BA
                    ldd       #$0001
                    std       $02,s
L14BA               ldd       $02,s
                    beq       L14C5
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L14C5               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L14D0               ldd       $04,s
                    cmpd      >$0069,y
                    bne       L14A1
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0a,s
                    leas      $06,s
                    puls      pc,u
L14EA               pshs      u,d
                    leax      $05C7,y
                    stx       ,s
                    leau      $05D1,y
L14F6               ldd       $06,s
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
                    bne       L14F6
                    bra       L1518

L150E               ldb       ,u
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L1518               leau      -$01,u
                    pshs      u
                    leax      $05D1,y
                    cmpx      ,s++
                    bls       L150E
                    clra
                    clrb
                    stb       [,s]
                    leax      $05C7,y
                    tfr       x,d
                    puls      pc,u,x
L1530               pshs      u,x,d
                    leax      $05C7,y
                    stx       $02,s
                    leau      $05D1,y
L153C               ldd       $08,s
                    clra
                    andb      #$0f
                    std       ,s
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L155E
                    ldd       $0C,s
                    beq       L1556
                    ldd       #$0041
                    bra       L1559

L1556               ldd       #$0061
L1559               addd      #$FFF6
                    bra       L1561

L155E               ldd       #$0030
L1561               addd      ,s++
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
                    bne       L153C
                    bra       L1581

L1577               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L1581               leau      -$01,u
                    pshs      u
                    leax      $05D1,y
                    cmpx      ,s++
                    bls       L1577
                    clra
                    clrb
                    stb       [$02,s]
                    leax      $05C7,y
                    tfr       x,d
                    lbra      L1673

L159B               pshs      u
                    ldu       $06,s
                    ldd       $0a,s
                    subd      $08,s
                    std       $0a,s
                    ldd       $05DB,y
                    bne       L15D0
                    bra       L15B8

L15AD               ldd       $05DD,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L15B8               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L15AD
                    bra       L15D0

L15C6               ldb       ,u+
                    sex
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L15D0               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L15C6
                    ldd       $05DB,y
                    beq       L15FB
                    bra       L15EF

L15E4               ldd       $05DD,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L15EF               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L15E4
L15FB               puls      pc,u
L15FD               pshs      u
                    ldu       $06,s
                    ldd       $08,s
                    pshs      d
                    pshs      u
                    lbsr      L1980
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       $08,s
                    ldd       $05DB,y
                    bne       L163F
                    bra       L1627

L161C               ldd       $05DD,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L1627               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L161C
                    bra       L163F

L1635               ldb       ,u+
                    sex
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L163F               ldb       ,u
                    bne       L1635
                    ldd       $05DB,y
                    beq       L1662
                    bra       L1656

L164B               ldd       $05DD,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L1656               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L164B
L1662               puls      pc,u
L1664               pshs      u
                    ldd       $05C5,y
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      fputc
L1673               leas      $04,s
                    puls      pc,u
L1677               pshs      u
                    ldd       $04,s
                    ldx       $05C5,y
                    leax      $01,x
                    stx       $05C5,y
                    stb       -$01,x
                    puls      pc,u
L1689               fcc       /-32768/            INT_MIN literal, special-cased by itoa
                    fcb       $00
fputc               pshs      u         stream putc: write char to FILE at work+$5c5
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L16B4
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      L17CA
                    pshs      u
                    lbsr      L18A7
                    leas      $02,s
L16B4               ldd       $06,u
                    clra
                    andb      #$04
                    beq       L16F0
                    ldd       #$0001
L16BE               pshs      d
                    leax      $07,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L16D5
                    leax      L1BBA,pcr
                    bra       L16D9

L16D5               leax      L1BA1,pcr
L16D9               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L1731
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      L17CA

L16F0               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L1700
                    pshs      u
                    lbsr      L17E5
                    leas      $02,s
L1700               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L1726
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L1731
                    ldd       $04,s
                    cmpd      #$000D
                    bne       L1731
L1726               pshs      u
                    lbsr      L17E5
                    std       ,s++
                    lbne      L17CA
L1731               ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      L1A66
                    pshs      d
                    lbsr      fputc
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      fputc
                    lbra      L189F

L1758               pshs      u,d
                    leau      >$006e,y
                    clra
                    clrb
                    std       ,s
                    bra       L176E

L1764               tfr       u,d
                    leau      $0d,u
                    pshs      d
                    bsr       L1780
                    leas      $02,s
L176E               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L1764
                    puls      pc,u,x
L1780               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L1790
                    ldd       $06,u
                    bne       L1795
L1790               ldd       #$FFFF
                    puls      pc,u,x
L1795               ldd       $06,u
                    clra
                    andb      #$02
                    beq       L17A4
                    pshs      u
                    bsr       L17B9
                    leas      $02,s
                    bra       L17A6

L17A4               clra
                    clrb
L17A6               std       ,s
                    ldd       $08,u
                    pshs      d
                    lbsr      L1B07
                    leas      $02,s
                    clra
                    clrb
                    std       $06,u
                    ldd       ,s
                    puls      pc,u,x
L17B9               pshs      u
                    ldu       $04,s
                    beq       L17CA
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L17CF
L17CA               ldd       #$FFFF
                    puls      pc,u
L17CF               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L17DF
                    pshs      u
                    lbsr      L18A7
                    leas      $02,s
L17DF               pshs      u
                    bsr       L17E5
                    puls      pc,u,x
L17E5               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L1817
                    ldd       ,u
                    cmpd      $04,u
                    beq       L1817
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L18A3
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L1BCA
                    leas      $08,s
L1817               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      L188F
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L188F
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L1866
                    ldd       $02,u
                    bra       L185E

L1837               ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L1BBA
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L1854
                    leax      $04,s
                    bra       L187E

L1854               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L185E               std       ,u
                    ldd       $02,s
                    bne       L1837
                    bra       L188F

L1866               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L1BA1
                    leas      $06,s
                    cmpd      $02,s
                    beq       L188F
                    bra       L1880

L187E               leas      -$04,x
L1880               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L189F

L188F               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
L189F               leas      $04,s
                    puls      pc,u
L18A3               pshs      u
                    puls      pc,u
L18A7               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       L18DF
                    leas      -$20,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L1A89
                    leas      $06,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       L18D3
                    ldd       #$0040
                    bra       L18D6

L18D3               ldd       #$0080
L18D6               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $20,s
L18DF               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       L18EC
                    puls      pc,u
L18EC               ldd       $0b,u
                    bne       L1901
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L18FC
                    ldd       #$0080
                    bra       L18FF

L18FC               ldd       #$0100
L18FF               std       $0b,u
L1901               ldd       $02,u
                    bne       L1916
                    ldd       $0b,u
                    pshs      d
                    lbsr      L1CBD
                    leas      $02,s
                    std       $02,u
                    cmpd      #$FFFF
                    beq       L191E
L1916               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       L192D

L191E               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
L192D               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    puls      pc,u
L1937               pshs      u
                    ldb       $05,s
                    sex
                    tfr       d,x
                    bra       L195D

L1940               ldd       [$06,s]
                    addd      #$0004
                    std       [$06,s]
                    leax      >L1974,pcr
                    bra       L1959

L194F               ldb       $05,s
                    stb       >$006C,y
                    leax      >$006b,y
L1959               tfr       x,d
                    puls      pc,u
L195D               cmpx      #$0064
                    beq       L1940
                    cmpx      #$006F
                    lbeq      L1940
                    cmpx      #$0078
                    lbeq      L1940
                    bra       L194F
                    puls      pc,u
L1974               fcb       $00       empty string
L1975               pshs      u
                    leax      >L197F,pcr
                    tfr       x,d
                    puls      pc,u
L197F               fcb       $00       empty string
L1980               pshs      u
                    ldu       $04,s
L1984               ldb       ,u+
                    bne       L1984
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u
L1991               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L199B               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L199B
                    ldd       $06,s
                    puls      pc,u,x
L19AB               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L19B5               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L19B5
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L19C6               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L19C6
                    ldd       $06,s
                    puls      pc,u,x
                    pshs      u
                    ldu       $04,s
                    bra       L19EC

L19DC               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L19EA
                    clra
                    clrb
                    puls      pc,u
L19EA               leau      $01,u
L19EC               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L19DC
                    ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u
L1A07               tsta
                    bne       L1A1C
                    tst       $02,s
                    bne       L1A1C
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
L1A1C               pshs      d
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
                    bcc       L1A39
                    inc       ,s
L1A39               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1A46
                    inc       ,s
L1A46               lda       $04,s
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
                    beq       L1A70
L1A5D               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L1A5D
                    bra       L1A70

L1A66               tstb
                    beq       L1A70
L1A69               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L1A69
L1A70               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts
                    tstb
                    beq       L1A70
L1A80               asl       $03,s
                    rol       $02,s
                    decb
                    bne       L1A80
                    bra       L1A70

L1A89               lda       $05,s
                    ldb       $03,s
                    beq       L1ABC
                    cmpb      #$01
                    beq       L1ABE
                    cmpb      #$06
                    beq       L1ABE
                    cmpb      #$02
                    beq       L1AA4
                    cmpb      #$05
                    beq       L1AA4
                    ldb       #$D0
                    lbra      L1D92

L1AA4               pshs      u
                    os9       I$GetStt
                    bcc       L1AB0
                    puls      u
                    lbra      L1D92

L1AB0               stx       [$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

L1ABC               ldx       $06,s
L1ABE               os9       I$GetStt
                    lbra      L1D9B
                    lda       $05,s
                    ldb       $03,s
                    beq       L1AD3
                    cmpb      #$02
                    beq       L1ADB
                    ldb       #$D0
                    lbra      L1D92

L1AD3               ldx       $06,s
                    os9       I$SetStt
                    lbra      L1D9B

L1ADB               pshs      u
                    ldx       $08,s
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u
                    lbra      L1D9B
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       L1AF5
                    os9       I$Close
L1AF5               lbra      L1D9B

L1AF8               ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      L1D92
                    tfr       a,b
                    clra
                    rts

L1B07               lda       $03,s
                    os9       I$Close
                    lbra      L1D9B
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      L1D9B

L1B19               ldx       $02,s
                    lda       $05,s
                    ldb       #$0b
                    os9       I$Create
                    bcs       L1B28
L1B24               tfr       a,b
                    clra
                    rts

L1B28               cmpb      #$DA
                    lbne      L1D92
                    lda       $05,s
                    bita      #$80
                    lbne      L1D92
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      L1D92
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L1B24
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      L1D92
                    ldx       $02,s
                    os9       I$Delete
                    lbra      L1D9B
                    lda       $03,s
                    os9       I$Dup
                    lbcs      L1D92
                    tfr       a,b
                    clra
                    rts
                    pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
L1B7E               bcc       L1B8D
                    cmpb      #$D3
                    bne       L1B88
                    clra
                    clrb
                    puls      pc,y,x
L1B88               puls      y,x
                    lbra      L1D92

L1B8D               tfr       y,d
                    puls      pc,y,x
                    pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
                    bra       L1B7E

L1BA1               pshs      y
                    ldy       $08,s
                    beq       L1BB6
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
L1BAF               bcc       L1BB6
                    puls      y
                    lbra      L1D92

L1BB6               tfr       y,d
                    puls      pc,y
L1BBA               pshs      y
                    ldy       $08,s
                    beq       L1BB6
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
                    bra       L1BAF

L1BCA               pshs      u
                    ldd       $0a,s
                    bne       L1BD8
                    ldu       #$0000
                    ldx       #$0000
                    bra       L1C0C

L1BD8               cmpd      #$0001
                    beq       L1C03
                    cmpd      #$0002
                    beq       L1BF8
                    ldb       #$F7
L1BE6               clra
                    std       $020d,y
                    ldd       #$FFFF
                    leax      $0201,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
L1BF8               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L1BE6
                    bra       L1C0C

L1C03               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L1BE6
L1C0C               tfr       u,d
                    addd      $08,s
                    std       $0203,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L1BE6
                    tfr       d,x
                    std       $0201,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       L1BE6
                    leax      $0201,y
                    puls      pc,u
L1C31               pshs      u,y
                    ldx       $06,s
                    lda       $09,s
                    asla
                    asla
                    asla
                    asla
                    ora       $0b,s
                    os9       F$Link
L1C40               tfr       u,d
                    puls      u,y
                    lbcs      L1D92
                    rts
                    pshs      u,y
                    ldx       $06,s
                    lda       $09,s
                    asla
                    asla
                    asla
                    asla
                    ora       $0b,s
                    os9       F$Load
                    bra       L1C40

L1C5A               pshs      u
                    ldu       $04,s
                    os9       F$UnLink
                    puls      u
                    lbra      L1D9B
                    ldd       $01FF,y
                    pshs      d
                    ldd       $04,s
                    cmpd      $05DF,y
                    bcs       L1C9A
                    addd      $01FF,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       L1C8C
                    ldd       #$FFFF
                    leas      $02,s
                    rts

L1C8C               std       $01FF,y
                    addd      $05DF,y
                    subd      ,s
                    std       $05DF,y
L1C9A               leas      $02,s
                    ldd       $05DF,y
                    pshs      d
                    subd      $04,s
                    std       $05DF,y
                    ldd       $01FF,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
L1CB3               sta       ,x+
                    cmpx      $01FF,y
                    bcs       L1CB3
                    puls      pc,d
L1CBD               ldd       $02,s
                    addd      $0209,y
                    bcs       L1CE6
                    cmpd      $020b,y
                    bcc       L1CE6
                    pshs      d
                    ldx       $0209,y
                    clra
L1CD3               cmpx      ,s
                    bcc       L1CDB
                    sta       ,x+
                    bra       L1CD3

L1CDB               ldd       $0209,y
                    puls      x
                    stx       $0209,y
                    rts

L1CE6               ldd       #$FFFF
                    rts
                    lda       $03,s
                    ldb       $05,s
                    os9       F$Send
                    lbra      L1D9B
                    clra
                    clrb
                    os9       F$Wait
                    lbcs      L1D92
                    ldx       $02,s
                    beq       L1D05
                    stb       $01,x
                    clr       ,x
L1D05               tfr       a,b
                    clra
                    rts
                    lda       $03,s
                    ldb       $05,s
                    os9       F$SPrior
                    lbra      L1D9B

L1D13               leau      ,s
                    leas      $00FF,y
                    ldx       $02,u
                    ldy       $04,u
                    lda       $09,u
                    asla
                    asla
                    asla
                    asla
                    ora       $0b,u
                    ldb       $0d,u
                    ldu       $06,u
                    os9       F$Chain
                    os9       F$Exit
                    pshs      u,y
                    ldx       $06,s
                    ldy       $08,s
                    ldu       $0a,s
                    lda       $0d,s
                    ora       $0f,s
                    ldb       $11,s
                    os9       F$Fork
                    puls      u,y
                    lbcs      L1D92
                    tfr       a,b
                    clra
                    rts

L1D4D               pshs      y
                    os9       F$ID
                    puls      y
                    bcc       L1D5A
                    lbcs      L1D92
L1D5A               tfr       a,b
                    clra
                    rts

L1D5E               pshs      y
                    os9       F$ID
                    bcc       L1D6A
L1D65               puls      y
                    lbra      L1D92

L1D6A               tfr       y,d
                    puls      pc,y
                    pshs      y
                    bsr       L1D5E
                    std       -$02,s
                    beq       L1D7A
                    ldb       #$D6
                    bra       L1D65

L1D7A               ldy       $04,s
                    os9       F$SUser
                    bcc       L1D8E
                    cmpb      #$D0
                    bne       L1D65
                    tfr       y,d
                    ldy       >L004B
                    std       $09,y
L1D8E               clra
                    clrb
                    puls      pc,y
L1D92               clra
                    std       $020d,y
                    ldd       #$FFFF
                    rts

L1D9B               bcs       L1D92
                    clra
                    clrb
                    rts

exit                lbsr      L1DAB
                    lbsr      L1758
_exit               ldd       $02,s
                    os9       F$Exit
L1DAB               rts

* ------------------------------------------------------------------
* L1DAC - initialisation image for the cc1 work block, walked once by
* the _start routine: count1 word + count1 bytes copied to base, then
* count2 word + count2 bytes copied to base+$2d, then two relocation
* directories that fix up embedded pointers (see _start at $001A).
* ------------------------------------------------------------------
L1DAC               fdb       $0001     count1 - bytes copied to base
                    fcb       $00       block1 image (-> base+$00)
                    fdb       $0192     count2 - bytes copied to base+$2d

* block2 - work block template ($192 bytes) copied to base+$2d
                    fcc       /ctmp.XXXXXX/       base+$2d temporary file name template
                    zmb       9         pad
                    fcc       /c.com/             base+$41 compiler command name
                    zmb       25        pad
                    fdb       L0CCF     base+$5f reloc ptr (+module base) -> banner
                    fdb       $2710,$03E8,$0064,$000A base+$61 powers of ten 10000,1000,100,10
                    fdb       $0069     base+$69 relocatable pointer, +work base
                    fcb       $6C,$78,$00 base+$6b
                    zmb       7         work block default fields
                    fcb       $01
                    zmb       12
                    fcb       $02,$00,$01
                    zmb       10
                    fcb       $42,$00,$02
                    zmb       173
                    fcb       $01,$01,$01,$01,$01,$01,$01,$01 character classification table
                    fcb       $01,$11,$11,$01,$11,$11,$01,$01
                    fcb       $01,$01,$01,$01,$01,$01,$01,$01
                    fcb       $01,$01,$01,$01,$01,$01,$01,$01
                    fcb       $30,$20,$20,$20,$20,$20,$20,$20
                    fcb       $20,$20,$20,$20,$20,$20,$20,$20
                    fcb       $48,$48,$48,$48,$48,$48,$48,$48
                    fcb       $48,$48,$20,$20,$20,$20,$20,$20
                    fcb       $20,$42,$42,$42,$42,$42,$42,$02
                    fcb       $02,$02,$02,$02,$02,$02,$02,$02
                    fcb       $02,$02,$02,$02,$02,$02,$02,$02
                    fcb       $02,$02,$02,$20,$20,$20,$20,$20
                    fcb       $20,$44,$44,$44,$44,$44,$44,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$20,$20,$20,$20,$01

* relocation directory
                    fdb       $0001     nreloc1
                    fdb       $005F     relocate word at work+$5f by module base
                    fdb       $0001     nreloc2
                    fdb       $0069     relocate word at work+$69 by work base

* trailing module name string
                    fcc       /cc1/
                    fcb       $00

                    emod
eom                 equ       *
                    end
