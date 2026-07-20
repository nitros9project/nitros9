                    nam       descgen
                    ttl       program module

* Disassembled 02/07/15 07:28:09 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       /dd/defs/os9defs
                    endc
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       2
u0006               rmb       3
u0009               rmb       1
u000A               rmb       3
u000D               rmb       3
u0010               rmb       2
u0012               rmb       4
u0016               rmb       1
u0017               rmb       8
u001F               rmb       1
u0020               rmb       15
u002F               rmb       1
u0030               rmb       4
u0034               rmb       5
u0039               rmb       11
u0044               rmb       13
u0051               rmb       12
u005D               rmb       7
u0064               rmb       29
u0081               rmb       3
u0084               rmb       2
u0086               rmb       3
u0089               rmb       2
u008B               rmb       25
u00A4               rmb       2
u00A6               rmb       8
u00AE               rmb       22
u00C4               rmb       2
u00C6               rmb       2
u00C8               rmb       30
u00E6               rmb       1
u00E7               rmb       1
u00E8               rmb       2
u00EA               rmb       1
u00EB               rmb       13
u00F8               rmb       76
u0144               rmb       1724
size                equ       .
name                equ       *
                    fcs       /descgen/
start               equ       *
                    leau      u0001,u
                    tfr       u,d
                    leau      >-$011A,s
                    leay      u000A,u
                    stx       $06,y
                    std       -$02,y
                    std       $02,y
                    leax      >u00C8,u
                    stx       -$04,y
                    sty       -$06,y
                    clr       -$07,y
                    stu       ,y
                    clr       $04,y
                    lbsr      L003A
                    clrb
                    os9       F$Exit
L003A               leau      >-u0144,u
                    lbsr      L0ABB
                    leax      >-$0144,y
                    stx       $08,y
                    lda       #$84
                    lbsr      L0B38
                    leax      >-$014E,y
                    stx       $0A,y
                    lda       #$04
                    lbsr      L0B6C
                    leax      >-$00C4,y
                    clra
                    lbsr      L0C2D
                    lbra      L03F3
L0062               lbsr      L0A9B
                    pshs      u,y,x
                    ldx       ,y
                    ldy       #$002C
                    leau      <$2C,x
                    os9       F$CRC
                    com       ,u
                    com       u0001,u
                    com       u0002,u
                    puls      u,y,x
                    ldd       #$0002
                    lbra      L0AEE
L0081               leau      -u0001,u
                    lbsr      L0A9B
                    leau      <-u0051,u
                    lbsr      L0ABB
                    leax      <-$5B,y
                    lbsr      L04F6
                    lbsr      L060E
                    fcb       $51                 Q
                    lbsr      L0718
                    leax      <-$5B,y
                    lbsr      L0A23
                    lbsr      L07A2
                    subd      #$0000
                    bne       L00AB
                    ldb       #$01
                    bra       L00AC
L00AB               clrb
L00AC               pshu      b
                    leax      <-$5B,y
                    lbsr      L0A23
                    ldd       #$0001
                    pshu      b,a
                    lbsr      L07A8
                    lbsr      L0781
                    ldb       #$59
                    pshu      b
                    lbsr      L0972
                    oim       #$20,<u00EA
                    subb      #$27
                    eim       #$5F,<u00E7
                    anda      $00,y
                    lsr       <u00C6
                    oim       #$E7,<u00A4
                    lbsr      L0ACE
                    neg       <u0001
                    oim       #$17,<u0009
                    jsr       >$3356
                    lbsr      L0ABB
                    clrb
                    stb       -$0B,y
                    ldx       -$06,y
                    leax      <-$39,x
                    pshu      x
                    ldd       #$87CD
                    std       [<-$16,y]
                    ldd       #$002F
                    ldx       <-$16,y
                    std       $02,x
                    ldb       #$21
                    ldx       <-$16,y
                    std       $04,x
                    ldb       #$F1
                    ldx       <-$16,y
                    stb       $06,x
                    ldb       #$82
                    ldx       <-$16,y
                    stb       $07,x
                    ldb       #$C8
                    ldx       <-$16,y
                    stb       $08,x
                    ldb       #$24
                    ldx       <-$16,y
                    std       $09,x
                    ldb       #$27
                    ldx       <-$16,y
                    std       $0B,x
                    ldb       #$FF
                    ldx       <-$16,y
                    stb       $0D,x
                    ldx       <-$16,y
                    stb       $0E,x
                    ldd       #$FF48
                    ldx       <-$16,y
                    std       $0F,x
                    ldb       #$0F
                    ldx       <-$16,y
                    stb       <$11,x
                    clrb
                    ldx       <-$16,y
                    stb       <$23,x
                    ldb       #$52
                    ldx       <-$16,y
                    stb       <$24,x
                    ldb       #$42
                    ldx       <-$16,y
                    stb       <$25,x
                    ldb       #$C6
                    ldx       <-$16,y
                    stb       <$26,x
                    ldb       #$53
                    ldx       <-$16,y
                    stb       <$27,x
                    ldb       #$64
                    ldx       <-$16,y
                    stb       <$28,x
                    ldb       #$69
                    ldx       <-$16,y
                    stb       <$29,x
                    ldb       #$73
                    ldx       <-$16,y
                    stb       <$2A,x
                    ldb       #$EB
                    ldx       <-$16,y
                    stb       <$2B,x
                    ldb       #$FF
                    ldx       <-$16,y
                    stb       <$2C,x
                    ldx       <-$16,y
                    std       <$2D,x
                    ldb       #$01
                    ldx       <-$16,y
                    stb       <$12,x
                    clrb
                    ldx       <-$16,y
                    stb       <$1A,x
                    ldb       #$04
                    ldx       <-$16,y
                    stb       <$1F,x
                    ldb       #$08
                    ldx       <-$16,y
                    stb       <$20,x
                    lbsr      L0A17
                    lbsr      L452A
                    inc       $0F,s
                    aim       #$20,>$436F
                    tst       -$10,s
                    eim       #$74,>$6572
                    bra       L020F
                    clr       -$0E,s
                    tst       $01,s
                    lsr       >$3F20
                    lbsr      L0500
                    lbsr      L05C5
                    clra
                    lbsr      L0081
                    ldb       ,u+
                    stb       -$0B,y
                    ldb       -$0B,y
                    lbeq      L01FE
                    ldb       #$20
                    ldx       <-$16,y
                    stb       <$15,x
                    ldd       #$0012
                    ldx       <-$16,y
                    std       <$1B,x
                    ldx       <-$16,y
                    std       <$1D,x
                    lbra      L0216
