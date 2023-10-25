                    nam       c.prep
                    ttl       C-compiler preprocessor

* Disassembled 02/08/25 13:23:49 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       4
                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       2
u0006               rmb       2
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       1
u000C               rmb       1
u000D               rmb       4
u0011               rmb       3
u0014               rmb       2
u0016               rmb       2
u0018               rmb       2
u001A               rmb       2
u001C               rmb       4
u0020               rmb       5
u0025               rmb       2
u0027               rmb       1
u0028               rmb       7
u002F               rmb       5
u0034               rmb       46
u0062               rmb       2
u0064               rmb       1
u0065               rmb       4
u0069               rmb       3
u006C               rmb       1
u006D               rmb       1
u006E               rmb       5
u0073               rmb       117
u00E8               rmb       150
u017E               rmb       2
u0180               rmb       58
u01BA               rmb       1
u01BB               rmb       3
u01BE               rmb       5452
size                equ       .
name                equ       *
                    fcs       /c.prep/
                    fcb       edition

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
                    leax      >$058A,x
                    pshs      x
                    leay      >L2633,pcr
                    ldx       ,y++
                    beq       L003E
                    bsr       L0014
                    ldu       $02,s
L003E               leau      >u001C,u
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
                    leax      >u0000,pcr
                    lbsr      L0162
L005F               ldd       ,y++
                    beq       L0068
                    leax      ,u
                    lbsr      L0162
L0068               leas      $04,s
                    puls      x
                    stx       >u01BE,u
                    sty       >u017E,u
                    ldd       #$0001
                    std       >u01BA,u
                    leay      >u0180,u
                    leax      ,s
                    lda       ,x+
L0084               ldb       >u01BB,u
                    cmpb      #$1D
                    beq       L00E0
L008C               cmpa      #$0D
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
                    inc       >u01BB,u
                    pshs      a
L00AC               lda       ,x+
                    cmpa      #$0D
                    beq       L00B6
                    cmpa      ,s
                    bne       L00AC
L00B6               puls      b
                    clr       -$01,x
                    cmpa      #$0D
                    beq       L00E0
                    lda       ,x+
                    bra       L0084
L00C2               leax      -$01,x
                    stx       ,y++
                    leax      $01,x
                    inc       >u01BB,u
L00CC               cmpa      #$0D
                    beq       L00DC
                    cmpa      #$20
                    beq       L00DC
                    cmpa      #$2C
                    beq       L00DC
                    lda       ,x+
                    bra       L00CC
L00DC               clr       -$01,x
                    bra       L0084
L00E0               leax      >u017E,u
                    pshs      x
                    ldd       >u01BA,u
                    pshs      b,a
                    leay      ,u
                    bsr       L00FA
                    lbsr      L018E
                    clr       ,-s
                    clr       ,-s
                    lbsr      L2627
L00FA               leax      >$058A,y
                    stx       >$01C8,y
                    sts       >$01BC,y
                    sts       >$01CA,y
                    ldd       #$FF82
L010F               leax      d,s
                    cmpx      >$01CA,y
                    bcc       L0121
                    cmpx      >$01C8,y
                    bcs       L013B
                    stx       >$01CA,y
L0121               rts

L0122               fcc       /**** STACK OVERFLOW ****/
                    fcb       $0D
L013B               leax      <L0122,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
L0148               os9       I$WritLn
                    clr       ,-s
                    lbsr      L262D

L0150               ldd       >$01BC,y
                    subd      >$01CA,y
                    rts

                    ldd       >$01CA,y
                    subd      >$01C8,y
L0161               rts

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
L017B               rts

L017C               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldd       #$0002
                    pshs      b,a
                    lbsr      L2627
                    puls      pc,u,x

L018E               pshs      u
                    ldd       #$FFB0
                    lbsr      L010F
                    leas      -$04,s
                    ldd       #$0800
                    pshs      b,a
                    lbsr      L15DB
                    leas      $02,s
                    leax      >L017C,pcr
                    pshs      x
                    lbsr      L25F7
                    lbra      L0366
L01AE               ldx       $0A,s
                    leax      $02,x
                    stx       $0A,s
                    ldb       [,x]
                    cmpb      #$2B
                    beq       L01C4
                    ldx       $0A,s
                    ldb       [,x]
                    cmpb      #$2D
                    lbne      L0290
L01C4               ldu       [<$0A,s]
                    leau      u0001,u
                    ldb       ,u
                    sex
                    tfr       d,x
                    lbra      L0271
L01D1               ldd       #$0001
                    std       <u0016
                    lbra      L0368
L01D9               leau      u0001,u
                    ldb       ,u
                    cmpb      #$3D
                    lbne      L0368
                    leax      u0001,u
                    stx       >$001C,y
                    lbra      L0368
L01EC               leau      u0001,u
                    ldb       ,u
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$06
                    bne       L0206
                    ldb       ,u
                    cmpb      #$5F
                    lbne      L025B
L0206               stu       $02,s
                    bra       L0211
L020A               ldd       $02,s
                    addd      #$0001
                    std       $02,s
L0211               ldb       [<$02,s]
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$0E
                    bne       L020A
                    ldb       [<$02,s]
                    cmpb      #$5F
                    lbeq      L020A
                    ldb       [<$02,s]
                    sex
                    std       ,s
                    clra
                    clrb
                    stb       [<$02,s]
                    ldd       ,s
                    cmpd      #$003D
                    bne       L0247
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
                    bra       L024D
L0247               leax      >L0379,pcr
                    stx       $02,s
L024D               ldd       $02,s
                    pshs      b,a
                    pshs      u
                    lbsr      L0A11
                    leas      $04,s
                    lbra      L0368
L025B               ldd       [<$0A,s]
                    pshs      b,a
                    ldd       #$0031
                    pshs      b,a
                    lbsr      L14D8
                    leas      $04,s
                    leax      >L037B,pcr
                    lbra      L0357
L0271               cmpx      #$006C
                    lbeq      L01D1
                    cmpx      #$0045
                    lbeq      L01D9
                    cmpx      #$0065
                    lbeq      L01D9
                    cmpx      #$0044
                    lbeq      L01EC
                    lbra      L0368
L0290               leax      >L038B,pcr
                    pshs      x
                    ldd       [<$0C,s]
                    pshs      b,a
                    lbsr      L187D
                    leas      $04,s
                    std       <u000A
                    lbeq      L0344
                    leas      -$02,s
                    ldd       #$0001
                    std       ,s
                    ldd       [<$0C,s]
                    pshs      b,a
                    leax      >$04CE,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    leax      >$04CE,y
                    pshs      x
                    lbsr      L0E72
                    std       ,s
                    leax      >$04EC,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    leax      >$04EC,y
                    pshs      x
                    leax      >$04CE,y
                    pshs      x
                    ldd       #$0037
                    pshs      b,a
                    lbsr      L14D8
                    leas      $06,s
                    ldd       >$001C,y
                    pshs      b,a
                    leax      >$04EC,y
                    pshs      x
                    ldd       #$0050
                    pshs      b,a
                    lbsr      L14D8
                    leas      $06,s
                    lbsr      L03A6
                    bra       L0339
L0304               ldd       <u000C
                    addd      #$FFFF
                    cmpd      ,s
                    beq       L0321
                    ldd       <u000C
                    addd      #$FFFF
                    std       ,s
                    pshs      b,a
                    ldd       #$0035
                    pshs      b,a
                    lbsr      L14D8
                    leas      $04,s
L0321               leax      >$02CE,y
                    pshs      x
                    leax      >L038D,pcr
                    pshs      x
                    lbsr      L18CF
                    leas      $04,s
                    ldd       ,s
                    addd      #$0001
                    std       ,s
L0339               lbsr      L03C1
                    cmpd      #$FFFF
                    bne       L0304
                    bra       L0366
L0344               ldd       [<$0A,s]
                    pshs      b,a
                    ldd       #$0031
                    pshs      b,a
                    lbsr      L14D8
                    leas      $04,s
                    leax      >L0391,pcr
L0357               pshs      x
                    lbsr      L18CF
                    leas      $02,s
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L2627
L0366               leas      $02,s
L0368               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    lbne      L01AE
                    leas      $04,s
                    puls      pc,u

L0377               fcb       $30
                    fcb       $00

L0379               fcb       $31
                    fcb       $00
L037B               fcb       $30
                    fcb       $0D
L037D               fcb       $30
                    fcb       $0D

L037F               fcc       "bad define"
                    fcb       $0D
                    fcb       $00
L038B               fcc       "r"
                    fcb       $00
L038D               fcc       "%s"
                    fcb       $0D
                    fcb       $00
L0391               fcb       $30
                    fcb       $0D
                    fcb       $30
                    fcb       $0D

L0395               fcc       "can't open file"
                    fcb       $0D
                    fcb       $00

L03A6               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    leax      >$02CE,y
                    stx       <u0008
                    clra
                    clrb
                    stb       >$02CE,y
                    ldd       #$0020
                    stb       <u0003
                    puls      pc,u

L03C1               pshs      u
                    ldd       #$FEAD
                    lbsr      L010F
                    leas      >-$010B,s
                    leax      >$02CE,y
                    pshs      x
                    leax      >$03CE,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    bra       L03E4
L03E0               leas      >-$010B,x
L03E4               lbsr      L10DD
                    std       -$02,s
                    lbeq      L056F
                    lbra      L0575
L03F0               ldd       <u0008
                    std       <u0004
L03F4               clra
                    clrb
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldb       <u0003
                    cmpb      #$20
                    beq       L03F4
                    ldb       <u0003
                    cmpb      #$09
L0407               lbeq      L03F4
                    ldd       <u0008
                    std       <u0004
                    ldb       <u0003
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$06
                    lbeq      L055D
                    leax      >$0100,s
                    pshs      x
                    lbsr      L106D
                    leas      $02,s
                    leax      >$0100,s
                    pshs      x
                    leax      >L12E8,pcr
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L044C
                    ldd       #$0001
L0444               pshs      b,a
                    lbsr      L0987
                    lbra      L0566
L044C               leax      >$0100,s
                    pshs      x
                    leax      >L12EF,pcr
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L0467
                    lbsr      L0C7A
                    lbra      L0568
L0467               leax      >$0100,s
                    pshs      x
                    leax      >L12F7,pcr
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L0487
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L0EEE
                    lbra      L0566
L0487               leax      >$0100,s
                    pshs      x
                    leax      >L12FD,pcr
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L04A6
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L0EEE
                    lbra      L0566
L04A6               leax      >$0100,s
                    pshs      x
                    leax      >L1304,pcr
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L04C1
                    lbsr      L0FDE
                    lbra      L0568
L04C1               leax      >$0100,s
                    pshs      x
                    leax      >L130A,pcr
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L04DC
                    lbsr      L0F9D
                    lbra      L0568
