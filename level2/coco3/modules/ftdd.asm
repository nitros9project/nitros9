********************************************************************
* FTDD - VRN (VIRQ/RAM/NIL driver) device descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    nam       FTDD
                    ttl       VRN (VIRQ/RAM/Nil driver) device descriptor

                    ifp1
                    use       defsfile
                    endc

Edtn                equ       1
rev                 equ       0

                    mod       ModSize,DvcNam,Devic+Objct,ReEnt+rev,MgrNam,DrvNam

                    fcb       UPDAT.              access mode(s)
                    fcb       $07                 hardware page
                    fdb       $FF01               hardware port
                    fcb       OptSize
OptStart            fcb       DT.SCF
OptSize             equ       *-OptStart
MgrNam              fcs       "SCF"
DrvNam              fcs       "VRN"
DvcNam              fcs       "FTDD"
                    fcb       Edtn

                    emod
ModSize             equ       *
                    end
