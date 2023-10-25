********************************************************************
* RBF - Disk file manager
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  24      1985/??/??
* From Tandy OS-9 Level One VR 02.00.00
*
*  25      2003/10/07  Rodney V. Hamilton
* Fix for LSN0 DD.TOT=0 lockout problem
*
*  26      2005/11/26  Boisy G. Pitre
* Added SS.FDInf which is now used by dir -e

                    nam       RBF
                    ttl       Disk file manager

* Disassembled 98/08/23 18:26:52 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       FlMgr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       26

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       0
size                equ       .

name                fcs       /RBF/
                    fcb       edition

*L0011    fcb   DRVMEM

* All routines are entered with
* (Y) = Path descriptor pointer
* (U) = Caller's register stack pointer
start               lbra      Create
                    lbra      Open
                    lbra      MakDir
                    lbra      ChgDir
                    lbra      Delete
                    lbra      Seek
                    lbra      Read
                    lbra      Write
                    lbra      ReadLn
                    lbra      WriteLn
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Close

Create              pshs      y
                    leas      -$05,s              make room on the stack
                    lda       R$B,u               get perms
                    anda      #^DIR.              mask off dir bit
                    sta       R$B,u               save perms back
                    lbsr      L061D
                    bcs       L004A
                    ldb       #$DA
L004A               cmpb      #$D8
                    bne       L0072
                    cmpa      #PDELIM
                    beq       L0072
                    pshs      x
                    ldx       PD.RGS,y
                    stu       R$X,x
                    ldb       <PD.SBP,y
                    ldx       <PD.SBP+1,y
                    lda       <PD.SSZ,y
                    ldu       <PD.SSZ+1,y
                    pshs      u,x,b,a
                    clra
                    ldb       #$01
                    lbsr      L0966
                    bcc       L0077
                    leas      $06,s
L0070               leas      $02,s
L0072               leas      $05,s
                    lbra      L027F
L0077               std       $0B,s
                    ldb       <PD.SBP,y
                    ldx       <PD.SBP+1,y
                    stb       $08,s
                    stx       $09,s
                    puls      u,x,b,a
                    stb       <PD.SBP,y
                    stx       <PD.SBP+1,y
                    sta       <PD.SSZ,y
                    stu       <PD.SSZ+1,y
                    ldd       <PD.DCP,y
                    std       $0B,y
                    ldd       <PD.DCP+2,y
                    std       $0D,y
                    lbsr      L079C
                    bcs       L00A9
L00A0               tst       ,x
                    beq       L00BB
                    lbsr      L0787
                    bcc       L00A0
L00A9               cmpb      #$D3
                    bne       L0070
                    ldd       #$0020
                    lbsr      L04C0
                    bcs       L0070
                    lbsr      L0243
                    lbsr      L079C
L00BB               leau      ,x
                    lbsr      L015C
                    puls      x
                    os9       F$PrsNam
                    bcs       L0072
                    cmpb      #$1D
                    bls       L00CD
                    ldb       #$1D
L00CD               clra
                    tfr       d,y
                    lbsr      L04F2
                    tfr       y,d
                    ldy       $05,s
                    decb
                    lda       b,u
                    ora       #$80
                    sta       b,u
                    ldb       ,s
                    ldx       $01,s
                    stb       <$1D,u
                    stx       <$1E,u
                    lbsr      L0D40
                    bcs       L0144
                    ldu       $08,y
                    bsr       L0163
                    lda       #$04
                    sta       $0A,y
                    ldx       $06,y
                    lda       $02,x
                    sta       ,u
                    ldx       <$004B
                    ldd       $09,x
                    std       $01,u
                    lbsr      L0290
                    ldd       $03,u
                    std       $0D,u
                    ldb       $05,u
                    stb       $0F,u
                    ldb       #$01
                    stb       $08,u
                    ldd       $03,s
                    subd      #$0001
                    beq       L012A
                    leax      <$10,u
                    std       $03,x
                    ldd       $01,s
                    addd      #$0001
                    std       $01,x
                    ldb       ,s
                    adcb      #$00
                    stb       ,x
L012A               ldb       ,s
                    ldx       $01,s
                    lbsr      L0D42
                    bcs       L0144
                    lbsr      L0837
                    stb       <$34,y
                    stx       <$35,y
                    lbsr      L082B
                    leas      $05,s
                    lbra      L01C4
L0144               puls      u,x,a
                    sta       <$16,y
                    stx       <$17,y
                    clr       <$19,y
                    stu       <$1A,y
                    pshs      b
                    lbsr      L0B6E
                    puls      b
L0159               lbra      L027F
L015C               pshs      u,x,b,a
                    leau      <$20,u
                    bra       L0169
L0163               pshs      u,x,b,a
                    leau      >$0100,u
L0169               clra
                    clrb
                    tfr       d,x
L016D               pshu      x,b,a
                    cmpu      $04,s
                    bhi       L016D
                    puls      pc,u,x,b,a

Open                pshs      y
                    lbsr      L061D
                    bcs       L0159
                    ldu       PD.RGS,y
                    stx       R$X,u
                    ldd       <PD.FD+1,y
                    bne       L01B3
                    lda       <PD.FD,y
                    bne       L01B3
                    ldb       PD.MOD,y
                    andb      #DIR.
                    lbne      L027D
                    std       <PD.SBP,y
                    sta       <PD.SBP+2,y
                    std       <PD.SBL,y
                    sta       <PD.SBL+2,y
                    ldx       <PD.DTB,y
                    lda       DD.TOT+2,x
* resave nonzero DD.TOT here and recopy
OpenFix             equ       *
                    std       <PD.SIZ+2,y
                    sta       <PD.SSZ+2,y
                    ldd       DD.TOT,x
                    std       PD.SIZ,y
                    std       <PD.SSZ,y
