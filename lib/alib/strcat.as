**********************************

* STRCAT: append 2 null terminated strings
*         User must ensure there is room in buffer!!!

* OTHER MODULES NEEDED: STRCPY, STRLEN

* ENTRY: X=start of string to move
*        Y=start of string to append to

* EXIT: all regs preserved (except cc)


                    nam       Append              2 null terminated strings
                    ttl       Assembler Library Module


                    section   .text

STRCAT
                    pshs      d,x,y
                    exg       x,y
                    lbsr      STRLEN              find end of appended string
                    leax      d,x                 point to end of "buffer"
                    exg       x,y
                    lbsr      STRCPY              copy string
                    puls      d,x,y,pc

                    endsect


