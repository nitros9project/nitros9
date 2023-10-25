* Disassembly by Os9disasm of strpbrk.r

                    section   code

strpbrk             pshs      x,u
                    ldx       8,s
                    ldu       6,s
                    pshs      x
L0008               clra
                    ldb       ,u+
                    beq       L0018
                    stb       3,s
                    lbsr      index
                    beq       L0008
                    leau      -1,u
                    tfr       u,d
L0018               leas      4,s
                    puls      u,pc

                    endsect

