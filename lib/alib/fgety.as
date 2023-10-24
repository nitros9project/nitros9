***************************************

* Subroutine to input one word in Y.

* OTHER MODULES NEEDED: none

* ENTRY: A=path


* EXIT:  Y  value
*        CC carry set if error (from I$Read)
*        B  error code if any

                    nam       Input               word
                    ttl       Assembler Library Module


                    section   .text

FGETY
                    pshs      x,y
                    ldy       #2                  number of char to read
                    leax      2,s                 point x at 2 char buffer
                    os9       I$Read
                    puls      x,y,pc

                    endsect
