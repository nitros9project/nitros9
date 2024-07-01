;;; TO_SP
;;;
;;; Advance to the first space character.
;;;
;;; Entry:  X = The string to advance.
;;;
;;; Exit:   X = The address of the first space character.

                    section   .text

TO_SP:              pshs      b
spl@                ldb       ,x+
                    cmpb      #$20                is it space?
                    bne       spl@                no, loop
                    leax      -1,x                point to space
                    puls      b,pc

                    endsect

;;; TO_SP_OR_NIL
;;;
;;; Advance to the first space or nil character.
;;;
;;; Entry:  X = The string to advance.
;;;
;;; Exit:   X = The address of the first space character.

                    section   .text

TO_SP_OR_NIL:       pshs      b
spl@                ldb       ,x+
                    beq       back@
                    cmpb      #$20                is it space?
                    bne       spl@                no, loop
back@               leax      -1,x                point to target char
                    puls      b,pc

;;; TO_CHAR_OR_NIL
;;;
;;; Advance to the first occurrence of the character in B.
;;;
;;; Entry:  B = The character to find.
;;;         X = The string to advance.
;;;
;;; Exit:   X = The address of the first occurrence of the character, or nil.

                    section   .text

TO_CHAR_OR_NIL:     pshs      b
spl@                ldb       ,x+
                    beq       back@
                    cmpb      ,s                  is it target character?
                    bne       spl@                no, loop
back@               leax      -1,x                point to target char
                    puls      b,pc

                    endsect
