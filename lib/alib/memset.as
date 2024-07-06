;;; MEMSET
;;;
;;; Sets memory to a specific value.
;;;
;;; Entry:  B = The value to set.
;;;         X = The start address.
;;;         Y = The number of bytes to set.
;;;
;;; All registers except CC are preserved.

                    section   .text

MEMSET:             pshs      x,y

loop:               stb       ,x+
                    leay      -1,y                dec count
                    bne       loop                till zero

                    puls      x,y,pc

                    endsect
