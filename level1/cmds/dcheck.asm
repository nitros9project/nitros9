********************************************************************
* dcheck - Check Disk File Structure
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4   ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   5   2002/07/21  Boisy G. Pitre
* Changed /D0 references to /DD.
*
*       2003/03/31  JB
* Completly disasembly to be more readable.
*
*   6   2008/05/24  Gene Hesketti ed 6
* Cleaning up the universal use of long branches when not required
*
*   7   2008/05/30  Gene heskett  ed 7
* Trying to add a few comments and an optimization or 2.
*	2008/05/31 Gene heskett adding comments

                    nam       dcheck
                    ttl       Check Disk File Structure

* Disassembled 03/03/27 00:00:24 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       $07

                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       1                   num of cli args
u0001               rmb       1                   copy of num of cli args
u0002               rmb       2                   pointer to 1st cli arg?
u0004               rmb       2                   pointer to 2nd cli arg?
u0006               rmb       2                   pointer to 3rd cli arg?
u0008               rmb       2
u000A               rmb       1
u000B               rmb       1
u000C               rmb       2
u000E               rmb       2
u0010               rmb       6
u0016               rmb       1
u0017               rmb       1
u0018               rmb       3
u001B               rmb       5
u0020               rmb       1
u0021               rmb       1
u0022               rmb       1
u0023               rmb       1
u0024               rmb       1
u0025               rmb       1
u0026               rmb       4
u002A               rmb       2
u002C               rmb       1
u002D               rmb       1
u002E               rmb       1
u002F               rmb       2
u0031               rmb       18
u0043               rmb       18
u0055               rmb       15
u0064               rmb       15
u0073               rmb       138
u00FD               rmb       2693
size                equ       .


;---------------------------------------------
;
;---------------------------------------------
L0014               pshs      b,a
                    leas      <-$22,s
                    clr       <$1F,s
                    clrb
                    stb       <$1E,s
                    stb       <$1D,s
                    clrb
                    clra
                    std       <$30,y
                    std       <$2C,y
                    std       <$2A,y
                    std       <$28,y
                    std       <$26,y
                    ldd       #$0001
                    std       <$12,y
                    leax      >L13E2,pcr          '/DD'
                    pshs      x
                    leax      <$70,y
                    tfr       x,d
                    lbsr      L248E               saves long branch
                    leas      $02,s
                    leax      >L13E6,pcr          '/DD'
                    pshs      x
                    leax      >$00AC,y
                    tfr       x,d
                    lbsr      L248E               saves long branch
                    leas      $02,s
L005B               ldd       <$22,s
                    subd      #$0001
                    std       <$22,s
                    cmpd      #$0000
                    lble      L015F
                    ldx       <$26,s
                    leax      $02,x
                    stx       <$26,s
                    ldx       ,x
                    ldb       ,x
                    cmpb      #$2D
                    lbne      L015F
                    ldd       [<$26,s]
                    addd      #$0001
                    std       ,s
L0086               ldb       [,s]
                    beq       L005B
                    ldb       [,s]
                    clra
                    lbsr      L245B               saves long branch
                    stb       $02,s
                    cmpb      #$62
                    beq       L010F
                    cmpb      #$64
                    lbeq      L012F
                    cmpb      #$6D
                    beq       L0106
                    cmpb      #$6F
                    beq       L0127
                    cmpb      #$70
                    beq       L011F
                    cmpb      #$73
                    beq       L0117
                    cmpb      #$77
                    beq       L00BD
                    bra       L0136

L00BD               ldx       ,s
                    ldb       $01,x
                    cmpb      #$3D
                    bne       L00F1
                    ldx       ,s
                    ldb       $02,x
                    beq       L00F1
                    ldd       ,s
                    addd      #$0002
                    pshs      b,a
                    leax      <$70,y
                    tfr       x,d
                    lbsr      L248E               saves long branch
                    leas      $02,s
                    ldd       ,s
                    addd      #$0002
                    pshs      b,a
                    leax      >$00AC,y
                    tfr       x,d
                    lbsr      L248E               saves long branch
                    leas      $02,s
                    bra       L014D

L00F1               leax      >L13EA,pcr          -w= error msg
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $02,s
                    clrb
                    clra
                    lbsr      L1B2D               saves long branch
                    bra       L014D

L0106               ldd       #$0001
                    std       <$14,y
                    bra       L014D

L010F               clrb
                    clra
                    std       <$12,y
                    bra       L014D

L0117               ldd       #$0001
                    std       <$16,y
                    bra       L014D

L011F               ldd       #$0001
                    std       <$10,y
                    bra       L014D

L0127               lbsr      L0705
                    clrb
                    clra
                    lbsr      L1B2D               saves long branch
L012F               ldd       #$0001
                    std       $0E,y
                    bra       L014D

L0136               ldb       [,s]
                    clra
                    pshs      b,a
                    leax      >L1412,pcr          illegal option msg
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $04,s
                    clrb
                    clra
                    std       <$22,s
L014D               ldb       $02,s
                    cmpb      #$77
                    lbeq      L005B
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    lbra      L0086

L015F               ldd       <$22,s
                    cmpd      #$0001
                    beq       L0170
                    lbsr      L0705
                    clrb
                    clra
                    lbsr      L1B2D               saves long branch
L0170               ldd       <$16,y
                    beq       L017F
                    clrb
                    clra
                    std       $0E,y
                    std       <$14,y
                    std       <$10,y
L017F               ldd       #$000B
                    std       <$36,y
                    ldd       <$16,y
                    bne       L0193
                    ldd       <$36,y
                    subd      #$0001
                    std       <$36,y
L0193               ldd       <$10,y
                    beq       L01A1
                    ldd       <$36,y
                    subd      #$0001
                    std       <$36,y
L01A1               ldd       [<$26,s]
                    lbsr      L24AA               saves long branch
                    cmpd      #$0000
                    bne       L01BF
                    leax      >L142F,pcr          no device msg
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $02,s
                    clrb
                    clra
                    lbsr      L1B2D               saves long branch
L01BF               clrb
                    clra
                    std       <$19,s
                    std       <$17,s
                    ldd       [<$26,s]
                    ldx       <$17,s
                    ldb       d,x
                    cmpb      #$2F
                    beq       L01E7
                    ldd       <$19,s
                    addd      #$0001
                    std       <$19,s
                    subd      #$0001
                    leax      $03,s
                    leax      d,x
                    ldb       #$2F
                    stb       ,x
L01E7               ldd       <$17,s
                    addd      #$0001
                    std       <$17,s
                    subd      #$0001
                    ldx       [<$26,s]
                    ldb       d,x
                    stb       $02,s
                    tstb
                    beq       L0213
                    ldd       <$19,s
                    addd      #$0001
                    std       <$19,s
                    subd      #$0001
                    leax      $03,s
                    leax      d,x
                    ldb       $02,s
                    stb       ,x
                    bra       L01E7

L0213               ldd       <$19,s
                    leax      $02,s
                    ldb       d,x
                    cmpb      #$40
                    beq       L0238
                    ldd       <$19,s
                    std       <$20,s
                    ldd       <$19,s
                    addd      #$0001
                    std       <$19,s
                    subd      #$0001
                    leax      $03,s
                    leax      d,x
                    ldb       #$40
                    stb       ,x
L0238               ldd       <$19,s
                    addd      #$0001
                    std       <$19,s
                    subd      #$0001
                    leax      $03,s
                    leax      d,x
                    clr       ,x
                    ldd       #$0001
                    pshs      b,a
                    leax      $05,s
                    tfr       x,d
                    lbsr      L26BD               saves long branch
                    leas      $02,s
                    std       ,y
                    cmpd      #$FFFF
                    bne       L0276
                    leax      $03,s
                    pshs      x
                    leax      >L144C,pcr
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $04,s
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L0276               clrb
                    clra
                    pshs      b,a
                    pshs      b,a
                    pshs      b,a
                    ldd       ,y
                    lbsr      L276D               saves long branch
                    leas      $06,s
                    leax      >$0178,y
                    tfr       x,d
                    lbsr      L0749
                    leax      >$0178,y
                    ldb       $05,x
                    clra
                    pshs      b,a
                    leax      >$0178,y
                    ldb       $04,x
                    clra
                    tfr       b,a
                    clrb
                    addd      ,s++
                    std       $0A,y
                    ldd       $0A,y
                    tfr       a,b
                    clra
                    std       <$32,y
                    ldd       $0A,y
                    anda      #$00
                    andb      #$FF
                    std       <$34,y
                    leax      >$0178,y
                    ldb       $07,x
                    clra
                    pshs      b,a
                    leax      >$0178,y
                    ldb       $06,x
                    clra
                    tfr       b,a
                    clrb
                    addd      ,s++
                    std       $06,y
                    ldd       $06,y
                    addd      #$FFFF
                    std       $08,y
                    leax      >$0178,y
                    ldb       $02,x
                    clra
                    pshs      b,a
                    leax      >$0178,y
                    ldb       $01,x
                    clra
                    tfr       b,a
                    clrb
                    addd      ,s++
                    std       $0C,y
                    ldd       $0C,y
                    pshs      b,a
                    ldd       $06,y
                    lbsr      L2531
                    std       $0C,y
                    leax      >$0178,y
                    tfr       x,d
                    addd      #$001F
                    pshs      b,a
                    leax      <$4F,y
                    tfr       x,d
                    lbsr      L0B8D
                    leas      $02,s
                    clrb
                    clra
                    std       <$17,s
L0314               ldd       <$17,s
                    cmpd      #$0002
                    bgt       L033D
                    ldd       <$17,s
                    leax      <$4C,y
                    leax      d,x
                    pshs      x
                    ldd       <$19,s
                    leax      >$0178,y
                    ldb       d,x
                    stb       [,s++]
                    ldd       <$17,s
                    addd      #$0001
                    std       <$17,s
                    bra       L0314

L033D               ldd       <$20,s
                    leax      $03,s
                    leax      d,x
                    clr       ,x
                    ldd       <$16,y
                    lbne      L03D4
                    leax      $03,s
                    pshs      x
                    leax      <$4F,y
                    pshs      x
                    leax      >L1464,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $04,s
                    ldd       $0A,y
                    pshs      b,a
                    leax      >L1480,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
                    ldd       $06,y
                    cmpd      #$0001
                    bne       L0383
                    leax      >L149F,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    bra       L0392

L0383               ldd       $06,y
                    pshs      b,a
                    leax      >L14B5,pcr          msg if DD.BIT != 1
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
L0392               leax      <$38,y
                    pshs      x
                    leax      <$4C,y
                    tfr       x,d
                    lbsr      L0720
                    leas      $02,s
                    leax      <$38,y
                    pshs      x
                    leax      >L14CD,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
                    leax      <$38,y
                    pshs      x
                    leax      >$0178,y
                    tfr       x,d
                    addd      #$0008
                    lbsr      L0720
                    leas      $02,s
                    leax      <$38,y
                    pshs      x
                    leax      >L14E8,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
L03D4               leax      $03,s
                    tfr       x,d
                    lbsr      L25D1
                    cmpd      #$FFFF
                    bne       L03F3
                    leax      >L1511,pcr
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $02,s
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L03F3               ldd       <$16,y
                    bne       L0469
                    ldd       #$1000
                    lbsr      L22BB
                    std       >$0278,y
                    cmpd      #$0000
                    beq       L041F
                    ldd       <$10,y
                    beq       L0436
                    ldd       #$1000
                    lbsr      L22BB
                    std       >$027A,y
                    cmpd      #$0000
                    bne       L0436
L041F               ldd       #$0004
                    pshs      b,a
                    leax      >L1536,pcr
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $04,s
                    clrb
                    clra
                    lbsr      L1B2D               saves long branch
