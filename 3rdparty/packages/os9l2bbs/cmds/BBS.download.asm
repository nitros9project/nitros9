                    nam       BBS.download
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       1
U0001               rmb       1
U0002               rmb       2
U0004               rmb       2
U0006               rmb       2
U0008               rmb       6
U000E               rmb       2
U0010               rmb       2
U0012               rmb       2
U0014               rmb       2
U0016               rmb       414
size                equ       .

name                fcs       /BBS.download/      * 000D 42 42 53 2E 64 6F 77 6E 6C 6F 61 E4 BBS.download
                    fcc       "Enter your download protocol" * 0019 45 6E 74 65 72 20 79 6F 75 72 20 64 6F 77 6E 6C 6F 61 64 20 70 72 6F 74 6F 63 6F 6C Enter your download protocol
                    fcb       $0D                 * 0035 0D             .
L0036               fcb       $0A                 * 0036 0A             .
                    fcb       $0D                 * 0037 0D             .
                    fcc       "[A] Ascii"         * 0038 5B 41 5D 20 41 73 63 69 69 [A] Ascii
                    fcb       $0A                 * 0041 0A             .
                    fcb       $0D                 * 0042 0D             .
                    fcc       "[X] xmodem"        * 0043 5B 58 5D 20 78 6D 6F 64 65 6D [X] xmodem
                    fcb       $0A                 * 004D 0A             .
                    fcb       $0D                 * 004E 0D             .
                    fcc       "[C] xmodem (CRC)"  * 004F 5B 43 5D 20 78 6D 6F 64 65 6D 20 28 43 52 43 29 [C] xmodem (CRC)
                    fcb       $0A                 * 005F 0A             .
                    fcb       $0D                 * 0060 0D             .
                    fcc       "[Y] ymodem"        * 0061 5B 59 5D 20 79 6D 6F 64 65 6D [Y] ymodem
                    fcb       $0A                 * 006B 0A             .
                    fcb       $0D                 * 006C 0D             .
                    fcc       "[Q] quit"          * 006D 5B 51 5D 20 71 75 69 74 [Q] quit
                    fcb       $0A                 * 0075 0A             .
                    fcb       $0D                 * 0076 0D             .
                    fcc       "Protocol?"         * 0077 50 72 6F 74 6F 63 6F 6C 3F Protocol?
L0080               fcc       "dloadx"            * 0080 64 6C 6F 61 64 78 dloadx
                    fcb       $0D                 * 0086 0D             .
L0087               fcc       "dloadxc"           * 0087 64 6C 6F 61 64 78 63 dloadxc
                    fcb       $0D                 * 008E 0D             .
L008F               fcc       "dloady"            * 008F 64 6C 6F 61 64 79 dloady
                    fcb       $0D                 * 0095 0D             .
                    fcc       "dloadyb"           * 0096 64 6C 6F 61 64 79 62 dloadyb
                    fcb       $0D                 * 009D 0D             .
L009E               fcc       "Dloada"            * 009E 44 6C 6F 61 64 61 Dloada
                    fcb       $0D                 * 00A4 0D             .
L00A5               fcb       $0D                 * 00A5 0D             .
                    fcb       $0A                 * 00A6 0A             .
L00A7               fcc       "/dd/bbs/BBS.userstats" * 00A7 2F 64 64 2F 62 62 73 2F 42 42 53 2E 75 73 65 72 73 74 61 74 73 /dd/bbs/BBS.userstats
                    fcb       $0D                 * 00BC 0D             .

start               lda       0,X                 * 00BD A6 84          &.
                    cmpa      #13                 * 00BF 81 0D          ..
                    beq       L00CC               * 00C1 27 09          '.
                    lda       #1                  * 00C3 86 01          ..
                    os9       I$ChgDir            * 00C5 10 3F 86       .?.
                    lbcs      L01F6               * 00C8 10 25 01 2A    .%.*
L00CC               leax      >L0036,PC           * 00CC 30 8D FF 66    0..f
                    ldy       #74                 * 00D0 10 8E 00 4A    ...J
                    lda       #1                  * 00D4 86 01          ..
                    os9       I$Write             * 00D6 10 3F 8A       .?.
                    leax      U0000,U             * 00D9 30 C4          0D
                    ldy       #1                  * 00DB 10 8E 00 01    ....
                    clra                          * 00DF 4F             O
                    os9       I$Read              * 00E0 10 3F 89       .?.
                    leax      >L00A5,PC           * 00E3 30 8D FF BE    0..>
                    ldy       #1                  * 00E7 10 8E 00 01    ....
                    lda       #1                  * 00EB 86 01          ..
                    os9       I$Write             * 00ED 10 3F 8A       .?.
                    lda       U0000,U             * 00F0 A6 C4          &D
                    anda      #223                * 00F2 84 DF          ._
                    cmpa      #65                 * 00F4 81 41          .A
                    beq       L011E               * 00F6 27 26          '&
                    cmpa      #88                 * 00F8 81 58          .X
                    beq       L010C               * 00FA 27 10          '.
                    cmpa      #89                 * 00FC 81 59          .Y
                    beq       L0112               * 00FE 27 12          '.
                    cmpa      #67                 * 0100 81 43          .C
                    beq       L0118               * 0102 27 14          '.
                    cmpa      #81                 * 0104 81 51          .Q
                    lbeq      L01F5               * 0106 10 27 00 EB    .'.k
                    bra       L00CC               * 010A 20 C0           @
L010C               leax      >L0080,PC           * 010C 30 8D FF 70    0..p
                    bra       L0124               * 0110 20 12           .
