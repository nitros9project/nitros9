;;; GETC
;;;
;;; Read a character from the standard input.
;;
;;; Other modules needed: FGETC
;;;
;;; Entry:  None.
;;;
;;; Exit:   A = The character read from the standard input.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

GETC:               clra                          std in
                    lbra      FGETC

                    endsect

