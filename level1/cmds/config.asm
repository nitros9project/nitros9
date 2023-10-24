********************************************************************
* Config - Boot configurator
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      ????/??/??  ???
* From Tandy OS-9 Level One VR 02.00.00.
*
*   5      ????/??/?/  ???
* Changed /D0 references to /DD

                    nam       Config
                    ttl       Boot configurator

* Disassembled 02/07/22 07:36:55 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       5

L0000               mod       eom,name,tylg,atrv,start,size

u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       1
u0005               rmb       2
u0007               rmb       2
u0009               rmb       1
u000A               rmb       3
u000D               rmb       2
u000F               rmb       2
u0011               rmb       14
u001F               rmb       1
u0020               rmb       1
u0021               rmb       2
u0023               rmb       6
u0029               rmb       2
u002B               rmb       2
u002D               rmb       1
u002E               rmb       1
u002F               rmb       2
u0031               rmb       1
u0032               rmb       1
u0033               rmb       1
u0034               rmb       1
u0035               rmb       2
u0037               rmb       2
u0039               rmb       2
u003B               rmb       2
u003D               rmb       2
u003F               rmb       2
u0041               rmb       1
u0042               rmb       1
u0043               rmb       1
u0044               rmb       1
u0045               rmb       2
u0047               rmb       1
u0048               rmb       1
u0049               rmb       2
u004B               rmb       2
u004D               rmb       2
u004F               rmb       1
u0050               rmb       1
u0051               rmb       1
u0052               rmb       1
u0053               rmb       1
u0054               rmb       3
u0057               rmb       4
u005B               rmb       8
u0063               rmb       1
u0064               rmb       11
u006F               rmb       4
u0073               rmb       25
u008C               rmb       2
u008E               rmb       86
u00E4               rmb       21
u00F9               rmb       1168
u0589               rmb       1084
size                equ       .

name                fcs       /config/
                    fcb       edition

L0014               lda       ,y+
                    sta       ,u+
                    leax      -$01,x
                    bne       L0014
                    rts

start               pshs      y
                    pshs      u
                    clra
                    clrb
L0023               sta       ,u+
                    decb
                    bne       L0023
                    ldx       ,s
                    leau      ,x
                    leax      >$0645,x
                    pshs      x
                    leay      >L2918,pcr
                    ldx       ,y++
                    beq       L003E
                    bsr       L0014
                    ldu       $02,s
L003E               leau      >u008E,u
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
                    stx       >u0589,u
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
                    lbsr      L018D
                    clra
                    clrb
                    lbsr      L2844
L00E8               leax      >$0645,y
                    stx       >$0593,y
                    sts       >$0587,y
                    sts       >$0595,y
                    ldd       #$FF82
L00FD               leax      d,s
                    cmpx      >$0595,y
                    bcc       L010F
                    cmpx      >$0593,y
                    bcs       L0129
                    stx       >$0595,y
L010F               rts
L0110               fcc       "**** STACK OVERFLOW ****"
                    fcb       C$CR
L0129               leax      <L0110,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
L0136               os9       I$WritLn
                    clra
                    puls      b
L013C               lbsr      L284E
                    ldd       >$0587,y
                    subd      >$0595,y
                    rts
                    ldd       >$0595,y
                    subd      >$0593,y
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
                    bne       L0189
                    lbsr      L12C9
                    lbsr      L0258
                    lbsr      L197A
                    ldd       ,s
                    lbsr      L2844
L0189               leas      $02,s
                    puls      pc,u
L018D               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    bsr       L01B9
                    lbsr      L07BB
                    lbsr      L071D
                    lbsr      L02D1
                    lbsr      L03F9
                    lbsr      L1709
                    lbsr      L19FB
                    lbsr      L1B13
                    lbsr      L12C9
                    lbsr      L0258
                    clra
                    clrb
                    lbsr      L2844
                    puls      pc,u
L01B9               pshs      u
                    ldd       #$FFB4
                    lbsr      L00FD
                    leas      -$04,s
                    leax      >$05BB,y
                    stx       $02,s
                    leax      >$0599,y
                    pshs      x
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L2574
                    leas      $04,s
                    ldd       $02,s
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L2574
                    leas      $04,s
                    clra
                    clrb
                    ldx       $02,s
                    stb       $05,x
                    stb       $04,x
                    pshs      x,b,a
                    lbsr      L25AE
                    leas      $04,s
                    leax      >L016B,pcr
                    tfr       x,d
                    lbsr      L281A
                    bsr       L0244
                    std       ,s
                    ldx       ,s
                    bra       L021A
L0205               ldd       #$0018
                    std       <u004B
                    ldd       #$0012
                    bra       L0216
L020F               clra
                    clrb
                    std       <u004B
                    ldd       #$000A
L0216               std       <u004D
                    bra       L0227
L021A               cmpx      #$0050
                    beq       L0205
                    cmpx      #$0020
                    beq       L020F
                    lbra      L020F
L0227               lbsr      L12C9
                    clra
                    clrb
                    lbsr      L12A0
                    lbsr      L0C28
                    bsr       L026A
                    std       <u0047
                    lbsr      L12C9
                    ldd       #$0005
                    std       <u003D
                    lbsr      L0DC6
                    lbra      L02CD
L0244               pshs      y
                    lda       #$01
                    ldb       #$26
                    os9       I$GetStt
                    bcc       L0254
                    ldd       #$0020
                    bra       L0256
L0254               tfr       x,d
L0256               puls      pc,y
L0258               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    bsr       L02AA
                    ldd       #$0001
                    lbsr      L12A0
                    puls      pc,u
L026A               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L10C8
L0275               ldd       #$0001
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2659
                    leas      $04,s
                    ldb       <u004F
                    sex
                    tfr       d,x
                    bra       L029C
L028E               ldd       #$0001
                    puls      pc,u
L0293               clra
                    clrb
                    puls      pc,u
L0297               lbsr      L1334
                    bra       L0275
L029C               cmpx      #$0031
                    beq       L028E
                    cmpx      #$0032
                    beq       L0293
                    bra       L0297
                    puls      pc,u
L02AA               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leax      >$0599,y
                    bra       L02C4
L02B8               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leax      >$05BB,y
L02C4               pshs      x
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L25AE
L02CD               leas      $04,s
                    puls      pc,u
L02D1               pshs      u
                    ldd       #$FFB6
                    lbsr      L00FD
                    leas      -$02,s
                    leax      >$008E,y
                    tfr       x,d
                    lbsr      L2715
                    ldd       <u0041
                    beq       L02EC
                    ldd       <u0037
                    bra       L0300
L02EC               ldd       <u0045
                    beq       L02FE
                    ldd       <u002B
                    std       <u002D
                    ldd       <u0039
                    std       ,s
                    ldd       <u003B
                    std       <u0039
                    bra       L0302
L02FE               ldd       <u0029
L0300               std       <u002D
L0302               ldd       #$0001
                    std       <u0049
                    lbsr      L12C9
                    lbsr      L0D27
L030D               ldu       #$0000
                    lbsr      L04A5
L0313               ldd       #$0001
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2659
                    leas      $04,s
                    ldb       <u004F
                    sex
                    tfr       d,x
                    bra       L0356
L032C               lbsr      L05D5
                    lbra      L03B7
L0332               lbsr      L06A8
                    lbra      L03B7
L0338               lbsr      L0661
                    lbra      L03B7
L033E               lbsr      L0680
                    lbra      L03B7
L0344               lbsr      L0542
                    lbra      L03B7
L034A               ldu       #$0001
                    lbra      L03B7
L0350               lbsr      L1334
                    lbra      L03B7
L0356               cmpx      #$0073
                    beq       L032C
                    cmpx      #$0053
                    lbeq      L032C
                    cmpx      #$0068
                    beq       L0332
                    cmpx      #$0048
                    lbeq      L0332
                    cmpx      #$000C
                    beq       L0338
                    cmpx      #$000A
                    beq       L033E
                    cmpx      #$0064
                    beq       L038E
                    cmpx      #$0044
                    beq       L038E
                    cmpx      #$0008
                    beq       L0344
                    cmpx      #$0009
                    beq       L034A
                    bra       L0350
L038E               lbsr      L12FD
                    ldd       <u0049
                    addd      <u004D
                    addd      #$FFFF
                    cmpd      <u0039
                    bge       L03A6
                    lbsr      L040F
                    std       -$02,s
                    bne       L03AD
                    bra       L03B1
L03A6               lbsr      L043A
                    std       -$02,s
                    beq       L03B1
L03AD               leax      $02,s
                    bra       L03E0
L03B1               lbsr      L12FD
                    lbsr      L0D27
L03B7               stu       -$02,s
                    lbeq      L0313
                    ldd       <u0049
                    addd      <u004D
                    cmpd      <u0039
                    ble       L03CB
                    lbsr      L1334
                    bra       L03D5
L03CB               ldd       <u0049
                    addd      <u004D
                    std       <u0049
                    ldd       <u002F
                    std       <u002D
L03D5               ldd       <u0049
                    cmpd      <u0039
                    lble      L030D
                    bra       L03E2
L03E0               leas      -$02,x
L03E2               ldd       <u0045
                    beq       L03ED
                    ldd       ,s
                    std       <u0039
                    lbsr      L070D
L03ED               leax      >$00B6,y
                    tfr       x,d
                    lbsr      L2715
                    lbra      L07A2
L03F9               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldd       #$0001
                    std       <u0045
                    lbsr      L02D1
                    clra
                    clrb
                    std       <u0045
                    puls      pc,u
L040F               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    clra
                    clrb
                    pshs      b,a
                    ldd       #$0006
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0014
                    pshs      b,a
                    leax      >$00B9,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    bsr       L043A
                    puls      pc,u
L043A               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0001
                    pshs      b,a
                    ldd       #$0006
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0014
                    pshs      b,a
                    leax      >$00CE,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
L0462               ldd       #$0001
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2659
                    leas      $04,s
                    ldb       <u004F
                    sex
                    tfr       d,x
                    bra       L0489
L047B               ldd       #$0001
                    puls      pc,u
L0480               clra
                    clrb
                    puls      pc,u
L0484               lbsr      L1334
                    bra       L0462
L0489               cmpx      #$0059
                    beq       L047B
                    cmpx      #$0079
                    lbeq      L047B
                    cmpx      #$004E
                    beq       L0480
                    cmpx      #$006E
                    lbeq      L0480
                    bra       L0484
                    puls      pc,u
L04A5               pshs      u
                    ldd       #$FFB4
                    lbsr      L00FD
                    leas      -$04,s
                    lbsr      L12D6
                    ldd       #$0005
                    std       <u008C
                    ldu       <u002D
                    std       <u003D
                    ldd       #$0001
                    lbra      L052B
L04C1               stu       -$02,s
                    lbeq      L0536
                    ldd       <u003D
                    pshs      b,a
                    ldd       #$0008
                    lbsr      L1248
                    leas      $02,s
                    ldd       <u0041
                    beq       L04EE
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L240A
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    pshs      b,a
                    bra       L04FD
L04EE               tfr       u,d
                    lbsr      L058C
                    std       ,s
                    pshs      b,a
                    leax      >$006F,y
                    pshs      x
L04FD               ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       ,u
                    beq       L050F
                    ldd       #$0001
                    lbsr      L127C
