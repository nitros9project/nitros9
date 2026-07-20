********************************************************************
* nzdesc - Descriptor for the /Nil and /Zero pseudo-devices
*
* One source, two builds (selected by the NIL assembly symbol; an
* undefined NIL counts as 0 via the condundefzero pragma):
*   default          -> module "Zero": device /Zero, driver "ZDrv"
*   assemble -DNIL=1  -> module "Nil" : device /Nil,  driver "NDrv"
*
* Both use the SCF file manager and the lean nzdrv driver. The hardware
* port below is required by the descriptor format but is never accessed
* by the driver, so its value is don't-care. (RBF/SCF device names are
* case-insensitive, so /zero and /nil work too.)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/06/17  Mark Murray
* Created.

                  IFP1
                    use       defsfile
                  ENDC

Edtn                equ       1
rev                 equ       0

                    mod       ModSize,DvcName,Devic+Objct,ReEnt+rev,MgrName,DrvName

                    fcb       UPDAT.    access mode(s): read + write
                    fcb       HW.Page   hardware page
                    fdb       $FF00     hardware port (unused by the driver)
                    fcb       OptSize
OptStart            fcb       DT.SCF    device type: SCF
OptSize             equ       *-OptStart
MgrName             fcs       "SCF"
                  IFNE    NIL
DrvName             fcs       "NDrv"
                  ELSE
DrvName             fcs       "ZDrv"
                  ENDC
                  IFNE    NIL
DvcName             fcs       "Nil"
                  ELSE
DvcName             fcs       "Zero"
                  ENDC
                    fcb       Edtn

                    emod
ModSize             equ       *
                    end
