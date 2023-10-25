******************************************
*
* ASCII String to binary byte conversion

* OTHER MODULES NEEDED: IS_TERMIN

* ENTRY: X = start of string of binary digits (001101)
*            terminated by space, comma, CR or null.

*  EXIT: D = value
*        CC carry set if error (string too long, not binary digits)
*        Y = terminator or error pos.


                    nam       ASCII               String to Binary Conversion
                    ttl       Assembler Library Module


                    section   .text

ASC_BIN
                    clra                          msb/lsb=0
                    clrb
                    pshs      a,b,x

ascbn1
                    ldb       ,x+                 get a digit
                    lbsr      IS_TERMIN           see if space/comma/null/cr
                    beq       ascbn2
                    subb      #$30                strip off ASCII
                    bmi       error               less than "0"..
                    cmpb      #1
                    bhi       error               geater than "1"
                    rorb                          get bit into carry
                    rol       1,S                 into LSB
                    rol       ,S                  into MSB
                    inca                          bump string length
                    cmpa      #16
                    bls       ascbn1              length ok, loop
                    bra       error

ascbn2
                    clrb                          = no errors
                    tsta                          len = 0?
                    bne       done                no, skip

* error -- too long or null

error
                    clr       ,S                  force data to 0
                    clr       1,S
                    orcc      #1                  set carry flag

done
                    leay      -1,x                end of string/error char
                    puls      A,B,X,PC            get data; restore & return

                    endsect


