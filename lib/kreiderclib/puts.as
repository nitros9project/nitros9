* Disassembly by Os9disasm of puts.r

                    section   code

puts                pshs      u
                    leax      _iob+13,y
                    ldd       4,s
                    pshs      d,x
                    bsr       fputs
                    ldb       #$0d
                    stb       1,s
                    lbsr      putc
                    leas      4,s
                    puls      u,pc
fputs               pshs      u
                    ldu       4,s
                    ldx       6,s
                    pshs      d,x
                    bra       L0026
L0021               stb       1,s
                    lbsr      putc
L0026               ldb       ,u+
                    bne       L0021
                    leas      4,s
                    puls      u,pc

                    endsect

