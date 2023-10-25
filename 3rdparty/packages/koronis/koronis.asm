********************************************************************
* Koronis - Koronis Rift Program
*
* $Id$
*
* NOTE:  This code assembles to the EXACT same object code found on
*        the original Koronis Rift disk.
*
*        Module size: $5C68  #23656
*        Module CRC : $FA659A (Good)
*        Hdr parity : $1C
*        Exec. off  : $0014  #20
*        Data size  : $6000  #24576
*        Edition    : $30  #48
*        Ty/La At/Rv: $11 $81
*        Prog mod, 6809 Obj, re-ent, R/O
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2003/01/12  Boisy G. Pitre
* Disassembled from original binary; patched so that standard output
* is used and /TERM is no longer assumed.
*          2011/08/01  Robert Gault
* Changed two routines that toggle the RS-232 line at $FF20 to the
* single bit sound line at $FF22. This preserves timing and prevents
* DriveWire complications. L5A1F, L5A2C

                    nam       Koronis
                    ttl       Koronis Rift Program

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       1
u0005               rmb       1
u0006               rmb       1
u0007               rmb       1
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       1
u000C               rmb       1
u000D               rmb       1
u000E               rmb       1
u000F               rmb       1
u0010               rmb       1
u0011               rmb       1
u0012               rmb       1
u0013               rmb       1
u0014               rmb       1
u0015               rmb       1
u0016               rmb       1
u0017               rmb       1
u0018               rmb       1
u0019               rmb       1
u001A               rmb       1
u001B               rmb       1
u001C               rmb       1
u001D               rmb       1
u001E               rmb       2
u0020               rmb       1
u0021               rmb       1
u0022               rmb       1
u0023               rmb       1
u0024               rmb       1
u0025               rmb       1
u0026               rmb       1
u0027               rmb       1
u0028               rmb       1
u0029               rmb       2
u002B               rmb       1
u002C               rmb       1
u002D               rmb       2
u002F               rmb       1
u0030               rmb       1
u0031               rmb       1
u0032               rmb       1
u0033               rmb       1
u0034               rmb       1
u0035               rmb       1
u0036               rmb       1
u0037               rmb       1
u0038               rmb       1
u0039               rmb       6
u003F               rmb       1
u0040               rmb       1
u0041               rmb       2
u0043               rmb       3
u0046               rmb       5
u004B               rmb       2
u004D               rmb       3
u0050               rmb       2
u0052               rmb       1
u0053               rmb       2
u0055               rmb       2
u0057               rmb       1
u0058               rmb       1
u0059               rmb       1
u005A               rmb       1
u005B               rmb       1
u005C               rmb       2
u005E               rmb       1
u005F               rmb       1
u0060               rmb       1
u0061               rmb       1
u0062               rmb       1
u0063               rmb       1
u0064               rmb       1
u0065               rmb       1
u0066               rmb       1
u0067               rmb       1
u0068               rmb       1
u0069               rmb       1
u006A               rmb       1
u006B               rmb       1
u006C               rmb       1
u006D               rmb       3
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
u007D               rmb       2
u007F               rmb       1
u0080               rmb       1
u0081               rmb       1
u0082               rmb       1
u0083               rmb       1
u0084               rmb       1
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
u008F               rmb       1
u0090               rmb       1
u0091               rmb       1
u0092               rmb       1
u0093               rmb       2
u0095               rmb       1
u0096               rmb       1
u0097               rmb       1
u0098               rmb       1
u0099               rmb       1
u009A               rmb       1
u009B               rmb       1
u009C               rmb       1
u009D               rmb       1
u009E               rmb       1
u009F               rmb       1
u00A0               rmb       2
u00A2               rmb       2
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
u00AF               rmb       1
u00B0               rmb       1
u00B1               rmb       1
u00B2               rmb       1
u00B3               rmb       1
u00B4               rmb       1
u00B5               rmb       1
u00B6               rmb       2
u00B8               rmb       2
u00BA               rmb       2
u00BC               rmb       1
u00BD               rmb       1
u00BE               rmb       1
u00BF               rmb       1
u00C0               rmb       1
u00C1               rmb       1
u00C2               rmb       1
u00C3               rmb       2
u00C5               rmb       3
u00C8               rmb       1
u00C9               rmb       1
u00CA               rmb       1
u00CB               rmb       1
u00CC               rmb       3
u00CF               rmb       1
u00D0               rmb       4
u00D4               rmb       1
u00D5               rmb       1
u00D6               rmb       2
u00D8               rmb       2
u00DA               rmb       1
u00DB               rmb       1
u00DC               rmb       2
u00DE               rmb       1
u00DF               rmb       1
u00E0               rmb       1
u00E1               rmb       1
u00E2               rmb       2
u00E4               rmb       2
u00E6               rmb       1
u00E7               rmb       1
u00E8               rmb       1
u00E9               rmb       1
u00EA               rmb       1
u00EB               rmb       1
u00EC               rmb       1
u00ED               rmb       2
u00EF               rmb       1
u00F0               rmb       1
u00F1               rmb       1
u00F2               rmb       1
u00F3               rmb       1
u00F4               rmb       1
u00F5               rmb       1
u00F6               rmb       1
u00F7               rmb       1
u00F8               rmb       1
u00F9               rmb       2
u00FB               rmb       2
u00FD               rmb       2
u00FF               rmb       1
u0100               rmb       256
u0200               rmb       236
u02EC               rmb       52
u0320               rmb       80
u0370               rmb       14400
u3BB0               rmb       9296
size                equ       .

name                fcs       /KORONIS/

start               leax      >IcptRtn,pcr
                    ldu       #$0000
                    os9       F$Icpt
                    orcc      #IntMasks
                    lds       #$5EE4
                    andcc     #^Intmasks
                    leax      >ScrnDev,pcr
* This code was patched to disallow opening /TERM.  This is so that the game
* can use the window/screen that it was forked from.
*         lda   #$03
                    nop
                    nop
*         os9   I$Open
                    nop
                    nop
                    nop
*         lbcs  L0156
                    nop
                    nop
                    lda       #$01
                    sta       >$0100
L0036               lda       #$04
                    lbsr      L4A6C
                    bcc       L0036
                    lbsr      L015B
                    lda       >$0371
                    pshs      a
                    lda       >$0100
                    ldb       #SS.Montr
                    ldx       >$0370
                    os9       I$SetStt            set monitor type
                    lda       >$0100
                    ldb       #SS.AScrn
                    ldx       #$0002
                    os9       I$SetStt            allocate screen
                    lbcs      L0156
                    stx       >$0103
                    sty       >$0101
                    pshs      y,x
                    lda       >$0100
                    clrb                          SS.Opt
                    ldx       #$034F
                    os9       I$GetStt            get options
                    clr       >$0353
                    clr       >$0356
                    lda       >$0100
                    clrb                          SS.Opt
                    ldx       #$034F
                    os9       I$SetStt            set options
                    ldu       #$0500
                    leax      >CTitle,pcr
                    lda       #$01
                    lbsr      L4A6C
                    lbsr      L0147
                    ldy       >$0101
                    lda       >$0100
                    ldb       #SS.DScrn
                    os9       I$SetStt            display screen
                    lbcs      L0154
                    ldy       #$0382
                    ldd       #$FF0F
L00A8               sta       b,y
                    decb
                    bpl       L00A8
                    leay      >L0244,pcr
                    lbsr      L013D
                    ldu       #$0500
                    leax      >CRobot,pcr
                    lda       #$01
                    lbsr      L4A6C
                    pshs      y
                    lda       #$30
                    sta       >$036F
                    clra
                    lbsr      L5A4C
                    leay      >L0224,pcr
                    lda       >$0371
                    ldb       #$10
                    mul
                    leay      d,y
                    bsr       L013D
                    puls      y
                    bsr       L0147
                    clra
                    ldu       #$0000
                    ldy       #$2869
                    leax      >KorVar,pcr
                    lbsr      L4A6C
                    puls      y,x
                    stx       >$0103
                    sty       >$0101
                    puls      a
                    sta       >$0371
                    lbra      L0264
L00FD               ldd       #SS.Joy
                    ldx       #$0001
                    os9       I$GetStt            get joystick values
                    tsta
                    beq       L00FD
                    rts
L010A               pshs      u,y,x,b,a
L010C               ldx       #$0382
                    cmpa      b,x
                    beq       L012F
                    sta       b,x
                    ldy       #$1B31              palette escape code
                    sty       >$034B
                    stb       >$034D
                    sta       >$034E
                    ldx       #$034B
                    ldy       #$0004
                    lda       #$01
                    os9       I$Write             write palette escape sequence
L012F               puls      pc,u,y,x,b,a
L0131               pshs      u,y,x,b,a
                    pshs      a
                    tfr       x,d
                    addb      #$05
                    puls      a
                    bra       L010C
L013D               ldb       #$0F
L013F               lda       b,y
                    bsr       L010A
                    decb
                    bpl       L013F
                    rts
L0147               ldu       >$0103
                    ldx       #$0500
                    lbra      L3243

* Intercept routine - merely return
IcptRtn             rti

                    ldd       #$0000
L0154               puls      y,x,a
L0156               lda       #$03
                    lbra      L4A6C
L015B               clr       >$0370
L015E               lbsr      L4B4C
                    leax      >Welcome,pcr
                    ldy       #$0023
                    lbsr      L01A1
                    leax      >MonTypes,pcr
                    ldy       #$001F
                    lbsr      L01A1
                    leax      >MonTypeQ,pcr
                    ldy       #$001A
                    lbsr      L01A1
                    clr       >$0371
L0185               lbsr      L4B6A
                    bcs       L0185
                    cmpa      #$63
                    beq       L019D
                    cmpa      #$43
                    beq       L019D
                    inc       >$0371
                    cmpa      #$72
                    beq       L019D
                    cmpa      #$52
                    bne       L015E
L019D               lbsr      L4B4C
                    rts
L01A1               lda       >$0100
                    os9       I$Write
                    rts

ScrnDev             fcc       "/TERM"
                    fcb       C$CR
KorVar              fcc       "KORVAR"
                    fcb       C$CR
CTitle              fcc       "CTITLE.C"
                    fcb       C$CR
CRobot              fcc       "CROBOT2.C"
                    fcb       C$CR
MonTypeQ            fcc       "     MONITOR TYPE (C/R) ? "
MonTypes            fcc       "  C = COMPOSITE (TV), R = RGB"
                    fcb       C$CR,C$LF
Welcome             fcb       C$CR,C$LF
                    fcb       C$LF,C$LF,C$LF
                    fcc       "    WELCOME TO KORONIS RIFT"
                    fcb       C$CR,C$LF,C$LF

* Palette Values
L0224               fcb       $0B,$29,$04,$34,$26,$10,$12,$36
                    fcb       $01,$02,$07,$2D,$20,$38,$00,$3F
L0234               fcb       $0A,$29,$20,$34,$26,$12,$10,$36
                    fcb       $09,$02,$07,$2D,$24,$38,$00,$3F
L0244               fcb       $00,$3F,$20,$13,$10,$02,$19,$1B
                    fcb       $36,$34,$26,$2D,$29,$0C,$38,$07
L0254               fcb       $12,$36,$09,$24,$3F,$1B,$2D,$34
                    fcb       $00,$12,$00,$3F,$00,$12,$00,$34

L0264               clr       >$0409
L0267               lda       #$FF
                    sta       >$03D0
L026C               lbsr      L0430
                    lbsr      L42A1
L0272               lda       >$33ED
                    bne       L0286
                    lda       >$33EC
L027A               beq       L0281
                    lbsr      L53B2
                    bra       L0272
L0281               lda       >$33EF
                    beq       L0296
L0286               lda       >$3666
                    bne       L0296
                    lbsr      L53A9
                    lbsr      L4881
                    clr       >$33ED
                    bra       L026C
L0296               lbsr      L41DB
                    lda       <u00F7
                    beq       L02B0
                    lbsr      L53B2
                    lbsr      L4465
                    lbsr      L430D
                    lda       #$14
                    lbsr      L36BC
                    lbsr      L24BE
                    bra       L0272
L02B0               lda       >$33EE
                    bne       L0272
                    lda       >$366E
                    bne       L02CC
                    lbsr      L16A4
                    lda       #$1F
                    lbsr      L36BC
                    lda       <u00A8
                    ora       >$3413
                    ora       >$3410
                    beq       L02FA
L02CC               lbsr      L042F
                    lbsr      L06C4
                    lda       #$15
                    lbsr      L36BC
                    lbsr      L24BE
                    lbsr      L0EB2
                    lda       #$01
                    lbsr      L36C9
                    lda       #$6B
                    lbsr      L36BC
                    lbsr      L24BE
                    lbsr      L0714
                    lda       #$04
                    lbsr      L36C9
                    lda       #$32
                    lbsr      L36BC
                    lbsr      L042F
L02FA               lbsr      L24BE
                    lbsr      L53B2
                    clr       >$3410
                    lbsr      L5A1F
                    lbsr      L2A6F
                    lbsr      L5A2C
                    lda       #$02
                    sta       >$5EE4
                    lbsr      L36C9
                    lda       #$C0
                    lbsr      L36BC
                    lbsr      L24BE
                    lbsr      L2D9F
                    lda       #$54
                    lbsr      L36BC
                    lbsr      L24BE
                    lbsr      L1CB1
                    lbsr      L0386
                    lbsr      L1AA0
                    lbsr      L19EE
                    lbsr      L1985
                    lbsr      L0395
                    clr       >$343A
                    clr       >$343F
                    lbsr      L255D
                    lda       >$3664
                    beq       L034A
                    lbsr      L5A4C
L034A               lda       >$34BF
                    beq       L0361
                    clra
                    clrb
                    lbsr      L010A
                    lda       #$05
                    lbsr      L5A4C
                    lda       [>$0374]
                    clrb
                    lbsr      L010A
L0361               lda       >$3405
                    beq       L037D
                    ldb       #$03
                    lda       >$33F2
                    lbsr      L010A
                    lda       #$06
                    lbsr      L5A4C
                    ldu       >$0374
                    lda       u0003,u
                    ldb       #$03
                    lbsr      L010A
L037D               clr       >$3405
                    clr       >$34BF
                    lbra      L0272
L0386               lbsr      L389A
                    lbsr      L2E05
                    lbsr      L2F17
                    lbsr      L4CE1
                    lbra      L3006
L0395               tst       >$336B
                    beq       L03A4
                    lda       #$80
                    sta       >$343A
                    orcc      #Carry
                    lbsr      L20EA
L03A4               lda       #$60
                    sta       >$3CE0
                    orcc      #IntMasks
                    stx       <u0095
                    stu       <u0099
                    sts       <u007F
                    sty       <u0081
                    lds       #$4008
                    ldu       #$0243
                    ldu       ,u
                    leau      u0007,u
L03C0               puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000A,u
                    puls      dp,b,a
                    pshu      dp,b,a
                    leau      u000A,u
                    clra
                    tfr       a,dp
                    sts       >$0347
                    lds       <u007F
                    andcc     #^IntMasks
                    orcc      #IntMasks
                    lds       >$0347
                    dec       >$3CE0
                    bne       L03C0
                    clra
                    tfr       a,dp
                    ldx       <u0095
                    ldy       <u0081
                    ldu       <u0099
                    lds       <u007F
                    andcc     #^IntMasks
                    rts
L042F               rts
L0430               ldu       >$0103
                    leau      >u3BB0,u
                    ldb       #$C0
                    ldy       #$0105
L043D               stu       ,y++
                    leau      <-u0050,u
                    decb
                    bne       L043D
                    ldu       #$5DB8
                    ldb       #$5F
                    ldy       #$0285
L044E               stu       ,y++
                    leau      <-u0050,u
                    decb
                    bpl       L044E
                    clra
                    ldy       #$2869
                    ldx       #$179F
                    lbsr      L18AB
                    clra
                    ldy       #$0000
                    ldx       #$0100
                    lbsr      L18AB
                    lda       #$01
                    sta       >$33EB
                    sta       >$3410
                    lda       #$04
                    sta       >$342D
                    lda       #$04
                    sta       <u00ED
                    sta       >$338C
                    lda       #$30
                    sta       >$036F
                    lda       #$80
                    sta       >$3390
                    lda       #$32
                    sta       >$3393
                    sta       >$3438
                    lda       #$FF
                    sta       >$32D5
                    sta       >$3661
                    sta       >$3417
                    sta       >$32D3
                    sta       >$3463
                    ldb       #$0E
                    ldx       #$33A4
L04A8               sta       b,x
                    decb
                    bpl       L04A8
                    sta       >$33EE
                    sta       >$3334
                    ldx       #$000C
                    ldu       #$1138
                    ldy       #$32D8
L04BD               ldd       ,u++
                    std       ,y++
                    leax      -$01,x
                    bne       L04BD
                    lda       #$05
                    sta       >$3399
                    lda       #$01
                    sta       <u00EF
                    sta       <u00EC
                    lda       #$05
                    sta       >$33C4
                    lda       #$0A
                    sta       >$340B
                    sta       >$340C
                    lda       #$10
                    sta       >$331F
                    lda       #$10
                    sta       >$33C6
                    sta       <u00E6
                    leax      >L57CF,pcr
                    stx       >$07B6
                    leax      >L5864,pcr
                    stx       >$07B8
                    ldx       #$322D
                    ldb       #$05
L04FC               stb       b,x
                    decb
                    bpl       L04FC
                    lbsr      L068B
                    lda       >$03D0
                    beq       L050C
                    lbsr      L0621
L050C               lbsr      L18CE
                    lbsr      L1932
                    ldy       #$0013
                    ldu       #$000F
                    ldx       #$00CE
                    ldd       #$0003
L051F               sta       b,u
                    sta       b,y
                    sta       b,x
                    decb
                    bpl       L051F
                    ldd       #$FF05
                    ldx       #$31E5
L052E               sta       b,x
                    decb
                    bpl       L052E
                    ldd       #$FF07
                    ldy       #$30E5
                    ldx       #$32C5
L053D               sta       ,y
                    sta       ,x+
                    leay      <$20,y
                    decb
                    bpl       L053D
                    clr       >$32CD
                    lbsr      L05E1
                    lda       #$06
                    sta       >$3336
                    lda       #$40
                    sta       >$3335
                    lda       #$10
                    sta       >$32D7
                    lda       #$08
                    sta       >$33CA
                    clr       >$33EC
                    lbsr      L4912
                    lbsr      L245C
                    lda       #$80
                    sta       <u00F6
                    lbsr      L208C
                    clr       >$03D0
                    lbra      L20A3
L0577               ldd       #$0C46
                    std       <u007F
                    lbsr      L49BC
                    lda       #$20
                    sta       ,y
                    lda       #$01
                    sta       >$33BF
                    lda       #$11
                    sta       <u00E9
                    lda       #$00
                    sta       <u00EB
                    lda       #$FF
                    sta       <u00EA
                    lda       #$FF
                    sta       >$3417
                    lbsr      L197F
                    lbsr      L196D
                    ldx       #$0002
                    lbsr      L1906
                    ldx       #$0005
                    lbsr      L1906
                    lbsr      L1979
                    lbsr      L1973
                    lda       #$0F
                    sta       <u00F5
                    ldb       #$05
L05B7               ldu       #$31E5
                    lda       b,u
                    cmpa      #$FF
                    beq       L05C3
                    lbsr      L5038
L05C3               decb
                    bpl       L05B7
                    ldb       #$05
                    ldy       #$3340
                    ldx       #$333A
L05CF               lda       b,y
                    sta       b,x
                    decb
                    bpl       L05CF
                    ldd       <u00AE
                    std       <u00BE
                    ldd       <u00B0
                    std       <u00C0
                    lbra      L37FD
L05E1               ldx       #$0000
                    ldy       #$0002
                    lda       #$14
                    sta       <u008F
                    lbsr      L060B
                    lda       #$01
                    ldb       #$02
                    lbsr      L5196
                    ldx       #$0014
                    ldy       #$0003
                    lda       #$19
                    sta       <u008F
                    lbsr      L060B
                    lda       #$02
                    ldb       #$03
                    lbra      L5196
L060B               tfr       x,d
                    ldx       #$069C
                    leax      d,x
                    leay      >$31E5,y
L0616               lda       ,x+
                    sta       ,y
                    leay      $06,y
                    dec       <u008F
                    bne       L0616
                    rts
L0621               ldx       #$050A
                    clrb
L0625               lda       >$33EB
                    lsla
                    lsla
                    lsla
                    lsla
                    adda      >$33EB
                    adda      #$25
                    sta       >$33EB
                    sta       ,x+
                    incb
                    bne       L0625
                    rts
L063A               lda       >$1F69
                    sta       <u00AE
                    sta       >$3314
                    sta       >$3310
                    sta       >$330C
                    lda       >$1F6A
                    sta       <u00B0
                    sta       >$3316
                    sta       >$3312
                    sta       >$330E
                    clr       <u00A7
                    clr       <u0011
                    lda       #$03
                    sta       <u00A8
                    lda       #$FF
                    sta       >$108E
                    sta       >$108F
                    sta       >$3463
                    lda       #$01
                    sta       >$3410
                    lda       >$1F6B
                    inca
                    sta       >$34DF
                    ldy       #$345B
                    ldb       #$07
L067B               clr       b,y
                    decb
                    bpl       L067B
                    ldb       >$1F6B
                    lda       #$01
L0685               sta       b,y
                    decb
                    bpl       L0685
                    rts
L068B               lda       >$0371
                    bne       L06AA
                    leax      >L0224,pcr
                    stx       >$0372
                    ldd       #$0970
                    std       >$0374
                    ldd       #$10A0
                    std       >$0376
                    ldd       #$10C0
                    std       >$0378
                    rts
L06AA               leax      >L0234,pcr
                    stx       >$0372
                    ldd       #$0960
                    std       >$0374
                    ldd       #$1090
                    std       >$0376
                    ldd       #$10B0
                    std       >$0378
                    rts
L06C4               ldb       <u00A7
                    stb       >$3327
                    lda       #$04
                    mul
                    sta       >$332F
                    ldd       <u00AE
                    std       <u00BE
                    ldd       <u00B0
                    std       <u00C0
                    lbsr      L130A
                    ldd       >$3320
                    std       <u001A
                    ldd       >$3322
                    std       <u001C
                    lda       >$3695
                    sta       >$3683
                    ldx       #$0000
                    clrb
L06EE               lda       >$3683,x
                    addd      >$3693
                    sta       >$3684,x
                    leax      $01,x
                    cmpx      #$000F
                    bne       L06EE
                    clrb
                    ldx       #$0010
L0704               lda       >$3673,x
                    subd      >$3693
                    sta       >$3672,x
                    leax      -$01,x
                    bne       L0704
                    rts
L0714               lda       <u00A7
                    sta       >$34B2
                    lda       <u00AF
                    sta       >$34B4
                    lda       <u00B1
                    sta       >$34B3
                    leay      >L1528,pcr
                    sty       >$3369
                    leay      >L1570,pcr
                    sty       >$3367
                    ldy       #$3D84
                    ldu       #$3E24
                    lda       #$5F
                    ldb       #$5F
                    tfr       d,x
                    ldb       #$50
L0742               stx       ,y++
                    stx       ,u++
                    decb
                    bne       L0742
                    clr       <u009E
                    clr       <u009F
                    ldd       >$0103
                    addd      #$3C00
                    std       >$30E1
                    addd      #$0200
                    std       >$30E3
                    lda       #$58
                    sta       <u0068
                    lda       #$A8
                    sta       <u0069
                    clr       <u006A
                    clr       <u006C
                    lda       #$FF
                    sta       <u006B
                    sta       <u006D
                    ldb       #$50
                    ldx       #$3EC4
                    ldy       #$0000
L0777               sty       ,x++
                    decb
                    bne       L0777
L077D               sty       <u0061
                    ldb       <u0062
                    ldx       >$3369
                    ldb       b,x
                    clra
                    std       <u002D
                    ldx       <u002D
                    ldu       #$38D6
                    lda       d,u
                    sta       <u0066
                    anda      #$20
                    lbne      L090D
                    ldb       <u0062
                    ldy       >$3367
                    ldb       b,y
                    clra
                    std       <u002B
                    ldx       <u002B
                    lda       d,u
                    sta       <u0067
                    anda      #$40
                    lbne      L090D
                    lda       <u0066
                    anda      <u0067
                    lbmi      L090D
                    lda       <u0067
                    anda      #$10
                    bne       L07CB
                    pshs      x
                    tfr       x,d
                    lslb
                    rola
                    tfr       d,x
                    lbsr      L1105
                    puls      x
L07CB               pshs      x
                    ldd       ,s
                    addd      ,s
                    ldu       #$3816
                    ldd       d,u
                    std       >$3906
                    ldu       #$3876
                    ldd       ,s
                    addd      ,s
                    ldd       d,u
                    std       >$3942
                    puls      b,a
                    ldu       #$37E6
                    lda       d,u
                    sta       >$397E
                    sta       <u0065
                    lda       >$3906
                    beq       L07FF
                    bpl       L07FB
                    clra
                    bra       L0802
L07FB               lda       #$FF
                    bra       L0802
L07FF               lda       >$3907
L0802               sta       <u0064
                    ldx       <u002D
                    ldu       #$38D6
                    ldd       <u002D
                    lda       d,u
                    anda      #$10
                    bne       L081C
                    tfr       x,d
                    lslb
                    rola
                    tfr       d,x
                    lbsr      L1105
                    ldx       <u002D
L081C               pshs      x
                    ldd       ,s
                    addd      ,s
                    ldu       #$3816
                    ldd       d,u
                    std       <u0057
                    ldd       ,s
                    addd      ,s
                    ldu       #$3876
                    ldd       d,u
                    std       <u0059
                    puls      b,a
                    ldu       #$37E6
                    lda       d,u
                    sta       <u005B
                    anda      <u0065
                    sta       <u0065
                    lda       <u0057
                    beq       L084E
                    bpl       L084A
                    clra
                    bra       L0850
L084A               lda       #$FF
                    bra       L0850
L084E               lda       <u0058
L0850               sta       <u0063
                    ldx       #$0000
                    lbsr      L0984
                    ldy       <u0061
                    lda       <u0065
                    lbpl      L093C
                    lda       <u0068
                    cmpa      <u0063
                    bcs       L0886
                    lda       <u0064
                    cmpa      <u0068
                    bcs       L0883
                    cmpa      <u006A
                    bcs       L0877
                    cmpa      <u006C
                    bcc       L0877
                    lda       <u006C
L0877               cmpa      <u006D
                    bcs       L0881
                    cmpa      <u006B
                    bcc       L0881
                    lda       <u006B
L0881               sta       <u0068
L0883               lbra      L090D
L0886               lda       <u0064
                    cmpa      <u0069
                    bcs       L08AF
                    lda       <u0063
                    cmpa      <u0069
                    bcc       L08AC
                    cmpa      <u006B
                    beq       L0898
                    bcc       L089E
L0898               cmpa      <u006D
                    bcs       L089E
                    lda       <u006D
L089E               cmpa      <u006C
                    beq       L08A4
                    bcc       L08AA
L08A4               cmpa      <u006A
                    bcs       L08AA
                    lda       <u006A
L08AA               sta       <u0069
L08AC               lbra      L090D
L08AF               lda       <u0063
                    adda      <u0064
                    rora
                    bmi       L08DF
                    lda       <u006C
                    bne       L08C2
                    lda       <u0063
                    sta       <u006A
                    lda       <u0064
                    sta       <u006C
L08C2               cmpa      <u0063
                    bcs       L08CE
                    lda       <u0064
                    cmpa      <u006C
                    bcs       L08CE
                    sta       <u006C
L08CE               lda       <u0064
                    cmpa      <u006A
                    bcs       L08DC
                    lda       <u0063
                    cmpa      <u006A
                    bcc       L08DC
                    sta       <u006A
L08DC               lbra      L090B
L08DF               clra
                    ldb       <u006D
                    tfr       d,x
                    lda       <u0064
                    cmpx      #$00FF
                    bne       L08F1
                    sta       <u006B
                    lda       <u0063
                    sta       <u006D
L08F1               cmpa      <u006D
                    bcs       L08FD
                    lda       <u0063
                    cmpa      <u006D
                    bcc       L08FD
                    sta       <u006D
L08FD               lda       <u006B
                    cmpa      <u0063
                    bcs       L090B
                    lda       <u0064
                    cmpa      <u006B
                    bcs       L090B
                    sta       <u006B
L090B               bra       L093C
L090D               lda       <u0068
                    cmpa      <u0069
                    bcs       L093C
                    ldy       <u0061
                    cmpy      #$0008
                    bcc       L0921
                    ldu       #$3CE4
                    bsr       L096F
L0921               cmpy      #$0014
                    bcc       L092C
                    ldu       #$3D84
                    bsr       L096F
L092C               cmpy      #$002A
                    bcc       L0937
                    ldu       #$3E24
                    bsr       L096F
L0937               ldd       <u009E
                    std       <u00A0
                    rts
L093C               ldy       <u0061
                    leay      $01,y
                    cmpy      #$0048
                    bcc       L0937
                    pshs      u,y,x
                    cmpy      #$0008
                    bne       L0954
                    ldu       #$3CE4
                    bsr       L096F
L0954               cmpy      #$0014
                    bne       L095F
                    ldu       #$3D84
                    bsr       L096F
L095F               cmpy      #$002A
                    bne       L096A
                    ldu       #$3E24
                    bsr       L096F
L096A               puls      u,y,x
                    lbra      L077D
L096F               pshs      y
                    ldd       <u009E
                    std       <u00A0
                    ldb       #$50
                    ldy       #$3EC4
L097B               ldx       ,y++
                    stx       ,u++
                    decb
                    bne       L097B
                    puls      pc,y
L0984               stx       <u0099
                    lda       >$3906
                    eora      #$80
                    sta       <u0028
                    lda       <u0057
                    eora      #$80
                    cmpa      <u0028
                    bne       L099A
                    lda       <u0058
                    cmpa      >$3907
L099A               bcc       L09FB
                    ldd       >$3906
                    std       >$3940
                    ldd       >$3942
                    std       >$397C
                    lda       >$397E
                    sta       >$399B
                    lda       #$14
                    sta       <u0019
                    ldd       #$0000
                    subd      <u0099
                    std       <u0095
                    addd      #$399B
                    tfr       d,u
                    ldd       <u0095
                    subd      <u0099
                    std       <u0095
                    addd      #$397C
                    tfr       d,y
                    ldd       <u0095
                    addd      #$3940
                    tfr       d,x
L09D0               lda       <u0057
                    bpl       L0A0C
                    dec       <u0019
                    tst       <u0019
                    bmi       L09FB
                    lbsr      L0AFB
                    ldd       <u005C
                    bmi       L09FE
                    tsta
                    bne       L09E8
                    cmpb      <u0068
                    bcs       L09FE
L09E8               std       ,--x
                    ldd       <u005E
                    std       ,--y
                    lda       <u0060
                    sta       ,-u
                    lda       <u009A
                    inca
                    sta       <u009A
                    cmpa      #$0F
                    bcs       L09D0
L09FB               ldx       <u0099
                    rts
L09FE               ldd       <u005C
                    std       <u0057
                    ldd       <u005E
                    std       <u0059
                    lda       <u0060
                    sta       <u005B
                    bra       L09D0
L0A0C               ldd       <u0057
                    tsta
                    bne       L09FB
                    cmpb      <u0069
                    bcc       L09FB
L0A15               lda       ,x
                    beq       L0A3C
L0A19               dec       <u0019
                    tst       <u0019
                    bmi       L0A39
                    lbsr      L0AFB
                    ldd       <u005C
                    std       ,--x
                    ldd       <u005E
                    std       ,--y
                    lda       <u0060
                    sta       ,-u
                    lda       <u009A
                    inca
                    sta       <u009A
                    cmpa      #$0F
                    bcc       L0A39
                    bra       L0A15
L0A39               ldx       <u0099
                    rts
L0A3C               lda       <u0059
                    bmi       L0A48
                    bne       L0A56
                    lda       <u005A
                    cmpa      #$50
                    bcc       L0A56
L0A48               lda       ,y
                    bmi       L0A64
                    bne       L0A67
                    lda       $01,y
                    cmpa      #$50
                    bcs       L0A64
                    bra       L0A67
L0A56               lda       ,y
                    bmi       L0A79
                    bne       L0A8C
                    lda       $01,y
                    cmpa      #$50
                    bcs       L0A79
                    bra       L0A8C
L0A64               lbra      L0AE2
L0A67               ldb       $01,x
                    subb      <u0058
                    cmpb      #$14
                    bcs       L0A8C
                    lsrb
                    lsrb
                    negb
                    sex
                    addd      <u0059
                    bpl       L0A8C
                    bra       L0A19
L0A79               ldb       $01,x
                    subb      <u0058
                    cmpb      #$14
                    bcs       L0A8C
                    lsrb
                    lsrb
                    negb
                    sex
                    addd      ,y
                    bpl       L0A8C
                    lbra      L0A19
L0A8C               lda       <u0059
                    beq       L0A99
                    bmi       L0A96
                    lda       #$FF
                    bra       L0A97
L0A96               clra
L0A97               sta       <u005A
L0A99               ldd       ,y
                    tsta
                    beq       L0AA7
                    bmi       L0AA4
                    lda       #$FF
                    bra       L0AA9
L0AA4               clra
                    bra       L0AA9
