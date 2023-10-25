********************************************************************
* End - OS-9 Level 3 End Marker
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??  Alan DeKok
* Created.

                    nam       End
                    ttl       OS-9 Level 3 End Marker

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Obj6309
attrev              set       ReEnt+rev
rev                 set       4
edition             set       1

                    mod       eom,name,tylg,attrev,start,0

name                fcs       /_end/
                    fcb       Edition

start               rts

                    emod
eom                 equ       *
                    end
