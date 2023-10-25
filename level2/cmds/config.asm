********************************************************************
* config - Config utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          ????/??/??  ???
* Original Tandy distribution version.

                    nam       config
                    ttl       Config utility

* Disassembled 02/07/06 13:07:34 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       1
u0005               rmb       1
u0006               rmb       1
u0007               rmb       1
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       2
u000D               rmb       2
u000F               rmb       2
u0011               rmb       2
u0013               rmb       2
u0015               rmb       2
u0017               rmb       2
u0019               rmb       2
u001B               rmb       2
u001D               rmb       2
u001F               rmb       1
u0020               rmb       1
u0021               rmb       1
u0022               rmb       1
u0023               rmb       2
u0025               rmb       2
u0027               rmb       2
u0029               rmb       2
u002B               rmb       2
u002D               rmb       1
u002E               rmb       1
u002F               rmb       2
u0031               rmb       1
u0032               rmb       1
u0033               rmb       1
u0034               rmb       1
u0035               rmb       1
u0036               rmb       1
u0037               rmb       10
u0041               rmb       1
u0042               rmb       1
u0043               rmb       1
u0044               rmb       3
u0047               rmb       1
u0048               rmb       5
u004D               rmb       2
u004F               rmb       1
u0050               rmb       3
u0053               rmb       1
u0054               rmb       1
u0055               rmb       1
u0056               rmb       1
u0057               rmb       4
u005B               rmb       8
u0063               rmb       1
u0064               rmb       8
u006C               rmb       3
u006F               rmb       3
u0072               rmb       2
u0074               rmb       2
u0076               rmb       2
u0078               rmb       1
u0079               rmb       2
u007B               rmb       2
u007D               rmb       107
u00E8               rmb       21
u00FD               rmb       688
u03AD               rmb       3154
size                equ       .
name                equ       *
                    fcs       /config/
                    fcb       $04
L0014               fcb       $A6                 &
                    fcb       $A0
                    fcb       $A7                 '
                    fcb       $C0                 @
                    fcb       $30                 0
                    fcb       $1F
                    fcb       $26                 &
                    fcb       $F8                 x
                    fcb       $39                 9
start               equ       *
                    pshs      y
                    pshs      u
                    clra
                    clrb
L0023               sta       ,u+
                    decb
                    bne       L0023
                    ldx       ,s
                    leau      ,x
                    leax      >$0C7F,x
                    pshs      x
                    leay      >L2E15,pcr
                    ldx       ,y++
                    beq       L003E
                    bsr       L0014
                    ldu       $02,s
L003E               leau      >u007D,u
                    ldx       ,y++
                    beq       L0049
                    bsr       L0014
                    clra
L0049               cmpu      ,s
                    beq       L0052
                    sta       ,u+
                    bra       L0049
L0052               ldu       $02,s
                    ldd       ,y++
                    beq       L005F
                    leax      >L0000,pcr
                    lbsr      L0151
L005F               ldd       ,y++
                    beq       L0068
                    leax      ,u
                    lbsr      L0151
L0068               leas      $04,s
                    puls      x
                    stx       >u03AD,u
                    pshs      y
                    ldy       #$0001
                    leax      $02,s
L0078               lda       ,x+
                    cmpa      #$0D
                    beq       L00BC
                    cmpa      #$20
                    beq       L0078
                    cmpa      #$2C
                    beq       L0078
                    cmpa      #$22
                    beq       L00A6
                    cmpa      #$27
                    beq       L00A6
                    leax      -$01,x
                    pshs      x
                    leay      $01,y
L0094               lda       ,x+
                    beq       L00B6
                    cmpa      #$0D
                    beq       L00B6
                    cmpa      #$20
                    beq       L00B6
                    cmpa      #$2C
                    beq       L00B6
                    bra       L0094
L00A6               pshs      x,a
                    leay      $01,y
L00AA               lda       ,x+
                    cmpa      #$0D
                    beq       L00B4
                    cmpa      ,s
                    bne       L00AA
L00B4               puls      b
L00B6               clr       -$01,x
                    cmpa      #$0D
                    bne       L0078
L00BC               tfr       y,d
                    leax      ,s
                    pshs      x,b,a
                    lslb
                    rola
                    leay      d,x
                    pshs      u
                    bra       L00D2
L00CA               ldd       ,x
                    ldu       ,y
                    std       ,y
                    stu       ,x++
L00D2               leay      -$02,y
                    pshs      y
                    cmpx      ,s++
                    bcs       L00CA
                    puls      y
                    bsr       L00E8
                    puls      b,a
                    lbsr      L018E
                    clra
                    clrb
                    lbsr      L2CDA
L00E8               leax      >$0C7F,y
                    stx       >$03B7,y
                    sts       >$03AB,y
                    sts       >$03B9,y
                    ldd       #$FF82
L00FD               leax      d,s
                    cmpx      >$03B9,y
                    bcc       L010F
                    cmpx      >$03B7,y
                    bcs       L0129
                    stx       >$03B9,y
L010F               rts
L0110               bpl       L013C
                    bpl       L013E
                    bra       L0169
                    lsrb
                    fcb       $41                 A
                    coma
                    fcb       $4B                 K
                    bra       L016B
                    rorb
                    fcb       $45                 E
                    fcb       $52                 R
                    rora
                    inca
                    clra
                    asrb
                    bra       L014F
                    bpl       L0151
                    bpl       L0136
L0129               leax      <L0110,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
L0136               os9       I$WritLn
                    clra
                    puls      b
L013C               lbsr      L2CE4
                    ldd       >$03AB,y
                    subd      >$03B9,y
                    rts
                    ldd       >$03B9,y
                    subd      >$03B7,y
                    rts
L0151               pshs      x
                    leax      d,y
                    leax      d,x
                    pshs      x
L0159               ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      $02,s
                    std       ,x
                    cmpy      ,s
                    bne       L0159
                    leas      $04,s
                    rts
L016B               pshs      u,b,a
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       ,s
                    cmpd      #$0002
                    lbne      L03B9
                    lbsr      L11B1
                    lbsr      L0269
                    lbsr      L19D4
                    ldd       ,s
                    lbsr      L2CDA
                    lbra      L03B9
L018E               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    bsr       L01CC
                    leax      >$007D,y
                    tfr       x,d
                    lbsr      L2B41
                    lbsr      L0984
                    lbsr      L08AA
                    lbsr      L0409
                    lbsr      L04B0
                    lbsr      L17BD
                    lbsr      L1AA1
                    leax      >$00A2,y
                    tfr       x,d
                    lbsr      L2B41
                    lbsr      L1BD9
                    lbsr      L11B1
                    lbsr      L0269
                    clra
                    clrb
                    lbsr      L2CDA
                    puls      pc,u
L01CC               pshs      u
                    ldd       #$FFB4
                    lbsr      L00FD
                    leas      -$04,s
                    leax      >$03DF,y
                    stx       $02,s
                    leax      >$03BD,y
                    pshs      x
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L2C6E
                    leas      $04,s
                    ldd       $02,s
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L2C6E
                    leas      $04,s
                    clra
                    clrb
                    ldx       $02,s
                    stb       $05,x
                    stb       $04,x
                    pshs      x,b,a
                    lbsr      L2CA8
                    leas      $04,s
                    leax      >L016B,pcr
                    tfr       x,d
                    lbsr      L2C46
                    bsr       L0255
                    std       ,s
                    ldx       ,s
                    bra       L022D
L0218               ldd       #$0018
                    std       <u002F
                    ldd       #$0012
                    bra       L0229
L0222               clra
                    clrb
                    std       <u002F
                    ldd       #$000A
L0229               std       <u0031
                    bra       L023A
L022D               cmpx      #$0050
                    beq       L0218
                    cmpx      #$0020
                    beq       L0222
                    lbra      L0222
L023A               lbsr      L11B1
                    clra
                    clrb
                    lbsr      L118F
                    lbsr      L0E40
                    bsr       L027C
                    lbsr      L11B1
                    ldd       #$0005
                    std       <u0027
                    lbsr      L0EBF
                    lbra      L0398
L0255               pshs      y
                    lda       #$01
                    ldb       #$26
                    os9       I$GetStt
                    bcc       L0265
                    ldd       #$0020
                    bra       L0267
L0265               tfr       x,d
L0267               puls      pc,y
L0269               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    lbsr      L0375
                    ldd       #$0001
                    lbsr      L118F
                    puls      pc,u
L027C               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L109A
L0287               lbsr      L1437
                    sex
                    tfr       d,x
                    bra       L029F
L028F               ldd       #$0001
                    bra       L0296
L0294               clra
                    clrb
L0296               std       <u002D
                    bra       L02AB
L029A               lbsr      L121F
                    bra       L0287
L029F               cmpx      #$0031
                    beq       L028F
                    cmpx      #$0032
                    beq       L0294
                    bra       L029A
L02AB               lbsr      L0375
                    ldd       #$000D
                    pshs      b,a
                    clra
                    clrb
                    lbsr      L1139
                    leas      $02,s
                    ldd       <u002D
                    beq       L0303
                    leax      >L03BD,pcr
                    tfr       x,d
                    lbsr      L140D
                    ldd       #$000C
                    pshs      b,a
                    leax      >$0401,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2A9B
                    leas      $04,s
                    leax      >$0401,y
                    tfr       x,d
                    lbsr      L2889
                    addd      #$FFFF
                    leax      >$0401,y
                    leax      d,x
                    clra
                    clrb
                    stb       ,x
                    leax      >$0401,y
                    pshs      x
                    leax      >$040D,y
                    tfr       x,d
                    lbsr      L1FE5
                    leas      $02,s
                    lbra      L0371
L0303               leax      >L03D2,pcr
                    tfr       x,d
                    lbsr      L140D
                    ldd       #$000C
                    pshs      b,a
                    leax      >$0401,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2A9B
                    leas      $04,s
                    ldd       #$000E
                    pshs      b,a
                    clra
                    clrb
                    lbsr      L1139
                    leas      $02,s
                    leax      >L03EE,pcr
                    tfr       x,d
                    lbsr      L140D
                    ldd       #$000C
                    pshs      b,a
                    leax      >$040D,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2A9B
                    leas      $04,s
                    leax      >$0401,y
                    tfr       x,d
                    lbsr      L2889
                    addd      #$FFFF
                    leax      >$0401,y
                    leax      d,x
                    clra
                    clrb
                    stb       ,x
                    leax      >$040D,y
                    tfr       x,d
                    lbsr      L2889
                    addd      #$FFFF
                    leax      >$040D,y
                    leax      d,x
                    clra
                    clrb
                    stb       ,x
L0371               bsr       L0383
                    puls      pc,u
L0375               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leax      >$03BD,y
                    bra       L038F
L0383               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leax      >$03DF,y
L038F               pshs      x
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L2CA8
L0398               leas      $04,s
                    puls      pc,u
L039C               pshs      u,b,a
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldx       ,s
                    ldb       $01,x
                    sex
                    lbsr      L277D
                    cmpd      #$0048
                    bne       L03B7
                    ldd       #$0001
                    bra       L03B9
L03B7               clra
                    clrb
L03B9               leas      $02,s
                    puls      pc,u
L03BD               fcb       $45                 E
                    fcb       $4E                 N
                    lsrb
                    fcb       $45                 E
                    fcb       $52                 R
                    bra       L0412
                    fcb       $41                 A
                    tsta
                    fcb       $45                 E
                    bra       L0418
                    rora
                    bra       L0410
                    rola
                    comb
                    fcb       $4B                 K
                    abx
                    bra       L03D2
L03D2               fcb       $45                 E
                    fcb       $4E                 N
                    lsrb
                    fcb       $45                 E
                    fcb       $52                 R
                    bra       L0427
                    fcb       $41                 A
                    tsta
                    fcb       $45                 E
                    bra       L042D
                    rora
                    bra       L0434
                    clra
                    fcb       $55                 U
                    fcb       $52                 R
                    coma
                    fcb       $45                 E
                    bra       L042C
                    rola
                    comb
                    fcb       $4B                 K
                    abx
                    bra       L03EE
L03EE               fcb       $45                 E
                    fcb       $4E                 N
                    lsrb
                    fcb       $45                 E
                    fcb       $52                 R
                    bra       L0443
                    fcb       $41                 A
                    tsta
                    fcb       $45                 E
                    bra       L0449
                    rora
                    bra       L0441
                    fcb       $45                 E
                    comb
                    lsrb
                    bgt       L0422
                    lsra
                    rola
                    comb
                    fcb       $4B                 K
                    abx
                    bra       L0409
L0409               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    lbsr      L11B1
                    lbsr      L0E92
                    clra
L0418               clrb
                    std       <u0074
                    bra       L0444
L041D               lbsr      L1437
                    sex
                    tfr       d,x
                    bra       L0450
L0425               lbsr      L0781
                    bra       L041D
L042A               lbsr      L083A
L042D               lbra      L041D
L0430               lbsr      L07F8
                    lbra      L041D
L0436               lbsr      L0817
                    lbra      L041D
L043C               ldd       #$FFFF
                    bra       L0444
L0441               ldd       #$0001
L0444               lbsr      L066D
                    lbra      L041D
L044A               lbsr      L121F
                    lbra      L041D
L0450               cmpx      #$000D
                    beq       L0425
                    cmpx      #$0073
                    lbeq      L0425
                    cmpx      #$0053
                    lbeq      L0425
                    cmpx      #$0068
                    beq       L042A
                    cmpx      #$0048
                    lbeq      L042A
                    cmpx      #$000C
                    beq       L0430
                    cmpx      #$000A
                    beq       L0436
                    cmpx      #$0064
                    beq       L048F
                    cmpx      #$0044
                    beq       L048F
                    cmpx      #$0008
                    beq       L043C
                    cmpx      #$0009
                    beq       L0441
                    bra       L044A
L048F               lbsr      L11E8
                    ldd       <u0074
                    addd      <u0031
                    cmpd      <u001D
                    bge       L049E
                    lbsr      L05FE
L049E               lbsr      L061D
                    std       -$02,s
                    bne       L04AE
                    lbsr      L11E8
                    lbsr      L0E92
                    lbra      L041D
L04AE               puls      pc,u
L04B0               pshs      u
                    ldd       #$FFB4
                    lbsr      L00FD
                    leas      -$04,s
L04BA               lbsr      L1065
                    lbsr      L1437
                    sex
                    tfr       d,x
                    bra       L051C
L04C5               ldd       #$0001
                    std       <u0033
                    leax      >L0915,pcr
                    stx       ,s
                    tfr       x,d
                    lbsr      L05CC
                    std       -$02,s
                    bne       L0534
                    leax      >L0919,pcr
                    bra       L0503
L04DF               clra
                    clrb
                    std       <u0033
                    leax      >L092A,pcr
                    stx       ,s
                    tfr       x,d
                    lbsr      L05CC
                    std       -$02,s
                    bne       L0534
                    leax      >L092E,pcr
                    tfr       x,d
                    lbsr      L05CC
                    std       -$02,s
                    bne       L0534
                    leax      >L0932,pcr
L0503               tfr       x,d
                    lbsr      L1473
                    bra       L04BA
L050A               leax      >L094F,pcr
                    tfr       x,d
                    lbsr      L1CFB
                    lbra      L04BA
L0516               lbsr      L121F
                    lbra      L04BA
L051C               cmpx      #$0031
                    beq       L04C5
                    cmpx      #$0032
                    beq       L04DF
                    cmpx      #$0068
                    beq       L050A
                    cmpx      #$0048
                    lbeq      L050A
                    bra       L0516
L0534               leax      >L0957,pcr
                    pshs      x
                    ldd       <u0015
                    lbsr      L08BE
                    leas      $02,s
                    leax      >L0959,pcr
                    pshs      x
                    ldd       <u0015
                    lbsr      L08BE
                    leas      $02,s
                    ldd       <u001D
                    std       $02,s
                    ldd       <u0021
                    std       <u001D
                    ldd       #$0001
                    std       <u0025
                    lbsr      L0409
                    ldd       $02,s
                    std       <u001D
                    clra
                    clrb
                    std       <u0025
                    ldu       <u0017
                    bra       L058F
