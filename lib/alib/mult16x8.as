;;; MULT168
;;;
;;; 16x8 multiplication.
;;;
;;; Entry:  A = The multiplier.
;;;         X = The multiplicand.
;;;
;;; Exit:   A = Bits 23-16 of the product.
;;;         X = Bits 15-0 of the product.

                    section   .text

MULT168:            pshs      A,X                 save numbers
                    leas      -3,S                room for product
                    ldb       5,S                 get lsb of multiplicand
                    mul
                    std       1,S                 save partial product
                    ldd       3,S                 get mupltiplier & msb of multp.
                    mul
                    addb      1,S                 add lsb to msb
                    adca      #0                  add carry
                    std       0,S                 save sum of partial products
                    ldx       1,S                 get 2 lsb's
                    leas      6,S                 clean stack
                    rts

                    endsect

