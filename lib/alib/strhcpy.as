**********************************

* STRHCPY: copy sign-bit terminated string
*          User must ensure there is room in buffer!!!
*          See also PARSNSTR, this routine does not change
*          sign-bit termination.

* OTHER MODULES NEEDED: strhlen,memmove


* ENTRY: X=start of string to move
*        Y=buffer for copy of string


* EXIT:  all regs preserved (except cc)


                    nam       Copy                sign-bit terminated String
                    ttl       Assembler Library Module


                    section   .text

STRHCPY
                    pshs      d
                    lbsr      STRHLEN             find length of string
                    lbsr      MEMMOVE             move it
                    puls      d,pc

                    endsect


