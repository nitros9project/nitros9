********************************************************************
* rbmemdesc device descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    use       defsfile

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    ifdef     CART
* Geometry values equals the size of the cartridge memory: 32 8K blocks (262,144 bytes)
DRVTYP              equ       $80
TRACKS              equ       64       number of tracks
BLOCKSTART          equ       $80       starting block number
SECTRK              equ       16
SAS                 equ       1
modes               equ       DIR.+SHARE.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC.
                  ELSE
* Geometry values equals the size of the flash area: 5 8K blocks (40,960 bytes)
DRVTYP              equ       $20
TRACKS              equ       40        number of tracks
BLOCKSTART          equ       $78       starting block number
SECTRK              equ       4
SAS                 equ       4
modes               equ       DIR.+SHARE.+PREAD.+PEXEC.+READ.+EXEC.
                  ENDC

                    fcb       modes
                    fcb       HW.Page   extended controller address
                    fdb       $FF00+BLOCKSTART physical controller address (lower 8 bits used for start block)
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
                  IFNE    CART
name                fcs       /c0/
                  ELSE
name                fcs       /f0/
                  ENDC
                  ENDC

mgrnam              fcs       /rbf/
drvnam              fcs       /rbmem/

                    emod
eom                 equ       *
                    end
