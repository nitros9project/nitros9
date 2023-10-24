***********************************

* Print a program-embedded, null terminated string to standard out.

* OTHER MODULES NEEDED: puts

* ENTRY: Null terminated string must follow PRINTS call
*        eg: LBSR PRINTS
*            fcc /this is stuff to print/
*            fcb $0d  * a new line
*            fcc /more stuff to print/
*            fcb $0d,0  the end
*            lda #xx or whatever..
*            * the rest of the program....

* EXIT: CC carry set if error
*       B error code (if any)


                    nam       Print               Embedded String to Std. Out
                    ttl       Assembler Library Module


                    section   .text

PRINTS
                    pshs      x,u
                    ldx       4,s                 get start of string (old return address)
                    tfr       x,u                 copy it

loop
                    tst       ,u+                 advance U to end of string
                    bne       loop

                    stu       4,s                 one past null=return address
                    lbsr      PUTS                print from orig pos.
                    puls      x,u,pc              return to caller

                    endsect

