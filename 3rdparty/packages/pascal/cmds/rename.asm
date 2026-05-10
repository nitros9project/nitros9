********************************************************************
* progname - program module
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*  -     Original Pascal 2.0 distribution version
*
* $Log$
* Revision 1.1  2002/04/05 08:23:28  roug
* Checked in Pascal 2.0
*
*

                    nam       Rename
                    ttl       program module

* Disassembled 02/04/05 10:06:07 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       /dd/defs/os9defs
                    endc
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       1
u0001               rmb       1
u0002               rmb       2
u0004               rmb       1
u0005               rmb       2
u0007               rmb       1
u0008               rmb       24
u0020               rmb       26
u003A               rmb       2
u003C               rmb       405
size                equ       .
name                equ       *
                    fcs       /Rename/
                    fcb       $05
start               equ       *
                    cmpd      #$0004
                    lbcs      L00A8
                    stx       <u0000
                    lda       #$02
                    os9       I$Open
                    bcc       L0032
                    cmpb      #$D6
                    bne       L00A5
                    ldx       <u0000
                    lda       #$82
                    os9       I$Open
                    bcs       L00A5
L0032               stx       <u0005
                    ldb       #$00
                    leax      <u0020,u
                    os9       I$GetStt
                    bcs       L00A5
                    os9       I$Close
                    bcs       L00A5
                    ldb       <u0020
                    cmpb      #$01
                    bne       L00A8
                    bsr       L00AE
                    bcs       L00A5
                    ldx       <u0002
                    lda       #$0D
                    sta       -$01,x
                    ldx       <u0000
                    lda       #$03
                    os9       I$ChgDir
                    bcs       L00A5
                    ldx       <u0005
                    ldb       <u0008
                    decb
                    lda       b,x
                    ora       #$80
                    sta       b,x
                    incb
                    cmpb      <u0004
                    bne       L0075
                    leay      ,x
                    ldx       <u0002
                    os9       F$CmpNam
                    bcc       L0082
L0075               ldx       <u0005
                    lda       #$01
                    os9       I$Open
                    bcc       L00A8
                    cmpb      #$D8
                    bne       L00A8
L0082               leax      <L00AC,pcr
                    lda       #$83
                    os9       I$Open
                    bcs       L00A5
                    ldx       <u003A
                    ldu       <u003C
                    os9       I$Seek
                    bcs       L00A5
                    ldx       <u0005
                    ldy       <u0007
                    os9       I$Write
                    bcs       L00A5
                    os9       I$Close
                    bcs       L00A5
                    clrb
L00A5               os9       F$Exit
L00A8               ldb       #$D7
                    bra       L00A5
L00AC               bgt       L00BB
L00AE               ldx       <u0000
                    bsr       L00F6
                    ldu       <u0000
                    lda       ,u
                    cmpa      #$2F
                    beq       L00C7
                    lda       ,y
                    cmpa      #$2F
                    beq       L00C7
                    leau      <L00AC,pcr
                    stu       <u0000
                    bra       L00CD
L00C7               leax      ,y
                    bsr       L00F6
                    bcs       L00F2
L00CD               stx       <u0002
                    stb       <u0004
                    leax      ,y
                    bsr       L00F6
                    bcc       L00CD
                    ldb       <u0004
                    beq       L00F2
                    ldx       <u0005
                    os9       F$PrsNam
                    bcs       L00F2
                    lda       ,y
                    cmpa      #$2F
                    beq       L00F2
                    cmpb      #$1E
                    bcc       L00F2
                    stx       <u0005
                    clra
                    std       <u0007
                    rts
L00F2               comb
                    ldb       #$D7
                    rts
L00F6               os9       F$PrsNam
                    bcc       L0119
                    clrb
                    leau      ,x
L00FE               lda       ,u+
                    bpl       L0107
                    incb
                    cmpa      #$AE
                    bne       L010C
L0107               incb
                    cmpa      #$2E
                    beq       L00FE
L010C               decb
                    beq       L0118
                    leay      -u0001,u
                    cmpb      #$03
                    bcc       L0118
                    clrb
                    bra       L0119
L0118               coma
L0119               rts
                    emod
eom                 equ       *
