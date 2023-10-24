* Disassembly by Os9disasm of calloc.r

                    section   code

calloc              pshs      u
                    ldd       4,s
                    ldx       6,s
                    pshs      x
                    lbsr      ccmult
                    pshs      d
                    lbsr      malloc
                    std       -2,s
                    beq       L001e
                    ldx       ,s
                    tfr       d,u
L0018               clr       ,u+
                    leax      -1,x
                    bne       L0018
L001e               leas      2,s
                    puls      u,pc

                    endsect

