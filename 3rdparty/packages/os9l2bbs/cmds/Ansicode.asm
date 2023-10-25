                    nam       Ansicode
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       400
size                equ       .

name                fcs       /Ansicode/          * 000D 41 6E 73 69 63 6F 64 E5 Ansicode
L0015               fcb       $1B                 * 0015 1B             .
                    fcb       $5B                 * 0016 5B             [
start               pshs      X                   * 0017 34 10          4.
                    leax      >L0015,PC           * 0019 30 8D FF F8    0..x
                    ldy       #2                  * 001D 10 8E 00 02    ....
                    lda       #1                  * 0021 86 01          ..
                    os9       I$Write             * 0023 10 3F 8A       .?.
                    puls      X                   * 0026 35 10          5.
                    ldy       #200                * 0028 10 8E 00 C8    ...H
                    os9       I$WritLn            * 002C 10 3F 8C       .?.
                    clrb                          * 002F 5F             _
                    os9       F$Exit              * 0030 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