* BUG FIX: handle special case of DD.TOT=0 in LSN0 which blocks
* all subsequent accesses.  NOTE: since we can only access LSN0
* for any non-zero value, set DD.TOT=1 to avoid NOT READY error.
                    bne       OpenRet             MSW nonzero, OK
                    lda       DD.TOT+2,x          MSW=0, check LSB
                    bne       OpenRet             LSB nonzero, OK
                    inca                          DD.TOT=0, make it 1
                    sta       DD.TOT+2,x          fix drive table
                    bra       OpenFix             and resave (B=0)
OpenRet             puls      pc,y                restore & return

L01B3               lda       PD.MOD,y
                    lbsr      L07F1
                    bcs       L0159
                    bita      #$02
                    beq       L01C4
                    lbsr      L0290
                    lbsr      L0D38
L01C4               puls      y
L01C6               clra
                    clrb
                    std       $0B,y
                    std       $0D,y
                    std       <$13,y
                    sta       <$15,y
                    sta       <$19,y
                    lda       ,u
                    sta       <$33,y
                    ldd       <$10,u
                    std       <$16,y
                    lda       <$12,u
                    sta       <$18,y
                    ldd       <$13,u
                    std       <$1A,y
                    ldd       $09,u
                    ldx       $0B,u
                    std       $0F,y
                    stx       <$11,y
                    clr       $0A,y
                    rts

MakDir              lbsr      Create
                    bcs       L0241
                    ldd       #$0040
                    std       <$11,y
                    bsr       L0253
                    bcs       L0241
                    lbsr      L0854
                    bcs       L0241
                    lbsr      L0CD4
                    ldu       $08,y
                    lda       ,u
                    ora       #$80
                    sta       ,u
                    bsr       L0246
                    bcs       L0241
                    lbsr      L0163
                    ldd       #$2EAE
                    std       ,u
                    stb       <$20,u
                    lda       <$37,y
                    sta       <$1D,u
                    ldd       <$38,y
                    std       <$1E,u
                    lda       <$34,y
                    sta       <$3D,u
                    ldd       <$35,y
                    std       <$3E,u
                    lbsr      L0D40
L0241               bra       L0282
L0243               lbsr      L0CD4
L0246               ldx       $08,y
                    ldd       $0F,y
                    std       $09,x
                    ldd       <$11,y
                    std       $0B,x
                    clr       $0A,y
L0253               lbra      L0D38

Close               clra
                    tst       $02,y
                    bne       L027C
                    lbsr      L0D72
                    bcs       L0282
                    ldb       $01,y
                    bitb      #$02
                    beq       L0282
                    ldd       <$34,y
                    bne       L0270
                    lda       <$36,y
                    beq       L0282
L0270               bsr       L0243
                    lbsr      L0529
                    bcc       L0282
                    lbsr      L0AAF
                    bra       L0282
L027C               rts
L027D               ldb       #$D6
L027F               coma
L0280               puls      y
L0282               pshs      b,cc
                    ldu       $08,y
                    beq       L028E
                    ldd       #$0100
                    os9       F$SRtMem
L028E               puls      pc,b,cc
L0290               lbsr      L0CD4
                    ldu       $08,y
                    lda       $08,u
                    pshs      a
                    leax      $03,u
                    os9       F$Time
                    puls      a
                    sta       $08,u
                    rts

ChgDir              pshs      y
                    lda       $01,y
                    ora       #$80
                    sta       $01,y
                    lbsr      Open
                    bcs       L0280
                    ldx       <$004B
                    ldu       <$35,y
                    ldb       $01,y
                    bitb      #$03
                    beq       L02C4
                    ldb       <$34,y
                    stb       <$1D,x
                    stu       <$1E,x
L02C4               ldb       $01,y
                    bitb      #$04
                    beq       L02D3
                    ldb       <$34,y
                    stb       <$23,x
                    stu       <$24,x
L02D3               clrb
                    bra       L0280

Delete              pshs      y
                    lbsr      L061D
                    bcs       L0280
                    ldd       <$35,y
                    bne       L02E9
                    tst       <$34,y
                    beq       L027D
L02E9               lda       #$42
                    lbsr      L07F1
                    bcs       L035F
                    ldu       $06,y
                    stx       R$X,u
                    lbsr      L0CD4
                    bcs       L035F
                    ldx       $08,y
                    dec       $08,x
                    beq       L0304
                    lbsr      L0D38
                    bra       L032A
L0304               clra
                    clrb
                    std       $0F,y
                    std       <$11,y
                    lbsr      L0AAF
                    bcs       L035F
                    ldb       <$34,y
                    ldx       <$35,y
                    stb       <$16,y
                    stx       <$17,y
                    ldx       $08,y
                    ldd       <$13,x
                    addd      #$0001
                    std       <$1A,y
                    lbsr      L0B6E
L032A               bcs       L035F
                    lbsr      L0D72
                    lbsr      L0837
                    lda       <$37,y
                    sta       <$34,y
                    ldd       <$38,y
                    std       <$35,y
                    lbsr      L0CD4
                    bcs       L035F
                    lbsr      L082B
                    ldu       $08,y
                    lbsr      L01C6
                    ldd       <$3A,y
                    std       $0B,y
                    ldd       <$3C,y
                    std       $0D,y
                    lbsr      L079C
                    bcs       L035F
                    clr       ,x
                    lbsr      L0D40
L035F               lbra      L0280

Seek                ldb       $0A,y
                    bitb      #$02
                    beq       L037B
                    lda       R$X+1,u
                    ldb       R$U,u
                    subd      $0C,y
                    bne       L0376
                    lda       R$X,u
                    sbca      $0B,y
                    beq       L037F
L0376               lbsr      L0D72
                    bcs       L0383
L037B               ldd       R$X,u
                    std       $0B,y
