*****************************************

* See if character in "B" is a punctuation character

* OTHER MODULES NEEDED: IS_ALNUM, IS_CNTRL

* ENTRY: B=character to test

* EXIT: CC zero=1 if punct., 0 if not


                    nam       Is                  Char Punctuation?
                    ttl       Assembler Library Module


                    section   .text


IS_PUNCT
                    lbsr      IS_ALNUM
                    beq       no                  if its a.z,A.Z or 0.9 not punct
                    lbsr      IS_CNTRL
                    beq       no                  controls not punct.
                    orcc      #%00000100          set carry
                    rts

no
                    andcc     #%11111011          clear zero
                    rts


                    endsect

