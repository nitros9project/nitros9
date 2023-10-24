********************************************************************
* Pipe - Pipe device descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    nam       Pipe
                    ttl       Pipe device descriptor

* Disassembled 98/08/23 21:15:32 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       pipe.d
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       READ.+WRITE.        mode byte
                    fcb       $00                 extended controller address
                    fdb       $0000               physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       DT.Pipe             device type:0=scf,1=rbf,2=pipe,3=scf
initsize            equ       *

name                fcs       /Pipe/
mgrnam              fcs       /PipeMan/
drvnam              fcs       /Piper/

                    emod
eom                 equ       *
                    end

