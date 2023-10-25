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

* Disassembled 02/04/05 10:06:56 by Disasm v1.6 (C) 1988 by RML

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
                    fcb       $1B
                    fcb       $3E                 >
                    fcb       $16
                    fcb       $10
                    fcb       $C1                 A
                    fcb       $16
                    fcb       $11
                    fcb       $14
                    fcb       $16
                    fcb       $11
                    fcb       $EA                 j
                    fcb       $16
                    fcb       $13
                    fcb       $35                 5
                    fcb       $16
                    fcb       $1D
                    fcb       $42                 B
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
                    fcb       $1A
                    fcb       $78                 x
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
                    fcb       $1A
                    fcb       $94
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
                    lbra      L14FC
                    lbra      L1508
                    lbra      L1559
                    lbra      L155D
                    lbra      L163D
                    lbra      L1640
                    lbra      L191A
                    lbra      L1A5D
                    lbra      L1A6F
                    lbra      L1A76
                    lbra      L1A7D
                    lbra      L1A84
                    lbra      L1A8B
                    lbra      L1BFD
                    lbra      L0FD3
                    lbra      L0F7D
                    lbra      L1050
                    lbra      L1070
                    lbra      L02CC
                    lbra      L1C8B
                    lbra      L1CC2
                    lbra      L10E9
                    lbra      L10EC
                    lbra      L10BB
                    lbra      L1D55
                    lbra      L1DB1
                    lbra      L1DB1
                    lbra      L1DB1
                    lbra      L1DB1
                    lbra      L1DB1
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
                    pshs      u,y
                    leay      $06,s
                    ldb       $04,y
                    eorb      #$01
                    stb       $04,y
                    bra       L117E
L1130               suba      #$10
                    bcs       L114E
                    suba      #$08
                    bcs       L113F
                    pshs      a
                    clra
                    ldb       $01,x
                    bra       L1145
L113F               adda      #$08
                    pshs      a
                    ldd       $01,x
L1145               ldx       #$0000
                    tst       ,s
                    beq       L1177
                    bra       L116B
L114E               adda      #$08
                    bcc       L1161
                    pshs      a
                    clra
                    ldb       $01,x
                    ldx       $02,x
                    tst       ,s
                    bne       L116D
                    exg       d,x
                    bra       L1177
L1161               adda      #$08
                    pshs      a
                    ldd       $01,x
                    ldx       $03,x
                    bra       L116D
L116B               exg       d,x
L116D               lsra
                    rorb
                    exg       d,x
                    rora
                    rorb
                    dec       ,s
                    bne       L116B
L1177               leas      $01,s
                    rts
L117A               pshs      u,y
                    leay      $06,s
L117E               lda       $01,y
                    lbeq      L1398
                    lda       $06,y
                    bne       L1197
L1188               ldd       ,y
                    std       $05,y
                    ldd       $02,y
                    std       $07,y
                    lda       $04,y
                    sta       $09,y
                    lbra      L1398
L1197               lda       $05,y
                    suba      ,y
                    bvc       L11A2
                    bpl       L1188
                    lbra      L1398
L11A2               bmi       L11AB
                    cmpa      #$1F
                    ble       L11B3
                    lbra      L1398
L11AB               cmpa      #$E1
                    blt       L1188
                    ldb       ,y
                    stb       $05,y
L11B3               ldb       $09,y
                    andb      #$01
                    stb       <u0028
                    eorb      $04,y
                    andb      #$01
                    stb       ,y
                    ldb       $09,y
                    andb      #$FE
                    stb       $09,y
                    ldb       $04,y
                    andb      #$FE
                    stb       $04,y
                    tsta
                    beq       L1201
                    bpl       L11F8
                    nega
                    leax      $05,y
                    lbsr      L1130
                    tst       ,y
                    beq       L1209
L11DA               subd      $03,y
                    exg       d,x
                    sbcb      $02,y
                    sbca      $01,y
                    bcc       L121F
                    coma
                    comb
                    exg       d,x
                    coma
                    comb
                    addd      #$0001
                    exg       d,x
                    bcc       L11F4
                    addd      #$0001
L11F4               dec       <u0028
                    bra       L121F
L11F8               leax      ,y
                    lbsr      L1130
                    stx       $01,y
                    std       $03,y
L1201               ldx       $06,y
                    ldd       $08,y
                    tst       ,y
                    bne       L11DA
L1209               addd      $03,y
                    exg       d,x
                    adcb      $02,y
                    adca      $01,y
                    bcc       L121F
                    rora
                    rorb
                    exg       d,x
                    rora
                    rorb
                    inc       $05,y
                    bvs       L126E
                    exg       d,x
L121F               tsta
                    bmi       L1230
L1222               dec       $05,y
                    bvs       L125F
                    exg       d,x
                    lslb
                    rola
                    exg       d,x
                    rolb
                    rola
                    bpl       L1222
L1230               exg       d,x
                    addd      #$0001
                    exg       d,x
                    bcc       L1243
                    addd      #$0001
                    bcc       L1243
                    rora
                    inc       $05,y
                    bvs       L126E
