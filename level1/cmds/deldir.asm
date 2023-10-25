********************************************************************
* Deldir - Delete a directory
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   3      ????/??/??
* From Tandy OS-9 Level Two VR 02.00.01.
*
*   4      2003/01/14  Boisy G. Pitre
* Updated to add -e instead of e to dir.
*
*          2003/06/21  Boisy G. Pitre
* Optimized for size.

                    nam       Deldir
                    ttl       Delete a directory

* Disassembled 98/09/10 23:18:11 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       4

                    mod       eom,name,tylg,atrv,start,size

                    org       0
parmptr             rmb       2
fpath               rmb       1
what2do             rmb       1
stats               rmb       24
u001C               rmb       4
u0020               rmb       4
u0024               rmb       10
u002E               rmb       6
u0034               rmb       15
u0043               rmb       1
u0044               rmb       1
u0045               rmb       1
u0046               rmb       2
u0048               rmb       2
buffer              rmb       336
size                equ       .

name                fcs       /Deldir/
                    fcb       edition

start               bsr       OpenPath
                    bcs       OpenErr
                    bsr       GetOpts
                    bcc       L002B
                    lbsr      PromptUser
                    bcs       OpenErr
                    lbsr      L01C3
                    bcs       OpenErr
                    lbsr      L0242
                    bcs       OpenErr
L002B               lda       <fpath
                    os9       I$Close
                    bcs       Exit
                    ldx       <parmptr
                    os9       I$Delete
                    bcs       Exit
                    lda       ,x
                    cmpa      #C$CR
                    bne       start
                    clrb
                    bra       Exit
OpenErr             pshs      b
                    lda       <fpath
                    os9       I$Close
                    puls      b
                    orcc      #Carry
Exit                os9       F$Exit


OpenPath            stx       <parmptr            save parameter pointer
                    lda       #READ.+WRITE.
                    os9       I$Open
                    bcs       L005D
                    sta       <fpath
                    bra       L0089
L005D               ldx       <parmptr
                    lda       #DIR.+READ.
                    os9       I$Open
                    bcs       L0090
                    sta       <fpath
L0068               ldx       <parmptr
                    os9       F$PrsNam
                    clra
                    incb
                    std       <u0046
                    lda       ,y
                    cmpa      #PDELIM
                    bne       L0089
                    lda       #C$CR
                    sta       ,y+
                    lda       #READ.+WRITE.
                    ldx       <parmptr
                    os9       I$ChgDir
                    bcs       L0090
                    sty       <parmptr
                    bra       L0068
L0089               leax      <-u001C,u
                    stx       <u0044
                    clr       <what2do
L0090               rts

GetOpts             lda       <fpath
                    ldb       #SS.OPT
                    leax      stats,u
                    os9       I$GetStt
                    bcs       L00AB
                    ldx       <u0044
                    lda       <PD.ATT,x
                    anda      #DIR.
                    beq       L00AA
                    clrb
                    orcc      #Carry
                    bra       L00AB
L00AA               clrb
L00AB               rts

Prompt              fcb       C$LF
                    fcc       "Deleting directory file. "
                    fcb       C$LF
                    fcc       "List directory, delete directory, or quit ? (l/d/q) "
PromptL             equ       *-Prompt

Cont                fcb       C$LF
                    fcc       "Continue? (y/n) "
ContL               equ       *-Cont

PromptUser
                    tstb
                    bne       L013E
                    lda       #$01
                    leax      <Prompt,pcr
                    ldy       #PromptL
                    os9       I$WritLn
L011B               bcs       L013E
                    bsr       ReadKey
                    bcs       L013E
                    ldb       <what2do
                    cmpb      #$01
                    bne       L012A
                    clrb
                    bra       L013E
L012A               bsr       L0145
L012C               bcs       L013E
                    leax      <Cont,pcr
                    ldy       #ContL
                    lda       #$01
                    os9       I$WritLn
                    bcs       L013E
                    bsr       ReadKey
L013E               rts
DIR                 fcc       "DIR"
                    fcb       C$CR
