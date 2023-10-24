***************************************

* Print binary number to standard out.

* ENTRY: D=value to print

* EXIT: CC carry set if error (from I$WritLn)
*       B error code, if any

                    nam       Print               # as ASCII String to Std. Out
                    ttl       Assembler Library Module


                    section   .text

PRINT_ASC
                    pshs      a,x
                    leas      -18,s               buffer
                    tfr       s,x
                    lbsr      BIN_ASC             convert to ascii
                    lbsr      PUTS                print to standard out
                    leas      18,s                clean stack
                    puls      a,x,pc              return with error in B

                    endsect

