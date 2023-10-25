*******************************************************************
*
*     Sdisk3 - floopy disk controller driver by D.P. Johnson
*      and Sardis Technologies for the DMC no-halt controllers.
*
*******************************************************************

* Sardis DMC controller registers
fdcdrv              equ       $ff40
fdccmd              equ       $ff48
fdcsta              equ       $ff48
fdctrk              equ       $ff49
fdcsec              equ       $ff4A
fdcdta              equ       $ff4B
fdwrit              equ       $ff44
fdread              equ       $ff4c
disdma              equ       $ff44
fdptrh              equ       $ff46
fdptrl              equ       $ff42
buffer              equ       $ff4e

                    nam       SDisk3
                    ttl       os9 device driver

                    ifp1
                    use       defsfile
                    endc

rev                 set       $01

                    mod       eom,name,Drivr+Objct,ReEnt+rev,start,size

                    org       V.USER
u0006               rmb       9
drvtab              rmb       35
u0032               rmb       24
u004A               rmb       4
u004E               rmb       2
u0050               rmb       49
u0081               rmb       2
u0083               rmb       2
u0085               rmb       1
u0086               rmb       1
u0087               rmb       1
u0088               rmb       1
u0089               rmb       1
u008A               rmb       1
u008B               rmb       1
u008C               rmb       1
u008D               rmb       1
u008E               rmb       1
u008F               rmb       2
u0091               rmb       1
u0092               rmb       1
u0093               rmb       1
u0094               rmb       1
u0095               rmb       1
u0096               rmb       2
u0098               rmb       1
u0099               rmb       1
virq1               rmb       4
u009E               rmb       1
virq2               rmb       1
u00A0               rmb       1
u00A1               rmb       1
u00A2               rmb       1
u00A3               rmb       1
u00A4               rmb       1
u00A5               rmb       1
u00A6               rmb       1
u00A7               rmb       1
u00A8               rmb       1
u00A9               rmb       1
u00AA               rmb       2
u00AC               rmb       12
u00B8               rmb       60
u00F4               rmb       1
u00F5               rmb       299
u0220               rmb       3
size                equ       .

                    fcb       $FF
name                fcs       /SDisk3/
                    fcb       $01

                    fcb       $00

L0016               fdb       $00f2               drive motor on time
L0018               fdb       $0020               motor startup delay
L001A               fdb       $0003               head settle time
L001C               fdb       $0100               default sector size
L001E               fdb       $1E00               delay-after-write before deselect
L0020               fcb       $23,$16,$28,$28,$00,$2b write precomp table
L0026               fcb       $01,$02,$04,$40     drive select codes
L002A               fdb       $0836
L002C               fdb       $009e               timeout for restore to track 0
                    fcb       $0B
L002F               fdb       $0836
L0031               fdb       $0005               timeout for step in one track
                    fcb       $4B
L0034               fdb       $0836
L0036               fdb       $0098               timeout value for seek
                    fcb       $1B
L0039               fdb       $084e
L003B               fdb       $005c               timeout value for read sector
                    fcb       $80
L003E               fdb       $083f
L0040               fdb       $005c               timeout for write sector
                    fcb       $A0
L0043               fdb       $083f
L0045               fdb       $0020               timeout value for write track
                    fcb       $F0
L0048               fcb       $03                 Multipak slot
* IRQ packet #1
L0049               fcb       $00                 IRQ flip byte
                    fcb       $01                 IRQ mask byte
L004B               fcb       $0A                 interupt priority for motor timer
* IRQ packet #2
L004C               fcb       $00                 IRQ flip byte
                    fcb       $01                 IRQ mask byte
L004E               fcb       $14                 interupt priority code

                    fcc       /Copyright 1984,1986 D.P.Johnson & Sardis Technologies/
                    fcb       $0D
                    fcc       /All rights reserved/

start               lbra      INIT
                    lbra      READ
                    lbra      WRITE
                    lbra      GETSTA
                    lbra      SETSTA

* Terminate routine
                    ldx       #$0000
                    leay      >virq1,u
                    os9       F$VIRQ
                    leay      >virq2,u
                    os9       F$VIRQ
                    os9       F$IRQ
                    leau      1,u
                    os9       F$IRQ
                    leau      -1,u
                    clra
                    sta       >$FF41
                    sta       >u0087,u
                    rts

* Init routine
INIT                lbsr      L04AB
                    pshs      cc
                    orcc      #IntMasks
                    ldd       >L0016,pc           get drive motor on time
                    std       >u0096,u
                    clra
                    sta       >u0088,u
                    sta       >u0083,u
                    sta       >u0087,u
                    ldb       >fdwrit
                    sta       >$FF41
                    sta       <D.MotOn
                    sta       >u0099,u
                    inca
                    sta       >u0092,u
                    sta       >u0093,u
                    sta       >u0094,u
                    puls      cc
                    bsr       L014B
                    bcs       L014A
                    lbsr      L0A55
