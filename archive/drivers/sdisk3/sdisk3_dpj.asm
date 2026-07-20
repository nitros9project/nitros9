*********************************************************************
*
*    Standard SDisk3 floppy disk controller driver from
*    DP Johnson
*
*********************************************************************

                    nam       SDisk3
                    ttl       os9 device driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       4
u0004               rmb       4
u0008               rmb       7
u000F               rmb       1
u0010               rmb       34
u0032               rmb       2
u0034               rmb       12
u0040               rmb       16
u0050               rmb       58
u008A               rmb       29
u00A7               rmb       2
u00A9               rmb       1
u00AA               rmb       1
u00AB               rmb       1
u00AC               rmb       1
u00AD               rmb       1
u00AE               rmb       2
u00B0               rmb       2
u00B2               rmb       1
u00B3               rmb       1
u00B4               rmb       1
u00B5               rmb       1
u00B6               rmb       1
u00B7               rmb       2
u00B9               rmb       2
u00BB               rmb       2
u00BD               rmb       2
u00BF               rmb       1
u00C0               rmb       1

u00D0               equ       $d0
u00FC               equ       $fc

size                equ       .
                    fcb       $FF                 driver mode byte

name                equ       *
                    fcs       /SDisk3/
                    fcb       $0F

                    fcc       /Copyright 1987 - D.P.Johnson/

L0031               fcb       $00,$01,$0a


start               lbra      INIT
                    lbra      READ
                    lbra      WRITE
                    lbra      GETSTA
                    lbra      SETSTA
* Terminate routine
* Entry: u=address of device memory area
                    ldx       #$0000              Disable our IRQ entry
                    os9       F$IRQ
                    bcs       TermExit            If error, exit
                    leay      >u00BB,u            Point to our VIRQ packet
                    os9       F$VIRQ              Disable our VIRQ entry
                    bcs       TermExit            If error, exit
                    tfr       u,x                 Move device memory pointer to x
                    ldu       >u00AE,u            Get address from our memory
                    ldd       #$0200              Return our 1st 512 byte buffer to the system
                    os9       F$SRtMem
                    ldu       >$00B7,x            Get address of our 2nd block of memory
                    beq       TermExit            If it wasn't used, exit
                    os9       F$SRtMem            Return that block too (extra for large sector size?)
TermExit            rts

* Init routine
* Entry: y=address of device descriptor
*        u=address of device memory

INIT                clra
                    sta       <D.MotOn            Clear out Floppy disk timeout counter
                    sta       >u00AC,u
                    ldd       #$012C
                    std       >u00B9,u
                    lbsr      L0180
                    lbsr      L046C
                    lda       >$FF48
                    lda       #$FF
                    ldb       #$04
                    leax      u000F,u
L0087               sta       $01,x
                    sta       <$15,x
                    leax      <$26,x
                    decb
                    bne       L0087
                    leax      >L026D,pcr
                    stx       <u00FC
                    pshs      y
                    leay      >u00BF,u
                    tfr       y,d
                    leay      >L0678,pcr
                    leax      >L0031,pcr
                    os9       F$IRQ
                    puls      y
                    bcs       L00C2
                    ldd       #$0200
                    pshs      u
                    os9       F$SRqMem
                    tfr       u,x
                    puls      u
                    bcs       L00C2
                    stx       >u00AE,u
                    clrb
L00C2               rts

READ                lbsr      L0171
                    clr       >u00B6,u
                    lda       #$92
                    cmpx      #$0000
                    bne       L0101
                    inc       >u00B6,u
                    bsr       L0101
                    bcs       L00C2
                    tst       >u00AC,u
                    beq       L00E3
                    clra
                    lbra      L0549
L00E3               ldx       $08,y
                    pshs      y,x
                    ldy       >u00A7,u
                    ldb       #$14
L00EE               lda       b,x
                    sta       b,y
                    decb
                    bpl       L00EE
                    clrb
                    puls      pc,y,x
L00F8               bcc       L0101
                    pshs      x,b,a
                    lbsr      L05FF
                    puls      x,b,a
L0101               pshs      x,b,a
                    bsr       L010C
                    puls      x,b,a
                    bcc       L00C2
                    lsra
                    bne       L00F8
