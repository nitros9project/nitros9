************************************

* MEMSET: Set bytes in memory to specified value

* OTHER MODULES NEEDED: none

* ENTRY: X=start of memory
*        Y=number of bytes to set
*        B=character to set

* EXIT: all registers (except cc) preserved

                    nam       Set                 memory
                    ttl       Assembler Library Module


                    section   .text

MEMSET
                    pshs      x,y

loop
                    stb       ,x+
                    leay      -1,y                dec count
                    bne       loop                till zero

                    puls      x,y,pc

                    endsect