* Setup drive tables
                    ldb       #$03                get default # drives
                    stb       V.NDRV,u            save it
                    lda       #$FF
                    leax      DRVBEG,u            point to drive table start
L0111               sta       DD.TOT+1,x
                    sta       <V.TRAK,x
                    leax      <DRVMEM,x
                    decb
                    bne       L0111

                    pshs      u,y
                    leay      >u009E,u
                    clr       ,y
                    tfr       y,d
                    leay      >L0A2A,pcr
                    leax      >L0049,pcr
                    os9       F$IRQ
                    bcs       L0148
                    leay      >u00A3,u
                    clr       ,y
                    tfr       y,d
                    leau      1,u
                    leay      >L0869,pcr
                    leax      >L004C,pcr
                    os9       F$IRQ
L0148               puls      u,y
L014A               rts

L014B               ldb       #$D0
                    stb       >fdread
                    nop
                    ldb       >fdwrit
                    clrb
                    ldx       #$2710
L0158               lbsr      L085B
                    ldb       >fdccmd
                    bitb      #$01
                    beq       L0169
                    leax      -$01,x
                    bne       L0158
                    comb
                    ldb       #E$NotRdy
L0169               rts

* Read entry point
READ                pshs      y,x
                    clra
                    lbsr      L0AE2
                    pshs      cc
                    bcs       L01AE
                    bmi       L017C
                    bne       L017C
                    bsr       L01D2
                    bra       L0185
L017C               lbsr      L034A
                    bcs       L01AE
                    bsr       L01B0
                    bcs       L01AE
L0185               lda       ,s
                    bita      #$08
                    bne       L018F
                    ldx       $01,s
                    bsr       L01ED
L018F               ldx       $01,s
                    bne       L01AD
                    tst       >u0088,u
                    bne       L01A9
                    ldx       $08,y               grabbing buffer address, PD.BUF?
                    ldy       >u0081,u
                    ldb       #$14
L01A2               lda       b,x
                    sta       b,y
                    decb
                    bpl       L01A2
L01A9               clr       >u0088,u
L01AD               clrb
L01AE               puls      pc,y,x,a

L01B0               lda       >u0095,u
L01B4               pshs      x,a
                    bsr       L01D7
                    puls      x,a
                    bcc       L01D2
                    cmpb      #$01
                    beq       L01CF
                    tsta
                    beq       L01CF
                    lsra
                    bcc       L01B4
                    pshs      x,a
                    lbsr      L0677
                    puls      x,a
                    bcc       L01B4
L01CF               orcc      #$01
                    rts

L01D2               lbsr      L0892
                    clrb
                    rts

L01D7               lbsr      L02E5
                    bcs       L01EC
                    lbsr      L028B
                    lbsr      L0883
                    leax      >L0039,pcr
                    lbsr      L0711
                    lbsr      L0298
L01EC               rts

L01ED               pshs      y
                    ldy       >u00AA,u
                    lbsr      L0AB0
                    sta       $02,y
                    stx       ,y
                    puls      pc,y

WRITE               pshs      x
                    lda       #$01
                    lbsr      L0AE2
                    pshs      cc
                    bcs       L021C
                    lbsr      L034A
                    bcs       L021C
                    bsr       L021E
                    bcs       L021C
                    lda       ,s
                    bita      #$08
                    bne       L021B
                    ldx       $01,s
                    bsr       L01ED
L021B               clrb
L021C               puls      pc,x,a

L021E               lda       >u0095,u
L0222               pshs      x,a
                    bsr       L0249
                    puls      x,a
                    bcs       L0233
                    tst       <PD.VFY,y
                    bne       L0248
                    bsr       L02A8
                    bcc       L0248
L0233               cmpb      #$01
                    beq       L0246
                    tsta
                    beq       L0246
                    lsra
                    bcc       L0222
                    pshs      x,a
                    lbsr      L0677
                    puls      x,a
                    bcc       L0222
L0246               orcc      #$01                Set carry
L0248               rts

L0249               lbsr      L02E5
                    bcs       L0280
                    bsr       L028B
                    lbsr      L08B1
                    leax      >L003E,pcr
                    bra       L0267
L0259               lbsr      L02E5
                    bcs       L0280
                    bsr       L028B
                    lbsr      L08E4
                    leax      >L0043,pcr
L0267               lbsr      L070D
                    pshs      b,cc
                    ldb       >L001E,pcr
L0270               lbsr      L085B
                    decb
                    bne       L0270
                    puls      b,cc
                    bsr       L0298
                    rts

