* Shared I/O and formatting functions for Basic09 and RunB.
* RunB: INCLUDED=RUNTIM+MATHPAK (=6), INCLUDED&EDITOR=0 (ifeq TRUE=RunB branch)
* Basic09: INCLUDED=7, INCLUDED&EDITOR=1 (ifeq FALSE=else branch)

                    ifeq      INCLUDED&EDITOR
L25A7               fcb       6,2,39,16,3,232,0,100,0,10
                    else
L25A7
L50DA               fdb       OUTHEX-L50B2
L50DC               fdb       10000
                    fdb       1000
                    fdb       100
                    fdb       10
                    endc
L25B1
L50E4               fcb       $04
                    fdb       $a000,$0000,$07c8,$0000,$000a,$fa00,$0000
                    fdb       $0e9c,$4000,$0011,$c350,$0000,$14f4,$2400,$0018
                    fdb       $9896,$8000,$1bbe,$bc20,$001e,$ee6b,$2800,$2295
                    fdb       $02f9,$0025,$ba43,$b740,$28e8,$d4a5,$102c,$9184
                    fdb       $e72a,$2fb5,$e620,$f432,$e35f,$a932,$368e,$1bc9
                    fdb       $c039,$b1a2,$bc2e,$3cde,$0b6b
                    fcb       $3a
L260B
L513E               fcb       $40
                    fdb       $8ac7,$2304

TRUESTR
L5143               fcc       "True"
                    fcb       $ff
FALSESTR
L5148               fcc       "False"
                    fcb       $ff

AtoITR
ASCNUM               pshs      u
                    leay      -6,y
                    clra
                    clrb
                    sta       <u0075
                    sta       <u0076
                    sta       <u0077
                    sta       <u0078
                    sta       <u0079
                    std       $04,y
                    std       $02,y
                    sta       $01,y
                    lbsr      L285D
                    bcc       L263F
                    leax      -$01,x
                    cmpa      #$2C
                    bne       err59
                    lbra      L26C8

L263F               cmpa      #$24
                    lbeq      L277F
                    cmpa      #$2B
                    beq       L264F
                    cmpa      #$2D
                    bne       L2651
                    inc       <u0078
L264F               lda       ,x+
L2651               cmpa      #$2E
                    bne       iof_L265D
                    tst       <u0077
                    bne       err59
                    inc       <u0077
                    bra       L264F
iof_L265D               lbsr      L2CAB
                    bcs       L26B2
                    pshs      a
                    inc       <u0076
                    ldd       $04,y
                    ldu       $02,y
                    bsr       L2698
                    std       $04,y
                    stu       $02,y
                    bsr       L2698
                    bsr       L2698
                    addd      $04,y
                    exg       d,u
                    adcb      $03,y
                    adca      $02,y
                    bcs       L26A5
                    exg       d,u
                    addb      ,s+
                    adca      #$00
                    bcc       L268C
                    leau      1,u
                    stu       $02,y
                    beq       L26A7
L268C               std       $04,y
                    stu       $02,y
                    tst       <u0077
                    beq       L264F
                    inc       <u0079
                    bra       L264F
L2698               lslb
                    rola
                    exg       d,u
                    rolb
                    rola
                    exg       d,u
                    bcs       L26A3
                    rts
L26A3               leas      $02,s
L26A5               leas      $01,s
L26A7               ldb       #$3C
                    bra       L26AD
err59               ldb       #E$IONum
L26AD               stb       <u0036
                    coma
                    puls      pc,u
L26B2               eora      #$45
                    anda      #$DF
                    beq       L26DB
                    leax      -$01,x
                    tst       <u0076
                    bne       L26C0
                    bra       err59
L26C0               tst       <u0077
                    bne       L2709
                    ldd       $02,y
                    bne       L2709
L26C8               ldd       $04,y
                    bmi       L2709
                    tst       <u0078
                    beq       L26D4
                    nega
                    negb
                    sbca      #$00
L26D4               std       $01,y
L26D6               lda       #$01
                    lbra      L2762
L26DB               lda       ,x
                    cmpa      #$2B
                    beq       L26E7
                    cmpa      #$2D
                    bne       L26E9
                    inc       <u0075
L26E7               leax      $01,x
L26E9               lbsr      L2CA9
                    bcs       err59
                    tfr       a,b
                    lbsr      L2CA9
                    bcc       L26F9
                    leax      -$01,x
                    bra       L2700
L26F9               pshs      a
                    lda       #$0A
                    mul
                    addb      ,s+
L2700               tst       <u0075
                    bne       L2705
                    negb
L2705               addb      <u0079
                    stb       <u0079