L01FE               clrb
                    ldx       <-$16,y
                    stb       <$15,x
                    ldd       #$0010
                    ldx       <-$16,y
                    std       <$1B,x
                    ldb       #$0A
                    ldx       <-$16,y
                    std       <$1D,x
L0216               lbsr      L0A17
                    orcc      #$53
                    lsr       >$6570
                    bra       L0292
                    oim       #$74,$05,s
                    bra       L028E
                    jmp       $00,y
                    tst       $09,s
                    inc       $0C,s
                    rol       -$0D,s
                    eim       #$63,$0F,s
                    jmp       $04,s
                    com       >$3D17
                    aim       #$C9,<u0017
                    com       <u008B
                    ldb       #$01
                    stb       -$0C,y
                    leax      <-$12,y
                    lbsr      L04F6
                    lbsr      L0564
                    lbsr      L0718
                    ldd       <-$12,y
                    cmpd      #$001E
                    bne       L025D
                    clrb
                    ldx       <-$16,y
                    stb       <$14,x
                    lbra      L0292
L025D               cmpd      #$0014
                    bne       L026E
                    ldb       #$01
                    ldx       <-$16,y
                    stb       <$14,x
                    lbra      L0292
L026E               cmpd      #$000C
                    bne       L027F
                    ldb       #$02
                    ldx       <-$16,y
                    stb       <$14,x
                    lbra      L0292
L027F               cmpd      #$0006
                    bne       L028F
                    ldb       #$03
                    ldx       <-$16,y
                    stb       <$14,x
                    bra       L0292
L028F               clrb
                    stb       -$0C,y
L0292               ldb       -$0C,y
                    lbeq      L0216
                    lbsr      L0A17
                    fcb       $11
                    lsra
                    aim       #$69,>$7665
                    bra       L030C
                    com       >$2039
                    pshu      y
                    lsrb
                    negb
                    rola
                    swi
                    fcb       $20
                    lbsr      L0500
                    lbsr      L05C5
                    clra
                    lbsr      L0081
                    ldb       ,u+
                    beq       L02C5
                    ldb       #$03
                    ldx       <-$16,y
                    stb       <$16,x
                    bra       L02CD
L02C5               ldb       #$01
                    ldx       <-$16,y
                    stb       <$16,x
L02CD               lbsr      L0A17
                    lbra      L5148
                    tst       $02,s
                    eim       #$72,$00,y
                    clr       $06,s
                    bra       L033F
                    rol       >$6C69
                    jmp       $04,s
                    eim       #$72,-$0D,s
                    bra       L0323
                    bra       L02FF
                    aim       #$16,<u0017
                    aim       #$D8,<u0030
                    eora      <L0308,pcr
                    aim       #$03,<u0017
                    aim       #$6E,<u0017
                    lsr       <u001F
                    ldd       <-$14,y
                    ldx       <-$16,y
L02FF               std       <$17,x
L0302               ldb       #$01
                    stb       -$0C,y
                    lbsr      L0A17
                    nop
                    fcb       $4E                 N
                    eim       #$6D,>$6265
                    aim       #$20,>$6F66
                    bra       L0388
                    rol       $04,s
                    eim       #$73,$00,y
                    mul
                    bra       L0334
                    oim       #$E1,<u0017
                    aim       #$A3,<u0030
L0323               leas      -$09,x
                    oim       #$CF,<u0017
                    aim       #$3A,<u0017
                    com       <u00EB
                    ldd       -$0E,y
                    ldx       <-$16,y
                    stb       <$19,x
                    ldd       -$0E,y
                    subd      #$0002
                    ble       L0340
                    ldb       #$01
                    bra       L0341
L0340               clrb
L0341               pshu      b
                    ldd       -$0E,y
                    subd      #$0001
                    bge       L034E
                    ldb       #$01
                    bra       L034F
L034E               clrb
L034F               orb       ,u+
                    beq       L0356
                    clrb
                    stb       -$0C,y
L0356               ldb       -$0C,y
                    lbeq      L0302
L035C               ldb       #$01
                    stb       -$0C,y
                    lbsr      L0A17
                    clr       <u0044
                    aim       #$69,>$7665
                    bra       L03D9
                    eim       #$6D,>$6265
                    aim       #$20,>$3D20
                    lbsr      L0500
                    lbsr      L05C5
                    leax      -$10,y
                    lbsr      L04F6
                    lbsr      L0564
                    lbsr      L0718
                    ldd       -$10,y
                    ldx       <-$16,y
                    stb       <$13,x
                    ldd       -$10,y
                    subd      #$0000
                    bge       L0397
                    ldb       #$01
                    bra       L0398
