***************************************************

* Convert character in "B" to uppercase

* OTHER MODULES NEEDED: IS_LOWER

* ENTRY: B=ascii value of character to convert

* EXIT: B=ascii value of character in uppercase

* Note: control codes, etc. are not effected.


                    nam       Convert             Char to Uppercase
                    ttl       Assembler Library Module


                    section   .text

TO_UPPER
                    pshs      cc
                    lbsr      IS_LOWER            only lowercase can be converted to upper
                    bne       toupx
                    subb      #$20                make uppercase

toupx
                    puls      cc,pc

                    endsect

