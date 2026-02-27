********************************************************************
* ptidedesc - Pico-Thing PATA IDE Device Descriptor
*
* Device descriptor for the PATA hard disk on the Pico-Thing.
* Uses rbsuper.dr as the file manager driver and llide_pt.dr
* as the low-level PATA interface driver.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version for Pico-Thing

                  IFP1
                    use       defsfile
                    use       rbsuper.d
                    use       ide.d
                  ENDC

ITDRV               set       0         drive number (master)
ITSTP               set       0         step rate (not used for PATA)
ITTYP               set       $81       hard disk, drive size query on
ITDNS               set       0         media density: master (IDE ID 0)

Sides               set       $40       default geometry (LBA drive auto-detects)
Cyls                set       $007f
SectTrk             set       $0020
SectTrk0            set       $0020
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
                    fcb       0         IT.WPC
                    fcb       0         IT.OFS
                    fcb       0         IT.SOffset3
initsize            equ       *
                    fdb       lldrv     low-level driver reference
                    fcb       0         IT.MPI

                  IFNE    DD
name                fcs       /DD/
                  ELSE
name                fcc       /I/
                    fcb       '0+ITDNS+$80
                  ENDC

mgrnam              fcs       /RBF/
drvnam              fcs       /rbsuper/
lldrv               equ       *
                    fcs       /llide_pt/
                    fcb       0

                    emod
eom                 equ       *
                    end