L010C               lbsr      L02DB
                    bcs       L00C2
                    ldx       $08,y
                    ldb       #$80
                    pshs      y,cc
                    bsr       L018C
                    beq       L0140
L011B               bita      >$FF48
                    bne       L0136
                    leay      -$01,y
                    bne       L011B
L0124               bita      >$FF48
                    bne       L0136
                    leay      -$01,y
                    bne       L0124
                    leas      $02,s
L012F               bsr       L0180
                    puls      y,cc
                    lbra      L028C
L0136               lda       >$FF4B
                    sta       ,x+
                    stb       >$FF40
                    bra       L0136
L0140               leas      $02,s
                    lbsr      L046C
                    ldb       >u00B4,u
L0149               bita      >$FF48
                    bne       L0166
                    leay      -$01,y
                    bne       L0149
L0152               bita      >$FF48
                    bne       L0166
                    leay      -$01,y
                    bne       L0152
                    bra       L012F
L015D               lda       >$FF48
                    beq       L012F
                    bita      #$02
                    beq       L015D
L0166               lda       >$FF4B
                    sta       ,x+
                    decb
                    bne       L015D
                    lbra      L026F
L0171               pshs      b,a
                    ldd       #$0100
                    std       >u00B3,u
                    stb       >u00B2,u
                    puls      pc,b,a
L0180               lda       #$D0
                    sta       >$FF48
                    lbsr      L046C
                    lda       >$FF48
                    rts
L018C               orcc      #$50
                    ldy       #$0000
                    stb       >$FF48
                    mul
                    mul
                    mul
                    ldb       #$08
                    orb       >u00AB,u
                    stb       >$FF40
                    orb       #$80
                    lda       #$02
                    tst       >u00AA,u
                    jmp       [,s]

WRITE               bsr       L0171
L01AD               lda       #$91
L01AF               pshs      x,b,a
                    bsr       L01D1
                    puls      x,b,a
                    bcs       L01C3
                    tst       <$28,y
                    bne       L01C1
                    lbsr      L029D
                    bcs       L01C3
L01C1               clrb
L01C2               rts
L01C3               lsra
                    beq       L01F8
                    bcc       L01AF
                    pshs      x,b,a
                    lbsr      L05FF
                    puls      x,b,a
                    bra       L01AF
L01D1               lbsr      L02DB
                    bcs       L01C2
                    ldx       $08,y
                    ldb       #$A0
                    pshs      y,cc
                    bsr       L018C
                    beq       L0209
L01E0               bita      >$FF48
                    bne       L01FF
                    leay      -$01,y
                    bne       L01E0
L01E9               bita      >$FF48
                    bne       L01FF
                    leay      -$01,y
                    bne       L01E9
                    leas      $02,s
L01F4               bsr       L0180
                    puls      y,cc
L01F8               ldb       >$FF48
                    orb       #$20
                    bra       L0277
L01FF               stb       >$FF40
                    lda       ,x+
                    sta       >$FF4B
                    bra       L01FF
L0209               leas      $02,s
                    lbsr      L046C
                    ldb       >u00B4,u
L0212               bita      >$FF48
                    bne       L022F
                    leay      -$01,y
                    bne       L0212
L021B               bita      >$FF48
                    bne       L022F
                    leay      -$01,y
                    bne       L021B
                    bra       L01F4
L0226               lda       >$FF48
                    beq       L01F4
                    bita      #$02
                    beq       L0226
L022F               lda       ,x+
                    sta       >$FF4B
                    decb
                    bne       L0226
                    bra       L026F
L0239               pshs      y,cc
                    lbsr      L018C
                    bne       L01E0
                    leas      $02,s
                    lbsr      L046C
L0245               bita      >$FF48
                    bne       L0266
                    leay      -$01,y
                    bne       L0245
L024E               bita      >$FF48
                    bne       L0266
                    leay      -$01,y
                    bne       L024E
                    bra       L01F4
L0259               lda       >$FF48
                    bita      #$02
                    bne       L0266
                    bita      #$01
                    bne       L0259
                    bra       L026F
L0266               lda       ,x+
                    sta       >$FF4B
                    bra       L0259
