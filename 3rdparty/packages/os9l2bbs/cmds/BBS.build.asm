                    nam       BBS.build
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       2
U0002               rmb       1
U0003               rmb       1
U0004               rmb       1
U0005               rmb       2
U0007               rmb       1
U0008               rmb       1
U0009               rmb       2
U000B               rmb       1
U000C               rmb       1
U000D               rmb       2
U000F               rmb       2
U0011               rmb       3
U0014               rmb       80
U0064               rmb       32
U0084               rmb       1
U0085               rmb       8199
size                equ       .

name                fcs       /BBS.build/         * 000D 42 42 53 2E 62 75 69 6C E4 BBS.build
                    fcc       "Copyright (C) 1988" * 0016 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 Copyright (C) 1988
                    fcc       "By Keith Alphonso" * 0028 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F By Keith Alphonso
                    fcc       "Licenced to Alpha Software Technologies" * 0039 4C 69 63 65 6E 63 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licenced to Alpha Software Technologies
                    fcc       "All rights reserved" * 0060 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 All rights reserved
                    fcb       $EC                 * 0073 EC             l
                    fcb       $E6                 * 0074 E6             f
                    fcb       $EA                 * 0075 EA             j
                    fcb       $F5                 * 0076 F5             u
                    fcb       $E9                 * 0077 E9             i
                    fcb       $A0                 * 0078 A0
                    fcb       $E2                 * 0079 E2             b
                    fcb       $ED                 * 007A ED             m
                    fcb       $F1                 * 007B F1             q
                    fcb       $E9                 * 007C E9             i
                    fcb       $F0                 * 007D F0             p
                    fcb       $EF                 * 007E EF             o
                    fcb       $F4                 * 007F F4             t
                    fcb       $F0                 * 0080 F0             p
L0081               fcb       $0A                 * 0081 0A             .
                    fcb       $0A                 * 0082 0A             .
                    fcc       "    Please enter message now            (Blank line ends)" * 0083 20 20 20 20 50 6C 65 61 73 65 20 65 6E 74 65 72 20 6D 65 73 73 61 67 65 20 6E 6F 77 20 20 20 20 20 20 20 20 20 20 20 20 28 42 6C 61 6E 6B 20 6C 69 6E 65 20 65 6E 64
                    fcb       $0D                 * 00BC 0D             .
L00BD               fcc       "----------------------------------------------------------------" * 00BD 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 00FD 0D             .
L00FE               fcb       $0A                 * 00FE 0A             .
                    fcc       "[A]bort [D]one [E]dit [C]ontinue or [L]ist" * 00FF 5B 41 5D 62 6F 72 74 20 5B 44 5D 6F 6E 65 20 5B 45 5D 64 69 74 20 5B 43 5D 6F 6E 74 69 6E 75 65 20 6F 72 20 5B 4C 5D 69 73 74 [A]bort [D]one [E]dit [C]ontinue or [L]ist
                    fcb       $0D                 * 0129 0D             .
L012A               fcc       "Enter line #"      * 012A 45 6E 74 65 72 20 6C 69 6E 65 20 23 Enter line #
                    fcb       $0D                 * 0136 0D             .
L0137               fcc       ">"                 * 0137 3E             >
L0138               fcb       $0A                 * 0138 0A             .
                    fcb       $0D                 * 0139 0D             .
L013A               fcb       $08                 * 013A 08             .
                    fcb       $20                 * 013B 20
                    fcb       $08                 * 013C 08             .

start               stx       U0005,U             * 013D AF 45          /E
                    lda       #2                  * 013F 86 02          ..
                    ldb       #27                 * 0141 C6 1B          F.
                    os9       I$Create            * 0143 10 3F 83       .?.
                    lbcs      ErrExit             * 0146 10 25 01 C3    .%.C
                    sta       U0000,U             * 014A A7 C4          'D
                    leax      >L0081,PC           * 014C 30 8D FF 31    0..1
                    ldy       #200                * 0150 10 8E 00 C8    ...H
                    lda       #1                  * 0154 86 01          ..
                    os9       I$WritLn            * 0156 10 3F 8C       .?.
                    lbcs      ErrExit             * 0159 10 25 01 B0    .%.0
                    leax      >L00BD,PC           * 015D 30 8D FF 5C    0..\
                    ldy       #80                 * 0161 10 8E 00 50    ...P
                    os9       I$WritLn            * 0165 10 3F 8C       .?.
                    lbcs      ErrExit             * 0168 10 25 01 A1    .%.!
                    ldd       #0                  * 016C CC 00 00       L..
                    std       U0007,U             * 016F ED 47          mG
                    sta       U0004,U             * 0171 A7 44          'D
