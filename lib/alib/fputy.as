***************************************

* Subroutine to save word in Y to file

* OTHER MODULES NEEDED: none

* ENTRY: A=path
*        Y=value to save

* EXIT:  CC carry set if error (from I$Write)
*        B  error code if any

                    nam       Save                word to file
                    ttl       Assembler Library Module


                    section   .text

FPUTY
                    pshs      x,y
                    ldy       #2                  number of chars to write
                    leax      2,s                 point X at value
                    os9       I$Write
                    puls      x,y,pc

                    endsect

