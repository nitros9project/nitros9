********************************************************************
* Ident - Show module information
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   7      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   8      2003/04/11  Boisy G. Pitre
* Now reports modules with a lang of Obj6309.
*
*   8r1    2005/03/07  Boisy G. Pitre
* Fixed so that an unsupported language shows ????

                    nam       Ident
                    ttl       Show module information

* Disassembled 98/09/20 15:54:44 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       8

                    mod       eom,name,tylg,atrv,start,size

                    org       0
u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       2
u0006               rmb       2
u0008               rmb       2
dolink              rmb       1
short               rmb       1
modvfy              rmb       1
fperm               rmb       1
modptr              rmb       2
u0010               rmb       2
u0012               rmb       1
u0013               rmb       1
u0014               rmb       1
u0015               rmb       1
u0016               rmb       1
u0017               rmb       1
u0018               rmb       1
path                rmb       1
mtype               rmb       1
u001B               rmb       1
u001C               rmb       2
u001E               rmb       2
u0020               rmb       2
u0022               rmb       66
u0064               rmb       14
u0072               rmb       14
u0080               rmb       33
u00A1               rmb       71
u00E8               rmb       180
u019C               rmb       2048
size                equ       .

name                fcs       /Ident/
                    fcb       edition

                    ifne      DOHELP
HelpMsg             fcb       C$LF
                    fcc       "Use: Ident [-opts] <path> [-opts]"
                    fcb       C$LF
                    fcc       "  -m = module in memory"
                    fcb       C$LF
                    fcc       "  -s = short form"
                    fcb       C$LF
                    fcc       "  -v = don't verify CRC"
                    fcb       C$LF
                    fcc       "  -x = file in exec dir"
                    fcb       C$CR
                    endc

M_MInc              fcs       "Module header is incorrect!"
M_Hdr               fcs       "Header for: "
M_MSiz              fcs       "Module size:"
M_MCRC              fcs       "Module CRC: "
M_HdrP              fcs       "Hdr parity: "
M_ExOff             fcs       "Exec. off:  "
M_DatSz             fcs       "Data Size:  "
M_TLAR              fcs       "Ty/La At/Rv:"
M_Edtn              fcs       "Edition:    "
M_Mod               fcs       "mod,"
M_ReEn              fcs       "re-en,"
M_NonShr            fcs       "non-shr,"
M_RO                fcs       "R/O"
M_RW                fcs       "R/W"
M_Good              fcs       "(Good)"
M_Bad               fcc       "(Bad)"
                    fcb       $80+C$BELL

TypeTbl             fcb       T_BAD-TypeTbl
                    fcb       T_PR-TypeTbl
                    fcb       T_SU-TypeTbl
                    fcb       T_MU-TypeTbl
                    fcb       T_DA-TypeTbl
                    fcb       T_U5-TypeTbl
                    fcb       T_U6-TypeTbl
                    fcb       T_U7-TypeTbl
                    fcb       T_U8-TypeTbl
                    fcb       T_U9-TypeTbl
                    fcb       T_UA-TypeTbl
                    fcb       T_UB-TypeTbl
                    fcb       T_SY-TypeTbl
                    fcb       T_FM-TypeTbl
                    fcb       T_DRV-TypeTbl
                    fcb       T_DSC-TypeTbl
T_BAD               fcs       "bad type for"
T_PR                fcs       "Prog"
T_SU                fcs       "Subr"
T_MU                fcs       "Multi"
T_DA                fcs       "Data"
T_U5                fcs       "Usr 5"
T_U6                fcs       "Usr 6"
T_U7                fcs       "Usr 7"
T_U8                fcs       "Usr 8"
T_U9                fcs       "Usr 9"
T_UA                fcs       "Usr A"
T_UB                fcs       "Usr B"
T_SY                fcs       "System"
T_FM                fcs       "File Man"
T_DRV               fcs       "Dev Dvr"
T_DSC               fcs       "Dev Dsc"

LangTbl             fcb       L_DA-LangTbl
                    fcb       L_68-LangTbl
                    fcb       L_B09-LangTbl
                    fcb       L_PSC-LangTbl
                    fcb       L_C-LangTbl
                    fcb       L_COB-LangTbl
                    fcb       L_FOR-LangTbl
                    fcb       L_63-LangTbl
                    fcb       L_BAD-LangTbl
                    fcb       L_BAD-LangTbl
                    fcb       L_BAD-LangTbl
                    fcb       L_BAD-LangTbl
                    fcb       L_BAD-LangTbl
                    fcb       L_BAD-LangTbl
                    fcb       L_BAD-LangTbl
                    fcb       L_BAD-LangTbl
