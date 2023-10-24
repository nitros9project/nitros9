                    nam       DLD.add
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
U0005               rmb       80
U0055               rmb       32
U0075               rmb       27
U0090               rmb       2
U0092               rmb       2
U0094               rmb       1
U0095               rmb       64
U00D5               rmb       31
U00F4               rmb       65
U0135               rmb       12
U0141               rmb       2
U0143               rmb       2
U0145               rmb       2
U0147               rmb       3
U014A               rmb       1
U014B               rmb       1
U014C               rmb       1
U014D               rmb       2
U014F               rmb       1
U0150               rmb       1
U0151               rmb       2
U0153               rmb       2
U0155               rmb       3
U0158               rmb       1
U0159               rmb       8399
size                equ       .

name                fcs       /DLD.add/           * 000D 44 4C 44 2E 61 64 E4 DLD.add
                    fcc       "Copyright (C) 1988By Keith AlphonsoLicenced to Alpha Software TechnologiesAll rights reserved" * 0014 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 4C 69 63 65 6E 63 65 64
                    fcb       $EC                 * 0071 EC             l
                    fcb       $E6                 * 0072 E6             f
                    fcb       $EA                 * 0073 EA             j
                    fcb       $F5                 * 0074 F5             u
                    fcb       $E9                 * 0075 E9             i
                    fcb       $A0                 * 0076 A0
                    fcb       $E2                 * 0077 E2             b
                    fcb       $ED                 * 0078 ED             m
                    fcb       $F1                 * 0079 F1             q
                    fcb       $E9                 * 007A E9             i
                    fcb       $F0                 * 007B F0             p
                    fcb       $EF                 * 007C EF             o
                    fcb       $F4                 * 007D F4             t
                    fcb       $F0                 * 007E F0             p
L007F               fcc       "Enter filename to add:" * 007F 45 6E 74 65 72 20 66 69 6C 65 6E 61 6D 65 20 74 6F 20 61 64 64 3A Enter filename to add:
L0095               fcc       "DLD.lst"           * 0095 44 4C 44 2E 6C 73 74 DLD.lst
                    fcb       $0D                 * 009C 0D             .
L009D               fcc       "DLD.key"           * 009D 44 4C 44 2E 6B 65 79 DLD.key
                    fcb       $0D                 * 00A4 0D             .
L00A5               fcc       "DLD.dsc"           * 00A5 44 4C 44 2E 64 73 63 DLD.dsc
                    fcb       $0D                 * 00AC 0D             .
                    fcb       $0D                 * 00AD 0D             .
                    fcb       $0A                 * 00AE 0A             .
L00AF               fcc       "Enter a one-line description of this file" * 00AF 45 6E 74 65 72 20 61 20 6F 6E 65 2D 6C 69 6E 65 20 64 65 73 63 72 69 70 74 69 6F 6E 20 6F 66 20 74 68 69 73 20 66 69 6C 65 Enter a one-line description of this file
                    fcb       $0D                 * 00D8 0D             .
L00D9               fcc       "----------------------------------------------------------------" * 00D9 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 0119 0D             .
L011A               fcb       $3E                 * 011A 3E             >
                    fcb       $0D                 * 011B 0D             .
L011C               fcc       "     Enter file keywords now            (Blank line ends)" * 011C 20 20 20 20 20 45 6E 74 65 72 20 66 69 6C 65 20 6B 65 79 77 6F 72 64 73 20 6E 6F 77 20 20 20 20 20 20 20 20 20 20 20 20 28 42 6C 61 6E 6B 20 6C 69 6E 65 20 65 6E 64
                    fcb       $0D                 * 0155 0D             .
L0156               fcb       $0A                 * 0156 0A             .
                    fcb       $0A                 * 0157 0A             .
                    fcc       "   Enter long description now          (Blank line ends)" * 0158 20 20 20 45 6E 74 65 72 20 6C 6F 6E 67 20 64 65 73 63 72 69 70 74 69 6F 6E 20 6E 6F 77 20 20 20 20 20 20 20 20 20 20 28 42 6C 61 6E 6B 20 6C 69 6E 65 20 65 6E 64 73
                    fcb       $0D                 * 0190 0D             .
L0191               fcc       "Enter keyword:"    * 0191 45 6E 74 65 72 20 6B 65 79 77 6F 72 64 3A Enter keyword:
L019F               fcb       $0A                 * 019F 0A             .
                    fcc       "[D]one [E]dit [C]ontinue or [L]ist" * 01A0 5B 44 5D 6F 6E 65 20 5B 45 5D 64 69 74 20 5B 43 5D 6F 6E 74 69 6E 75 65 20 6F 72 20 5B 4C 5D 69 73 74 [D]one [E]dit [C]ontinue or [L]ist
                    fcb       $0D                 * 01C2 0D             .
L01C3               fcb       $0A                 * 01C3 0A             .
                    fcb       $0D                 * 01C4 0D             .
L01C5               fcc       "Enter line #"      * 01C5 45 6E 74 65 72 20 6C 69 6E 65 20 23 Enter line #
                    fcb       $0D                 * 01D1 0D             .
L01D2               fcb       $08                 * 01D2 08             .
                    fcb       $20                 * 01D3 20
                    fcb       $08                 * 01D4 08             .
