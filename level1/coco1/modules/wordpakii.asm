********************************************************************
* WordPakII - Word-Pak II Driver
*
* $Id$
*
* NOTE: This driver is currently a stand-alone SCF driver.  Work has
* started to convert it into a co-module that would fit under the
* CCIO driver hierarchy, but that work is not complete.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      1985?/??/??
* Original OS-9 Level One Driver

                    nam       WordPakII
                    ttl       Word-Pak II Driver

* Disassembled 2005/01/06 19:47:27 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       vtiodefs
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       5

CO80                equ       0
SIZEX               equ       80
SIZEY               equ       24

                    mod       eom,name,tylg,atrv,start,size
                    rmb       $1D
V.PIA               rmb       2
                    rmb       $BB-$1D-2
size                equ       .

                    fcb       $07

name
                    ifeq      CO80
                    fcs       /WordPakII/
                    else
                    fcs       /CO80/
                    endc
                    fcb       edition

*         fcc   /(C) 1985 PBJ, Inc./

* WordPak Initialization Values
WPIV                fcb       $6E                 R0
                    fcb       $50                 R1
                    fcb       $56                 R2
                    fcb       $18                 R3
                    fcb       $1A                 R4
                    fcb       $00                 R5
                    fcb       $18                 R6
                    fcb       $19                 R7
                    fcb       $78                 R8
                    fcb       $09                 R9
L0034               fcb       $60                 R10
                    fcb       $09                 R11
                    fcb       $00                 R12
                    fcb       $00                 R13
                    fcb       $00                 R14
                    fcb       $00                 R15
                    fcb       $00                 R16
                    fcb       $00                 R17
                    fcb       $00                 R18
                    fcb       $00                 R19
                    fcb       $10                 R20

start               bra       Init
                    nop
                    ifeq      CO80
                    lbra      Read
                    endc
                    lbra      Write
                    bra       GetStat
                    nop
                    lbra      SetStat
                    ifeq      CO80
                    lbra      Term
                    else
                    rts
                    endc

Init
                    ifeq      CO80
                    pshs      dp,cc               save DP and CC
                    orcc      #IntMasks           mask interrupts
                    clra
                    tfr       a,dp                set DP to 0
                    stu       <D.KbdSta           save off statics ptr
                    nop
                    nop
                    nop
                    nop
                    leax      >IRQSVC,pcr         point to IRQ routine
                    stx       <D.AltIRQ           save as alternate IRQ
                    ldx       #PIA0Base           get base address of PIA0
                    stx       <V.PIA,u            save off in statics
                    clrb                          now D = 0
                    std       <$27,u
                    std       <$29,u
                    std       <$2B,u
                    std       <$2D,u
* Initialize PIA here
                    sta       $01,x
                    sta       ,x
                    sta       $03,x
                    comb                          B = $FF
                    stb       $02,x
                    stb       <$20,u
                    stb       <$21,u
                    stb       <$22,u
                    lda       #$34
                    sta       $01,x
                    lda       #$3F
                    sta       $03,x
                    lda       $02,x
                    endc
* Initialize WordPak Hardware
                    clra
                    leax      <WPIV,pcr           point to initialization values
L0097               ldb       ,x+
                    std       [<V.PORT,u]         write to WP hardware
                    inca
                    cmpa      #$14
                    bcs       L0097
                    ifeq      CO80
                    ldb       ,x
                    stb       <$31,u
                    ldx       V.PORT,u            get port address
                    lda       #64
                    sta       $04,x               ???
                    lbsr      ClrScr              clear screen
                    lda       <L0034,pcr
                    sta       <$3A,u
                    puls      pc,dp,cc
                    else
                    rts
                    endc


GetStat
                    ifeq      CO80
                    cmpa      #SS.Ready
                    bne       L00C9
                    lda       <$2E,u
                    suba      <$2D,u
                    lbne      L0181
                    ldb       #E$NotRdy
                    bra       L00F5
