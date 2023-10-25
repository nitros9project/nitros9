* Disassembly by Os9disasm of uminmax.r

                    section   code

umin                ldd       2,s
                    cmpd      4,s
                    bls       L0009
                    ldd       4,s
L0009               rts
umax                ldd       2,s
                    cmpd      4,s
                    bcc       L0013
                    ldd       4,s
L0013               rts

                    endsect