L0AA7               tfr       b,a
L0AA9               sta       <u0043
                    ldb       $01,x
                    stb       <u0039
                    lda       ,u
                    sta       <u004D
                    tst       <u0065
                    bmi       L0ADF
                    tst       <u0067
                    bpl       L0ACB
                    lda       <u0039
                    cmpa      #$58
                    bcs       L0ACB
                    cmpa      #$A8
                    bcc       L0ACB
                    ldb       <u0043
                    cmpb      #$50
                    bcc       L0AE2
L0ACB               tst       <u0066
                    bpl       L0ADF
                    lda       <u0058
                    cmpa      #$58
                    bcs       L0ADF
                    cmpa      #$A8
                    bcc       L0ADF
                    ldb       <u005A
                    cmpb      #$50
                    bcc       L0AE2
L0ADF               lbsr      L0B31
L0AE2               tst       <u009A
                    beq       L0AF7
                    ldd       ,x++
                    std       <u0057
                    ldd       ,y++
                    std       <u0059
                    lda       ,u+
                    sta       <u005B
                    dec       <u009A
                    lbra      L0A0C
L0AF7               ldx       #$0000
                    rts
L0AFB               ldd       <u0057
                    addd      ,x
                    asra
                    rorb
                    std       <u005C
                    ldd       <u0059
                    addd      ,y
                    asra
                    rorb
                    std       <u005E
                    lda       <u005B
                    inca
                    adda      ,u
                    sta       <u0060
                    bmi       L0B15
                    rts
L0B15               bcs       L0B26
                    ldd       <u005C
                    subd      <u0057
                    asra
                    rorb
                    pshs      b,a
                    ldd       <u005E
                    subd      ,s++
                    std       <u005E
                    rts
L0B26               ldd       <u005C
                    subd      <u0057
                    asra
                    rorb
                    addd      <u005E
                    std       <u005E
                    rts
L0B31               lda       <u0039
                    cmpa      <u0068
                    bls       L0B8E
                    cmpa      <u0058
                    bcs       L0B8E
                    bne       L0B8F
                    clra
                    ldb       <u0039
                    subb      #$58
                    lslb
                    std       <u000A
                    lda       <u0043
                    suba      #$50
                    bcs       L0B8E
                    pshs      x,b
                    ldx       <u000A
                    leax      >$3EC4,x
                    cmpa      ,x
                    bls       L0B8C
                    cmpa      #$5F
                    bls       L0B5D
                    lda       #$5F
L0B5D               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L0B8C
                    lda       <u000B
                    anda      #$01
                    bne       L0B8C
                    ldx       >$30E3
                    stb       ,x+
                    stx       >$30E3
                    lda       <u000B
                    adda      #$30
                    ldx       >$30E1
                    sta       ,x+
                    stx       >$30E1
                    inc       <u009F
                    bne       L0B8C
                    lda       <u009E
                    beq       L0B8A
                    dec       <u009F
                    bra       L0B8C
L0B8A               inc       <u009E
L0B8C               puls      x,b
L0B8E               rts
L0B8F               ldd       <u0099
                    std       <u0095
                    pshs      u,y,x
                    ldx       #$0039
                    ldy       #$0043
                    ldu       #$004D
                    clrb
L0BA0               lda       <u0058
                    cmpa      <u0068
                    bcs       L0BBC
                    sta       <u0096
                    suba      #$58
                    lsla
                    sta       <u000B
                    clr       <u000A
                    ldx       #$0039
                    ldy       #$0043
                    ldu       #$004D
                    lbra      L0C52
L0BBC               adda      ,x
                    rora
                    cmpa      <u0068
                    bhi       L0C05
                    sta       <u0058
                    orcc      #Carry
                    lda       <u005B
                    adda      ,u
                    sta       <u005B
                    bmi       L0BD8
                    lda       <u005A
                    adda      ,y
                    rora
                    sta       <u005A
                    bra       L0BA0
L0BD8               bcs       L0BEF
                    lda       ,x
                    suba      <u0058
                    lsra
                    sta       <u0028
                    lda       <u005A
                    adda      ,y
                    rora
                    suba      <u0028
                    bcc       L0BEB
                    clra
L0BEB               sta       <u005A
                    bra       L0BA0
L0BEF               lda       ,x
                    suba      <u0058
                    lsra
                    sta       <u0028
                    lda       <u005A
                    adda      ,y
                    rora
                    adda      <u0028
                    bcc       L0C01
                    lda       #$FF
L0C01               sta       <u005A
                    bra       L0BA0
L0C05               leax      $01,x
                    sta       ,x
                    orcc      #Carry
                    lda       <u005B
                    adda      ,u+
                    sta       ,u
                    bmi       L0C1E
                    lda       <u005A
                    adda      ,y+
                    rora
                    sta       ,y
                    incb
                    lbra      L0BA0
L0C1E               bcs       L0C37
                    lda       ,x
                    suba      <u0058
                    lsra
                    sta       <u0028
                    lda       <u005A
                    adda      ,y+
                    rora
                    suba      <u0028
                    bcc       L0C31
                    clra
L0C31               sta       ,y
                    incb
                    lbra      L0BA0
L0C37               lda       ,x
                    suba      <u0058
                    lsra
                    sta       <u0028
                    lda       <u005A
                    adda      ,y+
                    rora
                    adda      <u0028
                    bcc       L0C49
                    lda       #$FF
L0C49               sta       ,y
                    incb
                    lbra      L0BA0
L0C4F               puls      u,y,x
                    rts
L0C52               lda       <u0096
                    cmpa      <u0069
                    bcc       L0C4F
                    sta       <u0058
                    suba      b,x
                    cmpa      #$FE
                    lbne      L0DB0
                    lda       b,y
                    adda      <u005A
                    rora
                    sta       <u000D
                    adda      <u005A
                    rora
                    suba      #$50
                    bcs       L0CB3
                    pshs      x,b
                    ldx       <u000A
                    leax      >$3EC4,x
                    cmpa      ,x
                    bls       L0CB1
                    cmpa      #$5F
                    bls       L0C82
                    lda       #$5F
L0C82               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L0CB1
                    lda       <u000B
                    anda      #$01
                    bne       L0CB1
                    ldx       >$30E3
                    stb       ,x+
                    stx       >$30E3
                    lda       <u000B
                    adda      #$30
                    ldx       >$30E1
                    sta       ,x+
                    stx       >$30E1
                    inc       <u009F
                    bne       L0CB1
                    lda       <u009E
                    beq       L0CAF
                    dec       <u009F
                    bra       L0CB1
L0CAF               inc       <u009E
L0CB1               puls      x,b
L0CB3               inc       <u000B
                    lda       <u000D
                    suba      #$50
                    bcs       L0CFE
                    pshs      x,b
                    ldx       <u000A
                    leax      >$3EC4,x
                    cmpa      ,x
                    bls       L0CFC
                    cmpa      #$5F
                    bls       L0CCD
                    lda       #$5F
L0CCD               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L0CFC
                    lda       <u000B
                    anda      #$01
                    bne       L0CFC
                    ldx       >$30E3
                    stb       ,x+
                    stx       >$30E3
                    lda       <u000B
                    adda      #$30
                    ldx       >$30E1
                    sta       ,x+
                    stx       >$30E1
                    inc       <u009F
                    bne       L0CFC
                    lda       <u009E
                    beq       L0CFA
                    dec       <u009F
                    bra       L0CFC
L0CFA               inc       <u009E
L0CFC               puls      x,b
L0CFE               inc       <u000B
                    lda       <u000D
                    adda      b,y
                    rora
                    suba      #$50
                    bcs       L0D4C
                    pshs      x,b
                    ldx       <u000A
                    leax      >$3EC4,x
                    cmpa      ,x
                    bls       L0D4A
                    cmpa      #$5F
                    bls       L0D1B
                    lda       #$5F
L0D1B               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L0D4A
                    lda       <u000B
                    anda      #$01
                    bne       L0D4A
                    ldx       >$30E3
                    stb       ,x+
                    stx       >$30E3
                    lda       <u000B
                    adda      #$30
                    ldx       >$30E1
                    sta       ,x+
                    stx       >$30E1
                    inc       <u009F
                    bne       L0D4A
                    lda       <u009E
                    beq       L0D48
                    dec       <u009F
                    bra       L0D4A
L0D48               inc       <u009E
L0D4A               puls      x,b
L0D4C               inc       <u000B
                    lda       b,y
                    sta       <u005A
                    suba      #$50
                    bcs       L0D99
                    pshs      x,b
                    ldx       <u000A
                    leax      >$3EC4,x
                    cmpa      ,x
                    bls       L0D97
                    cmpa      #$5F
                    bls       L0D68
                    lda       #$5F
L0D68               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L0D97
                    lda       <u000B
                    anda      #$01
                    bne       L0D97
                    ldx       >$30E3
                    stb       ,x+
                    stx       >$30E3
                    lda       <u000B
                    adda      #$30
                    ldx       >$30E1
                    sta       ,x+
                    stx       >$30E1
                    inc       <u009F
                    bne       L0D97
                    lda       <u009E
                    beq       L0D95
                    dec       <u009F
                    bra       L0D97
L0D95               inc       <u009E
L0D97               puls      x,b
L0D99               decb
                    bmi       L0DAD
                    lda       <u0096
                    adda      #$02
                    sta       <u0096
                    inc       <u000B
                    incb
                    lda       b,u
                    decb
                    sta       <u005B
                    lbra      L0C52
L0DAD               puls      u,y,x
                    rts
L0DB0               lbcs      L0E5F
                    lda       <u005A
                    adda      b,y
                    rora
                    suba      #$50
                    bcs       L0E00
                    pshs      x,b
                    ldx       <u000A
                    leax      >$3EC4,x
                    cmpa      ,x
                    bls       L0DFE
                    cmpa      #$5F
                    bls       L0DCF
                    lda       #$5F
L0DCF               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L0DFE
                    lda       <u000B
                    anda      #$01
                    bne       L0DFE
                    ldx       >$30E3
                    stb       ,x+
                    stx       >$30E3
                    lda       <u000B
                    adda      #$30
                    ldx       >$30E1
                    sta       ,x+
                    stx       >$30E1
                    inc       <u009F
                    bne       L0DFE
                    lda       <u009E
                    beq       L0DFC
                    dec       <u009F
                    bra       L0DFE
L0DFC               inc       <u009E
L0DFE               puls      x,b
L0E00               inc       <u000B
                    lda       b,y
                    sta       <u005A
                    suba      #$50
                    bcs       L0E4D
                    pshs      x,b
                    ldx       <u000A
                    leax      >$3EC4,x
                    cmpa      ,x
                    bls       L0E4B
                    cmpa      #$5F
                    bls       L0E1C
                    lda       #$5F
L0E1C               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L0E4B
                    lda       <u000B
                    anda      #$01
                    bne       L0E4B
                    ldx       >$30E3
                    stb       ,x+
                    stx       >$30E3
                    lda       <u000B
                    adda      #$30
                    ldx       >$30E1
                    sta       ,x+
                    stx       >$30E1
                    inc       <u009F
                    bne       L0E4B
                    lda       <u009E
                    beq       L0E49
                    dec       <u009F
                    bra       L0E4B
L0E49               inc       <u009E
L0E4B               puls      x,b
L0E4D               inc       <u000B
                    decb
                    bpl       L0E54
                    puls      pc,u,y,x
L0E54               inc       <u0096
                    incb
                    lda       b,u
                    decb
                    sta       <u005B
                    lbra      L0C52
L0E5F               lda       <u0096
                    adda      b,x
                    rora
                    incb
                    sta       b,x
                    decb
                    orcc      #Carry
                    lda       <u005B
                    adda      b,u
                    incb
                    sta       b,u
                    bmi       L0E7F
                    decb
                    lda       <u005A
                    adda      b,y
                    rora
                    incb
                    sta       b,y
                    lbra      L0C52
L0E7F               bcs       L0E99
                    lda       b,x
                    decb
                    suba      <u0058
                    lsra
                    sta       <u0028
                    lda       <u005A
                    adda      b,y
                    rora
                    suba      <u0028
                    bcc       L0E93
                    clra
L0E93               incb
                    sta       b,y
                    lbra      L0C52
L0E99               lda       b,x
                    decb
                    suba      <u0058
                    lsra
                    sta       <u0028
                    lda       <u005A
                    adda      b,y
                    rora
                    adca      <u0028
                    bcc       L0EAC
                    lda       #$FF
L0EAC               incb
                    sta       b,y
                    lbra      L0C52
L0EB2               lda       #$FF
                    sta       >$345A
                    lbsr      L1061
                    lda       >$3447
                    beq       L0EC2
                    lbsr      L4EE3
L0EC2               lbsr      L2E81
                    bcc       L0ECA
                    lbsr      L37FD
L0ECA               lda       <u00BE
                    sta       >$3332
                    lda       <u00C0
                    sta       >$3333
                    lda       >$366E
                    bne       L0EE4
                    lbsr      L17C4
                    lda       >$330B
                    sta       >$3411
                    bra       L0EE7
L0EE4               lda       >$3411
L0EE7               adda      >$331F
                    sta       >$3331
                    clr       >$3330
                    lbsr      L15B8
                    lbsr      L1021
                    ldb       >$332F
                    bne       L0F00
                    ldx       #$075C
                    bra       L0F15
L0F00               cmpb      #$01
                    bne       L0F09
                    ldx       #$0789
                    bra       L0F15
L0F09               cmpb      #$02
                    bne       L0F12
                    ldx       #$072F
                    bra       L0F15
L0F12               ldx       #$0702
L0F15               stx       <u0017
                    ldx       #$0088
                    ldb       #$00
                    pshs      b
L0F1E               ldy       <u0017
                    lda       b,y
                    sta       <u0028
                    bpl       L0F37
                    leax      -$10,x
                    ldd       <u0072
                    addd      <u001A
                    std       <u0072
                    ldd       <u0074
                    subd      <u001C
                    std       <u0074
                    bra       L0F4A
L0F37               rol       <u0028
                    bpl       L0F4A
                    leax      <$10,x
                    ldd       <u0072
                    subd      <u001A
                    std       <u0072
                    ldd       <u0074
                    addd      <u001C
                    std       <u0074
L0F4A               rol       <u0028
                    bpl       L0F5E
                    leax      -$01,x
                    ldd       <u0072
                    subd      <u001C
                    std       <u0072
                    ldd       <u0074
                    subd      <u001A
                    std       <u0074
                    bra       L0F70
L0F5E               rol       <u0028
                    bpl       L0F70
                    leax      $01,x
                    ldd       <u0072
                    addd      <u001C
                    std       <u0072
                    ldd       <u0074
                    addd      <u001A
                    std       <u0074
L0F70               ldb       ,s
                    ldy       #$38D6
                    clr       b,y
                    clra
                    suba      >$3330
                    sta       <u0099
                    lda       >$040A,x
                    cmpa      #$80
                    bne       L0F8B
                    stb       >$345A
                    lda       #$20
L0F8B               ldy       #$37E6
                    sta       b,y
                    ldb       <u0099
                    suba      >$3331
                    rora
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    tfr       d,u
                    ldy       #$3786
                    ldb       ,s
                    leay      b,y
                    stu       b,y
                    tfr       x,d
                    ldy       #$3696
                    lda       ,s
                    stb       a,y
                    ldu       <u0072
                    ldy       #$36C6
                    ldb       ,s
                    leay      b,y
                    stu       b,y
                    ldy       #$3726
                    ldu       <u0074
                    leay      b,y
                    stu       b,y
                    lda       <u0074
                    bmi       L0FD0
                    bne       L0FE3
L0FD0               ldu       #$0100
                    ldy       #$3726
                    leay      b,y
                    stu       b,y
                    lda       #$80
                    ldy       #$38D6
                    sta       b,y
L0FE3               ldu       #$36C6
                    ldy       #$3726
                    leau      b,u
                    leau      b,u
                    leay      b,y
                    leay      b,y
                    ldd       ,u
                    bpl       L1004
                    ldd       #$0000
                    subd      ,u
                    cmpd      ,y
                    bcs       L1014
                    lda       #$40
                    bra       L100B
L1004               cmpd      ,y
                    bcs       L1014
                    lda       #$20
L100B               ldb       ,s
                    ldu       #$38D6
                    ora       b,u
                    sta       b,u
L1014               inc       ,s
                    ldb       ,s
                    cmpb      #$2D
                    lbcs      L0F1E
                    puls      b
                    rts
L1021               ldd       <u001A
                    std       <u0020
                    lda       <u00C1
                    lbsr      L12A3
                    ldd       <u001E
                    std       <u0072
                    ldd       <u001C
                    std       <u0020
                    lda       <u00BF
                    lbsr      L12A3
                    ldd       <u0072
                    subd      <u001E
                    std       <u0072
                    ldd       <u001C
                    std       <u0020
                    lda       <u00C1
                    lbsr      L12A3
                    ldd       <u001E
                    std       <u0074
                    ldd       <u001A
                    std       <u0020
                    lda       <u00BF
                    lbsr      L12A3
                    ldd       <u001E
                    addd      <u0074
                    std       <u0074
                    ldd       #$0000
                    subd      <u0074
                    std       <u0074
                    rts
L1061               clra
                    ldb       <u00C0
                    lslb
                    lslb
                    lslb
                    stb       <u007B
                    rola
                    ldx       #$1F7C
                    leax      d,x
                    stx       <u007D
                    ldb       <u00BE
                    stb       <u007A
                    addb      #$04
                    tfr       b,a
                    anda      #$07
                    sta       <u0076
                    lsrb
                    lsrb
                    lsrb
                    decb
                    stb       <u007C
                    lda       <u007B
                    lsla
                    adda      <u007A
                    sta       <u007A
                    ldx       #$0044
L108D               lbsr      L1096
                    cmpx      #$00E4
                    bne       L108D
                    rts
L1096               pshs      x
                    clra
                    ldb       <u007C
                    ldy       <u007D
                    leay      d,y
                    ldd       ,y++
                    std       <u0077
                    lda       ,y
                    sta       <u0079
                    ldb       <u007C
                    addb      #$08
                    stb       <u007C
                    clra
                    ldb       <u0076
                    incb
                    tfr       d,y
                    ldd       <u0077
L10B6               rol       <u0079
                    rolb
                    rola
                    leay      -$01,y
                    bne       L10B6
                    pshs      cc
                    std       <u0077
                    clra
                    ldb       <u007A
                    addd      #$050A
                    tfr       d,y
                    leax      >$040A,x
                    lda       ,y+
                    puls      cc
                    bcc       L10D8
                    ora       #$C0
                    bra       L10DA
L10D8               anda      #$7F
L10DA               rora
                    sta       ,x+
                    ldb       #$09
                    pshs      b
                    ldb       <u0078
L10E3               rolb
                    rol       <u0077
                    lda       ,y+
                    bcc       L10EE
                    ora       #$C0
                    bra       L10F0
L10EE               anda      #$7F
L10F0               rora
                    sta       ,x+
                    dec       ,s
                    bne       L10E3
                    puls      b
                    puls      x
                    leax      <$10,x
                    ldb       <u007A
                    addb      #$10
                    stb       <u007A
                    rts
L1105               tfr       x,d
                    lsra
                    rorb
                    ldy       #$38D6
                    leay      b,y
                    lda       ,y
                    ora       #$10
                    sta       ,y
                    ldd       >$3786,x
                    std       <u0008
                    ldd       >$3816,x
                    std       <u0000
                    ldd       >$3876,x
                    std       <u0002
                    ldd       >$3726,x
                    std       <u0024
                    std       <u0006
                    ldd       >$36C6,x
                    std       <u0004
                    bpl       L113E
                    ldd       #$0000
                    subd      >$36C6,x
L113E               std       <u0026
                    ldy       #$0000
L1144               cmpd      <u0024
                    bcs       L1169
                    lsl       <u0025
                    rol       <u0024
                    leay      $01,y
                    cmpy      #$0008
                    bne       L1144
                    lda       <u0004
                    bmi       L1161
                    ldd       #$4000
                    std       <u0000
                    lbra      L11CC
L1161               ldd       #$C000
                    std       <u0000
                    lbra      L11CC
L1169               pshs      y
                    lbsr      L12D6
                    puls      y
                    leay      -$01,y
                    cmpy      #$0000
                    bmi       L11AB
                    clra
                    ldb       <u0029
                    leay      $01,y
L117D               lslb
                    rola
                    leay      -$01,y
                    bne       L117D
                    stb       <u0029
                    sta       <u0028
                    lsra
                    rorb
                    addd      <u0028
                    lsra
                    rorb
                    lsra
                    rorb
                    std       <u0028
                    lda       <u0004
                    bmi       L11A0
                    ldd       #$0080
                    addb      <u0029
                    adca      <u0028
                    std       <u0000
                    bra       L11CC
L11A0               ldd       #$0080
                    subb      <u0029
                    sbca      <u0028
                    std       <u0000
                    bra       L11CC
L11AB               clr       <u0000
                    lda       <u0004
                    bmi       L11BF
                    lda       <u0029
                    lsra
                    inca
                    adda      <u0029
                    rora
                    lsra
                    ora       #$80
                    sta       <u0001
                    bra       L11CC
L11BF               lda       <u0029
                    lsra
                    inca
                    adda      <u0029
                    rora
                    lsra
                    coma
                    adda      #$81
                    sta       <u0001
L11CC               ldy       #$0000
                    ldd       <u0006
                    std       <u0024
                    ldd       <u0008
                    bpl       L11DD
                    coma
                    comb
                    addd      #$0001
L11DD               std       <u0026
L11DF               cmpd      <u0024
                    bcs       L1204
                    lsl       <u0025
                    rol       <u0024
                    leay      $01,y
                    cmpy      #$0008
                    bne       L11DF
                    lda       <u0008
                    bmi       L11FC
                    ldd       #$4000
                    std       <u0002
                    lbra      L1270
L11FC               ldd       #$C000
                    std       <u0002
                    lbra      L1270
L1204               pshs      y
                    lbsr      L12D6
                    puls      y
                    leay      -$01,y
                    cmpy      #$0000
                    bmi       L1246
                    clra
                    ldb       <u0029
                    leay      $01,y
L1218               lslb
                    rola
                    leay      -$01,y
                    bne       L1218
                    stb       <u0029
                    sta       <u0028
                    lsra
                    rorb
                    addd      <u0028
                    lsra
                    rorb
                    lsra
                    rorb
                    std       <u0028
                    lda       <u0008
                    bmi       L123B
                    ldd       #$0080
                    addb      <u0029
                    adca      <u0028
                    std       <u0002
                    bra       L1270
L123B               ldd       #$0080
                    subb      <u0029
                    sbca      <u0028
                    std       <u0002
                    bra       L1270
L1246               lda       <u0008
                    bmi       L125D
                    lda       <u0029
                    lsra
                    inca
                    adda      <u0029
                    rora
                    lsra
                    adda      #$80
                    sta       <u0003
                    clra
                    adca      #$00
                    sta       <u0002
                    bra       L1270
L125D               lda       <u0029
                    lsra
                    inca
                    adda      <u0029
                    rora
                    lsra
                    pshs      a
                    ldd       #$0080
                    subb      ,s+
                    sbca      #$00
                    std       <u0002
L1270               lda       <u0000
                    bpl       L1279
                    ldb       >$3673
                    bra       L128C
L1279               beq       L1280
                    ldb       >$3692
                    bra       L128C
L1280               ldb       <u0001
                    lsrb
                    lsrb
                    lsrb
                    sex
                    tfr       d,y
                    ldb       >$3673,y
L128C               sex
                    addd      <u0002
                    std       <u0002
                    ldd       <u0000
                    asra
                    rorb
                    addd      #$0040
                    std       >$3816,x
                    ldd       <u0002
                    std       >$3876,x
                    rts
L12A3               sta       <u0022
                    ldd       <u0020
                    sta       <u0023
                    bpl       L12B2
                    ldd       #$0000
                    subd      <u0020
                    std       <u0020
L12B2               lda       <u0022
                    mul
                    sta       <u0021
                    lda       <u0022
                    ldb       <u0020
                    mul
                    addb      <u0021
                    adca      #$00
                    std       <u001E
                    tst       <u0023
                    bpl       L12CD
                    ldd       #$0000
                    subd      <u001E
                    std       <u001E
L12CD               rts
L12CE               lsl       <u0027
                    rol       <u0026
                    lsl       <u0025
                    rol       <u0024
L12D6               lda       <u0024
                    lsla
                    bpl       L12CE
                    pshs      x
                    ldx       #$0008
                    ldd       <u0026
L12E2               lslb
                    rola
                    bmi       L12EA
                    lsla
                    bpl       L12F4
                    rora
L12EA               subd      <u0024
                    bcc       L12F9
                    addd      <u0024
                    andcc     #^Carry
                    bra       L12FB
L12F4               rora
                    andcc     #^Carry
                    bra       L12FB
L12F9               orcc      #Carry
L12FB               rol       <u0029
                    leax      -$01,x
                    bne       L12E2
                    puls      x
                    rts
L1304               mul
                    tstb
                    bpl       L1309
                    inca
L1309               rts
L130A               lda       >$3327
                    sta       >$3324
                    bsr       L1323
                    std       >$3320
                    lda       >$3324
                    adda      #$40
                    sta       >$3324
                    bsr       L1323
                    std       >$3322
                    rts
L1323               clra
                    ldb       >$3324
                    lslb
                    rola
                    lslb
                    rola
                    sta       >$3325
                    lsrb
                    lsrb
                    lda       >$3325
                    ldx       #$0396
                    leax      a,x
                    eorb      ,x
                    clra
                    lslb
                    rola
                    ldy       #$061A
                    leay      d,y
                    ldx       #$0392
                    ldb       >$3325
                    lda       b,x
                    bne       L1355
                    sta       <u00FF
                    ldd       ,y
                    std       <u00FD
                    bra       L1362
L1355               ldd       #$0000
                    subd      ,y
                    std       <u00FD
                    lda       #$00
                    sbca      #$00
                    sta       <u00FF
L1362               ldd       <u00FD
                    lslb
                    rola
                    rol       <u00FF
                    lslb
                    rola
                    rol       <u00FF
                    lslb
                    rola
                    rol       <u00FF
                    std       <u00FD
                    ldb       <u00FF
                    exg       a,b
                    rts
L1377               ldd       <u00F1
                    subd      <u00BE
                    std       <u002F
                    std       <u0026
                    bpl       L1388
                    ldd       #$0000
                    subd      <u0026
                    std       <u0026
L1388               ldd       <u00F3
                    subd      <u00C0
                    std       <u0031
                    std       <u0024
                    bpl       L1399
                    ldd       #$0000
                    subd      <u0024
                    std       <u0024
L1399               ldd       <u0026
                    cmpd      <u0024
                    bls       L13A8
                    ldx       <u0026
                    ldd       <u0024
                    std       <u0026
                    stx       <u0024
L13A8               rol       <u0033
                    lda       <u0033
                    eora      #$01
                    sta       <u0033
                    ldd       <u0026
                    lsra
                    rorb
                    adcb      <u0025
                    adca      <u0024
                    std       <u0034
                    ldd       <u0024
                    bne       L13C4
                    lda       #$FF
                    sta       <u0029
                    bra       L13C7
L13C4               lbsr      L12D6
L13C7               ldb       <u0029
                    addb      #$02
                    rorb
                    lsrb
                    ror       <u0033
                    lda       #$00
                    leay      >L1445,pcr
                    lda       d,y
                    sta       <u0033
                    bcc       L13E1
                    lda       #$40
                    suba      <u0033
                    sta       <u0033
L13E1               lda       <u0031
                    bpl       L13EB
                    lda       #$80
                    suba      <u0033
                    sta       <u0033
L13EB               lda       <u002F
                    bpl       L13F1
                    neg       <u0033
L13F1               rts
L13F2               lda       <u0034
                    bpl       L13F9
                    clr       <u0038
                    rts
L13F9               lda       <u0033
                    suba      >$3327
                    sta       <u0037
                    sta       <u0036
                    bpl       L140C
                    asra
                    asra
                    adca      <u0036
                    bpl       L1412
                    bra       L1414
L140C               lsra
                    lsra
                    adca      <u0036
                    bpl       L1414
L1412               lda       #$7F
L1414               adda      #$80
                    sta       <u0036
                    ldd       <u0034
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    bne       L1424
                    rorb
                    bra       L1425
L1424               clrb
L1425               lda       <u0037
                    bpl       L142A
                    nega
L142A               lsra
                    lsra
                    sta       <u0037
                    subb      <u0037
                    bcc       L1433
                    clrb
L1433               leax      >L56CF,pcr
                    abx
                    lda       ,x
                    sta       <u0038
                    adda      #$83
                    bcc       L1442
                    lda       #$FF
L1442               sta       <u0037
                    rts
L1445               fcb       $00,$01,$01         ...79...
L1448               fcb       $02,$03,$03,$04,$04,$05,$06,$06 ........
L1450               fcb       $07,$08,$08,$09,$09,$0A,$0B,$0B ........
L1458               fcb       $0C,$0C,$0D,$0D,$0E,$0F,$0F,$10 ........
L1460               fcb       $10,$11,$11,$12,$12,$13,$13,$14 ........
L1468               fcb       $14,$15,$15,$16,$16,$17,$17,$18 ........
L1470               fcb       $18,$19,$19,$19,$1A,$1A,$1B,$1B ........
L1478               fcb       $1B,$1C,$1C,$1D,$1D,$1D,$1E,$1E ........
L1480               fcb       $1E,$1F,$1F,$1F,$20,$20

L1486               pshs      cc
                    lda       #$FF
                    ldb       <u00A7
                    addb      #$20
                    lslb
                    bcc       L14A2
                    puls      cc
                    lslb
                    bcc       L149C
                    ldb       <u00BE
                    subb      <u00F1
                    bra       L14B3
L149C               ldb       <u00C0
                    subb      <u00F3
                    bra       L14B3
L14A2               lslb
                    bcc       L14AD
                    ldb       <u00F1
                    puls      cc
                    sbcb      <u00BE
                    bra       L14B3
L14AD               ldb       <u00F3
                    puls      cc
                    sbcb      <u00C0
L14B3               bmi       L14BB
                    cmpb      #$06
                    bcc       L14BB
                    tfr       b,a
L14BB               sta       <u00F0
                    rts
L14BE               clrb
                    stb       <u00AA
                    lda       <u00A7
                    sta       ,-s
                    lsla
                    bcc       L14CA
                    dec       <u00AA
L14CA               lsla
                    bcc       L14CE
                    decb
L14CE               eorb      <u00AA
                    stb       <u00AC
                    ldd       #$0000
                    rolb
                    tfr       d,x
                    lda       ,s+
                    anda      #$3F
                    sta       >$335D
                    sta       >$335E
                    eora      #$3F
                    inca
                    sta       >$335D,x
                    clra
                    ldb       >$335E
                    lslb
                    rola
                    ldx       #$061A
                    leax      d,x
                    lda       ,x
                    ldb       <u00A9
                    lbsr      L1304
                    sta       <u00AB
                    tsta
                    bne       L1502
                    sta       <u00AA
L1502               lda       <u00AA
                    beq       L1508
                    neg       <u00AB
L1508               ldb       >$335D
                    clra
                    lslb
                    rola
                    ldx       #$061A
                    leax      d,x
                    lda       ,x
                    ldb       <u00A9
                    lbsr      L1304
                    sta       <u00AD
                    tsta
                    bne       L1521
                    sta       <u00AC
L1521               lda       <u00AC
                    beq       L1527
                    neg       <u00AD
L1527               rts

L1528               fcb       $02,$00,$02,$03,$04,$05,$05,$04 ........
L1530               fcb       $09,$03,$0C,$0D,$06,$07,$08,$09 ........
L1538               fcb       $0A,$0B,$0C,$0D,$10,$11,$12,$0B ........
L1540               fcb       $0A,$16,$17,$08,$07,$06,$1B,$1A ........
L1548               fcb       $19,$18,$17,$16,$15,$14,$13,$12 ........
L1550               fcb       $11,$10,$2B,$2A,$29,$28,$13,$14 ..+*)(..
L1558               fcb       $15,$23,$22,$21,$18,$19,$1A,$1B .#"!....
L1560               fcb       $1C,$1D,$1E,$1F,$20,$21,$22,$23 .... !"#
L1568               fcb       $24,$25,$26,$27,$28,$29,$2A,$2B $%&'()*+
L1570               fcb       $00,$04,$01,$02,$03,$04,$07,$08 ........
L1578               fcb       $03,$0B,$02,$01,$07,$08,$09,$0A ........
L1580               fcb       $0B,$0C,$0D,$0E,$0E,$0D,$0C,$13 ........
L1588               fcb       $14,$0A,$09,$18,$19,$1A,$1A,$19 ........
L1590               fcb       $18,$17,$16,$15,$14,$13,$12,$11 ........
L1598               fcb       $10,$0F,$0F,$10,$11,$12,$27,$26 ......'&
L15A0               fcb       $25,$15,$16,$17,$20,$1F,$1E,$1D %... ...
L15A8               fcb       $1D,$1E,$1F,$20,$21,$22,$23,$24 ... !"#$
L15B0               fcb       $25,$26,$27,$28,$29,$2A,$2B,$2C %&'()*+,
L15B8               fcb       $DC,$BE,$DD,$B6,$DC,$C0,$DD,$B8 \>]6\@]8
L15C0               fcb       $DC,$1A,$47,$56,$47,$56,$47,$56 \.GVGVGV
L15C8               fcb       $47,$56,$DD,$BA,$47,$56,$47,$56 GV]:GVGV
L15D0               fcb       $FD,$33,$18,$DC,$1C,$47,$56,$47 .3.\.GVG
L15D8               fcb       $56,$47,$56,$47,$56,$DD,$BC,$47 VGVGV]<G
L15E0               fcb       $56,$47