L00C9               cmpa      #SS.EOF
                    lbeq      L0181
                    ldx       R$Y,y
                    cmpa      #SS.Joy
                    lbeq      SSJOY
                    cmpa      #SS.Cursr
                    beq       CURSR
                    cmpa      #SS.ScSiz
                    beq       SCSIZ
                    cmpa      #$83
                    beq       L00F8
                    cmpa      #$84
                    beq       L0106
                    cmpa      #$86
                    beq       L0117
                    cmpa      #$87
                    beq       L0101
                    cmpa      #$88
                    beq       L00FC
                    endc
SetStat             ldb       #E$UnkSvc
L00F5               orcc      #Carry
                    rts
L00F8               lda       #$7F
                    bra       L0102
L00FC               lda       <$31,u
                    bra       L0102
L0101               clra
L0102               sta       $01,x
                    bra       L0127

L0106               ldd       #80*256+24
                    bra       L0125

SCSIZ               ldd       #SIZEX
                    std       R$X,x
                    ldd       #SIZEY
                    std       R$Y,x
                    bra       L0127

L0117               ldb       <$3A,u
                    bsr       L0129
                    andb      #$0F
                    bne       L0124
                    ldb       #$01
                    bra       L0125
L0124               clrb
L0125               std       R$A,x
L0127               clrb
                    rts
L0129               pshs      x,b
                    clra
                    leax      >L083C,pcr
                    andb      #$60
L0132               cmpb      ,x+
                    beq       L013B
                    inca
                    cmpa      #$03
                    bcs       L0132
L013B               puls      x,b
                    rts

CURSR               clrb
                    pshs      b
                    ldd       <$34,u
L0144               cmpd      <$32,u
                    beq       L0151
                    subd      #SIZEX
                    inc       ,s
                    bra       L0144
L0151               puls      b
                    addb      #$20
                    clra
                    std       $06,x
                    ldd       <$36,u
                    subd      <$34,u
                    addb      #$20
                    clra
                    std       $04,x
                    lbsr      L05C2
                    anda      #$7F
                    sta       $01,x
                    ldx       <$36,u
                    lbra      L056A

                    ifeq      CO80
Term                pshs      cc
                    orcc      #IRQMask
                    ldd       >D.Clock            get original clock pointer
                    std       >D.AltIRQ           save as alternate IRQ
                    puls      pc,cc

L017C               incb
                    cmpb      #$7F
                    bls       L0182
L0181               clrb
L0182               rts

* Interrupt Service Routine
IRQSVC              ldu       >D.KbdSta           get IRQ static ptr in U
                    ldx       <V.PIA,u
                    lda       $03,x               get IRQ status bit
                    bmi       L0191               branch if set
                    jmp       [>D.AltIRQ]         else continue on
L0191               lda       $02,x
                    lda       #$FF
                    sta       $02,x
                    lda       ,x
                    coma
                    anda      #$03
                    bne       L01A7
                    clr       $02,x
                    lda       ,x
                    coma
                    anda      #$7F
                    bne       L01C8
L01A7               ldd       #$FFFF
                    std       <$20,u
                    std       <$22,u
L01B0               ldd       #$1E05
                    std       <$2F,u
L01B6               lda       >$00A0
                    beq       L01C4
                    deca
                    sta       >$00A0
                    bne       L01C4
                    sta       >$FF40
L01C4               jmp       [>D.Clock]
L01C8               bsr       L0217
                    bpl       L01D0
                    bcs       L01B6
                    bra       L01B0
L01D0               cmpa      #$1F
                    bne       L01D9
                    com       <$27,u
                    bra       L01B6
L01D9               ldb       <$2D,u
                    leax      <$3B,u
                    abx
                    bsr       L017C
                    cmpb      <$2E,u
                    beq       L01EA
                    stb       <$2D,u
L01EA               sta       ,x
                    beq       L020A
                    cmpa      V.PCHR,u            pause character?
                    bne       L01FA
                    ldx       V.DEV2,u
                    beq       L020A
                    sta       $08,x
                    bra       L020A
L01FA               ldb       #S$Intrpt
                    cmpa      V.INTR,u            interrupt character?
                    beq       L0206
                    ldb       #S$Abort
                    cmpa      V.QUIT,u            quit character?
                    bne       L020A
