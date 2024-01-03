;;; GETS
;;;
;;; Read a string from the standard input.
;;
;;; Other modules needed: GETS
;;;
;;; Entry:  X = The buffer that holds the string.
;;;         Y = The maximum buffer size minus 1 (for the null character).
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

GETS:               pshs      a
                    clra                          std in.
                    lbsr      FGETS
                    puls      a,pc

                    endsect

