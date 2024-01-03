;;; DATESTR
;;;
;;; Convert a date to a string.
;;;
;;; Other modules needed: BIN_ASC
;;;
;;; Entry:  X = The address of the 6-byte binary date/time.
;;;         Y = The buffer that holds the ASCII representation.
;;;
;;; Exit:   None.
;;;
;;; All registers (except CC) are preserved.
;;;
;;;  Use this routine to convert time from the system and files.
;;;
;;;  The date must be 6 bytes.

                    section   .text

DATESTR:            pshs      d,x,y,u             save registers
                    leau      delims,pcr          point to delimiters

* BGP - 2023/12/19: made Y2K compliant and print a 4 digit year
                    clra                          clear upper 8 bits
                    ldb       ,x+                 get year byte in B
                    pshs      u,x                 save registers
                    addd      #1900               add base year
                    leax      ,y                  transfer y to x
                    ldu       10,s                get static storage pointer on stack
                    lbsr      BIN_DEC             convert value in D to decimal string at X
                    puls      u,x                 recover registers
                    leay      4,y                 advance Y past 4 characters
                    bra       loop2               get the delimiter and go
loop                pshs      u
                    ldu       8,s
                    bsr       get1                convert a byte
                    puls      u
loop2               lda       ,u+                 get next delimiter
                    sta       ,y+                 add to ascii buffer
                    bne       loop                not end yet
                    puls      d,x,y,u,pc

get1                ldb       ,x+                 get next byte to convert
get11               clra                          only doing one byte value
                    pshs      x                   save ptr to date packet
                    leas      -8,s                buffer for ascii number
                    tfr       s,x
                    lbsr      BIN_DEC             convert
                    ldd       ,x                  get ascii
                    tstb                          1byte number?
                    bne       get2                no
                    tfr       a,b
                    lda       #'0                 leading "0"

get2                std       ,y++                to buffer
                    leas      8,s
                    puls      x,pc

delims              fcc       '// ::'
                    fcb       0

                    endsect
