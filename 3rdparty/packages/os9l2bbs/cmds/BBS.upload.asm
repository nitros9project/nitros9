                    nam       BBS.upload
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       1
U0001               rmb       2
U0003               rmb       13
U0010               rmb       2
U0012               rmb       2
U0014               rmb       2
U0016               rmb       6
U001C               rmb       2
U001E               rmb       2
U0020               rmb       2
U0022               rmb       16
U0032               rmb       27
U004D               rmb       2
U004F               rmb       2
U0051               rmb       1
U0052               rmb       64
U0092               rmb       31
U00B1               rmb       1
U00B2               rmb       8499
size                equ       .

name                fcs       /BBS.upload/        * 000D 42 42 53 2E 75 70 6C 6F 61 E4 BBS.upload
                    fcc       "Copyright (C) 1988By Keith AlphonsoLicenced to Alpha Software TechnologiesAll rights reserved" * 0017 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 4C 69 63 65 6E 63 65 64
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
L0082               fcc       "Uloadx"            * 0082 55 6C 6F 61 64 78 Uloadx
                    fcb       $0D                 * 0088 0D             .
L0089               fcc       "Uloadxc"           * 0089 55 6C 6F 61 64 78 63 Uloadxc
                    fcb       $0D                 * 0090 0D             .
L0091               fcc       "Uloady"            * 0091 55 6C 6F 61 64 79 Uloady
                    fcb       $0D                 * 0097 0D             .
                    fcc       "Uloadyb"           * 0098 55 6C 6F 61 64 79 62 Uloadyb
                    fcb       $0D                 * 009F 0D             .
L00A0               fcc       "Uloada"            * 00A0 55 6C 6F 61 64 61 Uloada
                    fcb       $0D                 * 00A6 0D             .
L00A7               fcc       "Enter your upload protocol" * 00A7 45 6E 74 65 72 20 79 6F 75 72 20 75 70 6C 6F 61 64 20 70 72 6F 74 6F 63 6F 6C Enter your upload protocol
                    fcb       $0D                 * 00C1 0D             .
L00C2               fcb       $0A                 * 00C2 0A             .
                    fcb       $0D                 * 00C3 0D             .
                    fcc       "[A] Ascii"         * 00C4 5B 41 5D 20 41 73 63 69 69 [A] Ascii
                    fcb       $0A                 * 00CD 0A             .
                    fcb       $0D                 * 00CE 0D             .
                    fcc       "[X] xmodem"        * 00CF 5B 58 5D 20 78 6D 6F 64 65 6D [X] xmodem
                    fcb       $0A                 * 00D9 0A             .
                    fcb       $0D                 * 00DA 0D             .
                    fcc       "[C] xmodem (CRC)"  * 00DB 5B 43 5D 20 78 6D 6F 64 65 6D 20 28 43 52 43 29 [C] xmodem (CRC)
                    fcb       $0A                 * 00EB 0A             .
                    fcb       $0D                 * 00EC 0D             .
                    fcc       "[Y] ymodem"        * 00ED 5B 59 5D 20 79 6D 6F 64 65 6D [Y] ymodem
                    fcb       $0A                 * 00F7 0A             .
                    fcb       $0D                 * 00F8 0D             .
                    fcc       "[Q] quit"          * 00F9 5B 51 5D 20 71 75 69 74 [Q] quit
                    fcb       $0A                 * 0101 0A             .
                    fcb       $0D                 * 0102 0D             .
                    fcc       "Protocol?"         * 0103 50 72 6F 74 6F 63 6F 6C 3F Protocol?
L010C               fcc       "Enter filename to upload:" * 010C 45 6E 74 65 72 20 66 69 6C 65 6E 61 6D 65 20 74 6F 20 75 70 6C 6F 61 64 3A Enter filename to upload:
L0125               fcc       "DLD.lst"           * 0125 44 4C 44 2E 6C 73 74 DLD.lst
                    fcb       $0D                 * 012C 0D             .
L012D               fcb       $0D                 * 012D 0D             .
                    fcb       $0A                 * 012E 0A             .
