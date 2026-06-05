********************************************************************
* SID - SIDIRQ device descriptor (/sid)
*
* Points an SCF device /sid at the SIDIRQ driver (sidirq.dr).
* Hardware port = $FF40 (X-SID base via MPI slot 1).
*
* Phase A: minimal SCF-managed descriptor.  All Sierra games already
* bundle scf.mn in their boot image, so no extra manager load needed.
********************************************************************

                    nam       SID
                    ttl       /sid device descriptor for SIDIRQ driver

                    ifp1
                    use       defsfile
                    endc

Edtn                equ       1
rev                 equ       0

                    mod       ModSize,DvcNam,Devic+Objct,ReEnt+rev,MgrNam,DrvNam

                    fcb       UPDAT.              access mode(s)
                    fcb       $FF                 hardware page (not paged)
                    fdb       $FF40               hardware port (X-SID base)
                    fcb       OptSize
OptStart            fcb       DT.SCF              device type
OptSize             equ       *-OptStart
MgrNam              fcs       "SCF"
DrvNam              fcs       "SIDIRQ"
DvcNam              fcs       "SID"
                    fcb       Edtn

                    emod
ModSize             equ       *
                    end
