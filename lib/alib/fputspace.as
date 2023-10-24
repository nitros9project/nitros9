****************************************

* Subroutine to print a space

* OTHER MODULES REQUIRED: FPUTC

* ENTRY: A=path

* EXIT: CC carry set if error (from I$WritLn)
*       B  error code if any.

                    nam       Output              One Space Char.
                    ttl       Assembler Library Module


                    section   .text

FPUTSPACE
                    ldb       #$20
                    lbra      FPUTC

                    endsect