L050F               ldd       <u008C
                    addd      #$0001
                    std       <u008C
                    ldd       <u003D
                    addd      #$0001
                    std       <u003D
                    ldu       <u0023,u
                    tfr       u,d
                    std       <u002F
                    bra       L0526
L0526               ldd       $02,s
                    addd      #$0001
L052B               std       $02,s
                    ldd       $02,s
                    cmpd      <u004D
                    lble      L04C1
L0536               ldd       #$0005
                    std       <u003D
                    lbsr      L1351
                    leas      $04,s
                    puls      pc,u
L0542               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leas      -$02,s
                    ldd       <u0049
                    cmpd      #$0001
                    lbeq      L0707
                    ldd       <u0049
                    subd      <u004D
                    std       <u0049
                    ldd       <u0041
                    beq       L0564
                    ldu       <u0037
                    bra       L056E
L0564               ldd       <u0045
                    beq       L056C
                    ldu       <u002B
                    bra       L056E
L056C               ldu       <u0029
L056E               ldd       #$0001
                    bra       L057B
L0573               ldu       <u0023,u
                    ldd       ,s
                    addd      #$0001
L057B               std       ,s
                    ldd       ,s
                    cmpd      <u0049
                    blt       L0573
                    stu       <u002D
                    lbsr      L04A5
                    lbra      L07A2
L058C               pshs      u,b,a
                    ldd       #$FFBA
                    lbsr      L00FD
                    leas      -$04,s
                    leau      >$006F,y
                    ldd       $04,s
                    addd      #$0002
                    std       $02,s
                    clra
                    clrb
                    bra       L05AA
L05A5               ldd       ,s
                    addd      #$0001
L05AA               std       ,s
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    ldb       -$01,x
                    stb       ,u+
                    cmpb      #$2E
                    bne       L05A5
                    clra
                    clrb
                    stb       ,-u
                    ldd       ,s
                    leas      $06,s
                    puls      pc,u
L05C4               pshs      u
                    ldd       #$FFC0
                    lbsr      L00FD
                    ldd       <u003D
                    addd      #$FFFB
                    addd      <u0049
                    puls      pc,u
L05D5               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    bsr       L05C4
                    std       ,s
                    ldd       <u0041
                    beq       L05EB
                    ldu       <u0037
                    bra       L0621
L05EB               ldu       <u002D
                    bra       L0621
L05EF               ldd       ,s
                    cmpd      <u001F,u
                    bne       L061E
                    ldd       ,u
                    bne       L0600
                    ldd       #$0001
                    bra       L0602
L0600               clra
                    clrb
L0602               std       ,u
                    ldd       <u0041
                    bne       L0616
                    ldd       <u0045
                    bne       L0616
                    ldd       ,u
                    pshs      b,a
                    tfr       u,d
                    bsr       L0628
                    leas      $02,s
L0616               ldd       ,u
                    lbsr      L127C
                    lbra      L07A2
L061E               ldu       <u0023,u
L0621               stu       -$02,s
                    bne       L05EF
                    lbra      L0707
L0628               pshs      u
                    tfr       d,u
                    ldd       #$FFC0
                    lbsr      L00FD
                    ldd       $04,s
                    beq       L064A
                    ldd       [<u0021,u]
                    addd      #$0001
                    std       [<u0021,u]
                    ldx       <u0021,u
                    ldd       [<$21,x]
                    addd      #$0001
                    bra       L065C
L064A               ldd       [<u0021,u]
                    addd      #$FFFF
                    std       [<u0021,u]
                    ldx       <u0021,u
                    ldd       [<$21,x]
                    addd      #$FFFF
L065C               std       [<$21,x]
                    puls      pc,u
L0661               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldd       <u003D
                    cmpd      #$0005
                    ble       L06A3
                    lbsr      L1370
                    ldd       <u003D
                    addd      #$FFFF
                    std       <u003D
                    lbsr      L1351
                    bra       L06A6
L0680               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldd       <u008C
                    addd      #$FFFF
                    cmpd      <u003D
                    ble       L06A3
                    ldd       <u003D
                    lbsr      L1370
                    ldd       <u003D
                    addd      #$0001
                    std       <u003D
                    lbsr      L1351
                    bra       L06A6
L06A3               lbsr      L1334
L06A6               puls      pc,u
L06A8               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    lbsr      L05C4
                    std       ,s
                    ldd       <u0041
                    beq       L06BF
                    ldu       <u0037
                    bra       L0703
L06BF               ldu       <u002D
                    bra       L0703
L06C3               ldd       ,s
                    cmpd      <u001F,u
                    bne       L0700
                    ldd       <u0041
                    bne       L06EF
                    tfr       u,d
                    lbsr      L058C
                    leax      >$00B2,y
                    pshs      x
                    leax      >$006F,y
                    tfr       x,d
                    lbsr      L2435
                    leas      $02,s
                    clra
                    clrb
                    pshs      b,a
                    leax      >$006F,y
                    bra       L06F8
L06EF               ldd       <u001F,u
                    pshs      b,a
                    leax      >L07A6,pcr
L06F8               tfr       x,d
                    lbsr      L1398
                    lbra      L0769
L0700               ldu       <u0023,u
L0703               stu       -$02,s
                    bne       L06C3
L0707               lbsr      L1334
                    lbra      L07A2
L070D               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    lbsr      L12C9
                    lbsr      L0DEA
                    puls      pc,u
L071D               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leax      >L07AE,pcr
                    tfr       x,d
                    bsr       L073F
                    leax      >L07B1,pcr
                    tfr       x,d
                    bsr       L073F
                    leax      >L07B6,pcr
                    tfr       x,d
                    bsr       L0776
                    puls      pc,u
L073F               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    ldu       <u0029
                    bra       L0770
L074B               ldd       ,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L0B5E
                    std       ,s++
                    beq       L076D
                    ldd       #$0001
                    std       ,u
                    pshs      b,a
                    tfr       u,d
                    lbsr      L0628
L0769               leas      $02,s
                    bra       L07A2
L076D               ldu       <u0023,u
L0770               stu       -$02,s
                    bne       L074B
                    bra       L07A2
L0776               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    ldu       <u002B
                    bra       L079E
L0782               ldd       ,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L0B5E
                    std       ,s++
                    beq       L079B
                    ldd       #$0001
                    std       ,u
                    bra       L07A2
L079B               ldu       <u0023,u
L079E               stu       -$02,s
                    bne       L0782
L07A2               leas      $02,s
                    puls      pc,u
L07A6               fcc       "cmds.hp"
                    fcb       $00
L07AE               fcc       "DD"
                    fcb       $00
L07B1               fcc       "TERM"
                    fcb       $00
L07B6               fcc       "CO32"
                    fcb       $00
L07BB               fcb       $34,$40
                    ldd       #$FF92
                    lbsr      L00FD
                    leas      <-$24,s
                    ldd       #$0081
                    pshs      b,a
                    leax      >$008E,y
                    tfr       x,d
                    lbsr      L25E1
                    leas      $02,s
                    std       <$20,s
                    cmpd      #$FFFF
                    bne       L07EF
                    ldd       #$001B
                    pshs      b,a
                    leax      >L0BC3,pcr
                    tfr       x,d
                    lbsr      L168D
                    leas      $02,s
L07EF               clra
                    clrb
                    pshs      b,a
                    ldd       #$0040
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    ldd       <$26,s
                    lbsr      L26AA
                    leas      $06,s
                    ldd       $02,x
                    pshs      b,a
                    ldd       ,x
                    pshs      b,a
                    bsr       L0812
                    fdb       $FFFF,$FFFF
L0812               fdb       $3510
L0814               lbsr      L2888
                    lbne      L08B0
                    ldd       #$001B
                    pshs      b,a
                    leax      >L0BDF,pcr
                    tfr       x,d
                    lbsr      L168D
                    leas      $02,s
                    lbra      L08B0
L082E               ldb       ,s
                    lbeq      L08B0
                    leax      ,s
                    pshs      x
                    leax      >$006F,y
                    tfr       x,d
                    lbsr      L2553
                    leas      $02,s
                    leax      >$006F,y
                    tfr       x,d
                    lbsr      L0AD5
                    std       -$02,s
                    beq       L0880
                    ldd       <u0029
                    bne       L0869
                    clra
                    clrb
                    pshs      b,a
                    leax      >$006F,y
                    tfr       x,d
                    lbsr      L08D2
                    leas      $02,s
                    std       <u0029
                    tfr       d,u
                    bra       L08B0
L0869               clra
                    clrb
                    pshs      b,a
                    leax      >$006F,y
                    tfr       x,d
                    lbsr      L08D2
                    leas      $02,s
                    std       <u0023,u
                    ldu       <u0023,u
                    bra       L08B0
L0880               leax      >$006F,y
                    tfr       x,d
                    lbsr      L0B02
                    std       -$02,s
                    beq       L08B0
                    ldd       <u002B
                    bne       L089E
                    leax      >$006F,y
                    tfr       x,d
                    lbsr      L094E
                    std       <u002B
                    bra       L08AD
L089E               leax      >$006F,y
                    tfr       x,d
                    lbsr      L094E
                    ldx       <$22,s
                    std       <$23,x
L08AD               std       <$22,s
L08B0               ldd       #$0020
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    ldd       <$24,s
                    lbsr      L2659
                    leas      $04,s
                    std       -$02,s
                    lbgt      L082E
                    ldd       <$20,s
                    lbsr      L25EE
                    leas      <$24,s
                    puls      pc,u
L08D2               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    leas      -$02,s
                    ldd       $08,s
                    pshs      b,a
                    ldd       $04,s
                    lbsr      L0A9C
                    leas      $02,s
                    tfr       d,u
                    ldd       <u0039
                    addd      #$0001
                    std       <u0039
                    std       <u001F,u
                    leax      >$008E,y
                    tfr       x,d
                    lbsr      L2715
                    ldd       #$0001
                    pshs      b,a
                    ldd       $04,s
                    lbsr      L25E1
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    beq       L092A
                    ldd       ,s
                    lbsr      L0970
                    std       <u0021,u
                    ldd       ,s
                    lbsr      L09D7
                    ldx       <u0021,u
                    std       <$21,x
                    ldd       ,s
                    lbsr      L25EE
                    bra       L0940
L092A               ldd       #$001E
                    pshs      b,a
                    leax      >L0BFB,pcr
                    tfr       x,d
                    lbsr      L1661
                    leas      $02,s
                    lbsr      L12FD
                    lbsr      L0DC6
L0940               leax      >$00B6,y
                    tfr       x,d
                    lbsr      L2715
                    tfr       u,d
                    lbra      L0B5A
L094E               pshs      u,b,a
                    ldd       #$FFB8
                    lbsr      L00FD
                    clra
                    clrb
                    pshs      b,a
                    ldd       $02,s
                    lbsr      L0A9C
                    leas      $02,s
                    tfr       d,u
                    ldd       <u003B
                    addd      #$0001
                    std       <u003B
                    std       <u001F,u
                    lbra      L0AD0
L0970               pshs      u,b,a
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
                    lbsr      L26AA
                    leas      $06,s
                    ldd       ,s
                    lbsr      L0A3D
                    leax      >$00AA,y
                    pshs      x
                    leax      >$0052,y
                    tfr       x,d
                    lbsr      L2435
                    leas      $02,s
                    ldu       <u0033
                    bra       L09BF
