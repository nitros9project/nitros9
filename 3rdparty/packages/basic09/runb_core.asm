tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       22
B09RUNB             set       1
                    ifndef    EDITOR
EDITOR              equ       $01
                    endc
                    ifndef    RUNTIM
RUNTIM              equ       $02
                    endc
                    ifndef    MATHPAK
MATHPAK             equ       $04
                    endc
                    ifndef    INCLUDED
INCLUDED            set       RUNTIM+MATHPAK
                    endc

L0000               mod       eom,name,tylg,atrv,start,dsize

membase             rmb       2
memsize             rmb       2
moddir              rmb       4
restop              rmb       2                   top or reserved space
u000A               rmb       1
u000B               rmb       1
freemem             rmb       2
table1              rmb       2
table2              rmb       2
table3              rmb       2
u0014               rmb       2
u0016               rmb       1
u0017               rmb       1
u0018               rmb       1
u0019               rmb       2
u001B               rmb       1
u001C               rmb       2
u001E               rmb       1
u001F               rmb       2
u0021               rmb       1
u0022               rmb       2
u0024               rmb       2
u0026               rmb       1
u0027               rmb       1
u0028               rmb       2
u002A               rmb       3
u002D               rmb       1
errpath             rmb       1
pgmaddr             rmb       1                   starting address of program
u0030               rmb       1
u0031               rmb       1
u0032               rmb       1
u0033               rmb       1
u0034               rmb       1
u0035               rmb       1
u0036               rmb       3
DATAPtr             rmb       2
u003B               rmb       1
u003C               rmb       2
u003E               rmb       1
u003F               rmb       1
u0040               rmb       2
u0042               rmb       1
u0043               rmb       1
u0044               rmb       2
u0046               rmb       2
u0048               rmb       2
u004A               rmb       1
u004B               rmb       1
u004C               rmb       1
u004D               rmb       1
u004E               rmb       2
u0050               rmb       1
u0051               rmb       1
u0052               rmb       1
u0053               rmb       1
u0054               rmb       1
u0055               rmb       1
u0056               rmb       1
u0057               rmb       1
u0058               rmb       1
u0059               rmb       1
u005A               rmb       2
u005C               rmb       2
u005E               rmb       1
u005F               rmb       1
u0060               rmb       2
u0062               rmb       2
u0064               rmb       2
u0066               rmb       1
u0067               rmb       1
u0068               rmb       2
u006A               rmb       1
u006B               rmb       1
u006C               rmb       1
u006D               rmb       1
u006E               rmb       2
u0070               rmb       2
u0072               rmb       2
u0074               rmb       1
u0075               rmb       1
u0076               rmb       1
u0077               rmb       1
u0078               rmb       1
u0079               rmb       1
u007A               rmb       1
u007B               rmb       1
u007C               rmb       1
u007D               rmb       1
u007E               rmb       1
u007F               rmb       1
u0080               rmb       1
u0081               rmb       1
u0082               rmb       3
u0085               rmb       1
u0086               rmb       1
u0087               rmb       1
u0088               rmb       1
u0089               rmb       1
u008A               rmb       1
u008B               rmb       1
u008C               rmb       1
u008D               rmb       1
u008E               rmb       2
u0090               rmb       1
u0091               rmb       1
u0092               rmb       1
u0093               rmb       1
u0094               rmb       1
u0095               rmb       1
u0096               rmb       1
u0097               rmb       2
u0099               rmb       1
u009A               rmb       1
u009B               rmb       1
u009C               rmb       1
u009D               rmb       1
u009E               rmb       2
u00A0               rmb       2
u00A2               rmb       1
u00A3               rmb       1
u00A4               rmb       1
u00A5               rmb       1
u00A6               rmb       1
u00A7               rmb       1
u00A8               rmb       1
u00A9               rmb       1
u00AA               rmb       1
u00AB               rmb       1
u00AC               rmb       1
u00AD               rmb       1
u00AE               rmb       1
u00AF               rmb       2
u00B1               rmb       2
u00B3               rmb       1
u00B4               rmb       3
u00B7               rmb       2
u00B9               rmb       1
u00BA               rmb       1
u00BB               rmb       1
u00BC               rmb       1
u00BD               rmb       1
u00BE               rmb       3
u00C1               rmb       1
u00C2               rmb       2
u00C4               rmb       1
u00C5               rmb       1
u00C6               rmb       3
u00C9               rmb       1
u00CA               rmb       1
u00CB               rmb       1
u00CC               rmb       1
u00CD               rmb       1
u00CE               rmb       1
u00CF               rmb       1
u00D0               rmb       1
u00D1               rmb       1
u00D2               rmb       1
u00D3               rmb       4
u00D7               rmb       2
u00D9               rmb       1
u00DA               rmb       2
u00DC               rmb       1
u00DD               rmb       1
u00DE               rmb       1
u00DF               rmb       1
u00E0               rmb       1
u00E1               rmb       1
u00E2               rmb       3
u00E5               rmb       2
u00E7               rmb       1
u00E8               rmb       2
u00EA               rmb       1
u00EB               rmb       3
u00EE               rmb       3
u00F1               rmb       1
u00F2               rmb       3
u00F5               rmb       4
u00F9               rmb       1
u00FA               rmb       3
u00FD               rmb       1
u00FE               rmb       1
u00FF               rmb       1
u0100               rmb       3840
dsize               equ       .

L000D               fdb       L00D9
                    fdb       L0468
                    fdb       L06D8
                    fdb       L06EB
                    fdb       L10DF
                    fdb       L2551
                    fdb       $0000

name                fcs       /RunB/
                    fcb       edition

                    fcb       $06
                    fcb       $0C
                    fcc       "            BASIC09"
                    fcb       C$LF
                    fcc       "      RS VERSION 01.00.00"
                    fcb       C$LF
                    fcc       "COPYRIGHT 1980 BY MOTOROLA INC."
                    fcb       C$LF
                    fcc       "  AND MICROWARE SYSTEMS CORP."
                    fcb       C$LF
                    fcc       "   REPRODUCED UNDER LICENSE"
                    fcb       C$LF
                    fcc       "       TO TANDY CORP."
                    fcb       C$LF
                    fcc       "    ALL RIGHTS RESERVED."
                    fcb       $8A
* Jump vector @ $1B goes here
L00D9               pshs      d,x
                    ldb       [$04,s]
                    leax      <L00E9,pcr
                    ldd       b,x
                    leax      d,x
                    stx       $04,s
                    puls      d,x,pc

L00E9               fdb       L03E9-L00E9
                    fdb       L040E-L00E9
                    fdb       L024E-L00E9
                    fdb       L0244-L00E9
                    fdb       L0412-L00E9
                    fdb       L0365-L00E9
                    fdb       L035F-L00E9
                    fdb       L0381-L00E9
                    fdb       L0433-L00E9

L00FB               jsr       <u001E
                    fcb       $04
L00FE               jsr       <u001E
                    fcb       $02
L0101               jsr       <u001E
                    fcb       $00
L0104               jsr       <u0021
                    fcb       $00
L0107               jsr       <u0024
                    fcb       $00
L010A               jsr       <u0024
                    fcb       $04
L010D               jsr       <u0024
                    fcb       $02
L0110               jsr       <u002A
                    fcb       $02

                    fcb       $0e
                    fcs       "Ready"
                    fcs       "What?"
                    fcs       " free"
L0123               fcs       "Program"
                    fcs       "PROCEDURE"
                    fcb       C$CR
                    fcb       C$LF
                    fcs       "  Name      Proc-Size  Data-Size"
                    fcc       "Rewrite?: "
                    fcc       "RANGE"
                    fcb       $87
                    fcb       $0E
                    fcs       "BREAK: "
                    fcs       "called by"
                    fcs       "ok"
                    fcs       "D:"
                    fcs       "E:"
                    fcs       "B:"
                    fcs       "can't find:"

L0189               lda       R$DP,s
                    tfr       a,dp
                    stb       <u0035
                    lsl       <u0034
                    coma
                    ror       <u0034
                    rti

start               pshs      u                   save start of data mem into D
                    leau      256,u               point to end of DP
                    clra                          clear all of DP to $00
                    clrb
L019D               std       ,--u
                    cmpu      ,s
                    bhi       L019D
                    puls      b,a                 get start of data mem into D
                    leau      ,x                  point U to start of parameter area
                    std       <membase            preserve start of data memory ptr
                    inca                          point to $100 in data area
                    sta       <u00D9              preserve it
                    std       <u0080              initialize ptr to start of temp buffer
                    std       <u0082              initialize current pos. in temp buffer
                    adda      #$02
                    std       <u0046
                    std       <u0044
                    inca
                    tfr       d,s
                    std       <moddir
                    inca
                    std       <restop
                    std       <u004A
                    tfr       u,d
                    subd      <membase
                    std       <memsize
                    clra
                    ldb       #$01                default err path
                    std       <u002D
                    sta       <u00BD
                    lda       #$03                close paths 4-16
L01D0               os9       I$Close
                    inca
                    cmpa      #16
                    bcs       L01D0
                    lda       #$02
                    os9       I$Dup
                    sta       <u00BE
                    clr       <u0035
                    pshs      x
                    leax      <L0189,pcr
                    os9       F$Icpt
                    ldx       <restop
                    clra
                    clrb
L01ED               std       ,--x
                    cmpx      <moddir
                    bhi       L01ED
                    leax      >L0000,pcr
                    pshs      x
                    ldx       <membase
                    leax      <$1B,x
                    leay      >L000D,pcr
L0202               lda       #$7E
                    sta       ,x+
                    ldd       ,y++
                    addd      ,s
                    std       ,x++
                    ldd       ,y
                    bne       L0202
                    leas      $02,s
                    lbsr      L0107
                    puls      y
                    bsr       L0222
                    ldx       <moddir
                    ldd       ,x
                    std       <pgmaddr
                    lbsr      L02B9
L0222               leax      <L025B,pcr
                    puls      u
                    bsr       L024E
                    pshs      u
                    clr       <u0034
                    ldd       <membase
                    addd      <memsize
                    subd      <restop
                    subd      <u000A
                    std       <freemem
                    leau      $02,s
                    stu       <u0046
                    stu       <u0044
                    leas      >-$00FE,s
                    jmp       [<-2,u]
L0244               lds       <u00B7
                    puls      b,a
                    std       <u00B7
                    lbra      L02AD
L024E               ldd       <u00B7
                    pshs      b,a
                    sts       <u00B7
                    ldd       $02,s
                    stx       $02,s
                    tfr       d,pc
L025B               bsr       L0222
                    lbra      BYE
                    ldb       #$2C
L0262               lbsr      L040E
                    lbra      L0244
L0268               ldb       #$2B
                    bra       L0262
                    ldb       ,y+
                    cmpb      #$2C
                    beq       L0278
                    cmpb      #$20
                    beq       L0278
                    leay      -$01,y