L012F               fcc       "Enter a one-line description of this file" * 012F 45 6E 74 65 72 20 61 20 6F 6E 65 2D 6C 69 6E 65 20 64 65 73 63 72 69 70 74 69 6F 6E 20 6F 66 20 74 68 69 73 20 66 69 6C 65 Enter a one-line description of this file
                    fcb       $0D                 * 0158 0D             .
L0159               fcb       $3E                 * 0159 3E             >
                    fcb       $0D                 * 015A 0D             .
L015B               fcc       "/dd/bbs/BBS.userstats" * 015B 2F 64 64 2F 62 62 73 2F 42 42 53 2E 75 73 65 72 73 74 61 74 73 /dd/bbs/BBS.userstats
                    fcb       $0D                 * 0170 0D             .
start               lda       0,X                 * 0171 A6 84          &.
                    cmpa      #13                 * 0173 81 0D          ..
                    beq       L0180               * 0175 27 09          '.
                    lda       #1                  * 0177 86 01          ..
                    os9       I$ChgDir            * 0179 10 3F 86       .?.
                    lbcs      L04B2               * 017C 10 25 03 32    .%.2
L0180               leax      >L0125,PC           * 0180 30 8D FF A1    0..!
                    lda       #3                  * 0184 86 03          ..
                    os9       I$Open              * 0186 10 3F 84       .?.
                    bcs       L018F               * 0189 25 04          %.
                    sta       U0001,U             * 018B A7 41          'A
                    bra       L01A0               * 018D 20 11           .
L018F               cmpb      #216                * 018F C1 D8          AX
                    lbne      L04B2               * 0191 10 26 03 1D    .&..
                    ldb       #27                 * 0195 C6 1B          F.
                    os9       I$Create            * 0197 10 3F 83       .?.
                    lbcs      L04B2               * 019A 10 25 03 14    .%..
                    sta       U0001,U             * 019E A7 41          'A
L01A0               leax      >L00A7,PC           * 01A0 30 8D FF 03    0...
                    ldy       #200                * 01A4 10 8E 00 C8    ...H
                    lda       #1                  * 01A8 86 01          ..
                    os9       I$WritLn            * 01AA 10 3F 8C       .?.
                    leax      >L00C2,PC           * 01AD 30 8D FF 11    0...
                    ldy       #74                 * 01B1 10 8E 00 4A    ...J
                    lda       #1                  * 01B5 86 01          ..
                    os9       I$Write             * 01B7 10 3F 8A       .?.
                    leax      U0000,U             * 01BA 30 C4          0D
                    ldy       #1                  * 01BC 10 8E 00 01    ....
                    lda       #1                  * 01C0 86 01          ..
                    os9       I$Read              * 01C2 10 3F 89       .?.
                    leax      >L012D,PC           * 01C5 30 8D FF 64    0..d
                    ldy       #1                  * 01C9 10 8E 00 01    ....
                    lda       #1                  * 01CD 86 01          ..
                    os9       I$WritLn            * 01CF 10 3F 8C       .?.
                    lda       U0000,U             * 01D2 A6 C4          &D
                    anda      #223                * 01D4 84 DF          ._
                    cmpa      #65                 * 01D6 81 41          .A
                    lbeq      L01F6               * 01D8 10 27 00 1A    .'..
                    cmpa      #88                 * 01DC 81 58          .X
                    lbeq      L023A               * 01DE 10 27 00 58    .'.X
                    cmpa      #67                 * 01E2 81 43          .C
                    lbeq      L027E               * 01E4 10 27 00 96    .'..
                    cmpa      #89                 * 01E8 81 59          .Y
                    lbeq      L02C6               * 01EA 10 27 00 D8    .'.X
                    cmpa      #81                 * 01EE 81 51          .Q
                    lbeq      L04B1               * 01F0 10 27 02 BD    .'.=
                    bra       L0180               * 01F4 20 8A           .
