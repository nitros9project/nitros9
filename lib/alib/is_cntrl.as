;;; IS_ALPHA
;;;
;;; Test if a character is a control character from $00-$1F or $7F-$FF
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is a control character; otherwise, 0.
;;;

                    section   .text


IS_CNTRL:           cmpb      #$7f
                    bhs       yes
                    cmpb      #$1f
                    bhi       exit                not control, zero cleared

yes                 orcc      #%00000100          set zero

exit                rts

                    endsect

