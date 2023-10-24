* Disassembly by Os9disasm of strhcpy.r

                    section   code

strhcpy             pshs      u
                    ldu       4,s
                    ldx       6,s
L0006               ldb       ,x+
                    stb       ,u+
                    bpl       L0006
                    andb      #$7f
                    stb       -1,u
                    clr       ,u
                    ldd       4,s
                    puls      u,pc

                    endsect

