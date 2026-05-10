*******************************************************************
* V0 - DragonPlus virtual (ram) disk descriptor
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   -      1986/??/??
* Original Compusense distribution version
*
* 2005-09-01, P.Harvey-Smith.
* 	Disassembled and cleaned up.
*

                    nam       V0
                    ttl       os9 device descriptor

* Disassembled 2005/05/31 16:27:46 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       $FF                 mode byte
                    fcb       $FF                 extended controller address
                    fdb       $FFFF               physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       $01                 device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 drive number
                    fcb       $00                 step rate
                    fcb       $80                 drive device type
                    fcb       $00                 media density:0=single,1=double
                    fdb       $0001               number of cylinders (tracks)
                    fcb       $01                 number of sides
                    fcb       $01                 verify disk writes:0=on
                    fdb       $001E               # of sectors per track
                    fdb       $001E               # of sectors per track (track 0)
                    fcb       $02                 sector interleave factor
                    fcb       $08                 minimum size of sector allocation
initsize            equ       *

name                equ       *
                    fcs       /V0/

mgrnam              equ       *
                    fcs       /RBF/

drvnam              equ       *
                    fcs       /VDISK/

                    emod
eom                 equ       *
                    end
