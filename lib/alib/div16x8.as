****************************************
* 16 x 8 bit integer divide

* Result must be an 8 bit value

* ENTRY: A = divisor
*        X = dividend

* EXIT:  A = remainder
*        B = quotient
*        all other registers (except CC) preserved

                    nam       16x8                bit Divide
                    ttl       Assembler Library Module


                    section   .bss
negcount            rmb       1
                    endsect

                    section   .text

* Signed Divide
SDIV168
                    clr       negcount,u
                    pshs      A,X
                    tst       ,s
                    bpl       testquo
                    lda       ,s
                    coma
                    inca
                    sta       ,s
                    inc       negcount,u
testquo
                    tst       1,s
                    bpl       ok
                    ldd       1,s
                    comb
                    coma
                    addd      #$0001
                    std       1,s
                    inc       negcount,u
ok
                    puls      a,x
                    bsr       DIV168
                    dec       negcount,u
                    bne       goforit
                    pshs      a,x
                    lda       ,s
                    coma
                    inca
                    sta       ,s
                    ldd       1,s
                    coma
                    comb
                    addd      #$0001
                    std       1,s
                    puls      a,x
goforit
                    rts


DIV168
                    ldb       #8                  bit counter
                    pshs      A,B,X               save count and divisor and value
                    tfr       X,D                 put dividend in D

div1
                    aslb                          shift dividend and quotient
                    rola
                    cmpa      0,S                 is trial subtraction successful?
                    bcs       div2
                    suba      0,S                 yes, subtract and set bit
                    incb                          in quotient

div2
                    dec       1,S                 count down bits
                    bne       div1                loop till done
                    leas      2,S                 clean stack
                    puls      X,PC                return

                    endsect

