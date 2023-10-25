* Disassembly by Os9disasm of strtok.r

                    section   bss

* Initialized Data (class G)
G0000               fcb       $00
                    fcb       $00

                    endsect

                    section   code

strtok              clra
                    clrb
                    pshs      d,u
                    ldu       6,s
                    bne       L000e
                    ldu       G0000,y
                    beq       L003a
L000e               ldx       8,s
                    pshs      x
                    pshs      u
                    lbsr      strspn
                    leas      4,s
                    leau      d,u
                    ldb       ,u
                    beq       L003a
                    stu       ,s
                    ldx       8,s
                    pshs      x
                    pshs      u
                    lbsr      strpbrk
                    leas      4,s
                    std       G0000,y
                    beq       L003a
                    tfr       d,x
                    clr       ,x+
                    stx       G0000,y
L003a               puls      d,u,pc

                    endsect

