;;; B09STRLEN
;;;
;;; Find the length of a BASIC09 string which can be terminated by $FF or allocated storage size.
;;;
;;; Entry:  X = Start of the string.
;;;         D = The maximum allocated value.
;;;
;;; Exit:   D = The streng length.
;;;
;;; All registers (except CC) are preserved.

                    section   .text

B09STRLEN:          pshs      d,x,y
                    tfr       d,y                 max. possible size to Y

loop                lda       ,x+                 get char from string
                    inca                          this effects a cmpa #$ff
                    beq       exit                reached terminator
                    leay      -1,y                if string max leng, no terminator
                    bne       loop                no yet, check more

exit                puls      d                   get max possible size
                    pshs      y                   unused size in memory
                    subd      ,s++                find actual length
                    puls      x,y,pc

                    endsect