L1243               std       $06,y
                    tfr       x,d
                    andb      #$FE
                    tst       <u0028
                    beq       L124E
                    incb
L124E               std       $08,y
                    lbra      L1398
L1253               pshs      u,y
                    leay      $06,s
                    lda       $01,y
                    bpl       L125F
                    lda       $06,y
                    bmi       L1266
L125F               clra
                    clrb
                    std       $05,y
                    lbra      L1398
L1266               lda       ,y
                    adda      $05,y
                    bvc       L1284
L126C               bpl       L125F
L126E               lda       <u003B
                    bne       L1276
                    coma
                    lbra      L1399
L1276               ldb       #$D0
                    stb       <u00D0
                    lda       <u003A
                    beq       L125F
                    ldu       $02,s
                    clra
                    lbra      L0B5C
L1284               sta       $05,y
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
                    bcc       L12AE
                    inc       ,s
L12AE               lda       $08,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L12BB
                    inc       ,s
L12BB               clr       ,-s
                    lda       $09,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L12CA
                    inc       ,s
L12CA               lda       $08,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L12D7
                    inc       ,s
L12D7               lda       $07,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L12E4
                    inc       ,s
L12E4               clr       ,-s
                    lda       $09,y
                    ldb       $01,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L12F3
                    inc       ,s
L12F3               lda       $08,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1300
                    inc       ,s
L1300               lda       $07,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L130D
                    inc       ,s
L130D               lda       $06,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L131A
                    inc       ,s
L131A               clr       ,-s
                    lda       $08,y
                    ldb       $01,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1329
                    inc       ,s
L1329               lda       $07,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1336
                    inc       ,s
L1336               lda       $06,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1343
                    inc       ,s
L1343               clr       ,-s
                    lda       $07,y
                    ldb       $01,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1352
                    inc       ,s
L1352               lda       $06,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L135F
                    inc       ,s
L135F               lda       $06,y
                    ldb       $01,y
                    mul
                    addd      ,s
                    bmi       L1374
                    lsl       $04,s
                    rol       $03,s
                    rol       $02,s
                    rolb
                    rola
                    dec       $05,y
                    bvs       L138B
L1374               std       $06,y
                    ldd       $02,s
                    addd      #$0001
                    bcc       L1390
                    inc       $07,y
                    bne       L1392
                    inc       $06,y
                    bne       L1392
                    ror       $06,y
                    inc       $05,y
                    bvc       L1392
L138B               leas      $07,s
                    lbra      L126C
L1390               andb      #$FE
L1392               orb       <u0028
                    std       $08,y
                    leas      $07,s
L1398               clra
L1399               puls      u,y
                    ldx       ,s
                    leas      $07,s
                    jmp       ,x
L13A1               pshs      u,y
                    leay      $06,s
                    lda       $01,y
                    bne       L13B5
                    ldb       #$D1
                    stb       <u00D0
                    lda       <u003A
                    beq       L13B7
                    clra
                    lbra      L0B5C
L13B5               lda       $06,y
L13B7               lbeq      L125F
                    lda       $05,y
                    suba      ,y
                    lbvs      L126C
                    sta       $05,y
                    lda       #$21
                    ldb       $04,y
                    eorb      $09,y
                    andb      #$01
                    std       <u000A
                    lsr       $01,y
                    ror       $02,y
                    ror       $03,y
                    ror       $04,y
                    ldd       $06,y
                    ldx       $08,y
                    lsra
                    rorb
                    exg       d,x
                    rora
                    rorb
                    clr       $09,y
                    bra       L13E7
L13E5               exg       d,x
L13E7               subd      $03,y
                    exg       d,x
                    bcc       L13F0
                    subd      #$0001
L13F0               subd      $01,y
                    beq       L1423
                    bmi       L141F
L13F6               orcc      #$01
L13F8               dec       <u000A
                    beq       L1470
                    rol       $09,y
                    rol       $08,y
                    rol       $07,y
                    rol       $06,y
                    exg       d,x
                    lslb
                    rola
                    exg       d,x
                    rolb
                    rola
                    bcc       L13E5
                    exg       d,x
                    addd      $03,y
                    exg       d,x
                    bcc       L1419
                    addd      #$0001
L1419               addd      $01,y
                    beq       L1423
                    bpl       L13F6
L141F               andcc     #$FE
                    bra       L13F8
L1423               leax      ,x
                    bne       L13F6
                    ldb       <u000A
                    decb
                    subb      #$10
                    blt       L1445
                    subb      #$08
                    blt       L143A
                    stb       <u000A
                    lda       $09,y
                    ldb       #$80
                    bra       L1463
L143A               addb      #$08
                    stb       <u000A
                    ldd       #$8000
                    ldx       $08,y
                    bra       L1465
L1445               addb      #$08
                    blt       L1453
                    stb       <u000A
                    ldx       $07,y
                    lda       $09,y
                    ldb       #$80
                    bra       L1465
L1453               addb      #$07
                    stb       <u000A
                    ldx       $06,y
                    ldd       $08,y
                    orcc      #$01
