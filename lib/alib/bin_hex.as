********************************************
*
* Binary to hexadecimal convertor
*
* This subroutine will convert the binary value in
* 'D' to a 4 digit hexadecimal ascii string.


* OTHER MODULES NEEDED: BIN2HEX

* ENTRY: D=value to convert
*        X=buffer for hex string-null terminated

* EXIT all registers (except CC) preserved.

                    nam       Convert             # to Hex String
                    ttl       Assembler Library Module


                    section   .text

BIN_HEX
                    pshs      d,x
                    ldb       ,s
                    lbsr      BIN2HEX             convert 1 byte
                    std       ,x++
                    ldb       1,s
                    lbsr      BIN2HEX             convert 2nd byte
                    std       ,x++
                    clr       ,x                  term with null
                    puls      d,x

                    endsect


