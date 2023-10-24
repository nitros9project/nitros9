*****************************************

* See if character in "B" is a hexdigit 0..9, A..F or a..f

* OTHER MODULES NEEDED: IS_DIGIT

* ENTRY: B=character to test

* EXIT: CC zero=1 if hex digit, 0 if not

                    nam       Is                  Char a Hex Digit?
                    ttl       Assembler Library Module


                    section   .text


IS_XDIGIT
                    pshs      b
                    lbsr      IS_DIGIT
                    beq       exit                digits are okay
                    cmpb      #'A
                    blo       exit                exit, zero not set
                    cmpb      #'f
                    bhi       exit                zero not set
                    cmpb      #'a
                    bhs       yes
                    cmpb      #'F
                    bhi       exit

yes
                    orcc      #%00000100          set zero

exit
                    puls      b,pc

                    endsect

