                    nam       BBS.post
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
U0007               rmb       1
U0008               rmb       2
U000A               rmb       1
U000B               rmb       1
U000C               rmb       1
U000D               rmb       1
U000E               rmb       2
U0010               rmb       2
U0012               rmb       2
U0014               rmb       1
U0015               rmb       1
U0016               rmb       2
U0018               rmb       2
U001A               rmb       200
U00E2               rmb       1
U00E3               rmb       5
U00E8               rmb       1
U00E9               rmb       2
U00EB               rmb       2
U00ED               rmb       60
U0129               rmb       2
U012B               rmb       2
U012D               rmb       20
U0141               rmb       30
U015F               rmb       6
U0165               rmb       2
U0167               rmb       2
U0169               rmb       2
U016B               rmb       2
U016D               rmb       6
U0173               rmb       2
U0175               rmb       2
U0177               rmb       2
U0179               rmb       16
U0189               rmb       200
U0251               rmb       8000
U2191               rmb       80
U21E1               rmb       1
U21E2               rmb       231
size                equ       .

name                fcs       /BBS.post/          * 000D 42 42 53 2E 70 6F 73 F4 BBS.post
                    fcc       "Copyright (C) 1988By Keith AlphonsoLicenced to Alpha Software TechnologiesAll rights reserved" * 0015 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 4C 69 63 65 6E 63 65 64
                    fcb       $EC                 * 0072 EC             l
                    fcb       $E6                 * 0073 E6             f
                    fcb       $EA                 * 0074 EA             j
                    fcb       $F5                 * 0075 F5             u
                    fcb       $E9                 * 0076 E9             i
                    fcb       $A0                 * 0077 A0
                    fcb       $E2                 * 0078 E2             b
                    fcb       $ED                 * 0079 ED             m
                    fcb       $F1                 * 007A F1             q
                    fcb       $E9                 * 007B E9             i
                    fcb       $F0                 * 007C F0             p
                    fcb       $EF                 * 007D EF             o
                    fcb       $F4                 * 007E F4             t
                    fcb       $F0                 * 007F F0             p
L0080               fcc       "BBS.msg.inx"       * 0080 42 42 53 2E 6D 73 67 2E 69 6E 78 BBS.msg.inx
                    fcb       $0D                 * 008B 0D             .
L008C               fcc       "BBS.msg"           * 008C 42 42 53 2E 6D 73 67 BBS.msg
                    fcb       $0D                 * 0093 0D             .
L0094               fcb       $0A                 * 0094 0A             .
                    fcc       "Enter subject of message" * 0095 45 6E 74 65 72 20 73 75 62 6A 65 63 74 20 6F 66 20 6D 65 73 73 61 67 65 Enter subject of message
                    fcb       $0D                 * 00AD 0D             .
                    fcb       $0A                 * 00AE 0A             .
                    fcc       ">"                 * 00AF 3E             >
L00B0               fcc       "Address message to (BLANK for ALL):" * 00B0 41 64 64 72 65 73 73 20 6D 65 73 73 61 67 65 20 74 6F 20 28 42 4C 41 4E 4B 20 66 6F 72 20 41 4C 4C 29 3A Address message to (BLANK for ALL):
                    fcb       $0D                 * 00D3 0D             .
                    fcb       $0A                 * 00D4 0A             .
                    fcb       $3E                 * 00D5 3E             >
L00D6               fcb       $00                 * 00D6 00             .
                    fcb       $1C                 * 00D7 1C             .
L00D8               fcb       $0A                 * 00D8 0A             .
                    fcb       $0A                 * 00D9 0A             .
                    fcc       "    Please enter message now            (Blank line ends)" * 00DA 20 20 20 20 50 6C 65 61 73 65 20 65 6E 74 65 72 20 6D 65 73 73 61 67 65 20 6E 6F 77 20 20 20 20 20 20 20 20 20 20 20 20 28 42 6C 61 6E 6B 20 6C 69 6E 65 20 65 6E 64
                    fcb       $0D                 * 0113 0D             .
L0114               fcc       "----------------------------------------------------------------" * 0114 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 0154 0D             .
L0155               fcc       "/dd/bbs/BBS.alias" * 0155 2F 64 64 2F 62 62 73 2F 42 42 53 2E 61 6C 69 61 73 /dd/bbs/BBS.alias
                    fcb       $0D                 * 0166 0D             .
L0167               fcb       $0A                 * 0167 0A             .
                    fcc       "[A]bort [D]one [E]dit [C]ontinue or [L]ist" * 0168 5B 41 5D 62 6F 72 74 20 5B 44 5D 6F 6E 65 20 5B 45 5D 64 69 74 20 5B 43 5D 6F 6E 74 69 6E 75 65 20 6F 72 20 5B 4C 5D 69 73 74 [A]bort [D]one [E]dit [C]ontinue or [L]ist
                    fcb       $0D                 * 0192 0D             .
L0193               fcc       "Enter line #"      * 0193 45 6E 74 65 72 20 6C 69 6E 65 20 23 Enter line #
                    fcb       $0D                 * 019F 0D             .
L01A0               fcb       $3E                 * 01A0 3E             >
L01A1               fcb       $0A                 * 01A1 0A             .
                    fcb       $0D                 * 01A2 0D             .
L01A3               fcb       $08                 * 01A3 08             .
                    fcb       $20                 * 01A4 20
                    fcb       $08                 * 01A5 08             .
L01A6               fcc       "/dd/bbs/BBS.userstats" * 01A6 2F 64 64 2F 62 62 73 2F 42 42 53 2E 75 73 65 72 73 74 61 74 73 /dd/bbs/BBS.userstats
                    fcb       $0D                 * 01BB 0D             .
L01BC               fcc       "User name not found!" * 01BC 55 73 65 72 20 6E 61 6D 65 20 6E 6F 74 20 66 6F 75 6E 64 21 User name not found!
                    fcb       $0D                 * 01D0 0D             .
