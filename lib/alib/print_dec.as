***************************************

* Print decimal number to standard out.

* ENTRY: D=value to print

* EXIT: CC carry set if error (from I$WritLn)
*       B error code, if any


                    nam       Print               # as Decimal String to Std Out
                    ttl       Assembler Library Module


                    section   .text

PRINT_DEC
                    pshs      a,x
                    leas      -8,s                buffer
                    tfr       s,x
                    lbsr      BIN_DEC             convert to decimal
                    lbsr      PUTS                print to standard out
                    leas      8,s                 clean stack
                    puls      a,x,pc              return with error in B

                    endsect

