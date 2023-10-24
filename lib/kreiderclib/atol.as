* Disassembly by Os9disasm of atol.r

                    section   code

* class D external label equates

D0000               equ       $0000
D000a               equ       $000a

atol                pshs      u
                    ldu       4,s
                    clra
                    clrb
                    pshs      b
                    pshs      d
                    pshs      d
L000c               ldb       ,u+
                    cmpb      #$20
                    beq       L000c
                    cmpb      #9
                    beq       L000c
                    cmpb      #$2d
                    bne       L001e
                    stb       4,s
                    bra       L0045
L001e               cmpb      #$2b
                    bne       L0047
                    bra       L0045
L0024               ldd       2,s
                    pshs      d
                    ldd       2,s
                    pshs      d
                    leax      >L006c,pcr
                    lbsr      _lmul
                    ldb       -1,u
                    clra
                    subb      #$30
                    addd      2,x
                    std       2,s
                    ldd       #0
                    adcb      1,x
                    adca      ,x
                    std       ,s
L0045               ldb       ,u+
L0047               clra
                    leax      _chcodes,y
                    ldb       d,x
                    andb      #8
                    bne       L0024
                    tst       4,s
                    beq       L005d
                    leax      ,s
                    lbsr      _lneg
                    bra       L005f
L005d               leax      ,s
L005f               leau      _flacc,y
                    pshs      u
                    lbsr      _lmove
                    leas      5,s
                    puls      u,pc
L006c               neg       D0000
                    neg       D000a

                    endsect

