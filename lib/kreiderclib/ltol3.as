* Disassembly by Os9disasm of ltol3.r

                    section   code

ltol3               pshs      u
                    ldu       4,s
                    leau      1,u
                    bra       L001d
L0008               ldx       6,s
                    ldb       1,x
                    stb       -1,u
                    ldx       6,s
                    ldd       2,x
                    std       ,u
                    ldd       6,s
                    addd      #4
                    std       6,s
                    leau      3,u
L001d               ldd       8,s
                    addd      #-1
                    std       8,s
                    subd      #-1
                    bgt       L0008
                    puls      u,pc

                    endsect

