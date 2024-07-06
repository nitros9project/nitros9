;;; PRINTS
;;;
;;; Print an embedded, null-terminated string to the standard output.
;;;
;;; Other modules needed: PUTS
;;;
;;; Entry:  None
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; The null-terminated follows the PRINTS call:
;;;
;;;          LBSR PRINTS
;;;          fcc /this is stuff to print/
;;;          fcb $0d  * a new line
;;;          fcc /more stuff to print/
;;;          fcb $0d,0  the end

                    section   .text

PRINTS:             pshs      x,u
                    ldx       4,s                 get start of string (old return address)
                    tfr       x,u                 copy it

loop                tst       ,u+                 advance U to end of string
                    bne       loop

                    stu       4,s                 one past null=return address
                    lbsr      PUTS                print from orig pos.
                    puls      x,u,pc              return to caller

                    endsect

