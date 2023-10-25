* Disassembly by Os9disasm of cfinish.r

                    section   code

* OS-9 system function equates

F$Exit              equ       $06

exit                lbsr      _dumprof
                    lbsr      _tidyup
_exit               ldd       2,s
                    os9       F$Exit

                    endsect

