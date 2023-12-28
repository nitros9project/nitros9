;;; FPUTCR
;;;
;;; Prints a carriage return to a device.
;;;
;;; Entry:  A = The path to print to.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

FPUTCR:             ldb       #$0d
                    lbra      FPUTC

                    endsect
