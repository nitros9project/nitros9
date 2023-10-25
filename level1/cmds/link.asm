********************************************************************
* Link - Link to a module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.

                    nam       Link
                    ttl       Link to a module

* Disassembled 98/09/10 23:13:54 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       5

                    mod       eom,name,tylg,atrv,start,size

                    org       0
u0000               rmb       450
size                equ       .

name                fcs       /Link/
                    fcb       edition

start               clra
                    clrb
                    os9       F$Link
                    bcs       L0026
                    lda       ,x+
                    cmpa      #C$COMA
                    beq       start
                    lda       ,-x
                    cmpa      #C$CR
                    bne       start
                    clrb
L0026               os9       F$Exit

                    emod
eom                 equ       *
                    end