DIROPTS             fcc       "-E "
DIROPTL             equ       *-DIROPTS
L0145               pshs      u
                    leau      <buffer,u
                    pshs      u
                    ldb       #DIROPTL
                    leax      <DIROPTS,pcr
                    lbsr      L0270
                    ldx       <parmptr
                    ldd       <u0046
                    decb
                    lbsr      L0270
                    lda       #C$CR
L015E               sta       ,u+
                    tfr       u,d
                    subd      ,s
                    tfr       d,y
                    puls      u
                    leax      <DIR,pcr
                    lda       #Prgrm+Objct
                    clrb
                    os9       F$Fork
                    puls      u
                    bcs       L013E
                    os9       F$Wait
L0178               rts

ReadKey             leax      <buffer,u
                    ldy       #80
                    clra
                    os9       I$ReadLn
                    bcs       L01B8
L0187               lda       ,x+
                    cmpa      #C$SPAC             eat spaces
                    beq       L0187
                    anda      #$DF
                    cmpa      #'Y                 branch if Y
                    beq       L01AD
                    cmpa      #'L                 branch if L
                    beq       L01A9
                    cmpa      #'D                 branch if D
                    beq       L01A5
                    bra       L01B4
L01A5               ldb       #$01
                    bra       L01AF
L01A9               ldb       #$02
                    bra       L01AF
L01AD               ldb       #$04
L01AF               stb       <what2do
                    clrb
*         bra   L01B8
                    rts
L01B4               ldb       #$01
                    orcc      #Carry
L01B8               rts

DelDir              fcc       "DELDIR"
                    fcb       C$CR

DotDot              fcc       ".."
                    fcb       C$CR

L01C3               ldb       <what2do
                    bitb      #$05
                    beq       L0210
                    lda       <fpath
                    pshs      u
                    ldu       #DIR.SZ*2
L01D0               ldx       #$0000
                    os9       I$Seek
                    puls      u
L01D8               bsr       L0215
                    bcs       L0209
                    ldx       <parmptr
                    lda       #READ.+WRITE.
                    os9       I$ChgDir
                    bcs       L0214
                    ldy       <u0048
                    clrb
                    lda       #Prgrm+Objct
                    pshs      u
                    leau      <u0024,u
                    leax      <DelDir,pcr
                    os9       F$Fork
                    puls      u
                    bcs       L0214
                    os9       F$Wait
                    bcs       L0214
                    leax      <DotDot,pcr
                    lda       #READ.+WRITE.
                    os9       I$ChgDir
                    bcc       L01D8
L0209               cmpb      #E$EOF
                    bne       L0214
                    clrb
                    rts
*         bra   L0214
L0210               ldb       #$01
                    orcc      #Carry
L0214               rts
L0215               lda       <fpath
                    leax      <u0024,u
                    ldy       #DIR.SZ
                    os9       I$Read
                    bcs       L0238
                    lda       ,x
                    beq       L0215
                    os9       F$PrsNam
                    lda       -$01,y
                    anda      #$7F
                    sta       -$01,y
                    lda       #C$CR
                    sta       ,y
                    clra
                    incb
                    std       <u0048
L0238               rts

ATTR                fcc       "ATTR"
                    fcb       C$CR

ATTROPTS            fcc       " -d"
                    fcb       C$CR
ATTROPTL            equ       *-ATTROPTS

L0242               pshs      u
                    leau      <buffer,u
                    pshs      u
                    ldd       <u0046
                    decb
                    ldx       <parmptr
                    bsr       L0270
                    leax      <ATTROPTS,pcr
                    ldb       #ATTROPTL
                    bsr       L0270
                    tfr       u,d
                    subd      ,s
                    tfr       d,y
                    puls      u
                    leax      <ATTR,pcr
                    clrb
                    lda       #Prgrm+Objct
                    os9       F$Fork
                    bcs       L026D
                    os9       F$Wait
L026D               puls      u
                    rts
L0270               decb
                    lda       ,x+
                    sta       ,u+
                    tstb
                    bne       L0270
                    rts

                    emod
eom                 equ       *
                    end