L_DA                fcs       "Data,"
L_68                fcs       "6809 obj,"
L_B09               fcs       "BASIC09 I-code,"
L_PSC               fcs       "PASCAL P-code,"
L_C                 fcs       "C I-code,"
L_COB               fcs       "COBOL I-code,"
L_FOR               fcs       "FORTRAN I-code,"
L_63                fcs       "6309 obj,"
L_BAD               fcs       "????"

start               leas      >u019C,u
                    sts       <u0006
                    tfr       y,d
                    subd      <u0006
                    std       <u0008
                    leay      <u0022,u
                    sty       <u0000
                    clr       <dolink
                    clr       <short
                    clr       <modvfy
                    clr       <u0018
                    lda       #READ.
                    sta       <fperm
                    ldd       #$0000
                    std       <u0002
                    std       <u0004
L0263               lda       ,x+
L0265               cmpa      #C$SPAC
                    beq       L0263
                    cmpa      #C$COMA
                    beq       L0263
                    cmpa      #C$CR
                    beq       L02BB
                    cmpa      #'-
                    beq       L027E
                    ldy       <u0002
                    bne       L0263
                    stx       <u0002
                    bra       L0263
L027E               lda       ,x+
                    cmpa      #'-
                    beq       L027E
                    cmpa      #'0
                    bcs       L0265
                    eora      #'M
                    anda      #$DF
                    bne       L0292
                    inc       <dolink
                    bra       L027E
L0292               lda       -$01,x
                    eora      #'S
                    anda      #$DF
                    bne       L029E
                    inc       <short
                    bra       L027E
L029E               lda       -$01,x
                    eora      #'V
                    anda      #$DF
                    bne       L02AA
                    inc       <modvfy
                    bra       L027E
L02AA               lda       -$01,x
                    eora      #'X
                    anda      #$DF
                    bne       L02B8
                    lda       #EXEC.+READ.
                    sta       <fperm
                    bra       L027E
L02B8               lbra      ShowHelp
L02BB               ldx       <u0002
                    lbeq      ShowHelp
                    leax      -$01,x
                    tst       <dolink
                    beq       L0314
                    pshs      u
                    clra
                    os9       F$Link
                    lbcs      L03D2
                    stu       <modptr
                    ldd       M$ID,u
                    cmpd      #M$ID12
                    beq       L02EB
                    puls      u
L02DD               leay      >M_MInc,pcr
                    lbsr      L05FC
                    lbsr      L0612
                    clrb
                    lbra      L03D2
L02EB               ldd       u0002,u
                    subd      #$0003
                    leax      d,u
                    puls      u
                    leay      <u0010,u
                    pshs      u
                    lda       #$03
L02FB               ldb       ,x+
                    stb       ,y+
                    deca
                    bne       L02FB
                    puls      u
                    lbsr      L03D5
                    ldu       <modptr
                    os9       F$UnLink
                    lbcs      L03D2
                    clrb
                    lbra      L03D2
L0314               lda       #$80
                    sta       <u00A1
                    lda       <fperm
                    os9       I$Open
                    lbcs      L03D2
                    sta       <path
                    ldd       #$0000
                    std       <u001E
                    std       <u0020
                    std       <u001C
L032C               ldd       <u0020
                    addd      <u001C
                    std       <u0020
                    bcc       L033B
                    ldd       <u001E
                    addd      #$0001
                    std       <u001E
L033B               pshs      u
                    ldx       <u001E
                    ldu       <u0020
                    lda       <path
                    os9       I$Seek
                    lbcs      L03D2
                    puls      u
                    leax      <u0072,u
                    stx       <modptr
                    ldy       #M$Port
                    os9       I$Read
                    bcc       L0360
                    cmpb      #E$EOF
                    bne       L03D2
                    bra       L03C1
L0360               ldd       ,x
                    cmpd      #M$ID12
                    lbne      L02DD
                    pshs      u,x
                    ldd       M$Size,x
                    std       <u001C
                    addd      <u0020
                    tfr       d,u
                    leau      -u0003,u
                    ldx       <u001E
                    bcc       L037C
                    leax      $01,x
L037C               lda       <path
                    os9       I$Seek
                    bcs       L03D2
                    puls      u,x
                    leax      <u0010,u
                    ldy       #$0003
                    lda       <path
                    os9       I$Read
                    bcs       L03D2
                    pshs      u,x
                    ldy       <modptr
                    ldd       M$Name,y
                    addd      <u0020
                    tfr       d,u
                    ldx       <u001E
                    bcc       L03A4
                    leax      $01,x
L03A4               lda       <path
                    os9       I$Seek
                    bcs       L03D2
                    puls      u,x
                    leax      >u0080,u
                    ldy       #$0021
                    lda       <path
                    os9       I$Read
                    bcs       L03D2
                    bsr       L03D5
                    lbra      L032C
