                    nam       BBS.convert
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

inxpath             rmb       1
buffer              rmb       62
U003F               rmb       400
size                equ       .

name                fcs       /BBS.convert/       * 000D 42 42 53 2E 63 6F 6E 76 65 72 F4 BBS.convert
L0018               fcb       $FF                 * 0018 FF             .
                    fcb       $FF                 * 0019 FF             .
msginx              fcc       "BBS.msg.inx"       * 001A 42 42 53 2E 6D 73 67 2E 69 6E 78 BBS.msg.inx
                    fcb       $0D                 * 0025 0D             .

start               leax      >msginx,PC          * 0026 30 8D FF F0    0..p
                    lda       #3                  * 002A 86 03          ..
                    os9       I$Open              * Open BBS.msg.inx                         * 002C 10 3F 84       .?.
                    lbcs      ErrExit             * Exit on error                            * 002F 10 25 00 21    .%.!
                    sta       inxpath,U           * Save the path                            * 0033 A7 C4          'D

Loop                lda       inxpath,U           * Get the path                             * 0035 A6 C4          &D
                    leax      buffer,U            * 0037 30 41          0A
                    ldy       #62                 * 0039 10 8E 00 3E    ...>
                    os9       I$Read              * Read 62 bytes                            * 003D 10 3F 89       .?.
                    lbcs      Exit                * Exit on error/EOF                        * 0040 10 25 00 0F    .%..

                    leax      >L0018,PC           * 0044 30 8D FF D0    0..P
                    ldy       #2                  * 0048 10 8E 00 02    ....
                    lda       inxpath,U           * 004C A6 C4          &D
                    os9       I$Write             * Write $FFFF to BBS.msg.inx               * 004E 10 3F 8A       .?.
                    bra       Loop                * Repeat for next block                    * 0051 20 E2           b

Exit                clrb                          * 0053 5F             _
ErrExit             os9       F$Exit              * 0054 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
