***************************************

* Subroutine to input a word in Y

* OTHER MODULES NEEDED: FGETY

* ENTRY: none


* EXIT:  Y  value
*        CC carry set if error (from I$Read)
*        B  error code if any

                    nam       Input               Word for stdin
                    ttl       Assembler Library Module


                    section   .text

GETY
                    pshs      a
                    clra                          std in
                    lbsr      FGETY
                    puls      a,pc

                    endsect
