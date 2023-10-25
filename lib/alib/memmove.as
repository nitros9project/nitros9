**************************************

* Memory move

* NOTE: This routine properly moves overlapping areas of memory.
*       Uses fast move algorithm

* ENTRY: X=source data
*        Y=destination
*        D=count

* EXIT: all registers (except CC) preserved

                    nam       Move                Memory
                    ttl       Assembler Library Module



                    section   .text

MEMMOVE
                    pshs      d,x,y,u
                    std       -2,s                test u
                    beq       exit                zero count, exit
                    tfr       y,u                 use u for dest
                    tfr       d,y                 count in y
                    cmpu      2,s                 compare dest. to source (x)
                    beq       exit                same, no need to move
                    bhi       down                u>x

up
                    bitb      #1                  see if odd number to move
                    beq       up1
                    lda       ,x+                 move odd byte
                    sta       ,u+
                    leay      -1,y                could be only one
                    beq       exit

up1
                    ldd       ,x++                move 2 bytes
                    std       ,u++
                    leay      -2,y                count down
                    bne       up1
                    bra       exit

down
                    leau      d,u                 u=dest end (count in D)
                    leax      d,x                 x=source end

                    bitb      #1
                    beq       down2
                    lda       ,-x                 move odd byte
                    sta       ,-u
                    leay      -1,y                could be only one to do
                    beq       exit

down2
                    ldd       ,--x                get 2 bytes
                    std       ,--u                move them
                    leay      -2,y                count down
                    bne       down2

exit
                    puls      d,x,y,u,pc

                    endsect
