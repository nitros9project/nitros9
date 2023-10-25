*****************************************

* See if character in "B" is a uppercase letter

* OTHER MODULES NEEDED: none

* ENTRY: B=character to test

* EXIT: CC zero=1 if uppercase, 0 if not

                    nam       Is                  Char Uppercase?
                    ttl       Assembler Library Module


                    section   .text


IS_UPPER
                    cmpb      #'A
                    blo       no                  not uppercase, zero cleared
                    cmpb      #'Z                 if equal, zero set
                    bhi       no                  not upperc, zero cleared
                    orcc      #%00000100          set zero

no
                    rts

                    endsect

