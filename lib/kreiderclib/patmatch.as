* Disassembly by Os9disasm of patmatch.r

                    section   code

patmatch            pshs      u
                    ldu       6,s
                    leas      -2,s
                    bra       L0041
L0008               cmpb      #$2a
                    bne       L0023
L000c               ldb       11,s
                    clra
                    pshs      d
                    pshs      u
                    ldd       10,s
                    pshs      d
                    bsr       patmatch
                    leas      6,s
                    bne       L005b
                    ldb       ,u+
                    bne       L000c
                    bra       L0060
L0023               tst       ,u
                    beq       L0060
                    cmpb      #$3f
                    bne       L002f
                    leau      1,u
                    bra       L0041
L002f               ldb       ,u+
                    tst       11,s
                    beq       L003d
                    clra
                    pshs      d
                    lbsr      toupper
                    leas      2,s
L003d               cmpb      1,s
                    bne       L0060
L0041               ldx       6,s
                    ldb       ,x+
                    stx       6,s
                    tst       11,s
                    beq       L0053
                    clra
                    pshs      d
                    lbsr      toupper
                    leas      2,s
L0053               stb       1,s
                    bne       L0008
                    ldb       ,u
                    bne       L0060
L005b               ldd       #1
                    bra       L0062
L0060               clra
                    clrb
L0062               leas      2,s
                    puls      u,pc

                    endsect

