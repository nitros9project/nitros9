********************************************************************
* RFMDesc - Remote File Manager Device Descriptor Template
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/03/28  Boisy G. Pitre
* Created.

                    nam       RFMDesc
                    ttl       Remote File Manager Device Descriptor Template

                    ifp1
                    use       defsfile
                    endc


tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    ifndef    DNum
DNum                set       0
                    endc

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       DIR.!SHARE.!PEXEC.!PWRIT.!PREAD.!EXEC.!UPDAT. mode byte
                    fcb       HW.Page             extended controller address
                    fdb       $0000+DNum          physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       DT.RFM              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       DNum                drive number
initsize            equ       *

                    ifne      DD
name                fcs       /DD/
                    else
name                fcc       /Y/
                    fcb       '0+DNum+$80
                    endc

mgrnam              fcs       /RFM/
drvnam              fcs       /RFMDrv/


                    emod
eom                 equ       *
                    end