L0278               rts
L0279               lbsr      L00FE
                    bne       L028C
                    ldy       <pgmaddr
                    beq       L0288
                    ldd       $04,y
                    leay      d,y
                    rts
L0288               leay      >L0123,pcr
L028C               rts
L028D               ldu       <u0046
                    stu       <u0044
                    ldx       <moddir
L0293               ldd       ,x
                    beq       L029B
                    tfr       x,d
                    leax      $02,x
L029B               std       ,--u
                    bne       L0293
                    stu       <u0044
                    lda       ,y
                    cmpa      #$0D
                    beq       L02A9
                    leay      $01,y
L02A9               sty       <u0082
                    rts
L02AD               clr       <u007D
                    inc       <u007D
                    pshs      x
                    ldx       <u0080
                    stx       <u0082
                    puls      pc,x
L02B9               lbsr      L00FE
                    bne       L02D1
                    pshs      y
                    lbsr      L0279
                    ldx       ,s
L02C5               lda       ,y+
                    sta       ,x+
                    bpl       L02C5
                    lda       #$0D
                    sta       ,x
                    puls      y
L02D1               lbsr      L03E9
                    lbcs      L0268
                    ldx       ,x
                    stx       <pgmaddr
                    lda       $06,x
                    beq       L02E8
                    anda      #$0F
                    cmpa      #$02                Basic09 program?
                    bne       L035A
                    bra       L02EE

L02E8               lda       <$17,x              Basic09 program has no errors?
                    rora
                    bcs       L035A               errors, report it
L02EE               lbsr      L0101               check param list
                    ldy       <u004A
                    ldb       ,y
                    cmpb      #$3D
                    beq       L035A
                    sty       <u005E
                    sty       <u005C
                    ldx       <u00AB
                    stx       <u0060
                    stx       <u004A
                    ldd       <freemem
                    pshs      y,b,a
                    lbsr      L0104
                    puls      y,b,a
                    std       <freemem
                    sty       <u004A
                    ldx       <pgmaddr
                    lda       <$17,x
                    rora
                    bcs       L035A
                    leas      >$0102,s
                    ldd       <membase
                    addd      <memsize
                    tfr       d,y
                    std       <u0046
                    std       <u0044
                    ldu       #$0000
                    stu       <u0031
                    stu       <u00B3
                    inc       <u00B4
                    clr       <u0036
                    ldd       <u004A
                    ldx       <freemem
                    pshs      x,b,a
                    leax      >L0351,pcr
                    lbsr      L024E
                    ldx       <u004A
                    lbsr      L010A
                    lbsr      L02AD
                    ldx       <pgmaddr
                    lbsr      L010D
                    bra       L0357
L0351               puls      x,b,a
                    std       <u004A
                    stx       <freemem
L0357               lbra      L0244
L035A               ldb       #$33
                    lbra      L0262

BYE
L035f               bsr       L0381
                    clrb
                    os9       F$Exit

L0365               lbsr      L00FE
                    beq       L037D
                    lbsr      L03C6
                    bcs       L037D
                    ldu       <u0046
                    clra
                    clrb
                    pshu      x,b,a
                    inca
                    sta       <u0035
                    bsr       L0391
                    clr       <u0035
                    rts
L037D               comb
                    ldb       #E$UnkPrc
                    rts
L0381               ldy       <u0082
                    lda       #$2A
                    sta       ,y
                    sta       <u0035
                    lbsr      L028D
                    clr       <pgmaddr
                    clr       <u0030
L0391               ldu       <u0046
                    stu       <u0044
                    bra       L03A7
L0397               ldx       ,x
                    pshs      u
                    leau      ,x
                    os9       F$UnLink
                    puls      u
                    ldd       #$FFFF
                    std       [,u]
L03A7               ldx       ,--u
                    bne       L0397
                    ldx       <moddir
                    tfr       x,y
L03AF               ldd       ,x++
                    cmpd      #$FFFF
                    beq       L03AF
L03B7               std       ,y++
                    bne       L03AF
                    cmpd      ,y
                    bne       L03B7
                    rts
L03C1               ldb       #$20
                    lbra      L0262
L03C6               pshs      u,y
                    ldx       <moddir
L03CA               ldy       ,s
                    ldu       ,x++
                    beq       L03E6
                    ldd       4,u
                    leau      d,u
L03D5               lda       ,y+
                    eora      ,u+
                    anda      #$DF
                    bne       L03CA
                    clra
                    tst       -1,u
                    bpl       L03D5
L03E2               leax      -$02,x
                    puls      pc,u,b,a
L03E6               coma
                    bra       L03E2
L03E9               bsr       L03C6
                    bcs       L03EE
                    rts
L03EE               pshs      u,y,x
                    ldb       $01,s
                    cmpb      #$FE
                    beq       L03C1
                    leax      ,y
                    clra
                    clrb
                    os9       F$Link
                    bcc       L0408
                    ldx       $02,s
                    clra
                    clrb
                    os9       F$Load
                    bcs       L040C
L0408               stx       $02,s
                    stu       [,s]
L040C               puls      pc,u,y,x

L040E               os9       F$PErr
                    rts

UNID1
L0412               pshs      b,a
                    bra       L0426
L0416               pshs      y,x
L0418               lda       ,x+
                    cmpa      #$FF
                    beq       L042E
                    cmpa      ,y+
                    beq       L0418
                    puls      y,x
                    leay      $01,y
L0426               cmpy      ,s
                    bls       L0416
                    coma
                    puls      pc,b,a
L042E               puls      y,x
                    clra
L0431               puls      pc,b,a              this probably does not need lable
L0433               pshs      x,b,a
L0435               leax      <L0442,pcr
                    lda       ,y+
L043A               cmpa      ,x++
                    bcs       L043A
                    ldb       ,-x
                    jmp       b,x

*embedded jumptable            second value
L0442               fcb       $f2
                    fcb       L045A-*             *$17
L0444               fcb       $92
                    fcb       L045E-*             *$19
L0446               fcb       $91
                    fcb       L045A-*             *$13
L0448               fcb       $90
                    fcb       L0460-*             *$17
L044A               fcb       $8f
                    fcb       L0458-*             *$0D
L044C               fcb       $8e
                    fcb       L045A-*             *$0D
L044E               fcb       $8d
                    fcb       L045C-*             *$0D
L0450               fcb       $55
                    fcb       L045A-*             *$09
L0452               fcb       $4b
                    fcb       L045E-*             *$0B
L0454               fcb       $3e
                    fcb       L0466-*             *$11
L0456               fcb       $00
                    fcb       L045E-*             *$07
L0458               leay      $03,y
L045A               leay      $01,y
L045C               leay      $01,y
L045E               bra       L0435
L0460               tst       ,y+
                    bpl       L0460
                    bra       L0435
L0466               puls      pc,x,b,a

L0468               pshs      x,b,a
                    ldb       [<$04,s]
                    leax      <L0478,pcr
                    ldd       b,x
                    leax      d,x
                    stx       $04,s
                    puls      pc,x,b,a

L0478               fdb       LAX1-L0478
                    fdb       LAX2-L0478
                    fdb       L06A8-L0478
                    fdb       L0686-L0478

L0480               jsr       <u001B
                    fcb       $02
L0483               jsr       <u001B
                    fcb       $04
L0486               jsr       <u001B
                    fcb       $06
L0489               jsr       <u002A
                    fcb       $00
                    fdb       $0007
                    fcb       $03
L048F               fcb       $cb
                    fdb       $4b0c,$accb,$4d0c,$a8cb,$4e0c,$a9d4,$890c,$ae21
                    fdb       $9006,$a200,$9106,$a4cb,$3f02
                    fcb       $8d

L04AB               lda       <u000B
L04AD               pshs      a
                    ldx       <u00A7
                    lda       #$0D
L04B3               lsl       ,x
                    lsr       ,x
                    cmpa      ,x+
                    bne       L04B3
                    ldx       <u00A7
                    bsr       PrintErr
                    ldd       <u00B9
                    subd      <u00A7
                    pshs      b
                    ldx       <u00AF
                    stx       <u00AB
                    ldy       <u00A7
                    lda       #$3D
                    lbsr      L0607
                    lda       #$3F
                    lbsr      L0607
                    lda       #$20
                    ldx       <u0080
L04DA               sta       ,x+
                    dec       ,s
                    bpl       L04DA
                    ldd       #$5E0D
                    std       -$01,x
                    ldx       <u0080
                    bsr       PrintErr
                    puls      b,a
                    lbsr      L0480
                    ldx       <u0046
                    stx       <u0044
                    lbra      L0486

PrintErr            ldy       #$0100
                    lda       <errpath
                    os9       I$WritLn
                    rts

**** decode passed parameters ****
L04FF               sty       <u00A7
                    ldx       <u004A
                    stx       <u00AF
                    stx       <u00AB
                    clr       <u00BB
                    clr       <u00BC
                    rts

LAX1                bsr       L04FF
                    inc       <u00A0
                    lbsr      L0542
                    bsr       L0523
                    clr       <u00A0
                    lda       <u00A3
                    cmpa      #$3F
                    lbne      L04AB
L0520               lbra      L0607
L0523               cmpa      #$4D
                    bne       L0541
L0527               bsr       L0520
                    ldd       <u00AB
                    lbsr      L056B
                    ldb       <u00A4
                    cmpb      #$06
                    bne       L0541
                    lbsr      L0542
                    lbsr      L054C
                    beq       L0527
                    pshs      a
                    lbra      L055D
L0541               rts
L0542               lbsr      L056B
                    ldx       <u00AD
                    stx       <u00AB
                    lda       <u00A3
                    rts
L054C               lda       <u00A3
                    cmpa      #$4B
                    rts
L0551               rts
L0552               lda       <u00A3
                    cmpa      #$4E
                    beq       L0551
                    lda       #$25
L055A               lbra      L04AD
L055D               bsr       L0552
                    puls      a
                    lbsr      L0607
                    lbra      L0542
L0567               lda       #$0A
                    bra       L055A
L056B               ldd       <u00AB
                    std       <u00AD
                    lbsr      SkipSpac
                    sty       <u00B9
                    lda       ,y
                    lbsr      IsNum
                    bcc       L05A0
                    leax      >L048F,pcr
                    lda       #$80
                    lbsr      L06A8
                    beq       L0567
                    ldb       ,x
                    leau      <L05C3,pcr
                    jmp       b,u
L058E               ldd       $01,x
                    stb       <u00A4
                    sta       <u00A3
                    lbra      L0607
                    lda       ,y
                    lbsr      IsNum
                    bcs       L058E
                    leay      -$01,y
L05A0               bsr       L05CC
                    bne       L05B5
                    ldd       #$8F05
L05A7               sta       <u00A3
L05A9               bsr       L05FC
                    lda       ,x+
                    decb
                    bpl       L05A9
                    lda       #$06
                    sta       <u00A4
                    rts
L05B5               ldd       #$8E02
                    tst       ,x
                    bne       L05A7
                    ldd       #$8D01
                    leax      $01,x
                    bra       L05A7