L056A               ldd       ,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L0D34
                    std       ,s++
                    beq       L058C
                    ldd       #$0001
                    std       ,u
                    pshs      b,a
                    tfr       u,d
                    lbsr      L07C8
                    leas      $02,s
                    bra       L0593
L058C               ldu       <u0023,u
L058F               stu       -$02,s
                    bne       L056A
L0593               ldd       <u0033
                    beq       L05C3
                    lbsr      L08F5
                    std       -$02,s
                    beq       L05C3
                    leax      >L095C,pcr
                    tfr       x,d
                    bsr       L05CC
                    std       -$02,s
                    bne       L05BF
                    leax      >L0960,pcr
                    tfr       x,d
                    bsr       L05CC
                    std       -$02,s
                    bne       L05BF
                    leax      >L0964,pcr
                    tfr       x,d
                    lbsr      L1473
L05BF               clra
                    clrb
                    std       <u0033
L05C3               lbsr      L11B1
                    lbsr      L0EDE
                    lbra      L076C
L05CC               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    ldu       <u000F
                    bra       L05F5
L05D8               ldd       ,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L0D34
                    std       ,s++
                    beq       L05F2
                    ldd       #$0001
                    std       ,u
                    lbra      L08E8
L05F2               ldu       <u0023,u
L05F5               stu       -$02,s
                    bne       L05D8
                    clra
                    clrb
                    lbra      L08E8
L05FE               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    clra
                    clrb
                    pshs      b,a
                    ldd       #$0006
                    lbsr      L1139
                    leas      $02,s
                    leax      >$00A5,y
                    tfr       x,d
                    lbsr      L140D
                    puls      pc,u
L061D               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       #$0001
                    pshs      b,a
                    ldd       #$0006
                    lbsr      L1139
                    leas      $02,s
                    leax      >$00BA,y
                    tfr       x,d
                    lbsr      L140D
L063B               lbsr      L1437
                    sex
                    tfr       d,x
                    bra       L0651
L0643               ldd       #$0001
                    puls      pc,u
L0648               clra
                    clrb
                    puls      pc,u
L064C               lbsr      L121F
                    bra       L063B
L0651               cmpx      #$0059
                    beq       L0643
                    cmpx      #$0079
                    lbeq      L0643
                    cmpx      #$004E
                    beq       L0648
                    cmpx      #$006E
                    lbeq      L0648
                    bra       L064C
                    puls      pc,u
L066D               pshs      u,b,a
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    ldd       $02,s
                    cmpd      #$FFFF
                    bne       L0689
                    ldd       <u0074
                    beq       L0698
                    ldd       <u0074
                    subd      <u0031
                    bra       L06A2
L0689               cmpd      #$0001
                    bne       L06A4
                    ldd       <u0074
                    addd      <u0031
                    cmpd      <u001D
                    blt       L069E
L0698               lbsr      L121F
                    lbra      L076C
L069E               ldd       <u0074
                    addd      <u0031
L06A2               std       <u0074
L06A4               ldd       <u0029
                    beq       L06AC
                    ldu       <u001B
                    bra       L06B6
L06AC               ldd       <u0025
                    beq       L06B4
                    ldu       <u0015
                    bra       L06B6
L06B4               ldu       <u000D
L06B6               clra
                    clrb
                    bra       L06C2
L06BA               ldu       <u0023,u
                    ldd       ,s
                    addd      #$0001
L06C2               std       ,s
                    ldd       ,s
                    cmpd      <u0074
                    blt       L06BA
                    stu       <u0076
                    bsr       L06D2
                    lbra      L076C
L06D2               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    lbsr      L11BE
                    ldu       <u0076
                    ldd       #$0005
                    std       <u0027
                    ldd       <u0027
                    addd      <u0031
                    std       ,s
                    bra       L0728
L06EE               ldd       <u0027
                    pshs      b,a
                    ldd       #$0008
                    lbsr      L1139
                    leas      $02,s
                    ldd       <u0029
                    beq       L0707
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    bra       L0711
L0707               tfr       u,d
                    bsr       L0745
                    leax      >$0055,y
                    tfr       x,d
L0711               lbsr      L140D
                    ldd       ,u
                    beq       L071E
                    ldd       #$0001
                    lbsr      L115B
L071E               ldu       <u0023,u
                    ldd       <u0027
                    addd      #$0001
                    std       <u0027
L0728               stu       -$02,s
                    beq       L0733
                    ldd       <u0027
                    cmpd      ,s
                    blt       L06EE
L0733               ldd       <u0027
                    addd      #$FFFF
                    std       <u0072
                    ldd       #$0005
                    std       <u0027
                    lbsr      L1240
                    lbra      L08E8
L0745               pshs      u,b,a
                    ldd       #$FFBC
                    lbsr      L00FD
                    leas      -$02,s
                    leau      >$0055,y
                    ldd       $02,s
                    addd      #$0002
                    std       ,s
L075A               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    stb       ,u+
                    cmpb      #$2E
                    bne       L075A
                    clra
                    clrb
                    stb       -u0001,u
L076C               leas      $04,s
                    puls      pc,u
L0770               pshs      u
                    ldd       #$FFC0
                    lbsr      L00FD
                    ldd       <u0027
                    addd      #$FFFC
                    addd      <u0074
                    puls      pc,u
L0781               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    bsr       L0770
                    std       ,s
                    ldu       <u0076
                    bra       L07C1
L0793               ldd       ,s
                    cmpd      <u001F,u
                    bne       L07BE
                    ldd       ,u
                    bne       L07A4
                    ldd       #$0001
                    bra       L07A6
L07A4               clra
                    clrb
L07A6               std       ,u
                    ldd       <u0029
                    bne       L07B6
                    ldd       ,u
                    pshs      b,a
                    tfr       u,d
                    bsr       L07C8
                    leas      $02,s
L07B6               ldd       ,u
                    lbsr      L115B
                    lbra      L08E8
L07BE               ldu       <u0023,u
L07C1               stu       -$02,s
                    bne       L0793
                    lbra      L08A5
L07C8               pshs      u
                    tfr       d,u
                    ldd       #$FFBE
                    lbsr      L00FD
                    leas      -$02,s
                    ldd       $06,s
                    beq       L07DD
                    ldd       #$0001
                    bra       L07E0
L07DD               ldd       #$FFFF
L07E0               std       ,s
                    ldd       [<u0021,u]
                    addd      ,s
                    std       [<u0021,u]
                    ldx       <u0021,u
                    ldd       [<$21,x]
                    addd      ,s
                    std       [<$21,x]
                    lbra      L08E8
L07F8               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldd       <u0027
                    cmpd      #$0005
                    ble       L0835
                    lbsr      L125A
                    ldd       <u0027
                    addd      #$FFFF
                    std       <u0027
                    lbsr      L1240
                    bra       L0838
L0817               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldd       <u0027
                    cmpd      <u0072
                    bge       L0835
                    lbsr      L125A
                    ldd       <u0027
                    addd      #$0001
                    std       <u0027
                    lbsr      L1240
                    bra       L0838
L0835               lbsr      L121F
L0838               puls      pc,u
L083A               pshs      u
                    ldd       #$FFB6
                    lbsr      L00FD
                    leas      -$02,s
                    lbsr      L0770
                    std       ,s
                    ldd       <u0029
                    beq       L0851
                    ldu       <u001B
                    bra       L08A1
L0851               ldu       <u0076
                    bra       L08A1
L0855               ldd       ,s
                    cmpd      <u001F,u
                    bne       L089E
                    tfr       u,d
                    lbsr      L0745
                    ldd       <u0029
                    beq       L0882
                    leax      >$0055,y
                    pshs      x
                    leax      >$0085,y
                    tfr       x,d
                    lbsr      L1B65
                    leas      $02,s
                    clra
                    clrb
                    lbsr      L2BEC
                    lbsr      L1506
                    lbra      L08E8
L0882               clra
                    clrb
                    pshs      b,a
                    leax      >$009E,y
                    pshs      x
                    leax      >$0055,y
                    tfr       x,d
                    lbsr      L28B4
                    leas      $02,s
                    lbsr      L1279
                    leas      $02,s
                    bra       L08E8
L089E               ldu       <u0023,u
L08A1               stu       -$02,s
                    bne       L0855
L08A5               lbsr      L121F
                    bra       L08E8
L08AA               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leax      >L0981,pcr
                    pshs      x
                    ldd       <u000D
                    bsr       L08BE
                    bra       L08E8
L08BE               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    bra       L08EF
L08CA               ldd       $04,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L0D34
                    std       ,s++
                    beq       L08EC
                    ldd       #$0001
                    std       ,u
                    pshs      b,a
                    tfr       u,d
                    lbsr      L07C8
L08E8               leas      $02,s
                    puls      pc,u
L08EC               ldu       <u0023,u
L08EF               stu       -$02,s
                    bne       L08CA
                    puls      pc,u
L08F5               pshs      u
                    ldd       #$FFC0
                    lbsr      L00FD
                    ldu       <u0015
                    bra       L090D
L0901               ldd       ,u
                    beq       L090A
                    ldd       #$0001
                    puls      pc,u
L090A               ldu       <u0023,u
L090D               stu       -$02,s
                    bne       L0901
                    clra
                    clrb
                    puls      pc,u
L0915               rorb
                    lsra
                    asra
                    neg       <u0056
                    lsra
                    asra
                    rola
                    fcb       $4E                 N
                    lsrb
                    bra       L096F
                    clra
                    lsrb
                    bra       L096B
                    clra
                    fcb       $55                 U
                    fcb       $4E                 N
                    lsra
                    neg       <u0057
                    rola
                    fcb       $4E                 N
                    neg       <u0047
                    fcb       $52                 R
                    rora
                    neg       <u0057
                    rola
                    fcb       $4E                 N
                    lsra
                    rola
                    fcb       $4E                 N
                    lsrb
                    bra       L097C
                    fcb       $4E                 N
                    lsra
                    bra       L0986
                    fcb       $52                 R
                    rora
                    rola
                    fcb       $4E                 N
                    lsrb
                    bra       L0994
                    clra
                    lsrb
                    bra       L0990
                    clra
                    fcb       $55                 U
                    fcb       $4E                 N
                    lsra
                    neg       <u0074
                    eim       #$72,$0D,s
                    bgt       L09BD
                    neg       >$0057
                    neg       <u0057
                    leay      $00,x
L095C               asrb
                    rola
                    fcb       $4E                 N
                    neg       <u0047
                    fcb       $52                 R
                    rora
                    neg       <u0057
                    rola
                    fcb       $4E                 N
                    lsra
                    rola
                    fcb       $4E                 N
                    lsrb
L096B               bra       L09AE
                    fcb       $4E                 N
                    lsra
L096F               bra       L09B8
                    fcb       $52                 R
                    rora
                    rola
                    fcb       $4E                 N
                    lsrb
                    bra       L09C6
                    clra
                    lsrb
                    bra       L09C2
L097C               clra
                    fcb       $55                 U
                    fcb       $4E                 N
                    lsra
                    neg       <u0044
                    leax      $00,x
L0984               pshs      u
L0986               ldd       #$FFA8
                    lbsr      L00FD
                    leas      -$0E,s
                    ldd       #$0081
                    pshs      b,a
                    leax      >L0DF1,pcr
                    tfr       x,d
                    lbsr      L29FE
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L09AF
                    leax      >L0DF3,pcr
                    tfr       x,d
                    lbsr      L14BD
L09AF               clra
                    clrb
                    pshs      b,a
                    ldd       #$0040
                    pshs      b,a
L09B8               clra
                    clrb
                    pshs      b,a
                    ldd       $06,s
                    lbsr      L2AD6
                    leas      $06,s
                    leax      >$000D,y
                    stx       $0C,s
                    leax      >$000F,y
                    stx       $0A,s
                    leax      >$0015,y
                    stx       $08,s
                    leax      >$0017,y
                    stx       $06,s
                    lbra      L0AD0
L09DE               leax      >$0461,y
                    stx       $04,s
                    ldd       $02,s
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L2DD7
                    std       $02,s
                    lbra      L0AC5
L09F3               ldb       [<$04,s]
                    lbeq      L0ABE
                    ldd       $04,s
                    pshs      b,a
                    leax      >$0055,y
                    tfr       x,d
                    lbsr      L29D2
                    leas      $02,s
                    leax      >$0055,y
                    tfr       x,d
                    lbsr      L0DD5
                    leax      >$0055,y
                    tfr       x,d
                    lbsr      L0CC7
                    std       -$02,s
                    beq       L0A41
                    leax      >$0055,y
                    tfr       x,d
                    lbsr      L0AF1
                    tfr       d,u
                    tfr       u,d
                    std       [<$0C,s]
                    ldd       <u001D
                    addd      #$0001
                    std       <u001D
                    std       <u001F,u
                    leax      <u0023,u
                    stx       $0C,s
                    lbra      L0ABE
L0A41               leax      >$0055,y
                    tfr       x,d
                    lbsr      L0CD7
                    std       -$02,s
                    beq       L0A65
                    leax      >$0055,y
                    tfr       x,d
                    lbsr      L0B49
                    tfr       d,u
                    tfr       u,d
                    std       [<$0A,s]
                    leax      <u0023,u
                    stx       $0A,s
                    bra       L0ABE
L0A65               leax      >$0055,y
                    tfr       x,d
                    lbsr      L0CE7
                    std       -$02,s
                    beq       L0A93
                    leax      >$0055,y
                    tfr       x,d
                    lbsr      L0AF1
                    tfr       d,u
                    tfr       u,d
                    std       [<$08,s]
                    ldd       <u0021
                    addd      #$0001
                    std       <u0021
                    std       <u001F,u
                    leax      <u0023,u
                    stx       $08,s
                    bra       L0ABE
L0A93               leax      >$0055,y
                    tfr       x,d
                    lbsr      L0CF7
                    std       -$02,s
                    beq       L0ABE
                    leax      >$0055,y
                    tfr       x,d
                    bsr       L0AF1
                    tfr       d,u
                    tfr       u,d
                    std       [<$06,s]
                    ldd       <u0023
                    addd      #$0001
                    std       <u0023
                    std       <u001F,u
                    leax      <u0023,u
                    stx       $06,s
L0ABE               ldd       $04,s
                    addd      #$0020
                    std       $04,s
L0AC5               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    lbge      L09F3
L0AD0               ldd       #$0800
                    pshs      b,a
                    leax      >$0461,y
                    pshs      x
                    ldd       $04,s
                    lbsr      L2A85
                    leas      $04,s
                    std       $02,s
                    lbgt      L09DE
                    ldd       ,s
                    lbsr      L2A0B
                    leas      $0E,s
                    puls      pc,u
L0AF1               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    leas      -$02,s
                    clra
                    clrb
                    pshs      b,a
                    ldd       $04,s
                    lbsr      L0C90
                    leas      $02,s
                    tfr       d,u
                    ldd       #$0001
                    pshs      b,a
                    ldd       $04,s
                    lbsr      L29FE
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    beq       L0B35
                    ldd       ,s
                    bsr       L0B6B
                    std       <u0021,u
                    ldd       ,s
                    lbsr      L0BD2
                    ldx       <u0021,u
                    std       <$21,x
                    ldd       ,s
                    lbsr      L2A0B
                    bra       L0B44
L0B35               leax      >L0E0F,pcr
                    tfr       x,d
                    lbsr      L145D
                    lbsr      L11E8
                    lbsr      L0EBF
L0B44               tfr       u,d
                    lbra      L0D30
L0B49               pshs      u,b,a
                    ldd       #$FFB8
                    lbsr      L00FD
                    clra
                    clrb
                    pshs      b,a
                    ldd       $02,s
                    lbsr      L0C90
                    leas      $02,s
                    tfr       d,u
                    ldd       <u001F
                    addd      #$0001
                    std       <u001F
                    std       <u001F,u
                    lbra      L0DAA
