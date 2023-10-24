**********************************

* Advance X to 1st non-space character

* OTHER MODULES NEEDED: none

* ENTRY: X=somewhere in a string

* EXIT: X=1st non-space character in string
*       B=char at X


                    nam       Advance             to non-space
                    ttl       Assembler Library Module

                    section   .text

TO_NON_SP
                    ldb       ,x+
                    cmpb      #$20                is it space?
                    beq       TO_NON_SP           yes, loop
                    leax      -1,x                point to non-space
                    rts

                    endsect
