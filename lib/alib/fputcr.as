****************************************

* Subroutine to print a carriage return

* OTHER MODULES REQUIRED: FPUTC

* ENTRY: A=path

* EXIT: CC carry set if error (from I$WritLn)
*       B  error code if any.


                    nam       Output              Carriage Return
                    ttl       Assembler Library Module


                    section   .text

FPUTCR
                    ldb       #$0d
                    lbra      FPUTC

                    endsect