L0397               clrb
L0398               pshu      b
                    ldd       -$10,y
                    subd      #$0003
                    ble       L03A5
                    ldb       #$01
                    bra       L03A6
L03A5               clrb
L03A6               orb       ,u+
                    beq       L03AD
                    clrb
                    stb       -$0C,y
L03AD               ldb       -$0C,y
                    lbeq      L035C
                    ldb       -$0B,y
                    lbeq      L03D0
                    ldb       #$44
                    ldx       <-$16,y
                    stb       <$21,x
                    ldd       -$10,y
                    addb      #$30
                    addb      #$80
                    ldx       <-$16,y
                    stb       <$22,x
                    lbra      L03EC
L03D0               ldb       #$53
                    ldx       <-$16,y
                    stb       <$21,x
                    ldb       #$44
                    ldx       <-$16,y
                    stb       <$22,x
                    ldd       -$10,y
                    addb      #$30
                    addb      #$80
                    ldx       <-$16,y
                    stb       <$23,x
L03EC               leau      u0002,u
                    clra
                    clrb
                    lbra      L0AEE
L03F3               lbsr      L0A17
                    fcb       $1B
                    lsra
                    eim       #$76,$09,s
                    com       $05,s
                    bra       L0443
                    eim       #$73,$03,s
                    aim       #$69,>$7074
                    clr       -$0E,s
                    bra       L0451
                    eim       #$6E,$05,s
                    aim       #$61,>$746F
                    aim       #$17,>$00EB
                    lbsr      L05C5
                    lbsr      L06F6
                    lbsr      L0A17
                    fcb       $1B
                    coma
                    clr       -$10,s
                    rol       >$7269
                    asr       $08,s
                    lsr       >$2031
                    rts
                    fcb       $38                 8
                    pshs      y
                    lsra
                    bgt       L0481
                    bgt       L0453
                    deca
                    clr       $08,s
                    jmp       -$0D,s
                    clr       $0E,s
                    lbsr      L0500
                    lbsr      L05C5
                    lbsr      L06F6
L0443               lbsr      L0500
                    lbsr      L06F6
L0449               lda       #$FF
                    lbsr      L00DB
                    leax      <-$39,y
L0451               tfr       x,d
L0453               pshu      b,a
                    lda       #$FF
                    lbsr      L0062
                    lbsr      L0A17
                    exg       pc,d
                    oim       #$74,$08,s
                    jmp       $01,s
                    tst       $05,s
                    bra       L04DC
                    clr       $00,y
                    com       >$6176
                    eim       #$20,$04,s
                    eim       #$73,$03,s
                    aim       #$69,>$7074
                    clr       -$0E,s
                    bra       L04EF
                    clr       -$09,x
                    neg       <u0081
                    lbsr      L05C5
                    lbsr      L06F6
                    lbsr      L0A17
                    aim       #$3D,<u0020
                    lbsr      L0500
                    lbsr      L05C5
                    leax      >-$008A,y
                    lbsr      L04F6
                    lbsr      L060E
                    fcb       $51                 Q
                    lbsr      L0718
                    leax      >-$00C4,y
                    pshu      x
                    ldd       #$002F
                    pshu      b,a
                    leax      >-$008A,y
                    lbsr      L0A23
                    lda       #$02
                    pshu      a
                    clrb
                    lbsr      L065C
                    leax      >-$00C4,y
                    stx       -$0A,y
                    leax      <-$39,y
                    lbsr      L09E6
                    neg       <u002F
                    lbsr      L053B
                    leax      >-$00C4,y
                    lbsr      L06A7
                    lbsr      L0A17
                    inc       <u0044
                    clra
                    bra       L051A
                    fcb       $4E                 N
                    clra
                    lsrb
L04DC               lsla
                    fcb       $45                 E
                    fcb       $52                 R
                    swi
                    fcb       $20
                    lbsr      L0500
                    lbsr      L05C5
                    lda       #$FF
                    lbsr      L0081
                    ldb       ,u+
                    eorb      #$01
                    lbeq      L0449
                    rts
                    neg       <u0034
                    ldy       -$06,y
                    ldx       $08,x
                    stx       -$0A,y
                    puls      pc,x
L0500               pshs      x
                    ldx       -$06,y
                    ldx       $0A,x
                    stx       -$0A,y
                    puls      pc,x
                    aim       #$A6,<u0084
                    bita      #$08
                    bne       L0514
                    lbsr      L0762
L0514               leax      $06,x
                    rts
                    pshu      x
                    ldx       -$0A,y
                    ldd       $04,x
                    pshs      y,b,a
                    bsr       L050B
                    pulu      y
L0523               lda       ,x+
                    sta       ,y+
                    ldd       ,s
                    subd      #$0001
                    std       ,s
                    bne       L0523
                    puls      y,b,a
                    ldx       -$0A,y
                    lda       ,x
                    anda      #$F7
                    sta       ,x
                    rts
L053B               pshs      y
                    ldy       -$0A,y
                    ldx       $04,y
                    leay      $06,y
L0544               pulu      a
                    sta       ,y+
                    leax      -$01,x
                    bne       L0544
                    puls      y
                    ldx       -$0A,y
                    lbra      L074E
                    aim       #$36,<u0006
                    ldb       #$0A
                    pshs      b
                    pulu      b,a
                    lbsr      L0842
                    puls      b
                    lbra      L05B2
L0564               pshs      x
                    lbsr      L0572
                    lbsr      L08AD
                    puls      x
                    std       ,x
                    rts
                    aim       #$34,<u0020
                    leas      <-$1A,s
