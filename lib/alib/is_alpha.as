;;; IS_ALPHA
;;;
;;; Test if a character is a letter from a-z or A-Z.
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is alphabetic; otherwise, 0.
;;;

                    section   .text

IS_ALPHA:           lbsr      IS_UPPER
                    beq       yes                 uppercase letters are alpha
                    lbsr      IS_LOWER            last chance to set flags.

yes                 rts

                    endsect
