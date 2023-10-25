*****************************************

* See if character in "B" is a printable character
* controls are defined as $00..$1F and $7F+ -- all others are printable

* OTHER MODULES NEEDED: IS_CNTRL

* ENTRY: B=character to test

* EXIT: CC zero=1 if printable, 0 if not


                    nam       Is                  Char Printable?
                    ttl       Assembler Library Module


                    section   .text

IS_PRINT
                    lbsr      IS_CNTRL
                    beq       no
                    orcc      #%00000100          set zero
                    rts

no
                    andcc     #%11111011          clear zero
                    rts

                    endsect