L09A6               leax      >$0052,y
                    pshs      x
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L2462
                    std       ,s++
                    lbeq      L0AD0
                    ldu       <u0023,u
L09BF               stu       -$02,s
                    bne       L09A6
                    ldd       <u0033
                    pshs      b,a
                    leax      >$0052,y
                    tfr       x,d
                    lbsr      L0A9C
                    leas      $02,s
                    std       <u0033
                    lbra      L0BBF
L09D7               pshs      u,b,a
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
                    lbsr      L26AA
                    leas      $06,s
                    ldd       ,s
                    bsr       L0A3D
                    leax      >$00AE,y
                    pshs      x
                    leax      >$0052,y
                    tfr       x,d
                    lbsr      L2435
                    leas      $02,s
                    ldu       <u0031
                    bra       L0A25
L0A0C               leax      >$0052,y
                    pshs      x
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L2462
                    std       ,s++
                    lbeq      L0AD0
                    ldu       <u0023,u
L0A25               stu       -$02,s
                    bne       L0A0C
                    ldd       <u0031
                    pshs      b,a
                    leax      >$0052,y
                    tfr       x,d
                    lbsr      L0A9C
                    leas      $02,s
                    std       <u0031
                    lbra      L0BBF
L0A3D               pshs      u,b,a
                    ldd       #$FFB1
                    lbsr      L00FD
                    leas      -$03,s
                    ldd       #$0002
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    ldd       $07,s
                    lbsr      L2659
                    leas      $04,s
                    clra
                    clrb
                    pshs      b,a
                    ldd       $02,s
                    lbsr      L28AC
                    ldd       $02,x
                    pshs      b,a
                    ldd       ,x
                    pshs      b,a
                    ldd       $09,s
                    lbsr      L26AA
                    leas      $06,s
                    leau      >$0052,y
                    bra       L0A79
L0A75               ldb       $02,s
                    stb       ,u+
L0A79               ldd       #$0001
                    pshs      b,a
                    leax      $04,s
                    pshs      x
                    ldd       $07,s
                    lbsr      L2659
                    leas      $04,s
                    ldb       $02,s
                    cmpb      #$7F
                    bls       L0A75
                    clra
                    andb      #$7F
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    leas      $05,s
                    puls      pc,u
L0A9C               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    ldu       <u0035
                    beq       L0AAF
                    ldd       <u0023,u
                    std       <u0035
                    bra       L0AB7
L0AAF               ldd       #$0025
                    lbsr      L0B31
                    tfr       d,u
L0AB7               ldd       ,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L241D
                    leas      $02,s
                    clra
                    clrb
                    std       ,u
                    ldd       $06,s
                    std       <u0023,u
L0AD0               tfr       u,d
                    lbra      L0BBF
L0AD5               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leax      >$009A,y
                    pshs      x
                    tfr       u,d
                    lbsr      L0B5E
                    std       ,s++
                    bne       L0AFD
                    leax      >$009E,y
                    pshs      x
                    tfr       u,d
                    lbsr      L0B5E
                    std       ,s++
                    beq       L0B2D
L0AFD               ldd       #$0001
                    bra       L0B2F
L0B02               pshs      u
                    tfr       d,u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leax      >$00A2,y
                    pshs      x
                    tfr       u,d
                    bsr       L0B5E
                    std       ,s++
                    bne       L0B28
                    leax      >$00A6,y
                    pshs      x
                    tfr       u,d
                    bsr       L0B5E
                    std       ,s++
                    beq       L0B2D
L0B28               ldd       #$0001
                    bra       L0B2F
L0B2D               clra
                    clrb
L0B2F               puls      pc,u
L0B31               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    leas      -$02,s
                    ldd       $02,s
                    lbsr      L2725
                    std       ,s
                    cmpd      #$FFFF
                    bne       L0B58
                    ldd       #$000D
                    pshs      b,a
                    leax      >L0C1A,pcr
                    tfr       x,d
                    lbsr      L168D
                    leas      $02,s
L0B58               ldd       ,s
L0B5A               leas      $04,s
                    puls      pc,u
L0B5E               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    leas      -$02,s
                    ldd       #$0001
                    std       ,s
                    addd      #$FFFF
                    leau      d,u
                    bra       L0B8F
L0B76               ldd       $06,s
                    pshs      b,a
                    tfr       u,d
                    leau      u0001,u
                    bsr       L0B95
                    std       ,s++
                    beq       L0B88
                    ldd       ,s
                    bra       L0BBF
L0B88               ldd       ,s
                    addd      #$0001
                    std       ,s
L0B8F               ldb       ,u
                    bne       L0B76
                    bra       L0BB4
L0B95               pshs      u,b,a
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldu       $06,s
                    bra       L0BB8
L0BA1               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    sex
                    pshs      b,a
                    ldb       ,u+
                    sex
                    cmpd      ,s++
                    beq       L0BB8
L0BB4               clra
                    clrb
                    bra       L0BBF
L0BB8               ldb       ,u
                    bne       L0BA1
                    ldd       #$0001
L0BBF               leas      $02,s
                    puls      pc,u

L0BC3               fcc       "Can't open module directory"
                    fcb       $00
L0BDF               fcc       "Error seeking past . and .."
                    fcb       $00
L0BFB               fcc       "Can't open the descriptor file"
                    fcb       $00
L0C1A               fcc       "Out of memory"
                    fcb       $00

L0C28               fcb       $34,$40
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L0CE6
                    ldd       #$0001
                    pshs      b,a
                    ldd       #$0006
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0013
                    pshs      b,a
                    leax      >$0428,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0002
L0C56               pshs      b,a
                    ldd       #$0007
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0011
                    pshs      b,a
                    leax      >$043C,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0005
L0C7B               lbsr      L1248
                    leas      $02,s
                    ldd       #$0017
                    pshs      b,a
                    leax      >$044E,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0004
                    pshs      b,a
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0018
                    pshs      b,a
                    leax      >$0466,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0005
                    pshs      b,a
                    ldd       #$0009
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$000E
                    pshs      b,a
                    leax      >$047F,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0006
                    pshs      b,a
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0013
                    pshs      b,a
                    leax      >$048E,y
                    lbra      L138D
L0CE6               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    clra
                    clrb
                    pshs      b,a
                    ldd       #$000D
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0006
                    pshs      b,a
                    leax      >$00E3,y
                    lbra      L138D
L0D06               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0008
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0010
                    pshs      b,a
                    leax      >$01CC,y
                    lbra      L138D
L0D27               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    bsr       L0CE6
                    ldd       #$0001
                    pshs      b,a
                    ldd       #$0003
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$001A
                    pshs      b,a
                    leax      >$00EA,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0002
                    pshs      b,a
                    clra
                    clrb
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$001F
                    pshs      b,a
                    leax      >$0105,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0007
                    lbsr      L1248
                    leas      $02,s
                    ldd       <u0041
                    beq       L0D8C
                    ldd       #$0013
                    pshs      b,a
                    leax      >$0139,y
                    bra       L0DA4
L0D8C               ldd       <u0045
                    beq       L0D9B
                    ldd       #$0013
                    pshs      b,a
                    leax      >$014D,y
                    bra       L0DA4
L0D9B               ldd       #$0013
                    pshs      b,a
                    leax      >$0125,y
L0DA4               pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0004
                    pshs      b,a
                    clra
                    clrb
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$001F
                    pshs      b,a
                    leax      >$0161,y
                    lbra      L138D
L0DC6               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0004
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0018
                    pshs      b,a
                    leax      >$01B3,y
                    lbra      L0FC2
L0DEA               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0006
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0012
                    pshs      b,a
                    leax      >$01DD,y
                    lbra      L0FC2
L0E0E               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0016
                    pshs      b,a
                    leax      >$0206,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0007
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0011
                    pshs      b,a
                    leax      >$021D,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0004
                    pshs      b,a
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0018
                    pshs      b,a
                    leax      >$019A,y
                    lbra      L138D
L0E6F               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       <u0047
                    beq       L0E83
                    lbsr      L11D0
                    lbsr      L11F7
                    puls      pc,u
L0E83               lbsr      L12C9
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0015
                    pshs      b,a
                    leax      >$01F0,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    lbsr      L0D06
                    ldd       #$0007
                    pshs      b,a
                    clra
                    clrb
                    lbsr      L1248
                    leas      $02,s
                    puls      pc,u
L0EBA               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L12C9
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0009
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0012
                    pshs      b,a
                    leax      >$022F,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0017
                    pshs      b,a
                    leax      >$0242,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0004
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0013
                    pshs      b,a
                    leax      >$025A,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0005
                    pshs      b,a
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0012
                    pshs      b,a
                    leax      >$026E,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0006
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0016
                    pshs      b,a
                    leax      >$0281,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0007
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0010
                    pshs      b,a
                    leax      >$0298,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0008
                    pshs      b,a
                    ldd       #$0007
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0015
                    pshs      b,a
                    leax      >$02A9,y
                    lbra      L138D
L0F9E               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L12C9
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0004
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0018
                    pshs      b,a
                    leax      >$0377,y
L0FC2               pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    lbsr      L0D06
                    puls      pc,u
L0FD1               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L12C9
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0016
                    pshs      b,a
                    leax      >$02BF,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0008
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0011
                    pshs      b,a
                    leax      >$02D6,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0004
                    pshs      b,a
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0018
                    pshs      b,a
                    leax      >$019A,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0001
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2659
                    leas      $04,s
                    ldd       <u0047
                    beq       L1058
                    lbsr      L11D0
                    lbsr      L1216
L1058               puls      pc,u
L105A               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L12C9
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$001C
                    pshs      b,a
                    leax      >$03D5,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0003
                    pshs      b,a
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$001A
                    pshs      b,a
                    leax      >$03F2,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0004
                    pshs      b,a
                    ldd       #$0003
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$001A
                    pshs      b,a
                    leax      >$040D,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0005
                    lbra      L1133
L10C8               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0008
                    pshs      b,a
                    ldd       #$0004
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$001C
                    pshs      b,a
                    leax      >$02E8,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0009
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0012
                    pshs      b,a
                    leax      >$0305,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$000A
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0016
                    pshs      b,a
                    leax      >$0318,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$000B
L1133               pshs      b,a
                    ldd       #$0008
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0010
                    pshs      b,a
                    leax      >$032F,y
                    lbra      L138D
L1149               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L12C9
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0003
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0019
                    pshs      b,a
                    leax      >$0340,y
                    bra       L1193
L116F               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L12C9
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0003
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0019
                    pshs      b,a
                    leax      >$035A,y
L1193               pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0004
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0018
                    pshs      b,a
                    leax      >$019A,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0001
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2659
                    lbra      L165D
L11D0               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L12C9
                    lbsr      L0CE6
                    ldd       #$0002
                    pshs      b,a
                    ldd       #$0005
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0016
                    pshs      b,a
                    leax      >$0390,y
                    lbra      L138D
L11F7               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0006
                    bsr       L1248
                    leas      $02,s
                    ldd       #$0014
                    pshs      b,a
                    leax      >$03A7,y
                    bra       L1233
L1216               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0003
                    pshs      b,a
                    ldd       #$0004
                    bsr       L1248
                    leas      $02,s
                    ldd       #$0018
                    pshs      b,a
                    leax      >$03BC,y
