;;; STRCAT
;;;
;;; Concatenate two null-terminated strings
;;;
;;; Other modules needed: STRCPY, STRLEN
;;;
;;; Entry:  X = The address of the first string.
;;;         Y = The address of the second string.
;;;
;;; Exit:   None.
;;;
;;; All registers except CC are preserved.

                    section   .text

STRCAT:             pshs      d,x,y
                    exg       x,y
                    lbsr      STRLEN              find end of appended string
                    leax      d,x                 point to end of "buffer"
                    exg       x,y
                    lbsr      STRCPY              copy string
                    puls      d,x,y,pc

                    endsect