L2709               ldb       #$20
                    stb       $01,y
                    ldd       $02,y
                    bne       L271A
                    cmpd      $04,y
                    bne       L271A
                    clr       $01,y
                    bra       L2760
L271A               tsta
                    bmi       iof_L2727
L271D               dec       $01,y
                    lsl       $05,y
                    rol       $04,y
                    rolb
                    rola
                    bpl       L271D
iof_L2727               std       $02,y
                    clr       <u0075
                    ldb       <u0079
                    beq       L2758
                    bpl       L2734
                    negb
                    inc       <u0075
L2734               cmpb      #$13
                    bls       L2748
                    subb      #$13
                    pshs      b
                    leau      >L260B,pcr
                    bsr       L2768
                    puls      b
                    lbcs      L26A7
L2748               decb
                    lda       #$05
                    mul
                    leau      >L25B1,pcr
                    leau      b,u
                    bsr       L2768
                    lbcs      L26A7
L2758               lda       $05,y
                    anda      #$FE
                    ora       <u0078
                    sta       $05,y
L2760               lda       #$02
L2762               sta       ,y
                    andcc     #^Carry
                    puls      pc,u

L2768
CNVOPR               leay      -$06,y
                    ifeq      INCLUDED&EDITOR
                    ldd       ,u
                    std       $01,y
                    ldd       2,u
                    std       $03,y
                    else
                    ifne      H6309
                    ldq       ,u
                    stq       1,y
                    else
                    ldd       ,u
                    std       1,y
                    ldd       2,u
                    std       3,y
                    endc
                    endc
                    ldb       4,u
                    stb       $05,y
                    lda       <u0075
                    ifeq      INCLUDED&EDITOR
                    lbeq      L256B
                    lbra      L256E
                    else
                    lbeq      L4234
                    lbra      L40D3
                    endc

L277F               lbsr      L2CA9
                    bcc       L2794
                    cmpa      #$61
                    bcs       L278A
                    suba      #$20
L278A               cmpa      #$41
                    bcs       L27A9
                    cmpa      #$46
                    bhi       L27A9
                    suba      #$37
L2794               inc       <u0076
                    ldb       #$04
L2798               lsl       $02,y
                    rol       $01,y
                    lbcs      L26A7
                    decb
                    bne       L2798
                    adda      $02,y
                    sta       $02,y
                    bra       L277F
L27A9               leax      -$01,x
                    tst       <u0076
                    lbeq      err59
                    lbra      L26D6

L2008
INPRL                pshs      x
                    ldx       <u0082
                    lbsr      AtoITR
                    bcc       L27BF
L27BD
ITYPER               puls      pc,x
L27BF
INPRL2               cmpa      #$02
                    beq       L27C6
                    ifeq      INCLUDED&EDITOR
                    lbsr      Flote
                    else
                    lbsr      L509B
                    endc
L27C6               lbsr      L2851
                    bcs       L27D2
                    ldb       #E$Illinp
                    stb       <u0036
                    coma
                    puls      pc,x
L27D2               stx       <u0082
                    clra
                    puls      pc,x

L2006
INPBYT               pshs      x
                    ldx       <u0082
                    lbsr      AtoITR
                    bcs       L27BD
                    cmpa      #$01
                    bne       err58
                    tst       $01,y
                    beq       L27C6
                    bra       err58

L2007
L531D                pshs      x
                    ldx       <u0082
                    lbsr      AtoITR
                    bcs       L27BD
                    cmpa      #$01
                    beq       L27C6
err58               ldb       #E$IOMism
                    stb       <u0036
                    coma
                    puls      pc,x

L2010
STRINP               pshs      u,x
                    leay      -$06,y
                    ldu       <u004A
                    stu       $01,y
                    lda       #$04
                    sta       ,y
                    ldx       <u0082
L280C               lda       ,x+
                    bsr       L2863
                    bcs       L2816
                    sta       ,u+
                    bra       L280C
L2816               stx       <u0082
                    lda       #$FF
                    sta       ,u+
                    stu       <u0048
                    clra
                    puls      pc,u,x

L20X9
INPBL                pshs      x
                    leay      -$06,y
                    lda       #$03
                    sta       ,y
                    clr       $02,y
                    ldx       <u0082
                    bsr       L285D
                    bcs       L284C
                    cmpa      #$54
                    beq       L2846
                    cmpa      #$74
                    beq       L2846
                    eora      #$46
                    anda      #$DF
                    beq       L2848
                    ldb       #E$IOMism
                    stb       <u0036
                    coma
                    puls      pc,x
L2846               com       $02,y
L2848               bsr       L2851
                    bcc       L2848
L284C               stx       <u0082
                    clra
                    puls      pc,x

