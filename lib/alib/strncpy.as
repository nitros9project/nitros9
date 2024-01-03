;;; STRNCPY
;;;
;;; Copy a number of characters of a null-terminated string.
;;;
;;; Other modules needed: STRNCPY
;;;
;;; Entry:  D = The number of characters to copy.
;;;         X = The address of the string to copy.
;;;         Y = The address of the location to copy the string to.
;;;
;;; Exit:   D = The number of bytes copied.
;;;
;;; All registers except CC are preserved.
;;;
;;; Ensure that there is room in the copy buffer.
;;;
;;; If the number of characters to copy is greater than the length of
;;; the string, the entire string is copied.

                    section   .text

STRNCPY:            pshs      d                   bytes wanted to move
                    lbsr      STRLEN              find length of string
                    addd      #1                  move NULL also
                    cmpd      ,s                  get smaller of passed/actual size
                    bls       skip                use actual length
                    ldd       ,s                  use passed length

skip                lbsr      MEMMOVE             move it
                    leas      2,s
                    rts

                    endsect


