* Disassembly by Os9disasm of cldiv.r


                    section   bss

* Uninitialized data (class B)
B0000               rmb       1
* Initialized Data (class G)

                    endsect

                    section   code

_ldiv               bsr       L0048
                    lda       1,s
                    beq       L0009
L0006               lbsr      _lnegx
L0009               leas      8,s
                    lbra      _lbexit
_lmod               lda       ,x
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    bne       L0029
                    ldd       ,x
                    std       _flacc,y
                    ldd       2,x
                    leax      _flacc,y
                    std       2,x
                    lbra      _lbexit
L0029               lda       2,s
                    sta       B0000,y
                    bsr       L005e
                    ldd       10,s
                    leax      _flacc,y
                    std       ,x
                    ldd       12,s
                    std       2,x
                    tst       B0000,y
                    bmi       L0006
                    leas      8,s
                    lbra      _lbexit
L0048               lda       ,x
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    bne       L005e
                    ldd       2,s
                    std       6,s
                    leas      6,s
                    ldd       #$002d
                    lbra      _rpterr
L005e               ldd       ,x
                    ldx       2,x
                    pshs      d,x
                    ldd       #0
                    pshs      d
                    std       _flacc,y
                    std       _flacc+2,y
                    tst       2,s
                    bpl       L007c
                    leax      2,s
                    lbsr      _lnegx
                    inc       1,s
L007c               tst       10,s
                    bpl       L0087
                    leax      10,s
                    lbsr      _lnegx
                    com       1,s
L0087               leax      _flacc,y
                    lda       #1
L008d               inca
                    asl       5,s
                    rol       4,s
                    rol       3,s
                    rol       2,s
                    bpl       L008d
                    sta       ,s
L009a               ldd       12,s
                    subd      4,s
                    std       12,s
                    ldd       10,s
                    sbcb      3,s
                    sbca      2,s
                    std       10,s
                    bcc       L00bc
                    ldd       12,s
                    addd      4,s
                    std       12,s
                    ldd       10,s
                    adcb      3,s
                    adca      2,s
                    std       10,s
                    andcc     #254
                    bra       L00be
L00bc               orcc      #1
L00be               rol       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    lsr       2,s
                    ror       3,s
                    ror       4,s
                    ror       5,s
                    dec       ,s
                    bne       L009a
                    jmp       [6,s]

                    endsect