L0436               clrb
                    clra
                    pshs      b,a
                    leax      $02,y
                    pshs      x
                    leax      <$70,y
                    pshs      x
                    ldd       >$0278,y
                    lbsr      L10EB
                    leas      $06,s
                    ldd       <$10,y
                    beq       L0469
                    ldd       #$0001
                    pshs      b,a
                    leax      $04,y
                    pshs      x
                    leax      >$00AC,y
                    pshs      x
                    ldd       >$027A,y
                    lbsr      L10EB
                    leas      $06,s
L0469               leax      >$0178,y
                    ldb       $04,x
                    clra
                    addd      #$0002
                    std       <$1B,s
                    leax      >$0178,y
                    ldb       $05,x
                    beq       L0487
                    ldd       <$1B,s
                    addd      #$0001
                    std       <$1B,s
L0487               clrb
                    clra
                    pshs      b,a
                    ldd       #$0013
                    pshs      b,a
                    leax      >$0178,y
                    tfr       x,d
                    addd      #$0008
                    pshs      b,a
                    ldd       ,y
                    lbsr      L275C
                    leas      $06,s
                    ldd       #$0002
                    pshs      b,a
                    leax      <$19,s
                    pshs      x
                    ldd       ,y
                    lbsr      L26D4
                    leas      $04,s
                    cmpd      #$FFFF
                    bne       L04BE
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L04BE               ldd       <$1B,s
                    addd      <$17,s
                    std       <$1B,s
                    ldd       <$16,y
                    bne       L04DC
                    ldd       <$1B,s
                    pshs      b,a
                    leax      >L1568,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
L04DC               clrb
                    clra
                    std       <$2E,y
                    leax      $03,s
                    stx       >$0108,y
                    ldd       <$16,y
                    bne       L0510
                    ldd       <$1B,s
                    pshs      b,a
                    leax      <$1F,s
                    pshs      x
                    clrb
                    clra
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldd       >$0278,y
                    lbsr      L0BB1
                    leas      $08,s
                    leax      >L15A6,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L0510               leax      $03,s
                    tfr       x,d
                    lbsr      L0779
                    ldd       <$16,y
                    lbne      L05E8
                    leax      >L15CC,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    lbsr      L0FA3
                    ldd       <$10,y
                    beq       L054F
                    ldd       <$2A,y
                    bne       L0539
                    ldd       <$26,y
                    beq       L054F
L0539               ldd       #$0001
                    std       <$2E,y
                    leax      >L15ED,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leax      $03,s
                    tfr       x,d
                    lbsr      L0779
L054F               leax      >L1614,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    ldd       <$2A,y
                    beq       L0588
                    ldd       <$2A,y
                    pshs      b,a
                    leax      >L1616,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
                    ldd       <$2A,y
                    cmpd      #$0001
                    beq       L057F
                    leax      >L163D,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L057F               leax      >L163F,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L0588               ldd       <$26,y
                    beq       L05B8
                    ldd       <$26,y
                    pshs      b,a
                    leax      >L1641,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
                    ldd       <$26,y
                    cmpd      #$0001
                    beq       L05AF
                    leax      >L164C,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L05AF               leax      >L164E,pcr          in file, not map msg
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L05B8               ldd       <$28,y
                    beq       L05E8
                    ldd       <$28,y
                    pshs      b,a
                    leax      >L167C,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
                    ldd       <$28,y
                    cmpd      #$0001
                    beq       L05DF
                    leax      >L1687,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L05DF               leax      >L1689,pcr          in map, not file msg
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L05E8               ldd       <$2C,y
                    beq       L0618
                    ldd       <$2C,y
                    pshs      b,a
                    leax      >L16B7,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
                    ldd       <$2C,y
                    cmpd      #$0001
                    beq       L060F
                    leax      >L16D5,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L060F               leax      >L16D7,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L0618               ldd       <$16,y
                    bne       L064E
                    leax      <$4F,y
                    pshs      x
                    leax      >L16D9,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
                    ldd       <$2C,y
                    bne       L063C
                    ldd       <$2A,y
                    bne       L063C
                    ldd       <$26,y
                    beq       L0645
L063C               leax      >L16F2,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L0645               leax      >L16F7,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
L064E               ldd       <$24,y
                    cmpd      #$0001
                    bne       L0662
                    leax      >L16FF,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    bra       L0672

L0662               ldd       <$24,y
                    pshs      b,a
                    leax      >L170C,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
L0672               ldd       <$22,y
                    cmpd      #$0001
                    bne       L0686
                    leax      >L171C,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    bra       L0696

L0686               ldd       <$22,y
                    pshs      b,a
                    leax      >L1724,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
L0696               ldd       <$16,y
                    bne       L06FC
                    clrb
                    clra
                    pshs      b,a
                    ldd       #$FFFF
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldd       >$0278,y
                    lbsr      L1232
                    leas      $08,s
                    ldd       $02,y
                    lbsr      L26CA
                    ldd       <$14,y
                    bne       L06C9
                    leax      <$70,y
                    tfr       x,d
                    lbsr      L27A1
L06C9               ldd       <$10,y
                    beq       L06FC
                    clrb
                    clra
                    pshs      b,a
                    ldd       #$FFFF
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $04,y
                    pshs      b,a
                    ldd       >$027A,y
                    lbsr      L1232
                    leas      $08,s
                    ldd       $04,y
                    lbsr      L26CA
                    ldd       <$14,y
                    bne       L06FC
                    leax      >$00AC,y
                    tfr       x,d
                    lbsr      L27A1
L06FC               clrb
                    clra
                    lbsr      L1B2D               saves long branch
                    leas      <$24,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0705               leax      >L172E,pcr          usage msg
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $02,s
                    leax      >L1800,pcr
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $02,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0720               pshs      b,a
                    ldx       ,s
                    ldb       $02,x
                    clra
                    pshs      b,a
                    ldx       $02,s
                    ldb       $01,x               all out of order
                    clra                          too complex
                    tfr       b,a                 an lda would have worked fine
                    clrb
                    addd      ,s++
                    pshs      b,a
                    ldb       [<$02,s]
                    clra
                    pshs      b,a
                    leax      >L1834,pcr
                    pshs      x
                    ldd       $0A,s
                    lbsr      L1B48
                    leas      $08,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0749               pshs      b,a
                    ldd       #$0100
                    pshs      b,a
                    ldd       $02,s
                    pshs      b,a
                    ldd       ,y
                    lbsr      L26D4
                    leas      $04,s
                    cmpd      #$0100
                    beq       L0773
                    leax      >L183E,pcr
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $02,s
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L0773               ldd       #$0100
                    leas      $02,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0779               pshs      b,a
                    leas      <-$2A,s
                    ldd       <$18,y
                    cmpd      #$0027
                    blt       L079E
                    ldd       #$0027
                    pshs      b,a
                    leax      >L1858,pcr
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $04,s
                    clrb
                    clra
                    lbsr      L1B2D               saves long branch
L079E               ldd       <$18,y
                    addd      #$0001
                    std       <$18,y
                    ldd       $0E,y
                    beq       L07DD
                    ldd       #$0001
                    std       ,s
L07B0               ldd       <$18,y
                    addd      #$FFFF
                    cmpd      ,s
                    ble       L07CD
                    leax      >L1882,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    bra       L07B0
L07CD               ldd       <$2A,s
                    pshs      b,a
                    leax      >L1885,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
L07DD               ldd       <$2E,y
                    bne       L07EB
                    ldd       <$24,y
                    addd      #$0001
                    std       <$24,y
L07EB               ldd       <$2A,s
                    lbsr      L25D1
                    cmpd      #$FFFF
                    bne       L0811
                    ldd       <$2A,s
                    pshs      b,a
                    leax      >L1888,pcr
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $04,s
                    lbsr      L1338
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L0811               lbsr      L13A1
                    std       $04,s
                    ldd       <$36,y
                    subd      #$0001
                    std       <$36,y
                    ldd       #$0001
                    pshs      b,a
                    ldd       #$0040
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       $0A,s
                    lbsr      L276D               saves long branch
                    leas      $06,s
L0834               ldd       #$0020
                    pshs      b,a
                    leax      >$00E8,y
                    pshs      x
                    ldd       $08,s
                    lbsr      L26D4
                    leas      $04,s
                    std       ,s
                    cmpd      #$FFFF
                    lbeq      L0974
                    ldb       >$00E8,y
                    beq       L0834
                    ldd       <$22,y
                    addd      #$0001
                    std       <$22,y
                    leax      >$00E8,y
                    pshs      x
                    leax      >$0158,y
                    tfr       x,d
                    lbsr      L0B8D
                    leas      $02,s
                    ldd       $0E,y
                    beq       L0877
                    lbsr      L1338
L0877               ldd       <$16,y
                    bne       L08D0
                    ldd       <$2E,y
                    cmpd      #$0001
                    bne       L08AA
                    ldd       $06,y
                    pshs      b,a
                    leax      >$00E8,y
                    tfr       x,d
                    addd      #$001D
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $04,y
                    pshs      b,a
                    ldd       >$027A,y
                    lbsr      L0BB1
                    leas      $08,s
                    bra       L08D0

L08AA               ldd       $06,y
                    pshs      b,a
                    leax      >$00E8,y
                    tfr       x,d
                    addd      #$001D
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldd       >$0278,y
                    lbsr      L0BB1
                    leas      $08,s
                    std       -$02,s
                    lbne      L0834
L08D0               clrb
                    clra
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    leax      >$00E8,y
                    tfr       x,d
                    addd      #$001D
                    pshs      b,a
                    ldd       ,y
                    lbsr      L275C
                    leas      $06,s
                    leax      >$0178,y
                    tfr       x,d
                    lbsr      L0749
                    leax      >$0178,y
                    tfr       x,d
                    lbsr      L09AE
                    std       -$02,s
                    lbeq      L0834
                    leax      >$00E8,y
                    pshs      x
                    leax      $08,s
                    tfr       x,d
                    lbsr      L0B8D
                    leas      $02,s
                    ldd       <$18,y
                    lslb
                    rola
                    leax      >$0108,y
                    leax      d,x
                    leau      $06,s
                    stu       ,x
                    ldd       <$36,y
                    bne       L096A
                    leax      <$28,s
                    pshs      x
                    leax      <$28,s
                    pshs      x
                    ldd       $08,s
                    lbsr      L26A2
                    leas      $04,s
                    ldd       $04,s
                    lbsr      L26CA
                    ldd       <$36,y
                    addd      #$0001
                    std       <$36,y
                    leax      $06,s
                    tfr       x,d
                    lbsr      L0779
                    lbsr      L13A1
                    std       $04,s
                    clrb
                    clra
                    pshs      b,a
                    ldd       <$2A,s
                    pshs      b,a
                    ldd       <$2A,s
                    pshs      b,a
                    ldd       $0A,s
                    lbsr      L276D               saves long branch
                    leas      $06,s
                    lbra      L0834

L096A               leax      $06,s
                    tfr       x,d
                    lbsr      L0779
                    lbra      L0834
L0974               ldd       $04,s
                    lbsr      L26CA
                    cmpd      #$FFFF
                    bne       L0984
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L0984               ldd       <$36,y
                    addd      #$0001
                    std       <$36,y
                    leax      >L18A7,pcr
                    tfr       x,d
                    lbsr      L25D1
                    cmpd      #$FFFF
                    bne       L09A1
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L09A1               ldd       <$18,y
                    subd      #$0001
                    std       <$18,y
                    leas      <$2C,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L09AE               pshs      b,a
                    leas      -$07,s
                    clrb
                    clra
                    std       $02,s
                    ldd       #$0010
                    std       ,s
