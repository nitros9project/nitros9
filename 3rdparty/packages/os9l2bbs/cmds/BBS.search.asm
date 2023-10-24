                    nam       BBS.search
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       3
U0003               rmb       1
U0004               rmb       1
U0005               rmb       2
U0007               rmb       2
U0009               rmb       6
U000F               rmb       3
U0012               rmb       1
U0013               rmb       2
U0015               rmb       1
U0016               rmb       34
U0038               rmb       1
U0039               rmb       1
U003A               rmb       1
U003B               rmb       1
U003C               rmb       1
U003D               rmb       1
U003E               rmb       1
U003F               rmb       1
U0040               rmb       1
U0041               rmb       64
U0081               rmb       4
U0085               rmb       20
U0099               rmb       30
U00B7               rmb       1
U00B8               rmb       1
U00B9               rmb       1
U00BA               rmb       205
size                equ       .

name                fcs       /BBS.search/        * 000D 42 42 53 2E 73 65 61 72 63 E8 BBS.search
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
                    fcc       "High message is #" * 0082 48 69 67 68 20 6D 65 73 73 61 67 65 20 69 73 20 23 High message is #
                    fcb       $00                 * 0093 00             .
                    fcb       $11                 * 0094 11             .
L0095               fcc       "Enter subject search text" * 0095 45 6E 74 65 72 20 73 75 62 6A 65 63 74 20 73 65 61 72 63 68 20 74 65 78 74 Enter subject search text
                    fcb       $0D                 * 00AE 0D             .
L00AF               fcc       ">"                 * 00AF 3E             >
L00B0               fcc       "Msg #    User name              Date        Subject" * 00B0 4D 73 67 20 23 20 20 20 20 55 73 65 72 20 6E 61 6D 65 20 20 20 20 20 20 20 20 20 20 20 20 20 20 44 61 74 65 20 20 20 20 20 20 20 20 53 75 62 6A 65 63 74 Msg #    User nam
                    fcb       $0D                 * 00E3 0D             .
L00E4               fcc       "----------------------------------------------------------------" * 00E4 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 0124 0D             .
L0125               fcc       "BBS.msg.inx"       * 0125 42 42 53 2E 6D 73 67 2E 69 6E 78 BBS.msg.inx
                    fcb       $0D                 * 0130 0D             .
L0131               fcc       "                                       " * 0131 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
L0158               fcc       "          ******   DELETED   ******" * 0158 20 20 20 20 20 20 20 20 20 20 2A 2A 2A 2A 2A 2A 20 20 20 44 45 4C 45 54 45 44 20 20 20 2A 2A 2A 2A 2A 2A           ******   DELETED   ******
                    fcb       $0D                 * 017B 0D             .
start               leax      >L0125,PC           * 017C 30 8D FF A5    0..%
                    lda       #1                  * 0180 86 01          ..
                    os9       I$Open              * 0182 10 3F 84       .?.
                    lbcs      L031D               * 0185 10 25 01 94    .%..
                    sta       U0000,U             * 0189 A7 C4          'D
                    leax      <U0041,U            * 018B 30 C8 41       0HA
                    ldy       #64                 * 018E 10 8E 00 40    ...@
                    lda       U0000,U             * 0192 A6 C4          &D
                    os9       I$Read              * 0194 10 3F 89       .?.
                    lbcs      L031D               * 0197 10 25 01 82    .%..
                    ldd       #0                  * 019B CC 00 00       L..
                    std       U0009,U             * 019E ED 49          mI
