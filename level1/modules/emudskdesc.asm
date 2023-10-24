********************************************************************
* Emudsk - Virtual disk driver for CoCo emulators
* Descriptor Template
*
* $Id$
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*  01    Modified to compile under OS9Source            tjl 02/08/28
*  02    Corrected device address for MESS          R.Gault 11/12/24
*        Address not used by driver but still ....

                    ifp1
                    use       os9.d
                    endc

type                set       Devic+Objct
                    mod       rend,rnam,type,ReEnt+1,fmnam,drvnam
                    fcb       $FF                 all access modes
                    fcb       $07,$FF,$80         device address

                    fcb       optl                number of options

optns               EQU       *
                    FCB       DT.RBF              RBF device
                    FCB       DNum                drive number
                    FCB       $00                 step rate
                    FCB       $80                 type=nonstd,coco
                    FCB       $01                 double density
                    FDB       $71c6               tracks
                    FCB       $01                 one side
                    FCB       $01                 no verify
                    FDB       $0012               sectors/track
                    FDB       $0012               "", track 0
                    FCB       $03                 interleave
                    FCB       $20                 min allocation
optl                EQU       *-optns

                    IFNE      DD
rnam                fcs       /DD/
                    ELSE
rnam                fcb       'H,'0+DNum+$80
                    ENDC
fmnam               FCS       /RBF/
drvnam              FCS       /EmuDsk/

                    emod
rend                equ       *
                    end