L2851
SKPDEL               lda       ,x+
                    cmpa      #C$SPAC
                    bne       L2863
                    bsr       L285D
                    bcc       L2872
                    bra       L2874
L285D
SKPDL1               lda       ,x+
                    cmpa      #C$SPAC
                    beq       L285D
L2863               cmpa      <u00DD
                    beq       L2874
                    cmpa      #C$CR
                    beq       L2872
                    cmpa      #$FF
                    beq       L2872
                    andcc     #^Carry
                    rts
L2872
SKPDL3               leax      -$01,x
L2874
SKPDL4               orcc      #Carry
                    rts

L2877
INTSTR               pshs      u,x
                    clra
                    sta       $03,y
                    sta       <u0076
                    sta       <u0078
                    lda       #$04
                    sta       <u007E
                    ldd       $01,y
                    bpl       L288E
                    nega
                    negb
                    sbca      #$00
                    inc       <u0078
L288E               leau      >L25A7,pcr
L2892               clr       <u007A
                    leau      2,u
L2896               subd      ,u
                    bcs       L289E
                    inc       <u007A
                    bra       L2896
L289E               addd      ,u
                    tst       <u007A
                    bne       L28A8
                    tst       $03,y
                    beq       L28B3
L28A8               inc       $03,y
                    pshs      a
                    lda       <u007A
                    lbsr      L29B7
                    puls      a
L28B3               dec       <u007E
                    bne       L2892
                    tfr       b,a
                    lbsr      L29B7
                    leay      $06,y
                    puls      pc,u,x

RtoA
RLASC                pshs      u,x
                    clr       <u0075
                    clr       <u0078
                    clr       <u007C
                    clr       <u007B
                    clr       <u0079
                    clr       <u0076
                    leau      ,x
                    ldd       #$0A30
L28D3               stb       ,u+
                    deca
                    bne       L28D3
                    ldd       $01,y
                    bne       L28E0
                    inca
                    lbra      L29B1
L28E0               ldb       $05,y
                    bitb      #$01
                    beq       L28EC
                    stb       <u0078
                    andb      #$FE
                    stb       $05,y
L28EC               ldd       $01,y
                    bpl       L28F3
                    inc       <u0075
                    nega
L28F3               cmpa      #$03
                    bls       L2924
                    ldb       #$9A
                    mul
                    lsra
                    nop
                    nop
                    tfr       a,b
                    tst       <u0075
                    beq       L2904
                    negb
L2904               stb       <u0079
                    cmpa      #$13
                    bls       L2917
                    pshs      a
                    leau      >L260B,pcr
                    lbsr      L2768
                    puls      a
                    suba      #$13
L2917               leau      >L25B1,pcr
                    deca
                    ldb       #$05
                    mul
                    leau      d,u
                    lbsr      L2768
L2924               ldd       $02,y
                    tst       $01,y
                    beq       L2950
                    bpl       L293C
L292C               lsra
                    rorb
                    ror       $04,y
                    ror       $05,y
                    ror       <u007C
                    inc       $01,y
                    bne       L292C
                    std       $02,y
                    bra       L2950
L293C               lsl       $05,y
                    rol       $04,y
                    rolb
                    rola
                    rol       <u007B
                    dec       $01,y
                    bne       L293C
                    std       $02,y
                    inc       <u0079
                    lda       <u007B
                    bsr       L29B7
L2950               ldd       $02,y
                    ldu       $04,y
L2954               clr       <u007B
                    bsr       L29BE
                    std       $02,y
                    stu       $04,y
                    pshs      a
                    lda       <u007B
                    sta       <u007C
                    puls      a
                    bsr       L29BE
                    bsr       L29BE
                    exg       d,u
                    addd      $04,y
                    exg       d,u
                    adcb      $03,y
                    adca      $02,y
                    pshs      a
                    lda       <u007B
                    adca      <u007C
                    bsr       L29B7
                    lda       <u0076
                    cmpa      #$09
                    puls      a
                    beq       L298E
                    cmpd      #$0000
                    bne       L2954
                    cmpu      #$0000
                    bne       L2954
L298E               sta       ,y
                    lda       <u0076
                    cmpa      #$09
                    bcs       L29AF
                    ldb       ,y
                    bpl       L29AF
L299A               lda       ,-x
                    inca
                    sta       ,x
                    cmpa      #$39
                    bls       L29AF
                    lda       #$30
                    sta       ,x
                    cmpx      ,s
                    bne       L299A
                    inc       ,x
                    inc       <u0079
L29AF               lda       #$09
L29B1               sta       <u0076
                    leay      $06,y
                    puls      pc,u,x
L29B7
PUTDIG               ora       #$30
                    sta       ,x+
                    inc       <u0076
                    rts
