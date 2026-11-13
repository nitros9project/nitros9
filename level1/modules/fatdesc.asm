* FAT32/blkdrv descriptor template. Explicit partition offset and length.
                    use       defsfile
                    use       blkdrv.d
                    use       pcf.d
                    ifndef    FATBase
FATBase             equ       0
                    endc
                    ifndef    FATLength
FATLength           equ       0
                    endc
                    ifndef    FATPort
FATPort             equ       $FE90
                    endc
                    mod       eom,name,Devic+Objct,ReEnt+1,manager,driver
                    ifne      FATWrite
                    fcb       $87                 directory/read/write/execute
                    else
                    fcb       $85                 directory/read/execute only
                    endc
                    fcb       0                   port extension
                    fdb       FATPort
                    fcb       1                   only DTP copied to PD.OPT
                    fcb       DT.PCF
                    fcb       BD.Version
                    fdb       backend
                    fdb       FATPort             BC.Port
                    fcb       0                   unit
                    ifne      FATWrite
                    fcb       0                   writable backend
                    else
                    fcb       BF.ReadOnly
                    endc
                    fdb       0,0                 RAM base, blocks (unused)
                    ifne      FATVHD
                    fdb       (FATBase+FATLength-1)/65536,(FATBase+FATLength-1)&$FFFF
                    else
                    fdb       0,0                 RAM sparse base (unused)
                    endc
                    fdb       $FFFF               failure injection disabled
                    fdb       FATBase/65536,FATBase&$FFFF
                    fdb       FATLength/65536,FATLength&$FFFF
name
                    ifne      DD
                    fcs       /dd/
                    else
                    fcs       /pc0/
                    endc
manager             fcs       /pcf/
driver              fcs       /blkdrv/
backend
                    ifne      FATVHD
                    fcs       /llcocovhd/
                    else
                    fcs       /llwbsdblk/
                    endc
                    emod
eom                 equ       *
                    end