L0B6B               pshs      u,b,a
                    ldd       #$FFB4
                    lbsr      L00FD
                    clra
                    clrb
                    pshs      b,a
                    ldd       #$000B
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    ldd       $06,s
                    lbsr      L2AD6
                    leas      $06,s
                    ldd       ,s
                    lbsr      L0C38
                    leax      >$0096,y
                    pshs      x
                    leax      >$0038,y
                    tfr       x,d
                    lbsr      L28B4
                    leas      $02,s
                    ldu       <u0013
                    bra       L0BBA
L0BA1               leax      >$0038,y
                    pshs      x
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L28E1
                    std       ,s++
                    lbeq      L0DAA
                    ldu       <u0023,u
L0BBA               stu       -$02,s
                    bne       L0BA1
                    ldd       <u0013
                    pshs      b,a
                    leax      >$0038,y
                    tfr       x,d
                    lbsr      L0C90
                    leas      $02,s
                    std       <u0013
                    lbra      L0DED
L0BD2               pshs      u,b,a
                    ldd       #$FFB4
                    lbsr      L00FD
                    clra
                    clrb
                    pshs      b,a
                    ldd       #$0009
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    ldd       $06,s
                    lbsr      L2AD6
                    leas      $06,s
                    ldd       ,s
                    bsr       L0C38
                    leax      >$009A,y
                    pshs      x
                    leax      >$0038,y
                    tfr       x,d
                    lbsr      L28B4
                    leas      $02,s
                    ldu       <u0011
                    bra       L0C20
L0C07               leax      >$0038,y
                    pshs      x
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L28E1
                    std       ,s++
                    lbeq      L0DAA
                    ldu       <u0023,u
L0C20               stu       -$02,s
                    bne       L0C07
                    ldd       <u0011
                    pshs      b,a
                    leax      >$0038,y
                    tfr       x,d
                    lbsr      L0C90
                    leas      $02,s
                    std       <u0011
                    lbra      L0DED
L0C38               pshs      u,b,a
                    ldd       #$FFB2
                    lbsr      L00FD
                    leas      -$02,s
                    ldd       #$0002
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    ldd       $06,s
                    lbsr      L2A85
                    leas      $04,s
                    clra
                    clrb
                    pshs      b,a
                    ldd       $02,s
                    lbsr      L2CE8
                    ldd       $02,x
                    pshs      b,a
                    ldd       ,x
                    pshs      b,a
                    ldd       $08,s
                    lbsr      L2AD6
                    leas      $06,s
                    ldd       #$001C
                    pshs      b,a
                    leau      >$0038,y
                    pshs      u
                    ldd       $06,s
                    lbsr      L2A85
                    leas      $04,s
L0C7C               ldb       ,u+
                    cmpb      #$7F
                    bls       L0C7C
                    ldb       -u0001,u
                    clra
                    andb      #$7F
                    stb       -u0001,u
                    clra
                    clrb
                    stb       ,u
                    lbra      L0D30
L0C90               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    ldu       <u0019
                    beq       L0CA3
                    ldd       <u0023,u
                    std       <u0019
                    bra       L0CAB
L0CA3               ldd       #$0025
                    lbsr      L0D0E
                    tfr       d,u
L0CAB               ldd       ,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L1FE5
                    leas      $02,s
                    clra
                    clrb
                    std       ,u
                    ldd       $06,s
                    std       <u0023,u
                    lbra      L0DAA
L0CC7               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leax      >$008A,y
                    bra       L0D05
L0CD7               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leax      >$0092,y
                    bra       L0D05
L0CE7               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leax      >L0E2A,pcr
                    bra       L0D05
L0CF7               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leax      >L0E2E,pcr
L0D05               pshs      x
                    tfr       u,d
                    bsr       L0D34
                    lbra      L0DED
L0D0E               pshs      u,b,a
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    ldd       $02,s
                    lbsr      L2B51
                    std       ,s
                    cmpd      #$FFFF
                    bne       L0D2E
                    leax      >L0E32,pcr
                    tfr       x,d
                    lbsr      L14BD
L0D2E               ldd       ,s
L0D30               leas      $04,s
                    puls      pc,u
L0D34               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    bra       L0D53
L0D40               ldd       $04,s
                    pshs      b,a
                    tfr       u,d
                    leau      u0001,u
                    bsr       L0D5B
                    std       ,s++
                    beq       L0D53
                    ldd       #$0001
                    puls      pc,u
L0D53               ldb       ,u
                    bne       L0D40
                    clra
                    clrb
                    puls      pc,u
L0D5B               pshs      u,b,a
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldu       $06,s
                    bra       L0D7F
L0D67               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    sex
                    pshs      b,a
                    ldb       ,u+
                    sex
                    cmpd      ,s++
                    beq       L0D7F
                    clra
                    clrb
                    lbra      L0DED
L0D7F               ldb       ,u
                    bne       L0D67
                    ldd       #$0001
                    lbra      L0DED
L0D89               pshs      u,b,a
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldu       ,s
                    bra       L0D97
L0D95               leau      u0001,u
L0D97               ldb       ,u
                    bne       L0D95
                    bra       L0DAE
L0D9D               ldb       ,u
                    sex
                    pshs      b,a
                    ldb       $09,s
                    sex
                    cmpd      ,s++
                    bne       L0DAE
L0DAA               tfr       u,d
                    bra       L0DED
L0DAE               tfr       u,d
                    leau      -u0001,u
                    cmpd      ,s
                    bne       L0D9D
                    ldd       ,s
                    bra       L0DED
L0DBB               pshs      u,b,a
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldu       ,s
                    bra       L0DC9
L0DC7               leau      u0001,u
L0DC9               ldb       ,u
                    sex
                    lbsr      L2795
                    stb       ,u
                    bne       L0DC7
                    bra       L0DED
L0DD5               pshs      u,b,a
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldu       ,s
                    bra       L0DE3
L0DE1               leau      u0001,u
L0DE3               ldb       ,u
                    sex
                    lbsr      L277D
                    stb       ,u
                    bne       L0DE1
L0DED               leas      $02,s
                    puls      pc,u
L0DF1               bgt       L0DF3
L0DF3               coma
                    oim       #$6E,$07,y
                    lsr       >$206F
                    neg       >$656E
                    bra       L0E6C
                    clr       $04,s
                    eim       #$6C,>$6520
                    lsr       $09,s
                    aim       #$65,>$6374
                    clr       -$0E,s
                    rol       >$0043
                    oim       #$6E,$07,y
                    lsr       >$206F
                    neg       >$656E
                    bra       L0E7F
                    eim       #$73,$03,s
                    aim       #$69,>$7074
                    clr       -$0E,s
                    bra       L0E8C
                    rol       $0C,s
                    eim       #$00,$0E,y
                    lsra
                    asrb
                    neg       <u002E
                    lsra
                    lsrb
                    neg       <u004F
                    eim       #$74,>$206F
                    ror       $00,y
                    tst       $05,s
                    tst       $0F,s
                    aim       #$79,>$0034
                    nega
                    ldd       #$FFB8
                    lbsr      L00FD
                    bsr       L0E5B
                    leax      >$01FB,y
                    pshs      x
                    ldd       #$0006
                    pshs      b,a
                    ldd       #$0001
                    lbra      L10B0
L0E5B               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    clra
                    clrb
                    pshs      b,a
                    ldd       #$000D
                    lbsr      L1139
                    leas      $02,s
                    ldd       >$01E5,y
                    lbra      L1274
L0E76               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0008
                    lbsr      L1139
                    leas      $02,s
                    leax      >$013A,y
                    lbra      L1272
L0E92               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leax      >$01E5,y
                    pshs      x
                    ldd       #$0004
                    pshs      b,a
                    clra
                    clrb
                    lbsr      L13C0
                    leas      $04,s
                    ldd       #$0004
                    pshs      b,a
                    clra
                    clrb
                    lbsr      L1139
                    leas      $02,s
                    leax      >$00CF,y
                    lbra      L1272
L0EBF               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    lbsr      L0E5B
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0004
                    lbsr      L1139
                    leas      $02,s
                    leax      >$0121,y
                    lbra      L0FCF
L0EDE               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    lbsr      L0E5B
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0006
                    lbsr      L1139
                    leas      $02,s
                    leax      >$014B,y
                    lbra      L0FCF
L0EFD               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leax      >$040D,y
                    tfr       x,d
                    lbsr      L039C
                    std       -$02,s
                    lbne      L10F2
                    lbsr      L0E5B
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1139
                    leas      $02,s
                    leax      >L1753,pcr
                    tfr       x,d
                    lbsr      L140D
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0010
                    lbsr      L1139
                    leas      $02,s
                    leax      >$040D,y
                    tfr       x,d
                    lbsr      L140D
                    ldd       #$0004
                    pshs      b,a
                    lbra      L10EB
L0F4B               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       <u002D
                    beq       L0F65
                    lbsr      L10F4
                    leax      >$01B5,y
                    tfr       x,d
                    lbsr      L1115
                    bra       L0F84
L0F65               lbsr      L11B1
                    lbsr      L0E5B
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0006
                    lbsr      L1139
                    leas      $02,s
                    leax      >$015E,y
                    tfr       x,d
                    lbsr      L140D
                    lbsr      L0E76
L0F84               ldd       #$0007
                    pshs      b,a
                    clra
                    clrb
                    lbsr      L1139
                    lbra      L14B9
L0F91               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L11B1
                    lbsr      L0E5B
                    leax      >$0207,y
                    pshs      x
                    ldd       #$0006
                    pshs      b,a
                    ldd       #$0002
                    lbra      L10B0
L0FB0               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    lbsr      L11B1
                    lbsr      L0E5B
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0004
                    lbsr      L1139
                    leas      $02,s
                    leax      >$0185,y
L0FCF               tfr       x,d
                    lbsr      L140D
                    lbsr      L0E76
                    puls      pc,u
L0FD9               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leax      >$0401,y
                    tfr       x,d
                    lbsr      L039C
                    std       -$02,s
                    bne       L103D
                    lbsr      L11B1
                    lbsr      L0E5B
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0004
                    lbsr      L1139
                    leas      $02,s
                    leax      >L176D,pcr
                    tfr       x,d
                    lbsr      L140D
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$000D
                    lbsr      L1139
                    leas      $02,s
                    leax      >$0401,y
                    tfr       x,d
                    lbsr      L140D
                    ldd       #$0004
                    pshs      b,a
                    lbsr      L1139
                    leas      $02,s
                    lbsr      L1506
                    ldd       <u002D
                    beq       L103D
                    lbsr      L10F4
                    leax      >$01CC,y
                    tfr       x,d
                    lbsr      L1115
L103D               puls      pc,u
L103F               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L11B1
                    lbsr      L0E5B
                    leax      >$01F5,y
                    pshs      x
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0002
                    lbsr      L13C0
                    leas      $04,s
                    ldd       #$0005
                    bra       L1089
L1065               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L11B1
                    lbsr      L0E5B
                    leax      >$0213,y
                    pshs      x
                    ldd       #$0004
                    pshs      b,a
                    ldd       #$0002
                    lbsr      L13C0
                    leas      $04,s
                    ldd       #$0006
L1089               pshs      b,a
                    ldd       #$0008
                    lbsr      L1139
                    leas      $02,s
                    ldd       >$01F3,y
                    lbra      L1274
L109A               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leax      >$01ED,y
                    pshs      x
                    ldd       #$0004
                    pshs      b,a
                    ldd       #$0008
L10B0               lbsr      L13C0
                    lbra      L1409
L10B6               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    lbsr      L11B1
                    lbsr      L0E5B
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0006
                    lbsr      L1139
                    leas      $02,s
                    leax      >$0172,y
                    tfr       x,d
                    lbsr      L140D
                    leax      >$040D,y
                    tfr       x,d
                    lbsr      L140D
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0004
L10EB               bsr       L1139
                    leas      $02,s
                    lbsr      L1506
L10F2               puls      pc,u
L10F4               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    lbsr      L11B1
                    lbsr      L0E5B
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0005
                    bsr       L1139
                    leas      $02,s
                    leax      >$019E,y
                    lbra      L1272
L1115               pshs      u,b,a
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0004
                    bsr       L1139
                    leas      $02,s
                    ldd       ,s
                    lbsr      L140D
                    ldd       #$0005
                    pshs      b,a
                    clra
                    clrb
                    bsr       L1139
                    bra       L118A
L1139               pshs      u,b,a
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0002
                    stb       <u0035
                    ldd       ,s
                    addd      #$0020
                    addd      <u002F
                    stb       <u0036
                    ldd       $06,s
                    addd      #$0020
                    stb       <u0037
                    ldd       #$0003
                    bra       L117F
L115B               pshs      u,b,a
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       <u0027
                    pshs      b,a
                    ldd       #$0018
                    bsr       L1139
                    leas      $02,s
                    ldd       ,s
                    beq       L1177
                    ldd       #$0058
                    bra       L117A
L1177               ldd       #$0020
L117A               stb       <u0035
                    ldd       #$0001
L117F               pshs      b,a
                    leax      >$0035,y
                    tfr       x,d
                    lbsr      L141C
L118A               leas      $02,s
                    lbra      L14B9
L118F               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       #$0005
                    stb       <u0035
                    stu       -$02,s
                    beq       L11A7
                    ldd       #$0021
                    bra       L11AA
L11A7               ldd       #$0020
L11AA               stb       <u0036
                    ldd       #$0002
                    bra       L11DA
L11B1               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       #$000C
                    bra       L11D5
L11BE               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       #$0005
                    pshs      b,a
                    clra
                    clrb
                    lbsr      L1139
                    leas      $02,s
                    ldd       #$000B
L11D5               stb       <u0035
                    ldd       #$0001
L11DA               pshs      b,a
                    leax      >$0035,y
                    tfr       x,d
                    lbsr      L141C
                    lbra      L14B9
L11E8               pshs      u
                    ldd       #$FFB9
                    lbsr      L00FD
                    leas      -$01,s
                    ldd       #$0004
                    stb       ,s
                    ldu       #$0000
                    bra       L1215
L11FC               pshs      u
                    clra
                    clrb
                    lbsr      L1139
                    leas      $02,s
                    ldd       #$0001
                    pshs      b,a
                    leax      $02,s
                    tfr       x,d
                    lbsr      L141C
                    leas      $02,s
                    leau      u0001,u
L1215               cmpu      #$0003
                    ble       L11FC
                    leas      $01,s
                    puls      pc,u
L121F               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0007
                    stb       <u0035
                    ldd       #$0001
                    pshs      b,a
                    leax      >$0035,y
                    pshs      x
                    ldd       #$0002
                    lbsr      L2AAD
                    lbra      L1409
L1240               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    pshs      u
                    ldd       #$0003
                    lbsr      L1139
                    leas      $02,s
                    leax      >$0001,y
                    bra       L1272
L125A               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    pshs      u
                    ldd       #$0003
                    lbsr      L1139
                    leas      $02,s
                    leax      >$0004,y
L1272               tfr       x,d
L1274               lbsr      L140D
                    puls      pc,u
L1279               pshs      u,b,a
                    ldd       #$FF8F
                    lbsr      L00FD
                    leas      <-$27,s
                    leax      >$0085,y
                    tfr       x,d
                    lbsr      L2B41
                    ldd       #$0001
                    pshs      b,a
                    ldd       <$29,s
                    lbsr      L29FE
                    leas      $02,s
                    std       <$25,s
                    cmpd      #$FFFF
                    bne       L12AF
                    leax      >L1787,pcr
                    tfr       x,d
                    lbsr      L145D
                    lbra      L1326
L12AF               lbsr      L11E8
                    clra
                    clrb
                    std       <$23,s
                    pshs      b,a
                    bra       L12F7
L12BB               ldd       <$23,s
                    cmpd      #$0002
                    ble       L12D9
                    lbsr      L133D
                    cmpd      #$0002
                    beq       L1312
                    clra
                    clrb
                    std       <$23,s
                    pshs      b,a
                    lbsr      L1139
                    leas      $02,s
L12D9               ldd       <$21,s
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    ldd       #$0001
                    lbsr      L2AC2
                    leas      $04,s
                    ldd       <$23,s
                    addd      #$0001
                    std       <$23,s
                    pshs      b,a
                    clra
                    clrb
