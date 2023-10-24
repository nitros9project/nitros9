                    nam       BBS.mail.post
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
U0002               rmb       1
U0003               rmb       1
U0004               rmb       1
U0005               rmb       1
U0006               rmb       1
U0007               rmb       2
U0009               rmb       1
U000A               rmb       1
U000B               rmb       1
U000C               rmb       1
U000D               rmb       2
U000F               rmb       2
U0011               rmb       2
U0013               rmb       1
U0014               rmb       1
U0015               rmb       2
U0017               rmb       2
U0019               rmb       200
U00E1               rmb       200
U01A9               rmb       1
U01AA               rmb       5
U01AF               rmb       1
U01B0               rmb       2
U01B2               rmb       2
U01B4               rmb       60
U01F0               rmb       2
U01F2               rmb       2
U01F4               rmb       20
U0208               rmb       30
U0226               rmb       6
U022C               rmb       2
U022E               rmb       2
U0230               rmb       8000
U2170               rmb       80
U21C0               rmb       1
U21C1               rmb       231
size                equ       .

name                fcs       /BBS.mail.post/     * 000D 42 42 53 2E 6D 61 69 6C 2E 70 6F 73 F4 BBS.mail.post
                    fcc       "Copyright (C) 1988" * 001A 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 Copyright (C) 1988
                    fcc       "By Keith Alphonso" * 002C 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F By Keith Alphonso
                    fcc       "Licenced to Alpha Software Technologies" * 003D 4C 69 63 65 6E 63 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licenced to Alpha Software Technologies
                    fcc       "All rights reserved" * 0064 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 All rights reserved
                    fcb       $EC                 * 0077 EC             l
                    fcb       $E6                 * 0078 E6             f
                    fcb       $EA                 * 0079 EA             j
                    fcb       $F5                 * 007A F5             u
                    fcb       $E9                 * 007B E9             i
                    fcb       $A0                 * 007C A0
                    fcb       $E2                 * 007D E2             b
                    fcb       $ED                 * 007E ED             m
                    fcb       $F1                 * 007F F1             q
                    fcb       $E9                 * 0080 E9             i
                    fcb       $F0                 * 0081 F0             p
                    fcb       $EF                 * 0082 EF             o
                    fcb       $F4                 * 0083 F4             t
                    fcb       $F0                 * 0084 F0             p
L0085               fcc       "BBS.mail.inx"      * 0085 42 42 53 2E 6D 61 69 6C 2E 69 6E 78 BBS.mail.inx
                    fcb       $0D                 * 0091 0D             .
L0092               fcc       "BBS.mail"          * 0092 42 42 53 2E 6D 61 69 6C BBS.mail
                    fcb       $0D                 * 009A 0D             .
L009B               fcc       "Enter subject of message" * 009B 45 6E 74 65 72 20 73 75 62 6A 65 63 74 20 6F 66 20 6D 65 73 73 61 67 65 Enter subject of message
                    fcb       $0D                 * 00B3 0D             .
                    fcb       $0A                 * 00B4 0A             .
                    fcc       ">"                 * 00B5 3E             >
L00B6               fcb       $00                 * 00B6 00             .
                    fcb       $1B                 * 00B7 1B             .
L00B8               fcb       $0A                 * 00B8 0A             .
                    fcb       $0A                 * 00B9 0A             .
                    fcc       "    Please enter message now            (Blank line ends)" * 00BA 20 20 20 20 50 6C 65 61 73 65 20 65 6E 74 65 72 20 6D 65 73 73 61 67 65 20 6E 6F 77 20 20 20 20 20 20 20 20 20 20 20 20 28 42 6C 61 6E 6B 20 6C 69 6E 65 20 65 6E 64
                    fcb       $0D                 * 00F3 0D             .
L00F4               fcc       "----------------------------------------------------------------" * 00F4 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 0134 0D             .
L0135               fcc       "/dd/bbs/BBS.alias" * 0135 2F 64 64 2F 62 62 73 2F 42 42 53 2E 61 6C 69 61 73 /dd/bbs/BBS.alias
                    fcb       $0D                 * 0146 0D             .
L0147               fcb       $0A                 * 0147 0A             .
                    fcc       "[A]bort [D]one [E]dit [C]ontinue or [L]ist" * 0148 5B 41 5D 62 6F 72 74 20 5B 44 5D 6F 6E 65 20 5B 45 5D 64 69 74 20 5B 43 5D 6F 6E 74 69 6E 75 65 20 6F 72 20 5B 4C 5D 69 73 74 [A]bort [D]one [E]dit [C]ontinue or [L]ist
                    fcb       $0D                 * 0172 0D             .
L0173               fcc       "Enter line #"      * 0173 45 6E 74 65 72 20 6C 69 6E 65 20 23 Enter line #
                    fcb       $0D                 * 017F 0D             .
L0180               fcc       ">"                 * 0180 3E             >
L0181               fcb       $0A                 * 0181 0A             .
                    fcb       $0D                 * 0182 0D             .
L0183               fcc       "Sorry...cannot locate that name" * 0183 53 6F 72 72 79 2E 2E 2E 63 61 6E 6E 6F 74 20 6C 6F 63 61 74 65 20 74 68 61 74 20 6E 61 6D 65 Sorry...cannot locate that name
                    fcb       $0D                 * 01A2 0D             .
L01A3               fcc       "Enter the name of the Person to send mail to" * 01A3 45 6E 74 65 72 20 74 68 65 20 6E 61 6D 65 20 6F 66 20 74 68 65 20 50 65 72 73 6F 6E 20 74 6F 20 73 65 6E 64 20 6D 61 69 6C 20 74 6F Enter the name of the Person to send mail to
                    fcb       $0D                 * 01CF 0D             .
L01D0               fcb       $08                 * 01D0 08             .
                    fcb       $20                 * 01D1 20
                    fcb       $08                 * 01D2 08             .

