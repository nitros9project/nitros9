********************************************************************
* Echo - Echo text
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.

                    nam       Echo
                    ttl       Echo text

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       5

                    mod       eom,name,tylg,atrv,start,size

                    org       0
                    rmb       200       stack
size                equ       .

name                fcs       /Echo/
                    fcb       edition

start               tfr       d,y       transfer parameter count to Y
                    lda       #1        we are writing to standard out
                    os9       I$WritLn  write the line
                    bcs       ex@       branch if an error
                    clrb                clear error and carry
ex@                 os9       F$Exit    exit

                    emod
eom                 equ       *
                    end

