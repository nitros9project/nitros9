                    nam       BBS.mail.delete
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
U0003               rmb       3
U0006               rmb       1
U0007               rmb       2
U0009               rmb       2
U000B               rmb       1
U000C               rmb       1
U000D               rmb       1
U000E               rmb       1
U000F               rmb       232
U00F7               rmb       2
U00F9               rmb       2
U00FB               rmb       60
U0137               rmb       80
U0187               rmb       2
U0189               rmb       60
U01C5               rmb       2
U01C7               rmb       200
size                equ       .

name                fcs       /BBS.mail.delete/   * 000D 42 42 53 2E 6D 61 69 6C 2E 64 65 6C 65 74 E5 BBS.mail.delete
L001C               fcc       "BBS.mail.inx"      * 001C 42 42 53 2E 6D 61 69 6C 2E 69 6E 78 BBS.mail.inx
                    fcb       $0D                 * 0028 0D             .
L0029               fcc       "BBS.mail"          * 0029 42 42 53 2E 6D 61 69 6C BBS.mail
                    fcb       $0D                 * 0031 0D             .
                    fcb       $0A                 * 0032 0A             .
                    fcb       $0A                 * 0033 0A             .
                    fcc       "From    :Left on :About   :" * 0034 46 72 6F 6D 20 20 20 20 3A 4C 65 66 74 20 6F 6E 20 3A 41 62 6F 75 74 20 20 20 3A From    :Left on :About   :
                    fcb       $00                 * 004F 00             .
                    fcb       $09                 * 0050 09             .
                    fcc       "----------------------------------------------------------------------" * 0051 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 0097 0D             .
L0098               fcc       "Deleting mail..."  * 0098 44 65 6C 65 74 69 6E 67 20 6D 61 69 6C 2E 2E 2E Deleting mail...
                    fcb       $0D                 * 00A8 0D             .
L00A9               fcb       $0A                 * 00A9 0A             .
                    fcc       "One moment please..." * 00AA 4F 6E 65 20 6D 6F 6D 65 6E 74 20 70 6C 65 61 73 65 2E 2E 2E One moment please...
                    fcb       $0A                 * 00BE 0A             .
                    fcb       $0D                 * 00BF 0D             .
L00C0               fcc       "mail.scratch.inx"  * 00C0 6D 61 69 6C 2E 73 63 72 61 74 63 68 2E 69 6E 78 mail.scratch.inx
                    fcb       $0D                 * 00D0 0D             .
L00D1               fcc       "mail.scratch"      * 00D1 6D 61 69 6C 2E 73 63 72 61 74 63 68 mail.scratch
                    fcb       $0D                 * 00DD 0D             .
L00DE               fcb       $2E                 * 00DE 2E             .
                    fcb       $0D                 * 00DF 0D             .
                    fcc       "Rename"            * 00E0 52 65 6E 61 6D 65 Rename
                    fcb       $0D                 * 00E6 0D             .