start               lda       0,X                 * 01D5 A6 84          &.
                    cmpa      #13                 * 01D7 81 0D          ..
                    beq       L01E4               * 01D9 27 09          '.
                    lda       #1                  * 01DB 86 01          ..
                    os9       I$ChgDir            * 01DD 10 3F 86       .?.
                    lbcs      L0599               * 01E0 10 25 03 B5    .%.5
L01E4               leax      >L0095,PC           * 01E4 30 8D FE AD    0.~-
                    lda       #3                  * 01E8 86 03          ..
                    os9       I$Open              * 01EA 10 3F 84       .?.
                    bcc       L01FE               * 01ED 24 0F          $.
                    cmpb      #216                * 01EF C1 D8          AX
                    lbne      L0599               * 01F1 10 26 03 A4    .&.$
                    ldb       #27                 * 01F5 C6 1B          F.
                    os9       I$Create            * 01F7 10 3F 83       .?.
                    lbcs      L0599               * 01FA 10 25 03 9B    .%..
L01FE               sta       U0001,U             * 01FE A7 41          'A
                    leax      >L009D,PC           * 0200 30 8D FE 99    0.~.
                    lda       #2                  * 0204 86 02          ..
                    os9       I$Open              * 0206 10 3F 84       .?.
                    bcc       L021A               * 0209 24 0F          $.
                    cmpb      #216                * 020B C1 D8          AX
                    lbne      L0599               * 020D 10 26 03 88    .&..
                    ldb       #27                 * 0211 C6 1B          F.
                    os9       I$Create            * 0213 10 3F 83       .?.
                    lbcs      L0599               * 0216 10 25 03 7F    .%..
L021A               sta       U0002,U             * 021A A7 42          'B
                    leax      >L00A5,PC           * 021C 30 8D FE 85    0.~.
                    lda       #3                  * 0220 86 03          ..
                    os9       I$Open              * 0222 10 3F 84       .?.
                    bcc       L0236               * 0225 24 0F          $.
                    cmpb      #216                * 0227 C1 D8          AX
                    lbne      L0599               * 0229 10 26 03 6C    .&.l
                    ldb       #27                 * 022D C6 1B          F.
                    os9       I$Create            * 022F 10 3F 83       .?.
                    lbcs      L0599               * 0232 10 25 03 63    .%.c
L0236               sta       U0003,U             * 0236 A7 43          'C
                    leax      >L007F,PC           * 0238 30 8D FE 43    0.~C
                    ldy       #22                 * 023C 10 8E 00 16    ....
                    lda       #1                  * 0240 86 01          ..
                    os9       I$Write             * 0242 10 3F 8A       .?.
                    leax      <U0075,U            * 0245 30 C8 75       0Hu
                    ldy       #27                 * 0248 10 8E 00 1B    ....
                    clra                          * 024C 4F             O
                    os9       I$ReadLn            * 024D 10 3F 8B       .?.
L0250               lda       U0001,U             * 0250 A6 41          &A
                    leax      >U00D5,U            * 0252 30 C9 00 D5    0I.U
                    ldy       #96                 * 0256 10 8E 00 60    ...`
                    os9       I$Read              * 025A 10 3F 89       .?.
                    bcs       L0273               * 025D 25 14          %.
                    leay      <U0075,U            * 025F 31 C8 75       1Hu
L0262               lda       ,X+                 * 0262 A6 80          &.
                    cmpa      ,Y+                 * 0264 A1 A0          !
                    bne       L0250               * 0266 26 E8          &h
                    cmpa      #13                 * 0268 81 0D          ..
                    beq       L026E               * 026A 27 02          '.
                    bra       L0262               * 026C 20 F4           t
L026E               ldb       #218                * 026E C6 DA          FZ
                    lbra      L0599               * 0270 16 03 26       ..&
L0273               cmpb      #211                * 0273 C1 D3          AS
                    lbne      L0599               * 0275 10 26 03 20    .&.
                    lda       U0001,U             * 0279 A6 41          &A
                    ldb       #5                  * 027B C6 05          F.
                    pshs      U                   * 027D 34 40          4@
                    os9       I$GetStt            * 027F 10 3F 8D       .?.
                    tfr       U,Y                 * 0282 1F 32          .2
                    puls      U                   * 0284 35 40          5@
                    stx       >U0145,U            * 0286 AF C9 01 45    /I.E
                    sty       >U0147,U            * 028A 10 AF C9 01 47 ./I.G
                    ldx       #0                  * 028F 8E 00 00       ...
                    pshs      U                   * 0292 34 40          4@
                    ldu       #0                  * 0294 CE 00 00       N..
                    os9       I$Seek              * 0297 10 3F 88       .?.
                    puls      U                   * 029A 35 40          5@
L029C               lda       U0001,U             * 029C A6 41          &A
                    leax      >U00D5,U            * 029E 30 C9 00 D5    0I.U
                    ldy       #96                 * 02A2 10 8E 00 60    ...`
                    os9       I$Read              * 02A6 10 3F 89       .?.
                    bcs       L02E2               * 02A9 25 37          %7
                    lda       >U00F4,U            * 02AB A6 C9 00 F4    &I.t
                    cmpa      #1                  * 02AF 81 01          ..
                    bne       L029C               * 02B1 26 E9          &i
                    lda       U0001,U             * 02B3 A6 41          &A
                    ldb       #5                  * 02B5 C6 05          F.
                    pshs      U                   * 02B7 34 40          4@
                    os9       I$GetStt            * 02B9 10 3F 8D       .?.
                    tfr       U,D                 * 02BC 1F 30          .0
                    subd      #96                 * 02BE 83 00 60       ..`
                    bge       L02C5               * 02C1 2C 02          ,.
                    leax      -$01,X              * 02C3 30 1F          0.
