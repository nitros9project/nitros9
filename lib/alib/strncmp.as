*************************************

* STRNCMP: compare 2 null terminated strings
*          maximum number of bytes to compare in D
*
* OTHER MODULES NEEDED: COMPARE

* ENTRY: X=start of 1st string
*        Y=start of 2nd string
*        D=number of bytes to compare
*        CASEMTCH:(a global variable in COMPARE)
*                 0=match for case
*                -1=ignore case differences

* EXIT: CC zero set  if equal (beq)
*          carry + zero clear if 1>2 (bhi)
*          carry set if 1<2 (blo)

                    nam       Compare             2 Strings
                    ttl       Assembler Library Module


                    section   .text


STRNCMP
                    pshs      d,x,y,u

                    tfr       y,u                 U=string2
                    tfr       d,y                 use Y for counter
                    leay      1,y                 comp for initial dec.

loop
                    leay      -1,y                count down
                    beq       exit                no miss-matches
                    lda       ,x+                 get 2 to compare
                    ldb       ,u+
                    lbsr      COMPARE             go compare chars.
                    beq       loop                chars match, do more

* exit with flags set. Do a beq, bhi or blo to correct
* routines....

exit
                    puls      d,x,y,u,pc

                    endsect