L0577               ldx       -$0A,y
                    lbsr      L06E4
                    cmpa      #$20
                    beq       L0577
                    clr       ,s
                    leay      $01,s
L0584               ldb       ,s
                    cmpb      #$18
                    bhi       L058D
                    incb
                    sta       ,y+
L058D               stb       ,s
                    pshs      y
                    ldy       <$1A,s
                    lbsr      L06E4
                    puls      y
                    cmpa      #$20
                    bne       L0584
                    ldb       ,s
L05A0               lda       b,s
                    pshu      a
                    decb
                    bpl       L05A0
                    lda       ,x
                    ora       #$08
                    sta       ,x
                    leas      <$1A,s
                    puls      pc,y
L05B2               stb       ,-s
                    bpl       L05B7
                    negb
L05B7               cmpb      ,u
                    bcc       L05BF
                    ldb       ,u
                    stb       ,s
L05BF               puls      b
                    lbra      L05C7
                    ror       <u00E6
                    andb      #$1F
                    eora      <u005D
                    bpl       L05CD
                    nega
L05CD               pshs      b,a
                    ldx       -$0A,y
                    tstb
                    bmi       L05DA
                    subb      ,u
                    ble       L05DA
                    bsr       L05F9
L05DA               ldb       ,u
                    cmpb      ,s
                    bls       L05E2
                    ldb       ,s
L05E2               tstb
                    beq       L05E8
                    lbsr      L06C4
L05E8               ldb       $01,s
                    bpl       L05F3
                    negb
                    subb      ,u
                    ble       L05F3
                    bsr       L05F9
L05F3               ldb       ,u+
                    leau      b,u
                    puls      pc,b,a
L05F9               pshs      b
                    lda       #$20
L05FD               pshu      a
                    decb
                    bne       L05FD
                    puls      b
                    pshu      b
                    lbsr      L06C4
                    ldb       ,u+
                    leau      b,u
                    rts
L060E               pshu      x
                    ldx       ,s
                    lda       ,x+
                    stx       ,s
                    pshu      a
                    clr       ,-s
                    clr       [<u0001,u]
L061D               ldx       -$0A,y
                    lda       ,x
                    bita      #$80
                    bne       L062A
                    lbsr      L094A
                    bne       L064D
L062A               lbsr      L06E4
                    ldb       ,x
                    bitb      #$80
                    beq       L063C
                    pshs      a
                    lbsr      L094A
                    puls      a
                    bne       L064D
L063C               ldb       ,s
                    incb
                    cmpb      ,u
                    bcc       L061D
                    ldx       u0001,u
                    sta       b,x
                    stb       ,x
                    inc       ,s
                    bra       L061D
L064D               ldb       ,x
                    orb       #$08
                    stb       ,x
                    leau      u0003,u
                    puls      pc,b
                    lsr       <u0086
                    oim       #$20,<u0002
L065C               lda       #$02
                    pshs      y,b,a
                    leax      u0001,u
                    ldb       ,x
                    beq       L066D
L0666               lda       $01,x
                    sta       ,x+
                    decb
                    bne       L0666
L066D               lda       #$0D
                    sta       ,x+
                    ldd       ,x
                    pshs      x
                    ldx       $02,x
                    std       $04,x
                    clr       $01,x
                    bsr       L06A7
                    lda       ,x
                    anda      #$04
                    ora       ,u
                    sta       ,x
                    lda       $02,s
                    ldb       $03,s
                    ldy       $02,x
                    leay      $09,y
                    pshs      y
                    leay      u0001,u
                    jsr       [,s++]
                    puls      y
                    leau      $04,y
                    lda       $01,x
                    beq       L06A2
                    ldb       ,x
                    andb      #$FC
                    stb       ,x
L06A2               puls      y,x
                    lbra      L0B22
L06A7               lda       ,x
                    bita      #$03
                    beq       L06B8
                    pshs      y
                    ldy       $02,x
                    lda       #$03
                    jsr       $09,y
                    puls      y
L06B8               lda       ,x
                    anda      #$FC
                    sta       ,x
                    lda       $01,x
                    lbra      L0B22
                    com       <u0034
                    leax      a,y
                    anda      #$85
                    aim       #$27,<u0012
                    tst       $01,x
                    bne       L06D7
                    ldy       $02,x
                    lda       #$FF
                    jsr       $03,y
L06D7               puls      y,x
                    lda       $01,x
                    lbra      L0B22
                    lda       #$11
                    sta       $01,x
                    bra       L06D7
L06E4               lda       ,x
                    bita      #$08
                    bne       L06ED
                    lbsr      L0762
L06ED               ldb       ,x
                    andb      #$F7
                    stb       ,x
                    lda       $06,x
                    rts
L06F6               pshs      y,x
                    ldx       -$0A,y
                    lda       ,x
                    bita      #$02
                    beq       L0712
                    tst       $01,x
                    bne       L070B
                    ldy       $02,x
                    lda       #$01
                    jsr       $03,y
L070B               lda       $01,x
                    puls      y,x
                    lbra      L0B22
L0712               lda       #$11
                    sta       $01,x
                    bra       L070B
L0718               pshs      y,x
                    ldx       -$0A,y
                    lda       ,x
                    bita      #$01
                    beq       L0712
L0722               tst       $01,x
                    bne       L070B
                    lbsr      L094A
                    bne       L0730
                    lbsr      L0762
                    bra       L0722
