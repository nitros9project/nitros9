* Disassembly by Os9disasm of strncmp.r

                    section   code

strncmp             pshs      y,u
                    ldx       6,s
                    ldu       8,s
                    ldy       10,s
                    beq       L001f
                    bra       L0015
L000d               leay      -1,y
                    beq       L001f
                    ldb       ,u+
                    beq       L001f
L0015               ldb       ,u
                    subb      ,x+
                    beq       L000d
                    negb
                    sex
                    bra       L0021
L001f               clra
                    clrb
L0021               puls      y,u,pc

                    endsect