L29BE               exg       d,u
                    lslb
                    rola
                    exg       d,u
                    rolb
                    rola
                    rol       <u007B
                    rts

READLN
INPLIN               pshs      y,x
                    ldx       <u0080
                    stx       <u0082
                    lda       #$01
                    sta       <u007D
                    ldy       #$0100
                    lda       <u007F
                    os9       I$ReadLn
                    bra       L29F1

WRITLN
OUTLIN               pshs      y,x
                    ldd       <u0082
                    subd      <u0080
                    beq       L29F5
                    tfr       d,y
                    ldx       <u0080
                    stx       <u0082
                    lda       <u007F
                    os9       I$WritLn
L29F1               bcc       L29F5
                    stb       <u0036
L29F5               puls      pc,y,x

setFP
                    ifeq      INCLUDED&EDITOR
                    else
SEEK
                    endc
                     pshs      u,x
                    lda       ,y
                    cmpa      #$02
                    beq       L2A03
                    ldu       $01,y
                    bra       L2A0A

L2A03               lda       $01,y
                    bgt       L2A0F
                    ldu       #$0000
L2A0A               ldx       #$0000
                    bra       iof_L2A2B
L2A0F               ldx       $02,y
                    ldu       $04,y
                    suba      #$20
                    bcs       L2A1C
                    ldb       #$4E
                    coma
                    bra       L2A32
L2A1C               exg       x,d
                    lsra
                    rorb
                    exg       d,u
                    rora
                    rorb
                    exg       d,x
                    exg       x,u
                    inca
                    bne       L2A1C
iof_L2A2B               lda       <u007F
                    os9       I$Seek
                    bcc       L2A34
L2A32               stb       <u0036
L2A34               puls      pc,u,x

PRreal
OUTRL                pshs      u,x
                    leas      -$0A,s
                    leax      ,s
                    lbsr      RtoA
                    pshs      x
                    lda       #$09
                    leax      $09,x
L2A45               ldb       ,-x
                    cmpb      #$30
                    bne       L2A50
                    deca
                    cmpa      #$01
                    bne       L2A45
L2A50               sta       <u0076
                    puls      x
                    ldb       <u0079
                    bgt       L2A79
                    negb
                    tfr       b,a
                    cmpb      #$09
                    bhi       L2A93
                    addb      <u0076
                    cmpb      #$09
                    bhi       L2A93
                    pshs      a
                    lbsr      L2B10
                    clra
                    bsr       L2ADF
                    puls      b
                    tstb
                    beq       L2A75
                    lbsr      L2B01
L2A75               lda       <u0076
                    bra       L2A8C
L2A79               cmpb      #$09
                    bhi       L2A93
                    lbsr      L2B10
                    tfr       b,a
                    bsr       L2ACE
                    bsr       L2ADF
                    lda       <u0076
                    suba      <u0079
                    bls       L2A8E
L2A8C               bsr       L2ACE
L2A8E               leas      $0A,s
                    clra
                    puls      pc,u,x
L2A93               bsr       L2B10
                    lda       #$01
                    bsr       L2ACE
                    bsr       L2ADF
                    lda       <u0076
                    deca
                    bne       L2AA1
                    inca
L2AA1               bsr       L2ACE
                    bsr       L2AA7
                    bra       L2A8E
L2AA7               lda       #$45
                    bsr       L2AE1
                    lda       <u0079
                    deca
                    pshs      a
                    bpl       L2AB8
                    neg       ,s
                    bsr       L2B14
                    bra       L2ABA
L2AB8               bsr       L2B18
L2ABA               puls      b
                    clra
L2ABD               subb      #$0A
                    bcs       L2AC4
                    inca
                    bra       L2ABD
L2AC4               addb      #$0A
                    bsr       L2ACA
                    tfr       b,a
L2ACA
OUTDIG               adda      #$30
                    bra       L2AE1
L2ACE
OUTZE1               tfr       a,b
                    tstb
                    beq       L2ADA
L2AD3               lda       ,x+
                    bsr       L2AE1
                    decb
                    bne       L2AD3
L2ADA               rts
L2ADB
OUTSP                lda       #$20
                    bra       L2AE1
L2ADF
L5612                lda       #$2E
L2AE1
OUTCHR               pshs      u,a
                    leau      <-$40,s
                    cmpu      <u0082
                    bhi       L2AF7
                    cmpa      #C$CR
                    beq       L2AF7
                    lda       #$50
                    sta       <u0036
                    sta       <u00DE
                    ifeq      INCLUDED&EDITOR
                    bra       L2AFF
                    else
                    puls      pc,u,a
                    endc
