                    nam       BBS.pack
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
U0005               rmb       3
U0008               rmb       1
U0009               rmb       1
U000A               rmb       2
U000C               rmb       1
U000D               rmb       1
U000E               rmb       1
U000F               rmb       1
U0010               rmb       2
U0012               rmb       2
U0014               rmb       2
U0016               rmb       1
U0017               rmb       1
U0018               rmb       32
U0038               rmb       232
U0120               rmb       2
U0122               rmb       2
U0124               rmb       60
U0160               rmb       80
U01B0               rmb       2
U01B2               rmb       62
U01F0               rmb       1
U01F1               rmb       399
size                equ       .

name                fcs       /BBS.pack/          * 000D 42 42 53 2E 70 61 63 EB BBS.pack
                    fcc       "Copyright (C) 1988" * 0015 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 Copyright (C) 1988
                    fcc       "By Keith Alphonso" * 0027 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F By Keith Alphonso
                    fcc       "Licenced to Alpha Software Technologies" * 0038 4C 69 63 65 6E 63 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licenced to Alpha Software Technologies
                    fcc       "All rights reserved" * 005F 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 All rights reserved
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
L0080               fcc       "BBS.msg"           * 0080 42 42 53 2E 6D 73 67 BBS.msg
                    fcb       $0D                 * 0087 0D             .
L0088               fcc       "BBS.msg.inx"       * 0088 42 42 53 2E 6D 73 67 2E 69 6E 78 BBS.msg.inx
                    fcb       $0D                 * 0093 0D             .
L0094               fcc       "BBs.msg.lst"       * 0094 42 42 73 2E 6D 73 67 2E 6C 73 74 BBs.msg.lst
                    fcb       $0D                 * 009F 0D             .
L00A0               fcb       $0A                 * 00A0 0A             .
                    fcc       "One moment please..." * 00A1 4F 6E 65 20 6D 6F 6D 65 6E 74 20 70 6C 65 61 73 65 2E 2E 2E One moment please...
                    fcb       $0A                 * 00B5 0A             .
                    fcb       $0D                 * 00B6 0D             .
L00B7               fcc       "msg.scratch"       * 00B7 6D 73 67 2E 73 63 72 61 74 63 68 msg.scratch
                    fcb       $0D                 * 00C2 0D             .
L00C3               fcc       "inx.scratch"       * 00C3 69 6E 78 2E 73 63 72 61 74 63 68 inx.scratch
                    fcb       $0D                 * 00CE 0D             .
L00CF               fcc       "."                 * 00CF 2E             .
                    fcb       $0D                 * 00D0 0D             .
                    fcc       "Rename"            * 00D1 52 65 6E 61 6D 65 Rename
                    fcb       $0D                 * 00D7 0D             .
L00D8               fcc       "Packing message..." * 00D8 50 61 63 6B 69 6E 67 20 6D 65 73 73 61 67 65 2E 2E 2E Packing message...
                    fcb       $0D                 * 00EA 0D             .

start               lda       0,X                 * 00EB A6 84          &.
                    cmpa      #13                 * 00ED 81 0D          ..
                    beq       L00FA               * 00EF 27 09          '.
                    lda       #1                  * 00F1 86 01          ..
                    os9       I$ChgDir            * 00F3 10 3F 86       .?.
                    lbcs      L02F7               * 00F6 10 25 01 FD    .%.}
