                    nam       BBS.list
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

InPath              rmb       1
Buffer              rmb       1
U0002               rmb       599
size                equ       .

name                fcs       /BBS.list/          * 000D 42 42 53 2E 6C 69 73 F4 BBS.list

start               lda       #1                  * 0015 86 01          ..
                    os9       I$Open              * Open the specified file for reading      * 0017 10 3F 84       .?.
                    lbcs      ErrExit             * Exit on error                            * 001A 10 25 00 2C    .%.,
                    sta       InPath,U            * Store the input path number              * 001E A7 C4          'D

* Copy the data in the file to the terminal or console
CopyLoop            lda       InPath,U            * Get the input path number                * 0020 A6 C4          &D
                    leax      Buffer,U            * 0022 30 41          0A
                    ldy       #200                * 0024 10 8E 00 C8    ...H
                    os9       I$ReadLn            * Read 200 bytes from the input file       * 0028 10 3F 8B       .?.
                    bcs       Exit                * Exit on error                            * 002B 25 1C          %.
                    lda       #1                  * 002D 86 01          ..
                    os9       I$WritLn            * Write the buffer to the output path      * 002F 10 3F 8C       .?.

* Has the user pressed a key on the terminal?
                    clra                          * 0032 4F             O
                    ldb       #1                  * 0033 C6 01          F.
                    os9       I$GetStt            * Is data waiting on the terminal?         * 0035 10 3F 8D       .?.
                    bcs       CopyLoop            * No, continue listing to the output path  * 0038 25 E6          %f

* If the user presses SPACE, abort the list
                    ldy       #1                  * 003A 10 8E 00 01    ....
                    leax      Buffer,U            * 003E 30 41          0A
                    os9       I$Read              * Read a character from the terminal       * 0040 10 3F 89       .?.
                    lda       0,X                 * 0043 A6 84          &.
                    cmpa      #32                 * Did the user press SPACE?                * 0045 81 20          .
                    bne       CopyLoop            * No, continue the listing                 * 0047 26 D7          &W

Exit                clrb                          * Clear the error flag                     * 0049 5F             _
ErrExit             os9       F$Exit              * and exit                                 * 004A 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