L037F               ldd       R$U,u
                    std       $0D,y
L0383               rts

ReadLn              bsr       L03C4
                    beq       L03AA
                    bsr       L03AB
                    pshs      u,y,x,b,a
                    exg       x,u
                    ldy       #$0000
                    lda       #$0D
L0394               leay      $01,y
                    cmpa      ,x+
                    beq       L039D
                    decb
                    bne       L0394
L039D               ldx       $06,s
                    bsr       L03F4
                    sty       $0A,s
                    puls      u,y,x,b,a
                    ldd       $02,s
                    leax      d,x
L03AA               rts
L03AB               bsr       L0414
                    lda       ,-x
                    cmpa      #$0D
                    beq       L03BA
                    ldd       $02,s
                    bne       L041A
L03BA               ldu       $06,y
                    ldd       R$Y,u
                    subd      $02,s
                    std       R$Y,u
                    bra       L040E
L03C4               ldd       R$Y,u
                    bsr       L03CD
                    bcs       L03F1
                    std       R$Y,u
                    rts
L03CD               pshs      b,a
                    ldd       <$11,y
                    subd      $0D,y
                    tfr       d,x
                    ldd       $0F,y
                    sbcb      $0C,y
                    sbca      $0B,y
                    bcs       L03EE
                    bne       L03EB
                    tstb
                    bne       L03EB
                    cmpx      ,s
                    bcc       L03EB
                    stx       ,s
                    beq       L03EE
L03EB               clrb
                    puls      pc,b,a
L03EE               comb
                    ldb       #E$EOF
L03F1               leas      $02,s
                    rts
L03F4               lbra      L04F2

Read                bsr       L03C4
                    beq       L0409
                    bsr       L040A
L03FD               pshs      u,y,x,b,a
                    exg       x,u
                    tfr       d,y
                    bsr       L03F4
                    puls      u,y,x,b,a
                    leax      d,x
L0409               rts
L040A               bsr       L0414
                    bne       L041A
L040E               clrb
L040F               leas      -$02,s
L0411               leas      $0A,s
                    rts
L0414               ldd       R$X,u
                    ldx       R$Y,u
                    pshs      x,b,a
L041A               lda       $0A,y
                    bita      #$02
                    bne       L043A
                    tst       $0E,y
                    bne       L0435
                    tst       $02,s
                    beq       L0435
                    leax      >L04A4,pcr
                    cmpx      $06,s
                    bne       L0435
                    lbsr      L0C49
                    bra       L0438
L0435               lbsr      L0D91
L0438               bcs       L040F
L043A               ldu       $08,y
                    clra
                    ldb       $0E,y
                    leau      d,u
                    negb
                    sbca      #$FF
                    ldx       ,s
                    cmpd      $02,s
                    bls       L044D
                    ldd       $02,s
L044D               pshs      b,a
                    jsr       [<$08,s]
                    stx       $02,s
                    lda       $0A,y
                    anda      #$BF
                    sta       $0A,y
                    ldb       $01,s
                    addb      $0E,y
                    stb       $0E,y
                    bne       L0471
                    lbsr      L0D72
                    inc       $0D,y
                    bne       L046F
                    inc       $0C,y
                    bne       L046F
                    inc       $0B,y
L046F               bcs       L0411
L0471               ldd       $04,s
                    subd      ,s++
                    std       $02,s
                    jmp       [<$04,s]

WriteLn             pshs      y
                    clrb
                    ldy       R$Y,u
                    beq       L0498
                    ldx       R$X,u
L0484               leay      -$01,y
                    beq       L0498
                    lda       ,x+
                    cmpa      #$0D
                    bne       L0484
                    tfr       y,d
                    nega
                    negb
                    sbca      #$00
                    addd      R$Y,u
                    std       R$Y,u
L0498               puls      y

Write               ldd       R$Y,u
                    beq       L04BE
                    bsr       L04C0
                    bcs       L04BF
                    bsr       L04B5
L04A4               pshs      y,b,a
                    tfr       d,y
                    bsr       L04F2
                    puls      y,b,a
                    leax      d,x
                    lda       $0A,y
                    ora       #$03
                    sta       $0A,y
                    rts
L04B5               lbsr      L0414
                    lbne      L041A
                    leas      $08,s
L04BE               clrb
L04BF               rts
L04C0               addd      $0D,y
                    tfr       d,x
                    ldd       $0B,y
                    adcb      #$00
                    adca      #$00
L04CA               cmpd      $0F,y
                    bcs       L04BE
                    bhi       L04D6
                    cmpx      <$11,y
                    bls       L04BE
L04D6               pshs      u
                    ldu       <$11,y
                    stx       <$11,y
                    ldx       $0F,y
                    std       $0F,y
                    pshs      u,x
                    lbsr      L0854
                    puls      u,x
                    bcc       L04F0
                    stx       $0F,y
                    stu       <$11,y
L04F0               puls      pc,u
L04F2               pshs      u,y,x
                    ldd       $02,s
                    beq       L051B
                    leay      d,u
                    lsrb
                    bcc       L0501
                    lda       ,x+
                    sta       ,u+
L0501               lsrb
                    bcc       L0508
                    ldd       ,x++
                    std       ,u++
L0508               pshs      y
                    exg       x,u
                    bra       L0515
L050E               pulu      y,b,a
                    std       ,x++
                    sty       ,x++
L0515               cmpx      ,s
                    bcs       L050E
                    leas      $02,s
L051B               puls      pc,u,y,x

GetStat             ldb       R$B,u
                    cmpb      #SS.Opt
                    beq       L0543
                    cmpb      #$06
                    bne       L052F
                    clr       R$B,u
L0529               clra
                    ldb       #$01
                    lbra      L03CD
L052F               cmpb      #SS.Ready
                    bne       L0536
                    clr       R$B,u
                    rts
