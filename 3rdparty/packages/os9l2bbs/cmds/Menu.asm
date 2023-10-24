                    nam       menu
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
U0005               rmb       2
U0007               rmb       2
U0009               rmb       2
U000B               rmb       1
U000C               rmb       1
U000D               rmb       2
U000F               rmb       2
U0011               rmb       2
U0013               rmb       2
U0015               rmb       4
U0019               rmb       4
U001D               rmb       1
U001E               rmb       1
U001F               rmb       1
U0020               rmb       1
U0021               rmb       16
U0031               rmb       8
U0039               rmb       3
U003C               rmb       3
U003F               rmb       3
U0042               rmb       3
U0045               rmb       9
U004E               rmb       23
U0065               rmb       32
U0085               rmb       206
U0153               rmb       40
U017B               rmb       120
U01F3               rmb       3200
U0E73               rmb       2
U0E75               rmb       80
U0EC5               rmb       1
U0EC6               rmb       4449
size                equ       .

name                fcs       /menu/              * 000D 6D 65 6E F5    menu
                    fcc       "Copyright (C) 1988By Keith AlphonsoLicenced to Alpha Software TechnologiesAll rights reserved" * 0011 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 4C 69 63 65 6E 63 65 64
                    fcb       $EC                 * 006E EC             l
                    fcb       $E6                 * 006F E6             f
                    fcb       $EA                 * 0070 EA             j
                    fcb       $F5                 * 0071 F5             u
                    fcb       $E9                 * 0072 E9             i
                    fcb       $A0                 * 0073 A0
                    fcb       $E2                 * 0074 E2             b
                    fcb       $ED                 * 0075 ED             m
                    fcb       $F1                 * 0076 F1             q
                    fcb       $E9                 * 0077 E9             i
                    fcb       $F0                 * 0078 F0             p
                    fcb       $EF                 * 0079 EF             o
                    fcb       $F4                 * 007A F4             t
                    fcb       $F0                 * 007B F0             p
L007C               fcc       "shell"             * 007C 73 68 65 6C 6C shell
                    fcb       $0D                 * 0081 0D             .
L0082               fcc       "Usage is:"         * 0082 55 73 61 67 65 20 69 73 3A Usage is:
                    fcb       $0A                 * 008B 0A             .
                    fcc       "MENU <menuname> <cmdname>" * 008C 4D 45 4E 55 20 3C 6D 65 6E 75 6E 61 6D 65 3E 20 3C 63 6D 64 6E 61 6D 65 3E MENU <menuname> <cmdname>
                    fcb       $0A                 * 00A5 0A             .
                    fcb       $0D                 * 00A6 0D             .
L00A7               fcb       $0A                 * 00A7 0A             .
                    fcb       $0A                 * 00A8 0A             .
                    fcb       $0D                 * 00A9 0D             .
L00AA               fcc       "Sorry, you do not have access to that option" * 00AA 53 6F 72 72 79 2C 20 79 6F 75 20 64 6F 20 6E 6F 74 20 68 61 76 65 20 61 63 63 65 73 73 20 74 6F 20 74 68 61 74 20 6F 70 74 69 6F 6E Sorry, you do not have access to that option
                    fcb       $0D                 * 00D6 0D             .
L00D7               fcc       "A user priority level has been specified incorrectly!" * 00D7 41 20 75 73 65 72 20 70 72 69 6F 72 69 74 79 20 6C 65 76 65 6C 20 68 61 73 20 62 65 65 6E 20 73 70 65 63 69 66 69 65 64 20 69 6E 63 6F 72 72 65 63 74 6C 79 21 A user pr
                    fcb       $0D                 * 010C 0D             .
L010D               fcc       "/dd/bbs/BBS.userstats" * 010D 2F 64 64 2F 62 62 73 2F 42 42 53 2E 75 73 65 72 73 74 61 74 73 /dd/bbs/BBS.userstats
                    fcb       $0D                 * 0122 0D             .
L0123               fcc       "I'm sorry, but your time has expired!" * 0123 49 27 6D 20 73 6F 72 72 79 2C 20 62 75 74 20 79 6F 75 72 20 74 69 6D 65 20 68 61 73 20 65 78 70 69 72 65 64 21 I'm sorry, but your time has expired!
                    fcb       $0D                 * 0148 0D             .
L0149               fcc       "WARNING!!  You have only a few minutes left online!" * 0149 57 41 52 4E 49 4E 47 21 21 20 20 59 6F 75 20 68 61 76 65 20 6F 6E 6C 79 20 61 20 66 65 77 20 6D 69 6E 75 74 65 73 20 6C 65 66 74 20 6F 6E 6C 69 6E 65 21 WARNING!!  You ha
                    fcb       $0D                 * 017C 0D             .
