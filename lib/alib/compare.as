**************************************

* COMPARE: Subroutine for string comparsion routines.
*          Compares chars in A/B, will convert both to
*          uppercase first if CASEMTCH is set (negative)


* OTHER MODULES NEEDED: TO_UPPER

* ENTRY: A/B=characters to compare
*        CASEMTCH=0 (or positive value) if A<>a
*                -1 (or neg value) if A=a


* EXIT: CC zero set if characters match.
*       All other registers preserved.


                    nam       Compare             2 Chars
                    ttl       Assembler Library Module


                    section   .bss

CASEMTCH            rmb       1

                    endsect

                    section   .text


COMPARE
                    pshs      d
                    tst       CASEMTCH            need to covert to upper?
                    bpl       no
                    lbsr      TO_UPPER
                    exg       a,b
                    lbsr      TO_UPPER
no
                    pshs      a                   somewhere to compare it
                    cmpb      ,s+                 do compare, set zero
                    puls      d,pc                go home

                    endsect
