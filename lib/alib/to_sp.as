**********************************

* Advance X to 1st space character

* OTHER MODULES NEEDED: none

* ENTRY: X=somewhere in a string

* EXIT: X=1st space character in string


                    nam       Advance             to space
                    ttl       Assembler Library Module

                    section   .text

TO_SP
                    pshs      b
spl
                    ldb       ,x+
                    cmpb      #$20                is it space?
                    bne       spl                 no, loop
                    leax      -1,x                point to space
                    puls      b,pc

                    endsect
