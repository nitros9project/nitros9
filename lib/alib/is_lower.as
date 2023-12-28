;;; IS_LOWER
;;;
;;; Test if a character is a lowercase letter from a-z.
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is a lowercase letter; otherwise, 0.
;;;

                    section   .text


IS_LOWER:           cmpb      #'a
                    blo       no                  not lowercase, zero cleared
                    cmpb      #'z                 if equal, zero set
                    bhi       no                  not lowc, zero cleared
                    orcc      #%00000100          set zero

no                  rts

                    endsect