L02C5               tfr       D,U                 * 02C5 1F 03          ..
                    ldy       0,S                 * 02C7 10 AE E4       ..d
                    lda       $01,Y               * 02CA A6 21          &!
                    os9       I$Seek              * 02CC 10 3F 88       .?.
                    lbcs      L0599               * 02CF 10 25 02 C6    .%.F
                    tfr       U,Y                 * 02D3 1F 32          .2
                    puls      U                   * 02D5 35 40          5@
                    stx       >U0145,U            * 02D7 AF C9 01 45    /I.E
                    sty       >U0147,U            * 02DB 10 AF C9 01 47 ./I.G
                    bra       L02E8               * 02E0 20 06           .
L02E2               cmpb      #211                * 02E2 C1 D3          AS
                    lbne      L0599               * 02E4 10 26 02 B1    .&.1
L02E8               leax      >L00AF,PC           * 02E8 30 8D FD C3    0.}C
                    ldy       #200                * 02EC 10 8E 00 C8    ...H
                    lda       #1                  * 02F0 86 01          ..
                    os9       I$WritLn            * 02F2 10 3F 8C       .?.
                    leax      >L011A,PC           * 02F5 30 8D FE 21    0.~!
                    ldy       #1                  * 02F9 10 8E 00 01    ....
                    os9       I$Write             * 02FD 10 3F 8A       .?.
                    leax      >U0095,U            * 0300 30 C9 00 95    0I..
                    ldy       #64                 * 0304 10 8E 00 40    ...@
                    clra                          * 0308 4F             O
                    os9       I$ReadLn            * 0309 10 3F 8B       .?.
                    lda       #255                * 030C 86 FF          ..
                    sta       >U0094,U            * 030E A7 C9 00 94    'I..
                    leax      <U0075,U            * 0312 30 C8 75       0Hu
                    lda       U0003,U             * 0315 A6 43          &C
                    ldb       #2                  * 0317 C6 02          F.
                    pshs      U                   * 0319 34 40          4@
                    os9       I$GetStt            * 031B 10 3F 8D       .?.
                    lbcs      L0599               * 031E 10 25 02 77    .%.w
                    os9       I$Seek              * 0322 10 3F 88       .?.
                    lbcs      L0599               * 0325 10 25 02 70    .%.p
                    tfr       U,Y                 * 0329 1F 32          .2
                    puls      U                   * 032B 35 40          5@
                    stx       >U0090,U            * 032D AF C9 00 90    /I..
                    sty       >U0092,U            * 0331 10 AF C9 00 92 ./I..
                    ldy       #96                 * 0336 10 8E 00 60    ...`
                    leax      <U0075,U            * 033A 30 C8 75       0Hu
                    lda       U0001,U             * 033D A6 41          &A
                    os9       I$Write             * 033F 10 3F 8A       .?.
                    lda       U0002,U             * 0342 A6 42          &B
                    ldb       #2                  * 0344 C6 02          F.
                    pshs      U                   * 0346 34 40          4@
                    os9       I$GetStt            * 0348 10 3F 8D       .?.
                    lbcs      L0599               * 034B 10 25 02 4A    .%.J
                    os9       I$Seek              * 034F 10 3F 88       .?.
                    lbcs      L0599               * 0352 10 25 02 43    .%.C
                    puls      U                   * 0356 35 40          5@
                    leax      >L011C,PC           * 0358 30 8D FD C0    0.}@
                    ldy       #200                * 035C 10 8E 00 C8    ...H
                    lda       #1                  * 0360 86 01          ..
                    os9       I$WritLn            * 0362 10 3F 8C       .?.
                    leax      >L00D9,PC           * 0365 30 8D FD 70    0.}p
                    ldy       #65                 * 0369 10 8E 00 41    ...A
                    lda       #1                  * 036D 86 01          ..
                    os9       I$WritLn            * 036F 10 3F 8C       .?.
                    ldd       >U0145,U            * 0372 EC C9 01 45    lI.E
                    std       >U0141,U            * 0376 ED C9 01 41    mI.A
                    ldd       >U0147,U            * 037A EC C9 01 47    lI.G
                    std       >U0143,U            * 037E ED C9 01 43    mI.C
L0382               leax      >L0191,PC           * 0382 30 8D FE 0B    0.~.
                    ldy       #14                 * 0386 10 8E 00 0E    ....
                    lda       #1                  * 038A 86 01          ..
                    os9       I$Write             * 038C 10 3F 8A       .?.
                    leax      >U0135,U            * 038F 30 C9 01 35    0I.5
                    ldy       #12                 * 0393 10 8E 00 0C    ....
                    clra                          * 0397 4F             O
                    os9       I$ReadLn            * 0398 10 3F 8B       .?.
                    lbcs      L0382               * 039B 10 25 FF E3    .%.c
                    cmpy      #1                  * 039F 10 8C 00 01    ....
                    lbls      L03B2               * 03A3 10 23 00 0B    .#..
                    lda       U0002,U             * 03A7 A6 42          &B
                    ldy       #16                 * 03A9 10 8E 00 10    ....
                    os9       I$Write             * 03AD 10 3F 8A       .?.
                    bra       L0382               * 03B0 20 D0           P
