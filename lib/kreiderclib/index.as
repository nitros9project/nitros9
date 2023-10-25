* Disassembly by Os9disasm of index.r

                    section   code

strchr              ldx       2,s
L0002               ldb       ,x+
                    beq       L000e
                    cmpb      5,s
                    bne       L0002
                    tfr       x,d
                    bra       L0025
L000e               clra
                    rts
strrchr             ldx       2,s
                    ldd       #1
                    pshs      d
                    bra       L001f
L0019               cmpb      7,s
                    bne       L001f
                    stx       ,s
L001f               ldb       ,x+
                    bne       L0019
                    puls      d
L0025               subd      #1
                    rts

                    endsect