L145D               rolb
                    rola
                    exg       d,x
                    rolb
                    rola
L1463               exg       d,x
L1465               andcc     #$FE
                    dec       <u000A
                    bpl       L145D
                    exg       d,x
                    tsta
                    bra       L1474
L1470               ldx       $08,y
                    ldd       $06,y
L1474               bmi       L1484
                    exg       d,x
                    rolb
                    rola
                    exg       d,x
                    rolb
                    rola
                    dec       $05,y
                    lbvs      L125F
L1484               exg       d,x
                    addd      #$0001
                    exg       d,x
                    bcc       L1499
                    addd      #$0001
                    bcc       L1499
                    rora
                    inc       $05,y
                    lbvs      L126C
L1499               std       $06,y
                    tfr       x,d
                    andb      #$FE
                    orb       <u000B
                    std       $08,y
                    inc       $05,y
                    lbvs      L126C
                    lbra      L1398
L14AC               pshs      u,y
                    leay      $08,s
                    andcc     #$F0
                    lda       $06,y
                    bne       L14C6
                    lda       $01,y
                    beq       L14C4
L14BA               lda       $04,y
L14BC               anda      #$01
                    bne       L14C4
L14C0               andcc     #$F0
                    orcc      #$08
L14C4               puls      pc,u,y
L14C6               lda       $01,y
                    bne       L14D0
                    lda       $09,y
                    eora      #$01
                    bra       L14BC
L14D0               lda       $09,y
                    eora      $04,y
                    anda      #$01
                    bne       L14BA
                    leau      $05,y
                    lda       $04,y
                    anda      #$01
                    beq       L14E2
                    exg       u,y
L14E2               ldd       ,u
                    cmpd      ,y
                    bne       L14C4
                    ldd       $02,u
                    cmpd      $02,y
                    bne       L14F6
                    lda       $04,u
                    cmpa      $04,y
                    beq       L14C4
L14F6               bcs       L14C0
                    andcc     #$F0
                    puls      pc,u,y
L14FC               stu       <u0010
                    ldx       ,s
                    stx       <u001E
                    leas      -$01,s
                    leau      ,s
                    bra       L151E
L1508               stu       <u0010
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
L151E               bsr       L1526
                    ldu       <u0010
                    ldx       <u001E
                    jmp       ,x
L1526               ldx       $03,u
                    clra
                    clrb
                    std       $03,u
                    std       $01,u
                    stb       ,u
                    leax      ,x
                    beq       L1558
                    tfr       x,d
                    ldx       #$0010
                    tsta
                    bpl       L1542
                    nega
                    negb
                    sbca      #$00
                    inc       $04,u
L1542               tsta
                    bne       L1549
                    leax      -$08,x
                    exg       a,b
L1549               tsta
                    bmi       L1552
L154C               leax      -$01,x
                    lslb
                    rola
                    bpl       L154C
L1552               std       $01,u
                    tfr       x,d
                    stb       ,u
L1558               rts
L1559               ldb       #$01
                    bra       L155E
L155D               clrb
L155E               stb       <u0052
                    ldb       $02,s
                    bgt       L1572
                    bmi       L156E
                    lda       <u0052
                    beq       L156E
                    lda       $03,s
                    bmi       L15C8
L156E               clra
                    clrb
                    bra       L15D3
L1572               subb      #$10
                    bhi       L15BC
                    bcs       L158E
                    lsr       $06,s
                    bcc       L15BC
                    ldd       $03,s
                    cmpd      #$8000
                    bne       L15BC
                    tst       <u0052
                    beq       L15D3
                    tst       $05,s
                    bmi       L15BC
                    bra       L15D3
L158E               cmpb      #$F8
                    bhi       L15A0
                    stb       <u000A
                    ldd       $03,s
                    std       $04,s
                    clr       $03,s
                    ldb       <u000A
                    addb      #$08
                    beq       L15A9
L15A0               lsr       $03,s
                    ror       $04,s
                    ror       $05,s
                    incb
                    bne       L15A0
L15A9               ldd       $03,s
                    tst       <u0052
                    beq       L15CB
                    tst       $05,s
                    bpl       L15CB
                    addd      #$0001
                    bvc       L15CB
                    lsr       $06,s
                    bcs       L15D3
L15BC               ldb       #$DD
                    stb       <u00D0
                    lda       <u003A
                    beq       L156E
                    clra
                    lbra      L0B5C
L15C8               ldd       #$0001
L15CB               lsr       $06,s
                    bcc       L15D3
                    nega
                    negb
                    sbca      #$00
L15D3               std       $05,s
                    ldx       ,s
                    leas      $05,s
                    jmp       ,x
L15DB               lda       <u0058
                    beq       L15F4
                    ldx       $02,y
                    ldd       <u0025
                    addd      #$0001
                    std       <u0025
                    leax      d,x
                    cmpd      ,y
                    bhi       L15F2
                    lda       -$01,x
                    rts
L15F2               clra
                    rts
L15F4               ldx       ,y
                    lda       $0B,x
                    bita      #$0C
                    bne       L1600
                    ldb       #$42
                    bra       L160E
