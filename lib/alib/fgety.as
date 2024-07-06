;;; FGETY
;;;
;;; Read a single word.
;;;
;;; Entry:  A = The path to read the string from.
;;;
;;; Exit:   Y = The read value.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

FGETY:              pshs      x,y
                    ldy       #2                  number of char to read
                    leax      2,s                 point x at 2 char buffer
                    os9       I$Read
                    puls      x,y,pc

                    endsect