start               clr       >U00E8,U            * 01D1 6F C9 00 E8    oI.h
                    clr       >U00E2,U            * 01D5 6F C9 00 E2    oI.b
                    clr       U0006,U             * 01D9 6F 46          oF
                    os9       F$ID                * 01DB 10 3F 0C       .?.
                    lbcs      L066A               * 01DE 10 25 04 88    .%..
                    sty       U0008,U             * 01E2 10 AF 48       ./H
                    ldy       #0                  * 01E5 10 8E 00 00    ....
                    os9       F$SUser             * 01E9 10 3F 1C       .?.
                    lbcs      L066A               * 01EC 10 25 04 7A    .%.z
                    leax      >L0080,PC           * 01F0 30 8D FE 8C    0.~.
                    lda       #1                  * 01F4 86 01          ..
                    os9       I$Open              * 01F6 10 3F 84       .?.
                    lbcs      L066A               * 01F9 10 25 04 6D    .%.m
                    sta       U0000,U             * 01FD A7 C4          'D
                    leax      >U00E9,U            * 01FF 30 C9 00 E9    0I.i
                    ldy       #64                 * 0203 10 8E 00 40    ...@
                    lda       U0000,U             * 0207 A6 C4          &D
                    os9       I$Read              * 0209 10 3F 89       .?.
                    lbcs      L066A               * 020C 10 25 04 5A    .%.Z
                    lda       U0000,U             * 0210 A6 C4          &D
                    os9       I$Close             * 0212 10 3F 8F       .?.
                    leax      >L0080,PC           * 0215 30 8D FE 67    0.~g
                    lda       #3                  * 0219 86 03          ..
                    os9       I$Open              * 021B 10 3F 84       .?.
                    lbcs      L066A               * 021E 10 25 04 48    .%.H
                    sta       U0000,U             * 0222 A7 C4          'D
                    lda       #6                  * 0224 86 06          ..
                    sta       U0003,U             * 0226 A7 43          'C
                    ldd       >U00E9,U            * 0228 EC C9 00 E9    lI.i
                    addd      #1                  * 022C C3 00 01       C..
                    std       >U00E9,U            * 022F ED C9 00 E9    mI.i
                    clr       U000C,U             * 0233 6F 4C          oL
                    clr       U000D,U             * 0235 6F 4D          oM
L0237               aslb                          * 0237 58             X
                    rola                          * 0238 49             I
                    rol       U000D,U             * 0239 69 4D          iM
                    dec       U0003,U             * 023B 6A 43          jC
                    bne       L0237               * 023D 26 F8          &x
                    std       U000E,U             * 023F ED 4E          mN
                    lda       U0000,U             * 0241 A6 C4          &D
                    ldx       U000C,U             * 0243 AE 4C          .L
                    pshs      U                   * 0245 34 40          4@
                    ldu       U000E,U             * 0247 EE 4E          nN
                    os9       I$Seek              * 0249 10 3F 88       .?.
                    lbcs      L066A               * 024C 10 25 04 1A    .%..
                    puls      U                   * 0250 35 40          5@
                    leax      >U015F,U            * 0252 30 C9 01 5F    0I._
                    os9       F$Time              * 0256 10 3F 15       .?.
                    leax      >L0094,PC           * 0259 30 8D FE 37    0.~7
                    ldy       >L00D6,PC           * 025D 10 AE 8D FE 74 ...~t
                    lda       #1                  * 0262 86 01          ..
                    os9       I$Write             * 0264 10 3F 8A       .?.
                    lbcs      L066A               * 0267 10 25 03 FF    .%..
                    clra                          * 026B 4F             O
                    leax      >U0141,U            * 026C 30 C9 01 41    0I.A
                    ldy       #30                 * 0270 10 8E 00 1E    ....
                    os9       I$ReadLn            * 0274 10 3F 8B       .?.
                    leax      >L0155,PC           * 0277 30 8D FE DA    0.~Z
                    lda       #1                  * 027B 86 01          ..
                    os9       I$Open              * 027D 10 3F 84       .?.
                    lbcs      L066A               * 0280 10 25 03 E6    .%.f
                    sta       U0002,U             * 0284 A7 42          'B
L0286               leax      >L00B0,PC           * 0286 30 8D FE 26    0.~&
                    ldy       #38                 * 028A 10 8E 00 26    ...&
                    lda       #1                  * 028E 86 01          ..
                    os9       I$Write             * 0290 10 3F 8A       .?.
                    leax      >U0189,U            * 0293 30 C9 01 89    0I..
                    ldy       #200                * 0297 10 8E 00 C8    ...H
                    clra                          * 029B 4F             O
                    os9       I$ReadLn            * 029C 10 3F 8B       .?.
                    cmpy      #1                  * 029F 10 8C 00 01    ....
                    ble       L030D               * 02A3 2F 68          /h
L02A5               lda       ,X+                 * 02A5 A6 80          &.
                    anda      #223                * 02A7 84 DF          ._
                    sta       -$01,X              * 02A9 A7 1F          '.
                    cmpa      #13                 * 02AB 81 0D          ..
                    bne       L02A5               * 02AD 26 F6          &v
L02AF               leax      <U001A,U            * 02AF 30 C8 1A       0H.
                    ldy       #200                * 02B2 10 8E 00 C8    ...H
                    lda       U0002,U             * 02B6 A6 42          &B
                    os9       I$ReadLn            * 02B8 10 3F 8B       .?.
                    bcs       L02F0               * 02BB 25 33          %3
                    leay      >U0189,U            * 02BD 31 C9 01 89    1I..
                    leax      <U001A,U            * 02C1 30 C8 1A       0H.
L02C4               lda       ,X+                 * 02C4 A6 80          &.
                    cmpa      #44                 * 02C6 81 2C          .,
                    beq       L02D2               * 02C8 27 08          '.
                    anda      #223                * 02CA 84 DF          ._
                    cmpa      ,Y+                 * 02CC A1 A0          !
                    bne       L02AF               * 02CE 26 DF          &_
                    bra       L02C4               * 02D0 20 F2           r