L00FA               leax      >U01F0,U            * 00FA 30 C9 01 F0    0I.p
                    stx       <U0014,U            * 00FE AF C8 14       /H.
                    clr       <U0016,U            * 0101 6F C8 16       oH.
                    clr       <U0017,U            * 0104 6F C8 17       oH.
                    os9       F$ID                * 0107 10 3F 0C       .?.
                    sty       U000A,U             * 010A 10 AF 4A       ./J
                    ldy       #0                  * 010D 10 8E 00 00    ....
                    os9       F$SUser             * 0111 10 3F 1C       .?.
                    clr       U0009,U             * 0114 6F 49          oI
                    clr       U0008,U             * 0116 6F 48          oH
                    leax      >L00A0,PC           * 0118 30 8D FF 84    0...
                    ldy       #200                * 011C 10 8E 00 C8    ...H
                    lda       #1                  * 0120 86 01          ..
                    os9       I$WritLn            * 0122 10 3F 8C       .?.
                    leax      >L0088,PC           * 0125 30 8D FF 5F    0.._
                    lda       #1                  * 0129 86 01          ..
                    os9       I$Open              * 012B 10 3F 84       .?.
                    lbcs      L02F7               * 012E 10 25 01 C5    .%.E
                    sta       U0000,U             * 0132 A7 C4          'D
                    leax      >L0080,PC           * 0134 30 8D FF 48    0..H
                    lda       #1                  * 0138 86 01          ..
                    os9       I$Open              * 013A 10 3F 84       .?.
                    lbcs      L02F7               * 013D 10 25 01 B6    .%.6
                    sta       U0001,U             * 0141 A7 41          'A
                    leax      >L00B7,PC           * 0143 30 8D FF 70    0..p
                    lda       #2                  * 0147 86 02          ..
                    ldb       #11                 * 0149 C6 0B          F.
                    os9       I$Create            * 014B 10 3F 83       .?.
                    lbcs      L02F7               * 014E 10 25 01 A5    .%.%
                    sta       U0002,U             * 0152 A7 42          'B
                    leax      >L00C3,PC           * 0154 30 8D FF 6B    0..k
                    lda       #2                  * 0158 86 02          ..
                    ldb       #11                 * 015A C6 0B          F.
                    os9       I$Create            * 015C 10 3F 83       .?.
                    sta       U0003,U             * 015F A7 43          'C
                    clr       U000C,U             * 0161 6F 4C          oL
                    clr       U000D,U             * 0163 6F 4D          oM
                    clr       U000E,U             * 0165 6F 4E          oN
                    clr       U000F,U             * 0167 6F 4F          oO
                    leax      >U0120,U            * 0169 30 C9 01 20    0I.
                    ldy       #64                 * 016D 10 8E 00 40    ...@
                    lda       U0000,U             * 0171 A6 C4          &D
                    os9       I$Read              * 0173 10 3F 89       .?.
                    lbcs      L02F7               * 0176 10 25 01 7D    .%.}
                    lda       U0002,U             * 017A A6 42          &B
                    os9       I$Write             * 017C 10 3F 8A       .?.
L017F               ldd       <U0016,U            * 017F EC C8 16       lH.
                    addd      #1                  * 0182 C3 00 01       C..
                    std       <U0016,U            * 0185 ED C8 16       mH.
                    leax      >U01B0,U            * 0188 30 C9 01 B0    0I.0
                    ldy       #64                 * 018C 10 8E 00 40    ...@
                    lda       U0000,U             * 0190 A6 C4          &D
                    os9       I$Read              * 0192 10 3F 89       .?.
                    lbcs      L0222               * 0195 10 25 00 89    .%..
                    cmpy      #64                 * 0199 10 8C 00 40    ...@
                    lbne      L0222               * 019D 10 26 00 81    .&..
                    ldd       >U01B0,U            * 01A1 EC C9 01 B0    lI.0
                    cmpd      #-1                 * 01A5 10 83 FF FF    ....
                    beq       L01E7               * 01A9 27 3C          '<
                    ldd       U000C,U             * 01AB EC 4C          lL
                    std       >U01B0,U            * 01AD ED C9 01 B0    mI.0
                    ldd       U000E,U             * 01B1 EC 4E          lN
                    std       >U01B2,U            * 01B3 ED C9 01 B2    mI.2
                    lda       U0002,U             * 01B7 A6 42          &B
                    os9       I$Write             * 01B9 10 3F 8A       .?.