L027B               leas      $01,s
L027D               comb                          Bad type error
                    ldb       #E$BTyp
L0280               rts

L0281               comb                          Seek error
                    ldb       #E$Seek
                    rts

L0285               leas      $01,s
L0287               comb                          Sector error
                    ldb       #E$Sect
                    rts

L028B               pshs      cc
                    tst       >u008B,u
                    beq       L02A6
                    lsr       >fdctrk
                    bra       L02A3
L0298               pshs      cc
                    tst       >u008B,u
                    beq       L02A6
                    lsl       >fdctrk
L02A3               lbsr      L085B
L02A6               puls      pc,cc

L02A8               pshs      y,x,a
                    lbsr      L01D7
                    bcs       L02E3
                    lbsr      L0883
                    ldx       $08,y
                    ldd       >u008F,u
                    tst       >u0098,u
                    beq       L02C8
                    ora       #$C0
                    lbsr      L08F6
                    tsta
                    beq       L02E0
                    bra       L02DD
L02C8               tfr       x,y
                    lsra
                    rorb
                    lsra
                    rorb
L02CE               ldx       >buffer
                    cmpx      ,y
                    bne       L02E0
                    ldx       >buffer
                    leay      $04,y
                    decb
                    bne       L02CE
L02DD               clrb
                    bra       L02E3
L02E0               comb
                    ldb       #E$Write            write error
L02E3               puls      pc,y,x,a

L02E5               pshs      x,cc
                    orcc      #$50
                    nop
                    lda       >u0087,u
                    anda      #$0F
                    tst       >u0085,u
                    beq       L02F8
                    ora       #$40
L02F8               tst       >u0086,u
                    beq       L0300
                    ora       #$20
L0300               tst       >u008C,u
                    beq       L0308
                    ora       #$10
L0308               sta       >u0087,u
                    bita      #$08
                    bne       L0312
                    anda      #$D8
L0312               sta       >$FF41
                    puls      cc
                    ldx       >u0081,u
                    lda       ,s
                    cmpa      <$15,x
                    beq       L033F
                    sta       <$15,x
                    sta       >fdcdta
                    lbsr      L085B
                    leax      >L0034,pcr
                    lbsr      L0711
                    bcs       L0348
                    ldx       >L001A,pcr
                    beq       L033F
                    lbsr      L06B2
                    bcs       L0348
L033F               ldb       $01,s
                    stb       >$FF4A
                    lbsr      L085B
                    clrb
L0348               puls      pc,x

L034A               tstb
                    lbne      L0287
                    lbsr      L0471
                    lbcs      L0450
                    clr       >u0085,u
                    clr       >u0086,u
                    clr       >u008B,u
                    clr       >u008D,u
                    clr       ,-s
                    tfr       x,d
                    ldx       >u0081,u
                    cmpd      #$0000
                    lbeq      L03FA
                    inc       >u008D,u
                    cmpd      $01,x
                    lbcc      L0285
                    subd      <PD.T0S,y
                    bcc       L038B
                    addd      <PD.T0S,y
                    bra       L03FA

L038B               pshs      b,a
                    ldd       <$11,x
                    subd      #$0012
                    stb       >u0091,u
                    ldb       <$10,x
                    lsrb
                    bcc       L03CC
                    ldb       <PD.SID,y
                    cmpb      #$01                only one side?
                    puls      b,a                 might as well clean up
                    lbls      L027B               and leave now...
                    tst       >u0091,u
                    bne       L03BD
                    bra       L03B5
L03B0               inc       ,s
                    subd      #$0090
L03B5               cmpa      #$01
                    bcc       L03B0
                    lsl       ,s
                    lsl       ,s
L03BD               com       >u0085,u
                    bne       L03C5
                    inc       ,s
L03C5               subd      <$11,x
                    bcc       L03BD
                    bra       L03EC
L03CC               puls      b,a
                    tst       >u0091,u
                    bne       L03E5
                    bra       L03DB
L03D6               inc       ,s
                    subd      #$0090
L03DB               cmpa      #$01
                    bcc       L03D6
                    lsl       ,s
                    lsl       ,s
                    lsl       ,s
L03E5               inc       ,s
                    subd      <$11,x
                    bcc       L03E5
L03EC               addd      <$11,x
                    lda       <$10,x
                    bita      #$02
                    beq       L03FA
                    com       >u0086,u
L03FA               lda       <PD.TYP,y
                    bita      #$20
                    beq       L0405
                    dec       >u0086,u