L02D2               lda       ,Y+                 * 02D2 A6 A0          &
                    cmpa      #13                 * 02D4 81 0D          ..
                    bne       L02AF               * 02D6 26 D7          &W
                    lbsr      L07FD               * 02D8 17 05 22       .."
                    std       >U0167,U            * 02DB ED C9 01 67    mI.g
                    lda       U0002,U             * 02DF A6 42          &B
                    pshs      U                   * 02E1 34 40          4@
                    ldu       #0                  * 02E3 CE 00 00       N..
                    ldx       #0                  * 02E6 8E 00 00       ...
                    os9       I$Seek              * 02E9 10 3F 88       .?.
                    puls      U                   * 02EC 35 40          5@
                    bra       L0314               * 02EE 20 24           $
L02F0               leax      >L01BC,PC           * 02F0 30 8D FE C8    0.~H
                    ldy       #200                * 02F4 10 8E 00 C8    ...H
                    lda       #1                  * 02F8 86 01          ..
                    os9       I$WritLn            * 02FA 10 3F 8C       .?.
                    lda       U0002,U             * 02FD A6 42          &B
                    pshs      U                   * 02FF 34 40          4@
                    ldu       #0                  * 0301 CE 00 00       N..
                    ldx       #0                  * 0304 8E 00 00       ...
                    os9       I$Seek              * 0307 10 3F 88       .?.
                    lbra      L0286               * 030A 16 FF 79       ..y
L030D               ldd       #-1                 * 030D CC FF FF       L..
                    std       >U0167,U            * 0310 ED C9 01 67    mI.g
L0314               leax      >L00D8,PC           * 0314 30 8D FD C0    0.}@
                    ldy       #200                * 0318 10 8E 00 C8    ...H
                    lda       #1                  * 031C 86 01          ..
                    os9       I$WritLn            * 031E 10 3F 8C       .?.
                    lbcs      L066A               * 0321 10 25 03 45    .%.E
                    leax      >L0114,PC           * 0325 30 8D FD EB    0.}k
                    ldy       #80                 * 0329 10 8E 00 50    ...P
                    os9       I$WritLn            * 032D 10 3F 8C       .?.
                    lbcs      L066A               * 0330 10 25 03 36    .%.6
                    ldd       #0                  * 0334 CC 00 00       L..
                    std       U000A,U             * 0337 ED 4A          mJ
L0339               ldd       U000A,U             * 0339 EC 4A          lJ
                    addd      #1                  * 033B C3 00 01       C..
                    std       U000A,U             * 033E ED 4A          mJ
                    cmpd      #99                 * 0340 10 83 00 63    ...c
                    bge       L0351               * 0344 2C 0B          ,.
                    lbsr      L0461               * 0346 17 01 18       ...
                    cmpy      #1                  * 0349 10 8C 00 01    ....
                    bls       L0351               * 034D 23 02          #.
                    bra       L0339               * 034F 20 E8           h
L0351               leax      >L0167,PC           * 0351 30 8D FE 12    0.~.
                    ldy       #200                * 0355 10 8E 00 C8    ...H
                    lda       #1                  * 0359 86 01          ..
                    os9       I$WritLn            * 035B 10 3F 8C       .?.
                    leax      >L01A0,PC           * 035E 30 8D FE 3E    0.~>
                    ldy       #1                  * 0362 10 8E 00 01    ....
                    os9       I$Write             * 0366 10 3F 8A       .?.
                    leax      U0005,U             * 0369 30 45          0E
                    clra                          * 036B 4F             O
                    ldy       #1                  * 036C 10 8E 00 01    ....
                    os9       I$Read              * 0370 10 3F 89       .?.
                    leax      >L01A1,PC           * 0373 30 8D FE 2A    0.~*
                    ldy       #1                  * 0377 10 8E 00 01    ....
                    lda       #1                  * 037B 86 01          ..
                    os9       I$WritLn            * 037D 10 3F 8C       .?.
                    lda       U0005,U             * 0380 A6 45          &E
                    anda      #223                * 0382 84 DF          ._
                    cmpa      #65                 * 0384 81 41          .A
                    lbeq      L0663               * 0386 10 27 02 D9    .'.Y
                    cmpa      #68                 * 038A 81 44          .D
                    lbeq      L04B6               * 038C 10 27 01 26    .'.&
                    cmpa      #69                 * 0390 81 45          .E
                    beq       L03A9               * 0392 27 15          '.
                    cmpa      #67                 * 0394 81 43          .C
                    beq       L03A0               * 0396 27 08          '.
                    cmpa      #76                 * 0398 81 4C          .L
                    lbeq      L0420               * 039A 10 27 00 82    .'..
                    bra       L0351               * 039E 20 B1           1
L03A0               ldd       U000A,U             * 03A0 EC 4A          lJ
                    subd      #1                  * 03A2 83 00 01       ...
                    std       U000A,U             * 03A5 ED 4A          mJ
                    bra       L0339               * 03A7 20 90           .
L03A9               leax      >L0193,PC           * 03A9 30 8D FD E6    0.}f
                    ldy       #200                * 03AD 10 8E 00 C8    ...H
                    lda       #1                  * 03B1 86 01          ..
                    os9       I$WritLn            * 03B3 10 3F 8C       .?.
                    leax      >L01A0,PC           * 03B6 30 8D FD E6    0.}f
                    ldy       #1                  * 03BA 10 8E 00 01    ....
                    os9       I$Write             * 03BE 10 3F 8A       .?.
                    clra                          * 03C1 4F             O
                    leax      >U00E3,U            * 03C2 30 C9 00 E3    0I.c
                    ldy       #3                  * 03C6 10 8E 00 03    ....
                    os9       I$ReadLn            * 03CA 10 3F 8B       .?.
                    lbsr      L07FD               * 03CD 17 04 2D       ..-
                    cmpd      U000A,U             * 03D0 10 A3 4A       .#J
                    lbcc      L0351               * 03D3 10 24 FF 7A    .$.z
                    std       <U0018,U            * 03D7 ED C8 18       mH.
                    leax      >U00E3,U            * 03DA 30 C9 00 E3    0I.c
                    lbsr      L086D               * 03DE 17 04 8C       ...
                    leax      >U00E3,U            * 03E1 30 C9 00 E3    0I.c
                    lda       #58                 * 03E5 86 3A          .:
                    sta       $02,X               * 03E7 A7 02          '.
                    ldy       #3                  * 03E9 10 8E 00 03    ....
                    lda       #1                  * 03ED 86 01          ..
                    os9       I$Write             * 03EF 10 3F 8A       .?.
                    ldd       <U0018,U            * 03F2 EC C8 18       lH.
                    leax      >U0251,U            * 03F5 30 C9 02 51    0I.Q
                    lda       #80                 * 03F9 86 50          .P
                    mul                           * 03FB 3D             =
                    leax      D,X                 * 03FC 30 8B          0.
                    ldy       #80                 * 03FE 10 8E 00 50    ...P
                    lda       #1                  * 0402 86 01          ..
                    os9       I$WritLn            * 0404 10 3F 8C       .?.
                    tfr       Y,D                 * 0407 1F 20          .
                    stb       U0006,U             * 0409 E7 46          gF
                    dec       U0006,U             * 040B 6A 46          jF
                    leay      >U2191,U            * 040D 31 C9 21 91    1I!.
