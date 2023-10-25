*****************************************

* See if character in "B" is a lowercase letter

* OTHER MODULES NEEDED: none

* ENTRY: B=character to test

* EXIT: CC zero=1 if lowercase, 0 if not

                    nam       Is                  Char. Lowercase?
                    ttl       Assembler Library Module


                    section   .text


IS_LOWER
                    cmpb      #'a
                    blo       no                  not lowercase, zero cleared
                    cmpb      #'z                 if equal, zero set
                    bhi       no                  not lowc, zero cleared
                    orcc      #%00000100          set zero

no
                    rts

                    endsect