L09BB               ldd       $07,s
                    addd      ,s
                    ldx       #$0002
                    leax      d,x
                    ldb       ,x
                    tstb
                    bne       L09E5
                    ldd       $07,s
                    addd      ,s
                    ldx       #$0001
                    leax      d,x
                    ldb       ,x
                    tstb
                    bne       L09E5
                    ldd       $07,s
                    ldx       ,s
                    ldb       d,x
                    lbeq      L0A93
L09E5               ldd       ,s
                    cmpd      #$0100
                    lbge      L0A93
                    ldd       $07,s
                    addd      ,s
                    ldx       #$0004
                    leax      d,x
                    ldb       ,x
                    clra
                    pshs      b,a
                    ldd       $09,s
                    addd      $02,s
                    ldx       #$0003
                    leax      d,x
                    ldb       ,x
                    clra
                    tfr       b,a
                    clrb
                    addd      ,s++
                    pshs      b,a
                    leax      $06,s
                    pshs      x
                    ldd       $0B,s
                    addd      $04,s
                    lbsr      L266D
                    leas      $04,s
                    leax      <$4C,y
                    pshs      x
                    ldd       $09,s
                    addd      $02,s
                    lbsr      L2682
                    leas      $02,s
                    cmpd      #$0000
                    bgt       L0A49
                    leax      <$4C,y
                    pshs      x
                    leax      $06,s
                    tfr       x,d
                    lbsr      L2682
                    leas      $02,s
                    cmpd      #$0000
                    ble       L0A89
L0A49               ldd       <$2E,y
                    bne       L0A82
                    leax      <$38,y
                    pshs      x
                    ldd       $09,s
                    addd      $02,s
                    lbsr      L0720
                    leas      $02,s
                    leax      <$42,y
                    pshs      x
                    leax      $06,s
                    tfr       x,d
                    lbsr      L0720
                    leas      $02,s
                    leax      <$42,y
                    pshs      x
                    leax      <$38,y
                    pshs      x
                    leax      >L18AA,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $04,s
                    lbsr      L1338
L0A82               ldd       #$FFFF
                    std       $02,s
                    bra       L0A93

L0A89               ldd       ,s
                    addd      #$0005
                    std       ,s
                    lbra      L09BB

L0A93               ldd       $02,s
                    beq       L0AAA
                    ldd       <$2E,y
                    bne       L0AA5
                    ldd       <$2C,y
                    addd      #$0001
                    std       <$2C,y
L0AA5               clrb
                    clra
                    leas      $09,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0AAA               ldd       <$16,y
                    lbne      L0B75
                    ldd       #$0010
                    std       ,s
L0AB6               ldd       $07,s
                    addd      ,s
                    ldx       #$0002
                    leax      d,x
                    ldb       ,x
                    tstb
                    bne       L0AE0
                    ldd       $07,s
                    addd      ,s
                    ldx       #$0001
                    leax      d,x
                    ldb       ,x
                    tstb
                    bne       L0AE0
                    ldd       $07,s
                    ldx       ,s
                    ldb       d,x
                    lbeq      L0B75
L0AE0               ldd       ,s
                    cmpd      #$0100
                    lbge      L0B75
                    ldd       <$2E,y
                    bne       L0B32
                    ldd       $07,s
                    addd      ,s
                    ldx       #$0004
                    leax      d,x
                    ldb       ,x
                    clra
                    pshs      b,a
                    ldd       $09,s
                    addd      $02,s
                    ldx       #$0003
                    leax      d,x
                    ldb       ,x
                    clra
                    tfr       b,a
                    clrb
                    addd      ,s++
                    pshs      b,a
                    ldd       $09,s
                    addd      $02,s
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldd       >$0278,y
                    lbsr      L0BB1
                    leas      $08,s
                    std       -$02,s
                    beq       L0B6B
                    ldd       #$FFFF
                    std       $02,s
                    bra       L0B6B

L0B32               ldd       $07,s
                    addd      ,s
                    ldx       #$0004
                    leax      d,x
                    ldb       ,x
                    clra
                    pshs      b,a
                    ldd       $09,s
                    addd      $02,s
                    ldx       #$0003
                    leax      d,x
                    ldb       ,x
                    clra
                    tfr       b,a
                    clrb
                    addd      ,s++
                    pshs      b,a
                    ldd       $09,s
                    addd      $02,s
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $04,y
                    pshs      b,a
                    ldd       >$027A,y
                    bsr       L0BB1
                    leas      $08,s
L0B6B               ldd       ,s
                    addd      #$0005
                    std       ,s
                    lbra      L0AB6

L0B75               ldd       $02,s
                    beq       L0B7E
                    clrb
                    clra
                    leas      $09,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0B7E               ldb       [<$07,s]
                    andb      #$80
                    subb      #$00
                    beq       L0B89
                    ldb       #$01
L0B89               clra
                    leas      $09,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0B8D               pshs      b,a
L0B8F               ldx       $04,s
                    ldb       ,x+
                    stx       $04,s
                    ldx       ,s
                    stb       ,x+
                    stx       ,s
                    cmpb      #$80
                    bcs       L0B8F
                    clr       [,s]
                    ldd       ,s
                    subd      #$0001
                    std       ,s
                    ldb       [,s]
                    andb      #$7F
                    stb       [,s]
                    leas      $02,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0BB1               pshs      b,a
                    leas      <-$1C,s
                    ldd       <$26,s
                    anda      $08,y
                    andb      $09,y
                    std       -$02,s
                    beq       L0BDB
                    ldd       $08,y
                    pshs      b,a
                    leax      $0C,s
                    pshs      x
                    ldd       <$28,s
                    lbsr      L266D
                    leas      $04,s
                    ldd       <$26,s
                    subd      $08,y
                    std       <$26,s
                    bra       L0BEB

L0BDB               clrb
                    clra
                    pshs      b,a
                    leax      $0C,s
                    pshs      x
                    ldd       <$28,s
                    lbsr      L266D
                    leas      $04,s
L0BEB               leax      ,s
                    pshs      x
                    leax      $0C,s
                    tfr       x,d
                    lbsr      L0720
                    leas      $02,s
                    leax      <$11,s
                    pshs      x
                    leax      <$11,s
                    pshs      x
                    leax      <$11,s
                    pshs      x
                    ldd       $06,y
                    pshs      b,a
                    leax      <$2E,s
                    pshs      x
                    leax      <$14,s
                    tfr       x,d
                    lbsr      L25E3
                    leas      $0A,s
                    ldd       $0E,y
                    beq       L0C59
                    leax      ,s
                    pshs      x
                    leax      $0C,s
                    tfr       x,d
                    lbsr      L0720
                    leas      $02,s
                    ldd       <$26,s
                    pshs      b,a
                    leax      $02,s
                    pshs      x
                    leax      >L18D0,pcr          I've never seen this string printed
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $04,s
                    ldd       <$11,s
                    pshs      b,a
                    ldd       <$11,s
                    pshs      b,a
                    ldd       <$11,s
                    pshs      b,a
                    leax      >L18F2,pcr          sector, byte, bit printout, never seen it either
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $06,s
L0C59               ldd       $0F,s
                    pshs      b,a
                    ldd       $0F,s
                    pshs      b,a
                    ldd       <$26,s
                    pshs      b,a
                    ldd       <$26,s
                    pshs      b,a
                    ldd       <$24,s
                    lbsr      L1232
                    leas      $08,s
                    std       -$02,s
                    beq       L0C7E
                    ldd       #$FFFF
                    leas      <$1E,s
                    rts


;---------------------------------------------
;
;---------------------------------------------
L0C7E               ldd       #$0080
                    ldx       <$11,s
                    beq       L0C8C
L0C86               asra
                    rorb
                    leax      -$01,x
                    bne       L0C86
L0C8C               stb       <$1B,s
                    ldb       <$1B,s
                    cmpb      #$80
                    lbeq      L0D31
L0C98               ldb       <$1B,s
                    beq       L0D17
                    ldd       <$26,s
                    beq       L0D17
                    ldd       <$22,s
                    lslb
                    rola
                    leax      <$1E,y
                    ldb       [d,x]
                    andb      <$1B,s
                    tstb
                    beq       L0CD8
                    ldd       #$0031
                    pshs      b,a
                    ldd       <$24,s
                    lslb
                    rola
                    leax      <$1E,y
                    ldb       [d,x]
                    andb      <$1D,s
                    clra
                    pshs      b,a
                    ldd       <$13,s
                    pshs      b,a
                    ldd       <$13,s
                    lbsr      L0E86
                    leas      $06,s
L0CD8               ldd       <$2E,y
                    bne       L0CFA
                    ldd       <$22,s
                    lslb
                    rola
                    leax      <$1E,y
                    leax      d,x
                    pshs      x
                    ldd       <$24,s
                    lslb
                    rola
                    leax      <$1E,y
                    ldb       [d,x]
                    orb       <$1D,s
                    ldx       [,s++]
                    stb       ,x
L0CFA               ldb       <$1B,s
                    lda       #$01
                    beq       L0D05
L0D01               lsrb
                    deca
                    bne       L0D01
L0D05               stb       <$1B,s
                    ldd       <$26,s
                    subd      #$0001
                    std       <$26,s
                    addd      #$0001
                    bra       L0C98

L0D17               ldd       $0F,s
                    addd      #$0001
                    std       $0F,s
                    ldd       <$22,s
                    lslb
                    rola
                    leax      <$1E,y
                    leax      d,x
                    tfr       x,u
                    ldd       ,u
                    addd      #$0001
                    std       ,u
L0D31               ldd       <$26,s
                    cmpd      #$0008
                    lbcs      L0DD7
                    ldd       $0F,s
                    cmpd      #$00FF
                    ble       L0D72
                    clrb
                    clra
                    std       $0F,s
                    ldd       $0F,s
                    pshs      b,a
                    ldd       $0F,s
                    addd      #$0001
                    std       $0F,s
                    pshs      b,a
                    ldd       <$26,s
                    pshs      b,a
                    ldd       <$26,s
                    pshs      b,a
                    ldd       <$24,s
                    lbsr      L1232
                    leas      $08,s
                    std       -$02,s
                    beq       L0D72
                    ldd       #$FFFF
                    leas      <$1E,s
                    rts


;---------------------------------------------
;
;---------------------------------------------
L0D72               ldd       <$22,s
                    lslb
                    rola
                    leax      <$1E,y
                    ldb       [d,x]
                    tstb
                    beq       L0D9E
                    ldd       #$0031
                    pshs      b,a
                    ldd       <$24,s
                    lslb
                    rola
                    leax      <$1E,y
                    ldb       [d,x]
                    clra
                    pshs      b,a
                    ldd       <$13,s
                    pshs      b,a
                    ldd       <$13,s
                    lbsr      L0E86
                    leas      $06,s
L0D9E               ldd       <$2E,y
                    bne       L0DB1
                    ldd       <$22,s
                    lslb
                    rola
                    leax      <$1E,y
                    leax      d,x
                    ldb       #$FF
                    stb       [,x]
L0DB1               ldd       <$22,s
                    lslb
                    rola
                    leax      <$1E,y
                    leax      d,x
                    tfr       x,u
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    ldd       $0F,s
                    addd      #$0001
                    std       $0F,s
                    ldd       <$26,s
                    subd      #$0008
                    std       <$26,s
                    lbra      L0D31

L0DD7               ldd       <$26,s
                    lbeq      L0E80
                    ldd       #$0008
                    subd      <$26,s
                    pshs      b,a
                    ldd       #$00FF
                    ldx       ,s++
                    beq       L0DF3
L0DED               lslb
                    rola
                    leax      -$01,x
                    bne       L0DED
