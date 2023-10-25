********************************************************************
* VI - VRN (VIRQ/RAM/Nil driver) device descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    nam       VI
                    ttl       VRN (VIRQ/RAM/Nil driver) device descriptor

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

Edtn                equ       1
rev                 equ       0

                    mod       ModSize,DvcNam,Devic+Objct,ReEnt+rev,MgrNam,DrvNam

                    fcb       UPDAT.              access mode(s)
                    fcb       HW.Page             hardware page
                    fdb       $FF02               hardware port
                    fcb       OptSize
OptStart            fcb       DT.SCF
OptSize             equ       *-OptStart
MgrNam              fcs       "SCF"
DrvNam              fcs       "VRN"
DvcNam              fcs       "VI"
                    fcb       Edtn

                    emod
ModSize             equ       *
                    end
