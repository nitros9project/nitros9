;;; STRNCMP
;;;
;;; Compare two null-terminated strings up to a maximum length.
;;;
;;; Other modules needed: COMPARE
;;;
;;; Entry:  D = The number of characters to compare.
;;;         X = The address of the first string.
;;;         Y = The address of the second string.
;;;
;;; Exit:  CC = Zero set if the strings are equal.
;;;        CC = Carry set and Zero clear if the first string is greater than the second.
;;;        CC = Carry set and Zero set if the first string is less than the second.
;;;
;;; Set CASEMTCH = 0 for non-case comparison, or -1 for case comparison.

                    section   .text

STRNCMP:            pshs      d,x,y,u

                    tfr       y,u                 U=string2
                    tfr       d,y                 use Y for counter
                    leay      1,y                 comp for initial dec.

loop                leay      -1,y                count down
                    beq       exit                no miss-matches
                    lda       ,x+                 get 2 to compare
                    ldb       ,u+
                    lbsr      COMPARE             go compare chars.
                    beq       loop                chars match, do more

* exit with flags set. Do a beq, bhi or blo to correct
* routines....

exit                puls      d,x,y,u,pc

                    endsect
