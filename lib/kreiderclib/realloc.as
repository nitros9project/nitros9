* Disassembly by Os9disasm of realloc.r

                    section   code

realloc             pshs      d,y,u
                    ldd       10,s
                    std       ,s
                    lbsr      malloc
                    std       ,s
                    beq       L003d
                    cmpd      8,s
                    beq       L003d
                    ldu       8,s
                    beq       L003d
                    tfr       d,x
                    ldu       8,s
                    ldd       -2,u
                    subd      #1
                    lslb
                    rola
                    lslb
                    rola
                    cmpd      10,s
                    bls       L002a
                    ldd       10,s
L002a               tfr       d,y
L002c               ldd       ,u++
                    std       ,x++
                    leay      -2,y
                    bne       L002c
                    ldd       8,s
                    pshs      d
                    lbsr      free
                    puls      d
L003d               puls      d,y,u,pc

                    endsect