L0173               ldd       U0007,U             * 0173 EC 47          lG
                    addd      #1                  * 0175 C3 00 01       C..
                    std       U0007,U             * 0178 ED 47          mG
                    cmpd      #99                 * 017A 10 83 00 63    ...c
                    bge       L018B               * 017E 2C 0B          ,.
                    lbsr      L0290               * 0180 17 01 0D       ...
                    cmpy      #1                  * 0183 10 8C 00 01    ....
                    bls       L018B               * 0187 23 02          #.
                    bra       L0173               * 0189 20 E8           h

L018B               leax      >L00FE,PC           * 018B 30 8D FF 6F    0..o
                    ldy       #200                * 018F 10 8E 00 C8    ...H
                    lda       #1                  * 0193 86 01          ..
                    os9       I$WritLn            * 0195 10 3F 8C       .?.
                    leax      >L0137,PC           * 0198 30 8D FF 9B    0...
                    ldy       #1                  * 019C 10 8E 00 01    ....
                    os9       I$Write             * 01A0 10 3F 8A       .?.
                    leax      U0003,U             * 01A3 30 43          0C
                    clra                          * 01A5 4F             O
                    ldy       #1                  * 01A6 10 8E 00 01    ....
                    os9       I$Read              * 01AA 10 3F 89       .?.
                    leax      >L0138,PC           * 01AD 30 8D FF 87    0...
                    ldy       #1                  * 01B1 10 8E 00 01    ....
                    lda       #1                  * 01B5 86 01          ..
                    os9       I$WritLn            * 01B7 10 3F 8C       .?.
                    lda       U0003,U             * 01BA A6 43          &C
                    anda      #223                * 01BC 84 DF          ._
                    cmpa      #65                 * 01BE 81 41          .A
                    lbeq      L0310               * 01C0 10 27 01 4C    .'.L
                    cmpa      #68                 * 01C4 81 44          .D
                    lbeq      L02DF               * 01C6 10 27 01 15    .'..
                    cmpa      #69                 * 01CA 81 45          .E
                    beq       L01E1               * 01CC 27 13          '.
                    cmpa      #67                 * 01CE 81 43          .C
                    beq       L01D8               * 01D0 27 06          '.
                    cmpa      #76                 * 01D2 81 4C          .L
                    beq       L0251               * 01D4 27 7B          '{
                    bra       L018B               * 01D6 20 B3           3

L01D8               ldd       U0007,U             * 01D8 EC 47          lG
                    subd      #1                  * 01DA 83 00 01       ...
                    std       U0007,U             * 01DD ED 47          mG
                    bra       L0173               * 01DF 20 92           .

L01E1               leax      >L012A,PC           * 01E1 30 8D FF 45    0..E
                    ldy       #200                * 01E5 10 8E 00 C8    ...H
                    lda       #1                  * 01E9 86 01          ..
                    os9       I$WritLn            * 01EB 10 3F 8C       .?.
                    leax      >L0137,PC           * 01EE 30 8D FF 45    0..E
                    ldy       #1                  * 01F2 10 8E 00 01    ....
                    os9       I$Write             * 01F6 10 3F 8A       .?.
                    clra                          * 01F9 4F             O
                    leax      <U0011,U            * 01FA 30 C8 11       0H.
                    ldy       #3                  * 01FD 10 8E 00 03    ....
                    os9       I$ReadLn            * 0201 10 3F 8B       .?.
                    lbsr      L04AD               * 0204 17 02 A6       ..&
                    cmpd      U0007,U             * 0207 10 A3 47       .#G
                    lbcc      L018B               * 020A 10 24 FF 7D    .$.}
                    std       U000F,U             * 020E ED 4F          mO
                    leax      <U0011,U            * 0210 30 C8 11       0H.
                    lbsr      L0514               * 0213 17 02 FE       ..~
                    leax      <U0011,U            * 0216 30 C8 11       0H.
                    lda       #58                 * 0219 86 3A          .:
                    sta       $02,X               * 021B A7 02          '.
                    ldy       #3                  * 021D 10 8E 00 03    ....
                    lda       #1                  * 0221 86 01          ..
                    os9       I$Write             * 0223 10 3F 8A       .?.
                    ldd       U000F,U             * 0226 EC 4F          lO
                    leax      >U0084,U            * 0228 30 C9 00 84    0I..
                    lda       #80                 * 022C 86 50          .P
                    mul                           * 022E 3D             =
                    leax      D,X                 * 022F 30 8B          0.
                    ldy       #80                 * 0231 10 8E 00 50    ...P
                    lda       #1                  * 0235 86 01          ..
                    os9       I$WritLn            * 0237 10 3F 8C       .?.
                    tfr       Y,D                 * 023A 1F 20          .
                    stb       U0004,U             * 023C E7 44          gD
                    dec       U0004,U             * 023E 6A 44          jD
                    leay      <U0014,U            * 0240 31 C8 14       1H.
