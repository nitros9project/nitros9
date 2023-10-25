                    nam       BBS.validate
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
U0003               rmb       2
U0005               rmb       80
U0055               rmb       1
U0056               rmb       479
size                equ       .

name                fcs       /BBS.validate/      * 000D 42 42 53 2E 76 61 6C 69 64 61 74 E5 BBS.validate
L0019               fcc       "Enter new user's name:=====>" * 0019 45 6E 74 65 72 20 6E 65 77 20 75 73 65 72 27 73 20 6E 61 6D 65 3A 3D 3D 3D 3D 3D 3E Enter new user's name:=====>
L0035               fcc       "Enter new user's password:=>" * 0035 45 6E 74 65 72 20 6E 65 77 20 75 73 65 72 27 73 20 70 61 73 73 77 6F 72 64 3A 3D 3E Enter new user's password:=>
L0051               fcc       "Enter new user's program:==>" * 0051 45 6E 74 65 72 20 6E 65 77 20 75 73 65 72 27 73 20 70 72 6F 67 72 61 6D 3A 3D 3D 3E Enter new user's program:==>
L006D               fcc       "Enter new user's number:===>" * 006D 45 6E 74 65 72 20 6E 65 77 20 75 73 65 72 27 73 20 6E 75 6D 62 65 72 3A 3D 3D 3D 3E Enter new user's number:===>
L0089               fcc       "Enter new user's time limit>" * 0089 45 6E 74 65 72 20 6E 65 77 20 75 73 65 72 27 73 20 74 69 6D 65 20 6C 69 6D 69 74 3E Enter new user's time limit>
L00A5               fcc       "Enter new user's alias:====>" * 00A5 45 6E 74 65 72 20 6E 65 77 20 75 73 65 72 27 73 20 61 6C 69 61 73 3A 3D 3D 3D 3D 3E Enter new user's alias:====>
L00C1               fcb       $0A                 * 00C1 0A             .
                    fcc       "New BBS.users line will read as follows:" * 00C2 4E 65 77 20 42 42 53 2E 75 73 65 72 73 20 6C 69 6E 65 20 77 69 6C 6C 20 72 65 61 64 20 61 73 20 66 6F 6C 6C 6F 77 73 3A New BBS.users line will read as follows:
                    fcb       $0D                 * 00EA 0D             .
L00EB               fcb       $0D                 * 00EB 0D             .
                    fcb       $0A                 * 00EC 0A             .
                    fcc       "Is this line correct? (Y/N):" * 00ED 49 73 20 74 68 69 73 20 6C 69 6E 65 20 63 6F 72 72 65 63 74 3F 20 28 59 2F 4E 29 3A Is this line correct? (Y/N):
L0109               fcc       "BBS.users"         * 0109 42 42 53 2E 75 73 65 72 73 BBS.users
                    fcb       $0D                 * 0112 0D             .
L0113               fcc       "/dd/bbs/bbs.alias" * 0113 2F 64 64 2F 62 62 73 2F 62 62 73 2E 61 6C 69 61 73 /dd/bbs/bbs.alias
                    fcb       $0D                 * 0124 0D             .
L0125               fcb       $0D                 * 0125 0D             .
                    fcb       $0A                 * 0126 0A             .
start               leax      >L0109,PC           * 0127 30 8D FF DE    0..^
                    lda       #3                  * 012B 86 03          ..
                    os9       I$Open              * 012D 10 3F 84       .?.
                    bcc       L014E               * 0130 24 1C          $.
                    cmpb      #216                * 0132 C1 D8          AX
                    lbne      L02F1               * 0134 10 26 01 B9    .&.9
                    os9       F$ID                * 0138 10 3F 0C       .?.
                    ldb       #214                * 013B C6 D6          FV
                    cmpy      #0                  * 013D 10 8C 00 00    ....
                    lbne      L02F1               * 0141 10 26 01 AC    .&.,
                    ldb       #3                  * 0145 C6 03          F.
                    os9       I$Create            * 0147 10 3F 83       .?.
                    lbcs      L02F1               * 014A 10 25 01 A3    .%.#
L014E               sta       U0000,U             * 014E A7 C4          'D
                    leax      >L0113,PC           * 0150 30 8D FF BF    0..?
                    lda       #3                  * 0154 86 03          ..
                    os9       I$Open              * 0156 10 3F 84       .?.
                    bcc       L0177               * 0159 24 1C          $.
                    cmpb      #216                * 015B C1 D8          AX
                    lbne      L02F1               * 015D 10 26 01 90    .&..
                    os9       F$ID                * 0161 10 3F 0C       .?.
                    ldb       #214                * 0164 C6 D6          FV
                    cmpy      #0                  * 0166 10 8C 00 00    ....
                    lbne      L02F1               * 016A 10 26 01 83    .&..
                    ldb       #11                 * 016E C6 0B          F.
                    os9       I$Create            * 0170 10 3F 83       .?.
                    lbcs      L02F1               * 0173 10 25 01 7A    .%.z
