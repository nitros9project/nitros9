* Disassembly by Os9disasm of xtoa.r

                    section   code

utoa                clra
                    clrb
                    pshs      d,u
                    ldu       8,s
                    bra       L0018
itoa                clra
                    clrb
                    pshs      d,u
                    ldu       8,s
                    tst       6,s
                    bpl       L0018
                    inc       ,s
                    subd      6,s
                    std       6,s
L0018               ldd       6,s
                    pshs      d
                    ldd       #$000a
                    lbsr      ccumod
                    addb      #$30
                    stb       ,u+
                    ldd       6,s
                    pshs      d
                    ldd       #$000a
                    lbsr      ccudiv
                    std       6,s
                    bgt       L0018
                    tst       ,s
                    beq       L003c
                    ldb       #$2d
                    stb       ,u+
L003c               clr       ,u
                    ldd       8,s
                    pshs      d
                    lbsr      reverse
                    leas      4,s
                    puls      u,pc

                    endsect

