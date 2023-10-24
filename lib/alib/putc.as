**********************************

* Put single character to standard out.

* OTHER MODULES NEEDED: FPUTC

* ENTRY: B=character to print

* EXIT: CC carry set if error
*       B=error code if any

                    nam       Print               Char to Std. Out
                    ttl       Assembler Library Module


                    section   .text

PUTC
                    pshs      a
                    lda       #1                  stn out
                    lbsr      FPUTC
                    puls      a,pc

                    endsect