L0DF3               stb       <$1B,s
                    ldd       $0F,s
                    cmpd      #$00FF
                    ble       L0E2C
                    clrb
                    clra
                    std       $0F,s
                    ldd       $0F,s
                    pshs      b,a
                    ldd       $0F,s
                    addd      #$0001
                    std       $0F,s
                    pshs      b,a
                    ldd       <$26,s
                    pshs      b,a
                    ldd       <$26,s
                    pshs      b,a
                    ldd       <$24,s
                    lbsr      L1232
                    leas      $08,s
                    std       -$02,s
                    beq       L0E2C
                    ldd       #$FFFF
                    leas      <$1E,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0E2C               ldd       <$22,s
                    lslb
                    rola
                    leax      <$1E,y
                    ldb       [d,x]
                    andb      <$1B,s
                    tstb
                    beq       L0E5E
                    ldd       #$0031
                    pshs      b,a
                    ldd       <$24,s
                    lslb
                    rola
                    leax      <$1E,y
                    ldb       [d,x]
                    andb      <$1D,s
                    clra
                    pshs      b,a
                    ldd       <$13,s
                    pshs      b,a
                    ldd       <$13,s
                    bsr       L0E86
                    leas      $06,s
L0E5E               ldd       <$2E,y
                    bne       L0E80
                    ldd       <$22,s
                    lslb
                    rola
                    leax      <$1E,y
                    leax      d,x
                    pshs      x
                    ldd       <$24,s
                    lslb
                    rola
                    leax      <$1E,y
                    ldb       [d,x]
                    orb       <$1D,s
                    ldx       [,s++]
                    stb       ,x
L0E80               clrb
                    clra
                    leas      <$1E,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0E86               pshs      b,a
                    leas      -$08,s
                    ldb       $0F,s
                    stb       $04,s
                    clrb
                    clra
                    std       ,s
L0E92               ldb       $04,s
                    lbeq      L0FA0
                    ldb       $04,s
                    andb      #$80
                    tstb
                    lbeq      L0F8A
                    ldd       ,s
                    pshs      b,a
                    ldd       $0E,s
                    pshs      b,a
                    ldd       $0C,s
                    pshs      b,a
                    ldd       $06,y
                    pshs      b,a
                    leax      $0D,s
                    tfr       x,d
                    lbsr      L2634
                    leas      $08,s
                    leax      <$38,y
                    pshs      x
                    leax      $07,s
                    tfr       x,d
                    lbsr      L0720
                    leas      $02,s
                    ldd       <$2E,y
                    bne       L0F41
                    ldd       <$10,s
                    cmpd      #$0031
                    bne       L0EF4
                    leax      <$38,y
                    pshs      x
                    leax      >L1916,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
                    ldd       <$2A,y
                    addd      #$0001
                    std       <$2A,y
                    bra       L0F51

L0EF4               ldd       <$10,s
                    cmpd      #$0032
                    bne       L0F18
                    leax      <$38,y
                    pshs      x
                    leax      >L193B,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
                    ldd       <$26,y
                    addd      #$0001
                    std       <$26,y
                    bra       L0F51

L0F18               ldd       <$10,s
                    cmpd      #$0033
                    bne       L0F51
                    ldd       <$12,y
                    beq       L0F36
                    leax      <$38,y
                    pshs      x
                    leax      >L1973,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
L0F36               ldd       <$28,y
                    addd      #$0001
                    std       <$28,y
                    bra       L0F51

L0F41               leax      <$38,y
                    pshs      x
                    leax      >L19AB,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
L0F51               ldd       <$10,y
                    beq       L0F8A
                    ldd       <$2E,y
                    bne       L0F87
                    ldd       <$30,y
                    bne       L0F8A
                    ldd       #$0001
                    std       <$30,y
                    ldd       $06,y
                    pshs      b,a
                    leax      $07,s
                    pshs      x
                    ldd       #$0001
                    pshs      b,a
                    ldd       $04,y
                    pshs      b,a
                    ldd       >$027A,y
                    lbsr      L0BB1
                    leas      $08,s
                    clrb
                    clra
                    std       <$30,y
                    bra       L0F8A

L0F87               lbsr      L1338
L0F8A               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldb       $04,s
                    lda       #$01
                    beq       L0F9B
L0F97               lslb
                    deca
                    bne       L0F97
L0F9B               stb       $04,s
                    lbra      L0E92

L0FA0               leas      $0A,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L0FA3               leas      -$0A,s
                    clrb
                    clra
                    pshs      b,a
                    ldd       #$0100
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       ,y
                    lbsr      L276D               saves long branch
                    leas      $06,s
                    clrb
                    clra
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldd       >$0278,y
                    lbsr      L1232
                    leas      $08,s
                    leax      >$0178,y
                    tfr       x,d
                    lbsr      L0749
                    clrb
                    clra
                    std       $04,s
                    std       $06,s
                    clrb
                    clra
                    std       ,s
L0FE5               ldd       ,s
                    cmpd      $0A,y
                    lbcc      L10E8
                    ldd       $06,s
                    leax      >$0178,y
                    ldb       d,x
                    eorb      [<$1E,y]
                    stb       $08,s
                    tstb
                    lbeq      L108D
                    ldd       ,s
                    addd      #$0001
                    cmpd      $0A,y
                    bne       L102E
                    ldd       $0C,y
                    anda      #$00
                    andb      #$07
                    pshs      b,a
                    ldd       #$0008
                    subd      ,s++
                    pshs      b,a
                    ldd       #$00FF
                    ldx       ,s++
                    beq       L1026
L1020               lslb
                    rola
                    leax      -$01,x
                    bne       L1020
L1026               pshs      b
                    ldb       $09,s
                    andb      ,s+
                    stb       $08,s
L102E               ldd       $06,s
                    leax      >$0178,y
                    ldb       d,x
                    andb      $08,s
                    stb       $09,s
                    tstb
                    beq       L1060
                    ldd       #$0033
                    pshs      b,a
                    ldb       $0B,s
                    clra
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    ldd       #$0100
                    lbsr      L2509
                    pshs      b,a
                    ldd       $0A,s
                    tfr       a,b
                    sex
                    addd      <$1A,y
                    lbsr      L0E86
                    leas      $06,s
L1060               ldb       $08,s
                    andb      [<$1E,y]
                    stb       $09,s
                    tstb
                    beq       L108D
                    ldd       #$0032
                    pshs      b,a
                    ldb       $0B,s
                    clra
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    ldd       #$0100
                    lbsr      L2509
                    pshs      b,a
                    ldd       $0A,s
                    tfr       a,b
                    sex
                    addd      <$1A,y
                    lbsr      L0E86
                    leas      $06,s
L108D               ldd       <$1E,y
                    addd      #$0001
                    std       <$1E,y
                    ldd       $04,s
                    addd      #$0001
                    std       $04,s
                    cmpd      #$1000
                    blt       L10C4
                    clrb
                    clra
                    std       $04,s
                    ldd       $04,s
                    pshs      b,a
                    ldd       <$1A,y
                    addd      #$0010
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldd       >$0278,y
                    lbsr      L1232
                    leas      $08,s
L10C4               ldd       $06,s
                    addd      #$0001
                    std       $06,s
                    cmpd      #$0100
                    blt       L10DE
                    clrb
                    clra
                    std       $06,s
                    leax      >$0178,y
                    tfr       x,d
                    lbsr      L0749
L10DE               ldd       ,s
                    addd      #$0001
                    std       ,s
                    lbra      L0FE5
L10E8               leas      $0A,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L10EB               pshs      b,a
                    leas      <-$18,s
                    ldd       <$20,s
                    pshs      b,a
                    lbsr      L27AE
                    pshs      b,a
                    leax      >L19C0,pcr
                    pshs      x
                    leax      $0A,s
                    tfr       x,d
                    lbsr      L1B48
                    leas      $06,s
                    leax      $04,s
                    pshs      x
                    ldd       <$1E,s
                    lbsr      L1378
                    leas      $02,s
                    ldb       [<$1C,s]
                    cmpb      #$2F
                    bne       L1132
                    ldd       #$0003
                    pshs      b,a
                    ldd       <$1E,s
                    lbsr      L272F
                    leas      $02,s
                    std       [<$1E,s]
                    cmpd      #$FFFF
                    bne       L1149
L1132               ldd       <$1C,s
                    pshs      b,a
                    leax      >L19CE,pcr
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $04,s
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L1149               clrb
                    clra
                    std       ,s
L114D               ldd       ,s
                    cmpd      #$1000
                    bge       L1168
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    ldx       <$18,s
                    leax      d,x
                    clr       ,x
                    bra       L114D

L1168               ldd       $0A,y
                    tfr       a,b
                    clra
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       $02,s
                    ldd       $0A,y
                    pshs      b,a
                    ldd       #$1000
                    lbsr      L2515
                    std       -$02,s
                    beq       L118C
                    ldd       $02,s
                    addd      #$0001
                    std       $02,s
L118C               clrb
                    clra
                    pshs      b,a
                    ldd       $04,s
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    tfr       b,a
                    clrb
                    addd      #$FFFF
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       [<$24,s]
                    lbsr      L276D               saves long branch
                    leas      $06,s
                    ldd       #$0001
                    pshs      b,a
                    ldd       <$1A,s
                    pshs      b,a
                    ldd       [<$22,s]
                    lbsr      L26E9
                    leas      $04,s
                    cmpd      #$FFFF
                    bne       L11CB
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L11CB               clrb
                    clra
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       [<$24,s]
                    lbsr      L276D               saves long branch
                    leas      $06,s
                    ldd       #$0001
                    std       ,s
L11E4               ldd       ,s
                    cmpd      $02,s
                    bgt       L1211
                    ldd       #$1000
                    pshs      b,a
                    ldd       <$1A,s
                    pshs      b,a
                    ldd       [<$22,s]
                    lbsr      L26E9
                    leas      $04,s
                    cmpd      #$FFFF
                    bne       L1208
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L1208               ldd       ,s
                    addd      #$0001
                    std       ,s
                    bra       L11E4
L1211               ldd       <$20,s
                    lslb
                    rola
                    leax      <$1A,y
                    leax      d,x
                    clrb
                    clra
                    std       ,x
                    ldd       <$20,s
                    lslb
                    rola
                    leax      <$1E,y
                    leax      d,x
                    ldd       <$18,s
                    std       ,x
                    leas      <$1A,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L1232               pshs      b,a
                    ldd       $08,s
                    cmpd      <$32,y
                    blt       L125B
                    ldd       $0A,s
                    cmpd      <$34,y
                    blt       L125B
                    ldd       <$2E,y
                    bne       L1255
                    leax      >L19F1,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    lbsr      L1338
L1255               ldd       #$FFFF
                    leas      $02,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L125B               ldd       $06,s
                    lslb
                    rola
                    leax      <$1A,y
                    ldd       d,x
                    cmpd      $08,s
                    bgt       L127E
                    ldd       $06,s
                    lslb
                    rola
                    leax      <$1A,y
                    ldd       d,x
                    addd      #$000F
                    cmpd      $08,s
                    lbge      L1315
