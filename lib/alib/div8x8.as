                    section   .bss
negcount            rmb       1
                    endsect

                    section   .text

;;; SDIV88
;;;
;;; Signed 8x8 division.
;;;
;;; Entry:  A = The divisor.
;;;         B = The dividend.
;;;
;;; Exit:   A = The remainder.
;;;         B = The quotient.

SDIV88:             clr       negcount,u
                    pshs      D
                    tst       ,s
                    bpl       testquo
                    lda       ,s
                    coma
                    inca
                    sta       ,s
                    inc       negcount,u
testquo             tst       1,s
                    bpl       ok
                    ldd       1,s
                    coma
                    adda      #$01
                    std       1,s
                    inc       negcount,u
ok                  puls      d
                    bsr       DIV88
                    dec       negcount,u
                    bne       goforit
                    pshs      d
                    lda       ,s
                    coma
                    inca
                    sta       ,s
                    lda       1,s
                    coma
                    inca
                    sta       1,s
                    puls      d
goforit             rts


;;; DIV88
;;;
;;; Unsigned 8x8 division.
;;;
;;; Entry:  A = The divisor.
;;;         B = The dividend.
;;;
;;; Exit:   A = The remainder.
;;;         B = The quotient.

DIV88:              pshs      A                   save divisor
                    lda       #8                  bit counter
                    pshs      A
                    clra                          initialize remainder

div1                aslb                          shift dividend & quotient
                    rola
                    cmpa      1,S                 trial subtraction needed
                    blo       div2
                    suba      1,S
                    incb

div2                dec       0,S                 count down # of bits
                    bne       div1
                    leas      2,S                 clean up stack
                    rts

                    endsect