L0536               cmpb      #SS.Size
                    bne       L0544
                    ldd       $0F,y
                    std       R$X,u
                    ldd       <$11,y
                    std       R$U,u
L0543               rts
L0544               cmpb      #SS.Pos
                    bne       L0551
                    ldd       $0B,y
                    std       R$X,u
                    ldd       $0D,y
                    std       R$U,u
Gst5FF              rts
L0551               cmpb      #SS.FD
                    bne       SSFDInf
                    lbsr      L0CD4
                    bcs       L0543
                    ldu       $06,y
                    ldd       R$Y,u
                    tsta
                    beq       L0564
                    ldd       #$0100
L0564               ldx       R$X,u
                    ldu       $08,y
                    lbra      L03FD
SSFDInf             cmpb      #SS.FDInf
                    bne       L056B
                    lbsr      L0D72               check for sector flush
                    bcs       Gst5FF
                    ldb       R$Y,u               get MSB of sector #
                    ldx       R$U,u               get LSW of sector #
                    lbsr      L0CEB               read the sector
                    bcs       Gst5FF              error, return
                    ldu       PD.RGS,y            get register stack pointer
                    ldd       R$Y,u               get length of data to move
                    clra                          clear MSB
                    bra       L0564               move it to user

L056B               lda       #$09
                    lbra      L0CED

SetStat             ldb       R$B,u
                    cmpb      #SS.Opt
                    bne       L0584
                    ldx       R$X,u
                    leax      $02,x
                    leau      <PD.STP,y
                    ldy       #$000D
                    lbra      L04F2
L0584               cmpb      #SS.Size
                    bne       L05C6
                    ldd       <PD.FD+1,y
                    bne       L0594
                    tst       <PD.FD,y
                    lbeq      L0619
L0594               lda       PD.MOD,y
                    bita      #WRITE.
                    beq       L05C2
                    ldd       R$X,u
                    ldx       R$U,u
                    cmpd      $0F,y
                    bcs       L05AD
                    bne       L05AA
                    cmpx      <PD.SIZ+2,y
                    bcs       L05AD
L05AA               lbra      L04CA
L05AD               std       PD.SIZ,y
                    stx       <PD.SIZ+2,y
                    ldd       PD.CP,y
                    ldx       PD.CP+2,y
                    pshs      x,b,a
                    lbsr      L0AAF
                    puls      u,x
                    stx       PD.CP,y
                    stu       PD.CP+2,y
                    rts
L05C2               comb
                    ldb       #E$BMode
                    rts
L05C6               cmpb      #SS.FD
                    bne       L0604
                    lbsr      L0CD4
                    bcs       L061C
                    pshs      y
                    ldx       R$X,u
                    ldu       $08,y
                    lda       $01,y
                    bita      #$02
                    beq       L05F0
                    ldy       <$004B
                    ldd       $09,y
                    bne       L05E7
                    ldd       #$0102
                    bsr       L05F6
L05E7               ldd       #$0305
                    bsr       L05F6
                    ldd       #$0D03
                    bsr       L05F6
* Change attrs
L05F0               ldd       #$0001
                    bsr       L05F6
                    puls      y
                    lbra      L0D38
L05F6               pshs      u,x
                    leax      a,x
                    leau      a,u
                    clra
                    tfr       d,y
                    lbsr      L04F2
                    puls      pc,u,x
L0604               cmpb      #$1E
                    bne       L0614
                    ldx       <$1E,y
                    lda       R$X+1,u
                    sta       <$1E,x
                    clr       <$1D,x
                    rts
L0614               lda       #$0C
                    lbra      L0CED
L0619               comb
                    ldb       #E$UnkSvc
L061C               rts

L061D
**** ADDED 06/19/2004 ****
* Call to SS.VarSect in Driver:
*
* This code calls the driver's SS.VarSect GetStat, which will
* update the PD.TYP byte in the path descriptor to the sector
* size of the media to which this path references.
* If the driver doesn't support the GetStat, it will return
* an error, and won't touch the PD.TYP anyway, so we ignore it.
                    ldx       PD.RGS,y            get caller's regs
                    lda       R$B,x               get caller's B
                    pshs      x,a                 save PD.RGS ptr and caller's original B
                    ldd       #D$GSTA*256+SS.VarSect getstat function/SS.VarSect GetStat
                    stb       R$B,x               put SS.VarSect into caller's B
                    lbsr      L0CED               send it to driver
                    puls      a,x                 get caller's original B and saved PD.RGS
                    sta       R$B,x               restore caller's original B
                    bcc       ok@                 branch if no error on GetStat
                    cmpb      #E$UnkSvc           Unknown Service call error?
                    lbne      L0B10               if not, return with error
****
ok@                 ldd       #256
                    stb       PD.BUF+2,y
                    os9       F$SRqMem
                    bcs       L061C
                    stu       PD.BUF,y
                    ldx       PD.RGS,y
                    ldx       R$X,x
                    pshs      u,y,x
                    leas      -$04,s
                    clra
                    clrb
                    sta       <PD.FD,y
                    std       <PD.FD+1,y
                    std       <PD.DSK,y
                    lda       ,x
                    sta       ,s
                    cmpa      #PDELIM
                    bne       L0654
                    lbsr      L07BC
                    sta       ,s
                    lbcs      L0752
                    leax      ,y
                    ldy       $06,s
                    bra       L0677
L0654               anda      #$7F                strip hi bit
                    cmpa      #PENTIR             raw?
                    beq       L0677               branch if so
                    lda       #PDELIM
                    sta       ,s
                    leax      -$01,x
                    lda       $01,y
                    ldu       <$004B
                    leau      <$1A,u
                    bita      #$24
                    beq       L066D
                    leau      $06,u
L066D               ldb       $03,u
                    stb       <PD.FD,y
                    ldd       $04,u
                    std       <PD.FD+1,y