L05C3               leay      -$01,y
                    bsr       L05CC
                    ldd       #$9102
                    bra       L05A7
L05CC               lbsr      SkipSpac
                    leax      ,y
                    ldy       <u0044
                    lbsr      L0489
                    exg       x,y
                    bcs       L05E0
                    lda       ,x+
                    cmpa      #$02
                    rts
L05E0               lda       #$16
                    bra       L0600
                    bsr       L058E
                    bra       L05EA
L05E8               bsr       L0607
L05EA               lda       ,y+
                    cmpa      #$0D
                    beq       L05FE
                    cmpa      #$22
                    bne       L05E8
                    cmpa      ,y+
                    beq       L05E8
                    leay      -$01,y
                    lda       #$FF
L05FC               bra       L0607
L05FE               lda       #$29
L0600               lbra      L04AD
                    lda       #$31
                    bra       L0600
L0607               pshs      x,b,a
                    ldx       <u00AB
                    sta       ,x+
                    stx       <u00AB
                    ldd       <u00AB
                    subd      <u004A
                    cmpb      #$FF
                    bcc       L061A
                    clra
                    puls      pc,x,b,a
L061A               lda       #$0D
                    lbsr      L0480
                    lbra      L0486

LAX2                bsr       SkipSpac
                    pshs      y
                    ldb       #$02
                    stb       <u00A5
                    clrb
                    bsr       IsAlpha
                    bcs       L064B
                    leay      $01,y
L0631               incb
                    lda       ,y+
                    bsr       L065C
                    bcc       L0631
                    cmpa      #$24
                    bne       L0643
                    incb
                    leay      $01,y
                    lda       #$04
                    sta       <u00A5
L0643               leay      -$01,y
                    lda       #$80
                    ora       -$01,y
                    sta       -$01,y
L064B               stb       <u00A6
                    puls      pc,y

SkipSpac            lda       ,y+
                    cmpa      #C$SPAC
                    beq       SkipSpac
                    cmpa      #C$LF
                    beq       SkipSpac
                    leay      -$01,y
                    rts

L065C               bsr       IsAlpha
                    bcc       L0685
IsNum               cmpa      #$30                0??
                    bcs       L0685
                    cmpa      #$39                0??
                    bls       L0683
                    bra       L0680

IsAlpha             anda      #$7F
                    cmpa      #$41
                    bcs       L0685
                    cmpa      #$5A
                    bls       L0683
                    cmpa      #$5F
                    beq       L0685
                    cmpa      #$61
                    bcs       L0685
                    cmpa      #$7A
                    bls       L0683
L0680               orcc      #Carry              no
                    rts
L0683               andcc     #^Carry             yes
L0685               rts

L0686               pshs      x,b,a
                    leax      d,u
                    pshs      x
L068C               bitb      #$03
                    beq       L069D
                    lda       ,u+
                    sta       ,y+
                    decb
                    bra       L068C
L0697               pulu      x,b,a
                    std       ,y++
                    stx       ,y++
L069D               cmpu      ,s
                    bcs       L0697
                    clr       ,s++
                    puls      pc,x,b,a
                    lda       #$20
L06A8               pshs      u,y,x,a
                    ldu       -$03,x
                    ldb       -$01,x
L06AE               stx       $01,s
                    cmpu      #$0000
                    beq       L06D6
                    leau      -1,u
                    ldy       $03,s
                    leax      b,x
L06BD               lda       ,x+
                    eora      ,y+
                    beq       L06CF
                    cmpa      ,s
                    beq       L06CF
                    leax      -$01,x
L06C9               lda       ,x+
                    bpl       L06C9
                    bra       L06AE
L06CF               tst       -$01,x
                    bpl       L06BD
                    sty       $03,s
L06D6               puls      pc,u,y,x,a
L06D8               pshs      x,b,a
                    ldb       [<$04,s]
                    leax      <L06E8,pcr
                    ldd       b,x
                    leax      d,x
                    stx       $04,s
                    puls      pc,x,b,a
L06E8               neg       <memsize
                    rts

UNID2
L06EB               pshs      x,b,a
                    ldb       [<$04,s]
                    leax      <L06FB,pcr
                    ldd       b,x
                    leax      d,x
                    stx       $04,s
                    puls      pc,x,b,a

L06FB               fdb       UNK5-L06FB
                    fdb       UNK6-L06FB
                    fdb       UNK7-L06FB
                    fdb       UNK8-L06FB
                    fdb       UNK9-L06FB
                    fdb       UNK10-L06FB
                    fdb       UNK11-L06FB

L0709               jsr       <u001B
                    fcb       $06
L070C               jsr       <u001B
                    fcb       $0C
L070F               jsr       <u001B
                    fcb       $0E
L0712               jsr       <u001B
                    fcb       $02
L0715               jsr       <u001B
                    fcb       $00
L0718               jsr       <u001B
                    fcb       $0A
L071B               jsr       <u001B
                    fcb       $10
L071E               jsr       <u001E
                    fcb       $06
L0721               jsr       <u0027
                    fcb       $04
L0724               jsr       <u0027
                    fcb       $0A
L0727               jsr       <u0027
                    fcb       $02
L072A               jsr       <u0027
                    fcb       $0C
L072D               jsr       <u0027
                    fcb       $0E
L0730               jsr       <u0027
                    fcb       $00
L0733               jsr       <u002A
                    fcb       $02

L0736               fdb       L1900-L0736
                    fdb       L1900-L0736         PARAM
                    fdb       L1900-L0736         TYPE
                    fdb       L1900-L0736         DIM
                    fdb       L1900-L0736         DATA
                    fdb       STOP-L0736
                    fdb       UNK1-L0736
                    fdb       L0F3F-L0736
                    fdb       L0F49-L0736
                    fdb       PAUSE-L0736
                    fdb       DEG-L0736
                    fdb       RAD-L0736
                    fdb       RETURN-L0736
                    fdb       L0897-L0736
                    fdb       LET-L0736
                    fdb       POKE-L0736
                    fdb       IF-L0736
                    fdb       GOTO-L0736          ELSE
                    fdb       ENDIF-L0736
                    fdb       FOR-L0736
                    fdb       NEXT-L0736
                    fdb       UNTIL-L0736         WHILE
                    fdb       GOTO-L0736          ENDWHILE
                    fdb       L0897-L0736
                    fdb       UNTIL-L0736
                    fdb       L0897-L0736         LOOP
                    fdb       GOTO-L0736          ENDLOOP
                    fdb       UNTIL-L0736         EXITIF
                    fdb       GOTO-L0736          ENDEXIT
                    fdb       ON-L0736
                    fdb       ERROR-L0736
                    fdb       errs51-L0736
                    fdb       GOTO-L0736
                    fdb       errs51-L0736
                    fdb       GOSUB-L0736
                    fdb       RUN-L0736
                    fdb       KILL-L0736
                    fdb       INPUT-L0736
                    fdb       PRINT-L0736
                    fdb       CHD-L0736
                    fdb       CHX-L0736
                    fdb       CREATE-L0736
                    fdb       OPEN-L0736
                    fdb       SEEK-L0736
                    fdb       READ-L0736
                    fdb       WRITE-L0736
                    fdb       GET-L0736
                    fdb       PUT-L0736
                    fdb       CLOSE-L0736
                    fdb       RESTORE-L0736
                    fdb       DELETE-L0736
                    fdb       CHAIN-L0736
                    fdb       SHELL-L0736
                    fdb       BASE0-L0736
                    fdb       BASE1-L0736
                    fdb       UNK4-L0736          REM
                    fdb       UNK4-L0736
                    fdb       END-L0736
                    fdb       L0895-L0736
                    fdb       L0895-L0736
                    fdb       UNK3-L0736
                    fdb       errs51-L0736
                    fdb       L0894-L0736         RTS
                    fdb       L0894-L0736
                    fdb       CpMbyte-L0736
                    fdb       CpMint-L0736
                    fdb       CpMreal-L0736
                    fdb       CpMbyte-L0736
                    fdb       CpMstrin-L0736
                    fdb       CpMarray-L0736

L07C2               fcc       "STOP Encountered"
                    fcb       C$LF,$ff

UNK6
L07D4               lda       <$17,x
                    bita      #1
                    beq       L07DF
                    ldb       #$33
                    bra       L07FB

L07DF               tfr       s,d
                    subd      #$0100
                    cmpd      <u0080
                    bcc       L07ED
                    ldb       #$39
                    bra       L07FB
L07ED               ldd       <freemem
                    subd      $0B,x
                    bcs       L07F9
                    cmpd      #$0100
                    bcc       L07FE
L07F9               ldb       #$20
L07FB               lbra      L0EDC
L07FE               std       <freemem
                    tfr       y,d
                    subd      $0B,x
                    exg       d,u
                    sts       5,u
                    std       7,u
                    stx       3,u
L080D               ldd       #$0001
                    std       <u0042
                    sta       1,u
                    sta       <$13,u
                    stu       <$14,u
                    bsr       L0848
                    ldd       <$13,x
                    beq       L0823
                    addd      <u005E
L0823               std       <DATAPtr
                    ldd       $0B,x
                    leay      d,u
                    pshs      y
                    ldd       <$11,x
                    leay      d,u
                    clra
                    clrb
                    bra       L0836
L0834               std       ,y++
L0836               cmpy      ,s
                    bcs       L0834
                    leas      $02,s
                    ldx       <pgmaddr
                    ldd       <u005E
                    addd      <$15,x
                    tfr       d,x
                    bra       L087A
L0848               stx       <pgmaddr
                    stu       <u0031
                    ldd       $0D,x
                    addd      <pgmaddr
                    std       <u0062
                    ldd       $0F,x
                    addd      <pgmaddr
                    std       <u0066
                    std       <u0060
                    ldd       $09,x
                    addd      <pgmaddr
                    std       <u005E
                    ldd       <$14,u
                    std       <u0046
                    std       <u0044
                    rts
L0868               stx       <u005C


*** MAIN LOOP
                    lda       <u0034              check if signal received
                    beq       L0878               no, execute next instruction
                    bpl       L0878               else flag signal received
                    anda      #$7F
                    sta       <u0034
                    ldb       <u0035
                    bra       L07FB               process it
L0878               bsr       L0897
L087A               cmpx      <u0060
                    bcs       L0868
                    bra       L088A

END                 ldb       ,x
                    lbsr      NextInst
                    beq       L088A
                    lbsr      PRINT
L088A               lbsr      L0F49
                    ldu       <u0031
                    lds       5,u
                    ldu       7,u
L0894               rts

L0895               leax      $02,x
UNK9
L0897               ldb       ,x+
                    bpl       L089D
                    addb      #$40
L089D               lslb
                    clra
                    ldu       <table1
                    ldd       d,u
                    jmp       d,u                 go to instruction

IF                  jsr       <u0016              if...
                    tst       $02,y
                    beq       GOTO                = FALSE
                    leax      $03,x               THEN
                    ldb       ,x
                    cmpb      #$3B
                    bne       L0894
                    leax      $01,x               ELSE