L127E               clrb
                    clra
                    pshs      b,a
                    ldd       $08,s
                    lslb
                    rola
                    leax      <$1A,y
                    ldd       d,x
                    tfr       b,a
                    clrb
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       $0A,s
                    lbsr      L276D               saves long branch
                    leas      $06,s
                    ldd       #$1000
                    pshs      b,a
                    ldd       $02,s
                    pshs      b,a
                    ldd       $08,s
                    lbsr      L26E9
                    leas      $04,s
                    cmpd      #$FFFF
                    bne       L12B6
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L12B6               ldd       $06,s
                    lslb
                    rola
                    leax      <$1A,y
                    leax      d,x
                    pshs      x
                    ldd       $0A,s
                    andb      #$F0
                    std       [,s++]
                    ldd       $08,s
                    cmpd      #$FFFF
                    beq       L1315
                    clrb
                    clra
                    pshs      b,a
                    ldd       $08,s
                    lslb
                    rola
                    leax      <$1A,y
                    ldd       d,x
                    tfr       b,a
                    clrb
                    pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       $0A,s
                    lbsr      L276D               saves long branch
                    leas      $06,s
                    ldd       #$1000
                    pshs      b,a
                    ldd       $02,s
                    pshs      b,a
                    ldd       $08,s
                    lbsr      L26D4
                    leas      $04,s
                    cmpd      #$FFFF
                    bne       L1315
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L1315               ldd       $06,s
                    lslb
                    rola
                    leax      <$1E,y
                    leax      d,x
                    pshs      x
                    ldd       $0A,s
                    pshs      b,a
                    ldd       #$0010
                    lbsr      L2509
                    tfr       b,a
                    clrb
                    addd      $02,s
                    addd      $0C,s
                    std       [,s++]
                    clrb
                    clra
                    leas      $02,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L1338               leas      -$02,s
                    clrb
                    clra
                    std       ,s
L133E               ldd       ,s
                    cmpd      <$18,y
                    bge       L1366
                    ldd       ,s
                    lslb
                    rola
                    leax      >$0108,y
                    ldd       d,x
                    pshs      b,a
                    leax      >L1A14,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $02,s
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    bra       L133E
L1366               leax      >$0158,y
                    pshs      x
                    leax      >L1A18,pcr
                    tfr       x,d
                    lbsr      L1B94               saves long branch
                    leas      $04,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L1378               pshs      b,a
                    leas      -$04,s
L137C               ldx       $04,s
                    ldb       ,x+
                    stx       $04,s
                    tstb
                    bne       L137C
                    ldd       $04,s
                    subd      #$0001
                    std       $04,s
L138C               ldb       [<$08,s]
                    ldx       $04,s
                    stb       ,x+
                    stx       $04,s
                    ldx       $08,s
                    ldb       ,x+
                    stx       $08,s
                    tstb
                    bne       L138C
                    leas      $06,s
                    rts

;---------------------------------------------
;
;---------------------------------------------
L13A1               leas      -$02,s
                    ldd       #$0081
                    pshs      b,a
                    leax      >L1A1C,pcr
                    tfr       x,d
                    lbsr      L26BD               saves long branch
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L13DD
                    leax      >L1A1E,pcr
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $02,s
                    leax      >L1A41,pcr
                    pshs      x
                    ldd       <u000E
                    lbsr      L1B5F
                    leas      $02,s
                    lbsr      L1338
                    ldd       <u0002
                    lbsr      L1B2D               saves long branch
L13DD               ldd       ,s
                    leas      $02,s
                    rts

;--------------------------------------------------------------
;                    STRINGS DEFINITION
;--------------------------------------------------------------

L13E2               fcc       "/DD"
                    fcb       0
L13E6               fcc       "/DD"
                    fcb       0
L13EA               fcc       "dcheck: -w= requires pathlist argument"
                    fcb       $0a,$00
L1412               fcc       "dcheck: illegal option '%c'"
                    fcb       $0a,$00
L142F               fcc       "dcheck: no device specified"
                    fcb       $0a,$00
L144C               fcc       "dcheck: cannot open %s"
                    fcb       $0a,$00
L1464               fcc       "Volume - '%s' on device %s"
                    fcb       $0a,$00
L1480               fcc       "$%04x bytes in allocation map"
                    fcb       $0a,$00
L149F               fcc       "1 sector per cluster"
                    fcb       $0a,$00
L14B5               fcc       "%d sectors per cluster"
                    fcb       $0a,$00
L14CD               fcc       "%s total sectors on media"
                    fcb       $0a,$00
L14E8               fcc       "Sector %s is start of root directory FD"
                    fcb       $0a,$00
L1511               fcc       "dcheck: cannot chd to root directory"
                    fcb       $00
L1536               fcc       "No memory available for bitmap buffer (%dK req.)"
                    fcb       $0a,$00
L1568               fcc       "$%04x sectors used for id, allocation map and root directory"
                    fcb       $0a,$00
L15A6               fcc       "Building allocation map work file..."
                    fcb       $0a,$00
L15CC               fcc       "Checking allocation map file..."
                    fcb       $0a,$00
L15ED               fcb       $0a
L15EE               fcc       "Pathlists for questionable clusters:"
                    fcb       $0a,$00
L1614               fcb       $0a,$00
L1616               fcc       "%d previously allocated clusters found"
                    fcb       $00
L163D               fcc       's'
                    fcb       $00
L163F               fcb       $0a,$00
L1641               fcc       "%d cluster"
                    fcb       $00
L164C               fcb       $73,$00
L164E               fcc       " in file structure but not in allocation map"
                    fcb       $0a,$00
L167C               fcc       "%d cluster"
                    fcb       $00
L1687               fcb       $73,$00
L1689               fcc       " in allocation map but not in file structure"
L16B5               fcb       $0A,00
L16B7               fcc       "%d bad file descriptor sector"
                    fcb       $00
L16D5               fcb       $73,$00
L16D7               fcb       $0a,$00
L16D9               fcb       $0a
L16DA               fcc       "'%s' file structure is "
                    fcb       0
L16F2               fcc       "not "
                    fcb       0
L16F7               fcc       "intact"
                    fcb       $0a,$00
L16FF               fcc       "1 directory"
                    fcb       $0a,$00
L170C               fcc       "%d directories"
                    fcb       $0a,$00
L171C               fcc       "1 file"
                    fcb       $0a,$00
L1724               fcc       "%d files"
                    fcb       $0a,$00
L172E               fcc       "Usage: dcheck [-opts] device_name "
                    fcb       $0a
                    fcc       "  -w = pathlist to directory for work files"
                    fcb       $0a
                    fcc       "  -p = print pathlists for questionable clusters"
                    fcb       $0a
                    fcc       "  -m = save allocation map work files"
                    fcb       $0a
                    fcc       "  -b = suppress listing of unused clusters"
                    fcb       $0a,$00
L1800               fcc       "  -s = display count of files and directories only"
                    fcb       $0a,$00
L1834               fcc       "$%02x%04x"
                    fcb       $00
L183E               fcc       "dcheck: fatal read error"
                    fcb       $0a,$00
L1858               fcc       "dcheck: directories nested too deep (%d)"
                    fcb       $0a,$00
L1882               fcb       $20,$20,$00
L1885               fcc       "%s"
                    fcb       $00
L1888               fcc       "dcheck: cannot chgdir to '%s'"
                    fcb       $0a,$00
L18A7               fcc       ".."
                    fcb       $00
L18AA               fcc       "*** Bad FD segment (%s-%s) for file: "
                    fcb       $00
L18D0               fcc       "--> setbits: Start=%s Count=$%04x"
                    fcb       $00
L18F2               fcc       " Sector=%02x Byte=%02x Bit=%1x <--"
                    fcb       $0a,$00
L1916               fcc       "Cluster %s was previously allocated"
                    fcb       $0a,$00
L193B               fcc       "Cluster %s in file structure but not in allocation map"
                    fcb       $0a,$00
L1973               fcc       "Cluster %s in allocation map but not in file structure"
                    fcb       $0a,$00
L19Ab               fcc       "Cluster %s in path: "
                    fcb       $00
L19C0               fcc       "/dcheck%02x%d"
                    fcb       $00
L19CE               fcc       "dcheck: cannot open workfile '%s'"
                    fcb       $0a,$00
L19F1               fcc       "*** Segment out of range in file: "
                    fcb       $00
L1A14               fcc       "%s/"
                    fcb       $00
L1A18               fcc       "%s"
                    fcb       $0a,$00
L1A1C               fcb       $2E,$00
L1A1E               fcc       "dcheck: cannot open '.' directory"
                    fcb       $0a,$00
L1A41               fcc       "Pathlist is: "
                    fcb       $00

;---------------------------------
; we got here from a F$Fork, so...
; Y=top of parameter area
; X,SP Highest address of data area
; U,DP lowest address
; D= size of parameter area
; U,Y always are at page boundaries
;---------------------------------
start               equ       *
                    clrb                          make even page boundary
                    stb       ,u++                U+2, 4 a 1 byte write?
rdarg               lda       ,x+                 get first char of cli
                    cmpa      #$0D                end of line?
                    beq       L1ABE               we have end of cli opts
                    bsr       isspace             else check for space?
                    beq       rdarg               was, get next char
                    leax      -$01,x              else 1 to many read
                    stx       ,u++                save addr of arg in u0002(4,6,8,A,etc)
                    inc       <u0000              tally we have one
L1AB0               lda       ,x+                 get cli char
                    cmpa      #$0D                end of line?
                    beq       L1ABE               yes, go
                    bsr       isspace             no, chkspace
                    bne       L1AB0               not a space,  back for more
                    clr       -$01,x
                    bra       rdarg               go back again

L1ABE               clr       ,-x                 end of cli options found
                    lda       <u0000
                    sta       <u0001              copy arg count
                    clra
                    clrb
                    pshs      b,a                 clear 2 bytes on stack
L1AC8               tst       <u0000              do we have arguments?
                    beq       L1AD4               no, go
                    dec       <u0000              else dec count
                    ldd       ,--u                get from u, and reset u-2
                    pshs      b,a                 put arg pointer on stack
                    bra       L1AC8               repeat till u0000=00

L1AD4               pshs      x                   save x
                    leax      ,s                  get stack pointer
                    pshs      x                   stack it
                    leax      -$02,s              push stack down 2 more
                    pshs      x                   now its 6 bytes
                    leax      ,u
L1AE0               clr       ,x+
                    cmpx      ,s
                    bcs       L1AE0
                    puls      x
                    leau      -u0002,u
                    leax      <u0010,u
                    stx       <u000A
                    stx       <u0008
                    leax      <u001B,u
                    stx       <u000C
                    stx       <u0018
                    leax      <u0026,u
                    stx       <u000E
                    stx       <u0023
                    lda       #$05
                    sta       <u0016
                    lda       #$06
                    sta       <u0021
                    sta       <u002C
                    clra
                    sta       <u0017
                    inca
                    sta       <u0022
                    inca
                    sta       <u002D
                    ldd       ,u
                    addd      #$0001
                    sty       <u0000
                    leay      >u00FD,u
                    lbsr      L0014
                    bra       L1B2D

isspace             cmpa      #$20                space char?
                    beq       L1B2C               yes, go
                    cmpa      #$09                whats a #$09?
L1B2C               rts

L1B2D               pshs      b,a
L1B2F               ldd       <u0008
                    beq       L1B3A
                    ldd       <u0008
                    lbsr      L1E93
                    bra       L1B2F

L1B3A               ldd       ,s
                    lbsr      L27AB
                    leas      $02,s
                    rts
;---------------------------------------------
;
;---------------------------------------------
L1B48               pshs      b,a
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
                    pshs      b,a
                    ldd       $04,s
                    bsr       L1BC1
                    leas      $04,s
                    leas      $02,s
                    rts

;---------------------------------------------
; entry to screen output print function
;---------------------------------------------
L1B5F               pshs      b,a
                    leas      >-$0100,s
                    leax      >$0106,s
                    pshs      x
                    ldd       >$0106,s
                    pshs      b,a
                    leax      $04,s
                    tfr       x,d
                    bsr       L1BC1
                    leas      $04,s
                    ldd       >$0100,s
                    pshs      b,a
                    leax      $02,s
                    tfr       x,d
                    lbsr      L1FEC
                    leas      $02,s
                    leas      >$0102,s
                    rts

