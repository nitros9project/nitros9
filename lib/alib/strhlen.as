**********************************

* String Length: find length of sign-bit terminated string.
*          note: sign-bit set byte IS included in count.

* OTHER MODULES NEEDED: none


* ENTRY: X=start of string


* EXIT: D=length
*       all other regs (except cc) preserved


                    nam       Find                sign-bit term. String Length
                    ttl       Assembler Library Module


                    section   .text

STRHLEN
                    pshs      x
                    clra                          it'll be at least one byte long
                    clrb

loop
                    addd      #1                  bump count
                    tst       ,x+                 end?
                    bpl       loop

                    puls      x,pc

                    endsect