L04DC               leax      >$0100,s
                    pshs      x
                    leax      >L130F,pcr
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L04F6
                    clra
                    clrb
                    lbra      L0444
L04F6               leax      >$0100,s
                    pshs      x
                    leax      >L1315,pcr
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L051A
                    ldd       >$001E,y
                    beq       L0568
                    ldd       #$0001
L0514               std       >$04FB,y
                    bra       L0568
L051A               leax      >$0100,s
                    pshs      x
                    leax      >L1319,pcr
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L0539
                    ldd       >$001E,y
                    beq       L0568
                    clra
                    clrb
                    bra       L0514
L0539               leax      >$0100,s
                    pshs      x
                    leax      >L1320,pcr
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L0553
                    lbsr      L0DE1
                    bra       L0568
L0553               leax      >$010B,s
                    bra       L0559
L0559               leas      >-$010B,x
L055D               leax      >L1325,pcr
                    pshs      x
                    lbsr      L1434
L0566               leas      $02,s
L0568               lbsr      L10DD
                    std       -$02,s
                    bne       L0575
L056F               ldd       #$FFFF
                    lbra      L05DA
L0575               clra
                    clrb
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldb       <u0003
                    cmpb      #$23
                    lbeq      L03F0
                    ldd       >$001E,y
                    beq       L05D3
                    ldd       >$04FB,y
                    beq       L05A4
                    leax      >$02CE,y
                    pshs      x
                    ldd       #$0032
                    pshs      b,a
                    lbsr      L14D8
                    leas      $04,s
                    bra       L05D3
L05A4               leax      ,s
                    stx       <u0006
                    leax      >$02CE,y
                    stx       <u0008
                    pshs      x
                    bsr       L05E0
                    leas      $02,s
                    leax      ,s
                    pshs      x
                    lbsr      L0C61
                    leas      $02,s
                    leax      ,s
                    pshs      x
                    leax      >$02CE,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    ldd       #$0020
                    bra       L05DA
                    bra       L05DA
L05D3               leax      >$010B,s
                    lbra      L03E0
L05DA               leas      >$010B,s
                    puls      pc,u

L05E0               pshs      u
                    ldd       #$FE72
                    lbsr      L010F
                    leas      <-$38,s
                    ldd       <u0008
                    std       <$21,s
                    ldd       <$3C,s
                    std       <u0008
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    lbra      L092E
L0602               ldb       <u0003
                    cmpb      #$27
                    beq       L060E
                    ldb       <u0003
                    cmpb      #$22
                    bne       L0630
L060E               leax      >$0006,y
                    pshs      x
                    lbsr      L1024
                    leas      $02,s
                    ldb       <u0003
                    ldx       <u0006
                    leax      $01,x
                    stx       <u0006
                    stb       -$01,x
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    lbra      L092E
L0630               ldb       <u0003
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$06
                    bne       L0648
                    ldb       <u0003
                    cmpb      #$5F
                    lbne      L08CE
L0648               leax      <$18,s
                    pshs      x
                    lbsr      L106D
                    leas      $02,s
                    leax      <$18,s
                    pshs      x
                    lbsr      L0944
                    leas      $02,s
                    std       ,s
                    lbeq      L08B8
                    leas      >-$010C,s
                    ldb       <u0003
                    cmpb      #$20
                    bne       L0671
                    ldd       #$0001
                    bra       L0673
L0671               clra
                    clrb
L0673               std       ,s
                    ldx       >$010C,s
                    ldu       $02,x
                    lbsr      L1176
                    ldb       <u0003
                    cmpb      #$28
                    lbne      L088F
                    ldx       >$010C,s
                    ldd       $04,x
                    lbeq      L088F
                    clra
                    clrb
                    std       >$0122,s
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    lbra      L078D
L06A3               leas      -$04,s
                    ldd       >$0126,s
                    lslb
                    rola
                    leax      >$0133,s
                    leax      d,x
                    pshs      x
                    ldd       <u0008
                    addd      #$FFFF
                    std       [,s++]
                    clra
                    clrb
                    std       $0A,s
                    std       $02,s
                    lbra      L0764
L06C3               ldb       <u0003
                    sex
                    tfr       d,x
                    lbra      L0732
L06CB               ldd       $02,s
                    lbne      L0753
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    bra       L06E8
L06DD               ldd       $02,s
                    beq       L06E8
                    ldd       $02,s
                    addd      #$FFFF
                    bra       L06F4
L06E8               leax      >$0148,s
                    lbra      L076C
L06EF               ldd       $02,s
                    addd      #$0001
L06F4               std       $02,s
                    lbra      L0753
L06F9               ldb       <u0003
                    sex
                    std       ,s
L06FE               ldb       <u0003
                    cmpb      #$5C
                    bne       L0714
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldd       $0A,s
                    addd      #$0001
                    std       $0A,s
L0714               clra
                    clrb
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldd       $0A,s
                    addd      #$0001
                    std       $0A,s
                    ldb       <u0003
                    beq       L0753
                    ldb       <u0003
                    sex
                    cmpd      ,s
                    bne       L06FE
                    bra       L0753
L0732               cmpx      #$002C
                    lbeq      L06CB
                    cmpx      #$0029
                    lbeq      L06DD
                    cmpx      #$0028
                    lbeq      L06EF
                    cmpx      #$0027
                    beq       L06F9
                    cmpx      #$0022
                    lbeq      L06F9
L0753               ldd       $0A,s
                    addd      #$0001
                    std       $0A,s
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
L0764               ldb       <u0003
                    lbne      L06C3
                    bra       L0770
L076C               leas      >-$0148,x
L0770               ldd       >$0126,s
                    lslb
                    rola
                    leax      >$0112,s
                    leax      d,x
                    ldd       $0A,s
                    std       ,x
                    ldd       >$0126,s
                    addd      #$0001
                    std       >$0126,s
                    leas      $04,s
L078D               ldb       <u0003
                    beq       L0799
                    ldb       <u0003
                    cmpb      #$29
                    lbne      L06A3
L0799               ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    leax      $08,s
                    stx       >$0108,s
                    ldb       ,u+
                    sex
                    std       $02,s
L07AE               ldd       $02,s
                    cmpd      #$0040
                    lbne      L0825
                    ldb       ,u+
                    sex
                    std       $02,s
                    addd      #$FFD0
                    std       $04,s
                    blt       L0814
                    ldd       $04,s
                    cmpd      >$0122,s
                    bge       L0814
                    ldd       $04,s
                    lslb
                    rola
                    leax      >$010E,s
                    leax      d,x
                    ldd       ,x
                    std       $06,s
                    ldd       $04,s
                    lslb
                    rola
                    leax      >$012F,s
                    leax      d,x
                    ldd       ,x
                    std       >$010A,s
                    bra       L0805
L07ED               ldx       >$010A,s
                    leax      $01,x
                    stx       >$010A,s
                    ldb       -$01,x
                    ldx       >$0108,s
                    leax      $01,x
                    stx       >$0108,s
                    stb       -$01,x
L0805               ldd       $06,s
                    addd      #$FFFF
                    std       $06,s
                    subd      #$FFFF
                    bne       L07ED
                    lbra      L087A
L0814               ldd       #$0040
                    ldx       >$0108,s
                    leax      $01,x
                    stx       >$0108,s
                    stb       -$01,x
                    bra       L086C
L0825               ldd       $02,s
                    cmpd      #$0027
                    beq       L0835
                    ldd       $02,s
                    cmpd      #$0022
                    bne       L086C
L0835               leas      -$01,s
                    ldd       $03,s
                    stb       ,s
L083B               ldd       $03,s
                    ldx       >$0109,s
                    leax      $01,x
                    stx       >$0109,s
                    stb       -$01,x
                    ldb       ,u+
                    sex
                    std       $03,s
                    ldd       $03,s
                    beq       L085A
                    ldb       ,s
                    sex
                    cmpd      $03,s
                    bne       L083B
L085A               ldd       $03,s
                    ldx       >$0109,s
                    leax      $01,x
                    stx       >$0109,s
                    stb       -$01,x
                    leas      $01,s
                    bra       L087A
L086C               ldd       $02,s
                    ldx       >$0108,s
                    leax      $01,x
                    stx       >$0108,s
                    stb       -$01,x
L087A               ldd       $02,s
                    beq       L0887
                    ldb       ,u+
                    sex
                    std       $02,s
                    lbne      L07AE
L0887               clra
                    clrb
                    stb       [>$0108,s]
                    leau      $08,s
L088F               ldb       <u0003
                    stb       >$0143,s
                    pshs      u
                    lbsr      L05E0
                    leas      $02,s
                    ldb       >$0143,s
                    stb       <u0003
                    ldd       ,s
                    beq       L08B1
                    ldd       #$0020
                    ldx       <u0006
                    leax      $01,x
                    stx       <u0006
                    stb       -$01,x
L08B1               leas      >$010C,s
                    lbra      L092E
L08B8               leau      <$18,s
                    bra       L08C7
L08BD               ldb       ,u+
                    ldx       <u0006
                    leax      $01,x
                    stx       <u0006
                    stb       -$01,x
L08C7               ldb       ,u
                    bne       L08BD
                    lbra      L092E
L08CE               ldb       <u0003
                    cmpb      #$30
                    bne       L091A
                    ldb       <u0003
                    ldx       <u0006
                    leax      $01,x
                    stx       <u0006
                    stb       -$01,x
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldb       <u0003
                    cmpb      #$78
                    beq       L08F4
                    ldb       <u0003
                    cmpb      #$58
                    bne       L092E
L08F4               ldb       <u0003
                    ldx       <u0006
                    leax      $01,x
                    stx       <u0006
                    stb       -$01,x
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldb       <u0003
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$40
                    bne       L08F4
                    bra       L092E
L091A               ldb       <u0003
                    ldx       <u0006
                    leax      $01,x
                    stx       <u0006
                    stb       -$01,x
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
L092E               ldb       <u0003
                    lbne      L0602
                    clra
                    clrb
                    stb       [>$0006,y]
                    ldd       <$21,s
                    std       <u0008
                    leas      <$38,s
                    puls      pc,u

L0944               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    leas      -$02,s
                    ldd       $06,s
                    pshs      b,a
                    lbsr      L153E
                    leas      $02,s
                    lslb
                    rola
                    leax      >$01CE,y
                    leax      d,x
                    ldu       ,x
                    bra       L097F
L0963               ldd       ,s
                    addd      #$0006
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    beq       L097B
                    ldu       ,u
                    bra       L097F
L097B               tfr       u,d
                    puls      pc,u,x
L097F               stu       ,s
                    bne       L0963
                    clra
                    clrb
                    puls      pc,u,x

L0987               pshs      u
                    ldd       #$FFAF
                    lbsr      L010F
                    leas      -$09,s
                    ldd       >$001E,y
                    lbeq      L09EE
                    lbsr      L11BD
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldb       <u0003
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$06
                    bne       L09BC
                    ldb       <u0003
                    cmpb      #$5F
                    bne       L09E3
