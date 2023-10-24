***************************************

* Subroutine to input one character from std in. if ready
* like an INKEY$...

* OTHER MODULES NEEDED: FGETC

* ENTRY: none


* EXIT:  A  character, 0=no char
*        CC carry set if error (from I$Read)
*        B  error code if any

                    nam       Inkey
                    ttl       Assembler Library Module


                    section   .text

INKEY
                    clra                          std in
                    ldb       #SS.Ready
                    os9       I$GetStt            see if key ready
                    bcc       getit
                    cmpb      #E$NotRdy           no keys ready=no error
                    bne       exit                other error, report it
                    clra                          no error
                    bra       exit

getit
                    lbsr      FGETC               go get the key

* this inst. needed since ctrl/: sometimes returns a null
* usually callers are not expecting a null....

                    tsta

exit
                    rts

                    endsect

