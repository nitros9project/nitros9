;;; STRHCPY
;;;
;;; Copy a sign bit-terminated string.
;;;
;;; Other modules needed: STRHLEN, MEMMOVE
;;;
;;; Entry:  X = The address of the string to copy.
;;;         Y = The address of the location to copy the string to.
;;;
;;; Exit:  None.
;;;
;;; All registers except CC are preserved.
;;;
;;; Ensure that there is room in the copy buffer.
;;;
;;; This routine doesn't change the sign bit of the last character.

                    section   .text

STRHCPY:            pshs      d
                    lbsr      STRHLEN             find length of string
                    lbsr      MEMMOVE             move it
                    puls      d,pc

                    endsect


