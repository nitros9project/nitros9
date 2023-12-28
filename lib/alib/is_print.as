;;; IS_PRINT
;;;
;;; Test if a character is a printable character from $20-$7E.
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is printable; otherwise, 0.
;;;

                    section   .text

IS_PRINT:           lbsr      IS_CNTRL
                    beq       no
                    orcc      #%00000100          set zero
                    rts

no                  andcc     #%11111011          clear zero
                    rts

                    endsect

