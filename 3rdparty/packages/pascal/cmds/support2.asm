********************************************************************
* progname - program module
*
* $Id$
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*  -     Original Pascal 2.0 distribution version
*
* $Log$
* Revision 1.1  2002/04/05 08:23:28  roug
* Checked in Pascal 2.0
*
*

                    nam       Support
                    ttl       subroutine module

* Disassembled 02/04/05 10:07:25 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       /dd/defs/os9defs
                    endc
tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $06
                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       0
size                equ       .
                    fcb       $31                 1
                    fcb       $64                 d
                    fcb       $31                 1
                    fcb       $28                 (
                    fcb       $43                 C
                    fcb       $29                 )
                    fcb       $20
                    fcb       $31                 1
                    fcb       $39                 9
                    fcb       $38                 8
                    fcb       $31                 1
                    fcb       $20
                    fcb       $42                 B
                    fcb       $59                 Y
                    fcb       $20
                    fcb       $4D                 M
                    fcb       $49                 I
                    fcb       $43                 C
                    fcb       $52                 R
                    fcb       $4F                 O
                    fcb       $57                 W
                    fcb       $41                 A
                    fcb       $52                 R
                    fcb       $45                 E
                    fcb       $20
                    fcb       $53                 S
                    fcb       $59                 Y
                    fcb       $53                 S
                    fcb       $54                 T
                    fcb       $45                 E
                    fcb       $4D                 M
                    fcb       $53                 S
                    fcb       $20
                    fcb       $43                 C
                    fcb       $4F                 O
                    fcb       $52                 R
                    fcb       $50                 P
                    fcb       $2E                 .
                    fcb       $20
                    fcb       $41                 A
                    fcb       $4C                 L
                    fcb       $4C                 L
                    fcb       $20
                    fcb       $52                 R
                    fcb       $49                 I
                    fcb       $47                 G
                    fcb       $48                 H
                    fcb       $54                 T
                    fcb       $53                 S
                    fcb       $20
                    fcb       $52                 R
                    fcb       $45                 E
                    fcb       $53                 S
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $56                 V
                    fcb       $45                 E
                    fcb       $44                 D
                    fcb       $2E                 .
                    fcb       $52                 R
                    fcb       $45                 E
                    fcb       $53                 S
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $56                 V
                    fcb       $45                 E
                    fcb       $44                 D
                    fcb       $2E                 .
                    fcb       $20