L1233               pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0005
                    pshs      b,a
                    clra
                    clrb
                    bsr       L1248
                    bra       L1278
L1248               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    ldd       #$0002
                    stb       <u004F
                    ldd       ,s
                    addd      #$0020
                    addd      <u004B
                    stb       <u0050
                    ldd       $06,s
                    addd      #$0020
                    stb       <u0051
                    ldd       #$0003
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
L1278               leas      $02,s
                    puls      pc,u
L127C               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       <u003D
                    pshs      b,a
                    ldd       #$0018
                    bsr       L1248
                    leas      $02,s
                    stu       -$02,s
                    beq       L129B
                    ldd       #$0058
                    lbra      L12ED
L129B               ldd       #$0020
                    bra       L12ED
L12A0               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0005
                    stb       <u004F
                    stu       -$02,s
                    bne       L12B8
                    ldd       #$0020
                    bra       L12BB
L12B8               ldd       #$0021
L12BB               stb       <u0050
                    ldd       #$0002
                    pshs      b,a
                    leax      >$004F,y
                    lbra      L138D
L12C9               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$000C
                    bra       L12ED
L12D6               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0005
                    pshs      b,a
                    clra
                    clrb
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$000B
L12ED               stb       <u004F
                    ldd       #$0001
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    lbra      L1392
L12FD               pshs      u
                    ldd       #$FFB7
                    lbsr      L00FD
                    leas      -$01,s
                    ldd       #$0004
                    stb       ,s
                    ldu       #$0000
                    bra       L132A
L1311               pshs      u
                    clra
                    clrb
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0001
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    lbsr      L2681
                    leas      $04,s
                    leau      u0001,u
L132A               cmpu      #$0003
                    ble       L1311
                    leas      $01,s
                    puls      pc,u
L1334               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       #$0007
                    stb       <u004F
                    ldd       #$0001
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    ldd       #$0002
                    bra       L1392
L1351               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    pshs      u
                    ldd       #$0003
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0002
                    pshs      b,a
                    leax      >$0001,y
                    bra       L138D
L1370               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    pshs      u
                    ldd       #$0003
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0002
                    pshs      b,a
                    leax      >$0004,y
L138D               pshs      x
                    ldd       #$0001
L1392               lbsr      L2681
                    lbra      L165D
L1398               pshs      u,b,a
                    ldd       #$FF67
                    lbsr      L00FD
                    leas      <-$4D,s
                    ldd       #$0001
                    pshs      b,a
                    ldd       <$4F,s
                    lbsr      L25E1
                    leas      $02,s
                    std       <$49,s
                    cmpd      #$FFFF
                    bne       L13CC
                    ldd       #$0014
                    pshs      b,a
                    leax      >L16D3,pcr
                    tfr       x,d
                    lbsr      L1661
                    leas      $02,s
                    lbra      L1596
L13CC               lbsr      L12FD
                    clra
                    clrb
                    std       <$47,s
                    std       <$45,s
                    pshs      b,a
                    lbsr      L1248
                    leas      $02,s
                    ldd       <u0041
                    lbeq      L154F
                    ldd       <$53,s
                    addd      #$FFFF
                    pshs      b,a
                    ldd       #$0064
                    lbsr      L28C5
                    std       <$41,s
                    clra
                    clrb
                    pshs      b,a
                    ldd       <$43,s
                    lbsr      L28AC
                    ldd       $02,x
                    pshs      b,a
                    ldd       ,x
                    pshs      b,a
                    ldd       <$4F,s
                    lbsr      L26AA
                    leas      $06,s
                    ldd       #$0001
                    pshs      b,a
                    ldd       #$0023
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    ldd       <$4F,s
                    lbsr      L26AA
                    leas      $06,s
                    ldd       #$0041
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    ldd       <$4D,s
                    lbsr      L266F
                    leas      $04,s
                    leax      ,s
                    tfr       x,d
                    lbsr      L240A
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    ldd       #$0001
                    lbsr      L2696
                    leas      $04,s
                    bra       L1455
L144D               leas      <-$4F,x
L1450               ldb       <$4C,s
                    bne       L145B
L1455               lbsr      L161C
                    lbra      L1505
L145B               ldb       <$4C,s
                    cmpb      #$0D
                    bne       L14B9
                    ldd       <$47,s
                    addd      #$0001
                    std       <$47,s
                    cmpd      #$0002
                    ble       L14AA
                    ldd       #$0001
                    pshs      b,a
                    leax      <$4E,s
                    pshs      x
                    ldd       <$4D,s
                    lbsr      L2659
                    leas      $04,s
                    std       <$41,s
                    lble      L152F
                    lbsr      L15A1
                    std       <$41,s
                    cmpd      #$0002
                    lbeq      L1505
                    clra
                    clrb
                    std       <$47,s
                    pshs      b,a
                    std       <$47,s
                    lbsr      L1248
                    leas      $02,s
                    lbra      L1529
L14AA               pshs      b,a
                    clra
                    clrb
                    std       <$47,s
                    lbsr      L1248
                    leas      $02,s
                    lbra      L154F
L14B9               ldd       <$45,s
                    addd      #$0001
                    std       <$45,s
                    subd      #$0001
                    cmpd      #$0020
                    lble      L1540
                    ldd       <$47,s
                    addd      #$0001
                    std       <$47,s
                    cmpd      #$0002
                    ble       L1534
                    ldb       <$4C,s
                    stb       <$4B,s
                    ldd       #$0001
                    pshs      b,a
                    leax      <$4E,s
                    pshs      x
                    ldd       <$4D,s
                    lbsr      L2659
                    leas      $04,s
                    std       <$41,s
                    ble       L152F
                    lbsr      L15A1
                    std       <$41,s
                    cmpd      #$0002
                    bne       L150B
L1505               leax      <$4F,s
                    lbra      L158D
L150B               clra
                    clrb
                    std       <$47,s
                    pshs      b,a
                    std       <$47,s
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0001
                    pshs      b,a
                    leax      <$4D,s
                    pshs      x
                    lbsr      L2681
                    leas      $04,s
L1529               leax      <$4F,s
                    lbra      L144D
L152F               leax      <$4F,s
                    bra       L1585
L1534               pshs      b,a
                    clra
                    clrb
                    std       <$47,s
                    lbsr      L1248
                    leas      $02,s
L1540               ldd       #$0001
                    pshs      b,a
                    leax      <$4E,s
                    pshs      x
                    lbsr      L2681
                    leas      $04,s
L154F               ldd       #$0001
                    pshs      b,a
                    leax      <$4E,s
                    pshs      x
                    ldd       <$4D,s
                    lbsr      L2659
                    leas      $04,s
                    std       <$41,s
                    lbgt      L1450
                    ldd       <$41,s
                    beq       L1588
                    ldd       #$0017
                    pshs      b,a
                    leax      >L16E8,pcr
                    tfr       x,d
                    lbsr      L1661
                    leas      $02,s
                    lbsr      L12FD
                    lbsr      L0D27
                    bra       L1588
L1585               leas      <-$4F,x
L1588               lbsr      L161C
                    bra       L1590
L158D               leas      <-$4F,x
L1590               ldd       <$49,s
                    lbsr      L25EE
L1596               lbsr      L12FD
                    lbsr      L0D27
                    leas      <$4F,s
                    puls      pc,u
L15A1               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       <u0043
                    beq       L15B2
                    ldd       #$000F
                    bra       L15B5
L15B2               ldd       #$0003
L15B5               pshs      b,a
                    ldd       #$0004
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0018
                    pshs      b,a
                    leax      >$0181,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
L15D2               ldd       #$0001
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2659
                    leas      $04,s
                    ldb       <u004F
                    sex
                    tfr       d,x
                    bra       L1600
L15EB               lbsr      L12FD
                    ldd       #$0001
                    puls      pc,u
L15F3               lbsr      L12FD
                    ldd       #$0002
                    puls      pc,u
L15FB               lbsr      L1334
                    bra       L15D2
L1600               cmpx      #$004D
                    beq       L15EB
                    cmpx      #$006D
                    lbeq      L15EB
                    cmpx      #$0043
                    beq       L15F3
                    cmpx      #$0063
                    lbeq      L15F3
                    bra       L15FB
                    puls      pc,u
L161C               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldd       <u0043
                    beq       L162D
                    ldd       #$000F
                    bra       L1630
L162D               ldd       #$0003
L1630               pshs      b,a
                    ldd       #$0004
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0018
                    pshs      b,a
                    leax      >$019A,y
                    pshs      x
                    ldd       #$0001
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0001
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2659
L165D               leas      $04,s
                    puls      pc,u
L1661               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L1334
                    lbsr      L12FD
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L1248
                    leas      $02,s
                    ldd       $04,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    lbsr      L2681
                    leas      $04,s
                    lbsr      L161C
                    puls      pc,u
L168D               pshs      u
                    tfr       d,u
                    ldd       #$FFB8
                    lbsr      L00FD
                    lbsr      L1334
                    lbsr      L12C9
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0008
                    pshs      b,a
                    leax      >L1700,pcr
                    pshs      x
                    ldd       #$0002
                    lbsr      L2681
                    leas      $04,s
                    ldd       $04,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    lbsr      L2681
                    leas      $04,s
                    lbsr      L0258
                    ldd       >$0597,y
                    lbsr      L2844
                    puls      pc,u

L16D3               fcc       "Can't open help file"
                    fcb       $00
L16E8               fcc       "Error reading help file"
                    fcb       $00
L1700               fcc       "CONFIG: "
                    fcb       $00

L1709               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    lbsr      L197A
                    ldd       #$0003
                    pshs      b,a
                    leax      >$0007,y
                    tfr       x,d
                    lbsr      L2600
                    leas      $02,s
                    std       <u003F
                    cmpd      #$FFFF
                    bne       L173C
                    ldd       #$0018
                    pshs      b,a
                    leax      >L19B0,pcr
                    tfr       x,d
                    lbsr      L168D
                    leas      $02,s
L173C               lbsr      L1871
                    bsr       L1754
                    bsr       L1762
                    bsr       L1770
                    lbsr      L17DA
                    lbsr      L187F
                    ldd       <u003F
                    lbsr      L25EE
                    bsr       L1782
                    puls      pc,u
L1754               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leax      >$0010,y
                    bra       L177C
L1762               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leax      >$0017,y
                    bra       L177C
L1770               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leax      >$001E,y
L177C               tfr       x,d
                    bsr       L17A7
                    puls      pc,u
L1782               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leax      >$0029,y
                    tfr       x,d
                    lbsr      L1950
                    leax      >$0033,y
                    tfr       x,d
                    lbsr      L1950
                    leax      >$0031,y
                    tfr       x,d
                    lbsr      L1950
                    puls      pc,u
L17A7               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    ldu       <u0031
                    bra       L17D3
L17B3               ldd       ,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L0B5E
                    std       ,s++
                    beq       L17D0
                    ldd       ,u
                    beq       L17D0
                    tfr       u,d
                    bsr       L17F7
                    lbra      L194C
L17D0               ldu       <u0023,u
L17D3               stu       -$02,s
                    bne       L17B3
                    lbra      L194C
L17DA               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldu       <u0031
                    bra       L17F1
