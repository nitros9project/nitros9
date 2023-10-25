********************************************************************
* TunePort - Tune Printer Port
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   3      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   3      2005/10/22    Robert Gault
* Patched the calculation for the beginning of the baud table to
* accommodate both Level1 and Level2

                    nam       TunePort
                    ttl       Tune Printer Port

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

                    mod       eom,name,tylg,atrv,start,size

                    org       0
u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       2
u0005               rmb       2
u0007               rmb       2
u0009               rmb       1
u000A               rmb       1
u000B               rmb       2
u000D               rmb       2
u000F               rmb       2
u0011               rmb       1
u0012               rmb       1
u0013               rmb       3
size                equ       .

name                fcs       /TunePort/
                    fcb       edition

AdjPmpt             fcb       C$CR
                    fcb       C$LF
                    fcc       " TO ADJUST YOUR PORT ENTER A"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "NEW VALUE FOR THE LOOP DELAY"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "AFTER THE PROMPT AND CURRENT"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "VALUE ARE GIVEN. HIT [ENTER]"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "TO END."
                    fcb       C$CR
                    fcb       C$LF
PmptLen             equ       *-AdjPmpt

DoneMsg             fcb       C$LF
                    fcb       C$CR
                    fcb       $20
                    fcc       "YOUR PORT IS NOW ADJUSTED FOR"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "THE CURRENT BAUD RATE AND THE"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "CRC OF THE MODULE HAS BEEN UP-"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "DATED.  TO MAKE THE CHANGE"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "PERMANENT IN THE BOOT USE THE"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "COBBLER OR OS9GEN UTILITIES"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "OR THE -S OPTION OF TUNEPORT"
                    fcb       C$CR
                    fcc       "AT SYSTEM STARTUP"
                    fcb       C$CR
DoneLen             equ       *-DoneMsg

                    ifne      DOHELP
HelpMsg             fcc       "USE:TUNEPORT </P OR /T1> [-OPT]"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "    ADJUST BAUD RATE DELAY ON"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "    SERIAL PORTS."
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "Opt: -S=VALUE TO SET LOOP DELAY"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "        FOR CURRENT BAUD VALUE"
                    fcb       C$CR
HelpLen             equ       *-HelpMsg
                    endc

ErrMsg              fcc       "TUNEPORT: CURRENT BAUD RATE"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "IS OUT OF RANGE"
                    fcb       C$CR
ErrLen              equ       *-ErrMsg
L0241               fcb       C$BELL

TestNow             fcb       C$CR
                    fcc       "NOW TESTING ....."
TestLen             equ       *-TestNow

NewVMsg             fcb       C$CR
                    fcc       "NEW VALUE = "
NewVLen             equ       *-NewVMsg

CurVMsg             fcb       C$LF
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "CURRENT VALUE = "
CurVLen             equ       *-CurVMsg

TestMsg             fcc       " This is a test line for the TunePort utility"
                    fcb       C$CR
TMsgLen             equ       *-TestMsg

start               stu       <u0003
                    clr       <u0002
                    lbsr      L0455
                    stx       <u0009
                    cmpb      #C$CR
                    lbeq      L03FB
                    cmpb      #'/
                    lbne      L03FB
                    lda       #Devic+Objct
                    leax      $01,x
                    os9       F$Link
                    lbcs      L03E6
                    stu       <u000B
                    lda       <u0012,u
                    ldu       <u0003
                    cmpa      #$00
                    lbne      L03FB
                    ldy       <u000B
                    leax      <IT.BAU,y
                    lda       ,x
                    anda      #$0F
                    cmpa      #$06
                    lbgt      L03E9
                    sta       <u0000
                    leax      M$PDev,y
                    ldd       ,x
                    leax      d,y
                    leay      <$19,u
L02EA               lda       ,x+
                    bmi       L02F2
                    sta       ,y+
                    bra       L02EA
L02F2               anda      #$7F
                    sta       ,y+
                    lda       #C$CR
                    sta       ,y+
                    ldu       <u000B
                    os9       F$UnLink
                    lbcs      L03E6
                    ldu       <u0003
                    ldx       <u0009
                    lda       #WRITE.
                    os9       I$Open
                    lbcs      L03E6
                    sta       <u0001
                    lbsr      L0455
                    cmpb      #C$CR
                    beq       L031D
                    inc       <u0002
                    stx       <u0009
L031D               lda       #Drivr+Objct
                    leax      <$19,u
                    os9       F$Link
                    lbcs      L03DE
                    stu       <u000B
                    sty       <u000D
                    ldu       <u0003
                    tst       <u0002
                    bne       L0345
                    lda       #$01
                    leax      >AdjPmpt,pcr
                    ldy       #PmptLen
                    os9       I$Write
                    lbcs      L03D7
L0345               ldd       <u000D
* Patched calc   RG
                    ifgt      Level-1
                    subd      #$0010              Level2 has 8 constants RG
                    else
                    subd      #$000E              Level2 has 7 constants RG
                    endif
                    tfr       d,x
                    lda       <u0000
                    lsla
                    leax      a,x
                    stx       <u000F
                    tst       <u0002
                    bne       L035D
                    lbsr      L045E
                    lbsr      L040D
L035D               tst       <u0002
                    beq       L038E
                    ldx       <u0009
                    ldb       ,x
                    cmpb      #'-
                    lbne      L03FB
                    leax      $01,x
                    ldb       ,x+
                    cmpb      #'S
                    beq       L037A
                    cmpb      #'s
                    beq       L037A
                    lbra      L03FB
L037A               ldb       ,x+
                    cmpb      #'=
                    bne       L03FB
                    stx       <u0009
                    lbsr      L04F1
                    ldd       <u0005
                    ldx       <u000F
                    std       ,x
                    clrb
                    bra       L03D7
