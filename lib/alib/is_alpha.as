*****************************************

* See if character in "B" is a alpha letter a..z or A..Z

* OTHER MODULES NEEDED: IS_LOWER, IS_UPPER

* ENTRY: B=character to test

* EXIT: CC zero=1 if alpha, 0 if not

                    nam       Is                  Char Alphabetic?
                    ttl       Assembler Library Module


                    section   .text


IS_ALPHA
                    lbsr      IS_UPPER
                    beq       yes                 uppercase letters are alpha
                    lbsr      IS_LOWER            last chance to set flags.

yes
                    rts


                    endsect