L0677               ldu       $03,y
                    stu       <PD.DVT,y
                    lda       <PD.DRV,y
                    ldb       #DRVMEM
                    mul
                    addd      $02,u
                    addd      #$000F
                    std       <PD.DTB,y
                    lda       ,s
                    anda      #$7F
                    cmpa      #PENTIR
                    bne       L0698
                    leax      $01,x
                    bra       L06BA
L0698               lbsr      L0CC1
                    lbcs      L075A
                    ldu       PD.BUF,y
                    ldd       $0E,u
                    std       <PD.DSK,y
                    ldd       <PD.FD+1,y
                    bne       L06BA
                    lda       <PD.FD,y
                    bne       L06BA
                    lda       $08,u
                    sta       <PD.FD,y
                    ldd       $09,u
                    std       <PD.FD+1,y
L06BA               stx       $04,s
                    stx       $08,s
L06BE               lbsr      L0D72
                    lbcs      L075A
                    lda       ,s
                    anda      #$7F
                    cmpa      #PENTIR
                    beq       L06D4
                    lbsr      L0CD4
                    lbcs      L075A
L06D4               lbsr      L082B
                    lda       ,s
                    cmpa      #PDELIM
                    bne       L0734
                    clr       $02,s
                    clr       $03,s
                    lda       $01,y
                    ora       #$80
                    lbsr      L07F1
                    bcs       L0752
                    lbsr      L01C6
                    ldx       $08,s
                    leax      $01,x
                    lbsr      L07BC
                    std       ,s
                    stx       $04,s
                    sty       $08,s
                    ldy       $06,s
                    bcs       L0752
                    lbsr      L079C
                    bra       L070A
L0705               bsr       L075D
L0707               bsr       L0787
L070A               bcs       L0752
                    tst       ,x
                    beq       L0705
                    clra
                    ldb       $01,s
                    leay      ,x
                    ldx       $04,s
                    os9       F$CmpNam
                    ldx       $06,s
                    exg       x,y
                    bcs       L0707
                    bsr       L076B
                    lda       <$1D,x
                    sta       <PD.FD,y
                    ldd       <$1E,x
                    std       <PD.FD+1,y
                    lbsr      L0837
                    bra       L06BE
L0734               ldx       $08,s
                    tsta
                    bmi       L0741
                    os9       F$PrsNam
                    leax      ,y
                    ldy       $06,s
L0741               stx       $04,s
                    clra
L0744               lda       ,s
                    leas      $04,s
                    pshs      b,a,cc
                    lda       $0A,y
                    anda      #$BF
                    sta       $0A,y
                    puls      pc,u,y,x,b,a,cc
L0752               cmpb      #$D3
                    bne       L075A
                    bsr       L075D
                    ldb       #$D8
L075A               coma
                    bra       L0744
L075D               pshs      b,a
                    lda       $04,s
                    cmpa      #$2F
                    beq       L0785
                    ldd       $06,s
                    bne       L0785
                    puls      b,a
L076B               pshs      b,a
                    stx       $06,s
                    lda       <PD.FD,y
                    sta       <PD.DFD,y
                    ldd       <PD.FD+1,y
                    std       <PD.DFD+1,y
                    ldd       $0B,y
                    std       <PD.DCP,y
                    ldd       $0D,y
                    std       <PD.DCP+2,y
L0785               puls      pc,b,a

L0787               ldb       $0E,y
                    addb      #$20
                    stb       $0E,y
                    bcc       L079C
                    lbsr      L0D72
                    inc       $0D,y
                    bne       L079C
                    inc       $0C,y
                    bne       L079C
                    inc       $0B,y
L079C               ldd       #$0020
                    lbsr      L03CD
                    bcs       L07BB
                    lda       $0A,y
                    bita      #$02
                    bne       L07B4
                    lbsr      L0C49
                    bcs       L07BB
                    lbsr      L0D91
                    bcs       L07BB
L07B4               ldb       $0E,y
                    lda       $08,y
                    tfr       d,x
                    clrb
L07BB               rts

L07BC               os9       F$PrsNam
                    pshs      x
                    bcc       L07E9
                    clrb
L07C4               pshs      a
                    anda      #$7F
                    cmpa      #PDIR
                    puls      a
                    bne       L07DF
                    incb
                    leax      $01,x
                    tsta
                    bmi       L07DF
                    lda       ,x
                    cmpb      #$03
                    bcs       L07C4
                    lda       #PDELIM
                    decb
                    leax      -$03,x
L07DF               tstb
                    bne       L07E7
L07E2               comb
                    ldb       #E$BPNam
                    puls      pc,x
L07E7               leay      ,x
L07E9               cmpb      #$20
                    bhi       L07E2
                    andcc     #^Carry
                    puls      pc,x

* A = PD.MOD (mode byte)
L07F1               tfr       a,b
                    anda      #$07
                    andb      #$C0
                    pshs      x,b,a
                    lbsr      L0CD4
                    bcs       L0820
                    ldu       $08,y
                    ldx       <$004B
                    ldd       $09,x
                    beq       L0809
                    cmpd      $01,u
L0809               puls      a
                    beq       L0810
                    lsla
                    lsla
                    lsla
L0810               ora       ,s
                    anda      #$BF
                    pshs      a
                    ora       #$80
                    anda      ,u
                    cmpa      ,s
                    beq       L0829
                    ldb       #$D6
L0820               leas      $02,s
                    coma
                    puls      pc,x
                    ldb       #$FD
                    bra       L0820
L0829               puls      pc,x,b,a
L082B               clra
                    clrb
                    std       $0B,y
                    std       $0D,y
                    sta       <$19,y
                    std       <$1A,y
