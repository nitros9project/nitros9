********************************************************************
* IDEDesc - IDE device descriptor
*
* IDE Defined Offsets
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------

                    nam       IDEDesc
                    ttl       IDE device descriptor

* IT.STP (offset $14)
*  Bit Meaning
*  --- ---------------------------------------------------------------
*
* IT.TYP (offset $15)
*  Bit Meaning
*  --- ---------------------------------------------------------------
*  7   Hard Disk:  1 = hard disk, 0 = floppy disk
*  6   Fudge LSN0: 0 = OS-9 disk, 1 = non-OS-9 disk
*
* IT.DNS (offset $16)
*  Bit Meaning
*  --- ---------------------------------------------------------------
*  1   Force CHS:     1 = Use CHS, 0 = Use LBA if drive supports it
*  0   Master/Slave:  0 = master, 1 = slave
*

* Interface Address
ADDR                set       $FF50

Master              set       %00000000
Slave               set       %00000001
ForceCHS            set       %00000010

DriveSel            set       Master


* Driver specific fields
ITDRV               set       $00
ITSTP               set       $00
ITTYP               set       $80
ITDNS               set       ITDRV

ITSOFS1             set       $00
ITSOFS2             set       $00
ITSOFS3             set       $00

* Default Geometry
Sides               set       $20
Cyls                set       $100
SectTrk             set       $0020
SectTrk0            set       $0020
Interlv             set       $01
SASiz               set       $08

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $0

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       $FF                 mode byte
                    fcb       HW.Page             extended controller address
                    fdb       ADDR                physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       DT.RBF              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       ITDRV               drive number
                    fcb       ITSTP               step rate
                    fcb       ITTYP               drive device type
                    fcb       ITDNS               media density
                    fdb       Cyls                number of cylinders (tracks)
                    fcb       Sides               number of sides
                    fcb       $01                 verify disk writes:0=on
                    fdb       SectTrk             # of sectors per track
                    fdb       SectTrk0            # of sectors per track (track 0)
                    fcb       Interlv             sector interleave factor
                    fcb       SASiz               minimum size of sector allocation
initsize            equ       *
*IDE Driver specific additions to the device descriptor go here
* NOTE: These do NOT get copied into the path descriptor; they
*       cannot due to the fact that there is simply NO ROOM in
*       the path descriptor to do so.  The driver must access
*       these values directly from the descriptor.
                    fcb       0,0,0,0,0,0,0,0,0

                    ifeq      DD-true
name                fcs       /DD/
                    else
name                fcc       /H/
                    fcb       '0+ITDRV+$80
                    endc
mgrnam              fcs       /RBF/
drvnam              fcs       /CCIDE/

                    emod
eom                 equ       *
                    end
