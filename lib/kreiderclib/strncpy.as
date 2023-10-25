* Disassembly by Os9disasm of strncpy.r

                    section   code

strncpy             pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       10,s
                    beq       L001c
L000b               ldb       ,u+
                    stb       ,x+
                    leay      -1,y
                    beq       L001c
                    tstb
                    bne       L000b
L0016               clr       ,x+
                    leay      -1,y
                    bne       L0016
L001c               ldd       6,s
                    puls      y,u,pc

                    endsect