L01F6               leax      >L010C,PC           * 01F6 30 8D FF 12    0...
                    ldy       #25                 * 01FA 10 8E 00 19    ....
                    lda       #1                  * 01FE 86 01          ..
                    os9       I$Write             * 0200 10 3F 8A       .?.
                    leax      <U0032,U            * 0203 30 C8 32       0H2
                    ldy       #27                 * 0206 10 8E 00 1B    ....
                    clra                          * 020A 4F             O
                    os9       I$ReadLn            * 020B 10 3F 8B       .?.
                    bcs       L01F6               * 020E 25 E6          %f
                    cmpy      #1                  * 0210 10 8C 00 01    ....
                    lbls      L04B1               * 0214 10 23 02 99    .#..
                    lda       #17                 * 0218 86 11          ..
                    ldb       #3                  * 021A C6 03          F.
                    leax      >L00A0,PC           * 021C 30 8D FE 80    0.~.
                    pshs      U                   * 0220 34 40          4@
                    leau      <U0032,U            * 0222 33 C8 32       3H2
                    os9       F$Fork              * 0225 10 3F 03       .?.
                    lbcs      L04B2               * 0228 10 25 02 86    .%..
                    clrb                          * 022C 5F             _
                    os9       F$Wait              * 022D 10 3F 04       .?.
                    tstb                          * 0230 5D             ]
                    lbne      L04B2               * 0231 10 26 02 7D    .&.}
                    puls      U                   * 0235 35 40          5@
                    lbra      L0336               * 0237 16 00 FC       ..|
L023A               leax      >L010C,PC           * 023A 30 8D FE CE    0.~N
                    ldy       #25                 * 023E 10 8E 00 19    ....
                    lda       #1                  * 0242 86 01          ..
                    os9       I$Write             * 0244 10 3F 8A       .?.
                    leax      <U0032,U            * 0247 30 C8 32       0H2
                    ldy       #27                 * 024A 10 8E 00 1B    ....
                    clra                          * 024E 4F             O
                    os9       I$ReadLn            * 024F 10 3F 8B       .?.
                    bcs       L023A               * 0252 25 E6          %f
                    cmpy      #1                  * 0254 10 8C 00 01    ....
                    lbls      L04B1               * 0258 10 23 02 55    .#.U
                    lda       #17                 * 025C 86 11          ..
                    ldb       #3                  * 025E C6 03          F.
                    leax      >L0082,PC           * 0260 30 8D FE 1E    0.~.
                    pshs      U                   * 0264 34 40          4@
                    leau      <U0032,U            * 0266 33 C8 32       3H2
                    os9       F$Fork              * 0269 10 3F 03       .?.
                    lbcs      L04B2               * 026C 10 25 02 42    .%.B
                    clrb                          * 0270 5F             _
                    os9       F$Wait              * 0271 10 3F 04       .?.
                    tstb                          * 0274 5D             ]
                    lbne      L04B2               * 0275 10 26 02 39    .&.9
                    puls      U                   * 0279 35 40          5@
                    lbra      L0336               * 027B 16 00 B8       ..8
L027E               leax      >L010C,PC           * 027E 30 8D FE 8A    0.~.
                    ldy       #25                 * 0282 10 8E 00 19    ....
                    lda       #1                  * 0286 86 01          ..
                    os9       I$Write             * 0288 10 3F 8A       .?.
                    leax      <U0032,U            * 028B 30 C8 32       0H2
                    ldy       #27                 * 028E 10 8E 00 1B    ....
                    clra                          * 0292 4F             O
                    os9       I$ReadLn            * 0293 10 3F 8B       .?.
                    bcs       L027E               * 0296 25 E6          %f
                    cmpy      #1                  * 0298 10 8C 00 01    ....
                    lbls      L04B1               * 029C 10 23 02 11    .#..
                    lda       #17                 * 02A0 86 11          ..
                    ldb       #3                  * 02A2 C6 03          F.
                    leax      >L0089,PC           * 02A4 30 8D FD E1    0.}a
                    pshs      U                   * 02A8 34 40          4@
                    leau      <U0032,U            * 02AA 33 C8 32       3H2
                    os9       F$Fork              * 02AD 10 3F 03       .?.
                    lbcs      L04B2               * 02B0 10 25 01 FE    .%.~
                    clrb                          * 02B4 5F             _
                    os9       F$Wait              * 02B5 10 3F 04       .?.
                    lbcs      L04B2               * 02B8 10 25 01 F6    .%.v
                    tstb                          * 02BC 5D             ]
                    lbne      L04B2               * 02BD 10 26 01 F1    .&.q
                    puls      U                   * 02C1 35 40          5@
                    lbra      L0336               * 02C3 16 00 70       ..p
