*****************************************

* See if character in "B" is a control character
* controls are defined as $00..$1F and $7F+

* OTHER MODULES NEEDED: none

* ENTRY: B=character to test

* EXIT: CC zero=1 if control, 0 if not

                    nam       Is                  Char a Control?
                    ttl       Assembler Library Module


                    section   .text


IS_CNTRL
                    cmpb      #$7f
                    bhs       yes
                    cmpb      #$1f
                    bhi       exit                not control, zero cleared

yes
                    orcc      #%00000100          set zero

exit
                    rts

                    endsect