start               clr       >U01AF,U            * 01D3 6F C9 01 AF    oI./
                    clr       >U01A9,U            * 01D7 6F C9 01 A9    oI.)
                    clr       U0006,U             * 01DB 6F 46          oF
                    os9       F$ID                * 01DD 10 3F 0C       .?.
                    lbcs      L05C5               * 01E0 10 25 03 E1    .%.a
                    sty       U0007,U             * 01E4 10 AF 47       ./G
                    ldy       #0                  * 01E7 10 8E 00 00    ....
                    os9       F$SUser             * 01EB 10 3F 1C       .?.
                    lbcs      L05C5               * 01EE 10 25 03 D3    .%.S
L01F2               leax      >L01A3,PC           * 01F2 30 8D FF AD    0..-
                    ldy       #200                * 01F6 10 8E 00 C8    ...H
                    lda       #1                  * 01FA 86 01          ..
                    os9       I$WritLn            * 01FC 10 3F 8C       .?.
                    leax      >L0180,PC           * 01FF 30 8D FF 7D    0..}
                    ldy       #1                  * 0203 10 8E 00 01    ....
                    os9       I$Write             * 0207 10 3F 8A       .?.
                    clra                          * 020A 4F             O
                    leax      >U00E1,U            * 020B 30 C9 00 E1    0I.a
                    ldy       #200                * 020F 10 8E 00 C8    ...H
                    os9       I$ReadLn            * 0213 10 3F 8B       .?.
                    cmpy      #1                  * 0216 10 8C 00 01    ....
                    lbls      L05BE               * 021A 10 23 03 A0    .#.
L021E               lda       ,X+                 * 021E A6 80          &.
                    cmpa      #13                 * 0220 81 0D          ..
                    beq       L022E               * 0222 27 0A          '.
                    cmpa      #97                 * 0224 81 61          .a
                    bcs       L021E               * 0226 25 F6          %v
                    anda      #223                * 0228 84 DF          ._
                    sta       -$01,X              * 022A A7 1F          '.
                    bra       L021E               * 022C 20 F0           p
L022E               leax      >L0135,PC           * 022E 30 8D FF 03    0...
                    lda       #1                  * 0232 86 01          ..
                    os9       I$Open              * 0234 10 3F 84       .?.
                    lbcs      L05C5               * 0237 10 25 03 8A    .%..
                    sta       U0002,U             * 023B A7 42          'B
L023D               leax      <U0019,U            * 023D 30 C8 19       0H.
                    ldy       #200                * 0240 10 8E 00 C8    ...H
                    lda       U0002,U             * 0244 A6 42          &B
                    os9       I$ReadLn            * 0246 10 3F 8B       .?.
                    bcs       L027D               * 0249 25 32          %2
L024B               lda       ,X+                 * 024B A6 80          &.
                    cmpa      #13                 * 024D 81 0D          ..
                    beq       L025B               * 024F 27 0A          '.
                    cmpa      #97                 * 0251 81 61          .a
                    bcs       L024B               * 0253 25 F6          %v
                    anda      #223                * 0255 84 DF          ._
                    sta       -$01,X              * 0257 A7 1F          '.
                    bra       L024B               * 0259 20 F0           p
L025B               leax      <U0019,U            * 025B 30 C8 19       0H.
                    leay      >U00E1,U            * 025E 31 C9 00 E1    1I.a
L0262               lda       ,Y+                 * 0262 A6 A0          &
                    cmpa      #13                 * 0264 81 0D          ..
                    beq       L026E               * 0266 27 06          '.
                    cmpa      ,X+                 * 0268 A1 80          !.
                    beq       L0262               * 026A 27 F6          'v
                    bra       L023D               * 026C 20 CF           O
L026E               lda       ,X+                 * 026E A6 80          &.
                    cmpa      #44                 * 0270 81 2C          .,
                    bne       L023D               * 0272 26 C9          &I
                    lbsr      L0758               * 0274 17 04 E1       ..a
                    std       >U022E,U            * 0277 ED C9 02 2E    mI..
                    bra       L0293               * 027B 20 16           .
L027D               cmpb      #211                * 027D C1 D3          AS
                    lbne      L05C5               * 027F 10 26 03 42    .&.B
                    leax      >L0183,PC           * 0283 30 8D FE FC    0.~|
                    ldy       #200                * 0287 10 8E 00 C8    ...H
                    lda       #1                  * 028B 86 01          ..
                    os9       I$WritLn            * 028D 10 3F 8C       .?.
                    lbra      L01F2               * 0290 16 FF 5F       .._
L0293               leax      >L0085,PC           * 0293 30 8D FD EE    0.}n
                    lda       #1                  * 0297 86 01          ..
                    os9       I$Open              * 0299 10 3F 84       .?.
                    lbcs      L0806               * 029C 10 25 05 66    .%.f
                    sta       U0000,U             * 02A0 A7 C4          'D
                    leax      >U01B0,U            * 02A2 30 C9 01 B0    0I.0
                    ldy       #64                 * 02A6 10 8E 00 40    ...@
                    lda       U0000,U             * 02AA A6 C4          &D
                    os9       I$Read              * 02AC 10 3F 89       .?.
                    lbcs      L05C5               * 02AF 10 25 03 12    .%..
                    lda       U0000,U             * 02B3 A6 C4          &D
                    os9       I$Close             * 02B5 10 3F 8F       .?.
                    leax      >L0085,PC           * 02B8 30 8D FD C9    0.}I
                    lda       #3                  * 02BC 86 03          ..
                    os9       I$Open              * 02BE 10 3F 84       .?.
                    lbcs      L05C5               * 02C1 10 25 03 00    .%..
                    sta       U0000,U             * 02C5 A7 C4          'D
                    lda       #6                  * 02C7 86 06          ..
                    sta       U0003,U             * 02C9 A7 43          'C
                    ldd       >U01B0,U            * 02CB EC C9 01 B0    lI.0
                    addd      #1                  * 02CF C3 00 01       C..
                    std       >U01B0,U            * 02D2 ED C9 01 B0    mI.0
                    clr       U000B,U             * 02D6 6F 4B          oK
                    clr       U000C,U             * 02D8 6F 4C          oL
