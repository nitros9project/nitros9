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

SAS                 equ       4

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    ifdef     CART
* Geometry values equals the size of the cartridge memory: 32 8K blocks (262,144 bytes)
tracks              equ       256       number of tracks
blockstart          equ       $80       starting block number
modes               equ       DIR.+SHARE.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC.
                  ELSE
* Geometry values equals the size of the flash area: 5 8K blocks (40,960 bytes)
tracks              equ       40        number of tracks
blockstart          equ       $78       starting block number
modes               equ       DIR.+SHARE.+PREAD.+PEXEC.+READ.+EXEC.
                  ENDC

                    fcb       modes
                    fcb       HW.Page   extended controller address
                    fdb       $FF00+blockstart physical controller address (lower 8 bits used for start block)
                    fcb       initsize-*-1 initialization table size
                    fcb       DT.RBF    device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00       drive number
                    fcb       $00       step rate
                    fcb       $20       drive device type
                    fcb       $01       media density:0=single,1=double
                    fdb       tracks    number of tracks
                    fcb       $01       number of sides
                    fcb       $01       verify disk writes:0=on
                    fdb       4         # of sectors per track
                    fdb       4         # of sectors per track (track 0)
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
