;;; BIN_HEX
;;;
;;; Binary to hexadecimal string conversion.
;;;
;;; OTHER MODULES NEEDED: BIN2HEX
;;;
;;; Entry:  D = The binary value to convert.
;;;         X = The address of the buffer that holds the nul-terminated hexadecimal string.
;;;
;;; Exit:  None.
;;;
;;; All registers (except CC) are preserved.

                    section   .text

BIN_HEX:            pshs      d,x
                    ldb       ,s
                    lbsr      BIN2HEX             convert 1 byte
                    std       ,x++
                    ldb       1,s
                    lbsr      BIN2HEX             convert 2nd byte
                    std       ,x++
                    clr       ,x                  term with null
                    puls      d,x

                    endsect