L03C1               clrb
                    bra       L03D2
ShowHelp            equ       *
                    ifne      DOHELP
                    lda       #$01
                    leax      >HelpMsg,pcr
                    ldy       #$00BA
                    os9       I$WritLn
                    endc
                    clrb
L03D2               os9       F$Exit
L03D5               tst       <short
                    lbne      L0502
                    lbsr      L0612
                    leay      >M_Hdr,pcr
                    lbsr      L05FC
                    lbsr      L04E9
                    lbsr      L0612
                    leay      >M_MSiz,pcr
                    lbsr      L05FC
                    ldy       <modptr
                    ldd       M$Size,y
                    lbsr      L05D2
                    leay      >M_MCRC,pcr
                    lbsr      L05FC
                    lbsr      L0543
                    tst       <modvfy
                    bne       L041E
                    lbsr      L0553
                    tsta
                    beq       L0417
                    leay      >M_Bad,pcr
                    lbsr      L05FC
                    bra       L041E
L0417               leay      >M_Good,pcr
                    lbsr      L05FC
L041E               lbsr      L0612
                    leay      >M_HdrP,pcr
                    lbsr      L05FC
                    ldy       <modptr
                    ldb       M$Parity,y
                    lbsr      L0633
                    lbsr      L0612
                    ldy       <modptr
                    ldb       M$Type,y
                    stb       <mtype
                    andb      #TypeMask
                    cmpb      #Drivr
                    beq       L0444
                    cmpb      #Prgrm
                    bne       L0462
L0444               leay      >M_ExOff,pcr
                    lbsr      L05FC
                    ldy       <modptr
                    ldd       M$Exec,y
                    lbsr      L05D2
                    leay      >M_DatSz,pcr
                    lbsr      L05FC
                    ldy       <modptr
                    ldd       M$Mem,y
                    lbsr      L05D2
L0462               leay      >M_Edtn,pcr
                    lbsr      L05FC
                    ldb       <u0016
                    pshs      b
                    lbsr      L0633
                    ldb       #$05
                    lbsr      L0654
                    puls      b
                    clra
                    lbsr      L0649
                    lbsr      L0612
                    leay      >M_TLAR,pcr
                    lbsr      L05FC
                    ldb       <mtype
                    lbsr      L0633
                    ldy       <modptr
                    ldb       M$Revs,y
                    stb       <u001B
                    lbsr      L0633
                    lbsr      L0612
                    ldb       <mtype
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    leax      >TypeTbl,pcr
                    lda       b,x
                    leay      a,x
                    lbsr      L05FC
                    leay      >M_Mod,pcr
                    lbsr      L05FC
                    ldb       <mtype
                    andb      #LangMask
                    leax      >LangTbl,pcr
                    lda       b,x
                    leay      a,x
                    lbsr      L05FC
                    ldb       <u001B
                    bitb      #$80
                    beq       L04CD
                    leay      >M_ReEn,pcr
                    lbsr      L05FC
                    bra       L04D4
L04CD               leay      >M_NonShr,pcr
                    lbsr      L05FC
L04D4               bitb      #$40
                    beq       L04DE
                    leay      >M_RW,pcr
                    bra       L04E2
L04DE               leay      >M_RO,pcr
L04E2               lbsr      L05FC
                    lbsr      L0612
                    rts
L04E9               tst       <dolink
                    beq       L04F6
                    ldy       <modptr
                    ldd       M$Name,y
                    leay      d,y
                    bra       L04FA
L04F6               leay      >u0080,u
L04FA               lbsr      L05FC
                    lda       ,y
                    sta       <u0016
                    rts
L0502               ldb       #$06
                    lbsr      L0654
                    ldy       <modptr
                    ldb       M$Type,y
                    lbsr      L0633
                    bsr       L0543
                    tst       <modvfy
                    beq       L0519
                    lda       #$20
                    bra       L0520
L0519               bsr       L0553
                    tsta
                    bne       L0520
                    lda       #C$PERD
L0520               lbsr      L0608
                    lbsr      L0666
                    bsr       L04E9
                    ldx       <u0000
                    pshs      x
                    leax      <u0022,u
                    stx       <u0000
                    ldb       <u0016
                    inc       <u0018
                    clra
                    lbsr      L0692
                    clr       <u0018
                    puls      x
                    stx       <u0000
                    lbsr      L0612
                    rts
L0543               lda       #'$
                    lbsr      L0608
                    ldd       <u0010
                    lbsr      L066E
                    ldb       <u0012
                    lbsr      L0664
                    rts
