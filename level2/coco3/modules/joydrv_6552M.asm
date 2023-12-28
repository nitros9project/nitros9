********************************************************************
* JoyDrv - Joystick Driver for 6551/Microsoft Mouse
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      1988/??/??
* L2 Upgrade distribution version.

                    nam       JoyDrv
                    ttl       Joystick Driver for 6552/Microsoft Mouse

* Disassembled 98/09/09 09:58:38 by Disasm v1.6 (C) 1988 by RML

MPI                 set       1

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       6

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       2
u0002               rmb       1
u0003               rmb       2
u0005               rmb       1
u0006               rmb       1
u0007               rmb       121
u0080               rmb       18
u0092               rmb       21
u00A7               rmb       65213
size                equ       .

name                fcs       /JoyDrv/
                    fcb       edition

start               lbra      Init
                    lbra      Term
                    lbra      SSMsBtn
                    lbra      SSMsXY
                    lbra      SSJoyBtn

SSJoyXY             pshs      x,b,a
                    ldx       #PIA0Base
                    lda       <$23,x
                    ldb       <$20,x
                    pshs      b,a
                    anda      #$F7
                    sta       <$23,x
                    lda       $01,x
                    ldb       $03,x
                    pshs      b,a
                    andb      #$F7
                    lsr       $04,s
                    bcs       L0043
                    orb       #$08
L0043               stb       $03,x
                    lda       ,s
                    ora       #$08
                    bsr       L0065
                    std       $06,s
                    lda       ,s
                    anda      #$F7
                    bsr       L0065
                    std       $04,s
                    puls      b,a
                    sta       $01,x
                    stb       $03,x
                    puls      b,a
                    stb       <$20,x
                    sta       <$23,x
                    puls      pc,y,x
L0065               sta       $01,x
                    lda       #$7F
                    ldb       #$40
                    bra       L0078
L006D               lsrb
                    cmpb      #$01
                    bhi       L0078
                    lsra
                    lsra
                    tfr       a,b
                    clra
                    rts
L0078               pshs      b
                    sta       <$20,x
                    tst       ,x
                    bpl       L0085
                    adda      ,s+
                    bra       L006D
L0085               suba      ,s+
                    bra       L006D
L0089               fcb       $00
L008A               fcb       $07,$01

Init                ldd       #$00007
L008F               sta       b,u
                    decb
                    bpl       L008F
                    ldd       >M$Mem,pcr
                    leax      >L0089,pcr
                    leay      >L0150,pcr
                    os9       F$IRQ
                    bcs       L00F5
                    tfr       d,x
                    ldd       #$46C0
                    pshs      cc
                    orcc      #IntMasks
                    sta       $01,x
                    stb       $01,x
                    clr       $02,x
                    lda       >PIA1Base+3
                    anda      #$FC
                    sta       >PIA1Base+3
                    lda       >PIA1Base+2
                    ldd       #$0187
                    ora       <u0092
                    sta       <u0092
                    sta       >IrqEnR
                    stb       ,x
                    ldb       $03,x
                    ldb       ,x
                    ldb       $03,x
                    ldb       ,x
                    andb      >L008A,pcr
                    bne       L00DF

                    ifeq      MPI-1
                    lda       #$03
                    sta       MPI.Slct
                    endc

                    puls      pc,cc

Term                pshs      cc
                    orcc      #IntMasks
L00DF               ldx       >M$Mem,pcr
                    lda       #$7F
                    sta       ,x
                    puls      cc
                    tfr       x,d
                    ldx       #$0000
                    leay      >L0150,pcr
                    os9       F$IRQ
L00F5               rts

SSJoyBtn            ldb       #$FF
                    ldx       #PIA0Base
                    stb       $02,x
                    ldb       ,x
                    comb
                    andb      #$0F
                    rts

SSMsBtn             lda       ,u
                    clrb
                    bita      #$20
                    beq       L010C
                    orb       #$03
L010C               bita      #$10
                    beq       L0112
                    orb       #$0C
L0112               tfr       b,a
                    anda      #$FA
                    pshs      a
                    andb      #$05
                    orb       u0007,u
                    leax      <L0132,pcr
                    lda       b,x
                    anda      #$0A
                    sta       u0007,u
                    ldb       b,x
                    andb      #$85
                    bpl       L012F
                    ldb       u0002,u
                    andb      #$C0
L012F               orb       ,s+
                    rts
L0132               fdb       $0003,$0003,$0806,$0206,$8002,$0002,$0806,$0a06

SSMsXY              pshs      cc
                    orcc      #IntMasks
                    ldx       u0003,u
                    ldd       u0005,u
                    lsra
                    rorb
                    tfr       d,y
                    puls      pc,cc
L0150               ldx       >M$Mem,pcr
                    bita      #$06
                    beq       L0162
                    ldb       $03,x
L015A               lda       u0002,u
                    anda      #$FC
L015E               sta       u0002,u
L0160               clrb
                    rts
L0162               bita      #$01
                    beq       L0160
                    ldb       $03,x
                    lda       u0002,u
                    anda      #$03
                    bne       L0178
                    bitb      #$40
                    beq       L0160
L0172               stb       a,u
                    inc       u0002,u
                    clrb
                    rts
L0178               bitb      #$40
                    bne       L015A
                    cmpa      #$02
                    bcs       L0172
                    ldx       #$017E
                    pshs      x
                    lda       ,u
                    lsra
                    lsra
                    leax      u0005,u
                    bsr       L01A7
                    ldd       ,u
                    ldx       #$027F
                    stx       ,s
                    leax      u0003,u
                    bsr       L01A7
                    leas      $02,s
                    lda       #$80
                    ldx       u0003,u
                    cmpx      #$0140
                    bcc       L015E
                    ora       #$C0
                    bra       L015E
L01A7               lslb
                    lslb
                    lsra
                    rorb
                    lsra
                    rorb
                    sex
                    pshs      b,a
                    bpl       L01B9
                    orb       #$07
                    addd      #$0001
                    bra       L01BB
L01B9               andb      #$F8
L01BB               asra
                    rorb
                    addd      ,s++
                    addd      ,x
                    bpl       L01C5
                    clra
                    clrb
L01C5               cmpd      $02,s
                    bls       L01CC
                    ldd       $02,s
L01CC               std       ,x
                    rts

                    emod
eom                 equ       *
                    end
