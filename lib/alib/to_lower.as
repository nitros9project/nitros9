***************************************************

* Convert character in "B" to lowercase

* OTHER MODULES NEEDED: IS_UPPER

* ENTRY: B=ascii value of character to convert

* EXIT: B=ascii value of character in lowercase

* Note: control codes, etc. are not effected.


                    nam       Convert             Char to Lowercase
                    ttl       Assembler Library Module


                    section   .text

TO_LOWER
                    pshs      cc
                    lbsr      IS_UPPER            only uppercase can be converted
                    bne       tolox               no upper, exit
                    addb      #$20                make lowercase

tolox
                    puls      cc,pc

                    endsect

