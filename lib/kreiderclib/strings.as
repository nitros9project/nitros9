* Disassembly by Os9disasm of strings.r

                    section   code

strcat              pshs      u
                    ldu       6,s
                    ldx       4,s
                    bsr       L001e
                    tfr       d,x
                    bra       L0012
strcpy              pshs      u
                    ldu       6,s
                    ldx       4,s
L0012               ldb       ,u+
                    stb       ,x+
                    bne       L0012
                    ldd       4,s
                    puls      u,pc
strend              ldx       2,s
L001e               ldb       ,x+
                    bne       L001e
                    leax      -1,x
                    tfr       x,d
                    rts

                    endsect

