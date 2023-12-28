;;; IS_XDIGIT
;;;
;;; Test if a character is a hexadecimal digit from 0-9, a-f, or A-F.
;;;
;;; Entry:  B = The character to test.
;;;
;;; Exit:  CC = Zero is 1 if the character is a hexadecimal digit; otherwise, 0.
;;;

                    section   .text

IS_XDIGIT:          pshs      b
                    lbsr      IS_DIGIT
                    beq       exit                digits are okay
                    cmpb      #'A
                    blo       exit                exit, zero not set
                    cmpb      #'f
                    bhi       exit                zero not set
                    cmpb      #'a
                    bhs       yes
                    cmpb      #'F
                    bhi       exit

yes                 orcc      #%00000100          set zero

exit                puls      b,pc

                    endsect