L1B94               pshs      b,a
                    leas      >-$0100,s
                    leax      >$0104,s
                    pshs      x
                    ldd       >$0102,s
                    pshs      b,a
                    leax      $04,s
                    tfr       x,d
                    bsr       L1BC1
                    leas      $04,s
                    leax      ,s
                    tfr       x,d
                    lbsr      L1F87
                    leas      >$0102,s
                    rts

L1BC1               pshs      b,a
                    leas      >-$010D,s
L1BC7               ldx       >$0111,s
                    ldb       ,x+
                    stx       >$0111,s
                    stb       ,s
                    tstb
                    lbeq      L1DF4
                    ldb       ,s
                    cmpb      #'%                 ; $25
                    beq       L1BF4
                    ldd       >$010D,s
                    addd      #$0001
                    std       >$010D,s
                    subd      #$0001
                    pshs      b,a
                    ldb       $02,s
                    stb       [,s++]
                    bra       L1BC7

L1BF4               leax      $0D,s
                    stx       $09,s
                    ldd       #$0006
                    std       $04,s
                    clr       $07,s
                    ldb       #$20
                    stb       $08,s
                    clr       $06,s
                    ldb       [>$0111,s]
                    cmpb      #'-                 ; $2D
                    bne       L1C1C
                    ldd       >$0111,s
                    addd      #$0001
                    std       >$0111,s
                    ldb       #$01
                    stb       $07,s
L1C1C               ldb       [>$0111,s]
                    clra
                    lbsr      L2444
                    addd      #$0000
                    beq       L1C42
                    ldb       [>$0111,s]
                    cmpb      #$30
                    bne       L1C35
                    ldb       #$30
                    stb       $08,s
L1C35               leax      >$0111,s
                    tfr       x,d
                    lbsr      L1F48
                    std       $02,s
                    bra       L1C46

L1C42               clrb
                    clra
                    std       $02,s
L1C46               ldb       [>$0111,s]
                    cmpb      #'.                 ; $2E
                    bne       L1C68
                    ldd       >$0111,s
                    addd      #$0001
                    std       >$0111,s
                    leax      >$0111,s
                    tfr       x,d
                    lbsr      L1F48
                    std       $04,s
                    ldb       #$01
                    stb       $06,s
L1C68               ldx       >$0111,s
                    ldb       ,x+
                    stx       >$0111,s
                    stb       ,s
                    ldb       ,s
                    clra
                    lbsr      L245B               saves long branch
                    cmpb      #'d                 ; $64
                    beq       L1C9D
                    cmpb      #'u                 ; $75
                    beq       L1CCA
                    cmpb      #'x                 ; $78
                    beq       L1CD0
                    cmpb      #'o                 ; $6F
                    beq       L1CD6
                    cmpb      #'c                 ; $63
                    beq       L1D00
                    cmpb      #'s                 ; $73
                    lbeq      L1D22
                    lbra      L1DDD

;------------------
; Treat printf %d
;------------------
L1C9D               ldd       [>$0113,s]
                    cmpd      #$0000
                    bge       L1CCA
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
                    subd      #$0001
                    pshs      b,a
                    ldb       #$2D
                    stb       [,s++]
                    ldd       [>$0113,s]
                    nega
                    negb
                    sbca      #$00
                    std       [>$0113,s]
                    ldd       $02,s
                    subd      #$0001
                    std       $02,s

;-------------------
; Treat printf %u
;-------------------
L1CCA               ldb       #$0A
                    stb       $01,s
                    bra       L1CDA

;------------------
; Treat printf %x
;------------------
L1CD0               ldb       #$10
                    stb       $01,s
                    bra       L1CDA

;-------------------
; Treat printf %o
;-------------------
L1CD6               ldb       #$08
                    stb       $01,s
L1CDA               ldb       $01,s
                    clra
                    pshs      b,a
                    ldx       >$0115,s
                    ldd       ,x++
                    stx       >$0115,s
                    pshs      b,a
                    leax      $0D,s
                    tfr       x,d
                    lbsr      L1DFD
                    leas      $04,s
                    clra
                    pshs      b,a
                    ldd       $04,s
                    subd      ,s++
                    std       $02,s
                    bra       L1D64

;------------------
; Treat printf %c
;------------------
L1D00               ldd       $09,s
                    addd      #$0001
                    std       $09,s
                    subd      #$0001
                    pshs      b,a
                    ldx       >$0115,s
                    ldd       ,x++
                    stx       >$0115,s
                    stb       [,s++]
                    ldd       $02,s
                    subd      #$0001
                    std       $02,s
                    bra       L1D64

;----------------
; Treat printf %s
;----------------
L1D22               ldb       $06,s
                    bne       L1D2B
                    ldd       #$0100
                    std       $04,s
L1D2B               ldx       >$0113,s
                    ldd       ,x++
                    stx       >$0113,s
                    std       $0B,s
L1D37               ldb       [<$0B,s]
                    beq       L1D64
                    ldd       $04,s
                    beq       L1D64
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
                    subd      #$0001
                    pshs      b,a
                    ldx       $0D,s
                    ldb       ,x+
                    stx       $0D,s
                    stb       [,s++]
                    ldd       $04,s
                    subd      #$0001
                    std       $04,s
                    ldd       $02,s
                    subd      #$0001
                    std       $02,s
                    bra       L1D37

L1D64               clr       [<$09,s]
                    leax      $0D,s
                    stx       $09,s
                    ldb       $07,s
                    bne       L1D95
L1D6F               ldd       $02,s
                    subd      #$0001
                    std       $02,s
                    addd      #$0001
                    cmpd      #$0000
                    ble       L1D95
                    ldd       >$010D,s
                    addd      #$0001
                    std       >$010D,s
                    subd      #$0001
                    pshs      b,a
                    ldb       $0A,s
                    stb       [,s++]
                    bra       L1D6F

L1D95               ldx       $09,s
                    ldb       ,x+
                    stx       $09,s
                    stb       [>$010D,s]
                    tstb
                    beq       L1DAF
                    ldd       >$010D,s
                    addd      #$0001
                    std       >$010D,s
                    bra       L1D95

L1DAF               ldb       $07,s
                    lbeq      L1BC7
L1DB5               ldd       $02,s
                    subd      #$0001
                    std       $02,s
                    addd      #$0001
                    cmpd      #$0000
                    lble      L1BC7
                    ldd       >$010D,s
                    addd      #$0001
                    std       >$010D,s
                    subd      #$0001
                    pshs      b,a
                    ldb       $0A,s
                    stb       [,s++]
                    bra       L1DB5

L1DDD               ldd       >$010D,s
                    addd      #$0001
                    std       >$010D,s
                    subd      #$0001
                    pshs      b,a
                    ldb       $02,s
                    stb       [,s++]
                    lbra      L1BC7

L1DF4               clr       [>$010D,s]
                    leas      >$010F,s
                    rts

L1DFD               pshs      b,a
                    leas      -$03,s
                    ldd       [<$03,s]
                    std       ,s
                    ldd       $07,s
                    pshs      b,a
                    ldd       $0B,s
                    lbsr      L2515
                    stb       $02,s
                    ldd       [<$03,s]
                    addd      #$0001
                    std       [<$03,s]
                    subd      #$0001
                    pshs      b,a
                    ldb       $04,s
                    cmpb      #$0A
                    bcc       L1E2B
                    ldb       $04,s
                    addb      #$30
                    bra       L1E2F

L1E2B               ldb       $04,s
                    addb      #$37
L1E2F               stb       [,s++]
L1E31               ldd       $07,s
                    pshs      b,a
                    ldd       $0B,s
                    lbsr      L2531
                    std       $07,s
                    addd      #$0000
                    beq       L1E6E
                    ldd       $07,s
                    pshs      b,a
                    ldd       $0B,s
                    lbsr      L2515
                    stb       $02,s
                    ldd       [<$03,s]
                    addd      #$0001
                    std       [<$03,s]
                    subd      #$0001
                    pshs      b,a
                    ldb       $04,s
                    cmpb      #$0A
                    bcc       L1E66
                    ldb       $04,s
                    addb      #$30
                    bra       L1E6A

L1E66               ldb       $04,s
                    addb      #$37
L1E6A               stb       [,s++]
                    bra       L1E31

L1E6E               ldx       [<$03,s]
                    clr       ,x
                    ldd       ,s
                    lbsr      L1F9A
                    ldd       [<$03,s]
                    subd      ,s
                    clra
                    leas      $05,s
                    rts

L1E93               pshs      b,a
                    leas      -$05,s
                    clrb
                    clra
                    std       $02,s
                    ldd       <u0008
                    std       ,s
L1E9F               ldd       ,s
                    beq       L1F02
                    ldd       ,s
                    cmpd      $05,s
                    bne       L1EF5
                    ldd       $02,s
                    beq       L1EC1
                    ldd       $02,s
                    addd      #$0008
                    pshs      b,a
                    ldx       $02,s
                    ldd       $08,x
                    std       [,s++]
                    bra       L1EC7

L1EC1               ldx       ,s
                    ldd       $08,x
                    std       <u0008
L1EC7               clr       $04,s
                    ldd       $05,s
                    lbsr      L22A1
                    ldx       $05,s
                    ldb       $07,x
                    clra
                    lbsr      L26CA
                    cmpd      #$FFFF
                    bne       L1EE0
                    ldb       #$01
                    stb       $04,s
L1EE0               ldd       $05,s
                    bsr       L1F08
                    ldb       $04,s
                    beq       L1EEF
                    ldd       #$FFFF
                    leas      $07,s
                    rts

L1EEF               ldd       #$0001
                    leas      $07,s
                    rts

L1EF5               ldd       ,s
                    std       $02,s
                    ldx       ,s
                    ldd       $08,x
                    std       ,s
                    bra       L1E9F

L1F02               ldd       #$FFFF
                    leas      $07,s
                    rts

L1F08               pshs      b,a
                    ldd       ,s
                    addd      #$0006
                    tfr       d,x
                    ldb       ,x
                    andb      #$08
                    tstb
                    beq       L1F1F
                    ldx       ,s
                    ldd       $04,x
                    lbsr      L238D
L1F1F               ldd       ,s
                    cmpd      <u000A
                    beq       L1F34
                    ldd       ,s
                    cmpd      <u000C
                    beq       L1F34
                    ldd       ,s
                    cmpd      <u000E
                    bne       L1F37
L1F34               leas      $02,s
                    rts

L1F37               ldd       ,s
                    lbsr      L238D
                    leas      $02,s
                    rts

L1F48               pshs      b,a
                    leas      -$02,s
                    clrb
                    clra
                    std       ,s
L1F50               ldx       [<$02,s]
                    ldb       ,x
                    clra
                    lbsr      L2444
                    addd      #$0000
                    beq       L1F7C
                    ldx       [<$02,s]
                    ldb       ,x+
                    stx       [<$02,s]
                    clra
                    pshs      b,a
                    ldd       $02,s
                    pshs      b,a
                    ldd       #$000A
                    lbsr      L24C6
                    addd      ,s++
                    subd      #$0030
                    std       ,s
                    bra       L1F50

L1F7C               ldd       ,s
                    leas      $04,s
                    rts

L1F87               pshs      b,a
                    ldd       <u000C
                    pshs      b,a
                    ldd       $02,s
                    bsr       L1FEC
                    leas      $02,s
                    leas      $02,s
                    rts

L1F9A               pshs      b,a
                    leas      -$05,s
                    clrb
                    clra
                    std       ,s
                    ldd       $05,s
                    lbsr      L24AA               switches to lb still saves
                    subd      #$0001
                    std       $02,s
