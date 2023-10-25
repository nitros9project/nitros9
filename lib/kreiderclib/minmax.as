* Disassembly by Os9disasm of minmax.r

                    section   code

min                 ldd       2,s
                    cmpd      4,s
                    ble       L0009
                    ldd       4,s
L0009               rts
max                 ldd       2,s
                    cmpd      4,s
                    bge       L0013
                    ldd       4,s
L0013               rts

                    endsect