L15E2               rorb
                    std       >$331A
                    ldd       <u00B6
                    subd      <u00BC
                    std       <u00B2
                    ldd       <u00B8
                    addd      <u00BA
                    std       <u00B4
                    lbsr      L17CC
                    lda       >$330B
                    sta       >$331C
                    ldd       <u00B6
                    subd      >$331A
                    std       >$330C
                    ldd       <u00B8
                    addd      >$3318
                    std       >$330E
                    ldd       <u00B6
                    addd      <u00BC
                    std       <u00B2
                    ldd       <u00B8
                    subd      <u00BA
                    std       <u00B4
                    lbsr      L17CC
                    lda       >$330B
                    sta       >$331D
                    ldd       <u00B6
                    addd      >$331A
                    std       >$3310
                    ldd       <u00B8
                    subd      >$3318
                    std       >$3312
                    ldd       <u00B6
                    subd      <u00BA
                    std       <u00B2
                    ldd       <u00B8
                    subd      <u00BC
                    std       <u00B4
                    lbsr      L17CC
                    lda       >$330B
                    sta       >$331E
                    ldd       <u00B6
                    subd      >$3318
                    std       >$3314
                    ldd       <u00B8
                    subd      >$331A
                    std       >$3316
                    ldb       >$331C
                    subb      >$331D
                    sex
                    bcs       L166C
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    cmpa      #$04
                    bcs       L1678
                    lda       #$03
                    bra       L1678
L166C               lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    cmpa      #$FD
                    bcc       L1678
                    lda       #$FD
L1678               std       >$3693
                    lda       >$3331
                    suba      >$331F
                    suba      >$331E
                    bcs       L1692
                    lsra
                    cmpa      #$20
                    bcs       L168D
                    lda       #$1F
L168D               sta       >$3695
                    bra       L169C
L1692               asra
                    cmpa      #$E1
                    bcc       L1699
                    lda       #$E1
L1699               sta       >$3695
L169C               clra
                    suba      >$3695
                    sta       >$3695
                    rts
L16A4               lda       >$3326
                    sta       >$3413
                    lda       >$33F6
                    lsla
                    lsla
                    bcc       L16B3
                    lda       #$FF
L16B3               lsla
                    bcc       L16B8
                    lda       #$FF
L16B8               lsla
                    bcc       L16BD
                    lda       #$FF
L16BD               ldb       >$3695
                    lslb
                    lslb
                    tfr       d,x
                    clr       >$33F6
                    lda       >$3331
                    suba      >$331F
                    cmpa      #$48
                    bcs       L1704
                    lda       >$3695
                    adda      #$1F
                    cmpa      #$03
                    bcc       L16E6
                    ldd       >$3314
                    std       <u00AE
                    ldd       >$3316
                    std       <u00B0
                    bra       L1704
L16E6               lda       >$331C
                    cmpa      >$331D
                    bcs       L16FA
                    ldd       >$3310
                    std       <u00AE
                    ldd       >$3312
                    std       <u00B0
                    bra       L1704
L16FA               ldd       >$330C
                    std       <u00AE
                    ldd       >$330E
                    std       <u00B0
L1704               tfr       x,d
                    addb      #$80
                    lbsr      L1304
                    ldb       >$3335
                    lbsr      L1304
                    ldb       >$33C5
                    lbsr      L1304
                    pshs      a
                    ldb       #$99
                    mul
                    adda      ,s+
                    sta       <u00A9
                    lbsr      L2EF2
                    bcc       L172A
                    clr       <u00A9
                    clr       >$3413
L172A               lda       >$3336
                    sta       <u00A8
                    lda       >$3442
                    beq       L1738
                    clr       <u00A8
                    bra       L1784
L1738               tst       >$0409
                    bpl       L175E
                    lda       >$3416
                    beq       L1746
                    neg       <u00A8
                    bra       L174D
L1746               lda       >$3415
                    bne       L174D
                    sta       <u00A8
L174D               lda       >$3414
                    beq       L1759
                    lda       #$01
                    sta       >$3326
                    bra       L175C
L1759               clr       >$3326
L175C               bra       L1784
L175E               lda       >$3390
                    cmpa      #$0C
                    bcc       L1769
                    neg       <u00A8
                    bra       L176F
L1769               cmpa      #$96
                    bcc       L176F
                    clr       <u00A8
L176F               lda       >$3393
                    cmpa      #$59
                    bls       L177D
                    lda       #$01
                    sta       >$3326
                    bra       L1784
L177D               cmpa      #$10
                    bcc       L1784
                    clr       >$3326
L1784               lda       >$3326
                    bne       L178B
                    sta       <u00A9
L178B               lbsr      L1A4F
                    lbsr      L1A2D
                    ldd       <u00AE
                    std       >$332B
                    ldd       <u00B0
                    std       >$332D
                    lda       <u00A7
                    adda      <u00A8
                    sta       <u00A7
                    lbsr      L14BE
                    lda       >$3326
                    bmi       L17B7
                    ldd       <u00AE
                    addd      <u00AA
                    std       <u00AE
                    ldd       <u00B0
                    addd      <u00AC
                    std       <u00B0
                    bra       L17C3
L17B7               ldd       <u00AE
                    subd      <u00AA
                    std       <u00AE
                    ldd       <u00B0
                    subd      <u00AC
                    std       <u00B0
L17C3               rts
L17C4               ldd       <u00BE
                    std       <u00B2
                    ldd       <u00C0
                    std       <u00B4
L17CC               lda       <u00B4
                    suba      <u00C0
                    adda      #$08
                    lsla
                    lsla
                    lsla
                    lsla
                    sta       >$3309
                    ldb       <u00B2
                    subb      <u00BE
                    addb      #$08
                    andb      #$0F
                    orb       >$3309
                    clra
                    tfr       d,y
                    ldd       >$040A,y
                    cmpa      #$80
                    bne       L17F1
                    lda       #$20
L17F1               sta       >$3353
                    cmpb      #$80
                    bne       L17FA
                    ldb       #$20
L17FA               stb       >$3354
                    ldd       >$041A,y
                    cmpa      #$80
                    bne       L1807
                    lda       #$20
L1807               sta       >$3355
                    cmpb      #$80
                    bne       L1810
                    ldb       #$20
L1810               stb       >$3356
                    ldb       <u00B3
                    stb       >$335A
                    ldy       #$0008
                    clra
L181D               lslb
                    bcs       L182F
                    lsr       >$3354
                    lsr       >$3353
                    adca      >$3353
                    leay      -$01,y
                    bne       L181D
                    bra       L183C
L182F               lsr       >$3353
                    lsr       >$3354
                    adca      >$3354
                    leay      -$01,y
                    bne       L181D
L183C               sta       >$3357
                    ldb       <u00B3
                    stb       >$335A
                    ldy       #$0008
                    clra
L1849               lslb
                    bcs       L185B
                    lsr       >$3356
                    lsr       >$3355
                    adca      >$3355
                    leay      -$01,y
                    bne       L1849
                    bra       L1868
L185B               lsr       >$3355
                    lsr       >$3356
                    adca      >$3356
                    leay      -$01,y
                    bne       L1849
L1868               sta       >$3358
                    ldb       <u00B5
                    stb       >$335B
                    ldy       #$0008
                    clra
L1875               lslb
                    bcs       L1887
                    lsr       >$3358
                    lsr       >$3357
                    adca      >$3357
                    leay      -$01,y
                    bne       L1875
                    bra       L1894
L1887               lsr       >$3357
                    lsr       >$3358
                    adca      >$3358
                    leay      -$01,y
                    bne       L1875
L1894               sta       >$330B
                    lsra
                    lsra
                    lsra
                    lsra
                    tfr       a,b
                    addb      >$330B
                    stb       >$330B
                    lsra
                    adca      >$330B
                    sta       >$330B
                    rts
L18AB               sta       ,y+
                    leax      -$01,x
                    bne       L18AB
                    rts
L18B2               ldx       #$0008
                    ldd       >$3406
L18B8               lslb
                    rola
                    cmpa      >$3408
                    bcs       L18C3
                    suba      >$3408
                    incb
L18C3               leax      -$01,x
                    bne       L18B8
                    sta       >$340A
                    stb       >$3409
                    rts
L18CE               ldy       #$3417
                    lda       #$FF
                    ldx       #$000D
                    lbsr      L18AB
                    ldx       #$0006
L18DD               bsr       L1906
                    leax      -$01,x
                    bne       L18DD
                    rts
L18E4               ldb       #$BC
                    lbsr      L218E
                    lda       >$0905,x
                    leau      a,u
                    lda       #$18
                    sta       >$3CE2
L18F4               ldb       #$0A
L18F6               lda       #$EE
                    sta       ,u+
                    decb
                    bne       L18F6
                    leau      <u0046,u
                    dec       >$3CE2
                    bne       L18F4
                    rts
L1906               bsr       L18E4
                    ldb       #$BA
                    lbsr      L218E
                    lda       >$0905,x
                    inca
                    leau      a,u
                    lda       #$14
                    sta       >$3CE2
L1919               bsr       L1924
                    leau      <u0050,u
                    dec       >$3CE2
                    bne       L1919
                    rts
L1924               ldy       #$08F3
                    ldb       #$07
L192A               lda       b,y
                    sta       b,u
                    decb
                    bpl       L192A
                    rts
L1932               ldx       #$0006
L1935               bsr       L18E4
                    leax      -$01,x
                    bne       L1935
                    lda       #$14
                    sta       >$3CE2
                    ldb       #$BA
                    lbsr      L218E
L1945               pshs      u
                    ldx       #$0006
L194A               pshs      u
                    lda       >$0905,x
                    inca
                    leau      a,u
                    bsr       L1924
                    puls      u
                    leax      -$01,x
                    bne       L194A
                    ldy       #$0014
                    lbsr      L4840
                    puls      u
                    leau      <u0050,u
                    dec       >$3CE2
                    bne       L1945
                    rts
L196D               ldd       #$0EA4
                    lbra      L36E4
L1973               ldd       #$0E2E
                    lbra      L36E4
L1979               ldd       #$0E19
                    lbra      L36E4
L197F               ldd       #$0E49
                    lbra      L36E4
L1985               ldb       <u00E6
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    stb       >$334A
                    lda       >$3348
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       >$33DC
                    cmpa      >$341C
                    bne       L19A3
                    cmpb      >$341B
                    bne       L19A3
                    rts
L19A3               stb       >$341B
                    sta       >$341C
                    clrb
L19AA               lda       #$EE
                    cmpb      >$334A
                    bcc       L19B3
                    lda       #$CC
L19B3               andcc     #^Carry
                    bsr       L19D7
                    incb
                    cmpb      #$0F
                    bne       L19AA
                    clrb
L19BD               lda       #$EE
                    cmpb      >$33DC
                    bcc       L19CD
                    lda       >$334F
                    ldy       #$08F3
                    lda       a,y
L19CD               orcc      #Carry
                    bsr       L19D7
                    incb
                    cmpb      #$0F
                    bne       L19BD
                    rts
L19D7               pshs      b,a,cc
                    addb      #$A5
                    lbsr      L218E
                    puls      a,cc
                    tfr       a,b
                    bcs       L19E9
                    std       <u002B,u
                    puls      pc,b
L19E9               std       <u002D,u
                    puls      pc,b
L19EE               ldy       #$0006
L19F2               lda       >$08F2,y
                    sta       >$3CD7
                    ldb       >$3339,y
                    addb      #$07
                    rorb
                    lsrb
                    lsrb
                    lsrb
                    cmpb      >$341C,y
                    beq       L1A28
                    stb       >$341C,y
                    cmpb      #$15
                    bcs       L1A13
                    ldb       #$14
L1A13               clra
                    lsrb
                    tfr       d,x
                    ldb       >$0E42,y
                    lda       #$44
                    pshs      y
                    ldy       #$000A
                    lbsr      L1ADB
                    puls      y
L1A28               leay      -$01,y
                    bne       L19F2
                    rts
L1A2D               lda       #$CC
                    sta       >$3CD7
                    ldb       <u00A9
                    addb      #$0F
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    cmpb      #$15
                    bcs       L1A40
                    ldb       #$14
L1A40               ldy       #$0008
                    clra
                    lsrb
                    tfr       d,x
                    lda       #$1D
                    ldb       #$A9
                    lbra      L1ADB
L1A4F               lda       >$3326
                    cmpa      >$3418
                    bne       L1A65
                    lda       <u00A9
                    cmpa      >$3419
                    bne       L1A65
                    lda       <u00A8
                    cmpa      >$341A
                    beq       L1A9F
L1A65               ldd       #$0EB9
                    lbsr      L36E4
                    lda       >$3326
                    sta       >$3418
                    beq       L1A84
                    lda       <u00A9
                    sta       >$3419
                    bne       L1A7F
                    ldd       #$0EC5
                    bra       L1A87
L1A7F               ldd       #$0ECC
                    bra       L1A87
L1A84               ldd       #$0ED3
L1A87               lbsr      L36E4
                    lda       <u00A8
                    sta       >$341A
                    bpl       L1A97
                    ldd       #$0EDA
                    lbra      L36E4
L1A97               beq       L1A9F
                    ldd       #$0EE2
                    lbsr      L36E4
L1A9F               rts
L1AA0               lda       >$3425
                    bne       L1AB1
                    tst       >$3423
                    bmi       L1AB0
                    lbsr      L197F
                    dec       >$3423
L1AB0               rts
L1AB1               clr       >$3423
                    lda       >$34B2
                    suba      >$3424
                    suba      #$10
                    eora      #$FF
                    lsra
                    lsra
                    lsra
                    lsra
                    anda      #$FE
                    cmpa      >$3417
                    bne       L1ACA
                    rts
L1ACA               sta       >$3417
                    lbsr      L197F
                    ldb       >$3417
                    ldx       #$0FC6
                    ldd       b,x
                    lbra      L36E4
L1ADB               stb       <u0086
                    sta       <u0085
                    pshs      x,cc
                    cmpx      #$0000
                    beq       L1AF0
                    lda       #$FF
L1AE8               sta       >$06C9,x
                    leax      -$01,x
                    bne       L1AE8
L1AF0               clra
                    puls      x,cc
                    bcc       L1AF7
                    lda       #$F0
L1AF7               sta       >$06CA,x
                    clra
                    leax      $01,x
                    cmpx      #$000A
                    bcs       L1AF7
                    ldb       <u0086
                    lbsr      L218E
                    ldb       <u0085
                    leau      b,u
                    tfr       y,d
                    ldy       #$06CA
L1B12               lda       ,y+
                    sta       >$3CE2
                    anda      >$3CD7
                    sta       >$3CE0
                    com       >$3CE2
                    lda       >$3CE2
                    anda      #$EE
                    ora       >$3CE0
                    sta       >u00F0,u
                    sta       >u00A0,u
                    sta       <u0050,u
                    sta       ,u+
                    decb
                    bne       L1B12
                    rts
L1B39               lda       >$340B
                    asra
                    sta       >$33C1
                    ldb       >$340C
                    lbsr      L1304
                    adda      >$33C1
                    sta       >$33C1
                    ldb       #$19
                    lbsr      L1304
                    tsta
                    bne       L1B5B
                    lda       #$01
                    sta       >$33C2
                    bra       L1B64
L1B5B               sta       >$33C2
                    lda       >$33C1
                    suba      >$33C2
L1B64               sta       >$33C1
                    ldx       #$0006
                    clr       >$3406
                    clr       >$3407
L1B70               lda       >$31E4,x
                    cmpa      #$FF
                    beq       L1B96
                    lda       >$32A4,x
                    beq       L1B96
                    lda       >$322C,x
                    cmpa      #$01
                    beq       L1B96
                    cmpa      #$02
                    beq       L1B96
                    ldd       >$3406
                    addb      >$3244,x
                    adca      #$00
                    std       >$3406
L1B96               leax      -$01,x
                    bne       L1B70
                    ldd       >$3406
                    lsra
                    rorb
                    lsra
                    rorb
                    tsta
                    beq       L1BA6
                    ldb       #$FF
L1BA6               std       >$3406
                    stb       >$3408
                    stb       >$33C4
                    lda       >$33C1
                    cmpa      >$33C4
                    bcs       L1BC4
                    suba      >$33C4
                    sta       >$33C1
                    lda       #$FF
                    sta       >$33C5
                    bra       L1BD6
L1BC4               sta       >$3406
                    clr       >$3407
                    lbsr      L18B2
                    lda       >$3409
                    sta       >$33C5
                    clr       >$33C1
L1BD6               lda       >$33C1
                    adda      >$33C2
                    bcc       L1BE1
                    lda       >$33C6
L1BE1               sta       >$33C2
                    ldb       #$33
                    lbsr      L1304
                    tsta
                    bne       L1BF3
                    lda       #$01
                    sta       >$33C3
                    bra       L1BFF
L1BF3               sta       >$33C3
                    lda       >$33C2
                    suba      >$33C3
                    sta       >$33C2
L1BFF               rts
L1C00               clr       <u0028
                    lda       >$33C6
                    suba      <u00E6
                    sta       >$33C7
                    cmpa      >$33C2
                    bcc       L1C17
                    ldb       >$33C2
                    subb      >$33C7
                    stb       <u0028
L1C17               lda       >$33C2
                    adda      <u00E6
                    bcc       L1C23
                    lda       >$33C6
                    bra       L1C2B
L1C23               cmpa      >$33C6
                    bls       L1C2B
                    lda       >$33C6
L1C2B               sta       <u00E6
                    ldb       <u0028
                    addb      >$33C3
                    bcc       L1C36
                    ldb       #$FF
L1C36               lda       >$340D
                    lbsr      L1304
                    sta       >$33C7
                    bne       L1C4E
                    lbsr      L36AB
                    cmpa      >$340D
                    bcc       L1C4E
                    lda       #$01
                    sta       >$33C7
L1C4E               ldx       #$0006
L1C51               lda       >$3339,x
                    adda      >$33C7
                    bcc       L1C60
                    lda       >$333F,x
                    bra       L1C6A
L1C60               cmpa      >$333F,x
                    bls       L1C6A
                    lda       >$333F,x
L1C6A               sta       >$3339,x
                    leax      -$01,x
                    bne       L1C51
                    rts
L1C73               tst       <u00EA
                    beq       L1C80
                    lda       #$B4
                    sta       >$33BF
                    ldb       <u00E9
                    bra       L1C91
L1C80               lda       >$33C0
                    cmpa      <u00EB
                    beq       L1C90
                    dec       >$33BF
                    bne       L1C90
                    ldb       <u00EB
                    bra       L1C91
L1C90               rts
L1C91               stb       >$33C0
                    lslb
                    ldx       #$1112
                    ldu       b,x
                    stu       <u007F
                    ldb       #$27
                    ldy       #$03C7
L1CA2               lda       b,u
                    sta       ,-y
                    decb
                    bpl       L1CA2
                    clr       <u00EA
                    ldd       #$039A
                    lbra      L36E4
L1CB1               tst       >$33E6
                    beq       L1CC5
                    ldx       #$0000
                    lbsr      L1E9B
                    ldx       #$0001
                    lbsr      L1E9B
                    clr       >$33E6
L1CC5               tst       >$33E5
                    beq       L1CD0
                    lbsr      L1E7A
                    clr       >$33E5
L1CD0               tst       >$33E7
                    beq       L1CDB
                    lbsr      L1B39
                    clr       >$33E7
L1CDB               tst       >$33E8
                    beq       L1CE6
                    lbsr      L1F09
                    clr       >$33E8
L1CE6               tst       >$3666
                    beq       L1CFA
                    lda       <u0015
                    ora       >$366E
                    bne       L1CFA
                    lbsr      L23CC
                    lda       #$F0
                    sta       >$33ED
L1CFA               lda       >$33F0
                    beq       L1D0A
                    clr       >$33F0
                    lbsr      L3D89
                    bcc       L1D0A
                    lbsr      L3D32
L1D0A               lda       <u00F5
                    cmpa      #$FF
                    bne       L1D2F
                    lda       <u0012
                    cmpa      #$01
                    beq       L1D2F
                    lbsr      L1F2F
                    lda       #$80
                    sta       <u00F5
                    lbsr      L1E7A
                    ldx       #$0000
                    lbsr      L1E9B
                    ldx       #$0001
                    lbsr      L1E9B
                    lbsr      L1F09
L1D2F               rts
L1D30               tst       >$366E
                    beq       L1D36
                    rts
L1D36               lda       <u00F5
                    bmi       L1D6B
                    beq       L1D53
                    dec       >$33CA
                    bne       L1D6A
                    lda       <u0012
                    beq       L1D4A
                    inc       >$33CA
                    bra       L1D6A
L1D4A               lda       #$1E
L1D4C               sta       >$33CA
                    dec       <u00F5
                    bra       L1D6A
L1D53               lbsr      L36AB
                    cmpa      >$32D7
                    bcc       L1D6A
                    lda       #$FF
                    sta       <u00F5
                    lda       <u00F6
                    cmpa      #$80
                    bne       L1D6A
                    clr       <u00F6
                    lbsr      L2088
L1D6A               rts
L1D6B               cmpa      #$FF
                    bne       L1D70
                    rts
L1D70               lda       <u000F
                    beq       L1D7C
                    lda       <u0013
                    beq       L1DE7
                    cmpa      #$1D
                    bcc       L1DE7
L1D7C               lda       <u0010
                    beq       L1D88
                    lda       <u0014
                    beq       L1DE7
                    cmpa      #$1D
                    bcc       L1DE7
L1D88               lda       #$0C
                    sta       <u00F5
                    clr       >$33C9
                    lda       >$32D5
                    bmi       L1D9C
                    lda       #$02
                    sta       <u00EF
                    lda       #$01
                    bra       L1DA1
L1D9C               lda       #$01
                    sta       <u00EF
                    clra
L1DA1               sta       <u00EB
                    lda       #$07
                    sta       <u00E9
                    lda       #$FF
                    sta       <u00EA
                    lda       >$32D1
                    cmpa      #$02
                    bcs       L1DB8
                    lda       >$32D6
                    inca
                    bra       L1DC4
L1DB8               lda       >$32D1
                    rora
                    lda       >$32D0
                    rora
                    lsra
                    lsra
                    lsra
                    lsra
L1DC4               cmpa      #$18
                    bls       L1DCA
                    lda       #$18
L1DCA               sta       >$32D6
                    lda       >$32D2
                    inca
                    cmpa      >$32D6
                    bcc       L1DD9
                    sta       >$32D6
L1DD9               lda       >$32D2
                    cmpa      >$32D6
                    bls       L1DE4
                    sta       >$32D6
L1DE4               lbra      L1E42
L1DE7               lda       >$33C9
                    bne       L1DFD
                    lda       #$01
                    sta       >$33C9
                    lda       #$06
                    sta       <u00EB
                    sta       <u00E9
                    lda       #$FF
                    sta       <u00EA
                    bra       L1E42
L1DFD               ldx       #$0000
                    lbsr      L36AB
                    bpl       L1E08
                    ldx       #$0001
L1E08               lbsr      L3262
                    bcc       L1E29
                    lbsr      L36AB
                    cmpa      >$33CB,x
                    bcc       L1E27
                    lbsr      L36AB
                    cmpa      >$33CD,x
                    bcc       L1E23
                    lda       #$01
                    bra       L1E24
L1E23               clra
L1E24               lbsr      L32CD
L1E27               bra       L1E42
L1E29               lbsr      L36AB
                    cmpa      >$32D2
                    bhi       L1E42
                    lbsr      L36AB
                    cmpa      >$33CB,x
                    bcc       L1E42
                    lbsr      L32AF
                    bcc       L1E42
                    lbsr      L2564
L1E42               ldb       <u00FB
                    clra
                    pshs      b,a
                    ldy       #$1F8C
                    lda       b,y
                    puls      y
                    cmpa      #$F1
                    bne       L1E79
                    lda       >$32D2
                    lsra
                    lsra
                    inca
                    cmpa      >$39A9
                    bcs       L1E79
                    lbsr      L36AB
                    lsla
                    bcs       L1E79
                    cmpa      >$32D2
                    bcc       L1E79
                    ldx       #$0002
                    lbsr      L3262
                    bcc       L1E79
                    ldx       #$0002
                    lda       #$01
                    lbsr      L32CD
L1E79               rts
L1E7A               lda       >$33D7
                    ldb       >$340E
                    lbsr      L1304
                    nega
                    adda      >$33D7
                    sta       >$33CF
                    lda       >$33D8
                    ldb       >$340E
                    lbsr      L1304
                    nega
                    adda      >$33D8
                    sta       >$33D0
                    rts
L1E9B               lda       >$3348
                    ldb       >$3349
                    lbsr      L1304
                    asra
                    asra
                    asra
                    sta       >$33DC
                    ldb       >$33E3
                    subb      >$33E1,x
                    lda       >$3348
                    asra
                    adda      >$33DC
                    tstb
L1EB9               beq       L1EC1
                    adda      >$33DC
                    decb
                    bra       L1EB9
L1EC1               sta       >$33DA,x
                    rts
L1EC6               lbsr      L3575
                    cmpx      #$0002
                    bcs       L1EF2
                    bne       L1EEF
                    clra
                    ldb       <u00FB
                    pshs      b,a
                    ldy       #$1F8C
                    lda       d,y
                    puls      y
                    cmpa      #$F1
                    bne       L1EEB
                    lbsr      L36AB
                    cmpa      #$40
                    bcs       L1EE9
                    rts
L1EE9               bra       L1EEF
L1EEB               cmpa      #$F2
                    beq       L1F08
L1EEF               lbra      L39C5
L1EF2               sta       >$33FE,x
                    lda       >$33D3,x
                    suba      >$33DA,x
                    bcs       L1F05
                    sta       >$33D3,x
                    rts
L1F05               lbsr      L39C5
L1F08               rts
L1F09               clra
                    ldx       #$0005
                    ldb       >$33A4,x
                    bmi       L1F20
                    tfr       d,x
                    lda       >$3245,x
                    ldb       >$323F,x
                    lbsr      L1304
L1F20               sta       >$3352
                    ldb       #$40
                    lbsr      L1304
                    nega
                    adda      #$40
                    sta       >$32D7
                    rts
L1F2F               ldb       >$32D6
                    lslb
                    lslb
                    lslb
                    clra
                    tfr       d,x
                    clr       >$33DF
                    clr       >$33E0
                    lbsr      L1F58
                    ldb       >$32D6
                    cmpb      #$03
                    bcs       L1F57
                    lslb
                    lslb
                    lslb
                    addb      #$08
                    clra
                    tfr       d,x
                    inca
                    sta       >$33E0
                    lbsr      L1F58
L1F57               rts
L1F58               ldy       >$33DF
                    leau      >L1FB8,pcr
                    tfr       x,d
                    leau      d,u
                    lda       u0001,u
                    sta       >$33D7,y
                    lda       u0006,u
                    sta       >$33DD,y
                    lda       u0003,u
                    sta       >$33D3,y
                    lda       u0004,u
                    sta       >$33CB,y
                    lda       u0005,u
                    sta       >$33CD,y
                    ldb       ,u
                    stb       >$33D1,y
                    clra
                    tfr       d,y
                    ldb       >$08ED,y
                    stb       <u0090
                    ldy       >$33DF
                    clra
                    ldb       u0002,u
                    stb       >$33E1,y
                    tfr       d,y
L1F9E               ldb       >$08ED,y
                    tfr       d,y
                    lbsr      L36AB
                    anda      #$07
                    leax      >L41D3,pcr
                    lda       a,x
                    sta       <u008F
                    ldx       >$33DF
                    lbsr      L4144
                    rts

