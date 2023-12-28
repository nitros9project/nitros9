;;; TO_LOWRS
;;;
;;; Convert a null-terminated string to lowercase.
;;;
;;; Other modules needed: TO_LOWER
;;;
;;; Entry:  X = The string to convert to lowercase.
;;;
;;; Exit:   X = The converted string.
;;;
;;; All registers are preserved.

                    section   .text

TO_LOWRS:           pshs      cc,b,x

loop                ldb       ,x                  get char to check
                    beq       exit                exit if all done
                    lbsr      TO_LOWER            convert to upper
                    stb       ,x+                 put back in string
                    bra       loop                loop till done

exit                puls      cc,b,x,pc

                    endsect

