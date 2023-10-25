*****************************************

* Convert a date to a string. This can be used
* for converting the system time as well as
* modify/create dates from files. The date must
* be 6 bytes -- null pad file dates.


* OTHER MODULES NEEDED: BIN_ASC

* ENTRY: X=binary date
*        Y=buffer for ascii

* EXIT: all registers preserved (except cc)

                    nam       Get                 ASCII Date
                    ttl       Assembler Library Module


                    section   .text

DATESTR
                    pshs      d,x,y,u
                    leau      delims,pcr

loop
                    bsr       get1                convert a byte
                    lda       ,u+                 get next delimiter
                    sta       ,y+                 add to ascii buffer
                    bne       loop                not end yet
                    puls      d,x,y,u,pc

get1
                    ldb       ,x+                 get next byte to convert
                    clra                          only doing one byte value
                    pshs      x                   save ptr to date packet
                    leas      -8,s                buffer for ascii number
                    tfr       s,x
                    lbsr      BIN_DEC             convert
                    ldd       ,x                  get ascii
                    tstb                          1byte number?
                    bne       get2                no
                    tfr       a,b
                    lda       #'0                 leading "0"

get2
                    std       ,y++                to buffer
                    leas      8,s
                    puls      x,pc

delims
                    fcc       '// ::'
                    fcb       0

                    endsect
t