L0206               lda       V.LPRC,u
                    bra       L020E
L020A               ldb       #S$Wake
                    lda       V.WAKE,u
L020E               beq       L0213
                    os9       F$Send
L0213               clr       V.WAKE,u
                    bra       L01B6
L0217               clra
                    clrb
                    sta       <$1F,u
                    std       <$28,u
                    coma
                    sta       <$24,u
                    sta       <$25,u
                    sta       <$26,u
                    deca
                    sta       $02,x
L022C               lda       ,x
                    coma
                    anda      #$7F
                    beq       L023F
                    ldb       #$FF
L0235               incb
                    lsra
                    bcc       L023B
                    bsr       L0286
L023B               cmpb      #$06
                    bcs       L0235
L023F               inc       <$1F,u
                    orcc      #Carry
                    rol       $02,x
                    bcs       L022C
                    bsr       L02C1
                    bmi       L0285
                    beq       L0268
                    suba      #$1A
                    bhi       L0268
                    adda      #$1A
                    ldb       <$29,u
                    bne       L0267
                    adda      #$40
                    ldb       <$28,u
                    eorb      <$27,u
                    andb      #$01
                    bne       L0267
                    adda      #$20
L0267               rts
L0268               ldb       #$03
                    mul
                    lda       <$28,u
                    beq       L0273
                    incb
                    bra       L027A
L0273               lda       <$29,u
                    beq       L027A
                    addb      #$02
L027A               pshs      x
                    leax      >L0344,pcr
                    clra
                    lda       d,x
                    puls      x
L0285               rts

L0286               pshs      b
                    lslb
                    lslb
                    lslb
                    addb      <$1F,u
                    cmpb      #$31
                    bne       L0297
                    inc       <$29,u
                    puls      pc,b
L0297               cmpb      #$37
                    bne       L02A0
                    com       <$28,u
                    puls      pc,b
L02A0               pshs      x
                    leax      <$24,u
                    bsr       L02AB
                    puls      x
                    puls      pc,b
L02AB               pshs      a
                    lda       ,x
                    bpl       L02B5
                    stb       ,x
                    puls      pc,a
L02B5               lda       $01,x
                    bpl       L02BD
                    stb       $01,x
                    puls      pc,a
L02BD               stb       $02,x
                    puls      pc,a
L02C1               pshs      y,x,b
                    leax      <$20,u
                    ldb       #$03
                    pshs      b
L02CA               leay      <$24,u
                    ldb       #$03
                    lda       ,x
                    bmi       L0322
L02D3               cmpa      ,y
                    bne       L0319
                    tst       <$23,u
                    bpl       L02EB
                    sta       <$23,u
                    pshs      b
                    ldd       #$1E05
                    std       <$2F,u
                    puls      b
                    bra       L0301
L02EB               cmpa      <$23,u
                    beq       L02F9
                    sta       <$23,u
                    ldd       #$1E05
                    std       <$2F,u
L02F9               tst       <$2F,u
                    beq       L0307
                    dec       <$2F,u
L0301               clr       ,y
                    com       ,y
                    bra       L0322
L0307               dec       <$30,u
                    beq       L0312
                    orcc      #Negative+Carry
L030E               leas      $01,s
                    puls      pc,y,x,b
L0312               ldb       #$05
                    stb       <$30,u
                    bra       L030E
L0319               leay      $01,y
                    decb
                    bne       L02D3
                    lda       #$FF
                    sta       ,x
L0322               leax      $01,x
                    dec       ,s
                    bne       L02CA
                    leas      $01,s
                    leax      <$24,u
                    lda       #$03
L032F               ldb       ,x+
                    bpl       L033A
                    deca
                    bne       L032F
                    orcc      #Negative
                    puls      pc,y,x,b
L033A               leax      <$20,u
                    lbsr      L02AB
                    tfr       b,a
                    puls      pc,y,x,b
                    endc