L0405               lda       <PD.STOFF,y
                    anda      #$0F
                    pshs      a
                    lda       <PD.STOFF,y
                    lsra
                    lsra
                    lsra
                    lsra
                    pshs      a
                    addb      ,s+
                    puls      a
                    adda      ,s
                    sta       ,s
                    tst       >u008D,u
                    beq       L0442
                    lda       <$10,x
                    lsra
                    bita      #$02
                    beq       L0435
                    eora      <PD.DNS,y
                    bita      #$02
                    beq       L0442
                    lbra      L027B
L0435               eora      <PD.DNS,y
                    bita      #$02
                    beq       L0442
                    com       >u008B,u
                    lsl       ,s
L0442               puls      a
                    cmpa      <PD.CYL+1,y
                    lbcc      L0281
                    tfr       d,x
                    lbsr      L0648
L0450               rts

L0451               pshs      x
                    lda       <PD.DRV,y           Get the drive number
                    cmpa      #$03                is it bigger than 3?
                    bcc       L0468               yes - not possible...

* this would be where the 4th+ drive hardware mod patch would go.

                    leax      drvtab,u            drive table beginning
                    ldb       #DRVMEM             drive table size
                    mul
                    leax      d,x                 compute the address
                    stx       >u0081,u
                    clrb
                    puls      pc,x

L0468               comb
                    ldb       #E$Unit
                    puls      pc,x

L046D               bsr       L0451
                    bcs       L0450
L0471               pshs      x
                    lbsr      L09CA
                    bcs       L04A9
                    pshs      cc
                    orcc      #$50
                    leax      >L0026,pcr
                    lda       <$21,y
                    ldb       >u0087,u
                    andb      #$F8
                    orb       a,x
                    stb       >u0087,u
                    puls      cc
                    ldx       >u0081,u
                    cmpx      >u0083,u
                    beq       L04A8
                    stx       >u0083,u
                    lda       <$15,x
                    sta       >fdctrk
                    lbsr      L085B
L04A8               clrb
L04A9               puls      pc,x

L04AB               ldd       #$0100
                    std       >u008F,u
                    lda       #$92
                    sta       >u0095,u
                    clr       >u0098,u
                    rts

* GetStat entry point
GETSTA              ldx       PD.RGS,y            get pointer to register stack
                    ldb       R$B,x               get callcode
                    clra
                    cmpb      #$84                SS.SDRD system direct sector read?
                    beq       L04F2
                    inca
                    cmpb      #$80                SS.DWRIT direct sector write?
                    beq       L04F2
                    cmpb      #$86                SS.DRVCH drive cache select?
                    beq       L04D3
                    comb
                    ldb       #E$UnkSvc
                    rts

L04D3               lda       >u00A9,u
                    sta       R$A,x
                    clrb
                    rts

* Direct sector read entry point
L04DB               bsr       L0507
                    bcs       L04FB
                    lda       >u00A9,u
                    bmi       L04ED
                    cmpa      <PD.DRV,y
                    bne       L04ED
                    lbsr      L0A95
L04ED               lbsr      L021E
                    bra       L04FB

* Direct sector write
L04F2               bsr       L0507
                    bcs       L04FB
                    lbsr      L01B0
                    bcs       L04FB
L04FB               pshs      b,cc
                    ldd       >u0089,u
                    std       PD.BUF,y
                    bsr       L04AB
                    puls      pc,b,cc

L0507               sta       >u0098,u
                    ldd       PD.BUF,y
                    std       >u0089,u
                    ldd       R$X,x
                    std       PD.BUF,y
                    ldd       R$Y,x
                    exg       a,b
                    tsta
                    bpl       L0522
                    clr       >u0095,u
                    anda      #$7F
L0522               lsra
                    lsra
                    lsra
                    lsra
                    andb      #$FC
                    cmpd      #$0000
                    bne       L0532
                    ldd       >L001C,pcr
L0532               std       >u008F,u
                    lbsr      L0B61
                    lbsr      L0451
                    bcs       L0543
                    ldx       R$U,x
                    lbsr      L05F3
L0543               rts

SETSTA              ldx       PD.RGS,y            grab caller's register stack pointer
                    ldb       R$B,x               get the Stat call number
                    cmpb      #SS.Reset           Seek to track 0?
                    lbeq      L0672               yes...
                    cmpb      #SS.Wtrk            direct track write?
                    lbeq      L05B9               yes...
                    cmpb      #SS.Frz
                    beq       L0581
                    cmpb      #$81                SS.UnFrz
                    beq       L057E
                    clra
                    cmpb      #$84                SS.SDRD
                    beq       L0564
                    inca
                    cmpb      #$80                SS.DREAD
L0564               lbeq      L04DB
                    cmpb      #$83                (SS.MOTIM) change drive motor-on time?
                    beq       L059B
                    cmpb      #$85                (SS.SLEEP) activate/deactivate sleep?
                    beq       L0589
                    cmpb      #$82                (SS.MOFF) shut off drive motor?
                    beq       L05A8
                    cmpb      #$86                (SS.DRVCHG) cache select?
                    lbeq      L0A8C
                    comb
                    ldb       #E$UnkSvc
                    rts