L2AF7
OUTCHR10             ldu       <u0082
                    sta       ,u+
                    stu       <u0082
                    inc       <u007D
                    ifeq      INCLUDED&EDITOR
L2AFF
                    endc
OUTCHR99             puls      pc,u,a
L2B01
OUTZER               lda       #$30
L2B03               tstb
                    beq       L2B0B
L2B06               bsr       L2AE1
                    decb
                    bne       L2B06
L2B0B               rts
L2B0C
SGNSPC               tst       <u0078
                    beq       L2ADB
L2B10
L5643                tst       <u0078
                    beq       L2B0B
L2B14
OUTMIN               lda       #$2D
                    bra       L2AE1
L2B18
L564B                lda       #$2B
                    bra       L2AE1
Spacing
MOVSTR               lda       #C$SPAC
                    bra       L2B03
L2B20
MOVST0               bsr       L2AE1
L2B22
L5655                lda       ,x+
                    cmpa      #$FF
                    bne       L2B20
                    rts

PRstring
L565C                pshs      x
                    ldx       $01,y
L2B2D               bsr       L2B22
                    clra
                    puls      pc,x

PRbool
OUTBL                pshs      x
                    leax      >TRUESTR,pcr
                    lda       $02,y
                    bne       L2B2D
                    leax      >FALSESTR,pcr
                    bra       L2B2D

PRintg
OUTINT               pshs      u,x
                    leas      -$05,s
                    leax      ,s
                    lbsr      L2877
                    bsr       L2B10
                    lda       <u0076
                    leax      ,s
                    lbsr      L2ACE
                    leas      $05,s
                    clra
                    puls      pc,u,x

L2015
OUTTAB               tfr       a,b
L2B5B
TAB                  pshs      u
                    ldu       <u0082
                    subb      <u007D
                    bls       L2B65
                    bsr       Spacing
L2B65               clra
                    puls      pc,u
L2B66
SKPZON               lbsr      L2ADB
L2B6B
SKPZ2                lda       <u007D
                    anda      #$0F
                    cmpa      #$01
                    beq       L2B7F
                    lbsr      L2ADB
                    bra       L2B6B

Strterm
OUTCR                lda       #C$CR
                    clr       <u007D
                    lbsr      L2AE1
L2B7F
SKIPZ3               clra
                    rts

OUTHEX               pshs      u
                    lda       #$04
                    leau      ,y
                    tst       ,u
                    bne       L2B8E
                    asra
                    leau      1,u
L2B8E               sta       <u0086
                    tfr       a,b
                    asrb
                    lbsr      L2D2A
                    puls      pc,u

L2B98
PRSJST               clrb
                    stb       <u0087
                    cmpa      #$3C
                    beq       L2BAB
                    cmpa      #$3E
                    bne       L2BA6
                    incb
                    bra       L2BAB
L2BA6               cmpa      #$5E
                    bne       iof_L2BAF
                    decb
L2BAB               stb       <u0087
                    lda       ,x+
iof_L2BAF
FDELIM               cmpa      #$2C
                    beq       L2BEB
                    cmpa      #$FF
                    bne       L2BC9
                    lda       <u0094
                    beq       L2BBF
                    leax      -$01,x
                    bra       L2BD4
L2BBF               ldx       <u008E
                    tst       <u00DC
                    beq       L2BCD
                    clr       <u00DC
                    bra       L2BEB
L2BC9               cmpa      #$29
                    beq       L2BD0
L2BCD               orcc      #Carry
                    rts
L2BD0               lda       <u0094
                    beq       L2BCD
L2BD4               dec       <u0092
                    bne       L2BE9
                    ldu       <u0046
                    pulu      y,a
                    sta       <u0092
                    sty       <u0090
                    stu       <u0046
                    lda       ,x+
                    dec       <u0094
                    bra       iof_L2BAF
L2BE9               ldx       <u0090
L2BEB               stx       <u008C
                    andcc     #^Carry
                    rts

L2BF0
L5723                fcb       'I
                    fdb       ARGUS1-L2BF0
L2BF3
L5726                fcb       'H
                    fdb       ARGUS1-L2BF3
L2BF6
L5729                fcb       'R
                    fdb       ARGUS2-L2BF6
L2BF9
L572C                fcb       'E
                    fdb       ARGUS2-L2BF9
L2BFD
L572F                fcb       'S
                    fdb       ARGUS1-L2BFD
L2C00
L5732                fcb       'B
                    fdb       ARGUS1-L2C00
L2C03
L5735                fcb       'T
                    fdb       ARGUS3-L2C03
L2C06
L5738                fcb       'X
                    fdb       ARGUS4-L2C06
L2C09
L573B                fcb       ''
                    fdb       ARGUS5-L2C09
                    fcb       $00