L0411               lda       ,X+                 * 0411 A6 80          &.
                    sta       ,Y+                 * 0413 A7 A0          '
                    decb                          * 0415 5A             Z
                    bne       L0411               * 0416 26 F9          &y
                    ldd       <U0018,U            * 0418 EC C8 18       lH.
                    bsr       L0461               * 041B 8D 44          .D
                    lbra      L0351               * 041D 16 FF 31       ..1
L0420               ldd       #0                  * 0420 CC 00 00       L..
                    std       U000A,U             * 0423 ED 4A          mJ
L0425               ldd       U000A,U             * 0425 EC 4A          lJ
                    addd      #1                  * 0427 C3 00 01       C..
                    std       U000A,U             * 042A ED 4A          mJ
                    leax      >U00E3,U            * 042C 30 C9 00 E3    0I.c
                    lbsr      L086D               * 0430 17 04 3A       ..:
                    leax      >U00E3,U            * 0433 30 C9 00 E3    0I.c
                    lda       #58                 * 0437 86 3A          .:
                    sta       $02,X               * 0439 A7 02          '.
                    lda       #1                  * 043B 86 01          ..
                    ldy       #3                  * 043D 10 8E 00 03    ....
                    os9       I$Write             * 0441 10 3F 8A       .?.
                    leax      >U0251,U            * 0444 30 C9 02 51    0I.Q
                    ldd       U000A,U             * 0448 EC 4A          lJ
                    lda       #80                 * 044A 86 50          .P
                    mul                           * 044C 3D             =
                    leax      D,X                 * 044D 30 8B          0.
                    ldy       #80                 * 044F 10 8E 00 50    ...P
                    lda       #1                  * 0453 86 01          ..
                    os9       I$WritLn            * 0455 10 3F 8C       .?.
                    cmpy      #1                  * 0458 10 8C 00 01    ....
                    bhi       L0425               * 045C 22 C7          "G
                    lbra      L0351               * 045E 16 FE F0       .~p
L0461               leax      >U00E3,U            * 0461 30 C9 00 E3    0I.c
                    pshs      D                   * 0465 34 06          4.
                    lbsr      L086D               * 0467 17 04 03       ...
                    leax      >U00E3,U            * 046A 30 C9 00 E3    0I.c
                    lda       #58                 * 046E 86 3A          .:
                    sta       $02,X               * 0470 A7 02          '.
                    lda       #1                  * 0472 86 01          ..
                    ldy       #3                  * 0474 10 8E 00 03    ....
                    os9       I$Write             * 0478 10 3F 8A       .?.
                    lbcs      L066A               * 047B 10 25 01 EB    .%.k
                    leax      >U2191,U            * 047F 30 C9 21 91    0I!.
                    ldb       U0006,U             * 0483 E6 46          fF
                    clra                          * 0485 4F             O
                    tfr       D,Y                 * 0486 1F 02          ..
                    lda       #1                  * 0488 86 01          ..
                    os9       I$Write             * 048A 10 3F 8A       .?.
                    puls      D                   * 048D 35 06          5.
                    lda       #80                 * 048F 86 50          .P
                    mul                           * 0491 3D             =
                    leax      >U0251,U            * 0492 30 C9 02 51    0I.Q
                    leax      D,X                 * 0496 30 8B          0.
                    leay      >U2191,U            * 0498 31 C9 21 91    1I!.
                    ldb       #80                 * 049C C6 50          FP
                    lda       U0006,U             * 049E A6 46          &F
                    beq       L04AF               * 04A0 27 0D          '.
                    sta       <U0014,U            * 04A2 A7 C8 14       'H.
L04A5               lda       ,Y+                 * 04A5 A6 A0          &
                    sta       ,X+                 * 04A7 A7 80          '.
                    decb                          * 04A9 5A             Z
                    dec       <U0014,U            * 04AA 6A C8 14       jH.
                    bne       L04A5               * 04AD 26 F6          &v
L04AF               clra                          * 04AF 4F             O
                    tfr       D,Y                 * 04B0 1F 02          ..
                    lbsr      L066D               * 04B2 17 01 B8       ..8
                    rts                           * 04B5 39             9
L04B6               leax      <U001A,U            * 04B6 30 C8 1A       0H.
                    ldy       #200                * 04B9 10 8E 00 C8    ...H
                    lda       U0002,U             * 04BD A6 42          &B
                    os9       I$ReadLn            * 04BF 10 3F 8B       .?.
                    lbcs      L066A               * 04C2 10 25 01 A4    .%.$
L04C6               lda       ,X+                 * 04C6 A6 80          &.
                    cmpa      #44                 * 04C8 81 2C          .,
                    bne       L04C6               * 04CA 26 FA          &z
                    lbsr      L07FD               * 04CC 17 03 2E       ...
                    cmpd      U0008,U             * 04CF 10 A3 48       .#H
                    bne       L04B6               * 04D2 26 E2          &b
                    leax      <U001A,U            * 04D4 30 C8 1A       0H.
                    leay      >U012D,U            * 04D7 31 C9 01 2D    1I.-
