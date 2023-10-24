********************************************************************
* CallDBG - Calls the debugger
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2005/04/04  Boisy G. Pitre
* Created.

                    nam       CallDBG
                    ttl       Calls the debugger

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
                    rmb       450
size                equ       .

name                fcs       /CallDBG/
                    fcb       edition

start
                    ldb       #$01
                    lda       #$02
                    os9       F$Debug             call debugger
* swi
                    lda       #$03
                    ldb       #$04
                    leax      start,pcr

exit                clrb
                    os9       F$Exit

                    emod
eom                 equ       *
                    end

