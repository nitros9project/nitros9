;;; TO_LOWER
;;;
;;; Convert a character to lowercase.
;;;
;;; Other modules needed: IS_UPPER
;;;
;;; Entry:  B = The character to convert to lowercase
;;;
;;; Exit:   B = The lowercase version of the character.
;;;
;;; All registers are preserved.

                    section   .text

TO_LOWER:           pshs      cc
                    lbsr      IS_UPPER            only uppercase can be converted
                    bne       tolox               no upper, exit
                    addb      #$20                make lowercase

tolox               puls      cc,pc

                    endsect

