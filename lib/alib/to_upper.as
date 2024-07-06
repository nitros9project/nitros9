;;; TO_UPPER
;;;
;;; Convert a character to uppercase.
;;;
;;; Other modules needed: IS_LOWER
;;;
;;; Entry:  B = The character to convert to uppercase
;;;
;;; Exit:   B = The uppercase version of the character.
;;;
;;; All registers are preserved.

                    section   .text

TO_UPPER:           pshs      cc
                    lbsr      IS_LOWER            only lowercase can be converted to upper
                    bne       toupx
                    subb      #$20                make uppercase

toupx               puls      cc,pc

                    endsect