L026D               leas      $0E,s
L026F               puls      y,cc
                    ldb       >$FF48
                    lbsr      L0180
L0277               leax      <L0290,pcr
L027A               tst       ,x
                    beq       L0286
                    bitb      ,x++
                    beq       L027A
                    ldb       ,-x
                    comb
                    rts

L0286               clrb
                    rts

                    comb
                    ldb       #$F5
                    rts

L028C               comb
                    ldb       #$F4
                    rts

L0290               suba      #$09
                    nega
                    tst       <u0010
                    lsl       <u0008
                    inc       <u0004
                    fcb       $0B,$20,$0a,$00
L029D               pshs      a,b,x
                    ldx       $8,y
                    pshs      x
                    ldx       >u00AE,u
L02A6               equ       *-1
                    stx       $08,y
                    ldx       $04,s
                    lbsr      L0101
                    puls      x
                    stx       $08,y
                    bcs       L02D9
                    ldd       >u00B3,u
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    pshs      u,y
                    ldy       >u00AE,u
                    tfr       x,u
L02C7               ldx       ,u
                    cmpx      ,y
                    bne       L02D6
                    leau      u0008,u
                    leay      $08,y
                    decb
                    bne       L02C7
                    bra       L02D7
L02D6               comb
L02D7               puls      u,y
L02D9               puls      pc,x,b,a

L02DB               clr       >u00AD,u
                    lbsr      L041A
                    tst       >u00B2,u
                    beq       L030A
                    ldx       PD.RGS,y
                    ldd       R$Y,x
                    bitb      #$01
                    beq       L02F4
                    com       >u00A9,u
L02F4               bitb      #$02
                    beq       L02FE
                    lda       #$20
                    sta       >u00AA,u
L02FE               ldd       R$U,x
                    stb       >$FF4A
                    ldx       >u00A7,u
                    lbra      L0391
L030A               tstb
                    bne       L031E
                    tfr       x,d
                    ldx       >u00A7,u
                    cmpd      #$0000
                    beq       L0360
                    cmpd      $01,x
                    bcs       L0322
L031E               comb
                    ldb       #$F1
                    rts

L0322               subd      <$2B,y
                    bcc       L032C
                    addd      <$2B,y
                    bra       L0360
L032C               clr       ,-s
                    pshs      b
                    ldb       <$10,x
                    lsrb
                    puls      b
                    bcc       L0347
L0338               com       >u00A9,u
                    bne       L0340
                    inc       ,s
L0340               subd      <$11,x
                    bcc       L0338
                    bra       L034E
L0347               inc       ,s
                    subd      <$11,x
                    bcc       L0347
L034E               lda       <$10,x
                    bita      #$02
                    beq       L035B
                    lda       #$20
                    sta       >u00AA,u
L035B               puls      a
                    addb      <$12,x
L0360               pshs      a
                    lda       <$23,y
                    bita      #$20
                    beq       L0371
                    lda       #$20
                    sta       >u00AA,u
                    lda       ,s
L0371               lda       <$32,y
                    anda      #$0F
                    pshs      a
                    lda       <$32,y
                    lsra
                    lsra
                    lsra
                    lsra
                    pshs      a
                    addb      ,s+
                    puls      a
                    adda      ,s+
                    stb       >$FF4A
L038A               ldb       <$10,x
                    stb       >u00B5,u
L0391               pshs      a
                    ldb       <$15,x
                    pshs      b
                    ldb       >u00B5,u
                    lsrb
                    bitb      #$02
                    beq       L03B3
                    tst       >u00B6,u
                    bne       L03D1
                    eorb      <$24,y
                    bitb      #$02
                    beq       L03BD
L03AE               comb
                    ldb       #$F9
                    puls      pc,x

L03B3               eorb      <$24,y
                    bitb      #$02
                    beq       L03BD
                    lsla
                    lsl       ,s
L03BD               tst       >u00B6,u
                    bne       L03D1
                    ldb       >u00B5,u
                    lsrb
                    bcc       L03D1
                    ldb       <$27,y
                    subb      #$02
                    bcs       L03AE
L03D1               puls      b
                    stb       >$FF49
                    tst       >u00AD,u
                    bne       L03E3
                    ldb       ,s
                    cmpb      <$15,x
                    beq       L03FE