L02DA               aslb                          * 02DA 58             X
                    rola                          * 02DB 49             I
                    rol       U000C,U             * 02DC 69 4C          iL
                    dec       U0003,U             * 02DE 6A 43          jC
                    bne       L02DA               * 02E0 26 F8          &x
                    std       U000D,U             * 02E2 ED 4D          mM
                    lda       U0000,U             * 02E4 A6 C4          &D
                    ldx       U000B,U             * 02E6 AE 4B          .K
                    pshs      U                   * 02E8 34 40          4@
                    ldu       U000D,U             * 02EA EE 4D          nM
                    os9       I$Seek              * 02EC 10 3F 88       .?.
                    lbcs      L05C5               * 02EF 10 25 02 D2    .%.R
                    puls      U                   * 02F3 35 40          5@
                    leax      >U0226,U            * 02F5 30 C9 02 26    0I.&
                    os9       F$Time              * 02F9 10 3F 15       .?.
                    leax      >L009B,PC           * 02FC 30 8D FD 9B    0.}.
                    ldy       >L00B6,PC           * 0300 10 AE 8D FD B1 ...}1
                    lda       #1                  * 0305 86 01          ..
                    os9       I$Write             * 0307 10 3F 8A       .?.
                    lbcs      L05C5               * 030A 10 25 02 B7    .%.7
                    clra                          * 030E 4F             O
                    leax      >U0208,U            * 030F 30 C9 02 08    0I..
                    ldy       #30                 * 0313 10 8E 00 1E    ....
                    os9       I$ReadLn            * 0317 10 3F 8B       .?.
                    leax      >L00B8,PC           * 031A 30 8D FD 9A    0.}.
                    ldy       #200                * 031E 10 8E 00 C8    ...H
                    lda       #1                  * 0322 86 01          ..
                    os9       I$WritLn            * 0324 10 3F 8C       .?.
                    lbcs      L05C5               * 0327 10 25 02 9A    .%..
                    leax      >L00F4,PC           * 032B 30 8D FD C5    0.}E
                    ldy       #80                 * 032F 10 8E 00 50    ...P
                    os9       I$WritLn            * 0333 10 3F 8C       .?.
                    lbcs      L05C5               * 0336 10 25 02 8B    .%..
                    ldd       #0                  * 033A CC 00 00       L..
                    std       U0009,U             * 033D ED 49          mI
L033F               ldd       U0009,U             * 033F EC 49          lI
                    addd      #1                  * 0341 C3 00 01       C..
                    std       U0009,U             * 0344 ED 49          mI
                    cmpd      #99                 * 0346 10 83 00 63    ...c
                    bge       L0357               * 034A 2C 0B          ,.
                    lbsr      L0467               * 034C 17 01 18       ...
                    cmpy      #1                  * 034F 10 8C 00 01    ....
                    bls       L0357               * 0353 23 02          #.
                    bra       L033F               * 0355 20 E8           h
L0357               leax      >L0147,PC           * 0357 30 8D FD EC    0.}l
                    ldy       #200                * 035B 10 8E 00 C8    ...H
                    lda       #1                  * 035F 86 01          ..
                    os9       I$WritLn            * 0361 10 3F 8C       .?.
                    leax      >L0180,PC           * 0364 30 8D FE 18    0.~.
                    ldy       #1                  * 0368 10 8E 00 01    ....
                    os9       I$Write             * 036C 10 3F 8A       .?.
                    leax      U0005,U             * 036F 30 45          0E
                    clra                          * 0371 4F             O
                    ldy       #1                  * 0372 10 8E 00 01    ....
                    os9       I$Read              * 0376 10 3F 89       .?.
                    leax      >L0181,PC           * 0379 30 8D FE 04    0.~.
                    ldy       #1                  * 037D 10 8E 00 01    ....
                    lda       #1                  * 0381 86 01          ..
                    os9       I$WritLn            * 0383 10 3F 8C       .?.
                    lda       U0005,U             * 0386 A6 45          &E
                    anda      #223                * 0388 84 DF          ._
                    cmpa      #65                 * 038A 81 41          .A
                    lbeq      L05BE               * 038C 10 27 02 2E    .'..
                    cmpa      #68                 * 0390 81 44          .D
                    lbeq      L04BC               * 0392 10 27 01 26    .'.&
                    cmpa      #69                 * 0396 81 45          .E
                    beq       L03AF               * 0398 27 15          '.
                    cmpa      #67                 * 039A 81 43          .C
                    beq       L03A6               * 039C 27 08          '.
                    cmpa      #76                 * 039E 81 4C          .L
                    lbeq      L0426               * 03A0 10 27 00 82    .'..
                    bra       L0357               * 03A4 20 B1           1
L03A6               ldd       U0009,U             * 03A6 EC 49          lI
                    subd      #1                  * 03A8 83 00 01       ...
                    std       U0009,U             * 03AB ED 49          mI
                    bra       L033F               * 03AD 20 90           .