L0730               ldb       ,x
                    andb      #$B7
                    stb       ,x
                    bra       L070B
                    pshs      y,x
                    lda       ,x
                    bita      #$02
                    beq       L0712
                    tst       $01,x
                    bne       L070B
                    ldy       $02,x
                    lda       #$06
                    jsr       $09,y
                    bra       L070B
                    aim       #$34,<u0030
                    lda       ,x
                    bita      #$02
                    beq       L077A
                    tst       $01,x
                    bne       L0773
                    ldy       $02,x
                    clra
                    jsr       $03,y
                    bra       L0773
L0762               pshs      y,x
                    lda       ,x
                    bita      #$01
                    beq       L077A
                    tst       $01,x
                    bne       L0773
                    ldy       $02,x
                    jsr       $06,y
L0773               puls      y,x
                    lda       $01,x
                    lbra      L0B22
L077A               lda       #$11
                    sta       $01,x
                    bra       L0773
                    oim       #$A6,<u00C4
                    pshs      a
                    lda       #$01
L0787               cmpa      ,s
                    bhi       L0794
                    ldb       a,u
                    bsr       L0796
                    stb       a,u
                    inca
                    bra       L0787
L0794               puls      pc,a
L0796               cmpb      #$61
                    bcs       L07A0
                    cmpb      #$7A
                    bhi       L07A0
                    subb      #$20
L07A0               rts
                    aim       #$37,<u0004
                    leau      b,u
                    clra
                    rts
L07A8               leax      u0002,u
                    pshu      b,a
                    ora       u0002,u
                    bne       L0800
                    ldb       u0003,u
                    beq       L0800
                    cmpb      #$7E
                    bhi       L0800
                    tst       u0001,u
                    beq       L07D1
                    addb      u0001,u
                    bcs       L0800
                    cmpb      u0004,u
                    bls       L07CB
                    ldb       u0004,u
                    incb
                    subb      u0003,u
                    stb       u0001,u
L07CB               ldb       u0003,u
                    cmpb      u0004,u
                    bls       L07D8
L07D1               ldb       ,x+
                    leau      b,x
                    clr       ,-u
                    rts
L07D8               leax      b,x
                    ldb       u0001,u
                    stb       u0002,u
                    decb
                    stb       ,u
                    ldb       u0004,u
                    subb      u0003,u
                    stb       u0003,u
L07E7               ldb       ,u
                    lda       b,x
                    ldb       u0003,u
                    sta       b,x
                    dec       u0003,u
                    dec       ,u
                    dec       u0002,u
                    bne       L07E7
                    lda       u0003,u
                    ldb       u0001,u
                    leau      a,x
                    stb       ,u
                    rts
L0800               ldb       ,x+
                    leau      b,x
                    clr       ,-u
                    lda       #$0A
                    lbra      L0B18
                    pshs      y,b
                    leay      ,u
                    leax      ,u
                    ldb       ,x+
                    leax      b,x
                    ldb       #$FF
                    stb       ,s
L0819               inc       ,s
                    ldb       ,y
L081D               lda       b,y
                    addb      ,s
                    cmpb      ,x
                    bhi       L083E
                    cmpa      b,x
                    bne       L0819
                    subb      ,s
                    decb
                    bne       L081D
                    ldb       ,s
                    incb
L0831               lda       ,u+
                    leau      a,u
                    lda       ,u+
                    leau      a,u
                    clra
                    leas      $01,s
                    puls      pc,y
L083E               clrb
                    bra       L0831
                    aim       #$34,<u0020
                    leas      -$0A,s
                    clr       $02,s
                    tsta
                    bpl       L0852
                    coma
                    comb
                    addd      #$0001
                    inc       $02,s
L0852               leax      $05,s
                    leay      <L08AD,pcr
                    sty       $03,s
                    leay      -$0A,y
L085C               clr       $01,s
L085E               subd      ,y
                    bcs       L0866
                    inc       $01,s
                    bra       L085E
L0866               addd      ,y++
                    pshs      a
                    lda       $02,s
                    adda      #$30
                    sta       ,x+
                    puls      a
                    cmpy      $03,s
                    bne       L085C
                    leax      $05,s
                    ldb       #$05
L087B               lda       ,x+
                    cmpa      #$30
                    bne       L0884
                    decb
                    bne       L087B
L0884               leax      -$01,x
                    stx       $03,s
                    clrb
                    leax      $0A,s
L088B               lda       ,-x
                    pshu      a
                    incb
                    cmpx      $03,s
                    bhi       L088B
                    tst       $02,s
                    beq       L089D
                    lda       #$2D
                    pshu      a
                    incb
L089D               pshu      b
                    leas      $0A,s
                    puls      pc,y
                    beq       L08B5
                    com       <u00E8
                    neg       <u0064
                    neg       <u000A
                    neg       <u0001
L08AD               leas      -$05,s
                    leax      ,u
                    ldd       #$0000
                    std       $03,s
                    clr       $02,s
                    lda       ,x+
                    sta       ,s
                    beq       L0916
                    lda       ,x+
                    dec       ,s
                    cmpa      #$2B
                    beq       L08CC
                    cmpa      #$2D
                    bne       L08D2
                    inc       $02,s
L08CC               lda       ,x+
                    dec       ,s
                    bmi       L0916
L08D2               cmpa      #$30
                    bcs       L0916
                    cmpa      #$39
                    bhi       L0916
                    anda      #$0F
                    sta       $01,s
                    ldd       $03,s
                    lslb
                    rola
                    bmi       L0916
                    lslb
                    rola
                    bmi       L0916
                    addd      $03,s
                    bmi       L0916
                    lslb
                    rola
                    bmi       L0916
                    addb      $01,s
                    adca      #$00
                    bmi       L0916
                    std       $03,s
                    lda       ,x+
                    dec       ,s
                    bpl       L08D2
                    tst       $02,s
                    beq       L090B
                    ldd       $03,s
                    coma
                    comb
                    addd      #$0001
                    std       $03,s