name                equ       *
                    fcs       /Support/
                    fcb       $06
                    fcb       $16
                    fcb       $00
                    fcb       $D8                 X
                    fcb       $16
                    fcb       $14
                    fcb       $82
                    fcb       $16
                    fcb       $14
                    fcb       $DE                 ^
                    fcb       $16
                    fcb       $14
                    fcb       $DB                 [
                    fcb       $16
                    fcb       $10
                    fcb       $BB                 ;
                    fcb       $16
                    fcb       $14
                    fcb       $D5                 U
                    fcb       $16
                    fcb       $15
                    fcb       $2C                 ,
                    fcb       $16
                    fcb       $02
                    fcb       $62                 b
                    fcb       $16
                    fcb       $02
                    fcb       $95
                    fcb       $16
                    fcb       $04
                    fcb       $CD                 M
                    fcb       $16
                    fcb       $06
                    fcb       $1E
                    fcb       $16
                    fcb       $09
                    fcb       $BB                 ;
                    fcb       $16
                    fcb       $0A
                    fcb       $49                 I
                    fcb       $16
                    fcb       $0A
                    fcb       $4A                 J
                    fcb       $16
                    fcb       $0A
                    fcb       $4B                 K
                    fcb       $16
                    fcb       $0B
                    fcb       $A8                 (
                    fcb       $16
                    fcb       $0A
                    fcb       $47                 G
                    fcb       $16
                    fcb       $01
                    fcb       $7F
                    fcb       $16
                    fcb       $08
                    fcb       $F1                 q
                    fcb       $16
                    fcb       $0D
                    fcb       $06
                    fcb       $16
                    fcb       $13
                    fcb       $BC                 <
                    fcb       $16
                    fcb       $09
                    fcb       $CF                 O
                    fcb       $16
                    fcb       $09
                    fcb       $F6                 v
                    fcb       $16
                    fcb       $04
                    fcb       $F1                 q
                    fcb       $16
                    fcb       $13
                    fcb       $D8                 X
                    fcb       $16
                    fcb       $02
                    fcb       $28                 (
                    fcb       $16
                    fcb       $0D
                    fcb       $03
                    fcb       $16
                    fcb       $0E
                    fcb       $56                 V
                    fcb       $16
                    fcb       $0E
                    fcb       $7D
                    fcb       $16
                    fcb       $0E
                    fcb       $9C
                    fcb       $16
                    fcb       $0E
                    fcb       $B7                 7
                    fcb       $16
                    fcb       $0C
                    fcb       $4E                 N
                    fcb       $16
                    fcb       $0B
                    fcb       $FC
                    fcb       $16
                    fcb       $03
                    fcb       $A6                 &
                    fcb       $16
                    fcb       $07
                    fcb       $5E                 ^
                    fcb       $16
                    fcb       $04
                    fcb       $E8                 h
start               equ       *
                    lbra      L0670
                    lbra      L06BA
                    lbra      L078A
                    lbra      L07E7
                    lbra      L09DB
                    lbra      L0CC7
                    lbra      L12C2
                    lbra      L12CE
                    lbra      L131F
                    lbra      L1323
                    lbra      L1566
                    lbra      L1578
                    lbra      L158D
                    lbra      L13A1
                    lbra      L13B3
                    lbra      L13BA
                    lbra      L13C1
                    lbra      L13C8
                    lbra      L13CF
                    lbra      L1558
                    lbra      L0FD3
                    lbra      L0F7D
                    lbra      L1050
                    lbra      L1070
                    lbra      L02CC
                    lbra      L1547
                    lbra      L1547
                    lbra      L10E9
                    lbra      L10EC
                    lbra      L10BB
                    lbra      L1554
                    lbra      L159B
                    lbra      L159B
                    lbra      L159B
                    lbra      L159B
                    lbra      L159B
                    lbra      L0182
                    pshs      y
                    ldx       $04,s
                    ldb       $0F,x
                    bne       L0151
                    ldd       $0A,x
                    bitb      #$0C
                    bne       L0147
                    ldb       #$47
                    bra       L014D
L0147               bitb      #$04
                    bne       L015B
                    ldb       #$46
L014D               clra
                    lbsr      L0B5C
L0151               clr       $05,s
L0153               puls      y
                    ldx       ,s
                    leas      $03,s
                    jmp       ,x
L015B               bita      #$80
                    beq       L017C
                    bitb      #$82
                    bne       L0169
L0163               ldb       #$01
                    stb       $05,s
                    bra       L0153
L0169               lda       $0C,x
                    ldb       #$01
                    os9       I$GetStt
                    bcc       L0163
                    cmpb      #$F6
                    beq       L0151
                    stb       <u002E
                    ldb       #$43
                    bra       L014D
L017C               bitb      #$01
                    bne       L0151
                    bra       L0163
L0182               pshs      y
                    ldx       $04,s
                    ldb       $0F,x
                    bne       L01C5
                    ldd       $0A,x
                    bitb      #$0C
                    bne       L0194
                    ldb       #$47
                    bra       L01C1
L0194               bitb      #$04
                    bne       L019C
                    ldb       #$46
                    bra       L01C1
L019C               bita      #$80
                    bne       L01B3
L01A0               leay      $05,s
                    pshs      y,x
                    lbsr      L09DB
                    bra       L01AB
L01A9               sta       $05,s
L01AB               puls      y
                    ldx       ,s
                    leas      $03,s
                    jmp       ,x
L01B3               bitb      #$80
                    beq       L01BB
                    andb      #$FC
                    stb       $0B,x
L01BB               bitb      #$01
                    beq       L01CB
                    ldb       #$45
L01C1               clra
                    lbsr      L0B5C
L01C5               lda       #$20
                    sta       $0E,x
                    bra       L01A9
L01CB               bitb      #$80
                    bne       L01D9
                    bitb      #$02
                    beq       L01A0
                    orb       #$80
                    stb       $0B,x
                    bra       L01C5
L01D9               lda       $0C,x
                    ldy       #$0001
                    leax      $0E,x
                    os9       I$Read
                    ldx       $04,s
                    bcc       L01FA
                    cmpb      #$D3
                    beq       L01F2
                    stb       <u002E
                    ldb       #$43
                    bra       L01C1
L01F2               lda       $0B,x
                    ora       #$03
                    sta       $0B,x
                    bra       L01C5
L01FA               lbsr      L0510
                    ldb       $0B,x
                    orb       #$80
                    andb      #$FD
                    lda       $0E,x
                    cmpa      #$0D
                    bne       L020B
                    orb       #$02
L020B               stb       $0B,x
                    bra       L01A9
                    puls      x
                    stx       <u001E
                    ldd       <u0000
                    std       <u0032
                    subd      <u0046
                    std       <u0012
                    std       <u0034
                    std       <u004C
                    subd      #$01C5
                    tfr       d,y
                    leas      ,y
                    leau      ,s
                    stu       <u0014
                    stu       <u004A
                    leax      $08,y
                    stx       <u001C
                    leax      <$12,y
                    stx       ,y
                    ldd       #$0080
                    std       $04,x
                    ldd       #$0014
                    std       $0A,x
                    clra
                    clrb
                    stb       <u0020
                    std       <u00CE
                    stb       <u00D0
                    stb       $0C,x
                    std       ,x
                    std       $02,x
                    stb       $0F,x
                    std       $06,x
                    std       $08,x
                    ldb       #$D0
                    stb       $0D,x
                    leas      <-$20,s
                    clrb
                    leax      ,s
                    os9       I$GetStt
                    ldx       ,y
                    bcc       L026C
                    stb       <u002E
                    ldd       #$0060
                    lbsr      L0B5C
L026C               lda       ,s
                    leas      <$20,s
                    bne       L0281
                    ldd       $0A,x
                    ora       #$80
                    orb       #$C0
                    std       $0A,x
                    lda       #$20
                    sta       $0E,x
                    bra       L0286
L0281               pshs      x
                    lbsr      L0821
L0286               leax      >$00A3,y
                    stx       $02,y
                    ldd       #$0080
                    std       $04,x
                    ldd       #$0018
                    std       $0A,x
                    lda       #$01
                    sta       $0C,x
                    clra
                    clrb
                    pshs      x,b,a
                    pshs      b,a
                    bsr       L02D4
                    leax      >$0134,y
                    stx       $04,y
                    ldd       #$0080
                    std       $04,x
                    ldd       #$0018
                    std       $0A,x
                    lda       #$02
                    sta       $0C,x
                    clra
                    clrb
                    pshs      x,b,a
                    pshs      b,a
                    bsr       L02D4
                    ldb       #$01
                    stb       <u0040
                    stb       <u003B
                    ldd       <u004E
                    std       $06,y
                    ldx       <u001E
                    jmp       ,x
L02CC               lda       #$18
                    bra       L02D6
                    lda       #$8C
                    bra       L02D6
L02D4               lda       #$08
L02D6               pshs      u,y,a
                    ldx       $0B,s
                    lbsr      L0530
                    ldb       $0B,x
                    ldy       $09,s
                    bne       L02EB
                    bitb      #$0C
                    bne       L02F8
                    ldy       $07,s
L02EB               bitb      #$0C
                    beq       L02F8
                    pshs      x
                    lbsr      L0C32
                    ldx       $0B,s
                    ldb       $0B,x
L02F8               andb      #$3D
                    orb       #$01
                    stb       $0B,x
                    lda       ,s
                    bsr       L0351
                    puls      u,y,a
                    puls      x
                    leas      $06,s
                    jmp       ,x
                    pshs      u,y
                    ldx       $0A,s
                    lbsr      L0530
                    ldb       $0B,x
                    ldy       $08,s
                    bne       L031F
                    bitb      #$0C
                    bne       L032C
                    ldy       $06,s
L031F               bitb      #$0C
                    beq       L032C
                    pshs      x
                    lbsr      L0C32
                    ldx       $0A,s
                    ldb       $0B,x
L032C               andb      #$3C
                    stb       $0B,x
                    lda       #$04
                    bsr       L0351
                    ldb       $0B,x
                    bitb      #$40
                    beq       L0344
                    orb       #$80
                    stb       $0B,x
                    lda       #$20
                    sta       $0E,x
                    bra       L0349
L0344               pshs      x
                    lbsr      L0821
L0349               puls      u,y
                    puls      x
                    leas      $06,s
                    jmp       ,x
L0351               pshs      u,y,x,b,a
                    clra
                    clrb
                    stb       $0F,x
                    std       $06,x
                    std       $08,x
                    ldb       #$D0
                    stb       $0D,x
                    ldd       $0A,x
                    anda      #$40
                    sta       $0A,x
                    bitb      #$0C
                    beq       L0396
                    lda       $0C,x
                    ldx       #$0000
                    leau      ,x
                    os9       I$Seek
                    bcc       L03BD
L0375               stb       <u002E
                    ldb       #$63
L0379               clra
                    ldx       $02,s
                    ldu       $06,s
                    lbsr      L0B5C
                    ldb       $0B,x
                    bitb      #$0C
                    pshs      cc
                    andb      #$F3
                    stb       $0B,x
                    puls      cc
                    beq       L0394
                    lda       $0C,x
                    os9       I$Close
L0394               puls      pc,u,y,x,b,a
L0396               leax      ,y
                    lda       ,s
                    bita      #$08
                    beq       L03B2
                    ldd       #$0303
                    os9       I$Create
                    bcc       L03B9
                    cmpb      #$DA
                    beq       L03B0
L03AA               stb       <u002E
                    ldb       #$62
                    bra       L0379
L03B0               ldx       $04,s
L03B2               lda       #$03
                    os9       I$Open
                    bcs       L03AA
L03B9               ldx       $02,s
                    sta       $0C,x
L03BD               ldx       $02,s
                    ldb       $0B,x
                    andb      #$F3
                    orb       ,s
                    stb       $0B,x
                    bsr       L0433
                    leas      <-$20,s
                    lda       $0C,x
                    clrb
                    leax      ,s
                    os9       I$GetStt
                    bcc       L03DF
L03D6               stb       <u002E
                    leas      <$20,s
                    ldb       #$60
                    bra       L0379
L03DF               ldx       <$22,s
                    lda       ,s
                    bne       L03F6
                    lda       $05,s
                    anda      #$01
                    ora       #$80
                    ora       $0A,x
                    ldb       $0B,x
                    orb       #$40
                    std       $0A,x
                    bra       L042E
L03F6               cmpa      #$01
                    bne       L042E
                    ldb       <$20,s
                    bitb      #$04
                    bne       L042E
                    lda       $0C,x
                    bitb      #$10
                    beq       L0422
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L03D6
                    stx       <u000C
                    ldx       <$22,s
                    lda       $0C,x
                    ldx       <u000C
                    os9       I$Seek
                    bcc       L042E
                    leas      <$20,s
                    lbra      L0375
L0422               ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    bcs       L03D6
L042E               leas      <$20,s
                    puls      pc,u,y,x,b,a
L0433               pshs      b,a
                    lda       $0B,x
                    bita      #$10
                    beq       L0441
                    clra
                    clrb
                    std       ,x
                    bra       L0443
L0441               ldd       $04,x
L0443               std       $02,x
                    puls      pc,b,a
L0447               pshs      x
                    ldy       $02,x
                    beq       L0463
                    lda       $0C,x
                    ldb       $0B,x
                    leax      <$10,x
                    bitb      #$10
                    bne       L045E
                    os9       I$Write
                    puls      pc,x
L045E               os9       I$WritLn
                    puls      pc,x
L0463               clrb
                    puls      pc,x
L0466               pshs      y
                    ldx       $04,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L0474
                    ldb       #$5F
                    bra       L048C
L0474               bitb      #$08
                    bne       L047C
                    ldb       #$5E
                    bra       L048C
L047C               bitb      #$80
                    beq       L0486
                    andb      #$7F
                    orb       #$01
                    stb       $0B,x
L0486               bitb      #$01
                    bne       L0492
                    ldb       #$5D
L048C               clra
                    lbsr      L0B5C
                    bra       L04FF
L0492               lda       $0F,x
                    bne       L0505
                    bitb      #$30
                    bne       L04A4
L049A               bsr       L0447
                    bcc       L0503
L049E               stb       <u002E
                    ldb       #$5C
                    bra       L048C
L04A4               bitb      #$10
                    beq       L049A
                    lda       $0D,x
                    cmpa      #$D0
                    beq       L04CD
                    lda       $0A,x
                    bita      #$80
                    beq       L04CD
                    ldd       $02,x
L04B6               beq       L04D2
                    std       $02,x
                    leay      <$10,x
                    subd      #$0001
                    lda       d,y
                    cmpa      #$20
                    bne       L04CD
                    ldd       $02,x
                    subd      #$0001
                    bra       L04B6
L04CD               lbsr      L0447
                    bcs       L049E
L04D2               lda       $0D,x
                    bne       L04DE
                    lda       #$0D
                    bsr       L0521
                    bcs       L049E
                    bra       L04FF
L04DE               cmpa      #$31
                    bne       L04FB
                    lda       #$0C
                    bsr       L0521
L04E6               lda       #$0D
                    pshs      x,a
                    lda       $0C,x
                    leax      ,s
                    ldy       #$0001
                    os9       I$Write
                    puls      x,a
                    bcs       L049E
                    bra       L04FF
L04FB               cmpa      #$2B
                    beq       L04E6
L04FF               ldb       #$D0
                    stb       $0D,x
L0503               bsr       L0510
L0505               lbsr      L0433
                    puls      y
                    puls      x
                    leas      $02,s
                    jmp       ,x
L0510               ldd       $08,x
                    addd      #$0001
                    std       $08,x
                    bcc       L0520
                    ldd       $06,x
                    addd      #$0001
                    std       $06,x
L0520               rts
L0521               pshs      x,a
                    lda       $0C,x
                    leax      ,s
                    ldy       #$0001
                    os9       I$WritLn
                    puls      pc,x,a
L0530               pshs      x,b,a
                    lda       $0B,x
                    anda      #$1D
                    cmpa      #$19
                    bne       L0543
                    ldd       ,x
                    beq       L0543
                    pshs      x
                    lbsr      L0466
L0543               puls      pc,x,b,a
L0545               pshs      y
                    ldx       $04,s
                    lda       $0B,x
                    bita      #$0C
                    bne       L0553
                    ldb       #$5F
                    bra       L0561
L0553               bita      #$08
                    bne       L055B
                    ldb       #$5E
                    bra       L0561
L055B               bita      #$01
                    bne       L0567
                    ldb       #$5D
L0561               clra
                    lbsr      L0B5C
                    bra       L058B
L0567               ldb       $0F,x
                    bne       L058B
                    ldd       $02,x
                    cmpd      $04,x
                    bcs       L0577
                    pshs      x
                    lbsr      L0466
L0577               ldx       $04,s
                    leay      <$10,x
                    ldd       ,x
                    leay      d,y
                    addd      #$0001
                    std       ,x
                    std       $02,x
                    lda       $0E,x
                    sta       ,y
L058B               puls      y
                    puls      x
                    leas      $02,s
                    jmp       ,x
                    puls      x
                    stx       <u001E
                    ldx       #$0001
                    ldd       ,s
                    pshs      x,b,a
                    ldd       $06,s
                    std       $04,s
                    leax      $08,s
                    stx       $06,s
                    bsr       L05B6
                    leas      $01,s
                    ldx       <u001E
                    jmp       ,x
L05AE               ldx       $06,s
                    cmpx      $04,s
                    bcc       L05B6
                    stx       $04,s
L05B6               pshs      y
                    lda       <u0038
                    lsra
                    bcc       L05D7
                    ldd       $08,s
L05BF               subd      $06,s
                    ble       L05D7
                    ldx       $04,s
                    lda       #$20
                    sta       $0E,x
                    pshs      x
                    lbsr      L0545
                    ldd       $08,s
                    subd      #$0001
                    std       $08,s
                    bra       L05BF
L05D7               ldx       $04,s
                    ldd       $06,s
                    beq       L05F4
                    ldy       $0A,s
L05E0               std       <u0025
                    ldb       ,y+
                    ldx       $04,s
                    stb       $0E,x
                    pshs      x
                    lbsr      L0545
                    ldd       <u0025
                    subd      #$0001
                    bne       L05E0
L05F4               ldd       $08,s
                    subd      $06,s
                    ble       L060E
L05FA               std       <u0025
                    ldx       $04,s
                    lda       #$20
                    sta       $0E,x
                    pshs      x
                    lbsr      L0545
                    ldd       <u0025
                    subd      #$0001
                    bne       L05FA
L060E               puls      y
                    puls      x
                    leas      $08,s
                    jmp       ,x
L0616               pshs      y,x,b,a
                    leax      <L0666,pcr
                    clr       <u0023
                    clr       <u0025
                    clr       <u0026
                    tsta
                    bpl       L0632
                    tst       <u0024
                    bne       L0632
                    lda       #$2D
                    sta       ,y+
                    inc       <u0026
                    clra
                    clrb
                    subd      ,s
L0632               std       <u000A
L0634               ldd       <u000A
                    clr       <u0027
L0638               subd      ,x
                    bcs       L0640
                    inc       <u0027
                    bra       L0638
L0640               addd      ,x
                    std       <u000A
                    lda       <u0027
                    bne       L064C
                    tst       <u0023
                    beq       L0654
L064C               inc       <u0023
                    ora       #$30
                    sta       ,y+
                    inc       <u0026
L0654               leax      $02,x
                    tst       ,x
                    bpl       L0634
                    lda       <u000B
                    ora       #$30
                    ldb       #$0D
                    std       ,y
                    inc       <u0026
                    puls      pc,y,x,b,a
L0666               beq       L0678
                    com       <u00E8
                    neg       <u0064
                    neg       <u000A
                    stu       >$FF34
                    bra       L0683
                    ldx       <u001C
                    ldd       $08,s
                    clr       <u0024
                    bsr       L0616
                    ldx       $06,s
                    ldd       <u0025
                    pshs      y,x,b,a
                    ldx       $0A,s
L0683               pshs      x
                    lbsr      L05B6
                    puls      y
                    puls      x
                    leas      $06,s
                    jmp       ,x
L0690               lsrb
                    fcb       $52                 R
                    fcb       $55                 U
                    fcb       $45                 E
L0694               rora
                    fcb       $41                 A
                    inca
                    comb
                    fcb       $45                 E
                    ldd       #$0004
                    leax      <L0690,pcr
                    lsr       $06,s
                    bcs       L06A7
                    leax      <L0694,pcr
                    incb
L06A7               pshs      x
                    ldx       $06,s
                    pshs      x,b,a
                    ldx       $08,s
                    pshs      x
                    lbsr      L05AE
                    puls      x
                    leas      $05,s
                    jmp       ,x
L06BA               ldx       $02,s
                    clr       <u0025
                    clr       <u0026
                    lda       $0B,x
                    bita      #$0C
                    bne       L06CA
                    ldb       #$42
                    bra       L06D8
L06CA               bita      #$04
                    bne       L06D2
                    ldb       #$41
                    bra       L06D8
L06D2               bita      #$01
                    beq       L06DB
L06D6               ldb       #$40
L06D8               lbra      L077B
L06DB               ldb       $0F,x
                    lbne      L077F
                    bita      #$80
                    beq       L06F2
L06E5               pshs      x
                    lbsr      L078A
                    ldx       $02,s
                    ldb       $0F,x
                    lbne      L077F
L06F2               lda       $0B,x
                    bita      #$01
                    bne       L06D6
                    ldb       $0E,x
                    cmpb      #$20
                    beq       L06E5
                    clr       <u0028
                    clr       <u002D
                    cmpb      #$2D
                    bne       L070A
                    inc       <u0028
                    bra       L070E
L070A               cmpb      #$2B
                    bne       L0712
L070E               pshs      x
                    bsr       L078A
L0712               ldx       $02,s
                    ldb       $0E,x
                    subb      #$30
                    bcs       L076B
                    cmpb      #$09
                    bhi       L076B
                    inc       <u002D
                    stb       <u0027
                    ldd       <u0025
                    lslb
                    rola
                    bcs       L074A
                    std       <u000A
                    lslb
                    rola
                    bcs       L074A
                    lslb
                    rola
                    bcs       L074A
                    addd      <u000A
                    bcs       L074A
                    addb      <u0027
                    adca      #$00
                    bcs       L074A
                    std       <u0025
                    cmpd      #$8000
                    bcs       L070E
                    bhi       L074A
                    tst       <u0028
                    bne       L070E
L074A               ldd       #$7FFF
                    tst       <u0028
                    beq       L0754
                    ldd       #$8000
L0754               std       <u0025
L0756               pshs      x
                    bsr       L078A
                    ldx       $02,s
                    ldb       $0E,x
                    cmpb      #$30
                    bcs       L0766
                    cmpb      #$39
                    bls       L0756
L0766               ldd       #$004F
                    bra       L077B
L076B               tst       <u0028
                    beq       L0775
                    clra
                    clrb
                    subd      <u0025
                    std       <u0025
L0775               tst       <u002D
                    bne       L077F
                    ldb       #$4E
L077B               clra
                    lbsr      L0B5C
L077F               ldd       <u0025
                    std       [<$04,s]
                    puls      x
                    leas      $04,s
                    jmp       ,x
L078A               pshs      y
                    ldx       $04,s
                    lda       $0B,x
                    bita      #$0C
                    bne       L0798
                    ldb       #$47
                    bra       L07A6
L0798               bita      #$04
                    bne       L07A0
                    ldb       #$46
                    bra       L07A6
L07A0               bita      #$01
                    beq       L07AC
                    ldb       #$45
L07A6               clra
                    lbsr      L0B5C
                    bra       L07C1
L07AC               ldb       $0F,x
                    bne       L07C7
                    bita      #$82
                    beq       L07BA
                    pshs      x
                    bsr       L0821
                    bra       L07DF
L07BA               ldd       ,x
                    cmpd      $02,x
                    bcs       L07CD
L07C1               lda       $0B,x
                    ora       #$02
                    sta       $0B,x
L07C7               ldb       #$20
                    stb       $0E,x
                    bra       L07DF
L07CD               leay      <$10,x
                    ldb       d,y
                    cmpb      #$0D
                    beq       L07C1
                    stb       $0E,x
                    ldd       ,x
                    addd      #$0001
                    std       ,x
L07DF               puls      y
                    puls      x
                    leas      $02,s
                    jmp       ,x
L07E7               ldx       $02,s
                    lda       $0B,x
                    bita      #$0C
                    bne       L07F3
                    ldb       #$42
                    bra       L0801
L07F3               bita      #$04
                    bne       L07FB
                    ldb       #$41
                    bra       L0801
L07FB               bita      #$01
                    beq       L0807
                    ldb       #$40
L0801               clra
                    lbsr      L0B5C
                    bra       L081B
L0807               ldb       $0F,x
                    bne       L081B
                    bita      #$40
                    beq       L0817
                    ora       #$80
                    anda      #$FD
                    sta       $0B,x
                    bra       L081B
L0817               pshs      x
                    bsr       L0821
L081B               puls      x
                    leas      $02,s
                    jmp       ,x
L0821               pshs      y
                    ldx       $04,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L082F
                    ldb       #$47
                    bra       L0845
L082F               bitb      #$04
                    bne       L0837
                    ldb       #$46
                    bra       L0845
L0837               bitb      #$80
                    beq       L083F
                    andb      #$7E
                    stb       $0B,x
L083F               bitb      #$01
                    beq       L085B
                    ldb       #$45
L0845               clra
                    lbsr      L0B5C
                    ldb       $0B,x
                    bra       L088C
L084D               cmpy      $02,x
                    lbeq      L08D5
                    sty       $02,x
                    ldb       #$44
                    bra       L0845
L085B               lda       $0F,x
                    bne       L088C
                    bitb      #$30
                    beq       L086D
                    bitb      #$10
                    bne       L0898
                    lda       $0A,x
                    bita      #$80
                    bne       L0898
L086D               lda       $0C,x
                    ldy       $02,x
                    leax      <$10,x
                    os9       I$Read
                    ldx       $04,s
                    bcc       L084D
L087C               cmpb      #$D3
                    beq       L0886
                    stb       <u002E
                    ldb       #$43
                    bra       L0845
L0886               ldb       $0B,x
                    orb       #$03
                    stb       $0B,x
L088C               bitb      #$10
                    beq       L08D8
                    clra
                    clrb
                    std       ,x
                    std       $02,x
                    bra       L08D8
L0898               lda       $0C,x
                    ldy       $04,x
                    leax      <$10,x
                    os9       I$ReadLn
                    ldx       $04,s
                    bcs       L087C
                    tfr       y,d
                    addd      #$000F
                    lda       d,x
                    cmpa      #$0D
                    bne       L08B4
                    leay      -$01,y
L08B4               ldb       $0B,x
                    bitb      #$20
                    bne       L08E0
                    sty       $02,x
                    lda       <$10,x
                    cmpa      #$0D
                    bne       L08CA
                    orb       #$02
                    lda       #$20
                    bra       L08CC
L08CA               andb      #$FD
L08CC               sta       $0E,x
                    stb       $0B,x
                    ldd       #$0001
                    std       ,x
L08D5               lbsr      L0510
L08D8               puls      y
                    puls      x
                    leas      $02,s
                    jmp       ,x
L08E0               pshs      y
                    ldd       ,s
                    leay      <$10,x
                    leay      d,y
                    ldd       $04,x
                    std       $02,x
                    subd      ,s++
                    tfr       d,x
                    lda       #$20
L08F3               sta       ,y+
                    leax      -$01,x
                    bne       L08F3
                    ldx       $04,s
                    bra       L08D5
                    bra       L091F
                    bra       L0921
                    bra       L0923
                    bra       L0951
                    clr       $03,s
                    oim       #$6C,-$03,y
                    bra       L092C
                    bra       L092E
                    fcb       $45                 E
                    lsl       >$7465
                    jmp       $04,s
                    eim       #$64,-$03,y
                    bra       L095A
                    com       -$0C,s
                    eim       #$61,>$6C20
L091F               lsl       $05,s
L0921               oim       #$70,-$03,y
                    fcb       $41                 A
                    com       -$0C,s
                    eim       #$61,>$6C20
                    com       >$7461
L092E               com       $0B,s
                    mul
                    bra       L0953
                    rora
                    aim       #$65,>$6520
                    com       >$7461
                    com       $0B,s
                    mul
                    bra       L0960
                    bra       L0988
                    aim       #$65,>$6520
                    lsl       $05,s
                    oim       #$70,-$03,y
                    bra       L096D
                    bra       L096F
                    bra       L0971
L0951               bra       L0973
L0953               comb
                    asr       >$6170
                    mul
L0958               stu       >$A500
                    tst       <u0000
                    fcb       $42                 B
                    stu       >$B200
                    tst       <u0000
                    lsra
                    stu       >$F300
                    tst       <u0000
                    lsla
                    stu       >$BF00
L096D               tst       <u0000
L096F               inca
                    stu       >$CC00
L0973               tst       <u0000
                    sexw
                    stu       >$D900
                    tst       <u0000
                    deca
                    stu       >$E600
                    tst       <u0000
                    fcb       $3E                 >
                    neg       <u0000
                    ldy       <u0014
                    lda       <u0040
                    beq       L09DA
                    ldx       $02,y
                    lbsr      L0530
                    ldx       $04,y
                    lbsr      L0530
                    lda       <u0039
                    beq       L09DA
                    ldb       #$01
                    stb       <u0024
                    lbsr      L0C08
                    ldd       <u0002
                    addd      <u003E
                    subd      <u004C
                    std       <u003E
                    ldd       <u004C
                    subd      <u0034
                    std       <u004C
                    ldd       <u0014
                    subd      <u004A
                    std       <u0014
                    ldd       <u004A
                    subd      <u0018
                    bcc       L09BC
                    clra
                    clrb
L09BC               std       <u004A
                    leau      <L0958,pcr
L09C1               ldd       ,u++
                    beq       L09DA
                    leax      <L0958,pcr
                    leax      d,x
                    ldd       ,u++
                    lbsr      L0C19
                    ldx       <u0002
                    ldd       ,u++
                    ldd       d,x
                    lbsr      L0C23
                    bra       L09C1
L09DA               rts
L09DB               ldx       $02,s
                    lda       $0B,x
                    bita      #$0C
                    bne       L09E7
                    ldb       #$42
                    bra       L09F5
L09E7               bita      #$04
                    bne       L09EF
                    ldb       #$41
                    bra       L09F5
L09EF               bita      #$01
                    beq       L09FB
                    ldb       #$40
L09F5               clra
                    lbsr      L0B5C
                    bra       L0A10
L09FB               ldb       $0F,x
                    bne       L0A10
                    bita      #$80
                    beq       L0A17
                    pshs      x
                    lbsr      L0821
                    ldx       $02,s
                    lda       $0B,x
                    bita      #$01
                    beq       L0A17
L0A10               ldb       #$20
                    stb       [<$04,s]
                    bra       L0A33
L0A17               ldb       $0E,x
                    stb       [<$04,s]
                    ldd       $0A,x
                    bitb      #$02
                    beq       L0A2E
                    bita      #$80
                    beq       L0A2E
                    andb      #$FD
                    orb       #$80
                    stb       $0B,x
                    bra       L0A33
L0A2E               pshs      x
                    lbsr      L078A
L0A33               ldx       ,s
                    leas      $06,s
                    jmp       ,x
                    pshs      y
                    ldd       <u0012
                    std       [<$06,s]
                    addd      $04,s
                    std       <u0012
                    cmpd      <u004C
                    bls       L0A4B
                    std       <u004C
L0A4B               cmpd      <u0032
                    bls       L0A63
                    cmpd      <u0000
                    bhi       L0A59
                    tst       <u0036
                    bne       L0A63
L0A59               subd      <u0002
                    os9       F$Mem
                    bcs       L0ABC
                    sty       <u0000
L0A63               puls      y
                    puls      x
                    leas      $04,s
                    jmp       ,x
                    pshs      y
                    ldx       $04,s
                    cmpx      <u0012
                    bhi       L0AC2
                    cmpx      <u0034
                    bcs       L0AC2
                    stx       <u0012
                    lda       <u0036
                    bne       L0A8D
                    cmpx      <u0032
                    bls       L0A8D
                    ldd       <u0012
                    subd      <u0002
                    os9       F$Mem
                    bcs       L0AB6
                    sty       <u0000
L0A8D               puls      y
                    ldx       ,s
                    leas      $04,s
                    jmp       ,x
                    ldx       ,s
                    pshs      b,a
                    ldd       $04,s
                    pshs      u
                    cmpd      ,s++
                    bhi       L0AC6
                    subd      ,s++
                    bcs       L0AC6
                    cmpd      <u004A
                    bcc       L0AAD
                    std       <u004A
L0AAD               subd      <u0018
                    bcs       L0AC6
                    lds       $02,s
                    jmp       ,x
L0AB6               stb       <u002E
                    ldb       #$E4
                    bra       L0AD6
L0ABC               stb       <u002E
                    ldb       #$B6
                    bra       L0AD6
L0AC2               ldb       #$BA
                    bra       L0AD6
L0AC6               ldb       #$BB
                    bra       L0AD6
                    ldb       #$C0
                    bra       L0AD4
                    ldb       #$C1
                    bra       L0AD4
                    ldb       #$C2
L0AD4               ldx       $02,s
L0AD6               clra
                    lbra      L0B5C
L0ADA               negb
                    fcb       $41                 A
                    comb
                    coma
                    fcb       $41                 A
                    inca
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $52                 R
                    addd      <u0034
                    rora
                    lda       <u0022
                    bgt       L0AFA
                    blt       L0B21
                    leax      <L0ADA,pcr
                    lda       #$21
                    os9       I$Open
                    bcs       L0B21
                    sta       <u0021
                    inc       <u0022
L0AFA               ldx       #$0000
                    leau      ,x
                    lda       <u0021
                    os9       I$Seek
                    bcs       L0B1F
L0B06               leax      $06,s
                    ldy       #$0050
                    lda       <u0021
                    os9       I$ReadLn
                    bcs       L0B1F
                    ldd       ,s
                    subd      #$0001
                    std       ,s
                    bne       L0B06
                    leax      $06,s
                    clrb
L0B1F               puls      pc,u,b,a
L0B21               lda       #$80
                    sta       <u0022
                    comb
                    puls      pc,u,b,a
L0B28               inca
                    rol       $0E,s
                    eim       #$20,$0E,s
                    eim       #$6D,>$6265
                    aim       #$3D,>$5061
                    com       >$6361
                    inc       $00,y
                    eim       #$72,-$0E,s
                    clr       -$0E,s
                    bra       L0B65
L0B42               negb
                    com       $0F,s
                    lsr       $05,s
                    bra       L0BB5
                    clr       $03,s
                    oim       #$74,$09,s
                    clr       $0E,s
                    mul
L0B51               negb
                    aim       #$6F,>$6365
                    lsr       -$0B,s
                    aim       #$65,>$2023
L0B5C               pshs      u,y,x,b,a
                    cmpd      #$0064
                    bcc       L0B7C
                    lda       $0A,x
                    bita      #$40
                    beq       L0B7C
                    lda       $0F,x
                    bne       L0B7A
                    ldb       <u002E
                    beq       L0B76
                    clr       <u002E
                    bra       L0B78
L0B76               ldb       $01,s
L0B78               stb       $0F,x
L0B7A               puls      pc,u,y,x,b,a
L0B7C               lbsr      L0C08
                    leax      <L0B34,pcr
                    ldd       #$000E
                    lbsr      L0C19
                    ldb       #$01
                    stb       <u0024
                    ldd       ,s
                    lbsr      L0C23
                    ldd       ,s
                    leas      <-$51,s
                    lbsr      L0AE4
                    bcs       L0BA2
                    lda       #$02
                    os9       I$WritLn
                    bcs       L0C05
L0BA2               leas      <$51,s
                    ldb       <u002E
                    beq       L0BB0
                    lda       #$02
                    os9       F$PErr
                    clr       <u002E
L0BB0               ldb       <u0040
                    beq       L0C01
                    leax      <L0B51,pcr
                    ldd       #$000B
                    bsr       L0C19
                    clra
                    ldb       <u0020
                    bsr       L0C23
L0BC1               cmpu      <u0014
                    bcc       L0BD7
                    leax      <L0B51,pcr
                    ldd       #$000B
                    bsr       L0C19
                    clra
                    ldb       $02,u
                    bsr       L0C23
                    ldu       ,u
                    bra       L0BC1
L0BD7               ldd       <u00CE
                    beq       L0BE8
                    leax      >L0B28,pcr
                    ldd       #$000C
                    bsr       L0C19
                    ldd       <u00CE
                    bsr       L0C23
L0BE8               ldx       ,s
                    cmpx      #$00BE
                    bcs       L0C01
                    cmpx      #$00C7
                    bhi       L0C01
                    leax      >L0B42,pcr
                    ldd       #$000F
                    bsr       L0C19
                    ldd       $02,s
                    bsr       L0C23
L0C01               ldx       <u0008
                    jmp       ,x
L0C05               os9       F$Exit
L0C08               pshs      y,x,b,a
                    clra
                    ldb       #$0D
                    pshs      b
                    leax      ,s
                    bsr       L0C19
                    leas      $01,s
                    puls      pc,y,x,b,a
L0C17               leax      ,y
L0C19               tfr       d,y
                    lda       #$02
                    os9       I$WritLn
                    bcs       L0C05
                    rts
L0C23               pshs      y,x,b,a
                    ldy       <u001C
                    lbsr      L0616
                    ldd       <u0025
                    incb
                    bsr       L0C17
                    puls      pc,y,x,b,a
L0C32               ldx       $02,s
                    lda       $0B,x
                    bita      #$0C
                    beq       L0C58
                    lbsr      L0530
                    clr       $0F,x
                    lda       $0C,x
                    os9       I$Close
                    bcc       L0C50
                    stb       <u002E
                    ldx       $02,s
                    ldd       #$003F
                    lbsr      L0B5C
L0C50               ldx       $02,s
                    lda       $0B,x
                    anda      #$F3
                    sta       $0B,x
L0C58               puls      x
                    leas      $02,s
                    jmp       ,x
L0C5E               std       $02,x
                    ldb       #$B7
                    stb       <u00D0
                    lda       <u003A
                    beq       L0C6C
                    clra
                    lbsr      L0B5C
L0C6C               rts
L0C6D               ldd       ,x
                    beq       L0C5E
                    cmpd      #$0002
                    bne       L0C86
                    ldd       $02,x
                    beq       L0C83
                    asra
                    rorb
                    std       $02,x
                    ldd       #$0000
                    rolb
L0C83               std       ,x
                    rts
L0C86               ldd       $02,x
                    beq       L0C83
                    tsta
                    bne       L0C95
                    exg       a,b
                    std       <u000A
                    ldb       #$08
                    bra       L0C99
L0C95               std       <u000A
                    ldb       #$10
L0C99               stb       <u0025
                    ldd       #$0000
L0C9E               lsl       <u000B
                    rol       <u000A
                    rolb
                    rola
                    subd      ,x
                    bmi       L0CAC
                    inc       <u000B
                    bra       L0CAE
L0CAC               addd      ,x
L0CAE               dec       <u0025
                    bne       L0C9E
                    std       ,x
                    ldd       <u000A
                    std       $02,x
                    rts
                    leax      $02,s
                    bsr       L0CED
                    bsr       L0C6D
                    ldb       <u0028
                    beq       L0D2C
                    ldd       $02,x
                    bra       L0D26
L0CC7               leax      $02,s
                    lda       <u0037
                    beq       L0CD1
                    ldd       ,x
                    bmi       L0CDD
L0CD1               bsr       L0CED
                    bsr       L0C6D
                    ldd       ,x
                    tst       <u0037
                    beq       L0D22
                    bra       L0D2A
L0CDD               ldb       #$BC
                    stb       <u00D0
                    lda       <u003A
                    beq       L0CE9
                    clra
                    lbsr      L0B5C
L0CE9               clra
                    clrb
                    bra       L0D2A
L0CED               clr       <u0028
                    ldd       $02,x
                    bpl       L0CFB
                    nega
                    negb
                    sbca      #$00
                    std       $02,x
                    com       <u0028
L0CFB               ldd       ,x
                    bpl       L0D07
                    nega
                    negb
                    sbca      #$00
                    std       ,x
                    com       <u0028
L0D07               rts
                    leax      $02,s
                    bsr       L0CED
                    bsr       L0D42
                    ldd       <u0029
                    bne       L0D32
                    ldd       <u002B
                    cmpd      #$8000
                    bcs       L0D22
                    bhi       L0D32
                    tst       <u0028
                    bne       L0D2A
                    bra       L0D32
L0D22               tst       <u0028
                    beq       L0D2A
L0D26               nega
                    negb
                    sbca      #$00
L0D2A               std       $04,s
L0D2C               ldx       ,s
                    leas      $04,s
                    jmp       ,x
L0D32               ldb       #$B8
                    stb       <u00D0
                    lda       <u003A
                    beq       L0D3E
                    clra
                    lbsr      L0B5C
L0D3E               ldd       <u002B
                    bra       L0D22
L0D42               ldd       ,x
                    beq       L0D67
                    cmpd      #$0002
                    bne       L0D50
                    ldd       $02,x
                    bra       L0D5C
L0D50               ldd       $02,x
                    beq       L0D67
                    cmpd      #$0002
                    bne       L0D6C
                    ldd       ,x
L0D5C               lslb
                    rola
                    std       <u002B
                    ldd       #$0000
                    rolb
                    std       <u0029
                    rts
L0D67               std       <u002B
                    std       <u0029
                    rts
L0D6C               ldd       #$0000
                    std       <u0029
                    ldb       $01,x
                    lda       $03,x
                    mul
                    std       <u002B
                    ldb       $01,x
                    lda       $02,x
                    mul
                    addd      <u002A
                    std       <u002A
                    bcc       L0D85
                    inc       <u0029
L0D85               ldb       ,x
                    lda       $03,x
                    mul
                    addd      <u002A
                    std       <u002A
                    bcc       L0D92
                    inc       <u0029
L0D92               ldb       ,x
                    lda       $02,x
                    mul
                    addd      <u0029
                    std       <u0029
                    rts
                    leax      $02,s
                    bsr       L0D42
                    ldd       <u0029
                    bne       L0DA8
                    ldd       <u002B
                    bra       L0D2A
L0DA8               ldd       #$00B9
                    lbra      L0B5C
                    ldb       #$01
                    stb       <u0038
                    stb       <u0037
                    clr       <u0036
                    stb       <u003A
                    clr       <u0039
                    ldx       <u004E
L0DBC               cmpx      <u0050
                    lbcc      L0E77
                    lda       ,x+
L0DC4               cmpa      #$3A
                    lbeq      L0E77
                    cmpa      #$20
                    beq       L0DBC
                    cmpa      #$2C
                    beq       L0DBC
                    cmpa      #$61
                    bcs       L0DDC
                    cmpa      #$7A
                    bhi       L0DDC
                    suba      #$20
L0DDC               leau      >L0EE7,pcr
L0DE0               cmpa      ,u
                    beq       L0DFE
                    leau      $03,u
                    ldb       ,u
                    bne       L0DE0
                    leau      >L0EF7,pcr
L0DEE               cmpa      ,u
                    beq       L0E1A
                    leau      $03,u
                    ldb       ,u
                    bne       L0DEE
                    ldd       #$00C8
                    lbra      L0B5C
L0DFE               ldu       $01,u
                    ldd       <u0002
                    leau      d,u
                    lda       #$01
                    sta       ,u
                    lda       ,x+
                    cmpx      <u0050
                    bhi       L0E77
                    cmpa      #$2B
                    beq       L0DBC
                    cmpa      #$2D
                    bne       L0DC4
                    clr       ,u
                    bra       L0DBC
L0E1A               ldu       $01,u
                    ldd       <u0002
                    leay      d,u
                    clra
                    clrb
                    std       ,y
L0E24               lda       ,x+
                    cmpx      <u0050
                    bhi       L0E77
                    cmpa      #$6B
                    beq       L0E5C
                    cmpa      #$4B
                    beq       L0E5C
                    cmpa      #$30
                    bcs       L0E6E
                    cmpa      #$39
                    bhi       L0E6E
                    anda      #$0F
                    sta       <u0027
                    ldd       ,y
                    lslb
                    rola
                    bcs       L0E71
                    std       <u000A
                    lslb
                    rola
                    bcs       L0E71
                    lslb
                    rola
                    bcs       L0E71
                    addd      <u000A
                    bcs       L0E71
                    addb      <u0027
                    adca      #$00
                    bcs       L0E71
                    std       ,y
                    bra       L0E24
L0E5C               ldd       ,y
                    cmpd      #$0040
                    bcc       L0E71
                    lda       $01,y
                    clrb
                    lsla
                    lsla
                    std       ,y
                    lbra      L0DBC
L0E6E               lbra      L0DC4
L0E71               ldd       #$00C9
                    lbra      L0B5C
L0E77               ldu       <u0002
                    leau      <$7E,u
                    stu       <u004E
                    ldb       #$50
                    stb       <u000A
L0E82               cmpx      <u0050
                    bcc       L0E90
                    lda       ,x+
                    sta       ,u+
                    dec       <u000A
                    bne       L0E82
                    bra       L0E98
L0E90               lda       #$20
L0E92               sta       ,u+
                    dec       <u000A
                    bne       L0E92
L0E98               ldd       #$0800
                    cmpd      <u0048
                    bls       L0EA2
                    std       <u0048
L0EA2               ldd       <u0042
                    bne       L0EC1
                    ldx       <u0016
                    beq       L0EE0
                    ldb       <u003C
                    stb       <u000A
                    clra
                    clrb
L0EB0               addd      $02,x
                    bcs       L0EE1
                    pshs      b
                    ldb       <u00D1
                    abx
                    puls      b
                    dec       <u000A
                    bne       L0EB0
                    std       <u0042
L0EC1               ldd       <u0044
                    bne       L0EE0
                    ldx       <u0016
                    beq       L0EE0
                    ldb       <u003C
                    stb       <u000A
                    clra
                    clrb
L0ECF               addd      $04,x
                    bcs       L0EE1
                    pshs      b
                    ldb       <u00D1
                    abx
                    puls      b
                    dec       <u000A
                    bne       L0ECF
                    std       <u0044
L0EE0               rts
L0EE1               ldd       #$00CA
                    lbra      L0B5C
L0EE7               deca
                    neg       <u0038
                    tsta
                    neg       <u0037
                    fcb       $52                 R
                    neg       <u0036
                    rola
                    neg       <u0039
                    fcb       $41                 A
                    neg       <u003A
                    neg       <u0045
                    neg       <u0044
                    lsla
                    neg       <u0046
                    inca
                    neg       <u0042
                    comb
                    neg       <u0048
                    neg       <u00DF
                    subr      v,cc
                    leax      ,s
                    os9       F$Time
                    bcc       L0F17
                    clra
                    clrb
                    std       ,s
                    std       $02,s
                    std       $04,s
L0F17               leau      <$14,s
                    ldx       #$0006
                    clra
L0F1E               puls      b
                    std       [,--u]
                    leax      -$01,x
                    bne       L0F1E
                    ldu       <u0010
                    ldx       ,s
                    leas      $0E,s
                    jmp       ,x
                    ldx       $03,s
                    lda       $0A,x
                    lsr       $02,s
                    bcs       L0F3C
                    ora       #$40
                    sta       $0A,x
                    bra       L0F4A
L0F3C               anda      #$BF
                    sta       $0A,x
                    ldb       $0F,x
                    beq       L0F4A
                    ldd       #$002D
                    lbsr      L0B5C
L0F4A               ldx       ,s
                    leas      $05,s
                    jmp       ,x
                    clr       $04,s
                    ldx       $02,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L0F62
                    ldd       #$005B
                    lbsr      L0B5C
                    bra       L0F68
L0F62               bitb      #$40
                    beq       L0F68
                    inc       $04,s
L0F68               ldx       ,s
                    leas      $04,s
                    jmp       ,x
                    ldx       $02,s
                    clra
                    ldb       $0F,x
                    std       $04,s
                    sta       $0F,x
                    ldx       ,s
                    leas      $04,s
                    jmp       ,x
L0F7D               ldx       $04,s
                    cmpx      #$0010
                    bcc       L0FAF
                    ldx       $02,s
                    leax      -$01,x
                    cmpx      #$0010
                    bcc       L0FAF
                    stx       $02,s
                    leax      <L0FB3,pcr
                    ldd       $06,s
                    std       <u000A
                    ldb       $03,s
                    lslb
                    ldd       b,x
                    pshs      b,a
                    lda       $05,s
                    ldb       $07,s
                    bsr       L1020
                    anda      ,s+
                    andb      ,s+
L0FA7               std       $08,s
                    ldx       ,s
                    leas      $08,s
                    jmp       ,x
L0FAF               clra
                    clrb
                    bra       L0FA7
L0FB3               neg       <u0001
                    neg       <u0003
                    neg       <u0007
                    neg       <u000F
                    neg       <u001F
                    neg       <u003F
                    neg       <u007F
                    neg       <u00FF
                    oim       #$FF,<u0003
                    stu       >$07FF
                    clr       <u00FF
                    tfr       f,f
                    swi
                    fcb       $FF
                    clr       >$FFFF
                    stu       >$AE66
                    cmpx      #$0010
                    bcc       L101A
                    ldx       $04,s
                    leax      -$01,x
                    cmpx      #$0010
                    bcc       L101A
                    stx       $04,s
                    leax      <L0FB3,pcr
                    ldd       [<$08,s]
                    std       <u000A
                    ldb       $05,s
                    lslb
                    ldd       b,x
                    coma
                    comb
                    pshs      b,a
                    lda       $07,s
                    ldb       $09,s
                    bsr       L1020
                    anda      ,s+
                    andb      ,s+
                    std       <u000A
                    ldb       $05,s
                    lslb
                    ldd       b,x
                    anda      $02,s
                    andb      $03,s
                    ora       <u000A
                    orb       <u000B
                    std       <u000A
                    lda       $07,s
                    ldb       $05,s
                    bsr       L1020
                    std       [<$08,s]
L101A               ldx       ,s
                    leas      $0A,s
                    jmp       ,x
L1020               pshs      x,a
                    subb      ,s+
                    beq       L1047
                    sex
                    tfr       d,x
                    bmi       L1039
                    ldd       <u000A
L102D               lsra
                    rorb
                    bcc       L1033
                    ora       #$80
L1033               leax      -$01,x
                    bne       L102D
                    puls      pc,x
L1039               ldd       <u000A
L103B               lslb
                    rola
                    bcc       L1041
                    orb       #$01
L1041               leax      $01,x
                    bne       L103B
                    puls      pc,x
L1047               ldd       <u000A
                    puls      pc,x
L104B               comb
                    lsla
                    fcb       $45                 E
                    inca
                    ldd       #$3460
                    leax      <L104B,pcr
                    ldy       $06,s
                    ldu       $08,s
                    ldd       #$1101
                    os9       F$Fork
                    bcs       L1065
                    os9       F$Wait
L1065               clra
                    std       $0A,s
                    puls      u,y
                    ldx       ,s
                    leas      $06,s
                    jmp       ,x
L1070               pshs      y
                    ldx       $06,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L107E
                    ldb       #$5F
                    bra       L1084
L107E               bitb      #$08
                    bne       L108A
                    ldb       #$5E
L1084               clra
                    lbsr      L0B5C
                    bra       L10B3
L108A               bitb      #$01
                    bne       L1092
                    ldb       #$5D
                    bra       L1084
L1092               lda       $0F,x
                    bne       L10B3
                    ldd       $04,s
                    leas      <-$51,s
                    lbsr      L0AE4
                    bcs       L10B0
                    pshs      x
                    leay      -$01,y
                    pshs      y
                    pshs      y
                    ldd       <$5D,s
                    pshs      b,a
                    lbsr      L05B6
L10B0               leas      <$51,s
L10B3               puls      y
                    ldx       ,s
                    leas      $06,s
                    jmp       ,x
L10BB               ldx       $04,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L10C8
                    ldd       #$0061
                    bra       L10DC
L10C8               lda       $0F,x
                    bne       L10E3
                    ldd       $02,s
                    blt       L10D5
                    cmpd      $04,x
                    ble       L10E1
L10D5               ldd       $04,x
                    std       $02,x
                    ldd       #$0028
L10DC               lbsr      L0B5C
                    bra       L10E3
L10E1               std       $02,x
L10E3               ldx       ,s
                    leas      $06,s
                    jmp       ,x
L10E9               clra
                    bra       L10EE
L10EC               lda       #$01
L10EE               sta       <u000A
                    ldx       $04,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L10FD
                    ldd       #$0055
                    bra       L111B
L10FD               lda       $0F,x
                    bne       L111E
                    lda       $0C,x
                    clrb
                    ldx       $02,s
                    tst       <u000A
                    beq       L110F
                    os9       I$SetStt
                    bra       L1112
L110F               os9       I$GetStt
L1112               bcc       L111E
                    stb       <u002E
                    ldx       $04,s
                    ldd       #$0057
L111B               lbsr      L0B5C
L111E               ldx       ,s
                    leas      $06,s
                    jmp       ,x
L1124               pshs      u,y
                    leay      $06,s
                    lda       $01,y
                    bpl       L1130
                    lda       $06,y
                    bmi       L1137
L1130               clra
                    clrb
                    std       $05,y
                    lbra      L1269
L1137               lda       ,y
                    adda      $05,y
                    bvc       L1155
L113D               bpl       L1130
                    lda       <u003B
                    bne       L1147
                    coma
                    lbra      L126A
L1147               ldb       #$D0
                    stb       <u00D0
                    lda       <u003A
                    beq       L1130
                    ldu       $02,s
                    clra
                    lbra      L0B5C
L1155               sta       $05,y
                    ldb       $09,y
                    eorb      $04,y
                    andb      #$01
                    stb       <u0028
                    lda       $09,y
                    anda      #$FE
                    sta       $09,y
                    ldb       $04,y
                    andb      #$FE
                    stb       $04,y
                    mul
                    sta       ,-s
                    clr       ,-s
                    clr       ,-s
                    lda       $09,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L117F
                    inc       ,s
L117F               lda       $08,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L118C
                    inc       ,s
L118C               clr       ,-s
                    lda       $09,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L119B
                    inc       ,s
L119B               lda       $08,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L11A8
                    inc       ,s
L11A8               lda       $07,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L11B5
                    inc       ,s
L11B5               clr       ,-s
                    lda       $09,y
                    ldb       $01,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L11C4
                    inc       ,s
L11C4               lda       $08,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L11D1
                    inc       ,s
L11D1               lda       $07,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L11DE
                    inc       ,s
L11DE               lda       $06,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L11EB
                    inc       ,s
L11EB               clr       ,-s
                    lda       $08,y
                    ldb       $01,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L11FA
                    inc       ,s
L11FA               lda       $07,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1207
                    inc       ,s
L1207               lda       $06,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1214
                    inc       ,s
L1214               clr       ,-s
                    lda       $07,y
                    ldb       $01,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1223
                    inc       ,s
L1223               lda       $06,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1230
                    inc       ,s
L1230               lda       $06,y
                    ldb       $01,y
                    mul
                    addd      ,s
                    bmi       L1245
                    lsl       $04,s
                    rol       $03,s
                    rol       $02,s
                    rolb
                    rola
                    dec       $05,y
                    bvs       L125C
L1245               std       $06,y
                    ldd       $02,s
                    addd      #$0001
                    bcc       L1261
                    inc       $07,y
                    bne       L1263
                    inc       $06,y
                    bne       L1263
                    ror       $06,y
                    inc       $05,y
                    bvc       L1263
L125C               leas      $07,s
                    lbra      L113D
L1261               andb      #$FE
L1263               orb       <u0028
                    std       $08,y
                    leas      $07,s
L1269               clra
L126A               puls      u,y
                    ldx       ,s
                    leas      $07,s
                    jmp       ,x
L1272               pshs      u,y
                    leay      $08,s
                    andcc     #$F0
                    lda       $06,y
                    bne       L128C
                    lda       $01,y
                    beq       L128A
L1280               lda       $04,y
L1282               anda      #$01
                    bne       L128A
L1286               andcc     #$F0
                    orcc      #$08
L128A               puls      pc,u,y
L128C               lda       $01,y
                    bne       L1296
                    lda       $09,y
                    eora      #$01
                    bra       L1282
L1296               lda       $09,y
                    eora      $04,y
                    anda      #$01
                    bne       L1280
                    leau      $05,y
                    lda       $04,y
                    anda      #$01
                    beq       L12A8
                    exg       u,y
L12A8               ldd       ,u
                    cmpd      ,y
                    bne       L128A
                    ldd       $02,u
                    cmpd      $02,y
                    bne       L12BC
                    lda       $04,u
                    cmpa      $04,y
                    beq       L128A
L12BC               bcs       L1286
                    andcc     #$F0
                    puls      pc,u,y
L12C2               stu       <u0010
                    ldx       ,s
                    stx       <u001E
                    leas      -$01,s
                    leau      ,s
                    bra       L12E4
L12CE               stu       <u0010
                    ldx       ,s
                    stx       <u001E
                    leas      -$01,s
                    ldd       $03,s
                    std       ,s
                    ldd       $05,s
                    std       $02,s
                    lda       $07,s
                    sta       $04,s
                    leau      $05,s
L12E4               bsr       L12EC
                    ldu       <u0010
                    ldx       <u001E
                    jmp       ,x
L12EC               ldx       $03,u
                    clra
                    clrb
                    std       $03,u
                    std       $01,u
                    stb       ,u
                    leax      ,x
                    beq       L131E
                    tfr       x,d
                    ldx       #$0010
                    tsta
                    bpl       L1308
                    nega
                    negb
                    sbca      #$00
                    inc       $04,u
L1308               tsta
                    bne       L130F
                    leax      -$08,x
                    exg       a,b
L130F               tsta
                    bmi       L1318
L1312               leax      -$01,x
                    lslb
                    rola
                    bpl       L1312
L1318               std       $01,u
                    tfr       x,d
                    stb       ,u
L131E               rts
L131F               ldb       #$01
                    bra       L1324
L1323               clrb
L1324               stb       <u0052
                    ldb       $02,s
                    bgt       L1338
                    bmi       L1334
                    lda       <u0052
                    beq       L1334
                    lda       $03,s
                    bmi       L138E
L1334               clra
                    clrb
                    bra       L1399
L1338               subb      #$10
                    bhi       L1382
                    bcs       L1354
                    lsr       $06,s
                    bcc       L1382
                    ldd       $03,s
                    cmpd      #$8000
                    bne       L1382
                    tst       <u0052
                    beq       L1399
                    tst       $05,s
                    bmi       L1382
                    bra       L1399
L1354               cmpb      #$F8
                    bhi       L1366
                    stb       <u000A
                    ldd       $03,s
                    std       $04,s
                    clr       $03,s
                    ldb       <u000A
                    addb      #$08
                    beq       L136F
L1366               lsr       $03,s
                    ror       $04,s
                    ror       $05,s
                    incb
                    bne       L1366
L136F               ldd       $03,s
                    tst       <u0052
                    beq       L1391
                    tst       $05,s
                    bpl       L1391
                    addd      #$0001
                    bvc       L1391
                    lsr       $06,s
                    bcs       L1399
L1382               ldb       #$DD
                    stb       <u00D0
                    lda       <u003A
                    beq       L1334
                    clra
                    lbra      L0B5C
L138E               ldd       #$0001
L1391               lsr       $06,s
                    bcc       L1399
                    nega
                    negb
                    sbca      #$00
L1399               std       $05,s
                    ldx       ,s
                    leas      $05,s
                    jmp       ,x
L13A1               lbsr      L1272
                    beq       L13A9
L13A6               clrb
                    bra       L13AB
L13A9               ldb       #$01
L13AB               ldx       ,s
                    leas      $0B,s
                    stb       ,s
                    jmp       ,x
L13B3               lbsr      L1272
                    bne       L13A9
                    bra       L13A6
L13BA               lbsr      L1272
                    bgt       L13A9
                    bra       L13A6
L13C1               lbsr      L1272
                    bge       L13A9
                    bra       L13A6
L13C8               lbsr      L1272
                    blt       L13A9
                    bra       L13A6
L13CF               lbsr      L1272
                    ble       L13A9
                    bra       L13A6
L13D6               ldb       ,y
                    bgt       L13EC
                    bmi       L13E0
                    lda       $01,y
                    bmi       L13E3
L13E0               clrb
                    bra       L13E5
L13E3               ldb       #$01
L13E5               clra
                    std       $02,u
                    clrb
                    std       ,u
                    rts
L13EC               subb      #$20
                    bhi       L141D
                    stb       <u0025
                    ldd       $01,y
                    std       ,u
                    ldd       $03,y
                    bitb      #$01
                    bne       L141D
                    tst       <u0025
                    beq       L1419
L1400               lsr       ,u
                    ror       $01,u
                    rora
                    rorb
                    inc       <u0025
                    bne       L1400
                    bcc       L1419
                    addd      #$0001
                    bne       L1419
                    inc       $01,u
                    bne       L1419
                    inc       ,u
                    beq       L141D
L1419               std       $02,u
                    clrb
                    rts
L141D               bsr       L13E0
                    comb
                    rts
L1421               ldd       ,u
                    beq       L142F
                    std       $01,y
                    ldd       $02,u
                    std       $03,y
                    ldb       #$20
                    bra       L143C
L142F               std       $03,y
                    ldd       $02,u
                    bne       L1438
                    std       ,y
                    rts
L1438               std       $01,y
                    ldb       #$10
L143C               stb       ,y
                    tst       $01,y
                    bmi       L144E
L1442               dec       ,y
                    lsl       $04,y
                    rol       $03,y
                    rol       $02,y
                    rol       $01,y
                    bpl       L1442
L144E               ldb       $04,y
                    andb      #$FE
                    stb       $04,y
                    rts
                    pshs      u,y
                    ldx       $06,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L146B
                    ldd       #$0058
                    lbsr      L0B5C
L1465               clra
                    clrb
                    std       $08,s
                    bra       L1475
L146B               lda       $0F,x
                    bne       L1465
                    leay      $08,s
                    leau      $06,x
                    bsr       L1421
L1475               puls      u,y
                    ldx       ,s
                    leas      $04,s
                    jmp       ,x
                    pshs      u,y
                    ldx       $0B,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L1491
                    ldb       #$56
L1489               clra
                    ldu       $02,s
                    lbsr      L0B5C
                    bra       L14DA
L1491               lda       $0F,x
                    bne       L14DA
                    ldb       $0B,x
                    andb      #$FE
                    orb       #$80
                    stb       $0B,x
                    leay      $06,s
                    leau      $06,x
                    lbsr      L13D6
                    bcs       L14D6
                    leas      -$05,s
                    leay      ,s
                    lbsr      L1421
                    ldd       $04,x
                    pshs      b,a
                    lbsr      L12C2
                    lbsr      L1124
                    ldu       <u0002
                    leau      <$29,u
                    lbsr      L13D6
                    leas      $05,s
                    bcs       L14D6
                    ldx       $0B,s
                    lda       $0C,x
                    ldx       <u0029
                    ldu       <u002B
                    os9       I$Seek
                    bcc       L14DA
                    stb       <u002E
                    ldb       #$53
                    bra       L1489
L14D6               ldb       #$54
                    bra       L1489
L14DA               puls      u,y
                    ldx       ,s
                    leas      $09,s
                    jmp       ,x
                    pshs      u,y
                    leas      -$05,s
                    ldx       $0B,s
                    ldb       $0B,x
                    andb      #$0C
                    bne       L14F3
                    ldd       #$0059
                    bra       L1532
L14F3               cmpb      #$04
                    bne       L14FC
                    ldd       #$004D
                    bra       L1532
L14FC               lda       $0F,x
                    bne       L1537
                    leau      $06,x
                    leay      ,s
                    lbsr      L1421
                    ldd       $04,x
                    pshs      b,a
                    lbsr      L12C2
                    lbsr      L1124
                    ldu       <u0002
                    leau      <$29,u
                    lbsr      L13D6
                    bcc       L1520
                    ldd       #$004B
                    bra       L1532
L1520               ldx       $0B,s
                    lda       $0C,x
                    ldx       <u0029
                    ldu       <u002B
                    ldb       #$02
                    os9       I$SetStt
                    bcc       L1537
                    ldd       #$004C
L1532               ldu       $07,s
                    lbsr      L0B5C
L1537               leas      $05,s
                    puls      u,y
                    ldx       ,s
                    leas      $04,s
                    jmp       ,x
                    ldx       ,s
                    leas      $07,s
                    pshs      x
L1547               ldb       #$70
                    stb       <u00D0
                    lda       <u003A
                    bne       L1550
                    rts
L1550               clra
                    lbra      L0B5C
L1554               clra
                    clrb
                    std       $04,s
L1558               ldd       #$002C
                    ldx       $02,s
                    lbsr      L0B5C
                    ldx       ,s
                    leas      $04,s
                    jmp       ,x
L1566               clra
                    clrb
                    std       [<$04,s]
                    ldx       $02,s
                    ldb       #$2C
                    lbsr      L0B5C
                    ldx       ,s
                    leas      $06,s
                    jmp       ,x
L1578               clra
                    clrb
                    std       $06,s
                    ldb       #$70
                    stb       <u00D0
                    tst       <u003A
                    beq       L1587
                    lbra      L0B5C
L1587               ldx       ,s
                    leas      $06,s
                    jmp       ,x
L158D               ldd       #$002C
                    ldx       $02,s
                    lbsr      L0B5C
                    ldx       ,s
                    leas      $0D,s
                    jmp       ,x
L159B               clra
                    clrb
                    std       $02,s
                    ldb       #$70
                    stb       <u00D0
                    tst       <u003A
                    bne       L15A8
                    rts
L15A8               lbra      L0B5C
                    emod
eom                 equ       *
