* Disassembly by Os9disasm of strcmp.r

                    section   code

strcmp              pshs      u
                    ldx       4,s
                    ldu       6,s
                    bra       L000c
L0008               ldb       ,u+
                    beq       L0013
L000c               ldb       ,u
                    subb      ,x+
                    beq       L0008
                    negb
L0013               sex
                    puls      u,pc

                    endsect

