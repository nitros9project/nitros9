;;; PUTC
;;;
;;; Prints one character to the standard output.
;;;
;;; Other modules needed: FPUTC
;;;
;;; Entry:  B = The character to print.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
**********************************

                    section   .text

PUTC:               pshs      a
                    lda       #1                  stn out
                    lbsr      FPUTC
                    puls      a,pc

                    endsect

