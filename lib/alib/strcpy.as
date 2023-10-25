**********************************

* STRCPY: copy a null terminated string
*         User must ensure there is room in buffer!!!

* OTHER MODULES NEEDED: STRNCPY

* ENTRY: X=start of string to move
*        Y=buffer for copy of string

* EXIT: all regs preserved (except cc)


                    nam       Copy                Null Term. String
                    ttl       Assembler Library Module


                    section   .text

STRCPY
                    pshs      d
                    ldd       #$ffff              pass very long value to STRNCPY
                    lbsr      STRNCPY             move it
                    puls      d,pc

                    endsect