L0243               lda       ,X+                 * 0243 A6 80          &.
                    sta       ,Y+                 * 0245 A7 A0          '
                    decb                          * 0247 5A             Z
                    bne       L0243               * 0248 26 F9          &y
                    ldd       U000F,U             * 024A EC 4F          lO
                    bsr       L0290               * 024C 8D 42          .B
                    lbra      L018B               * 024E 16 FF 3A       ..:

L0251               ldd       #0                  * 0251 CC 00 00       L..
                    std       U0007,U             * 0254 ED 47          mG
L0256               ldd       U0007,U             * 0256 EC 47          lG
                    addd      #1                  * 0258 C3 00 01       C..
                    std       U0007,U             * 025B ED 47          mG
                    leax      <U0011,U            * 025D 30 C8 11       0H.
                    lbsr      L0514               * 0260 17 02 B1       ..1
                    leax      <U0011,U            * 0263 30 C8 11       0H.
                    lda       #58                 * 0266 86 3A          .:
                    sta       $02,X               * 0268 A7 02          '.
                    lda       #1                  * 026A 86 01          ..
                    ldy       #3                  * 026C 10 8E 00 03    ....
                    os9       I$Write             * 0270 10 3F 8A       .?.
                    leax      >U0084,U            * 0273 30 C9 00 84    0I..
                    ldd       U0007,U             * 0277 EC 47          lG
                    lda       #80                 * 0279 86 50          .P
                    mul                           * 027B 3D             =
                    leax      D,X                 * 027C 30 8B          0.
                    ldy       #80                 * 027E 10 8E 00 50    ...P
                    lda       #1                  * 0282 86 01          ..
                    os9       I$WritLn            * 0284 10 3F 8C       .?.
                    cmpy      #1                  * 0287 10 8C 00 01    ....
                    bhi       L0256               * 028B 22 C9          "I
                    lbra      L018B               * 028D 16 FE FB       .~{

L0290               leax      <U0011,U            * 0290 30 C8 11       0H.
                    pshs      D                   * 0293 34 06          4.
                    lbsr      L0514               * 0295 17 02 7C       ..|
                    leax      <U0011,U            * 0298 30 C8 11       0H.
                    lda       #58                 * 029B 86 3A          .:
                    sta       $02,X               * 029D A7 02          '.
                    lda       #1                  * 029F 86 01          ..
                    ldy       #3                  * 02A1 10 8E 00 03    ....
                    os9       I$Write             * 02A5 10 3F 8A       .?.
                    lbcs      ErrExit             * 02A8 10 25 00 61    .%.a
                    leax      <U0014,U            * 02AC 30 C8 14       0H.
                    ldb       U0004,U             * 02AF E6 44          fD
                    clra                          * 02B1 4F             O
                    tfr       D,Y                 * 02B2 1F 02          ..
                    lda       #1                  * 02B4 86 01          ..
                    os9       I$Write             * 02B6 10 3F 8A       .?.
                    puls      D                   * 02B9 35 06          5.
                    lda       #80                 * 02BB 86 50          .P
                    mul                           * 02BD 3D             =
                    leax      >U0084,U            * 02BE 30 C9 00 84    0I..
                    leax      D,X                 * 02C2 30 8B          0.
                    leay      <U0014,U            * 02C4 31 C8 14       1H.
                    ldb       #80                 * 02C7 C6 50          FP
                    lda       U0004,U             * 02C9 A6 44          &D
                    beq       L02D8               * 02CB 27 0B          '.
                    sta       U000B,U             * 02CD A7 4B          'K
L02CF               lda       ,Y+                 * 02CF A6 A0          &
                    sta       ,X+                 * 02D1 A7 80          '.
                    decb                          * 02D3 5A             Z
                    dec       U000B,U             * 02D4 6A 4B          jK
                    bne       L02CF               * 02D6 26 F7          &w
L02D8               clra                          * 02D8 4F             O
                    tfr       D,Y                 * 02D9 1F 02          ..
                    lbsr      L0320               * 02DB 17 00 42       ..B
                    rts                           * 02DE 39             9

L02DF               lda       #0                  * 02DF 86 00          ..
                    sta       U0009,U             * 02E1 A7 49          'I
L02E3               lda       U0009,U             * 02E3 A6 49          &I
                    inca                          * 02E5 4C             L
                    sta       U0009,U             * 02E6 A7 49          'I
                    cmpa      U0008,U             * 02E8 A1 48          !H
                    bhi       Exit                * 02EA 22 20          "
                    ldb       #80                 * 02EC C6 50          FP
                    mul                           * 02EE 3D             =
                    leax      >U0084,U            * 02EF 30 C9 00 84    0I..
                    leax      D,X                 * 02F3 30 8B          0.
                    ldy       #80                 * 02F5 10 8E 00 50    ...P
                    lda       U0000,U             * 02F9 A6 C4          &D
                    os9       I$WritLn            * 02FB 10 3F 8C       .?.
                    lbcs      ErrExit             * 02FE 10 25 00 0B    .%..
                    cmpy      #1                  * 0302 10 8C 00 01    ....
                    bls       Exit                * 0306 23 04          #.
                    tfr       Y,D                 * 0308 1F 20          .
                    bra       L02E3               * 030A 20 D7           W

Exit                clrb                          * 030C 5F             _
ErrExit             os9       F$Exit              * 030D 10 3F 06       .?.

L0310               lda       U0000,U             * 0310 A6 C4          &D
                    os9       I$Close             * 0312 10 3F 8F       .?.
                    ldx       U0005,U             * 0315 AE 45          .E
                    lda       #1                  * 0317 86 01          ..
                    os9       I$Delete            * 0319 10 3F 87       .?.
                    bcs       ErrExit             * 031C 25 EF          %o
                    bra       Exit                * 031E 20 EC           l

L0320               lbsr      L0478               * 0320 17 01 55       ..U
                    ldb       U0004,U             * 0323 E6 44          fD
                    leay      B,Y                 * 0325 31 A5          1%
                    pshs      Y                   * 0327 34 20          4
                    negb                          * 0329 50             P
                    sex                           * 032A 1D             .
                    leay      D,Y                 * 032B 31 AB          1+
                    clr       U0004,U             * 032D 6F 44          oD
                    cmpy      #0                  * 032F 10 8C 00 00    ....
                    lbeq      L03EF               * 0333 10 27 00 B8    .'.8
                    pshs      Y,X                 * 0337 34 30          40
                    lda       #13                 * 0339 86 0D          ..
L033B               sta       ,X+                 * 033B A7 80          '.
                    leay      -$01,Y              * 033D 31 3F          1?
                    bne       L033B               * 033F 26 FA          &z
                    puls      Y,X                 * 0341 35 30          50
L0343               pshs      Y,X                 * 0343 34 30          40
                    leax      U0003,U             * 0345 30 43          0C
                    ldy       #1                  * 0347 10 8E 00 01    ....
                    clra                          * 034B 4F             O
                    os9       I$Read              * 034C 10 3F 89       .?.
                    bcs       L037C               * 034F 25 2B          %+
                    lda       U0003,U             * 0351 A6 43          &C
                    cmpa      #1                  * 0353 81 01          ..
                    beq       L0380               * 0355 27 29          ')
                    cmpa      #8                  * 0357 81 08          ..
                    beq       L03A2               * 0359 27 47          'G
                    cmpa      #24                 * 035B 81 18          ..
                    beq       L03C6               * 035D 27 67          'g
                    cmpa      #13                 * 035F 81 0D          ..
                    lbeq      L03ED               * 0361 10 27 00 88    .'..
                    cmpa      #32                 * 0365 81 20          .
                    bcs       L037C               * 0367 25 13          %.
                    lda       #1                  * 0369 86 01          ..
                    os9       I$Write             * 036B 10 3F 8A       .?.
                    puls      Y,X                 * 036E 35 30          50
                    lda       U0003,U             * 0370 A6 43          &C
                    sta       ,X+                 * 0372 A7 80          '.
                    leay      -$01,Y              * 0374 31 3F          1?
                    lbeq      L0416               * 0376 10 27 00 9C    .'..
                    bra       L0343               * 037A 20 C7           G

L037C               puls      Y,X                 * 037C 35 30          50
                    bra       L0343               * 037E 20 C3           C

L0380               puls      Y,X                 * 0380 35 30          50
                    leay      -$01,Y              * 0382 31 3F          1?
                    beq       L039D               * 0384 27 17          '.
                    lda       ,X+                 * 0386 A6 80          &.
                    cmpa      #13                 * 0388 81 0D          ..
                    beq       L039B               * 038A 27 0F          '.
                    pshs      Y,X                 * 038C 34 30          40
                    leax      -$01,X              * 038E 30 1F          0.
                    ldy       #1                  * 0390 10 8E 00 01    ....
                    lda       #1                  * 0394 86 01          ..
                    os9       I$Write             * 0396 10 3F 8A       .?.
                    bra       L0380               * 0399 20 E5           e

L039B               leax      -$01,X              * 039B 30 1F          0.
L039D               leay      $01,Y               * 039D 31 21          1!
                    lbra      L0343               * 039F 16 FF A1       ..!

L03A2               puls      Y,X                 * 03A2 35 30          50
                    leay      $01,Y               * 03A4 31 21          1!
                    cmpy      0,S                 * 03A6 10 AC E4       .,d
                    bhi       L03C1               * 03A9 22 16          ".
                    pshs      Y,X                 * 03AB 34 30          40
                    leax      >L013A,PC           * 03AD 30 8D FD 89    0.}.
                    ldy       #3                  * 03B1 10 8E 00 03    ....
                    lda       #1                  * 03B5 86 01          ..
                    os9       I$Write             * 03B7 10 3F 8A       .?.
                    puls      Y,X                 * 03BA 35 30          50
                    leax      -$01,X              * 03BC 30 1F          0.
                    lbra      L0343               * 03BE 16 FF 82       ...