L12F7               lbsr      L1139
                    leas      $02,s
                    ldd       #$0020
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    ldd       <$29,s
                    lbsr      L2A9B
                    leas      $04,s
                    std       <$21,s
                    bgt       L12BB
L1312               ldd       <$21,s
                    bge       L1320
                    leax      >L179C,pcr
                    tfr       x,d
                    lbsr      L145D
L1320               ldd       <$25,s
                    lbsr      L2A0B
L1326               lbsr      L139D
                    leax      >$00A2,y
                    tfr       x,d
                    lbsr      L2B41
                    lbsr      L11E8
                    lbsr      L0E92
                    leas      <$29,s
                    puls      pc,u
L133D               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       <u002B
                    beq       L134E
                    ldd       #$000F
                    bra       L1351
L134E               ldd       #$0003
L1351               pshs      b,a
                    ldd       #$0004
                    lbsr      L1139
                    leas      $02,s
                    leax      >$00EF,y
                    tfr       x,d
                    lbsr      L140D
L1364               lbsr      L1437
                    sex
                    tfr       d,x
                    bra       L1381
L136C               lbsr      L11E8
                    ldd       #$0001
                    puls      pc,u
L1374               lbsr      L11E8
                    ldd       #$0002
                    puls      pc,u
L137C               lbsr      L121F
                    bra       L1364
L1381               cmpx      #$004D
                    beq       L136C
                    cmpx      #$006D
                    lbeq      L136C
                    cmpx      #$0043
                    beq       L1374
                    cmpx      #$0063
                    lbeq      L1374
                    bra       L137C
                    puls      pc,u
L139D               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       <u002B
                    beq       L13AE
                    ldd       #$000F
                    bra       L13B1
L13AE               ldd       #$0003
L13B1               pshs      b,a
                    ldd       #$0004
                    lbsr      L1139
                    leas      $02,s
                    lbsr      L1506
                    puls      pc,u
L13C0               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    leas      -$02,s
                    bra       L1400
L13CC               ldd       [<$0A,s]
                    lbsr      L2889
                    pshs      b,a
                    ldd       #$0020
                    subd      ,s++
                    pshs      b,a
                    ldd       #$0002
                    lbsr      L2D6D
                    std       ,s
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
                    subd      #$0001
                    pshs      b,a
                    ldd       $02,s
                    lbsr      L1139
                    leas      $02,s
                    ldx       $0A,s
                    leax      $02,x
                    stx       $0A,s
                    ldd       -$02,x
                    bsr       L140D
L1400               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    bge       L13CC
L1409               leas      $04,s
                    puls      pc,u
L140D               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    ldd       ,s
                    lbsr      L2889
                    bra       L1426
L141C               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    ldd       $06,s
L1426               pshs      b,a
                    ldd       $02,s
                    pshs      b,a
                    ldd       #$0001
                    lbsr      L2AAD
                    leas      $04,s
                    lbra      L14B9
L1437               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0001
                    pshs      b,a
                    leax      >$0078,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2A85
                    leas      $04,s
                    std       -$02,s
                    bgt       L1459
                    clra
                    clrb
                    stb       <u0078
L1459               ldb       <u0078
                    puls      pc,u
L145D               pshs      u
                    tfr       d,u
                    ldd       #$FFBC
                    lbsr      L00FD
                    lbsr      L121F
                    lbsr      L11E8
                    tfr       u,d
                    bsr       L1484
                    puls      pc,u
L1473               pshs      u,b,a
                    ldd       #$FFBA
                    lbsr      L00FD
                    lbsr      L11B1
                    ldd       ,s
                    bsr       L1484
                    bra       L14B9
L1484               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    tfr       u,d
                    lbsr      L2889
                    pshs      b,a
                    ldd       #$0020
                    subd      ,s++
                    pshs      b,a
                    ldd       #$0002
                    lbsr      L2D6D
                    std       ,s
                    clra
                    clrb
                    pshs      b,a
                    ldd       $02,s
                    lbsr      L1139
                    leas      $02,s
                    tfr       u,d
                    lbsr      L140D
                    lbsr      L139D
L14B9               leas      $02,s
                    puls      pc,u
L14BD               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L121F
                    lbsr      L11B1
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L1139
                    leas      $02,s
                    ldd       #$0008
                    pshs      b,a
                    leax      >L17B4,pcr
                    pshs      x
                    ldd       #$0002
                    lbsr      L2AAD
                    leas      $04,s
                    tfr       u,d
                    lbsr      L2889
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    lbsr      L2AAD
                    leas      $04,s
                    lbsr      L0269
                    ldd       >$03BB,y
                    lbsr      L2CDA
                    puls      pc,u
L1506               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leax      >$0108,y
                    tfr       x,d
                    lbsr      L140D
                    lbsr      L1437
                    puls      pc,u
                    coma
                    clra
                    fcb       $4E                 N
                    rora
                    rola
                    asra
                    neg       <u0041
                    fcb       $52                 R
                    fcb       $52                 R
                    clra
                    asrb
                    comb
                    bra       L1558
                    bra       L1582
                    negb
                    ble       L1574
                    clra
                    asrb
                    fcb       $4E                 N
                    ble       L1582
                    clra
                    fcb       $52                 R
                    fcb       $45                 E
                    ble       L157C
                    fcb       $41                 A
                    coma
                    fcb       $4B                 K
                    neg       <u0053
                    bra       L156E
                    bra       L1596
                    fcb       $45                 E
                    inca
                    ble       L159C
                    fcb       $4E                 N
                    comb
                    fcb       $45                 E
                    inca
                    bra       L1595
                    bra       L157C
                    bra       L1599
                    fcb       $45                 E
                    inca
                    negb
                    bra       L159A
                    bra       L1585
L1558               bra       L159E
                    clra
                    fcb       $4E                 N
                    fcb       $45                 E
                    neg       <u0020
                    bra       L1581
                    rola
                    lsrb
                    fcb       $45                 E
                    tsta
                    bra       L1587
                    bra       L1589
                    bra       L158B
                    bra       L158D
                    bra       L15C2
                    fcb       $45                 E
                    inca
                    neg       <u0048
                    clra
L1574               asrb
                    bra       L15C4
                    fcb       $41                 A
                    fcb       $4E                 N
                    rolb
                    bra       L15C0
L157C               fcb       $52                 R
                    rola
                    rorb
                    fcb       $45                 E
                    comb
L1581               bra       L15C7
                    clra
                    bra       L15DF
                    clra
L1587               fcb       $55                 U
                    bra       L15D2
                    fcb       $41                 A
L158B               rorb
                    fcb       $45                 E
L158D               abx
                    neg       <u0031
                    bra       L15BF
                    bra       L15E3
                    fcb       $4E                 N
L1595               fcb       $45                 E
L1596               bra       L15DC
                    fcb       $52                 R
L1599               rola
L159A               rorb
                    fcb       $45                 E
L159C               bra       L15ED
L159E               fcb       $4E                 N
                    inca
                    rolb
                    bra       L15C3
                    bra       L15C5
                    neg       <u0032
                    bra       L15D6
                    bra       L15FF
                    asrb
                    clra
                    bra       L15FE
                    fcb       $52                 R
                    bra       L15FF
                    clra
                    fcb       $52                 R
                    fcb       $45                 E
                    bra       L15FB
                    fcb       $52                 R
                    rola
                    rorb
                    fcb       $45                 E
                    comb
                    neg       <u0053
                    fcb       $45                 E
L15BF               inca
L15C0               fcb       $45                 E
                    coma
L15C2               lsrb
L15C3               rola
L15C4               clra
L15C5               fcb       $4E                 N
                    bra       L1623
                    leay      $0C,y
                    leas      -u0003,u
                    bra       L15CE
L15CE               comb
                    fcb       $45                 E
                    inca
                    fcb       $45                 E
L15D2               coma
                    lsrb
                    bra       L1619
L15D6               inca
                    clra
                    coma
                    fcb       $4B                 K
                    bra       L1629
L15DC               clra
                    lsra
                    fcb       $55                 U
L15DF               inca
                    fcb       $45                 E
                    abx
                    neg       <u0031
                    bra       L1613
                    bra       L161E
                    leax      $00,y
                    lsla
                    decb
                    bra       L1616
                    fcb       $41                 A
                    tsta
                    fcb       $45                 E
                    fcb       $52                 R
                    rola
                    coma
                    fcb       $41                 A
                    fcb       $4E                 N
                    bra       L1648
                    clra
                    asrb
                    fcb       $45                 E
L15FB               fcb       $52                 R
                    bvs       L15FE
L15FE               leas      $00,y
                    blt       L1622
                    puls      y,x
                    bra       L164E
                    decb
                    bra       L1631
                    fcb       $45                 E
                    fcb       $55                 U
                    fcb       $52                 R
                    clra
                    negb
                    fcb       $45                 E
                    fcb       $41                 A
                    fcb       $4E                 N
                    bra       L1663
L1613               clra
                    asrb
                    fcb       $45                 E
L1616               fcb       $52                 R
                    bvs       L1619
L1619               coma
                    clra
                    fcb       $4E                 N
                    rora
                    rola
L161E               asra
                    bra       L1677
                    fcb       $45                 E
L1622               fcb       $52                 R
L1623               comb
                    rola
                    clra
                    fcb       $4E                 N
                    bra       L165B
L1629               bgt       L165B
                    neg       <u0043
                    clra
                    negb
                    rolb
                    fcb       $52                 R
L1631               rola
                    asra
                    lsla
                    lsrb
                    bra       L1668
                    rts
                    fcb       $38                 8
                    pshu      y
                    fcb       $42                 B
                    rolb
                    neg       <u004D
                    rola
                    coma
                    fcb       $52                 R
                    clra
                    asrb
                    fcb       $41                 A
                    fcb       $52                 R
                    fcb       $45                 E
                    bra       L169C
                    rolb
                    comb
                    lsrb
                    fcb       $45                 E
                    tsta
L164E               comb
                    bra       L1694
                    clra
                    fcb       $52                 R
                    negb
                    bgt       L1656
L1656               fcb       $52                 R
                    fcb       $45                 E
                    negb
                    fcb       $52                 R
                    clra
L165B               lsra
                    fcb       $55                 U
                    coma
                    fcb       $45                 E
                    lsra
                    bra       L16B7
                    fcb       $4E                 N
L1663               lsra
                    fcb       $45                 E
                    fcb       $52                 R
                    bra       L16B4
L1668               rola
                    coma
                    fcb       $45                 E
                    fcb       $4E                 N
                    comb
                    fcb       $45                 E
                    neg       <u0054
                    clra
                    bra       L16C7
                    fcb       $41                 A
                    fcb       $4E                 N
                    lsra
                    rolb
L1677               bra       L16BC
                    clra
                    fcb       $52                 R
                    negb
                    bgt       L167E
L167E               fcb       $41                 A
                    inca
                    inca
                    bra       L16D5
                    rola
                    asra
                    lsla
                    lsrb
                    comb
                    bra       L16DC
                    fcb       $45                 E
                    comb
                    fcb       $45                 E
                    fcb       $52                 R
                    rorb
                    fcb       $45                 E
                    lsra
                    neg       <u0044
                    clra
L1694               bra       L16EF
                    clra
                    fcb       $55                 U
                    bra       L16F1
                    rola
                    comb
L169C               lsla
                    bra       L16F3
                    clra
                    bra       L16E3
                    lsra
                    lsra
                    neg       <u005B
                    fcb       $4E                 N
                    tstb
                    clra
                    bra       L16EE
                    clra
                    tsta
                    tsta
                    fcb       $41                 A
                    fcb       $4E                 N
                    lsra
                    comb
                    bge       L16D4
L16B4               comb
                    lsrb
                    clra
L16B7               negb
                    bra       L1708
                    clra
                    asrb
L16BC               neg       <u005B
                    rora
                    tstb
                    fcb       $55                 U
                    inca
                    inca
                    bra       L1708
                    clra
                    tsta
L16C7               tsta
                    fcb       $41                 A
                    fcb       $4E                 N
                    lsra
                    bra       L1720
                    fcb       $45                 E
                    lsrb
                    bra       L16F1
                    bra       L16F3
                    bra       L16D5