L03B2               leax      >L0156,PC           * 03B2 30 8D FD A0    0.}
                    ldy       #200                * 03B6 10 8E 00 C8    ...H
                    lda       #1                  * 03BA 86 01          ..
                    os9       I$WritLn            * 03BC 10 3F 8C       .?.
                    lbcs      L0599               * 03BF 10 25 01 D6    .%.V
                    leax      >L00D9,PC           * 03C3 30 8D FD 12    0.}.
                    ldy       #80                 * 03C7 10 8E 00 50    ...P
                    os9       I$WritLn            * 03CB 10 3F 8C       .?.
                    lbcs      L0599               * 03CE 10 25 01 C7    .%.G
                    ldd       #0                  * 03D2 CC 00 00       L..
                    std       >U014B,U            * 03D5 ED C9 01 4B    mI.K
                    sta       U0004,U             * 03D9 A7 44          'D
L03DB               ldd       >U014B,U            * 03DB EC C9 01 4B    lI.K
                    addd      #1                  * 03DF C3 00 01       C..
                    std       >U014B,U            * 03E2 ED C9 01 4B    mI.K
                    cmpd      #99                 * 03E6 10 83 00 63    ...c
                    bge       L03F7               * 03EA 2C 0B          ,.
                    lbsr      L0510               * 03EC 17 01 21       ..!
                    cmpy      #1                  * 03EF 10 8C 00 01    ....
                    bls       L03F7               * 03F3 23 02          #.
                    bra       L03DB               * 03F5 20 E4           d
L03F7               leax      >L019F,PC           * 03F7 30 8D FD A4    0.}$
                    ldy       #200                * 03FB 10 8E 00 C8    ...H
                    lda       #1                  * 03FF 86 01          ..
                    os9       I$WritLn            * 0401 10 3F 8C       .?.
                    leax      >L011A,PC           * 0404 30 8D FD 12    0.}.
                    ldy       #1                  * 0408 10 8E 00 01    ....
                    os9       I$Write             * 040C 10 3F 8A       .?.
                    leax      U0000,U             * 040F 30 C4          0D
                    clra                          * 0411 4F             O
                    ldy       #1                  * 0412 10 8E 00 01    ....
                    os9       I$Read              * 0416 10 3F 89       .?.
                    leax      >L01C3,PC           * 0419 30 8D FD A6    0.}&
                    ldy       #1                  * 041D 10 8E 00 01    ....
                    lda       #1                  * 0421 86 01          ..
                    os9       I$WritLn            * 0423 10 3F 8C       .?.
                    lda       U0000,U             * 0426 A6 C4          &D
                    anda      #223                * 0428 84 DF          ._
                    cmpa      #68                 * 042A 81 44          .D
                    lbeq      L0563               * 042C 10 27 01 33    .'.3
                    cmpa      #69                 * 0430 81 45          .E
                    beq       L044D               * 0432 27 19          '.
                    cmpa      #67                 * 0434 81 43          .C
                    beq       L0440               * 0436 27 08          '.
                    cmpa      #76                 * 0438 81 4C          .L
                    lbeq      L04C7               * 043A 10 27 00 89    .'..
                    bra       L03F7               * 043E 20 B7           7
L0440               ldd       >U014B,U            * 0440 EC C9 01 4B    lI.K
                    subd      #1                  * 0444 83 00 01       ...
                    std       >U014B,U            * 0447 ED C9 01 4B    mI.K
                    bra       L03DB               * 044B 20 8E           .
L044D               leax      >L01C5,PC           * 044D 30 8D FD 74    0.}t
                    ldy       #200                * 0451 10 8E 00 C8    ...H
                    lda       #1                  * 0455 86 01          ..
                    os9       I$WritLn            * 0457 10 3F 8C       .?.
                    leax      >L011A,PC           * 045A 30 8D FC BC    0.|<
                    ldy       #1                  * 045E 10 8E 00 01    ....
                    os9       I$Write             * 0462 10 3F 8A       .?.
                    clra                          * 0465 4F             O
                    leax      >U0155,U            * 0466 30 C9 01 55    0I.U
                    ldy       #3                  * 046A 10 8E 00 03    ....
                    os9       I$ReadLn            * 046E 10 3F 8B       .?.
                    lbsr      L0728               * 0471 17 02 B4       ..4
                    cmpd      >U014B,U            * 0474 10 A3 C9 01 4B .#I.K
                    lbcc      L03F7               * 0479 10 24 FF 7A    .$.z
                    std       >U0153,U            * 047D ED C9 01 53    mI.S
                    leax      >U0155,U            * 0481 30 C9 01 55    0I.U
                    lbsr      L07AD               * 0485 17 03 25       ..%
                    leax      >U0155,U            * 0488 30 C9 01 55    0I.U
                    lda       #58                 * 048C 86 3A          .:
                    sta       $02,X               * 048E A7 02          '.
                    ldy       #3                  * 0490 10 8E 00 03    ....
                    lda       #1                  * 0494 86 01          ..
                    os9       I$Write             * 0496 10 3F 8A       .?.
                    ldd       >U0153,U            * 0499 EC C9 01 53    lI.S
                    leax      >U0158,U            * 049D 30 C9 01 58    0I.X
                    lda       #80                 * 04A1 86 50          .P
                    mul                           * 04A3 3D             =
                    leax      D,X                 * 04A4 30 8B          0.
                    ldy       #80                 * 04A6 10 8E 00 50    ...P
                    lda       #1                  * 04AA 86 01          ..
                    os9       I$WritLn            * 04AC 10 3F 8C       .?.
                    tfr       Y,D                 * 04AF 1F 20          .
                    stb       U0004,U             * 04B1 E7 44          gD
                    dec       U0004,U             * 04B3 6A 44          jD
                    leay      U0005,U             * 04B5 31 45          1E