L03E3               sta       <$15,x
                    sta       >$FF4B
                    ldb       #$1B
                    eorb      <$22,y
                    bsr       L0452
                    pshs      b,a
                    lda       #$1E
L03F4               ldb       #$B2
L03F6               decb
                    bne       L03F6
                    deca
                    bne       L03F4
                    puls      b,a
L03FE               puls      a
                    sta       <$15,x
                    sta       >$FF49
                    ldb       #$40
                    leax      >u00A9,u
                    andb      ,x
                    orb       $01,x
                    orb       $02,x
                    stb       $02,x
                    clrb
                    rts

L0416               fcb       $01
                    fcb       $02
                    lsr       <u0040
L041A               lbsr      L0627
                    lda       <$21,y
                    cmpa      #$04
                    bcs       L0428
                    comb
                    ldb       #$F0
L0427               rts

L0428               pshs      x,b,a
                    leax      <L0416,pcr
                    ldb       a,x
                    stb       >u00AB,u
                    leax      u000F,u
                    ldb       #$26
                    mul
                    leax      d,x
                    cmpx      >u00A7,u
                    beq       L0448
                    stx       >u00A7,u
                    com       >u00AD,u
L0448               clr       >u00A9,u
                    clr       >u00AA,u
                    puls      pc,x,b,a

L0452               bsr       L046A
L0454               ldb       >$FF48
                    bitb      #$01
                    beq       L0427
                    bra       L0454
L045D               lda       #$08
                    ora       >u00AB,u
                    sta       >$FF40
                    stb       >$FF48
                    rts

L046A               bsr       L045D
L046C               bsr       L046E
L046E               pshs      x,b,a
                    puls      pc,x,b,a

GETSTA              clr       >u00C0,u
                    ldx       PD.RGS,y
                    ldb       R$B,x
                    cmpb      #$84
                    beq       L0488
                    inc       >u00C0,u
                    cmpb      #$80
                    lbne      L053B
L0488               bsr       L04BC
                    lda       #$92
                    lbsr      L0101
                    pshs      b,cc
                    tst       >u00C0,u
                    lbeq      L0582
                    pshs      u,y
                    ldx       <u0050
                    lda       <u00D0
                    ldb       $06,x
                    ldx       PD.RGS,y
                    ldx       R$X,x
                    ldy       >u00B3,u
                    ldu       >u00B7,u
                    exg       x,u
                    os9       F$Move
                    puls      u,y
                    lbcc      L0582
                    leas      $02,s
                    rts

L04BC               ldd       $08,y
                    std       >u00B0,u
                    lda       #$01
                    sta       >u00B2,u
                    ldx       PD.RGS,y
                    ldd       R$X,x
                    tst       >u00C0,u
                    beq       L04EC
                    ldd       >u00B7,u
                    bne       L04EC
                    pshs      u
                    ldd       #$0200
                    os9       F$SRqMem
                    lbcs      L05F9
                    tfr       u,d
                    puls      u
                    std       >u00B7,u
L04EC               std       PD.BUF,y
                    ldx       PD.RGS,y
                    ldd       R$Y,x
                    andb      #$0F
                    stb       >u00B5,u
                    ldd       R$Y,x
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    exg       a,b
                    std       >u00B3,u
                    cmpa      #$02
                    bls       L050B
                    lbra      L03AE
L050B               rts

SETSTA              clr       >u00C0,u
                    ldx       PD.RGS,y
                    ldb       R$B,x               Get function
                    cmpb      #$84                System direct write
                    beq       L0558
                    inc       >u00C0,u
                    cmpb      #$80                Direct sector write
                    beq       L0558
                    cmpb      #$03
                    lbeq      L05FF
                    cmpb      #$04
                    beq       L058A
                    cmpb      #$0A
                    beq       L0547
                    clra
                    cmpb      #$81
                    beq       L0549
                    cmpb      #$82
                    beq       L054F
                    cmpb      #$83
                    beq       L053F
L053B               comb
                    ldb       #$D0
L053E               rts

L053F               ldd       R$X,x
                    std       >u00B9,u
                    clrb
                    rts

