***************************************

* Print hex number to standard out.

* ENTRY: D=value to print

* EXIT: CC carry set if error (from I$WritLn)
*       B error code, if any


                    nam       Print               # as Hex String to Std Out
                    ttl       Assembler Library Module


                    section   .text

PRINT_HEX
                    pshs      a,x
                    leas      -6,s                buffer
                    tfr       s,x
                    lbsr      BIN_HEX             convert to hex
                    lbsr      PUTS                print to standard out
                    leas      6,s                 clean stack
                    puls      a,x,pc              return with error in B

                    endsect

