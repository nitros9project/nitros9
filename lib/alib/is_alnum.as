;;; IS_ALNUM
;;;
;;; Test if a character is alphanumeric.
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is alphanumeric; otherwise, 0.
;;;

                    section   .text

IS_ALNUM:           lbsr      IS_ALPHA
                    beq       yes                 upper/lowercase letters are alphanumeric
                    lbsr      IS_DIGIT            last chance to set flags.

yes                 rts


                    endsect