L03C1               leay      -$01,Y              * 03C1 31 3F          1?
                    lbra      L0343               * 03C3 16 FF 7D       ..}

L03C6               puls      Y,X                 * 03C6 35 30          50
                    leay      $01,Y               * 03C8 31 21          1!
                    cmpy      0,S                 * 03CA 10 AC E4       .,d
                    bhi       L03C1               * 03CD 22 F2          "r
                    pshs      Y,X                 * 03CF 34 30          40
                    leax      >L013A,PC           * 03D1 30 8D FD 65    0.}e
                    ldy       #3                  * 03D5 10 8E 00 03    ....
                    lda       #1                  * 03D9 86 01          ..
                    os9       I$Write             * 03DB 10 3F 8A       .?.
                    puls      Y,X                 * 03DE 35 30          50
                    leax      -$01,X              * 03E0 30 1F          0.
                    cmpy      0,S                 * 03E2 10 AC E4       .,d
                    lbhi      L0343               * 03E5 10 22 FF 5A    .".Z
                    pshs      Y,X                 * 03E9 34 30          40
                    bra       L03C6               * 03EB 20 D9           Y

L03ED               puls      Y,X                 * 03ED 35 30          50
L03EF               lda       #13                 * 03EF 86 0D          ..
                    sta       ,X+                 * 03F1 A7 80          '.
                    pshs      Y,X                 * 03F3 34 30          40
                    leax      >L0138,PC           * 03F5 30 8D FD 3F    0.}?
                    ldy       #1                  * 03F9 10 8E 00 01    ....
                    lda       #1                  * 03FD 86 01          ..
                    os9       I$WritLn            * 03FF 10 3F 8C       .?.
                    puls      Y,X                 * 0402 35 30          50
                    puls      D                   * 0404 35 06          5.
                    pshs      Y                   * 0406 34 20          4
                    subd      0,S                 * 0408 A3 E4          #d
                    leas      $02,S               * 040A 32 62          2b
                    tfr       D,Y                 * 040C 1F 02          ..
                    leay      $01,Y               * 040E 31 21          1!
                    lbsr      L0491               * 0410 17 00 7E       ..~
                    rts                           * 0413 39             9

                    fcc       "50"                * 0414 35 30          50