L09BC               leax      ,s
                    pshs      x
                    lbsr      L106D
                    leas      $02,s
                    ldd       $0D,s
                    cmpd      #$0001
                    bne       L09DB
                    clra
                    clrb
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    bsr       L0A11
                    leas      $04,s
                    bra       L09EE
L09DB               leax      ,s
                    pshs      x
                    bsr       L09F2
                    bra       L09EC
L09E3               leax      >L1331,pcr
                    pshs      x
                    lbsr      L144D
L09EC               leas      $02,s
L09EE               leas      $09,s
                    puls      pc,u

L09F2               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    bra       L0A00
L09FC               clra
                    clrb
                    stb       u0006,u
L0A00               ldd       $04,s
                    pshs      b,a
                    lbsr      L0944
                    leas      $02,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L09FC
                    puls      pc,u

L0A11               pshs      u
                    ldd       #$FE91
                    lbsr      L010F
                    leas      >-$0127,s
                    ldd       #$0006
                    pshs      b,a
                    lbsr      L1574
                    leas      $02,s
                    std       >$0125,s
                    tfr       d,u
                    ldd       >$012B,s
                    pshs      b,a
                    lbsr      L153E
                    leas      $02,s
                    std       >$0123,s
                    lslb
                    rola
                    leax      >$01CE,y
                    leax      d,x
                    ldd       ,x
                    std       >$011F,s
                    ldd       >$0123,s
                    lslb
                    rola
                    leax      >$01CE,y
                    leax      d,x
                    ldd       >$0125,s
                    std       ,x
                    ldd       >$011F,s
                    std       [>$0125,s]
                    ldd       >$012B,s
                    pshs      b,a
                    lbsr      L15F7
                    leas      $02,s
                    ldd       <u0001
                    ldx       >$0125,s
                    std       $02,x
                    ldd       >$012D,s
                    beq       L0A8E
                    ldd       >$012D,s
                    pshs      b,a
                    lbsr      L15F7
                    leas      $02,s
                    lbsr      L155E
                    lbra      L0C5B
L0A8E               clra
                    clrb
                    std       ,s
                    ldb       <u0003
                    cmpb      #$28
                    lbne      L0B36
                    ldd       #$0001
                    ldx       >$0125,s
                    std       $04,x
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    leau      <$1F,s
                    bra       L0AB2
L0AB2               lbsr      L1176
                    ldb       <u0003
                    lbeq      L0B2C
                    ldb       <u0003
                    cmpb      #$29
                    lbeq      L0B2C
                    ldd       ,s
                    lslb
                    rola
                    leax      $02,s
                    leax      d,x
                    stu       ,x
                    ldb       <u0003
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$06
                    bne       L0AE3
                    ldb       <u0003
                    cmpb      #$5F
                    bne       L0B1E
L0AE3               leax      <$16,s
                    pshs      x
                    lbsr      L106D
                    leas      $02,s
                    leax      <$16,s
                    stx       >$011F,s
L0AF4               ldx       >$011F,s
                    leax      $01,x
                    stx       >$011F,s
                    ldb       -$01,x
                    stb       ,u+
                    bne       L0AF4
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    lbsr      L1176
                    ldb       <u0003
                    cmpb      #$2C
                    bne       L0B29
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    bra       L0B27
L0B1E               leax      >L1344,pcr
                    pshs      x
                    lbsr      L144D
L0B27               leas      $02,s
L0B29               lbra      L0AB2
L0B2C               ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
L0B36               lbsr      L1176
                    lbra      L0C4C
L0B3C               ldb       <u0003
                    cmpb      #$27
                    beq       L0B48
                    ldb       <u0003
                    cmpb      #$22
                    bne       L0B52
L0B48               ldb       <u0003
                    sex
                    orb       #$80
                    stb       <u0003
                    lbra      L0C4C
L0B52               ldb       <u0003
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$06
                    bne       L0B6A
                    ldb       <u0003
                    cmpb      #$5F
                    lbne      L0BEC
L0B6A               leax      <$16,s
                    pshs      x
                    lbsr      L106D
                    leas      $02,s
                    clra
                    clrb
                    bra       L0BB2
L0B78               ldd       >$0123,s
                    lslb
                    rola
                    leax      $02,s
                    leax      d,x
                    ldd       ,x
                    pshs      b,a
                    leax      <$18,s
                    pshs      x
                    lbsr      L2270
                    leas      $04,s
                    std       -$02,s
                    bne       L0BAB
                    ldd       #$0040
                    stb       <$16,s
                    ldd       >$0123,s
                    addd      #$0030
                    stb       <$17,s
                    clra
                    clrb
                    stb       <$18,s
                    bra       L0BBF
L0BAB               ldd       >$0123,s
                    addd      #$0001
L0BB2               std       >$0123,s
                    ldd       >$0123,s
                    cmpd      ,s
                    blt       L0B78
L0BBF               leax      <$16,s
                    stx       >$011F,s
                    bra       L0BD3
L0BC8               ldd       >$0121,s
                    pshs      b,a
                    lbsr      L1614
                    leas      $02,s
L0BD3               ldx       >$011F,s
                    leax      $01,x
                    stx       >$011F,s
                    ldb       -$01,x
                    sex
                    std       >$0121,s
                    bne       L0BC8
                    lbsr      L155E
                    lbra      L0C4C
L0BEC               ldb       <u0003
                    cmpb      #$30
                    bne       L0C38
                    ldb       <u0003
                    sex
                    pshs      b,a
                    lbsr      L1614
                    leas      $02,s
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldb       <u0003
                    cmpb      #$78
                    beq       L0C12
                    ldb       <u0003
                    cmpb      #$58
                    bne       L0C4C
L0C12               ldb       <u0003
                    sex
                    pshs      b,a
                    lbsr      L1614
                    leas      $02,s
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldb       <u0003
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$40
                    bne       L0C12
                    bra       L0C4C
L0C38               ldb       <u0003
                    sex
                    pshs      b,a
                    lbsr      L1614
                    leas      $02,s
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
L0C4C               ldb       <u0003
                    lbne      L0B3C
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L1614
                    leas      $02,s
L0C5B               leas      >$0127,s
                    puls      pc,u

L0C61               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    ldu       $04,s
                    bra       L0C74
L0C6D               ldb       ,u+
                    clra
                    andb      #$7F
                    stb       -u0001,u
L0C74               ldb       ,u
                    bne       L0C6D
                    puls      pc,u

L0C7A               pshs      u
                    ldd       #$FF90
                    lbsr      L010F
                    leas      <-$26,s
                    ldd       >$001E,y
                    lbeq      L0DDC
                    lbsr      L11BD
                    ldd       <u0008
                    std       <u0004
                    leau      $04,s
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldb       <u0003
                    sex
                    std       ,s
                    cmpd      #$0022
                    beq       L0CB5
                    ldd       ,s
                    cmpd      #$003C
                    lbne      L0DD1
L0CB5               clra
                    clrb
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldd       ,s
                    cmpd      #$003C
                    bne       L0D11
                    ldd       #$003E
                    std       ,s
                    ldb       >$04FD,y
                    bne       L0CF3
                    leax      >L135B,pcr
                    pshs      x
                    leax      >$04FD,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    leax      >L135F,pcr
                    pshs      x
                    leax      >$04FD,y
                    pshs      x
                    lbsr      L2245
                    leas      $04,s
L0CF3               leax      >$04FD,y
                    pshs      x
                    pshs      u
                    lbsr      L14BF
                    leas      $04,s
                    tfr       d,u
                    bra       L0D11
L0D04               ldb       <u0003
                    stb       ,u+
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
L0D11               ldb       <u0003
                    beq       L0D1D
                    ldb       <u0003
                    sex
                    cmpd      ,s
                    bne       L0D04
L0D1D               clra
                    clrb
                    stb       ,u
                    leax      >L1366,pcr
                    pshs      x
                    leax      $06,s
                    pshs      x
                    lbsr      L187D
                    leas      $04,s
                    std       <$22,s
                    lbeq      L0DCB
                    ldd       #$0017
                    pshs      b,a
                    lbsr      L1574
                    leas      $02,s
                    std       $02,s
                    ldd       <u0014
                    std       [<$02,s]
                    ldd       <u000C
                    ldx       $02,s
                    std       $02,x
                    ldd       <u000A
                    ldx       $02,s
                    std       $04,x
                    leax      >$04CE,y
                    pshs      x
                    lbsr      L15F7
                    leas      $02,s
                    ldx       $02,s
                    std       $06,x
                    leax      >$04EC,y
                    pshs      x
                    ldd       $04,s
                    addd      #$0008
                    pshs      b,a
                    lbsr      L222B
                    leas      $04,s
                    leax      $04,s
                    pshs      x
                    leax      >$04CE,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    leax      $04,s
                    pshs      x
                    lbsr      L0E72
                    std       ,s
                    leax      >$04EC,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    leax      >$04EC,y
                    pshs      x
                    leax      >$04CE,y
                    pshs      x
                    ldd       #$0037
                    pshs      b,a
                    lbsr      L14D8
                    leas      $06,s
                    ldd       $02,s
                    std       <u0014
                    clra
                    clrb
                    pshs      b,a
                    ldd       #$0035
                    pshs      b,a
                    lbsr      L14D8
                    leas      $04,s
                    clra
                    clrb
                    std       <u000C
                    ldd       <$22,s
                    std       <u000A
                    bra       L0DDC
L0DCB               leax      >L1368,pcr
                    bra       L0DD5
L0DD1               leax      >L1373,pcr
L0DD5               pshs      x
                    lbsr      L140B
                    leas      $02,s
L0DDC               leas      <$26,s
                    puls      pc,u

L0DE1               pshs      u
                    ldd       #$FFAB
                    lbsr      L010F
                    leas      -$0B,s
                    ldd       >$001E,y
                    lbeq      L0E6E
                    lbsr      L11BD
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    leax      ,s
                    pshs      x
                    lbsr      L106D
                    leas      $02,s
                    leax      ,s
                    pshs      x
                    lbsr      L22A1
                    leas      $02,s
                    std       $09,s
                    beq       L0E1A
                    ldd       $09,s
                    std       <u000C
L0E1A               lbsr      L11BD
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    leax      ,s
                    pshs      x
                    lbsr      L106D
                    leas      $02,s
                    ldb       ,s
                    beq       L0E58
                    leax      ,s
                    pshs      x
                    leax      >$04CE,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    leax      >$04CE,y
                    pshs      x
                    bsr       L0E72
                    std       ,s
                    leax      >$04EC,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
L0E58               leax      >$04EC,y
                    pshs      x
                    leax      >$04CE,y
                    pshs      x
                    ldd       #$0037
                    pshs      b,a
                    lbsr      L14D8
                    leas      $06,s