L0547               lda       #$FF
L0549               sta       >u00AC,u
                    clrb
L054E               rts

* Setstat : System direct write
L054F               ldd       #$0001
                    std       >u00BD,u
                    clrb
                    rts

* Setstat : direct sector write
L0558               lbsr      L04BC
                    tst       >u00C0,u
                    beq       L057D
                    pshs      u,y
                    ldb       <u00D0
                    ldx       <u0050
                    lda       P$Task,x
                    ldx       PD.RGS,y
                    ldx       R$X,x
                    ldy       >u00B3,u
                    ldu       >u00B7,u
                    os9       F$Move
                    puls      u,y
                    bcs       L054E
L057D               lbsr      L01AD
                    pshs      b,cc
L0582               ldd       >u00B0,u
                    std       PD.BUF,y
                    puls      pc,b,cc
L058A               lbsr      L041A
                    bcs       L053E
                    lda       R$U+1,x
                    ldb       R$Y+1,x
                    ldx       >u00A7,u
                    stb       <$10,x
                    bitb      #$01
                    beq       L05A2
                    com       >u00A9,u
L05A2               bitb      #$02
                    beq       L05AC
                    ldb       #$20
                    stb       >u00AA,u
L05AC               lbsr      L038A
                    bcs       L053E
                    pshs      u,y
                    ldd       #$1A00
                    os9       F$SRqMem
                    bcs       L05F9
                    ldx       <u0050
                    lda       P$Task,x
                    ldb       <u00D0
                    ldx       PD.RGS,y
                    ldx       R$X,x
                    ldy       #$1A00
                    os9       F$Move
                    tfr       u,x
                    puls      u,y
                    pshs      u,y
                    clrb
                    pshs      x,b
                    ldb       #$F0
                    lda       #$03
L05D9               pshs      x,b,a
                    lbsr      L0239
                    puls      x,b,a
                    bcc       L05E7
                    deca
                    bne       L05D9
                    inc       ,s
L05E7               tfr       x,u
                    ldd       #$1A00
                    os9       F$SRtMem
                    clrb
                    puls      u,y,x,b
                    tstb
                    beq       L05F8
                    comb
                    ldb       #$F5
L05F8               rts

L05F9               puls      u,y
                    comb
                    ldb       #$ED
L05FE               rts

L05FF               lbsr      L041A
                    bcs       L05FE
                    ldx       >u00A7,u
                    clr       <$15,x
                    lda       #$05
L060D               ldb       #$4B
                    pshs      a
                    eorb      <$22,y
                    lbsr      L0452
                    bcs       L0626
                    puls      a
                    deca
                    bne       L060D
                    ldb       #$0B
                    eorb      <$22,y
                    lbra      L0452
L0626               rts

L0627               pshs      y,x,b,a,cc
                    orcc      #$50
                    lda       <u0032
                    bmi       L0641
                    bne       L0649
                    andcc     #$AF
L0633               lda       #$08
                    sta       >$FF40
                    ldx       #$7530
L063B               mul
                    mul
                    leax      -$01,x
                    bne       L063B
L0641               bsr       L0663
                    bcc       L0649
                    ldb       #$80
                    stb       <u0032
L0649               bsr       L064D
                    puls      pc,y,x,b,a,cc

L064D               lda       #$80
                    sta       >u00BF,u
                    ldd       >u00B9,u
                    std       >u00BD,u
                    ldd       #$00B4
                    std       >u00BB,u
                    rts

L0663               bsr       L064D
                    pshs      b,a
                    lda       #$01
                    sta       <u0032
                    ldx       #$0001
                    puls      b,a
                    leay      >u00BB,u
                    os9       F$VIRQ
                    rts

L0678               ldb       <u008A
                    beq       L068A
                    tst       >u00BF,u
                    bpl       L0686
                    bsr       L064D
                    bra       L069E
L0686               bsr       L0663
                    bra       L069E
L068A               lda       #$08
                    sta       >$FF40
                    tst       >u00BF,u
                    bmi       L069A
                    stb       >$FF40
                    stb       <u0032
L069A               clr       >u00BF,u
L069E               clrb
                    rts
                    bvc       L0633
                    emod
eom                 equ       *