GOTO                ldd       ,x
                    addd      <u005E
                    tfr       d,x
                    rts

ENDIF               leax      $01,x
                    rts

UNTIL               jsr       <u0016
                    tst       $02,y
                    beq       GOTO                = FALSE
                    leax      $03,x
                    rts

L08C8               fdb       INTStep1P-L08C8
                    fdb       INTStepXP-L08C8
                    fdb       REALStep1P-L08C8
                    fdb       REALStepXP-L08C8

NEXT                leay      <L08C8,pcr
L08D3               ldb       ,x+
                    lslb
                    ldd       b,y
                    ldu       <u0031
                    jmp       d,y

INTStep1            ldd       ,x
                    leay      d,u
                    bra       L08F9

INTStepX            ldd       ,x
                    leay      d,u
                    ldd       $04,x
                    lda       d,u
                    bpl       L08F9
                    bra       L0919

* FOR .. NEXT / INTEGER
INTStep1P
                    ldd       ,x                  offset counter
                    leay      d,u                 address counter
                    ldd       ,y
                    addd      #$0001              increment counter
                    std       ,y
L08F9               ldd       $02,x               offset target
                    leax      $06,x
                    ldd       d,u                 target value
                    cmpd      ,y
                    bge       GOTO                loop again
                    leax      $03,x
                    rts

* FOR .. NEXT .. STEP / INTEGER
INTStepXP
                    ldd       ,x
                    leay      d,u
                    ldd       $04,x
                    ldd       d,u
                    pshs      a
                    addd      ,y                  update counter
                    std       ,y
                    tst       ,s+
                    bpl       L08F9               incrementing
L0919               ldd       $02,x
                    leax      $06,x
                    ldd       d,u
                    cmpd      ,y
                    ble       GOTO                loop again
                    leax      $03,x
                    rts

REALStep1
                    ldy       <u0046
                    clrb
                    bsr       L0977
                    bra       L0967

REALStepX
                    ldy       <u0046
                    clrb
                    bsr       L0977
                    ldd       $04,x
                    addd      #$0004
                    ldu       <u0031
                    lda       d,u
                    lsra                          sign
                    bcc       L0967
                    bra       L09B5

* FOR .. NEXT / REAL
REALStep1P
                    ldy       <u0046
                    clrb
                    bsr       L0977
                    leay      -$06,y
                    ldd       #$0180              step 1 (save in temp var)
                    std       $01,y
                    clra
                    clrb
                    std       $03,y
                    sta       $05,y
                    lbsr      L0721
                    bsr       L09C5
                    ldd       $01,y
                    std       ,u
                    ldd       $03,y
                    std       2,u
                    lda       $05,y
                    sta       4,u
L0967               ldb       #$02                incrementing
                    bsr       L0977
                    leax      $06,x
                    lbsr      L0724
                    lble      GOTO                loop again
                    leax      $03,x
                    rts

L0977               ldd       b,x                 copy number
                    addd      <u0031
                    tfr       d,u
                    leay      -$06,y
                    lda       #$02
                    ldb       ,u
                    std       ,y
                    ldd       1,u
                    std       $02,y
                    ldd       3,u
                    std       $04,y
                    rts

* FOR .. NEXT .. STEP / REAL
REALStepXP
                    ldy       <u0046
                    clrb
                    bsr       L0977
                    stu       <u00D2
                    ldb       #$04
                    bsr       L0977
                    lda       4,u
                    sta       <u00D1
                    lbsr      L0721               increment counter
                    bsr       L09C5
                    ldu       <u00D2
                    ldd       $01,y
                    std       ,u
                    ldd       $03,y
                    std       2,u
                    lda       $05,y
                    sta       4,u
                    lsr       <u00D1              check sign
                    bcc       L0967
L09B5               ldb       #$02                decrementing
                    bsr       L0977
                    leax      $06,x
                    lbsr      L0724
                    lbge      GOTO                loop again
                    leax      $03,x
                    rts
L09C5               ldb       <u0034
                    rts

******** table for FOR ********
L09C8               fdb       INTStep1-L09C8
                    fdb       INTStepX-L09C8
                    fdb       REALStep1-L09C8
                    fdb       REALStepX-L09C8

FOR                 ldb       ,x+
                    cmpb      #$82
                    beq       L405
                    bsr       CpMint
                    bsr       L09EB
                    ldb       -1,x
                    cmpb      #$47
                    bne       L09E2
                    bsr       L09EB
L09E2               lbsr      GOTO
                    leay      <L09C8,pcr
                    lbra      L08D3
L09EB               ldd       ,x++
                    addd      <u0031
                    pshs      b,a
                    jsr       <u0016
                    ldd       $01,y
                    std       [,s++]
                    rts

L405                bsr       CpMreal
                    bsr       L0A06
                    ldb       -$01,x
                    cmpb      #$47
                    bne       L09E2
                    bsr       L0A06
                    bra       L09E2

L0A06               ldd       ,x++
                    addd      <u0031
                    pshs      b,a
                    jsr       <u0016
                    bra       L0A5C

LET                 jsr       <u0016
L0A12               cmpa      #$04
                    bcs       L0A1A
                    pshs      u
                    ldu       <u003E
L0A1A               pshs      u,a
                    leax      $01,x
                    jsr       <u0016
L0A20               puls      a
                    lsla
                    leau      <L0A28,pcr
                    jmp       a,u

L0A28               bra       L0A3E               byte
                    bra       L0A4D               integer
                    bra       L0A5C               real
                    bra       L0A3E               boolean
                    bra       L0A7F               string
                    bra       L0AA4               array

CpMbyte             ldd       ,x
                    addd      <u0031
                    pshs      b,a
                    leax      $03,x
                    jsr       <u0016
L0A3E               ldb       $02,y
                    stb       [,s++]
                    rts

CpMint              ldd       ,x
                    addd      <u0031
                    pshs      b,a
                    leax      $03,x
                    jsr       <u0016
L0A4D               ldd       $01,y
                    std       [,s++]
                    rts

CpMreal             ldd       ,x
                    addd      <u0031
                    pshs      b,a
                    leax      $03,x
                    jsr       <u0016
L0A5C               puls      u
                    ldd       $01,y
                    std       ,u
                    ldd       $03,y
                    std       2,u
                    lda       $05,y
                    sta       4,u
                    rts

CpMstrin            ldd       ,x
                    addd      <u0066
                    tfr       d,u
                    ldd       ,u
                    addd      <u0031
                    pshs      b,a
                    ldd       2,u
                    pshs      b,a
                    leax      $03,x
                    jsr       <u0016
L0A7F               puls      u,b,a               D = Max size of string to copy
                    tstb
                    bne       L0A85
                    deca
L0A85               sta       <u003E
                    ldy       $01,y
                    sty       <u0048
L0A8D               lda       ,y+
                    sta       ,u+
                    cmpa      #$FF
                    beq       L0A9C
                    decb
                    bne       L0A8D
                    dec       <u003E
                    bpl       L0A8D
L0A9C               clra
                    rts

CpMarray            lbsr      L0727
                    lbra      L0A12

L0AA4               puls      u,b,a
                    cmpd      $03,y
                    bls       L0AAD
                    ldd       $03,y
L0AAD               ldy       $01,y
                    exg       y,u
                    lbra      L071E

POKE                jsr       <u0016
                    ldd       $01,y
                    pshs      b,a
                    jsr       <u0016
                    ldb       $02,y
                    stb       [,s++]
                    rts

STOP                lbsr      PRINT
                    lda       <errpath
                    sta       <u007F
                    leax      >L07C2,pcr
                    lbsr      Sprint
                    lbra      L0709               exit

UNK1                lbra      L070C

PAUSE               lbsr      PRINT
                    rts

GOSUB               ldd       ,x
                    leax      $03,x
L0ADE               ldy       <u0031
                    ldu       <$14,y
                    cmpu      <u004A
                    bhi       L0AEE
                    ldb       #E$SubOvf
                    lbra      L0EDC
L0AEE               stx       ,--u
                    stu       <$14,y
                    stu       <u0046
                    addd      <u005E
                    tfr       d,x
                    rts

RETURN              ldy       <u0031
                    cmpy      <$14,y
                    bhi       L0B08
                    ldb       #$36
                    lbra      L0EDC
L0B08               ldu       <$14,y
                    ldx       ,u++
                    stu       <$14,y
                    stu       <u0046
                    rts

ON                  ldd       ,x
                    cmpa      #$1E
                    beq       L0B4E
                    jsr       <u0016
                    ldd       ,x
                    lslb
                    rola
                    lslb
                    rola
                    addd      #$0002
                    leau      d,x
                    pshs      u
                    ldd       $01,y
                    ble       L0B4C
                    cmpd      ,x++
                    bhi       L0B4C
                    subd      #$0001
                    lslb
                    rola
                    lslb
                    rola
                    addd      #$0001
                    ldd       d,x
                    pshs      b,a
                    ldb       ,x
                    cmpb      #$22
                    puls      x,b,a
                    beq       L0ADE
                    addd      <u005E
                    tfr       d,x
                    rts
L0B4C               puls      pc,x
L0B4E               ldu       <u0031
                    cmpb      #$20
                    bne       L0B63
                    ldd       $02,x
                    addd      <u005E
                    std       <$11,u
                    lda       #$01
                    sta       <$13,u
                    leax      $05,x
                    rts
L0B63               clr       <$13,u
                    leax      $02,x
                    rts

CREATE              bsr       L0B87
                    ldb       #PREAD.+UPDAT.
                    os9       I$Create
                    bra       L0B77

OPEN                bsr       L0B87
                    os9       I$Open
L0B77               lbcs      L0EDC
                    puls      u,b
                    cmpb      #$01
                    bne       L0B83
                    clr       ,u+
L0B83               sta       ,u
                    puls      pc,x
L0B87               leax      $01,x
                    lbsr      GetVar
                    leax      $01,x
                    jsr       <u0016
                    lda       #$03
                    cmpb      #$4A
                    bne       L0B98
                    lda       ,x++
L0B98               ldu       $03,s
                    stx       $03,s
                    ldx       $01,y
                    jmp       ,u

SEEK                lbsr      SetPath
                    jsr       <u0016
                    ldb       #$0E
                    lbsr      L0733
                    lbcs      L0EDE
                    rts

InputPrompt         fcc       /? /
L0BB0               fcb       $ff

L0BB2               fcc       "** Input error - reenter **"
                    fcb       C$CR,$ff

INPUT               lda       <errpath
                    lbsr      SetPath
                    lda       #$2C
                    sta       <u00DD
                    pshs      x

L0BDA               ldx       ,s
                    ldb       ,x
                    cmpb      #$90
                    bne       L0BEA
                    jsr       <u0016
                    pshs      x
                    ldx       $01,y
                    bra       L0BEF
L0BEA               pshs      x
                    leax      <InputPrompt,pcr
