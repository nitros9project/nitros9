* Disassembly by Os9disasm of l3tol.r

                    section   code

l3tol               pshs      u
                    ldu       4,s
                    ldd       6,s
                    addd      #1
                    bra       L0021
L000b               clra
                    clrb
                    stb       ,u
                    ldx       6,s
                    ldb       -1,x
                    stb       1,u
                    ldd       [6,s]
                    std       2,u
                    leau      4,u
                    ldd       6,s
                    addd      #3
L0021               std       6,s
                    ldd       8,s
                    addd      #-1
                    std       8,s
                    subd      #-1
                    bgt       L000b
                    puls      u,pc

                    endsect

