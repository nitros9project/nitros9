;;; STRHLEN
;;;
;;; Find the length of a sign bit-terminated string.
;;;
;;; Entry:  X = The address of the string.
;;;
;;; Exit:   D = The length of the string.
;;;
;;; All registers except CC are preserved.
;;;
;;; The sign bit byte is included in the count.

                    section   .text

STRHLEN:            pshs      x
                    clra                          it'll be at least one byte long
                    clrb

loop                addd      #1                  bump count
                    tst       ,x+                 end?
                    bpl       loop

                    puls      x,pc

                    endsect