L0837               rts
L0838               pshs      y,x,b,a
                    ldx       <D.Proc
                    lda       <P$IOQN,x
                    beq       L0851
                    clr       <P$IOQN,x
                    ldb       #S$Wake
                    os9       F$Send
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    clr       <P$IOQP,y
L0851               clrb
                    puls      pc,y,x,b,a
L0854               pshs      u,x
L0856               bsr       L08B2
                    bne       L0866
                    cmpx      <$1A,y
                    bcs       L08AD
                    bne       L0866
                    lda       <$12,y
                    beq       L08AD
L0866               lbsr      L0CD4
                    bcs       L08AA
                    ldx       $0B,y
                    ldu       $0D,y
                    pshs      u,x
                    ldd       $0F,y
                    std       $0B,y
                    ldd       <$11,y
                    std       $0D,y
                    lbsr      L0C63
                    puls      u,x
                    stx       $0B,y
                    stu       $0D,y
                    bcc       L08AD
                    cmpb      #$D5
                    bne       L08AA
                    bsr       L08B2
                    bne       L0896
                    tst       <$12,y
                    beq       L0899
                    leax      $01,x
                    bne       L0899
L0896               ldx       #$FFFF
L0899               tfr       x,d
                    tsta
                    bne       L08A6
                    cmpb      <$2E,y
                    bcc       L08A6
                    ldb       <$2E,y
L08A6               bsr       L08C0
                    bcc       L0856
L08AA               coma
                    puls      pc,u,x
L08AD               lbsr      L0C49
                    puls      pc,u,x
L08B2               ldd       <$10,y
                    subd      <$14,y
                    tfr       d,x
                    ldb       $0F,y
                    sbcb      <$13,y
                    rts
L08C0               pshs      u,x
                    lbsr      L0966
                    bcs       L08FF
                    lbsr      L0CD4
                    bcs       L08FF
                    ldu       $08,y
                    clra
                    clrb
                    std       $09,u
                    std       $0B,u
                    leax      <$10,u
                    ldd       $03,x
                    beq       L0947
                    ldd       $08,y
                    inca
                    pshs      b,a
                    bra       L08EF
L08E2               clrb
                    ldd       -$02,x
                    beq       L08FB
                    addd      $0A,u
                    std       $0A,u
                    bcc       L08EF
                    inc       $09,u
L08EF               leax      $05,x
                    cmpx      ,s
                    bcs       L08E2
                    lbsr      L0B6E
                    comb
                    ldb       #E$SLF
L08FB               leas      $02,s
                    leax      -$05,x
L08FF               bcs       L0964
                    ldd       -$04,x
                    addd      -$02,x
                    pshs      b,a
                    ldb       -$05,x
                    adcb      #$00
                    cmpb      <$16,y
                    puls      b,a
                    bne       L0947
                    cmpd      <$17,y
                    bne       L0947
                    ldu       <$1E,y
                    ldd       $06,u
                    ldu       $08,y
                    subd      #$0001
                    coma
                    comb
                    pshs      b,a
                    ldd       -$05,x
                    eora      <$16,y
                    eorb      <$17,y
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    anda      ,s+
                    andb      ,s+
                    std       -$02,s
                    bne       L0947
                    ldd       -$02,x
                    addd      <$1A,y
                    bcs       L0947
                    std       -$02,x
                    bra       L0956
L0947               ldd       <$16,y
                    std       ,x
                    lda       <$18,y
                    sta       $02,x
                    ldd       <$1A,y
                    std       $03,x
L0956               ldd       $0A,u
                    addd      <$1A,y
                    std       $0A,u
                    bcc       L0961
                    inc       $09,u
L0961               lbsr      L0D38
L0964               puls      pc,u,x
L0966               pshs      u,y,x,b,a
                    ldb       #$0C
L096A               clr       ,-s
                    decb
                    bne       L096A
                    ldx       <$1E,y
                    ldd       $04,x
                    std       $04,s
                    ldd       $06,x
                    std       $02,s
                    std       $0A,s
                    ldx       $03,y
                    ldx       $04,x
                    leax      <$12,x
                    subd      #$0001
                    addb      $0E,x
                    adca      #$00
                    bra       L098E
L098C               lsra
                    rorb
L098E               lsr       $0A,s
                    ror       $0B,s
                    bcc       L098C
                    std       ,s
                    ldd       $02,s
                    std       $0A,s
                    subd      #$0001
                    addd      $0C,s
                    bcc       L09A8
                    ldd       #$FFFF
                    bra       L09A8
L09A6               lsra
                    rorb
L09A8               lsr       $0A,s
                    ror       $0B,s
                    bcc       L09A6
                    cmpa      #$08
                    bcs       L09B5
                    ldd       #$0800
L09B5               std       $0C,s
                    lbsr      L0BD8
                    lbcs      L0AA3
                    ldx       <$1E,y
                    ldd       <$1A,x
                    cmpd      $0E,x
                    bne       L09D7
                    lda       <$1C,x
                    cmpa      $04,x
                    bne       L09D7
                    ldb       <$1D,x
                    cmpb      $04,x
                    bcs       L09E5
L09D7               ldd       $0E,x
                    std       <$1A,x
                    lda       $04,x
                    sta       <$1C,x
                    clrb
                    stb       <$1D,x
L09E5               incb
                    stb       $06,s
                    ldx       <$1E,y
                    cmpb      <$1E,x
                    beq       L0A21
                    lbsr      L0C33
                    lbcs      L0AA3
                    ldb       $06,s
                    cmpb      $04,s
                    bls       L0A02
                    clra
                    ldb       $05,s
                    bra       L0A05
L0A02               ldd       #$0100
L0A05               ldx       $08,y
                    leau      d,x
                    ldy       $0C,s
                    clra
                    clrb
                    os9       F$SchBit
                    bcc       L0A4E
                    cmpy      $08,s
                    bls       L0A21
                    sty       $08,s
                    std       $0A,s
                    lda       $06,s
                    sta       $07,s
