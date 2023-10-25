* r0 - rammer device descriptor
*
* $id: r0.asm,v 1.4 2004/02/6 01:00:00 R.Gault exp $
*
* edt/rev  yyyy/mm/dd  modified by
* comment
* Modified by R.Gault for Nocan 2004/2/1
* ------------------------------------------------------------------
Nocan               set       1                   0=64Meg 1=8Meg 2=16Meg based on "hardware" in use

                    nam       r0
                    ttl       rammer device descriptor

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    ifeq      Nocan
cylinder            set       $F80                in tracks of $40 sectors: 62 Meg
                    endc
                    ifeq      Nocan-1
cylinder            set       $180                6 Meg
                    endc
                    ifeq      Nocan-2
cylinder            set       $380                14 Meg
                    endc

sas                 set       $40
                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       dir.+share.+pread.+pwrit.+pexec.+read.+write.+exec. mode byte
                    fcb       7                   extended controller address
                    fdb       $ffe0               physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       dt.rbf              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 drive number
                    fcb       $00                 step rate
                    fcb       $40                 drive device type; non standard
                    fcb       $01                 media density:0=single,1=double
                    fdb       cylinder
                    fcb       $01                 number of sides
                    fcb       $01                 verify disk writes:0=on
                    fdb       sas                 # of sectors per track
                    fdb       sas                 # of sectors per track (track 0)
                    fcb       1                   sector interleave factor
                    fcb       sas                 minimum size of sector allocation
initsize            equ       *

name                fcs       /r0/

mgrnam              fcs       /rbf/
drvnam              fcs       /rammer/

                    emod
eom                 equ       *
                    end