L0177               sta       U0001,U             * 0177 A7 41          'A
                    lda       U0000,U             * 0179 A6 C4          &D
                    ldb       #2                  * 017B C6 02          F.
                    pshs      U                   * 017D 34 40          4@
                    os9       I$GetStt            * 017F 10 3F 8D       .?.
                    lbcs      L02F1               * 0182 10 25 01 6B    .%.k
                    os9       I$Seek              * 0186 10 3F 88       .?.
                    lbcs      L02F1               * 0189 10 25 01 64    .%.d
                    puls      U                   * 018D 35 40          5@
                    lda       U0001,U             * 018F A6 41          &A
                    ldb       #2                  * 0191 C6 02          F.
                    pshs      U                   * 0193 34 40          4@
                    os9       I$GetStt            * 0195 10 3F 8D       .?.
                    lbcs      L02F1               * 0198 10 25 01 55    .%.U
                    os9       I$Seek              * 019C 10 3F 88       .?.
                    lbcs      L02F1               * 019F 10 25 01 4E    .%.N
                    puls      U                   * 01A3 35 40          5@
L01A5               leax      >L0019,PC           * 01A5 30 8D FE 70    0.~p
                    ldy       #28                 * 01A9 10 8E 00 1C    ....
                    lda       #1                  * 01AD 86 01          ..
                    os9       I$Write             * 01AF 10 3F 8A       .?.
                    leax      U0005,U             * 01B2 30 45          0E
                    clra                          * 01B4 4F             O
                    ldy       #80                 * 01B5 10 8E 00 50    ...P
                    os9       I$ReadLn            * 01B9 10 3F 8B       .?.
                    pshs      X                   * 01BC 34 10          4.
L01BE               lda       0,X                 * 01BE A6 84          &.
                    cmpa      #97                 * 01C0 81 61          .a
                    bcs       L01C6               * 01C2 25 02          %.
                    anda      #223                * 01C4 84 DF          ._
L01C6               sta       ,X+                 * 01C6 A7 80          '.
                    cmpa      #13                 * 01C8 81 0D          ..
                    bne       L01BE               * 01CA 26 F2          &r
                    puls      X                   * 01CC 35 10          5.
                    tfr       Y,D                 * 01CE 1F 20          .
                    leax      D,X                 * 01D0 30 8B          0.
                    lda       #44                 * 01D2 86 2C          .,
                    sta       -$01,X              * 01D4 A7 1F          '.
                    pshs      X                   * 01D6 34 10          4.
                    leax      >L0035,PC           * 01D8 30 8D FE 59    0.~Y
                    ldy       #28                 * 01DC 10 8E 00 1C    ....
                    lda       #1                  * 01E0 86 01          ..
                    os9       I$Write             * 01E2 10 3F 8A       .?.
                    puls      X                   * 01E5 35 10          5.
                    ldy       #80                 * 01E7 10 8E 00 50    ...P
                    clra                          * 01EB 4F             O
                    os9       I$ReadLn            * 01EC 10 3F 8B       .?.
                    pshs      X                   * 01EF 34 10          4.
L01F1               lda       0,X                 * 01F1 A6 84          &.
                    cmpa      #97                 * 01F3 81 61          .a
                    bcs       L01F9               * 01F5 25 02          %.
                    anda      #223                * 01F7 84 DF          ._
