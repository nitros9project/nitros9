**********************************

* Put the word in Y to std out

* OTHER MODULES NEEDED: FPUTY

* ENTRY: Y=value to save

* EXIT: CC carry set if error
*       B=error code if any

                    nam       Save                word to std out
                    ttl       Assembler Library Module


                    section   .text

PUTY
                    pshs      a
                    lda       #1                  stn out
                    lbsr      FPUTY
                    puls      a,pc

                    endsect
