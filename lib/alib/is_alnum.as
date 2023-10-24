*****************************************

* See if character in "B" is a alpha letter a..z or A..Z or digit 0..9

* OTHER MODULES NEEDED: IS_ALPHA, IS_DIGIT

* ENTRY: B=character to test

* EXIT: CC zero=1 if alphanumeric, 0 if not


                    nam       Is                  Char AlphaNumeric?
                    ttl       Assembler Library Module


                    section   .text


IS_ALNUM
                    lbsr      IS_ALPHA
                    beq       yes                 upper/lowercase letters are alphanumeric
                    lbsr      IS_DIGIT            last chance to set flags.

yes
                    rts


                    endsect

