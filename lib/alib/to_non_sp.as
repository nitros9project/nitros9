;;; TO_NON_SP
;;;
;;; Advance to the first non-space character.
;;;
;;; Entry:  X = The string to advance.
;;;
;;; Exit:   B = The first non-space character.
;;;         X = The address of the first non-space character.

                    section   .text

TO_NON_SP:          ldb       ,x+
                    cmpb      #$20                is it space?
                    beq       TO_NON_SP           yes, loop
                    leax      -1,x                point to non-space
                    rts

                    endsect