L0416               puls      D                   * 0416 35 06          5.
                    pshs      Y                   * 0418 34 20          4
                    subd      0,S                 * 041A A3 E4          #d
                    leas      $02,S               * 041C 32 62          2b
                    addd      #1                  * 041E C3 00 01       C..
                    tfr       D,Y                 * 0421 1F 02          ..
                    clrb                          * 0423 5F             _
L0424               leay      -$01,Y              * 0424 31 3F          1?
                    beq       L0442               * 0426 27 1A          '.
                    lda       ,-X                 * 0428 A6 82          &.
                    cmpa      #32                 * 042A 81 20          .
                    beq       L0453               * 042C 27 25          '%
                    pshs      Y,X                 * 042E 34 30          40
                    leax      >L013A,PC           * 0430 30 8D FD 06    0.}.
                    ldy       #3                  * 0434 10 8E 00 03    ....
                    lda       #1                  * 0438 86 01          ..
                    os9       I$Write             * 043A 10 3F 8A       .?.
                    incb                          * 043D 5C             \
                    puls      Y,X                 * 043E 35 30          50
                    bra       L0424               * 0440 20 E2           b

L0442               lda       #13                 * 0442 86 0D          ..
                    sta       <$004F,X            * 0444 A7 88 4F       '.O
                    ldy       #200                * 0447 10 8E 00 C8    ...H
                    lda       #1                  * 044B 86 01          ..
                    os9       I$WritLn            * 044D 10 3F 8C       .?.
                    puls      Y                   * 0450 35 20          5
                    rts                           * 0452 39             9