L1600               bita      #$04
                    bne       L1608
                    ldb       #$41
                    bra       L160E
L1608               bita      #$01
                    beq       L1619
L160C               ldb       #$40
L160E               clra
                    ldu       -$04,y
                    lbsr      L0B5C
L1614               leas      $02,s
                    lbra      L1713
L1619               ldb       $0F,x
                    bne       L1614
                    bita      #$80
                    bne       L1625
                    ldb       <u0026
                    beq       L1636
L1625               pshs      x
                    lbsr      L078A
                    ldx       ,y
                    lda       $0B,x
                    bita      #$01
                    bne       L160C
                    ldb       $0F,x
                    bne       L1614
L1636               lda       $0E,x
                    ldb       #$01
                    stb       <u0026
                    rts
L163D               clrb
                    bra       L1642
L1640               ldb       #$01
L1642               stb       <u0058
                    pshs      u,y
                    leay      $06,s
                    clra
                    clrb
                    stb       <u0053
                    stb       <u0054
                    stb       <u002D
                    stb       <u0055
                    stb       <u0056
                    stb       <u0057
                    stb       <u003B
                    std       <u0025
                    pshs      b,a
                    pshs      b,a
                    pshs      b
L1660               lbsr      L15DB
                    cmpa      #$20
                    beq       L1660
                    cmpa      #$2B
                    beq       L1671
                    cmpa      #$2D
                    bne       L1674
                    inc       <u0053
L1671               lbsr      L15DB
L1674               cmpa      #$2E
                    bne       L168F
                    ldb       <u0055
                    beq       L1681
                    ldd       #$0048
                    bra       L16FD
L1681               inc       <u0055
                    clra
                    clrb
                    pshs      b,a
                    pshs      b,a
                    pshs      b
                    stb       <u0057
                    bra       L1671
L168F               cmpa      #$45
                    beq       L1697
                    cmpa      #$65
                    bne       L16CC
L1697               ldb       <u002D
                    beq       L16F5
                    clr       <u002D
                    lbsr      L15DB
                    cmpa      #$2B
                    beq       L16AA
                    cmpa      #$2D
                    bne       L16AD
                    inc       <u0054
L16AA               lbsr      L15DB
L16AD               cmpa      #$30
                    bcs       L16F1
                    cmpa      #$39
                    bhi       L16F1
                    sta       <u002D
                    anda      #$0F
                    pshs      a
                    lda       #$0A
                    ldb       <u0056
                    mul
                    addb      ,s+
                    adca      #$00
                    beq       L16C8
                    ldb       #$FF
L16C8               stb       <u0056
                    bra       L16AA
L16CC               cmpa      #$30
                    bcs       L16F1
                    cmpa      #$39
                    bhi       L16F1
                    sta       <u002D
                    lda       #$01
                    clrb
                    lbsr      L1764
                    bcs       L16FA
                    ldb       <u002D
                    andb      #$0F
                    clra
                    pshs      b,a
                    lbsr      L14FC
                    lbsr      L117A
                    bcs       L16FA
                    inc       <u0057
                    bra       L1671
L16F1               lda       <u002D
                    bne       L1728
L16F5               ldd       #$0049
                    bra       L16FD
L16FA               ldd       #$004A
L16FD               tst       <u0058
                    bne       L170A
                    ldx       ,y
L1703               ldu       -$04,y
                    lbsr      L0B5C
                    bra       L1713
L170A               addd      #$0098
                    stb       <u00D0
                    tst       <u003A
                    bne       L1703
L1713               lda       <u0058
                    beq       L171B
                    leax      $04,y
                    bra       L171D
L171B               ldx       $02,y
L171D               ldb       #$05
L171F               clr       ,x+
                    decb
                    bne       L171F
                    leas      -$06,y
                    bra       L175A
L1728               lda       <u0055
                    beq       L1739
                    lda       <u0057
                    ldb       #$01
                    bsr       L1764
                    bcs       L16FA
                    lbsr      L117A
                    bcs       L16FA
L1739               lda       <u0056
                    ldb       <u0054
                    bsr       L1764
                    bcs       L16FA
                    lda       $04,s
                    ora       <u0053
                    sta       $04,s
                    lda       <u0058
                    beq       L174F
                    leax      $04,y
                    bra       L1751
L174F               ldx       $02,y
L1751               ldb       #$05
L1753               puls      a
                    sta       ,x+
                    decb
                    bne       L1753
L175A               puls      u,y
                    ldx       ,s
                    leas      $06,s
                    inc       <u003B
                    jmp       ,x
L1764               stx       <u000C
                    puls      u
                    tsta
                    beq       L1798
L176B               leax      <L179D,pcr
                    std       <u000E
                    cmpa      #$13
                    bls       L1776
                    lda       #$13
L1776               ldb       #$05
                    mul
                    leax      d,x
                    ldb       #$05
L177D               lda       ,-x
                    pshs      a
                    decb
                    bne       L177D
                    ldb       <u000F
                    bne       L178D
                    lbsr      L1253
