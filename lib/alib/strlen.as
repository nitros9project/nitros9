;;; STRLEN
;;;
;;; Find the length of a null-terminated string.
;;;
;;; Entry:  X = The address of the string.
;;;
;;; Exit:   D = The length of the string.
;;;
;;; All registers except CC are preserved.
;;;
;;; The null byte is not included in the count.

                    section   .text

STRLEN:             pshs      x
                    ldd       #-1                 comp for inital inc

loop                addd      #1                  bump count
                    tst       ,x+                 end?
                    bne       loop

                    puls      x,pc

                    endsect