start               os9       F$ID                * 00E7 10 3F 0C       .?.
                    sty       U0009,U             * 00EA 10 AF 49       ./I
                    ldy       #0                  * 00ED 10 8E 00 00    ....
                    os9       F$SUser             * 00F1 10 3F 1C       .?.
                    leax      >L00A9,PC           * 00F4 30 8D FF B1    0..1
                    ldy       #200                * 00F8 10 8E 00 C8    ...H
                    lda       #1                  * 00FC 86 01          ..
                    os9       I$WritLn            * 00FE 10 3F 8C       .?.
                    leax      >L001C,PC           * 0101 30 8D FF 17    0...
                    lda       #1                  * 0105 86 01          ..
                    os9       I$Open              * 0107 10 3F 84       .?.
                    lbcs      L024F               * 010A 10 25 01 41    .%.A
                    sta       U0000,U             * 010E A7 C4          'D
                    leax      >L0029,PC           * 0110 30 8D FF 15    0...
                    lda       #1                  * 0114 86 01          ..
                    os9       I$Open              * 0116 10 3F 84       .?.
                    lbcs      L024F               * 0119 10 25 01 32    .%.2
                    sta       U0001,U             * 011D A7 41          'A
                    leax      >L00C0,PC           * 011F 30 8D FF 9D    0...
                    lda       #2                  * 0123 86 02          ..
                    ldb       #11                 * 0125 C6 0B          F.
                    os9       I$Create            * 0127 10 3F 83       .?.
                    lbcs      L024F               * 012A 10 25 01 21    .%.!
                    sta       U0002,U             * 012E A7 42          'B
                    leax      >L00D1,PC           * 0130 30 8D FF 9D    0...
                    lda       #2                  * 0134 86 02          ..
                    ldb       #11                 * 0136 C6 0B          F.
                    os9       I$Create            * 0138 10 3F 83       .?.
                    sta       U0003,U             * 013B A7 43          'C
                    clr       U000B,U             * 013D 6F 4B          oK
                    clr       U000C,U             * 013F 6F 4C          oL
                    clr       U000D,U             * 0141 6F 4D          oM
                    clr       U000E,U             * 0143 6F 4E          oN
                    leax      >U00F7,U            * 0145 30 C9 00 F7    0I.w
                    ldy       #64                 * 0149 10 8E 00 40    ...@
                    lda       U0000,U             * 014D A6 C4          &D
                    os9       I$Read              * 014F 10 3F 89       .?.
                    lbcs      L024F               * 0152 10 25 00 F9    .%.y
                    lda       U0002,U             * 0156 A6 42          &B
                    os9       I$Write             * 0158 10 3F 8A       .?.
L015B               leax      >U0187,U            * 015B 30 C9 01 87    0I..
                    ldy       #64                 * 015F 10 8E 00 40    ...@
                    lda       U0000,U             * 0163 A6 C4          &D
                    os9       I$Read              * 0165 10 3F 89       .?.
                    bcs       L01E5               * 0168 25 7B          %{
                    cmpy      #64                 * 016A 10 8C 00 40    ...@
                    bne       L01E5               * 016E 26 75          &u
                    ldd       >U01C5,U            * 0170 EC C9 01 C5    lI.E
                    cmpd      U0009,U             * 0174 10 A3 49       .#I
                    beq       L01B5               * 0177 27 3C          '<
                    ldd       U000B,U             * 0179 EC 4B          lK
                    std       >U0187,U            * 017B ED C9 01 87    mI..
                    ldd       U000D,U             * 017F EC 4D          lM
                    std       >U0189,U            * 0181 ED C9 01 89    mI..
                    lda       U0002,U             * 0185 A6 42          &B
                    os9       I$Write             * 0187 10 3F 8A       .?.
L018A               lda       U0001,U             * 018A A6 41          &A
                    leax      >U0137,U            * 018C 30 C9 01 37    0I.7
                    ldy       #80                 * 0190 10 8E 00 50    ...P
                    os9       I$ReadLn            * 0194 10 3F 8B       .?.
                    bcs       L01E5               * 0197 25 4C          %L
                    lda       U0003,U             * 0199 A6 43          &C
                    os9       I$WritLn            * 019B 10 3F 8C       .?.
                    tfr       Y,D                 * 019E 1F 20          .
                    addd      U000D,U             * 01A0 E3 4D          cM
                    std       U000D,U             * 01A2 ED 4D          mM
                    bcc       L01AD               * 01A4 24 07          $.
                    ldd       U000B,U             * 01A6 EC 4B          lK
                    addd      #1                  * 01A8 C3 00 01       C..
                    std       U000B,U             * 01AB ED 4B          mK
L01AD               cmpy      #1                  * 01AD 10 8C 00 01    ....
                    bhi       L018A               * 01B1 22 D7          "W
                    bra       L015B               * 01B3 20 A6           &
L01B5               leax      >L0098,PC           * 01B5 30 8D FE DF    0.~_
                    ldy       #200                * 01B9 10 8E 00 C8    ...H
                    lda       #1                  * 01BD 86 01          ..
                    os9       I$WritLn            * 01BF 10 3F 8C       .?.
                    ldd       >U00F7,U            * 01C2 EC C9 00 F7    lI.w
                    subd      #1                  * 01C6 83 00 01       ...
                    std       >U00F7,U            * 01C9 ED C9 00 F7    mI.w
L01CD               lda       U0001,U             * 01CD A6 41          &A
                    leax      >U0137,U            * 01CF 30 C9 01 37    0I.7
                    ldy       #80                 * 01D3 10 8E 00 50    ...P
                    os9       I$ReadLn            * 01D7 10 3F 8B       .?.
                    bcs       L01E5               * 01DA 25 09          %.
                    cmpy      #1                  * 01DC 10 8C 00 01    ....
                    bhi       L01CD               * 01E0 22 EB          "k
                    lbra      L015B               * 01E2 16 FF 76       ..v
L01E5               ldd       U000B,U             * 01E5 EC 4B          lK
                    std       >U00F9,U            * 01E7 ED C9 00 F9    mI.y
                    ldd       U000D,U             * 01EB EC 4D          lM
                    std       >U00FB,U            * 01ED ED C9 00 FB    mI.{
                    pshs      U                   * 01F1 34 40          4@
                    lda       U0002,U             * 01F3 A6 42          &B
                    ldx       #0                  * 01F5 8E 00 00       ...
                    ldu       #0                  * 01F8 CE 00 00       N..
                    os9       I$Seek              * 01FB 10 3F 88       .?.
                    puls      U                   * 01FE 35 40          5@
                    lbcs      L024F               * 0200 10 25 00 4B    .%.K
                    leax      >U00F7,U            * 0204 30 C9 00 F7    0I.w
                    ldy       #64                 * 0208 10 8E 00 40    ...@
                    lda       U0002,U             * 020C A6 42          &B
                    os9       I$Write             * 020E 10 3F 8A       .?.
                    lda       U0000,U             * 0211 A6 C4          &D
                    os9       I$Close             * 0213 10 3F 8F       .?.
                    lbcs      L024F               * 0216 10 25 00 35    .%.5
                    lda       U0001,U             * 021A A6 41          &A
                    os9       I$Close             * 021C 10 3F 8F       .?.
                    lbcs      L024F               * 021F 10 25 00 2C    .%.,
                    lda       U0002,U             * 0223 A6 42          &B
                    os9       I$Close             * 0225 10 3F 8F       .?.
                    lbcs      L024F               * 0228 10 25 00 23    .%.#
                    lda       U0003,U             * 022C A6 43          &C
                    os9       I$Close             * 022E 10 3F 8F       .?.
                    lbcs      L024F               * 0231 10 25 00 1A    .%..
                    leax      >L001C,PC           * 0235 30 8D FD E3    0.}c
                    os9       I$Delete            * 0239 10 3F 87       .?.
                    lbcs      L024F               * 023C 10 25 00 0F    .%..
                    leax      >L0029,PC           * 0240 30 8D FD E5    0.}e
                    os9       I$Delete            * 0244 10 3F 87       .?.
                    lbcs      L024F               * 0247 10 25 00 04    .%..
                    lbsr      L025C               * 024B 17 00 0E       ...
                    clrb                          * 024E 5F             _