L057E               clra
                    bra       L0583
L0581               lda       #$FF
L0583               sta       >u0088,u
                    clrb
                    rts

L0589               ldx       R$X,x
                    bne       L0591
                    clra
                    inca
                    bra       L0596
L0591               clra
                    sta       >u0093,u
L0596               sta       >u0094,u
                    rts

* Change drive motor time
L059B               ldd       R$X,x
                    bmi       L05A2
                    addd      #$0002
L05A2               std       >u0096,u
                    clrb
                    rts

L05A8               pshs      y,x,a,cc
                    orcc      #$50
                    nop
                    ldd       >virq1,u
                    beq       L05B6
                    ldd       #$0001
L05B6               lbra      L09FC

L05B9               lda       >u00A9,u            Write track/format
                    lbsr      L0A95
                    lbsr      L0451
                    bcs       L05F2
                    ldb       R$Y+1,x
                    ldx       R$U,x
                    pshs      x
                    ldx       >u0081,u
                    stb       <$10,x
                    puls      b,a
                    lda       #$01
                    exg       a,b
                    tfr       d,x
                    bsr       L05F3
                    bcs       L05F2
                    lda       #$03
L05E0               pshs      x,a
                    lbsr      L0259
                    puls      x,a
                    bcc       L05F2
                    cmpb      #$01
                    beq       L05F0
                    deca
                    bne       L05E0
L05F0               orcc      #$01
L05F2               rts

L05F3               lbsr      L0471
                    bcs       L0647
                    pshs      x
                    ldx       PD.RGS,y
                    lda       R$Y+1,x             grab low end of Y
                    clrb
                    bita      #$01
                    beq       L060C
                    ldb       <PD.SID,y
                    cmpb      #$01
                    bls       L0627
                    ldb       #$FF
L060C               stb       >u0085,u
                    clrb
                    bita      #$02
                    beq       L0616
                    comb
L0616               stb       >u0086,u
                    clrb
                    lsra
                    bita      #$02
                    beq       L062C
                    eora      <PD.DNS,y
                    bita      #$02
                    beq       L0636
L0627               leas      $02,s
                    lbra      L027D
L062C               eora      <PD.DNS,y
                    bita      #$02
                    beq       L0636
                    comb
                    lsl       ,s
L0636               stb       >u008B,u
                    puls      x
                    tfr       x,d
                    cmpa      <PD.CYL+1,y
                    lbcc      L0281
                    bsr       L0648
L0647               rts

L0648               pshs      x
                    clr       >u008C,u
                    leax      >L0020,pcr
                    ldb       <PD.CYL+1,y
L0655               tst       ,x
                    beq       L0661
                    cmpb      ,x
                    beq       L0661
                    leax      $02,x
                    bra       L0655
L0661               cmpa      $01,x
                    bcs       L066F
                    tst       >u0086,u
                    beq       L066F
                    inc       >u008C,u
L066F               clrb
                    puls      pc,x

L0672               lbsr      L046D
                    bcs       L06AE
L0677               leax      >L002A,pcr
                    lbsr      L0711
                    bcs       L06A4
                    bsr       L06AF
                    bcs       L06A4
                    lda       #$05
L0686               pshs      a
                    leax      >L002F,pcr
                    lbsr      L0711
                    puls      a
                    bcs       L06A4
                    deca
                    bne       L0686
                    bsr       L06AF
                    bcs       L06A4
                    leax      >L002A,pcr
                    bsr       L0711
                    bcs       L06A4
                    bsr       L06AF
L06A4               ldx       >u0081,u
                    lda       >fdctrk
                    sta       <$15,x
L06AE               rts

L06AF               ldx       #$000E
L06B2               pshs      x,a
                    clrb
                    bra       L06D4
L06B7               os9       F$Sleep
L06BA               stx       $01,s
                    ldx       <D.Proc
                    lda       P$State,x
                    bita      #Condem
                    bne       L0708
                    ldb       <P$Signal,x
                    ldx       <P$SigVec,x
                    bne       L06D4
                    cmpb      #S$Wake
                    bls       L06D4
                    cmpb      #S$Window
                    bne       L0708
L06D4               ldx       $01,s
                    beq       L0705
                    pshs      b,a
                    ldd       <D.Proc
                    cmpd      <D.SysPrc
                    puls      b,a
                    beq       L06F9
                    tst       >u0093,u
                    bne       L06ED
                    cmpb      #$01
                    bls       L06B7
