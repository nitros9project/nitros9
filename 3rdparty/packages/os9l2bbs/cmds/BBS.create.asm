                    nam       BBS.create
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

inxpath             rmb       1
msgpath             rmb       1
buffer              rmb       64
U0042               rmb       200
size                equ       .

name                fcs       /BBS.create/        * 000D 42 42 53 2E 63 72 65 61 74 E5 BBS.create
                    fcc       "Copyright (C) 1988" * 0017 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 Copyright (C) 1988
                    fcc       "By Keith Alphonso" * 0029 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F By Keith Alphonso
                    fcc       "Licenced to Alpha Software Technologies" * 003A 4C 69 63 65 6E 63 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licenced to Alpha Software Technologies
                    fcc       "All rights reserved" * 0061 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 All rights reserved
                    fcb       $EC                 * 0074 EC             l
                    fcb       $E6                 * 0075 E6             f
                    fcb       $EA                 * 0076 EA             j
                    fcb       $F5                 * 0077 F5             u
                    fcb       $E9                 * 0078 E9             i
                    fcb       $A0                 * 0079 A0
                    fcb       $E2                 * 007A E2             b
                    fcb       $ED                 * 007B ED             m
                    fcb       $F1                 * 007C F1             q
                    fcb       $E9                 * 007D E9             i
                    fcb       $F0                 * 007E F0             p
                    fcb       $EF                 * 007F EF             o
                    fcb       $F4                 * 0080 F4             t
                    fcb       $F0                 * 0081 F0             p
msginx              fcc       "BBS.msg.inx"       * 0082 42 42 53 2E 6D 73 67 2E 69 6E 78 BBS.msg.inx
                    fcb       $0D                 * 008D 0D             .
bbsmsg              fcc       "BBS.msg"           * 008E 42 42 53 2E 6D 73 67 BBS.msg
                    fcb       $0D                 * 0095 0D             .

* Create BBS.msg.inx
start               leax      >msginx,PC          * 0096 30 8D FF E8    0..h
                    lda       #11                 * 009A 86 0B          ..
                    tfr       A,B                 * 009C 1F 89          ..
                    os9       I$Create            * 009E 10 3F 83       .?.
                    lbcs      Exit                * Exit on error                            * 00A1 10 25 00 33    .%.3
                    sta       inxpath,U           * 00A5 A7 C4          'D

* Create BBS.msg
                    leax      >bbsmsg,PC          * 00A7 30 8D FF E3    0..c
                    lda       #11                 * 00AB 86 0B          ..
                    tfr       A,B                 * 00AD 1F 89          ..
                    os9       I$Create            * 00AF 10 3F 83       .?.
                    lbcs      Exit                * 00B2 10 25 00 22    .%."
                    sta       msgpath,U           * 00B6 A7 41          'A

* Clear the first six bytes
                    leax      buffer,U            * 00B8 30 42          0B
                    ldd       #0                  * 00BA CC 00 00       L..
                    std       0,X                 * 00BD ED 84          m.
                    std       $02,X               * 00BF ED 02          m.
                    std       $04,X               * 00C1 ED 04          m.

* Write the buffer to BBS.msg.inx
                    lda       inxpath,U           * 00C3 A6 C4          &D
                    ldy       #64                 * 00C5 10 8E 00 40    ...@
                    os9       I$Write             * 00C9 10 3F 8A       .?.
                    lbcs      Exit                * 00CC 10 25 00 08    .%..

* Close BBS.msg.inx
                    os9       I$Close             * 00D0 10 3F 8F       .?.
                    lbcs      Exit                * 00D3 10 25 00 01    .%..

                    clrb                          * 00D7 5F             _
Exit                os9       F$Exit              * 00D8 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
