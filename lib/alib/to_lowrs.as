*******************************

* convert a null terminated string to all lowercase

* OTHER MODULES NEEDED: TO_LOWER

* ENTRY: X=start of string

* EXIT:  all registers  preserved

                    nam       Convert             String to Lowercase
                    ttl       Assembler Library Module

                    section   .text

TO_LOWRS
                    pshs      cc,b,x

loop
                    ldb       ,x                  get char to check
                    beq       exit                exit if all done
                    lbsr      TO_LOWER            convert to upper
                    stb       ,x+                 put back in string
                    bra       loop                loop till done

exit
                    puls      cc,b,x,pc

                    endsect

