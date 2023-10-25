**********************************

* BASIC09 String Length: find length of a BASIC09 string
*                        which can be terminated by a $ff
*                         =or= allocated storage size

* ENTRY: X=start of string
*        D=max allocated

* EXIT: D=actual length
*       all other regs (except cc) preserved

                    nam       Find                Basic09 String Length
                    ttl       Assembler Library Module


                    section   .text

B09STRLEN
                    pshs      d,x,y
                    tfr       d,y                 max. possible size to Y

loop
                    lda       ,x+                 get char from string
                    inca                          this effects a cmpa #$ff
                    beq       exit                reached terminator
                    leay      -1,y                if string max leng, no terminator
                    bne       loop                no yet, check more

exit
                    puls      d                   get max possible size
                    pshs      y                   unused size in memory
                    subd      ,s++                find actual length
                    puls      x,y,pc

                    endsect

