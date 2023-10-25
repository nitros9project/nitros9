********************************************************************
* Piper - Pipe device driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??  ???
* Original OS-9/Tandy distribution

                    nam       Piper
                    ttl       Pipe device driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       6
size                equ       .

                    fcb       READ.+WRITE.

name                fcs       /Piper/
                    fcb       edition

start               equ       *
Init                clrb
                    rts
                    nop
Read                clrb
                    rts
                    nop
Write               clrb
                    rts
                    nop
GetStat             clrb
                    rts
                    nop
SetStat             clrb
                    rts
                    nop
Term                clrb
                    rts

                    emod
eom                 equ       *
                    end