L0E6E               leas      $0B,s
                    puls      pc,u

L0E72               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$04,s
                    bra       L0E88
L0E80               ldd       ,s
                    cmpd      #$002F
                    bne       L0E8A
L0E88               stu       $02,s
L0E8A               ldb       ,u+
                    sex
                    std       ,s
                    bne       L0E80
                    leau      >$0511,y
                    ldb       [<$02,s]
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    beq       L0EC3
                    ldd       #$005F
                    bra       L0EC1
L0EAB               ldd       ,s
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$0E
                    bne       L0EBF
                    ldd       #$005F
                    std       ,s
L0EBF               ldd       ,s
L0EC1               stb       ,u+
L0EC3               ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    ldb       -$01,x
                    sex
                    std       ,s
                    beq       L0EE0
                    leax      >$0511,y
                    pshs      x
                    tfr       u,d
                    subd      ,s++
                    cmpd      #$000E
                    ble       L0EAB
L0EE0               clra
                    clrb
                    stb       ,u
                    leax      >$0511,y
                    tfr       x,d
                    leas      $04,s
                    puls      pc,u

L0EEE               pshs      u
                    ldd       #$FFB1
                    lbsr      L010F
                    leas      -$09,s
                    ldd       >$0534,y
                    cmpd      #$000A
                    bne       L0F08
                    leax      >L1384,pcr
                    bra       L0F33
L0F08               lbsr      L11BD
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldd       <u0008
                    std       <u0004
                    ldb       <u0003
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$06
                    bne       L0F3D
                    ldb       <u0003
                    cmpb      #$5F
                    beq       L0F3D
                    leax      >L139B,pcr
L0F33               pshs      x
                    lbsr      L144D
                    leas      $02,s
                    lbra      L0F99
L0F3D               leax      ,s
                    pshs      x
                    lbsr      L106D
                    leas      $02,s
                    ldd       >$0534,y
                    lslb
                    rola
                    leax      >$0536,y
                    leax      d,x
                    ldd       >$054A,y
                    std       ,x
                    ldd       #$0001
                    std       >$054A,y
                    ldd       >$0534,y
                    addd      #$0001
                    std       >$0534,y
                    subd      #$0001
                    lslb
                    rola
                    leax      >$0520,y
                    leax      d,x
                    ldd       >$001E,y
                    std       ,x
                    std       -$02,s
                    beq       L0F99
                    leax      ,s
                    pshs      x
                    lbsr      L0944
                    std       ,s++
                    bne       L0F8F
                    ldd       #$0001
                    bra       L0F91
L0F8F               clra
                    clrb
L0F91               eora      $0D,s
                    eorb      $0E,s
                    std       >$001E,y
L0F99               leas      $09,s
                    puls      pc,u

L0F9D               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldd       >$054A,y
                    bne       L0FB6
                    leax      >L13B4,pcr
                    pshs      x
                    lbsr      L144D
                    puls      pc,u,x
L0FB6               ldd       >$0534,y
                    addd      #$FFFF
                    lslb
                    rola
                    leax      >$0520,y
                    leax      d,x
                    ldd       ,x
                    beq       L0FD4
                    ldd       >$001E,y
                    bne       L0FD4
                    ldd       #$0001
                    bra       L0FD6
L0FD4               clra
                    clrb
L0FD6               std       >$001E,y
                    clra
                    clrb
                    bra       L101E

L0FDE               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldd       >$0534,y
                    bne       L0FF7
                    leax      >L13C9,pcr
                    pshs      x
                    lbsr      L144D
                    puls      pc,u,x
L0FF7               ldd       >$0534,y
                    addd      #$FFFF
                    std       >$0534,y
                    lslb
                    rola
                    leax      >$0520,y
                    leax      d,x
                    ldd       ,x
                    std       >$001E,y
                    ldd       >$0534,y
                    lslb
                    rola
                    leax      >$0536,y
                    leax      d,x
                    ldd       ,x
L101E               std       >$054A,y
                    puls      pc,u

L1024               pshs      u
                    ldd       #$FFB9
                    lbsr      L010F
                    leas      -$01,s
                    ldu       [<$05,s]
                    ldb       <u0003
                    stb       ,s
L1035               ldb       <u0003
                    stb       ,u+
                    ldb       <u0003
                    cmpb      #$5C
                    bne       L104C
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldb       <u0003
                    stb       ,u+
L104C               clra
                    clrb
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldb       <u0003
                    beq       L1066
                    ldb       <u0003
                    sex
                    pshs      b,a
                    ldb       $02,s
                    sex
                    cmpd      ,s++
                    bne       L1035
L1066               stu       [<$05,s]
                    leas      $01,s
                    puls      pc,u

L106D               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    ldd       #$0001
                    bra       L1091
L107E               ldb       <u0003
                    stb       ,u+
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
                    ldd       ,s
                    addd      #$0001
L1091               std       ,s
                    ldd       ,s
                    cmpd      #$0009
                    bge       L10B3
                    ldb       <u0003
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$0E
                    bne       L107E
                    ldb       <u0003
                    cmpb      #$5F
                    lbeq      L107E
L10B3               clra
                    clrb
                    stb       ,u
                    bra       L10C3
L10B9               ldd       #$0001
                    pshs      b,a
                    lbsr      L1191
                    leas      $02,s
L10C3               ldb       <u0003
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$0E
                    bne       L10B9
                    ldb       <u0003
                    cmpb      #$5F
                    lbeq      L10B9
                    puls      pc,u,x

L10DD               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
L10E5               lbsr      L1257
                    std       -$02,s
                    beq       L1105
                    ldd       <u0016
                    beq       L1100
                    leax      >$02CE,y
                    pshs      x
                    ldd       #$0036
                    pshs      b,a
                    lbsr      L14D8
                    leas      $04,s
L1100               ldd       #$0001
                    puls      pc,u
L1105               ldd       <u000A
                    pshs      b,a
                    lbsr      L1EC5
                    leas      $02,s
                    ldd       <u0014
                    lbeq      L1170
                    ldx       <u0014
                    ldd       $04,x
                    std       <u000A
                    ldx       <u0014
                    ldd       $02,x
                    std       <u000C
                    ldx       <u0014
                    ldd       $06,x
                    pshs      b,a
                    leax      >$04CE,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    ldd       <u0014
                    addd      #$0008
                    pshs      b,a
                    leax      >$04EC,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    ldd       [>$0014,y]
                    std       <u0014
                    leax      >$04EC,y
                    pshs      x
                    leax      >$04CE,y
                    pshs      x
                    ldd       #$0037
                    pshs      b,a
                    lbsr      L14D8
                    leas      $06,s
                    ldd       <u000C
                    pshs      b,a
                    ldd       #$0035
                    pshs      b,a
                    lbsr      L14D8
                    leas      $04,s
                    lbra      L10E5
L1170               clra
                    clrb
                    puls      pc,u
                    puls      pc,u

L1176               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    bra       L1189
L1180               ldd       #$0001
                    pshs      b,a
                    bsr       L1191
                    leas      $02,s
L1189               ldb       <u0003
                    cmpb      #$20
                    beq       L1180
                    puls      pc,u

L1191               pshs      u
                    ldd       #$FFBC
                    lbsr      L010F
                    ldb       [>$0008,y]
                    stb       <u0003
                    bne       L11A3
                    puls      pc,u
L11A3               ldd       $04,s
                    beq       L11B4
                    bsr       L11BD
                    std       -$02,s
                    beq       L11B4
                    ldd       #$0020
                    stb       <u0003
                    bra       L11BB
L11B4               ldd       <u0008
                    addd      #$0001
                    std       <u0008
L11BB               puls      pc,u

L11BD               pshs      u
                    ldd       #$FFB9
                    lbsr      L010F
                    leas      -$03,s
                    clra
                    clrb
L11C9               std       ,s
L11CB               ldb       [>$0008,y]
                    stb       $02,s
                    sex
                    tfr       d,x
                    lbra      L1235
L11D7               ldd       #$0020
                    stb       [>$0008,y]
L11DE               ldd       <u0008
                    addd      #$0001
                    std       <u0008
                    ldd       #$0001
                    bra       L11C9
L11EA               ldx       <u0008
                    ldb       $01,x
                    cmpb      #$2A
                    bne       L1231
                    ldd       #$0001
                    std       ,s
                    ldd       <u0008
                    addd      #$0002
                    bra       L1211
L11FE               ldb       $02,s
                    bne       L120C
                    bsr       L1257
                    std       -$02,s
                    bne       L1213
                    bra       L1231
                    bra       L1213
L120C               ldd       <u0008
                    addd      #$0001
L1211               std       <u0008
L1213               ldb       [>$0008,y]
                    stb       $02,s
                    cmpb      #$2A
                    bne       L11FE
                    ldx       <u0008
                    ldb       $01,x
                    cmpb      #$2F
                    lbne      L11FE
                    ldd       <u0008
                    addd      #$0002
                    std       <u0008
                    lbra      L11CB
L1231               ldd       ,s
                    bra       L1253
L1235               cmpx      #$000C
                    lbeq      L11D7
                    cmpx      #$0009
                    lbeq      L11D7
                    cmpx      #$0020
                    lbeq      L11DE
                    cmpx      #$002F
                    lbeq      L11EA
                    bra       L1231
L1253               leas      $03,s
                    puls      pc,u

L1257               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    leas      -$04,s
                    ldd       #$0100
                    std       $02,s
                    leax      >$02CE,y
                    stx       <u0008
                    leau      ,x
                    ldd       <u000A
                    pshs      b,a
                    lbsr      L1FEC
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L12AB
                    ldx       <u000A
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L1293
                    leax      >L13DA,pcr
                    pshs      x
                    lbsr      L140B
                    leas      $02,s
L1293               clra
                    clrb
                    stb       ,u
                    sex
                    bra       L12E4
                    bra       L12AB
L129C               ldd       ,s
                    stb       ,u+
                    ldd       <u000A
                    pshs      b,a
                    lbsr      L1FEC
                    leas      $02,s
                    std       ,s
L12AB               ldd       ,s
                    cmpd      #$000D
                    beq       L12C7
                    ldd       ,s
                    cmpd      #$FFFF
                    beq       L12C7
                    ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bgt       L129C
L12C7               ldd       $02,s
                    bge       L12D6
                    leax      >L13F1,pcr
                    pshs      x
                    lbsr      L140B
                    leas      $02,s
L12D6               clra
                    clrb
                    stb       ,u
                    ldd       <u000C
                    addd      #$0001
                    std       <u000C
                    ldd       #$0001
L12E4               leas      $04,s
                    puls      pc,u

L12E8               fcc       "define"
                    fcb       $00
L12EF               fcc       "include"
                    fcb       $00
L12F7               fcc       "ifdef"
                    fcb       $00
L12FD               fcc       "ifndef"
                    fcb       $00