L03AF               leax      >L0173,PC           * 03AF 30 8D FD C0    0.}@
                    ldy       #200                * 03B3 10 8E 00 C8    ...H
                    lda       #1                  * 03B7 86 01          ..
                    os9       I$WritLn            * 03B9 10 3F 8C       .?.
                    leax      >L0180,PC           * 03BC 30 8D FD C0    0.}@
                    ldy       #1                  * 03C0 10 8E 00 01    ....
                    os9       I$Write             * 03C4 10 3F 8A       .?.
                    clra                          * 03C7 4F             O
                    leax      >U01AA,U            * 03C8 30 C9 01 AA    0I.*
                    ldy       #3                  * 03CC 10 8E 00 03    ....
                    os9       I$ReadLn            * 03D0 10 3F 8B       .?.
                    lbsr      L0758               * 03D3 17 03 82       ...
                    cmpd      U0009,U             * 03D6 10 A3 49       .#I
                    lbcc      L0357               * 03D9 10 24 FF 7A    .$.z
                    std       <U0017,U            * 03DD ED C8 17       mH.
                    leax      >U01AA,U            * 03E0 30 C9 01 AA    0I.*
                    lbsr      L07C8               * 03E4 17 03 E1       ..a
                    leax      >U01AA,U            * 03E7 30 C9 01 AA    0I.*
                    lda       #58                 * 03EB 86 3A          .:
                    sta       $02,X               * 03ED A7 02          '.
                    ldy       #3                  * 03EF 10 8E 00 03    ....
                    lda       #1                  * 03F3 86 01          ..
                    os9       I$Write             * 03F5 10 3F 8A       .?.
                    ldd       <U0017,U            * 03F8 EC C8 17       lH.
                    leax      >U0230,U            * 03FB 30 C9 02 30    0I.0
                    lda       #80                 * 03FF 86 50          .P
                    mul                           * 0401 3D             =
                    leax      D,X                 * 0402 30 8B          0.
                    ldy       #80                 * 0404 10 8E 00 50    ...P
                    lda       #1                  * 0408 86 01          ..
                    os9       I$WritLn            * 040A 10 3F 8C       .?.
                    tfr       Y,D                 * 040D 1F 20          .
                    stb       U0006,U             * 040F E7 46          gF
                    dec       U0006,U             * 0411 6A 46          jF
                    leay      >U2170,U            * 0413 31 C9 21 70    1I!p
L0417               lda       ,X+                 * 0417 A6 80          &.
                    sta       ,Y+                 * 0419 A7 A0          '
                    decb                          * 041B 5A             Z
                    bne       L0417               * 041C 26 F9          &y
                    ldd       <U0017,U            * 041E EC C8 17       lH.
                    bsr       L0467               * 0421 8D 44          .D
                    lbra      L0357               * 0423 16 FF 31       ..1
L0426               ldd       #0                  * 0426 CC 00 00       L..
                    std       U0009,U             * 0429 ED 49          mI
L042B               ldd       U0009,U             * 042B EC 49          lI
                    addd      #1                  * 042D C3 00 01       C..
                    std       U0009,U             * 0430 ED 49          mI
                    leax      >U01AA,U            * 0432 30 C9 01 AA    0I.*
                    lbsr      L07C8               * 0436 17 03 8F       ...
                    leax      >U01AA,U            * 0439 30 C9 01 AA    0I.*
                    lda       #58                 * 043D 86 3A          .:
                    sta       $02,X               * 043F A7 02          '.
                    lda       #1                  * 0441 86 01          ..
                    ldy       #3                  * 0443 10 8E 00 03    ....
                    os9       I$Write             * 0447 10 3F 8A       .?.
                    leax      >U0230,U            * 044A 30 C9 02 30    0I.0
                    ldd       U0009,U             * 044E EC 49          lI
                    lda       #80                 * 0450 86 50          .P
                    mul                           * 0452 3D             =
                    leax      D,X                 * 0453 30 8B          0.
                    ldy       #80                 * 0455 10 8E 00 50    ...P
                    lda       #1                  * 0459 86 01          ..
                    os9       I$WritLn            * 045B 10 3F 8C       .?.
                    cmpy      #1                  * 045E 10 8C 00 01    ....
                    bhi       L042B               * 0462 22 C7          "G
                    lbra      L0357               * 0464 16 FE F0       .~p
L0467               leax      >U01AA,U            * 0467 30 C9 01 AA    0I.*
                    pshs      D                   * 046B 34 06          4.
                    lbsr      L07C8               * 046D 17 03 58       ..X
                    leax      >U01AA,U            * 0470 30 C9 01 AA    0I.*
                    lda       #58                 * 0474 86 3A          .:
                    sta       $02,X               * 0476 A7 02          '.
                    lda       #1                  * 0478 86 01          ..
                    ldy       #3                  * 047A 10 8E 00 03    ....
                    os9       I$Write             * 047E 10 3F 8A       .?.
                    lbcs      L05C5               * 0481 10 25 01 40    .%.@
                    leax      >U2170,U            * 0485 30 C9 21 70    0I!p
                    ldb       U0006,U             * 0489 E6 46          fF
                    clra                          * 048B 4F             O
                    tfr       D,Y                 * 048C 1F 02          ..
                    lda       #1                  * 048E 86 01          ..
                    os9       I$Write             * 0490 10 3F 8A       .?.
                    puls      D                   * 0493 35 06          5.
                    lda       #80                 * 0495 86 50          .P
                    mul                           * 0497 3D             =
                    leax      >U0230,U            * 0498 30 C9 02 30    0I.0
                    leax      D,X                 * 049C 30 8B          0.
                    leay      >U2170,U            * 049E 31 C9 21 70    1I!p
                    ldb       #80                 * 04A2 C6 50          FP
                    lda       U0006,U             * 04A4 A6 46          &F
                    beq       L04B5               * 04A6 27 0D          '.
                    sta       <U0013,U            * 04A8 A7 C8 13       'H.
L04AB               lda       ,Y+                 * 04AB A6 A0          &
                    sta       ,X+                 * 04AD A7 80          '.
                    decb                          * 04AF 5A             Z
                    dec       <U0013,U            * 04B0 6A C8 13       jH.
                    bne       L04AB               * 04B3 26 F6          &v
L04B5               clra                          * 04B5 4F             O
                    tfr       D,Y                 * 04B6 1F 02          ..
                    lbsr      L05C8               * 04B8 17 01 0D       ...
                    rts                           * 04BB 39             9