L06ED               lda       #$EA
L06EF               lbsr      L085B
                    deca
                    bne       L06EF
                    leax      -$01,x
                    bra       L06BA
L06F9               lda       #$EA
L06FB               lbsr      L085B
                    deca
                    bne       L06FB
                    leax      -$01,x
                    bne       L06F9
L0705               clrb
                    puls      pc,x,a

L0708               comb
                    ldb       #$01
                    puls      pc,x,a
L070D               lda       #$01
                    bra       L0712
L0711               clra
L0712               pshs      y,x
                    ldb       >fdccmd
                    bitb      #$81
                    lbne      L07ED
                    lbsr      L09CA
                    lbcs      L081A
                    pshs      cc
                    orcc      #$50
                    tsta
                    bne       L0737
                    ldb       $04,x
                    bmi       L0732
                    eorb      <PD.STP,y
L0732               stb       >fdread
                    bra       L073C
L0737               ldb       $04,x
                    stb       >fdwrit
L073C               ldx       $02,x
                    puls      cc
                    ldd       <D.Proc
                    cmpd      <D.SysPrc
                    beq       L07B2
                    tst       >u0092,u
                    bne       L07B2
                    tst       >u0094,u
                    bne       L07B2
                    clr       >u0099,u
                    leay      >virq2,u
                    clr       PD.DEV+1,y
                    tfr       x,d
                    ldx       #$0001
                    os9       F$VIRQ
                    bcc       L0770
                    lbra      L081A
L076A               ldx       #$0001
                    os9       F$Sleep
L0770               ldx       <D.Proc
                    lda       P$State,x
                    ldb       <P$Signal,x
                    ldx       <P$SigVec,x
                    bne       L0784
                    cmpb      #S$Wake
                    bls       L0784
                    cmpb      #S$Window
                    bne       L0788
L0784               bita      #Condem
                    beq       L0799
L0788               leay      >virq2,u
                    ldx       #$0000
                    os9       F$VIRQ
                    lbsr      L081F
                    ldb       #$01
                    bra       L0818
L0799               tst       >fdcdrv
                    bmi       L07A6
                    tst       >u0099,u
                    beq       L076A
                    bra       L07ED
L07A6               leay      >virq2,u
                    ldx       #$0000
                    os9       F$VIRQ
                    bra       L07F3
L07B2               lda       #$D2
L07B4               lbsr      L085B
                    tst       >fdcdrv
                    bmi       L07F3
                    deca
                    bne       L07B4
                    leax      -$01,x
                    beq       L07ED
                    ldd       <u0050
                    cmpd      <u004A
                    beq       L07B2
                    pshs      x
                    ldx       <D.Proc
                    lda       P$State,x
                    ldb       <P$Signal,x
                    ldx       <P$SigVec,x
                    puls      x
                    bne       L07E2
                    cmpb      #$01
                    bls       L07E2
                    cmpb      #$04
                    bne       L07E6
L07E2               bita      #Condem
                    beq       L07B2
L07E6               lbsr      L081F
                    ldb       #$01
                    bra       L0818
L07ED               bsr       L081F
                    ldb       #$80
                    bra       L07F9
L07F3               lda       >fdwrit
                    ldb       >fdccmd
L07F9               stb       >u008E,u
                    lbsr      L09CA
                    bcs       L081A
                    leax      >0,pcr
                    ldd       [,s]
                    leax      d,x
                    ldb       >u008E,u
L080E               tst       ,x
                    beq       L081C
                    bitb      ,x++
                    beq       L080E
                    ldb       ,-x
L0818               orcc      #$01
L081A               puls      pc,y,x
L081C               clrb
                    puls      pc,y,x

L081F               pshs      b,cc
                    orcc      #$50
                    lda       >fdwrit
                    lda       >u0087,u
                    anda      #$DF
                    sta       >$FF41
                    puls      cc
                    lbsr      L014B
                    puls      pc,b

                    fdb       $80f6
                    fdb       $1017
                    fdb       $08f3
                    fdb       $01f6
                    fdb       $0080
                    fdb       $f640
                    fdb       $f220
                    fdb       $f510
                    fdb       $f708
                    fdb       $f304
                    fdb       $f501
                    fdb       $f600
                    fdb       $80f6
                    fdb       $20f4
                    fdb       $10f7
                    fdb       $08f3
                    fdb       $04f4
                    fdb       $01f6
                    fcb       $00

L085B               tst       >$00A0
                    beq       L0864
                    bsr       L0868
                    bsr       L0864
L0864               bsr       L0866
L0866               bsr       L0868
L0868               rts

L0869               pshs      a
                    lda       >u00A2,u
                    bita      #$01
                    beq       L0880
                    sta       >u0098,u
                    anda      #$FE
                    sta       >u00A2,u
                    clra
                    bra       L0881
