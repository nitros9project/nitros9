****************************************

* Subroutine to print a carriage return to std. out.

* OTHER MODULES REQUIRED: FPUTCR

* ENTRY: none

* EXIT: CC carry set if error (from I$WritLn)
*       B  error code if any.


                    nam       Output              Carriage Return to Std. Out
                    ttl       Assembler Library Module


                    section   .text

PUTCR
                    pshs      a
                    lda       #1                  std out
                    lbsr      FPUTCR
                    puls      a,pc

                    endsect
