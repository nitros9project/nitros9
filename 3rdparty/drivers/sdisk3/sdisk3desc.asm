********************************************************************
* SDisk3Desc - SDisk 3 Device Descriptor Template
*
* $Id$
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------

                    nam       SDisk3Desc
                    ttl       SDisk 3 Device Descriptor Template

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $01

DNum                set       0
Type                set       TYP.CCF+TYP.5
Density             set       DNS.MFM
Step                set       STP.6ms
Cyls                set       35
Sides               set       1
Verify              set       1
SectTrk             set       18
SectTrk0            set       18
Interlv             set       3
SAS                 set       8

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       DIR.!SHARE.!PEXEC.!PWRIT.!PREAD.!EXEC.!UPDAT. mode byte
                    fcb       HW.Page             extended controller address
                    fdb       $FF40               physical controller address
                    fcb       initsize-*-1        initalization table size
                    fcb       DT.RBF              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       DNum                drive number
                    fcb       Step                step rate
                    fcb       Type                drive device type
                    fcb       Density             media density:0=single,1=double
                    fdb       Cyls                number of cylinders (tracks)
                    fcb       Sides               number of sides
                    fcb       Verify              verify disk writes:0=on
                    fdb       SectTrk             # of sectors per track
                    fdb       SectTrk0            # of sectors per track (track 0)
                    fcb       Interlv             sector interleave factor
                    fcb       SAS                 minimum size of sector allocation
* SDisk 3 Offsets
                    fcb       0                   (reserved)
                    fdb       0                   (reserved)
                    fcb       $10                 sector/track offset (CoCo OS-9 disk format)
initsize            equ       *

                    ifne      DD
name                fcs       /DD/
                    else
name                fcb       'D,'0+DNum+$80
                    endc
mgrnam              fcs       'RBF'
drvnam              fcs       'SDisk3'

                    emod
eom                 equ       *
                    end
