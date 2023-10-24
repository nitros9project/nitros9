* Disassembly by Os9disasm of clshifts.r

                    section   code

_lshl               ldx       2,s
                    pshs      b
                    lbsr      _ltoacc
                    puls      b
                    tstb
                    beq       L0017
L000c               asl       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    decb
                    bne       L000c
L0017               puls      d
                    std       ,s
                    rts
_lshr               ldx       2,s
                    pshs      b
                    lbsr      _ltoacc
                    puls      b
                    tstb
                    beq       L0033
L0028               asr       ,x
                    ror       1,x
                    ror       2,x
                    ror       3,x
                    decb
                    bne       L0028
L0033               puls      d
                    std       ,s
                    rts

                    endsect