L02C6               leax      >L010C,PC           * 02C6 30 8D FE 42    0.~B
                    ldy       #25                 * 02CA 10 8E 00 19    ....
                    lda       #1                  * 02CE 86 01          ..
                    os9       I$Write             * 02D0 10 3F 8A       .?.
                    leax      <U0032,U            * 02D3 30 C8 32       0H2
                    ldy       #27                 * 02D6 10 8E 00 1B    ....
                    clra                          * 02DA 4F             O
                    os9       I$ReadLn            * 02DB 10 3F 8B       .?.
                    bcs       L02C6               * 02DE 25 E6          %f
                    cmpy      #1                  * 02E0 10 8C 00 01    ....
                    lbls      L04B1               * 02E4 10 23 01 C9    .#.I
                    lda       #17                 * 02E8 86 11          ..
                    ldb       #3                  * 02EA C6 03          F.
                    leax      >L0091,PC           * 02EC 30 8D FD A1    0.}!
                    pshs      U                   * 02F0 34 40          4@
                    leau      <U0032,U            * 02F2 33 C8 32       3H2
                    os9       F$Fork              * 02F5 10 3F 03       .?.
                    lbcs      L04B2               * 02F8 10 25 01 B6    .%.6
                    clrb                          * 02FC 5F             _
                    os9       F$Wait              * 02FD 10 3F 04       .?.
                    lbcs      L04B2               * 0300 10 25 01 AE    .%..
                    tstb                          * 0304 5D             ]
                    lbne      L04B2               * 0305 10 26 01 A9    .&.)
                    puls      U                   * 0309 35 40          5@
                    lbra      L0336               * 030B 16 00 28       ..(
                    fcb       $86                 * 030E 86             .
                    fcb       $11                 * 030F 11             .
                    fcb       $10                 * 0310 10             .
                    fcb       $8E                 * 0311 8E             .
                    fcb       $00                 * 0312 00             .
                    fcb       $01                 * 0313 01             .
                    fcb       $C6                 * 0314 C6             F
                    fcb       $03                 * 0315 03             .
                    fcb       $30                 * 0316 30             0
                    fcb       $8D                 * 0317 8D             .
                    fcb       $FD                 * 0318 FD             }
                    fcc       "~4@3"              * 0319 7E 34 40 33    ~4@3
                    fcb       $C9                 * 031D C9             I
                    fcb       $01                 * 031E 01             .
                    fcb       $2D                 * 031F 2D             -
                    fcb       $10                 * 0320 10             .
                    fcb       $3F                 * 0321 3F             ?
                    fcb       $03                 * 0322 03             .
                    fcb       $10                 * 0323 10             .
                    fcb       $25                 * 0324 25             %
                    fcb       $01                 * 0325 01             .
                    fcb       $8B                 * 0326 8B             .
                    fcb       $5F                 * 0327 5F             _
                    fcb       $10                 * 0328 10             .
                    fcb       $3F                 * 0329 3F             ?
                    fcb       $04                 * 032A 04             .
                    fcb       $10                 * 032B 10             .
                    fcb       $25                 * 032C 25             %
                    fcb       $01                 * 032D 01             .
                    fcb       $83                 * 032E 83             .
                    fcb       $5D                 * 032F 5D             ]
                    fcb       $10                 * 0330 10             .
                    fcb       $26                 * 0331 26             &
                    fcb       $01                 * 0332 01             .
                    fcc       "~5@"               * 0333 7E 35 40       ~5@
L0336               lda       U0001,U             * 0336 A6 41          &A
                    leax      >U0092,U            * 0338 30 C9 00 92    0I..
                    ldy       #96                 * 033C 10 8E 00 60    ...`
                    os9       I$Read              * 0340 10 3F 89       .?.
                    bcs       L0359               * 0343 25 14          %.
                    leay      <U0032,U            * 0345 31 C8 32       1H2
L0348               lda       ,X+                 * 0348 A6 80          &.
                    cmpa      ,Y+                 * 034A A1 A0          !
                    bne       L0336               * 034C 26 E8          &h
                    cmpa      #13                 * 034E 81 0D          ..
                    beq       L0354               * 0350 27 02          '.
                    bra       L0348               * 0352 20 F4           t
