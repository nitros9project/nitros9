;;; IS_DIGIT
;;;
;;; Test if a character is a digit from 0-9.
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is a digit; otherwise, 0.
;;;

                    section   .text

IS_DIGIT:           cmpb      #'0
                    blo       no                  not digit, zero cleared
                    cmpb      #'9                 if equal, zero set
                    bhi       no                  not digit, zero cleared
                    orcc      #%00000100          set zero

no                  rts

                    endsect