L017D               fcb       $1F                 * 017D 1F             .
                    fcb       $1C                 * 017E 1C             .
                    fcb       $1F                 * 017F 1F             .
                    fcb       $1E                 * 0180 1E             .
                    fcb       $1F                 * 0181 1F             .
                    fcb       $1E                 * 0182 1E             .
                    fcb       $1F                 * 0183 1F             .
                    fcb       $1F                 * 0184 1F             .
                    fcb       $1E                 * 0185 1E             .
                    fcb       $1F                 * 0186 1F             .
                    fcb       $1E                 * 0187 1E             .
                    fcb       $1F                 * 0188 1F             .
start               pshs      U,Y,X,D             * 0189 34 76          4v
                    os9       F$ID                * 018B 10 3F 0C       .?.
                    sty       <U0013,U            * 018E 10 AF C8 13    ./H.
                    puls      U,Y,X,D             * 0192 35 76          5v
                    ldd       #2573               * 0194 CC 0A 0D       L..
                    std       >U0E73,U            * 0197 ED C9 0E 73    mI.s
                    sty       U000B,U             * 019B 10 AF 4B       ./K
                    leay      <U0045,U            * 019E 31 C8 45       1HE
L01A1               lda       ,X+                 * 01A1 A6 80          &.
                    cmpx      U000B,U             * 01A3 AC 4B          ,K
                    lbhi      L0586               * 01A5 10 22 03 DD    .".]
                    sta       ,Y+                 * 01A9 A7 A0          '
                    cmpa      #32                 * 01AB 81 20          .
                    bne       L01A1               * 01AD 26 F2          &r
                    lda       #13                 * 01AF 86 0D          ..
                    sta       -$01,Y              * 01B1 A7 3F          '?
                    leay      <U0065,U            * 01B3 31 C8 65       1He
L01B6               lda       ,X+                 * 01B6 A6 80          &.
                    cmpx      U000B,U             * 01B8 AC 4B          ,K
                    lbhi      L0586               * 01BA 10 22 03 C8    .".H
                    sta       ,Y+                 * 01BE A7 A0          '
                    cmpa      #13                 * 01C0 81 0D          ..
                    bne       L01B6               * 01C2 26 F2          &r
                    leax      >L010D,PC           * 01C4 30 8D FF 45    0..E
                    lda       #1                  * 01C8 86 01          ..
                    os9       I$Open              * 01CA 10 3F 84       .?.
                    lbcs      L027C               * 01CD 10 25 00 AB    .%.+
                    sta       U0000,U             * 01D1 A7 C4          'D
L01D3               leax      <U0019,U            * 01D3 30 C8 19       0H.
                    ldy       #32                 * 01D6 10 8E 00 20    ...
                    lda       U0000,U             * 01DA A6 C4          &D
                    os9       I$Read              * 01DC 10 3F 89       .?.
                    bcs       L01EC               * 01DF 25 0B          %.
                    ldd       <U0013,U            * 01E1 EC C8 13       lH.
                    cmpd      <U0019,U            * 01E4 10 A3 C8 19    .#H.
                    bne       L01D3               * 01E8 26 E9          &i
                    bra       L01F4               * 01EA 20 08           .
L01EC               lda       U0000,U             * 01EC A6 C4          &D
                    os9       I$Close             * 01EE 10 3F 8F       .?.
                    lbra      L027C               * 01F1 16 00 88       ...
L01F4               ldd       <U0031,U            * 01F4 EC C8 31       lH1
                    cmpd      #0                  * 01F7 10 83 00 00    ....
                    lbeq      L0277               * 01FB 10 27 00 78    .'.x
                    ldb       <U0021,U            * 01FF E6 C8 21       fH!
                    clra                          * 0202 4F             O
                    addd      <U0031,U            * 0203 E3 C8 31       cH1
                    cmpd      #60                 * 0206 10 83 00 3C    ...<
                    bcs       L0263               * 020A 25 57          %W
L020C               subd      #60                 * 020C 83 00 3C       ..<
                    pshs      D                   * 020F 34 06          4.
                    lda       <U0020,U            * 0211 A6 C8 20       &H
                    inca                          * 0214 4C             L
                    cmpa      #24                 * 0215 81 18          ..
                    bcs       L0258               * 0217 25 3F          %?
                    clr       <U0020,U            * 0219 6F C8 20       oH
                    lda       <U001F,U            * 021C A6 C8 1F       &H.
                    inca                          * 021F 4C             L
                    leax      >L017D,PC           * 0220 30 8D FF 59    0..Y
                    ldb       <U001E,U            * 0224 E6 C8 1E       fH.
                    decb                          * 0227 5A             Z
                    leax      B,X                 * 0228 30 85          0.
                    cmpa      0,X                 * 022A A1 84          !.
                    bcs       L0253               * 022C 25 25          %%
                    lda       #1                  * 022E 86 01          ..
                    sta       <U001F,U            * 0230 A7 C8 1F       'H.
                    lda       <U001E,U            * 0233 A6 C8 1E       &H.
                    inca                          * 0236 4C             L
                    cmpa      #12                 * 0237 81 0C          ..
                    blt       L024E               * 0239 2D 13          -.
                    lda       #1                  * 023B 86 01          ..
                    sta       <U001E,U            * 023D A7 C8 1E       'H.
                    lda       <U001D,U            * 0240 A6 C8 1D       &H.
                    inca                          * 0243 4C             L
                    cmpa      #100                * 0244 81 64          .d
                    bcs       L0249               * 0246 25 01          %.
                    clra                          * 0248 4F             O