L0BEF               bsr       Sprint
                    puls      x
                    lda       <u007F
                    cmpa      <errpath
                    bne       L0BFD
                    lda       <u002D
                    sta       <u007F
L0BFD               ldb       #$06
L0BFF               lbsr      L0733
                    bcc       L0C11
                    cmpb      #$03
                    lbne      L0EDE
                    lbsr      L0F04
                    clr       <u0036
                    bra       L0BDA
L0C11               bsr       L0C24
                    bcc       L0C1C
                    leax      <L0BB2,pcr
                    bsr       Sprint
                    bra       L0BDA
L0C1C               ldb       ,x+
                    cmpb      #$4B
                    beq       L0C11
                    puls      pc,b,a
L0C24               bsr       GetVar
                    ldb       ,s
                    addb      #$07
                    ldy       <u0046
                    lbsr      L0733
                    lbcc      L0A20
                    lda       ,s
L0C36               cmpa      #$04
                    bcs       L0C3C
                    leas      $02,s
L0C3C               leas      $03,s
                    coma
                    rts

* Entry: X = address of string to print
Sprint              pshs      y
                    leas      -$06,s
                    leay      ,s
                    stx       $01,y
                    ldd       <u0080
                    std       <u0082
                    ldb       #$05
                    lbsr      L0733
                    ldb       #$00
                    lbsr      L0733
                    leas      $06,s
                    puls      pc,y

GetVar              lda       ,x+
                    cmpa      #$0E
                    bne       L0C64
                    jsr       <u0016
                    bra       L0C89
L0C64               suba      #$80
                    cmpa      #$04
                    bcs       L0C7F
                    beq       L0C71
                    lbsr      L0727
                    bra       L0C89
L0C71               ldd       ,x++
                    addd      <u0066
                    tfr       d,u
                    ldd       2,u
                    std       <u003E
                    ldd       ,u
                    bra       L0C81
L0C7F               ldd       ,x++
L0C81               addd      <u0031
                    tfr       d,u
                    lda       -$03,x
                    suba      #$80
L0C89               puls      y
                    cmpa      #$04
                    bcs       L0C93
                    pshs      u
                    ldu       <u003E
L0C93               pshs      u,a
                    jmp       ,y

* set IO path
* called by #path statement
SetPath             ldb       ,x
                    cmpb      #$54
                    bne       L0CA9
                    leax      $01,x
                    jsr       <u0016
                    cmpb      #$4B
                    beq       L0CA7
                    leax      -$01,x
L0CA7               lda       $02,y
L0CA9               sta       <u007F
                    rts

READ                ldb       ,x
                    cmpb      #$54
                    bne       L0CD6
                    bsr       SetPath
                    clr       <u00DD
                    cmpb      #$4B
                    bne       L0CBC
                    leax      -$01,x
L0CBC               ldb       #$06
                    lbsr      L0733
                    bcc       L0CCF
                    cmpb      #$E4
                    beq       L0CBC
L0CC7               lbra      L0EDE
L0CCA               lbsr      L0C24
                    bcs       L0CC7
L0CCF               ldb       ,x+
                    cmpb      #$4B
                    beq       L0CCA
                    rts
L0CD6               bsr       NextInst
                    beq       L0D13
L0CDA               bsr       L0CE3
                    ldb       ,x+
                    cmpb      #$4B
                    beq       L0CDA
                    rts
L0CE3               lbsr      GetVar
                    bsr       L0D15
                    lda       ,s
                    bne       L0CED
                    inca
L0CED               cmpa      ,y
                    lbeq      L0A20
                    cmpa      #$02
                    bcs       L0CFD
                    beq       L0D09
L0CF9               ldb       #$47
                    bra       L0D1D
L0CFD               lda       ,y
                    cmpa      #$02
                    bne       L0CF9
                    lbsr      L072A
                    lbra      L0A20
L0D09               cmpa      ,y
                    bcs       L0CF9
                    lbsr      L072D
                    lbra      L0A20
L0D13               leax      $01,x
L0D15               pshs      x
                    ldx       <DATAPtr
                    bne       L0D20
                    ldb       #E$NoData
L0D1D               lbra      L0EDC
L0D20               jsr       <u0016
                    cmpb      #$4B
                    beq       L0D2C
                    ldd       ,x
                    addd      <u005E
                    tfr       d,x
L0D2C               stx       <DATAPtr
                    puls      pc,x

* instruction delimiters
NextInst            cmpb      #$3F
                    beq       L0D36
                    cmpb      #$3E
L0D36               rts

PRINT               lda       <errpath
                    lbsr      SetPath
                    ldd       <u0080
                    std       <u0082
                    ldb       ,x+
                    cmpb      #$49                PRINT USING
                    beq       L0D84
L0D46               bsr       NextInst
                    beq       L0D6C
L0D4A               cmpb      #$4B
                    beq       L0D60
                    cmpb      #$51
                    beq       L0D64
                    leax      -$01,x
                    jsr       <u0016
                    ldb       ,y
                    addb      #$01
                    bsr       L0D7C
                    ldb       -$01,x
                    bra       L0D46
L0D60               ldb       #$0D
                    bsr       L0D7C
L0D64               ldb       ,x+
                    bsr       NextInst
                    bne       L0D4A
                    bra       L0D70
L0D6C               ldb       #$0C
                    bsr       L0D7C
L0D70               ldb       #$00
                    bsr       L0D7C
                    lda       <u00DE
                    clr       <u00DE
                    tsta
                    bne       L0D81
L0D7B               rts
L0D7C               lbsr      L0733
                    bcc       L0D7B
L0D81               lbra      L0EDE
L0D84               jsr       <u0016
                    ldd       <u004A
                    std       <u008E
                    std       <u008C
                    ldu       <u0046
                    pshs      u,b,a
                    clr       <u0094
                    ldd       <u0048
                    std       <u004A
L0D96               ldb       -$01,x
                    bsr       NextInst
                    beq       L0DB8
                    ldb       ,x+
                    bsr       NextInst
                    beq       L0DB3
                    leax      -$01,x
                    ldb       #$11
                    lbsr      L0733
                    bcc       L0D96
                    puls      u,b,a
                    std       <u004A
                    stu       <u0046
                    bra       L0D81
L0DB3               leay      <L0D70,pcr
                    bra       L0DBB
L0DB8               leay      <L0D6C,pcr
L0DBB               puls      u,b,a
                    std       <u004A
                    stu       <u0046
                    jmp       ,y

WRITE               lda       <errpath
                    lbsr      SetPath
                    ldu       <u0080
                    stu       <u0082
                    ldb       ,x+
                    lbsr      NextInst
                    beq       L0DF5
                    cmpb      #$4B                comma separator?
                    beq       L0DE3
                    leax      -$01,x
                    bra       L0DE3

L0DDB               clra
                    ldb       #$12
                    lbsr      L0733
                    bcs       L0D81
L0DE3               jsr       <u0016
                    ldb       ,y
                    addb      #$01
                    lbsr      L0733
                    bcs       L0D81
                    ldb       -$01,x
                    lbsr      NextInst
                    bne       L0DDB
L0DF5               lbra      L0D6C

GET                 bsr       L0E0B
                    os9       I$Read
                    bra       L0E04

PUT                 bsr       L0E0B
                    os9       I$Write
L0E04               leax      ,u
                    bcc       L0E2A
L0E08               lbra      L0EDC

L0E0B               lbsr      SetPath
                    lbsr      GetVar
                    leau      ,x
                    puls      a
                    cmpa      #$04
                    bcc       L0E24
                    leax      >L1031,pcr
                    ldb       a,x
                    clra
                    tfr       d,y
                    bra       L0E26
L0E24               puls      y
L0E26               puls      x
                    lda       <u007F
L0E2A               rts
CLOSE               lbsr      SetPath
                    os9       I$Close
                    bcs       L0E08
                    cmpb      #$4B
                    beq       CLOSE
                    rts

RESTORE             ldb       ,x+
                    cmpb      #$3B
                    beq       L0E48
                    ldu       <pgmaddr
                    ldd       <$13,u
L0E43               addd      <u005E
                    std       <DATAPtr
                    rts
L0E48               ldd       ,x
                    addd      #$0001
                    leax      $03,x
                    bra       L0E43

DELETE              jsr       <u0016
                    pshs      x
                    ldx       $01,y
                    os9       I$Delete
L0E5A               bcs       L0E08
                    puls      pc,x

CHD                 jsr       <u0016
                    lda       #UPDAT.
L0E62               pshs      x
                    ldx       $01,y
                    os9       I$ChgDir
                    bra       L0E5A

CHX                 jsr       <u0016
                    lda       #EXEC.
                    bra       L0E62

                    lbsr      GetVar
                    ldy       <u0046
                    leay      -$06,y
                    ldb       <u007F
                    clra
                    std       $01,y
                    lbra      L0A20

CHAIN               jsr       <u0016
                    ldy       $01,y
                    pshs      u,y,x
                    lbsr      L070F
                    puls      u,y,x
                    bsr       L0EC1
                    sts       <u00B1
                    lds       <u0080
                    os9       F$Chain
                    lds       <u00B1
                    bra       L0EDC

SHELL               jsr       <u0016
                    pshs      u,x
                    ldy       $01,y
                    bsr       L0EC1
                    os9       F$Fork
                    bcs       L0EDC
                    pshs      a
L0EAD               os9       F$Wait
                    cmpa      ,s
                    bne       L0EAD
                    leas      $01,s
                    tstb
                    bne       L0EDC
                    puls      pc,u,x

L0EBB               fcc       "SHELL"
L0EC0               fcb       C$CR

L0EC1               ldx       <u0048
                    lda       #C$CR
                    sta       -1,x
                    tfr       x,d
                    leax      >L0EBB,pcr
                    leau      ,y
                    pshs      y
                    subd      ,s++
                    tfr       d,y
                    clra
                    clrb
                    rts

ERROR               jsr       <u0016
                    ldb       2,y
UNK8
L0EDC               stb       <u0036
L0EDE               ldu       <u0031
                    beq       L0EFC               not running subroutine
                    tst       <$13,u
                    beq       L0EF5               no error trap
                    lds       5,u
                    ldx       <$11,u
                    ldd       <$14,u
                    std       <u0046
                    lbra      L0868               process error

L0EF5               bsr       L0F04
                    bsr       L0F49
                    lbra      L0709               exit
L0EFC               lbsr      L0712
                    lbra      L0709               exit

L0F02               fcb       14,255              Force text mode in VDGINT

L0F04               leax      <L0F02,pcr
                    lbsr      Sprint
                    lbsr      L070F
                    ldb       <u0036
                    os9       F$Exit
                    rts
BASE0               clrb
                    bra       L0F18

BASE1               ldb       #$01
L0F18               clra
                    std       <u0042
                    leax      $01,x
                    rts

UNK4                ldb       ,x+
                    clra
                    leax      d,x
                    rts

UNK3                exg       x,pc
                    rts

L1900               leay      ,x
                    lbsr      L071B
                    leax      ,y
                    rts

