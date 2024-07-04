                    export    _mktemp
                    
                    section   code

_mktemp             pshs      u
                    ldu       4,s
L0004               ldb       ,u+
                    beq       L0024
                    cmpb      #$58
                    bne       L0004
                    leau      -1,u
                    pshs      u
                    ldd       #5
L0013               sta       ,u+
                    decb
                    bne       L0013
                    puls      u
                    lbsr      _getpid
                    pshs      d,u
                    lbsr      itoa
                    leas      4,s
L0024               ldd       4,s
                    puls      u,pc

                    endsect

