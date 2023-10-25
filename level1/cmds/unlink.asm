********************************************************************
* Unlink - Unlink memory module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??
* Original Tandy/Microware version

                    nam       Unlink
                    ttl       Unlink memory module

* Disassembled 02/04/03 22:32:26 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

                    org       0
u0000               rmb       512
size                equ       .

name                fcs       /Unlink/
                    fcb       edition

start               clra
                    ifgt      Level-1
                    os9       F$UnLoad
                    else
                    clrb
                    os9       F$Link
                    bcs       exit
                    os9       F$UnLink
                    bcs       exit
                    os9       F$UnLink
                    endc
                    bcs       exit
                    lda       ,x
                    cmpa      #C$CR
                    bne       start
                    clrb
exit                os9       F$Exit

                    emod
eom                 equ       *
                    end

