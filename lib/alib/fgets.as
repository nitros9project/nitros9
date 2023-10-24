***************************************

* Subroutine to input a null terminated string.

* OTHER MODULES NEEDED: none

* ENTRY: A=path
*        X=buffer for string
*        Y=max buffer size (leave room for null!!)

* EXIT:  CC carry set if error (from I$ReadLn)
*        B  error code if any


* NOTE: The string entered must end with an end-of-record char
*       (usually a $0D), the null is appended for ease in string
*       handling.


                    nam       Input               Null Terminated String
                    ttl       Assembler Library Module


                    section   .text

FGETS_NOCR
                    pshs      d,x
                    bsr       FGETS
                    bcs       bye
                    tfr       y,d
                    leax      -1,x
                    clr       d,x
bye                 puls      d,x,pc

FGETS
                    pshs      a,x
                    os9       I$ReadLn            get line
                    bcs       exit                return error code
                    tfr       y,d
                    clr       d,x                 add null
                    clrb                          no error..

exit
                    puls      a,x,pc

                    endsect

