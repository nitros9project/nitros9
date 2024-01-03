;;; FPUTY
;;;
;;; Print a word to a device.
;;;
;;; Entry:  A = The path to print to.
;;;         Y = The value to print.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

FPUTY:              pshs      x,y
                    ldy       #2                  number of chars to write
                    leax      2,s                 point X at value
                    os9       I$Write
                    puls      x,y,pc

                    endsect

