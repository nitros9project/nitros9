* Disassembly by Os9disasm of fwrite.r

                    section   code

fwrite              pshs      d,x,u
                    ldu       8,s
                    clra
                    clrb
                    bra       L002b
L0008               ldd       10,s
                    bra       L0022
L000c               ldx       14,s
                    ldb       ,u+
                    pshs      d,x
                    lbsr      putc
                    leas      4,s
                    cmpd      #-1
                    beq       L0032
                    ldd       ,s
                    subd      #1
L0022               std       ,s
                    bne       L000c
                    ldd       2,s
                    addd      #1
L002b               std       2,s
                    cmpd      12,s
                    blt       L0008
L0032               leas      2,s
                    puls      d,u,pc

                    endsect