errs51              ldb       #$33
                    bra       L0EDC

DEG                 lda       #$01
                    bra       L0F38

RAD                 clra
L0F38               ldu       <u0031
                    sta       1,u
                    leax      $01,x
                    rts

UNK10
L0F3F               lda       <u0034
                    bita      #$01
                    bne       L0F5F
                    ora       #$01
                    bra       L0F51
UNK11
L0F49               lda       <u0034
                    bita      #$01
                    beq       L0F5F
                    anda      #$FE
L0F51               sta       <u0034
                    ldd       <u0017
                    pshs      b,a
                    ldd       <u0019
                    std       <u0017
                    puls      b,a
                    std       <u0019
L0F5F               rts

RUN                 lbsr      L0727
                    pshs      x
                    ldb       <u00CF
                    cmpb      #$A0
                    beq       L0F8C
                    ldy       <u0048
                    ldx       <u003E
L0F70               lda       ,u+
                    leax      -$01,x
                    beq       L0F7E
                    sta       ,y+
                    cmpa      #$FF
                    bne       L0F70
                    lda       ,--y
L0F7E               ora       #$80
                    sta       ,y
                    ldy       <u0048
                    lbsr      L0715
                    bcs       L0FCA
                    leau      ,x
L0F8C               ldd       ,u
                    bne       L0F9E
                    ldy       <u00D2
                    leay      $03,y
                    lbsr      L0715
                    bcs       L0FCA
                    ldd       ,x
                    std       ,u
L0F9E               ldx       ,s
                    std       ,s
                    ldu       <u0031
                    lda       <u0034
                    sta       ,u
                    ldb       <u0043
                    stb       2,u
                    ldd       <u004A
                    std       $D,u
                    ldd       <u0040
                    std       $F,u
                    ldd       <DATAPtr
                    std       9,u
                    bsr       L1035
                    stx       $B,u
                    puls      x
                    lda       $06,x
                    beq       L0FF9
                    cmpa      #$22
                    beq       L0FF9
                    cmpa      #$21
                    beq       L0FCF
L0FCA               ldb       #$2B
L0FCC               lbra      L0EDC
L0FCF               ldd       5,u
                    pshs      b,a
                    sts       5,u
                    leas      ,y
                    ldd       <u0040
                    pshs      y
                    subd      ,s++
                    lsra
                    rorb
                    lsra
                    rorb
                    pshs      b,a
                    ldd       $09,x
                    leay      >L07D4,pcr
                    jsr       d,x
                    ldu       <u0031
                    lds       5,u
                    puls      x
                    stx       5,u
                    bcc       L1012
                    bra       L0FCC
L0FF9               lbsr      L0F49
                    lda       <u0034
                    anda      #$7F
                    sta       <u0034
                    lbsr      L07D4
                    lda       ,u
                    bita      #$01
                    beq       L1012
                    lbsr      L0F3F
                    lda       ,u
                    sta       <u0034
L1012               ldd       $D,u
                    std       <u004A
                    ldd       $F,u
                    std       <u0040
                    ldd       9,u
                    std       <DATAPtr
                    ldb       2,u
                    sex
                    std       <u0042
                    ldx       3,u
                    lbsr      L0848
                    ldx       $B,u
                    ldd       <u0044
                    subd      <u004A
                    std       <freemem
                    rts
L1031               fcb       $01
                    fcb       $02
                    fcb       $05
                    fcb       $01

UNK7
L1035               pshs      u
                    ldb       ,x+
                    clra
                    pshs      x,a
                    cmpb      #$4D
                    bne       L10B7
                    leay      ,s
L1042               pshs      y
                    ldb       ,x
                    cmpb      #$0E
                    beq       L1079
                    jsr       <u0016
                    leax      -$01,x
                    cmpa      #$02
                    beq       L105C
                    cmpa      #$04
                    beq       L1069
                    ldd       $01,y
                    std       $04,y
                    lda       ,y
L105C               ldb       #$06
                    leau      <L1031,pcr
                    subb      a,u
                    leau      b,y
                    stu       <u0046
                    bra       L107D
L1069               ldu       $01,y
                    ldd       <u0048
                    subd      <u004A
                    std       <u003E
                    ldd       <u0048
                    std       <u004A
                    lda       #$04
                    bra       L107D
L1079               leax      $01,x
                    jsr       <u0016
L107D               puls      y
                    inc       ,y
                    cmpa      #$04
                    bcs       L1089
                    pshs      u
                    ldu       <u003E
L1089               pshs      u,a
                    ldb       ,x+
                    cmpb      #$4B
                    beq       L1042
                    leax      $01,x
                    stx       $01,y
                    leax      <L1031,pcr
                    ldu       <u0046
                    stu       <u0040
L109C               puls      b
                    cmpb      #$04
                    bcs       L10A6
                    puls      b,a
                    bra       L10A9
L10A6               ldb       b,x
                    clra
L10A9               std       ,--u
                    puls      b,a
                    std       ,--u
                    dec       ,y
                    bne       L109C
                    leay      ,u
                    bra       L10BD
L10B7               ldy       <u0046
                    sty       <u0040
L10BD               tfr       y,d
                    subd      <u004A
                    lbcs      L07F9
                    std       <freemem
                    puls      pc,u,x,a

KILL                jsr       <u0016
                    ldy       $01,y
                    pshs      x
                    lbsr      L0718
                    puls      pc,x

UNK5                lbsr      L0730
                    leax      >L0736,pcr
                    stx       <table1
                    rts

UNID3
L10DF               pshs      x,b,a
                    ldb       [<$04,s]
                    leax      <L10EF,pcr
                    ldd       b,x
                    leax      d,x
                    stx       $04,s
                    puls      pc,x,b,a

L10EF               fdb       UNK12-L10EF
                    fdb       L1253-L10EF
                    fdb       RLADD-L10EF
                    fdb       L15A6-L10EF
                    fdb       L1707-L10EF
                    fdb       RLCMP-L10EF
                    fdb       FIX-L10EF
                    fdb       FLOAT-L10EF

L10FF               jsr       <u001B
                    fcb       $08
L1102               jsr       <u0024
                    fcb       $06
L1105               jsr       <u002A
                    fcb       $02

                    fdb       MIDFNC-L1188
                    fdb       L4EE2-L1188
                    fdb       RGTFNC-L1188
                    fdb       CHRFNC-L1188
                    fdb       STRFNI-L1188
                    fdb       L4FA8-L1188
                    fdb       DATFNC-L1188
                    fdb       TABFNC-L1188
                    fdb       FIX-L1188
                    fdb       fixN1-L1188
                    fdb       fixN2-L1188
                    fdb       FLOAT-L1188
                    fdb       float2-L1188
                    fdb       LNOTB-L1188
                    fdb       NEGint-L1188
                    fdb       NEGrl-L1188
                    fdb       LANDB-L1188
                    fdb       LORB-L1188
                    fdb       LXORB-L1188
                    fdb       L43FF-L1188
                    fdb       L4443-L1188
                    fdb       L43D1-L1188
                    fdb       INCMLT-L1188
                    fdb       RLCMLT-L1188
                    fdb       STCMLE-L1188
                    fdb       INCMEQ-L1188
                    fdb       RLCMEQ-L1188
                    fdb       L43C5-L1188
                    fdb       L441D-L1188
                    fdb       INCMGE-L1188
                    fdb       RLCMGE-L1188
                    fdb       STCMNE-L1188
                    fdb       BLCMEQ-L1188
                    fdb       INCMGT-L1188
                    fdb       RLCMGT-L1188
                    fdb       STCMGT-L1188
                    fdb       INCMNE-L1188
                    fdb       RLCMNE-L1188
                    fdb       STCMEQ-L1188
                    fdb       INTADD-L1188
                    fdb       RLADD-L1188
                    fdb       L44E5-L1188
                    fdb       INTSUB-L1188
                    fdb       RLSUB-L1188
                    fdb       INTMUL-L1188
                    fdb       RLMUL-L1188
                    fdb       INTDIV-L1188
                    fdb       RLDIV-L1188
                    fdb       POWERS-L1188
                    fdb       POWERS-L1188
                    fdb       DIM-L1188
                    fdb       DIM-L1188
                    fdb       DIM-L1188
                    fdb       DIM-L1188
                    fdb       PARAM-L1188
                    fdb       PARAM-L1188
                    fdb       PARAM-L1188
                    fdb       PARAM-L1188
                    fdb       $0000,$0000,$0000,$0000,$0000,$0000

L1188               fdb       BCPVAR-L1188
                    fdb       ICPVAR-L1188
                    fdb       L2102-L1188
                    fdb       BlCPVAR-L1188
                    fdb       SVSTR-L1188
                    fdb       L2105-L1188
                    fdb       L2105-L1188
                    fdb       L2105-L1188
                    fdb       L2105-L1188
                    fdb       L2106-L1188
                    fdb       L2106-L1188
                    fdb       L2106-L1188
                    fdb       L2106-L1188
                    fdb       BCPCNST-L1188
                    fdb       ICPCNST-L1188
                    fdb       RCPCNST-L1188
                    fdb       STRLIT-L1188
                    fdb       ICPCNST-L1188
                    fdb       ADDR-L1188
                    fdb       ADDR-L1188
                    fdb       SIZE-L1188
                    fdb       SIZE-L1188
                    fdb       POS-L1188
                    fdb       ERR-L1188
                    fdb       MODint-L1188
                    fdb       MODrl-L1188
                    fdb       RNDFNC-L1188
                    fdb       L4B03-L1188
                    fdb       SUBFNC-L1188
                    fdb       SGNint-L1188
                    fdb       SGNrl-L1188
                    fdb       SINFNC-L1188
                    fdb       COSFNC-L1188
                    fdb       TANFNC-L1188
                    fdb       ASNFNC-L1188
                    fdb       ACSFNC-L1188
                    fdb       ATNFNC-L1188
                    fdb       EXP-L1188
                    fdb       ABSint-L1188
                    fdb       ABSrl-L1188
                    fdb       LOG-L1188
                    fdb       LOG10-L1188
                    fdb       SQRT-L1188
                    fdb       SQRT-L1188
                    fdb       FLOAT-L1188
                    fdb       INTrl-L1188
                    fdb       L1AC3-L1188
                    fdb       FIX-L1188
                    fdb       FLOAT-L1188
                    fdb       L1AC3-L1188
                    fdb       SQint-L1188
                    fdb       SQrl-L1188
                    fdb       PEEK-L1188
                    fdb       LNOTI-L1188
                    fdb       VAL-L1188
                    fdb       L4EAB-L1188
                    fdb       ASCFNC-L1188
                    fdb       LANDI-L1188
                    fdb       LORI-L1188
                    fdb       LXORI-L1188
                    fdb       equTRUE-L1188
                    fdb       equFALSE-L1188
                    fdb       EOFFNC-L1188
                    fdb       TRMFNC-L1188

