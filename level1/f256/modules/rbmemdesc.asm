********************************************************************
* rbmemdesc device descriptor
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    use       defsfile

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

modes               set       DIR.+SHARE.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC.

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

SECTRK              set       4
SAS                 set       4


                    IFDEF     C0
DRVTYP              set       $80
BLOCK               set       $80
TRACKS              set       256

                    ELSE
                    IFDEF     C1
DRVTYP              set       $80
BLOCK               set       $90
TRACKS              set       128

                    ELSE
                    IFDEF     F1
DRVTYP              set       $80
BLOCK               set       $40
TRACKS              set       512-40     take what FEU isn't using

                    ELSE
DRVTYP              set       $20
BLOCK               set       $78       FEU drive starting block number
TRACKS              set       40
DNum                set       0
modes               set       DIR.+SHARE.+PREAD.+PEXEC.+READ.+EXEC.

                    ENDC
                    ENDC
                    ENDC
                    ENDC


                    fcb       modes
                    fcb       HW.Page   extended controller address
                    fdb       $FF00+BLOCK physical controller address (lower 8 bits used for start block)
                    fcb       initsize-*-1 initialization table size
                    fcb       DT.RBF    device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       DNum      drive number
                    fcb       $00       step rate
                    fcb       DRVTYP    drive device type
                    fcb       $01       media density:0=single,1=double
                    fdb       TRACKS    number of tracks
                    fcb       $01       number of sides
                    fcb       $01       verify disk writes:0=on
                    fdb       SECTRK    # of sectors per track
                    fdb       SECTRK    # of sectors per track (track 0)
                    fcb       $01       sector interleave factor
                    fcb       SAS       minimum size of sector allocation
initsize            equ       *

                IFNE    DD
name                fcs       /dd/
                ELSE
                IFNE    C0
name                fcs       /c0/
                ELSE
                IFNE    C1
name                fcs       /c1/
                ELSE
                IFNE    F1
name                fcs       /f1/
                ELSE
name                fcs       /f0/
                ENDC
                ENDC
                ENDC
                ENDC

mgrnam              fcs       /rbf/
drvnam              fcs       /rbmem/

                    emod
eom                 equ       *
                    end
