* Disassembly by Os9disasm of ltoa.r

                    section   code

* class D external label equates

D0000               equ       $0000
D000a               equ       $000a

ltoa                clra
                    clrb
                    pshs      d,u
                    ldu       10,s
                    tst       6,s
                    bpl       L0018
                    inc       ,s
                    leax      6,s
                    pshs      x
                    leax      8,s
                    lbsr      _lneg
                    lbsr      _lmove
L0018               ldd       8,s
                    pshs      d
                    ldd       8,s
                    pshs      d
                    leax      >L005e,pcr
                    lbsr      _lmod
                    ldb       3,x
                    addb      #$30
                    stb       ,u+
                    leax      6,s
                    pshs      x
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      >L005e,pcr
                    lbsr      _ldiv
                    lbsr      _lmove
                    ldd       8,s
                    addd      6,s
                    bne       L0018
                    tst       ,s
                    beq       L0051
                    ldb       #$2d
                    stb       ,u+
L0051               clr       ,u
                    ldd       10,s
                    pshs      d
                    lbsr      reverse
                    leas      4,s
                    puls      u,pc
L005e               neg       D0000
                    neg       D000a

                    endsect

