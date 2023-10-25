***********************************

* 16 x 8 Multiply (24 bit result)

* OTHER MODULES NEEDED: none

* ENTRY: A = multiplier
*        X = multiplicand

*  EXIT: A = product byte 1
*        X = product bytes 2 & 3

                    nam       16x8                bit Multiply
                    ttl       Assembler Library Module


                    section   .text

MULT168
                    pshs      A,X                 save numbers
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

