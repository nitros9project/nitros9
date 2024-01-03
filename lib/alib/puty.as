;;; PUTY
;;;
;;; Print a word to the standard output.
;;;
;;; Other modules needed: FPUTY
;;;
;;; Entry:  Y = The value to print.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

PUTY:               pshs      a
                    lda       #1                  stn out
                    lbsr      FPUTY
                    puls      a,pc

                    endsect