ARGUS3
TFMTP                bsr       iof_L2BAF
                    bcs       L2C74
                    ldb       <u0086
                    lbsr      L2B5B
                    bra       L2C3F

ARGUS4
XFMTP                bsr       iof_L2BAF
                    bcs       L2C74
                    ldb       <u0086
                    lbsr      Spacing
                    bra       L2C3F

ARGUS5
QFMTP                cmpa      #$FF
                    beq       L2C74
                    cmpa      #$27
                    bne       L2C32
                    lda       ,x+
                    bsr       iof_L2BAF
                    bcs       L2C74
                    bra       L2C3F
L2C32
QFMTP2               lbsr      L2AE1
                    lda       ,x+
                    bra       ARGUS5

PRNTUSIN
NXTFMT               pshs      y,x
                    clr       <u00DC
                    inc       <u00DC
L2C3F
NXTFM1               ldx       <u008C
                    bsr       L2C8F
                    bcs       L2C5E
                    cmpa      #$28
                    bne       L2C78
                    lda       <u0092
                    stb       <u0092
                    beq       L2C78
                    inc       <u0094
                    ldu       <u0046
                    ldy       <u0090
                    pshu      y,a
                    stu       <u0046
                    stx       <u0090
                    lda       ,x+
L2C5E
                    ifeq      INCLUDED&EDITOR
NXTFM3               leay      >L2BF0,pcr
                    else
NXTFM3               leay      L2BF0,pcr
                    endc
                    clrb
L2C63
NXTFM4               pshs      a
                    eora      ,y
                    anda      #$DF
                    puls      a
                    beq       L2C7F
                    leay      $03,y
                    incb
                    tst       ,y
                    bne       L2C63
L2C74
RPTERR               ldb       #$3F
                    bra       L2C7A
L2C78
L57AB                ldb       #E$IOFRpt
L2C7A
FMEXIT               stb       <u0036
                    coma
                    puls      pc,y,x

L2C7F
L57B2                stb       <u0085
                    ldd       $01,y
                    leay      d,y
                    bsr       L2C8F
                    bcc       L2C8B
                    ldb       #$01
L2C8B               stb       <u0086
                    jmp       ,y

L2C8F
FMTNUM               bsr       L2CA9
                    ifeq      INCLUDED&EDITOR
                    bcs       L2CB8
                    else
                    bcs       L57ED
                    endc
                    tfr       a,b
                    bsr       L2CA9
                    bcs       L2CB5
                    bsr       iof_L2CBB
                    bsr       L2CA9
                    bcs       L2CB5
                    bsr       iof_L2CBB
                    tsta
                    beq       L2CA5
                    clrb
L2CA5               lda       ,x+
                    bra       L2CB5

L2CA9
L57DC                lda       ,x+
L2CAB
CHKDIG               cmpa      #'0
                    ifeq      INCLUDED&EDITOR
                    bcs       L2CB8
                    else
                    blo       L57ED
                    endc
                    cmpa      #'9
                    bhi       L2CB8
                    suba      #'0
L2CB5
L57E8                andcc     #^Carry
                    rts
L2CB8
BADNUM               orcc      #Carry
                    ifeq      INCLUDED&EDITOR
                    else
L57ED
                    endc
                    rts
iof_L2CBB
BLDNUM               pshs      a
                    lda       #10
                    mul
                    addb      ,s+
                    adca      #$00
                    rts

ARGUS2
RFMTP                cmpa      #$2E
                    bne       L2C74
                    bsr       L2C8F
                    bcs       L2C74
                    stb       <u0089

ARGUS1
L5802                lbsr      L2B98
                    bcs       L2C74
                    puls      y,x
                    inc       <u00DC
L2018
EXCFMT               ldb       <u0085
                    lbeq      FMTint
                    decb
                    beq       L2CF3
                    decb
                    lbeq      L2E36
                    decb
                    lbeq      FMTexp
                    decb
                    lbeq      FMTstr
                    lbra      FMTbool

L2CF3
L5826                jsr       <u0016
                    cmpa      #$04
                    bcs       L2D09
                    ldu       $01,y
                    clrb
L2CFC               lda       ,u+
                    cmpa      #$FF
                    beq       L2D05
                    incb
                    bne       L2CFC
L2D05               ldu       $01,y
                    bra       L2D2A
L2D09
H.FMT4               leau      $01,y
                    lda       ,y
                    cmpa      #$02
                    bne       L2D15
                    ldb       #$05
                    bra       L2D2A
L2D15               cmpa      #$01
                    bne       L2D1F
                    ldb       #$02
                    cmpb      <u0086
                    bcs       iof_L2D23
