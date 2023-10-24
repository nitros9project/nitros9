* Disassembly by Os9disasm of pwcryp.r

                    section   code

pwcryp              pshs      u
                    ldu       4,s
                    ldd       #-1
                    pshs      d
                    pshs      b
                    leax      ,s
                    pshs      x
                    pshs      u
                    lbsr      strlen
                    std       ,s
                    pshs      u
                    lbsr      crc
                    leas      6,s
                    lda       ,s+
                    bsr       L002f
                    lda       ,s+
                    bsr       L002f
                    lda       ,s+
                    bsr       L002f
                    clr       ,u
                    ldd       4,s
                    puls      u,pc
L002f               pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L003b
                    puls      a
                    anda      #$0f
L003b               adda      #$30
                    cmpa      #$39
                    bls       L0043
                    adda      #7
L0043               sta       ,u+
                    rts

                    endsect

