********************************************************************
* MR0 - myram RAM Disk Device Descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    nam       MR0
                    ttl       myram RAM Disk Device Descriptor

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    ifndef    RAMSize
RAMSize             set       128
                    endc
                    ifndef    SAS
SAS                 set       4
                    endc

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       DIR.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC. mode byte
                    fcb       $00                 extended controller address
                    fdb       $0000               physical controller address
                    fcb       initsize-*-1        initialization table size
                    fcb       DT.RBF              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 drive number
                    fcb       $00                 step rate
                    fcb       $00                 drive device type
                    fcb       $00                 media density:0=single,1=double
                    fdb       $0000               number of cylinders (tracks)
                    fcb       $01                 number of sides
                    fcb       $00                 verify disk writes:0=on
                    fdb       RAMSize             # of sectors per track
                    fdb       $0000               # of sectors per track (track 0)
                    fcb       $00                 sector interleave factor
                    fcb       SAS                 minimum size of sector allocation

initsize            equ       *

                    ifne      DD
name                fcs       /DD/
                    else
name                fcs       /R0/
                    endc
mgrnam              fcs       /RBF/
drvnam              fcs       /MRAM/

                    emod
eom                 equ       *
                    end