L2D1F               ldb       #$01
                    leau      1,u
iof_L2D23               tfr       b,a
                    lsla
                    cmpa      <u0086
                    bhi       iof_L2D60
L2D2A
HEXOUT               tst       <u0087
                    beq       L2D56
                    bmi       L2D3D
                    pshs      b
                    lslb
                    pshs      b
                    ldb       <u0086
                    subb      ,s+
                    bcs       L2D54
                    bra       L2D49
L2D3D               pshs      b
                    lslb
                    pshs      b
                    ldb       <u0086
                    subb      ,s+
                    bcs       L2D54
                    asrb
L2D49               pshs      b
                    lda       <u0086
                    suba      ,s+
                    sta       <u0086
                    lbsr      Spacing
L2D54               puls      b
L2D56
HEXO10               lda       ,u
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L2D70
                    beq       L2D6E
iof_L2D60
L5893                lda       ,u+
                    bsr       L2D70
                    beq       L2D6E
                    decb
                    bne       L2D56
                    ldb       <u0086
                    lbsr      Spacing
L2D6E
HEXO90               clra
                    rts

L2D70
HEXCHR               anda      #$0F
                    cmpa      #$09
                    bls       L2D78
                    adda      #$07
L2D78               lbsr      L2ACA
                    dec       <u0086
                    rts

L2D7E
FMSMAT               coma
                    rts

FMTint
I.FMT                jsr       <u0016
                    cmpa      #$02
                    bcs       iof_L2D8B
                    bne       L2D7E
                    ifeq      INCLUDED&EDITOR
                    lbsr      L2565
                    else
                    lbsr      L5098
                    endc
iof_L2D8B
I.FMT1               pshs      u,x
                    leas      -$05,s
                    leax      ,s
                    lbsr      L2877
                    ldb       <u0086
                    decb
                    subb      <u0076
                    bpl       iof_L2DA2
                    leas      $05,s
                    puls      u,x
                    lbra      Overflow

iof_L2DA2
L58D5                tst       <u0087
                    beq       iof_L2DB0
                    bmi       L2DC1
                    lbsr      Spacing
                    lbsr      L2B0C
                    bra       L2DC7

iof_L2DB0               lbsr      L2B0C
                    pshs      b
                    lda       <u0076
                    lbsr      L2ACE
                    puls      b
                    lbsr      Spacing
                    bra       L2DCC

L2DC1               lbsr      L2B0C
                    lbsr      L2B01
L2DC7               lda       <u0076
                    lbsr      L2ACE
L2DCC               leas      $05,s
                    clra
                    puls      pc,u,x

FMTbool
L5904                jsr       <u0016
                    cmpa      #$03
                    bne       L2D7E
                    pshs      u,x
                    leax      >TRUESTR,pcr
                    ldb       #$04
                    lda       $02,y
                    bne       L2DFF
                    leax      >FALSESTR,pcr
                    ldb       #$05
                    bra       L2DFF

FMTstr
S.FMT                jsr       <u0016
                    cmpa      #$04
                    bne       L2D7E
                    pshs      u,x
                    ldx       $01,y
                    ldd       <u0048
                    subd      $01,y
                    subd      #$0001
                    tsta
                    bne       L2E03
L2DFF
S.FMT1               cmpb      <u0086
                    bls       L2E05
L2E03
S.FMT2               ldb       <u0086
L2E05
S.FMT3               tfr       b,a
                    negb
                    addb      <u0086
                    tst       <u0087
                    beq       L2E1C
                    bmi       L2E20
                    pshs      a
                    lbsr      Spacing
                    puls      a
                    lbsr      L2ACE
                    bra       L2E33
L2E1C
L594F                pshs      b
                    bra       L2E2B
L2E20
S.FMTC               lsrb
                    bcc       L2E24
                    incb
L2E24
S.FMT4               pshs      b,a
                    lbsr      Spacing
                    puls      a
L2E2B
L595E                lbsr      L2ACE
                    puls      b
                    lbsr      Spacing
L2E33
S.FMTX               clra
                    puls      pc,u,x

L2E36
R.FMT                jsr       <u0016
                    cmpa      #$02
                    beq       L2E43
                    lbcc      L2D7E
                    ifeq      INCLUDED&EDITOR
                    lbsr      Flote
                    else
                    lbsr      L509B
                    endc
L2E43
R.FMT1               pshs      u,x
                    leas      -$0A,s
                    leax      ,s
                    lbsr      RtoA
                    lda       <u0079
                    cmpa      #$09
                    bgt       L2E63
                    lbsr      L2F37
                    lda       <u0086
                    suba      #$02
                    bmi       L2E63
                    suba      <u0089
                    bmi       L2E63
                    suba      <u008A
                    bpl       L2E69
