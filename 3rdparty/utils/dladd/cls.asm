********************************************************************
* cls - Clear Screen
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      1986/12/27  David Ladd
* Started.
*

                    nam       cls
                    ttl       Clear Screen

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+Rev
rev                 set       $00
edition             set       1

                    org       0
                    rmb       $0100               for the stack
size                equ       .

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /cls/
                    fcb       edition

clearn              fcb       C$FORM
LCLEAR              equ       *-clearn

* Entry of program
Start               leax      <clearn,pc
                    ldy       #LCLEAR
                    lda       #1
                    os9       I$Write
                    clrb
                    os9       F$Exit

                    emod
eom                 equ       *
                    end

