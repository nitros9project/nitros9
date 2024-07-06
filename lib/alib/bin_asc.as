;;; BIN_ASC
;;;
;;; Binary word to ASCII string conversion.
;;;
;;; Entry:  D = The binary value to convert.
;;;         X = The address of the buffer that holds a 16-bit number.
;;;
;;; Exit:  None.
;;;
;;; All registers (except CC) are preserved.

                    section   .text

BIN_ASC:            pshs      a,b,x               save registers
                    pshs      a,b                 save data again
                    ldb       #16                 total bits to convert
                    andcc     #%11111110          clear CARRY to start

binas1              lda       #'0                 get ASCII 0
                    rol       1,S                 get hi bit in LSB to carry
                    rol       ,S                  and into MSB; is it 1 or 0?
                    bcc       binas2              0, skip
                    inca                          get ASCII 1

binas2              sta       ,x+                 put it in the buffer
                    decb                          done all bits?
                    bne       binas1              no, loop
                    clr       ,x                  mark end of string
                    leas      2,s                 clean up
                    puls      a,b,x,pc            restore & return

                    endsect

