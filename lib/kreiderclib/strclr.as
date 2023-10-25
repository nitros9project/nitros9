* Disassembly by Os9disasm of strclr.r

                    section   code

strclr              pshs      u
                    ldu       4,s
                    clrb
                    ldx       6,s
                    beq       L000f
L0009               stb       ,u+
                    leax      -1,x
                    bne       L0009
L000f               ldd       4,s
                    puls      u,pc

                    endsect

