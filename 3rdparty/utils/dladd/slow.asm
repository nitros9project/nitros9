********************************************************************
* slow - sets the computer to slow 0.89MHz
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2017/09/09  David Ladd
* Started.
*

                    nam       slow
                    ttl       Slow Down

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

name                fcs       /slow/
                    fcb       edition

clearn              fcb       C$FORM
LCLEAR              equ       *-clearn

* Entry of program
Start               clrb
                    stb       >$FFD8
                    os9       F$Exit

                    emod
eom                 equ       *
                    end