L0112               leax      >L008F,PC           * 0112 30 8D FF 79    0..y
                    bra       L0124               * 0116 20 0C           .
L0118               leax      >L0087,PC           * 0118 30 8D FF 6B    0..k
                    bra       L0124               * 011C 20 06           .
L011E               leax      >L009E,PC           * 011E 30 8D FF 7C    0..|
                    bra       L0124               * 0122 20 00           .
L0124               ldy       #1                  * 0124 10 8E 00 01    ....
                    lda       #17                 * 0128 86 11          ..
                    ldb       #3                  * 012A C6 03          F.
                    pshs      U                   * 012C 34 40          4@
                    leau      >L00A5,PC           * 012E 33 8D FF 73    3..s
                    os9       F$Fork              * 0132 10 3F 03       .?.
                    lbcs      L01F6               * 0135 10 25 00 BD    .%.=
                    clrb                          * 0139 5F             _
                    os9       F$Wait              * 013A 10 3F 04       .?.
                    lbcs      L01F6               * 013D 10 25 00 B5    .%.5
                    cmpb      #0                  * 0141 C1 00          A.
                    lbne      L01F6               * 0143 10 26 00 AF    .&./
                    puls      U                   * 0147 35 40          5@
                    leax      >L00A7,PC           * 0149 30 8D FF 5A    0..Z
                    lda       #3                  * 014D 86 03          ..
                    os9       I$Open              * 014F 10 3F 84       .?.
                    bcc       L015D               * 0152 24 09          $.
                    ldb       #27                 * 0154 C6 1B          F.
                    os9       I$Create            * 0156 10 3F 83       .?.
                    lbcs      L01F6               * 0159 10 25 00 99    .%..
L015D               sta       U0001,U             * 015D A7 41          'A
                    os9       F$ID                * 015F 10 3F 0C       .?.
                    sty       U0002,U             * 0162 10 AF 42       ./B
L0165               leax      U0004,U             * 0165 30 44          0D
                    ldy       #32                 * 0167 10 8E 00 20    ...
                    lda       U0001,U             * 016B A6 41          &A
                    os9       I$Read              * 016D 10 3F 89       .?.
                    bcs       L017B               * 0170 25 09          %.
                    ldd       U0004,U             * 0172 EC 44          lD
                    cmpd      U0002,U             * 0174 10 A3 42       .#B
                    bne       L0165               * 0177 26 EC          &l
                    bra       L0184               * 0179 20 09           .
L017B               cmpb      #211                * 017B C1 D3          AS
                    lbne      L01F6               * 017D 10 26 00 75    .&.u
                    lbra      L01C1               * 0181 16 00 3D       ..=
L0184               ldd       <U0012,U            * 0184 EC C8 12       lH.
                    addd      #1                  * 0187 C3 00 01       C..
                    std       <U0012,U            * 018A ED C8 12       mH.
                    lda       U0001,U             * 018D A6 41          &A
                    ldb       #5                  * 018F C6 05          F.
                    pshs      U                   * 0191 34 40          4@
                    os9       I$GetStt            * 0193 10 3F 8D       .?.
                    tfr       U,D                 * 0196 1F 30          .0
                    subd      #32                 * 0198 83 00 20       ..
                    bge       L019F               * 019B 2C 02          ,.
                    leax      -$01,X              * 019D 30 1F          0.
L019F               ldu       0,S                 * 019F EE E4          nd
                    tfr       D,Y                 * 01A1 1F 02          ..
                    lda       U0001,U             * 01A3 A6 41          &A
                    tfr       Y,U                 * 01A5 1F 23          .#
                    os9       I$Seek              * 01A7 10 3F 88       .?.
                    lbcs      L01F6               * 01AA 10 25 00 48    .%.H
                    puls      U                   * 01AE 35 40          5@
                    leax      U0004,U             * 01B0 30 44          0D
                    ldy       #32                 * 01B2 10 8E 00 20    ...
                    lda       U0001,U             * 01B6 A6 41          &A
                    os9       I$Write             * 01B8 10 3F 8A       .?.
                    os9       I$Close             * 01BB 10 3F 8F       .?.
                    lbra      L01F5               * 01BE 16 00 34       ..4
L01C1               leax      U0004,U             * 01C1 30 44          0D
                    ldd       #1                  * 01C3 CC 00 01       L..
                    std       U0006,U             * 01C6 ED 46          mF
                    std       <U0010,U            * 01C8 ED C8 10       mH.
                    ldd       #0                  * 01CB CC 00 00       L..
                    std       U000E,U             * 01CE ED 4E          mN
                    std       <U0014,U            * 01D0 ED C8 14       mH.
                    std       <U0012,U            * 01D3 ED C8 12       mH.
                    ldd       U0002,U             * 01D6 EC 42          lB
                    std       U0004,U             * 01D8 ED 44          mD
                    leax      U0008,U             * 01DA 30 48          0H
                    os9       F$Time              * 01DC 10 3F 15       .?.
                    lbcs      L01F6               * 01DF 10 25 00 13    .%..
                    leax      U0004,U             * 01E3 30 44          0D
                    ldy       #32                 * 01E5 10 8E 00 20    ...
                    lda       U0001,U             * 01E9 A6 41          &A
                    os9       I$Write             * 01EB 10 3F 8A       .?.
                    os9       I$Close             * 01EE 10 3F 8F       .?.
                    lbcs      L01F6               * 01F1 10 25 00 01    .%..
L01F5               clrb                          * 01F5 5F             _
L01F6               os9       F$Exit              * 01F6 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