L01BC               lda       U0001,U             * 01BC A6 41          &A
                    leax      >U0160,U            * 01BE 30 C9 01 60    0I.`
                    ldy       #80                 * 01C2 10 8E 00 50    ...P
                    os9       I$ReadLn            * 01C6 10 3F 8B       .?.
                    bcs       L0222               * 01C9 25 57          %W
                    lda       U0003,U             * 01CB A6 43          &C
                    os9       I$WritLn            * 01CD 10 3F 8C       .?.
                    tfr       Y,D                 * 01D0 1F 20          .
                    addd      U000E,U             * 01D2 E3 4E          cN
                    std       U000E,U             * 01D4 ED 4E          mN
                    bcc       L01DF               * 01D6 24 07          $.
                    ldd       U000C,U             * 01D8 EC 4C          lL
                    addd      #1                  * 01DA C3 00 01       C..
                    std       U000C,U             * 01DD ED 4C          mL
L01DF               cmpy      #1                  * 01DF 10 8C 00 01    ....
                    bhi       L01BC               * 01E3 22 D7          "W
                    bra       L017F               * 01E5 20 98           .
L01E7               ldx       <U0014,U            * 01E7 AE C8 14       .H.
                    ldd       <U0016,U            * 01EA EC C8 16       lH.
                    std       ,X++                * 01ED ED 81          m.
                    stx       <U0014,U            * 01EF AF C8 14       /H.
                    leax      >L00D8,PC           * 01F2 30 8D FE E2    0.~b
                    ldy       #200                * 01F6 10 8E 00 C8    ...H
                    lda       #1                  * 01FA 86 01          ..
                    os9       I$WritLn            * 01FC 10 3F 8C       .?.
                    ldd       >U0120,U            * 01FF EC C9 01 20    lI.
                    subd      #1                  * 0203 83 00 01       ...
                    std       >U0120,U            * 0206 ED C9 01 20    mI.
L020A               lda       U0001,U             * 020A A6 41          &A
                    leax      >U0160,U            * 020C 30 C9 01 60    0I.`
                    ldy       #80                 * 0210 10 8E 00 50    ...P
                    os9       I$ReadLn            * 0214 10 3F 8B       .?.
                    bcs       L0222               * 0217 25 09          %.
                    cmpy      #1                  * 0219 10 8C 00 01    ....
                    bhi       L020A               * 021D 22 EB          "k
                    lbra      L017F               * 021F 16 FF 5D       ..]
L0222               ldd       U000C,U             * 0222 EC 4C          lL
                    std       >U0122,U            * 0224 ED C9 01 22    mI."
                    ldd       U000E,U             * 0228 EC 4E          lN
                    std       >U0124,U            * 022A ED C9 01 24    mI.$
                    pshs      U                   * 022E 34 40          4@
                    lda       U0002,U             * 0230 A6 42          &B
                    ldx       #0                  * 0232 8E 00 00       ...
                    ldu       #0                  * 0235 CE 00 00       N..
                    os9       I$Seek              * 0238 10 3F 88       .?.
                    puls      U                   * 023B 35 40          5@
                    lbcs      L02F7               * 023D 10 25 00 B6    .%.6
                    leax      >U0120,U            * 0241 30 C9 01 20    0I.
                    ldy       #64                 * 0245 10 8E 00 40    ...@
                    lda       U0002,U             * 0249 A6 42          &B
                    os9       I$Write             * 024B 10 3F 8A       .?.
                    lda       U0000,U             * 024E A6 C4          &D
                    os9       I$Close             * 0250 10 3F 8F       .?.
                    lbcs      L02F7               * 0253 10 25 00 A0    .%.
                    lda       U0001,U             * 0257 A6 41          &A
                    os9       I$Close             * 0259 10 3F 8F       .?.
                    lbcs      L02F7               * 025C 10 25 00 97    .%..
                    lda       U0002,U             * 0260 A6 42          &B
                    os9       I$Close             * 0262 10 3F 8F       .?.
                    lbcs      L02F7               * 0265 10 25 00 8E    .%..
                    lda       U0003,U             * 0269 A6 43          &C
                    os9       I$Close             * 026B 10 3F 8F       .?.
                    lbcs      L02F7               * 026E 10 25 00 85    .%..
                    leax      >L0088,PC           * 0272 30 8D FE 12    0.~.
                    os9       I$Delete            * 0276 10 3F 87       .?.
                    lbcs      L02F7               * 0279 10 25 00 7A    .%.z
                    leax      >L0080,PC           * 027D 30 8D FD FF    0.}.
                    os9       I$Delete            * 0281 10 3F 87       .?.
                    lbcs      L02F7               * 0284 10 25 00 6F    .%.o
                    leax      >L00B7,PC           * 0288 30 8D FE 2B    0.~+
                    leay      >L0088,PC           * 028C 31 8D FD F8    1.}x
                    lbsr      L0304               * 0290 17 00 71       ..q
                    leax      >L00C3,PC           * 0293 30 8D FE 2C    0.~,
                    leay      >L0080,PC           * 0297 31 8D FD E5    1.}e
                    lbsr      L0304               * 029B 17 00 66       ..f
                    leax      >L0094,PC           * 029E 30 8D FD F2    0.}r
                    lda       #3                  * 02A2 86 03          ..
                    os9       I$Open              * 02A4 10 3F 84       .?.
                    lbcs      L02F6               * 02A7 10 25 00 4B    .%.K
                    sta       U0004,U             * 02AB A7 44          'D
