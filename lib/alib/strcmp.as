;;; STRCMP
;;;
;;; Compare two null-terminated strings.
;;;
;;; Other modules needed: STRNCMP, STRLEN
;;;
;;; Entry:  X = The address of the first string.
;;;         Y = The address of the second string.
;;;
;;; Exit:  CC = Zero set if the strings are equal.
;;;        CC = Carry set and Zero clear if the first string is greater than the second.
;;;        CC = Carry set and Zero set if the first string is less than the second.
;;;
;;; All registers except CC are preserved.
;;;
;;; This routine first finds the length of both strings and passes the length of the longer one to STRNCMP.

                    section   .text

STRCMP:             pshs      d
                    lbsr      STRLEN              find len of str1
                    pshs      d
                    exg       y,x                 find len of str2
                    lbsr      STRLEN
                    exg       y,x                 restore ptrs
                    cmpd      ,s
                    bhi       ok
                    ldd       ,s                  get bigger value

ok                  leas      2,s                 clean stack
                    lbsr      STRNCMP             go compare
                    puls      d,pc                go home

                    endsect