L01A0               leax      >L0095,PC           * 01A0 30 8D FE F1    0.~q
                    ldy       #200                * 01A4 10 8E 00 C8    ...H
                    lda       #1                  * 01A8 86 01          ..
                    os9       I$WritLn            * 01AA 10 3F 8C       .?.
                    lbcs      L031D               * 01AD 10 25 01 6C    .%.l
                    leax      >L00AF,PC           * 01B1 30 8D FE FA    0.~z
                    ldy       #1                  * 01B5 10 8E 00 01    ....
                    os9       I$Write             * 01B9 10 3F 8A       .?.
                    lbcs      L031D               * 01BC 10 25 01 5D    .%.]
                    leax      <U0016,U            * 01C0 30 C8 16       0H.
                    ldy       #30                 * 01C3 10 8E 00 1E    ....
                    clra                          * 01C7 4F             O
                    os9       I$ReadLn            * 01C8 10 3F 8B       .?.
                    bcs       L01A0               * 01CB 25 D3          %S
                    clr       <U0015,U            * 01CD 6F C8 15       oH.
                    leax      <U0016,U            * 01D0 30 C8 16       0H.
                    leax      >L00B0,PC           * 01D3 30 8D FE D9    0.~Y
                    ldy       #80                 * 01D7 10 8E 00 50    ...P
                    lda       #1                  * 01DB 86 01          ..
                    os9       I$WritLn            * 01DD 10 3F 8C       .?.
                    lbcs      L031D               * 01E0 10 25 01 39    .%.9
                    leax      >L00E4,PC           * 01E4 30 8D FE FC    0.~|
                    ldy       #80                 * 01E8 10 8E 00 50    ...P
                    os9       I$WritLn            * 01EC 10 3F 8C       .?.
                    lbcs      L031D               * 01EF 10 25 01 2A    .%.*
L01F3               lda       U0000,U             * 01F3 A6 C4          &D
                    ldy       #64                 * 01F5 10 8E 00 40    ...@
                    leax      >U0081,U            * 01F9 30 C9 00 81    0I..
                    os9       I$Read              * 01FD 10 3F 89       .?.
                    lbcs      L031C               * 0200 10 25 01 18    .%..
                    ldd       U0009,U             * 0204 EC 49          lI
                    addd      #1                  * 0206 C3 00 01       C..
                    std       U0009,U             * 0209 ED 49          mI
                    leay      >U0099,U            * 020B 31 C9 00 99    1I..
                    ldb       #30                 * 020F C6 1E          F.
L0211               leax      <U0016,U            * 0211 30 C8 16       0H.
L0214               lda       ,X+                 * 0214 A6 80          &.
                    cmpa      #13                 * 0216 81 0D          ..
                    beq       L0223               * 0218 27 09          '.
                    decb                          * 021A 5A             Z
                    beq       L01F3               * 021B 27 D6          'V
                    cmpa      ,Y+                 * 021D A1 A0          !
                    bne       L0211               * 021F 26 F0          &p
                    bra       L0214               * 0221 20 F1           q
L0223               ldd       >U0081,U            * 0223 EC C9 00 81    lI..
                    cmpd      #-1                 * 0227 10 83 FF FF    ....
                    lbeq      L030C               * 022B 10 27 00 DD    .'.]
                    ldd       U0009,U             * 022F EC 49          lI
                    leax      U000F,U             * 0231 30 4F          0O
                    lbsr      L0387               * 0233 17 01 51       ..Q
                    leax      U000F,U             * 0236 30 4F          0O
                    ldy       #5                  * 0238 10 8E 00 05    ....
                    lda       #1                  * 023C 86 01          ..
                    os9       I$Write             * 023E 10 3F 8A       .?.
                    lbcs      L031D               * 0241 10 25 00 D8    .%.X
                    leax      >L0131,PC           * 0245 30 8D FE E8    0.~h
                    ldy       #4                  * 0249 10 8E 00 04    ....
                    os9       I$Write             * 024D 10 3F 8A       .?.
                    lbcs      L031D               * 0250 10 25 00 C9    .%.I
                    leax      >U0085,U            * 0254 30 C9 00 85    0I..
                    clr       U0003,U             * 0258 6F 43          oC
                    clr       U0004,U             * 025A 6F 44          oD
L025C               lda       ,X+                 * 025C A6 80          &.
                    cmpa      #13                 * 025E 81 0D          ..
                    beq       L0266               * 0260 27 04          '.
                    inc       U0004,U             * 0262 6C 44          lD
                    bra       L025C               * 0264 20 F6           v
