;;; FPUTS
;;;
;;; Prints a null-terminated string to the standard output.
;;;
;;; Other modules needed: FPUTS
;;;
;;; Entry:  X = The address of the string to print.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

PUTS:               pshs      a
                    lda       #1                  std out
                    lbsr      FPUTS
                    puls      a,pc

                    endsect

