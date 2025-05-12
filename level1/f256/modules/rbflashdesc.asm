********************************************************************
* rbflashdesc device descriptor
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

                IFDEF     CART
* Geometry values equals the size of the cartridge memory: 32 8K blocks (262,144 bytes)
DEVTYP              equ       $80       Bit 7 High means HDD
SAS                 equ       1
TRACKS              equ       64        number of tracks
TRACKSIZ            equ       16        sectors per track
BLOCKSTART          equ       $80       starting block number
MODES               equ       DIR.+SHARE.+PREAD.+PWRIT.+PEXEC.+READ.+WRITE.+EXEC.
                ELSE
* Geometry values equals the size of the F256 motherboard Flash area: 5 8K blocks (40,960 bytes)
DEVTYP              equ       $80       Bit 7 High means HDD
SAS                 equ       1
TRACKS              equ       40        number of tracks
TRACKSIZ            equ       4         sectors per track
BLOCKSTART          equ       $78       starting block number
MODES               equ       DIR.+SHARE.+PREAD.+PEXEC.+READ.+EXEC.
                ENDC

                    fcb       MODES
                    fcb       HW.Page   extended controller address
                    fdb       $FF00+BLOCKSTART physical controller address (lower 8 bits used for start block)
                    fcb       initsize-*-1 initialization table size
                    fcb       DT.RBF    device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00       drive number
                    fcb       $00       step rate
                    fcb       DEVTYP    drive device type
                    fcb       $01       media density:0=single,1=double
                    fdb       TRACKS    number of tracks
                    fcb       $01       number of sides
                    fcb       $01       verify disk writes:0=on
                    fdb       TRACKSIZ  # of sectors per track
                    fdb       TRACKSIZ  # of sectors per track (track 0)
                    fcb       $01       sector interleave factor
                    fcb       SAS       minimum size of sector allocation
initsize            equ       *

                IFNE    DD
name                fcs       /dd/
                ELSE
                IFNE    CART
name                fcs       /cf/
                ELSE
name                fcs       /f0/
                ENDC
                ENDC

mgrnam              fcs       /rbf/
drvnam              fcs       /rbflash/

                    emod
eom                 equ       *
                    end