L024F               pshs      B                   * 024F 34 04          4.
                    ldy       U0009,U             * 0251 10 AE 49       ..I
                    os9       F$SUser             * 0254 10 3F 1C       .?.
                    puls      B                   * 0257 35 04          5.
                    os9       F$Exit              * 0259 10 3F 06       .?.
L025C               leax      >L00DE,PC           * 025C 30 8D FE 7E    0.~~
                    lda       #131                * 0260 86 83          ..
                    os9       I$Open              * 0262 10 3F 84       .?.
                    lbcs      L024F               * 0265 10 25 FF E6    .%.f
                    sta       U0007,U             * 0269 A7 47          'G
                    clr       U0006,U             * 026B 6F 46          oF
L026D               pshs      U                   * 026D 34 40          4@
                    lda       U0006,U             * 026F A6 46          &F
                    inca                          * 0271 4C             L
                    sta       U0006,U             * 0272 A7 46          'F
                    ldb       #32                 * 0274 C6 20          F
                    mul                           * 0276 3D             =
                    tfr       D,X                 * 0277 1F 01          ..
                    lda       U0007,U             * 0279 A6 47          &G
                    ldu       #0                  * 027B CE 00 00       N..
                    exg       X,U                 * 027E 1E 13          ..
                    os9       I$Seek              * 0280 10 3F 88       .?.
                    puls      U                   * 0283 35 40          5@
                    leax      U000F,U             * 0285 30 4F          0O
                    ldy       #32                 * 0287 10 8E 00 20    ...
                    lda       U0007,U             * 028B A6 47          &G
                    os9       I$Read              * 028D 10 3F 89       .?.
                    bcs       L02B4               * 0290 25 22          %"
                    leay      >L00C0,PC           * 0292 31 8D FE 2A    1.~*
                    leax      U000F,U             * 0296 30 4F          0O