L1FAC               ldd       ,s
                    cmpd      $02,s
                    bge       L1FE6
                    ldd       ,s
                    ldx       $05,s
                    ldb       d,x
                    stb       $04,s
                    ldd       $05,s
                    addd      ,s
                    pshs      b,a
                    ldd       $04,s
                    ldx       $07,s
                    ldb       d,x
                    stb       [,s++]
                    ldd       $05,s
                    addd      $02,s
                    pshs      b,a
                    ldb       $06,s
                    stb       [,s++]
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $02,s
                    subd      #$0001
                    std       $02,s
                    bra       L1FAC

L1FE6               leas      $07,s
                    rts

L1FEC               pshs      b,a
                    leas      >-$0107,s
                    ldd       >$010B,s
                    lbsr      L22A1
                    ldd       >$0107,s
                    std       $01,s
                    leax      $07,s
                    stx       $03,s
L2003               ldb       [<$01,s]
                    lbeq      L209A
                    ldb       [<$01,s]
                    cmpb      #$0A
                    bne       L2042
                    ldb       #$0D
                    stb       [<$03,s]
                    ldd       #$0100
                    pshs      b,a
                    leax      $09,s
                    pshs      x
                    ldx       >$010F,s
                    ldb       $07,x
                    clra
                    lbsr      L2713
                    leas      $04,s
                    cmpd      #$FFFF
                    bne       L203B
                    ldd       #$FFFF
                    leas      >$0109,s
                    rts

L203B               leax      $07,s
                    stx       $03,s
                    bra       L2090

L2042               ldb       [<$01,s]
                    cmpb      #$09
                    bne       L207F
                    ldd       $03,s
                    leax      $07,s
                    pshs      x
                    subd      ,s++
                    pshs      b,a
                    ldd       #$0008
                    lbsr      L2509
                    pshs      b,a
                    ldd       #$0008
                    subd      ,s++
                    std       $05,s
L2062               ldd       $05,s
                    beq       L2090
                    ldd       $03,s
                    addd      #$0001
                    std       $03,s
                    subd      #$0001
                    pshs      b,a
                    ldb       #$20
                    stb       [,s++]
                    ldd       $05,s
                    subd      #$0001
                    std       $05,s
                    bra       L2062

L207F               ldd       $03,s
                    addd      #$0001
                    std       $03,s
                    subd      #$0001
                    pshs      b,a
                    ldb       [<$03,s]
                    stb       [,s++]
L2090               ldd       $01,s
                    addd      #$0001
                    std       $01,s
                    lbra      L2003

L209A               clr       [<$03,s]
                    ldd       $03,s
                    leax      $07,s
                    pshs      x
                    cmpd      ,s++
                    beq       L20D1
                    leax      $07,s
                    tfr       x,d
                    lbsr      L24AA
                    pshs      b,a
                    leax      $09,s
                    pshs      x
                    ldx       >$010F,s
                    ldb       $07,x
                    clra
                    lbsr      L26E9
                    leas      $04,s
                    cmpd      #$FFFF
                    bne       L20D1
                    ldd       #$FFFF
                    leas      >$0109,s
                    rts

L20D1               ldd       >$0107,s
                    leas      >$0109,s
                    rts

L20F9               pshs      b,a
                    ldd       $04,s
                    addd      #$0002
                    tfr       d,x
                    ldd       ,x
                    subd      #$0001
                    std       ,x
                    cmpd      #$0000
                    blt       L2124
                    ldd       [<$04,s]
                    addd      #$0001
                    std       [<$04,s]
                    subd      #$0001
                    pshs      b,a
                    ldb       $03,s
                    stb       [,s++]
                    clra
                    bra       L2135

L2124               ldd       #$0001
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldb       $05,s
                    clra
                    bsr       L2148
                    leas      $04,s
L2135               leas      $02,s
                    rts

L2148               pshs      b,a
                    leas      -$03,s
                    ldb       $04,s
                    stb       $02,s
                    ldd       $07,s
                    addd      #$0006
                    tfr       d,x
                    ldb       ,x
                    andb      #$02
                    cmpb      #$00
                    beq       L216E
                    ldd       $07,s
                    addd      #$0006
                    tfr       d,x
                    ldb       ,x
                    andb      #$30
                    cmpb      #$00
                    beq       L2174
L216E               ldd       #$FFFF
                    leas      $05,s
                    rts

L2174               ldb       $0A,s
                    beq       L217D
                    ldd       #$0001
                    bra       L217F

L217D               clrb
                    clra
L217F               pshs      b,a
                    ldd       $09,s
                    addd      #$0002
                    pshs      b,a
                    ldd       #$0100
                    subd      [,s++]
                    subd      ,s++
                    std       ,s
                    ldd       $07,s
                    addd      #$0006
                    tfr       d,x
                    ldb       ,x
                    andb      #$04
                    cmpb      #$00
                    bne       L21D0
                    ldx       $07,s
                    ldd       $04,x
                    bne       L21D0
                    ldd       $07,s
                    addd      #$0004
                    pshs      b,a
                    ldd       #$0100
                    lbsr      L22BB
                    std       [,s++]
                    cmpd      #$0000
                    bne       L21CC
                    ldd       $07,s
                    addd      #$0006
                    tfr       d,u
                    ldb       ,u
                    orb       #$04
                    stb       ,u
                    bra       L21D0

L21CC               clrb
                    clra
                    std       ,s
L21D0               ldd       $07,s
                    addd      #$0006
                    tfr       d,x
                    ldb       ,x
                    andb      #$04
                    tstb
                    beq       L2214
                    ldb       $0A,s
                    beq       L2245
                    ldd       #$0001
                    pshs      b,a
                    leax      $04,s
                    pshs      x
                    ldx       $0B,s
                    ldb       $07,x
                    clra
                    lbsr      L26E9
                    leas      $04,s
                    cmpd      #$FFFF
                    bne       L2245
                    ldd       $07,s
                    addd      #$0006
                    tfr       d,u
                    ldb       ,u
                    orb       #$20
                    stb       ,u
                    ldd       #$FFFF
                    leas      $05,s
                    rts

L2214               ldd       ,s
                    beq       L2245
                    ldd       ,s
                    pshs      b,a
                    ldx       $09,s
                    ldd       $04,x
                    pshs      b,a
                    ldx       $0B,s
                    ldb       $07,x
                    clra
                    lbsr      L26E9
                    leas      $04,s
                    cmpd      #$FFFF
                    bne       L2245
                    ldd       $07,s
                    addd      #$0006
                    tfr       d,u
                    ldb       ,u
                    orb       #$20
                    stb       ,u
                    ldd       #$FFFF
                    leas      $05,s
                    rts

L2245               ldd       $07,s
                    addd      #$0002
                    pshs      b,a
                    ldd       $09,s
                    addd      #$0006
                    tfr       d,x
                    ldb       ,x
                    andb      #$04
                    tstb
                    beq       L225E
                    clrb
                    clra
                    bra       L2261

L225E               ldd       #$0100
L2261               std       [,s++]
                    ldx       $07,s
                    ldd       $04,x
                    std       [<$07,s]
                    ldb       $0A,s
                    beq       L229B
                    ldd       $07,s
                    addd      #$0006
                    tfr       d,x
                    ldb       ,x
                    andb      #$04
                    cmpb      #$00
                    bne       L229B
                    ldd       [<$07,s]
                    addd      #$0001
                    std       [<$07,s]
                    subd      #$0001
                    pshs      b,a
                    ldb       $06,s
                    stb       [,s++]
                    ldd       $07,s
                    addd      #$0002
                    pshs      b,a
                    ldd       #$00FF
                    std       [,s++]
L229B               ldb       $04,s
                    clra
                    leas      $05,s
                    rts

L22A1               pshs      b,a
                    clrb
                    clra
                    pshs      b,a
                    ldd       $02,s
                    pshs      b,a
                    clrb
                    clra
                    lbsr      L2148
                    leas      $04,s
                    leas      $02,s
                    rts

L22BB               pshs      b,a
                    leas      -$08,s
                    ldd       $08,s
                    addd      #$0003
                    lsra
                    rorb
                    lsra
                    rorb
                    addd      #$0001
                    std       $06,s
                    ldd       >$0280,y
                    std       $02,s
                    cmpd      #$0000
                    bne       L22ED
                    leax      >$027C,y
                    stx       $02,s
                    stx       >$0280,y
                    stx       >$027C,y
                    clrb
                    clra
                    std       >$027E,y
L22ED               ldd       [<$02,s]
                    std       ,s
L22F2               ldx       ,s
                    ldd       $02,x
                    cmpd      $06,s
                    bcs       L2348
                    ldx       ,s
                    ldd       $02,x
                    cmpd      $06,s
                    bne       L230D
                    ldd       [,s]
                    std       [<$02,s]
                    bra       L233A

L230D               ldd       ,s
                    addd      #$0002
                    tfr       d,u
                    ldd       ,u
                    subd      $06,s
                    std       ,u
                    ldd       ,s
                    addd      #$0002
                    tfr       d,x
                    ldd       ,x
                    lslb
                    rola
                    lslb
                    rola
                    pshs      b,a
                    ldd       $02,s
                    addd      ,s++
                    std       ,s
                    ldd       ,s
                    addd      #$0002
                    pshs      b,a
                    ldd       $08,s
                    std       [,s++]
L233A               ldd       $02,s
                    std       >$0280,y
                    ldd       ,s
                    addd      #$0004
                    leas      $0A,s
                    rts

L2348               ldd       ,s
                    cmpd      >$0280,y
                    bne       L2382
                    ldd       $06,s
                    lslb
                    rola
                    lslb
                    rola
                    lbsr      L25A8
                    std       $04,s
                    cmpd      #$FFFF
                    bne       L2369
                    clrb
                    clra
                    leas      $0A,s
                    rts

L2369               ldd       $04,s
                    addd      #$0002
                    pshs      b,a
                    ldd       $08,s
                    std       [,s++]
                    ldd       $04,s
                    addd      #$0004
                    bsr       L238D
                    ldd       >$0280,y
                    std       ,s
L2382               ldd       ,s
                    std       $02,s
                    ldd       [,s]
                    std       ,s
                    lbra      L22F2

L238D               pshs      b,a
                    leas      -$04,s
                    ldd       $04,s
                    subd      #$0004
                    std       ,s
                    ldd       >$0280,y
                    std       $02,s
L239E               ldd       ,s
                    cmpd      $02,s
                    bls       L23AD
                    ldd       ,s
                    cmpd      [<$02,s]
                    bcs       L23CC
L23AD               ldd       $02,s
                    cmpd      [<$02,s]
                    bcs       L23C4
                    ldd       ,s
                    cmpd      $02,s
                    bhi       L23CC
                    ldd       ,s
                    cmpd      [<$02,s]
                    bcs       L23CC
L23C4               ldd       [<$02,s]
                    std       $02,s
                    bra       L239E

L23CC               ldd       ,s
                    addd      #$0002
                    tfr       d,x
                    ldd       ,x
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s
                    cmpd      [<$02,s]
                    bne       L23FF
                    ldd       [<$02,s]
                    addd      #$0002
                    pshs      b,a
                    ldd       $02,s
                    addd      #$0002
                    tfr       d,u
                    ldd       ,u
                    addd      [,s++]
                    std       ,u
                    ldx       [<$02,s]
                    ldd       ,x
                    std       [,s]
                    bra       L2404

L23FF               ldd       [<$02,s]
                    std       [,s]
L2404               ldd       $02,s
                    addd      #$0002
                    tfr       d,x
                    ldd       ,x
                    lslb
                    rola
                    lslb
                    rola
                    addd      $02,s
                    cmpd      ,s
                    bne       L2433
                    ldd       ,s
                    addd      #$0002
                    pshs      b,a
                    ldd       $04,s
                    addd      #$0002
                    tfr       d,u
                    ldd       ,u
                    addd      [,s++]
                    std       ,u
                    ldd       [,s]
                    std       [<$02,s]
                    bra       L2438

