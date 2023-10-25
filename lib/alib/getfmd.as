************************************

* Get the "last modified" date of an open file

* NOTE: Even though OS9 does not save seconds in its
*       files this routine stores a zero in this position.
*       This is done to make the routine compatible with
*       DATESTR.

* OTHER MODULES NEEDED: none

* ENTRY: X=buffer for 6 byte date
*        A=path of open file

* EXIT: CC carry set if error
*       B  error code (if any) from SS.FD


                    nam       Get                 Last Modified Date
                    ttl       Assembler Library Module

                    section   .text

BUFSIZ              equ       8

GETFMD
                    pshs      x,y
                    leas      -BUFSIZ,s           where to put FD sector info
                    tfr       s,x                 pointer for FD sector info
                    ldy       #BUFSIZ             bytes to read from FD sector
                    ldb       #$0F                SS.FD
                    os9       I$GetStt
                    bcs       exit
                    ldy       BUFSIZ,s            get back orig X
                    ldx       3,s                 get 2 bytes
                    stx       ,y++                move year,month
                    ldx       5,s
                    stx       ,y++                move date,hour
                    lda       7,s
                    sta       ,y+                 move minutes
                    clr       ,y                  null for seconds

exit
                    leas      BUFSIZ,s
                    puls      x,y,pc

                    endsect

