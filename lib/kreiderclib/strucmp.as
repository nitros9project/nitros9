* Disassembly by Os9disasm of strucmp.r

                    section   codd

strucmp             pshs      u
                    ldx       4,s
                    ldu       6,s
                    bra       L000c
L0008               ldb       ,u+
                    beq       L002a
L000c               ldb       ,u
                    clra
                    pshs      d,x
                    lbsr      toupper
                    leas      2,s
                    ldx       ,s
                    std       ,s
                    ldb       ,x+
                    clra
                    pshs      d,x
                    lbsr      toupper
                    leas      2,s
                    puls      x
                    subd      ,s++
                    beq       L0008
L002a               puls      u,pc

                    endsect

