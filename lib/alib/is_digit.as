*****************************************

* See if character in "B" is a digit 0..9

* OTHER MODULES NEEDED: none

* ENTRY: B=character to test

* EXIT: CC zero=1 if digit, 0 if not

                    nam       Is                  Char a Digit?
                    ttl       Assembler Library Module


                    section   .text


IS_DIGIT
                    cmpb      #'0
                    blo       no                  not digit, zero cleared
                    cmpb      #'9                 if equal, zero set
                    bhi       no                  not digit, zero cleared
                    orcc      #%00000100          set zero

no
                    rts

                    endsect