L0344               fdb       $4060,$000c,$1c13,$0a1a,$1208,$1810
                    fdb       $0919,$1120,$2020,$3030,$1f31,$217c,$3222,$0033
                    fdb       $237e,$3424,$0035,$2500,$3626,$0037,$275e,$3828
                    fdb       $5b39,$295d,$3a2a,$003b,$2b00,$2c3c,$7b2d,$3d5f
                    fdb       $2e3e,$7d2f,$3f5c,$0d0d,$0d00,$0000,$0503
                    fcb       $1b

                    ifeq      CO80
Read                leax      <$3B,u
                    ldb       <$2E,u
                    orcc      #IntMasks
                    cmpb      <$2D,u
                    beq       L03A8
                    abx
                    lda       ,x
                    lbsr      L017C
                    stb       <$2E,u
                    andcc     #^(IntMasks+Carry)
                    rts
L03A8               lda       V.BUSY,u
                    sta       V.WAKE,u
                    andcc     #^IntMasks
                    ldx       #$0000
                    os9       F$Sleep
                    clr       V.WAKE,u
                    ldx       >D.Proc
                    ldb       <$36,x
                    beq       Read
                    cmpb      #$03
L03C0               bhi       Read
                    coma
                    rts
                    endc

SSJOY               pshs      u,y,cc
                    orcc      #IntMasks
                    ldu       <V.PIA,u            get PIA address
                    lda       #$FF
                    sta       $02,u
                    ldb       ,u
L03D1               ldy       $04,x
                    beq       L03DC
                    andb      #$02
                    beq       L03E1
                    bra       L03E0
L03DC               andb      #$01
                    beq       L03E1
L03E0               clra
L03E1               sta       $01,x
                    lda       $03,u
                    ora       #$08
                    ldy       $04,x
                    bne       L03EE
                    anda      #$F7
L03EE               sta       >$FF03
                    lda       $01,u
                    anda      #$F7
                    bsr       L040B
                    std       $04,x
                    lda       $01,u
                    ora       #$08
                    bsr       L040B
                    pshs      b,a
                    ldd       #$003F
                    subd      ,s++
                    std       $06,x
                    clrb
                    puls      pc,u,y,cc

L040B               sta       $01,u
                    clrb
                    bsr       L041A
                    bsr       L041A
                    bsr       L041A
                    bsr       L041A
                    lsrb
                    lsrb
                    clra
                    rts

L041A               pshs      b
                    lda       #$7F
                    tfr       a,b
L0420               lsrb
                    cmpb      #$03
                    bhi       L042C
                    lsra
                    lsra
                    tfr       a,b
                    addb      ,s+
                    rts

L042C               addb      #$02
                    andb      #$FC
                    pshs      b
                    sta       >PIA1Base
                    tst       ,u
                    bpl       L043D
                    adda      ,s+
                    bra       L0420
L043D               suba      ,s+
                    bra       L0420

L0441               fcb       $02
                    fdb       ClrScr-*            $0276
                    fcb       $05
                    fdb       Do05-*              $0258
                    fcb       $06
                    fdb       Do06-*              $03b3
                    fcb       $09
                    fdb       Do09-*              $0222
                    fcb       $0b
                    fdb       Do0B-*              $0209
                    fcb       $0F
                    fdb       Do0F-*              $01fe
                    fcb       $13
                    fdb       Do13-*              $0283
                    fcb       $14
                    fdb       Do14-*              $0339
                    fcb       $19
                    fdb       Do19-*              $023f
                    fcb       $1b
                    fdb       DoESC-*             $0095
                    fcb       $80

L0460               fcb       $01
                    fdb       DoH01-*             $01ee
                    fcb       $02
                    fdb       DoH02-*             $032c
                    fcb       $03
                    fdb       DoH03-*             $0232
                    fcb       $04
                    fdb       DoH04-*             $0233
                    fcb       $05
                    fdb       DoH05-*             $008c
                    fcb       $06
                    fdb       DoH06-*             $01fd
                    fcb       $09
                    fdb       DoH09-*             $01e4
                    fcb       $0b
                    fdb       DoH0B-*             $0261
                    fcb       $0c
                    fdb       ClrScr-*            $023f
                    fcb       $1b
                    fdb       DoESC-*             $0076
                    fcb       $80