L0880               coma
L0881               puls      pc,a
L0883               ldb       >u00A4,u
L0887               stb       >fdptrl
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    stb       >fdptrh
                    rts

L0892               pshs      u,dp,a
                    bsr       L08D2
                    tst       >u0098,u
                    beq       L08A2
                    ora       #$80
                    bsr       L08F6
                    bra       L08AF
L08A2               bsr       L08DB
L08A4               ldu       <u004E
                    stu       ,x++
                    ldu       <u004E
                    stu       ,x++
                    decb
                    bne       L08A4
L08AF               puls      pc,u,dp,a

L08B1               pshs      u,dp,a
                    bsr       L08D2
                    tst       >u0098,u
                    beq       L08BF
                    bsr       L08F6
                    bra       L08CE
L08BF               bsr       L08DB
L08C1               ldu       ,x++
                    stu       <u004E
                    ldu       ,x++
                    stu       <u004E
                    decb
                    bne       L08C1
                    ldu       $02,s
L08CE               bsr       L0883
                    puls      pc,u,dp,a

L08D2               bsr       L0883
                    ldx       $08,y
                    ldd       >u008F,u
                    rts
L08DB               lsra
                    rorb
                    lsra
                    rorb
                    lda       #$FF
                    tfr       a,dp
                    rts

L08E4               ldb       #$20
                    bsr       L0887
                    ldx       PD.RGS,y
                    ldx       R$X,x
                    ldd       #$1A00
                    bsr       L08F6
                    ldb       #$20
                    bsr       L0887
                    rts

L08F6               pshs      u,y,x,a
                    leas      -$0C,s
                    sta       $0B,s
                    anda      #$3F
                    std       $04,s
                    lda       #$01
                    sta       $0C,s
                    tfr       x,d
                    anda      #$1F
                    std       $08,s
                    exg       x,d
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    lsla
                    inca
                    ldu       <D.Proc
                    ldb       P$Task,u
                    ldu       <D.TskIPt
                    lslb
                    ldu       b,u
                    leau      a,u
                    stu       $06,s
                    ldd       #$2000
                    subd      $08,s
                    std       ,s
L0927               pshs      cc
                    orcc      #$50
                    ldd       [>D.SysDAT]
                    stb       $0B,s
                    ldd       $05,s
                    cmpd      $01,s
                    bls       L093A
                    ldd       $01,s
L093A               cmpd      #$0040
                    bls       L0943
                    ldd       #$0040
L0943               std       $03,s
                    lsra
                    rorb
                    tfr       d,y
                    ldb       [<$07,s]
                    stb       >$FFA0
                    lda       $0C,s
                    bpl       L098C
                    bita      #$40
                    bne       L096D
                    bcc       L0962
                    lda       >buffer
                    sta       ,x+
                    leay      ,y
                    beq       L09A0
L0962               ldd       >buffer
                    std       ,x++
                    leay      -$01,y
                    bne       L0962
                    bra       L09A0
L096D               bcc       L097C
                    lda       >buffer
                    cmpa      ,x+
                    beq       L0978
                    clr       $0D,s
L0978               leay      ,y
                    beq       L09A0
L097C               ldd       >buffer
                    cmpd      ,x++
                    beq       L0986
                    clr       $0D,s
L0986               leay      -$01,y
                    bne       L097C
                    bra       L09A0
L098C               bcc       L0997
                    lda       ,x+
                    sta       >buffer
                    leay      ,y
                    beq       L09A0
L0997               ldd       ,x++
                    std       >buffer
                    leay      -$01,y
                    bne       L0997
L09A0               ldb       $0B,s
                    stb       >$FFA0
                    puls      cc
                    ldd       $04,s
                    subd      $02,s
                    beq       L09C6
                    std       $04,s
                    ldd       ,s
                    subd      $02,s
                    bne       L09C1
                    tfr       d,x
                    ldd       $06,s
                    addd      #$0002
                    std       $06,s
                    ldd       #$2000
L09C1               std       ,s
                    lbra      L0927
L09C6               leas      $0C,s
                    puls      pc,u,y,x,a

L09CA               pshs      y,x,a,cc
                    orcc      #$50
                    nop
                    lda       >u0087,u
                    bita      #$08
                    bne       L09EF
                    ora       #$08
                    sta       >u0087,u
                    anda      #$D8
                    sta       >$FF41
                    bsr       L0A05
                    puls      cc
                    ldx       >L0018,pcr
                    lbsr      L06B2
                    bra       L0A03
L09EF               sta       >$FF41
                    tst       <D.MotOn
                    beq       L09F8
                    bsr       L0A05
L09F8               ldd       >u0096,u
L09FC               std       >virq1,u
                    puls      cc
                    clrb