L0266               leax      >U0085,U            * 0266 30 C9 00 85    0I..
                    ldy       U0003,U             * 026A 10 AE 43       ..C
                    lda       #1                  * 026D 86 01          ..
                    os9       I$Write             * 026F 10 3F 8A       .?.
                    lbcs      L031D               * 0272 10 25 00 A7    .%.'
                    ldd       #22                 * 0276 CC 00 16       L..
                    subd      U0003,U             * 0279 A3 43          #C
                    tfr       D,Y                 * 027B 1F 02          ..
                    leax      >L0131,PC           * 027D 30 8D FE B0    0.~0
                    lda       #1                  * 0281 86 01          ..
                    os9       I$Write             * 0283 10 3F 8A       .?.
                    lbcs      L031D               * 0286 10 25 00 93    .%..
                    leax      U000F,U             * 028A 30 4F          0O
                    ldb       >U00B8,U            * 028C E6 C9 00 B8    fI.8
                    clra                          * 0290 4F             O
                    lbsr      L0387               * 0291 17 00 F3       ..s
                    lda       <U0012,U            * 0294 A6 C8 12       &H.
                    sta       <U0038,U            * 0297 A7 C8 38       'H8
                    lda       <U0013,U            * 029A A6 C8 13       &H.
                    sta       <U0039,U            * 029D A7 C8 39       'H9
                    lda       #47                 * 02A0 86 2F          ./
                    sta       <U003A,U            * 02A2 A7 C8 3A       'H:
                    ldb       >U00B9,U            * 02A5 E6 C9 00 B9    fI.9
                    clra                          * 02A9 4F             O
                    leax      U000F,U             * 02AA 30 4F          0O
                    lbsr      L0387               * 02AC 17 00 D8       ..X
                    lda       <U0012,U            * 02AF A6 C8 12       &H.
                    sta       <U003B,U            * 02B2 A7 C8 3B       'H;
                    lda       <U0013,U            * 02B5 A6 C8 13       &H.
                    sta       <U003C,U            * 02B8 A7 C8 3C       'H<
                    lda       #47                 * 02BB 86 2F          ./
                    sta       <U003D,U            * 02BD A7 C8 3D       'H=
                    ldb       >U00B7,U            * 02C0 E6 C9 00 B7    fI.7
                    clra                          * 02C4 4F             O
                    leax      U000F,U             * 02C5 30 4F          0O
                    lbsr      L0387               * 02C7 17 00 BD       ..=
                    lda       <U0012,U            * 02CA A6 C8 12       &H.
                    sta       <U003E,U            * 02CD A7 C8 3E       'H>
                    lda       <U0013,U            * 02D0 A6 C8 13       &H.
                    sta       <U003F,U            * 02D3 A7 C8 3F       'H?
                    lda       #13                 * 02D6 86 0D          ..
                    sta       <U0040,U            * 02D8 A7 C8 40       'H@
                    leax      <U0038,U            * 02DB 30 C8 38       0H8
                    ldy       #8                  * 02DE 10 8E 00 08    ....
                    lda       #1                  * 02E2 86 01          ..
                    os9       I$Write             * 02E4 10 3F 8A       .?.
                    lbcs      L031D               * 02E7 10 25 00 32    .%.2
                    ldy       #5                  * 02EB 10 8E 00 05    ....
                    leax      >L0131,PC           * 02EF 30 8D FE 3E    0.~>
                    os9       I$Write             * 02F3 10 3F 8A       .?.
                    lbcs      L031D               * 02F6 10 25 00 23    .%.#
                    leax      >U0099,U            * 02FA 30 C9 00 99    0I..
                    ldy       #30                 * 02FE 10 8E 00 1E    ....
                    os9       I$WritLn            * 0302 10 3F 8C       .?.
                    lbcs      L031D               * 0305 10 25 00 14    .%..
                    lbra      L01F3               * 0309 16 FE E7       .~g
L030C               leax      >L0158,PC           * 030C 30 8D FE 48    0.~H
                    ldy       #200                * 0310 10 8E 00 C8    ...H
                    lda       #1                  * 0314 86 01          ..
                    os9       I$WritLn            * 0316 10 3F 8C       .?.
                    lbra      L01F3               * 0319 16 FE D7       .~W
