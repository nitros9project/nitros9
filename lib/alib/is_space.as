;;; IS_SPACE
;;;
;;; Test if a character is a space.
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is a space; otherwise, 0.
;;;

                    section   .text

IS_SPACE:           cmpb      #$20
                    rts

                    endsect

