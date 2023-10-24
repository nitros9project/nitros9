* Disassembly by Os9disasm of strspn.r

                    section   code

strspn              pshs      x,u
                    ldx       8,s
                    ldu       6,s
                    pshs      x
L0008               ldb       ,u+
                    beq       L0028
                    stb       3,s
                    lbsr      strchr
                    bne       L0008
                    bra       L0028
strcspn             pshs      x,u
                    ldx       8,s
                    ldu       6,s
                    pshs      x
L001d               ldb       ,u+
                    beq       L0028
                    stb       3,s
                    lbsr      strchr
                    beq       L001d
L0028               leau      -1,u
                    tfr       u,d
                    subd      8,s
                    leas      4,s
                    puls      u,pc

                    endsect

