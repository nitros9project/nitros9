* Disassembly by Os9disasm of memcmp.r

                    section   code

memcmp              pshs      y,u
                    ldx       6,s
                    cmpx      8,s
                    beq       L001d
                    ldu       8,s
                    ldy       10,s
                    beq       L001d
L000f               ldb       ,u+
                    subb      ,x+
                    beq       L0019
                    negb
                    sex
                    bra       L001f
L0019               leay      -1,y
                    bne       L000f
L001d               clra
                    clrb
L001f               puls      y,u,pc

                    endsect