L0249               sta       <U001D,U            * 0249 A7 C8 1D       'H.
                    bra       L025B               * 024C 20 0D           .
L024E               sta       <U001E,U            * 024E A7 C8 1E       'H.
                    bra       L025B               * 0251 20 08           .
L0253               sta       <U001F,U            * 0253 A7 C8 1F       'H.
                    bra       L025B               * 0256 20 03           .
L0258               sta       <U0020,U            * 0258 A7 C8 20       'H
L025B               puls      D                   * 025B 35 06          5.
                    cmpd      #60                 * 025D 10 83 00 3C    ...<
                    bcc       L020C               * 0261 24 A9          $)
L0263               stb       <U0021,U            * 0263 E7 C8 21       gH!
                    lda       #6                  * 0266 86 06          ..
                    leax      <U001D,U            * 0268 30 C8 1D       0H.
                    leay      <U003F,U            * 026B 31 C8 3F       1H?
L026E               ldb       ,X+                 * 026E E6 80          f.
                    stb       ,Y+                 * 0270 E7 A0          g
                    deca                          * 0272 4A             J
                    bne       L026E               * 0273 26 F9          &y
                    bra       L027C               * 0275 20 05           .
L0277               lda       #101                * 0277 86 65          .e
                    sta       <U003F,U            * 0279 A7 C8 3F       'H?
