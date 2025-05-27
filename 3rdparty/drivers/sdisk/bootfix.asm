********************************************************************
* BootFix - D.P. Johnson boot track fix
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*   4    D.P. Johnson original version

                    nam       bootfix
                    ttl       D.P. Johnson boot track fix

* Disassembled 02/07/15 07:16:24 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       4

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       2
u0002               rmb       1
u0003               rmb       2
u0005               rmb       2
u0007               rmb       2
u0009               rmb       2
u000B               rmb       2
u000D               rmb       32
u002D               rmb       4
u0031               rmb       18
u0043               rmb       1
u0044               rmb       1
u0045               rmb       232
u012D               rmb       512
u032D               rmb       16
u033D               rmb       240
u042D               rmb       24826
size                equ       .

name                fcs       /bootfix/
                    fcb       edition

                    fcc       "(c) Copyright 1983 D.P.Johnson"

start               stu       <u0000
                    leay      u000D,u
L0037               lda       ,x+
                    cmpa      #C$SPAC
                    beq       L0037
                    cmpa      #PDELIM
                    beq       L0046
                    ldb       #E$BPNam
                    os9       F$Exit
L0046               sta       ,y+
                    lda       ,x+
                    cmpa      #C$CR
                    beq       L0052
                    cmpa      #C$SPAC
                    bne       L0046
L0052               lda       #PENTIR
                    ldb       #C$SPAC
                    std       ,y
                    leax      u000D,u
                    lda       #UPDAT.
                    os9       I$Open
                    bcc       L0064
L0061               os9       F$Exit
L0064               sta       <u0002
                    leax      <u002D,u
                    ldy       #256
                    os9       I$Read
                    bcs       L0061
                    lda       <DD.FMT,x
                    anda      #$03
                    cmpa      #$03
                    bne       L0089
                    ldd       DD.BIT,x
                    cmpd      #$0001
                    bne       L0089
                    lda       DD.TKS,x
                    cmpa      #18
                    beq       L008F
L0089               comb
                    ldb       #E$BTyp
                    os9       F$Exit
L008F               lda       DD.MAP,x
                    leax      >u012D,u
                    inca
                    clrb
                    tfr       d,y
                    lda       <u0002
                    os9       I$Read
                    bcs       L0061
                    lda       <u0002
                    ldx       #$0002
                    ldu       #(34*18*256)
                    os9       I$Seek
                    ldu       <u0000
                    bcs       L0061
                    leax      >u042D,u
                    ldy       #$0F00
                    os9       I$Read
                    bcs       L0061
                    leax      >u012D,u
                    ldd       #34*18
                    ldy       #$000F
                    os9       F$DelBit
                    bcs       L0061
                    ldd       #$04C8
                    os9       F$AllBit
                    bcs       L0061
                    lda       <u0002
                    ldx       #$0004
                    ldu       #$C800
                    os9       I$Seek
                    ldu       <u0000
                    bcs       L0115
                    leax      >u042D,u
                    ldy       #$0F00
                    os9       I$Write
                    bcs       L0115
                    leax      <u002D,u
                    lda       <$17,x
                    deca
                    clrb
                    tfr       d,u
                    ldx       #$0000
                    lda       <u0002
                    os9       I$Seek
                    ldu       <u0000
                    bcs       L0115
                    ldd       <u0045,u
                    addd      #$00FF
                    clrb
                    cmpd      #$6000
                    bls       L0118
                    ldb       #E$MemFul
L0115               os9       F$Exit
L0118               addd      #$0100
                    leax      >u032D,u
                    tfr       d,y
                    lda       <u0002
                    os9       I$Read
                    bcs       L0115
                    ldd       <u0043,u
                    std       <u0005
                    ldd       <u0045,u
                    std       <u0007
                    inc       <u0007
                    ldd       #18
                    std       <u0009
                    leay      >u033D,u
L013D               sty       <u000B
                    ldd       <u0005
                    clr       ,y
                    std       $01,y
                    ldd       <u0009
                    subd      <u0005
                    cmpb      <u0007
                    bls       L0150
                    ldb       <u0007
L0150               std       $03,y
                    pshs      b,a
                    ldb       <u0007
                    subd      $01,s
                    puls      y
                    ldd       <u0005
                    leax      >u012D,u
                    os9       F$AllBit
                    pshs      y
                    addd      ,s++
                    ldy       #18
                    os9       F$DelBit
                    ldy       <u000B
                    ldd       $03,y
                    addd      <u0005
                    addd      #18
                    std       <u0005
                    ldb       <u0007
                    subb      $04,y
                    stb       <u0007
                    beq       L018D
                    ldd       <u0009
                    addd      #$0024
                    std       <u0009
                    leay      $05,y
                    bra       L013D
L018D               lda       <u0002
                    ldx       #$0000
                    ldu       #$0100
                    os9       I$Seek
                    ldu       <u0000
                    bcc       L019F
L019C               os9       F$Exit
L019F               lda       <u0031,u
                    inca
                    clrb
                    tfr       d,y
                    leax      >u012D,u
                    lda       <u0002
                    os9       I$Write
                    bcs       L019C
                    lda       <u0044,u
                    deca
                    clrb
                    tfr       d,u
                    ldx       #$0000
                    lda       <u0002
                    os9       I$Seek
                    ldu       <u0000
                    bcs       L019C
                    ldy       #$0100
                    leax      >u032D,u
                    os9       I$Write
                    bcs       L019C
                    leax      >u042D,u
                    stx       <u0003
                    leay      >u033D,u
L01DB               lda       $02,y
                    clrb
                    tfr       d,u
                    ldx       #$0000
                    lda       <u0002
                    os9       I$Seek
                    ldu       <u0000
                    bcs       L019C
                    ldx       <u0003
                    lda       $04,y
                    clrb
                    pshs      y,x,b,a
                    tfr       d,y
                    lda       <u0002
                    os9       I$Write
                    bcs       L019C
                    puls      y,x,b,a
                    leax      d,x
                    stx       <u0003
                    leay      $05,y
                    tst       $04,y
                    bne       L01DB
                    clrb
                    os9       F$Exit
                    fcb       $01
                    fcb       $E9                 i

                    emod
eom                 equ       *
                    end