L16D5               fcb       $5B                 [
                    rola
                    tstb
                    fcb       $4E                 N
                    rola
                    lsra
                    rola
L16DC               rorb
                    rola
                    lsra
                    fcb       $55                 U
                    fcb       $41                 A
                    inca
                    inca
L16E3               rolb
                    bra       L1739
                    fcb       $45                 E
                    inca
                    fcb       $45                 E
                    coma
                    lsrb
                    bra       L16ED
L16ED               fcb       $5B                 [
L16EE               lsla
L16EF               tstb
                    bra       L1744
                    fcb       $45                 E
L16F3               coma
                    fcb       $45                 E
                    rola
                    rorb
                    fcb       $45                 E
                    bra       L1742
                    fcb       $45                 E
                    inca
                    negb
                    bra       L171F
                    bra       L1721
                    bra       L1723
                    bra       L1705
L1705               comb
                    fcb       $45                 E
                    inca
L1708               fcb       $45                 E
                    coma
                    lsrb
                    rola
                    clra
                    fcb       $4E                 N
                    bra       L176B
                    fcb       $4E                 N
                    bge       L1759
                    bge       L175E
                    bge       L175F
                    tstb
                    neg       <u0053
                    fcb       $45                 E
                    inca
                    fcb       $45                 E
                    coma
                    lsrb
L171F               bra       L1775
L1721               fcb       $45                 E
                    fcb       $52                 R
L1723               tsta
                    bra       L176A
                    fcb       $45                 E
                    comb
                    coma
                    fcb       $52                 R
                    rola
                    negb
                    lsrb
                    clra
                    fcb       $52                 R
                    neg       <u0031
                    bra       L1760
                    bra       L1789
                    fcb       $45                 E
                    fcb       $52                 R
                    tsta
                    clrb
L1739               rorb
                    lsra
                    asra
                    neg       <u0032
                    bra       L176D
                    bra       L1796
L1742               fcb       $45                 E
                    fcb       $52                 R
L1744               tsta
                    clrb
                    asrb
                    rola
                    fcb       $4E                 N
                    neg       <u0048
                    bra       L177A
                    bra       L1797
                    fcb       $45                 E
                    inca
                    negb
                    neg       <u0050
                    inca
                    fcb       $41                 A
                    coma
                    fcb       $45                 E
                    bra       L179B
                    bra       L17A2
                    clra
                    fcb       $52                 R
L175E               tsta
L175F               fcb       $41                 A
L1760               lsrb
                    lsrb
                    fcb       $45                 E
                    lsra
                    bra       L17AA
                    rola
                    comb
                    fcb       $4B                 K
                    bra       L17B4
L176B               fcb       $4E                 N
                    neg       <u0050
                    inca
                    fcb       $41                 A
                    coma
                    fcb       $45                 E
                    bra       L17CD
                    clra
L1775               fcb       $55                 U
                    fcb       $52                 R
                    bra       L17CC
                    rolb
L177A               comb
                    lsrb
                    fcb       $45                 E
                    tsta
                    bra       L17C4
                    rola
                    comb
                    fcb       $4B                 K
                    bra       L17CE
                    fcb       $4E                 N
                    neg       <u0043
                    oim       #$6E,$07,y
                    lsr       >$206F
                    neg       >$656E
                    bra       L17FB
                    eim       #$6C,-$10,s
L1796               bra       L17FE
                    rol       $0C,s
                    eim       #u0000,$05,u
                    aim       #$72,>$6F72
                    bra       L1815
                    eim       #$61,$04,s
                    rol       $0E,s
                    asr       $00,y
L17AA               lsl       $05,s
                    inc       -$10,s
                    bra       L1816
                    rol       $0C,s
                    eim       #u0000,$03,u
                    clra
                    fcb       $4E                 N
                    rora
                    rola
                    asra
                    abx
                    bra       L17BD
L17BD               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       #$0003
                    pshs      b,a
                    leax      >$021B,y
L17CE               tfr       x,d
                    lbsr      L2A1C
                    leas      $02,s
                    std       <u0079
                    cmpd      #$FFFF
                    bne       L17E6
                    leax      >L1A3D,pcr
                    tfr       x,d
                    lbsr      L14BD
L17E6               lbsr      L1909
                    bsr       L182B
                    ldd       <u0079
                    lbsr      L2A0B
                    bsr       L17F4
                    puls      pc,u
L17F4               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leax      >$000D,y
                    tfr       x,d
                    lbsr      L19AA
                    leax      >$0013,y
                    tfr       x,d
                    lbsr      L19AA
                    leax      >$0011,y
                    tfr       x,d
                    lbsr      L19AA
                    leax      >$0015,y
                    tfr       x,d
                    lbsr      L19AA
                    leax      >$000F,y
                    tfr       x,d
                    lbsr      L19AA
                    puls      pc,u
L182B               pshs      u
                    ldd       #$FFB6
                    lbsr      L00FD
                    leas      -$02,s
                    clra
                    clrb
                    bra       L186F
L1839               ldu       <u0011
                    bra       L1866
L183D               ldd       ,s
                    lslb
                    rola
                    leax      >$0007,y
                    leax      d,x
                    ldd       ,x
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L0D34
                    std       ,s++
                    beq       L1863
                    ldd       ,u
                    beq       L186A
                    tfr       u,d
                    bsr       L188F
                    bra       L186A
L1863               ldu       <u0023,u
L1866               stu       -$02,s
                    bne       L183D
L186A               ldd       ,s
                    addd      #$0001
L186F               std       ,s
                    ldd       ,s
                    cmpd      #$0002
                    blt       L1839
                    ldu       <u0011
                    bra       L1888
L187D               ldd       ,u
                    beq       L1885
                    tfr       u,d
                    bsr       L188F
L1885               ldu       <u0023,u
L1888               stu       -$02,s
                    bne       L187D
                    lbra      L1A39
L188F               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    leas      -$02,s
                    ldd       $02,s
                    addd      #$0002
                    lbsr      L197E
                    clra
                    clrb
                    std       [<$02,s]
                    ldd       <u0013
                    lbra      L18FE
L18AB               ldx       ,s
                    ldd       <$21,x
                    cmpd      $02,s
                    bne       L18F9
                    ldd       ,x
                    beq       L18F9
                    tfr       x,d
                    addd      #$0002
                    lbsr      L197E
                    ldd       ,s
                    addd      #$0002
                    lbsr      L1924
                    std       -$02,s
                    beq       L18D0
                    lbsr      L19E7
L18D0               clra
                    clrb
                    std       [,s]
                    ldu       <u000D
                    bra       L18F5
L18D8               ldd       <u0021,u
                    cmpd      ,s
                    bne       L18F2
                    ldd       ,u
                    beq       L18F2
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L197E
                    clra
                    clrb
                    std       ,u
L18F2               ldu       <u0023,u
L18F5               stu       -$02,s
                    bne       L18D8
L18F9               ldx       ,s
                    ldd       <$23,x
L18FE               std       ,s
                    ldd       ,s
                    lbne      L18AB
                    lbra      L19D0
L1909               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leau      >$0224,y
                    bra       L191C
L1917               ldd       ,u++
                    lbsr      L197E
L191C               ldd       ,u
                    bne       L1917
                    bsr       L1941
                    puls      pc,u
L1924               pshs      u,b,a
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       ,s
                    lbsr      L0DD5
                    leax      >L1A83,pcr
                    pshs      x
                    ldd       $02,s
                    lbsr      L0D34
                    leas      $02,s
                    lbra      L1A39
L1941               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    lbsr      L103F
L194C               lbsr      L1437
                    sex
                    tfr       d,x
                    bra       L1969
L1954               leax      >L1A89,pcr
                    bra       L195E
L195A               leax      >L1A94,pcr
L195E               tfr       x,d
                    bsr       L197E
                    puls      pc,u
L1964               lbsr      L121F
                    bra       L194C
L1969               cmpx      #$000D
                    beq       L1954
                    cmpx      #$0031
                    lbeq      L1954
                    cmpx      #$0032
                    beq       L195A
                    bra       L1964
                    puls      pc,u
L197E               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    tfr       u,d
                    lbsr      L2889
                    pshs      b,a
                    pshs      u
                    ldd       <u0079
                    lbsr      L2AAD
                    leas      $04,s
                    ldd       #$0001
                    pshs      b,a
                    leax      >L1A9F,pcr
                    pshs      x
                    ldd       <u0079
                    lbsr      L2AAD
                    bra       L19D0
L19AA               pshs      u,b,a
                    ldd       #$FFBC
                    lbsr      L00FD
                    leas      -$02,s
                    ldu       [<$02,s]
                    bra       L19C7
L19B9               ldd       <u0023,u
                    std       ,s
                    ldd       <u0019
                    std       <u0023,u
                    stu       <u0019
                    ldu       ,s
L19C7               stu       -$02,s
                    bne       L19B9
                    clra
                    clrb
                    std       [<$02,s]
L19D0               leas      $04,s
                    puls      pc,u
L19D4               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leax      >$021B,y
                    tfr       x,d
                    lbsr      L2A73
                    puls      pc,u
L19E7               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    clra
                    clrb
                    bra       L1A2F
L19F5               ldx       ,s
                    bra       L1A05
L19F9               ldu       <u000F
                    bra       L1A26
L19FD               ldu       <u0017
                    bra       L1A26
L1A01               ldu       <u0015
                    bra       L1A26
L1A05               stx       -$02,s
                    beq       L19F9
                    cmpx      #$0001
                    beq       L19FD
                    cmpx      #$0002
                    beq       L1A01
                    bra       L1A26
L1A15               ldd       ,u
                    beq       L1A23
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L197E
L1A23               ldu       <u0023,u
L1A26               stu       -$02,s
                    bne       L1A15
                    ldd       ,s
                    addd      #$0001
L1A2F               std       ,s
                    ldd       ,s
                    cmpd      #$0003
                    blt       L19F5
L1A39               leas      $02,s
                    puls      pc,u
L1A3D               coma
                    oim       #$6E,$07,y
                    lsr       >$2063
                    aim       #$65,>$6174
                    eim       #$20,$02,s
                    clr       $0F,s
                    lsr       >$6C69
                    com       >$7400
                    fcb       $52                 R
                    fcb       $42                 B
                    rora
                    bgt       L1AC5
                    jmp       $00,x
                    comb
                    coma
                    rora
                    bgt       L1ACC
                    jmp       $00,x
                    negb
                    rola
                    negb
                    fcb       $45                 E
                    tsta
                    fcb       $41                 A
                    fcb       $4E                 N
                    bgt       L1AD7
                    jmp       $00,x
                    clra
                    comb
                    rts
                    negb
                    leas      $00,x
                    rola
                    clra
                    tsta
                    oim       #$6E,$00,x
                    rola
                    jmp       $09,s
                    lsr       >$0043
                    coma
                    leau      u0007,u
                    clr       $00,x
L1A83               coma
                    coma
                    leau      u0009,u
                    clra
                    neg       <u0043
                    inc       $0F,s
                    com       $0B,s
                    bgt       L1AC6
                    leax      $08,s
                    dec       >$0043
                    inc       $0F,s
                    com       $0B,s
                    bgt       L1AD0
                    leax      $08,s
                    dec       >$000D
                    neg       <u0034
                    nega
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    lbsr      L11B1
                    leax      >$040D,y
                    pshs      x
                    leax      >$0419,y
                    tfr       x,d
                    lbsr      L1FE5
                    leas      $02,s
                    tfr       d,u
                    ldd       <u002D
                    beq       L1AD9
L1AC5               leax      >L1BA6,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L1FE5
L1AD0               leas      $02,s
                    tfr       d,u
                    lbsr      L0375
L1AD7               bra       L1ADC
L1AD9               lbsr      L0EFD
L1ADC               leax      >L1BAA,pcr
                    pshs      x
                    tfr       u,d
                    lbsr      L1FE5
                    leas      $02,s
                    lbsr      L0F4B
                    leax      >$0419,y
                    tfr       x,d
                    bsr       L1B13
                    leax      ,s
                    tfr       x,d
                    lbsr      L2BEC
                    ldd       ,s
                    beq       L1B07
                    lbsr      L0269
                    ldd       ,s
                    lbsr      L2CDA
L1B07               ldd       <u002D
                    lbeq      L1B89
                    lbsr      L0383
                    lbra      L1B89
L1B13               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    clra
                    clrb
                    lbsr      L2A7A
                    std       <u007B
                    clra
                    clrb
                    lbsr      L2A0B
                    ldd       #$0001
                    pshs      b,a
                    leax      >$021B,y
                    tfr       x,d
                    lbsr      L29FE
                    leas      $02,s
                    std       <u0079
                    bge       L1B46
                    leax      >L1BAC,pcr
                    tfr       x,d
                    lbsr      L14BD
L1B46               pshs      u
                    leax      >L1BC0,pcr
                    tfr       x,d
                    bsr       L1B65
                    leas      $02,s
                    cmpd      #$FFFF
                    bne       L1B61
                    leax      >L1BC7,pcr
                    tfr       x,d
                    lbsr      L14BD
L1B61               bsr       L1B8D
                    puls      pc,u
L1B65               pshs      u,b,a
                    ldd       #$FFB0
                    lbsr      L00FD
                    ldd       #$0040
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    pshs      b,a
                    ldd       $0C,s
                    pshs      b,a
                    lbsr      L2889
                    pshs      b,a
                    ldd       $0A,s
                    lbsr      L2C2A
                    leas      $0A,s
L1B89               leas      $02,s
                    puls      pc,u
L1B8D               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldd       <u0079
                    lbsr      L2A0B
                    ldd       <u007B
                    lbsr      L2A7A
                    ldd       <u007B
                    lbsr      L2A0B
                    puls      pc,u
L1BA6               bra       L1BD5
                    com       >$000D
                    neg       <u0063
                    oim       #$6E,$07,y
                    lsr       >$206F
                    neg       >$656E
                    bra       L1C1A
                    clr       $0F,s
                    lsr       >$6669
                    inc       $05,s
                    neg       <u006F
                    com       >$3967
                    eim       #$6E,$00,x
L1BC7               coma
                    oim       #$6E,$07,y
                    lsr       >$2066
                    clr       -$0E,s
                    tim       #u0020,$0F,u
                    comb
                    rts
L1BD5               asr       $05,s
                    jmp       $00,x
L1BD9               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
L1BE1               lbsr      L0F91
                    lbsr      L1437
                    sex
                    tfr       d,x
                    bra       L1C17
L1BEC               ldd       <u0033
                    bne       L1BF9
                    leax      >L2006,pcr
                    tfr       x,d
                    lbsr      L145D
L1BF9               puls      pc,u
L1BFB               bsr       L1C4B
                    puls      pc,u
L1BFF               bsr       L1C5B
                    puls      pc,u
L1C03               leax      >L2023,pcr
                    tfr       x,d
                    lbsr      L1CFB
                    lbsr      L0F91
                    bra       L1BE1
L1C11               lbsr      L121F
                    lbra      L1BE1
L1C17               cmpx      #$004E
L1C1A               beq       L1BEC
                    cmpx      #$006E
                    lbeq      L1BEC
                    cmpx      #$0046
                    beq       L1BFB
                    cmpx      #$0066
                    lbeq      L1BFB
                    cmpx      #$0049
                    beq       L1BFF
                    cmpx      #$0069
                    lbeq      L1BFF
                    cmpx      #$0048
                    beq       L1C03
                    cmpx      #$0068
                    lbeq      L1C03
                    bra       L1C11
                    puls      pc,u
L1C4B               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldd       #$0001
                    lbsr      L1DA2
                    bra       L1C70
L1C5B               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldd       #$0001
                    std       <u0029
                    clra
                    clrb
                    lbsr      L1DA2
                    lbsr      L0409
L1C70               bsr       L1C74
                    puls      pc,u
L1C74               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    bsr       L1C83
                    lbsr      L1E86
                    puls      pc,u
L1C83               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       <u002D
                    beq       L1C94
                    lbsr      L10B6
                    bra       L1C97
L1C94               lbsr      L0FB0
L1C97               leax      >$040D,y
                    tfr       x,d
                    lbsr      L2B41
                    ldd       #$00BF
                    pshs      b,a
                    leax      >$022E,y
                    tfr       x,d
                    lbsr      L2A13
                    std       ,s++
                    beq       L1CBB
                    leax      >$0233,y
                    tfr       x,d
                    lbsr      L14BD
L1CBB               puls      pc,u
L1CBD               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    ldu       <u001B
                    bra       L1CF2
L1CC9               pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L0DBB
                    ldd       ,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L28E1
                    std       ,s++
                    bne       L1CEF
                    ldd       ,u
                    beq       L1CF6
                    ldd       #$0001
                    lbra      L2002
L1CEF               ldu       <u0023,u
L1CF2               stu       -$02,s
                    bne       L1CC9
L1CF6               clra
                    clrb
                    lbra      L2002
L1CFB               pshs      u,b,a
                    ldd       #$FFB2
                    lbsr      L00FD
                    leas      -$04,s
                    leax      >$0085,y
                    tfr       x,d
                    lbsr      L2B41
                    ldd       #$0001
                    pshs      b,a
                    ldd       $06,s
                    lbsr      L29FE
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L1D31
                    leax      >L202D,pcr
                    tfr       x,d
                    lbsr      L145D
                    lbsr      L11E8
                    lbra      L1D95
L1D31               ldd       #$0001
                    std       <u002B
                    bra       L1D38
L1D38               lbsr      L11B1
                    ldu       #$0000
                    bra       L1D74
L1D40               ldd       #$0020
                    pshs      b,a
                    leax      >$0441,y
                    pshs      x
                    ldd       $04,s
                    lbsr      L2A9B
                    leas      $04,s
                    std       $02,s
                    ble       L1D7A
                    pshs      u
                    clra
                    clrb
                    lbsr      L1139
                    leas      $02,s
                    ldd       #$0020
                    pshs      b,a
                    leax      >$0441,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2AC2
                    leas      $04,s
                    leau      u0001,u
L1D74               cmpu      #$000F
                    blt       L1D40
L1D7A               ldd       $02,s
                    bgt       L1D83
                    lbsr      L139D
                    bra       L1D8C
L1D83               lbsr      L133D
                    cmpd      #$0002
                    bne       L1D38
L1D8C               ldd       ,s
                    lbsr      L2A0B
                    clra
                    clrb
                    std       <u002B
L1D95               leax      >$00A2,y
                    tfr       x,d
                    lbsr      L2B41
                    leas      $06,s
                    puls      pc,u
L1DA2               pshs      u,b,a
                    ldd       #$FF8E
                    lbsr      L00FD
                    leas      <-$26,s
                    lbsr      L0FD9
                    leax      >$0401,y
                    tfr       x,d
                    lbsr      L2B41
                    ldd       #$0081
                    pshs      b,a
                    leax      >$022E,y
                    tfr       x,d
                    lbsr      L29FE
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    bne       L1DDA
                    leax      >L2042,pcr
                    tfr       x,d
                    lbsr      L14BD
L1DDA               clra
                    clrb
                    pshs      b,a
                    ldd       #$0040
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    ldd       $08,s
                    lbsr      L2AD6
                    leas      $06,s
                    clra
                    clrb
                    std       <u001D
                    leax      >$001B,y
                    stx       $06,s
                    lbra      L1E64
L1DFB               ldd       ,s
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L2DD7
                    std       ,s
                    leax      >$0461,y
                    stx       $04,s
                    bra       L1E59
L1E0F               ldb       [<$04,s]
                    beq       L1E52
                    ldd       $04,s
                    pshs      b,a
                    leax      $0A,s
                    tfr       x,d
                    lbsr      L29D2
                    leas      $02,s
                    clra
                    clrb
                    pshs      b,a
                    leax      $0A,s
                    tfr       x,d
                    lbsr      L0C90
                    leas      $02,s
                    tfr       d,u
                    tfr       u,d
                    std       [<$06,s]
                    ldd       <$26,s
                    beq       L1E3F
                    ldd       #$0001
                    bra       L1E41
L1E3F               clra
                    clrb
L1E41               std       ,u
                    ldd       <u001D
                    addd      #$0001
                    std       <u001D
                    std       <u001F,u
                    leax      <u0023,u
                    stx       $06,s
L1E52               ldd       $04,s
                    addd      #$0020
                    std       $04,s
L1E59               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    lbge      L1E0F
L1E64               ldd       #$0800
                    pshs      b,a
                    leax      >$0461,y
                    pshs      x
                    ldd       $06,s
                    lbsr      L2A85
                    leas      $04,s
                    std       ,s
                    lbgt      L1DFB
                    ldd       $02,s
                    lbsr      L2A0B
                    leas      <$28,s
                    puls      pc,u
L1E86               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    leax      >$0401,y
                    pshs      x
                    leax      >$0441,y
                    tfr       x,d
                    lbsr      L1FE5
                    leas      $02,s
                    std       ,s
                    leax      >L2052,pcr
                    pshs      x
                    ldd       $02,s
                    lbsr      L1FE5
                    leas      $02,s
                    leax      >$0441,y
                    tfr       x,d
                    lbsr      L1F2A
                    leax      >$022E,y
                    tfr       x,d
                    lbsr      L2B41
                    leax      >L205B,pcr
                    pshs      x
                    ldd       $02,s
                    lbsr      L1FE5
                    leas      $02,s
                    std       ,s
                    ldd       <u0033
                    bne       L1EF7
                    leax      >L2062,pcr
                    tfr       x,d
                    lbsr      L1CBD
                    std       -$02,s
                    bne       L1EF7
                    leax      >L2069,pcr
                    pshs      x
                    ldd       $02,s
                    lbsr      L1FE5
                    leas      $02,s
                    leax      >$0441,y
                    tfr       x,d
                    bsr       L1F2A
L1EF7               ldu       <u001B
                    bra       L1F1A
L1EFB               ldd       ,u
                    beq       L1F17
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    pshs      b,a
                    ldd       $02,s
                    lbsr      L1FE5
                    leas      $02,s
                    leax      >$0441,y
                    tfr       x,d
                    bsr       L1F2A
L1F17               ldu       <u0023,u
L1F1A               stu       -$02,s
                    bne       L1EFB
                    leax      >$00A2,y
                    tfr       x,d
                    lbsr      L2B41
                    lbra      L2002
L1F2A               pshs      u
                    tfr       d,u
                    ldd       #$FF62
                    lbsr      L00FD
                    leas      <-$56,s
                    ldd       #$002F
                    pshs      b,a
                    tfr       u,d
                    lbsr      L0D89
                    leas      $02,s
                    addd      #$0001
                    std       $02,s
                    pshs      u
                    leax      $06,s
                    tfr       x,d
                    lbsr      L1FE5
                    leas      $02,s
                    std       ,s
                    ldd       #$0020
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    ldd       <u002D
                    beq       L1F84
                    pshs      u
                    ldd       $02,s
                    lbsr      L1FE5
                    leas      $02,s
                    std       ,s
                    leax      >L2070,pcr
                    pshs      x
                    ldd       $02,s
                    lbsr      L1FE5
                    leas      $02,s
                    lbsr      L0FD9
                    lbsr      L0375
                    bra       L1F98
L1F84               leax      >L2075,pcr
                    pshs      x
                    ldd       $04,s
                    pshs      b,a
                    ldd       $04,s
                    bsr       L1FE5
                    leas      $02,s
                    bsr       L1FE5
                    leas      $02,s
L1F98               leax      $04,s
                    pshs      x
                    leax      >L2077,pcr
                    tfr       x,d
                    lbsr      L1B65
                    leas      $02,s
                    cmpd      #$FFFF
                    bne       L1FB6
                    leax      >L207C,pcr
                    tfr       x,d
                    lbsr      L14BD
L1FB6               leax      <$54,s
                    tfr       x,d
                    lbsr      L2BEC
                    ldd       <$54,s
                    beq       L1FD9
                    lbsr      L121F
                    ldd       >$03BB,y
                    pshs      b,a
                    pshs      u
                    leax      >L208C,pcr
                    tfr       x,d
                    lbsr      L20A5
                    leas      $04,s
L1FD9               ldd       <u002D
                    beq       L1FE0
                    lbsr      L0383
L1FE0               leas      <$56,s
                    puls      pc,u
L1FE5               pshs      u,b,a
                    ldd       #$FFBE
                    lbsr      L00FD
                    ldu       $06,s
L1FEF               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L1FEF
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L2002               leas      $02,s
                    puls      pc,u
L2006               tsta
                    fcb       $55                 U
                    comb
                    lsrb
                    bra       L2054
                    fcb       $41                 A
                    rorb
                    fcb       $45                 E
                    bra       L2058
                    fcb       $52                 R
                    rora
                    lsra
                    fcb       $52                 R
                    rorb
                    bra       L2061
                    fcb       $4E                 N
                    bra       L205E
                    tsta
                    lsra
                    comb
                    bra       L2064
                    rola
                    fcb       $52                 R
                    neg       <u0063
                    clr       $0E,s
                    ror       $09,s
                    asr       $0E,y
                    lsl       -$10,s
                    neg       <u0043
                    oim       #$6E,$07,y
                    lsr       >$206F
                    neg       >$656E
                    bra       L20A1
                    eim       #$6C,-$10,s
                    bra       L20A4
                    rol       $0C,s
                    eim       #u0000,$03,u
                    oim       #$6E,$07,y
                    lsr       >$206F
                    neg       >$656E
                    bra       L2091
                    tsta
                    lsra
                    comb
                    neg       <u002F
                    com       >$7461
                    aim       #$74,>$7570
                    neg       <u002F
                    coma
                    tsta
L205E               lsra
                    comb
                    ble       L2062
L2062               asr       -$0E,s
L2064               ror       $04,s
                    aim       #$76,>$0067
                    aim       #$66,>$6472
                    ror       >$0020
                    blt       L20E6
                    tst       <u0000
L2075               tst       <u0000
L2077               com       $0F,s
                    neg       >$7900
L207C               coma
                    oim       #$6E,$07,y
                    lsr       >$2066
                    clr       -$0E,s
                    tim       #$20,$03,s
                    clr       -$10,s
                    rol       >$000D
                    fcb       $45                 E
                    aim       #$72,>$6F72
                    bra       L20F7
                    clr       -$10,s
                    rol       >$696E
                    asr       -$06,y
                    bra       L20C2
                    com       >$202D
                    bra       L20C7
                    lsr       $0D,x
L20A4               neg       <u0034
                    rora
                    leax      >$0267,y
                    stx       >$0C61,y
                    leax      $06,s
                    pshs      x
                    ldd       $02,s
                    bra       L20C5
                    pshs      u,b,a
                    ldd       ,s
                    std       >$0C61,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L20C5               pshs      b,a
L20C7               leax      >L254B,pcr
                    tfr       x,d
                    bsr       L20F9
                    leas      $04,s
                    bra       L20F5
                    pshs      u,b,a
                    ldd       ,s
                    std       >$0C61,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      b,a
                    leax      >L255C,pcr
                    tfr       x,d
                    bsr       L20F9
                    leas      $04,s
                    clra
                    clrb
                    stb       [>$0C61,y]
                    ldd       ,s
L20F5               leas      $02,s
L20F7               puls      pc,u
L20F9               pshs      u,b,a
                    ldu       $06,s
                    leas      -$0B,s
                    bra       L210B
L2101               ldb       $08,s
                    lbeq      L2328
                    sex
                    jsr       [<$0B,s]
L210B               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L2101
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2D
                    bne       L2130
                    ldd       #$0001
                    std       >$0C77,y
                    ldb       ,u+
                    stb       $08,s
                    bra       L2136
L2130               clra
                    clrb
                    std       >$0C77,y
L2136               ldb       $08,s
                    cmpb      #$30
                    bne       L2141
                    ldd       #$0030
                    bra       L2144
L2141               ldd       #$0020
L2144               std       >$0C79,y
                    bra       L2164
L214A               ldd       $06,s
                    pshs      b,a
                    ldd       #$000A
                    lbsr      L2D01
                    pshs      b,a
                    ldb       $0A,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L2164               ldb       $08,s
                    sex
                    leax      >$032B,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L214A
                    ldb       $08,s
                    cmpb      #$2E
                    bne       L21AD
                    ldd       #$0001
                    std       $04,s
                    bra       L2197
L2181               ldd       $02,s
                    pshs      b,a
                    ldd       #$000A
                    lbsr      L2D01
                    pshs      b,a
                    ldb       $0A,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L2197               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      >$032B,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L2181
                    bra       L21B1
L21AD               clra
                    clrb
                    std       $04,s
L21B1               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L22CB
L21B9               ldd       $06,s
                    pshs      b,a
                    ldx       <$15,s
                    leax      $02,x
                    stx       <$15,s
                    ldd       -$02,x
                    lbsr      L232C
                    lbra      L229B
L21CD               ldd       $06,s
                    pshs      b,a
                    ldx       <$15,s
                    leax      $02,x
                    stx       <$15,s
                    ldd       -$02,x
                    lbsr      L23E7
                    lbra      L229B
L21E1               ldd       $06,s
                    pshs      b,a
                    ldb       $0A,s
                    sex
                    leax      >$032B,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$02
                    pshs      b,a
                    ldx       <$17,s
                    leax      $02,x
                    stx       <$17,s
                    ldd       -$02,x
                    lbsr      L2431
                    lbra      L22B6
L2205               ldd       $06,s
                    pshs      b,a
                    ldx       <$15,s
                    leax      $02,x
                    stx       <$15,s
                    ldd       -$02,x
                    pshs      b,a
                    leax      >$0C63,y
                    tfr       x,d
                    lbsr      L2370
                    lbra      L22B6
L2221               ldd       $04,s
                    bne       L222A
                    ldd       #$0006
                    std       $02,s
L222A               ldd       $06,s
                    pshs      b,a
                    leax      <$15,s
                    pshs      x
                    ldd       $06,s
                    pshs      b,a
                    ldb       $0E,s
                    sex
                    lbsr      L287E
                    leas      $04,s
                    lbra      L229B
L2242               ldx       <$13,s
                    leax      $02,x
                    stx       <$13,s
                    ldd       -$02,x
                    lbra      L22C5
L224F               ldx       <$13,s
                    leax      $02,x
                    stx       <$13,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L2295
                    ldd       $09,s
                    std       $04,s
                    bra       L2271
L2265               ldb       [<$09,s]
                    beq       L227D
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L2271               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L2265
L227D               ldd       $06,s
                    pshs      b,a
                    ldd       $0B,s
                    subd      $06,s
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    ldd       <$11,s
                    lbsr      L249F
                    leas      $06,s
                    bra       L22BF
L2295               ldd       $06,s
                    pshs      b,a
                    ldd       $0B,s
L229B               pshs      b,a
                    bra       L22B8
L229F               ldb       ,u+
                    stb       $08,s
                    bra       L22A7
                    leas      -$0D,x
L22A7               ldd       $06,s
                    pshs      b,a
                    leax      <$15,s
                    pshs      x
                    ldb       $0C,s
                    sex
                    lbsr      L283E
L22B6               std       ,s
L22B8               ldd       $0F,s
                    lbsr      L24F5
                    leas      $04,s
L22BF               lbra      L210B
L22C2               ldb       $08,s
                    sex
L22C5               jsr       [<$0B,s]
                    lbra      L210B
L22CB               cmpx      #$0064
                    lbeq      L21B9
                    cmpx      #$006F
                    lbeq      L21CD
                    cmpx      #$0078
                    lbeq      L21E1
                    cmpx      #$0058
                    lbeq      L21E1
                    cmpx      #$0075
                    lbeq      L2205
                    cmpx      #$0066
                    lbeq      L2221
                    cmpx      #$0065
                    lbeq      L2221
                    cmpx      #$0067
                    lbeq      L2221
                    cmpx      #$0045
                    lbeq      L2221
                    cmpx      #$0047
                    lbeq      L2221
                    cmpx      #$0063
                    lbeq      L2242
                    cmpx      #$0073
                    lbeq      L224F
                    cmpx      #$006C
                    lbeq      L229F
                    bra       L22C2
L2328               leas      $0D,s
                    puls      pc,u
L232C               pshs      u,b,a
                    leas      -$02,s
                    leax      >$0C63,y
                    stx       ,s
                    ldd       $02,s
                    bge       L2363
                    nega
                    negb
                    sbca      #$00
                    std       $02,s
                    std       -$02,s
                    bge       L2358
                    leax      >L2570,pcr
                    pshs      x
                    leax      >$0C63,y
                    tfr       x,d
                    lbsr      L289C
                    leas      $02,s
                    lbra      L242D
L2358               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L2363               ldd       $02,s
                    pshs      b,a
                    ldd       $02,s
                    bsr       L2370
                    leas      $02,s
                    lbra      L2427
L2370               pshs      u,b,a
                    leas      -$06,s
                    ldu       $06,s
                    clra
                    clrb
                    std       $02,s
                    std       ,s
                    bra       L238D
L237E               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      >$024D,y
                    std       $0C,s
L238D               ldd       $0C,s
                    blt       L237E
                    leax      >$024D,y
                    stx       $04,s
                    bra       L23CD
L2399               ldd       ,s
                    addd      #$0001
                    std       ,s
L23A0               ldd       $0C,s
                    subd      [<$04,s]
                    std       $0C,s
                    bge       L2399
                    addd      [<$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L23B7
                    ldd       #$0001
                    std       $02,s
L23B7               ldd       $02,s
                    beq       L23C2
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L23C2               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L23CD               ldd       $04,s
                    cmpd      >$0255,y
                    bne       L23A0
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $06,s
                    leas      $08,s
                    puls      pc,u
L23E7               pshs      u,b,a
                    leas      -$02,s
                    leax      >$0C63,y
                    stx       ,s
                    leau      >$0C6D,y
L23F5               ldd       $02,s
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
                    bne       L23F5
                    bra       L2417
L240D               ldb       ,u
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L2417               leau      -u0001,u
                    pshs      u
                    leax      >$0C6D,y
                    cmpx      ,s++
                    bls       L240D
                    clra
                    clrb
                    stb       [,s]
L2427               leax      >$0C63,y
                    tfr       x,d
L242D               leas      $04,s
                    puls      pc,u
L2431               pshs      u,b,a
                    leas      -$04,s
                    leax      >$0C63,y
                    stx       $02,s
                    leau      >$0C6D,y
L243F               ldd       $04,s
                    clra
                    andb      #$0F
                    std       ,s
                    pshs      b,a
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L2461
                    ldd       $0C,s
                    beq       L2459
                    ldd       #$0041
                    bra       L245C
L2459               ldd       #$0061
L245C               addd      #$FFF6
                    bra       L2464
L2461               ldd       #$0030
L2464               addd      ,s++
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
                    anda      #$0F
                    std       $04,s
                    bne       L243F
                    bra       L2484
L247A               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L2484               leau      -u0001,u
                    pshs      u
                    leax      >$0C6D,y
                    cmpx      ,s++
                    bls       L247A
                    clra
                    clrb
                    stb       [<$02,s]
                    leax      >$0C63,y
                    tfr       x,d
                    leas      $06,s
                    puls      pc,u
L249F               pshs      u,b,a
                    ldu       $06,s
                    ldd       $0A,s
                    subd      $08,s
                    std       $0A,s
                    ldd       >$0C77,y
                    bne       L24CA
                    bra       L24B7
L24B1               ldd       >$0C79,y
                    jsr       [,s]
L24B7               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    bgt       L24B1
                    bra       L24CA
L24C5               ldb       ,u+
                    sex
                    jsr       [,s]
L24CA               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L24C5
                    ldd       >$0C77,y
                    lbeq      L256C
                    bra       L24E6
L24E0               ldd       >$0C79,y
                    jsr       [,s]
L24E6               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    bgt       L24E0
                    lbra      L256C
L24F5               pshs      u,b,a
                    ldu       $06,s
                    ldd       $08,s
                    pshs      b,a
                    tfr       u,d
                    lbsr      L2889
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       $08,s
                    ldd       >$0C77,y
                    bne       L252B
                    bra       L2518
L2512               ldd       >$0C79,y
                    jsr       [,s]
L2518               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L2512
                    bra       L252B
L2526               ldb       ,u+
                    sex
                    jsr       [,s]
L252B               ldb       ,u
                    bne       L2526
                    ldd       >$0C77,y
                    beq       L256C
                    bra       L253D
L2537               ldd       >$0C79,y
                    jsr       [,s]
L253D               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L2537
                    bra       L256C
L254B               pshs      u,b,a
                    ldd       >$0C61,y
                    pshs      b,a
                    ldd       $02,s
                    lbsr      L2577
                    leas      $02,s
                    bra       L256C
L255C               pshs      u,b,a
                    ldd       ,s
                    ldx       >$0C61,y
                    leax      $01,x
                    stx       >$0C61,y
                    stb       -$01,x
L256C               leas      $02,s
                    puls      pc,u
L2570               blt       L25A5
                    leas      -$09,y
                    pshu      y,x,dp
                    neg       <u0034
                    rora
                    ldu       $06,s
                    ldd       u0006,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L2599
                    ldd       u0006,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      L2670
                    tfr       u,d
                    lbsr      L27B2
L2599               ldd       u0006,u
                    clra
                    andb      #$04
                    beq       L25D5
                    ldd       #$0001
                    pshs      b,a
L25A5               leax      $03,s
                    pshs      x
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L25B6
                    leax      >L2AC2,pcr
                    bra       L25BA
L25B6               leax      >L2AAD,pcr
L25BA               tfr       x,d
                    tfr       d,x
                    ldd       u0008,u
                    jsr       ,x
                    leas      $04,s
                    cmpd      #$FFFF
                    lbne      L268F
                    ldd       u0006,u
                    orb       #$20
                    std       u0006,u
                    lbra      L2670
L25D5               ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L25E3
                    tfr       u,d
                    lbsr      L26C3
L25E3               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       ,s
                    stb       ,x
                    ldd       ,u
                    cmpd      u0004,u
                    bcc       L260D
                    ldd       u0006,u
                    clra
                    andb      #$40
                    lbeq      L268F
                    ldd       ,s
                    cmpd      #$000D
                    lbne      L268F
L260D               tfr       u,d
                    lbsr      L26C3
                    std       -$02,s
                    lbne      L2670
                    lbra      L268F
                    pshs      u
                    tfr       d,u
                    ldd       $04,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0008
                    lbsr      L2DE3
                    lbsr      L2577
                    leas      $02,s
                    ldd       $04,s
                    pshs      b,a
                    tfr       u,d
                    lbsr      L2577
                    lbra      L2691
L263C               pshs      u,b,a
                    leau      >$025A,y
                    clra
                    clrb
                    std       ,s
                    bra       L264E
L2648               tfr       u,d
                    leau      u000D,u
                    bsr       L2660
L264E               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L2648
                    bra       L2691
L2660               pshs      u
                    tfr       d,u
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L2670
                    ldd       u0006,u
                    bne       L2675
L2670               ldd       #$FFFF
                    bra       L2691
L2675               ldd       u0006,u
                    clra
                    andb      #$02
                    beq       L2682
                    tfr       u,d
                    bsr       L2695
                    bra       L2684
L2682               clra
                    clrb
L2684               std       ,s
                    ldd       u0008,u
                    lbsr      L2A0B
                    clra
                    clrb
                    std       u0006,u
L268F               ldd       ,s
L2691               leas      $02,s
                    puls      pc,u
L2695               pshs      u
                    tfr       d,u
                    cmpu      #$0000
                    beq       L26AA
                    ldd       u0006,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L26AF
L26AA               ldd       #$FFFF
                    puls      pc,u
L26AF               ldd       u0006,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L26BD
                    tfr       u,d
                    lbsr      L27B2
L26BD               tfr       u,d
                    bsr       L26C3
                    puls      pc,u
L26C3               pshs      u
                    tfr       d,u
                    leas      -$04,s
                    ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L26F1
                    ldd       ,u
                    cmpd      u0004,u
                    beq       L26F1
                    clra
                    clrb
                    pshs      b,a
                    tfr       u,d
                    lbsr      L2779
                    ldd       $02,x
                    pshs      b,a
                    ldd       ,x
                    pshs      b,a
                    ldd       u0008,u
                    lbsr      L2AD6
                    leas      $06,s
L26F1               ldd       ,u
                    subd      u0002,u
                    std       $02,s
                    lbeq      L2765
                    ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L2765
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L273E
                    ldd       u0002,u
                    bra       L2736
L2711               ldd       $02,s
                    pshs      b,a
                    ldd       ,u
                    pshs      b,a
                    ldd       u0008,u
                    lbsr      L2AC2
                    leas      $04,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L272C
                    leax      $04,s
                    bra       L2754
L272C               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L2736               std       ,u
                    ldd       $02,s
                    bne       L2711
                    bra       L2765
L273E               ldd       $02,s
                    pshs      b,a
                    ldd       u0002,u
                    pshs      b,a
                    ldd       u0008,u
                    lbsr      L2AAD
                    leas      $04,s
                    cmpd      $02,s
                    beq       L2765
                    bra       L2756
L2754               leas      -$04,x
L2756               ldd       u0006,u
                    orb       #$20
                    std       u0006,u
                    ldd       u0004,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L2775
L2765               ldd       u0006,u
                    ora       #$01
                    std       u0006,u
                    ldd       u0002,u
                    std       ,u
                    addd      u000B,u
                    std       u0004,u
                    clra
                    clrb
L2775               leas      $04,s
                    puls      pc,u
L2779               pshs      u
                    puls      pc,u
L277D               pshs      u,b,a
                    ldd       ,s
                    leax      >$032B,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$04
                    beq       L27AC
                    ldd       ,s
                    clra
                    andb      #$DF
                    bra       L27AE
L2795               pshs      u,b,a
                    ldd       ,s
                    leax      >$032B,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$02
                    beq       L27AC
                    ldd       ,s
                    orb       #$20
                    bra       L27AE
L27AC               ldd       ,s
L27AE               leas      $02,s
                    puls      pc,u
L27B2               pshs      u
                    tfr       d,u
                    ldd       #$FF98
                    lbsr      L00FD
                    ldd       u0006,u
                    clra
                    andb      #$C0
                    bne       L27EA
                    leas      <-$22,s
                    leax      ,s
                    pshs      x
                    ldd       u0008,u
                    lbsr      L2C62
                    leas      $02,s
                    ldd       u0006,u
                    pshs      b,a
                    ldb       $02,s
                    bne       L27DE
                    ldd       #$0040
                    bra       L27E1
L27DE               ldd       #$0080
L27E1               ora       ,s+
                    orb       ,s+
                    std       u0006,u
                    leas      <$22,s
L27EA               ldd       u0006,u
                    ora       #$80
                    std       u0006,u
                    clra
                    andb      #$0C
                    beq       L27F7
                    puls      pc,u
L27F7               ldd       u000B,u
                    bne       L280C
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L2807
                    ldd       #$0080
                    bra       L280A
L2807               ldd       #$0100
L280A               std       u000B,u
L280C               ldd       u0002,u
                    bne       L281D
                    ldd       u000B,u
                    lbsr      L2BB7
                    std       u0002,u
                    cmpd      #$FFFF
                    beq       L2825
L281D               ldd       u0006,u
                    orb       #$08
                    std       u0006,u
                    bra       L2834
L2825               ldd       u0006,u
                    orb       #$04
                    std       u0006,u
                    leax      u000A,u
                    stx       u0002,u
                    ldd       #$0001
                    std       u000B,u
L2834               ldd       u0002,u
                    addd      u000B,u
                    std       u0004,u
                    std       ,u
                    puls      pc,u
L283E               pshs      u,b,a
                    ldb       $01,s
                    sex
                    tfr       d,x
                    bra       L2864
L2847               ldd       [<$06,s]
                    addd      #$0004
                    std       [<$06,s]
                    leax      >L287D,pcr
                    bra       L2860
L2856               ldb       $01,s
                    stb       >$0258,y
                    leax      >$0257,y
L2860               tfr       x,d
                    bra       L2879
L2864               cmpx      #$0064
                    beq       L2847
                    cmpx      #$006F
                    lbeq      L2847
                    cmpx      #$0078
                    lbeq      L2847
                    bra       L2856
L2879               leas      $02,s
                    puls      pc,u
L287D               neg       <u0034
                    nega
                    leax      >L2888,pcr
                    tfr       x,d
                    puls      pc,u
L2888               neg       <u0034
                    rora
                    ldu       ,s
L288D               ldb       ,u+
                    bne       L288D
                    tfr       u,d
                    subd      ,s
                    addd      #$FFFF
                    leas      $02,s
                    puls      pc,u
L289C               pshs      u,b,a
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L28A6               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L28A6
                    bra       L28DB
L28B4               pshs      u,b,a
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L28BE               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L28BE
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L28CF               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L28CF
L28DB               ldd       $02,s
                    leas      $04,s
                    puls      pc,u
L28E1               pshs      u
                    tfr       d,u
                    bra       L28F7
L28E7               ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       -$01,x
                    bne       L28F5
                    clra
                    clrb
                    puls      pc,u
L28F5               leau      u0001,u
L28F7               ldb       ,u
                    sex
                    pshs      b,a
                    ldb       [<$06,s]
                    sex
                    cmpd      ,s++
                    beq       L28E7
                    sex
                    pshs      b,a
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u
                    pshs      u,b,a
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L2919               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    ble       L293D
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2919
                    bra       L293D
L2933               clra
                    clrb
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L293D               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    bgt       L2933
                    lbra      L29CC
                    pshs      u
                    tfr       d,u
                    bra       L2962
L2952               ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       -$01,x
                    bne       L2960
                    clra
                    clrb
                    puls      pc,u
L2960               leau      u0001,u
L2962               ldd       $06,s
                    addd      #$FFFF
                    std       $06,s
                    subd      #$FFFF
                    ble       L297C
                    ldb       ,u
                    sex
                    pshs      b,a
                    ldb       [<$06,s]
                    sex
                    cmpd      ,s++
                    beq       L2952
L297C               ldd       $06,s
                    bge       L2984
                    clra
                    clrb
                    bra       L298F
L2984               ldb       [<$04,s]
                    sex
                    pshs      b,a
                    ldb       ,u
                    sex
                    subd      ,s++
L298F               puls      pc,u
                    pshs      u,b,a
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L299B               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L299B
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L29AC               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    ble       L29C4
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L29AC
L29C4               ldd       $0A,s
                    bge       L29CC
                    clra
                    clrb
                    stb       [,s]
L29CC               ldd       $02,s
                    leas      $04,s
                    puls      pc,u
L29D2               pshs      u,b,a
                    ldu       ,s
L29D6               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
                    bgt       L29D6
                    ldb       -u0001,u
                    clra
                    andb      #$7F
                    stb       -u0001,u
                    clra
                    clrb
                    stb       ,u
                    ldd       ,s
                    leas      $02,s
                    puls      pc,u
                    tfr       d,x
                    lda       $03,s
                    os9       I$Open
                    bcc       L2A0D
                    bra       L2A10
L29FE               tfr       d,x
                    lda       $03,s
                    os9       I$Open
                    bcs       L2A5F
                    tfr       a,b
                    clra
                    rts
L2A0B               tfr       b,a
L2A0D               os9       I$Close
L2A10               lbra      L2CD5
L2A13               tfr       d,x
                    ldb       $03,s
                    os9       I$MakDir
                    bra       L2A10
L2A1C               pshs      b,a
                    ldx       ,s
                    lda       $05,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0B
                    os9       I$Create
                    bcs       L2A33
L2A2D               leas      $02,s
                    tfr       a,b
                    clra
                    rts
L2A33               cmpb      #$DA
                    bne       L2A5D
                    lda       $05,s
                    bita      #$80
                    bne       L2A5D
                    anda      #$07
                    ldx       ,s
                    os9       I$Open
                    bcs       L2A5D
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L2A2D
                    pshs      b
                    os9       I$Close
                    puls      b
L2A5D               leas      $02,s
L2A5F               lbra      L2CCC
                    tfr       d,x
                    lda       $03,s
                    ldb       $05,s
                    os9       I$Create
                    lbcs      L2CCC
                    tfr       a,b
                    clra
                    rts
L2A73               tfr       d,x
                    os9       I$Delete
                    bra       L2A10
L2A7A               tfr       b,a
                    os9       I$Dup
                    bcs       L2A5F
                    tfr       a,b
                    clra
                    rts
L2A85               pshs      y
                    tfr       b,a
                    ldx       $04,s
                    ldy       $06,s
                    os9       I$Read
                    bcc       L2AA9
L2A93               cmpb      #$D3
                    bne       L2ABD
                    clra
                    clrb
                    puls      pc,y
L2A9B               pshs      y
                    tfr       b,a
                    ldx       $04,s
                    ldy       $06,s
                    os9       I$ReadLn
                    bcs       L2A93
L2AA9               tfr       y,d
                    puls      pc,y
L2AAD               pshs      y
                    ldy       $06,s
                    beq       L2AD2
                    tfr       b,a
                    ldx       $04,s
                    os9       I$Write
                    bcc       L2AD2
L2ABD               puls      y
                    lbra      L2CCC
L2AC2               pshs      y
                    ldy       $06,s
                    beq       L2AD2
                    tfr       b,a
                    ldx       $04,s
                    os9       I$WritLn
                    bcs       L2ABD
L2AD2               tfr       y,d
                    puls      pc,y
L2AD6               pshs      u,b,a
                    ldd       $0A,s
                    bne       L2AE4
                    ldu       #$0000
                    ldx       #$0000
                    bra       L2B1A
L2AE4               cmpd      #$0001
                    beq       L2B11
                    cmpd      #$0002
                    beq       L2B06
                    ldb       #$F7
L2AF2               clra
                    std       >$03BB,y
                    ldd       #$FFFF
                    leax      >$03AF,y
                    std       ,x
                    std       $02,x
                    leas      $02,s
                    puls      pc,u
L2B06               lda       $01,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L2AF2
                    bra       L2B1A
L2B11               lda       $01,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L2AF2
L2B1A               tfr       u,d
                    addd      $08,s
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L2AF2
                    tfr       d,x
                    stx       >$03AF,y
                    stu       >$03B1,y
                    lda       $01,s
                    os9       I$Seek
                    bcs       L2AF2
                    leax      >$03AF,y
                    leas      $02,s
                    puls      pc,u
L2B41               tfr       d,x
                    lda       #$01
L2B45               os9       I$ChgDir
                    lbra      L2CD5
                    tfr       d,x
                    lda       #$04
                    bra       L2B45
L2B51               pshs      y,b,a
                    cmpd      >$0C7B,y
                    bls       L2B88
                    subd      >$0C7B,y
                    addd      >$03AD,y
                    subd      $02,s
                    os9       F$Mem
                    tfr       y,d
                    ldy       $02,s
                    bcc       L2B74
                    ldd       #$FFFF
                    leas      $04,s
                    rts
L2B74               ldx       >$03AD,y
                    std       >$03AD,y
                    pshs      x
                    subd      ,s++
                    addd      >$0C7B,y
                    std       >$0C7B,y
L2B88               ldd       >$03AD,y
                    subd      >$0C7B,y
                    tfr       d,x
                    ldd       >$0C7B,y
                    subd      ,s
                    std       >$0C7B,y
                    ldd       ,s
                    stx       ,s
                    bitb      #$01
                    beq       L2BA7
                    clr       ,x+
                    decb
L2BA7               tfr       d,y
                    leay      ,y
                    beq       L2BB5
                    clra
                    clrb
L2BAF               std       ,x++
                    leay      -$02,y
                    bne       L2BAF
L2BB5               puls      pc,y,b,a
L2BB7               addd      >$03B7,y
                    bcs       L2BDE
                    cmpd      >$03B9,y
                    bcc       L2BDE
                    pshs      b,a
                    ldx       >$03B7,y
                    clra
                    bra       L2BCF
L2BCD               sta       ,x+
L2BCF               cmpx      ,s
                    bcs       L2BCD
                    ldd       >$03B7,y
                    puls      x
                    stx       >$03B7,y
                    rts
L2BDE               ldd       #$FFFF
                    rts
                    tfr       b,a
                    ldb       $03,s
                    os9       F$Send
                    lbra      L2CD5
L2BEC               tfr       d,x
                    clra
                    clrb
                    os9       F$Wait
                    lbcs      L2CCC
                    stx       -$02,s
                    beq       L2BFF
                    stb       $01,x
                    clr       ,x
L2BFF               tfr       a,b
                    clra
                    rts
                    tfr       b,a
                    ldb       $03,s
                    os9       F$SPrior
                    lbra      L2CD5
                    leau      $02,s
                    leas      >$00FF,y
                    tfr       d,x
                    ldy       ,u
                    lda       u0005,u
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       u0007,u
                    ldb       u0009,u
                    ldu       u0002,u
                    os9       F$Chain
                    os9       F$Exit
L2C2A               pshs      u,y
                    tfr       d,x
                    ldy       $06,s
                    ldu       $08,s
                    lda       $0B,s
                    ora       $0D,s
                    ldb       $0F,s
                    os9       F$Fork
                    puls      u,y
                    lbcs      L2CCC
                    tfr       a,b
                    clra
                    rts
L2C46               pshs      u
                    tfr       y,u
                    std       >$0C7D,y
                    leax      >L2C5A,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      L2CD5
L2C5A               tfr       u,y
                    clra
                    jsr       [>$0C7D,y]
                    rti
L2C62               tfr       b,a
                    ldb       #$00
                    ldx       $02,s
                    os9       I$GetStt
                    lbra      L2CD5
L2C6E               lda       $03,s
                    tstb
                    beq       L2CA0
                    cmpb      #$01
                    beq       L2CA2
                    cmpb      #$06
                    beq       L2CA2
                    cmpb      #$02
                    beq       L2C88
                    cmpb      #$05
                    beq       L2C88
                    ldb       #$D0
                    lbra      L2CCC
L2C88               pshs      u
                    os9       I$GetStt
                    bcc       L2C94
                    puls      u
                    lbra      L2CCC
L2C94               stx       [<$06,s]
                    ldx       $06,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts
L2CA0               ldx       $04,s
L2CA2               os9       I$GetStt
                    lbra      L2CD5
L2CA8               lda       $03,s
                    tstb
                    beq       L2CB6
                    cmpb      #$02
                    beq       L2CBE
                    ldb       #$D0
                    lbra      L2CCC
L2CB6               ldx       $04,s
                    os9       I$SetStt
                    lbra      L2CD5
L2CBE               pshs      u
                    ldx       $06,s
                    ldu       $08,s
                    os9       I$SetStt
                    puls      u
                    lbra      L2CD5
L2CCC               clra
                    std       >$03BB,y
                    ldd       #$FFFF
                    rts
L2CD5               bcs       L2CCC
                    clra
                    clrb
                    rts
L2CDA               pshs      b,a
                    lbsr      L2CE7
                    lbsr      L263C
                    puls      b,a
L2CE4               os9       F$Exit
L2CE7               rts
L2CE8               leax      >$03AF,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    leax      >$03AF,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
                    rts
L2D01               tsta
                    bne       L2D16
                    tst       $02,s
                    bne       L2D16
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,b,a
L2D16               pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      b,a
                    lda       $05,s
                    ldb       $09,s
                    mul
                    std       $02,s
                    lda       $05,s
                    ldb       $08,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L2D33
                    inc       ,s
L2D33               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L2D40
                    inc       ,s
L2D40               lda       $04,s
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
                    subd      #$0000
                    beq       L2D63
                    pshs      b,a
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    bra       L2D91
L2D63               puls      b,a
                    std       ,s
                    ldd       #$002D
                    lbra      L2E06
L2D6D               subd      #$0000
                    beq       L2D63
                    pshs      b,a
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    tsta
                    bpl       L2D85
                    nega
                    negb
                    sbca      #$00
                    inc       $01,s
                    std       $02,s
L2D85               ldd       $06,s
                    bpl       L2D91
                    nega
                    negb
                    sbca      #$00
                    com       $01,s
                    std       $06,s
L2D91               lda       #$01
L2D93               inca
                    lsl       $03,s
                    rol       $02,s
                    bpl       L2D93
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
L2DA2               subd      $02,s
                    bcc       L2DAC
                    addd      $02,s
                    andcc     #$FE
                    bra       L2DAE
L2DAC               orcc      #$01
L2DAE               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       L2DA2
                    std       $02,s
                    tst       $01,s
                    beq       L2DC8
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L2DC8               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
                    leas      $06,s
                    rts
L2DD7               tstb
                    beq       L2DED
L2DDA               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L2DDA
                    bra       L2DED
L2DE3               tstb
                    beq       L2DED
L2DE6               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L2DE6
L2DED               ldd       $02,s
                    pshs      b,a
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts
                    tstb
                    beq       L2DED
L2DFD               lsl       $03,s
                    rol       $02,s
                    decb
                    bne       L2DFD
                    bra       L2DED
L2E06               std       >$03BB,y
                    pshs      y,b
                    os9       F$ID
                    puls      y,b
                    os9       F$Send
                    rts
L2E15               neg       <u000D
                    neg       <u002D
                    fcb       $3E                 >
                    neg       <u0020
                    bra       L2E1E
L2E1E               orcc      #$53
                    orcc      #$5A
                    orcc      #$61
                    com       <u002E
                    tsta
                    clra
                    lsra
                    fcb       $55                 U
                    inca
                    fcb       $45                 E
                    comb
                    neg       <u0048
                    fcb       $45                 E
                    inca
                    negb
                    neg       <u002E
                    lsra
                    lsra
                    neg       <u002F
                    lsra
                    leax      $00,x
                    bgt       L2E86
                    clra
                    neg       <u002E
                    lsr       -$0E,s
                    neg       <u002E
                    tst       $0E,s
                    neg       <u002E
                    lsl       -$10,s
                    neg       <u002E
                    bgt       L2E4E
L2E4E               lsrb
                    lsla
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $45                 E
                    bra       L2E96
                    fcb       $52                 R
                    fcb       $45                 E
                    bra       L2EAC
                    lsrb
                    rola
                    inca
                    inca
                    bra       L2EAC
                    clra
                    fcb       $52                 R
                    fcb       $45                 E
                    neg       <u0041
                    fcb       $52                 R
                    fcb       $45                 E
                    bra       L2EC1
                    clra
                    fcb       $55                 U
                    bra       L2EBF
                    fcb       $55                 U
                    fcb       $52                 R
                    fcb       $45                 E
                    bra       L2E99
                    rolb
                    ble       L2EC2
                    bvs       L2E96
                    swi
                    fcb       $00
                    bra       L2EA7
                    blt       L2EA9
                    blt       L2EAB
                    blt       L2EAD
                    blt       L2EAF
                    blt       L2EB1
                    blt       L2EB3
L2E86               blt       L2EB5
                    blt       L2EB7
                    blt       L2EB9
                    blt       L2EBB
                    blt       L2EBD
                    blt       L2EBF
                    blt       L2EC1
                    blt       L2EC3
L2E96               blt       L2E98
L2E98               tsta
L2E99               bra       L2EC8
                    bra       L2EEA
                    clra
                    fcb       $52                 R
                    fcb       $45                 E
                    bra       L2EC2
                    bra       L2EC4
                    coma
                    bra       L2ED4
L2EA7               bra       L2EEC
L2EA9               clra
                    fcb       $4E                 N
L2EAB               lsrb
L2EAC               rola
L2EAD               fcb       $4E                 N
                    fcb       $55                 U
L2EAF               fcb       $45                 E
                    neg       <u0020
                    lsla
L2EB3               rola
                    lsrb
L2EB5               bra       L2EF8
L2EB7               fcb       $4E                 N
                    rolb
L2EB9               bra       L2F06
L2EBB               fcb       $45                 E
                    rolb
L2EBD               bra       L2F13
L2EBF               clra
                    bra       L2F05
L2EC2               clra
L2EC3               fcb       $4E                 N
L2EC4               lsrb
                    rola
                    fcb       $4E                 N
                    fcb       $55                 U
L2EC8               fcb       $45                 E
                    neg       <u0042
                    fcb       $55                 U
                    rola
                    inca
                    lsra
                    rola
                    fcb       $4E                 N
                    asra
                    bra       L2F18
L2ED4               fcb       $45                 E
                    comb
                    coma
                    fcb       $52                 R
                    rola
                    negb
                    lsrb
                    clra
                    fcb       $52                 R
                    bra       L2F2B
                    rola
                    comb
                    lsrb
                    neg       <u002E
                    bgt       L2F14
                    bgt       L2F08
                    negb
                    inca
L2EEA               fcb       $45                 E
                    fcb       $41                 A
L2EEC               comb
                    fcb       $45                 E
                    bra       L2F47
                    fcb       $41                 A
                    rola
                    lsrb
                    neg       <u0042
                    fcb       $55                 U
                    rola
                    inca
L2EF8               lsra
                    rola
                    fcb       $4E                 N
                    asra
                    bra       L2F40
                    clra
                    clra
                    lsrb
                    bra       L2F4F
                    rola
                    comb
L2F05               lsrb
L2F06               neg       <u0047
L2F08               fcb       $45                 E
                    fcb       $4E                 N
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $41                 A
                    lsrb
                    rola
                    fcb       $4E                 N
                    asra
                    bra       L2F61
L2F13               fcb       $45                 E
L2F14               asrb
                    bra       L2F59
                    clra
L2F18               clra
                    lsrb
                    neg       <u0050
                    inca
                    fcb       $41                 A
                    coma
                    fcb       $45                 E
                    bra       L2F70
                    fcb       $45                 E
                    asrb
                    bra       L2F6A
                    rola
                    comb
                    fcb       $4B                 K
                    bra       L2F74
L2F2B               fcb       $4E                 N
                    bra       L2F2E
L2F2E               coma
                    fcb       $52                 R
                    fcb       $45                 E
                    fcb       $41                 A
                    lsrb
                    rola
                    fcb       $4E                 N
                    asra
                    bra       L2F86
                    fcb       $45                 E
                    asrb
                    bra       L2F8F
                    rolb
                    comb
                    lsrb
                    fcb       $45                 E
L2F40               tsta
                    bra       L2F87
                    rola
                    comb
                    fcb       $4B                 K
                    neg       <u0044
                    fcb       $45                 E
                    comb
                    lsrb
                    rola
                    fcb       $4E                 N
                    fcb       $41                 A
                    lsrb
L2F4F               rola
                    clra
                    fcb       $4E                 N
                    bra       L2F91
                    bra       L2FA4
                    fcb       $45                 E
                    asrb
                    bra       L2F9E
                    rola
                    comb
                    fcb       $4B                 K
                    neg       <u0020
                    bra       L2FB4
L2F61               clra
                    fcb       $55                 U
                    fcb       $52                 R
                    coma
                    fcb       $45                 E
                    bra       L2FA5
                    bra       L2FAD
L2F6A               clra
                    fcb       $4E                 N
                    rora
                    rola
                    asra
                    bra       L2FB5
                    rola
                    comb
                    fcb       $4B                 K
L2F74               neg       <u0053
                    clra
                    fcb       $55                 U
                    fcb       $52                 R
                    coma
                    fcb       $45                 E
                    bra       L2FBA
                    bra       L2FCE
                    comb
                    rts
                    bra       L2FD6
                    rolb
                    comb
                    lsrb
L2F86               fcb       $45                 E
L2F87               tsta
                    bra       L2FCE
                    rola
                    comb
                    fcb       $4B                 K
                    neg       <u0015
L2F8F               andcc     #$15
L2F91               bls       L2FA8
                    fcb       $3E                 >
                    fcb       $15
                    fcb       $5E                 ^
                    fcb       $15
                    aim       #$15,>$8F15
                    lda       -$0B,x
                    jsr       >$15CE
                    fcb       $15
                    addd      -$0B,x
                    ldu       >$1619
                    lbra      L5BBF
                    fcb       $3E                 >
                    lbra      L85C3
L2FAD               clr       -$0A,x
                    jmp       >$1692
                    lbra      LD4CB
L2FB5               jsr       >$16D5
                    lbra      L1CD2
                    eim       #$17,<u0019
                    lbsr      L5FD8
                    mul
                    lbsr      L7A27
                    clr       $0F,s
                    lsr       >$6C69
                    com       >$7400
                    orcc      #$6C
                    orcc      #$72
                    orcc      #$78
                    orcc      #$7D
                    neg       <u0000
                    coma
                    tsta
                    lsra
                    comb
                    neg       <u0043
                    oim       #$6E,$07,y
                    lsr       >$206D
                    oim       #$6B,$05,s
                    bra       L302B
                    tsta
                    lsra
                    comb
                    bra       L3051
                    rol       -$0E,s
                    eim       #$63,-$0C,s
                    clr       -$0E,s
                    rol       >$0027
                    fcb       $10
                    com       <u00E8
                    neg       <u0064
                    neg       <u000A
                    aim       #$55,<u006C
                    lsl       >$0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    oim       #$00,<u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    aim       #$00,<u0001
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    fcb       $42                 B
                    neg       <u0002
                    neg       <u0000
                    neg       <u0000
L302B               neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
L3051               neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0000
                    neg       <u0001
                    oim       #$01,<u0001
                    oim       #$01,<u0001
                    oim       #$01,<u0011
                    fcb       $11
                    oim       #$11,<u0011
                    oim       #$01,<u0001
                    oim       #$01,<u0001
                    oim       #$01,<u0001
                    oim       #$01,<u0001
                    oim       #$01,<u0001
                    oim       #$01,<u0001
                    leax      $00,y
                    bra       L3118
                    bra       L311A
                    bra       L311C
                    bra       L311E
                    bra       L3120
                    bra       L3122
                    bra       L3124
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    bra       L3130
                    bra       L3132
                    bra       L3134
                    bra       L3158
                    fcb       $42                 B
                    fcb       $42                 B
L3118               fcb       $42                 B
                    fcb       $42                 B
L311A               fcb       $42                 B
                    aim       #$02,<u0002
L311E               aim       #$02,<u0002
                    aim       #$02,<u0002
L3124               aim       #$02,<u0002
                    aim       #$02,<u0002
                    aim       #$02,<u0002
                    aim       #$02,<u0020
L3130               bra       L3152
L3132               bra       L3154
L3134               bra       L317A
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    lsr       <u0004
                    lsr       <u0004
                    lsr       <u0004
                    lsr       <u0004
                    lsr       <u0004
                    lsr       <u0004
                    lsr       <u0004
                    lsr       <u0004
                    lsr       <u0004
                    lsr       <u0004
                    bra       L3171
                    bra       L3173
                    oim       #$00,<u0022
                    neg       <u0009
L3158               neg       <u0007
                    aim       #$2A,<u0002
                    bvc       L3161
                    bne       L3163
L3161               bcc       L3164
L3163               stu       $01,x
                    std       $01,x
                    addb      $01,x
                    adcb      $01,x
                    stb       $01,x
                    bitb      $00,x
                    tim       #$01,<u00FD
                    oim       #$FB,<u0001
                    adcb      >$01F7
                    oim       #$F5,<u0001
                    addd      >$01F1
                    aim       #$0B,<u0002
                    rol       <u0002
                    asr       <u0002
                    eim       #$02,<u0003
                    aim       #$01,<u0001
                    stu       >$0219
                    aim       #$17,<u0002
                    fcb       $15
                    aim       #$13,<u0002
                    fcb       $11
                    aim       #$0F,<u0002
                    tst       <u0000
                    oim       #$02,<u0055
                    com       $0F,s
                    jmp       $06,s
                    rol       $07,s
                    fcb       $00

                    emod
eom                 equ       *
                    end