L1304               fcc       "endif"
                    fcb       $00
L130A               fcc       "else"
                    fcb       $00
L130F               fcc       "undef"
                    fcb       $00
L1315               fcc       "asm"
                    fcb       $00
L1319               fcc       "endasm"
                    fcb       $00
L1320               fcc       "line"
                    fcb       $00
L1325               fcc       "illegal '#'"
                    fcb       $00
L1331               fcc       "illegal macro name"
                    fcb       $00
L1344               fcc       "macro definition error"
                    fcb       $00
L135B               fcc       "/dd"
                    fcb       $00
L135F               fcc       "/defs/"
                    fcb       $00
L1366               fcc       "r"
                    fcb       $00
L1368               fcc       "can't open"
                    fcb       $00
L1373               fcc       "bad include file"
                    fcb       $00
L1384               fcc       "'#if' nesting too deep"
                    fcb       $00
L139B               fcc       "illegal '#if' macro name"
                    fcb       $00
L13B4               fcc       "no '#if' for '#else'"
                    fcb       $00
L13C9               fcc       "too many #endifs"
                    fcb       $00
L13DA               fcc       "source file read error"
                    fcb       $00
L13F1               fcc       "source file line too long"
                    fcb       $00

L140B               pshs      u
                    ldd       #$0031
                    pshs      b,a
                    ldd       <u000C
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    leax      >$02CE,y
                    pshs      x
                    ldd       <u0004
                    subd      ,s++
                    pshs      b,a
                    bsr       L146E
                    leas      $08,s
                    ldd       #$0001
                    pshs      b,a
                    lbsr      L2627
                    puls      pc,u,x

L1434               pshs      u
                    ldd       #$0030
                    pshs      b,a
L143B               ldd       <u000C
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    leax      >$02CE,y
                    pshs      x
                    ldd       <u0004
                    bra       L1464

L144D               pshs      u
                    ldd       #$0030
                    pshs      b,a
                    ldd       <u000C
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    leax      >$02CE,y
                    pshs      x
                    ldd       <u0008
L1464               subd      ,s++
                    pshs      b,a
                    bsr       L146E
L146A               leas      $08,s
                    puls      pc,u

L146E               pshs      u
                    ldd       $08,s
                    cmpd      <u000C
                    bne       L147D
                    leau      >$02CE,y
                    bra       L1491
L147D               ldd       <u000C
                    addd      #$FFFF
                    cmpd      $08,s
                    bne       L148D
                    leau      >$03CE,y
                    bra       L1491
L148D               leau      >L1673,pcr

L1491               pshs      u
                    ldd       $0C,s
                    pshs      b,a
                    bsr       L14D8
                    leas      $04,s
                    ldd       $08,s
                    pshs      b,a
                    leax      >L1674,pcr
                    pshs      x
                    lbsr      L18CF
                    leas      $04,s
                    ldd       $06,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    leax      >L1678,pcr
                    pshs      x
                    lbsr      L18CF
                    leas      $06,s
                    puls      pc,u

L14BF               pshs      u
                    ldu       $04,s
L14C3               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
                    bne       L14C3
                    pshs      u
                    ldd       #$FFFF
                    addd      ,s++
                    puls      pc,u

L14D8               pshs      u
                    ldx       $04,s
                    bra       L1529
L14DE               ldd       $08,s
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    ldd       #$0023
                    pshs      b,a
                    leax      >L167F,pcr
                    pshs      x
                    lbsr      L18CF
                    leas      $0A,s
                    bra       L153C
L14FC               ldd       $06,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldd       #$0023
                    pshs      b,a
                    leax      >L168B,pcr
                    bra       L1520
L150F               ldd       $06,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldd       #$0023
                    pshs      b,a
                    leax      >L1694,pcr
L1520               pshs      x
                    lbsr      L18CF
                    leas      $08,s
                    bra       L153C
L1529               cmpx      #$0037
                    beq       L14DE
                    cmpx      #$0050
                    lbeq      L14DE
                    cmpx      #$0035
                    beq       L14FC
                    bra       L150F
L153C               puls      pc,u

L153E               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L154C
L1548               ldd       $02,s
                    addd      ,s
L154C               std       $02,s
                    ldb       ,u+
                    sex
                    std       ,s
                    bne       L1548
                    ldd       $02,s
                    clra
                    andb      #$7F
                    leas      $04,s
                    puls      pc,u

L155E               pshs      u
                    ldd       <u0001
                    cmpd      <u001A
                    bcs       L1572
                    ldd       #$0100
                    pshs      b,a
                    bsr       L1574
                    leas      $02,s
                    std       <u0001
L1572               puls      pc,u

L1574               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       <u0001
                    std       ,s
                    ldd       <u0001
                    cmpd      <u0018
                    bls       L15B4
                    leax      >L169D,pcr
                    pshs      x
                    lbsr      L140B
                    leas      $02,s
                    bra       L15B4
L1592               ldd       #$0100
                    pshs      b,a
                    lbsr      L2573
                    leas      $02,s
                    cmpd      #$FFFF
                    bne       L15AD
                    leax      >L16AA,pcr
                    pshs      x
                    lbsr      L140B
                    leas      $02,s
L15AD               ldd       <u0018
                    addd      #$0100
                    std       <u0018
L15B4               ldd       <u0018
                    subd      <u0001
                    pshs      b,a
                    pshs      u
                    ldd       #$0020
                    addd      ,s++
                    cmpd      ,s++
                    bhi       L1592
                    ldd       <u0018
                    addd      #$FFE0
                    std       <u001A
                    ldd       <u0001
                    pshs      b,a
                    tfr       u,d
                    addd      ,s++
                    std       <u0001
                    ldd       ,s
                    puls      pc,u,x

L15DB               pshs      u
                    ldd       $04,s
                    pshs      b,a
                    lbsr      L2573
                    leas      $02,s
                    std       <u0001
                    ldd       <u0001
                    addd      $04,s
                    std       <u0018
                    ldd       <u0018
                    addd      #$FFE0
                    std       <u001A
                    puls      pc,u

L15F7               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       <u0001
                    std       ,s
L1601               ldb       ,u+
                    ldx       <u0001
                    leax      $01,x
                    stx       <u0001
                    stb       -$01,x
                    bne       L1601
                    lbsr      L155E
                    ldd       ,s
                    puls      pc,u,x

L1614               pshs      u
                    ldb       $05,s
                    ldx       <u0001
                    leax      $01,x
                    stx       <u0001
                    stb       -$01,x
                    lbsr      L155E
                    ldd       <u0001
                    addd      #$FFFF
                    puls      pc,u
                    pshs      u,b,a
                    clra
                    clrb
                    pshs      b,a
                    ldd       #$0004
                    pshs      b,a
                    leax      >L16B8,pcr
                    pshs      x
                    lbsr      L253E
                    leas      $06,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L164D
                    lbsr      L16C1
                    bra       L166F

L164D               pshs      u
                    ldd       u0009,u
                    addd      ,s++
                    std       ,s
                    pshs      b,a
                    leax      >$054C,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    pshs      u
                    lbsr      L2567
                    leas      $02,s
                    leax      >$054C,y
                    tfr       x,d
L166F               puls      pc,u,x
                    puls      pc,u,x
L1673               fcb       $00
L1674               fcc       "%d"
                    fcb       $0D
                    fcb       $00
L1678               fcc       "%d"
                    fcb       $0D
                    fcc       "%s"
                    fcb       $0D
                    fcb       $00
L167F               fcc       "%c%c"
                    fcb       $0D
                    fcc       "%s"
                    fcb       $0D
                    fcc       "%s"
                    fcb       $0D
                    fcb       $00
L168B               fcc       "%c%c"
                    fcb       $0D
                    fcc       "%d"
                    fcb       $0D
                    fcb       $00
L1694               fcc       "%c%c"
                    fcb       $0D
                    fcc       "%s"
                    fcb       $0D
                    fcb       $00

L169D               fcc       "grab overlap"
                    fcb       $00

L16AA               fcc       "out of memory"
                    fcb       $00
L16B8               fcc       "ccdevice"
                    fcb       $00

L16C1               pshs      u
                    leas      -$07,s
                    clra
                    clrb
                    pshs      b,a
                    ldd       #$000C
                    pshs      b,a
                    leax      >L1722,pcr
                    pshs      x
                    lbsr      L253E
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    beq       L171C
                    ldd       ,s
                    ldx       ,s
                    addd      <$10,x
                    std       $05,s
                    leau      >$0560,y
                    bra       L16F4
L16F0               ldb       $04,s
L16F2               stb       ,u+
L16F4               ldx       $05,s
                    leax      $01,x
                    stx       $05,s
                    ldb       -$01,x
                    stb       $04,s
                    bgt       L16F0
                    ldb       $04,s
                    clra
                    andb      #$7F
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       ,s
                    pshs      b,a
                    lbsr      L2567
                    leas      $02,s
                    leax      >$0560,y
                    tfr       x,d
                    bra       L171E
L171C               clra
                    clrb
L171E               leas      $07,s
                    puls      pc,u

L1722               fcc       "Init"
                    fcb       $00

L1727               pshs      u
                    leau      >$002D,y
L172D               ldd       u0006,u
                    clra
                    andb      #$03
                    lbeq      L179E
                    leau      u000D,u
                    pshs      u
                    leax      >$00FD,y
                    cmpx      ,s++
                    bhi       L172D
                    ldd       #$00C8
                    std       >$01CC,y
                    lbra      L17A2
                    puls      pc,u

L174E               pshs      u
                    ldu       $08,s
                    bne       L1758
                    bsr       L1727
                    tfr       d,u
L1758               stu       -$02,s
                    beq       L17A2
                    ldd       $04,s
                    std       u0008,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2B
                    beq       L1770
                    ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2B
                    bne       L1776
L1770               ldd       u0006,u
                    orb       #$03
                    bra       L1794
L1776               ldd       u0006,u
                    pshs      b,a
                    ldb       [<$08,s]
                    cmpb      #$72
                    beq       L1788
                    ldb       [<$08,s]
                    cmpb      #$64
                    bne       L178D
L1788               ldd       #$0001
                    bra       L1790
L178D               ldd       #$0002
L1790               ora       ,s+
                    orb       ,s+
L1794               std       u0006,u
                    ldd       u0002,u
                    addd      u000B,u
                    std       u0004,u
                    std       ,u
L179E               tfr       u,d
                    puls      pc,u
L17A2               clra
                    clrb
                    puls      pc,u

L17A6               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0A,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L17D7
L17B9               ldx       $0A,s
                    ldb       $02,x
                    cmpb      #$2B
                    bne       L17C6
                    ldd       #$0007
                    bra       L17CE
L17C6               ldd       #$0004
                    bra       L17CE
L17CB               ldd       #$0003
L17CE               std       ,s
                    bra       L17E7
L17D2               leax      $04,s
                    lbra      L183F