L0553               ldd       #$FFFF
                    std       <u0013
                    stb       <u0015
                    pshs      u,y,x
                    leau      <u0013,u
                    tst       <dolink
                    beq       L0571
                    ldx       <modptr
                    ldy       M$Size,x
                    os9       F$CRC
                    lbcs      L03D2
                    bra       L058C
L0571               pshs      u,x
                    ldx       <u001E
                    ldu       <u0020
                    lda       <path
                    os9       I$Seek
                    puls      u,x
                    lbcs      L03D2
                    ldd       <u001C
                    pshs      b,a
                    bsr       L05BF
                    puls      b,a
                    std       <u001C
L058C               puls      u,y,x
                    lda       <u0013
                    cmpa      #CRCCon1
                    bne       L059E
                    ldd       <u0014
                    cmpd      #CRCCon23
                    bne       L059E
                    bra       L05A1
L059E               lda       #$3F
                    rts
L05A1               clra
                    rts
L05A3               lda       <path
                    ldx       <u0006
                    ldy       <u0008
                    cmpy      <u001C
                    bls       L05B2
                    ldy       <u001C
L05B2               os9       I$Read
                    sty       <u0004
                    rts
L05B9               bsr       L05A3
                    lbcs      L03D2
L05BF               ldy       <u0004
                    beq       L05B9
                    os9       F$CRC
                    ldd       <u001C
                    subd      <u0004
                    std       <u001C
                    bne       L05B9
                    std       <u0004
                    rts
L05D2               pshs      b,a
                    bsr       L0628
                    ldb       #$03
                    bsr       L0654
                    puls      b,a
                    bsr       L0649
                    bsr       L0612
                    rts
                    pshs      b,a
                    andb      #$F0
                    lsrb
                    lsrb
                    lsrb
                    lsrb
L05E9               lda       #'$
                    bsr       L0608
                    lbsr      L0682
                    ldb       #$02
                    bsr       L0654
                    puls      pc,b,a
                    pshs      b,a
                    andb      #$0F
                    bra       L05E9
L05FC               lda       ,y
                    anda      #$7F
                    bsr       L0608
                    lda       ,y+
                    bpl       L05FC
L0606               lda       #C$SPAC
L0608               pshs      x
                    ldx       <u0000
                    sta       ,x+
                    stx       <u0000
                    puls      pc,x
L0612               pshs      y,x,a
                    lda       #C$CR
                    bsr       L0608
                    leax      <u0022,u
                    stx       <u0000
                    ldy       #80
                    lda       #$01
                    os9       I$WritLn
                    puls      pc,y,x,a
L0628               pshs      a
                    lda       #'$
                    bsr       L0608
                    puls      a
                    bsr       L0660
                    rts
L0633               pshs      a
                    lda       #'$
                    bsr       L0608
                    puls      a
                    bsr       L0664
                    rts
                    pshs      a
                    lda       #'$
                    bsr       L0608
                    puls      a
                    bsr       L0682
                    rts
L0649               pshs      a
                    lda       #'#
                    bsr       L0608
                    puls      a
                    bsr       L0692
                    rts
L0654               pshs      b,a
L0656               tstb
                    ble       L065E
                    bsr       L0606
                    decb
                    bra       L0656
L065E               puls      pc,b,a
L0660               bsr       L066E
                    bra       L0666
L0664               bsr       L0674
L0666               pshs      a
                    lda       #C$SPAC
                    bsr       L0608
                    puls      pc,a
L066E               exg       a,b
                    bsr       L0674
                    tfr       a,b
L0674               pshs      b
                    andb      #$F0
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    bsr       L0682
                    puls      b
                    andb      #$0F
L0682               cmpb      #$09
                    bls       L0688
                    addb      #$07
L0688               addb      #$30
                    exg       a,b
                    lbsr      L0608
                    exg       a,b
                    rts

L0692               pshs      u,y,b
                    leau      <L06C3,pcr
                    clr       <u0017
                    ldy       #$0005
L069D               clr       ,s
L069F               subd      ,u
                    bcs       L06A7
                    inc       ,s
                    bra       L069F
L06A7               addd      ,u++
                    pshs      b
                    ldb       $01,s
                    exg       a,b
                    bsr       L06CD
                    exg       a,b
                    puls      b
                    cmpy      #$0002
                    bgt       L06BD
                    inc       <u0017
L06BD               leay      -$01,y
                    bne       L069D
                    puls      pc,u,y,b
L06C3               fdb       10000,1000,100,10,1
L06CD               tsta
                    beq       L06D2
                    sta       <u0017
L06D2               tst       <u0017
                    bne       L06DF
                    tst       <u0018
                    beq       L06DE
                    lda       #$20
                    bra       L06E1
L06DE               rts
L06DF               adda      #$30
L06E1               lbra      L0608

                    emod
eom                 equ       *
                    end