L04BC               leax      >L0135,PC           * 04BC 30 8D FC 75    0.|u
                    lda       #1                  * 04C0 86 01          ..
                    os9       I$Open              * 04C2 10 3F 84       .?.
                    lbcs      L05C5               * 04C5 10 25 00 FC    .%.|
                    sta       U0002,U             * 04C9 A7 42          'B
L04CB               leax      <U0019,U            * 04CB 30 C8 19       0H.
                    ldy       #200                * 04CE 10 8E 00 C8    ...H
                    lda       U0002,U             * 04D2 A6 42          &B
                    os9       I$ReadLn            * 04D4 10 3F 8B       .?.
                    lbcs      L05C5               * 04D7 10 25 00 EA    .%.j
L04DB               lda       ,X+                 * 04DB A6 80          &.
                    cmpa      #44                 * 04DD 81 2C          .,
                    bne       L04DB               * 04DF 26 FA          &z
                    lbsr      L0758               * 04E1 17 02 74       ..t
                    cmpd      U0007,U             * 04E4 10 A3 47       .#G
                    bne       L04CB               * 04E7 26 E2          &b
                    leax      <U0019,U            * 04E9 30 C8 19       0H.
                    leay      >U01F4,U            * 04EC 31 C9 01 F4    1I.t
L04F0               lda       ,X+                 * 04F0 A6 80          &.
                    cmpa      #44                 * 04F2 81 2C          .,
                    beq       L04FA               * 04F4 27 04          '.
                    sta       ,Y+                 * 04F6 A7 A0          '
                    bra       L04F0               * 04F8 20 F6           v