L1208               fdb       BtoI-L1208
                    fdb       INTCPY-L1208
                    fdb       RCPVAR-L1208
                    fdb       L13-L1208
                    fdb       STRVAR-L1208
                    fdb       RCDVAR-L1208

L1214               ldy       <u0046              = table4
                    ldd       <u004A
                    std       <u0048              clear expression stack
                    bra       L1224

L121D               lslb
                    ldu       <table2
                    ldd       b,u
                    jsr       d,u
L1224               ldb       ,x+
                    bmi       L121D               next part
                    clra                          clear carry
                    lda       ,y
                    rts                           instruction done

* get size of DIM array
L2105               bsr       L1253
L122E               pshs      pc,u
                    ldu       <table3
                    lsla
                    ldd       a,u
                    leau      d,u
                    stu       $02,s
                    puls      pc,u

* Get size of PARAM array
L2106               bsr       L124B
                    bra       L122E

DIM                 leas      $02,s
                    lda       #$F2
                    bra       L1255

PARAM               leas      $02,s
                    lda       #$F6
                    bra       L124D

L124B               lda       #$89
L124D               sta       <u00A3
                    clr       <u003B
                    bra       L1259
L1253               lda       #$85
L1255               sta       <u00A3
                    sta       <u003B
L1259               ldd       ,x++
                    addd      <u0062
                    std       <u00D2
                    ldu       <u00D2
                    lda       ,u
                    anda      #$E0
                    sta       <u00CF
                    eora      #$80
                    sta       <u00CE
                    lda       ,u
                    anda      #$07
                    ldb       -$03,x
                    subb      <u00A3
                    pshs      b,a
                    lda       ,u
                    anda      #$18
                    lbeq      L1312
                    ldd       1,u
                    addd      <u0066
                    tfr       d,u
                    ldd       ,u
                    std       <u003C
                    lda       $01,s
                    bne       L1297
                    lda       #$05
                    sta       ,s
                    ldd       2,u
                    std       <u003E
                    clra
                    clrb
                    bra       L12EA
L1297               leay      -$06,y
                    clra
                    clrb
                    std       $01,y
                    leau      4,u
                    bra       L12A8
L12A1               ldd       ,u
                    std       $01,y
                    lbsr      INTMUL
L12A8               ldd       $07,y
                    subd      <u0042
                    cmpd      ,u++
                    bcs       L12B6
                    ldb       #$37
                    lbra      L1102
L12B6               addd      $01,y
                    std       $07,y
                    dec       $01,s
                    bne       L12A1
                    lda       ,s
                    beq       L12D2
                    cmpa      #$02
                    bcs       L12D6
                    beq       L12DE
                    cmpa      #$04
                    bcs       L12D2
                    ldd       ,u
                    std       <u003E
                    bra       L12E1
L12D2               ldd       $07,y
                    bra       L12DA
L12D6               ldd       $07,y
                    lslb
                    rola
L12DA               leay      $0C,y
                    bra       L12EA
L12DE               ldd       #$0005
L12E1               std       $01,y
                    lbsr      INTMUL
                    ldd       $01,y
                    leay      $06,y
L12EA               tst       <u00CE
                    bne       L1306
                    pshs      b,a
                    ldd       <u003C
                    addd      <u0031
                    cmpd      <u0040
                    bcc       err56
                    tfr       d,u
                    puls      b,a
                    cmpd      2,u
                    bhi       err56
                    addd      ,u
                    bra       L1346
L1306               addd      <u003C
                    tst       <u003B
                    bne       L1344
L130C               addd      $01,y
                    leay      $06,y
                    bra       L1346
L1312               lda       ,s
                    cmpa      #$04
                    ldd       1,u
                    bcs       L1324
                    addd      <u0066
                    tfr       d,u
                    ldd       2,u
                    std       <u003E
                    ldd       ,u
L1324               tst       <u003B
                    beq       L130C
                    addd      <u0031
                    tfr       d,u
                    tst       <u00CE
                    bne       L1348
                    cmpd      <u0040
                    bcc       err56
                    ldd       <u003E
                    cmpd      2,u
                    bcs       L1340
                    ldd       2,u
                    std       <u003E
L1340               ldu       ,u
                    bra       L1348
L1344               addd      <u0031
L1346               tfr       d,u
L1348               clra
                    puls      pc,b,a

err56               ldb       #$38
                    lbra      L1102

BCPCNST             leau      ,x+
                    bra       BtoI

BCPVAR              ldd       ,x++
                    addd      <u0031
                    tfr       d,u
BtoI                ldb       ,u
                    clra
                    leay      -$06,y
                    std       $01,y
                    lda       #$01
                    sta       ,y
                    rts

ICPCNST             leau      ,x++
                    bra       INTCPY

ICPVAR              ldd       ,x++
                    addd      <u0031
                    tfr       d,u
INTCPY              ldd       ,u
                    leay      -$06,y
                    std       $01,y
                    lda       #$01
                    sta       ,y
                    rts

NEGint              clra
                    clrb
                    subd      $01,y
                    std       $01,y
                    rts

INTADD              ldd       $07,y
                    addd      $01,y
                    leay      $06,y
                    std       $01,y
                    rts

INTSUB              ldd       $07,y
                    subd      $01,y
                    leay      $06,y
                    std       $01,y
                    rts

INTMUL              ldd       $07,y
                    beq       L13CD
                    cmpd      #$0002
                    bne       L13OO
                    ldd       $01,y
                    bra       L13AE

L13OO               ldd       $01,y
                    beq       L13B0
                    cmpd      #$0002
                    bne       L13B4
                    ldd       $07,y
L13AE               lslb
                    rola
L13B0               std       $07,y
                    bra       L13CD
L13B4               lda       $08,y
                    mul
                    sta       $03,y
                    lda       $08,y
                    stb       $08,y
                    ldb       $01,y
                    mul
                    addb      $03,y
                    lda       $07,y
                    stb       $07,y
                    ldb       $02,y
                    mul
                    addb      $07,y
                    stb       $07,y
L13CD               leay      $06,y
                    rts
L13D0               clr       ,y
                    ldd       $07,y
                    bpl       L13DE
                    nega
                    negb
                    sbca      #$00
                    std       $07,y
                    com       ,y
L13DE               ldd       $01,y
                    bpl       L13EA
                    nega
                    negb
                    sbca      #$00
                    std       $01,y
                    com       ,y
L13EA               cmpd      #$0002
                    rts

INTDIV              bsr       L13D0
                    bne       L1401
                    ldd       $07,y
                    beq       L140E
                    asra
                    rorb
                    std       $07,y
                    ldd       #$0000
                    rolb
                    bra       L1438

L1401               ldd       $01,y
                    bne       L140A
                    ldb       #E$DivZer
                    lbra      L1102
L140A               ldd       $07,y
                    bne       L1413
L140E               leay      $06,y
                    std       $03,y
                    rts
L1413               tsta
                    bne       L141E
                    exg       a,b
                    std       $07,y
                    ldb       #$08
                    bra       L1420
L141E               ldb       #$10
L1420               stb       $03,y
                    clra
                    clrb
L1424               lsl       $08,y
                    rol       $07,y
                    rolb
                    rola
                    subd      $01,y
                    bmi       L1432
                    inc       $08,y
                    bra       L1434
L1432               addd      $01,y
L1434               dec       $03,y
                    bne       L1424
L1438               std       $09,y
                    tst       ,y
                    bpl       L144C
                    nega
                    negb
                    sbca      #$00
                    std       $09,y
                    ldd       $07,y
                    nega
                    negb
                    sbca      #$00
                    std       $07,y
L144C               leay      $06,y
                    rts

RCPCNST             leay      -$06,y
                    ldb       ,x+
                    lda       #$02
                    std       ,y
                    ldd       ,x++
                    std       $02,y
                    ldd       ,x++
                    std       $04,y
                    rts

L2102               ldd       ,x++
                    addd      <u0031
                    tfr       d,u
RCPVAR              leay      -$06,y
                    lda       #$02
                    ldb       ,u
                    std       ,y
                    ldd       1,u
                    std       $02,y
                    ldd       3,u
                    std       $04,y
                    rts

* invert sign of real number
NEGrl               lda       $05,y
                    eora      #$01
                    sta       $05,y
                    rts

RLSUB
L147E               ldb       $05,y
                    eorb      #$01
                    stb       $05,y

RLADD               pshs      x
                    tst       $02,y
                    beq       L149A
                    tst       $08,y
                    bne       L149E
L148E               ldd       $01,y
                    std       $07,y
                    ldd       $03,y
                    std       $09,y
                    lda       $05,y
                    sta       $0B,y
L149A               leay      $06,y
                    puls      pc,x

* compare exponents
L149E               lda       $07,y
                    suba      $01,y
                    bvc       L14A8
                    bpl       L148E
                    bra       L149A
L14A8               bmi       L14B0
                    cmpa      #$1F
                    ble       L14B8
                    bra       L149A
L14B0               cmpa      #$E1
                    blt       L148E
                    ldb       $01,y
                    stb       $07,y
L14B8               ldb       $0B,y
                    andb      #$01
                    stb       ,y
                    eorb      $05,y
                    andb      #$01
                    stb       $01,y
                    ldb       $0B,y
                    andb      #$FE
                    stb       $0B,y
                    ldb       $05,y
                    andb      #$FE
                    stb       $05,y
                    tsta
                    beq       L1504
                    bpl       L14FC
                    nega
                    leax      $06,y
                    bsr       L1555
                    tst       $01,y
                    beq       L150C
L14DE               subd      $04,y
                    exg       d,x
                    sbcb      $03,y
                    sbca      $02,y
                    bcc       L1520
                    coma
                    comb
                    exg       d,x
                    coma
                    comb
                    addd      #$0001
                    exg       d,x
                    bcc       L14F8
                    addd      #$0001
L14F8               dec       ,y
                    bra       L1520
L14FC               leax      ,y
                    bsr       L1555
                    stx       $02,y
                    std       $04,y
L1504               ldx       $08,y
                    ldd       $0A,y
                    tst       $01,y
                    bne       L14DE
L150C               addd      $04,y
                    exg       d,x
                    adcb      $03,y
                    adca      $02,y
                    bcc       L1520
                    rora
                    rorb
                    exg       d,x
                    rora
                    rorb
                    inc       $07,y
                    exg       d,x
L1520               tsta
                    bmi       L1533
L1523               dec       $07,y
                    lbvs      L15B0
                    exg       d,x
                    lslb
                    rola
                    exg       d,x
                    rolb
                    rola
                    bpl       L1523
L1533               exg       d,x
                    addd      #$0001
                    exg       d,x
                    bcc       L1544
                    addd      #$0001
                    bcc       L1544
                    rora
                    inc       $07,y
L1544               std       $08,y
                    tfr       x,d
                    andb      #$FE
                    tst       ,y
                    beq       L154F
                    incb
L154F               std       $0A,y
                    leay      $06,y
                    puls      pc,x
L1555               suba      #$10
                    bcs       L1573
                    suba      #$08
                    bcs       L1564
                    pshs      a
                    clra
                    ldb       $02,x
                    bra       L156A