L178B               bra       L1790
L178D               lbsr      L13A1
L1790               bcs       L1799
                    ldd       <u000E
                    suba      #$13
                    bhi       L176B
L1798               clrb
L1799               ldx       <u000C
                    jmp       ,u
L179D               lsr       <u00A0
                    neg       <u0000
                    neg       <u0007
                    eorb      #$00
                    neg       <u0000
                    dec       <u00FA
                    neg       <u0000
                    neg       <u000E
                    cmpx      <u0040
                    neg       <u0000
                    fcb       $11
                    addd      #$5000
                    neg       <u0014
                    andb      >$2400
                    neg       <u0018
                    eora      <u0096
                    suba      #$00
                    fcb       $1B
                    ldx       >$BC20
                    neg       <u001E
                    ldu       $0B,s
                    bvc       L17CA
L17CA               bhi       L1761
                    aim       #$F9,<u0000
                    bcs       L178B
                    coma
                    sta       >$4028
                    eorb      [,u]
                    bita      -$10,x
                    bge       L176C
                    anda      #$E7
                    bpl       L180E
                    bita      >$E620
                    andb      >$32E3
                    clrb
                    adca      -$0E,y
                    pshu      pc,dp,b,a
                    fcb       $1B
                    adcb      #$C0
                    rts
                    cmpa      >$A2BC
                    bgt       L182F
                    ldu       <u000B
                    tim       #u003A,$00,u
                    ora       #$C7
                    bls       L1800
L17FC               pshs      u,y,x
                    clr       <u0054
L1800               clr       <u0053
                    clr       <u000A
                    clr       <u000B
                    clr       <u0056
                    clr       <u0057
                    leau      ,x
                    ldd       #$0A30
L180F               stb       ,u+
                    deca
                    bne       L180F
                    ldb       $01,y
                    lbeq      L18E9
                    ldb       #$04
L181C               lda       b,y
                    pshs      a
                    decb
                    bpl       L181C
                    leay      ,s
                    ldb       $04,y
                    bitb      #$01
                    beq       L1831
                    inc       <u0053
                    andb      #$FE
L182F               stb       $04,y
L1831               ldd       ,y
                    bpl       L1839
                    inc       <u0054
                    nega
                    inca
L1839               ldb       #$9A
                    mul
                    lsra
                    beq       L185A
                    sta       <u0056
                    ldb       <u0054
                    beq       L1847
                    neg       <u0056
L1847               eorb      #$01
                    lbsr      L1764
                    lda       ,y
                    cmpa      #$03
                    ble       L185A
                    inc       <u0056
                    ldd       #$0101
                    lbsr      L1764
L185A               ldd       $01,y
                    tst       ,y
                    beq       L1886
                    bpl       L1872
L1862               lsra
                    rorb
                    ror       $03,y
                    ror       $04,y
                    ror       <u000A
                    inc       ,y
                    bne       L1862
                    std       $01,y
                    bra       L1886
L1872               lsl       $04,y
                    rol       $03,y
                    rolb
                    rola
                    rol       <u000B
                    dec       ,y
                    bne       L1872
                    std       $01,y
                    inc       <u0056
                    lda       <u000B
                    bsr       L18EB
L1886               ldd       $01,y
                    ldu       $03,y
L188A               clr       <u000B
                    bsr       L18F2
                    std       $01,y
                    stu       $03,y
                    pshs      a
                    lda       <u000B
                    sta       <u000A
                    puls      a
                    bsr       L18F2
                    bsr       L18F2
                    exg       d,u
                    addd      $03,y
                    exg       d,u
                    adcb      $02,y
                    adca      $01,y
                    pshs      a
                    lda       <u000B
                    adca      <u000A
                    bsr       L18EB
                    lda       <u0057
                    cmpa      #$09
                    puls      a
                    beq       L18C4
                    cmpd      #$0000
                    bne       L188A
                    cmpu      #$0000
                    bne       L188A
L18C4               sta       ,y
                    lda       <u0057
                    cmpa      #$09
                    bcs       L18E5
                    ldb       ,y
                    bpl       L18E5
L18D0               lda       ,-x
                    inca
                    sta       ,x
                    cmpa      #$39
                    bls       L18E5
                    lda       #$30
                    sta       ,x
                    cmpx      $05,s
                    bne       L18D0
                    inc       ,x
                    inc       <u0056
L18E5               dec       <u0056
                    leas      $05,s
L18E9               puls      pc,u,y,x
L18EB               ora       #$30
                    sta       ,x+
                    inc       <u0057
                    rts
L18F2               exg       d,u
                    lslb
                    rola
                    exg       d,u
                    rolb
                    rola
                    rol       <u000B
                    rts
L18FD               lda       b,x
                    adda      #$05
                    bra       L1909
L1903               decb
                    bmi       L1915
                    lda       b,x
                    inca
L1909               sta       b,x
                    cmpa      #$39
                    bls       L1919
                    lda       #$30
                    sta       b,x
                    bra       L1903
L1915               inc       ,x
                    inc       <u0056
