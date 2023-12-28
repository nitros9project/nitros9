;;; PARSNSTR
;;;
;;; Parse a sign bit terminated string.
;;;
;;; Entry:  X = The address of the sign bit termianted string.
;;;         Y = The buffer for the null-terminated string.
;;;
;;; Exit:   D = The string size (not including the null character).
;;;
;;; All registers except CC are preserved.

                    section   .text

PARSNSTR:           pshs      x
                    lbsr      STRHCPY             copy string
                    tfr       y,x                 point to moved string
                    lbsr      STRHLEN             find length of string
                    pshs      d                   size
                    leax      d,x
                    lda       ,-x                 get final byte
                    anda      #%01111111          clear sign bit
                    clrb                          add null terminator
                    std       ,x
                    puls      d,x,pc

                    endsect
