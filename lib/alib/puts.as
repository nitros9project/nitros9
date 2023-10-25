***********************************

* Print a null terminated string to standard out.

* OTHER MODULES NEEDED: fputs

* ENTRY: X=string to print

* EXIT: CC carry set if error
*       B error code (if any)


                    nam       Print               String to Std. Out
                    ttl       Assembler Library Module


                    section   .text

PUTS
                    pshs      a
                    lda       #1                  std out
                    lbsr      FPUTS
                    puls      a,pc

                    endsect

