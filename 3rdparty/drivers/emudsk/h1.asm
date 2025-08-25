********************************************************************
* Emudsk - Virtual disk driver for CoCo emulators
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

optns               equ       *
                    fcb       DT.RBF              RBF device
                    fcb       $01                 drive number
                    fcb       $00                 step rate
                    fcb       $80                 type=nonstd,coco
                    fcb       $01                 double density
                    fdb       $71c6               tracks
                    fcb       $01                 one side
                    fcb       $01                 no verify
                    fdb       $0012               sectors/track
                    fdb       $0012               "", track 0
                    fcb       $03                 interleave
                    fcb       $20                 min allocation
optl                equ       *-optns

rnam                fcs       /H1/
fmnam               fcs       /RBF/
drvnam              fcs       /EmuDsk/

                    emod
rend                equ       *
                    end

