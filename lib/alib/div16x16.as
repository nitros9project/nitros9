*********************************************
* 16 x 16 bit integer divide

* OTHER MODULES NEEDED: none

* ENTRY: D = divisor
*        X = dividend

*  EXIT: X = quotient
*        D = remainder

                    nam       16x16               bit Divide
                    ttl       Assembler Library Module


                    section   .bss
negcount            rmb       1
                    endsect

                    section   .text

* Signed Divide
SDIV16
                    clr       negcount,u
                    pshs      D,X
                    tst       ,s
                    bpl       testquo
                    ldd       ,s
                    comb
                    coma
                    addd      #$0001
                    std       ,s
                    inc       negcount,u
testquo
                    tst       2,s
                    bpl       ok
                    ldd       2,s
                    comb
                    coma
                    addd      #$0001
                    std       2,s
                    inc       negcount,u
ok
                    puls      d,x
                    bsr       DIV16
                    dec       negcount,u
                    bne       goforit
                    pshs      d,x
                    ldd       ,s
                    coma
                    comb
                    addd      #$0001
                    std       ,s
                    ldd       2,s
                    coma
                    comb
                    addd      #$0001
                    std       2,s
                    puls      d,x
goforit
                    rts


* Unsigned Divide
DIV16
                    pshs      D,X                 save divisor & dividend
                    lda       #16                 bit counter
                    pshs      A
                    clra                          initialize remainder
                    clrb

div1
                    asl       4,S                 shift dividend & quotient
                    rol       3,S
                    rolb                          shift dividend into B
                    rola
                    cmpd      1,S                 trial subtraction reqd?
                    blo       div2
                    subd      1,S                 yes, do subtraction
                    inc       4,S                 increment quotient

div2
                    dec       ,S                  count down another bit
                    bne       div1
                    ldx       3,S                 get quotient
                    leas      5,S                 clean stack
                    rts

                    endsect

