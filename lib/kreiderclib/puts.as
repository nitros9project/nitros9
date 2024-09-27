                    export    _puts
                    export    _fputs
                    
                    section   code

_puts               pshs      u
                    leax      __iob+13,y
                    ldd       4,s
                    pshs      d,x
                    bsr       _fputs
                    ldb       #$0d
                    stb       1,s
                    lbsr      _putc
                    leas      4,s
                    puls      u,pc
_fputs              pshs      u
                    ldu       4,s
                    ldx       6,s
                    pshs      d,x
                    bra       L0026
L0021               stb       1,s
                    lbsr      _putc
L0026               ldb       ,u+
                    bne       L0021
                    leas      4,s
                    puls      u,pc

                    endsect