L0453               lda       #13                 * 0453 86 0D          ..
                    sta       ,X+                 * 0455 A7 80          '.
                    pshs      Y,X                 * 0457 34 30          40
                    stb       U0004,U             * 0459 E7 44          gD
                    leay      <U0014,U            * 045B 31 C8 14       1H.
L045E               lda       ,X+                 * 045E A6 80          &.
                    sta       ,Y+                 * 0460 A7 A0          '
                    decb                          * 0462 5A             Z
                    bne       L045E               * 0463 26 F9          &y
                    leax      >L0138,PC           * 0465 30 8D FC CF    0.|O
                    ldy       #1                  * 0469 10 8E 00 01    ....
                    lda       #1                  * 046D 86 01          ..
                    os9       I$WritLn            * 046F 10 3F 8C       .?.
                    puls      Y,X                 * 0472 35 30          50
                    lbsr      L0491               * 0474 17 00 1A       ...
                    rts                           * 0477 39             9

L0478               pshs      Y,X,D               * 0478 34 36          46
                    leax      <U0064,U            * 047A 30 C8 64       0Hd
                    clra                          * 047D 4F             O
                    ldb       #0                  * 047E C6 00          F.
                    os9       I$GetStt            * 0480 10 3F 8D       .?.
                    leax      -$20,X              * 0483 30 88 E0       0.`
                    clr       <$0024,X            * 0486 6F 88 24       o.$
                    leax      <$0020,X            * 0489 30 88 20       0.
                    os9       I$SetStt            * 048C 10 3F 8E       .?.
                    puls      PC,Y,X,D            * 048F 35 B6          56

L0491               pshs      Y,X,D               * 0491 34 36          46
                    leax      <U0064,U            * 0493 30 C8 64       0Hd
                    clra                          * 0496 4F             O
                    ldb       #0                  * 0497 C6 00          F.
                    os9       I$GetStt            * 0499 10 3F 8D       .?.
                    leax      -$20,X              * 049C 30 88 E0       0.`
                    lda       #1                  * 049F 86 01          ..
                    sta       <$0024,X            * 04A1 A7 88 24       '.$
                    leax      <$0020,X            * 04A4 30 88 20       0.
                    clra                          * 04A7 4F             O
                    os9       I$SetStt            * 04A8 10 3F 8E       .?.
                    puls      PC,Y,X,D            * 04AB 35 B6          56

