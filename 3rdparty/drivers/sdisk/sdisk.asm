********************************************************************
* SDisk - D.P. Johnson floppy driver for CoCo
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
* 18     D.P. Johnson original version

                    nam       SDisk
                    ttl       D.P. Johnson floppy driver for CoCo

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $02
edition             set       $12

maxdrv              set       3

                    mod       eom,name,tylg,atrv,start,size

                    rmb       DRVBEG+(DRVMEM*maxdrv)
u0081               rmb       2
u0083               rmb       1
u0084               rmb       1
u0085               rmb       1
u0086               rmb       1
u0087               rmb       1
u0088               rmb       2
u008A               rmb       2
u008C               rmb       1
u008D               rmb       1
u008E               rmb       1
size                equ       .

                    fcb       $FF

name                fcs       /SDisk/
                    fcb       edition

                    fcc       "Copyright 1984 D.P.Johnson"
                    fcb       C$CR
                    fcc       "ALL RIGHTS RESERVED"

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

Init                clra
                    sta       >D.DskTmr
                    sta       >u0086,u
                    lda       #$D0
                    sta       >$FF48
                    lbsr      L0419
                    lda       >$FF48
                    lda       #$FF
                    ldb       #maxdrv
                    leax      DRVBEG,u
L006D               sta       $01,x
                    sta       <$15,x
                    leax      <DRVMEM,x
                    decb
                    bne       L006D
                    leax      >L0235,pcr
                    stx       >D.XNMI
                    lda       #$7E
                    sta       >$0109
                    ldd       #256
                    pshs      u
                    os9       F$SRqMem
                    tfr       u,x
                    puls      u
                    bcs       L0097
                    stx       >u0088,u
                    clrb
L0097               rts

Term                ldu       >u0088,u
                    ldd       #256
                    os9       F$SRtMem
L00A2               rts

Read                lbsr      L0150
                    lda       #$91
                    cmpx      #$0000              LSN0?
                    bne       L00D5               branch if not
                    bsr       L00D5
                    bcs       L00A2
                    tst       >u0086,u
                    bne       L00A2
                    ldx       $08,y
                    pshs      y,x
                    ldy       >u0081,u
                    ldb       #$14
L00C2               lda       b,x
                    sta       b,y
                    decb
                    bpl       L00C2
                    clrb
                    puls      pc,y,x
L00CC               bcc       L00D5
                    pshs      x,b,a
                    lbsr      L04D4
                    puls      x,b,a
L00D5               pshs      x,b,a
                    bsr       L00E0
                    puls      x,b,a
                    bcc       L00A2
                    lsra
                    bne       L00CC
L00E0               lbsr      L02A5
                    bcs       L00A2
                    ldx       $08,y
                    pshs      y,cc
                    orcc      #IntMasks
                    ldy       #$0000
                    ldb       #$80
                    stb       >$FF48
                    ldb       #$08
                    orb       >u0085,u
                    stb       >$FF40
                    ldb       #$88
                    orb       >u0085,u
                    lbsr      L041C
                    lda       #$02
                    tst       >u0084,u
                    beq       L012F
L010E               bita      >$FF48
                    bne       L0125
                    leay      -$01,y
                    bne       L010E
L0117               lda       >u0085,u
                    ora       #$08
                    sta       >$FF40
                    puls      y,cc
                    lbra      L026A
L0125               lda       >$FF4B
                    sta       ,x+
                    stb       >$FF40
                    bra       L0125
L012F               ldb       >u008D,u
L0133               bita      >$FF48
                    bne       L0145
                    leay      -$01,y
                    bne       L0133
                    bra       L0117
L013E               lda       #$02
                    bita      >$FF48
                    beq       L013E
L0145               lda       >$FF4B
                    sta       ,x+
                    decb
                    bne       L013E
                    lbra      L0237
L0150               clr       >u008D,u
                    clr       >u008C,u
                    rts

Write               bsr       L0150
L015B               lda       #$91
L015D               pshs      x,b,a
                    bsr       L017F
                    puls      x,b,a
                    bcs       L0171
                    tst       <$28,y
                    bne       L016F
                    lbsr      L026E
                    bcs       L0171
L016F               clrb
L0170               rts
L0171               lsra
                    beq       L01C1
                    bcc       L015D
                    pshs      x,b,a
                    lbsr      L04D4
                    puls      x,b,a
                    bra       L015D
L017F               lbsr      L02A5
                    bcs       L0170
                    ldx       $08,y
                    ldb       #$A0
                    pshs      y,cc
                    orcc      #IntMasks
                    ldy       #$0000
                    stb       >$FF48
                    ldb       #$08
                    orb       >u0085,u
                    stb       >$FF40
                    ldb       #$88
                    orb       >u0085,u
                    lbsr      L041C
                    lda       #$02
                    tst       >u0084,u
                    beq       L01CE
L01AD               bita      >$FF48
                    bne       L01C4
                    leay      -$01,y
                    bne       L01AD
