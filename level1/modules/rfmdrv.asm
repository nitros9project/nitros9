********************************************************************
* rfmdrv - remote file manager driver
*

                    nam       rfmdrv
                    ttl       Remote file manager driver

                    ifp1
                    use       defsfile
                    use       rfm.d
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $01

                    mod       eom,name,tylg,atrv,start,size


                    org       V.RFM
size                equ       .

                    fcb       DIR.+SHARE.+PEXEC.+PWRIT.+PREAD.+EXEC.+UPDAT.


name                fcs       /rfmdrv/
                    fcb       edition

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
*         lbra   Term

Init
Read
Write
GetStat
SetStat
                    nop
                    clrb
                    rts

                    emod
eom                 equ       *
                    end