L1FB8               fcb       $00,$03,$01,$00,$0A,$40,$2A,$00 .....@*.
L1FC0               fcb       $00,$04,$02,$01,$0A,$40,$23,$00 .....@#.
L1FC8               fcb       $01,$04,$00,$02,$0C,$40,$2C,$00 .....@,.
L1FD0               fcb       $02,$04,$01,$03,$10,$30,$28,$00 .....0(.
L1FD8               fcb       $01,$05,$03,$05,$12,$50,$37,$00 .....P7.
L1FE0               fcb       $00,$07,$04,$06,$15,$40,$37,$00 .....@7.
L1FE8               fcb       $02,$09,$00,$09,$19,$40,$3C,$00 .....@<.
L1FF0               fcb       $01,$0A,$02,$0A,$1A,$80,$1A,$00 ........
L1FF8               fcb       $05,$0C,$04,$0C,$1D,$50,$37,$00 .....P7.
L2000               fcb       $01,$06,$00,$0F,$20,$58,$28,$00 .... X(.
L2008               fcb       $03,$0F,$02,$16,$28,$60,$28,$00 ....(`(.
L2010               fcb       $05,$0F,$05,$1D,$20,$70,$3C,$00 .... p<.
L2018               fcb       $04,$18,$03,$19,$2A,$80,$1E,$00 ....*...
L2020               fcb       $04,$14,$01,$23,$30,$50,$4B,$00 ...#0PK.
L2028               fcb       $05,$19,$00,$2D,$10,$A0,$28,$00 ...-. (.
L2030               fcb       $02,$23,$02,$19,$20,$70,$50,$00 .#.. pP.
L2038               fcb       $05,$2D,$04,$32,$25,$60,$50,$00 .-.2%`P.
L2040               fcb       $04,$3C,$05,$37,$2C,$70,$46,$00 .<.7,pF.
L2048               fcb       $05,$46,$03,$41,$29,$80,$28,$00 .F.A).(.
L2050               fcb       $04,$4B,$04,$50,$33,$80,$55,$00 .K.P3.U.
L2058               fcb       $03,$55,$01,$5A,$3A,$A0,$64,$00 .U.Z: d.
L2060               fcb       $01,$5F,$00,$78,$34,$90,$6E,$00 ._.x4.n.
L2068               fcb       $04,$72,$05,$88,$10,$D0,$78,$00 .r...Px.
L2070               fcb       $00,$78,$01,$A0,$60,$C0,$8C,$00 .x. `@..
L2078               fcb       $02,$96,$03,$C8,$A0,$C0,$82,$00 ...H @..
L2080               fcb       $05,$A0,$02,$C8,$A0,$C0,$8C,$00 . .H @..
L2088               fcb       $86,$EE,$20,$02

L208C               lda       #$FF
                    sta       >$3430
                    lda       <u00EC
                    ldx       #$0F91
                    ldb       a,x
                    clra
                    tfr       d,x
                    ldy       #$003C
                    lda       #$04
                    bra       L20C8
L20A3               lda       #$DD
                    bra       L20AD
L20A7               lda       #$EE
                    bra       L20AD
L20AB               lda       #$FF
L20AD               sta       >$3430
                    ldb       <u00ED
                    ldx       #$0F95
                    lda       b,x
                    pshs      a
                    ldy       #$0F9B
                    ldb       b,y
                    clra
                    tfr       d,y
                    puls      b
                    tfr       d,x
                    lda       #$04
L20C8               pshs      u,a
                    tfr       y,d
                    lslb
                    rola
                    ldu       #$0105
                    ldu       d,u
                    tfr       x,d
                    leau      b,u
                    lda       >$3430
                    puls      b
L20DC               sta       >u00A0,u
                    sta       <u0050,u
                    sta       ,u+
                    decb
                    bne       L20DC
                    puls      pc,u
L20EA               tst       >$343A
                    bmi       L20F0
                    rts
L20F0               lda       #$0B
                    sta       <u008C
                    lda       >$3390
                    sta       >$3439
                    ldb       >$3393
                    stb       >$3438
                    stb       <u008D
                    bcc       L2109
                    lbsr      L2189
                    bra       L210C
L2109               lbsr      L2180
L210C               ldx       #$0000
L210F               lda       #$04
                    sta       <u008B
                    ldb       >$3390
                    lsrb
L2117               lda       b,u
                    sta       >$1150,x
                    lda       >$0EF0,x
                    coma
                    anda      >$1150,x
                    pshs      a
                    lda       >$0EF0,x
                    anda      #$CC
                    ora       ,s+
                    sta       b,u
                    incb
                    leax      $01,x
                    dec       <u008B
                    bne       L2117
                    leau      <u0050,u
                    dec       <u008D
                    dec       <u008C
                    bne       L210F
                    clr       >$343A
                    lda       #$35
                    lbra      L36BC
L214A               lda       >$343A
                    anda      #$7F
                    beq       L217F
                    tst       >$336B
                    beq       L217F
                    lda       #$0B
                    sta       <u008C
                    ldb       >$3438
                    stb       <u008D
                    lbsr      L2180
                    ldx       #$1150
L2165               lda       #$04
                    sta       <u008B
                    ldb       >$3439
                    lsrb
L216D               lda       ,x+
                    sta       b,u
                    incb
                    dec       <u008B
                    bne       L216D
                    leau      <u0050,u
                    dec       <u008D
                    dec       <u008C
                    bne       L2165
L217F               rts
L2180               ldu       #$0185
L2183               clra
                    lslb
                    rola
                    ldu       d,u
                    rts
L2189               ldu       #$0285
                    bra       L2183
L218E               ldu       #$0105
                    bra       L2183
L2193               bsr       L21F1
                    lda       #$0A
                    sta       <u008C
                    lda       >$34B0
                    cmpa      #$58
                    bcc       L21A1
L21A0               rts
L21A1               cmpa      #$A8
                    bhi       L21A0
                    ldb       >$34B1
                    cmpb      #$AF
                    bhi       L21A0
                    cmpb      #$5A
                    bcs       L21A0
                    suba      #$58
                    sta       >$343E
                    subb      #$50
                    stb       >$343D
                    lbsr      L2180
                    ldy       #$11F4
                    ldx       #$0000
L21C4               lda       #$06
                    sta       <u008B
                    ldb       >$343E
L21CB               lda       b,u
                    sta       >$117C,x
                    anda      ,y+
                    ora       >$11B8,x
                    sta       b,u
                    incb
                    leax      $01,x
                    dec       <u008B
                    bne       L21CB
                    leau      <u0050,u
                    dec       <u008C
                    bne       L21C4
                    lda       #$01
                    sta       >$343F
                    lda       #$35
                    lbra      L36BC
L21F1               tst       >$343F
                    beq       L221E
                    lda       #$0A
                    sta       <u008C
                    ldb       >$343D
                    lbsr      L2180
                    ldx       #$0000
L2203               lda       #$06
                    sta       <u008B
                    ldb       >$343E
L220A               lda       >$117C,x
                    sta       b,u
                    incb
                    leax      $01,x
                    dec       <u008B
                    bne       L220A
                    leau      <u0050,u
                    dec       <u008C
                    bne       L2203
L221E               rts
L221F               lda       >$33A3
                    bne       L222F
                    lda       #$05
                    sta       >$33A3
                    lda       >$334F
                    sta       >$33A2
L222F               rts
L2230               lda       >$33A3
                    beq       L222F
                    anda      #$01
                    bne       L223C
                    lbsr      L225C
L223C               dec       >$33A3
                    bne       L222F
                    lda       >$3390
                    adda      #$02
                    sta       >$3440
                    lda       >$3393
                    adda      #$4A
                    sta       >$3441
                    lda       #$01
                    sta       >$3671
                    lbsr      L3453
                    lbra      L53B5
L225C               ldb       >$33A2
                    ldy       #$08F3
                    lda       b,y
                    sta       >$3CD7
                    bsr       L2288
                    suba      #$0A
                    bcc       L226F
                    clra
L226F               sta       >$3384
                    lbsr      L31A6
                    bsr       L2288
                    adda      #$0A
                    cmpa      #$50
                    bcs       L227F
                    lda       #$4F
L227F               sta       >$3384
                    lbsr      L31A6
                    lbra      L5A4A
L2288               lda       #$5F
                    sta       >$3386
                    lda       >$3393
                    sta       >$3382
                    lda       >$3390
                    lsra
                    adda      #$02
                    sta       >$3380
                    rts
L229D               lda       >$33A3
                    bne       L22B6
                    lda       >$3348
                    beq       L22B6
                    lda       <u00E6
                    cmpa      >$3348
                    bcs       L22B6
                    suba      >$3348
                    sta       <u00E6
                    lbsr      L221F
L22B6               rts
L22B7               ldb       <u00EB
                    cmpb      #$06
                    bcs       L22BF
                    ldb       #$05
L22BF               lslb
                    lslb
                    lslb
                    addb      <u00EC
                    addb      <u00EC
                    leau      >L248E,pcr
                    ldd       b,u
                    leau      d,u
                    pshs      u
                    rts
L22D1               lda       >$338D
                    ora       <u00F7
                    bne       L22E3
                    lbsr      L20A7
                    ldb       >$338C
                    stb       <u00ED
                    lbsr      L20AB
L22E3               ldb       <u00ED
                    ldx       #$31E5
                    lda       b,x
                    cmpa      #$FF
                    bne       L22FB
                    lda       <u00F7
                    lbne      L2305
                    lda       <u0012
                    bne       L2304
                    lbra      L23DF
L22FB               lda       <u00F7
                    lbne      L2315
                    lbsr      L502F
L2304               rts
L2305               lbsr      L247B
                    bcs       L2314
                    lda       #$FF
                    sta       >$33B7
                    lda       #$04
                    sta       >$33BC
L2314               rts
L2315               lda       >$32D4
                    cmpa      #$08
                    bcs       L2325
                    lda       #$0C
                    sta       <u00E9
                    lda       #$FF
                    sta       <u00EA
                    rts
L2325               lda       #$FF
                    sta       >$33B6
                    lda       #$81
                    sta       >$33BC
                    lbsr      L51E4
                    inc       >$32D4
                    rts
                    ldb       #$07
L2338               ldu       #$32C5
                    lda       b,u
                    cmpa      #$FF
                    beq       L2347
                    stb       >$32CD
                    lbsr      L2366
L2347               decb
                    bpl       L2338
                    ldb       #$05
L234C               ldu       #$31E5
                    lda       b,u
                    cmpa      #$FF
                    beq       L235D
                    ldu       #$3251
                    lda       b,u
                    lbsr      L497D
L235D               decb
                    bpl       L234C
                    lda       #$F0
                    sta       >$33ED
                    rts
L2366               pshs      b
                    lbsr      L4457
                    addb      #$12
                    ldx       #$30E5
                    clra
                    lda       d,x
                    lbsr      L497D
                    puls      pc,b
                    pshs      b
                    lbsr      L247B
                    puls      b
                    bcs       L23AC
                    lbsr      L2366
                    lbsr      L5289
                    lda       #$10
                    sta       <u00E9
                    lda       #$FF
                    sta       <u00EA
                    ldd       #$0C27
                    std       <u007F
                    lbsr      L49CB
                    dec       >$32D4
                    beq       L23A7
                    lda       >$32D4
                    cmpa      >$32CD
                    bne       L23A7
                    dec       >$32CD
L23A7               lda       #$03
                    sta       >$33BC
L23AC               rts
                    lda       >$366E
                    bne       L23C7
                    lda       #$FF
                    sta       <u00EA
                    lda       >$34AD
                    beq       L23C0
                    lda       #$0E
                    sta       <u00E9
                    rts
L23C0               lda       #$09
                    sta       <u00E9
                    sta       >$33F0
L23C7               rts
                    lda       <u0012
                    bne       L23C7
L23CC               lda       #$0D
                    sta       <u00E9
                    sta       <u00EB
                    lda       #$FF
                    sta       <u00EA
                    lda       #$01
                    sta       >$366E
                    sta       >$3412
                    rts
L23DF               lda       >$32D5
                    cmpa      #$FF
                    beq       L2406
                    ldb       <u00ED
                    lbsr      L50D3
                    lda       >$32D5
                    lbsr      L5178
                    lda       #$FF
                    sta       >$32D5
                    tst       <u00F5
                    bmi       L2406
                    sta       <u00EA
                    lda       #$00
                    sta       <u00EB
                    sta       <u00E9
                    lda       #$01
                    sta       <u00EF
L2406               rts
                    lda       >$32D2
                    cmpa      #$13
                    bcc       L2411
                    inc       >$32D2
L2411               lda       >$32D2
                    cmpa      #$13
                    bcc       L241B
                    inc       >$32D2
L241B               clr       >$33BA
                    lda       #$03
                    sta       >$366E
                    lda       #$FF
                    sta       <u00EA
                    lda       >$32D5
                    cmpa      #$FF
                    bne       L2439
                    lda       #$00
                    sta       <u00EB
                    sta       <u00E9
                    lda       #$01
                    sta       <u00EF
                    rts
L2439               lda       #$01
                    sta       <u00EB
                    sta       <u00E9
                    lda       #$02
                    sta       <u00EF
                    rts
                    lda       #$02
                    sta       <u00EB
                    sta       <u00E9
                    lda       #$03
                    sta       <u00EF
                    bra       L246C
                    lda       #$03
                    sta       <u00EB
                    sta       <u00E9
                    lda       #$03
                    sta       <u00EF
                    bra       L246C
L245C               lda       #$04
                    sta       <u00EB
                    sta       <u00E9
                    lda       #$03
                    sta       <u00EF
                    bra       L246C
                    lda       #$05
                    sta       <u00E9
L246C               lda       #$FF
                    sta       <u00EA
                    rts
                    lda       #$01
                    bra       L2477
                    lda       #$02
L2477               sta       >$34AB
                    rts
L247B               lda       >$33BA
                    bne       L248B
                    lda       #$FF
                    sta       <u00EA
                    lda       #$0B
                    sta       <u00E9
                    orcc      #Carry
                    rts
L248B               andcc     #^Carry
                    rts

L248E               fcb       $FF,$3A             ..9..9.:
L2490               fcb       $FF,$1F,$FE,$76,$FE,$76,$FF,$3A ...v.v.:
L2498               fcb       $FF,$1F,$FF,$51,$FE,$76,$FF,$CE ...Q.v.N
L24A0               fcb       $FE,$EA,$1F,$35,$FF,$C2,$FF,$E3 .j.5.B.c
L24A8               fcb       $FF,$E7,$FE,$A8,$FF,$B6,$FF,$B6 .g.(.6.6
L24B0               fcb       $FF,$8D,$FF,$83,$FF,$79,$FE,$76 .....y.v
L24B8               fcb       $FE,$76,$FE,$76,$FE
L24BD               fcb       $76
L24Be               fcb       $B6,$32
L24C0               fcb       $CF,$B0,$34,$2C,$26,$01

                    rts
L24C7               sta       >$342B
L24CA               lda       #$01
                    sta       >$0611
                    inc       >$342C
                    lda       <u00F7
                    bne       L252D
                    lda       >$342C
                    anda      #$1F
                    cmpa      #$1F
                    bne       L24E2
                    lbsr      L1C00
L24E2               lda       >$3446
                    beq       L24F7
                    lda       <u00F9
                    bne       L24ED
                    dec       <u00F8
L24ED               dec       <u00F9
                    lda       <u00F8
                    bpl       L24F7
                    clr       <u00F8
                    clr       <u00F9
L24F7               lda       >$33C8
                    bpl       L2505
                    clr       >$33C8
                    ldx       #$0002
                    lbsr      L39C5
L2505               tst       >$0409
                    bpl       L250D
                    lbsr      L53B2
L250D               lbsr      L2230
                    lbsr      L3372
                    lda       >$3337
                    beq       L251E
                    lbsr      L1D30
                    clra
                    bra       L2520
L251E               lda       #$01
L2520               sta       >$3337
                    lda       >$3413
                    eora      #$01
                    ora       >$3404
                    bne       L252D
L252D               lbsr      L1C73
                    tst       >$0409
                    bmi       L2544
                    lda       <u00F7
                    bne       L2541
                    tst       >$0611
                    beq       L2544
                    clr       >$0611
L2541               lbsr      L53B8
L2544               lda       >$342C
                    cmpa      >$342D
                    bne       L2554
                    adca      #$04
                    sta       >$342D
                    lbsr      L255D
L2554               dec       >$342B
                    beq       L255C
                    lbra      L24CA
L255C               rts
L255D               lbsr      L337B
                    lbsr      L53B5
                    rts
L2564               lda       #$FF
                    sta       >$3405
                    clra
                    ldb       >$33D9
                    tfr       d,x
                    lda       #$FF
                    sta       >$3449
                    bra       L25A6
L2576               lda       #$FF
                    sta       >$3405
                    ldb       >$33D9
                    clra
                    tfr       d,x
                    cmpb      #$02
                    bne       L25A6
                    lda       #$3F
                    sta       >$33F2
                    ldy       #$0006
L258E               lda       >$3339,y
                    suba      >$32D2
                    bcc       L259D
                    lda       #$FF
                    sta       >$33EF
                    clra
L259D               sta       >$3339,y
                    leay      -$01,y
                    bne       L258E
                    rts
L25A6               clra
                    ldb       >$33D1,x
                    tfr       d,y
                    lda       >$08F3,y
                    anda      #$0F
                    pshs      u
                    ldu       >$0374
                    lda       a,u
                    puls      u
                    sta       >$33F2
                    lda       >$3449
                    bpl       L25CC
                    lda       >$33CF,x
                    lsra
                    lsra
                    bra       L25D0
L25CC               lda       >$33CF,x
L25D0               sta       >$3449
                    lda       >$333A,y
                    suba      >$3449
                    bcc       L25E2
                    lda       #$FF
                    sta       >$33EF
                    clra
L25E2               sta       >$333A,y
                    clr       >$3449
                    rts
                    rts
L25EB               sta       <u0090
                    cmpx      #$0000
                    bne       L2606
                    ldd       >$0614
                    std       >$0618
                    ldd       #$2869
                    std       <u0083
                    addd      >$060A
                    std       >$060E
                    clra
                    bra       L2619
L2606               ldd       >$0616
                    std       >$0618
                    ldd       #$2CA5
                    std       <u0083
                    addd      >$060C
                    std       >$060E
                    lda       #$01
L2619               sta       >$3452
                    ldb       <u00F0
                    lslb
                    ldy       #$1082
                    ldd       b,y
                    std       >$4006
                    lda       <u009B
                    bne       L262D
                    rts
L262D               cmpa      #$3F
                    bcs       L2633
                    lda       #$3E
L2633               anda      #$FE
                    sta       <u009B
                    ldy       #$0040
                    ldd       #$0000
L263E               std       >$12AE,y
                    leay      -$02,y
                    bne       L263E
                    clra
                    ldb       <u009B
                    incb
                    tfr       d,x
                    ldy       #$12B0
                    leau      >L27EE,pcr
                    tfr       u,d
                    leau      d,x
                    lda       #$01
L265A               ldb       ,-u
                    sta       b,y
                    leax      -$01,x
                    bne       L265A
                    clr       <u0028
                    ldb       >$3452
                    lda       <u009D
                    ldy       #$344C
                    sta       b,y
                    lda       <u009C
                    suba      #$58
                    lsla
                    adda      #$30
                    sta       <u009C
                    ldy       #$344A
                    sta       b,y
                    ldd       #$000C
                    ldy       #$12CF
L2685               adda      b,y
                    decb
                    bpl       L2685
                    ldb       >$3452
                    ldy       #$344E
                    sta       b,y
                    lda       <u0090
                    bne       L26A6
                    ldb       #$16
                    lda       <u009D
                    ldy       #$12BA
L269F               suba      b,y
                    decb
                    bpl       L269F
                    sta       <u009D
L26A6               lda       <u009D
                    suba      #$50
                    sta       <u0080
                    lda       #$2B
                    sta       <u0081
                    ldd       #$0050
                    subb      <u009D
                    bls       L26D8
                    decb
L26B8               tfr       d,y
L26BA               ldd       <u0083
                    addd      #$0018
                    std       <u0083
                    inc       <u0080
                    dec       <u0081
                    bpl       L26C8
                    rts
L26C8               leay      -$01,y
                    cmpy      #$0000
                    bpl       L26BA
                    ldb       <u0080
                    bpl       L26FC
                    negb
                    clra
                    bra       L26B8
L26D8               lda       #$FF
                    sta       <u0081
                    clra
                    ldb       <u009D
                    tfr       d,y
                    ldu       #$12B0
                    ldb       #$2B
L26E6               inc       <u0081
                    lda       b,u
                    beq       L26F4
                    leay      $01,y
                    cmpy      #$00AF
                    bcc       L26F7
L26F4               decb
                    bpl       L26E6
L26F7               lda       <u0081
                    bne       L26FC
                    rts
L26FC               lda       <u009C
                    suba      #$02
                    ldb       #$0C
                    ldy       #$12CF
                    andcc     #^Carry
L2708               sbca      b,y
                    decb
                    bpl       L2708
                    anda      #$FE
                    sta       <u0092
                    lda       #$01
                    sta       >$0613
                    sta       >$0612
L2719               clra
                    ldb       <u0081
                    tfr       d,y
                    lda       >$12B9,y
                    lbeq      L27B6
                    inc       <u0028
                    ldb       <u0080
                    lbsr      L2189
                    clra
                    ldb       <u0092
                    std       <u008F
                    lda       #$17
                    sta       <u007F
                    clr       >$0613
L2739               ldb       <u007F
                    ldy       #$12C4
                    lda       b,y
                    lbeq      L27A8
                    ldx       <u0083
                    lda       b,x
                    ldb       <u0090
                    addb      #$02
                    stb       <u0090
                    cmpb      #$30
                    bcs       L27A8
                    tst       >$0612
                    beq       L277E
                    ldx       >$4006
                    abx
                    ldb       ,x+
                    beq       L276C
                    cmpb      <u0080
                    bcs       L276C
                    anda      #$0F
                    clr       >$0613
                    inc       >$0613
L276C               ldb       ,x
                    beq       L277C
                    cmpb      <u0080
                    bcs       L277C
                    anda      #$F0
                    clr       >$0613
                    inc       >$0613
L277C               ldb       <u0090
L277E               tsta
                    beq       L27A8
                    subb      #$30
                    cmpb      #$A0
                    bcc       L27A8
                    lsrb
                    pshs      a
                    anda      #$F0
                    bne       L2796
                    lda       b,u
                    anda      #$F0
                    ora       ,s+
                    bra       L27A6
L2796               lda       ,s
                    anda      #$0F
                    bne       L27A4
                    lda       b,u
                    anda      #$0F
                    ora       ,s+
                    bra       L27A6
L27A4               lda       ,s+
L27A6               sta       b,u
L27A8               dec       <u007F
                    lbpl      L2739
                    inc       <u0080
                    lda       <u0080
                    cmpa      #$60
                    bpl       L27D1
L27B6               lda       >$0613
                    bne       L27BE
                    sta       >$0612
L27BE               ldd       <u0083
                    addd      #$0018
                    std       <u0083
                    cmpd      >$060E
                    bcc       L27D1
                    dec       <u0081
                    lbpl      L2719
L27D1               lda       <u0028
                    ldb       >$3452
                    ldy       #$3450
                    sta       b,y
                    ldb       <u009B
                    lda       #$10
                    mul
                    std       <u007F
                    lda       <u007F
                    lbsr      L36C9
                    lda       <u0080
                    lbsr      L36BC
                    rts
L27EE               fcb       $1F,$20             ....O9.
L27F0               fcb       $0F,$30,$2F,$10,$27,$18,$07,$38 .0/.'..8
L27F8               fcb       $37,$08,$17,$28,$13,$2C,$2B,$14 7..(.,+.
L2800               fcb       $0B,$34,$33,$0C,$03,$3C,$3B,$04 .43..<;.
L2808               fcb       $23,$1C,$1B,$24,$1D,$22,$2D,$12 #..$."-.
L2810               fcb       $0D,$32,$35,$0A,$05,$3A,$15,$2A .25..:.*
L2818               fcb       $25,$1A,$39,$06,$11,$2E,$21,$1E %.9...!.
L2820               fcb       $31,$0E,$09,$36,$29,$16,$3D,$02 1..6).=.
L2828               fcb       $19,$26,$01,$3E,$00
L282D               fcb       $8E,$10,$8E         .&.>....
L2830               fcb       $E1,$86,$26,$01,$39

L2835               stb       <u008F
                    sta       <u0092
                    stb       a,x
                    ldy       #$07B6
                    lslb
L2840               ldd       b,y
                    std       <u0085
                    ldb       <u008F
                    cmpb      #$02
                    bcc       L284F
                    lda       >$338E
                    bra       L2869
L284F               cmpb      #$08
                    bcc       L2883
                    lda       <u0092
                    ldy       #$33E1
                    lda       a,y
                    ldy       #$08F3
                    lda       a,y
                    anda      #$0F
                    ldy       >$0374
                    lda       a,y
L2869               ldb       <u0092
                    bne       L2873
                    leau      >L29B1,pcr
                    bra       L2877
L2873               leau      >L29C9,pcr
L2877               ldb       <u008F
                    leay      >L29A9,pcr
                    ldb       b,y
                    leau      b,u
                    bra       L28BA
L2883               subb      #$08
                    ldy       #$1F94
                    lda       b,y
                    pshs      a
                    anda      #$0F
                    pshs      a
                    ldx       >$0376
                    lda       a,x
                    sta       <u0091
                    lda       ,s+
                    ldx       >$0378
                    lda       a,x
                    sta       >$338E
                    ldb       <u0092
                    beq       L28AC
                    leau      >L29C9,pcr
                    bra       L28B0
L28AC               leau      >L29B1,pcr
L28B0               puls      a
                    anda      #$F0
                    lsra
                    lsra
                    leau      a,u
                    lda       <u0091
L28BA               ldy       #$399C
                    ldb       <u00A4
                    sta       b,y
                    tst       <u0092
                    bne       L28CB
                    ldd       #$2869
                    bra       L28CE
L28CB               ldd       #$2CA5
L28CE               std       <u0087
                    ldx       #$043C
                    tfr       d,y
                    clra
                    lbsr      L18AB
                    ldb       #$03
                    ldy       #$3453
L28DF               lda       b,u
                    sta       b,y
                    decb
                    bpl       L28DF
                    ldb       <u0092
                    lda       >$3455
                    ldx       #$3457
                    sta       b,x
L28F0               clr       <u0091
                    ldy       <u0085
                    ldd       ,y++
                    std       <u007F
                    ldx       #$3453
                    ldu       <u0087
                    pshs      u
                    leay      d,y
L2902               lda       ,-y
                    sta       <u008F
                    bpl       L294F
                    ldb       #$02
                    pshs      y
                    ldy       #$0085
L2910               lda       <u008F
                    anda      #$03
                    lda       a,x
                    lsr       <u008F
                    lsr       <u008F
                    sta       b,y
                    decb
                    bpl       L2910
                    tst       <u0091
                    beq       L293B
                    lda       ,y
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       ,u
                    sta       ,u+
                    lda       $02,y
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       $01,y
                    sta       ,u+
                    clr       <u0091
                    bra       L294B
L293B               lda       $01,y
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       ,y
                    sta       ,u+
                    lda       $02,y
                    sta       ,u
                    inc       <u0091
L294B               puls      y
                    bra       L2977
L294F               anda      #$03
                    lda       a,x
                    sta       <u0085
                    ldb       <u0085
                    lslb
                    lslb
                    lslb
                    lslb
                    lsr       <u008F
                    lsr       <u008F
L295F               tst       <u0091
                    beq       L296D
                    tfr       b,a
                    ora       ,u
                    sta       ,u+
                    clr       <u0091
                    bra       L2973
L296D               lda       <u0085
                    sta       ,u
                    inc       <u0091
L2973               dec       <u008F
                    bpl       L295F
L2977               ldd       <u007F
                    subd      #$0001
                    std       <u007F
                    bne       L2902
                    tfr       u,d
                    subd      ,s++
                    pshs      b,a
                    ldy       #$0029
L298A               leay      -$01,y
                    subd      #$0018
                    bcc       L298A
                    leay      $01,y
                    puls      b,a
                    tst       <u0092
                    beq       L29A1
                    std       >$060C
                    sty       >$0616
                    rts
L29A1               std       >$060A
                    sty       >$0614
                    rts
L29A9               fcb       $00,$00,$08,$00,$04,$08,$00 9.......
L29B0               fcb       $00
L29B1               fcb       $00,$0E,$05,$0F,$00,$0E,$0F ........
L29B8               fcb       $05,$00,$05,$0E,$0F,$00,$05,$0F ........
L29C0               fcb       $0E,$00,$0F,$0E,$05,$00,$0F,$05 ........
L29C8               fcb       $0E
L29C9               fcb       $00,$0E,$06,$0F,$00,$0E,$0F ........
L29D0               fcb       $06,$00,$06,$0E,$0F,$00,$06,$0F ........
L29D8               fcb       $0E,$00,$0F,$0E,$06,$00,$0F,$06 ........
L29E0               fcb       $0E
L29E1               fcb       $17,$00,$35,$1F,$23,$48,$34 ...5.#H4
L29E8               fcb       $26,$B7,$33,$6C,$F7,$33,$6D,$17 &73lw3m.
L29F0               fcb       $00,$5A,$48,$F6,$33,$6D,$3D,$1F .ZHv3m=.
L29F8               fcb       $23,$33,$CB,$F6,$33,$6C,$31,$A5 #3Kv3l1%

L2A00               lda       ,-y
                    anda      >$3CD7
                    sta       ,-u
                    decb
                    bne       L2A00
                    ldb       >$336C
                    leay      b,y
                    leay      b,y
                    dec       >$336D
                    bne       L2A00
                    puls      y,b,a
                    rts
                    pshs      y,b,a
                    sta       >$336C
                    stb       >$336D
                    lbsr      L2A59
                    tfr       a,b
                    lsla
                    tfr       y,u
                    leau      a,u
L2A2B               lda       ,y+
                    lsla
                    rola
                    rola
                    rola
                    anda      >$3CD7
                    sta       ,-u
                    decb
                    bne       L2A2B
                    ldb       >$336C
                    leay      b,y
                    leau      b,u
                    leau      b,u
                    leau      b,u
                    dec       >$336D
                    bne       L2A2B
                    puls      y,b,a
                    rts
L2A4C               pshs      y,b,a
                    mul
L2A4F               lda       ,u+
                    sta       ,y+
                    decb
                    bne       L2A4F
                    puls      y,b,a
                    rts
L2A59               pshs      y,b,a
L2A5B               ldb       ,s
L2A5D               lda       ,u+
                    sta       ,y+
                    decb
                    bne       L2A5D
                    ldb       ,s
                    leay      b,y
                    dec       $01,s
                    bne       L2A5B
                    puls      y,b,a
                    rts
L2A6F               ldx       #$3F64
                    ldu       #$3A4E
                    ldy       #$3B3E
                    bsr       L2AD5
                    ldx       #$3EC4
                    ldu       #$3A9E
                    ldy       #$3B8E
L2A85               bsr       L2AD5
                    ldx       #$3E24
                    ldu       #$3AEE
                    ldy       #$3BDE
                    bsr       L2AD5
                    ldu       #$3CD0
                    ldx       #$3A4F
                    ldy       #$3C89
                    bsr       L2AF1
                    ldx       #$3A9F
                    ldy       #$3C93
                    bsr       L2AF1
                    ldx       #$3AEF
                    ldy       #$3C9D
                    bsr       L2AF1
                    ldu       #$3CD3
                    ldx       #$3B3F
                    ldy       #$3CA7
                    bsr       L2B22
                    ldx       #$3B8F
                    ldy       #$3CB1
                    bsr       L2B22
                    ldx       #$3BDF
                    ldy       #$3CBB
                    bsr       L2B22
                    lbsr      L2B4F
                    lbra      L2B99
L2AD5               ldb       #$50
L2AD7               lda       ,-x
                    cmpa      ,-x
                    bcc       L2AE7
                    sta       b,u
                    lda       ,x
                    sta       b,y
                    decb
                    bne       L2AD7
                    rts
L2AE7               sta       b,y
                    lda       ,x
                    sta       b,u
                    decb
                    bne       L2AD7
                    rts
L2AF1               lda       #$5F
                    sta       ,u
                    lda       #$0A
                    sta       <u009A
L2AF9               lda       #$5F
                    sta       ,y
                    lda       #$04
                    sta       <u0099
L2B01               ldd       ,x++
                    cmpa      ,y
                    bcc       L2B09
                    sta       ,y
L2B09               cmpb      ,y
                    bcc       L2B0F
                    stb       ,y
L2B0F               dec       <u0099
                    bne       L2B01
                    lda       ,y+
                    cmpa      ,u
                    bcc       L2B1B
                    sta       ,u
L2B1B               dec       <u009A
                    bne       L2AF9
                    leau      u0001,u
                    rts
L2B22               clr       ,u
                    lda       #$0A
                    sta       <u009A
L2B28               clr       ,y
                    lda       #$04
                    sta       <u0099
L2B2E               ldd       ,x++
                    cmpa      ,y
                    bls       L2B36
                    sta       ,y
L2B36               cmpb      ,y
                    bls       L2B3C
                    stb       ,y
L2B3C               dec       <u0099
                    bne       L2B2E
                    lda       ,y+
                    cmpa      ,u
                    bls       L2B48
                    sta       ,u
L2B48               dec       <u009A
                    bne       L2B28
                    leau      u0001,u
                    rts
L2B4F               lda       #$5F
                    sta       >$3CCF
                    clr       >$3CD6
                    lda       >$3CD3
                    ldb       #$09
                    ldu       #$3C7F
L2B5F               sta       b,u
                    decb
L2B62               bpl       L2B5F
                    lda       >$3CD2
                    ldb       #$09
                    ldu       #$3CC5
L2B6C               sta       b,u
                    decb
                    bpl       L2B6C
                    ldx       #$3CA7
                    ldy       #$3A4F
                    bsr       L2B81
                    ldx       #$3C9D
                    ldy       #$3C7F
L2B81               ldb       #$09
L2B83               lda       b,x
                    sta       ,-y
                    sta       ,-y
                    sta       ,-y
                    sta       ,-y
                    sta       ,-y
                    sta       ,-y
                    sta       ,-y
                    sta       ,-y
                    decb
                    bpl       L2B83
                    rts
L2B99               bsr       L2BA4
                    lbsr      L2C36
                    lbsr      L2CB5
                    lbra      L2D24
L2BA4               lda       >$3CD0
                    cmpa      >$3CCF
                    bcc       L2BB6
                    ldb       >$3CCF
                    stb       >$3CE0
                    ldb       #$00
                    bsr       L2BEA
L2BB6               lda       >$3CD1
                    cmpa      >$3CD0
                    bcc       L2BC8
                    ldb       >$3CD0
                    stb       >$3CE0
                    ldb       #$11
                    bsr       L2BEA
L2BC8               lda       >$3CD2
                    cmpa      >$3CD1
                    bcc       L2BDA
                    ldb       >$3CD1
                    stb       >$3CE0
                    ldb       #$22
                    bsr       L2BEA
L2BDA               lda       >$3CD6
                    cmpa      >$3CD2
                    bcc       L2C35
                    ldb       >$3CD2
                    stb       >$3CE0
                    ldb       #$33
L2BEA               sta       <u0090
                    nega
                    adda      >$3CE0
                    inca
                    sta       >$3CE0
                    orcc      #IntMasks
                    sts       <u0099
                    stb       <u0092
                    ldb       <u0090
                    clra
                    lslb
                    rola
                    lds       #$0285
                    lds       d,s
                    leas      <$50,s
                    lda       <u0092
                    sta       <u0093
                    ldb       <u0092
                    ldx       <u0092
                    ldy       <u0092
                    ldu       <u0092
L2C17               pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    dec       >$3CE0
                    bne       L2C17
                    lds       <u0099
                    andcc     #^IntMasks
L2C35               rts
L2C36               ldx       #$3CD0
                    ldy       #$3C88
                    ldb       #$11
                    bsr       L2C55
                    ldx       #$3CD1
                    ldy       #$3C92
                    ldb       #$22
                    bsr       L2C55
                    ldx       #$3CD2
                    ldy       #$3C9C
                    ldb       #$33
L2C55               stb       >$3CD7
                    lda       #$0A
L2C5A               ldb       ,x
                    cmpb      a,y
                    bcc       L2C71
                    pshs      y,x,a
                    sta       >$3CD8
                    stb       >$3CE0
                    lda       a,y
                    ldb       >$3CD7
                    bsr       L2C75
                    puls      y,x,a
L2C71               deca
                    bne       L2C5A
                    rts
L2C75               stb       <u0092
                    stb       <u0093
                    suba      >$3CE0
                    sta       <u0090
                    orcc      #IntMasks
                    sts       <u0099
                    ldb       >$3CE0
                    lds       #$0285
                    leas      b,s
                    lds       b,s
                    ldb       <u0090
                    lda       >$3CD8
                    lsla
                    lsla
                    lsla
                    leas      a,s
                    lda       <u0092
                    ldx       <u0092
                    ldy       <u0092
                    ldu       <u0092
                    tfr       a,dp
L2CA4               pshs      u,y,x,dp,a
                    leas      <-$48,s
                    decb
                    bpl       L2CA4
                    clra
                    tfr       a,dp
                    lds       <u0099
                    andcc     #^IntMasks
                    rts
L2CB5               ldu       #$3C92
                    ldy       #$3A4E
                    ldb       #$11
                    bsr       L2CD4
                    ldu       #$3C9C
                    ldy       #$3A9E
                    ldb       #$22
                    bsr       L2CD4
                    ldu       #$3CA6
                    ldy       #$3AEE
                    ldb       #$33
L2CD4               stb       >$3CD7
                    lda       #$50
                    ldx       #$0008
L2CDC               ldb       ,u
                    cmpb      a,y
                    bcc       L2CF3
                    pshs      u,y,x,a
                    sta       >$3CD8
                    stb       >$3CE0
                    lda       a,y
                    ldb       >$3CD7
                    bsr       L2D00
                    puls      u,y,x,a
L2CF3               leax      -$01,x
                    bne       L2CFC
                    leau      -u0001,u
                    ldx       #$0008
L2CFC               deca
                    bne       L2CDC
                    rts
L2D00               stb       <u0092
                    suba      >$3CE0
                    pshs      a
                    ldb       >$3CE0
                    ldu       #$0285
                    leau      b,u
                    ldu       b,u
                    ldb       >$3CD8
                    decb
                    leau      b,u
                    puls      b
                    lda       <u0092
L2D1B               sta       ,u
                    leau      <-u0050,u
                    decb
                    bpl       L2D1B
                    rts
L2D24               lda       #$11
                    ldy       #$3F64
                    ldx       #$3A9F
                    bsr       L2D43
                    lda       #$22
                    ldy       #$3EC4
                    ldx       #$3AEF
                    bsr       L2D43
                    lda       #$33
                    ldy       #$3E24
                    ldx       #$3B3F
L2D43               sta       >$3CD7
                    lda       #$0F
                    sta       >$3CE0
                    lda       #$50
                    sta       >$3CD8
L2D50               lda       ,-y
                    cmpa      ,-x
                    bls       L2D5C
                    tfr       a,b
                    subb      ,x
                    bsr       L2D74
L2D5C               com       >$3CE0
                    lda       ,-y
                    cmpa      ,x
                    bls       L2D6B
                    tfr       a,b
                    subb      ,x
                    bsr       L2D74
L2D6B               com       >$3CE0
                    dec       >$3CD8
                    bne       L2D50
                    rts
L2D74               ldu       #$0285
                    leau      a,u
                    ldu       a,u
                    lda       >$3CD8
                    deca
                    leau      a,u
                    lda       >$3CE0
                    sta       >$3CE2
                    anda      >$3CD7
                    sta       <u0092
                    com       >$3CE2
L2D8F               lda       ,u
                    anda      >$3CE2
                    ora       <u0092
                    sta       ,u
                    leau      <u0050,u
                    decb
                    bne       L2D8F
                    rts
L2D9F               ldd       <u00A0
                    beq       L2E04
                    std       <u008F
                    ldx       >$0103
                    leax      >$3BFF,x
                    leay      >$0200,x
                    sty       >$30E3
L2DB4               ldy       >$30E3
                    ldd       <u008F
                    lda       d,x
                    pshs      a
                    ldd       <u008F
                    ldb       d,y
                    cmpb      #$5F
                    beq       L2DD3
                    lbsr      L2189
                    ldb       ,s
                    subb      #$30
                    bcs       L2DD3
                    cmpb      #$A0
                    bcs       L2DD7
L2DD3               puls      b
                    bra       L2DFB
L2DD7               lsrb
                    clra
                    leau      d,u
                    puls      b
                    subb      #$30
                    lsrb
                    bcs       L2DE6
                    lda       #$F0
                    bra       L2DE8
L2DE6               lda       #$0F
L2DE8               sta       >$3CE2
                    anda      #$EE
                    sta       <u0092
                    com       >$3CE2
                    lda       ,u
                    anda      >$3CE2
                    ora       <u0092
                    sta       ,u
L2DFB               ldd       <u008F
                    subd      #$0001
                    std       <u008F
                    bne       L2DB4
L2E04               rts
L2E05               lda       <u0011
                    bne       L2E0A
                    rts
L2E0A               lbsr      L3E2B
                    clr       <u00D0
                    lda       >$345A
                    cmpa      #$FF
                    bne       L2E17
                    rts
L2E17               clr       <u00F2
                    clr       <u00F4
                    lda       <u00DA
                    sta       <u00F1
                    lda       <u00E2
                    sta       <u00F3
                    orcc      #Carry
                    lbsr      L1486
                    lbsr      L1377
                    lda       <u0015
                    bne       L2E3D
                    lda       <u0033
                    sta       <u00C8
                    lda       <u0035
                    sta       >$39AA
                    lda       <u0034
                    sta       >$39A9
L2E3D               lda       >$345A
                    bmi       L2E80
                    lda       <u00F0
                    bmi       L2E80
                    sta       >$39B7
                    lbsr      L13F2
                    lda       <u0038
                    sta       <u00CC
                    clra
                    ldb       >$345A
                    tfr       d,x
                    lda       >$38D6,x
                    cmpa      #$10
                    bne       L2E80
                    ldb       >$345A
                    lslb
                    clra
                    tfr       d,x
                    lda       >$3817,x
                    sta       <u00D0
                    ldd       >$3876,x
                    bpl       L2E74
                    clr       <u00D0
                    rts
L2E74               tst       <u0015
                    beq       L2E7C
                    subb      #$28
                    addb      <u0015
L2E7C               subb      #$03
                    stb       <u00D4
L2E80               rts
L2E81               lda       <u00BE
                    suba      #$05
                    sta       <u008F
                    lda       <u00C0
                    suba      #$05
                    sta       <u0090
                    ldb       >$1F6B
                    ldu       #$345B
                    ldx       #$1F6C
                    ldy       #$1F74
L2E9A               lda       b,u
                    beq       L2EAE
                    lda       b,x
                    suba      <u008F
                    cmpa      #$0A
                    bcc       L2EAE
                    lda       b,y
                    suba      <u0090
                    cmpa      #$0A
                    bcs       L2EB4
L2EAE               decb
                    bpl       L2E9A
                    lbra      L37FD
L2EB4               stb       <u00FB
                    lda       <u0011
                    bne       L2EC0
                    lda       #$01
                    sta       <u0011
                    clr       <u0015
L2EC0               lda       b,x
                    sta       <u00DA
                    lda       b,y
                    sta       <u00E2
                    addb      #$08
                    stb       >$39A3
                    lda       <u00E2
                    suba      <u00C0
                    bcs       L2ED9
                    lsla
                    lsla
                    lsla
                    lsla
                    bra       L2EDF
L2ED9               nega
                    lsla
                    lsla
                    lsla
                    lsla
                    nega
L2EDF               adda      #$88
                    sta       <u008F
                    ldb       <u00DA
                    subb      <u00BE
                    addb      <u008F
                    ldx       #$040A
                    abx
                    lda       #$80
                    sta       ,x
                    rts
L2EF2               lda       <u0011
                    beq       L2F14
                    lda       <u0015
                    bne       L2F14
                    lda       >$39A9
                    bne       L2F14
                    lda       >$39AA
                    cmpa      #$A0
                    bcc       L2F14
                    lda       >$34B2
                    suba      <u00C8
                    adda      #$40
                    cmpa      #$80
                    bcc       L2F14
                    orcc      #Carry
                    rts
L2F14               andcc     #^Carry
                    rts
L2F17               ldd       >$39E1
                    std       >$33FE
                    clrb
                    lbsr      L2F28
                    ldb       #$01
                    lbsr      L2F28
                    ldb       #$03
L2F28               stb       <u00A4
                    ldy       #$000F
                    lda       b,y
                    bne       L2F33
                    rts
L2F33               ldx       #$00CE
                    clr       b,x
                    cmpb      #$03
                    beq       L2F44
                    lbsr      L2FDA
                    lbsr      L3E69
                    bra       L2F47
L2F44               lbsr      L3B78
L2F47               lbsr      L3DF2
                    ldb       <u00A4
                    ldy       #$00D6
                    lslb
                    ldx       b,y
                    stx       <u00F1
                    ldy       #$00DE
                    ldd       b,y
                    std       <u00F3
                    andcc     #^Carry
                    lbsr      L1486
                    lbsr      L1377
                    ldb       <u00A4
                    lda       <u00F0
                    ldy       #$39B5
                    sta       b,y
                    lda       <u0033
                    ldy       #$00C6
                    sta       b,y
                    ldy       #$39A5
                    lslb
                    leay      b,y
                    ldd       <u0034
                    std       ,y
                    ldb       <u00F0
                    bmi       L2FD9
                    lbsr      L13F2
                    ldb       <u00A4
                    lda       <u0038
                    cmpb      #$03
                    bne       L2F92
                    lsra
L2F92               ldy       #$00CA
                    sta       b,y
                    lda       <u0036
                    ldy       #$00CE
                    sta       b,y
                    lsra
                    lsra
                    lsra
                    tfr       a,b
                    clra
                    tfr       d,x
                    ldb       <u00A4
                    lda       <u0037
                    cmpa      #$83
                    bne       L2FB2
                    lda       #$FF
L2FB2               cmpb      #$03
                    bne       L2FB8
                    lda       #$80
L2FB8               suba      #$80
                    lsra
                    adda      #$80
                    adca      >$3673,x
                    ldy       #$0013
                    tst       b,y
                    beq       L2FCD
                    suba      #$28
                    adda      b,y
L2FCD               ldy       #$39E7
                    adda      b,y
                    ldy       #$00D2
                    sta       b,y
L2FD9               rts
L2FDA               ldy       #$00D6
                    lslb
                    lda       b,y
                    suba      <u00AE
                    cmpa      #$05
                    bgt       L2FFC
                    cmpa      #$FB
                    blt       L2FFC
                    ldy       #$00DE
                    lda       b,y
                    suba      <u00B0
                    cmpa      #$05
                    bgt       L2FFC
                    cmpa      #$FB
                    blt       L2FFC
                    rts
L2FFC               clra
                    lsrb
                    tfr       d,y
                    lbsr      L38FA
                    ldd       ,s++
                    rts
L3006               ldb       #$03
L3008               lda       >$3411
                    cmpa      #$68
                    bls       L3010
                    rts
L3010               ldx       #$00CE
                    ldy       #$00D2
                    lda       b,x
                    cmpa      #$58
                    bcs       L3021
                    cmpa      #$A8
                    bcs       L3022
L3021               clra
L3022               sta       b,x
                    lda       b,y
                    cmpa      #$1E
                    bcc       L302D
                    clra
                    sta       b,x
L302D               cmpa      #$AF
                    bcs       L3034
                    clra
                    sta       b,x
L3034               sta       b,y
                    lda       b,x
                    ldu       #$39AD
                    sta       b,u
                    decb
                    bpl       L3008
                    ldx       #$0000
                    ldy       #$0004
L3047               lda       $0E,y
                    beq       L3062
                    lda       >$00CD,y
                    beq       L3062
                    lda       >$39E6,y
                    cmpa      #$3C
                    beq       L3062
                    tfr       y,d
                    decb
                    stb       >$39FB,x
                    leax      $01,x
L3062               leay      -$01,y
                    bne       L3047
                    cmpx      #$0000
                    bne       L306C
                    rts
L306C               cmpx      #$0001
                    bne       L3077
                    ldb       >$39FB
                    lbra      L3110
L3077               clra
                    ldb       >$39FB
                    lslb
                    tfr       d,y
                    ldb       >$39FC
                    lslb
                    tfr       d,x
                    ldd       >$39A5,y
                    subd      >$39A5,x
                    bcs       L309C
                    ldb       >$39FB
                    stb       >$39D9
                    ldb       >$39FC
                    stb       >$39DA
                    bra       L30A8
L309C               ldb       >$39FC
                    stb       >$39D9
                    ldb       >$39FB
                    stb       >$39DA
L30A8               ldb       >$39DA
                    cmpb      #$03
                    beq       L3108
                    ldb       >$39D9
                    cmpb      #$03
                    bne       L30C3
                    ldb       >$39DA
                    stb       >$39D9
                    ldb       #$03
                    stb       >$39DA
                    bra       L3108
L30C3               ldu       #$00CA
                    cmpb      #$02
                    bne       L30DF
                    lda       b,u
                    cmpa      #$1E
                    bls       L30DD
                    ldb       >$39DA
                    lda       b,u
                    cmpa      #$1E
                    bls       L30DD
                    lda       #$1E
                    sta       b,u
L30DD               bra       L3108
L30DF               ldb       >$39DA
                    cmpb      #$02
                    bne       L30FB
                    lda       b,u
                    cmpa      #$1E
                    bls       L3108
                    ldb       >$39D9
                    lda       b,u
                    cmpa      #$1E
                    bls       L3108
                    lda       #$1E
                    sta       b,u
                    bra       L3108
L30FB               ldb       >$39D9
                    lda       b,u
                    cmpa      #$1E
                    bls       L3108
                    lda       #$1E
                    sta       b,u
L3108               ldb       >$39D9
                    bsr       L3110
                    ldb       >$39DA
L3110               stb       <u00A4
                    ldu       #$0013
                    lda       b,u
                    beq       L311F
                    cmpa      #$1E
                    lbcs      L31A3
L311F               ldx       #$00CE
                    lda       b,x
                    sta       <u009C
                    ldy       #$00D2
                    lda       b,y
                    sta       <u009D
                    ldu       #$00CA
                    lda       b,u
                    sta       <u009B
                    ldu       #$39B5
                    lda       b,u
                    sta       <u00F0
                    ldu       #$0013
                    lda       b,u
                    beq       L3145
                    inc       <u00F0
L3145               ldu       #$03FF
                    lda       b,u
                    ldu       #$39A1
                    ldb       b,u
                    lbsr      L282D
                    ldb       <u00A4
                    ldu       #$399C
                    lda       b,u
                    pshs      a
                    ldu       #$03FF
                    ldb       b,u
                    clra
                    tfr       d,x
                    puls      a
                    sta       >$39DD,x
                    cmpx      #$0002
                    bne       L3178
                    ldb       <u00FB
                    ldy       #$345B
                    tst       b,y
                    beq       L317B
L3178               lbsr      L0131
L317B               lbsr      L25EB
                    ldb       <u00A4
                    cmpb      #$02
                    bne       L319A
                    lda       <u009D
                    andcc     #^Carry
                    ldx       #$12B9
                    pshs      b
                    ldb       #$29
L318F               adca      b,x
                    decb
                    bpl       L318F
                    suba      #$0D
                    puls      b
                    bra       L319E
L319A               lda       <u009D
                    adca      #$07
L319E               ldu       #$39B1
                    sta       b,u
L31A3               lbra      L3AF1
L31A6               lda       >$3380
                    suba      >$3384
                    bcc       L31C8
                    lda       >$3380
                    ldb       >$3384
                    stb       >$3380
                    sta       >$3384
                    lda       >$3382
                    ldb       >$3386
                    stb       >$3382
                    sta       >$3386
                    bra       L31A6
L31C8               sta       >$3388
                    clr       >$3CE2
                    lda       >$3382
                    suba      >$3386
                    bcc       L31D9
                    inc       >$3CE2
L31D9               sta       >$3389
                    clr       >$3381
                    clr       >$3385
                    clr       >$3383
                    clr       >$3387
                    lda       >$3384
                    sta       >$338A
                    lda       >$3386
                    sta       >$338B
L31F4               ldb       >$3386
                    lbsr      L2189
                    pshs      u
                    ldb       >$3386
                    lbsr      L2180
                    ldb       >$3384
                    lda       >$3CD7
                    sta       b,u
                    puls      u
                    sta       b,u
L320E               clra
                    ldb       >$3389
                    tst       >$3CE2
                    beq       L3218
                    deca
L3218               addd      >$3386
                    std       >$3386
                    clra
                    ldb       >$3388
                    addd      >$3384
                    std       >$3384
                    cmpa      >$338A
                    bne       L3235
                    ldb       >$3386
                    cmpb      >$338B
                    beq       L320E
L3235               cmpa      >$3380
                    bcs       L31F4
                    lda       >$3386
                    cmpa      >$3382
                    bne       L31F4
                    rts
L3243               lda       ,x+
                    bpl       L3254
                    anda      #$7F
                    leay      -$01,y
                    ldb       ,x+
L324D               stb       ,u+
                    deca
                    bne       L324D
                    bra       L325D
L3254               ldb       ,x+
                    stb       ,u+
                    leay      -$01,y
                    deca
                    bne       L3254
L325D               leay      -$01,y
                    bne       L3243
                    rts
L3262               tfr       x,d
                    stb       >$3465
                    lda       $0F,x
                    beq       L32AC
                    lda       <$13,x
                    bne       L32AC
                    lda       >$00CE,x
                    beq       L32AC
                    lda       >$3463
                    bpl       L32AC
                    lda       >$39B1,x
                    cmpa      #$A0
                    bcc       L32AC
                    lda       >$39AD,x
                    cmpa      #$58
                    bcs       L32AC
                    cmpa      #$A8
                    bcc       L32AC
                    ldb       >$39B5,x
                    lslb
                    ldu       #$1082
                    ldu       b,u
                    suba      #$40
                    lsla
                    tfr       a,b
                    clra
                    lda       d,u
                    adda      #$50
                    cmpa      >$39B1,x
                    bcc       L32AC
                    orcc      #Carry
                    rts
L32AC               andcc     #^Carry
                    rts
L32AF               tfr       x,d
                    lslb
                    ldu       #$39A5
                    lda       b,u
                    cmpa      #$03
                    bcc       L32CA
                    lda       >$00C6,x
                    cmpa      #$40
                    bcs       L32CA
                    cmpa      #$C0
                    bcc       L32CA
                    orcc      #Carry
                    rts
L32CA               andcc     #^Carry
                    rts
L32CD               sta       >$3464
                    clr       >$3463
                    tfr       x,d
                    stb       >$33D9
                    lda       >$0FA1,x
                    sta       >$39A0
                    lda       >$39AD,x
                    sta       >$3466
                    lda       >$39B1,x
                    sta       >$3477
                    lda       >$3464
                    beq       L3308
                    lbsr      L36AB
                    anda      #$1F
                    adda      #$71
                    sta       >$3476
                    lbsr      L36AB
                    anda      #$1F
                    adda      #$71
                    sta       >$3487
                    bra       L332C
L3308               lbsr      L36AB
                    anda      #$7F
                    adda      #$40
                    cmpa      #$68
                    bcs       L3317
                    cmpa      #$98
                    bcs       L3308
L3317               sta       >$3476
L331A               lbsr      L36AB
                    anda      #$7F
                    adda      #$40
                    cmpa      #$68
                    bcs       L3329
                    cmpa      #$98
                    bcs       L331A
L3329               sta       >$3487
L332C               clrb
                    pshs      u,y,x
                    ldu       #$06D5
                    ldx       #$3466
                    ldy       #$3477
                    stu       ,--s
L333B               lda       b,u
                    stb       $01,s
                    incb
                    lda       a,x
                    sta       ,s
                    lda       b,u
                    incb
                    lda       a,x
                    adda      ,s
                    rora
                    ldb       b,u
                    sta       b,x
                    ldb       $01,s
                    lda       b,u
                    incb
                    lda       a,y
                    sta       ,s
                    lda       b,u
                    incb
                    lda       a,y
                    adda      ,s
                    rora
                    ldb       b,u
                    sta       b,y
                    ldb       $01,s
                    addb      #$03
                    cmpb      #$2D
                    bne       L333B
                    ldd       ,s++
                    puls      u,y,x
                    rts
L3372               lda       >$3463
                    bmi       L337A
                    inc       >$3463
L337A               rts
L337B               ldb       >$3463
                    bmi       L33B1
                    lsrb
                    ldx       #$3466
                    lda       b,x
                    sta       >$34B0
                    ldy       #$3477
                    lda       b,y
                    sta       >$34B1
                    ldu       #$0FA4
                    lda       b,u
                    sta       >$34AF
                    lda       >$3463
                    cmpa      #$22
                    bmi       L33B2
                    lda       #$FF
                    sta       >$3463
                    lbsr      L21F1
                    lda       >$3464
                    beq       L33B1
                    lbsr      L2576
L33B1               rts
L33B2               ldb       >$34B0
                    lsrb
                    andb      #$01
                    clra
                    tfr       d,x
                    clra
                    ldb       >$39A0
                    tfr       d,y
                    lda       >$34AF
                    bsr       L33C9
                    lbra      L2193
L33C9               pshs      y
                    bne       L33D3
                    leau      >L3444,pcr
                    bra       L33E0
L33D3               deca
                    bne       L33DC
                    leau      >L3435,pcr
                    bra       L33E0
L33DC               leau      >L3426,pcr
L33E0               lda       #$FF
                    sta       >$3CD7
                    ldy       #$11B8
                    lda       #$03
                    ldb       #$05
                    lbsr      L29E1
                    puls      y
                    lda       >$08F3,y
                    sta       <u007F
                    ldy       #$11F4
                    ldx       #$11B8
                    ldu       #$0FB6
                    ldb       #$0A
                    pshs      b
L3406               lbsr      L36AB
                    anda      #$0F
                    lda       a,u
                    sta       <u0082
                    ldb       #$06
L3411               lda       ,x
                    anda      <u0082
                    sta       ,y
                    anda      <u007F
                    sta       ,x+
                    com       ,y+
                    decb
                    bne       L3411
                    dec       ,s
                    bne       L3406
                    puls      pc,b
L3426               fcb       $00,$00             jd&b5...
L3428               fcb       $FF,$00,$FF,$FF,$0F,$FF,$FF,$FF ........
L3430               fcb       $FF,$FF,$FF,$FF,$FF
L3435               fcb       $00,$00,$00         ........
L3438               fcb       $00,$00,$00,$00,$00,$FF,$00,$0F ........
L3440               fcb       $FF,$00,$FF,$FF
L3444               fcb       $00,$00,$00,$00     ........
L3448               fcb       $00,$00,$00,$00,$00,$00,$00,$0F ........
L3450               fcb       $00,$0F,$FF
L3453               fcb       $B6,$36,$71,$27,$1D ...66q'.
L3458               fcb       $7F,$36,$72,$10,$8E,$0E,$EA,$8E ^?6r...j.
L3460               fcb       $11,$50,$C6,$05

L3464               lda       b,y
                    lda       a,x
                    cmpa      #$3F
                    bhi       L3476
                    anda      #$0F
                    cmpa      #$03
                    bhi       L3476
                    decb
                    bpl       L3464
L3475               rts
L3476               ldx       #$000F
                    ldy       #$00CE
                    ldb       #$03
L347F               lda       b,x
                    bne       L3485
                    sta       b,y
L3485               decb
                    bpl       L347F
                    ldx       #$344A
                    ldy       #$344C
                    clrb
L3490               lda       b,y
                    cmpa      >$3441
                    bhi       L34C3
                    ldu       #$3450
                    adda      b,u
                    cmpa      >$3441
                    bls       L34C3
                    lda       b,x
                    ldu       #$344E
                    adda      b,u
                    suba      #$30
                    cmpa      >$3440
                    bls       L34C3
                    lda       b,x
                    suba      b,u
                    suba      #$30
                    cmpa      >$3440
                    bhi       L34C3
                    tfr       b,a
                    inca
                    adda      >$3672
                    sta       >$3672
L34C3               incb
                    cmpb      #$02
                    bne       L3490
                    clr       >$3671
                    lda       >$3672
                    beq       L352C
                    cmpa      #$03
                    beq       L34FC
                    dec       >$3672
                    ldx       #$00CE
                    ldy       #$0013
                    ldu       #$03FF
                    ldb       #$03
L34E3               lda       b,x
                    beq       L34F8
                    lda       b,y
                    bne       L34F8
                    lda       b,u
                    cmpa      >$3672
                    bne       L34F8
                    clra
                    tfr       d,x
                    lbra      L1EC6
L34F8               decb
                    bpl       L34E3
                    rts
L34FC               ldx       #$00CE
                    ldy       #$0013
                    ldu       #$00CA
                    ldb       #$03
                    clr       >$366F
L350B               lda       b,x
                    beq       L3520
                    lda       b,y
                    bne       L3520
                    lda       b,u
                    cmpa      >$366F
                    bcs       L3520
                    sta       >$366F
                    stb       >$3670
L3520               decb
                    bpl       L350B
                    clra
                    ldb       >$3670
                    tfr       d,x
                    lbsr      L1EC6
L352C               rts
L352D               lda       #$60
                    sta       >$036F
                    ldu       #$0C86
L3535               ldb       #$27
                    ldy       #$039F
L353B               lda       b,u
                    beq       L355C
                    sta       b,y
                    decb
                    bpl       L353B
                    ldd       #$039A
                    pshs      u
                    lbsr      L36E4
                    ldy       #$001E
                    lbsr      L4840
                    lbsr      L484C
                    puls      u
                    leau      u0001,u
                    bra       L3535
L355C               lda       #$30
                    sta       >$036F
                    rts
L3562               ldu       #$0343
                    ldy       ,u
                    ldx       #$0F00
                    ldd       #$FFFF
L356E               std       ,y++
                    leax      -$01,x
                    bne       L356E
                    rts
L3575               lda       #$FF
                    sta       >$34BF
                    cmpx      #$0002
                    bcs       L3582
                    clr       >$34BF
L3582               ldb       >$399C,x
                    ldy       #$08F3
                    rts
L358B               lda       #$EE
                    bra       L3591
L358F               lda       #$FF
L3591               pshs      b
                    sta       >$3CE2
                    lbsr      L35D4
                    lbsr      L36E6
                    ldb       ,s
                    lbsr      L35FF
                    lbsr      L36E6
                    puls      pc,b
L35A6               pshs      x
                    lda       >$090C,x
                    sta       >$03CB
                    lda       >$0918,x
                    sta       >$03CC
                    ldd       #$03C8
                    lbsr      L36E4
                    ldx       ,s
                    lda       >$0912,x
                    sta       >$03CB
                    lda       >$0918,x
                    sta       >$03CC
                    ldd       #$03C8
                    lbsr      L36E4
                    puls      pc,x
L35D4               pshs      u,b
                    ldu       #$322D
                    lda       b,u
                    sta       <u008F
                    ldu       #$3239
                    ldb       b,u
                    clra
                    tfr       d,y
                    ldb       ,s
                    ldu       #$090C
                    lda       b,u
                    sta       >$0F7B
                    ldu       #$0918
                    lda       b,u
                    sta       >$0F7C
                    leau      >L4C56,pcr
                    stu       <u008B
                    bra       L3625
L35FF               pshs      u,b
                    ldu       #$3233
                    ldb       b,u
                    stb       <u008F
                    andb      #$07
                    clra
                    tfr       d,y
                    leau      >L5917,pcr
                    stu       <u008B
                    ldb       ,s
                    ldu       #$0912
                    lda       b,u
                    sta       >$0F7B
                    ldu       #$0918
                    lda       b,u
                    sta       >$0F7C
L3625               puls      u,b
L3627               pshs      u,y,x,b
                    lda       >$08F3,y
                    sta       <u0090
                    ldb       <u008F
                    lslb
                    lslb
                    lslb
                    clra
                    addd      <u008B
                    tfr       d,y
                    ldu       #$348A
                    ldb       #$1F
L363E               clr       b,u
                    decb
                    bpl       L363E
                    lda       #$F0
                    sta       >$3CD7
                    ldx       #$0008
L364B               lda       ,y+
                    sta       >$3489
                    clrb
L3651               lsr       >$3489
                    bcc       L365F
                    lsrb
                    lda       b,u
                    ora       >$3CD7
                    sta       b,u
                    rolb
L365F               com       >$3CD7
                    incb
                    cmpb      #$04
                    bne       L3651
                    leau      <u0010,u
                    clrb
L366B               lsr       >$3489
                    bcc       L3679
                    lsrb
                    lda       b,u
                    ora       >$3CD7
                    sta       b,u
                    rolb
L3679               com       >$3CD7
                    incb
                    cmpb      #$04
                    bne       L366B
                    leau      -u000E,u
                    leax      -$01,x
                    lbne      L364B
                    ldy       #$348A
                    ldb       #$1F
L368F               lda       b,y
                    pshs      a
                    anda      <u0090
                    sta       b,y
                    puls      a
                    coma
                    anda      >$3CE2
                    ora       b,y
                    sta       b,y
                    decb
                    bpl       L368F
                    ldd       #$0F78
                    std       <u00A5
                    puls      pc,u,y,x,b
L36AB               pshs      y,b
                    clra
                    ldb       >$34AA
                    tfr       d,y
                    inc       >$34AA
                    lda       >$050A,y
                    puls      pc,y,b
L36BC               adda      >$34AE
                    sta       >$34AE
                    bcc       L36C8
                    lda       #$01
                    bra       L36C9
L36C8               rts
L36C9               pshs      a
                    adda      >$33F6
                    sta       >$33F6
                    puls      a
                    adca      >$32CF
                    sta       >$32CF
                    bcc       L36E3
                    inc       >$32D0
                    bne       L36E3
                    inc       >$32D1
L36E3               rts
L36E4               std       <u00A5
L36E6               ldy       <u00A5
                    ldx       #$007F
                    ldb       #$04
                    lbsr      L37F5
                    sty       <u00A5
L36F4               lda       <u0082
                    sta       <u0084
                    lda       <u0081
                    sta       <u0086
L36FC               lda       <u0083
                    sta       <u0085
                    inc       >$34C3
                    ldu       <u00A5
                    lda       ,u
                    beq       L3752
                    clrb
                    ldy       #$0924
L370E               cmpa      b,y
                    beq       L3715
                    incb
                    bne       L370E
L3715               lda       <u0084
                    bmi       L3739
                    cmpa      #$4F
                    bhi       L3739
                    lda       #$10
                    mul
                    addd      <u007F
                    tfr       d,y
                    ldb       <u0085
                    lbsr      L218E
                    lda       <u0084
                    leau      a,u
                    ldb       #$08
L372F               ldx       ,y++
                    stx       ,u
                    leau      <u0050,u
                    decb
                    bne       L372F
L3739               inc       <u00A6
                    bne       L373F
                    inc       <u00A5
L373F               inc       <u0084
                    inc       <u0084
                    dec       <u0086
                    lbne      L36FC
                    lda       <u0083
                    suba      #$08
                    sta       <u0083
                    lbra      L36F4
L3752               lda       #$10
                    ldb       >$34C3
                    mul
                    sta       <u007F
                    lbsr      L36C9
                    lda       <u007F
                    lbra      L36BC
L3762               clr       >$3CE2
                    ldy       <u00A5
                    leay      $03,y
                    ldd       ,y++
                    sta       >$34C4
                    stb       >$34C5
L3772               lda       ,y+
                    bne       L3777
                    rts
L3777               sty       >$336F
                    cmpa      #$20
                    beq       L37E6
                    ldu       #$094D
                    ldb       #$FF
L3784               incb
                    cmpa      ,u+
                    bne       L3784
                    cmpb      #$09
                    bhi       L3798
                    bne       L3791
                    ldb       #$06
L3791               stb       <u008F
                    ldd       #$1A20
                    bra       L379F
L3798               subb      #$0A
                    stb       <u008F
                    ldd       #$1AB0
L379F               std       <u008B
                    lsl       <u008F
                    ldy       #$0005
                    lda       <u008F
                    pshs      a
                    lbsr      L3627
                    ldy       #$348A
                    ldx       #$19E0
                    ldb       #$1F
                    lbsr      L37F5
                    puls      a
                    inca
                    sta       <u008F
                    ldy       #$0005
                    lbsr      L3627
                    ldy       #$348A
                    ldx       #$1A00
                    ldb       #$1F
                    lbsr      L37F5
                    lda       >$34C4
                    sta       >$0F83
                    lda       >$34C5
                    sta       >$0F84
                    ldd       #$0F80
                    std       <u00A5
                    lbsr      L36E6
L37E6               lda       >$34C4
                    adda      #$04
                    sta       >$34C4
                    ldy       >$336F
                    lbra      L3772
L37F5               lda       ,y+
                    sta       ,x+
                    decb
                    bpl       L37F5
                    rts
L37FD               ldd       #$FFFF
                    std       <u0081
                    lda       >$1F6B
                    sta       <u007F
L3807               ldb       <u007F
                    cmpb      <u00FB
                    bne       L3811
                    lda       <u0015
                    bne       L386B
L3811               ldy       #$345B
                    lda       b,y
                    beq       L386B
                    clr       <u00F2
                    clr       <u00F4
                    ldy       #$1F6C
                    lda       b,y
                    sta       <u00F1
                    ldy       #$1F74
                    lda       b,y
                    sta       <u00F3
                    lbsr      L1377
                    ldb       <u007F
                    lda       <u0033
                    ldy       #$34D6
                    sta       b,y
                    lda       <u0035
                    ldy       #$34CE
                    sta       b,y
                    sta       <u0097
                    lda       <u0034
                    ldy       #$34C6
                    sta       b,y
                    sta       >$3CE0
                    cmpa      <u0081
                    bcs       L385B
                    bne       L386B
                    lda       <u0097
                    cmpa      <u0082
                    bhi       L386B
L385B               lda       >$3CE0
                    stb       <u0083
                    sta       <u0081
                    lda       <u0097
                    sta       <u0082
                    lda       <u0033
                    sta       >$34DE
L386B               dec       <u007F
                    bpl       L3807
                    lda       <u0015
                    bne       L3877
                    lda       <u0083
                    sta       <u00FB
L3877               ldb       <u00FB
                    ldy       #$1F94
                    lda       b,y
                    anda      #$0F
                    ldx       >$0376
                    lda       a,x
                    ldb       #$09
                    lbsr      L010A
                    ldd       <u0081
                    std       >$39A9
                    lda       >$34DE
                    sta       <u00C8
                    lda       #$4E
                    lbra      L36BC
L389A               lda       #$03
                    sta       <u00A4
L389E               ldb       <u00A4
                    ldy       #$0013
                    lda       b,y
                    beq       L38F5
                    cmpa      #$28
                    bne       L38C3
                    cmpb      #$02
                    bne       L38C0
                    lda       <u00FB
                    sta       >$338F
                    dec       >$34DF
                    bne       L38BD
                    lbsr      L197F
L38BD               lbsr      L37FD
L38C0               lbsr      L39CE
L38C3               ldb       <u00A4
                    ldy       #$0013
                    dec       b,y
                    beq       L38FA
                    ldy       #$00CA
                    lda       b,y
                    lsra
                    lsra
                    lsra
                    lsra
                    ldy       #$10E0
                    cmpa      #$0F
                    bls       L38E1
                    lda       #$0F
L38E1               ldb       a,y
                    lbsr      L3941
                    ldb       <u00A4
                    ldy       #$0013
                    lda       b,y
                    cmpa      #$1E
                    bcs       L38F5
                    lbsr      L3A2C
L38F5               dec       <u00A4
                    bpl       L389E
                    rts
L38FA               ldy       #$03FF
                    pshs      b
                    ldb       b,y
                    lda       #$FF
                    ldy       #$108E
                    sta       b,y
                    ldb       ,s+
                    bne       L3914
                    lda       <u0010
                    lbne      L3A5E
L3914               cmpb      #$02
                    bne       L3926
                    lda       >$338F
                    ldy       #$345B
                    clr       a,y
                    lbsr      L37FD
                    bra       L3932
L3926               cmpb      #$03
                    bne       L3932
                    lda       #$FF
                    sta       >$34AD
                    sta       >$32D5
L3932               ldb       <u00A4
                    cmpb      #$03
                    lbeq      L3CCD
                    ldy       #$000F
                    clr       b,y
                    rts
L3941               stb       <u007F
                    bne       L3947
                    inc       <u007F
L3947               ldb       <u00A4
                    ldy       #$03FF
                    lda       #$1F
                    sta       <u0087
                    ldb       #$3F
L3953               lbsr      L396A
                    ldy       #$3620
                    lda       b,y
                    adda      #$06
                    bcc       L3962
                    lda       #$FF
L3962               sta       b,y
                    decb
                    cmpb      <u0087
                    bne       L3953
                    rts
L396A               stb       <u0098
                    clra
                    ldu       #$35E0
                    ldb       b,u
                    andb      #$7F
                    lda       <u007F
                    mul
                    std       <u0083
                    ldb       <u0098
                    ldy       #$34E0
                    leay      b,y
                    leay      b,y
                    tst       b,u
                    bmi       L398F
                    ldd       <u0083
                    addd      ,y
                    std       ,y
                    bra       L3995
L398F               ldd       ,y
                    subd      <u0083
                    std       ,y
L3995               ldb       <u0098
                    clra
                    ldu       #$3620
                    ldb       b,u
                    andb      #$7F
                    lda       <u007F
                    lsla
                    lsla
                    mul
                    std       <u0083
                    ldb       <u0098
                    ldy       #$3560
                    leay      b,y
                    leay      b,y
                    tst       b,u
                    bmi       L39BC
                    ldd       <u0083
                    addd      ,y
                    std       ,y
                    bra       L39C2
L39BC               ldd       ,y
                    subd      <u0083
                    std       ,y
L39C2               ldb       <u0098
                    rts
L39C5               lbsr      L3575
                    lda       #$28
                    sta       <$13,x
                    rts
L39CE               ldb       <u00A4
                    ldy       #$00CA
                    ldb       b,y
                    lsrb
                    lsrb
                    cmpb      #$0F
                    bls       L39DE
                    ldb       #$0F
L39DE               ldy       #$10D0
                    lda       b,y
                    sta       <u008F
                    lsra
                    sta       <u0090
                    ldb       <u00A4
                    ldy       #$03FF
                    ldb       b,y
                    lda       #$1F
                    sta       <u0087
                    ldb       #$3F
                    ldx       #$3560
L39FA               pshs      b
                    lslb
                    lbsr      L36AB
                    anda      <u008F
                    sbca      <u0090
                    ldu       #$34E0
                    sta       b,u
                    lbsr      L36AB
                    anda      <u008F
                    sbca      <u0090
                    sta       b,x
                    puls      b
                    lbsr      L36AB
                    ldu       #$35E0
                    sta       b,u
                    lbsr      L36AB
                    anda      #$7F
                    ldu       #$3620
                    sta       b,u
                    decb
                    cmpb      <u0087
                    bne       L39FA
                    rts
L3A2C               ldb       <u00A4
                    ldu       #$2869
                    ldx       #$001F
                    ldy       #$03FF
                    lda       b,y
                    beq       L3A3F
                    ldu       #$2CA5
L3A3F               pshs      u
                    lbsr      L36AB
                    tfr       a,b
                    clra
                    leau      d,u
                    clr       ,u
                    clr       >u0100,u
                    clr       >u0200,u
                    clr       >u02EC,u
                    puls      u
                    leax      -$01,x
                    bne       L3A3F
                    rts
L3A5E               pshs      b
                    lda       >$39A2
                    sta       >$39A1
                    ldd       <u00D8
                    std       <u00D6
                    ldd       <u00E0
                    std       <u00DE
                    lda       >$39AE
                    sta       >$39AD
                    lda       >$39B2
                    sta       >$39B1
                    ldd       >$39BB
                    std       >$39B9
                    lda       >$39C2
                    sta       >$39C1
                    lda       <u00C3
                    sta       <u00C2
                    ldd       >$39C7
                    std       >$39C5
                    ldd       >$39CF
                    std       >$39CD
                    lda       >$39D6
                    sta       >$39D5
                    lda       >$399D
                    sta       >$399C
                    lda       >$39E4
                    sta       >$39E3
                    lda       >$39E8
                    sta       >$39E7
                    lda       >$39EC
                    sta       >$39EB
                    lda       <u0014
                    sta       <u0013
                    lda       >$33E2
                    sta       >$33E1
                    lda       >$33D4
                    sta       >$33D3
                    lda       >$33DB
                    sta       >$33DA
                    lda       >$33FF
                    sta       >$33FE
                    lda       #$FF
                    sta       >$108E
                    clr       <u0010
                    lda       #$01
                    sta       <u000F
                    lda       <u00CF
                    bne       L3AEE
                    lbsr      L41AC
                    clr       <u0084
                    clr       <u0086
                    ldd       <u0083
                    std       <u00D6
                    ldd       <u0085
                    std       <u00DE
L3AEE               puls      b
                    rts
L3AF1               ldb       <u00A4
                    ldu       #$0013
                    lda       b,u
                    bne       L3AFB
                    rts
L3AFB               ldx       #$00CE
                    lda       b,x
                    sta       <u0082
                    ldy       #$00D2
                    lda       b,y
                    cmpb      #$02
                    bne       L3B10
                    adda      #$28
                    suba      b,u
L3B10               sta       <u0081
                    ldu       #$39B5
                    ldb       b,u
                    lslb
                    ldu       #$1082
                    ldd       b,u
                    std       <u007F
                    ldb       <u00A4
                    ldu       #$03FF
                    ldb       b,u
                    lda       #$1F
                    sta       <u0087
                    lda       #$3F
                    sta       <u0092
L3B2E               ldb       <u0092
                    lslb
                    ldx       #$34E0
                    abx
                    lda       ,x
                    adda      <u0082
                    sta       <u008F
                    ldx       #$3560
                    abx
                    lda       ,x
                    adda      <u0081
                    bcs       L3B6F
                    suba      #$50
                    bcs       L3B6F
                    ldb       <u008F
                    ldx       <u007F
                    abx
                    cmpa      ,x
                    bcs       L3B6F
                    cmpa      #$5F
                    bcc       L3B6F
                    ldb       <u008F
                    subb      #$58
                    bcs       L3B6F
                    cmpb      #$50
                    bcc       L3B6F
                    pshs      b
                    tfr       a,b
                    lbsr      L2189
                    puls      b
                    leau      b,u
                    lda       #$CC
                    sta       ,u
L3B6F               dec       <u0092
                    lda       <u0092
                    cmpa      <u0087
                    bhi       L3B2E
                    rts
L3B78               lda       <u0016
                    bne       L3B92
                    lda       <u0012
                    beq       L3B92
                    lda       <u00C5
                    cmpa      #$01
                    bne       L3B93
                    lda       #$06
                    adda      >$39EA
                    sta       >$39EA
                    bne       L3B92
                    inc       <u00C5
L3B92               rts
L3B93               cmpa      #$02
                    bne       L3BB0
                    lda       <u0015
                    beq       L3BA5
                    lda       #$01
                    sta       >$39A4
                    lda       #$06
                    sta       <u00C5
                    rts
L3BA5               ldd       <u00DA
                    std       <u00F1
                    ldd       <u00E2
                    std       <u00F3
                    lbra      L3CD0
L3BB0               cmpa      #$03
                    bne       L3BE9
                    lda       #$FB
                    adda      >$39EA
                    sta       >$39EA
                    lda       <u0015
                    beq       L3BC8
                    inc       <u00C5
                    lda       #$02
                    sta       >$39C4
                    rts
L3BC8               lda       <u00CC
                    cmpa      #$22
                    bcs       L3BD0
                    lda       #$22
L3BD0               lsra
                    adda      <u00D4
                    sta       <u008F
                    lda       <u00D5
                    cmpa      <u008F
                    bcc       L3BE8
                    lda       >$3662
                    beq       L3BE6
                    lda       #$01
                    sta       >$3663
                    rts
L3BE6               inc       <u00C5
L3BE8               rts
L3BE9               cmpa      #$04
                    bne       L3C5E
                    dec       >$39C4
                    bne       L3C5D
                    ldb       <u00FB
                    ldx       #$1F8C
                    lda       b,x
                    cmpa      #$F1
                    bne       L3C0C
                    ldx       #$0003
                    lbsr      L39C5
                    lda       >$34AC
                    beq       L3C0B
                    lbsr      L3E12
L3C0B               rts
L3C0C               cmpa      #$F2
                    bne       L3C31
                    lda       >$34AC
                    beq       L3C2B
                    inc       >$32FA
                    clr       >$3326
                    clr       <u00A9
                    clr       >$3414
                    lda       #$FF
                    sta       >$3666
                    ldx       #$0002
                    lbsr      L39C5
L3C2B               ldx       #$0003
                    lbra      L39C5
L3C31               lda       >$34AC
                    beq       L3C3F
                    lbsr      L3E12
                    ldx       #$0003
                    lbra      L39C5
L3C3F               lda       #$01
                    lbsr      L5A4C
                    lda       #$01
                    sta       >$39A4
                    inc       <u00C5
                    lda       <u0015
                    bne       L3C5D
                    lda       >$3665
                    sta       >$32D5
                    inc       >$3660
                    lda       #$12
                    sta       >$3661
L3C5D               rts
L3C5E               cmpa      #$05
                    bne       L3C6F
                    lda       #$05
                    adda      >$39EA
                    sta       >$39EA
                    bne       L3C6E
                    inc       <u00C5
L3C6E               rts
L3C6F               cmpa      #$06
                    bne       L3C97
                    lda       #$37
                    sta       <u00A9
                    lda       <u00A7
                    sta       >$3667
                    lda       <u00C9
                    sta       <u00A7
                    lbsr      L14BE
                    lda       >$3667
                    sta       <u00A7
                    ldd       <u00AA
                    addd      <u00AE
                    std       <u00F1
                    ldd       <u00AC
                    addd      <u00B0
                    std       <u00F3
                    lbra      L3CD0
L3C97               cmpa      #$07
                    bne       L3CAA
                    lda       #$FA
                    adda      >$39EA
                    sta       >$39EA
                    cmpa      #$A6
                    bne       L3CA9
                    inc       <u00C5
L3CA9               rts
L3CAA               cmpa      #$08
                    bne       L3CCF
                    lda       >$3660
                    beq       L3CCD
                    lda       #$01
                    sta       <u00EB
                    sta       <u00E9
                    lda       #$FF
                    sta       <u00EA
                    lda       #$02
                    sta       <u00EF
                    lda       <u00F5
                    bmi       L3CC9
                    cmpa      #$05
                    bhi       L3CCD
L3CC9               lda       #$05
                    sta       <u00F5
L3CCD               clr       <u0012
L3CCF               rts
L3CD0               lda       >$3660
                    cmpa      #$01
                    bne       L3CDD
                    inc       >$3660
                    lbsr      L3DC1
L3CDD               ldd       <u00BE
                    pshs      b,a
                    ldd       <u00C0
                    pshs      b,a
                    ldd       <u00DC
                    std       <u00BE
                    ldd       <u00E4
                    std       <u00C0
                    lbsr      L1377
                    puls      b,a
                    std       <u00C0
                    puls      b,a
                    std       <u00BE
                    lda       #$30
                    sta       <u00A9
                    lda       <u0034
                    bne       L3D14
                    lda       <u0035
                    cmpa      <u00A9
                    bcc       L3D14
                    sta       <u00A9
                    lda       >$3662
                    beq       L3D12
                    lda       #$0F
                    sta       >$39A3
L3D12               inc       <u00C5
L3D14               lda       <u00A7
                    sta       >$3667
                    lda       <u0033
                    sta       <u00A7
                    lbsr      L14BE
                    lda       >$3667
                    sta       <u00A7
                    ldd       <u00DC
                    addd      <u00AA
                    std       <u00DC
                    ldd       <u00E4
                    addd      <u00AC
                    std       <u00E4
                    rts
L3D32               clrb
                    lda       <u00FB
                    sta       >$3665
                    ldy       #$1F8C
                    lda       a,y
                    cmpa      #$F0
                    bne       L3D43
                    incb
L3D43               stb       >$3662
                    clr       >$3663
                    lda       #$08
                    sta       >$39C4
                    lda       #$37
                    sta       <u00A9
                    lda       <u00A7
                    sta       >$3667
                    lda       <u00C8
                    sta       <u00A7
                    lbsr      L14BE
                    lda       >$3667
                    sta       <u00A7
                    ldd       <u00AA
                    addd      <u00AE
                    std       <u00DC
                    ldd       <u00AC
                    addd      <u00B0
                    std       <u00E4
                    lda       #$01
                    sta       <u0012
                    sta       <u00C5
                    clr       >$39A4
                    clr       >$3660
                    lda       #$A6
                    sta       >$39EA
                    lda       <u00F5
                    bpl       L3D88
                    lda       #$04
                    sta       <u00F5
L3D88               rts
L3D89               lda       <u000F
                    beq       L3D93
                    lda       <u0013
                    cmpa      #$1D
                    bcc       L3DBE
L3D93               lda       <u0010
                    beq       L3D9D
                    lda       <u0014
                    cmpa      #$1D
                    bcc       L3DBE
L3D9D               lda       <u0012
                    bne       L3DBE
                    lda       <u0011
                    beq       L3DBE
                    lda       <u0015
                    bne       L3DBE
                    lda       >$39A9
                    cmpa      #$03
                    bcc       L3DBE
                    lda       >$34B2
                    suba      <u00C8
                    adda      #$14
                    cmpa      #$28
                    bcc       L3DBE
                    orcc      #Carry
                    rts
L3DBE               andcc     #^Carry
                    rts
L3DC1               ldy       #$0006
L3DC5               lda       >$3457
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       >$3457
                    sta       >$2888,y
                    sta       >$28A0,y
                    sta       >$28B8,y
                    sta       >$28D0,y
                    sta       >$28E8,y
                    sta       >$2900,y
                    lda       #$EE
                    sta       >$2918,y
                    leay      -$01,y
                    bne       L3DC5
                    rts
L3DF2               lda       <u0011
                    beq       L3E11
                    lda       <u0015
                    beq       L3DFF
                    lda       #$FF
                    sta       >$3661
L3DFF               lda       >$3661
                    bmi       L3E11
                    dec       >$3661
                    bne       L3E11
                    lda       #$FF
                    sta       >$3661
                    lbsr      L3E12
L3E11               rts
L3E12               pshs      y,b,a
                    ldb       >$3665
                    cmpb      <u00FB
                    bne       L3E22
                    lda       #$FF
                    sta       >$33C8
                    bra       L3E28
L3E22               ldy       #$345B
                    clr       b,y
L3E28               puls      y,b,a
                    rts
L3E2B               lda       <u0015
                    bne       L3E68
                    lda       >$3663
                    beq       L3E68
                    lbsr      L3CCD
                    lda       #$FF
                    sta       >$34AD
                    ldb       >$3662
                    ldy       #$1100
                    lda       b,y
                    sta       >$39A3
                    cmpa      #$0C
                    beq       L3E52
                    suba      #$0D
                    adda      #$07
                    bra       L3E53
L3E52               clra
L3E53               sta       >$3664
                    inc       >$3662
                    cmpb      #$11
                    bne       L3E68
                    clr       >$3663
                    lda       >$34AC
                    beq       L3E68
                    lbsr      L3E12
L3E68               rts
L3E69               clra
                    ldb       <u00A4
                    lslb
                    tfr       d,x
                    stb       <u008F
                    ldy       >$00D6,x
                    sty       <u0083
                    ldy       >$00DE,x
                    sty       <u0085
                    ldy       >$39B9,x
                    sty       <u00A2
                    ldb       >$39C5,x
                    stb       >$0F8E
                    ldb       >$39CD,x
                    stb       >$0F8F
                    ldb       <u00A4
                    tfr       d,x
                    lda       >$39C1,x
                    sta       >$0F8A
                    lda       >$00C2,x
                    sta       >$0F8B
                    lda       >$39D5,x
                    sta       >$0F8C
                    lda       >$39F7,x
                    sta       <u0033
                    lda       >$33DD,x
                    sta       >$335F
                    lbsr      L4EBE
                    tst       <$13,x
                    beq       L3F05
                    lda       <u0033
                    adda      #$83
                    sbca      >$00C6,x
                    cmpa      #$06
                    bcc       L3EF6
                    pshs      x
                    tfr       x,d
                    lslb
                    tfr       d,x
                    ldy       >$39EF,x
                    sty       <u00AA
                    ldy       >$39F3,x
                    sty       <u00AC
                    ldd       <u0083
                    addd      <u00AA
                    std       <u0083
                    ldd       <u0085
                    addd      <u00AC
                    std       <u0085
                    puls      x
L3EF6               lbsr      L4081
                    bcc       L3F02
                    ldd       #$0000
                    std       <u00AA
                    std       <u00AC
L3F02               lbra      L4023
L3F05               lda       >$39EB,x
                    beq       L3F1E
                    adda      >$39E7,x
                    sta       >$39E7,x
                    beq       L3F1A
                    cmpa      #$3C
                    beq       L3F1A
                    rts
L3F1A               clr       >$39EB,x
L3F1E               dec       >$0F8A
                    bne       L3F4E
                    ldb       >$0F8B
L3F26               ldu       <u00A2
                    clra
                    leau      d,u
                    lda       ,u+
                    sta       >$0F8E
                    lda       ,u+
                    sta       >$0F8F
                    lda       ,u+
                    bpl       L3F42
                    anda      #$7F
                    tfr       a,b
                    stb       >$0F8B
                    bra       L3F26
L3F42               sta       >$0F8A
                    lda       >$0F8B
                    adda      >$0F8C
                    sta       >$0F8B
L3F4E               lda       >$0F8E
                    cmpa      #$80
                    lbeq      L4023
                    lda       >$0F8E
                    sta       <u0087
                    lda       >$0F8F
                    sta       <u0088
                    lda       <u00A7
                    cmpa      #$20
                    bls       L3F99
                    cmpa      #$60
                    bcc       L3F78
                    lda       >$0F8F
                    sta       <u0087
                    lda       >$0F8E
                    nega
                    sta       <u0088
                    bra       L3F99
L3F78               cmpa      #$A0
                    bcc       L3F8A
                    lda       >$0F8E
                    nega
                    sta       <u0087
                    lda       >$0F8F
                    nega
                    sta       <u0088
                    bra       L3F99
L3F8A               cmpa      #$E0
                    bcc       L3F99
                    lda       >$0F8E
                    sta       <u0088
                    lda       >$0F8F
                    nega
                    sta       <u0087
L3F99               lda       <u00AF
                    sta       <u00F2
                    lda       <u0087
                    adda      <u00AE
                    sta       <u00F1
                    lda       <u00B1
                    sta       <u00F4
                    lda       <u0088
                    adda      <u00B0
                    sta       <u00F3
                    ldd       <u00BE
                    pshs      b,a
                    ldd       <u00C0
                    pshs      b,a
                    ldd       <u0083
                    std       <u00BE
                    ldd       <u0085
                    std       <u00C0
                    lbsr      L1377
                    puls      b,a
                    std       <u00C0
                    puls      b,a
                    std       <u00BE
                    lda       >$335F
                    sta       <u00A9
                    lda       <u0034
                    bne       L3FDD
                    lda       <u0035
                    cmpa      <u00A9
                    bcc       L3FDD
                    ldb       >$0F8B
                    lbra      L3F26
L3FDD               lda       <u00A7
                    sta       >$3667
                    lda       <u0033
                    sta       <u00A7
                    lbsr      L14BE
                    lda       >$3667
                    sta       <u00A7
                    ldd       <u0083
                    addd      <u00AA
                    std       <u0083
                    ldd       <u0085
                    addd      <u00AC
                    std       <u0085
                    lbsr      L4081
                    bcc       L4011
                    ldb       <u00A4
                    ldu       #$39E7
                    lda       b,u
                    bne       L4023
                    lda       #$03
                    ldu       #$39EB
                    sta       b,u
                    bra       L4023
L4011               ldb       <u00A4
                    ldu       #$39E7
                    lda       b,u
                    cmpa      #$3C
                    bne       L4023
                    lda       #$FD
                    ldu       #$39EB
                    sta       b,u
L4023               clra
                    ldb       <u00A4
                    lslb
                    stb       <u008F
                    tfr       d,x
                    ldy       <u0083
                    sty       >$00D6,x
                    ldy       <u0085
                    sty       >$00DE,x
                    ldy       <u00A2
                    sty       >$39B9,x
                    ldy       <u00AA
                    sty       >$39EF,x
                    ldy       <u00AC
                    sty       >$39F3,x
                    ldb       >$0F8E
                    stb       >$39C5,x
                    ldb       >$0F8F
                    stb       >$39CD,x
                    ldb       <u00A4
                    tfr       d,x
                    lda       >$0F8A
                    sta       >$39C1,x
                    lda       >$0F8B
                    sta       >$00C2,x
                    lda       >$0F8C
                    sta       >$39D5,x
                    lda       <u0033
                    sta       >$39F7,x
                    rts
L4081               lda       #$03
                    sta       <u0091
L4085               ldu       #$1FA4
                    stu       <u0089
                    ldb       <u0091
                    lda       <u0086
                    leau      >L4140,pcr
                    adda      b,u
                    lda       <u0085
                    adca      #$00
                    sta       <u0090
                    lda       <u0084
                    leau      >L413C,pcr
                    adda      b,u
                    ldb       <u0083
                    adcb      #$00
                    stb       <u008F
                    andb      #$07
                    pshs      b
                    clra
                    ldb       <u008F
                    andb      #$3F
                    lsrb
                    lsrb
                    lsrb
                    addd      <u0089
                    std       <u0089
                    lda       #$08
                    ldb       <u0090
                    mul
                    addd      <u0089
                    tfr       d,u
                    lda       ,u
                    leax      >L4110,pcr
                    puls      b
                    anda      b,x
                    beq       L40D0
                    orcc      #Carry
                    rts
L40D0               dec       <u0091
                    bpl       L4085
                    ldb       <u00A4
                    cmpb      #$01
                    bne       L410D
                    lda       <u0083
                    suba      #$07
                    sta       <u008F
                    lda       <u0085
                    suba      #$07
                    sta       <u0090
                    ldb       >$1F6B
                    ldu       #$345B
                    ldx       #$1F6C
                    ldy       #$1F74
L40F3               lda       b,u
                    beq       L410A
                    lda       b,x
                    suba      <u008F
                    cmpa      #$0E
                    bcc       L410A
                    lda       b,y
                    suba      <u0090
                    cmpa      #$0E
                    bcc       L410A
                    orcc      #Carry
                    rts
L410A               decb
                    bpl       L40F3
L410D               andcc     #^Carry
                    rts
L4110               fcb       $80,$40,$20,$10,$08,$04,$02,$01
L4118               clra
                    tfr       d,x
                    lda       #$01
                    sta       >$39C1,x
                    clr       >$00C2,x
                    lda       #$03
                    sta       >$39D5,x
                    clra
                    lslb
                    tfr       d,x
                    tfr       y,d
                    lslb
                    ldu       #$0FD6
                    ldd       b,u
                    std       >$39B9,x
                    rts
L413C               fcb       $E0,$20,$E0,$20
L4140               fcb       $20,$20,$E0,$E0

L4144               sta       >$366A
                    tfr       x,d
                    stb       <u00A4
                    tfr       y,d
                    stb       >$399C,x
                    lda       <u008F
                    sta       >$39A1,x
                    lda       <u0090
                    sta       >$0FA1,x
                    lda       #$FF
                    sta       >$108E,x
                    clr       $0F,x
                    clr       <u0084
                    clr       <u0086
                    bsr       L41AC
                    lda       #$01
                    sta       $0F,x
                    clra
                    ldb       >$366A
                    tfr       d,y
                    ldb       <u00A4
                    lbsr      L4118
                    ldb       <u00A4
                    clra
                    lslb
                    tfr       d,x
                    ldy       <u0083
                    sty       >$00D6,x
                    ldy       <u0085
                    sty       >$00DE,x
                    ldb       <u00A4
                    tfr       d,x
                    clr       >$00CE,x
                    clr       <$13,x
                    lda       #$3C
                    sta       >$39E7,x
                    clr       >$39EB,x
                    lda       #$0A
                    sta       >$39E3,x
                    rts
L41AC               lbsr      L36AB
                    anda      #$03
                    adca      <u00AE
                    suba      #$02
                    cmpa      #$40
                    bcs       L41AC
                    cmpa      #$80
                    bcc       L41AC
                    sta       <u0083
L41BF               lbsr      L36AB
                    anda      #$03
                    adca      <u00B0
                    suba      #$02
                    cmpa      #$01
                    bcs       L41BF
                    cmpa      #$2E
                    bcc       L41BF
                    sta       <u0085
                    rts
L41D3               fcb       $02,$03,$04,$05,$06 ..9.....
L41D8               fcb       $07,$02,$03
L41DB               fcb       $B6,$36,$6E,$81,$01 ...66n..
L41E0               fcb       $26,$04,$7C,$36,$6E,$39

L41E6               cmpa      #$02
                    lbne      L4240
                    clr       >$336B
                    inc       <u00A7
                    lda       >$3412
                    cmpa      #$08
                    bcc       L41FB
                    inc       >$3412
L41FB               adda      >$3411
                    sta       >$3411
                    cmpa      #$F0
                    lbcs      L423F
                    lda       <u0015
                    beq       L4218
                    ldb       >$3665
                    ldy       #$345B
                    clr       b,y
                    clr       <u0015
                    clr       <u0011
L4218               clr       >$33A3
                    lbsr      L53A9
                    lda       #$FF
                    sta       >$33EE
                    lbsr      L429B
                    lbsr      L20A7
                    lbsr      L56B8
                    lda       >$338C
                    sta       <u00ED
                    clr       >$366E
                    lda       >$3666
                    beq       L423F
                    lbsr      L352D
                    clr       >$3666
L423F               rts
L4240               cmpa      #$03
                    bne       L4270
                    ldy       >$0374
                    lbsr      L013D
                    inc       >$366E
                    lda       #$EF
                    sta       >$3411
                    lda       #$E1
                    sta       >$3695
                    lbsr      L4950
                    lbsr      L3562
                    lbsr      L0395
                    lda       >$32D2
                    cmpa      >$32D3
                    beq       L426C
                    lbsr      L4974
L426C               lbsr      L0577
                    rts
L4270               cmpa      #$04
                    bne       L429A
                    clr       >$33EE
                    lbsr      L17C4
                    lda       >$330B
                    cmpa      >$3411
                    bcs       L4287
                    clr       >$366E
                    bra       L429A
L4287               lda       >$3411
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       <u008F
                    inc       <u008F
                    lda       >$3411
                    suba      <u008F
                    sta       >$3411
L429A               rts
L429B               lbsr      L3562
                    lbsr      L0395
L42A1               leax      >L42F5,pcr
                    ldu       #$4008
                    lda       #$01
                    lbsr      L4A6C
                    ldy       >$0372
                    lbsr      L013D
                    lbsr      L0395
                    lbsr      L4912
                    leax      >L42FB,pcr
                    ldu       #$4008
                    ldy       #$15BE
                    clra
                    lbsr      L4A6C
                    leax      >L4305,pcr
                    ldu       #$3CE4
                    ldy       #$00E8
                    clra
                    lbsr      L4A6C
                    lda       #$FF
                    sta       >$3371
                    sta       >$3372
                    sta       >$3373
                    ldd       #$0890
                    std       >$3374
                    ldd       #$08CA
                    std       >$3376
                    lbsr      L4632
                    lbra      L4694
L42F5               fcc       /ULTEK/
                    fcb       C$CR
L42FB               fcc       /ROBOTBUFF/
                    fcb       C$CR
L4305               fcc       /SINWAVE/
                    fcb       C$CR
L430D               fcb       $B6,$34,$AB,$27,$10,$81,$01,$26,$05,$17,$08,$A3,$20,$07
L431B               cmpa      #$02
                    bne       L4322
                    lbsr      L4BE0
L4322               lda       >$34B6
                    beq       L4328
                    rts
L4328               lda       >$33BC
                    beq       L4374
                    sta       >$33BD
                    bmi       L435D
                    lda       >$33B6
                    beq       L433D
                    clr       >$33B6
                    lbsr      L43A5
L433D               lda       >$33BC
                    cmpa      #$03
                    bcc       L4348
                    ldb       #$FF
                    bra       L4352
L4348               cmpa      #$05
                    bcc       L4350
                    ldb       #$00
                    bra       L4352
L4350               ldb       #$FF
L4352               stb       >$33BA
                    lbsr      L44BA
                    clr       >$33BC
                    bra       L4372
L435D               anda      #$7F
                    sta       >$33BC
                    lda       >$33BA
                    beq       L4372
                    lda       >$33BC
                    adda      #$02
                    lbsr      L44BA
                    clr       >$33BA
L4372               bra       L43A4
L4374               lda       >$33B7
                    beq       L4391
                    clr       >$33B7
                    ldb       <u00ED
                    lbsr      L5243
                    dec       >$32D4
                    lda       >$32D4
                    beq       L4391
                    cmpa      >$32CD
                    bne       L4391
                    dec       >$32CD
L4391               lda       >$33BB
                    beq       L43A1
                    clr       >$33BB
                    lda       #$0A
                    sta       <u00E9
                    lda       #$FF
                    sta       <u00EA
L43A1               clr       >$33BD
L43A4               rts
L43A5               lbsr      L4457
                    addb      #$0C
                    ldx       #$30E5
                    abx
                    lda       ,x+
                    sta       >$34B7
                    lda       ,x+
                    sta       >$34B8
                    anda      #$07
                    sta       >$34BD
                    lda       ,x
                    sta       >$34BC
                    rts
                    lbsr      L247B
                    lbcs      L2304
                    lda       #$05
                    sta       >$33BC
                    lbsr      L4457
                    addb      #$0F
                    ldu       #$30E5
                    clra
                    lda       d,u
                    ldy       #$000C
                    lbsr      L4416
                    ldb       >$32CD
                    ldx       #$32C5
                    abx
                    ldb       ,x
                    lslb
                    lslb
                    lslb
                    lslb
                    lslb
                    addb      #$10
                    clra
                    lda       d,u
                    ldy       #$0017
                    lbsr      L4416
                    lbsr      L4457
                    addb      #$12
                    clra
                    lda       d,u
                    suba      >$32D2
                    bcc       L4409
                    clra
L4409               ldy       #$0022
                    lbsr      L4416
                    lda       #$FF
                    sta       >$33BB
                    rts
L4416               pshs      u,y,x
                    pshs      a
                    leay      >$0B15,y
                    cmpa      #$FD
                    bcs       L4433
                    lda       >$0925
                    sta       ,y
                    lda       >$0924
                    ldb       >$0924
                    std       $01,y
                    puls      a
                    bra       L4455
L4433               ldx       #$0924
                    ldu       #$10F0
                    ldb       ,s
                    lda       #$20
                    sta       ,y
                    cmpb      #$10
                    bcs       L444B
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    ldb       b,u
                    lda       b,x
L444B               puls      b
                    andb      #$0F
                    ldb       b,u
                    ldb       b,x
                    std       $01,y
L4455               puls      pc,u,y,x
L4457               ldb       >$32CD
                    ldy       #$32C5
                    clra
                    lda       d,y
                    ldb       #$20
                    mul
                    rts
L4465               lbsr      L450D
                    lda       >$34B6
                    bne       L446E
                    rts
L446E               cmpa      #$05
                    beq       L44AF
                    tst       >$34C0
                    beq       L447B
                    dec       >$34C0
                    rts
L447B               tfr       a,b
                    leay      >L44B5,pcr
                    lda       b,y
                    sta       >$366B
                    leay      >L44B0,pcr
                    lda       b,y
                    adda      >$34B9
                    sta       >$34B9
                    lbsr      L4581
                    lda       >$34B9
                    cmpa      >$366B
                    bne       L44AF
                    cmpa      #$23
                    bne       L44A6
                    lbsr      L4581
                    bra       L44A9
L44A6               lbsr      L45B4
L44A9               lbsr      L4632
                    clr       >$34B6
L44AF               rts
L44B0               fcb       $00,$02,$FE,$02,$FE
L44B5               fcb       $00,$23,$23         ......##
L44B8               fcb       $4F,$FB
L44BA               fcb       $B7,$34,$B6,$34,$02,$48 O.7464.H
L44C0               fcb       $10,$8E,$08,$78,$AE,$A6,$BF,$33 ...x.&?3
L44C8               fcb       $74,$10,$8E,$08,$84,$AE,$A6,$BF t.....&?
L44D0               fcb       $33,$76,$35,$02,$81,$05,$26,$0E 3v5...&.
L44D8               fcb       $B6,$34,$B9,$81,$23,$26,$03,$17 649.#&..
L44E0               fcb       $03,$0B
L44E2               clr       >$34B6
                    rts
L44E6               bcc       L4507
                    tfr       a,b
                    leay      >L4508,pcr
                    lda       b,y
                    sta       >$34B9
                    leay      >L44B0,pcr
                    lda       b,y
                    lbsr      L4694
                    lbsr      L4533
                    lda       #$20
                    sta       >$34C0
                    clr       >$03F5
L4507               rts
L4508               fcb       $00,$FB,$4F,$23,$23
L450D               lda       >$3379
                    bne       L452C
                    lda       #$3A
                    sta       >$3379
                    lda       >$366C
                    anda      #$03
                    lsla
                    ldy       #$3CE4
                    ldd       a,y
                    addd      #$3CE4
                    lbsr      L45C6
                    inc       >$366C
L452C               clr       >$3378
                    dec       >$3379
                    rts
L4533               lda       #$EE
                    sta       >$3CE2
                    lda       >$34B7
                    sta       <u008F
                    clra
                    ldb       >$34BC
                    tfr       d,y
                    leax      >L4C56,pcr
                    stx       <u008B
                    lbsr      L3627
                    ldy       #$348A
                    ldx       #$0F1C
                    ldb       #$1F
L4555               lda       b,y
                    sta       b,x
                    decb
                    bpl       L4555
                    ldb       >$34B8
                    stb       <u008F
                    clra
                    ldb       >$34BD
                    tfr       d,y
                    leax      >L5917,pcr
                    stx       <u008B
                    lbsr      L3627
                    ldy       #$348A
                    ldx       #$0F4C
                    ldb       #$1F
L4579               lda       b,y
                    sta       b,x
                    decb
                    bpl       L4579
                    rts
L4581               pshs      b
                    ldb       >$34B9
                    lsrb
                    lsrb
                    lsrb
                    cmpb      #$08
                    bls       L458E
                    clrb
L458E               addb      #$28
                    lbsr      L4634
                    lbsr      L4694
                    puls      b
                    lbsr      L45B4
                    lda       >$34B9
                    sta       >$03F5
                    sta       >$03D4
                    inc       >$03D4
                    ldd       #$03D1
                    std       <u00A5
                    lda       #$33
                    lbsr      L45DB
                    lbra      L36E6
L45B4               ldx       #$0280
                    ldb       #$0F
                    lbsr      L2180
                    ldd       #$9999
L45BF               std       ,u++
                    leax      -$01,x
                    bne       L45BF
                    rts
L45C6               std       <u007F
                    lda       #$04
                    sta       <u008F
                    lda       #$0E
                    sta       <u0090
                    lda       #$40
                    sta       <u0091
                    lda       #$32
                    sta       <u0092
                    lbra      L4789
L45DB               sta       >$3CD7
                    ldb       >$34B9
                    cmpb      #$50
                    bcc       L4631
                    ldb       #$0E
                    lbsr      L2180
                    ldb       >$34B9
                    leau      b,u
                    negb
                    addb      #$4F
                    cmpb      #$0C
                    bcs       L45F8
                    ldb       #$0B
L45F8               pshs      u,b
                    lda       >$3CD7
L45FD               sta       >u0370,u
                    sta       >u0320,u
                    sta       <u0050,u
                    sta       ,u+
                    decb
                    bpl       L45FD
                    ldu       $01,s
                    leau      >u00A0,u
                    ldb       #$08
L4615               sta       ,u
                    leau      <u0050,u
                    decb
                    bne       L4615
                    puls      u,b
                    cmpb      #$0B
                    bne       L4631
                    leau      >u00A0,u
                    ldb       #$08
L4629               sta       u000B,u
                    leau      <u0050,u
                    decb
                    bne       L4629
L4631               rts
L4632               ldb       #$2C
L4634               cmpb      >$3371
                    bne       L4640
                    ldy       #$0005
                    lbra      L4840
L4640               stb       >$3371
                    lslb
                    ldx       #$07B6
                    ldd       b,x
                    std       <u0085
                    ldd       #$2CA5
                    std       <u0087
                    clr       >$3453
                    ldd       #$020F
                    std       >$3454
                    lda       #$0E
                    sta       >$3456
                    lbsr      L28F0
                    ldd       #$4836
                    std       <u007F
                    lda       #$10
                    sta       <u008F
                    lda       #$12
                    sta       <u0090
                    lda       #$20
                    sta       <u0091
                    lda       #$50
                    sta       <u0092
                    lbsr      L4789
                    ldd       #$2CFD
                    std       <u007F
                    lda       #$0B
                    sta       <u008F
                    lda       #$08
                    sta       <u0090
                    lda       #$22
                    sta       <u0091
                    ldb       #$47
                    lbsr      L2180
                    lda       #$50
                    lbra      L47AB
L4694               clr       >$3378
                    ldx       >$3374
                    ldb       ,x+
                    beq       L46AC
                    stx       >$3374
                    cmpb      >$3372
                    beq       L46AC
                    inc       >$3378
                    stb       >$3372
L46AC               ldx       >$3376
                    ldb       ,x+
                    beq       L46C1
                    stx       >$3376
                    cmpb      >$3373
                    beq       L46C1
                    inc       >$3378
                    stb       >$3373
L46C1               ldy       #$0010
                    tst       >$3378
                    bne       L46D0
                    lbsr      L4840
                    lbra      L4763
L46D0               lbsr      L4769
                    ldb       >$3372
                    lslb
                    ldx       #$07B6
                    ldd       b,x
                    std       <u0085
                    ldd       #$2CA5
                    std       <u0087
                    lbsr      L477C
                    lbsr      L28F0
                    ldb       >$3372
                    subb      #$1C
                    lslb
                    lslb
                    ldy       #$0818
                    leay      b,y
                    ldd       ,y++
                    sta       <u0091
                    stb       <u0092
                    ldd       ,y
                    sta       <u008F
                    stb       <u0090
                    mul
                    addd      #$2CA5
                    std       <u007F
                    lda       #$37
                    ldu       #$577E
                    lbsr      L47AB
                    ldb       >$3373
                    lslb
                    ldx       #$07B6
                    ldd       b,x
                    std       <u0085
                    ldd       #$2CA5
                    std       <u0087
                    lbsr      L477C
                    lbsr      L28F0
                    ldb       >$3373
                    subb      #$10
                    lslb
                    lslb
                    ldy       #$0848
                    leay      b,y
                    ldd       ,y++
                    sta       <u0091
                    stb       <u0092
                    ldd       ,y
                    sta       <u008F
                    stb       <u0090
                    mul
                    addd      #$2CA5
                    std       <u007F
                    ldu       #$577E
                    lda       #$37
                    lbsr      L47AB
                    ldd       #$55C6
                    std       <u007F
                    ldd       #$3726
                    sta       <u008F
                    stb       <u0090
                    ldd       #$0E38
                    sta       <u0091
                    stb       <u0092
                    lbsr      L4789
L4763               clr       >$3379
                    lbra      L450D
L4769               ldy       #$400A
                    ldu       #$55C6
                    ldx       #$0415
L4773               ldd       ,y++
                    std       ,u++
                    leax      -$01,x
                    bne       L4773
                    rts
L477C               ldd       #$000E
                    std       >$3453
                    ldd       #$0D0F
                    std       >$3455
                    rts
L4789               ldy       <u007F
                    ldb       <u0092
                    lbsr      L2180
                    ldb       <u0091
                    leau      b,u
L4795               ldb       <u008F
                    decb
L4798               lda       b,y
                    sta       b,u
                    decb
                    bpl       L4798
                    lda       <u008F
                    leay      a,y
                    leau      <u0050,u
                    dec       <u0090
                    bne       L4795
                    rts
L47AB               pshs      a
                    ldy       <u007F
                    ldb       <u0091
                    leau      b,u
L47B4               pshs      u
                    ldb       <u008F
                    decb
L47B9               lda       ,-y
                    beq       L47DB
                    anda      #$F0
                    beq       L47CB
                    pshs      a
                    lda       ,u
                    anda      #$0F
                    ora       ,s+
                    sta       ,u
L47CB               lda       ,y
                    anda      #$0F
                    beq       L47DB
                    pshs      a
                    lda       ,u
                    anda      #$F0
                    ora       ,s+
                    sta       ,u
L47DB               leau      u0001,u
                    decb
                    bpl       L47B9
                    puls      u
                    lda       ,s
                    leau      a,u
                    dec       <u0090
                    bne       L47B4
                    puls      a
                    rts
L47ED               lda       #$99
                    lbsr      L45DB
                    lda       #$20
                    sta       >$366D
L47F7               ldb       #$10
                    subb      >$366D
                    bcc       L47FF
                    negb
L47FF               lsrb
                    lsrb
                    negb
                    addb      #$30
                    lbsr      L4634
                    lbsr      L4694
                    ldd       #$03DC
                    lbsr      L36E4
                    lbsr      L483C
                    lbsr      L484C
                    ldd       #$03E7
                    lbsr      L36E4
                    lbsr      L483C
                    lbsr      L484C
                    ldd       #$03DC
                    lbsr      L36E4
                    lbsr      L483C
                    lbsr      L484C
                    ldd       #$03E7
                    lbsr      L36E4
                    dec       >$366D
                    bne       L47F7
                    lbra      L4581
L483C               ldy       #$0001
L4840               ldx       #$01F4
L4843               leax      -$01,x
                    bne       L4843
                    leay      -$01,y
                    bne       L4840
                    rts
L484C               lda       >$3404
                    lbeq      L5A4A
                    rts
L4854               ldx       #$0000
                    lda       #$FF
                    sta       <u008F
                    bsr       L486E
                    ldx       #$0011
                    bra       L486E
L4862               ldx       #$0000
                    lda       #$99
                    sta       <u008F
                    bsr       L486E
                    ldx       #$0011
L486E               tfr       x,d
                    lbsr      L2180
                    ldx       #$0028
                    lda       <u008F
                    ldb       <u008F
L487A               std       ,u++
                    leax      -$01,x
                    bne       L487A
                    rts
L4881               lda       >$33ED
                    cmpa      #$F0
                    bne       L488E
                    lbsr      L18CE
                    lbra      L48CE
L488E               lda       #$22
                    sta       <u008B
L4892               lda       <u008B
                    sta       >$34AA
                    ldb       #$5F
                    stb       <u0089
                    lbsr      L2180
                    ldy       #$050A
L48A2               ldb       #$4F
L48A4               lda       >$34AA
                    lda       a,y
                    sta       ,u+
                    inc       >$34AA
                    tst       >$34AA
                    bpl       L48B8
                    lda       >$3404
                    bne       L48B8
L48B8               decb
                    bpl       L48A4
                    inc       >$34AA
                    inc       >$34AA
                    inc       >$34AA
                    dec       <u0089
                    bne       L48A2
                    dec       <u008B
                    dec       <u008B
                    bne       L4892
L48CE               ldx       #$0005
L48D1               lbsr      L35A6
                    leax      -$01,x
                    cmpx      #$0000
                    bpl       L48D1
                    lbsr      L20A7
                    lbsr      L2088
                    ldb       #$5F
                    lbsr      L2180
                    ldx       #$0060
                    clra
L48EA               ldb       #$4F
L48EC               sta       ,u+
                    decb
                    bpl       L48EC
                    leax      -$01,x
                    bne       L48EA
                    lbsr      L49AD
                    ldd       #$0980
                    std       <u00A5
                    lbsr      L3762
                    ldd       #$098F
                    std       <u00A5
                    lbsr      L3762
                    ldb       #$08
                    lbsr      L1C91
                    lda       #$00
                    lbra      L5A4C
L4912               lda       #$FF
                    sta       >$33EE
                    lbsr      L18CE
                    ldd       #$2869
                    std       <u0083
                    lda       #$02
                    sta       <u00EB
                    tst       >$34AD
                    beq       L492D
                    clr       >$34AD
                    lda       #$0F
L492D               sta       <u00E9
                    lda       #$03
                    sta       <u00EF
                    lda       #$FF
                    sta       <u00EA
                    lda       >$3410
                    beq       L494B
                    lda       #$04
                    sta       <u00EB
                    sta       <u00E9
                    lda       #$01
                    sta       >$3396
                    lda       #$80
                    sta       <u00F6
L494B               lda       #$01
                    sta       <u00F7
                    rts
L4950               lda       #$02
                    ora       <u00E7
                    sta       >$33FA
                    sta       >$33FB
                    sta       >$33FC
                    sta       >$33FD
                    sta       >$33FE
                    sta       >$33FF
                    sta       >$39A0
                    lda       #$FF
                    sta       >$108E
                    sta       >$108F
                    clr       <u00F7
                    rts
L4974               sta       >$32D3
                    lbsr      L4A25
                    lbra      L063A
L497D               suba      >$32D2
                    bcc       L4983
                    clra
L4983               cmpa      #$63
                    bls       L498D
                    suba      #$63
                    bsr       L497D
                    lda       #$63
L498D               adda      >$32F8
                    sta       >$32F8
                    cmpa      #$64
                    bcs       L49AC
                    suba      #$64
                    sta       >$32F8
                    inc       >$32F9
                    lda       >$32F9
                    cmpa      #$64
                    bcs       L49AC
                    clr       >$32F9
                    inc       >$32FA
L49AC               rts
L49AD               ldd       #$098B
                    std       <u007F
                    bsr       L49BC
                    ldd       #$099A
                    std       <u007F
                    bsr       L49CB
                    rts
L49BC               clr       <u0081
                    clr       >$098B
                    clr       >$098C
                    lda       >$32D3
                    inca
                    bsr       L49FA
                    rts
L49CB               clr       <u0081
                    lda       #$20
                    ldb       #$07
                    ldy       <u007F
L49D4               sta       b,y
                    decb
                    bpl       L49D4
                    lda       >$32FA
                    bsr       L49FA
                    lda       >$32F9
                    bsr       L49FA
                    lda       <u0081
                    beq       L49F0
                    lda       #$2C
                    sta       ,y
                    leay      $01,y
                    sty       <u007F
L49F0               lda       >$32F8
                    bsr       L49FA
                    lda       #$30
                    sta       ,y
                    rts
L49FA               bsr       L4A19
                    pshs      b
                    bsr       L4A05
                    puls      a
                    bsr       L4A05
                    rts
L4A05               tst       <u0081
                    bne       L4A0E
                    cmpa      #$30
                    bne       L4A0E
                    rts
L4A0E               inc       <u0081
                    ldy       <u007F
                    sta       ,y+
                    sty       <u007F
                    rts
L4A19               ldb       #$2F
L4A1B               incb
                    suba      #$0A
                    bcc       L4A1B
                    adda      #$3A
                    exg       a,b
                    rts
L4A25               pshs      u,y,x
                    inca
                    cmpa      #$0A
                    blt       L4A3C
                    cmpa      #$14
                    bne       L4A36
                    ldb       #$32
                    suba      #$14
                    bra       L4A3E
L4A36               ldb       #$31
                    suba      #$0A
                    bra       L4A3E
L4A3C               ldb       #$30
L4A3E               stb       >$037F
                    adda      #$30
                    sta       >$0380
                    ldx       #$037A
                    clra
                    ldu       #$1E69
                    ldy       #$0A00
                    lbsr      L4A6C
                    ldy       #$211C
                    ldu       #$07C6
                    ldx       #$0008
L4A5E               sty       ,u++
                    ldd       ,y++
                    leay      d,y
                    leax      -$01,x
                    bne       L4A5E
                    puls      u,y,x
                    rts
L4A6C               std       <u0095
                    stu       <u0099
                    lsla
                    leau      >L4A80,pcr
                    ldd       a,u
                    leau      d,u
                    pshs      u
                    ldd       <u0095
                    ldu       <u0099
                    rts
L4A80               neg       <u000A
                    neg       <u0026
                    neg       <u0043
                    neg       <u0075
                    neg       <u00EA
                    sty       <u0095
                    stu       <u0099
                    lda       #READ.
                    os9       I$Open
                    bcs       L4AF5
                    ldy       <u0095
L4A99               ldx       <u0099
                    pshs      a
                    os9       I$Read
                    puls      a
                    os9       I$Close
                    rts
                    stu       <u0099
                    lda       #READ.
                    os9       I$Open
                    bcs       L4AF5
                    pshs      a
                    ldx       #$0347
                    ldy       #$0002
                    os9       I$Read
                    puls      a
                    ldy       >$0347
                    bra       L4A99
                    sty       <u0095
                    stu       <u0099
                    pshs      x
                    os9       I$Delete
                    puls      x
                    lda       #WRITE.
                    ldb       #SHARE.+PWRIT.+PREAD.+UPDAT.
                    os9       I$Create
                    bcs       L4AEC
                    sta       >$336E
                    ldx       <u0099
                    ldy       <u0095
                    os9       I$Write
                    bcs       L4AEC
                    lda       >$336E
                    os9       I$Close
                    rts
L4AEC               lda       #$12
                    sta       <u00E9
                    lda       #$FF
                    sta       <u00EA
                    rts
L4AF5               pshs      b
                    ldy       #$0000
                    lda       >$0100
                    ldb       #SS.DScrn
                    os9       I$SetStt            display screen
                    leay      >L0254,pcr
                    lbsr      L013D
                    bsr       L4B4C
                    lda       >$0100
                    ldb       #SS.FScrn
                    ldy       >$0101
                    os9       I$SetStt            free screen
                    puls      b
                    tstb
                    beq       L4B33
                    pshs      b
                    leax      >L4BAB,pcr
                    ldy       #$0008
                    lda       >$0100
                    os9       I$Write
                    puls      a
                    bsr       L4B84
                    bsr       L4B5B
L4B33               clra
                    tfr       a,dp
                    lds       #$00FF
                    leax      >Shell,pcr
                    ldy       #$0000
                    ldu       #$0000
                    lda       #$11
                    ldb       #$03
                    os9       F$Chain             chain to shell
L4B4C               leax      >L4BB9,pcr
                    ldy       #$0001
                    lda       >$0100
                    os9       I$Write
                    rts
L4B5B               leax      >L4BBA,pcr
                    ldy       #$0002
                    lda       >$0100
                    os9       I$Write
                    rts
L4B6A               ldd       #SS.Ready
                    os9       I$GetStt            check for ready from stdin
                    bcs       L4B83
                    ldx       #$0095
                    ldy       #$0001
                    lda       >$0100
                    os9       I$Read
                    lda       <u0095
                    andcc     #^Carry
L4B83               rts
L4B84               pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L4B90
                    puls      a
                    anda      #$0F
L4B90               cmpa      #$09
                    bhi       L4B98
                    ora       #$30
                    bra       L4B9A
L4B98               adda      #$37
L4B9A               sta       >$0347
                    ldx       #$0347
                    ldy       #$0001
                    lda       >$0100
                    os9       I$Write
                    rts
L4BAB               fcc       /ERROR # /
Shell               fcc       /SHELL/
                    fcb       C$CR
L4BB9               fcb       $0C
L4BBA               fcb       C$CR,C$LF
L4BBC               lda       #$02
                    ldu       #$0000
                    ldy       #$037A
                    leax      >Save1,pcr
                    lbsr      L4A6C
                    lda       #$02
                    ldu       #$2869
                    ldy       #$1196
L4BD5               leax      >Save2,pcr
                    lbsr      L4A6C
                    clr       >$34AB
                    rts
L4BE0               lda       >$0371
                    pshs      a
                    lbsr      L2088
                    lbsr      L20A7
                    clra
                    ldu       #$0000
                    ldy       #$037A
                    leax      >Save1,pcr
                    lbsr      L4A6C
                    clra
                    ldu       #$2869
                    ldy       #$1196
                    leax      >Save2,pcr
                    lbsr      L4A6C
                    ldx       #$0005
L4C0C               tfr       x,d
                    pshs      b
                    lda       >$31E5,x
                    cmpa      #$FF
                    bne       L4C1D
                    lbsr      L35A6
                    bra       L4C22
L4C1D               lda       #$EE
                    lbsr      L51D1
L4C22               ldb       ,s+
                    clra
                    tfr       d,x
                    leax      -$01,x
                    decb
                    bpl       L4C0C
                    lda       #$03
                    sta       <u00EF
                    clr       >$34AB
                    clr       >$33BA
                    lda       >$32D2
                    lbsr      L4A25
                    lbsr      L208C
                    puls      a
                    sta       >$0371
                    lbsr      L068B
                    lbra      L20A3
Save1               fcc       /SAVE1/
                    fcb       C$CR
Save2               fcc       /SAVE2/
                    fcb       C$CR
L4C56               fcb       $00,$00             SAVE2...
L4C58               fcb       $00,$00,$00,$00,$00,$00,$FF,$BF .......?
L4C60               fcb       $01,$0F,$DF,$8F,$07,$FF,$FF,$C3 .._....C
L4C68               fcb       $BD,$66,$66,$BD,$C3,$FF,$E7,$DB =ff=C.g[
L4C70               fcb       $DB,$99,$A5,$24,$42,$FF,$FF,$F7 [.%$B..w
L4C78               fcb       $FB,$FC,$54,$FC,$FB,$F7,$E7,$FF ..T..wg.
L4C80               fcb       $E7,$00,$3C,$99,$C3,$E7,$FF,$EF g.<.Cg.o
L4C88               fcb       $EF,$01,$83,$C7,$AB,$FF,$FF,$83 o..G+...
L4C90               fcb       $BB,$B9,$B9,$BB,$83,$FF,$FF,$E3 ;99;...c
L4C98               fcb       $F7,$B6,$88,$B6,$F7,$E3,$FF,$DB w6.6wc.[
L4CA0               fcb       $BD,$00,$BD,$DB,$FF,$FF,$00,$7E =.=[...~
L4CA8               fcb       $5E,$5A,$7E,$3E,$66,$00,$FF,$FF ^Z~>f...
L4CB0               fcb       $E7,$81,$7E,$81,$C3,$FF,$7E,$7E g.~.C.~~
L4CB8               fcb       $42,$42,$42,$7E,$5A,$7E,$C3,$E7 BBB~Z~Cg
L4CC0               fcb       $E7,$81,$81,$81,$81,$FF,$34,$04 g.....4.
L4CC8               fcb       $A6,$89,$32,$57,$B7,$34,$2A,$A6 &.2W74*&
L4CD0               fcb       $89,$32,$5D,$B7,$34,$28,$1F,$10 .2]74(..
L4CD8               fcb       $F7,$34,$26,$35,$84,$7F,$34,$2A w4&5.^?4*
L4CE0               fcb       $39

L4CE1               clr       >$3425
                    lda       >$342A
                    bne       L4CF7
                    lda       <u00C8
                    sta       >$3424
                    lda       >$34DF
                    beq       L4CF6
                    inc       >$3425
L4CF6               rts
L4CF7               cmpa      #$01
                    bne       L4D1E
                    ldy       #$0008
L4CFF               lda       >$345A,y
                    beq       L4D19
                    lda       >$1F83,y
                    cmpa      >$3428
                    bne       L4D19
                    lda       >$34D5,y
                    sta       >$3424
                    inc       >$3425
                    rts
L4D19               leay      -$01,y
                    bne       L4CFF
                    rts
L4D1E               cmpa      #$02
                    bne       L4D2C
                    lda       >$3427
                    sta       >$3424
                    inc       >$3425
                    rts
L4D2C               inc       >$3425
                    cmpa      #$03
                    beq       L4D37
                    clr       >$3425
                    rts
L4D37               clr       >$3429
                    ldx       #$0001
L4D3D               lda       $0E,x
                    beq       L4D64
                    lda       <$12,x
                    bne       L4D64
                    clra
                    ldb       >$33E0,x
                    tfr       d,y
                    ldb       >$091E,y
                    addb      >$3426
                    tfr       d,y
                    lda       >$325D,y
                    beq       L4D64
                    tfr       x,d
                    addb      >$3429
                    stb       >$3429
L4D64               leax      $01,x
                    cmpx      #$0003
                    bne       L4D3D
                    lda       >$3429
                    cmpa      #$03
                    bne       L4D84
                    lda       #$01
                    sta       >$3429
                    lda       >$39A7
                    cmpa      >$39A5
                    bls       L4D84
                    lda       #$02
                    sta       >$3429
L4D84               ldb       >$3429
                    decb
                    bpl       L4D8F
                    clr       >$3425
                    bra       L4D99
L4D8F               clra
                    tfr       d,x
                    lda       >$00C6,x
                    sta       >$3424
L4D99               rts
L4D9A               lda       >$33B5
                    beq       L4DA6
                    lda       <u00F6
                    beq       L4DA7
                    clr       >$3442
L4DA6               rts
L4DA7               inca
                    sta       >$3442
                    clr       >$3443
                    ldu       #$00CD
                    ldy       #$0012
                    ldb       #$01
L4DB7               ldx       #$000E
                    lda       b,x
                    beq       L4DE4
                    lda       b,u
                    beq       L4DE4
                    lda       b,y
                    bne       L4DE4
                    ldx       #$33E0
                    lda       b,x
                    ldx       #$091E
                    lda       a,x
                    adda      >$3444
                    ldx       #$3257
                    lda       a,x
                    beq       L4DE4
                    pshs      b
                    addb      >$3443
                    stb       >$3443
                    puls      b
L4DE4               incb
                    cmpb      #$03
                    bne       L4DB7
                    lda       >$3443
                    cmpa      #$03
                    bne       L4E00
                    lda       #$01
                    sta       >$3443
                    lda       <u00CB
                    cmpa      <u00CA
                    bls       L4E00
                    lda       #$02
                    sta       >$3443
L4E00               ldb       >$3443
                    decb
                    bpl       L4E08
                    clra
                    rts
L4E08               pshs      b
                    ldy       #$344E
                    lda       b,y
                    lsra
                    pshs      a
                    ldu       #$00D2
                    leau      b,u
                    ldx       #$00CE
                    lda       b,x
                    cmpa      #$58
                    bcs       L4E29
                    cmpa      #$A8
                    bcs       L4E2B
                    lda       #$A8
                    bra       L4E2B
L4E29               lda       #$58
L4E2B               suba      #$58
                    lsla
                    adda      ,s+
                    tfr       a,b
                    clra
                    tfr       d,y
                    puls      a
                    ldx       #$3450
                    ldb       a,x
                    lsrb
                    addb      ,u
                    subb      #$4C
                    clra
                    tfr       d,x
                    lda       #$80
                    rts
                    pshs      u,y,x,b,a
                    tfr       x,d
                    ldx       #$3257
                    lda       b,x
                    sta       >$3446
                    ldu       #$32F0
                    ldx       #$325D
                    ldy       #$32D8
                    cmpa      #$01
                    bne       L4E82
                    lda       b,x
                    leau      a,u
                    lda       ,u
                    bne       L4E74
L4E69               clr       >$3446
                    ldb       >$3445
                    lbsr      L50D3
L4E72               puls      pc,u,y,x,b,a
L4E74               stb       >$3445
                    deca
                    sta       ,u
                    lda       b,x
                    ldd       a,y
                    std       <u00F8
                    bra       L4E72
L4E82               cmpa      #$02
                    bne       L4E99
                    lda       b,x
                    leay      a,y
                    lda       ,y
                    ora       $01,y
                    beq       L4E69
                    stb       >$3445
                    ldd       ,y
                    std       <u00F8
                    bra       L4E72
L4E99               stb       >$3445
                    bra       L4E72
                    pshs      b
                    lda       >$3446
                    beq       L4EBC
                    lda       >$3257,x
                    cmpa      #$02
                    bne       L4EB9
                    ldb       >$325D,x
                    clra
                    tfr       d,y
                    ldd       <u00F8
                    std       >$32D8
L4EB9               clr       >$3446
L4EBC               puls      pc,b
L4EBE               lda       >$3446
                    bne       L4EC4
                    rts
L4EC4               ldd       <u00F8
                    bne       L4ECE
                    ldb       >$3445
                    lbra      L50D3
L4ECE               clra
                    ldb       >$3445
                    tfr       d,x
                    lda       >$323F,x
                    coma
                    ldb       >$335F
                    lbsr      L1304
                    sta       >$335F
                    rts
L4EE3               ldb       <u00BE
                    subb      #$48
                    bcc       L4EED
                    lda       #$FF
                    bra       L4EF2
L4EED               tfr       b,a
                    lsra
                    lsra
                    lsra
L4EF2               sta       >$3362
                    andb      #$07
                    stb       >$3361
                    clra
                    ldb       <u00C0
                    subb      #$07
                    stb       >$3363
                    bcc       L4F05
                    clrb
L4F05               lslb
                    lslb
                    lslb
                    rola
                    pshs      u
                    ldu       #$1F9C
                    leau      d,u
                    stu       <u007D
                    puls      u
                    clrb
L4F15               stb       >$3364
                    lda       >$3363
                    cmpa      #$30
                    bcc       L4F49
                    ldb       >$3362
                    bsr       L4F7C
                    sta       >$3365
                    bsr       L4F7C
                    sta       >$3366
                    lda       >$3361
                    beq       L4F40
                    bsr       L4F7C
                    ldb       >$3361
L4F36               lsla
                    rol       >$3366
                    rol       >$3365
                    decb
                    bne       L4F36
L4F40               ldd       <u007D
                    addd      #$0008
                    std       <u007D
                    bra       L4F51
L4F49               lda       #$FF
                    sta       >$3365
                    sta       >$3366
L4F51               inc       >$3363
                    ldb       >$3364
                    lda       >$3365
                    bsr       L4F89
                    lda       >$3366
                    bsr       L4F89
                    cmpb      #$80
                    bcs       L4F15
                    lda       #$00
                    sta       >$1274
                    lda       #$06
                    sta       >$32B8
                    lda       #$FF
                    sta       >$32B2
                    bsr       L4FD3
                    lda       #$01
                    lbsr      L36BC
                    rts
L4F7C               ldu       <u007D
                    clra
                    lda       d,u
                    cmpb      #$08
                    bcs       L4F87
                    lda       #$FF
L4F87               incb
                    rts
L4F89               sta       >$3CE0
                    ldy       #$0004
                    clra
                    tfr       d,x
L4F93               lda       #$EE
                    lsl       >$3CE0
                    bcc       L4F9C
                    lda       #$FE
L4F9C               lsl       >$3CE0
                    bcc       L4FA3
                    ora       #$EF
L4FA3               sta       >$1230,x
                    incb
                    leax      $01,x
                    leay      -$01,y
                    bne       L4F93
                    rts
                    pshs      u,y,x,b,a
                    ldx       #$0002
                    lbsr      L18E4
                    lda       #$01
                    sta       >$3447
                    puls      pc,u,y,x,b,a
                    clr       >$3447
                    clr       >$32B8
                    lda       #$FF
                    sta       >$32B2
                    pshs      u,y,x,b,a
                    ldx       #$0002
                    lbsr      L1906
                    puls      pc,u,y,x,b,a
L4FD3               ldy       #$1230
                    ldb       #$A9
                    lbsr      L218E
                    leau      <u0010,u
                    ldx       #$0010
L4FE2               ldb       #$08
L4FE4               lda       ,y+
                    sta       ,u+
                    decb
                    bne       L4FE4
                    leau      <-u0058,u
                    leax      -$01,x
                    bne       L4FE2
                    rts
L4FF3               fcb       $02,$BD,$02,$BE,$03 &p9.=.>.
                    fcb       $35,$03,$0C,$03,$26,$03,$74,$FC 5...&.t.
                    fcb       $D3,$02,$F1,$03,$7A,$03,$8A,$FF S.q.z...
                    fcb       $BC,$FE,$54,$03,$9E,$03,$AC
L500F               fcb       $02                 <.T...,.
                    fcb       $A1,$02,$CC,$03,$41,$03,$01,$03 !.L.A...
                    fcb       $13,$03,$58,$FC,$CE,$02,$E4,$03 ..X.N.d.
                    fcb       $67,$03,$7C,$FF,$AF,$FE,$8F,$03 g.|./...
                    fcb       $8F,$03,$96,$02,$85,$02,$83
L502F               ldu       #$32A5
                    lda       b,u
                    lbne      L50D3
L5038               pshs      u,b,a
                    ldu       #$31E5
                    lda       b,u
                    cmpa      #$FF
                    bne       L5045
                    puls      pc,u,b,a
L5045               clra
                    tfr       d,x
                    ldu       #$32A5
                    lda       b,u
                    bne       L5077
                    ldu       #$324B
                    lda       b,u
                    beq       L5072
                    lbsr      L5120
                    ldu       #$324B
                    lda       b,u
                    ldu       #$32B7
                    sta       >$32B7,y
                    tfr       y,d
                    tfr       b,a
                    ldb       $01,s
                    ldu       #$32AB
                    sta       b,u
                    bra       L5077
L5072               ldu       #$32AB
                    clr       b,u
L5077               pshs      x
                    lbsr      L358F
                    puls      x
                    lda       #$FF
                    sta       >$33E7
                    ldu       #$322D
                    lda       b,u
                    stb       >$33B4
                    ldu       #$33A4
                    ldb       a,u
                    bmi       L5099
                    pshs      x,b,a
                    lbsr      L50D3
                    puls      x,b,a
L5099               ldb       >$33B4
                    ldu       #$322D
                    lda       b,u
                    ldu       #$33A4
                    stb       a,u
                    lda       #$01
                    ldu       #$32A5
                    sta       b,u
                    ldu       #$31F1
                    lda       b,u
                    sta       >$32C3
                    ldu       #$31EB
                    lda       b,u
                    sta       >$32C2
                    puls      u,b,a
                    stu       <u0099
                    std       <u0095
                    ldd       >$32C2
                    leau      >L4FF3,pcr
                    leau      d,u
                    pshs      u
                    ldd       <u0095
                    ldu       <u0099
                    rts
L50D3               pshs      b,a
                    clra
                    tfr       d,x
                    lda       >$31E5,x
                    cmpa      #$FF
                    bne       L50E2
                    puls      pc,b,a
L50E2               lda       >$32A5,x
                    beq       L511E
                    lbsr      L358B
                    lda       #$FF
                    sta       >$33E7
                    ldu       #$322D
                    ldb       b,u
                    lda       #$FF
                    ldu       #$33A4
                    sta       b,u
                    ldb       $01,s
                    ldu       #$32A5
                    clr       b,u
                    ldu       #$31FD
                    lda       b,u
                    sta       >$32C3
                    ldu       #$31F7
                    lda       b,u
                    ldb       >$32C3
                    leau      >L500F,pcr
                    leau      d,u
                    puls      b,a
                    pshs      u
                    rts
L511E               puls      pc,b,a
L5120               pshs      b
                    ldb       #$05
                    ldy       #$32B7
L5128               lda       b,y
                    bne       L5131
                    clra
                    tfr       d,y
                    puls      pc,b
L5131               decb
                    bpl       L5128
                    lbsr      L514A
                    ldu       #$32AB
                    stb       ,s
                    lda       b,u
                    sta       <u0096
                    clr       <u0095
                    lbsr      L50D3
                    ldy       <u0095
                    puls      pc,b
L514A               clr       >$32BF
                    pshs      u,y,x
                    ldb       #$05
                    ldu       #$32A5
                    ldx       #$32AB
                    ldy       #$3227
L515B               lda       b,u
                    beq       L5170
                    lda       b,x
                    bmi       L5170
                    lda       b,y
                    cmpa      >$32BF
                    bcs       L5170
                    sta       >$32BF
                    stb       >$32BE
L5170               decb
                    bpl       L515B
                    ldb       >$32BE
                    puls      pc,u,y,x
L5178               pshs      b
                    ldb       #$20
                    mul
                    ldy       #$1E69
                    leay      d,y
                    ldx       #$31E5
                    ldb       ,s
                    abx
                    ldb       #$20
L518B               lda       ,y+
                    sta       ,x
                    leax      $06,x
                    decb
                    bne       L518B
                    puls      b
L5196               pshs      b
                    ldx       #$31EB
                    leax      b,x
                    ldy       #$31F1
                    leay      b,y
                    ldb       ,y
                    lslb
                    leau      >L4FF3,pcr
                    ldd       b,u
                    sta       ,x
                    stb       ,y
                    ldb       ,s
                    ldx       #$31F7
                    leax      b,x
                    ldy       #$31FD
                    leay      b,y
                    ldb       ,y
                    lslb
                    leau      >L500F,pcr
                    ldd       b,u
                    sta       ,x
                    stb       ,y
                    puls      b
                    lda       #$EE
                    lbra      L51D1
L51D1               pshs      b
                    sta       >$3CE2
                    lbsr      L35D4
                    lbsr      L36E6
                    puls      b
                    lbsr      L35FF
                    lbra      L36E6
L51E4               pshs      b
                    ldb       #$07
                    ldu       #$32CB
L51EB               lda       ,u+
                    sta       ,u
                    leau      -u0002,u
                    decb
                    cmpb      >$32CD
                    bhi       L51EB
                    ldb       #$07
                    ldu       #$30E5
L51FC               stb       >$32CE
                    lda       #$20
                    mul
                    lda       d,u
                    cmpa      #$FF
                    beq       L5211
                    ldb       >$32CE
                    decb
                    bpl       L51FC
                    lbra      L4AF5
L5211               ldx       #$31E5
                    ldy       #$30E5
                    clra
                    leay      d,y
                    ldb       ,s
                    abx
                    ldb       #$20
L5220               lda       ,x
                    sta       ,y+
                    leax      $06,x
                    decb
                    bne       L5220
                    ldb       >$32CD
                    lda       >$32CE
                    ldu       #$32C5
                    sta       b,u
                    puls      b
                    lda       #$FF
                    ldu       #$31E5
                    sta       b,u
                    clra
                    tfr       d,x
                    lbra      L35A6
L5243               pshs      y,b
                    ldb       >$32CD
                    ldx       #$32C5
                    lda       b,x
                    pshs      a
                    abx
L5250               lda       $01,x
                    sta       ,x+
                    incb
                    cmpb      #$07
                    bcs       L5250
                    puls      b
                    lda       #$20
                    mul
                    ldy       #$30E5
                    leay      d,y
                    pshs      y
                    ldx       #$31E5
                    ldb       $02,s
                    abx
                    ldb       #$20
L526E               lda       ,y+
                    sta       ,x
                    leax      $06,x
                    decb
                    bne       L526E
                    puls      y
                    lda       #$FF
                    sta       ,y
                    lda       #$FF
                    sta       >$32CC
                    puls      y,b
                    lda       #$EE
                    lbra      L51D1
L5289               pshs      y,x,b
                    ldb       >$32CD
                    ldx       #$32C5
                    abx
                    lda       ,x
                    pshs      a
L5296               lda       $01,x
                    sta       ,x+
                    incb
                    cmpb      #$07
                    bcs       L5296
                    puls      b
                    lda       #$20
                    mul
                    ldy       #$30E5
                    leay      d,y
                    lda       #$FF
                    sta       ,y
                    puls      pc,y,x,b
                    rts
                    pshs      x
                    ldx       #$3245
                    lda       b,x
                    sta       >$3348
                    ldx       #$323F
                    lda       b,x
                    sta       >$3349
                    ldx       #$3239
                    lda       b,x
                    sta       >$33E3
                    ldx       #$08ED
                    lda       a,x
                    sta       >$334F
                    lda       #$FF
                    sta       >$33E6
                    puls      x
                    rts
                    lda       #$02
                    sta       >$334F
                    clr       >$3348
                    rts
                    ldu       #$3245
                    lda       b,u
                    sta       >$33C6
                    cmpa      <u00E6
                    bcc       L52F2
                    sta       <u00E6
L52F2               rts
                    lda       #$10
                    sta       >$33C6
                    cmpa      <u00E6
                    bcc       L52FE
                    sta       <u00E6
L52FE               rts
                    ldu       #$323F
                    lda       b,u
                    sta       >$340C
                    ldu       #$3245
                    lda       b,u
                    sta       >$340B
                    rts
                    lda       #$0A
                    sta       >$340B
                    sta       >$340C
                    rts
                    ldu       #$323F
                    lda       b,u
                    sta       >$3335
                    rts
                    lda       #$40
                    sta       >$3335
                    rts
                    ldu       #$3245
                    lda       b,u
                    sta       >$340D
                    ldu       #$323F
                    lda       b,u
                    sta       >$340E
                    pshs      y,b
                    ldu       #$3257
                    leau      b,u
                    ldy       #$3340
                    ldb       #$05
L5345               lda       ,u
                    sta       ,y+
                    leau      u0006,u
                    decb
                    bpl       L5345
                    puls      pc,y,b
                    pshs      b,a
                    ldd       #$0000
                    std       >$3340
                    std       >$3342
                    std       >$3344
                    sta       >$340D
                    sta       >$340E
                    puls      b,a
                    rts
                    lda       #$FF
                    sta       >$33E8
                    rts
                    lda       #$FF
                    sta       >$33B5
                    stb       >$3444
                    rts
                    clr       >$33B5
                    clr       >$3442
                    rts
                    ldu       #$323F
                    lda       b,u
                    pshs      a
                    lsra
                    adda      ,s+
                    sta       >$3336
                    rts
                    lda       #$06
                    sta       >$3336
                    rts
                    pshs      u,b
                    ldu       #$3257
                    lda       b,u
                    lbsr      L5A4C
                    puls      u,b
                    rts
                    rts
                    lda       #$FF
                    sta       >$34AC
                    rts
                    clr       >$34AC
                    rts
L53A9               ldb       #$05
L53AB               lbsr      L50D3
                    decb
                    bpl       L53AB
                    rts
L53B2               lbra      L53BB
L53B5               lbra      L53DD
L53B8               lbra      L5605
L53BB               lda       #$04
                    lbsr      L4A6C
                    bcs       L53DC
                    cmpa      #$03
                    bne       L53CC
                    ldd       #$0300
                    lbra      L4A6C
L53CC               cmpa      #$73
                    bne       L53D0
L53D0               cmpa      #$20
                    bne       L53DC
                    lda       #$FF
                    eora      >$33EC
                    sta       >$33EC
L53DC               rts
L53DD               lda       >$33EE
                    beq       L53E7
                    lda       <u00F7
                    bne       L53E7
L53E6               rts
L53E7               lbsr      L4D9A
                    bmi       L540E
                    lda       >$33A3
                    bne       L53E6
                    lda       >$34B6
                    bne       L53E6
                    lda       #$39
                    lbsr      L36BC
                    lbsr      L55C6
                    lda       <u00F6
                    lbmi      L5481
                    lbne      L54ED
                    lda       <u00F7
                    lbne      L554E
L540E               tfr       x,d
                    tfr       b,a
                    cmpa      >$343C
                    bhi       L5421
                    adda      #$03
                    cmpa      >$343C
                    bls       L5421
                    lda       >$343C
L5421               adda      >$343C
                    rora
                    sta       >$343C
                    cmpa      #$5E
                    bcs       L542E
                    lda       #$5E
L542E               cmpa      #$0B
                    bhi       L5434
                    lda       #$0B
L5434               sta       >$3393
                    suba      >$3438
                    pshs      a
                    tfr       y,d
                    tfr       b,a
                    cmpa      >$343B
                    bhi       L544F
                    adda      #$03
                    cmpa      >$343B
                    bls       L544F
                    lda       >$343B
L544F               adda      >$343B
                    rora
                    sta       >$343B
                    cmpa      #$02
                    bcc       L545C
                    lda       #$02
L545C               cmpa      #$96
                    bls       L5462
                    lda       #$96
L5462               sta       >$3390
                    ldb       >$343A
                    suba      >$3439
                    ora       ,s+
                    beq       L5471
                    orb       #$81
L5471               stb       >$343A
                    lbsr      L214A
                    lda       #$01
                    sta       >$336B
                    andcc     #^Carry
                    lbra      L20EA
L5481               lda       <u00E8
                    anda      #$01
                    bne       L54A0
                    lda       >$3328
                    bpl       L54A0
L548C               clra
                    sta       <u00F6
                    sta       >$343A
                    lbsr      L2088
                    lbsr      L5A4A
                    lda       <u00F7
                    beq       L549F
                    lbsr      L4854
L549F               rts
L54A0               lda       >$337D
                    cmpa      #$28
                    lbcs      L568A
                    lda       <u00EF
                    cmpa      <u00EC
                    bcc       L54BC
                    lbsr      L2088
                    lda       <u00EF
                    sta       >$3431
                    sta       <u00EC
                    lbsr      L208C
L54BC               leay      >L54E9,pcr
                    lda       >$337B
                    ldb       #$03
L54C5               cmpa      b,y
                    bcc       L54CC
                    decb
                    bpl       L54C5
L54CC               cmpb      >$3431
                    bne       L54D2
                    rts
L54D2               stb       >$3431
                    cmpb      <u00EF
                    bls       L54DE
                    ldb       <u00EF
                    stb       >$3431
L54DE               lbsr      L2088
                    ldb       >$3431
                    stb       <u00EC
                    lbra      L208C
L54E9               fcb       $00,$04,$40,$7D
L54ED               lda       >$338D
                    beq       L54F3
                    rts
L54F3               lda       <u00E8
                    anda      #$01
                    bne       L5503
                    lda       <u00F5
                    bpl       L5503
                    lbsr      L56AA
                    lbra      L548C
L5503               lda       <u00F5
                    bmi       L5510
                    lda       >$337D
                    cmpa      #$48
                    lbcc      L567A
L5510               leay      >L56C9,pcr
                    lda       >$337B
                    ldb       #$05
L5519               cmpa      b,y
                    bcc       L5520
                    decb
                    bpl       L5519
L5520               cmpb      >$337E
                    beq       L554D
                    stb       >$337E
                    lda       <u00F7
                    beq       L5537
                    lbsr      L20A7
                    ldb       >$337E
                    stb       <u00ED
                    lbra      L20AB
L5537               lbsr      L56AA
                    ldb       >$337E
                    stb       >$338C
                    lda       <u00ED
                    pshs      a
                    stb       <u00ED
                    lbsr      L20AB
                    puls      a
                    sta       <u00ED
L554D               rts
L554E               lda       >$337D
                    cmpa      #$50
                    bcc       L5563
                    lbsr      L5A4A
                    lbsr      L4862
                    lda       #$80
                    sta       <u00F6
                    lbsr      L208C
L5562               rts
L5563               lda       >$33BC
                    ora       >$33BD
                    bne       L5562
                    lda       >$32D4
                    beq       L5562
                    lda       <u00E8
                    anda      #$08
                    bne       L5594
                    lda       >$32CD
                    beq       L558E
                    lda       >$33BA
                    beq       L5583
                    dec       >$32CD
L5583               lda       #$81
                    sta       >$33BC
                    lda       #$FF
                    sta       >$33B6
                    rts
L558E               lda       >$33BA
                    beq       L5583
                    rts
L5594               lda       <u00E8
                    anda      #$04
                    bne       L55C5
                    lda       >$32CD
                    inca
                    cmpa      >$32D4
                    bcc       L55B6
                    lda       >$33BA
                    beq       L55AB
                    inc       >$32CD
L55AB               lda       #$82
                    sta       >$33BC
                    lda       #$FF
                    sta       >$33B6
                    rts
L55B6               lda       >$33BA
                    bne       L55C5
                    lda       #$02
                    sta       >$33BC
                    lda       #$FF
                    sta       >$33B6
L55C5               rts
L55C6               ldd       #SS.Joy
                    ldx       #$0001
                    os9       I$GetStt            get joystick values
                    tfr       y,d
                    lslb
                    tfr       d,y
                    tfr       x,d
                    lda       #$05
                    mul
                    lsra
                    rorb
                    tfr       d,x
                    stx       >$337A
                    sty       >$337C
                    exg       x,y
                    lda       #$FF
                    cmpx      #$007C
                    bls       L55EF
                    anda      #$FE
L55EF               cmpx      #$0006
                    bcc       L55F6
                    anda      #$FD
L55F6               cmpb      #$91
                    bls       L55FC
                    anda      #$F7
L55FC               cmpb      #$06
                    bcc       L5602
                    anda      #$FB
L5602               sta       <u00E8
                    rts
L5605               lda       >$33EE
                    beq       L560E
                    lda       <u00F7
                    beq       L5641
L560E               lda       >$33BC
                    ora       >$33BD
                    bne       L5641
                    ldd       #SS.Joy
                    ldx       #$0001
                    os9       I$GetStt            get joystick values
                    tsta
                    beq       L5624
                    lda       #$01
L5624               eora      #$01
                    beq       L5631
                    lda       #$FF
                    sta       >$3328
                    clr       >$338D
                    rts
L5631               ldb       >$3328
                    bmi       L5642
                    lda       >$33A3
                    bne       L5641
                    lda       <u00F6
                    lbeq      L229D
L5641               rts
L5642               clr       >$3328
                    lda       <u00F6
                    beq       L5650
                    lbmi      L22B7
                    lbra      L22D1
L5650               clr       >$338D
                    lda       >$3393
                    cmpa      #$10
                    lbhi      L229D
                    lbsr      L5A4A
                    inc       >$338D
                    lda       <u00F7
                    beq       L566B
                    lbsr      L4862
                    bra       L5676
L566B               lbsr      L214A
                    clr       >$336B
                    lda       #$50
                    sta       >$3390
L5676               lda       <u00F5
                    bmi       L568D
L567A               lbsr      L214A
                    clr       >$336B
                    lda       #$80
                    sta       <u00F6
                    lbsr      L56AA
                    lbra      L208C
L568A               lbsr      L2088
L568D               lbsr      L214A
                    clr       >$336B
                    lda       #$01
                    sta       <u00F6
                    lbsr      L20A3
                    lda       <u00ED
                    cmpa      >$338C
                    lbeq      L20AB
                    lda       <u00F7
                    lbne      L20AB
                    rts
L56AA               lda       <u00F7
                    bne       L56B5
                    lda       <u00ED
                    cmpa      >$338C
                    bne       L56B8
L56B5               lbra      L20A3
L56B8               lda       <u00ED
                    pshs      a
                    lda       >$338C
                    sta       <u00ED
                    lbsr      L20A7
                    puls      a
                    sta       <u00ED
                    rts
L56C9               fcb       $00,$04,$20,$40,$5F,$7D
L56CF               fcb       $7B                 9.. @_}{
                    fcb       $7B,$7B,$7B,$7B,$7B,$72,$6B,$64 {{{{{rkd
                    fcb       $5E,$59,$54,$50,$4C,$49,$46,$43 ^YTPLIFC
                    fcb       $40,$3E,$3B,$39,$37,$35,$34,$32 @>;97542
                    fcb       $30,$2F,$2E,$2C,$2B,$2A,$29,$28 0/.,+*)(
                    fcb       $27,$26,$25,$24,$24,$23,$22,$21 '&%$$#"!
                    fcb       $21,$20,$1F,$1F,$1E,$1E,$1D,$1D ! ......
                    fcb       $1C,$1C,$1B,$1B,$1A,$1A,$19,$19 ........
                    fcb       $19,$18,$18,$18,$17,$17,$17,$16 ........
                    fcb       $16,$16,$15,$15,$15,$15,$14,$14 ........
                    fcb       $14,$14,$13,$13,$13,$13,$12,$12 ........
                    fcb       $12,$12,$12,$11,$11,$11,$11,$11 ........
                    fcb       $10,$10,$10,$10,$10,$10,$10,$0F ........
                    fcb       $0F,$0F,$0F,$0F,$0F,$0F,$0E,$0E ........
                    fcb       $0E,$0E,$0E,$0E,$0E,$0E,$0D,$0D ........
                    fcb       $0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D ........
                    fcb       $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C ........
                    fcb       $0C,$0C,$0C,$0B,$0B,$0B,$0B,$0B ........
                    fcb       $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B ........
                    fcb       $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A ........
                    fcb       $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A ........
                    fcb       $09,$09,$09,$09,$09,$09,$09,$09 ........
                    fcb       $09,$09,$09,$09,$09,$09,$09,$09 ........
                    fcb       $09,$09,$09,$09,$08,$08,$08,$08 ........
                    fcb       $08,$08,$08,$08,$08,$08,$08,$08 ........
                    fcb       $08,$08,$08,$00,$00,$00,$00,$00 ........
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
                    fcb       $00,$00,$00,$00,$00,$00,$00
L57CF               fcb       $00                 ........
                    fcb       $93,$50,$15,$7C,$1C,$25,$7C,$0C .P.|.%|.
                    fcb       $35,$7C,$94,$35,$78,$45,$74,$45 5|.5xEtE
                    fcb       $70,$4D,$6C,$4D,$68,$55,$64,$21 pMlMhUd!
                    fcb       $0E,$21,$64,$55,$64,$21,$0E,$21 .!dUd!.!
                    fcb       $64,$55,$64,$21,$0E,$21,$64,$9A dUd!.!d.
                    fcb       $41,$8A,$68,$46,$74,$16,$17,$16 A.hFt...
                    fcb       $74,$A5,$96,$1D,$9A,$81,$6C,$A5 t%....l%
                    fcb       $0A,$17,$0E,$85,$70,$A5,$96,$1D ....p%..
                    fcb       $9A,$81,$6C,$A5,$0A,$17,$0E,$85 ..l%....
                    fcb       $70,$A5,$96,$1D,$9A,$81,$6C,$A5 p%....l%
                    fcb       $96,$1D,$9A,$81,$6C,$A5,$96,$1D ....l%..
                    fcb       $9A,$81,$6C,$A5,$0A,$17,$0E,$85 ..l%....
                    fcb       $78,$36,$7C,$0C,$25,$7C,$14,$9A x6|.%|..
                    fcb       $11,$8A,$7C,$10,$26,$7C,$14,$26 ..|.&|.&
                    fcb       $7C,$14,$8A,$10,$8A,$7C,$10,$8A |....|..
                    fcb       $10,$8A,$7C,$10,$85,$10,$85,$7C ..|....|
                    fcb       $08,$A5,$96,$90,$A9,$85,$7C,$94 .%..).|.
                    fcb       $9A,$81,$A5,$96,$7C,$A0,$82,$8A ..%.| ..
                    fcb       $A8,$A0,$82,$38
L5864               fcb       $00,$B1,$58,$15     ( .8.1X.
                    fcb       $7C,$1C,$25,$7C,$0C,$35,$7C,$94 |.%|.5|.
                    fcb       $09,$16,$11,$78,$0D,$26,$0D,$74 ...x.&.t
                    fcb       $0D,$26,$0D,$70,$19,$16,$19,$6C .&.p...l
                    fcb       $4D,$68,$55,$64,$25,$9A,$21,$64 MhUd%.!d
                    fcb       $55,$64,$25,$9A,$21,$64,$55,$64 Ud%.!dUd
                    fcb       $25,$9A,$21,$64,$9A,$41,$8A,$68 %.!d.A.h
                    fcb       $46,$74,$16,$15,$16,$74,$A5,$96 Ft...t%.
                    fcb       $B5,$97,$A5,$96,$74,$A5,$96,$17 5.%.t%..
                    fcb       $A5,$96,$74,$A5,$96,$17,$A5,$96 %.t%..%.
                    fcb       $74,$A5,$96,$AF,$BE,$A5,$96,$74 t%./>%.t
                    fcb       $A5,$96,$AF,$BE,$A5,$96,$74,$A5 %./>%.t%
                    fcb       $96,$AF,$BE,$A5,$96,$74,$A5,$96 ./>%.t%.
                    fcb       $AF,$BE,$A5,$96,$74,$A5,$96,$17 />%.t%..
                    fcb       $A5,$96,$7C,$9A,$BD,$0F,$A5,$82 %.|.=.%.
                    fcb       $7C,$90,$A9,$AF,$96,$7C,$14,$9A |.)/.|..
                    fcb       $A9,$A5,$82,$7C,$0C,$26,$7C,$14 )%.|.&|.
                    fcb       $26,$7C,$14,$8A,$10,$8A,$7C,$10 &|....|.
                    fcb       $8A,$10,$8A,$7C,$10,$85,$10,$85 ...|....
                    fcb       $7C,$08,$A5,$96,$90,$A9,$85,$7C |.%..).|
                    fcb       $94,$9A,$81,$A5,$96,$7C,$A0,$12 ...%.| .
                    fcb       $A0,$12,$7C,$7C,$7C,$7C,$7C,$7C .||||||
                    fcb       $7C,$7C,$7C,$7C,$7C,$7C,$38
L5917               fcb       $FF
                    fcb       $C7,$AB,$6D,$01,$6D,$AB,$C7,$FF G+m.m+G.
                    fcb       $A5,$99,$A5,$A5,$99,$A5,$FF,$FF %.%%.%..
                    fcb       $EB,$C9,$94,$C9,$EB,$FF,$FF,$FF kI.Ik...
                    fcb       $AB,$29,$83,$C7,$EF,$EF,$FF,$FF +).Goo..
                    fcb       $EF,$D7,$AB,$D7,$EF,$EF,$FF,$FF oW+Woo..
                    fcb       $A5,$81,$BD,$BD,$DB,$E7,$FF,$FF %.==[g..
                    fcb       $99,$99,$E7,$E7,$99,$99,$FF,$FF ..gg....
                    fcb       $80,$BE,$D5,$EB,$C1,$80,$FF,$FF .>UkA...
                    fcb       $CF,$B1,$CF,$F3,$8D,$F3,$FF,$FF O1Os.s..
                    fcb       $81,$F3,$97,$E9,$CF,$81,$FF,$FF .s.iO...
                    fcb       $AB,$01,$AB,$C7,$EF,$FF,$FF,$FF +.+Go...
                    fcb       $E7,$5A,$3C,$5A,$E7,$FF,$FF,$FF gZ<Zg...
                    fcb       $83,$8D,$8D,$B1,$B1,$C1,$FF,$FF ...11A..
                    fcb       $80,$BE,$D5,$EB,$C1,$80,$FF,$FF .>UkA...
                    fcb       $9D,$B9,$F3,$E7,$CD,$99,$FF,$FF .9sgM...
                    fcb       $FF,$A7,$A3,$81,$B7,$FF,$FF,$FF .'#.7...
                    fcb       $BD,$C3,$E7,$BD,$C3,$E7,$FF,$FF =Cg=Cg..
                    fcb       $A5,$99,$A5,$A5,$99,$A5,$FF,$FF %.%%.%..
                    fcb       $E7,$FF,$A5,$81,$A5,$BD,$FF,$FF g.%.%=..
                    fcb       $BD,$89,$A5,$A5,$91,$BD,$FF,$FF =.%%.=..
                    fcb       $BD,$DB,$E7,$E7,$DB,$BD,$FF,$FF =[gg[=..
                    fcb       $C8,$88,$68,$42,$66,$6C,$FF,$FF H.hBfl..
                    fcb       $81,$EF,$85,$A1,$F7,$81,$FF,$FF .o.!w...
                    fcb       $FF,$E7,$99,$81,$99,$E7,$FF,$FF .g...g..
                    fcb       $99,$A5,$BD,$BD,$A5,$99,$FF,$FF .%==%...
                    fcb       $DB,$AB,$AB,$D5,$D5,$DB,$FF,$FF [++UU[..
                    fcb       $DF,$AF,$A1,$AB,$DB,$F5,$FF,$FF _/!+[u..
                    fcb       $93,$6D,$55,$55,$55,$6D,$93,$FF .mUUUm..
                    fcb       $99,$C3,$A5,$81,$DB,$E7,$FF,$FF .C%.[g..
                    fcb       $E1,$F1,$F9,$BD,$9F,$8F,$FF,$FF aqy=....
                    fcb       $EF,$D7,$AB,$AB,$C7,$EF,$FF,$FF oW++Go..
                    fcb       $E3,$DD,$EF,$F7,$F7,$FF,$F7,$FF c]oww.w.
                    fcb       $C7,$AB,$6D,$01,$6D,$AB,$C7

* These next two routines change the RS-232 line and can't have any use in the game.
* They do interfere with DW4 so I've changed them to toggle the single bit sound as
* that might just make some sense. Also no timing changes will result by switching to
* $FF22. RG
L5A1F               pshs      a
                    lda       >$FF22
                    anda      #$FD
                    sta       >$FF22
                    puls      a
                    rts
L5A2C               pshs      a
                    lda       >$FF22
                    ora       #$02
                    sta       >$FF22
                    puls      a
                    rts
* Needs Label
                    pshs      u,y,x,b,a,cc
                    ldy       #$0E00
                    ldx       #$2001
                    ldd       #$01*256+SS.Tone
                    os9       I$SetStt            play tone
                    puls      pc,u,y,x,b,a,cc
L5A4A               lda       #$04
L5A4C               pshs      u,y,x,b
                    sta       >$0346
                    lsla
                    leay      >L5AB2,pcr
                    ldd       a,y
                    leau      d,y
                    stu       >$0349
                    bra       L5A62
L5A5F               clr       >$0346
L5A62               ldu       >$0349
L5A65               tst       >$0346
                    bne       L5A7A
                    ldd       #SS.Joy
                    ldx       #$0001
                    pshs      u
                    os9       I$GetStt            get joystick values
                    puls      u
                    tsta
                    bne       L5AA0
L5A7A               ldy       ,u
                    beq       L5AA2
                    cmpy      #$0001
                    beq       L5AA0
                    cmpy      #$0002
                    beq       L5A5F
                    lda       >$036F
                    ldb       u0002,u
                    tfr       d,x
                    pshs      u
                    ldd       #$01*256+SS.Tone
                    os9       I$SetStt            play tone
                    puls      u
L5A9C               leau      u0003,u
                    bra       L5A65
L5AA0               puls      pc,u,y,x,b
L5AA2               ldb       u0002,u
                    beq       L5A9C
L5AA6               ldx       #$01F4
L5AA9               leax      -$01,x
                    bne       L5AA9
                    decb
                    bne       L5AA6
                    bra       L5A9C

L5AB2               fcb       $00,$B5,$01,$92,$00,$77 j.5...w
                    fcb       $00,$12,$01,$77,$01,$7C,$01,$81 ...w.|..
                    fcb       $01,$A9,$01,$AE,$0E,$52,$02,$0E .)...R..
                    fcb       $E1,$02,$0F,$0E,$02,$0E,$52,$02 a.....R.
                    fcb       $00,$00,$02,$0E,$E1,$02,$0E,$F1 ....a..q
                    fcb       $02,$0E,$96,$02,$0E,$52,$02,$0E .....R..
                    fcb       $E1,$02,$0E,$96,$02,$0E,$52,$02 a.....R.
                    fcb       $00,$00,$02,$0E,$E1,$02,$0E,$BD ....a..=
                    fcb       $02,$0E,$96,$02,$0E,$52,$02,$0E .....R..
                    fcb       $E1,$02,$0F,$0E,$02,$0E,$52,$02 a.....R.
                    fcb       $00,$00,$02,$0E,$E1,$02,$0E,$F1 ....a..q
                    fcb       $02,$0E,$96,$02,$0F,$29,$02,$00 .....)..
                    fcb       $00,$02,$0F,$0E,$02,$00,$00,$02 ........
                    fcb       $0E,$96,$05,$0E,$96,$02,$00,$00 ........
                    fcb       $05,$0F,$29,$02,$00,$00,$02,$00 ..).....
                    fcb       $01,$0F,$0E,$1E,$0E,$BD,$05,$0F .....=..
                    fcb       $0E,$05,$0F,$40,$14,$0F,$0E,$14 ...@....
                    fcb       $0F,$40,$1E,$0F,$0E,$05,$0F,$40 .@.....@
                    fcb       $05,$0F,$5F,$23,$00,$00,$05,$0F .._#....
                    fcb       $5F,$1E,$0F,$40,$05,$0E,$BD,$05 _..@..=.
                    fcb       $0F,$80,$14,$0F,$80,$14,$0F,$40 .......@
                    fcb       $1E,$0F,$00,$05,$0F,$40,$05,$0F .....@..
                    fcb       $5F,$23,$00,$00,$05,$00,$01,$0E _#......
                    fcb       $96,$0A,$0E,$81,$0A,$0E,$52,$0A ......R.
                    fcb       $0E,$96,$0A,$0E,$81,$0A,$0E,$52 .......R
                    fcb       $0A,$0E,$81,$0A,$0E,$96,$0A,$0E ........
                    fcb       $96,$0A,$0E,$81,$0A,$0E,$52,$0A ......R.
                    fcb       $0E,$96,$0A,$0E,$81,$0A,$0E,$52 .......R
                    fcb       $0A,$0E,$81,$0A,$0E,$96,$0A,$0E ........
                    fcb       $BD,$0A,$0E,$96,$0A,$0E,$81,$0A =.......
                    fcb       $0E,$BD,$0A,$0E,$96,$0A,$0E,$81 .=......
                    fcb       $0A,$0E,$96,$0A,$0E,$BD,$0A,$0E .....=..
                    fcb       $BD,$0A,$0E,$96,$0A,$0E,$81,$0A =.......
                    fcb       $0E,$BD,$0A,$0E,$96,$0A,$0E,$81 .=......
                    fcb       $0A,$0E,$96,$0A,$0E,$BD,$0A,$0E .....=..
                    fcb       $96,$0A,$0E,$81,$0A,$0E,$52,$0A ......R.
                    fcb       $0E,$96,$0A,$0E,$81,$0A,$0E,$52 .......R
                    fcb       $0A,$0E,$81,$0A,$0E,$96,$0A,$0E ........
                    fcb       $96,$0A,$0E,$81,$0A,$0E,$52,$0A ......R.
                    fcb       $0E,$96,$0A,$0E,$81,$0A,$0E,$52 .......R
                    fcb       $0A,$0E,$81,$0A,$0E,$96,$0A,$0E ........
                    fcb       $E1,$0A,$0E,$BD,$0A,$0E,$96,$0A a..=....
                    fcb       $0E,$E1,$0A,$0E,$BD,$0A,$0E,$96 .a..=...
                    fcb       $0A,$0E,$BD,$0A,$0E,$E1,$0A,$0E ..=..a..
                    fcb       $E1,$0A,$0E,$E1,$0A,$0E,$F1,$0A a..a..q.
                    fcb       $0E,$E1,$0A,$0E,$BD,$0A,$0E,$96 .a..=...
                    fcb       $0A,$0E,$52,$0A,$0E,$81,$0A,$00 ..R.....
                    fcb       $02,$0E,$F1,$01,$00,$01,$0D,$2C ..q....,
                    fcb       $02,$00,$01,$00,$13,$03,$00,$14 ........
                    fcb       $03,$00,$15,$03,$00,$14,$03,$00 ........
                    fcb       $13,$03,$00,$01,$0F,$46,$02,$0F .....F..
                    fcb       $40,$02,$0F,$5F,$02,$0F,$29,$02 @.._..).
                    fcb       $0F,$40,$02,$0F,$70,$02,$0F,$46 .@..p..F
                    fcb       $02,$00,$01,$0D,$2C,$02,$00,$01 ....,...
                    fcb       $0D,$55,$02,$00,$01

                    emod
eom                 equ       *
                    end
