**********************************

* String Length: find length of null terminated string.
*  note:null NOT included in count.

* ENTRY: X=start of string

* EXIT: D=length
*       all other regs (except cc) preserved

                    nam       Find                String Length
                    ttl       Assembler Library Module


                    section   .text

STRLEN
                    pshs      x
                    ldd       #-1                 comp for inital inc

loop
                    addd      #1                  bump count
                    tst       ,x+                 end?
                    bne       loop

                    puls      x,pc

                    endsect


