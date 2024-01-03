;;; STRCPY
;;;
;;; Copy a null-terminated string.
;;;
;;; Other modules needed: STRNCPY
;;;
;;; Entry:  X = The address of the string to copy.
;;;         Y = The address of the location to copy the string to.
;;;
;;; Exit:  None.
;;;
;;; All registers except CC are preserved.
;;;
;;; Ensure that there is room in the copy buffer.

                    section   .text

STRCPY:             pshs      d
                    ldd       #$ffff              pass very long value to STRNCPY
                    lbsr      STRNCPY             move it
                    puls      d,pc

                    endsect


