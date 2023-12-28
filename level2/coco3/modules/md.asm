********************************************************************
* MD - RAMMER Memory Device Descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    nam       MD
                    ttl       RAMMER Memory Device Descriptor

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       DIR.+SHARE.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC. mode byte
                    fcb       HW.Page             extended controller address
                    fdb       $FFE0               physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       DT.RBF              device type:0=scf,1=rbf,2=pipe,3=scf
initsize            equ       *

name                fcs       /MD/
mgrnam              fcs       /RBF/
drvnam              fcs       /Rammer/

                    emod
eom                 equ       *
                    end