L17E6               ldd       ,u
                    beq       L17EE
                    tfr       u,d
                    bsr       L17F7
L17EE               ldu       <u0023,u
L17F1               stu       -$02,s
                    bne       L17E6
                    puls      pc,u
L17F7               pshs      u,b,a
                    ldd       #$FFB6
                    lbsr      L00FD
                    leas      -$02,s
                    ldd       $02,s
                    addd      #$0002
                    lbsr      L191E
                    clra
                    clrb
                    std       [<$02,s]
                    ldd       <u0033
                    lbra      L1866
L1813               ldx       ,s
                    ldd       <$21,x
                    cmpd      $02,s
                    bne       L1861
                    ldd       ,x
                    beq       L1861
                    tfr       x,d
                    addd      #$0002
                    lbsr      L191E
                    ldd       ,s
                    addd      #$0002
                    lbsr      L189D
                    std       -$02,s
                    beq       L1838
                    lbsr      L198D
L1838               clra
                    clrb
                    std       [,s]
                    ldu       <u0029
                    bra       L185D
L1840               ldd       <u0021,u
                    cmpd      ,s
                    bne       L185A
                    ldd       ,u
                    beq       L185A
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L191E
                    clra
                    clrb
                    std       ,u
L185A               ldu       <u0023,u
L185D               stu       -$02,s
                    bne       L1840
L1861               ldx       ,s
                    ldd       <$23,x
L1866               std       ,s
                    ldd       ,s
                    lbne      L1813
                    lbra      L1976
L1871               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leax      >L19C9,pcr
                    bra       L1896
L187F               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    bsr       L18CE
                    leax      >L19CF,pcr
                    tfr       x,d
                    lbsr      L191E
                    leax      >L19D5,pcr
L1896               tfr       x,d
                    lbsr      L191E
                    puls      pc,u
L189D               pshs      u,b,a
                    ldd       #$FFB8
                    lbsr      L00FD
                    leax      >L19DB,pcr
                    pshs      x
                    ldd       $02,s
                    lbsr      L0B5E
                    std       ,s++
                    bne       L18C3
                    leax      >L19E0,pcr
                    pshs      x
                    ldd       $02,s
                    lbsr      L0B5E
                    std       ,s++
                    beq       L18C9
L18C3               ldd       #$0001
                    lbra      L194C
L18C9               clra
                    clrb
                    lbra      L194C
L18CE               pshs      u
                    ldd       #$FFB7
                    lbsr      L00FD
                    leas      -$01,s
                    lbsr      L105A
L18DB               ldd       #$0001
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    clra
                    clrb
                    lbsr      L2659
                    leas      $04,s
                    ldb       ,s
                    sex
                    tfr       d,x
                    bra       L1907
L18F2               leax      >L19E5,pcr
                    bra       L18FC
L18F8               leax      >L19F0,pcr
L18FC               tfr       x,d
                    bsr       L191E
                    bra       L191A
L1902               lbsr      L1334
                    bra       L18DB
L1907               cmpx      #$000D
                    beq       L18F2
                    cmpx      #$0031
                    lbeq      L18F2
                    cmpx      #$0032
                    beq       L18F8
                    bra       L1902
L191A               leas      $01,s
                    puls      pc,u
L191E               pshs      u
                    tfr       d,u
                    ldd       #$FFB6
                    lbsr      L00FD
                    leas      -$02,s
                    stu       ,s
                    bra       L1935
L192E               ldd       ,s
                    addd      #$0001
                    std       ,s
L1935               ldb       [,s]
                    bne       L192E
                    ldd       #$000D
                    stb       [,s]
                    ldd       #$001D
                    pshs      b,a
                    pshs      u
                    ldd       <u003F
                    lbsr      L2696
                    leas      $04,s
L194C               leas      $02,s
                    puls      pc,u
L1950               pshs      u,b,a
                    ldd       #$FFBC
                    lbsr      L00FD
                    leas      -$02,s
                    ldu       [<$02,s]
                    bra       L196D
L195F               ldd       <u0023,u
                    std       ,s
                    ldd       <u0035
                    std       <u0023,u
                    stu       <u0035
                    ldu       ,s
L196D               stu       -$02,s
                    bne       L195F
                    clra
                    clrb
                    std       [<$02,s]
L1976               leas      $04,s
                    puls      pc,u
L197A               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    leax      >$0007,y
                    tfr       x,d
                    lbsr      L2646
                    puls      pc,u
L198D               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldu       <u002B
                    bra       L19AA
L1999               ldd       ,u
                    beq       L19A7
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L191E
L19A7               ldu       <u0023,u
L19AA               stu       -$02,s
                    bne       L1999
                    puls      pc,u
L19B0               fcc       "Can't open bootlist file"
                    fcb       $00
L19C9               fcc       "IOMan"
                    fcb       $00
L19CF               fcc       "SysGo"
                    fcb       $00
L19D5               fcc       "Shell"
                    fcb       $00
L19DB               fcc       "VTIO"
                    fcb       $00
L19E0               fcc       "vtio"
                    fcb       $00
L19E5               fcc       "Clock.60hz"
                    fcb       $00
L19F0               fcc       "Clock.50hz"
                    fcb       $00
L19FB               fcb       $34,$40
                    ldd       #$FFAE
                    lbsr      L00FD
                    leas      -$04,s
                    lbsr      L12C9
                    ldd       <u0047
                    bne       L1A23
                    lbsr      L0E0E
                    ldd       #$0001
                    pshs      b,a
                    leax      >$004F,y
                    pshs      x
                    clra
                    clrb
                    lbsr      L2659
                    leas      $04,s
                    bra       L1A26
L1A23               lbsr      L02AA
L1A26               lbsr      L0E6F
                    leax      >$008E,y
                    tfr       x,d
                    lbsr      L2715
                    ldd       <u0047
                    beq       L1A6C
                    clra
                    clrb
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    pshs      b,a
                    leax      >$04C2,y
                    pshs      x
                    tfr       x,d
                    lbsr      L240A
                    pshs      b,a
                    leax      >L1AD1,pcr
                    tfr       x,d
                    lbsr      L27FE
                    leas      $0A,s
                    std       $02,s
                    cmpd      #$FFFF
                    bne       L1AA7
                    ldd       #$0019
                    pshs      b,a
                    leax      >L1AD7,pcr
                    bra       L1AA0
L1A6C               clra
                    clrb
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    pshs      b,a
                    leax      >$04A2,y
                    pshs      x
                    tfr       x,d
                    lbsr      L240A
                    pshs      b,a
                    leax      >L1AF0,pcr
                    tfr       x,d
                    lbsr      L27FE
                    leas      $0A,s
                    std       $02,s
                    cmpd      #$FFFF
                    bne       L1AA7
                    ldd       #$0019
                    pshs      b,a
                    leax      >L1AF6,pcr
L1AA0               tfr       x,d
                    lbsr      L168D
                    leas      $02,s
L1AA7               leax      ,s
                    tfr       x,d
                    lbsr      L27C0
                    ldd       ,s
                    beq       L1ABA
                    lbsr      L0258
                    ldd       ,s
                    lbsr      L2844
L1ABA               ldd       <u0047
                    beq       L1AC4
                    lbsr      L02B8
                    lbsr      L116F
L1AC4               leax      >L1B0F,pcr
                    tfr       x,d
                    lbsr      L2715
                    leas      $04,s
                    puls      pc,u

L1AD1               fcc       "Shell"
                    fcb       $00
L1AD7               fcc       "Can't execute the OS9Gen"
                    fcb       $00
L1AF0               fcc       "Shell"
                    fcb       $00
L1AF6               fcc       "Can't execute the OS9gen"
                    fcb       $00

L1B0F               fcc       "/dd"
                    fcb       $00

L1B13               pshs      u
                    ldd       #$FFB5
                    lbsr      L00FD
                    leas      -$03,s
                    ldd       #$0001
                    pshs      b,a
                    pshs      b,a
                    leax      >L21D2,pcr
                    tfr       x,d
                    lbsr      L286B
                    leas      $04,s
                    std       ,s
                    leax      >$008E,y
                    tfr       x,d
                    lbsr      L2715
                    lbsr      L0EBA
L1B3D               ldd       #$0001
                    pshs      b,a
                    leax      $04,s
                    pshs      x
                    clra
                    clrb
                    lbsr      L2659
                    leas      $04,s
                    ldb       $02,s
                    sex
                    tfr       d,x
                    bra       L1B73
L1B54               ldd       #$0001
                    bra       L1B5B
L1B59               clra
                    clrb
L1B5B               lbsr      L1BBF
                    bra       L1BBB
L1B60               lbsr      L1BFE
                    bra       L1BBB
L1B65               lbsr      L1C74
                    lbsr      L0EBA
                    bra       L1B3D
L1B6D               lbsr      L1334
                    lbra      L1B3D
L1B73               cmpx      #$004E
                    beq       L1BBB
                    cmpx      #$006E
                    beq       L1BBB
                    cmpx      #$0042
                    beq       L1B54
                    cmpx      #$0062
                    lbeq      L1B54
                    cmpx      #$0046
                    beq       L1B59
                    cmpx      #$0066
                    lbeq      L1B59
                    cmpx      #$0049
                    beq       L1B60
                    cmpx      #$0069
                    lbeq      L1B60
                    cmpx      #$003F
                    beq       L1B65
                    bra       L1B6D
                    ldd       <u0047
                    beq       L1BB2
                    lbsr      L02B8
                    lbsr      L116F
L1BB2               leax      >L21D7,pcr
                    tfr       x,d
                    lbsr      L2715
L1BBB               leas      $03,s
                    puls      pc,u
L1BBF               pshs      u,b,a
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       ,s
                    lbsr      L1E28
                    ldu       <u0037
                    bra       L1BD8
L1BD0               ldd       #$0001
                    std       ,u
                    ldu       <u0023,u
L1BD8               stu       -$02,s
                    bne       L1BD0
                    ldd       <u0047
                    bne       L1BE6
                    lbsr      L0FD1
                    lbsr      L0F9E
L1BE6               lbsr      L1E0B
                    lbsr      L1D1F
                    lbsr      L1F79
                    ldd       ,s
                    lbne      L1D78
                    lbsr      L1D7C
                    lbsr      L202A
                    lbra      L1D78
L1BFE               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldd       #$0001
                    std       <u0041
                    clra
                    clrb
                    lbsr      L1E28
                    lbsr      L02D1
                    ldd       <u0047
                    bne       L1C1D
                    lbsr      L0FD1
                    lbsr      L0F9E
L1C1D               lbsr      L1E0B
                    lbsr      L1D1F
                    bsr       L1C34
                    std       -$02,s
                    beq       L1C2C
                    lbsr      L1D7C
L1C2C               lbsr      L1F79
                    lbsr      L202A
                    puls      pc,u
L1C34               pshs      u
                    ldd       #$FFB8
                    lbsr      L00FD
                    ldu       <u0037
                    bra       L1C6E
L1C40               pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L21B4
                    leax      >L21DB,pcr
                    pshs      x
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L2462
                    std       ,s++
                    bne       L1C6B
                    ldd       ,u
                    beq       L1C67
                    ldd       #$0001
                    puls      pc,u
L1C67               clra
                    clrb
                    puls      pc,u
