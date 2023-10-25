********************************************************************
* Rename - Rename a file
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.

                    nam       Rename
                    ttl       Rename a file

* Disassembled 98/09/11 01:35:46 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       6

                    mod       eom,name,tylg,atrv,start,size

                    org       0
parmptr             rmb       1
u0001               rmb       1
u0002               rmb       2
u0004               rmb       1
nextparm            rmb       2
u0007               rmb       1
u0008               rmb       24
pathopts            rmb       26
u003A               rmb       2
u003C               rmb       2
                    rmb       2
                    rmb       401
size                equ       .

name                fcs       /Rename/
                    fcb       edition

start               cmpd      #$0004              at least 3 chars + CR on cmd line?
                    lbcs      bpnam               branch if less than
                    stx       <parmptr            save parameter pointer
                    lda       #WRITE.             write mode
                    os9       I$Open              open file to rename in write mode
                    bcc       L0032               branch if ok
                    cmpb      #E$FNA              file not accessible?
                    bne       Exit                branch if any other error
                    ldx       <parmptr            else get pointer to file
                    lda       #DIR.+WRITE.        and try open as directory
                    os9       I$Open              try opening again
                    bcs       Exit                branch if error
L0032               stx       <nextparm           save off updated param pointer
                    ldb       #SS.Opt
                    leax      <pathopts,u
                    os9       I$GetStt            get path options
                    bcs       Exit                branch if error
                    os9       I$Close             close path to file
                    bcs       Exit                branch if error
                    ldb       <pathopts
                    cmpb      #$01
                    bne       bpnam
                    bsr       L00AE
                    bcs       Exit
                    ldx       <u0002
                    lda       #C$CR
                    sta       -1,x
                    ldx       <parmptr
                    lda       #READ.+WRITE.
                    os9       I$ChgDir
                    bcs       Exit
                    ldx       <nextparm
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
L0075               ldx       <nextparm
                    lda       #READ.
                    os9       I$Open
                    bcc       bpnam
                    cmpb      #E$PNNF
                    bne       bpnam
L0082               leax      <Dot,pcr            point to .
                    lda       #DIR.!UPDAT.        open as directory in update mode
                    os9       I$Open              do it!
                    bcs       Exit                branch if error
                    ldx       <u003A              get file directory entry ptr (PD.DCP)
                    ldu       <u003C
                    os9       I$Seek              seek
                    bcs       Exit                branch if error
                    ldx       <nextparm           get ptr to name to rename
                    ldy       <u0007
                    os9       I$Write
                    bcs       Exit
                    os9       I$Close
                    bcs       Exit
                    clrb
Exit                os9       F$Exit
bpnam               ldb       #E$BPNam
                    bra       Exit

Dot                 fcc       "."
                    fcb       C$CR

L00AE               ldx       <parmptr
                    bsr       L00F6
                    ldu       <parmptr
                    lda       ,u
                    cmpa      #PDELIM
                    beq       L00C7
                    lda       ,y
                    cmpa      #PDELIM
                    beq       L00C7
                    leau      <Dot,pcr
                    stu       <parmptr
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
                    ldx       <nextparm
                    os9       F$PrsNam
                    bcs       L00F2
                    lda       ,y
                    cmpa      #PDELIM
                    beq       L00F2
                    cmpb      #$1E
                    bcc       L00F2
                    stx       <nextparm
                    clra
                    std       <u0007
                    rts
L00F2               comb
                    ldb       #E$BPNam
                    rts
L00F6               os9       F$PrsNam
                    bcc       L0119
                    clrb
                    leau      ,x
L00FE               lda       ,u+
                    bpl       L0107
                    incb
                    cmpa      #C$PERD!$80
                    bne       L010C
L0107               incb
                    cmpa      #C$PERD
                    beq       L00FE
L010C               decb
                    beq       L0118
                    leay      -1,u
                    cmpb      #$03
                    bcc       L0118
                    clrb
                    bra       L0119
L0118               coma
L0119               rts

                    emod
eom                 equ       *
                    end