L1564               adda      #$08
                    pshs      a
                    ldd       $02,x
L156A               ldx       #$0000
                    tst       ,s
                    beq       L159C
                    bra       L1590
L1573               adda      #$08
                    bcc       L1586
                    pshs      a
                    clra
                    ldb       $02,x
                    ldx       $03,x
                    tst       ,s
                    bne       L1592
                    exg       d,x
                    bra       L159C
L1586               adda      #$08
                    pshs      a
                    ldd       $02,x
                    ldx       $04,x
                    bra       L1592
L1590               exg       d,x
L1592               lsra
                    rorb
                    exg       d,x
                    rora
                    rorb
                    dec       ,s
                    bne       L1590
L159C               leas      $01,s
                    rts

RLMUL               bsr       L15A6
                    lbcs      L1102
                    rts
L15A6               pshs      x
                    lda       $02,y
                    bpl       L15B0
                    lda       $08,y
                    bmi       L15BC
L15B0               clra
                    clrb
                    std       $07,y
                    std       $09,y
                    sta       $0B,y
                    leay      $06,y
                    puls      pc,x
L15BC               lda       $01,y
                    adda      $07,y
                    bvc       L15C9
L15C2               bpl       L15B0
                    comb
                    ldb       #$32
                    puls      pc,x
L15C9               sta       $07,y
                    ldb       $0B,y
                    eorb      $05,y
                    andb      #$01
                    stb       ,y
                    lda       $0B,y
                    anda      #$FE
                    sta       $0B,y
                    ldb       $05,y
                    andb      #$FE
                    stb       $05,y
                    mul
                    sta       ,-s
                    clr       ,-s
                    clr       ,-s
                    lda       $0B,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L15F3
                    inc       ,s
L15F3               lda       $0A,y
                    ldb       $05,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1600
                    inc       ,s
L1600               ldb       $02,s
                    ldx       ,s
                    stx       $01,s
                    clr       ,s
                    lda       $0B,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1615
                    inc       ,s
L1615               lda       $0A,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1622
                    inc       ,s
L1622               lda       $09,y
                    ldb       $05,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L162F
                    inc       ,s
L162F               ldb       $02,s
                    ldx       ,s
                    stx       $01,s
                    clr       ,s
                    lda       $0B,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1644
                    inc       ,s
L1644               lda       $0A,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1651
                    inc       ,s
L1651               lda       $09,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L165E
                    inc       ,s
L165E               lda       $08,y
                    ldb       $05,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L166B
                    inc       ,s
L166B               ldb       $02,s
                    ldx       ,s
                    stx       $01,s
                    clr       ,s
                    stb       $0B,y
                    lda       $0A,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1682
                    inc       ,s
L1682               lda       $09,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L168F
                    inc       ,s
L168F               lda       $08,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L169C
                    inc       ,s
L169C               ldb       $02,s
                    ldx       ,s
                    stx       $01,s
                    clr       ,s
                    stb       $0A,y
                    lda       $09,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L16B3
                    inc       ,s
L16B3               lda       $08,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L16C0
                    inc       ,s
L16C0               lda       $08,y
                    ldb       $02,y
                    mul
                    addd      ,s
                    bmi       L16D5
                    lsl       $0B,y
                    rol       $0A,y
                    rol       $02,s
                    rolb
                    rola
                    dec       $07,y
                    bvs       L16EE
L16D5               std       $08,y
                    lda       $02,s
                    ldb       $0A,y
                    addd      #$0001
                    bcc       L16F3
                    inc       $09,y
                    bne       L16F5
                    inc       $08,y
                    bne       L16F5
                    ror       $08,y
                    inc       $07,y
                    bvc       L16F5
L16EE               leas      $03,s
                    lbra      L15C2
L16F3               andb      #$FE
L16F5               orb       ,y
                    std       $0A,y
                    leay      $06,y
                    leas      $03,s
                    clrb
                    puls      pc,x

RLDIV               bsr       L1707
                    lbcs      L1102
L1706               rts
L1707               comb
                    ldb       #$2D
                    tst       $02,y
                    beq       L1706
                    pshs      x
                    tst       $08,y
                    lbeq      L15B0
                    lda       $07,y
                    suba      $01,y
                    lbvs      L15C2
                    sta       $07,y
                    lda       #$21
                    ldb       $05,y
                    eorb      $0B,y
                    andb      #$01
                    std       ,y
                    lsr       $02,y
                    ror       $03,y
                    ror       $04,y
                    ror       $05,y
                    ldd       $08,y
                    ldx       $0A,y
                    lsra
                    rorb
                    exg       d,x
                    rora
                    rorb
                    clr       $0B,y
                    bra       L1742
L1740               exg       d,x
L1742               subd      $04,y
                    exg       d,x
                    bcc       L174B
                    subd      #$0001
L174B               subd      $02,y
                    beq       L177E
                    bmi       L177A
L1751               orcc      #Carry
L1753               dec       ,y
                    beq       L17CB
                    rol       $0B,y
                    rol       $0A,y
                    rol       $09,y
                    rol       $08,y
                    exg       d,x
                    lslb
                    rola
                    exg       d,x
                    rolb
                    rola
                    bcc       L1740
                    exg       d,x
                    addd      $04,y
                    exg       d,x
                    bcc       L1774
                    addd      #$0001
L1774               addd      $02,y
                    beq       L177E
                    bpl       L1751
L177A               andcc     #^Carry
                    bra       L1753
L177E               leax      ,x
                    bne       L1751
                    ldb       ,y
                    decb
                    subb      #$10
                    blt       L17A0
                    subb      #$08
                    blt       L1795
                    stb       ,y
                    lda       $0B,y
                    ldb       #$80
                    bra       L17BE
L1795               addb      #$08
                    stb       ,y
                    ldd       #$8000
                    ldx       $0A,y
                    bra       L17C0
L17A0               addb      #$08
                    blt       L17AE
                    stb       ,y
                    ldx       $09,y
                    lda       $0B,y
                    ldb       #$80
                    bra       L17C0
L17AE               addb      #$07
                    stb       ,y
                    ldx       $08,y
                    ldd       $0A,y
                    orcc      #Carry
L17B8               rolb
                    rola
                    exg       d,x
                    rolb
                    rola
L17BE               exg       d,x
L17C0               andcc     #^Carry
                    dec       ,y
                    bpl       L17B8
                    exg       d,x
                    tsta
                    bra       L17CF
L17CB               ldx       $0A,y
                    ldd       $08,y
L17CF               bmi       L17DF
                    exg       d,x
                    rolb
                    rola
                    exg       d,x
                    rolb
                    rola
                    dec       $07,y
                    lbvs      L15B0
L17DF               exg       d,x
                    addd      #$0001
                    exg       d,x
                    bcc       L17F4
                    addd      #$0001
                    bcc       L17F4
                    rora
                    inc       $07,y
                    lbvs      L15C2
L17F4               std       $08,y
                    tfr       x,d
                    andb      #$FE
                    orb       $01,y
                    std       $0A,y
                    inc       $07,y
                    lbvs      L15C2
L1804               leay      $06,y
                    clrb
                    puls      pc,x

POWERS              pshs      x
                    ldd       $07,y
                    beq       L1804
                    ldx       $01,y
                    bne       L1822
                    leay      $06,y
L1815               ldd       #$0180
                    std       $01,y
                    clr       $03,y
                    clr       $04,y
                    clr       $05,y
                    puls      pc,x
L1822               std       $01,y
                    stx       $07,y
                    ldd       $09,y
                    ldx       $03,y
                    std       $03,y
                    stx       $09,y
                    lda       $0B,y
                    ldb       $05,y
                    sta       $05,y
                    stb       $0B,y
                    puls      x
                    lbsr      LOG
                    lbsr      RLMUL
                    lbra      L1D37

BlCPVAR             ldd       ,x++
                    addd      <u0031
                    tfr       d,u
L13                 ldb       ,u
                    clra
                    leay      -$06,y
                    std       $01,y
                    lda       #$03
                    sta       ,y
                    rts

LANDB               ldb       $08,y
                    andb      $02,y
                    bra       L1863

LORB                ldb       $08,y
                    orb       $02,y
                    bra       L1863

LXORB               ldb       $08,y
                    eorb      $02,y
L1863               leay      $06,y
                    std       $01,y
                    rts

LNOTB               com       $02,y
                    rts

                    use       basic09_compare.asm

                    use       basic09_rlcmp.asm

                    use       basic09_strops.asm

                    use       basic09_floatfix.asm

                    use       basic09_scalar.asm

                    use       basic09_sqrt.asm

MODint              lbsr      INTDIV
                    ldd       $03,y
                    std       $01,y
                    rts

                    use       basic09_miscfunc.asm

                    use       basic09_logexp.asm

                    use       basic09_trig.asm

                    use       basic09_rnd.asm

                    use       basic09_strfns.asm

                    use       basic09_datefunc.asm

UNK12               ldb       #$06
                    pshs      y,x,b
                    tfr       dp,a
                    ldb       #$50
                    tfr       d,y
                    leax      >L4DCE,pcr
L2531               ldd       ,x++
                    std       ,y++
                    dec       ,s
                    bne       L2531
                    leax      >L1188,pcr
                    stx       <table2
                    leax      >L1208,pcr
                    stx       <table3
                    lda       #$7E
                    sta       <u0016
                    leax      >L1214,pcr
                    stx       <u0017
                    puls      pc,y,x,b

L2551               pshs      x,b,a
                    ldb       [<$04,s]
                    leax      <L2561,pcr
                    ldd       b,x
                    leax      d,x
                    stx       $04,s
                    puls      pc,x,b,a
L2561               fdb       $00ba
                    fdb       $0010
L2565               jsr       <u0027
                    fcb       $0C
Flote               jsr       <u0027
                    fcb       $0E
L256B               jsr       <u0027
                    fcb       $08
L256E               jsr       <u0027
                    fcb       $06
                    pshs      pc,x,b,a
                    lslb
                    leax      <L257F,pcr
L2577               ldd       b,x
L2579               leax      d,x
                    stx       $04,s
                    puls      pc,x,b,a

L257F               fdb       WRITLN-L257F
                    fdb       PRintg-L257F
                    fdb       PRintg-L257F
                    fdb       PRreal-L257F
                    fdb       PRbool-L257F
                    fdb       PRstring-L257F
                    fdb       READLN-L257F
                    fdb       L2006-L257F
                    fdb       L2007-L257F
                    fdb       L2008-L257F
                    fdb       L20X9-L257F
                    fdb       L2010-L257F
                    fdb       Strterm-L257F
                    fdb       L2B66-L257F
                    fdb       setFP-L257F
                    fdb       err48-L257F
                    fdb       L2015-L257F
                    fdb       PRNTUSIN-L257F
                    fdb       L2AE1-L257F
                    fdb       L2018-L257F

                    use       basic09_iofunc.asm

                    emod
eom                 equ       *
