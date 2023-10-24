* Disassembly by Os9disasm of bsearch.r

                    section   code

bsearch             pshs      d,x,y,u
                    ldu       10,s
                    clra
                    clrb
L0006               addd      #1
                    std       2,s
                    ldd       14,s
L000d               subd      2,s
                    bmi       L003d
                    ldd       14,s
                    addd      2,s
                    lsra
                    rorb
                    std       4,s
                    addd      #-1
                    pshs      d
                    ldd       18,s
                    lbsr      ccmult
                    addd      12,s
                    std       ,s
                    pshs      u
                    jsr       [20,s]
                    std       ,s++
                    beq       L0041
                    asla
                    ldd       4,s
                    bcc       L0006
                    addd      #-1
                    std       14,s
                    bra       L000d
L003d               clra
                    clrb
                    bra       L0043
L0041               ldd       ,s
L0043               leas      6,s
                    puls      u,pc

                    endsect