L01B6               lda       >u0085,u
                    ora       #$08
                    sta       >$FF40
                    puls      y,cc
L01C1               lbra      L0266
L01C4               lda       ,x+
                    sta       >$FF4B
                    stb       >$FF40
                    bra       L01C4
L01CE               ldb       >u008D,u
L01D2               bita      >$FF48
                    bne       L01E4
                    leay      -$01,y
                    bne       L01D2
                    bra       L01B6
L01DD               lda       #$02
L01DF               bita      >$FF48
                    beq       L01DF
L01E4               lda       ,x+
                    sta       >$FF4B
                    decb
                    bne       L01DD
                    bra       L0237
L01EE               pshs      y,cc
                    orcc      #IntMasks
                    ldy       #$0000
                    stb       >$FF48
                    ldb       #$08
                    orb       >u0085,u
                    stb       >$FF40
                    ldb       #$88
                    orb       >u0085,u
                    lbsr      L041C
                    lda       #$02
                    tst       >u0084,u
                    bne       L01AD
                    ldb       #$01
L0215               bita      >$FF48
                    bne       L022E
                    leay      -$01,y
                    bne       L0215
                    bra       L01B6
L0220               lda       #$02
L0222               bita      >$FF48
                    bne       L022E
                    bitb      >$FF48
                    bne       L0222
                    bra       L0237
L022E               lda       ,x+
                    sta       >$FF4B
                    bra       L0220
L0235               leas      $0C,s
L0237               puls      y,cc
                    ldb       >$FF48
                    bitb      #$FC
                    beq       L0260
                    bitb      #$04
                    bne       L026A
                    lda       #$F6
                    bitb      #$80
                    bne       L0262
                    lda       #$F2
                    bitb      #$40
                    bne       L0262
                    bitb      #$20
                    bne       L0266
                    lda       #$F7
                    bitb      #$10
                    bne       L0262
                    lda       #$F3
                    bitb      #$08
                    bne       L0262
L0260               clrb
                    rts
L0262               comb
                    tfr       a,b
                    rts
L0266               comb
                    ldb       #E$Write
                    rts
L026A               comb
                    ldb       #E$Read
                    rts
L026E               pshs      x,b,a
                    ldx       $08,y
                    pshs      x
                    ldx       >u0088,u
                    stx       $08,y
                    ldx       $04,s
                    lbsr      L00E0
                    puls      x
                    stx       $08,y
                    bcs       L02A3
                    lda       #$20
                    pshs      u,y,a
                    ldy       >u0088,u
                    tfr       x,u
L0290               ldx       ,u
                    cmpx      ,y
                    bne       L02A0
                    leau      8,u
                    leay      $08,y
                    dec       ,s
                    bne       L0290
                    bra       L02A1
L02A0               coma
L02A1               puls      u,y,a
L02A3               puls      pc,x,b,a
L02A5               clr       >u0087,u
                    lbsr      L03C1
                    tst       >u008C,u
                    beq       L02D3
                    ldx       $06,y
                    ldd       $06,x
                    bitb      #$01
                    beq       L02BE
                    com       >u0083,u
L02BE               bitb      #$02
                    beq       L02C8
                    lda       #$20
                    sta       >u0084,u
L02C8               ldd       $08,x
                    stb       >$FF4A
                    ldx       >u0081,u
                    bra       L034E
L02D3               tstb
                    bne       L02E7
                    tfr       x,d
                    ldx       >u0081,u
                    cmpd      #$0000
                    beq       L0329
                    cmpd      $01,x
                    bcs       L02EB
L02E7               comb
                    ldb       #E$Sect
                    rts
L02EB               subd      <$2B,y
                    bcc       L02F5
                    addd      <$2B,y
                    bra       L0329
L02F5               clr       ,-s
                    pshs      b
                    ldb       <$10,x
                    lsrb
                    puls      b
                    bcc       L0310
L0301               com       >u0083,u
                    bne       L0309
                    inc       ,s
L0309               subd      <$11,x
                    bcc       L0301
                    bra       L0317
L0310               inc       ,s
                    subd      <$11,x
                    bcc       L0310
L0317               lda       <$10,x
                    bita      #$02
                    beq       L0324
                    lda       #$20
                    sta       >u0084,u
L0324               puls      a
                    addb      <$12,x
L0329               pshs      a
                    lda       <$23,y
                    bita      #$20
                    beq       L0342
                    incb
                    lda       #$20
                    sta       >u0084,u
                    lda       #$15
                    cmpa      ,s
                    bcc       L0342
                    lbsr      L04BF
L0342               puls      a
                    stb       >$FF4A
L0347               ldb       <$10,x
                    stb       >u008E,u
L034E               pshs      a
                    ldb       <$15,x
                    pshs      b
                    ldb       >u008E,u
                    lsrb
                    bitb      #$02
                    beq       L036B
                    eorb      <$24,y
                    bitb      #$02
                    beq       L0375
                    leas      $02,s
                    comb
                    ldb       #E$BTyp
                    rts
