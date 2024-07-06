;;; TO_SP
;;;
;;; Advance to the first space character.
;;;
;;; Entry:  X = The string to advance.
;;;
;;; Exit:   X = The address of the first space character.

                    section   .text

TO_SP:              pshs      b
spl                 ldb       ,x+
                    cmpb      #$20                is it space?
                    bne       spl                 no, loop
                    leax      -1,x                point to space
                    puls      b,pc

                    endsect
