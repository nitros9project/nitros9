                    nam       ViewBBS
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       1
U0001               rmb       400
size                equ       .

name                fcs       /ViewBBS/           * 000D 56 69 65 77 42 42 D3 ViewBBS
L0014               fcc       "/wb"               * 0014 2F 77 62       /wb
                    fcb       $0D                 * 0017 0D             .
L0018               fcb       $1B                 * 0018 1B             .
                    fcb       $21                 * 0019 21             !
start               leax      >L0014,PC           * 001A 30 8D FF F6    0..v
                    lda       #3                  * 001E 86 03          ..
                    os9       I$Open              * 0020 10 3F 84       .?.
                    lbcs      L004E               * 0023 10 25 00 27    .%.'
                    sta       U0000,U             * 0027 A7 C4          'D
                    leax      >L0018,PC           * 0029 30 8D FF EB    0..k
                    ldy       #2                  * 002D 10 8E 00 02    ....
                    lda       U0000,U             * 0031 A6 C4          &D
                    os9       I$Write             * 0033 10 3F 8A       .?.
                    clra                          * 0036 4F             O
                    os9       I$Close             * 0037 10 3F 8F       .?.
                    inca                          * 003A 4C             L
                    os9       I$Close             * 003B 10 3F 8F       .?.
                    inca                          * 003E 4C             L
                    os9       I$Close             * 003F 10 3F 8F       .?.
                    lda       U0000,U             * 0042 A6 C4          &D
                    os9       I$Dup               * 0044 10 3F 82       .?.
                    os9       I$Dup               * 0047 10 3F 82       .?.
                    os9       I$Dup               * 004A 10 3F 82       .?.
                    clrb                          * 004D 5F             _
L004E               os9       F$Exit              * 004E 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
