********************************************************************
* mc09sdcdesc - Multicomp09 SDCC Device Descriptor Template
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2015/08/31  ncrook
* Created from 1773 descriptor template
*          2016/01/07  ncrook
* Bill Nobel pointed out the impact of reusing the Interlv and SAS
* bytes, so I have allocated 2 new bytes for SDOFFSET. Also, set the
* track and sector count correctly because these are needed for
* calculations by RBF during writes.

                    nam       mc09sddesc
                    ttl       Multicomp09 SDCC Device Descriptor Template

                    use       defsfile

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

* All of these values can be provided on the build line in the Makefile
* overriding the defaults below
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
Step                set       STP.6ms
                    ifndef    Cyls
Cyls                set       35
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
Interlv             set       3
                    endc
                    ifndef    SAS
SAS                 set       8
                    endc

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       DIR.!SHARE.!PEXEC.!PWRIT.!PREAD.!EXEC.!UPDAT. mode byte
                    fcb       HW.Page             extended controller address
                    fdb       $FFD8               physical controller (base) address
                    fcb       initsize-*-1        initialization table size
* In "The NitrOS-9 Technical Reference" describes this initialisation table.
* The first byte is at offset IT.DTP from the start of the module but is copied
* to PD.DTP in the path descriptor.
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
                    fcb       0                   IT.TFM
                    fdb       0                   IT.Exten
                    fcb       0                   IT.STOff
* SDcard driver-specific additions to the device descriptor go
* here. They do NOT get copied into the path descriptor; they
* cannot because there is NO ROOM. The driver has to access these
* values directly in the descriptor (see rbsuper/superdesc for how)

* High 16 bits of the 24-bit SDcard block address corresponding
* to the start of this disk image.
                    fdb       SDOFFSET
initsize            equ       *

                    ifne      DD
name                fcs       /DD/
                    else
name                fcb       'D,'0+DNum+$80
                    endc
mgrnam              fcs       /RBF/
drvnam              fcs       /mc09sd/

                    emod
eom                 equ       *
                    end