L1C6B               ldu       <u0023,u
L1C6E               stu       -$02,s
                    bne       L1C40
                    puls      pc,u
L1C74               pshs      u
                    ldd       #$FF96
                    lbsr      L00FD
                    leas      <-$22,s
                    ldd       #$0001
                    std       <u0043
                    pshs      b,a
                    leax      >$04FC,y
                    tfr       x,d
                    lbsr      L25E1
                    leas      $02,s
                    std       <$20,s
                    cmpd      #$FFFF
                    bne       L1CB3
                    ldd       #$0014
                    pshs      b,a
                    leax      >L21DF,pcr
                    tfr       x,d
                    lbsr      L1661
                    leas      $02,s
                    lbsr      L12FD
                    lbsr      L0D27
                    lbra      L1D1A
L1CB3               lbsr      L12C9
                    ldu       #$0000
                    bra       L1CF1
L1CBB               ldd       #$0020
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    ldd       <$24,s
                    lbsr      L266F
                    leas      $04,s
                    std       -$02,s
                    bne       L1CD5
                    leax      <$22,s
                    bra       L1D05
L1CD5               pshs      u
                    clra
                    clrb
                    lbsr      L1248
                    leas      $02,s
                    ldd       #$0020
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    ldd       #$0001
                    lbsr      L2696
                    leas      $04,s
                    leau      u0001,u
L1CF1               cmpu      #$000E
                    ble       L1CBB
                    lbsr      L15A1
                    cmpd      #$0002
                    bne       L1CB3
                    leax      <$22,s
                    bra       L1D0D
L1D05               leas      <-$22,x
                    lbsr      L161C
                    bra       L1D10
L1D0D               leas      <-$22,x
L1D10               ldd       <$20,s
                    lbsr      L25EE
                    clra
                    clrb
                    std       <u0043
L1D1A               leas      <$22,s
                    puls      pc,u
L1D1F               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       <u0047
                    beq       L1D2E
                    lbsr      L1149
L1D2E               ldd       #$007F
                    pshs      b,a
                    leax      >$04E6,y
                    tfr       x,d
                    lbsr      L25F6
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L1D54
                    ldd       #$001B
                    pshs      b,a
                    leax      >L21F4,pcr
                    tfr       x,d
                    lbsr      L168D
                    leas      $02,s
L1D54               ldd       #$007F
                    pshs      b,a
                    leax      >$04EB,y
                    tfr       x,d
                    lbsr      L25F6
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L1D7A
                    ldd       #$001A
                    pshs      b,a
                    leax      >L2210,pcr
                    tfr       x,d
                    lbsr      L168D
L1D78               leas      $02,s
L1D7A               puls      pc,u
L1D7C               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldd       <u0047
                    beq       L1D8B
                    lbsr      L1149
L1D8B               ldd       #$007F
                    pshs      b,a
                    leax      >$04EF,y
                    tfr       x,d
                    lbsr      L25F6
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L1DB1
                    ldd       #$001B
                    pshs      b,a
                    leax      >L222B,pcr
                    tfr       x,d
                    lbsr      L168D
                    leas      $02,s
L1DB1               leax      >$04EF,y
                    tfr       x,d
                    lbsr      L2715
                    leax      >L2258,pcr
                    pshs      x
                    leax      >L2247,pcr
                    tfr       x,d
                    lbsr      L2066
                    leas      $02,s
                    leax      >L2271,pcr
                    pshs      x
                    leax      >L2260,pcr
                    tfr       x,d
                    lbsr      L2066
                    leas      $02,s
                    leax      >L228A,pcr
                    pshs      x
                    leax      >L2279,pcr
                    tfr       x,d
                    lbsr      L2066
                    leas      $02,s
                    leax      >L22A3,pcr
                    pshs      x
                    leax      >L2292,pcr
                    tfr       x,d
                    lbsr      L2066
                    leas      $02,s
                    leax      >L22BD,pcr
                    pshs      x
                    leax      >L22AB,pcr
                    lbra      L2055
L1E0B               pshs      u
                    ldd       #$FFBC
                    lbsr      L00FD
                    ldd       <u0047
                    beq       L1E21
                    lbsr      L02AA
                    leax      >L22C6,pcr
                    lbra      L205F
L1E21               leax      >L22CA,pcr
                    lbra      L205F
L1E28               pshs      u,b,a
                    ldd       #$FFB0
                    lbsr      L00FD
                    leas      -$06,s
                    ldd       #$0001
                    pshs      b,a
                    leax      >$04F4,y
                    tfr       x,d
                    lbsr      L25E1
                    leas      $02,s
                    std       $04,s
                    cmpd      #$FFFF
                    bne       L1E5A
                    ldd       #$0018
                    pshs      b,a
                    leax      >L22CE,pcr
                    tfr       x,d
                    lbsr      L168D
                    leas      $02,s
L1E5A               clra
                    clrb
                    std       <u0039
L1E5E               ldd       #$0064
                    pshs      b,a
                    ldd       >$04E4,y
                    pshs      b,a
                    ldd       $08,s
                    lbsr      L2659
                    leas      $04,s
                    std       $02,s
                    bgt       L1E84
                    ldd       #$001B
                    pshs      b,a
                    leax      >L22E7,pcr
                    tfr       x,d
                    lbsr      L168D
                    leas      $02,s
L1E84               ldd       $06,s
                    beq       L1EB4
                    ldx       >$04E4,y
                    ldd       $0A,x
                    beq       L1EB2
                    clra
                    clrb
                    pshs      b,a
                    tfr       x,d
                    lbsr      L0A9C
                    leas      $02,s
                    std       <u0037
                    ldd       #$0001
                    std       [>$0037,y]
                    ldd       <u0039
                    addd      #$0001
                    std       <u0039
                    ldx       <u0037
                    std       <$1F,x
                    bra       L1EDE
L1EB2               bra       L1E5E
L1EB4               clra
                    clrb
                    pshs      b,a
                    ldd       >$04E4,y
                    lbsr      L0A9C
                    leas      $02,s
                    std       <u0037
                    ldd       <u0039
                    addd      #$0001
                    std       <u0039
                    ldx       <u0037
                    std       <$1F,x
                    ldx       >$04E4,y
                    ldd       $0A,x
                    beq       L1EDE
                    ldd       #$0001
                    std       [>$0037,y]
L1EDE               ldd       <u0037
                    std       ,s
                    lbra      L1F45
L1EE5               ldd       $06,s
                    beq       L1F18
                    ldx       >$04E4,y
                    ldd       $0A,x
                    lbeq      L1F45
                    clra
                    clrb
                    pshs      b,a
                    tfr       x,d
                    lbsr      L0A9C
                    leas      $02,s
                    ldx       ,s
                    std       <$23,x
                    std       ,s
                    ldd       <u0039
                    addd      #$0001
                    std       <u0039
                    ldx       ,s
                    std       <$1F,x
                    ldd       #$0001
                    std       ,x
                    bra       L1F45
L1F18               clra
                    clrb
                    pshs      b,a
                    ldd       >$04E4,y
                    lbsr      L0A9C
                    leas      $02,s
                    ldx       ,s
                    std       <$23,x
                    std       ,s
                    ldd       <u0039
                    addd      #$0001
                    std       <u0039
                    ldx       ,s
                    std       <$1F,x
                    ldx       >$04E4,y
                    ldd       $0A,x
                    beq       L1F45
                    ldd       #$0001
                    std       [,s]
L1F45               ldd       #$0064
                    pshs      b,a
                    ldd       >$04E4,y
                    pshs      b,a
                    ldd       $08,s
                    lbsr      L2659
                    leas      $04,s
                    std       $02,s
                    lbgt      L1EE5
                    ldd       $02,s
                    cmpd      #$FFFF
                    bne       L1F75
                    ldd       #$001B
                    pshs      b,a
                    leax      >L2303,pcr
                    tfr       x,d
                    lbsr      L168D
                    leas      $02,s
L1F75               leas      $08,s
                    puls      pc,u
L1F79               pshs      u
                    ldd       #$FF84
                    lbsr      L00FD
                    leas      <-$36,s
                    leax      >L232B,pcr
                    pshs      x
                    leax      >L231F,pcr
                    tfr       x,d
                    lbsr      L2066
                    leas      $02,s
                    leax      >$04E6,y
                    tfr       x,d
                    lbsr      L2715
                    ldu       <u0037
                    bra       L1FF6
L1FA2               ldd       ,u
                    beq       L1FF3
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    lbsr      L21B4
                    leax      >L2333,pcr
                    pshs      x
                    leax      <$1A,s
                    tfr       x,d
                    lbsr      L241D
                    leas      $02,s
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    pshs      b,a
                    leax      <$1A,s
                    tfr       x,d
                    lbsr      L2435
                    leas      $02,s
                    pshs      u
                    ldd       #$0002
                    addd      ,s++
                    pshs      b,a
                    leax      $06,s
                    tfr       x,d
                    lbsr      L241D
                    leas      $02,s
                    leax      $04,s
                    pshs      x
                    leax      <$1A,s
                    tfr       x,d
                    lbsr      L2066
                    leas      $02,s
L1FF3               ldu       <u0023,u
L1FF6               stu       -$02,s
                    bne       L1FA2
                    leax      >$00B6,y
                    tfr       x,d
                    lbsr      L2715
                    leax      >$04EB,y
                    tfr       x,d
                    lbsr      L2715
                    leax      >L234C,pcr
                    pshs      x
                    leax      >L233D,pcr
                    tfr       x,d
                    bsr       L2066
                    leas      $02,s
                    leax      >$00B6,y
                    tfr       x,d
                    lbsr      L2715
                    leas      <$36,s
                    puls      pc,u
L202A               pshs      u
                    ldd       #$FFBA
                    lbsr      L00FD
                    leax      >$04EB,y
                    tfr       x,d
                    lbsr      L2715
                    leax      >L2364,pcr
                    pshs      x
                    leax      >L2353,pcr
                    tfr       x,d
                    bsr       L2066
                    leas      $02,s
                    leax      >L237A,pcr
                    pshs      x
                    leax      >L236D,pcr
L2055               tfr       x,d
                    bsr       L2066
                    leas      $02,s
                    leax      >$00B6,y
L205F               tfr       x,d
                    lbsr      L2715
                    puls      pc,u
L2066               pshs      u
                    tfr       d,u
                    ldd       #$FF72
                    lbsr      L00FD
                    leas      <-$40,s
                    ldd       <u0047
                    lbeq      L20E9
                    lbsr      L0FD1
                    pshs      u
                    leax      $02,s
                    tfr       x,d
                    lbsr      L241D
                    leas      $02,s
                    leax      >L237F,pcr
                    pshs      x
                    leax      $02,s
                    tfr       x,d
                    lbsr      L2435
                    leas      $02,s
                    pshs      u
                    leax      $02,s
                    tfr       x,d
                    lbsr      L2435
                    leas      $02,s
                    leax      >L2382,pcr
                    pshs      x
                    leax      $02,s
                    tfr       x,d
                    lbsr      L2435
                    leas      $02,s
                    ldd       #$003C
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    pshs      b,a
                    leax      $06,s
                    pshs      x
                    tfr       x,d
                    lbsr      L240A
                    pshs      b,a
                    leax      >L2387,pcr
                    tfr       x,d
                    lbsr      L27FE
                    leas      $0A,s
                    std       <$3E,s
                    cmpd      #$FFFF
                    lbne      L215B
                    ldd       #$000A
                    pshs      b,a
                    leax      >L238C,pcr
                    lbra      L2154
