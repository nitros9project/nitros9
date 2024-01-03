;;; FPUTSPACE
;;;
;;; Prints a space to the standard output.
;;;
;;; Other modules needed: FPUTSPACE
;;;
;;; Entry:  None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

PUTSPACE:           pshs      a
                    lda       #1
                    lbsr      FPUTSPACE
                    puls      a,pc

                    endsect