L031C               clrb                          * 031C 5F             _
L031D               os9       F$Exit              * 031D 10 3F 06       .?.
                    fcb       $34                 * 0320 34             4
                    fcb       $20                 * 0321 20
                    fcb       $A6                 * 0322 A6             &
                    fcb       $80                 * 0323 80             .
                    fcb       $81                 * 0324 81             .
                    fcb       $0D                 * 0325 0D             .
                    fcb       $10                 * 0326 10             .
                    fcb       $27                 * 0327 27             '
                    fcb       $00                 * 0328 00             .
                    fcb       $CB                 * 0329 CB             K
                    fcb       $81                 * 032A 81             .
                    fcb       $30                 * 032B 30             0
                    fcb       $25                 * 032C 25             %
                    fcb       $F4                 * 032D F4             t
                    fcb       $81                 * 032E 81             .
                    fcb       $39                 * 032F 39             9
                    fcb       $22                 * 0330 22             "
                    fcb       $F0                 * 0331 F0             p
                    fcb       $30                 * 0332 30             0
                    fcb       $1F                 * 0333 1F             .
                    fcb       $A6                 * 0334 A6             &
                    fcb       $80                 * 0335 80             .
                    fcb       $81                 * 0336 81             .
                    fcb       $30                 * 0337 30             0
                    fcb       $25                 * 0338 25             %
                    fcb       $06                 * 0339 06             .
                    fcb       $81                 * 033A 81             .
                    fcb       $39                 * 033B 39             9
                    fcb       $22                 * 033C 22             "
                    fcb       $02                 * 033D 02             .
                    fcb       $20                 * 033E 20
                    fcb       $F4                 * 033F F4             t
                    fcb       $34                 * 0340 34             4
                    fcb       $10                 * 0341 10             .
                    fcb       $30                 * 0342 30             0
                    fcb       $1F                 * 0343 1F             .
                    fcc       "oEoF"              * 0344 6F 45 6F 46    oEoF
                    fcb       $CC                 * 0348 CC             L
                    fcb       $00                 * 0349 00             .
                    fcb       $01                 * 034A 01             .
                    fcb       $ED                 * 034B ED             m
                    fcb       $47                 * 034C 47             G
                    fcb       $A6                 * 034D A6             &
                    fcb       $82                 * 034E 82             .
                    fcb       $81                 * 034F 81             .
                    fcc       "0%."               * 0350 30 25 2E       0%.
                    fcb       $81                 * 0353 81             .
                    fcc       /9"*/               * 0354 39 22 2A       9"*
                    fcb       $80                 * 0357 80             .
                    fcb       $30                 * 0358 30             0
                    fcb       $A7                 * 0359 A7             '
                    fcb       $42                 * 035A 42             B
                    fcb       $CC                 * 035B CC             L
                    fcb       $00                 * 035C 00             .
                    fcb       $00                 * 035D 00             .
                    fcc       "mB'"               * 035E 6D 42 27       mB'
                    fcb       $06                 * 0361 06             .
                    fcb       $E3                 * 0362 E3             c
                    fcc       "GjB "              * 0363 47 6A 42 20    GjB
                    fcb       $F6                 * 0367 F6             v
                    fcb       $E3                 * 0368 E3             c
                    fcb       $45                 * 0369 45             E
                    fcb       $ED                 * 036A ED             m
                    fcb       $45                 * 036B 45             E
                    fcb       $86                 * 036C 86             .
                    fcb       $0A                 * 036D 0A             .
                    fcb       $A7                 * 036E A7             '
                    fcb       $42                 * 036F 42             B
                    fcb       $CC                 * 0370 CC             L
                    fcb       $00                 * 0371 00             .
                    fcb       $00                 * 0372 00             .
                    fcc       "mB'"               * 0373 6D 42 27       mB'
                    fcb       $06                 * 0376 06             .
                    fcb       $E3                 * 0377 E3             c
                    fcc       "GjB "              * 0378 47 6A 42 20    GjB
                    fcb       $F6                 * 037C F6             v
                    fcb       $ED                 * 037D ED             m
                    fcb       $47                 * 037E 47             G
                    fcb       $20                 * 037F 20
                    fcb       $CC                 * 0380 CC             L
                    fcb       $EC                 * 0381 EC             l
                    fcb       $45                 * 0382 45             E
                    fcb       $35                 * 0383 35             5
                    fcb       $10                 * 0384 10             .
                    fcb       $35                 * 0385 35             5
                    fcb       $A0                 * 0386 A0
