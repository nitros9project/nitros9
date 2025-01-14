                    export    _strucat
                    export    _strucpy
                    
                    section   code

_strucat            pshs      u
                    ldu       6,s
                    ldx       4,s
L0006               ldb       ,x+
                    bne       L0006
                    leax      -1,x
                    bra       L0014
_strucpy            pshs      u
                    ldu       6,s
                    ldx       4,s
L0014               ldb       ,u+
                    clra
                    pshs      d,x
                    lbsr      _toupper
                    leas      2,s
                    puls      x
                    stb       ,x+
                    bne       L0014
                    ldd       4,s
                    puls      u,pc

                    endsect

