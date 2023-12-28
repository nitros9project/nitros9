;;; STIMESTR
;;;
;;; Get the system time as an ASCII string.
;;;
;;; Other modules needed: DATESTR
;;;
;;; Entry:  X = The buffer for the ASCII string.
;;;
;;; Exit:   None.
;;;
;;; All registers except CC are preserved.

                    section   .text

STIMESTR:           pshs      x,y
                    tfr       x,y                 ascii buffer to Y
                    leas      -7,s                buffer for time packet
                    tfr       s,x
                    os9       F$Time              get system time
                    lbsr      DATESTR             convert to ascii in Y buffer
                    leas      7,s
                    puls      x,y,pc

                    endsect
t