L2433               ldd       ,s
                    std       [<$02,s]
L2438               ldd       $02,s
                    std       >$0280,y
                    leas      $06,s
                    rts

L2444               pshs      b,a
                    ldb       $01,s
                    cmpb      #$30
                    bcs       L2456
                    ldb       $01,s
                    cmpb      #$39
                    bhi       L2456
                    ldb       #$01
                    bra       L2457

L2456               clrb
L2457               clra
                    leas      $02,s
                    rts

L245B               pshs      b,a
                    ldb       $01,s
                    clra
                    bsr       L2477
                    addd      #$0000
                    beq       L246E
                    ldb       $01,s
                    addb      #$20
                    bra       L2470

L246E               ldb       $01,s
L2470               clra
                    leas      $02,s
                    rts

L2477               pshs      b,a
                    ldb       $01,s
                    cmpb      #$41
                    bcs       L2489
                    ldb       $01,s
                    cmpb      #$5A
                    bhi       L2489
                    ldb       #$01
                    bra       L248A
L2489               clrb
L248A               clra
                    leas      $02,s
                    rts

***************************
* an often called subroutine
***************************
L248E               pshs      b,a
L2490               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    pshs      b,a
                    ldx       $06,s
                    ldb       ,x+
                    stx       $06,s
                    stb       [,s++]
                    tstb
                    bne       L2490
                    leas      $02,s
                    rts

L24AA               pshs      b,a
                    leas      -$02,s
                    ldd       $02,s
                    std       ,s
L24B2               ldb       [,s]
                    beq       L24BF
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    bra       L24B2

L24BF               ldd       ,s
                    subd      $02,s
                    leas      $04,s
                    rts

L24C6               leas      -$05,s
                    clr       ,s
                    bsr       L24FF
                    std       $01,s
                    ldd       $07,s
                    bsr       L24FF
                    std       $07,s
                    lda       $02,s
                    ldb       $08,s
                    mul
                    std       $03,s
                    lda       $01,s
                    ldb       $08,s
                    mul
                    tfr       b,a
                    clrb
                    addd      $03,s
                    std       $03,s
                    lda       $02,s
                    ldb       $07,s
                    mul
                    tfr       b,a
                    clrb
                    addd      $03,s
                    tst       ,s
                    bpl       L24F9
                    nega
                    negb
                    sbca      #$00
L24F9               ldx       $05,s
                    leas      $09,s
                    jmp       ,x                  this one jmp could screw it all up

L24FF               tsta
                    bpl       L2508
                    com       $02,s
                    nega
                    negb
                    sbca      #$00
L2508               rts

L2509               ldx       $02,s
                    bsr       L2588
                    pshs      cc
                    stx       $03,s
                    puls      cc
                    bra       L2517

L2515               andcc     #$F7
L2517               orcc      #$01
                    pshs      cc
                    ldx       #$0000
                    puls      cc
                    bra       L2536

L2531               ldx       #$FFFF
                    andcc     #$F6
L2536               leas      -$03,s
                    pshs      cc
                    std       $02,s
                    bne       L2544
                    puls      cc
                    tfr       x,d
                    bra       L2582

L2544               lda       #$01
                    sta       $01,s
L2548               tst       $02,s
                    bmi       L2554
                    lsl       $03,s
                    rol       $02,s
                    inc       $01,s
                    bra       L2548

L2554               ldd       $06,s
                    clr       $06,s
                    clr       $07,s
L255A               subd      $02,s
                    bcc       L2564
                    addd      $02,s
                    andcc     #$FE
                    bra       L2566

L2564               orcc      #$01
L2566               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       $01,s
                    bne       L255A
                    puls      cc
                    bcs       L257C
                    pshs      cc
                    ldd       $06,s
                    puls      cc
L257C               bpl       L2582
                    nega
                    negb
                    sbca      #$00
L2582               ldx       $03,s
                    leas      $07,s
                    jmp       ,x

L2588               pshs      u
                    tfr       d,u
                    pshs      x
                    eora      ,s++
                    andcc     #$FE
                    pshs      cc
                    tfr       x,d
                    bsr       L25A0
                    tfr       d,x
                    tfr       u,d
                    bsr       L25A0
                    puls      pc,u,cc

L25A0               tsta
                    bpl       L25A7
                    nega
                    negb
                    sbca      #$00
L25A7               rts

******************************
* memory  for what purpose?
******************************
L25A8               pshs      b,a
                    leax      >-$00FD,y
                    tfr       x,d
                    nega
                    negb
                    sbca      #$00
                    addd      <u0000
                    addd      ,s
                    pshs      y
* ENTRY
* D= size of new memory in bytes
* if 0, get current size and upper bound
                    os9       F$Mem
* Y= address of memory upper bound
* D= actual size of memory in bytes
                    puls      y                   throws Y away?
                    puls      x
                    bcs       L25CA               error, go
                    ldd       <u0000              overwrites size from F$Mem?
                    leax      d,x                 no error, assume success
                    stx       <u0000              and store new memory in bytes
                    rts

L25CA               clra
                    std       <u0002
                    ldd       #$FFFF
                    rts

****************************
* search new dir?
****************************
L25D1               tfr       d,x
                    lda       #$01
                    os9       I$ChgDir            if success, its a dir
                    bcc       L25E0               go
                    std       <u0002              else file, save
                    ldd       #$FFFF              -1 failure
                    rts

L25E0               clra
                    clrb
                    rts

L25E3               leas      -$04,s
                    ldu       $06,s
                    tfr       d,x
                    ldd       ,x
                    std       ,s
                    lda       $02,x
                    sta       $02,s
                    ldd       $08,s
                    bra       L260B

L25F5               lsr       ,s
                    ror       $01,s
                    ror       $02,s
                    bcc       L2607
                    inc       $02,s
                    bne       L2607
                    inc       $01,s
                    bne       L2607
                    inc       ,s
L2607               lsr       ,u
                    ror       u0001,u
L260B               lsra
                    rorb
                    bcc       L25F5
                    clra
                    ldb       $02,s
                    andb      #$07
                    ldu       $0E,s
                    std       ,u
                    ldd       $01,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    clra
                    ldu       $0C,s
                    std       ,u
                    ldd       ,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    ldu       $0A,s
                    std       ,u
                    leas      $04,s
                    rts

L2634               tfr       d,x
                    clra
                    clrb
                    std       ,x
                    stb       $02,x
                    ldd       $04,s
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    std       ,x
                    ldd       $06,s
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addd      $01,x
                    std       $01,x
                    bcc       L2656
                    inc       ,x
L2656               addd      $08,s
                    std       $01,x
                    bcc       L265E
                    inc       ,x
L265E               ldd       $02,s
                    bra       L2668

L2662               lsl       $02,x
                    rol       $01,x
                    rol       ,x
L2668               asra
                    rorb
                    bne       L2662
                    rts

L266D               tfr       d,x
                    ldu       $02,s
                    ldb       ,x
                    stb       ,u
                    ldd       $01,x
                    addd      $04,s
                    std       u0001,u
                    bcc       L267F
                    inc       ,u
L267F               clra
                    clrb
                    rts

;---------------------------------------------
; 24 bits comparison
; IN : *(d)   first 24 bits value to compare
;      *(2+s) Seconds value to compare
; OUT: D = -1 : 1st < 2nd
;           0 : 1st = 2nd
;           1 : 1st > 2nd
;---------------------------------------------
L2682               tfr       d,x
                    ldu       $02,s
                    ldb       ,x
                    cmpb      ,u
                    bhi       L269E
                    bcs       L269A
                    ldd       $01,x
                    cmpd      1,u
                    bhi       L269E
                    bcs       L269A
                    clra
                    clrb
                    rts

L269A               ldd       #$FFFF
                    rts

L269E               ldd       #$0001
                    rts

;---------------------------------------------
;
; OUT: D = -1 : error
;           0 : No error occured
;---------------------------------------------
L26A2               tfr       b,a
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L26B9
                    tfr       x,d
                    ldx       $04,s
                    stu       ,x
                    ldx       $02,s
                    std       ,x
                    clra
                    clrb
                    bra       L26BC
L26B9               ldd       #$FFFF
L26BC               rts

;---------------------------------------------
;
;---------------------------------------------
L26BD               tfr       d,x
                    lda       $03,s
                    os9       I$Open
                    bcs       L2728
                    tfr       a,b
                    clra
                    rts

;---------------------------------------------
;
;---------------------------------------------
L26CA               tfr       b,a
                    os9       I$Close
                    bcs       L2728
                    clra
                    clrb
                    rts

;---------------------------------------------
;
;---------------------------------------------
L26D4               pshs      y
                    tfr       b,a
                    ldx       $04,s
                    ldy       $06,s
                    os9       I$Read
                    puls      x
                    exg       x,y
                    bcs       L2728
                    tfr       x,d
                    rts

;---------------------------------------------
;
;---------------------------------------------
L26E9               pshs      y
                    tfr       b,a
                    ldx       $04,s
                    ldy       $06,s
                    os9       I$Write
                    puls      x
                    exg       x,y
                    bcs       L2728
                    tfr       x,d
                    rts

;---------------------------------------------
;
;---------------------------------------------
                    pshs      y
                    tfr       b,a
                    ldx       $04,s
                    ldy       $06,s
                    os9       I$ReadLn
                    puls      x
                    exg       x,y
                    bcs       L2728
                    tfr       x,d
                    rts

;---------------------------------------------
;
;---------------------------------------------
L2713               pshs      y
                    tfr       b,a
                    ldx       $04,s
                    ldy       $06,s
                    os9       I$WritLn
                    puls      x
                    exg       x,y
                    bcs       L2728
                    tfr       x,d
                    rts

;---------------------------------------------
;
;---------------------------------------------
L2728               clra
                    std       <u0002
                    ldd       #$FFFF
                    rts

;---------------------------------------------
;
;---------------------------------------------
L272F               tfr       d,x
                    lda       #$02
                    ldb       $03,s
                    bmi       L273B
                    tfr       b,a
                    anda      #$03
L273B               orb       #$01
                    pshs      x,b,a
                    os9       I$Create
                    puls      u,x
                    exg       x,u
                    bcc       L2758
                    pshs      x
                    os9       I$Delete
                    puls      x
                    bcs       L2728
                    tfr       u,d
                    os9       I$Create
                    bcs       L2728
L2758               tfr       a,b
                    clra
                    rts

;---------------------------------------------
;
;---------------------------------------------
L275C               pshs      b,a
                    ldx       $04,s
                    ldd       ,x
                    std       $04,s
                    clrb
                    lda       $02,x
                    addd      $06,s
                    std       $06,s
                    puls      b,a
L276D               tfr       b,a
                    ldb       $07,s
                    ldx       $02,s
                    ldu       $04,s
                    decb
                    bne       L2781
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L2728
                    bra       L278B
L2781               decb
                    bne       L2799
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L2728
L278B               exg       d,u
                    addd      $04,s
                    exg       d,u
                    exg       d,x
                    adcb      $03,s
                    adca      $02,s
                    exg       d,x
L2799               os9       I$Seek
                    bcs       L2728
                    clra
                    clrb
                    rts

;---------------------------------------------
;
;---------------------------------------------
L27A1               tfr       d,x
                    os9       I$Delete
                    bcs       L2728
                    clra
                    clrb
                    rts

;---------------------------------------------
;
;---------------------------------------------
L27AB               os9       F$Exit
L27AE               bsr       L27B9
                    tfr       a,b
                    clra
                    rts

;---------------------------------------------
;
;---------------------------------------------
L27B9               pshs      y
                    os9       F$ID
                    tfr       y,x
                    puls      y
                    rts

name                equ       *
                    fcs       /dcheck/
                    fcb       edition

                    emod
eom                 equ       *
                    end