L04FA               lda       #13                 * 04FA 86 0D          ..
                    sta       0,Y                 * 04FC A7 A4          '$
                    ldd       >U01B2,U            * 04FE EC C9 01 B2    lI.2
                    std       >U01F0,U            * 0502 ED C9 01 F0    mI.p
                    ldd       >U01B4,U            * 0506 EC C9 01 B4    lI.4
                    std       >U01F2,U            * 050A ED C9 01 F2    mI.r
                    ldd       U0007,U             * 050E EC 47          lG
                    std       >U022C,U            * 0510 ED C9 02 2C    mI.,
                    leax      >U01F0,U            * 0514 30 C9 01 F0    0I.p
                    lda       U0000,U             * 0518 A6 C4          &D
                    ldy       #64                 * 051A 10 8E 00 40    ...@
                    os9       I$Write             * 051E 10 3F 8A       .?.
                    lbcs      L05C5               * 0521 10 25 00 A0    .%.
                    leax      >L0092,PC           * 0525 30 8D FB 69    0.{i
                    lda       #3                  * 0529 86 03          ..
                    os9       I$Open              * 052B 10 3F 84       .?.
                    lbcs      L05C5               * 052E 10 25 00 93    .%..
                    sta       U0001,U             * 0532 A7 41          'A
                    pshs      U                   * 0534 34 40          4@
                    ldx       >U01B2,U            * 0536 AE C9 01 B2    .I.2
                    lda       U0001,U             * 053A A6 41          &A
                    ldu       >U01B4,U            * 053C EE C9 01 B4    nI.4
                    os9       I$Seek              * 0540 10 3F 88       .?.
                    lbcs      L05C5               * 0543 10 25 00 7E    .%.~
                    puls      U                   * 0547 35 40          5@
                    lda       #0                  * 0549 86 00          ..
                    sta       U000F,U             * 054B A7 4F          'O
                    ldd       #1                  * 054D CC 00 01       L..
                    std       <U0011,U            * 0550 ED C8 11       mH.
L0553               lda       U000F,U             * 0553 A6 4F          &O
                    inca                          * 0555 4C             L
                    sta       U000F,U             * 0556 A7 4F          'O
                    cmpa      U000A,U             * 0558 A1 4A          !J
                    bhi       L0582               * 055A 22 26          "&
                    ldb       #80                 * 055C C6 50          FP
                    mul                           * 055E 3D             =
                    leax      >U0230,U            * 055F 30 C9 02 30    0I.0
                    leax      D,X                 * 0563 30 8B          0.
                    ldy       #80                 * 0565 10 8E 00 50    ...P
                    lda       U0001,U             * 0569 A6 41          &A
                    os9       I$WritLn            * 056B 10 3F 8C       .?.
                    lbcs      L05C5               * 056E 10 25 00 53    .%.S
                    cmpy      #1                  * 0572 10 8C 00 01    ....
                    bls       L0582               * 0576 23 0A          #.
                    tfr       Y,D                 * 0578 1F 20          .
                    addd      <U0011,U            * 057A E3 C8 11       cH.
                    std       <U0011,U            * 057D ED C8 11       mH.
                    bra       L0553               * 0580 20 D1           Q
L0582               ldd       >U01B4,U            * 0582 EC C9 01 B4    lI.4
                    addd      <U0011,U            * 0586 E3 C8 11       cH.
                    std       >U01B4,U            * 0589 ED C9 01 B4    mI.4
                    bcc       L059A               * 058D 24 0B          $.
                    ldd       >U01B2,U            * 058F EC C9 01 B2    lI.2
                    addd      #1                  * 0593 C3 00 01       C..
                    std       >U01B2,U            * 0596 ED C9 01 B2    mI.2
L059A               pshs      U                   * 059A 34 40          4@
                    lda       U0000,U             * 059C A6 C4          &D
                    ldx       #0                  * 059E 8E 00 00       ...
                    ldu       #0                  * 05A1 CE 00 00       N..
                    os9       I$Seek              * 05A4 10 3F 88       .?.
                    lbcs      L05C5               * 05A7 10 25 00 1A    .%..
                    puls      U                   * 05AB 35 40          5@
                    leax      >U01B0,U            * 05AD 30 C9 01 B0    0I.0
                    ldy       #64                 * 05B1 10 8E 00 40    ...@
                    lda       U0000,U             * 05B5 A6 C4          &D
                    os9       I$Write             * 05B7 10 3F 8A       .?.
                    lbcs      L05C5               * 05BA 10 25 00 07    .%..
L05BE               clrb                          * 05BE 5F             _
                    ldy       U0007,U             * 05BF 10 AE 47       ..G
                    os9       F$SUser             * 05C2 10 3F 1C       .?.
L05C5               os9       F$Exit              * 05C5 10 3F 06       .?.
L05C8               lbsr      L0721               * 05C8 17 01 56       ..V
                    ldb       U0006,U             * 05CB E6 46          fF
                    leay      B,Y                 * 05CD 31 A5          1%
                    pshs      Y                   * 05CF 34 20          4
                    negb                          * 05D1 50             P
                    sex                           * 05D2 1D             .
                    leay      D,Y                 * 05D3 31 AB          1+
                    clr       U0006,U             * 05D5 6F 46          oF
                    cmpy      #0                  * 05D7 10 8C 00 00    ....
                    lbeq      L0697               * 05DB 10 27 00 B8    .'.8
                    pshs      Y,X                 * 05DF 34 30          40
                    lda       #13                 * 05E1 86 0D          ..
L05E3               sta       ,X+                 * 05E3 A7 80          '.
                    leay      -$01,Y              * 05E5 31 3F          1?
                    bne       L05E3               * 05E7 26 FA          &z
                    puls      Y,X                 * 05E9 35 30          50
L05EB               pshs      Y,X                 * 05EB 34 30          40
                    leax      U0005,U             * 05ED 30 45          0E
                    ldy       #1                  * 05EF 10 8E 00 01    ....
                    clra                          * 05F3 4F             O
                    os9       I$Read              * 05F4 10 3F 89       .?.
                    bcs       L0624               * 05F7 25 2B          %+
                    lda       U0005,U             * 05F9 A6 45          &E
                    cmpa      #1                  * 05FB 81 01          ..
                    beq       L0628               * 05FD 27 29          ')
                    cmpa      #8                  * 05FF 81 08          ..
                    beq       L064A               * 0601 27 47          'G
                    cmpa      #24                 * 0603 81 18          ..
                    beq       L066E               * 0605 27 67          'g
                    cmpa      #13                 * 0607 81 0D          ..
                    lbeq      L0695               * 0609 10 27 00 88    .'..
                    cmpa      #32                 * 060D 81 20          .
                    bcs       L0624               * 060F 25 13          %.
                    lda       #1                  * 0611 86 01          ..
                    os9       I$Write             * 0613 10 3F 8A       .?.
                    puls      Y,X                 * 0616 35 30          50
                    lda       U0005,U             * 0618 A6 45          &E
                    sta       ,X+                 * 061A A7 80          '.
                    leay      -$01,Y              * 061C 31 3F          1?
                    lbeq      L06BE               * 061E 10 27 00 9C    .'..
                    bra       L05EB               * 0622 20 C7           G
L0624               puls      Y,X                 * 0624 35 30          50
                    bra       L05EB               * 0626 20 C3           C
L0628               puls      Y,X                 * 0628 35 30          50
                    leay      -$01,Y              * 062A 31 3F          1?
                    beq       L0645               * 062C 27 17          '.
                    lda       ,X+                 * 062E A6 80          &.
                    cmpa      #13                 * 0630 81 0D          ..
                    beq       L0643               * 0632 27 0F          '.
                    pshs      Y,X                 * 0634 34 30          40
                    leax      -$01,X              * 0636 30 1F          0.
                    ldy       #1                  * 0638 10 8E 00 01    ....
                    lda       #1                  * 063C 86 01          ..
                    os9       I$Write             * 063E 10 3F 8A       .?.
                    bra       L0628               * 0641 20 E5           e
L0643               leax      -$01,X              * 0643 30 1F          0.
L0645               leay      $01,Y               * 0645 31 21          1!
                    lbra      L05EB               * 0647 16 FF A1       ..!
L064A               puls      Y,X                 * 064A 35 30          50
                    leay      $01,Y               * 064C 31 21          1!
                    cmpy      0,S                 * 064E 10 AC E4       .,d
                    bhi       L0669               * 0651 22 16          ".
                    pshs      Y,X                 * 0653 34 30          40
                    leax      >L01D0,PC           * 0655 30 8D FB 77    0.{w
                    ldy       #3                  * 0659 10 8E 00 03    ....
                    lda       #1                  * 065D 86 01          ..
                    os9       I$Write             * 065F 10 3F 8A       .?.
                    puls      Y,X                 * 0662 35 30          50
                    leax      -$01,X              * 0664 30 1F          0.
                    lbra      L05EB               * 0666 16 FF 82       ...
L0669               leay      -$01,Y              * 0669 31 3F          1?
                    lbra      L05EB               * 066B 16 FF 7D       ..}
L066E               puls      Y,X                 * 066E 35 30          50
                    leay      $01,Y               * 0670 31 21          1!
                    cmpy      0,S                 * 0672 10 AC E4       .,d
                    bhi       L0669               * 0675 22 F2          "r
                    pshs      Y,X                 * 0677 34 30          40
                    leax      >L01D0,PC           * 0679 30 8D FB 53    0.{S
                    ldy       #3                  * 067D 10 8E 00 03    ....
                    lda       #1                  * 0681 86 01          ..
                    os9       I$Write             * 0683 10 3F 8A       .?.
                    puls      Y,X                 * 0686 35 30          50
                    leax      -$01,X              * 0688 30 1F          0.
                    cmpy      0,S                 * 068A 10 AC E4       .,d
                    lbhi      L05EB               * 068D 10 22 FF 5A    .".Z
                    pshs      Y,X                 * 0691 34 30          40
                    bra       L066E               * 0693 20 D9           Y
L0695               puls      Y,X                 * 0695 35 30          50
L0697               lda       #13                 * 0697 86 0D          ..
                    sta       ,X+                 * 0699 A7 80          '.
                    pshs      Y,X                 * 069B 34 30          40
                    leax      >L0181,PC           * 069D 30 8D FA E0    0.z`
                    ldy       #1                  * 06A1 10 8E 00 01    ....
                    lda       #1                  * 06A5 86 01          ..
                    os9       I$WritLn            * 06A7 10 3F 8C       .?.
                    puls      Y,X                 * 06AA 35 30          50
                    puls      D                   * 06AC 35 06          5.
                    pshs      Y                   * 06AE 34 20          4
                    subd      0,S                 * 06B0 A3 E4          #d
                    leas      $02,S               * 06B2 32 62          2b
                    tfr       D,Y                 * 06B4 1F 02          ..
                    leay      $01,Y               * 06B6 31 21          1!
                    lbsr      L073B               * 06B8 17 00 80       ...
                    rts                           * 06BB 39             9
                    fcc       "50"                * 06BC 35 30          50
L06BE               puls      D                   * 06BE 35 06          5.
                    pshs      Y                   * 06C0 34 20          4
                    subd      0,S                 * 06C2 A3 E4          #d
                    leas      $02,S               * 06C4 32 62          2b
                    addd      #1                  * 06C6 C3 00 01       C..
                    tfr       D,Y                 * 06C9 1F 02          ..
                    clrb                          * 06CB 5F             _
L06CC               leay      -$01,Y              * 06CC 31 3F          1?
                    beq       L06EA               * 06CE 27 1A          '.
                    lda       ,-X                 * 06D0 A6 82          &.
                    cmpa      #32                 * 06D2 81 20          .
                    beq       L06FB               * 06D4 27 25          '%
                    pshs      Y,X                 * 06D6 34 30          40
                    leax      >L01D0,PC           * 06D8 30 8D FA F4    0.zt
                    ldy       #3                  * 06DC 10 8E 00 03    ....
                    lda       #1                  * 06E0 86 01          ..
                    os9       I$Write             * 06E2 10 3F 8A       .?.
                    incb                          * 06E5 5C             \
                    puls      Y,X                 * 06E6 35 30          50
                    bra       L06CC               * 06E8 20 E2           b
L06EA               lda       #13                 * 06EA 86 0D          ..
                    sta       <$004F,X            * 06EC A7 88 4F       '.O
                    ldy       #200                * 06EF 10 8E 00 C8    ...H
                    lda       #1                  * 06F3 86 01          ..
                    os9       I$WritLn            * 06F5 10 3F 8C       .?.
                    puls      Y                   * 06F8 35 20          5
                    rts                           * 06FA 39             9
L06FB               lda       #13                 * 06FB 86 0D          ..
                    sta       ,X+                 * 06FD A7 80          '.
                    pshs      Y,X                 * 06FF 34 30          40
                    stb       U0006,U             * 0701 E7 46          gF
                    leay      >U2170,U            * 0703 31 C9 21 70    1I!p
L0707               lda       ,X+                 * 0707 A6 80          &.
                    sta       ,Y+                 * 0709 A7 A0          '
                    decb                          * 070B 5A             Z
                    bne       L0707               * 070C 26 F9          &y
                    leax      >L0181,PC           * 070E 30 8D FA 6F    0.zo
                    ldy       #1                  * 0712 10 8E 00 01    ....
                    lda       #1                  * 0716 86 01          ..
                    os9       I$WritLn            * 0718 10 3F 8C       .?.
                    puls      Y,X                 * 071B 35 30          50
                    lbsr      L073B               * 071D 17 00 1B       ...
                    rts                           * 0720 39             9
L0721               pshs      Y,X,D               * 0721 34 36          46
                    leax      >U21C0,U            * 0723 30 C9 21 C0    0I!@
                    clra                          * 0727 4F             O
                    ldb       #0                  * 0728 C6 00          F.
                    os9       I$GetStt            * 072A 10 3F 8D       .?.
                    leax      -$20,X              * 072D 30 88 E0       0.`
                    clr       <$0024,X            * 0730 6F 88 24       o.$
                    leax      <$0020,X            * 0733 30 88 20       0.
                    os9       I$SetStt            * 0736 10 3F 8E       .?.
                    puls      PC,Y,X,D            * 0739 35 B6          56
L073B               pshs      Y,X,D               * 073B 34 36          46
                    leax      >U21C0,U            * 073D 30 C9 21 C0    0I!@
                    clra                          * 0741 4F             O
                    ldb       #0                  * 0742 C6 00          F.
                    os9       I$GetStt            * 0744 10 3F 8D       .?.
                    leax      -$20,X              * 0747 30 88 E0       0.`
                    lda       #1                  * 074A 86 01          ..
                    sta       <$0024,X            * 074C A7 88 24       '.$
                    leax      <$0020,X            * 074F 30 88 20       0.
                    clra                          * 0752 4F             O
                    os9       I$SetStt            * 0753 10 3F 8E       .?.
                    puls      PC,Y,X,D            * 0756 35 B6          56
L0758               pshs      Y                   * 0758 34 20          4
L075A               lda       ,X+                 * 075A A6 80          &.
                    cmpa      #13                 * 075C 81 0D          ..
                    lbeq      L0801               * 075E 10 27 00 9F    .'..
                    cmpa      #48                 * 0762 81 30          .0
                    bcs       L075A               * 0764 25 F4          %t
                    cmpa      #57                 * 0766 81 39          .9
                    bhi       L075A               * 0768 22 F0          "p
                    leax      -$01,X              * 076A 30 1F          0.
L076C               lda       ,X+                 * 076C A6 80          &.
                    cmpa      #48                 * 076E 81 30          .0
                    bcs       L0778               * 0770 25 06          %.
                    cmpa      #57                 * 0772 81 39          .9
                    bhi       L0778               * 0774 22 02          ".
                    bra       L076C               * 0776 20 F4           t
L0778               pshs      X                   * 0778 34 10          4.
                    leax      -$01,X              * 077A 30 1F          0.
                    clr       <U0013,U            * 077C 6F C8 13       oH.
                    clr       <U0014,U            * 077F 6F C8 14       oH.
                    ldd       #1                  * 0782 CC 00 01       L..
                    std       <U0015,U            * 0785 ED C8 15       mH.
L0788               lda       ,-X                 * 0788 A6 82          &.
                    cmpa      #48                 * 078A 81 30          .0
                    bcs       L07C1               * 078C 25 33          %3
                    cmpa      #57                 * 078E 81 39          .9
                    bhi       L07C1               * 0790 22 2F          "/
                    suba      #48                 * 0792 80 30          .0
                    sta       U0004,U             * 0794 A7 44          'D
                    ldd       #0                  * 0796 CC 00 00       L..
L0799               tst       U0004,U             * 0799 6D 44          mD
                    beq       L07A4               * 079B 27 07          '.
                    addd      <U0015,U            * 079D E3 C8 15       cH.
                    dec       U0004,U             * 07A0 6A 44          jD
                    bra       L0799               * 07A2 20 F5           u
L07A4               addd      <U0013,U            * 07A4 E3 C8 13       cH.
                    std       <U0013,U            * 07A7 ED C8 13       mH.
                    lda       #10                 * 07AA 86 0A          ..
                    sta       U0004,U             * 07AC A7 44          'D
                    ldd       #0                  * 07AE CC 00 00       L..
L07B1               tst       U0004,U             * 07B1 6D 44          mD
                    beq       L07BC               * 07B3 27 07          '.
                    addd      <U0015,U            * 07B5 E3 C8 15       cH.
                    dec       U0004,U             * 07B8 6A 44          jD
                    bra       L07B1               * 07BA 20 F5           u
L07BC               std       <U0015,U            * 07BC ED C8 15       mH.
                    bra       L0788               * 07BF 20 C7           G
L07C1               ldd       <U0013,U            * 07C1 EC C8 13       lH.
                    puls      X                   * 07C4 35 10          5.
                    puls      PC,Y                * 07C6 35 A0          5
L07C8               pshs      Y                   * 07C8 34 20          4
                    std       <U0013,U            * 07CA ED C8 13       mH.
                    lda       #48                 * 07CD 86 30          .0
                    sta       0,X                 * 07CF A7 84          '.
                    sta       $01,X               * 07D1 A7 01          '.
                    ldd       #10                 * 07D3 CC 00 0A       L..
                    std       <U0015,U            * 07D6 ED C8 15       mH.
                    ldd       <U0013,U            * 07D9 EC C8 13       lH.
                    bsr       L07EF               * 07DC 8D 11          ..
                    ldd       #1                  * 07DE CC 00 01       L..
                    std       <U0015,U            * 07E1 ED C8 15       mH.
                    ldd       <U0013,U            * 07E4 EC C8 13       lH.
                    bsr       L07EF               * 07E7 8D 06          ..
                    lda       #13                 * 07E9 86 0D          ..
                    sta       0,X                 * 07EB A7 84          '.
                    puls      PC,Y                * 07ED 35 A0          5
L07EF               subd      <U0015,U            * 07EF A3 C8 15       #H.
                    bcs       L07F8               * 07F2 25 04          %.
                    inc       0,X                 * 07F4 6C 84          l.
                    bra       L07EF               * 07F6 20 F7           w
L07F8               addd      <U0015,U            * 07F8 E3 C8 15       cH.
                    std       <U0013,U            * 07FB ED C8 13       mH.
                    leax      $01,X               * 07FE 30 01          0.
                    rts                           * 0800 39             9
L0801               ldd       #-1                 * 0801 CC FF FF       L..
                    puls      PC,Y                * 0804 35 A0          5
L0806               leax      >L0085,PC           * 0806 30 8D F8 7B    0.x{
                    lda       #11                 * 080A 86 0B          ..
                    tfr       A,B                 * 080C 1F 89          ..
                    os9       I$Create            * 080E 10 3F 83       .?.
                    lbcs      L05C5               * 0811 10 25 FD B0    .%}0
                    sta       U0000,U             * 0815 A7 C4          'D
                    leax      >L0092,PC           * 0817 30 8D F8 77    0.xw
                    lda       #11                 * 081B 86 0B          ..
                    tfr       A,B                 * 081D 1F 89          ..
                    os9       I$Create            * 081F 10 3F 83       .?.
                    lbcs      L05C5               * 0822 10 25 FD 9F    .%}.
                    sta       U0001,U             * 0826 A7 41          'A
                    leax      >U01B0,U            * 0828 30 C9 01 B0    0I.0
                    ldd       #0                  * 082C CC 00 00       L..
                    std       0,X                 * 082F ED 84          m.
                    std       $02,X               * 0831 ED 02          m.
                    std       $04,X               * 0833 ED 04          m.
                    lda       U0000,U             * 0835 A6 C4          &D
                    ldy       #64                 * 0837 10 8E 00 40    ...@
                    os9       I$Write             * 083B 10 3F 8A       .?.
                    lbcs      L05C5               * 083E 10 25 FD 83    .%}.
                    os9       I$Close             * 0842 10 3F 8F       .?.
                    lbcs      L05C5               * 0845 10 25 FD 7C    .%}|
                    lda       U0000,U             * 0849 A6 C4          &D
                    os9       I$Close             * 084B 10 3F 8F       .?.
                    lda       U0001,U             * 084E A6 41          &A
                    os9       I$Close             * 0850 10 3F 8F       .?.
                    lbra      L0293               * 0853 16 FA 3D       .z=

                    emod
eom                 equ       *
                    end