L1919               rts
L191A               pshs      u,y
                    leay      $0C,s
                    ldx       <u001C
                    lbsr      L17FC
                    ldd       $08,s
                    lbpl      L19B9
                    ldd       #$0008
                    cmpd      $0A,s
                    bgt       L1939
                    ldd       #$0052
                    cmpd      $0A,s
                    bgt       L193B
L1939               std       $0A,s
L193B               ldd       $0A,s
                    cmpd      #$0010
                    bge       L1947
                    subb      #$06
                    bsr       L18FD
L1947               lda       #$20
                    ldb       <u0053
                    beq       L194F
                    lda       #$2D
L194F               leas      <-$52,s
                    leay      ,s
                    sta       ,y+
                    lda       ,x+
                    ldb       #$2E
                    std       ,y++
                    lda       ,x+
                    sta       ,y+
                    ldd       <$5C,s
                    subb      #$08
                    lda       #$07
                    std       <u0025
                    tstb
                    beq       L1980
L196C               lda       ,x+
                    sta       ,y+
                    dec       <u0026
                    beq       L1980
                    dec       <u0025
                    bne       L196C
L1978               lda       #$30
                    sta       ,y+
                    dec       <u0026
                    bne       L1978
L1980               lda       #$45
                    sta       ,y+
                    lda       #$2B
                    ldb       <u0056
                    bpl       L198D
                    lda       #$2D
                    negb
L198D               sta       ,y+
                    lda       #$30
L1991               subb      #$0A
                    bcs       L1998
                    inca
                    bra       L1991
L1998               addb      #$3A
                    std       ,y++
                    leau      ,s
                    ldx       <$5C,s
                    leay      ,x
L19A3               ldd       <$58,s
                    pshs      u,y,x,b,a
                    ldu       <$5C,s
                    lbsr      L05B6
                    leas      <$52,s
                    puls      u,y
                    ldx       ,s
                    leas      $0D,s
                    jmp       ,x
L19B9               cmpd      #$002A
                    bls       L19C1
                    ldb       #$2A
L19C1               stb       <u000A
                    incb
                    addb      <u0056
                    cmpb      #$09
                    bhi       L19CD
                    lbsr      L18FD
L19CD               ldb       <u0056
                    incb
                    lda       #$09
                    std       <u0025
                    leas      <-$52,s
                    leay      ,s
                    lda       <u0053
                    beq       L19E1
                    lda       #$2D
                    sta       ,y+
L19E1               cmpb      #$00
                    ble       L1A2A
L19E5               lda       ,x+
                    sta       ,y+
                    dec       <u0026
                    beq       L19F9
                    dec       <u0025
                    bne       L19E5
L19F1               lda       #$30
                    sta       ,y+
                    dec       <u0026
                    bne       L19F1
L19F9               lda       <u000A
                    beq       L1A19
                    lda       #$2E
                    sta       ,y+
                    lda       <u0025
                    beq       L1A11
L1A05               lda       ,x+
                    sta       ,y+
                    dec       <u000A
                    beq       L1A19
                    dec       <u0025
                    bne       L1A05
L1A11               lda       #$30
                    sta       ,y+
                    dec       <u000A
                    bne       L1A11
L1A19               leau      ,s
                    tfr       y,d
                    pshs      u
                    subd      ,s++
                    tfr       d,x
                    ldy       <$5C,s
                    lbra      L19A3
L1A2A               lda       #$30
                    sta       ,y+
                    lda       <u000A
                    beq       L1A19
                    lda       #$2E
                    sta       ,y+
                    negb
                    stb       <u0026
                    beq       L1A47
L1A3B               lda       #$30
                    sta       ,y+
                    dec       <u000A
                    beq       L1A19
                    dec       <u0026
                    bne       L1A3B
L1A47               lda       ,x+
                    sta       ,y+
                    dec       <u000A
                    beq       L1A19
                    dec       <u0025
                    bne       L1A47
L1A53               lda       #$30
                    sta       ,y+
                    dec       <u000A
                    bne       L1A53
                    bra       L1A19
L1A5D               lbsr      L14AC
                    beq       L1A65
L1A62               clrb
                    bra       L1A67
L1A65               ldb       #$01
L1A67               ldx       ,s
                    leas      $0B,s
                    stb       ,s
                    jmp       ,x
L1A6F               lbsr      L14AC
                    bne       L1A65
                    bra       L1A62
L1A76               lbsr      L14AC
                    bgt       L1A65
                    bra       L1A62
L1A7D               lbsr      L14AC
                    bge       L1A65
                    bra       L1A62
L1A84               lbsr      L14AC
                    blt       L1A65
                    bra       L1A62
L1A8B               lbsr      L14AC
                    ble       L1A65
                    bra       L1A62
L1A92               ldb       ,y
                    bgt       L1AA8
                    bmi       L1A9C
                    lda       $01,y
                    bmi       L1A9F
L1A9C               clrb
                    bra       L1AA1
L1A9F               ldb       #$01
L1AA1               clra
                    std       $02,u
                    clrb
                    std       ,u
                    rts
