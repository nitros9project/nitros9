;;; IS_PUNCT
;;;
;;; Test if a character is a punctuation character
;;;
;;; Other modules needed: IS_ALNUM, IS_CNTRL
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is a punctuation character; otherwise, 0.
;;;

                    section   .text


IS_PUNCT:           lbsr      IS_ALNUM
                    beq       no                  if its a.z,A.Z or 0.9 not punct
                    lbsr      IS_CNTRL
                    beq       no                  controls not punct.
                    orcc      #%00000100          set carry
                    rts

no                  andcc     #%11111011          clear zero
                    rts


                    endsect

