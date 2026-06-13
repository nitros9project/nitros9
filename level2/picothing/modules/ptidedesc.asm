********************************************************************
* ptidedesc - Pico-Thing PATA IDE Device Descriptor
*
* Device descriptor for the PATA hard disk on the Pico-Thing.
* Uses rbsuper.dr as the file manager driver and llide_pt.dr
* as the low-level PATA interface driver.
*
* Assembly-time defines:
*   DD=1    - names the descriptor "DD" (default drive)
*   SOFF1   - sector offset high byte (partition number * $20)
*             each unit of $20 = 2097152 sectors = 512MB
*             default 0 (no offset)
*   DRVID   - physical IDE drive: 0 = master (name /I), 1 = slave
*             (name /J). Sets both the rbsuper drive-table index
*             (PD.DRV) and the low-level device-select bit (PD.DNS
*             bit 0, the ATA DEV bit). Default 0.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version for Pico-Thing
*     2    2026/03/10 MarkM - add SOFF1 partitioning support
*     3    2026/06/13 MarkM - add DRVID master/slave support

                  IFP1
                    use       defsfile
                    use       rbsuper.d
                    use       ide.d
                  ENDC

* Sector offset for partitioning (default 0)
* SOFF1 = high byte of 24-bit sector offset ($20 per 512MB partition)
* PNUM = partition number for device name (0-7)
                    ifndef    SOFF1
SOFF1               set       0
                  ENDC
                    ifndef    PNUM
PNUM                set       SOFF1/$20
                  ENDC
                    ifndef    DRVID
DRVID               set       0
                  ENDC

ITDRV               set       DRVID     drive table index: 0=master 1=slave
ITSTP               set       0         step rate (not used for PATA)
ITTYP               set       $81       hard disk, drive size query on
ITDNS               set       DRVID     device select: bit 0 = ATA DEV bit

* Geometry: 512MB partition (2097152 sectors)
* 1024 cyls x 64 sides x 32 sectors/track = 2097152 sectors
Cyls                set       1024
Sides               set       64
SectTrk             set       32
SectTrk0            set       32
Interlv             set       $01
SAS                 set       $10

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                  IFNE    DD
                    fcb       DIR.+SHARE.+PEXEC.+PREAD.+PWRIT.+EXEC.+UPDAT.
                  ELSE
                    fcb       DIR.+SHARE.+PEXEC.+PREAD.+PWRIT.+EXEC.+UPDAT.
                  ENDC
                    fcb       HW.Page   extended controller address ($FF)
                    fdb       PTIDEBase physical controller address
                    fcb       initsize-*-1 initialization table size
                    fcb       DT.RBF    device type: RBF
                    fcb       ITDRV     drive number
                    fcb       ITSTP     step rate
                    fcb       ITTYP     drive type (hard disk)
                    fcb       ITDNS     media density
                    fdb       Cyls      number of cylinders
                    fcb       Sides     number of sides
                    fcb       $01       verify disk writes
                    fdb       SectTrk   sectors per track
                    fdb       SectTrk0  sectors per track (track 0)
                    fcb       Interlv   sector interleave factor
                    fcb       SAS       sector allocation size
                    fcb       0         IT.TFM
                    fdb       0         IT.Exten
                    fcb       0         IT.STOff
                    fcb       SOFF1     IT.SOFF1 (partition sector offset high byte)
                    fcb       0         IT.SOFF2
                    fcb       0         IT.SOFF3
initsize            equ       *
                    fdb       lldrv     low-level driver reference
                    fcb       0         IT.MPI

                  IFNE    DD
name                fcs       /DD/
                  ELSE
                  IFNE    DRVID
name                fcc       /J/       slave drive partitions
                  ELSE
name                fcc       /I/       master drive partitions
                  ENDC
                    fcb       '0+PNUM+$80
                  ENDC

mgrnam              fcs       /RBF/
drvnam              fcs       /rbsuper/
lldrv               equ       *
                    fcs       /llide_pt/
                    fcb       0

                    emod
eom                 equ       *
                    end
