* Disassembly by Os9disasm of memset.r

                    section   code

memset              pshs      u
                    ldu       4,s
                    ldx       8,s
                    beq       L0010
                    ldb       7,s
L000a               stb       ,u+
                    leax      -1,x
                    bne       L000a
L0010               ldd       4,s
                    puls      u,pc

                    endsect

