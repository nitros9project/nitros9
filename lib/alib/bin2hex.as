;;; BIN2HEX
;;;
;;; Convert a byte to two hexadecimal digits.
;;;
;;; Entry:  B = The binary value to convert.
;;;         X = The address of the 20-byte buffer that holds the roman numerals.
;;;
;;; Exit:   D = Two-byte hexadecimal digits.

                    section   .text

BIN2HEX:            pshs      b
                    lsrb                          get msn
                    lsrb
                    lsrb
                    lsrb                          fall through to convert msn and return
                    bsr       ToHex
                    tfr       b,a                 1st digit in A
                    puls      b                   get lsn
                    andb      #%00001111          keep msn

ToHex               addb      #'0                 convert to ascii
                    cmpb      #'9
                    bls       ToHex1
                    addb      #7                  convert plus 9 to A..F
ToHex1              rts

                    endsect