L0A21               ldy       <$10,s
                    ldb       $06,s
                    cmpb      $04,s
                    bcs       L0A32
                    bhi       L0A31
                    tst       $05,s
                    bne       L0A32
L0A31               clrb
L0A32               ldx       <$1E,y
                    cmpb      <$1D,x
                    bne       L09E5
                    ldb       $07,s
                    beq       L0AA1
                    cmpb      $06,s
                    beq       L0A47
                    stb       $06,s
                    lbsr      L0C33
L0A47               ldx       $08,y
                    ldd       $0A,s
                    ldy       $08,s
L0A4E               std       $0A,s
                    sty       $08,s
                    os9       F$AllBit
                    ldy       <$10,s
                    ldb       $06,s
                    lbsr      L0C0B
                    bcs       L0AA3
                    ldx       <$1E,y
                    lda       $06,s
                    deca
                    sta       <$1D,x
                    clrb
                    lsla
                    rolb
                    lsla
                    rolb
                    lsla
                    rolb
                    stb       <$16,y
                    ora       $0A,s
                    ldb       $0B,s
                    ldx       $08,s
                    ldy       <$10,s
                    std       <$17,y
                    stx       <$1A,y
                    ldd       $02,s
                    bra       L0A97
L0A88               lsl       <$18,y
                    rol       <$17,y
                    rol       <$16,y
                    lsl       <$1B,y
                    rol       <$1A,y
L0A97               lsra
                    rorb
                    bcc       L0A88
                    clrb
                    ldd       <$1A,y
                    bra       L0AAB
L0AA1               ldb       #$F8
L0AA3               ldy       <$10,s
                    lbsr      L0C12
                    coma
L0AAB               leas      $0E,s
                    puls      pc,u,y,x
L0AAF               clra
                    lda       $01,y
                    bita      #$80
                    bne       L0B11
                    ldd       $0F,y
                    std       $0B,y
                    ldd       <$11,y
                    std       $0D,y
                    lbsr      L0C63
                    bcc       L0AC8
                    cmpb      #$D5
                    bra       L0B09
L0AC8               ldd       <$14,y
                    subd      $0C,y
                    addd      <$1A,y
                    tst       $0E,y
                    beq       L0AD7
                    subd      #$0001
L0AD7               pshs      b,a
                    ldu       <$1E,y
                    ldd       $06,u
                    subd      #$0001
                    coma
                    comb
                    anda      ,s+
                    andb      ,s+
                    ldu       <$1A,y
                    std       <$1A,y
                    beq       L0B0B
                    tfr       u,d
                    subd      <$1A,y
                    pshs      x,b,a
                    addd      <$17,y
                    std       <$17,y
                    bcc       L0B01
                    inc       <$16,y
L0B01               bsr       L0B6E
                    bcc       L0B12
                    leas      $04,s
                    cmpb      #$DB
L0B09               bne       L0B10
L0B0B               lbsr      L0CD4
                    bcc       L0B1B
L0B10               coma
L0B11               rts
L0B12               lbsr      L0CD4
                    bcs       L0B6B
                    puls      x,b,a
                    std       $03,x
L0B1B               ldu       $08,y
                    ldd       <$11,y
                    std       $0B,u
                    ldd       $0F,y
                    std       $09,u
                    tfr       x,d
                    clrb
                    inca
                    leax      $05,x
                    pshs      x,b,a
                    bra       L0B56
L0B30               ldd       -$02,x
                    beq       L0B63
                    std       <$1A,y
                    ldd       -$05,x
                    std       <$16,y
                    lda       -$03,x
                    sta       <$18,y
                    bsr       L0B6E
                    bcs       L0B6B
                    stx       $02,s
                    lbsr      L0CD4
                    bcs       L0B6B
                    ldx       $02,s
                    clra
                    clrb
                    std       -$05,x
                    sta       -$03,x
                    std       -$02,x
L0B56               lbsr      L0D38
                    bcs       L0B6B
                    ldx       $02,s
                    leax      $05,x
                    cmpx      ,s
                    bcs       L0B30
L0B63               clra
                    clrb
                    sta       <$19,y
                    std       <$1A,y
L0B6B               leas      $04,s
                    rts
L0B6E               pshs      u,y,x,a
                    ldx       <$1E,y
                    ldd       $06,x
                    subd      #$0001
                    addd      <$17,y
                    std       <$17,y
                    ldd       $06,x
                    bcc       L0B96
                    inc       <$16,y
                    bra       L0B96
L0B87               lsr       <$16,y
                    ror       <$17,y
                    ror       <$18,y
                    lsr       <$1A,y
                    ror       <$1B,y
L0B96               lsra
                    rorb
                    bcc       L0B87
                    clrb
                    ldd       <$1A,y
                    beq       L0BD6
                    ldd       <$16,y
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    tfr       b,a
                    ldb       #$DB
                    cmpa      $04,x
                    bhi       L0BD5
                    inca
                    sta       ,s
L0BB4               bsr       L0BD8
                    bcs       L0BB4
                    ldb       ,s
                    bsr       L0C33
                    bcs       L0BD5
                    ldx       $08,y
                    ldd       <$17,y
                    anda      #$07
                    ldy       <$1A,y
                    os9       F$DelBit
                    ldy       $03,s
                    ldb       ,s
                    bsr       L0C0B
                    bcc       L0BD6
L0BD5               coma
L0BD6               puls      pc,u,y,x,a
L0BD8               lbsr      L0D72
                    bra       L0BE5
L0BDD               lbsr      L0838
                    os9       F$IOQu
                    bsr       L0BF5
L0BE5               bcs       L0BF4
                    ldx       <$1E,y
                    lda       <$17,x
                    bne       L0BDD
                    lda       $05,y
                    sta       <$17,x
