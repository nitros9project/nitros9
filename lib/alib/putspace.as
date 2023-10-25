****************************************

* Subroutine to print a space to std. out

* OTHER MODULES REQUIRED: FPUTSPACE

* ENTRY: none

* EXIT: CC carry set if error (from I$WritLn)
*       B  error code if any.

                    nam       Output              One Space Char. to Std. Out
                    ttl       Assembler Library Module


                    section   .text

PUTSPACE
                    pshs      a
                    lda       #1
                    lbsr      FPUTSPACE
                    puls      a,pc

                    endsect
