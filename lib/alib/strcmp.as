**************************************

* STRCMP: compare two null terminated strings.

* NOTE: This routine first finds the length of both
*       strings and passes the length of the longer
*       one to strncmp.

* OTHER MODULES NEEDED: STRNCMP, STRLEN


* ENTRY: X=start of 1st string
*        Y=start of 2nd string

* EXIT: CC zero set  if equal (beq)
*          carry + zero clear if 1>2 (bhi)
*          carry set if 1<2 (blo)


                    nam       Compare             Strings
                    ttl       Assembler Library Module


                    section   .text

STRCMP
                    pshs      d
                    lbsr      STRLEN              find len of str1
                    pshs      d
                    exg       y,x                 find len of str2
                    lbsr      STRLEN
                    exg       y,x                 restore ptrs
                    cmpd      ,s
                    bhi       ok
                    ldd       ,s                  get bigger value

ok
                    leas      2,s                 clean stack
                    lbsr      STRNCMP             go compare
                    puls      d,pc                go home

                    endsect

