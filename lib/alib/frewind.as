;;; FREWIND
;;;
;;; Rewind a file.
;;;
;;; Entry:  A = The path to print to.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

FREWIND:            pshs      x,u
                    ldx       #0
                    tfr       x,u
                    os9       I$Seek              seek to pos 0
                    puls      x,u,pc

                    endsect