L02AD               lda       U0004,U             * 02AD A6 44          &D
                    leax      <U0010,U            * 02AF 30 C8 10       0H.
                    ldy       #4                  * 02B2 10 8E 00 04    ....
                    os9       I$Read              * 02B6 10 3F 89       .?.
                    lbcs      L02F6               * 02B9 10 25 00 39    .%.9
                    leax      >U01F0,U            * 02BD 30 C9 01 F0    0I.p
                    clr       U0009,U             * 02C1 6F 49          oI
L02C3               ldd       ,X++                * 02C3 EC 81          l.
                    cmpd      <U0012,U            * 02C5 10 A3 C8 12    .#H.
                    bhi       L02CD               * 02C9 22 02          ".
                    inc       U0009,U             * 02CB 6C 49          lI
L02CD               cmpx      <U0014,U            * 02CD AC C8 14       ,H.
                    bcs       L02C3               * 02D0 25 F1          %q
                    ldd       <U0012,U            * 02D2 EC C8 12       lH.
                    subd      U0008,U             * 02D5 A3 48          #H
                    std       <U0012,U            * 02D7 ED C8 12       mH.
                    lda       U0004,U             * 02DA A6 44          &D
                    ldb       #5                  * 02DC C6 05          F.
                    pshs      U                   * 02DE 34 40          4@
                    os9       I$GetStt            * 02E0 10 3F 8D       .?.
                    leau      -$02,U              * 02E3 33 5E          3^
                    os9       I$Seek              * 02E5 10 3F 88       .?.
                    puls      U                   * 02E8 35 40          5@
                    leax      <U0012,U            * 02EA 30 C8 12       0H.
                    ldy       #2                  * 02ED 10 8E 00 02    ....
                    os9       I$Write             * 02F1 10 3F 8A       .?.
                    bra       L02AD               * 02F4 20 B7           7
L02F6               clrb                          * 02F6 5F             _
L02F7               pshs      B                   * 02F7 34 04          4.
                    ldy       U000A,U             * 02F9 10 AE 4A       ..J
                    os9       F$SUser             * 02FC 10 3F 1C       .?.
                    puls      B                   * 02FF 35 04          5.
                    os9       F$Exit              * 0301 10 3F 06       .?.
L0304               leax      >L00CF,PC           * 0304 30 8D FD C7    0.}G
                    lda       #131                * 0308 86 83          ..
                    os9       I$Open              * 030A 10 3F 84       .?.
                    lbcs      L02F7               * 030D 10 25 FF E6    .%.f
                    sta       U0005,U             * 0311 A7 45          'E
                    clr       <U0038,U            * 0313 6F C8 38       oH8
L0316               pshs      U                   * 0316 34 40          4@
                    lda       <U0038,U            * 0318 A6 C8 38       &H8
                    inca                          * 031B 4C             L
                    sta       <U0038,U            * 031C A7 C8 38       'H8
                    ldb       #32                 * 031F C6 20          F
                    mul                           * 0321 3D             =
                    tfr       D,X                 * 0322 1F 01          ..
                    lda       U0005,U             * 0324 A6 45          &E
                    ldu       #0                  * 0326 CE 00 00       N..
                    exg       X,U                 * 0329 1E 13          ..
                    os9       I$Seek              * 032B 10 3F 88       .?.
                    puls      U                   * 032E 35 40          5@
                    leax      <U0018,U            * 0330 30 C8 18       0H.
                    ldy       #32                 * 0333 10 8E 00 20    ...
                    lda       U0005,U             * 0337 A6 45          &E
                    os9       I$Read              * 0339 10 3F 89       .?.
                    bcs       L0362               * 033C 25 24          %$
                    leay      >L00B7,PC           * 033E 31 8D FD 75    1.}u
                    leax      <U0018,U            * 0342 30 C8 18       0H.