L047F               fcb       $41
                    fdb       Do41-*              $021d
                    fcb       $42
                    fdb       Do42-*              $0254
                    fcb       $45
                    fdb       Do45-*              $02c2
                    fcb       $46
                    fdb       Do46-*              $02e5
                    fcb       $47
                    fdb       Do47-*              $0287
                    fcb       $48
                    fdb       Do48-*              $0264
                    fcb       $53
                    fdb       Do53-*              $0058
                    fcb       $56
                    fdb       Do56-*              $037f
                    fcb       $58
                    fdb       Do58-*              $0056
                    fcb       $57
                    fdb       Do57-*              $004b
                    fcb       $76
                    fdb       Do76-*              $037d
                    fcb       $80

Write
                    ifeq      CO80
                    fcb       $6D,$C8,$2C
                    lbne      L079C
                    ldx       <$36,u
                    tst       <$2A,u
                    bne       L04FD
                    endc
                    cmpa      #C$SPAC             space?
                    lbcc      L053A               branch if >=
                    cmpa      #C$CR               carriage return?
                    lbeq      L0557               branch if equal
                    cmpa      #C$LF               line feed?
                    lbeq      L055C               branch if equal
                    cmpa      #C$BSP              backspace?
                    lbeq      L056A               branch if equal
                    tst       V.TYPE,u            look at type
                    bmi       L04D2               branch if hi-bit set
                    leay      >L0441,pcr
                    bra       L04D6
L04D2               leay      >L0460,pcr
L04D6               cmpa      ,y+
                    beq       L04E2
                    leay      $02,y
                    tst       ,y
                    bpl       L04D6
                    bra       L0555
L04E2               ldd       ,y
                    jmp       d,y

Do57                lda       #$57
                    bra       L04F4

Do53                lda       #$53
                    bra       L04F4

Do58                lda       #$58
                    bra       L04F4

DoESC               lda       #$1B
L04F4               sta       <$2A,u
L04F7               clrb
                    rts

DoH05
Do01                lda       #$05
                    bra       L04F4

L04FD               ldb       <$2A,u
                    clr       <$2A,u
                    tst       V.TYPE,u            get type byte
                    bmi       L0513               branch if hi-bit set
                    cmpb      #$2E
                    lbeq      L0807
                    cmpa      #$2E
                    beq       L04F4
                    clrb
                    rts

L0513               cmpb      #$05
                    beq       L04F7
                    cmpb      #$57
                    lbeq      L0822
                    cmpb      #$53
                    lbeq      L07F2
                    cmpb      #$58
                    bne       L0534
                    suba      #$20
                    ble       L0555
                    cmpa      #$10
                    bhi       L0555
                    sta       <$31,u
                    bra       L0555
L0534               leay      >L047F,pcr
                    bra       L04D6
L053A               bsr       L05A1
                    leax      $01,x
                    stx       <$36,u
                    bsr       L058C
                    ldx       <$34,u
                    leax      <$50,x
                    cmpx      <$36,u
                    bhi       L0555
L054E               stx       <$34,u
                    bsr       L05CD
L0553               bsr       L0587
L0555               clrb
                    rts

L0557               ldx       <$34,u
                    bra       L0582
L055C               leax      <$50,x
                    stx       <$36,u
                    ldx       <$34,u
                    leax      <$50,x
                    bra       L054E
L056A               cmpx      <$34,u
                    bhi       L0580
                    ldy       <$34,u
                    cmpy      <$32,u
                    beq       L0555
                    leay      <-$50,y
                    sty       <$34,u
L0580               leax      -$01,x
L0582               stx       <$36,u
                    bra       L0553
L0587               ldx       <$36,u
L058A               bsr       L0591
L058C               lda       #$0E
                    bsr       L0593
                    rts
L0591               lda       #$12
L0593               pshs      x
                    ldb       ,s+
                    std       [<V.PORT,u]
                    inca                          increment A
                    ldb       ,s+
                    std       [<V.PORT,u]
                    rts
