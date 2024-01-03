;;; FGETC
;;;
;;; Read one character from a device.
;;;
;;; Entry:  A = The path to read the character from.
;;;
;;; Exit:   A = The character read.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; The result must be an 8 bit value.

                    section   .text

FGETC:              pshs      a,x,y
                    ldy       #1                  number of char to print
                    tfr       s,x                 point x at 1 char buffer
                    os9       I$Read
                    puls      a,x,y,pc

                    endsect

