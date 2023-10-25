* Disassembly by Os9disasm of time.r

                    section   code

* OS-9 system function equates

F$Time              equ       $15
F$STime             equ       $16

setime              ldx       2,s
                    os9       F$STime
                    lbra      _sysret
getime              ldx       2,s
                    os9       F$Time
                    lbra      _sysret

                    endsect

