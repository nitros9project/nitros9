* Disassembly by Os9disasm of cshifts.r

                    section   code

ccasr               tstb
                    beq       L0022
L0003               asr       2,s
                    ror       3,s
                    decb
                    bne       L0003
                    bra       L0022
cclsr               tstb
                    beq       L0022
L000f               lsr       2,s
                    ror       3,s
                    decb
                    bne       L000f
                    bra       L0022
ccasl               tstb
                    beq       L0022
L001b               asl       3,s
                    rol       2,s
                    decb
                    bne       L001b
L0022               ldd       2,s
                    pshs      d
                    ldd       2,s
                    std       4,s
                    ldd       ,s
                    leas      4,s
                    rts

                    endsect

