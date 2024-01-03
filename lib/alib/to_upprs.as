;;; TO_UPPRS
;;;
;;; Convert a null-terminated string to uppercase.
;;;
;;; Other modules needed: TO_LOWER
;;;
;;; Entry:  X = The string to convert to uppercase.
;;;
;;; Exit:   X = The converted string.
;;;
;;; All registers are preserved.

                    section   .text

TO_UPPRS:           pshs      cc,b,x

loop                ldb       ,x                  get char to check
                    beq       exit                exit if all done
                    lbsr      TO_UPPER            convert to upper
                    stb       ,x+                 put back in string
                    bra       loop

exit                puls      cc,b,x,pc

                    endsect

