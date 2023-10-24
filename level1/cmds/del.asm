********************************************************************
* Del - File deletion utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   6      2003/01/13  Boisy G. Pitre
* Now option can be anywhere on command line, and all files will be
* deleted.  Also made smaller.

                    nam       Del
                    ttl       File deletion utility

* Disassembled 98/09/10 22:43:13 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       6

                    mod       eom,name,tylg,atrv,start,size

                    org       0
amode               rmb       1
                    rmb       250
stack               rmb       200
size                equ       .

name                fcs       /Del/
                    fcb       edition

                    ifne      DOHELP
HelpMsg             fcb       C$LF
                    fcc       "Use: Del [-x] <path> {<path>} [-x]"
                    fcb       C$CR
                    endc

start               lda       ,x                  get first char on command line
                    cmpa      #C$CR               carriage return?
                    beq       ShowHelp            if so, no params, show help
                    lda       #READ.
                    sta       <amode
                    pshs      x                   save param pointer
                    bsr       GetOpts             get opts
                    puls      x                   get param pointer
L0043               lda       <amode
                    os9       I$DeletX
                    bcs       Exit
                    lda       ,x
                    cmpa      #C$CR
                    bne       L0043
ExitOk              clrb
Exit                os9       F$Exit

GetOpts             ldd       ,x+
                    cmpa      #C$SPAC
                    beq       GetOpts
                    cmpa      #C$COMA
                    beq       GetOpts
                    cmpa      #C$CR
                    beq       Return
                    cmpa      #'-
                    bne       SkipName
                    eorb      #'X
                    andb      #$DF
                    bne       ShowHelp
                    lda       #EXEC.
                    sta       <amode
                    ldd       #$2020
                    std       -1,x                write over option
SkipName            lda       ,x+
                    cmpa      #C$SPAC
                    beq       GetOpts
                    cmpa      #C$COMA
                    beq       GetOpts
CheckCR             cmpa      #C$CR
                    bne       SkipName
Return              rts

ShowHelp            equ       *
                    ifne      DOHELP
                    leax      >HelpMsg,pcr
                    ldy       #80
                    lda       #2                  stderr
                    os9       I$WritLn            write help
                    endc
                    bra       ExitOk

                    emod
eom                 equ       *
                    end

