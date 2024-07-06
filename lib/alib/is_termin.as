;;; IS_TERMIN
;;;
;;; Test if a character is a valid string terminator.
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is a valid string terminator; otherwise, 0.
;;;
;;; Valid string terminators are space, carriage return, comma, and null.

                    section   .text

IS_TERMIN:          tstb                          null?
                    beq       exit
                    cmpb      #$20                space
                    beq       exit
                    cmpb      #$0d                carriage return
                    beq       exit
                    cmpb      #',                 comma?

exit                rts

                    endsect