L1AA8               subb      #$20
                    bhi       L1AD9
                    stb       <u0025
                    ldd       $01,y
                    std       ,u
                    ldd       $03,y
                    bitb      #$01
                    bne       L1AD9
                    tst       <u0025
                    beq       L1AD5
L1ABC               lsr       ,u
                    ror       $01,u
                    rora
                    rorb
                    inc       <u0025
                    bne       L1ABC
                    bcc       L1AD5
                    addd      #$0001
                    bne       L1AD5
                    inc       $01,u
                    bne       L1AD5
                    inc       ,u
                    beq       L1AD9
L1AD5               std       $02,u
                    clrb
                    rts
L1AD9               bsr       L1A9C
                    comb
                    rts
L1ADD               ldd       ,u
                    beq       L1AEB
                    std       $01,y
                    ldd       $02,u
                    std       $03,y
                    ldb       #$20
                    bra       L1AF8
L1AEB               std       $03,y
                    ldd       $02,u
                    bne       L1AF4
                    std       ,y
                    rts
L1AF4               std       $01,y
                    ldb       #$10
L1AF8               stb       ,y
                    tst       $01,y
                    bmi       L1B0A
L1AFE               dec       ,y
                    lsl       $04,y
                    rol       $03,y
                    rol       $02,y
                    rol       $01,y
                    bpl       L1AFE
L1B0A               ldb       $04,y
                    andb      #$FE
                    stb       $04,y
                    rts
                    pshs      u,y
                    ldx       $06,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L1B27
                    ldd       #$0058
                    lbsr      L0B5C
L1B21               clra
                    clrb
                    std       $08,s
                    bra       L1B31
L1B27               lda       $0F,x
                    bne       L1B21
                    leay      $08,s
                    leau      $06,x
                    bsr       L1ADD
L1B31               puls      u,y
                    ldx       ,s
                    leas      $04,s
                    jmp       ,x
                    pshs      u,y
                    ldx       $0B,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L1B4D
                    ldb       #$56
L1B45               clra
                    ldu       $02,s
                    lbsr      L0B5C
                    bra       L1B96
L1B4D               lda       $0F,x
                    bne       L1B96
                    ldb       $0B,x
                    andb      #$FE
                    orb       #$80
                    stb       $0B,x
                    leay      $06,s
                    leau      $06,x
                    lbsr      L1A92
                    bcs       L1B92
                    leas      -$05,s
                    leay      ,s
                    lbsr      L1ADD
                    ldd       $04,x
                    pshs      b,a
                    lbsr      L14FC
                    lbsr      L1253
                    ldu       <u0002
                    leau      <$29,u
                    lbsr      L1A92
                    leas      $05,s
                    bcs       L1B92
                    ldx       $0B,s
                    lda       $0C,x
                    ldx       <u0029
                    ldu       <u002B
                    os9       I$Seek
                    bcc       L1B96
                    stb       <u002E
                    ldb       #$53
                    bra       L1B45
L1B92               ldb       #$54
                    bra       L1B45
L1B96               puls      u,y
                    ldx       ,s
                    leas      $09,s
                    jmp       ,x
                    pshs      u,y
                    leas      -$05,s
                    ldx       $0B,s
                    ldb       $0B,x
                    andb      #$0C
                    bne       L1BAF
                    ldd       #$0059
                    bra       L1BEE
L1BAF               cmpb      #$04
                    bne       L1BB8
                    ldd       #$004D
                    bra       L1BEE
L1BB8               lda       $0F,x
                    bne       L1BF3
                    leau      $06,x
                    leay      ,s
                    lbsr      L1ADD
                    ldd       $04,x
                    pshs      b,a
                    lbsr      L14FC
                    lbsr      L1253
                    ldu       <u0002
                    leau      <$29,u
                    lbsr      L1A92
                    bcc       L1BDC
                    ldd       #$004B
                    bra       L1BEE
L1BDC               ldx       $0B,s
                    lda       $0C,x
                    ldx       <u0029
                    ldu       <u002B
                    ldb       #$02
                    os9       I$SetStt
                    bcc       L1BF3
                    ldd       #$004C
L1BEE               ldu       $07,s
                    lbsr      L0B5C
L1BF3               leas      $05,s
                    puls      u,y
                    ldx       ,s
                    leas      $04,s
                    jmp       ,x
L1BFD               pshs      u,y
                    leas      -$05,s
                    ldx       $0B,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L1C0E
                    ldd       #$0052
                    bra       L1C74
L1C0E               lda       $0F,x
                    bne       L1C79
                    orb       #$80
                    stb       $0B,x
                    lda       $0C,x
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L1C4B
                    stx       <u0029
                    stu       <u002B
                    ldu       <u0002
                    leau      <$29,u
                    leay      ,s
                    lbsr      L1ADD
                    ldx       $0B,s
                    ldd       $04,x
                    pshs      b,a
                    leau      $06,x
                    lbsr      L14FC
                    lbsr      L13A1
                    lbsr      L1A92
                    ldx       $0B,s
                    lda       $0C,x
                    ldx       <u0029
                    ldu       <u002B
                    os9       I$Seek
                    bcc       L1C52
