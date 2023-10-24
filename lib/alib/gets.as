***************************************

* Subroutine to input a null terminated string from Std. In

* OTHER MODULES NEEDED: GETS

* ENTRY: X=buffer for string
*        Y=max buffer size (leave room for null!!)

* EXIT:  CC carry set if error (from I$ReadLn)
*        B  error code if any

* NOTE: The string entered must end with an end-of-record char
*       (usually a $0D), the null is appended for ease in string
*       handling.

                    nam       Input               Null Terminated String from Std. In
                    ttl       Assembler Library Module


                    section   .text

GETS
                    pshs      a
                    clra                          std in.
                    lbsr      FGETS
                    puls      a,pc

                    endsect