L04B7               lda       ,X+                 * 04B7 A6 80          &.
                    sta       ,Y+                 * 04B9 A7 A0          '
                    decb                          * 04BB 5A             Z
                    bne       L04B7               * 04BC 26 F9          &y
                    ldd       >U0153,U            * 04BE EC C9 01 53    lI.S
                    bsr       L0510               * 04C2 8D 4C          .L
                    lbra      L03F7               * 04C4 16 FF 30       ..0
L04C7               ldd       #0                  * 04C7 CC 00 00       L..
                    std       >U014B,U            * 04CA ED C9 01 4B    mI.K
L04CE               ldd       >U014B,U            * 04CE EC C9 01 4B    lI.K
                    addd      #1                  * 04D2 C3 00 01       C..
                    std       >U014B,U            * 04D5 ED C9 01 4B    mI.K
                    leax      >U0155,U            * 04D9 30 C9 01 55    0I.U
                    lbsr      L07AD               * 04DD 17 02 CD       ..M
                    leax      >U0155,U            * 04E0 30 C9 01 55    0I.U
                    lda       #58                 * 04E4 86 3A          .:
                    sta       $02,X               * 04E6 A7 02          '.
                    lda       #1                  * 04E8 86 01          ..
                    ldy       #3                  * 04EA 10 8E 00 03    ....
                    os9       I$Write             * 04EE 10 3F 8A       .?.
                    leax      >U0158,U            * 04F1 30 C9 01 58    0I.X
                    ldd       >U014B,U            * 04F5 EC C9 01 4B    lI.K
                    lda       #80                 * 04F9 86 50          .P
                    mul                           * 04FB 3D             =
                    leax      D,X                 * 04FC 30 8B          0.
                    ldy       #80                 * 04FE 10 8E 00 50    ...P
                    lda       #1                  * 0502 86 01          ..
                    os9       I$WritLn            * 0504 10 3F 8C       .?.
                    cmpy      #1                  * 0507 10 8C 00 01    ....
                    bhi       L04CE               * 050B 22 C1          "A
                    lbra      L03F7               * 050D 16 FE E7       .~g
L0510               leax      >U0155,U            * 0510 30 C9 01 55    0I.U
                    pshs      D                   * 0514 34 06          4.
                    lbsr      L07AD               * 0516 17 02 94       ...
                    leax      >U0155,U            * 0519 30 C9 01 55    0I.U
                    lda       #58                 * 051D 86 3A          .:
                    sta       $02,X               * 051F A7 02          '.
                    lda       #1                  * 0521 86 01          ..
                    ldy       #3                  * 0523 10 8E 00 03    ....
                    os9       I$Write             * 0527 10 3F 8A       .?.
                    lbcs      L0599               * 052A 10 25 00 6B    .%.k
                    leax      U0005,U             * 052E 30 45          0E
                    ldb       U0004,U             * 0530 E6 44          fD
                    clra                          * 0532 4F             O
                    tfr       D,Y                 * 0533 1F 02          ..
                    lda       #1                  * 0535 86 01          ..
                    os9       I$Write             * 0537 10 3F 8A       .?.
                    puls      D                   * 053A 35 06          5.
                    lda       #80                 * 053C 86 50          .P
                    mul                           * 053E 3D             =
                    leax      >U0158,U            * 053F 30 C9 01 58    0I.X
                    leax      D,X                 * 0543 30 8B          0.
                    leay      U0005,U             * 0545 31 45          1E
                    ldb       #80                 * 0547 C6 50          FP
                    lda       U0004,U             * 0549 A6 44          &D
                    beq       L055C               * 054B 27 0F          '.
                    sta       >U014F,U            * 054D A7 C9 01 4F    'I.O
L0551               lda       ,Y+                 * 0551 A6 A0          &
                    sta       ,X+                 * 0553 A7 80          '.
                    decb                          * 0555 5A             Z
                    dec       >U014F,U            * 0556 6A C9 01 4F    jI.O
                    bne       L0551               * 055A 26 F5          &u
L055C               clra                          * 055C 4F             O
                    tfr       D,Y                 * 055D 1F 02          ..
                    lbsr      L059C               * 055F 17 00 3A       ..:
                    rts                           * 0562 39             9
L0563               lda       #0                  * 0563 86 00          ..
                    sta       >U014D,U            * 0565 A7 C9 01 4D    'I.M
L0569               lda       >U014D,U            * 0569 A6 C9 01 4D    &I.M
                    inca                          * 056D 4C             L
                    sta       >U014D,U            * 056E A7 C9 01 4D    'I.M
                    cmpa      >U014C,U            * 0572 A1 C9 01 4C    !I.L
                    bhi       L0598               * 0576 22 20          "
                    ldb       #80                 * 0578 C6 50          FP
                    mul                           * 057A 3D             =
                    leax      >U0158,U            * 057B 30 C9 01 58    0I.X
                    leax      D,X                 * 057F 30 8B          0.
                    ldy       #80                 * 0581 10 8E 00 50    ...P
                    lda       U0003,U             * 0585 A6 43          &C
                    os9       I$WritLn            * 0587 10 3F 8C       .?.
                    lbcs      L0599               * 058A 10 25 00 0B    .%..
                    cmpy      #1                  * 058E 10 8C 00 01    ....
                    bls       L0598               * 0592 23 04          #.
                    tfr       Y,D                 * 0594 1F 20          .
                    bra       L0569               * 0596 20 D1           Q