L1C4B               stb       <u002E
                    ldd       #$0051
                    bra       L1C74
L1C52               ldx       $0B,s
                    ldd       $04,x
                    pshs      b,a
                    lbsr      L14FC
                    lbsr      L1253
                    ldu       <u0002
                    leau      $0A,u
                    lbsr      L1A92
                    ldx       <u000A
                    cmpx      <u0029
                    bne       L1C71
                    ldx       <u000C
                    cmpx      <u002B
                    beq       L1C79
L1C71               ldd       #$0050
L1C74               ldu       $07,s
                    lbsr      L0B5C
L1C79               leas      $05,s
                    puls      u,y
                    ldx       ,s
                    leas      $04,s
                    jmp       ,x
L1C83               neg       <u0080
                    subb      #$E0
                    subb      >$F8FC
                    ldu       >$A662
                    ble       L1CBD
                    cmpa      #$1F
                    bge       L1CA9
                    leax      <L1C83,pcr
                    anda      #$07
                    ldb       a,x
                    lda       $02,s
                    lsra
                    lsra
                    lsra
                    cmpa      #$03
                    bne       L1CAA
L1CA3               orb       #$01
                    andb      $06,s
                    stb       $06,s
L1CA9               rts
L1CAA               adda      #$03
                    andb      a,s
                    stb       a,s
                    clrb
                    cmpa      #$04
                    bhi       L1CA3
                    beq       L1CB9
                    stb       $04,s
L1CB9               stb       $05,s
                    bra       L1CA3
L1CBD               clra
                    clrb
                    std       $02,s
                    rts
L1CC2               lda       $02,s
                    ble       L1CCE
                    cmpa      #$1F
                    blt       L1CCF
                    clra
                    clrb
                    std       $02,s
L1CCE               rts
L1CCF               clr       <u0028
                    ldb       $06,s
                    bitb      #$01
                    beq       L1CD9
                    inc       <u0028
L1CD9               andb      #$FE
                    stb       $06,s
                    clr       $02,s
                    suba      #$10
                    bcs       L1CFD
                    suba      #$08
                    bcs       L1CEE
                    sta       <u0025
                    lda       $06,s
                    clrb
                    bra       L1CF4
L1CEE               adda      #$08
                    sta       <u0025
                    ldd       $05,s
L1CF4               ldx       #$0000
                    tst       <u0025
                    beq       L1D24
                    bra       L1D18
L1CFD               adda      #$08
                    bcc       L1D10
                    sta       <u0025
                    ldx       $04,s
                    lda       $06,s
                    clrb
                    tst       <u0025
                    bne       L1D1A
                    exg       d,x
                    bra       L1D24
L1D10               adda      #$08
                    sta       <u0025
                    ldx       $05,s
                    ldd       $03,s
L1D18               exg       d,x
L1D1A               lslb
                    rola
                    exg       d,x
                    rolb
                    rola
                    dec       <u0025
                    bne       L1D18
L1D24               tsta
                    bmi       L1D4C
                    leax      ,x
                    bne       L1D40
                    tstb
                    bne       L1D38
                    tsta
                    beq       L1D4C
L1D31               dec       $02,s
                    lsla
                    bpl       L1D31
                    bra       L1D4C
L1D38               dec       $02,s
                    lslb
                    rola
                    bpl       L1D38
                    bra       L1D4C
L1D40               dec       $02,s
                    exg       d,x
                    lslb
                    rola
                    exg       d,x
                    rolb
                    rola
                    bpl       L1D40
L1D4C               std       $03,s
                    tfr       x,d
                    orb       <u0028
                    std       $05,s
                    rts
L1D55               pshs      u,y
                    leas      -$05,s
                    ldx       $0B,s
                    ldb       $0B,x
                    bitb      #$0C
                    bne       L1D66
                    ldd       #$0029
                    bra       L1DA4
L1D66               lda       $0F,x
                    bne       L1DAB
                    lda       $0C,x
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L1D9F
                    stx       <u0029
                    stu       <u002B
                    ldu       <u0002
                    leau      <$29,u
                    leay      ,s
                    lbsr      L1ADD
                    ldx       $0B,s
                    ldd       $04,x
                    pshs      b,a
                    lbsr      L14FC
                    lbsr      L13A1
                    lbsr      L1A92
                    leay      $0D,s
                    lbsr      L1ADD
L1D95               leas      $05,s
                    puls      u,y
                    ldx       ,s
                    leas      $04,s
                    jmp       ,x
L1D9F               stb       <u002E
                    ldd       #$002A
L1DA4               ldx       $0B,s
                    ldu       $07,s
                    lbsr      L0B5C
L1DAB               clra
                    clrb
                    std       $0D,s
                    bra       L1D95
L1DB1               clra
                    clrb
                    std       $02,s
                    ldb       #$70
                    stb       <u00D0
                    tst       <u003A
                    bne       L1DBE
                    rts
L1DBE               lbra      L0B5C
                    emod
eom                 equ       *
