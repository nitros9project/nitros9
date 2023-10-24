* Disassembly by Os9disasm of syscommon.r

                    section   code

_os9err             clra
                    std       errno,y
                    ldd       #-1
                    rts
_sysret             bcs       _os9err
                    clra
                    clrb
                    rts

                    endsect

