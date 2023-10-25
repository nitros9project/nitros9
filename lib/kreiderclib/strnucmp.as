* Disassembly by Os9disasm of strnucmp.r

                    section   code

strnucmp            pshs      y,u
                    ldu       8,s
                    ldd       10,s
                    beq       L0037
                    bra       L0017
L000a               ldd       10,s
                    subd      #1
                    std       10,s
                    beq       L0035
                    ldb       ,u+
                    beq       L0035
L0017               ldb       ,u
                    clra
                    pshs      d
                    lbsr      toupper
                    std       ,s
                    ldx       8,s
                    ldb       ,x+
                    stx       8,s
                    clra
                    pshs      d
                    lbsr      toupper
                    leas      2,s
                    subd      ,s++
                    beq       L000a
                    bra       L0037
L0035               clra
                    clrb
L0037               puls      y,u,pc

                    endsect

