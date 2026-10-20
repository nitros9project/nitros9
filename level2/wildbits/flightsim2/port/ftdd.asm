********************************************************************
* FTDD - the VRN (VIRQ/RAM/Nil driver) device descriptor, the WildBits build: /FTDD, FS's frame timer
*
* NitrOS-9's level2/coco3/modules/ftdd.asm as it assembles for the WildBits: byte for byte the boot file's
* FTDD (33 bytes, CRC $6F5C22, on the K2 and the Jr2 alike). FS opens /FTDD and paces its frames with VRN's
* FS2 signal and tick counter (vrn.asm). The port address is the CoCo's and VRN never uses it.

                    nam       FTDD
                    ttl       VRN (VIRQ/RAM/Nil driver) device descriptor

                    ifp1
                    use       defsfile
                    endc

Edtn                equ       1
rev                 equ       0

                    mod       ModSize,DvcNam,Devic+Objct,ReEnt+rev,MgrNam,DrvNam

                    fcb       UPDAT.              access modes: read and write
                    fcb       $07                 the port's extended address (block $07, the CoCo's I/O)
                    fdb       $FF01               the port: the CoCo's PIA (VRN does not use it)
                    fcb       OptSize             the options' length
OptStart            fcb       DT.SCF              device type: SCF
OptSize             equ       *-OptStart
MgrNam              fcs       "SCF"               the file manager
DrvNam              fcs       "VRN"               the driver
DvcNam              fcs       "FTDD"              the device's name
                    fcb       Edtn                the edition

                    emod
ModSize             equ       *
                    end
