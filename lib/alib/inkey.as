;;; INKEY
;;;
;;; Reads one character from the standard input.
;;;
;;; Other modules needed: FGETC
;;;
;;; Entry:  NOne.
;;;
;;; Exit:   A = The character read, or 0 if there was no character.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error (too large, non-numeric).

                    section   .text

INKEY:              clra                          std in
                    ldb       #SS.Ready
                    os9       I$GetStt            see if key ready
                    bcc       getit
                    cmpb      #E$NotRdy           no keys ready=no error
                    bne       exit                other error, report it
                    clra                          no error
                    bra       exit

getit               lbsr      FGETC               go get the key

* this inst. needed since ctrl/: sometimes returns a null
* usually callers are not expecting a null....

                    tsta

exit                rts

                    endsect