L17D7               stx       -$02,s
                    beq       L17E7
                    cmpx      #$0078
                    beq       L17B9
                    cmpx      #$002B
                    beq       L17CB
                    bra       L17D2
L17E7               ldb       [<$0A,s]
                    sex
                    tfr       d,x
                    lbra      L184C
L17F0               ldd       ,s
                    orb       #$01
                    bra       L1832
L17F6               ldd       ,s
                    orb       #$02
                    pshs      b,a
                    pshs      u
                    lbsr      L2405
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L1821
                    ldd       #$0002
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    lbsr      L24D7
                    leas      $08,s
                    bra       L1866
L1821               ldd       ,s
                    orb       #$02
                    pshs      b,a
                    pshs      u
                    lbsr      L2426
                    bra       L1839
L182E               ldd       ,s
                    orb       #$81
L1832               pshs      b,a
                    pshs      u
                    lbsr      L2405
L1839               leas      $04,s
                    std       $02,s
                    bra       L1866
L183F               leas      -$04,x
L1841               ldd       #$00CB
                    std       >$01CC,y
                    clra
                    clrb
                    bra       L1868
L184C               cmpx      #$0072
                    lbeq      L17F0
                    cmpx      #$0061
                    lbeq      L17F6
                    cmpx      #$0077
                    beq       L1821
                    cmpx      #$0064
                    beq       L182E
                    bra       L1841
L1866               ldd       $02,s
L1868               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    lbra      L18C8

L187D               pshs      u
                    ldd       $06,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    lbsr      L17A6
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L1898
                    clra
                    clrb
                    bra       L18CD
L1898               clra
                    clrb
                    bra       L18C0
                    pshs      u
                    ldd       $08,s
                    pshs      b,a
                    lbsr      L1EC5
                    leas      $02,s
                    ldd       $06,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    lbsr      L17A6
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L18BE
                    clra
                    clrb
                    bra       L18CD
L18BE               ldd       $08,s
L18C0               pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    pshs      u
L18C8               lbsr      L174E
                    leas      $06,s
L18CD               puls      pc,u

L18CF               pshs      u
                    leax      >$003A,y
                    stx       >$056C,y
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
                    bra       L18EF
                    pshs      u
                    ldd       $04,s
                    std       >$056C,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L18EF               pshs      b,a
                    leax      >L1DA9,pcr
                    pshs      x
                    bsr       L1921
                    leas      $06,s
                    puls      pc,u
                    pshs      u
                    ldd       $04,s
                    std       >$056C,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      b,a
                    leax      >L1DBC,pcr
                    pshs      x
                    bsr       L1921
                    leas      $06,s
                    clra
                    clrb
                    stb       [>$056C,y]
                    ldd       $04,s
                    puls      pc,u

L1921               pshs      u
                    ldu       $06,s
                    leas      -$0B,s
                    bra       L1939
L1929               ldb       $08,s
                    lbeq      L1B6A
                    ldb       $08,s
                    sex
                    pshs      b,a
                    jsr       [<$11,s]
                    leas      $02,s
L1939               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L1929
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2D
                    bne       L195E
                    ldd       #$0001
                    std       >$0582,y
                    ldb       ,u+
                    stb       $08,s
                    bra       L1964
L195E               clra
                    clrb
                    std       >$0582,y
L1964               ldb       $08,s
                    cmpb      #$30
                    bne       L196F
                    ldd       #$0030
                    bra       L1972
L196F               ldd       #$0020
L1972               std       >$0584,y
                    bra       L1992
L1978               ldd       $06,s
                    pshs      b,a
                    ldd       #$000A
                    lbsr      L2314
                    pshs      b,a
                    ldb       $0A,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L1992               ldb       $08,s
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L1978
                    ldb       $08,s
                    cmpb      #$2E
                    bne       L19DB
                    ldd       #$0001
                    std       $04,s
                    bra       L19C5
L19AF               ldd       $02,s
                    pshs      b,a
                    ldd       #$000A
                    lbsr      L2314
                    pshs      b,a
                    ldb       $0A,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L19C5               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L19AF
                    bra       L19DF
L19DB               clra
                    clrb
                    std       $04,s
L19DF               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L1B0D
L19E7               ldd       $06,s
                    pshs      b,a
                    ldx       <$15,s
                    leax      $02,x
                    stx       <$15,s
                    ldd       -$02,x
                    pshs      b,a
                    lbsr      L1B6E
                    bra       L1A0F
L19FC               ldd       $06,s
                    pshs      b,a
                    ldx       <$15,s
                    leax      $02,x
                    stx       <$15,s
                    ldd       -$02,x
                    pshs      b,a
                    lbsr      L1C2F
L1A0F               std       ,s
                    lbra      L1AF3
L1A14               ldd       $06,s
                    pshs      b,a
                    ldb       $0A,s
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$02
                    pshs      b,a
                    ldx       <$17,s
                    leax      $02,x
                    stx       <$17,s
                    ldd       -$02,x
                    pshs      b,a
                    lbsr      L1C75
                    lbra      L1AEF
L1A3A               ldd       $06,s
                    pshs      b,a
                    ldx       <$15,s
                    leax      $02,x
                    stx       <$15,s
                    ldd       -$02,x
                    pshs      b,a
                    leax      >$056E,y
                    pshs      x
                    lbsr      L1BB6
                    lbra      L1AEF
L1A56               ldd       $04,s
                    bne       L1A5F
                    ldd       #$0006
                    std       $02,s
L1A5F               ldd       $06,s
                    pshs      b,a
                    leax      <$15,s
                    pshs      x
                    ldd       $06,s
                    pshs      b,a
                    ldb       $0E,s
                    sex
                    pshs      b,a
                    lbsr      L220F
                    leas      $06,s
                    lbra      L1AF1
L1A79               ldx       <$13,s
                    leax      $02,x
                    stx       <$13,s
                    ldd       -$02,x
                    lbra      L1B03
L1A86               ldx       <$13,s
                    leax      $02,x
                    stx       <$13,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L1ACE
                    ldd       $09,s
                    std       $04,s
                    bra       L1AA8
L1A9C               ldb       [<$09,s]
                    beq       L1AB4
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L1AA8               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L1A9C
L1AB4               ldd       $06,s
                    pshs      b,a
                    ldd       $0B,s
                    subd      $06,s
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    ldd       <$15,s
                    pshs      b,a
                    lbsr      L1CE0
                    leas      $08,s
                    bra       L1AFD
L1ACE               ldd       $06,s
                    pshs      b,a
                    ldd       $0B,s
                    bra       L1AF1
L1AD6               ldb       ,u+
                    stb       $08,s
                    bra       L1ADE
                    leas      -$0B,x
L1ADE               ldd       $06,s
                    pshs      b,a
                    leax      <$15,s
                    pshs      x
                    ldb       $0C,s
                    sex
                    pshs      b,a
                    lbsr      L21D1
L1AEF               leas      $04,s
L1AF1               pshs      b,a
L1AF3               ldd       <$13,s
                    pshs      b,a
                    lbsr      L1D42
                    leas      $06,s
L1AFD               lbra      L1939
L1B00               ldb       $08,s
                    sex
L1B03               pshs      b,a
                    jsr       [<$11,s]
                    leas      $02,s
                    lbra      L1939
L1B0D               cmpx      #$0064
                    lbeq      L19E7
                    cmpx      #$006F
                    lbeq      L19FC
                    cmpx      #$0078
                    lbeq      L1A14
                    cmpx      #$0058
                    lbeq      L1A14
                    cmpx      #$0075
                    lbeq      L1A3A
                    cmpx      #$0066
                    lbeq      L1A56
                    cmpx      #$0065
                    lbeq      L1A56
                    cmpx      #$0067
                    lbeq      L1A56
                    cmpx      #$0045
                    lbeq      L1A56
                    cmpx      #$0047
                    lbeq      L1A56
                    cmpx      #$0063
                    lbeq      L1A79
                    cmpx      #$0073
                    lbeq      L1A86
                    cmpx      #$006C
                    lbeq      L1AD6
                    bra       L1B00
L1B6A               leas      $0B,s
                    puls      pc,u

L1B6E               pshs      u,b,a
                    leax      >$056E,y
                    stx       ,s
                    ldd       $06,s
                    bge       L1BA2
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L1B97
                    leax      >L1DCE,pcr
                    pshs      x
                    leax      >$056E,y
                    pshs      x
                    lbsr      L222B
                    leas      $04,s
                    puls      pc,u,x
L1B97               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L1BA2               ldd       $06,s
                    pshs      b,a
                    ldd       $02,s
                    pshs      b,a
                    bsr       L1BB6
                    leas      $04,s
                    leax      >$056E,y
                    tfr       x,d
                    puls      pc,u,x

L1BB6               pshs      u,y,x,b,a
                    ldu       $0A,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    bra       L1BD3
L1BC4               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      >$0020,y
                    std       $0C,s
L1BD3               ldd       $0C,s
                    blt       L1BC4
                    leax      >$0020,y
                    stx       $04,s
                    bra       L1C15
L1BDF               ldd       ,s
                    addd      #$0001
                    std       ,s
