********************************************************************
* Load - Load a module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.

                    nam       Load
                    ttl       Load a module

* Disassembled 98/09/10 23:08:07 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       4

                    mod       eom,name,tylg,atrv,start,size

                    org       0
u0000               rmb       450
size                equ       .

name                fcs       /Load/
                    fcb       edition

start               os9       F$Load
                    bcs       Exit
                    lda       ,x
                    cmpa      #C$CR
                    bne       start
                    clrb
Exit                os9       F$Exit

                    emod
eom                 equ       *
                    end
