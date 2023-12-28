;;; FPUTC
;;;
;;; Prints one character to a device.
;;;
;;; Entry:  A = The path to print to.
;;;         B = The character to print.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

FPUTC:              pshs      b,x,y
                    ldy       #1                  number of char to print
                    tfr       s,x                 point x at char to print
                    os9       I$WritLn
                    leas      1,s                 don't care about char anymore (B now = error)
                    puls      x,y,pc

                    endsect

