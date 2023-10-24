********************************************************************
* ddiskdesc - ddisk Device Descriptor Template
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* Converted rb1773 to ddisk for Dragon disks.
* ------------------------------------------------------------------
*
* 2005-06-20, P.Harvey-Smith.
*	Added DragonAlpha define to correctly define the I/O port on the
*	Dragon ALpha/Professional
*
*
                    nam       ddiskdesc
                    ttl       ddisk Device Descriptor Template

* Disassembled 98/08/23 17:09:41 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    ifndef    DNum
DNum                set       0
                    endc
                    ifne      D35
Type                set       TYP.CCF+TYP.3
                    else
Type                set       TYP.CCF+TYP.5
                    endc
                    ifndef    Density
Density             set       DNS.MFM
                    endc
                    ifndef    Step
Step                set       STP.6ms
                    endc
                    ifndef    Cyls
Cyls                set       40
                    endc
                    ifndef    Sides
Sides               set       1
                    endc
Verify              set       1
                    ifndef    SectTrk
SectTrk             set       18
                    endc
                    ifndef    SectTrk0
SectTrk0            set       18
                    endc
                    ifndef    Interlv
Interlv             set       2
                    endc
                    ifndef    SAS
SAS                 set       8
                    endc

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       DIR.!SHARE.!PEXEC.!PWRIT.!PREAD.!EXEC.!UPDAT. mode byte
                    fcb       HW.Page             extended controller address

                    ifeq      DragonAlpha-1
                    fdb       $FF2C               physical controller address
                    else
                    fdb       $FF40               physical controller address
                    endc

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
initsize            equ       *

                    ifne      DD
name                fcs       /DD/
                    else
name                fcb       'D,'0+DNum+$80
                    endc
mgrnam              fcs       /RBF/
drvnam              fcs       /DDisk/

                    emod
eom                 equ       *
                    end

