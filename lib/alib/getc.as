***************************************

* Subroutine to input one character from std in.

* OTHER MODULES NEEDED: FGETC

* ENTRY: none


* EXIT:  A  character
*        CC carry set if error (from I$Read)
*        B  error code if any

                    nam       Input               Single Character
                    ttl       Assembler Library Module


                    section   .text

GETC
                    clra                          std in
                    lbra      FGETC

                    endsect