L090B               ldb       ,u+
                    leau      b,u
                    ldd       $03,s
                    leas      $05,s
                    lbra      L0B0B
L0916               ldb       ,u+
                    leau      b,u
                    lda       #$0D
                    leas      $05,s
                    lbra      L0AF9
                    aim       #$A6,<u0084
                    bita      #$03
                    beq       L0945
                    bita      #$01
                    beq       L0945
                    ldb       #$20
L092E               bita      #$88
                    bne       L0941
                    pshs      y,b
                    ldy       $02,x
                    jsr       $06,y
                    puls      y,b
                    lda       $01,x
                    lbne      L0B22
L0941               bitb      ,x
L0943               beq       L0948
L0945               ldb       #$01
                    rts
L0948               clrb
                    rts
L094A               lda       ,x
                    anda      #$05
                    cmpa      #$05
                    bne       L0945
                    lda       ,x
                    ldb       #$60
                    bra       L092E
                    pshs      y
                    ldy       $02,x
                    lda       #$00
                    jsr       $09,y
                    puls      y
                    lda       ,x
                    pshs      a
                    anda      #$EF
                    sta       ,x
                    puls      b
                    bitb      #$10
                    bra       L0943
                    aim       #$35,<u0010
                    ldd       ,x++
                    pshs      u,y,x,b,a
                    leay      ,u
                    leax      <L09CF,pcr
                    anda      #$03
                    ldb       a,x
                    jsr       b,x
                    leax      <L09CF,pcr
                    lda       ,s
                    lsra
                    lsra
                    ldb       a,x
                    jsr       b,x
                    sty       $06,s
                    pulu      x,a
                    pulu      y,b
                    tsta
                    bne       L09AD
                    tstb
                    bne       L09A9
L099B               ldb       #$1C
L099D               andb      $01,s
                    beq       L09A3
                    ldb       #$01
L09A3               leas      $02,s
                    puls      u,y,x
                    jmp       ,x
L09A9               ldb       #$29
                    bra       L099D
L09AD               tstb
                    bne       L09B4
L09B0               ldb       #$32
                    bra       L099D
L09B4               sta       ,s
L09B6               lda       ,x+
                    cmpa      ,y+
                    bcs       L09A9
                    bhi       L09B0
                    dec       ,s
                    decb
                    beq       L09C9
                    tst       ,s
                    bne       L09B6
                    bra       L09A9
L09C9               tst       ,s
                    beq       L099B
                    bra       L09B0
L09CF               com       <u000A
                    jmp       <u00A6
                    suba      -$0A,y
                    bhi       L0A08
                    lda       -$07,y
                    lda       #$01
                    bra       L09D4
                    ldx       $04,s
                    lda       ,x+
                    stx       $04,s
                    bra       L09D4
                    oim       #$34,<u0020
                    ldy       [<$02,s]
                    beq       L09FA
                    tfr       y,d
                    leax      d,x
L09F2               lda       ,-x
                    sta       ,-u
                    leay      -$01,y
                    bne       L09F2
L09FA               puls      y
                    puls      x
                    jmp       $02,x
                    pshs      y
                    ldy       [<$02,s]
                    beq       L0A10
L0A08               lda       ,u+
                    sta       ,x+
                    leay      -$01,y
                    bne       L0A08
L0A10               puls      y
                    puls      x
                    jmp       $02,x
                    com       <u00AE
                    andb      a,s
                    suba      #$30
                    bita      #$EC
                    andb      >-$1BE1,w
                    oim       #$E6,<u0084
L0A25               lda       b,x
                    pshu      a
                    decb
                    bpl       L0A25
                    rts
                    pshu      x
                    ldx       ,s
                    lda       ,x+
                    stx       ,s
                    pulu      x
                    ldb       ,u
                    incb
                    cmpa      ,u
                    bls       L0A46
L0A3E               pulu      a
                    sta       ,x+
                    decb
                    bne       L0A3E
                    rts
L0A46               leau      b,u
                    lda       #$08
                    lbra      L0B18
                    ldx       ,s
                    lda       ,x+
                    stx       ,s
                    deca
                    suba      ,u
                    bcs       L0A72
                    pshs      y
                    beq       L0A70
                    leay      ,u
                    nega
                    leau      a,u
                    leax      ,u
                    ldb       ,y+
                    stb       ,x+
                    beq       L0A70
L0A69               lda       ,y+
                    sta       ,x+
                    decb
                    bne       L0A69
L0A70               puls      pc,y
L0A72               nega
                    leau      a,u
                    lda       #$08
                    lbra      L0B18
                    ldx       ,s
                    lda       ,x+
                    pshs      y,x
                    leax      a,x
                    stx       $04,s
                    puls      x
                    leay      ,u
                    cmpa      ,y+
                    bne       L0A98
                    tsta
                    beq       L0A98
L0A8F               ldb       ,y+
                    cmpb      ,x+
                    bne       L0A98
                    deca
                    bne       L0A8F
L0A98               puls      pc,y
                    com       <u0030
                    anda      u000D,u
                    bmi       L0AA6
L0AA0               ldy       -$02,y
                    deca
                    bpl       L0AA0
L0AA6               pshu      y,x
                    ldd       -$08,y
                    ldx       -$06,y
                    pshu      x,b,a
                    leau      -u0002,u
                    leay      u000A,u
                    lda       #$15
                    cmps      -$04,x
                    lbls      L0B12