L05A1               tst       <$2B,u
                    beq       L05AA
                    ora       #$80
                    bra       L05AC
L05AA               anda      #$7F
L05AC               bsr       L05B7
                    pshs      x
                    ldx       $01,u
                    sta       $03,x
                    puls      x
                    rts
L05B7               ldb       #$1F
                    stb       [<V.PORT,u]
L05BC               tst       [<V.PORT,u]
                    bpl       L05BC
                    rts
L05C2               bsr       L05B7
                    pshs      x
                    ldx       $01,u
                    lda       $03,x
                    puls      x
L05CC               rts
L05CD               ldd       <$34,u
                    subd      <$32,u
                    cmpd      #SIZEX*SIZEY
                    bmi       L05CC
                    lbsr      L06AE
                    ldx       <$32,u
                    leax      <$50,x
                    cmpx      #$5000
                    bmi       L05F3
                    ldx       #SIZEX*SIZEY-SIZEX
                    stx       <$34,u
                    stx       <$36,u
                    ldx       #$0000
L05F3               stx       <$32,u
                    ldy       $01,u
                    leay      $04,y
                    ldb       <$31,u
                    cmpb      #$10
                    beq       L062A
                    negb
                    andb      #$0F
                    lda       #$C0
L0607               pshs      b
                    pshs      b
                    ldb       #$20
                    inca
                    cmpa      #$CA
                    beq       L0628
L0612               bitb      [<V.PORT,u]
                    bne       L0612
L0617               bitb      [<V.PORT,u]
                    beq       L0617
                    sta       ,y
                    dec       ,s
                    bne       L0612
                    puls      b
                    puls      b
                    bra       L0607
L0628               leas      $02,s
L062A               tfr       x,d
                    tfr       a,b
                    lda       #$0C
                    pshs      b,a
                    tfr       x,d
                    lda       #$0D
                    pshs      b,a
                    ldb       #$20
L063A               bitb      [<V.PORT,u]
                    beq       L063A
                    puls      x,b,a
                    stx       [<V.PORT,u]
                    std       [<V.PORT,u]
                    lda       #$40
                    sta       ,y
                    lbsr      L0587
                    rts


DoH01
Do0F                ldx       <$32,u
                    stx       <$34,u
                    bra       L0693

DoH09
Do0B                ldx       <$34,u
                    cmpx      <$32,u
                    bls       L0696
                    leax      <-$50,x
                    stx       <$34,u
                    ldx       <$36,u
                    leax      <-$50,x
                    bra       L0693

DoH06
Do09                ldd       <$34,u
                    addd      #SIZEX-1
                    cmpd      <$36,u
                    bhi       L068E
                    ldx       <$32,u
                    leax      >SIZEX*SIZEY-SIZEX,x
                    cmpx      <$34,u
                    beq       L0696
                    ldx       <$34,u
                    leax      <$50,x
                    stx       <$34,u
L068E               ldx       <$36,u
                    leax      $01,x
L0693               stx       <$36,u
L0696               lbra      L0553

DoH03
Do19
                    bsr       L06AE
                    clrb
                    rts

Do41
DoH04
Do05                bsr       L06A1
                    clrb
                    rts
L06A1               ldd       <$34,u
                    addd      #SIZEX
                    subd      <$36,u
                    tfr       d,y
                    bra       L06B5
L06AE               ldx       <$34,u
                    ldy       #SIZEX
L06B5               lbra      L0768
Do02
ClrScr              ldx       <$32,u
                    ldy       #2048
                    bsr       L06E6
                    ldx       #$0000
                    stx       <$32,u
                    stx       <$34,u
                    stx       <$36,u
                    lda       #$0C
                    lbsr      L0593
                    lbsr      L058A
                    clrb
                    rts

Do42
DoH0B
Do13
                    ldd       <$32,u
                    addd      #2048
                    subd      <$36,u
                    tfr       d,y
                    bsr       L06E6
                    bra       L0696
L06E6               lbsr      L0591
L06E9               lda       #$20
L06EB               lbsr      L05A1
                    leay      -$01,y
                    bne       L06EB
                    rts