L038E               lbsr      L0432
                    lbsr      L04DC
                    bcc       L039D
                    lbsr      L0444
                    andcc     #^Carry
                    bra       L038E
L039D               ldd       <u0005
                    beq       L03A9
                    ldx       <u000F
                    std       ,x
                    bsr       L040D
                    bra       L038E
L03A9               ldx       <u000B
                    ldd       $02,x
                    subd      #$0003
                    tfr       d,y
                    leau      d,x
                    ldd       #$FFFF
                    std       u0001,u
                    sta       ,u
                    os9       F$CRC
                    com       ,u
                    com       u0001,u
                    com       u0002,u
                    ldu       <u0003
                    clra
                    leax      >DoneMsg,pcr
                    ldy       #DoneLen
                    os9       I$Write
                    bcs       L03E6
                    lbsr      L045E
L03D7               ldu       <u000B
                    os9       F$UnLink
                    bcs       L03E6
L03DE               lda       <u0001
                    os9       I$Close
                    bcs       L03E6
                    clrb
L03E6               os9       F$Exit
L03E9               lda       #$02
                    leax      >ErrMsg,pcr
                    ldy       #ErrLen
                    os9       I$Write
                    bcs       L03E6
                    clrb
                    bra       L03E6
L03FB               equ       *
                    ifne      DOHELP
                    lda       #$02
                    leax      >HelpMsg,pcr
                    ldy       #HelpLen
                    os9       I$Write
                    bcs       L03E6
                    endc
                    clrb
                    bra       L03E6
L040D               lda       #$01
                    leax      >TestNow,pcr
                    ldy       #TestLen
                    os9       I$Write
                    bcs       L03E6
                    lda       <u0001
                    leax      >TestMsg,pcr
                    ldy       #TMsgLen
                    os9       I$WritLn
                    bcs       L03E6
                    ldx       #$000A
                    os9       F$Sleep
                    rts
L0432               bsr       L045E
                    lda       #$01
                    leax      >NewVMsg,pcr
                    ldy       #NewVLen
                    os9       I$Write
                    bcs       L03E6
                    rts
L0444               pshs      y,x,b,a
                    lda       #$02
                    leax      >L0241,pcr
                    ldy       #$0001
                    os9       I$Write
                    puls      pc,y,x,b,a
L0455               ldb       ,x+
                    cmpb      #C$SPAC
                    beq       L0455
                    leax      -$01,x
                    rts
L045E               pshs      y,x,b,a
                    lda       #$01
                    leax      >CurVMsg,pcr
                    ldy       #CurVLen
                    os9       I$Write
                    lbcs      L03E6
                    ldx       <u000F
                    ldd       ,x
                    std       <u0005
                    leay      >L04D0,pcr
                    leax      <u0013,u
                    stx       <u0011
L0480               ldd       ,y
                    beq       L04BC
                    ldd       <u0005
                    pshs      b,a
                    ldd       ,y++
                    lbsr      L053F
                    cmpb      #$00
                    bne       L0498
                    leax      <u0013,u
                    cmpx      <u0011
                    beq       L0480
L0498               std       <u0007
                    addb      #$30
                    ldx       <u0011
                    stb       ,x+
                    stx       <u0011
                    ldx       <u0007
                    leax      -$01,x
                    leay      -$02,y
                    ldd       ,y++
                    std       <u0007
L04AC               addd      <u0007
                    leax      -$01,x
                    bne       L04AC
                    std       <u0007
                    ldd       <u0005
                    subd      <u0007
                    std       <u0005
                    bra       L0480
L04BC               ldx       <u0011
                    lda       #$0D
                    sta       ,x
                    leax      <u0013,u
                    lda       #$01
                    ldy       #$0006
                    os9       I$WritLn
                    puls      pc,y,x,b,a
L04D0               fcb       $27,$10,$03,$e8,$00,$64,$00,$0a,$00,$01,$00,$00
L04DC               pshs      y,x,b,a
                    clra
                    leax      <u0013,u
L04E2               ldy       #$0006
                    os9       I$ReadLn
                    lbcs      L03E6
                    bsr       L0504
                    puls      pc,y,x,b,a
L04F1               pshs      y,x,b,a
                    ldx       <u0009
                    leay      <u0013,u
L04F8               lda       ,x+
                    sta       ,y+
                    cmpa      #C$CR
                    bne       L04F8
                    bsr       L0504
                    puls      pc,y,x,b,a
L0504               pshs      y,x,b,a
                    clra
                    clrb
                    std       <u0005
                    leay      <u0013,u
L050D               ldb       ,y+
                    cmpb      #'0
                    blt       L0537
                    cmpb      #'9
                    bgt       L0537
                    pshs      b
                    ldx       #$0009
                    ldd       <u0005
                    std       <u0007
L0520               addd      <u0007
                    leax      -$01,x
                    bne       L0520
                    std       <u0005
                    puls      b
                    subb      #'0
                    clra
                    std       <u0007
                    ldd       <u0005
                    addd      <u0007
                    std       <u0005
                    bra       L050D
L0537               cmpb      #C$CR
                    beq       L053D
                    orcc      #Carry
L053D               puls      pc,y,x,b,a
L053F               pshs      b,a
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    lda       #$01
L0549               inca
                    lsl       $03,s
                    rol       $02,s
                    bpl       L0549
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
L0558               subd      $02,s
                    bcc       L0562
                    addd      $02,s
                    andcc     #^Carry
                    bra       L0564
L0562               orcc      #Carry
L0564               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       L0558
                    std       $02,s
                    tst       $01,s
                    beq       L057E
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L057E               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
                    leas      $06,s
                    rts

                    emod
eom                 equ       *
                    end