L0ABB               lda       #$14
                    ldx       -$06,y
                    cmpu      -$02,x
                    lbls      L0B12
                    cmpu      $02,x
                    lbls      L0B12
                    rts
L0ACE               puls      x
                    pshs      y
                    ldd       ,x
                    addd      ,s
                    tfr       d,y
                    lda       $02,x
                    ldx       ,s
                    tsta
                    bpl       L0AE5
                    lda       ,x
L0AE1               ldb       a,x
                    stb       ,-y
L0AE5               deca
                    bpl       L0AE1
                    tfr       y,d
                    subd      ,s
                    puls      y
L0AEE               leau      -$04,y
                    ldy       ,u
                    leau      u0004,u
                    leau      d,u
                    rts
                    com       <u00AE
                    abx
                    ldb       #$01
                    stb       $04,x
                    ldb       #$04
                    bra       L0B27
                    lda       #$04
                    bra       L0B18
                    lda       #$05
                    bra       L0B18
L0B0B               ldx       -$06,y
                    clr       $04,x
                    rts
                    tfr       b,a
L0B12               tsta
                    beq       L0B2B
                    lbra      L0B2D
L0B18               ldx       -$06,y
                    ldb       #$01
                    stb       $05,x
                    ldb       #$01
                    bra       L0B27
L0B22               tsta
                    beq       L0B2B
                    ldb       #$02
L0B27               bitb      -$07,y
                    bne       L0B12
L0B2B               rts
                    aim       #$1F,<u0089
                    cmpb      #$FF
                    bne       L0B34
                    clrb
L0B34               os9       F$Exit
                    ror       <u0020
                    dec       <u0000
                    rts
                    neg       <u0000
                    lbra      L0D6E
                    lbra      L0C8D
                    pshs      y,x
                    ora       #$01
                    leay      <L0B38,pcr
                    ldb       #$00
                    lbsr      L0C41
                    lbsr      L0C58
                    lda       ,y
                    bita      #$10
                    beq       L0B6A
                    anda      #$EF
                    sta       ,y
                    pshs      u
                    leau      ,y
                    leax      >L0C86,pcr
                    os9       F$Icpt
                    puls      u
L0B6A               puls      pc,y,x
L0B6C               bra       L0B78
                    neg       <u0016
                    oim       #$B9,<u0039
                    neg       <u0000
                    lbra      L0C8D
L0B78               pshs      y,x
                    ora       #$02
                    ldb       #$01
                    leay      <L0B6C,pcr
                    lbra      L0C3D
L0B84               bra       L0B90
                    neg       <u0016
                    oim       #$A1,<u0039
                    neg       <u0000
                    lbra      L0C8D
L0B90               pshs      y,x
                    ora       #$02
                    ldb       #$02
                    leay      <L0B84,pcr
                    lbra      L0C3D
L0B9C               bra       L0BA8
                    neg       <u0039
                    neg       <u0000
                    lbra      L0D6E
                    lbra      L0C8D
L0BA8               pshs      y,x
                    anda      #$7F
                    ora       #$01
                    ldb       #$00
                    leay      <L0B9C,pcr
                    lbsr      L0C41
                    leas      <-$20,s
                    leax      ,s
                    lda       #$00
                    ldb       #$00
                    os9       I$GetStt
                    tst       ,x
                    bne       L0C28
                    leay      ,x
                    ldb       #$0E
                    os9       I$GetStt
                    bcc       L0BE4
                    cmpb      #$D0
                    beq       L0BD9
                    leas      <$20,s
                    lbra      L0D13
L0BD9               ldy       <$1B,x
                    ldy       $04,y
                    ldd       $04,y
                    leay      d,y
L0BE4               lda       #$2F
L0BE6               ldb       ,y+
                    bmi       L0BF0
                    sta       ,x+
                    tfr       b,a
                    bra       L0BE6
L0BF0               sta       ,x+
                    tfr       b,a
                    anda      #$7F
                    ldb       #$0D
                    std       ,x
                    leax      ,s
                    lda       #$01
                    os9       I$Open
                    leas      <$20,s
                    lbcs      L0D13
                    ldx       ,s
                    sta       $07,x
                    ldb       ,x
                    orb       #$80
                    stb       ,x
                    leas      <-$20,s
                    leax      ,s
                    clrb
                    os9       I$GetStt
                    ldb       #$01
L0C1D               clr       b,x
                    incb
                    cmpb      #$13
                    bls       L0C1D
                    clrb
                    os9       I$SetStt
L0C28               leas      <$20,s
                    puls      pc,y,x
L0C2D               bra       L0C38
                    neg       <u0016
                    neg       <u00F8
                    lbra      L0D6E
                    bra       L0C8D
L0C38               pshs      y,x
                    leay      <L0C2D,pcr
L0C3D               bsr       L0C41
                    puls      pc,y,x
L0C41               sta       ,x
                    clr       $01,x
                    sty       $02,x
                    stb       $07,x
                    ldy       #$0001
                    sty       $04,x
                    bita      #$04
                    beq       L0C57
                    clr       $08,x
L0C57               rts
L0C58               leay      ,x
                    lda       ,y
                    anda      #$05
                    cmpa      #$05
                    bne       L0C85
                    leax      $0C,y
                    stx       $0A,y
                    ldb       #$0D
                    stb       ,x
                    lda       $07,y
                    leas      <-$20,s
                    leax      ,s
                    clrb
                    os9       I$GetStt
                    ldb       ,x
                    leas      <$20,s
                    lda       ,y
                    anda      #$7F
                    tstb
                    bne       L0C83
                    ora       #$80
L0C83               sta       ,y
L0C85               rts
L0C86               lda       ,u
                    ora       #$10
                    sta       ,u
                    rti
