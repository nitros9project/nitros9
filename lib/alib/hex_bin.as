;;; HEX_BIN
;;;
;;; Hexadecimal string to binary conversion.
;;;
;;; Other modules needed: TO_UPPER, IS_TERMIN, IS_XDIGIT
;;;
;;; Entry:  X = The address of a hexadecimal string termianted by a space, comma, carriage return, or null.
;;;
;;; Exit:   D = The binary value.
;;;         Y = The terminator or error character position.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error (too large, non-numeric).

                    section   .text

HEX_BIN:            clra                          init number
                    clrb
                    pshs      d,x
                    tfr       d,y                 digit counter

loop                ldb       ,x+                 get next digit
                    lbsr      TO_UPPER            convert to uppercase
                    lbsr      IS_TERMIN           end of string?
                    beq       exit                yes, go home
                    lbsr      IS_XDIGIT           make sure it's valid digit
                    bne       error               not 0..9, a..f
                    cmpb      #'9                 convert to binary value
                    bls       notAtoF
                    subb      #7                  fix a..f
notAtoF             subb      #'0                 convert to binary 0..15

* now shift the digit to bits 7..4

                    lslb
                    lslb
                    lslb
                    lslb

* now shift the value in to the result

                    lda       #4                  number of bits
l1                  lslb                          digit bit to carry
                    rol       1,s                 carry bit to result
                    rol       0,s
                    deca                          done 4?
                    bne       l1                  no, loop

                    leay      1,y                 number of digits done
                    cmpy      #4
                    bhi       error               more than 4
                    bra       loop                keep going


exit                clrb                          clear carry=no error
                    sty       -2,s                test y (count)
                    bne       done                no digits?

error               clr       0,s
                    clr       1,s
                    orcc      #1                  set carry

done                leay      -1,x                terminator/error pos
                    puls      d,x,pc

                    endsect


