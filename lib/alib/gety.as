;;; GETY
;;;
;;; Read a single word from the standard input
;;;
;;; Entry:  None
;;;
;;; Exit:   Y = The read value.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

GETY:               pshs      a
                    clra                          std in
                    lbsr      FGETY
                    puls      a,pc

                    endsect