L0598               clrb                          * 0598 5F             _
L0599               os9       F$Exit              * 0599 10 3F 06       .?.
L059C               lbsr      L06F3               * 059C 17 01 54       ..T
                    ldb       U0004,U             * 059F E6 44          fD
                    leay      B,Y                 * 05A1 31 A5          1%
                    pshs      Y                   * 05A3 34 20          4
                    negb                          * 05A5 50             P
                    sex                           * 05A6 1D             .
                    leay      D,Y                 * 05A7 31 AB          1+
                    clr       U0004,U             * 05A9 6F 44          oD
                    cmpy      #0                  * 05AB 10 8C 00 00    ....
                    lbeq      L066B               * 05AF 10 27 00 B8    .'.8
                    pshs      Y,X                 * 05B3 34 30          40
                    lda       #13                 * 05B5 86 0D          ..
L05B7               sta       ,X+                 * 05B7 A7 80          '.
                    leay      -$01,Y              * 05B9 31 3F          1?
                    bne       L05B7               * 05BB 26 FA          &z
                    puls      Y,X                 * 05BD 35 30          50
L05BF               pshs      Y,X                 * 05BF 34 30          40
                    leax      U0000,U             * 05C1 30 C4          0D
                    ldy       #1                  * 05C3 10 8E 00 01    ....
                    clra                          * 05C7 4F             O
                    os9       I$Read              * 05C8 10 3F 89       .?.
                    bcs       L05F8               * 05CB 25 2B          %+
                    lda       U0000,U             * 05CD A6 C4          &D
                    cmpa      #1                  * 05CF 81 01          ..
                    beq       L05FC               * 05D1 27 29          ')
                    cmpa      #8                  * 05D3 81 08          ..
                    beq       L061E               * 05D5 27 47          'G
                    cmpa      #24                 * 05D7 81 18          ..
                    beq       L0642               * 05D9 27 67          'g
                    cmpa      #13                 * 05DB 81 0D          ..
                    lbeq      L0669               * 05DD 10 27 00 88    .'..
                    cmpa      #32                 * 05E1 81 20          .
                    bcs       L05F8               * 05E3 25 13          %.
                    lda       #1                  * 05E5 86 01          ..
                    os9       I$Write             * 05E7 10 3F 8A       .?.
                    puls      Y,X                 * 05EA 35 30          50
                    lda       U0000,U             * 05EC A6 C4          &D
                    sta       ,X+                 * 05EE A7 80          '.
                    leay      -$01,Y              * 05F0 31 3F          1?
                    lbeq      L0692               * 05F2 10 27 00 9C    .'..
                    bra       L05BF               * 05F6 20 C7           G
L05F8               puls      Y,X                 * 05F8 35 30          50
                    bra       L05BF               * 05FA 20 C3           C
L05FC               puls      Y,X                 * 05FC 35 30          50
                    leay      -$01,Y              * 05FE 31 3F          1?
                    beq       L0619               * 0600 27 17          '.
                    lda       ,X+                 * 0602 A6 80          &.
                    cmpa      #13                 * 0604 81 0D          ..
                    beq       L0617               * 0606 27 0F          '.
                    pshs      Y,X                 * 0608 34 30          40
                    leax      -$01,X              * 060A 30 1F          0.
                    ldy       #1                  * 060C 10 8E 00 01    ....
                    lda       #1                  * 0610 86 01          ..
                    os9       I$Write             * 0612 10 3F 8A       .?.
                    bra       L05FC               * 0615 20 E5           e
L0617               leax      -$01,X              * 0617 30 1F          0.
L0619               leay      $01,Y               * 0619 31 21          1!
                    lbra      L05BF               * 061B 16 FF A1       ..!
L061E               puls      Y,X                 * 061E 35 30          50
                    leay      $01,Y               * 0620 31 21          1!
                    cmpy      0,S                 * 0622 10 AC E4       .,d
                    bhi       L063D               * 0625 22 16          ".
                    pshs      Y,X                 * 0627 34 30          40
                    leax      >L01D2,PC           * 0629 30 8D FB A5    0.{%
                    ldy       #3                  * 062D 10 8E 00 03    ....
                    lda       #1                  * 0631 86 01          ..
                    os9       I$Write             * 0633 10 3F 8A       .?.
                    puls      Y,X                 * 0636 35 30          50
                    leax      -$01,X              * 0638 30 1F          0.
                    lbra      L05BF               * 063A 16 FF 82       ...
L063D               leay      -$01,Y              * 063D 31 3F          1?
                    lbra      L05BF               * 063F 16 FF 7D       ..}