L1BE6               ldd       $0C,s
                    subd      [<$04,s]
                    std       $0C,s
                    bge       L1BDF
                    ldd       $0C,s
                    addd      [<$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L1BFF
                    ldd       #$0001
                    std       $02,s
L1BFF               ldd       $02,s
                    beq       L1C0A
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L1C0A               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L1C15               ldd       $04,s
                    cmpd      >$0028,y
                    bne       L1BE6
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0A,s
                    leas      $06,s
                    puls      pc,u

L1C2F               pshs      u,b,a
                    leax      >$056E,y
                    stx       ,s
                    leau      >$0578,y
L1C3B               ldd       $06,s
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
                    bne       L1C3B
                    bra       L1C5D
L1C53               ldb       ,u
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L1C5D               leau      -u0001,u
                    pshs      u
                    leax      >$0578,y
                    cmpx      ,s++
                    bls       L1C53
                    clra
                    clrb
                    stb       [,s]
                    leax      >$056E,y
                    tfr       x,d
                    puls      pc,u,x
L1C75               pshs      u,x,b,a
                    leax      >$056E,y
                    stx       $02,s
                    leau      >$0578,y
L1C81               ldd       $08,s
                    clra
                    andb      #$0F
                    std       ,s
                    pshs      b,a
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L1CA3
                    ldd       $0C,s
                    beq       L1C9B
                    ldd       #$0041
                    bra       L1C9E
L1C9B               ldd       #$0061
L1C9E               addd      #$FFF6
                    bra       L1CA6
L1CA3               ldd       #$0030
L1CA6               addd      ,s++
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
                    anda      #$0F
                    std       $08,s
                    bne       L1C81
                    bra       L1CC6
L1CBC               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L1CC6               leau      -u0001,u
                    pshs      u
                    leax      >$0578,y
                    cmpx      ,s++
                    bls       L1CBC
                    clra
                    clrb
                    stb       [<$02,s]
                    leax      >$056E,y
                    tfr       x,d
                    lbra      L1DB8

L1CE0               pshs      u
                    ldu       $06,s
                    ldd       $0A,s
                    subd      $08,s
                    std       $0A,s
                    ldd       >$0582,y
                    bne       L1D15
                    bra       L1CFD
L1CF2               ldd       >$0584,y
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L1CFD               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    bgt       L1CF2
                    bra       L1D15
L1D0B               ldb       ,u+
                    sex
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L1D15               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L1D0B
                    ldd       >$0582,y
                    beq       L1D40
                    bra       L1D34
L1D29               ldd       >$0584,y
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L1D34               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    bgt       L1D29
L1D40               puls      pc,u

L1D42               pshs      u
                    ldu       $06,s
                    ldd       $08,s
                    pshs      b,a
                    pshs      u
                    lbsr      L221A
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       $08,s
                    ldd       >$0582,y
                    bne       L1D84
                    bra       L1D6C
L1D61               ldd       >$0584,y
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L1D6C               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L1D61
                    bra       L1D84
L1D7A               ldb       ,u+
                    sex
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L1D84               ldb       ,u
                    bne       L1D7A
                    ldd       >$0582,y
                    beq       L1DA7
                    bra       L1D9B
L1D90               ldd       >$0584,y
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L1D9B               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L1D90
L1DA7               puls      pc,u

L1DA9               pshs      u
                    ldd       >$056C,y
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    lbsr      L1DD5
L1DB8               leas      $04,s
                    puls      pc,u

L1DBC               pshs      u
                    ldd       $04,s
                    ldx       >$056C,y
                    leax      $01,x
                    stx       >$056C,y
                    stb       -$01,x
                    puls      pc,u
L1DCE               fcc       "-32768"
                    fcb       $00

L1DD5               pshs      u
                    ldu       $06,s
                    ldd       u0006,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L1DF9
                    ldd       u0006,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      L1F0F
                    pshs      u
                    lbsr      L2141
                    leas      $02,s
L1DF9               ldd       u0006,u
                    clra
                    andb      #$04
                    beq       L1E35
                    ldd       #$0001
L1E03               pshs      b,a
                    leax      $07,s
                    pshs      x
                    ldd       u0008,u
                    pshs      b,a
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L1E1A
                    leax      >L24C7,pcr
                    bra       L1E1E
L1E1A               leax      >L24AE,pcr
L1E1E               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L1E76
                    ldd       u0006,u
                    orb       #$20
                    std       u0006,u
                    lbra      L1F0F
L1E35               ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L1E45
                    pshs      u
                    lbsr      L1F2A
                    leas      $02,s
L1E45               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      u0004,u
                    bcc       L1E6B
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L1E76
                    ldd       $04,s
                    cmpd      #$000D
                    bne       L1E76

L1E6B               pshs      u
                    lbsr      L1F2A
                    std       ,s++
                    lbne      L1F0F
L1E76               ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0008
                    lbsr      L2373
                    pshs      b,a
                    lbsr      L1DD5
                    leas      $04,s
                    ldd       $06,s
                    pshs      b,a
                    pshs      u
                    lbsr      L1DD5
                    lbra      L1FE4

L1E9D               pshs      u,b,a
                    leau      >$002D,y
                    clra
                    clrb
                    std       ,s
                    bra       L1EB3
L1EA9               tfr       u,d
                    leau      u000D,u
                    pshs      b,a
                    bsr       L1EC5
                    leas      $02,s
L1EB3               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L1EA9
                    puls      pc,u,x

L1EC5               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L1ED5
                    ldd       u0006,u
                    bne       L1EDA
L1ED5               ldd       #$FFFF
                    puls      pc,u,x
L1EDA               ldd       u0006,u
                    clra
                    andb      #$02
                    beq       L1EE9
                    pshs      u
                    bsr       L1EFE
                    leas      $02,s
                    bra       L1EEB
L1EE9               clra
                    clrb
L1EEB               std       ,s
                    ldd       u0008,u
                    pshs      b,a
                    lbsr      L2414
                    leas      $02,s
                    clra
                    clrb
                    std       u0006,u
                    ldd       ,s
                    puls      pc,u,x

L1EFE               pshs      u
                    ldu       $04,s
                    beq       L1F0F
                    ldd       u0006,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L1F14
L1F0F               ldd       #$FFFF
                    puls      pc,u
L1F14               ldd       u0006,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L1F24
                    pshs      u
                    lbsr      L2141
                    leas      $02,s

L1F24               pshs      u
                    bsr       L1F2A
                    puls      pc,u,x

L1F2A               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L1F5C
                    ldd       ,u
                    cmpd      u0004,u
                    beq       L1F5C
                    clra
                    clrb
                    pshs      b,a
                    pshs      u
                    lbsr      L1FE8
                    leas      $02,s
                    ldd       $02,x
                    pshs      b,a
                    ldd       ,x
                    pshs      b,a
                    ldd       u0008,u
                    pshs      b,a
                    lbsr      L24D7
                    leas      $08,s
L1F5C               ldd       ,u
                    subd      u0002,u
                    std       $02,s
                    lbeq      L1FD4
                    ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L1FD4
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L1FAB
                    ldd       u0002,u
                    bra       L1FA3
L1F7C               ldd       $02,s
                    pshs      b,a
                    ldd       ,u
                    pshs      b,a
                    ldd       u0008,u
                    pshs      b,a
                    lbsr      L24C7
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L1F99
                    leax      $04,s
                    bra       L1FC3
L1F99               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L1FA3               std       ,u
                    ldd       $02,s
                    bne       L1F7C
                    bra       L1FD4
L1FAB               ldd       $02,s
                    pshs      b,a
                    ldd       u0002,u
                    pshs      b,a
                    ldd       u0008,u
                    pshs      b,a
                    lbsr      L24AE
                    leas      $06,s
                    cmpd      $02,s
                    beq       L1FD4
                    bra       L1FC5
L1FC3               leas      -$04,x
L1FC5               ldd       u0006,u
                    orb       #$20
                    std       u0006,u
                    ldd       u0004,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L1FE4
L1FD4               ldd       u0006,u
                    ora       #$01
                    std       u0006,u
                    ldd       u0002,u
                    std       ,u
                    addd      u000B,u
                    std       u0004,u
                    clra
                    clrb
L1FE4               leas      $04,s
                    puls      pc,u

L1FE8               pshs      u
                    puls      pc,u

L1FEC               pshs      u
                    ldu       $04,s
                    beq       L2038
                    ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2038
                    ldd       ,u
                    cmpd      u0004,u
                    bcc       L2013
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    bra       L201A

L2013               pshs      u
                    lbsr      L2087
                    leas      $02,s
L201A               puls      pc,u
                    pshs      u
                    ldu       $06,s
                    beq       L2038
                    ldd       u0006,u
                    clra
                    andb      #$01
                    beq       L2038
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       L2038
                    ldd       ,u
                    cmpd      u0002,u
                    bhi       L203D
L2038               ldd       #$FFFF
                    puls      pc,u
L203D               ldd       ,u
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
                    lbsr      L1FEC
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L2072
                    pshs      u
                    lbsr      L1FEC
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L2077
L2072               ldd       #$FFFF
                    bra       L2083
L2077               ldd       $02,s
                    pshs      b,a
                    ldd       #$0008
                    lbsr      L238A
                    addd      ,s
L2083               leas      $04,s
                    puls      pc,u

L2087               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       u0006,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       L20B0
                    ldd       u0006,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    beq       L20A9
                    ldd       #$FFFF
                    puls      pc,u,x

L20A9               pshs      u
                    lbsr      L2141
                    leas      $02,s
L20B0               leax      >$002D,y
                    pshs      x
                    cmpu      ,s++
                    bne       L20CD
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L20CD
                    leax      >$003A,y
                    pshs      x
                    lbsr      L1EFE
                    leas      $02,s
L20CD               ldd       u0006,u
                    clra
                    andb      #$08
                    beq       L20F9
                    ldd       u000B,u
                    pshs      b,a
                    ldd       u0002,u
                    pshs      b,a
                    ldd       u0008,u
                    pshs      b,a
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L20ED
                    leax      >L249E,pcr
                    bra       L20F1
L20ED               leax      >L247D,pcr
L20F1               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       L210B
L20F9               ldd       #$0001
                    pshs      b,a
                    leax      u000A,u
                    stx       u0002,u
                    pshs      x
                    ldd       u0008,u
                    pshs      b,a
                    lbsr      L247D
L210B               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       L212E
                    ldd       u0006,u
                    pshs      b,a
                    ldd       $02,s
                    beq       L2120
                    ldd       #$0020
                    bra       L2123
L2120               ldd       #$0010
L2123               ora       ,s+
                    orb       ,s+
                    std       u0006,u
                    ldd       #$FFFF
                    puls      pc,u,x
L212E               ldd       u0002,u
                    addd      #$0001
                    std       ,u
                    ldd       u0002,u
                    addd      ,s
                    std       u0004,u
                    ldb       [<u0002,u]
                    clra
                    puls      pc,u,x

L2141               pshs      u
                    ldu       $04,s
                    ldd       u0006,u
                    clra
                    andb      #$C0
                    bne       L2179
                    leas      <-$20,s
                    leax      ,s
                    pshs      x
                    ldd       u0008,u
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    lbsr      L2396
                    leas      $06,s
                    ldd       u0006,u
                    pshs      b,a
                    ldb       $02,s
                    bne       L216D
                    ldd       #$0040
                    bra       L2170
L216D               ldd       #$0080
L2170               ora       ,s+
                    orb       ,s+
                    std       u0006,u
                    leas      <$20,s
L2179               ldd       u0006,u
                    ora       #$80
                    std       u0006,u
                    clra
                    andb      #$0C
                    beq       L2186
                    puls      pc,u
L2186               ldd       u000B,u
                    bne       L219B
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L2196
                    ldd       #$0080
                    bra       L2199
L2196               ldd       #$0100
L2199               std       u000B,u
L219B               ldd       u0002,u
                    bne       L21B0
                    ldd       u000B,u
                    pshs      b,a
                    lbsr      L25CA
                    leas      $02,s
                    std       u0002,u
                    cmpd      #$FFFF
                    beq       L21B8
L21B0               ldd       u0006,u
                    orb       #$08
                    std       u0006,u
                    bra       L21C7
L21B8               ldd       u0006,u
                    orb       #$04
                    std       u0006,u
                    leax      u000A,u
                    stx       u0002,u
                    ldd       #$0001
                    std       u000B,u
L21C7               ldd       u0002,u
                    addd      u000B,u
                    std       u0004,u
                    std       ,u
                    puls      pc,u

L21D1               pshs      u
                    ldb       $05,s
                    sex
                    tfr       d,x
                    bra       L21F7
L21DA               ldd       [<$06,s]
                    addd      #$0004
                    std       [<$06,s]
                    leax      >L220E,pcr
                    bra       L21F3
L21E9               ldb       $05,s
                    stb       >$002B,y
                    leax      >$002A,y
L21F3               tfr       x,d
                    puls      pc,u
L21F7               cmpx      #$0064
                    beq       L21DA
                    cmpx      #$006F
                    lbeq      L21DA
                    cmpx      #$0078
                    lbeq      L21DA
                    bra       L21E9
                    puls      pc,u

L220E               fcb       $00

L220F               pshs      u
                    leax      >L2219,pcr
                    tfr       x,d
                    puls      pc,u

L2219               fcb       $00

L221A               pshs      u
                    ldu       $04,s
L221E               ldb       ,u+
                    bne       L221E
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u

L222B               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L2235               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2235
                    ldd       $06,s
                    puls      pc,u,x
L2245               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L224F               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L224F
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L2260               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2260
                    ldd       $06,s
                    puls      pc,u,x

L2270               pshs      u
                    ldu       $04,s
                    bra       L2286
L2276               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L2284
                    clra
                    clrb
                    puls      pc,u
L2284               leau      u0001,u
L2286               ldb       ,u
                    sex
                    pshs      b,a
                    ldb       [<$08,s]
                    sex
                    cmpd      ,s++
                    beq       L2276
                    ldb       [<$06,s]
                    sex
                    pshs      b,a
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u

L22A1               pshs      u
                    ldu       $04,s
                    leas      -$05,s
                    clra
                    clrb
                    std       $01,s
L22AB               ldb       ,u+
                    stb       ,s
                    cmpb      #$20
                    beq       L22AB
                    ldb       ,s
                    cmpb      #$09
                    lbeq      L22AB
                    ldb       ,s
                    cmpb      #$2D
                    bne       L22C6
                    ldd       #$0001
                    bra       L22C8
L22C6               clra
                    clrb
L22C8               std       $03,s
                    ldb       ,s
                    cmpb      #$2D
                    beq       L22EE
                    ldb       ,s
                    cmpb      #$2B
                    bne       L22F2
                    bra       L22EE
L22D8               ldd       $01,s
                    pshs      b,a
                    ldd       #$000A
                    lbsr      L2314
                    pshs      b,a
                    ldb       $02,s
                    sex
                    addd      ,s++
                    addd      #$FFD0
                    std       $01,s
L22EE               ldb       ,u+
                    stb       ,s
L22F2               ldb       ,s
                    sex
                    leax      >$00FE,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L22D8
                    ldd       $03,s
                    beq       L230E
                    ldd       $01,s
                    nega
                    negb
                    sbca      #$00
                    bra       L2310
L230E               ldd       $01,s
L2310               leas      $05,s
                    puls      pc,u
L2314               tsta
                    bne       L2329
                    tst       $02,s
                    bne       L2329
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,b,a
L2329               pshs      b,a
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
                    bcc       L2346
                    inc       ,s
L2346               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L2353
                    inc       ,s
L2353               lda       $04,s
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
                    beq       L237D
L236A               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L236A
                    bra       L237D
L2373               tstb
                    beq       L237D
L2376               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L2376
L237D               ldd       $02,s
                    pshs      b,a
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts
L238A               tstb
                    beq       L237D
L238D               lsl       $03,s
                    rol       $02,s
                    decb
                    bne       L238D
                    bra       L237D
L2396               lda       $05,s
                    ldb       $03,s
                    beq       L23C9
                    cmpb      #$01
                    beq       L23CB
                    cmpb      #$06
                    beq       L23CB
                    cmpb      #$02
                    beq       L23B1
                    cmpb      #$05
                    beq       L23B1
                    ldb       #$D0
                    lbra      L2619

L23B1               pshs      u
                    os9       I$GetStt
                    bcc       L23BD
                    puls      u
                    lbra      L2619
L23BD               stx       [<$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

L23C9               ldx       $06,s
L23CB               os9       I$GetStt
                    lbra      L2622
                    lda       $05,s
                    ldb       $03,s
                    beq       L23E0
                    cmpb      #$02
                    beq       L23E8
                    ldb       #$D0
                    lbra      L2619
L23E0               ldx       $06,s
                    os9       I$SetStt
                    lbra      L2622

L23E8               pshs      u
                    ldx       $08,s
                    ldu       $0A,s
                    os9       I$SetStt
                    puls      u
                    lbra      L2622
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       L2402
                    os9       I$Close
L2402               lbra      L2622
L2405               ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      L2619
                    tfr       a,b
                    clra
                    rts
L2414               lda       $03,s
                    os9       I$Close
                    lbra      L2622
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      L2622
L2426               ldx       $02,s
                    lda       $05,s
                    ldb       #$0B
                    os9       I$Create
                    bcs       L2435
L2431               tfr       a,b
                    clra
                    rts
L2435               cmpb      #$DA
                    lbne      L2619
                    lda       $05,s
                    bita      #$80
                    lbne      L2619
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      L2619
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L2431
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      L2619
                    ldx       $02,s
                    os9       I$Delete
                    lbra      L2622
                    lda       $03,s
                    os9       I$Dup
                    lbcs      L2619
                    tfr       a,b
                    clra
                    rts
L247D               pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
L248B               bcc       L249A
                    cmpb      #$D3
                    bne       L2495
                    clra
                    clrb
                    puls      pc,y,x
L2495               puls      y,x
                    lbra      L2619
L249A               tfr       y,d
                    puls      pc,y,x
L249E               pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
                    bra       L248B
L24AE               pshs      y
                    ldy       $08,s
                    beq       L24C3
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
L24BC               bcc       L24C3
                    puls      y
                    lbra      L2619
L24C3               tfr       y,d
                    puls      pc,y
L24C7               pshs      y
                    ldy       $08,s
                    beq       L24C3
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
                    bra       L24BC

L24D7               pshs      u
                    ldd       $0A,s
                    bne       L24E5
                    ldu       #$0000
                    ldx       #$0000
                    bra       L2519
L24E5               cmpd      #$0001
                    beq       L2510
                    cmpd      #$0002
                    beq       L2505
                    ldb       #$F7
L24F3               clra
                    std       >$01CC,y
                    ldd       #$FFFF
                    leax      >$01C0,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
L2505               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L24F3
                    bra       L2519
L2510               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L24F3
L2519               tfr       u,d
                    addd      $08,s
                    std       >$01C2,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L24F3
                    tfr       d,x
                    std       >$01C0,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       L24F3
                    leax      >$01C0,y
                    puls      pc,u

L253E               pshs      u,y
                    ldx       $06,s
                    lda       $09,s
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       $0B,s
                    os9       F$Link
L254D               tfr       u,d
                    puls      u,y
                    lbcs      L2619
                    rts

                    pshs      u,y
                    ldx       $06,s
                    lda       $09,s
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       $0B,s
                    os9       F$Load
                    bra       L254D

L2567               pshs      u
                    ldu       $04,s
                    os9       F$UnLink
                    puls      u
                    lbra      L2622

L2573               ldd       >$01BE,y
                    pshs      b,a
                    ldd       $04,s
                    cmpd      >$0586,y
                    bcs       L25A7
                    addd      >$01BE,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       L2599
                    ldd       #$FFFF
                    leas      $02,s
                    rts
L2599               std       >$01BE,y
                    addd      >$0586,y
                    subd      ,s
                    std       >$0586,y
L25A7               leas      $02,s
                    ldd       >$0586,y
                    pshs      b,a
                    subd      $04,s
                    std       >$0586,y
                    ldd       >$01BE,y
                    subd      ,s++
                    pshs      b,a
                    clra
                    ldx       ,s
L25C0               sta       ,x+
                    cmpx      >$01BE,y
                    bcs       L25C0
                    puls      pc,b,a
L25CA               ldd       $02,s
                    addd      >$01C8,y
                    bcs       L25F3
                    cmpd      >$01CA,y
                    bcc       L25F3
                    pshs      b,a
                    ldx       >$01C8,y
                    clra
L25E0               cmpx      ,s
                    bcc       L25E8
                    sta       ,x+
                    bra       L25E0
L25E8               ldd       >$01C8,y
                    puls      x
                    stx       >$01C8,y
                    rts
L25F3               ldd       #$FFFF
                    rts

L25F7               pshs      u
                    tfr       y,u
                    ldx       $04,s
                    stx       >$0588,y
                    leax      >L260D,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      L2622
L260D               tfr       u,y
                    clra
                    pshs      b,a
                    jsr       [>$0588,y]
                    leas      $02,s
                    rti

L2619               clra
                    std       >$01CC,y
                    ldd       #$FFFF
                    rts
L2622               bcs       L2619
                    clra
                    clrb
                    rts

L2627               lbsr      L2632
                    lbsr      L1E9D

L262D               ldd       $02,s
                    os9       F$Exit
L2632               rts

L2633               fcb       $00
                    fcb       $01
                    fcb       $00
                    fcb       $01
                    fcb       $62                 b
                    fcb       $03
                    fcb       $77                 w
                    fcb       $00
                    fcb       $01
                    fcb       $27                 '
                    fcb       $10
                    fcb       $03
                    fcb       $E8
                    fcb       $00
                    fcb       $64                 d
                    fcb       $00
                    fcb       $0A
                    fcb       $00
                    fcb       $28                 (
                    fcb       $6C                 l
                    fcb       $78                 x
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $01
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $02
                    fcb       $00
                    fcb       $01
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $42                 B
                    fcb       $00
                    fcb       $02
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $01
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
                    fcb       $30                 0
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $48                 H
                    fcb       $48                 H
                    fcb       $48                 H
                    fcb       $48                 H
                    fcb       $48                 H
                    fcb       $48                 H
                    fcb       $48                 H
                    fcb       $48                 H
                    fcb       $48                 H
                    fcb       $48                 H
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $42                 B
                    fcb       $42                 B
                    fcb       $42                 B
L275E               fcb       $42                 B
                    fcb       $42                 B
L2760               fcb       $42                 B
                    fcb       $02
                    fcb       $02
                    fcb       $02
L2764               fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $02
L276A               fcb       $02
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
                    fcb       $20
L2776               fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $44                 D
                    fcb       $44                 D
                    fcb       $44                 D
                    fcb       $44                 D
                    fcb       $44                 D
                    fcb       $44                 D
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $04
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $01
                    fcb       $00
                    fcb       $01
                    fcb       $00
                    fcb       $1C
                    fcb       $00
                    fcb       $01
                    fcb       $00
                    fcb       $28                 (
                    fcb       $63                 c
                    fcb       $2E                 .
                    fcb       $70                 p
                    fcb       $72                 r
                    fcb       $65                 e
                    fcb       $70                 p
                    fcb       $00
                    emod
eom                 equ       *
