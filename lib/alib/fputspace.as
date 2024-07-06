;;; FPUTSPACE
;;;
;;; Prints a space to a device.
;;;
;;; Entry:  A = The path to print to.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

FPUTSPACE:          ldb       #$20
                    lbra      FPUTC

                    endsect