L2E63
R.FMTE               leas      $0A,s
                    puls      u,x
                    bra       Overflow

L2E69
R.FMT2               sta       <u0088
                    leax      ,s
                    ldb       <u0087
                    beq       iof_L2E79
                    bmi       iof_L2E7F
                    bsr       L2EB6
                    bsr       L2E8B
                    bra       L2E86
iof_L2E79               bsr       L2E8B
                    bsr       L2EB6
                    bra       L2E86
iof_L2E7F
OUTRNS               bsr       L2EB6
                    bsr       L2E8E
                    lbsr      L2B0C
L2E86
R.FMTX               leas      $0A,s
                    clra
                    puls      pc,u,x
L2E8B
L59BE                lbsr      L2B0C
L2E8E
OUTRN                lda       <u008A
                    lbsr      L2ACE
                    lbsr      L2ADF
                    ldb       <u0079
                    bpl       L2EC6
                    negb
                    cmpb      <u0089
                    bls       L2EA1
                    ldb       <u0089
L2EA1
OUTRN1               pshs      b
                    lbsr      L2B01
                    ldb       <u0089
                    subb      ,s+
                    stb       <u0089
                    lda       <u008B
                    cmpa      <u0089
                    bls       L2EB4
                    lda       <u0089
L2EB4
OUTRN2               bra       L2EC8

L2EB6
SPCFIL               ldb       <u0088
                    lbra      Spacing
L2EBB
OUTFP0               lbsr      L2B0C
                    lda       <u008A
                    lbsr      L2ACE
                    lbsr      L2ADF
L2EC6
L59F9                lda       <u008B
L2EC8
OUTFP2               lbsr      L2ACE
                    ldb       <u0089
                    subb      <u008B
                    ble       iof_L2EDC
                    lbra      L2B01

Overflow
L5A07                ldb       <u0086
                    lda       #'*
                    lbsr      L2B03
                    clra
iof_L2EDC
BADRTS               rts

FMTexp
L5A10                jsr       <u0016
                    cmpa      #$02
                    beq       L2EEA
                    lbcc      L2D7E
                    ifeq      INCLUDED&EDITOR
                    lbsr      Flote
                    else
                    lbsr      L509B
                    endc
L2EEA
E.FMT0               pshs      u,x
                    leas      -$0A,s
                    leax      ,s
                    lbsr      RtoA
                    lda       <u0079
                    pshs      a
                    lda       #$01
                    sta       <u0079
                    bsr       L2F37
                    puls      a
                    ldb       <u0079
                    cmpb      #$01
                    beq       L2F06
                    inca
L2F06               ldb       #$01
                    stb       <u008A
                    sta       <u0079
                    lda       <u0086
                    suba      #$06
                    bmi       L2F1A
                    suba      <u0089
                    bmi       L2F1A
                    suba      <u008A
                    bpl       L2F20
L2F1A               leas      $0A,s
                    puls      u,x
                    bra       Overflow
L2F20
E.FMT2               sta       <u0088
                    ldb       <u0087
                    beq       L2F2F
                    bsr       L2EB6
                    bsr       L2EBB
                    lbsr      L2AA7
                    bra       L2F34
L2F2F               bsr       L2EBB
                    lbsr      L2AA7
L2F34
E.FMTX               lbra      L2E86

L2F37
RNDRL                pshs      x
                    lda       <u0079
                    adda      <u0089
                    bne       L2F45
                    lda       ,x
                    cmpa      #$35
                    bcc       L2F5C
L2F45               deca
                    bmi       L2F78
                    cmpa      #$07
                    bhi       L2F78
                    leax      a,x
                    ldb       $01,x
                    cmpb      #$35
                    bcs       L2F78
L2F54               inc       ,x
                    ldb       ,x
                    cmpb      #$39
                    bls       L2F78
L2F5C               ldb       #$30
                    stb       ,x
                    leax      -$01,x
                    cmpx      ,s
                    bcc       L2F54
                    ldx       ,s
                    leax      $08,x
L2F6A               lda       ,-x
                    sta       $01,x
                    cmpx      ,s
                    bhi       L2F6A
                    lda       #$31
                    sta       ,x
                    inc       <u0079
L2F78               puls      x
                    lda       <u0079
                    bpl       iof_L2F7F
                    clra
iof_L2F7F               sta       <u008A
                    nega
                    adda      #$09
                    bpl       L2F87
                    clra
L2F87               cmpa      <u0089
                    bls       L2F8D
                    lda       <u0089
L2F8D               sta       <u008B
                    rts

err48
UNIMPL               ldb       #E$NoRout
                    stb       <u0036
                    coma
                    rts