L027C               leax      >U0153,U            * 027C 30 C9 01 53    0I.S
                    stx       U0005,U             * 0280 AF 45          /E
                    leax      >U01F3,U            * 0282 30 C9 01 F3    0I.s
                    stx       U0007,U             * 0286 AF 47          /G
                    leax      >U017B,U            * 0288 30 C9 01 7B    0I.{
                    stx       U0009,U             * 028C AF 49          /I
                    leax      <U0065,U            * 028E 30 C8 65       0He
                    lda       #1                  * 0291 86 01          ..
                    os9       I$Open              * 0293 10 3F 84       .?.
                    lbcs      L0594               * 0296 10 25 02 FA    .%.z
                    sta       U0002,U             * 029A A7 42          'B
L029C               ldx       U0005,U             * 029C AE 45          .E
                    ldy       #1                  * 029E 10 8E 00 01    ....
                    os9       I$Read              * 02A2 10 3F 89       .?.
                    ldb       0,X                 * 02A5 E6 84          f.
                    cmpb      #47                 * 02A7 C1 2F          A/
                    beq       L02F4               * 02A9 27 49          'I
                    cmpb      #62                 * 02AB C1 3E          A>
                    lbeq      L03AB               * 02AD 10 27 00 FA    .'.z
                    cmpb      #60                 * 02B1 C1 3C          A<
                    lbeq      L03AB               * 02B3 10 27 00 F4    .'.t
                    cmpb      #61                 * 02B7 C1 3D          A=
                    lbeq      L03AB               * 02B9 10 27 00 EE    .'.n
                    ldy       U0009,U             * 02BD 10 AE 49       ..I
                    pshs      D                   * 02C0 34 06          4.
                    lda       #45                 * 02C2 86 2D          .-
                    sta       ,Y+                 * 02C4 A7 A0          '
                    ldd       #-1                 * 02C6 CC FF FF       L..
                    std       ,Y++                * 02C9 ED A1          m!
                    puls      D                   * 02CB 35 06          5.
                    sty       U0009,U             * 02CD 10 AF 49       ./I
L02D0               cmpb      #97                 * 02D0 C1 61          Aa
                    bcs       L02D8               * 02D2 25 04          %.
                    andb      #223                * 02D4 C4 DF          D_
                    stb       0,X                 * 02D6 E7 84          g.
L02D8               leax      $01,X               * 02D8 30 01          0.
                    stx       U0005,U             * 02DA AF 45          /E
                    ldx       U0007,U             * 02DC AE 47          .G
                    ldy       #80                 * 02DE 10 8E 00 50    ...P
                    os9       I$ReadLn            * 02E2 10 3F 8B       .?.
                    lbcs      L0594               * 02E5 10 25 02 AB    .%.+
                    sty       <$004E,X            * 02E9 10 AF 88 4E    ./.N
                    leax      <$0050,X            * 02ED 30 88 50       0.P
                    stx       U0007,U             * 02F0 AF 47          /G
                    bra       L029C               * 02F2 20 A8           (
L02F4               leax      >U0E75,U            * 02F4 30 C9 0E 75    0I.u
                    ldy       #80                 * 02F8 10 8E 00 50    ...P
                    os9       I$ReadLn            * 02FC 10 3F 8B       .?.
                    lbcs      L0594               * 02FF 10 25 02 91    .%..
                    sty       <U0011,U            * 0303 10 AF C8 11    ./H.
                    ldx       U0005,U             * 0307 AE 45          .E
                    lda       #255                * 0309 86 FF          ..
                    sta       0,X                 * 030B A7 84          '.
                    lda       U0002,U             * 030D A6 42          &B
                    os9       I$Close             * 030F 10 3F 8F       .?.
                    lbcs      L0594               * 0312 10 25 02 7E    .%.~
                    leax      <U0045,U            * 0316 30 C8 45       0HE
                    lda       #1                  * 0319 86 01          ..
                    os9       I$Open              * 031B 10 3F 84       .?.
                    lbcs      L0594               * 031E 10 25 02 72    .%.r
                    sta       U0001,U             * 0322 A7 41          'A
                    leax      >U0EC5,U            * 0324 30 C9 0E C5    0I.E
                    ldy       #4000               * 0328 10 8E 0F A0    ...
                    lda       U0001,U             * 032C A6 41          &A
                    os9       I$Read              * 032E 10 3F 89       .?.
                    sty       <U0015,U            * 0331 10 AF C8 15    ./H.
                    lbcs      L0594               * 0335 10 25 02 5B    .%.[
                    os9       I$Close             * 0339 10 3F 8F       .?.
                    stx       U000B,U             * 033C AF 4B          /K
                    tfr       Y,D                 * 033E 1F 20          .
                    leax      D,X                 * 0340 30 8B          0.
                    stx       U000F,U             * 0342 AF 4F          /O
                    ldx       U000B,U             * 0344 AE 4B          .K
                    ldy       #1                  * 0346 10 8E 00 01    ....
L034A               pshs      X                   * 034A 34 10          4.
                    lda       #1                  * 034C 86 01          ..
                    ldb       #1                  * 034E C6 01          F.
                    os9       I$GetStt            * 0350 10 3F 8D       .?.
                    lbcc      L0440               * 0353 10 24 00 E9    .$.i
                    ldy       <U0015,U            * 0357 10 AE C8 15    ..H.
                    ldx       0,S                 * 035B AE E4          .d
L035D               lda       ,X+                 * 035D A6 80          &.
                    cmpa      #13                 * 035F 81 0D          ..
                    beq       L0374               * 0361 27 11          '.
                    leay      -$01,Y              * 0363 31 3F          1?
                    bne       L035D               * 0365 26 F6          &v
                    puls      X                   * 0367 35 10          5.
                    lda       #1                  * 0369 86 01          ..
                    ldy       <U0015,U            * 036B 10 AE C8 15    ..H.
                    os9       I$Write             * 036F 10 3F 8A       .?.
                    bra       L037F               * 0372 20 0B           .
L0374               puls      X                   * 0374 35 10          5.
                    lda       #1                  * 0376 86 01          ..
                    ldy       <U0015,U            * 0378 10 AE C8 15    ..H.
                    os9       I$WritLn            * 037C 10 3F 8C       .?.
L037F               lbcs      L0594               * 037F 10 25 02 11    .%..
                    pshs      Y                   * 0383 34 20          4
                    ldd       <U0015,U            * 0385 EC C8 15       lH.
                    subd      0,S                 * 0388 A3 E4          #d
                    std       <U0015,U            * 038A ED C8 15       mH.
                    cmpd      #0                  * 038D 10 83 00 00    ....
                    ble       L03A8               * 0391 2F 15          /.
                    puls      D                   * 0393 35 06          5.
                    leax      D,X                 * 0395 30 8B          0.
                    lda       #1                  * 0397 86 01          ..
                    ldb       #1                  * 0399 C6 01          F.
                    os9       I$GetStt            * 039B 10 3F 8D       .?.
                    lbcc      L0440               * 039E 10 24 00 9E    .$..
                    cmpx      U000F,U             * 03A2 AC 4F          ,O
                    bhi       L03A8               * 03A4 22 02          ".
                    bra       L034A               * 03A6 20 A2           "
L03A8               lbra      L03F9               * 03A8 16 00 4E       ..N
L03AB               pshs      X,A                 * 03AB 34 12          4.
                    ldy       U0009,U             * 03AD 10 AE 49       ..I
                    stb       ,Y+                 * 03B0 E7 A0          g
                    leax      >U0085,U            * 03B2 30 C9 00 85    0I..
                    pshs      Y                   * 03B6 34 20          4
                    ldy       #6                  * 03B8 10 8E 00 06    ....
                    os9       I$Read              * 03BC 10 3F 89       .?.
                    leax      >U0085,U            * 03BF 30 C9 00 85    0I..
                    lbsr      L0597               * 03C3 17 01 D1       ..Q
                    puls      Y                   * 03C6 35 20          5
                    std       ,Y++                * 03C8 ED A1          m!
                    sty       U0009,U             * 03CA 10 AF 49       ./I
                    puls      X,A                 * 03CD 35 12          5.
                    ldy       #1                  * 03CF 10 8E 00 01    ....
                    os9       I$Read              * 03D3 10 3F 89       .?.
                    ldb       0,X                 * 03D6 E6 84          f.
                    lbra      L02D0               * 03D8 16 FE F5       .~u
L03DB               leax      >L0123,PC           * 03DB 30 8D FD 44    0.}D
                    ldy       #200                * 03DF 10 8E 00 C8    ...H
                    lda       #1                  * 03E3 86 01          ..
                    os9       I$WritLn            * 03E5 10 3F 8C       .?.
                    lbra      L0582               * 03E8 16 01 97       ...
L03EB               leax      >L0149,PC           * 03EB 30 8D FD 5A    0.}Z
                    ldy       #200                * 03EF 10 8E 00 C8    ...H
                    lda       #1                  * 03F3 86 01          ..
                    os9       I$WritLn            * 03F5 10 3F 8C       .?.
                    rts                           * 03F8 39             9
L03F9               leax      <U0039,U            * 03F9 30 C8 39       0H9
                    os9       F$Time              * 03FC 10 3F 15       .?.
                    ldb       #6                  * 03FF C6 06          F.
                    leax      <U0039,U            * 0401 30 C8 39       0H9
                    leay      <U003F,U            * 0404 31 C8 3F       1H?
L0407               lda       ,X+                 * 0407 A6 80          &.
                    cmpa      ,Y+                 * 0409 A1 A0          !
                    lbhi      L03DB               * 040B 10 22 FF CC    .".L
                    bcs       L0414               * 040F 25 03          %.
                    decb                          * 0411 5A             Z
                    bne       L0407               * 0412 26 F3          &s
L0414               cmpb      #3                  * 0414 C1 03          A.
                    bgt       L0431               * 0416 2E 19          ..
                    ldd       <U003C,U            * 0418 EC C8 3C       lH<
                    addb      #5                  * 041B CB 05          K.
                    cmpb      #60                 * 041D C1 3C          A<
                    bcs       L0429               * 041F 25 08          %.
                    subb      #60                 * 0421 C0 3C          @<
                    inca                          * 0423 4C             L
                    cmpa      #24                 * 0424 81 18          ..
                    bcs       L0429               * 0426 25 01          %.
                    clra                          * 0428 4F             O
L0429               cmpd      <U0042,U            * 0429 10 A3 C8 42    .#HB
                    bls       L0431               * 042D 23 02          #.
                    bsr       L03EB               * 042F 8D BA          .:
L0431               leax      >U0E75,U            * 0431 30 C9 0E 75    0I.u
                    ldy       <U0011,U            * 0435 10 AE C8 11    ..H.
                    leay      -$01,Y              * 0439 31 3F          1?
                    lda       #1                  * 043B 86 01          ..
                    os9       I$Write             * 043D 10 3F 8A       .?.
L0440               leax      U0003,U             * 0440 30 43          0C
                    ldy       #1                  * 0442 10 8E 00 01    ....
                    clra                          * 0446 4F             O
                    os9       I$Read              * 0447 10 3F 89       .?.
                    ldy       #2                  * 044A 10 8E 00 02    ....
                    lda       #1                  * 044E 86 01          ..
                    pshs      X                   * 0450 34 10          4.
                    leax      >L00A7,PC           * 0452 30 8D FC 51    0.|Q
                    os9       I$WritLn            * 0456 10 3F 8C       .?.
                    puls      X                   * 0459 35 10          5.
                    lda       0,X                 * 045B A6 84          &.
                    cmpa      #63                 * 045D 81 3F          .?
                    lbeq      L027C               * 045F 10 27 FE 19    .'~.
                    cmpa      #97                 * 0463 81 61          .a
                    bcs       L046B               * 0465 25 04          %.
                    anda      #223                * 0467 84 DF          ._
                    sta       0,X                 * 0469 A7 84          '.
L046B               lda       0,X                 * 046B A6 84          &.
                    leax      >U0153,U            * 046D 30 C9 01 53    0I.S
                    clrb                          * 0471 5F             _
L0472               tst       0,X                 * 0472 6D 84          m.
                    bmi       L03F9               * 0474 2B 83          +.
                    cmpa      ,X+                 * 0476 A1 80          !.
                    beq       L0482               * 0478 27 08          '.
                    incb                          * 047A 5C             \
                    cmpb      #40                 * 047B C1 28          A(
                    bls       L0472               * 047D 23 F3          #s
                    lbra      L03F9               * 047F 16 FF 77       ..w
L0482               pshs      B                   * 0482 34 04          4.
                    lda       #3                  * 0484 86 03          ..
                    mul                           * 0486 3D             =
                    leax      >U017B,U            * 0487 30 C9 01 7B    0I.{
                    leax      D,X                 * 048B 30 8B          0.
                    lda       ,X+                 * 048D A6 80          &.
                    cmpa      #60                 * 048F 81 3C          .<
                    beq       L04DF               * 0491 27 4C          'L
                    cmpa      #62                 * 0493 81 3E          .>
                    beq       L04EF               * 0495 27 58          'X
                    cmpa      #61                 * 0497 81 3D          .=
                    beq       L04FF               * 0499 27 64          'd
L049B               puls      B                   * 049B 35 04          5.
                    lda       #80                 * 049D 86 50          .P
                    mul                           * 049F 3D             =
                    pshs      U                   * 04A0 34 40          4@
                    leau      >U01F3,U            * 04A2 33 C9 01 F3    3I.s
                    leau      D,U                 * 04A6 33 CB          3K
                    lda       U0001,U             * 04A8 A6 41          &A
                    anda      #223                * 04AA 84 DF          ._
                    cmpa      #67                 * 04AC 81 43          .C
                    bne       L04CC               * 04AE 26 1C          &.
                    lda       U0002,U             * 04B0 A6 42          &B
                    anda      #223                * 04B2 84 DF          ._
                    cmpa      #72                 * 04B4 81 48          .H
                    bne       L04CC               * 04B6 26 14          &.
                    lda       U0003,U             * 04B8 A6 43          &C
                    anda      #223                * 04BA 84 DF          ._
                    cmpa      #77                 * 04BC 81 4D          .M
                    lbeq      L0557               * 04BE 10 27 00 95    .'..
                    cmpa      #88                 * 04C2 81 58          .X
                    lbeq      L0549               * 04C4 10 27 00 81    .'..
                    cmpa      #68                 * 04C8 81 44          .D
                    beq       L053B               * 04CA 27 6F          'o
L04CC               lda       U0001,U             * 04CC A6 41          &A
                    anda      #223                * 04CE 84 DF          ._
                    cmpa      #69                 * 04D0 81 45          .E
                    bne       L051F               * 04D2 26 4B          &K
                    lda       U0002,U             * 04D4 A6 42          &B
                    anda      #223                * 04D6 84 DF          ._
                    cmpa      #88                 * 04D8 81 58          .X
                    bne       L051F               * 04DA 26 43          &C
                    lbra      L0582               * 04DC 16 00 A3       ..#
L04DF               ldd       <U0013,U            * 04DF EC C8 13       lH.
                    lbeq      L049B               * 04E2 10 27 FF B5    .'.5
                    cmpd      0,X                 * 04E6 10 A3 84       .#.
                    lbcs      L049B               * 04E9 10 25 FF AE    .%..
                    bra       L050D               * 04ED 20 1E           .
L04EF               ldd       <U0013,U            * 04EF EC C8 13       lH.
                    lbeq      L049B               * 04F2 10 27 FF A5    .'.%
                    cmpd      0,X                 * 04F6 10 A3 84       .#.
                    lbhi      L049B               * 04F9 10 22 FF 9E    ."..
                    bra       L050D               * 04FD 20 0E           .
L04FF               ldd       <U0013,U            * 04FF EC C8 13       lH.
                    lbeq      L049B               * 0502 10 27 FF 95    .'..
                    cmpd      0,X                 * 0506 10 A3 84       .#.
                    lbeq      L049B               * 0509 10 27 FF 8E    .'..
L050D               leax      >L00AA,PC           * 050D 30 8D FB 99    0.{.
                    ldy       #200                * 0511 10 8E 00 C8    ...H
                    lda       #1                  * 0515 86 01          ..
                    os9       I$WritLn            * 0517 10 3F 8C       .?.
                    puls      B                   * 051A 35 04          5.
                    lbra      L03F9               * 051C 16 FE DA       .~Z
L051F               ldy       <U004E,U            * 051F 10 AE C8 4E    ..HN
                    leax      >L007C,PC           * 0523 30 8D FB 55    0.{U
                    ldb       #3                  * 0527 C6 03          F.
                    lda       #17                 * 0529 86 11          ..
                    os9       F$Fork              * 052B 10 3F 03       .?.
                    puls      U                   * 052E 35 40          5@
                    bcc       L0535               * 0530 24 03          $.
                    os9       F$PErr              * 0532 10 3F 0F       .?.
L0535               os9       F$Wait              * 0535 10 3F 04       .?.
                    lbra      L03F9               * 0538 16 FE BE       .~>
L053B               tfr       U,X                 * 053B 1F 31          .1
                    puls      U                   * 053D 35 40          5@
                    leax      $04,X               * 053F 30 04          0.
                    lda       #1                  * 0541 86 01          ..
                    os9       I$ChgDir            * 0543 10 3F 86       .?.
                    lbra      L027C               * 0546 16 FD 33       .}3
L0549               tfr       U,X                 * 0549 1F 31          .1
                    puls      U                   * 054B 35 40          5@
                    leax      $04,X               * 054D 30 04          0.
                    lda       #4                  * 054F 86 04          ..
                    os9       I$ChgDir            * 0551 10 3F 86       .?.
                    lbra      L027C               * 0554 16 FD 25       .}%
L0557               tfr       U,X                 * 0557 1F 31          .1
                    puls      U                   * 0559 35 40          5@
                    leay      <U0045,U            * 055B 31 C8 45       1HE
                    leax      $04,X               * 055E 30 04          0.
L0560               lda       ,X+                 * 0560 A6 80          &.
                    cmpa      #32                 * 0562 81 20          .
                    beq       L0560               * 0564 27 FA          'z
                    leax      -$01,X              * 0566 30 1F          0.
L0568               lda       ,X+                 * 0568 A6 80          &.
                    sta       ,Y+                 * 056A A7 A0          '
                    cmpa      #32                 * 056C 81 20          .
                    bne       L0568               * 056E 26 F8          &x
                    lda       #13                 * 0570 86 0D          ..
                    sta       -$01,Y              * 0572 A7 3F          '?
                    leay      <U0065,U            * 0574 31 C8 65       1He
L0577               lda       ,X+                 * 0577 A6 80          &.
                    sta       ,Y+                 * 0579 A7 A0          '
                    cmpa      #13                 * 057B 81 0D          ..
                    bne       L0577               * 057D 26 F8          &x
                    lbra      L027C               * 057F 16 FC FA       .|z
L0582               clrb                          * 0582 5F             _
                    os9       F$Exit              * 0583 10 3F 06       .?.
L0586               leax      >L0082,PC           * 0586 30 8D FA F8    0.zx
                    ldy       #200                * 058A 10 8E 00 C8    ...H
                    lda       #1                  * 058E 86 01          ..
                    os9       I$WritLn            * 0590 10 3F 8C       .?.
                    clrb                          * 0593 5F             _
L0594               os9       F$Exit              * 0594 10 3F 06       .?.
L0597               pshs      Y                   * 0597 34 20          4
L0599               lda       ,X+                 * 0599 A6 80          &.
                    cmpa      #13                 * 059B 81 0D          ..
                    lbeq      L064E               * 059D 10 27 00 AD    .'.-
                    cmpa      #48                 * 05A1 81 30          .0
                    bcs       L0599               * 05A3 25 F4          %t
                    cmpa      #57                 * 05A5 81 39          .9
                    bhi       L0599               * 05A7 22 F0          "p
                    leax      -$01,X              * 05A9 30 1F          0.
L05AB               lda       ,X+                 * 05AB A6 80          &.
                    cmpa      #48                 * 05AD 81 30          .0
                    bcs       L05B7               * 05AF 25 06          %.
                    cmpa      #57                 * 05B1 81 39          .9
                    bhi       L05B7               * 05B3 22 02          ".
                    bra       L05AB               * 05B5 20 F4           t
L05B7               pshs      X                   * 05B7 34 10          4.
                    leax      -$01,X              * 05B9 30 1F          0.
                    clr       U000B,U             * 05BB 6F 4B          oK
                    clr       U000C,U             * 05BD 6F 4C          oL
                    ldd       #1                  * 05BF CC 00 01       L..
                    std       U000D,U             * 05C2 ED 4D          mM
L05C4               lda       ,-X                 * 05C4 A6 82          &.
                    cmpa      #48                 * 05C6 81 30          .0
                    bcs       L05F8               * 05C8 25 2E          %.
                    cmpa      #57                 * 05CA 81 39          .9
                    bhi       L05F8               * 05CC 22 2A          "*
                    suba      #48                 * 05CE 80 30          .0
                    sta       U0004,U             * 05D0 A7 44          'D
                    ldd       #0                  * 05D2 CC 00 00       L..
L05D5               tst       U0004,U             * 05D5 6D 44          mD
                    beq       L05DF               * 05D7 27 06          '.
                    addd      U000D,U             * 05D9 E3 4D          cM
                    dec       U0004,U             * 05DB 6A 44          jD
                    bra       L05D5               * 05DD 20 F6           v
L05DF               addd      U000B,U             * 05DF E3 4B          cK
                    std       U000B,U             * 05E1 ED 4B          mK
                    lda       #10                 * 05E3 86 0A          ..
                    sta       U0004,U             * 05E5 A7 44          'D
                    ldd       #0                  * 05E7 CC 00 00       L..
L05EA               tst       U0004,U             * 05EA 6D 44          mD
                    beq       L05F4               * 05EC 27 06          '.
                    addd      U000D,U             * 05EE E3 4D          cM
                    dec       U0004,U             * 05F0 6A 44          jD
                    bra       L05EA               * 05F2 20 F6           v
L05F4               std       U000D,U             * 05F4 ED 4D          mM
                    bra       L05C4               * 05F6 20 CC           L
L05F8               ldd       U000B,U             * 05F8 EC 4B          lK
                    puls      X                   * 05FA 35 10          5.
                    puls      PC,Y                * 05FC 35 A0          5
                    fcb       $ED                 * 05FE ED             m
                    fcb       $4B                 * 05FF 4B             K
                    fcb       $86                 * 0600 86             .
                    fcb       $30                 * 0601 30             0
                    fcb       $A7                 * 0602 A7             '
                    fcb       $84                 * 0603 84             .
                    fcb       $A7                 * 0604 A7             '
                    fcb       $01                 * 0605 01             .
                    fcb       $A7                 * 0606 A7             '
                    fcb       $02                 * 0607 02             .
                    fcb       $A7                 * 0608 A7             '
                    fcb       $03                 * 0609 03             .
                    fcb       $A7                 * 060A A7             '
                    fcb       $04                 * 060B 04             .
                    fcb       $CC                 * 060C CC             L
                    fcb       $27                 * 060D 27             '
                    fcb       $10                 * 060E 10             .
                    fcb       $ED                 * 060F ED             m
                    fcb       $4D                 * 0610 4D             M
                    fcb       $EC                 * 0611 EC             l
                    fcb       $4B                 * 0612 4B             K
                    fcb       $17                 * 0613 17             .
                    fcb       $00                 * 0614 00             .
                    fcb       $29                 * 0615 29             )
                    fcb       $CC                 * 0616 CC             L
                    fcb       $03                 * 0617 03             .
                    fcb       $E8                 * 0618 E8             h
                    fcb       $ED                 * 0619 ED             m
                    fcb       $4D                 * 061A 4D             M
                    fcb       $EC                 * 061B EC             l
                    fcb       $4B                 * 061C 4B             K
                    fcb       $8D                 * 061D 8D             .
                    fcb       $20                 * 061E 20
                    fcb       $CC                 * 061F CC             L
                    fcb       $00                 * 0620 00             .
                    fcb       $64                 * 0621 64             d
                    fcb       $ED                 * 0622 ED             m
                    fcb       $4D                 * 0623 4D             M
                    fcb       $EC                 * 0624 EC             l
                    fcb       $4B                 * 0625 4B             K
                    fcb       $8D                 * 0626 8D             .
                    fcb       $17                 * 0627 17             .
                    fcb       $CC                 * 0628 CC             L
                    fcb       $00                 * 0629 00             .
                    fcb       $0A                 * 062A 0A             .
                    fcb       $ED                 * 062B ED             m
                    fcb       $4D                 * 062C 4D             M
                    fcb       $EC                 * 062D EC             l
                    fcb       $4B                 * 062E 4B             K
                    fcb       $8D                 * 062F 8D             .
                    fcb       $0E                 * 0630 0E             .
                    fcb       $CC                 * 0631 CC             L
                    fcb       $00                 * 0632 00             .
                    fcb       $01                 * 0633 01             .
                    fcb       $ED                 * 0634 ED             m
                    fcb       $4D                 * 0635 4D             M
                    fcb       $EC                 * 0636 EC             l
                    fcb       $4B                 * 0637 4B             K
                    fcb       $8D                 * 0638 8D             .
                    fcb       $05                 * 0639 05             .
                    fcb       $86                 * 063A 86             .
                    fcb       $0D                 * 063B 0D             .
                    fcb       $A7                 * 063C A7             '
                    fcb       $84                 * 063D 84             .
                    fcb       $39                 * 063E 39             9
                    fcb       $A3                 * 063F A3             #
                    fcb       $4D                 * 0640 4D             M
                    fcb       $25                 * 0641 25             %
                    fcb       $04                 * 0642 04             .
                    fcb       $6C                 * 0643 6C             l
                    fcb       $84                 * 0644 84             .
                    fcb       $20                 * 0645 20
                    fcb       $F8                 * 0646 F8             x
                    fcb       $E3                 * 0647 E3             c
                    fcb       $4D                 * 0648 4D             M
                    fcb       $ED                 * 0649 ED             m
                    fcb       $4B                 * 064A 4B             K
                    fcb       $30                 * 064B 30             0
                    fcb       $01                 * 064C 01             .
                    fcb       $39                 * 064D 39             9
L064E               leax      >L00D7,PC           * 064E 30 8D FA 85    0.z.
                    ldy       #200                * 0652 10 8E 00 C8    ...H
                    lda       #1                  * 0656 86 01          ..
                    os9       I$WritLn            * 0658 10 3F 8C       .?.
                    lda       #1                  * 065B 86 01          ..
                    lbra      L0594               * 065D 16 FF 34       ..4

                    emod
eom                 equ       *
                    end