L01F9               sta       ,X+                 * 01F9 A7 80          '.
                    cmpa      #13                 * 01FB 81 0D          ..
                    bne       L01F1               * 01FD 26 F2          &r
                    puls      X                   * 01FF 35 10          5.
                    tfr       Y,D                 * 0201 1F 20          .
                    leax      D,X                 * 0203 30 8B          0.
                    lda       #44                 * 0205 86 2C          .,
                    sta       -$01,X              * 0207 A7 1F          '.
                    pshs      X                   * 0209 34 10          4.
                    leax      >L0051,PC           * 020B 30 8D FE 42    0.~B
                    ldy       #28                 * 020F 10 8E 00 1C    ....
                    lda       #1                  * 0213 86 01          ..
                    os9       I$Write             * 0215 10 3F 8A       .?.
                    puls      X                   * 0218 35 10          5.
                    clra                          * 021A 4F             O
                    ldy       #80                 * 021B 10 8E 00 50    ...P
                    os9       I$ReadLn            * 021F 10 3F 8B       .?.
                    tfr       Y,D                 * 0222 1F 20          .
                    leax      D,X                 * 0224 30 8B          0.
                    lda       #44                 * 0226 86 2C          .,
                    sta       -$01,X              * 0228 A7 1F          '.
                    pshs      X                   * 022A 34 10          4.
                    leax      >L00A5,PC           * 022C 30 8D FE 75    0.~u
                    ldy       #28                 * 0230 10 8E 00 1C    ....
                    lda       #1                  * 0234 86 01          ..
                    os9       I$Write             * 0236 10 3F 8A       .?.
                    leax      <U0055,U            * 0239 30 C8 55       0HU
                    ldy       #80                 * 023C 10 8E 00 50    ...P
                    clra                          * 0240 4F             O
                    os9       I$ReadLn            * 0241 10 3F 8B       .?.
                    tfr       Y,D                 * 0244 1F 20          .
                    leax      D,X                 * 0246 30 8B          0.
                    lda       #44                 * 0248 86 2C          .,
                    sta       -$01,X              * 024A A7 1F          '.
                    stx       U0003,U             * 024C AF 43          /C
                    leax      >L006D,PC           * 024E 30 8D FE 1B    0.~.
                    ldy       #28                 * 0252 10 8E 00 1C    ....
                    lda       #1                  * 0256 86 01          ..
                    os9       I$Write             * 0258 10 3F 8A       .?.
                    puls      X                   * 025B 35 10          5.
                    ldy       #80                 * 025D 10 8E 00 50    ...P
                    clra                          * 0261 4F             O
                    os9       I$ReadLn            * 0262 10 3F 8B       .?.
                    ldy       U0003,U             * 0265 10 AE 43       ..C
L0268               lda       ,X+                 * 0268 A6 80          &.
                    sta       ,Y+                 * 026A A7 A0          '
                    cmpa      #13                 * 026C 81 0D          ..
                    bne       L0268               * 026E 26 F8          &x
                    lda       #44                 * 0270 86 2C          .,
                    sta       -$01,X              * 0272 A7 1F          '.
                    pshs      X                   * 0274 34 10          4.
                    leax      >L0089,PC           * 0276 30 8D FE 0F    0.~.
                    ldy       #28                 * 027A 10 8E 00 1C    ....
                    lda       #1                  * 027E 86 01          ..
                    os9       I$Write             * 0280 10 3F 8A       .?.
                    puls      X                   * 0283 35 10          5.
                    ldy       #80                 * 0285 10 8E 00 50    ...P
                    clra                          * 0289 4F             O
                    os9       I$ReadLn            * 028A 10 3F 8B       .?.
                    leax      >L00C1,PC           * 028D 30 8D FE 30    0.~0
                    ldy       #200                * 0291 10 8E 00 C8    ...H
                    lda       #1                  * 0295 86 01          ..
                    os9       I$WritLn            * 0297 10 3F 8C       .?.
                    leax      U0005,U             * 029A 30 45          0E
                    ldy       #200                * 029C 10 8E 00 C8    ...H
                    os9       I$WritLn            * 02A0 10 3F 8C       .?.
                    leax      >L00EB,PC           * 02A3 30 8D FE 44    0.~D
                    ldy       #30                 * 02A7 10 8E 00 1E    ....
                    lda       #1                  * 02AB 86 01          ..
                    os9       I$Write             * 02AD 10 3F 8A       .?.
                    leax      U0002,U             * 02B0 30 42          0B
                    ldy       #1                  * 02B2 10 8E 00 01    ....
                    clra                          * 02B6 4F             O
                    os9       I$Read              * 02B7 10 3F 89       .?.
                    leax      >L0125,PC           * 02BA 30 8D FE 67    0.~g
                    ldy       #1                  * 02BE 10 8E 00 01    ....
                    lda       #1                  * 02C2 86 01          ..
                    os9       I$WritLn            * 02C4 10 3F 8C       .?.
                    lda       U0002,U             * 02C7 A6 42          &B
                    anda      #223                * 02C9 84 DF          ._
                    cmpa      #89                 * 02CB 81 59          .Y
                    lbne      L01A5               * 02CD 10 26 FE D4    .&~T
                    lda       U0000,U             * 02D1 A6 C4          &D
                    leax      U0005,U             * 02D3 30 45          0E
                    ldy       #81                 * 02D5 10 8E 00 51    ...Q
                    os9       I$WritLn            * 02D9 10 3F 8C       .?.
                    lbcs      L02F1               * 02DC 10 25 00 11    .%..
                    lda       U0001,U             * 02E0 A6 41          &A
                    leax      <U0055,U            * 02E2 30 C8 55       0HU
                    ldy       #81                 * 02E5 10 8E 00 51    ...Q
                    os9       I$WritLn            * 02E9 10 3F 8C       .?.
                    lbcs      L02F1               * 02EC 10 25 00 01    .%..
                    clrb                          * 02F0 5F             _
L02F1               os9       F$Exit              * 02F1 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