L0642               puls      Y,X                 * 0642 35 30          50
                    leay      $01,Y               * 0644 31 21          1!
                    cmpy      0,S                 * 0646 10 AC E4       .,d
                    bhi       L063D               * 0649 22 F2          "r
                    pshs      Y,X                 * 064B 34 30          40
                    leax      >L01D2,PC           * 064D 30 8D FB 81    0.{.
                    ldy       #3                  * 0651 10 8E 00 03    ....
                    lda       #1                  * 0655 86 01          ..
                    os9       I$Write             * 0657 10 3F 8A       .?.
                    puls      Y,X                 * 065A 35 30          50
                    leax      -$01,X              * 065C 30 1F          0.
                    cmpy      0,S                 * 065E 10 AC E4       .,d
                    lbhi      L05BF               * 0661 10 22 FF 5A    .".Z
                    pshs      Y,X                 * 0665 34 30          40
                    bra       L0642               * 0667 20 D9           Y
L0669               puls      Y,X                 * 0669 35 30          50
L066B               lda       #13                 * 066B 86 0D          ..
                    sta       ,X+                 * 066D A7 80          '.
                    pshs      Y,X                 * 066F 34 30          40
                    leax      >L01C3,PC           * 0671 30 8D FB 4E    0.{N
                    ldy       #1                  * 0675 10 8E 00 01    ....
                    lda       #1                  * 0679 86 01          ..
                    os9       I$WritLn            * 067B 10 3F 8C       .?.
                    puls      Y,X                 * 067E 35 30          50
                    puls      D                   * 0680 35 06          5.
                    pshs      Y                   * 0682 34 20          4
                    subd      0,S                 * 0684 A3 E4          #d
                    leas      $02,S               * 0686 32 62          2b
                    tfr       D,Y                 * 0688 1F 02          ..
                    leay      $01,Y               * 068A 31 21          1!
                    lbsr      L070C               * 068C 17 00 7D       ..}
                    rts                           * 068F 39             9
                    fcc       "50"                * 0690 35 30          50
L0692               puls      D                   * 0692 35 06          5.
                    pshs      Y                   * 0694 34 20          4
                    subd      0,S                 * 0696 A3 E4          #d
                    leas      $02,S               * 0698 32 62          2b
                    addd      #1                  * 069A C3 00 01       C..
                    tfr       D,Y                 * 069D 1F 02          ..
                    clrb                          * 069F 5F             _
L06A0               leay      -$01,Y              * 06A0 31 3F          1?
                    beq       L06BE               * 06A2 27 1A          '.
                    lda       ,-X                 * 06A4 A6 82          &.
                    cmpa      #32                 * 06A6 81 20          .
                    beq       L06CF               * 06A8 27 25          '%
                    pshs      Y,X                 * 06AA 34 30          40
                    leax      >L01D2,PC           * 06AC 30 8D FB 22    0.{"
                    ldy       #3                  * 06B0 10 8E 00 03    ....
                    lda       #1                  * 06B4 86 01          ..
                    os9       I$Write             * 06B6 10 3F 8A       .?.
                    incb                          * 06B9 5C             \
                    puls      Y,X                 * 06BA 35 30          50
                    bra       L06A0               * 06BC 20 E2           b
L06BE               lda       #13                 * 06BE 86 0D          ..
                    sta       <$004F,X            * 06C0 A7 88 4F       '.O
                    ldy       #200                * 06C3 10 8E 00 C8    ...H
                    lda       #1                  * 06C7 86 01          ..
                    os9       I$WritLn            * 06C9 10 3F 8C       .?.
                    puls      Y                   * 06CC 35 20          5
                    rts                           * 06CE 39             9
L06CF               lda       #13                 * 06CF 86 0D          ..
                    sta       ,X+                 * 06D1 A7 80          '.
                    pshs      Y,X                 * 06D3 34 30          40
                    stb       U0004,U             * 06D5 E7 44          gD
                    leay      U0005,U             * 06D7 31 45          1E
L06D9               lda       ,X+                 * 06D9 A6 80          &.
                    sta       ,Y+                 * 06DB A7 A0          '
                    decb                          * 06DD 5A             Z
                    bne       L06D9               * 06DE 26 F9          &y
                    leax      >L01C3,PC           * 06E0 30 8D FA DF    0.z_
                    ldy       #1                  * 06E4 10 8E 00 01    ....
                    lda       #1                  * 06E8 86 01          ..
                    os9       I$WritLn            * 06EA 10 3F 8C       .?.
                    puls      Y,X                 * 06ED 35 30          50
                    lbsr      L070C               * 06EF 17 00 1A       ...
                    rts                           * 06F2 39             9
L06F3               pshs      Y,X,D               * 06F3 34 36          46
                    leax      <U0055,U            * 06F5 30 C8 55       0HU
                    clra                          * 06F8 4F             O
                    ldb       #0                  * 06F9 C6 00          F.
                    os9       I$GetStt            * 06FB 10 3F 8D       .?.
                    leax      -$20,X              * 06FE 30 88 E0       0.`
                    clr       <$0024,X            * 0701 6F 88 24       o.$
                    leax      <$0020,X            * 0704 30 88 20       0.
                    os9       I$SetStt            * 0707 10 3F 8E       .?.
                    puls      PC,Y,X,D            * 070A 35 B6          56
L070C               pshs      Y,X,D               * 070C 34 36          46
                    leax      <U0055,U            * 070E 30 C8 55       0HU
                    clra                          * 0711 4F             O
                    ldb       #0                  * 0712 C6 00          F.
                    os9       I$GetStt            * 0714 10 3F 8D       .?.
                    leax      -$20,X              * 0717 30 88 E0       0.`
                    lda       #1                  * 071A 86 01          ..
                    sta       <$0024,X            * 071C A7 88 24       '.$
                    leax      <$0020,X            * 071F 30 88 20       0.
                    clra                          * 0722 4F             O
                    os9       I$SetStt            * 0723 10 3F 8E       .?.
                    puls      PC,Y,X,D            * 0726 35 B6          56
L0728               pshs      Y                   * 0728 34 20          4
L072A               lda       ,X+                 * 072A A6 80          &.
                    cmpa      #13                 * 072C 81 0D          ..
                    lbeq      L07EE               * 072E 10 27 00 BC    .'.<
                    cmpa      #48                 * 0732 81 30          .0
                    bcs       L072A               * 0734 25 F4          %t
                    cmpa      #57                 * 0736 81 39          .9
                    bhi       L072A               * 0738 22 F0          "p
                    leax      -$01,X              * 073A 30 1F          0.
L073C               lda       ,X+                 * 073C A6 80          &.
                    cmpa      #48                 * 073E 81 30          .0
                    bcs       L0748               * 0740 25 06          %.
                    cmpa      #57                 * 0742 81 39          .9
                    bhi       L0748               * 0744 22 02          ".
                    bra       L073C               * 0746 20 F4           t
L0748               pshs      X                   * 0748 34 10          4.
                    leax      -$01,X              * 074A 30 1F          0.
                    clr       >U014F,U            * 074C 6F C9 01 4F    oI.O
                    clr       >U0150,U            * 0750 6F C9 01 50    oI.P
                    ldd       #1                  * 0754 CC 00 01       L..
                    std       >U0151,U            * 0757 ED C9 01 51    mI.Q
L075B               lda       ,-X                 * 075B A6 82          &.
                    cmpa      #48                 * 075D 81 30          .0
                    bcs       L07A5               * 075F 25 44          %D
                    cmpa      #57                 * 0761 81 39          .9
                    bhi       L07A5               * 0763 22 40          "@
                    suba      #48                 * 0765 80 30          .0
                    sta       >U014A,U            * 0767 A7 C9 01 4A    'I.J
                    ldd       #0                  * 076B CC 00 00       L..
L076E               tst       >U014A,U            * 076E 6D C9 01 4A    mI.J
                    beq       L077E               * 0772 27 0A          '.
                    addd      >U0151,U            * 0774 E3 C9 01 51    cI.Q
                    dec       >U014A,U            * 0778 6A C9 01 4A    jI.J
                    bra       L076E               * 077C 20 F0           p
L077E               addd      >U014F,U            * 077E E3 C9 01 4F    cI.O
                    std       >U014F,U            * 0782 ED C9 01 4F    mI.O
                    lda       #10                 * 0786 86 0A          ..
                    sta       >U014A,U            * 0788 A7 C9 01 4A    'I.J
                    ldd       #0                  * 078C CC 00 00       L..
L078F               tst       >U014A,U            * 078F 6D C9 01 4A    mI.J
                    beq       L079F               * 0793 27 0A          '.
                    addd      >U0151,U            * 0795 E3 C9 01 51    cI.Q
                    dec       >U014A,U            * 0799 6A C9 01 4A    jI.J
                    bra       L078F               * 079D 20 F0           p
L079F               std       >U0151,U            * 079F ED C9 01 51    mI.Q
                    bra       L075B               * 07A3 20 B6           6
L07A5               ldd       >U014F,U            * 07A5 EC C9 01 4F    lI.O
                    puls      X                   * 07A9 35 10          5.
                    puls      PC,Y                * 07AB 35 A0          5
L07AD               pshs      Y                   * 07AD 34 20          4
                    std       >U014F,U            * 07AF ED C9 01 4F    mI.O
                    lda       #48                 * 07B3 86 30          .0
                    sta       0,X                 * 07B5 A7 84          '.
                    sta       $01,X               * 07B7 A7 01          '.
                    ldd       #10                 * 07B9 CC 00 0A       L..
                    std       >U0151,U            * 07BC ED C9 01 51    mI.Q
                    ldd       >U014F,U            * 07C0 EC C9 01 4F    lI.O
                    bsr       L07D9               * 07C4 8D 13          ..
                    ldd       #1                  * 07C6 CC 00 01       L..
                    std       >U0151,U            * 07C9 ED C9 01 51    mI.Q
                    ldd       >U014F,U            * 07CD EC C9 01 4F    lI.O
                    bsr       L07D9               * 07D1 8D 06          ..
                    lda       #13                 * 07D3 86 0D          ..
                    sta       0,X                 * 07D5 A7 84          '.
                    puls      PC,Y                * 07D7 35 A0          5
L07D9               subd      >U0151,U            * 07D9 A3 C9 01 51    #I.Q
                    bcs       L07E3               * 07DD 25 04          %.
                    inc       0,X                 * 07DF 6C 84          l.
                    bra       L07D9               * 07E1 20 F6           v
L07E3               addd      >U0151,U            * 07E3 E3 C9 01 51    cI.Q
                    std       >U014F,U            * 07E7 ED C9 01 4F    mI.O
                    leax      $01,X               * 07EB 30 01          0.
                    rts                           * 07ED 39             9
L07EE               ldd       #-1                 * 07EE CC FF FF       L..
                    puls      PC,Y                * 07F1 35 A0          5

                    emod
eom                 equ       *
                    end
