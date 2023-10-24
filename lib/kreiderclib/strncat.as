* Disassembly by Os9disasm of strncat.r

                    section   code

strncat             pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       10,s
                    beq       L001e
L000b               ldb       ,x+
                    bne       L000b
                    leax      -1,x
L0011               ldb       ,u+
                    stb       ,x+
                    leay      -1,y
                    beq       L001c
                    tstb
                    bne       L0011
L001c               clr       ,x
L001e               ldd       4,s
                    puls      y,u,pc

                    endsect

