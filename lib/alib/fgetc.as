***************************************

* Subroutine to input one character.

* OTHER MODULES NEEDED: none

* ENTRY: A=path


* EXIT:  A  character
*        CC carry set if error (from I$Read)
*        B  error code if any

                    nam       Input               Single Character
                    ttl       Assembler Library Module


                    section   .text

FGETC
                    pshs      a,x,y
                    ldy       #1                  number of char to print
                    tfr       s,x                 point x at 1 char buffer
                    os9       I$Read
                    puls      a,x,y,pc

                    endsect

