*****************************************

* See if character in "B" is a valid string terminator.

* NOTE: This module is used by HEX_BIN, DEC_BIN, etc. It permits
*       SPACE, CR, COMMA and NULL to be used as a delimiter -- useful
*       for paramater and list processing....

* OTHER MODULES NEEDED: none

* ENTRY: B=character to test

* EXIT: CC zero=1 if space, 0 if not


                    nam       Is                  Char a Terminator?
                    ttl       Assembler Library Module


                    section   .text


IS_TERMIN
                    tstb                          null?
                    beq       exit
                    cmpb      #$20                space
                    beq       exit
                    cmpb      #$0d                carriage return
                    beq       exit
                    cmpb      #',                 comma?

exit
                    rts

                    endsect