L20E9               pshs      u
                    leax      $02,s
                    tfr       x,d
                    lbsr      L241D
                    leas      $02,s
                    leax      >L23A0,pcr
                    pshs      x
                    leax      $02,s
                    tfr       x,d
                    lbsr      L2435
                    leas      $02,s
                    ldd       <$44,s
                    pshs      b,a
                    leax      $02,s
                    tfr       x,d
                    lbsr      L2435
                    leas      $02,s
                    leax      >L23A3,pcr
                    pshs      x
                    leax      $02,s
                    tfr       x,d
                    lbsr      L2435
                    leas      $02,s
                    ldd       #$003C
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    pshs      b,a
                    leax      $06,s
                    pshs      x
                    tfr       x,d
                    lbsr      L240A
                    pshs      b,a
                    leax      >L23A5,pcr
                    tfr       x,d
                    lbsr      L27FE
                    leas      $0A,s
                    std       <$3E,s
                    cmpd      #$FFFF
                    bne       L215B
                    ldd       #$0013
                    pshs      b,a
                    leax      >L23AA,pcr
L2154               tfr       x,d
                    lbsr      L168D
                    leas      $02,s
L215B               leax      <$3C,s
                    tfr       x,d
                    lbsr      L27C0
                    ldd       <$3C,s
                    beq       L21AF
                    lbsr      L1334
                    ldd       #$0002
                    pshs      b,a
                    leax      >L23BE,pcr
                    pshs      x
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0010
                    pshs      b,a
                    leax      >L23C1,pcr
                    pshs      x
                    ldd       #$0002
                    lbsr      L2681
                    leas      $04,s
                    tfr       u,d
                    lbsr      L240A
                    pshs      b,a
                    pshs      u
                    ldd       #$0002
                    lbsr      L2681
                    leas      $04,s
                    ldd       #$0002
                    pshs      b,a
                    leax      >L23D2,pcr
                    pshs      x
                    lbsr      L2681
                    leas      $04,s
L21AF               leas      <$40,s
                    puls      pc,u
L21B4               pshs      u,b,a
                    ldd       #$FFBA
                    lbsr      L00FD
                    ldu       ,s
                    bra       L21CA
L21C0               ldb       ,u
                    sex
                    lbsr      L23ED
                    stb       ,u
                    leau      u0001,u
L21CA               ldb       ,u
                    bne       L21C0
                    leas      $02,s
                    puls      pc,u

L21D2               fcc       "copy"
                    fcb       $00
L21D7               fcc       "/dd"
                    fcb       $00
L21DB               fcc       "asm"
                    fcb       $00
L21DF               fcc       "Can't open help file"
                    fcb       $00
L21f4               fcc       "Can't create CMDS directory"
                    fcb       $00
L2210               fcc       "Can't create SYS directory"
                    fcb       $00
L222B               fcc       "Can't create DEFS directory"
                    fcb       $00
L2247               fcc       "/dd/DEFS/OS9Defs"
                    fcb       $00
L2258               fcc       "OS9Defs"
                    fcb       $00
L2260               fcc       "/dd/DEFS/RBFDefs"
                    fcb       $00
L2271               fcc       "RBFDefs"
                    fcb       $00
L2279               fcc       "/dd/DEFS/SCFDefs"
                    fcb       $00
L228A               fcc       "SCFDefs"
                    fcb       $00
L2292               fcc       "/dd/DEFS/SysType"
                    fcb       $00
L22A3               fcc       "SysType"
                    fcb       $00
L22AB               fcc       "/dd/DEFS/defsfile"
                    fcb       $00
L22BD               fcc       "defsfile"
                    fcb       $00
L22C6               fcc       "/dd"
                    fcb       $00
L22CA               fcc       "/d1"
                    fcb       $00
L22CE               fcc       "Can't open commands file"
                    fcb       $00
L22E7               fcc       "Error reading commands file"
                    fcb       $00
L2303               fcc       "Error reading commands file"
                    fcb       $00
L231F               fcc       "/dd/startup"
                    fcb       $00
L232B               fcc       "startup"
                    fcb       $00
L2333               fcc       "/dd/CMDS/"
                    fcb       $00
L233D               fcc       "/dd/SYS/errmsg"
                    fcb       $00
L234C               fcc       "errmsg"
                    fcb       $00
L2353               fcc       "/dd/SYS/password"
                    fcb       $00
L2364               fcc       "password"
                    fcb       $00
L236D               fcc       "/dd/SYS/motd"
                    fcb       $00
L237A               fcc       "motd"
                    fcb       $00
L237F               fcc       "  "
                    fcb       $00
L2382               fcc       " -s"
                    fcb       C$CR,$00
L2387               fcc       "copy"
                    fcb       $00
L238C               fcc       "Can't fork the copy"
                    fcb       $00
L23A0               fcc       "  "
                    fcb       $00
L23A3               fcb       C$CR
                    fcb       $00
L23A5               fcc       "copy"
                    fcb       $00
L23AA               fcc       "Can't fork the copy"
                    fcb       $00
L23BE               fcb       C$CR,C$LF,$00
L23C1               fcc       "Error copying : "
                    fcb       $00
L23D2               fcb       C$CR,C$LF,$00

                    fcb       $34,$46
                    ldd       ,s
                    leax      >$0507,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$04
                    beq       L2404
                    ldd       ,s
                    clra
                    andb      #$DF
                    bra       L2406
L23ED               pshs      u,b,a
                    ldd       ,s
                    leax      >$0507,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$02
                    beq       L2404
                    ldd       ,s
                    orb       #$20
                    bra       L2406
L2404               ldd       ,s
L2406               leas      $02,s
                    puls      pc,u
L240A               pshs      u,b,a
                    ldu       ,s
L240E               ldb       ,u+
                    bne       L240E
                    tfr       u,d
                    subd      ,s
                    addd      #$FFFF
                    leas      $02,s
                    puls      pc,u
L241D               pshs      u,b,a
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L2427               ldb       ,u+
                    ldx       ,s
L242B               leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2427
                    bra       L245C
L2435               pshs      u,b,a
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L243F               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L243F
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L2450               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2450
L245C               ldd       $02,s
                    leas      $04,s
                    puls      pc,u
L2462               pshs      u
                    tfr       d,u
                    bra       L2478
L2468               ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       -$01,x
                    bne       L2476
                    clra
                    clrb
                    puls      pc,u
L2476               leau      u0001,u
L2478               ldb       ,u
                    sex
                    pshs      b,a
                    ldb       [<$06,s]
                    sex
                    cmpd      ,s++
                    beq       L2468
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
L249A               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    ble       L24BE
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L249A
                    bra       L24BE
L24B4               clra
                    clrb
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L24BE               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    bgt       L24B4
                    lbra      L254D
                    pshs      u
                    tfr       d,u
                    bra       L24E3
L24D3               ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       -$01,x
                    bne       L24E1
                    clra
                    clrb
                    puls      pc,u
L24E1               leau      u0001,u
L24E3               ldd       $06,s
                    addd      #$FFFF
                    std       $06,s
                    subd      #$FFFF
                    ble       L24FD
                    ldb       ,u
                    sex
                    pshs      b,a
                    ldb       [<$06,s]
                    sex
                    cmpd      ,s++
                    beq       L24D3
L24FD               ldd       $06,s
                    bge       L2505
                    clra
                    clrb
                    bra       L2510
L2505               ldb       [<$04,s]
                    sex
                    pshs      b,a
                    ldb       ,u
                    sex
                    subd      ,s++
L2510               puls      pc,u
                    pshs      u,b,a
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L251C               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L251C
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L252D               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    ble       L2545
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L252D
L2545               ldd       $0A,s
                    bge       L254D
                    clra
                    clrb
                    stb       [,s]
L254D               ldd       $02,s
                    leas      $04,s
                    puls      pc,u
L2553               pshs      u,b,a
                    ldu       ,s
L2557               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
                    bgt       L2557
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
L2574               lda       $03,s
                    tstb
                    beq       L25A6
                    cmpb      #$01
                    beq       L25A8
                    cmpb      #$06
                    beq       L25A8
                    cmpb      #$02
                    beq       L258E
                    cmpb      #$05
                    beq       L258E
                    ldb       #$D0
                    lbra      L2836
L258E               pshs      u
                    os9       I$GetStt
                    bcc       L259A
                    puls      u
                    lbra      L2836
L259A               stx       [<$06,s]
                    ldx       $06,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts
L25A6               ldx       $04,s
L25A8               os9       I$GetStt
                    lbra      L283F
L25AE               lda       $03,s
                    tstb
                    beq       L25BC
                    cmpb      #$02
                    beq       L25C4
                    ldb       #$D0
                    lbra      L2836
L25BC               ldx       $04,s
                    os9       I$SetStt
                    lbra      L283F
L25C4               pshs      u
                    ldx       $06,s
                    ldu       $08,s
                    os9       I$SetStt
                    puls      u
                    lbra      L283F
                    tfr       d,x
                    lda       $03,s
                    os9       I$Open
                    bcs       L25DE
                    os9       I$Close
L25DE               lbra      L283F
L25E1               tfr       d,x
                    lda       $03,s
                    os9       I$Open
                    bcs       L2643
                    tfr       a,b
                    clra
                    rts
L25EE               tfr       b,a
                    os9       I$Close
                    lbra      L283F
L25F6               tfr       d,x
                    ldb       $03,s
                    os9       I$MakDir
                    lbra      L283F
L2600               pshs      b,a
                    ldx       ,s
                    lda       $05,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0B
                    os9       I$Create
                    bcs       L2617
L2611               leas      $02,s
                    tfr       a,b
                    clra
                    rts
L2617               cmpb      #$DA
                    bne       L2641
                    lda       $05,s
                    bita      #$80
                    bne       L2641
                    anda      #$07
                    ldx       ,s
                    os9       I$Open
                    bcs       L2641
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L2611
                    pshs      b
                    os9       I$Close
                    puls      b
L2641               leas      $02,s
L2643               lbra      L2836
L2646               tfr       d,x
                    os9       I$Delete
                    lbra      L283F
                    tfr       b,a
                    os9       I$Dup
                    bcs       L2643
                    tfr       a,b
                    clra
                    rts
L2659               pshs      y
                    tfr       b,a
                    ldx       $04,s
                    ldy       $06,s
                    os9       I$Read
                    bcc       L267D
L2667               cmpb      #$D3
                    bne       L2691
                    clra
                    clrb
                    puls      pc,y
L266F               pshs      y
                    tfr       b,a
                    ldx       $04,s
                    ldy       $06,s
                    os9       I$ReadLn
                    bcs       L2667
L267D               tfr       y,d
                    puls      pc,y
L2681               pshs      y
                    ldy       $06,s
                    beq       L26A6
                    tfr       b,a
                    ldx       $04,s
                    os9       I$Write
                    bcc       L26A6
L2691               puls      y
                    lbra      L2836
L2696               pshs      y
                    ldy       $06,s
                    beq       L26A6
                    tfr       b,a
                    ldx       $04,s
                    os9       I$WritLn
                    bcs       L2691