L04AD               pshs      Y                   * 04AD 34 20          4
L04AF               lda       ,X+                 * 04AF A6 80          &.
                    cmpa      #13                 * 04B1 81 0D          ..
                    lbeq      L0545               * 04B3 10 27 00 8E    .'..
                    cmpa      #48                 * 04B7 81 30          .0
                    bcs       L04AF               * 04B9 25 F4          %t
                    cmpa      #57                 * 04BB 81 39          .9
                    bhi       L04AF               * 04BD 22 F0          "p
                    leax      -$01,X              * 04BF 30 1F          0.
L04C1               lda       ,X+                 * 04C1 A6 80          &.
                    cmpa      #48                 * 04C3 81 30          .0
                    bcs       L04CD               * 04C5 25 06          %.
                    cmpa      #57                 * 04C7 81 39          .9
                    bhi       L04CD               * 04C9 22 02          ".
                    bra       L04C1               * 04CB 20 F4           t

L04CD               pshs      X                   * 04CD 34 10          4.
                    leax      -$01,X              * 04CF 30 1F          0.
                    clr       U000B,U             * 04D1 6F 4B          oK
                    clr       U000C,U             * 04D3 6F 4C          oL
                    ldd       #1                  * 04D5 CC 00 01       L..
                    std       U000D,U             * 04D8 ED 4D          mM
L04DA               lda       ,-X                 * 04DA A6 82          &.
                    cmpa      #48                 * 04DC 81 30          .0
                    bcs       L050E               * 04DE 25 2E          %.
                    cmpa      #57                 * 04E0 81 39          .9
                    bhi       L050E               * 04E2 22 2A          "*
                    suba      #48                 * 04E4 80 30          .0
                    sta       U0002,U             * 04E6 A7 42          'B
                    ldd       #0                  * 04E8 CC 00 00       L..
L04EB               tst       U0002,U             * 04EB 6D 42          mB
                    beq       L04F5               * 04ED 27 06          '.
                    addd      U000D,U             * 04EF E3 4D          cM
                    dec       U0002,U             * 04F1 6A 42          jB
                    bra       L04EB               * 04F3 20 F6           v

L04F5               addd      U000B,U             * 04F5 E3 4B          cK
                    std       U000B,U             * 04F7 ED 4B          mK
                    lda       #10                 * 04F9 86 0A          ..
                    sta       U0002,U             * 04FB A7 42          'B
                    ldd       #0                  * 04FD CC 00 00       L..
L0500               tst       U0002,U             * 0500 6D 42          mB
                    beq       L050A               * 0502 27 06          '.
                    addd      U000D,U             * 0504 E3 4D          cM
                    dec       U0002,U             * 0506 6A 42          jB
                    bra       L0500               * 0508 20 F6           v

L050A               std       U000D,U             * 050A ED 4D          mM
                    bra       L04DA               * 050C 20 CC           L
L050E               ldd       U000B,U             * 050E EC 4B          lK
                    puls      X                   * 0510 35 10          5.
                    puls      PC,Y                * 0512 35 A0          5

L0514               pshs      Y                   * 0514 34 20          4
                    std       U000B,U             * 0516 ED 4B          mK
                    lda       #48                 * 0518 86 30          .0
                    sta       0,X                 * 051A A7 84          '.
                    sta       $01,X               * 051C A7 01          '.
                    ldd       #10                 * 051E CC 00 0A       L..
                    std       U000D,U             * 0521 ED 4D          mM
                    ldd       U000B,U             * 0523 EC 4B          lK
                    bsr       L0536               * 0525 8D 0F          ..
                    ldd       #1                  * 0527 CC 00 01       L..
                    std       U000D,U             * 052A ED 4D          mM
                    ldd       U000B,U             * 052C EC 4B          lK
                    bsr       L0536               * 052E 8D 06          ..
                    lda       #13                 * 0530 86 0D          ..
                    sta       0,X                 * 0532 A7 84          '.
                    puls      PC,Y                * 0534 35 A0          5

L0536               subd      U000D,U             * 0536 A3 4D          #M
                    bcs       L053E               * 0538 25 04          %.
                    inc       0,X                 * 053A 6C 84          l.
                    bra       L0536               * 053C 20 F8           x

L053E               addd      U000D,U             * 053E E3 4D          cM
                    std       U000B,U             * 0540 ED 4B          mK
                    leax      $01,X               * 0542 30 01          0.
                    rts                           * 0544 39             9

L0545               ldd       #-1                 * 0545 CC FF FF       L..
                    puls      PC,Y                * 0548 35 A0          5

                    emod
eom                 equ       *
                    end
