*******************************

* convert a null terminated string to all uppercase

* OTHER MODULES NEEDED: TO_UPPER

* ENTRY: X=start of string

* EXIT:  all registers (except CC) preserved


                    nam       Convert             String to Uppercase
                    ttl       Assembler Library Module


                    section   .text

TO_UPPRS
                    pshs      cc,b,x

loop
                    ldb       ,x                  get char to check
                    beq       exit                exit if all done
                    lbsr      TO_UPPER            convert to upper
                    stb       ,x+                 put back in string
                    bra       loop

exit
                    puls      cc,b,x,pc

                    endsect