L04DB               lda       ,X+                 * 04DB A6 80          &.
                    cmpa      #44                 * 04DD 81 2C          .,
                    beq       L04E5               * 04DF 27 04          '.
                    sta       ,Y+                 * 04E1 A7 A0          '
                    bra       L04DB               * 04E3 20 F6           v
L04E5               lda       #13                 * 04E5 86 0D          ..
                    sta       0,Y                 * 04E7 A7 A4          '$
                    ldd       >U00EB,U            * 04E9 EC C9 00 EB    lI.k
                    std       >U0129,U            * 04ED ED C9 01 29    mI.)
                    ldd       >U00ED,U            * 04F1 EC C9 00 ED    lI.m
                    std       >U012B,U            * 04F5 ED C9 01 2B    mI.+
                    ldd       U0008,U             * 04F9 EC 48          lH
                    std       >U0165,U            * 04FB ED C9 01 65    mI.e
                    leax      >U0129,U            * 04FF 30 C9 01 29    0I.)
                    lda       U0000,U             * 0503 A6 C4          &D
                    ldy       #64                 * 0505 10 8E 00 40    ...@
                    os9       I$Write             * 0509 10 3F 8A       .?.
                    lbcs      L066A               * 050C 10 25 01 5A    .%.Z
                    leax      >L008C,PC           * 0510 30 8D FB 78    0.{x
                    lda       #3                  * 0514 86 03          ..
                    os9       I$Open              * 0516 10 3F 84       .?.
                    lbcs      L066A               * 0519 10 25 01 4D    .%.M
                    sta       U0001,U             * 051D A7 41          'A
                    pshs      U                   * 051F 34 40          4@
                    ldx       >U00EB,U            * 0521 AE C9 00 EB    .I.k
                    lda       U0001,U             * 0525 A6 41          &A
                    ldu       >U00ED,U            * 0527 EE C9 00 ED    nI.m
                    os9       I$Seek              * 052B 10 3F 88       .?.
                    lbcs      L066A               * 052E 10 25 01 38    .%.8
                    puls      U                   * 0532 35 40          5@
                    lda       #0                  * 0534 86 00          ..
                    sta       <U0010,U            * 0536 A7 C8 10       'H.
                    ldd       #1                  * 0539 CC 00 01       L..
                    std       <U0012,U            * 053C ED C8 12       mH.
L053F               lda       <U0010,U            * 053F A6 C8 10       &H.
                    inca                          * 0542 4C             L
                    sta       <U0010,U            * 0543 A7 C8 10       'H.
                    cmpa      U000B,U             * 0546 A1 4B          !K
                    bhi       L0570               * 0548 22 26          "&
                    ldb       #80                 * 054A C6 50          FP
                    mul                           * 054C 3D             =
                    leax      >U0251,U            * 054D 30 C9 02 51    0I.Q
                    leax      D,X                 * 0551 30 8B          0.
                    ldy       #80                 * 0553 10 8E 00 50    ...P
                    lda       U0001,U             * 0557 A6 41          &A
                    os9       I$WritLn            * 0559 10 3F 8C       .?.
                    lbcs      L066A               * 055C 10 25 01 0A    .%..
                    cmpy      #1                  * 0560 10 8C 00 01    ....
                    bls       L0570               * 0564 23 0A          #.
                    tfr       Y,D                 * 0566 1F 20          .
                    addd      <U0012,U            * 0568 E3 C8 12       cH.
                    std       <U0012,U            * 056B ED C8 12       mH.
                    bra       L053F               * 056E 20 CF           O
L0570               ldd       >U00ED,U            * 0570 EC C9 00 ED    lI.m
                    addd      <U0012,U            * 0574 E3 C8 12       cH.
                    std       >U00ED,U            * 0577 ED C9 00 ED    mI.m
                    bcc       L0588               * 057B 24 0B          $.
                    ldd       >U00EB,U            * 057D EC C9 00 EB    lI.k
                    addd      #1                  * 0581 C3 00 01       C..
                    std       >U00EB,U            * 0584 ED C9 00 EB    mI.k
L0588               pshs      U                   * 0588 34 40          4@
                    lda       U0000,U             * 058A A6 C4          &D
                    ldx       #0                  * 058C 8E 00 00       ...
                    ldu       #0                  * 058F CE 00 00       N..
                    os9       I$Seek              * 0592 10 3F 88       .?.
                    lbcs      L066A               * 0595 10 25 00 D1    .%.Q
                    puls      U                   * 0599 35 40          5@
                    leax      >U00E9,U            * 059B 30 C9 00 E9    0I.i
                    ldy       #64                 * 059F 10 8E 00 40    ...@
                    lda       U0000,U             * 05A3 A6 C4          &D
                    os9       I$Write             * 05A5 10 3F 8A       .?.
                    lbcs      L066A               * 05A8 10 25 00 BE    .%.>
                    leax      >L01A6,PC           * 05AC 30 8D FB F6    0.{v
                    lda       #3                  * 05B0 86 03          ..
                    os9       I$Open              * 05B2 10 3F 84       .?.
                    bcc       L05C0               * 05B5 24 09          $.
                    ldb       #27                 * 05B7 C6 1B          F.
                    os9       I$Create            * 05B9 10 3F 83       .?.
                    lbcs      L066A               * 05BC 10 25 00 AA    .%.*
L05C0               sta       U0007,U             * 05C0 A7 47          'G
L05C2               leax      >U0169,U            * 05C2 30 C9 01 69    0I.i
                    ldy       #32                 * 05C6 10 8E 00 20    ...
                    lda       U0007,U             * 05CA A6 47          &G
                    os9       I$Read              * 05CC 10 3F 89       .?.
                    bcs       L05DC               * 05CF 25 0B          %.
                    ldd       >U0169,U            * 05D1 EC C9 01 69    lI.i
                    cmpd      U0008,U             * 05D5 10 A3 48       .#H
                    bne       L05C2               * 05D8 26 E8          &h
                    bra       L05E5               * 05DA 20 09           .
L05DC               cmpb      #211                * 05DC C1 D3          AS
                    lbne      L066A               * 05DE 10 26 00 88    .&..
                    lbra      L0623               * 05E2 16 00 3E       ..>
L05E5               ldd       >U0173,U            * 05E5 EC C9 01 73    lI.s
                    addd      #1                  * 05E9 C3 00 01       C..
                    std       >U0173,U            * 05EC ED C9 01 73    mI.s
                    lda       U0007,U             * 05F0 A6 47          &G
                    ldb       #5                  * 05F2 C6 05          F.
                    pshs      U                   * 05F4 34 40          4@
                    os9       I$GetStt            * 05F6 10 3F 8D       .?.
                    tfr       U,D                 * 05F9 1F 30          .0
                    subd      #32                 * 05FB 83 00 20       ..
                    bge       L0602               * 05FE 2C 02          ,.
                    leax      -$01,X              * 0600 30 1F          0.
L0602               ldu       0,S                 * 0602 EE E4          nd
                    tfr       D,Y                 * 0604 1F 02          ..
                    lda       U0007,U             * 0606 A6 47          &G
                    tfr       Y,U                 * 0608 1F 23          .#
                    os9       I$Seek              * 060A 10 3F 88       .?.
                    lbcs      L066A               * 060D 10 25 00 59    .%.Y
                    puls      U                   * 0611 35 40          5@
                    leax      >U0169,U            * 0613 30 C9 01 69    0I.i
                    ldy       #32                 * 0617 10 8E 00 20    ...
                    lda       U0007,U             * 061B A6 47          &G
                    os9       I$Write             * 061D 10 3F 8A       .?.
                    lbra      L0663               * 0620 16 00 40       ..@
L0623               leax      >U0169,U            * 0623 30 C9 01 69    0I.i
                    ldd       #1                  * 0627 CC 00 01       L..
                    std       >U016B,U            * 062A ED C9 01 6B    mI.k
                    ldd       #0                  * 062E CC 00 00       L..
                    std       >U0173,U            * 0631 ED C9 01 73    mI.s
                    std       >U0175,U            * 0635 ED C9 01 75    mI.u
                    std       >U0179,U            * 0639 ED C9 01 79    mI.y
                    std       >U0177,U            * 063D ED C9 01 77    mI.w
                    ldd       U0008,U             * 0641 EC 48          lH
                    std       >U0169,U            * 0643 ED C9 01 69    mI.i
                    leax      >U016D,U            * 0647 30 C9 01 6D    0I.m
                    os9       F$Time              * 064B 10 3F 15       .?.
                    lbcs      L066A               * 064E 10 25 00 18    .%..
                    leax      >U0169,U            * 0652 30 C9 01 69    0I.i
                    ldy       #32                 * 0656 10 8E 00 20    ...
                    lda       U0007,U             * 065A A6 47          &G
                    os9       I$Write             * 065C 10 3F 8A       .?.
                    lbcs      L066A               * 065F 10 25 00 07    .%..
L0663               clrb                          * 0663 5F             _
                    ldy       U0008,U             * 0664 10 AE 48       ..H
                    os9       F$SUser             * 0667 10 3F 1C       .?.
L066A               os9       F$Exit              * 066A 10 3F 06       .?.
L066D               lbsr      L07C6               * 066D 17 01 56       ..V
                    ldb       U0006,U             * 0670 E6 46          fF
                    leay      B,Y                 * 0672 31 A5          1%
                    pshs      Y                   * 0674 34 20          4
                    negb                          * 0676 50             P
                    sex                           * 0677 1D             .
                    leay      D,Y                 * 0678 31 AB          1+
                    clr       U0006,U             * 067A 6F 46          oF
                    cmpy      #0                  * 067C 10 8C 00 00    ....
                    lbeq      L073C               * 0680 10 27 00 B8    .'.8
                    pshs      Y,X                 * 0684 34 30          40
                    lda       #13                 * 0686 86 0D          ..
L0688               sta       ,X+                 * 0688 A7 80          '.
                    leay      -$01,Y              * 068A 31 3F          1?
                    bne       L0688               * 068C 26 FA          &z
                    puls      Y,X                 * 068E 35 30          50
L0690               pshs      Y,X                 * 0690 34 30          40
                    leax      U0005,U             * 0692 30 45          0E
                    ldy       #1                  * 0694 10 8E 00 01    ....
                    clra                          * 0698 4F             O
                    os9       I$Read              * 0699 10 3F 89       .?.
                    bcs       L06C9               * 069C 25 2B          %+
                    lda       U0005,U             * 069E A6 45          &E
                    cmpa      #1                  * 06A0 81 01          ..
                    beq       L06CD               * 06A2 27 29          ')
                    cmpa      #8                  * 06A4 81 08          ..
                    beq       L06EF               * 06A6 27 47          'G
                    cmpa      #24                 * 06A8 81 18          ..
                    beq       L0713               * 06AA 27 67          'g
                    cmpa      #13                 * 06AC 81 0D          ..
                    lbeq      L073A               * 06AE 10 27 00 88    .'..
                    cmpa      #32                 * 06B2 81 20          .
                    bcs       L06C9               * 06B4 25 13          %.
                    lda       #1                  * 06B6 86 01          ..
                    os9       I$Write             * 06B8 10 3F 8A       .?.
                    puls      Y,X                 * 06BB 35 30          50
                    lda       U0005,U             * 06BD A6 45          &E
                    sta       ,X+                 * 06BF A7 80          '.
                    leay      -$01,Y              * 06C1 31 3F          1?
                    lbeq      L0763               * 06C3 10 27 00 9C    .'..
                    bra       L0690               * 06C7 20 C7           G
L06C9               puls      Y,X                 * 06C9 35 30          50
                    bra       L0690               * 06CB 20 C3           C
L06CD               puls      Y,X                 * 06CD 35 30          50
                    leay      -$01,Y              * 06CF 31 3F          1?
                    beq       L06EA               * 06D1 27 17          '.
                    lda       ,X+                 * 06D3 A6 80          &.
                    cmpa      #13                 * 06D5 81 0D          ..
                    beq       L06E8               * 06D7 27 0F          '.
                    pshs      Y,X                 * 06D9 34 30          40
                    leax      -$01,X              * 06DB 30 1F          0.
                    ldy       #1                  * 06DD 10 8E 00 01    ....
                    lda       #1                  * 06E1 86 01          ..
                    os9       I$Write             * 06E3 10 3F 8A       .?.
                    bra       L06CD               * 06E6 20 E5           e
L06E8               leax      -$01,X              * 06E8 30 1F          0.
L06EA               leay      $01,Y               * 06EA 31 21          1!
                    lbra      L0690               * 06EC 16 FF A1       ..!
L06EF               puls      Y,X                 * 06EF 35 30          50
                    leay      $01,Y               * 06F1 31 21          1!
                    cmpy      0,S                 * 06F3 10 AC E4       .,d
                    bhi       L070E               * 06F6 22 16          ".
                    pshs      Y,X                 * 06F8 34 30          40
                    leax      >L01A3,PC           * 06FA 30 8D FA A5    0.z%
                    ldy       #3                  * 06FE 10 8E 00 03    ....
                    lda       #1                  * 0702 86 01          ..
                    os9       I$Write             * 0704 10 3F 8A       .?.
                    puls      Y,X                 * 0707 35 30          50
                    leax      -$01,X              * 0709 30 1F          0.
                    lbra      L0690               * 070B 16 FF 82       ...
L070E               leay      -$01,Y              * 070E 31 3F          1?
                    lbra      L0690               * 0710 16 FF 7D       ..}
L0713               puls      Y,X                 * 0713 35 30          50
                    leay      $01,Y               * 0715 31 21          1!
                    cmpy      0,S                 * 0717 10 AC E4       .,d
                    bhi       L070E               * 071A 22 F2          "r
                    pshs      Y,X                 * 071C 34 30          40
                    leax      >L01A3,PC           * 071E 30 8D FA 81    0.z.
                    ldy       #3                  * 0722 10 8E 00 03    ....
                    lda       #1                  * 0726 86 01          ..
                    os9       I$Write             * 0728 10 3F 8A       .?.
                    puls      Y,X                 * 072B 35 30          50
                    leax      -$01,X              * 072D 30 1F          0.
                    cmpy      0,S                 * 072F 10 AC E4       .,d
                    lbhi      L0690               * 0732 10 22 FF 5A    .".Z
                    pshs      Y,X                 * 0736 34 30          40
                    bra       L0713               * 0738 20 D9           Y
L073A               puls      Y,X                 * 073A 35 30          50
L073C               lda       #13                 * 073C 86 0D          ..
                    sta       ,X+                 * 073E A7 80          '.
                    pshs      Y,X                 * 0740 34 30          40
                    leax      >L01A1,PC           * 0742 30 8D FA 5B    0.z[
                    ldy       #1                  * 0746 10 8E 00 01    ....
                    lda       #1                  * 074A 86 01          ..
                    os9       I$WritLn            * 074C 10 3F 8C       .?.
                    puls      Y,X                 * 074F 35 30          50
                    puls      D                   * 0751 35 06          5.
                    pshs      Y                   * 0753 34 20          4
                    subd      0,S                 * 0755 A3 E4          #d
                    leas      $02,S               * 0757 32 62          2b
                    tfr       D,Y                 * 0759 1F 02          ..
                    leay      $01,Y               * 075B 31 21          1!
                    lbsr      L07E0               * 075D 17 00 80       ...
                    rts                           * 0760 39             9
                    fcc       "50"                * 0761 35 30          50
L0763               puls      D                   * 0763 35 06          5.
                    pshs      Y                   * 0765 34 20          4
                    subd      0,S                 * 0767 A3 E4          #d
                    leas      $02,S               * 0769 32 62          2b
                    addd      #1                  * 076B C3 00 01       C..
                    tfr       D,Y                 * 076E 1F 02          ..
                    clrb                          * 0770 5F             _
L0771               leay      -$01,Y              * 0771 31 3F          1?
                    beq       L078F               * 0773 27 1A          '.
                    lda       ,-X                 * 0775 A6 82          &.
                    cmpa      #32                 * 0777 81 20          .
                    beq       L07A0               * 0779 27 25          '%
                    pshs      Y,X                 * 077B 34 30          40
                    leax      >L01A3,PC           * 077D 30 8D FA 22    0.z"
                    ldy       #3                  * 0781 10 8E 00 03    ....
                    lda       #1                  * 0785 86 01          ..
                    os9       I$Write             * 0787 10 3F 8A       .?.
                    incb                          * 078A 5C             \
                    puls      Y,X                 * 078B 35 30          50
                    bra       L0771               * 078D 20 E2           b
L078F               lda       #13                 * 078F 86 0D          ..
                    sta       <$004F,X            * 0791 A7 88 4F       '.O
                    ldy       #200                * 0794 10 8E 00 C8    ...H
                    lda       #1                  * 0798 86 01          ..
                    os9       I$WritLn            * 079A 10 3F 8C       .?.
                    puls      Y                   * 079D 35 20          5
                    rts                           * 079F 39             9
L07A0               lda       #13                 * 07A0 86 0D          ..
                    sta       ,X+                 * 07A2 A7 80          '.
                    pshs      Y,X                 * 07A4 34 30          40
                    stb       U0006,U             * 07A6 E7 46          gF
                    leay      >U2191,U            * 07A8 31 C9 21 91    1I!.
L07AC               lda       ,X+                 * 07AC A6 80          &.
                    sta       ,Y+                 * 07AE A7 A0          '
                    decb                          * 07B0 5A             Z
                    bne       L07AC               * 07B1 26 F9          &y
                    leax      >L01A1,PC           * 07B3 30 8D F9 EA    0.yj
                    ldy       #1                  * 07B7 10 8E 00 01    ....
                    lda       #1                  * 07BB 86 01          ..
                    os9       I$WritLn            * 07BD 10 3F 8C       .?.
                    puls      Y,X                 * 07C0 35 30          50
                    lbsr      L07E0               * 07C2 17 00 1B       ...
                    rts                           * 07C5 39             9
L07C6               pshs      Y,X,D               * 07C6 34 36          46
                    leax      >U21E1,U            * 07C8 30 C9 21 E1    0I!a
                    clra                          * 07CC 4F             O
                    ldb       #0                  * 07CD C6 00          F.
                    os9       I$GetStt            * 07CF 10 3F 8D       .?.
                    leax      -$20,X              * 07D2 30 88 E0       0.`
                    clr       <$0024,X            * 07D5 6F 88 24       o.$
                    leax      <$0020,X            * 07D8 30 88 20       0.
                    os9       I$SetStt            * 07DB 10 3F 8E       .?.
                    puls      PC,Y,X,D            * 07DE 35 B6          56
L07E0               pshs      Y,X,D               * 07E0 34 36          46
                    leax      >U21E1,U            * 07E2 30 C9 21 E1    0I!a
                    clra                          * 07E6 4F             O
                    ldb       #0                  * 07E7 C6 00          F.
                    os9       I$GetStt            * 07E9 10 3F 8D       .?.
                    leax      -$20,X              * 07EC 30 88 E0       0.`
                    lda       #1                  * 07EF 86 01          ..
                    sta       <$0024,X            * 07F1 A7 88 24       '.$
                    leax      <$0020,X            * 07F4 30 88 20       0.
                    clra                          * 07F7 4F             O
                    os9       I$SetStt            * 07F8 10 3F 8E       .?.
                    puls      PC,Y,X,D            * 07FB 35 B6          56
L07FD               pshs      Y                   * 07FD 34 20          4
L07FF               lda       ,X+                 * 07FF A6 80          &.
                    cmpa      #13                 * 0801 81 0D          ..
                    lbeq      L08A6               * 0803 10 27 00 9F    .'..
                    cmpa      #48                 * 0807 81 30          .0
                    bcs       L07FF               * 0809 25 F4          %t
                    cmpa      #57                 * 080B 81 39          .9
                    bhi       L07FF               * 080D 22 F0          "p
                    leax      -$01,X              * 080F 30 1F          0.
L0811               lda       ,X+                 * 0811 A6 80          &.
                    cmpa      #48                 * 0813 81 30          .0
                    bcs       L081D               * 0815 25 06          %.
                    cmpa      #57                 * 0817 81 39          .9
                    bhi       L081D               * 0819 22 02          ".
                    bra       L0811               * 081B 20 F4           t
L081D               pshs      X                   * 081D 34 10          4.
                    leax      -$01,X              * 081F 30 1F          0.
                    clr       <U0014,U            * 0821 6F C8 14       oH.
                    clr       <U0015,U            * 0824 6F C8 15       oH.
                    ldd       #1                  * 0827 CC 00 01       L..
                    std       <U0016,U            * 082A ED C8 16       mH.
L082D               lda       ,-X                 * 082D A6 82          &.
                    cmpa      #48                 * 082F 81 30          .0
                    bcs       L0866               * 0831 25 33          %3
                    cmpa      #57                 * 0833 81 39          .9
                    bhi       L0866               * 0835 22 2F          "/
                    suba      #48                 * 0837 80 30          .0
                    sta       U0004,U             * 0839 A7 44          'D
                    ldd       #0                  * 083B CC 00 00       L..
L083E               tst       U0004,U             * 083E 6D 44          mD
                    beq       L0849               * 0840 27 07          '.
                    addd      <U0016,U            * 0842 E3 C8 16       cH.
                    dec       U0004,U             * 0845 6A 44          jD
                    bra       L083E               * 0847 20 F5           u
L0849               addd      <U0014,U            * 0849 E3 C8 14       cH.
                    std       <U0014,U            * 084C ED C8 14       mH.
                    lda       #10                 * 084F 86 0A          ..
                    sta       U0004,U             * 0851 A7 44          'D
                    ldd       #0                  * 0853 CC 00 00       L..
L0856               tst       U0004,U             * 0856 6D 44          mD
                    beq       L0861               * 0858 27 07          '.
                    addd      <U0016,U            * 085A E3 C8 16       cH.
                    dec       U0004,U             * 085D 6A 44          jD
                    bra       L0856               * 085F 20 F5           u
L0861               std       <U0016,U            * 0861 ED C8 16       mH.
                    bra       L082D               * 0864 20 C7           G
L0866               ldd       <U0014,U            * 0866 EC C8 14       lH.
                    puls      X                   * 0869 35 10          5.
                    puls      PC,Y                * 086B 35 A0          5
L086D               pshs      Y                   * 086D 34 20          4
                    std       <U0014,U            * 086F ED C8 14       mH.
                    lda       #48                 * 0872 86 30          .0
                    sta       0,X                 * 0874 A7 84          '.
                    sta       $01,X               * 0876 A7 01          '.
                    ldd       #10                 * 0878 CC 00 0A       L..
                    std       <U0016,U            * 087B ED C8 16       mH.
                    ldd       <U0014,U            * 087E EC C8 14       lH.
                    bsr       L0894               * 0881 8D 11          ..
                    ldd       #1                  * 0883 CC 00 01       L..
                    std       <U0016,U            * 0886 ED C8 16       mH.
                    ldd       <U0014,U            * 0889 EC C8 14       lH.
                    bsr       L0894               * 088C 8D 06          ..
                    lda       #13                 * 088E 86 0D          ..
                    sta       0,X                 * 0890 A7 84          '.
                    puls      PC,Y                * 0892 35 A0          5
L0894               subd      <U0016,U            * 0894 A3 C8 16       #H.
                    bcs       L089D               * 0897 25 04          %.
                    inc       0,X                 * 0899 6C 84          l.
                    bra       L0894               * 089B 20 F7           w
L089D               addd      <U0016,U            * 089D E3 C8 16       cH.
                    std       <U0014,U            * 08A0 ED C8 14       mH.
                    leax      $01,X               * 08A3 30 01          0.
                    rts                           * 08A5 39             9
L08A6               ldd       #-1                 * 08A6 CC FF FF       L..
                    puls      PC,Y                * 08A9 35 A0          5

                    emod
eom                 equ       *
                    end