L036B               eorb      <$24,y
                    bitb      #$02
                    beq       L0375
                    lsla
                    lsl       ,s
L0375               puls      b
                    stb       >$FF49
                    tst       >u0087,u
                    bne       L0387
                    ldb       ,s
                    cmpb      <$15,x
                    beq       L03A2
L0387               sta       <$15,x
                    sta       >$FF4B
                    ldb       #$1B
                    eorb      <$22,y
                    bsr       L03FA
                    pshs      b,a
                    lda       #$1E
L0398               ldb       #$B2
L039A               decb
                    bne       L039A
                    deca
                    bne       L0398
                    puls      b,a
L03A2               puls      a
                    sta       <$15,x
                    sta       >$FF49
                    ldb       #$40
                    andb      >u0083,u
                    orb       >u0084,u
                    orb       >u0085,u
                    stb       >u0085,u
                    clrb
                    rts
L03BE               fcb       $01,$02,$04
L03C1               lbsr      L04F8
                    lda       <$21,y
                    cmpa      #$03
                    bcs       L03CF
                    comb
                    ldb       #E$Unit
                    rts
L03CF               pshs      x,b,a
                    leax      >L03BE,pcr
                    ldb       a,x
                    stb       >u0085,u
                    leax      DRVBEG,u
                    ldb       #$26
                    mul
                    leax      d,x
                    cmpx      >u0081,u
                    beq       L03F0
                    stx       >u0081,u
                    com       >u0087,u
L03F0               clr       >u0083,u
                    clr       >u0084,u
                    puls      pc,x,b,a
L03FA               bsr       L0417
L03FC               ldb       >$FF48
                    bitb      #$01
                    beq       L041F
                    lda       #$F0
                    sta       >$006F
                    bra       L03FC
L040A               lda       #$08
                    ora       >u0085,u
                    sta       >$FF40
                    stb       >$FF48
                    rts
L0417               bsr       L040A
L0419               lbsr      L041C
L041C               lbsr      L041F
L041F               rts

GetStat             ldx       PD.RGS,y
                    ldb       R$B,x
                    cmpb      #$80
                    bne       L046F
                    bsr       L0439
                    lda       #$91
                    lbsr      L00D5
L042F               pshs      b,cc
                    ldd       >u008A,u
                    std       $08,y
                    puls      pc,b,cc
L0439               ldd       $08,y
                    std       >u008A,u
                    lda       #$01
                    sta       >u008C,u
                    ldx       $06,y
                    ldd       $04,x
                    std       $08,y
                    ldd       $06,x
                    sta       >u008D,u
                    stb       >u008E,u
                    rts

SetStat             ldx       PD.RGS,y
                    ldb       R$B,x
                    cmpb      #$03
                    beq       L04D4
                    cmpb      #$04
                    beq       L0482
                    cmpb      #$0A
                    beq       L0473
                    clra
                    cmpb      #$81
                    beq       L0475
                    cmpb      #$80
                    beq       L047B
L046F               comb
                    ldb       #E$UnkSvc
L0472               rts
L0473               lda       #$FF
L0475               sta       >u0086,u
                    clrb
L047A               rts
L047B               bsr       L0439
                    lbsr      L015B
                    bra       L042F
L0482               lbsr      L03C1
                    bcs       L0472
                    lda       $09,x
                    ldb       <$23,y
                    bitb      #$20
                    beq       L0496
                    cmpa      #$15
                    bls       L0496
                    bsr       L04BF
L0496               ldb       $07,x
                    ldx       >u0081,u
                    stb       <$10,x
                    bitb      #$01
                    beq       L04A7
                    com       >u0083,u
L04A7               bitb      #$02
                    beq       L04B1
                    ldb       #$20
                    stb       >u0084,u
L04B1               lbsr      L0347
                    bcs       L0472
                    ldx       $06,y
                    ldx       $04,x
                    ldb       #$F0
                    lbra      L01EE
L04BF               pshs      a
                    lda       <$26,y
                    cmpa      #$23
                    bne       L04D2
                    lda       >u0085,u
                    ora       #$10
                    sta       >u0085,u
L04D2               puls      pc,a
L04D4               lbsr      L03C1
                    bcs       L047A
                    ldx       >u0081,u
                    clr       <$15,x
                    lda       #$05
L04E2               ldb       #$4B
                    pshs      a
                    eorb      <$22,y
                    bsr       L04F5
                    puls      a
                    deca
                    bne       L04E2
                    ldb       #$0B
                    eorb      <$22,y
L04F5               lbra      L03FA
L04F8               pshs      x,b,a
                    lda       >$006F
                    bne       L050D
                    lda       #$08
                    sta       >$FF40
                    ldx       #$A000
L0507               nop
                    nop
                    leax      -$01,x
                    bne       L0507
L050D               lda       #$F0
                    sta       >$006F
                    puls      pc,x,b,a

                    fdb       $01E9

                    emod
eom                 equ       *
                    end