L0354               ldb       #218                * 0354 C6 DA          FZ
                    lbra      L04B2               * 0356 16 01 59       ..Y
L0359               cmpb      #211                * 0359 C1 D3          AS
                    lbne      L04B2               * 035B 10 26 01 53    .&.S
                    lda       U0001,U             * 035F A6 41          &A
                    ldb       #5                  * 0361 C6 05          F.
                    ldx       #0                  * 0363 8E 00 00       ...
                    pshs      U                   * 0366 34 40          4@
                    ldu       #0                  * 0368 CE 00 00       N..
                    os9       I$Seek              * 036B 10 3F 88       .?.
                    puls      U                   * 036E 35 40          5@
L0370               lda       U0001,U             * 0370 A6 41          &A
                    leax      >U0092,U            * 0372 30 C9 00 92    0I..
                    ldy       #96                 * 0376 10 8E 00 60    ...`
                    os9       I$Read              * 037A 10 3F 89       .?.
                    bcs       L03A7               * 037D 25 28          %(
                    lda       >U00B1,U            * 037F A6 C9 00 B1    &I.1
                    cmpa      #1                  * 0383 81 01          ..
                    bne       L0370               * 0385 26 E9          &i
                    lda       U0001,U             * 0387 A6 41          &A
                    ldb       #5                  * 0389 C6 05          F.
                    pshs      U                   * 038B 34 40          4@
                    os9       I$GetStt            * 038D 10 3F 8D       .?.
                    tfr       U,D                 * 0390 1F 30          .0
                    subd      #96                 * 0392 83 00 60       ..`
                    bge       L0399               * 0395 2C 02          ,.
                    leax      -$01,X              * 0397 30 1F          0.
L0399               ldy       0,S                 * 0399 10 AE E4       ..d
                    tfr       D,U                 * 039C 1F 03          ..
                    lda       $01,Y               * 039E A6 21          &!
                    os9       I$Seek              * 03A0 10 3F 88       .?.
                    puls      U                   * 03A3 35 40          5@
                    bra       L03AD               * 03A5 20 06           .
L03A7               cmpb      #211                * 03A7 C1 D3          AS
                    lbne      L04B2               * 03A9 10 26 01 05    .&..
L03AD               ldx       #0                  * 03AD 8E 00 00       ...
                    ldy       #0                  * 03B0 10 8E 00 00    ....
                    stx       <U004D,U            * 03B4 AF C8 4D       /HM
                    sty       <U004F,U            * 03B7 10 AF C8 4F    ./HO
                    leax      >L012F,PC           * 03BB 30 8D FD 70    0.}p
                    ldy       #200                * 03BF 10 8E 00 C8    ...H
                    lda       #1                  * 03C3 86 01          ..
                    os9       I$WritLn            * 03C5 10 3F 8C       .?.
                    leax      >L0159,PC           * 03C8 30 8D FD 8D    0.}.
                    ldy       #1                  * 03CC 10 8E 00 01    ....
                    os9       I$Write             * 03D0 10 3F 8A       .?.
                    leax      <U0052,U            * 03D3 30 C8 52       0HR
                    ldy       #64                 * 03D6 10 8E 00 40    ...@
                    clra                          * 03DA 4F             O
                    os9       I$ReadLn            * 03DB 10 3F 8B       .?.
                    clr       <U0051,U            * 03DE 6F C8 51       oHQ
                    leax      <U0032,U            * 03E1 30 C8 32       0H2
                    ldy       #-1                 * 03E4 10 8E FF FF    ....
                    sty       <U004D,U            * 03E8 10 AF C8 4D    ./HM
                    sty       <U004F,U            * 03EC 10 AF C8 4F    ./HO
                    ldy       #96                 * 03F0 10 8E 00 60    ...`
                    lda       U0001,U             * 03F4 A6 41          &A
                    os9       I$Write             * 03F6 10 3F 8A       .?.
                    leax      >L015B,PC           * 03F9 30 8D FD 5E    0.}^
                    lda       #3                  * 03FD 86 03          ..
                    os9       I$Open              * 03FF 10 3F 84       .?.
                    bcc       L040D               * 0402 24 09          $.
                    ldb       #27                 * 0404 C6 1B          F.
                    os9       I$Create            * 0406 10 3F 83       .?.
                    lbcs      L04B2               * 0409 10 25 00 A5    .%.%
