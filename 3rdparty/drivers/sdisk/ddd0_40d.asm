********************************************************************
* DD - Disk device descriptor for SDisk
*
* $Id$
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*        Created

                    nam       DD
                    ttl       Disk device descriptor for SDisk

                    ifp1
                    use       defsfile
                    endc

Type                set       Devic+Objct
Revs                set       Reent+1

* MODULE HEADER AND FIXED INFORMATION
                    mod       DescEnd,DescName,Type,Revs,DscMgr,DscDrv

                    fcb       DIR.+SHARE.+PREAD.+PWRIT.+UPDAT.+EXEC.+PEXEC.

                    fcb       HW.Page             port bank
                    fdb       DPort               port address

* USER CHANGEABLE SETTINGS
Drive               set       0                   drive number (0-3)
DrvTyp              set       TYP.5+TYP.CCF+TYP.FLP 5" floppy (double density on track 0)
StpRat              set       STP.6ms             drive stepping rate code
Cyls                set       40                  number of cylinders (tracks per side)
SecTrk              set       18                  number of sectors per track
SecTr0              set       SecTrk              number of sectors per track (track 0, side 0)
Density             set       DNS.MFM+DNS.STD     48 tpi, MFM
Sides               set       2                   number of sides (1 or 2)

* OPTION TABLE
                    fcb       OptEnd-*-1          number of bytes in option section below
                    fcb       DT.RBF              device type = RBF
                    fcb       Drive               drive number
                    fcb       StpRat              step rate code
                    fcb       DrvTyp
                    fcb       Density
                    fdb       Cyls                number of cylinders
                    fcb       Sides
                    fcb       0                   verify turned on
                    fdb       SecTrk
                    fdb       SecTr0
                    fcb       3                   sector interleave offset factor
                    fcb       8                   minimum sector allocation size
                    fcb       0                   (reserved)
                    fdb       0                   (reserved)
                    fcb       $10                 sector/track offset (CoCo OS-9 disk format)
OptEnd              equ       *

* NAME STRINGS
; The following is the original code which doesn't make sense. The line
; after is what it was probably assembling as, which also doesn't make
; sense. --WAA
;DescName fcb   'DD'
DescName            fcb       'D
DscMgr              fcs       'RBF'
DscDrv              fcs       'SDisk'

                    emod
DescEnd             equ       *
                    end
