*****************************************

* See if character in "B" is a space ($20)

* NOTE: This module is included for completeness only,
*       it is much more efficient to do an inline test.

* OTHER MODULES NEEDED: none

* ENTRY: B=character to test

* EXIT: CC zero=1 if space, 0 if not


                    nam       Is                  Char a Space?
                    ttl       Assembler Library Module


                    section   .text


IS_SPACE
                    cmpb      #$20
                    rts

                    endsect

