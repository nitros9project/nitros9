                    export    _reverse
                    
                    section   code

_reverse            pshs      u
                    ldu       4,s
                    pshs      u
                    pshs      u
                    lbsr      _strlen
                    leas      2,s
                    addd      ,s++
                    tfr       d,x
                    bra       L001b
L0013               ldb       ,u
                    lda       ,-x
                    sta       ,u+
                    stb       ,x
L001b               pshs      x
                    cmpu      ,s++
                    bcs       L0013
                    ldd       4,s
                    puls      u,pc

                    endsect