L26A6               tfr       y,d
                    puls      pc,y
L26AA               pshs      u,b,a
                    ldd       $0A,s
                    bne       L26B8
                    ldu       #$0000
                    ldx       #$0000
                    bra       L26EE
L26B8               cmpd      #$0001
                    beq       L26E5
                    cmpd      #$0002
                    beq       L26DA
                    ldb       #$F7
L26C6               clra
                    std       >$0597,y
                    ldd       #$FFFF
                    leax      >$058B,y
                    std       ,x
                    std       $02,x
                    leas      $02,s
                    puls      pc,u
L26DA               lda       $01,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L26C6
                    bra       L26EE
L26E5               lda       $01,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L26C6
L26EE               tfr       u,d
                    addd      $08,s
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L26C6
                    tfr       d,x
                    stx       >$058B,y
                    stu       >$058D,y
                    lda       $01,s
                    os9       I$Seek
                    bcs       L26C6
                    leax      >$058B,y
                    leas      $02,s
                    puls      pc,u
L2715               tfr       d,x
                    lda       #$01
L2719               os9       I$ChgDir
                    lbra      L283F
                    tfr       d,x
                    lda       #$04
                    bra       L2719
L2725               pshs      y,b,a
                    cmpd      >$0641,y
                    bls       L275C
                    subd      >$0641,y
                    addd      >$0589,y
                    subd      $02,s
                    os9       F$Mem
                    tfr       y,d
                    ldy       $02,s
                    bcc       L2748
                    ldd       #$FFFF
                    leas      $04,s
                    rts
L2748               ldx       >$0589,y
                    std       >$0589,y
                    pshs      x
                    subd      ,s++
                    addd      >$0641,y
                    std       >$0641,y
L275C               ldd       >$0589,y
                    subd      >$0641,y
                    tfr       d,x
                    ldd       >$0641,y
                    subd      ,s
                    std       >$0641,y
                    ldd       ,s
                    stx       ,s
                    bitb      #$01
                    beq       L277B
                    clr       ,x+
                    decb
L277B               tfr       d,y
                    leay      ,y
                    beq       L2789
                    clra
                    clrb
L2783               std       ,x++
                    leay      -$02,y
                    bne       L2783
L2789               puls      pc,y,b,a
                    addd      >$0593,y
                    bcs       L27B2
                    cmpd      >$0595,y
                    bcc       L27B2
                    pshs      b,a
                    ldx       >$0593,y
                    clra
                    bra       L27A3
L27A1               sta       ,x+
L27A3               cmpx      ,s
                    bcs       L27A1
                    ldd       >$0593,y
                    puls      x
                    stx       >$0593,y
                    rts
L27B2               ldd       #$FFFF
                    rts
                    tfr       b,a
                    ldb       $03,s
                    os9       F$Send
                    lbra      L283F
L27C0               tfr       d,x
                    clra
                    clrb
                    os9       F$Wait
                    lbcs      L2836
                    stx       -$02,s
                    beq       L27D3
                    stb       $01,x
                    clr       ,x
L27D3               tfr       a,b
                    clra
                    rts
                    tfr       b,a
                    ldb       $03,s
                    os9       F$SPrior
                    lbra      L283F
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
L27FE               pshs      u,y
                    tfr       d,x
                    ldy       $06,s
                    ldu       $08,s
                    lda       $0B,s
                    ora       $0D,s
                    ldb       $0F,s
                    os9       F$Fork
                    puls      u,y
                    lbcs      L2836
                    tfr       a,b
                    clra
                    rts
L281A               pshs      u
                    tfr       y,u
                    std       >$0643,y
                    leax      >L282E,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      L283F
L282E               tfr       u,y
                    clra
                    jsr       [>$0643,y]
                    rti
L2836               clra
                    std       >$0597,y
                    ldd       #$FFFF
                    rts
L283F               bcs       L2836
                    clra
                    clrb
                    rts
L2844               pshs      b,a
                    lbsr      L2851
                    lbsr      L2852
                    puls      b,a
L284E               os9       F$Exit
L2851               rts
L2852               rts
                    pshs      u,y
                    tfr       d,x
                    lda       $07,s
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       $09,s
                    os9       F$Link
L2862               tfr       u,d
                    puls      u,y
                    lbcs      L2836
                    rts
L286B               pshs      u,y
                    tfr       d,x
                    lda       $07,s
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       $09,s
                    os9       F$Load
                    bra       L2862
                    pshs      u
                    tfr       d,u
                    os9       F$UnLink
                    puls      u
                    lbra      L283F
L2888               ldd       $02,s
                    cmpd      ,x
                    bne       L28A1
                    ldd       $04,s
                    cmpd      $02,x
                    beq       L28A1
                    bcs       L289E
                    lda       #$01
                    andcc     #$FE
                    bra       L28A1
L289E               clra
                    cmpa      #$01
L28A1               pshs      cc
                    ldd       $01,s
                    std       $05,s
                    puls      cc
                    leas      $04,s
                    rts
L28AC               leax      >$058B,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts
                    leax      >$058B,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
                    rts
L28C5               tsta
                    bne       L28DA
                    tst       $02,s
                    bne       L28DA
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,b,a
L28DA               pshs      b,a
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
                    bcc       L28F7
                    inc       ,s
L28F7               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L2904
                    inc       ,s
L2904               lda       $04,s
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

L2918               fcb       $00
                    fcc       ")"
                    fcb       $00
                    fcc       "->"
                    fcb       $00
                    fcc       "  "
                    fcb       $00
L2921               fcc       "bootlist"
                    fcb       $00

                    fcc       "RBF.mn"
                    fcb       $00
                    fcc       "SCF.mn"
                    fcb       $00
                    fcc       "PIPEMAN.mn"
                    fcb       $00
                    fcb       $04
                    fcs       "y"
                    fcc       "/DD/MODULES"
                    fcb       $00
                    fcc       ".dd"
                    fcb       $00
                    fcc       ".DD"
                    fcb       $00
                    fcc       ".io"
                    fcb       $00
                    fcc       ".IO"
                    fcb       $00
                    fcc       ".dr"
                    fcb       $00
                    fcc       ".mn"
                    fcb       $00
                    fcc       ".hp"
                    fcb       $00
                    fcc       ".."
                    fcb       $00
                    fcc       "THERE ARE STILL MORE"
                    fcb       $00
                    fcc       "ARE YOU SURE (Y/N) ?"
                    fcb       $00
                    fcc       "CONFIG"
                    fcb       $00
                    fcc       "ARROWS - UP/DOWN/MORE/BACK"
                    fcb       $00
                    fcc       "S - SEL/UNSEL H - HELP D - DONE"
                    fcb       $00
                    fcc       "DEVICE NAME     SEL"
                    fcb       $00
                    fcc       "COMMAND NAME    SEL"
                    fcb       $00
                    fcc       "I/O SUBROUTINE  SEL"
                    fcb       $00
                    fcc       " ------------------------------"
                    fcb       $00
                    fcc       "M - MORE    C - CONTINUE"
                    fcb       $00
                    fcc       " HIT ANY KEY TO CONTINUE"
                    fcb       $00
                    fcc       "BUILDING DESCRIPTOR LIST"
                    fcb       $00
                    fcc       ".... PLEASE WAIT"
                    fcb       $00
                    fcc       "BUILDING BOOT LIST"
                    fcb       $00
                    fcc       "GENERATING A NEW BOOT"
                    fcb       $00
                    fcc       "PLACE A FORMATTED DISK"
                    fcb       $00
                    fcc       "IN DRIVE NUMBER 1"
                    fcb       $00
                    fcc       "DO YOU WISH TO ADD"
                    fcb       $00
                    fcc       "[N]O COMMANDS, STOP NOW"
                    fcb       $00
                    fcc       "[B]ASIC COMMAND SET"
                    fcb       $00
                    fcc       "[F]ULL COMMAND SET"
                    fcb       $00
                    fcc       "[I]NIDIVIDUALLY SELECT"
                    fcb       $00
                    fcc       "[?] RECIEVE HELP"
                    fcb       $00
                    fcc       "SELECTION [N,B,F,I,?]"
                    fcb       $00
                    fcc       "PLACE YOUR SYSTEM DISK"
                    fcb       $00
                    fcc       "IN DRIVE NUMBER 0"
                    fcb       $00
                    fcc       "HOW MANY DRIVES DO YOU HAVE:"
                    fcb       $00
                    fcc       "1 - ONE DRIVE ONLY"
                    fcb       $00
                    fcc       "2 - TWO OR MORE DRIVES"
                    fcb       $00
                    fcc       "SELECTION [1,2] "
                    fcb       $00
                    fcc       "PLACE NEW DISK IN /DD NOW"
                    fcb       $00
                    fcc       "PLACE CONFIG DISK IN /DD NOW"
                    fcb       $00
                    fcc       "CREATING NEW SYSTEM DISK"
                    fcb       $00
                    fcc       "DESTINATION = NEW DISK"
                    fcb       $00
                    fcc       "SOURCE = CONFIG DISK"
                    fcb       $00
                    fcc       "SOURCE = OS9 SYSTEM DISK"
                    fcb       $00
                    fcc       "WHAT CLOCK MODULE IS NEEDED:"
                    fcb       $00
                    fcc       "1 - 60 HZ (AMERICAN POWER)"
                    fcb       $00
                    fcc       "2 - 50 HZ (EUROPEAN POWER)"
                    fcb       $00
                    fcc       "RS VERSION 01.00.00"
                    fcb       $00
                    fcc       "COPYRIGHT 1985 BY"
                    fcb       $00
                    fcc       "MICROWARE SYSTEMS CORP."
                    fcb       $00
                    fcc       "REPRODUCED UNDER LICENSE"
                    fcb       $00
                    fcc       "TO TANDY CORP."
                    fcb       $00
                    fcc       "ALL RIGHTS RESERVED"
                    fcb       $00
                    fcc       "os9gen /d1  #15k </dd/bootlist"
                    fcb       C$CR,$00
                    fcc       "os9gen /dd -s #15k </dd/bootlist"
                    fcb       C$CR,$00,$05,$dd
                    fcc       "CMDS"
                    fcb       $00
                    fcc       "SYS"
                    fcb       $00
                    fcc       "DEFS"
                    fcb       $00
                    fcc       "cmds.hp"
                    fcb       $00
                    fcc       "config.hp"

                    fdb       $0000,$0101
                    fdb       $0101,$0101,$0101,$0111,$1101,$1111,$0101,$0101
                    fdb       $0101,$0101,$0101,$0101,$0101,$0101,$0101,$3020
                    fdb       $2020,$2020,$2020,$2020,$2020,$2020,$2020,$4848
                    fdb       $4848,$4848,$4848,$4848,$2020,$2020,$2020,$2042
                    fdb       $4242,$4242,$4202,$0202,$0202,$0202,$0202,$0202
                    fdb       $0202,$0202,$0202,$0202,$0220,$2020,$2020,$2044
                    fdb       $4444,$4444,$4404,$0404,$0404,$0404,$0404,$0404
                    fdb       $0404,$0404,$0404,$0404,$0420,$2020,$2001,$0000
                    fdb       $0001,$04e4,$636f,$6e66,$6967
                    fcb       $00

                    emod
eom                 equ       *
                    end