Do48                ldx       <$34,u
                    tfr       x,y
                    leax      <$4F,x
                    pshs      x
L06FD               leax      $08,y
                    bsr       L0733
                    cmpx      ,s
                    bcc       L0709
                    leay      $01,y
                    bra       L06FD
L0709               leas      $02,s
                    ldy       #$0008
                    bsr       L06E9
                    bra       L0696

Do47                ldy       <$34,u
                    leay      <$4F,y
L071A               leax      -$08,y
                    bsr       L0733
                    cmpx      <$34,u
                    bls       L0727
                    leay      -$01,y
                    bra       L071A
L0727               ldx       <$34,u
                    ldy       #$0008
                    bsr       L06E6
                    lbra      L0553
L0733               lbsr      L0591
                    lbsr      L05C2
                    pshs      a
                    exg       x,y
                    lbsr      L0591
                    puls      a
                    lbsr      L05AC
                    exg       x,y
                    rts

Do45                ldy       <$32,u
                    leay      >$077F,y
L0750               leax      <-$50,y
                    bsr       L0733
                    cmpx      <$34,u
                    bls       L075E
                    leay      -$01,y
                    bra       L0750
L075E               ldx       <$34,u
                    stx       <$36,u
L0764               ldy       #SIZEX
L0768               lbsr      L06E6
                    lbra      L0553

Do46                ldy       <$32,u
                    leay      >SIZEX*SIZEY-SIZEX,y
                    pshs      y
                    ldy       <$34,u
L077C               leax      <$50,y
                    bsr       L0733
                    cmpy      ,s
                    bcc       L078A
                    leay      $01,y
                    bra       L077C
L078A               leas      $02,s
                    tfr       y,x
                    bra       L0764

DoH02
Do14
                    ldb       #$58
                    tst       V.TYPE,u
                    bmi       L0797
                    incb
L0797               stb       <$2C,u
                    clrb
                    rts

L079C               suba      #$20
                    ldb       <$2C,u
                    tst       V.TYPE,u
                    bpl       L07B1
                    cmpb      #$58
                    bne       L07AD
                    bsr       L07C6
                    bra       L07F0
L07AD               bsr       L07B9
                    bra       L07D5
L07B1               cmpb      #$59
                    bne       L07D3
                    bsr       L07B9
                    bra       L07F0
L07B9               cmpa      #$17
                    bls       L07BF
                    lda       #$17
L07BF               sta       <$38,u
                    dec       <$2C,u
                    rts
L07C6               cmpa      #$4F
                    bls       L07CC
                    lda       #$4F
L07CC               sta       <$39,u
                    inc       <$2C,u
                    rts
L07D3               bsr       L07C6
L07D5               lda       <$38,u
                    ldb       #SIZEX
                    mul
                    ldx       <$32,u
                    leax      d,x
                    stx       <$34,u
                    ldb       <$39,u
                    abx
                    stx       <$36,u
                    lbsr      L0587
                    clr       <$2C,u
L07F0               clrb
                    rts
L07F2               suba      #$20
                    beq       L0802
                    deca
                    beq       L0801
                    bra       L0805

Do06                clra
                    tst       <$2B,u
                    bne       L0802
L0801               coma
L0802               sta       <$2B,u
L0805               clrb
                    rts

L0807               suba      #$30
                    cmpa      #$04
                    bhi       L083A
                    leax      <L083F,pcr
                    ldb       a,x
                    bra       L0832

Do56                ldb       #$F0
                    andb      <$3A,u
                    bra       L0832

Do76                ldb       #$08
                    orb       <$3A,u
                    bra       L0832
L0822               suba      #$20
                    cmpa      #$03
                    bhi       L083A
                    leax      <L083C,pcr
                    ldb       <$3A,u
                    andb      #$9F
                    orb       a,x
L0832               stb       <$3A,u
                    lda       #$0A
                    std       [<V.PORT,u]
L083A               clrb
                    rts

L083C               neg       <$60
                    nega
L083F               fcb       $20,$60,$00,$68,$08

                    emod
eom                 equ       *
                    end
