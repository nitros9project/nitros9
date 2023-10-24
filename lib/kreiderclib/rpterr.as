* Disassembly by Os9disasm of rpterr.r

                    section   code

* OS-9 system function equates

F$Send              equ       $08
F$ID                equ       $0c

_rpterr             std       errno,y
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
                    rts

                    endsect

