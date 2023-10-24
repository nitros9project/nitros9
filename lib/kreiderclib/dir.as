* Disassembly by Os9disasm of dir.r

                    section   code

* OS-9 system function equates

I$ChgDir            equ       $86

chdir               lda       #1
L0002               ldx       2,s
                    os9       I$ChgDir
                    lbra      _sysret
chxdir              lda       #4
                    bra       L0002

                    endsect

