* Disassembly by Os9disasm of clcompare.r

                    section   code

_lcmpr              ldd       2,s
                    cmpd      ,x
                    bne       L0019
                    ldd       4,s
                    cmpd      2,x
                    beq       L0019
                    bcs       L0016
                    lda       #1
                    andcc     #254
                    bra       L0019
L0016               clra
                    cmpa      #1
L0019               pshs      cc
                    ldd       1,s
                    std       5,s
                    puls      cc
                    leas      4,s
                    rts

                    endsect