L0C8D               pshs      y,x,b,a
                    leay      ,x
                    lbsr      L0D20
                    cmpa      #$00
                    beq       L0CCA
                    cmpa      #$06
                    lbeq      L0E1C
                    cmpa      #$03
                    beq       L0CEB
                    cmpa      #$05
                    beq       L0CF8
                    cmpa      #$04
                    beq       L0CE2
                    ldx       $04,s
                    ldb       ,s
                    cmpb      #$01
                    bne       L0CCC
                    lda       ,y
                    anda      #$03
                    ora       $01,s
                    os9       I$Open
                    bcs       L0D13
L0CBD               bsr       L0D20
                    sta       ,x
                    leax      ,y
                    lbsr      L0C58
L0CC6               ldx       $02,s
                    clr       $01,x
L0CCA               puls      pc,y,x,b,a
L0CCC               os9       I$Delete
                    lda       ,y
                    anda      #$03
                    ldx       $04,s
                    ldb       $01,s
                    bne       L0CDB
                    ldb       #$03
L0CDB               os9       I$Create
                    bcs       L0D13
                    bra       L0CBD
L0CE2               ldx       $04,s
                    os9       I$Delete
                    bcs       L0D13
                    bra       L0CC6
L0CEB               lda       ,x
                    cmpa      #$02
                    bls       L0CC6
                    os9       I$Close
                    bcs       L0D13
                    bra       L0CC6
L0CF8               ldy       $04,s
                    pshs      u
                    lda       ,x
                    ldu       $02,y
                    ldx       ,y
                    os9       I$Seek
                    bcs       L0D09
                    clrb
L0D09               puls      u
                    ldx       $02,s
                    lda       ,x
                    anda      #$97
                    sta       ,x
L0D13               ldy       $02,s
                    cmpb      #$D3
                    bne       L0D1C
                    ldb       #$12
L0D1C               stb       $01,y
                    puls      pc,y,x,b,a
L0D20               pshs      b,a
                    ldd       $04,y
                    addd      #$0006
                    leax      d,y
                    puls      pc,b,a
L0D2B               pshs      y,x,b,a
                    leay      ,x
                    ldb       ,y
                    bitb      #$04
                    bne       L0D43
                    bsr       L0D20
                    lda       ,x
                    leax      $06,y
                    ldy       $04,y
                    os9       I$Write
                    bra       L0D5E
L0D43               tsta
                    bmi       L0D63
                    beq       L0D50
                    clr       $08,y
                    lda       #$0D
                    sta       $06,y
                    bra       L0D53
L0D50               inca
                    sta       $08,y
L0D53               lda       $07,y
                    leax      $06,y
                    ldy       #$0001
L0D5B               os9       I$WritLn
L0D5E               bcs       L0D13
                    lbra      L0CC6
L0D63               leax      u0001,u
                    clr       ,s
                    lda       $07,y
                    ldy       ,s
                    bra       L0D5B
L0D6E               pshs      y,x,b,a
                    leay      ,x
                    bsr       L0D20
                    ldb       ,y
                    orb       #$08
                    stb       ,y
                    bitb      #$04
                    bne       L0DAA
                    bitb      #$20
                    bne       L0D97
                    lda       ,x
                    leax      $06,y
                    ldy       $04,y
                    os9       I$Read
                    bcs       L0D9B
                    ldx       $02,s
                    cmpy      $04,x
                    lbeq      L0CC6
L0D97               ldb       #$12
                    bra       L0DE8
L0D9B               cmpb      #$D3
                    bne       L0DE8
                    ldx       $02,s
                    lda       ,x
                    ora       #$20
                    sta       ,x
                    lbra      L0CC6
L0DAA               andb      #$BF
                    bitb      #$80
                    beq       L0DB2
                    andb      #$DF
L0DB2               stb       ,y
                    bitb      #$20
                    bne       L0D97
                    ldx       $0A,y
L0DBA               lda       ,x+
                    cmpa      #$0D
                    beq       L0DEF
                    bitb      #$80
                    beq       L0DC8
                    cmpa      #$1A
                    beq       L0DEF
L0DC8               lda       ,x
                    beq       L0DBA
                    sta       $06,y
                    stx       $0A,y
                    cmpa      #$0D
                    beq       L0DDE
                    bitb      #$80
                    beq       L0DDC
                    cmpa      #$1A
                    beq       L0DEB
L0DDC               puls      pc,y,x,b,a
L0DDE               orb       #$40
L0DE0               stb       ,y
                    lda       #$20
                    sta       $06,y
                    puls      pc,y,x,b,a
L0DE8               lbra      L0D13
L0DEB               orb       #$20
                    bra       L0DE0
L0DEF               leax      $0C,y
                    stx       $0A,y
                    lda       $07,y
                    ldy       #$0074
                    os9       I$ReadLn
                    bcs       L0E07
                    ldy       $02,s
                    ldx       $0A,y
                    ldb       ,y
                    bra       L0DC8
L0E07               ldy       $02,s
                    cmpb      #$03
                    bls       L0DEF
                    cmpb      #$D3
                    bne       L0DE8
                    lda       ,y
                    bita      #$80
                    bne       L0DE8
                    ldb       ,y
                    bra       L0DEB
L0E1C               leax      ,y
                    lda       $08,y
                    beq       L0E25
                    lbsr      L0D2B
L0E25               lda       #$0C
                    sta       $06,y
                    clra
                    lbsr      L0D2B
                    puls      pc,y,x,b,a
                    neg       <u0001
                    fcb       $E9                 i
                    emod
eom                 equ       *