L0BF4               rts
L0BF5               ldu       <$004B
                    ldb       <$36,u
                    cmpb      #$01
                    bls       L0C02
                    cmpb      #$03
                    bls       L0C09
L0C02               clra
                    lda       $0D,u
                    bita      #$02
                    beq       L0C0A
L0C09               coma
L0C0A               rts
L0C0B               clra
                    tfr       d,x
                    clrb
                    lbsr      L0D42
L0C12               pshs      cc
                    ldx       <$1E,y
                    lda       $05,y
                    cmpa      <$17,x
                    bne       L0C31
                    clr       <$17,x
                    ldx       <$004B
                    lda       <$11,x
                    beq       L0C31
                    lbsr      L0838
                    ldx       #$0001
                    os9       F$Sleep
L0C31               puls      pc,cc
L0C33               clra
                    tfr       d,x
                    clrb
                    lbra      L0CEB
                    pshs      u,x
                    lbsr      L0D40
                    bcs       L0C47
                    lda       $0A,y
                    anda      #$FE
                    sta       $0A,y
L0C47               puls      pc,u,x
L0C49               ldd       $0C,y
                    subd      <$14,y
                    tfr       d,x
                    ldb       $0B,y
                    sbcb      <$13,y
                    cmpb      <$19,y
                    bcs       L0C61
                    bhi       L0C63
                    cmpx      <$1A,y
                    bcc       L0C63
L0C61               clrb
L0C62               rts
L0C63               pshs      u
                    bsr       L0CD4
                    bcs       L0CBF
                    clra
                    clrb
                    std       <$13,y
                    stb       <$15,y
                    ldu       $08,y
                    leax      <$10,u
                    lda       $08,y
                    ldb       #$FC
                    pshs      b,a
L0C7C               ldd       $03,x
                    beq       L0CA1
                    addd      <$14,y
                    tfr       d,u
                    ldb       <$13,y
                    adcb      #$00
                    cmpb      $0B,y
                    bhi       L0CAE
                    bne       L0C95
                    cmpu      $0C,y
                    bhi       L0CAE
L0C95               stb       <$13,y
                    stu       <$14,y
                    leax      $05,x
                    cmpx      ,s
                    bcs       L0C7C
L0CA1               clra
                    clrb
                    sta       <$19,y
                    std       <$1A,y
                    comb
                    ldb       #E$NES
                    bra       L0CBD
L0CAE               ldd       ,x
                    std       <$16,y
                    lda       $02,x
                    sta       <$18,y
                    ldd       $03,x
                    std       <$1A,y
L0CBD               leas      $02,s
L0CBF               puls      pc,u
L0CC1               pshs      x,b
                    lbsr      L0D72
                    bcs       L0CD0
                    clrb
                    ldx       #$0000
                    bsr       L0CEB
                    bcc       L0CD2
L0CD0               stb       ,s
L0CD2               puls      pc,x,b
L0CD4               ldb       $0A,y
                    bitb      #$04
                    bne       L0C61
                    lbsr      L0D72
                    bcs       L0C62
                    ldb       $0A,y
                    orb       #$04
                    stb       $0A,y
                    ldb       <$34,y
                    ldx       <$35,y
L0CEB               lda       #$03
L0CED               pshs      u,y,x,b,a
                    lda       $0A,y
                    ora       #$20
                    sta       $0A,y
                    ldu       $03,y
                    ldu       $02,u
                    bra       L0D01
L0CFB               lbsr      L0838
                    os9       F$IOQu
L0D01               lda       $04,u
                    bne       L0CFB
                    lda       $05,y
                    sta       $04,u
                    ldd       ,s
                    ldx       $02,s
                    pshs      u
                    bsr       L0D26
                    puls      u
                    ldy       $04,s
                    pshs      cc
                    bcc       L0D1C
                    stb       $02,s
L0D1C               lda       $0A,y
                    anda      #$DF
                    sta       $0A,y
                    clr       $04,u
                    puls      pc,u,y,x,b,a,cc
L0D26               pshs      pc,x,b,a
                    ldx       $03,y
                    ldd       ,x
                    ldx       ,x
                    addd      $09,x
                    addb      ,s
                    adca      #$00
                    std       $04,s
                    puls      pc,x,b,a
L0D38               ldb       <$34,y
                    ldx       <$35,y
                    bra       L0D42
L0D40               bsr       L0D5B
L0D42               lda       #$06
                    pshs      x,b,a
                    ldd       <$1C,y
                    beq       L0D51
                    ldx       <$1E,y
                    cmpd      $0E,x
L0D51               puls      x,b,a
                    beq       L0CED
                    comb
                    ldb       #E$DIDC
                    rts
L0D5B               ldd       $0C,y
                    subd      <$14,y
                    tfr       d,x
                    ldb       $0B,y
                    sbcb      <$13,y
                    exg       d,x
                    addd      <$17,y
                    exg       d,x
                    adcb      <$16,y
                    rts
L0D72               clrb
                    pshs      u,x
                    ldb       $0A,y
                    andb      #$46
                    beq       L0D8F
                    tfr       b,a
                    eorb      $0A,y
                    stb       $0A,y
                    andb      #$01
                    beq       L0D8F
                    eorb      $0A,y
                    stb       $0A,y
                    bita      #$02
                    beq       L0D8F
                    bsr       L0D40
L0D8F               puls      pc,u,x
L0D91               pshs      u,x
                    lbsr      L0C49
                    bcs       L0DAA
                    bsr       L0D72
                    bcs       L0DAA
                    bsr       L0D5B
                    lbsr      L0CEB
                    bcs       L0DAA
                    lda       $0A,y
                    ora       #$42
                    sta       $0A,y
L0DAA               puls      pc,u,x

                    emod
eom                 equ       *
                    end