L0A03               puls      pc,y,x,a

L0A05               clr       <D.MotOn
                    ldd       >u0096,u
                    leay      >virq1,u
                    clr       $04,y
                    ldx       #$0001
                    os9       F$VIRQ
                    bcc       L0A1C
                    dec       <D.MotOn
                    rts
L0A1C               tst       >u0092,u
                    beq       L0A29
                    clr       >u0092,u
                    lbsr      L0591
L0A29               rts
L0A2A               pshs      a
                    coma
                    lda       >u009E,u
                    bita      #$01
                    beq       L0A53
                    tst       <D.DMAReq
                    beq       L0A3E
                    bsr       L0A05
                    clra
                    bra       L0A53
L0A3E               lda       >u0087,u
                    anda      #$F7
                    sta       >u0087,u
                    anda      #$D8
                    sta       >$FF41
                    clr       >u009E,u
                    clr       <D.MotOn
L0A53               puls      pc,a

L0A55               pshs      x,b,a
                    lda       #$BE
                    sta       >u00A8,u
                    clra
                    ldb       #$3C
                    lbsr      L0887
                    sta       >buffer
                    deca
                    ldb       #$7C
                    lbsr      L0887
                    sta       >buffer
                    ldb       #$3C
                    lbsr      L0887
                    clra
                    ldb       #$7C
                    tst       >buffer
                    beq       L0A80
                    lda       #$20
                    ldb       #$1C
L0A80               sta       >u00A5,u
                    stb       >u00A6,u
                    lda       #$FF
                    bra       L0A9B
L0A8C               lda       <$21,y
                    ldx       $04,x
                    bne       L0A95
                    lda       #$FF
L0A95               pshs      x,b,a
                    ldb       >u00A6,u
L0A9B               sta       >u00A9,u
                    leax      >u00AC,u
                    lda       #$FF
L0AA5               sta       ,x+
                    sta       ,x+
                    clr       ,x+
                    decb
                    bne       L0AA5
                    puls      pc,x,b,a
L0AB0               pshs      x,b
                    lda       >u00A8,u
                    inca
                    cmpa      #$FF
                    bne       L0ADC
                    leax      >u00AC,u
                    ldb       >u00A6,u
L0AC3               lda       $02,x
                    beq       L0AD5
                    cmpa      #$7F
                    bls       L0ACF
                    suba      #$40
                    bra       L0AD3
L0ACF               lsra
                    bne       L0AD3
                    inca
L0AD3               sta       $02,x
L0AD5               leax      $03,x
                    decb
                    bne       L0AC3
                    lda       #$BF
L0ADC               sta       >u00A8,u
                    puls      pc,x,b

L0AE2               tstb
                    lbne      L0287
                    cmpx      #$FFFF
                    lbeq      L0287
                    pshs      y,x,b,a
                    sta       >u00A7,u
                    lbsr      L0451
                    bcs       L0B37
                    lda       >u00A9,u
                    bmi       L0B63
                    cmpa      <PD.DRV,y
                    bne       L0B63
                    cmpx      #$0003
                    bls       L0B57
                    lda       #$FF
                    ldb       >u00A6,u
                    subb      #$04
                    leay      >u00B8,u
L0B15               cmpx      ,y
                    beq       L0B39
                    cmpa      $02,y
                    bls       L0B21
                    lda       $02,y
                    stb       ,s
L0B21               leay      $03,y
                    decb
                    bne       L0B15
                    ldb       >u00A6,u
                    subb      ,s
                    bsr       L0B7C
L0B2E               ldd       #$FFFF
                    std       ,y
L0B33               clr       $02,y
                    lda       #$01
L0B37               puls      pc,y,x,b,a

L0B39               sty       >u00AA,u
                    stb       ,s
                    ldb       >u00A6,u
                    subb      ,s
                    addb      >u00A5,u
                    stb       >u00A4,u
L0B4E               tst       >u00A7,u
                    bne       L0B2E
                    clra
                    puls      pc,y,x,b,a

L0B57               tfr       x,d
                    bsr       L0B7C
                    tst       $02,y
                    bne       L0B4E
                    bra       L0B33
L0B61               pshs      y,x,b,a
L0B63               lda       >u00A6,u
                    adda      >u00A5,u
                    sta       >u00A4,u
                    leay      >u0220,u
                    sty       >u00AA,u
                    clra
                    deca
                    puls      pc,y,x,b,a
L0B7C               tfr       b,a
                    adda      >u00A5,u
                    sta       >u00A4,u
                    lda       #$03
                    mul
                    leay      >u00AC,u
                    leay      d,y
                    sty       >u00AA,u
                    rts

L0B95               fdb       $0000

                    emod

eom                 equ       *