L0345               lda       ,X+                 * 0345 A6 80          &.
                    bmi       L036E               * 0347 2B 25          +%
                    cmpa      ,Y+                 * 0349 A1 A0          !
                    bne       L034F               * 034B 26 02          &.
                    bra       L0345               * 034D 20 F6           v
L034F               leax      <U0018,U            * 034F 30 C8 18       0H.
                    leay      >L00C3,PC           * 0352 31 8D FD 6D    1.}m
L0356               lda       ,X+                 * 0356 A6 80          &.
                    bmi       L0383               * 0358 2B 29          +)
                    cmpa      ,Y+                 * 035A A1 A0          !
                    bne       L0360               * 035C 26 02          &.
                    bra       L0356               * 035E 20 F6           v
L0360               bra       L0316               * 0360 20 B4           4
L0362               cmpb      #211                * 0362 C1 D3          AS
                    lbne      L02F7               * 0364 10 26 FF 8F    .&..
                    lda       U0005,U             * 0368 A6 45          &E
                    os9       I$Close             * 036A 10 3F 8F       .?.
                    rts                           * 036D 39             9
L036E               anda      #127                * 036E 84 7F          ..
                    cmpa      ,Y+                 * 0370 A1 A0          !
                    bne       L034F               * 0372 26 DB          &[
                    lda       ,Y+                 * 0374 A6 A0          &
                    cmpa      #13                 * 0376 81 0D          ..
                    bne       L034F               * 0378 26 D5          &U
                    leax      <U0018,U            * 037A 30 C8 18       0H.
                    leay      >L0088,PC           * 037D 31 8D FD 07    1.}.
                    bra       L0396               * 0381 20 13           .
L0383               anda      #127                * 0383 84 7F          ..
                    cmpa      ,Y+                 * 0385 A1 A0          !
                    bne       L0360               * 0387 26 D7          &W
                    lda       #13                 * 0389 86 0D          ..
                    cmpa      ,Y+                 * 038B A1 A0          !
                    bne       L0360               * 038D 26 D1          &Q
                    leax      <U0018,U            * 038F 30 C8 18       0H.
                    leay      >L0080,PC           * 0392 31 8D FC EA    1.|j
L0396               lda       ,Y+                 * 0396 A6 A0          &
                    cmpa      #13                 * 0398 81 0D          ..
                    beq       L03A0               * 039A 27 04          '.
                    sta       ,X+                 * 039C A7 80          '.
                    bra       L0396               * 039E 20 F6           v
L03A0               lda       ,-X                 * 03A0 A6 82          &.
                    ora       #128                * 03A2 8A 80          ..
                    sta       0,X                 * 03A4 A7 84          '.
                    lda       <U0038,U            * 03A6 A6 C8 38       &H8
                    ldb       #32                 * 03A9 C6 20          F
                    mul                           * 03AB 3D             =
                    tfr       D,X                 * 03AC 1F 01          ..
                    lda       U0005,U             * 03AE A6 45          &E
                    ldb       #5                  * 03B0 C6 05          F.
                    pshs      U                   * 03B2 34 40          4@
                    ldu       #0                  * 03B4 CE 00 00       N..
                    exg       X,U                 * 03B7 1E 13          ..
                    os9       I$Seek              * 03B9 10 3F 88       .?.
                    lbcs      L02F7               * 03BC 10 25 FF 37    .%.7
                    puls      U                   * 03C0 35 40          5@
                    leax      <U0018,U            * 03C2 30 C8 18       0H.
                    ldy       #32                 * 03C5 10 8E 00 20    ...
                    lda       U0005,U             * 03C9 A6 45          &E
                    os9       I$Write             * 03CB 10 3F 8A       .?.
                    ldb       #211                * 03CE C6 D3          FS
                    lbra      L0362               * 03D0 16 FF 8F       ...
                    fcb       $16                 * 03D3 16             .
                    fcb       $FF                 * 03D4 FF             .
                    fcb       $40                 * 03D5 40             @

                    emod
eom                 equ       *
                    end
