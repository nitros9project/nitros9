;;; IS_UPPER
;;;
;;; Test if a character is an uppercase letter from A-Z.
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is an uppercase letter; otherwise, 0.
;;;
                    section   .text

IS_UPPER:           cmpb      #'A
                    blo       no                  not uppercase, zero cleared
                    cmpb      #'Z                 if equal, zero set
                    bhi       no                  not upperc, zero cleared
                    orcc      #%00000100          set zero

no                  rts

                    endsect