L0387               pshs      X                   * 0387 34 10          4.
                    std       U0005,U             * 0389 ED 45          mE
                    lda       #48                 * 038B 86 30          .0
                    sta       0,X                 * 038D A7 84          '.
                    sta       $01,X               * 038F A7 01          '.
                    sta       $02,X               * 0391 A7 02          '.
                    sta       $03,X               * 0393 A7 03          '.
                    sta       $04,X               * 0395 A7 04          '.
                    ldd       #10000              * 0397 CC 27 10       L'.
                    std       U0007,U             * 039A ED 47          mG
                    ldd       U0005,U             * 039C EC 45          lE
                    lbsr      L03E6               * 039E 17 00 45       ..E
                    ldd       #1000               * 03A1 CC 03 E8       L.h
                    std       U0007,U             * 03A4 ED 47          mG
                    ldd       U0005,U             * 03A6 EC 45          lE
                    bsr       L03E6               * 03A8 8D 3C          .<
                    ldd       #100                * 03AA CC 00 64       L.d
                    std       U0007,U             * 03AD ED 47          mG
                    ldd       U0005,U             * 03AF EC 45          lE
                    bsr       L03E6               * 03B1 8D 33          .3
                    ldd       #10                 * 03B3 CC 00 0A       L..
                    std       U0007,U             * 03B6 ED 47          mG
                    ldd       U0005,U             * 03B8 EC 45          lE
                    bsr       L03E6               * 03BA 8D 2A          .*
                    ldd       #1                  * 03BC CC 00 01       L..
                    std       U0007,U             * 03BF ED 47          mG
                    ldd       U0005,U             * 03C1 EC 45          lE
                    bsr       L03E6               * 03C3 8D 21          .!
                    lda       #13                 * 03C5 86 0D          ..
                    sta       0,X                 * 03C7 A7 84          '.
                    puls      X                   * 03C9 35 10          5.
                    ldb       #32                 * 03CB C6 20          F
L03CD               lda       0,X                 * 03CD A6 84          &.
                    cmpa      #48                 * 03CF 81 30          .0
                    bne       L03D7               * 03D1 26 04          &.
                    stb       ,X+                 * 03D3 E7 80          g.
                    bra       L03CD               * 03D5 20 F6           v
L03D7               lda       ,X+                 * 03D7 A6 80          &.
                    cmpa      #48                 * 03D9 81 30          .0
                    bcs       L03E3               * 03DB 25 06          %.
                    cmpa      #57                 * 03DD 81 39          .9
                    bhi       L03E3               * 03DF 22 02          ".
                    bra       L03D7               * 03E1 20 F4           t
L03E3               leax      -$01,X              * 03E3 30 1F          0.
                    rts                           * 03E5 39             9
L03E6               subd      U0007,U             * 03E6 A3 47          #G
                    bcs       L03EE               * 03E8 25 04          %.
                    inc       0,X                 * 03EA 6C 84          l.
                    bra       L03E6               * 03EC 20 F8           x
L03EE               addd      U0007,U             * 03EE E3 47          cG
                    std       U0005,U             * 03F0 ED 45          mE
                    leax      $01,X               * 03F2 30 01          0.
                    rts                           * 03F4 39             9
                    fcb       $CC                 * 03F5 CC             L
                    fcb       $FF                 * 03F6 FF             .
                    fcb       $FF                 * 03F7 FF             .
                    fcb       $35                 * 03F8 35             5
                    fcb       $A0                 * 03F9 A0

                    emod
eom                 equ       *
                    end