L0298               lda       ,X+                 * 0298 A6 80          &.
                    bmi       L02C0               * 029A 2B 24          +$
                    cmpa      ,Y+                 * 029C A1 A0          !
                    bne       L02A2               * 029E 26 02          &.
                    bra       L0298               * 02A0 20 F6           v
L02A2               leax      U000F,U             * 02A2 30 4F          0O
                    leay      >L00D1,PC           * 02A4 31 8D FE 29    1.~)
L02A8               lda       ,X+                 * 02A8 A6 80          &.
                    bmi       L02D4               * 02AA 2B 28          +(
                    cmpa      ,Y+                 * 02AC A1 A0          !
                    bne       L02B2               * 02AE 26 02          &.
                    bra       L02A8               * 02B0 20 F6           v
L02B2               bra       L026D               * 02B2 20 B9           9
L02B4               cmpb      #211                * 02B4 C1 D3          AS
                    lbne      L024F               * 02B6 10 26 FF 95    .&..
                    lda       U0007,U             * 02BA A6 47          &G
                    os9       I$Close             * 02BC 10 3F 8F       .?.
                    rts                           * 02BF 39             9
L02C0               anda      #127                * 02C0 84 7F          ..
                    cmpa      ,Y+                 * 02C2 A1 A0          !
                    bne       L02A2               * 02C4 26 DC          &\
                    lda       ,Y+                 * 02C6 A6 A0          &
                    cmpa      #13                 * 02C8 81 0D          ..
                    bne       L02A2               * 02CA 26 D6          &V
                    leax      U000F,U             * 02CC 30 4F          0O
                    leay      >L001C,PC           * 02CE 31 8D FD 4A    1.}J
                    bra       L02E6               * 02D2 20 12           .
L02D4               anda      #127                * 02D4 84 7F          ..
                    cmpa      ,Y+                 * 02D6 A1 A0          !
                    bne       L02B2               * 02D8 26 D8          &X
                    lda       #13                 * 02DA 86 0D          ..
                    cmpa      ,Y+                 * 02DC A1 A0          !
                    bne       L02B2               * 02DE 26 D2          &R
                    leax      U000F,U             * 02E0 30 4F          0O
                    leay      >L0029,PC           * 02E2 31 8D FD 43    1.}C
L02E6               lda       ,Y+                 * 02E6 A6 A0          &
                    cmpa      #13                 * 02E8 81 0D          ..
                    beq       L02F0               * 02EA 27 04          '.
                    sta       ,X+                 * 02EC A7 80          '.
                    bra       L02E6               * 02EE 20 F6           v
L02F0               lda       ,-X                 * 02F0 A6 82          &.
                    ora       #128                * 02F2 8A 80          ..
                    sta       0,X                 * 02F4 A7 84          '.
                    lda       U0006,U             * 02F6 A6 46          &F
                    ldb       #32                 * 02F8 C6 20          F
                    mul                           * 02FA 3D             =
                    tfr       D,X                 * 02FB 1F 01          ..
                    lda       U0007,U             * 02FD A6 47          &G
                    ldb       #5                  * 02FF C6 05          F.
                    pshs      U                   * 0301 34 40          4@
                    ldu       #0                  * 0303 CE 00 00       N..
                    exg       X,U                 * 0306 1E 13          ..
                    os9       I$Seek              * 0308 10 3F 88       .?.
                    lbcs      L024F               * 030B 10 25 FF 40    .%.@
                    puls      U                   * 030F 35 40          5@
                    leax      U000F,U             * 0311 30 4F          0O
                    ldy       #32                 * 0313 10 8E 00 20    ...
                    lda       U0007,U             * 0317 A6 47          &G
                    os9       I$Write             * 0319 10 3F 8A       .?.
                    lbra      L026D               * 031C 16 FF 4E       ..N

                    emod
eom                 equ       *
                    end
