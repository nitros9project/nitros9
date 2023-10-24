****************************************

* Convert hex byte to 2 hex digits

* OTHER MODULES REQUIRED: none

* ENTRY: B= value to convert

* EXIT: D=2 byte hex digits


                    nam       Convert             Byte to Hex
                    ttl       Assembler Library Module

                    section   .text

BIN2HEX
                    pshs      b
                    lsrb                          get msn
                    lsrb
                    lsrb
                    lsrb                          fall through to convert msn and return
                    bsr       ToHex
                    tfr       b,a                 1st digit in A
                    puls      b                   get lsn
                    andb      #%00001111          keep msn

ToHex
                    addb      #'0                 convert to ascii
                    cmpb      #'9
                    bls       ToHex1
                    addb      #7                  convert plus 9 to A..F
ToHex1
                    rts

                    endsect

