***************************************

* Subroutine to print one character.

* OTHER MODULES NEEDED: none

* ENTRY: A=path
*        B=char to print

* EXIT:  CC carry set if error (from I$WritLn)
*        B  error code if any

                    nam       Output              Single Char.
                    ttl       Assembler Library Module


                    section   .text

FPUTC
                    pshs      b,x,y
                    ldy       #1                  number of char to print
                    tfr       s,x                 point x at char to print
                    os9       I$WritLn
                    leas      1,s                 don't care about char anymore (B now = error)
                    puls      x,y,pc

                    endsect

