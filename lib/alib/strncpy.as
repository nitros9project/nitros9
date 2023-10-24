**********************************

* STRNCPY: copy N bytes of a null terminated string
*          User must ensure there is room in buffer!!!
*          If N>string length only N bytes will be moved

* OTHER MODULES NEEDED: STRLEN, MEMMOVE

* ENTRY: X=start of string to move
*        Y=buffer for copy of string

* EXIT: D = actual number of bytes moved
*       all other regs preserved (except cc)


                    nam       Copy                partial String
                    ttl       Assembler Library Module


                    section   .text

STRNCPY
                    pshs      d                   bytes wanted to move
                    lbsr      STRLEN              find length of string
                    addd      #1                  move NULL also
                    cmpd      ,s                  get smaller of passed/actual size
                    bls       skip                use actual length
                    ldd       ,s                  use passed length
skip
                    lbsr      MEMMOVE             move it
                    leas      2,s
                    rts

                    endsect


