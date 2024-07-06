;;; PUTCR
;;;
;;; Prints a carriage return to the standard output.
;;;
;;; Other modules needed: FPUTCR
;;;
;;; Entry:  None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

PUTCR:              pshs      a
                    lda       #1                  std out
                    lbsr      FPUTCR
                    puls      a,pc

                    endsect
