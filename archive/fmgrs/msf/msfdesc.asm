                    ifp1
Level               set       2
                    use       defsfile
                    endc

**************************************************************
* Device Descriptors for MSDos drives
*

                    mod       lenB,namB,DEVIC+OBJCT,REENT+1,mgrB,dvrB

                    fcb       $ff                 all modes
                    fcb       7                   extended port address
                    fdb       $ff40               port address
                    fcb       optB-*-1            option table size
                    fcb       DT.RBF              this is a RBF device
                    fcb       DNum                this is drive dnum to the controller
                    fcb       3                   step rate
                    fcb       %01000000+MSDOS.    non standard type
                    fcb       density
                    fdb       tracks
                    fcb       sides
                    fcb       1                   verify
optB                equ       *

                    ifeq      density&%100        ..not hi density
namB                fcb       dnam,'0+DNum+$80    device name
                    else
namB                fcb       dnam,'H,'0+DNum+$80 add H to device name
                    endc

mgrB                fcs       /MSF/
dvrB                fcs       /SDISK3/

                    emod
lenB                equ       *
                    end