L040D               sta       U0003,U             * 040D A7 43          'C
                    os9       F$ID                * 040F 10 3F 0C       .?.
                    sty       <U0010,U            * 0412 10 AF C8 10    ./H.
L0416               leax      <U0012,U            * 0416 30 C8 12       0H.
                    ldy       #32                 * 0419 10 8E 00 20    ...
                    lda       U0003,U             * 041D A6 43          &C
                    os9       I$Read              * 041F 10 3F 89       .?.
                    bcs       L042F               * 0422 25 0B          %.
                    ldd       <U0012,U            * 0424 EC C8 12       lH.
                    cmpd      <U0010,U            * 0427 10 A3 C8 10    .#H.
                    bne       L0416               * 042B 26 E9          &i
                    bra       L0438               * 042D 20 09           .
L042F               cmpb      #211                * 042F C1 D3          AS
                    lbne      L04B2               * 0431 10 26 00 7D    .&.}
                    lbra      L0476               * 0435 16 00 3E       ..>
L0438               ldd       <U0022,U            * 0438 EC C8 22       lH"
                    addd      #1                  * 043B C3 00 01       C..
                    std       <U0022,U            * 043E ED C8 22       mH"
                    lda       U0003,U             * 0441 A6 43          &C
                    ldb       #5                  * 0443 C6 05          F.
                    pshs      U                   * 0445 34 40          4@
                    os9       I$GetStt            * 0447 10 3F 8D       .?.
                    tfr       U,D                 * 044A 1F 30          .0
                    subd      #32                 * 044C 83 00 20       ..
                    bge       L0453               * 044F 2C 02          ,.
                    leax      -$01,X              * 0451 30 1F          0.
L0453               ldu       0,S                 * 0453 EE E4          nd
                    tfr       D,Y                 * 0455 1F 02          ..
                    lda       U0003,U             * 0457 A6 43          &C
                    tfr       Y,U                 * 0459 1F 23          .#
                    os9       I$Seek              * 045B 10 3F 88       .?.
                    lbcs      L04B2               * 045E 10 25 00 50    .%.P
                    puls      U                   * 0462 35 40          5@
                    leax      <U0012,U            * 0464 30 C8 12       0H.
                    ldy       #32                 * 0467 10 8E 00 20    ...
                    lda       U0003,U             * 046B A6 43          &C
                    os9       I$Write             * 046D 10 3F 8A       .?.
                    os9       I$Close             * 0470 10 3F 8F       .?.
                    lbra      L04B1               * 0473 16 00 3B       ..;
L0476               leax      <U0012,U            * 0476 30 C8 12       0H.
                    ldd       #1                  * 0479 CC 00 01       L..
                    std       <U0014,U            * 047C ED C8 14       mH.
                    std       <U001E,U            * 047F ED C8 1E       mH.
                    ldd       #0                  * 0482 CC 00 00       L..
                    std       <U001C,U            * 0485 ED C8 1C       mH.
                    std       <U0022,U            * 0488 ED C8 22       mH"
                    std       <U0020,U            * 048B ED C8 20       mH
                    ldd       <U0010,U            * 048E EC C8 10       lH.
                    std       <U0012,U            * 0491 ED C8 12       mH.
                    leax      <U0016,U            * 0494 30 C8 16       0H.
                    os9       F$Time              * 0497 10 3F 15       .?.
                    lbcs      L04B2               * 049A 10 25 00 14    .%..
                    leax      <U0012,U            * 049E 30 C8 12       0H.
                    ldy       #32                 * 04A1 10 8E 00 20    ...
                    lda       U0003,U             * 04A5 A6 43          &C
                    os9       I$Write             * 04A7 10 3F 8A       .?.
                    os9       I$Close             * 04AA 10 3F 8F       .?.
                    lbcs      L04B2               * 04AD 10 25 00 01    .%..
L04B1               clrb                          * 04B1 5F             _
L04B2               os9       F$Exit              * 04B2 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
