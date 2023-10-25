******************************************
*
* This subroutine creates a temorary filename
* by adding a "." and a 2digit hex value based
* on the process id.
* IMPORTANT: there must be room after the filename
* for at least 6 bytes!! Filename must be variable
* area, not parameter or program sections!!!

* OTHER MODULES NEEDED: BIN_HEX

* ENTRY: X= filename

* EXIT: no registers (expect cc) modified
*       filename ends in ".processid",$0d

                    nam       Make                Unique Filename
                    ttl       Assembler Library Module


                    section   .text

MKTEMP
                    pshs      d,x,y

                    os9       F$PrsNam            find end of name
                    tfr       y,x

                    lda       #'.
                    sta       ,x+                 put "." in name

                    os9       F$ID
                    tfr       a,b                 convert to 4 digit hex
                    lbsr      BIN2HEX
                    std       ,x++
                    lda       #$0d                end name with cr
                    sta       ,x
                    puls      d,x,y,pc

                    endsect
