                    nam       D3
                    ttl       Disk Device Descriptor for SDISK3
*********************************
*
* Device Descriptor for D3 for SDISK3
*
*********************************

                    ifp1
                    use       defsfile
                    endc

Type                set       Devic+Objct
Revs                set       Reent+3

Step30              equ       0
Step20              equ       1
Step12              equ       2
Step06              equ       3

* MODULE HEADER AND FIXED INFORMATION
                    mod       DescEnd,DescName,Type,Revs,DscMgr,DscDrv
                    fcb       DIR.+SHARE.+PREAD.+PWRIT.+UPDAT.+EXEC.+PEXEC.

                    fcb       $07                 port bank
                    fdb       $FF40               port address

* USER CHANGEABLE SETTINGS
Drive               set       0                   drive number (0-3)
DrvTyp              set       $20                 5" floppy drive (double density on track 0)
StpRat              set       Step06              drive stepping rate code
Cyls                set       40                  number of cylinders (tracks per side)
SecTrk              set       18                  number of sectors per track
SecTr0              set       18                  number of sectors per track (track 0, side 0)
Density             set       1                   48 tpi, MFM
Sides               set       2                   number of sides (1 or 2)
Verify              set       1                   verify off

* OPTION TABLE
                    fcb       OptEnd-*-1          number of bytes in option section below
                    fcb       DT.RBF              device type = RBF
                    fcb       Drive               drive number
                    fcb       StpRat              step rate code
                    fcb       DrvTyp
                    fcb       Density
                    fdb       Cyls                number of cylinders
                    fcb       Sides
                    fcb       Verify              verify
                    fdb       SecTrk
                    fdb       SecTr0
                    fcb       3                   sector interleave offset factor
                    fcb       8                   minimum sector allocation size
                    fcb       0                   (reserved)
                    fdb       0                   (reserved)
                    fcb       $10                 sector/track offset (CoCo OS-9 disk format)
OptEnd              equ       *

* NAME STRINGS
                    ifne      DD
DescName            fcs       "DD"
                    else
DescName            fcb       'D,'0+Drive+$80
                    endc
DscMgr              fcs       'RBF'
DscDrv              fcs       'SDisk3'

                    emod
DescEnd             equ       *
                    end
