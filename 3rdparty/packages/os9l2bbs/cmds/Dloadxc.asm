                    nam       Dloadxc
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
U0004               rmb       2
U0006               rmb       1
U0007               rmb       2
U0009               rmb       2
U000B               rmb       10
U0015               rmb       1
U0016               rmb       1
U0017               rmb       1
U0018               rmb       128
U0098               rmb       1
U0099               rmb       1
U009A               rmb       32
U00BA               rmb       2
U00BC               rmb       1
U00BD               rmb       231
size                equ       .

name                fcs       /Dloadxc/           * 000D 44 6C 6F 61 64 78 E3 Dloadxc
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
L007F               fcc       "Enter filename to download-->" * 007F 45 6E 74 65 72 20 66 69 6C 65 6E 61 6D 65 20 74 6F 20 64 6F 77 6E 6C 6F 61 64 2D 2D 3E Enter filename to download-->
L009C               fcb       $00                 * 009C 00             .
                    fcb       $1D                 * 009D 1D             .
L009E               fcc       "File open, ready to send..." * 009E 46 69 6C 65 20 6F 70 65 6E 2C 20 72 65 61 64 79 20 74 6F 20 73 65 6E 64 2E 2E 2E File open, ready to send...
                    fcb       $0D                 * 00B9 0D             .
L00BA               fcc       "File transfer successful" * 00BA 46 69 6C 65 20 74 72 61 6E 73 66 65 72 20 73 75 63 63 65 73 73 66 75 6C File transfer successful
                    fcb       $0D                 * 00D2 0D             .
L00D3               fcc       "File transfer unsuccessful" * 00D3 46 69 6C 65 20 74 72 61 6E 73 66 65 72 20 75 6E 73 75 63 63 65 73 73 66 75 6C File transfer unsuccessful
                    fcb       $0D                 * 00ED 0D             .
L00EE               fcc       "Press <CTRL><X> to abort" * 00EE 50 72 65 73 73 20 3C 43 54 52 4C 3E 3C 58 3E 20 74 6F 20 61 62 6F 72 74 Press <CTRL><X> to abort
                    fcb       $0D                 * 0106 0D             .
L0107               fcb       $04                 * 0107 04             .
L0108               fcb       $0A                 * 0108 0A             .
                    fcb       $0D                 * 0109 0D             .
L010A               fcc       "Total number of blocks to download:" * 010A 54 6F 74 61 6C 20 6E 75 6D 62 65 72 20 6F 66 20 62 6C 6F 63 6B 73 20 74 6F 20 64 6F 77 6E 6C 6F 61 64 3A Total number of blocks to download:
L012D               lda       #255                * 012D 86 FF          ..
                    sta       U0002,U             * 012F A7 42          'B
                    leax      >U00BC,U            * 0131 30 C9 00 BC    0I.<
                    clra                          * 0135 4F             O
                    clrb                          * 0136 5F             _
                    os9       I$GetStt            * 0137 10 3F 8D       .?.
                    leax      -$20,X              * 013A 30 88 E0       0.`
                    clr       <$0024,X            * 013D 6F 88 24       o.$
                    leax      >U00BC,U            * 0140 30 C9 00 BC    0I.<
                    clra                          * 0144 4F             O
                    clrb                          * 0145 5F             _
                    os9       I$SetStt            * 0146 10 3F 8E       .?.
                    rts                           * 0149 39             9
start               lda       0,X                 * 014A A6 84          &.
                    cmpa      #13                 * 014C 81 0D          ..
                    bne       L016A               * 014E 26 1A          &.
                    leax      >L007F,PC           * 0150 30 8D FF 2B    0..+
                    ldy       >L009C,PC           * 0154 10 AE 8D FF 43 ....C
                    lda       #1                  * 0159 86 01          ..
                    os9       I$Write             * 015B 10 3F 8A       .?.
                    leax      >U009A,U            * 015E 30 C9 00 9A    0I..
                    ldy       #32                 * 0162 10 8E 00 20    ...
                    clra                          * 0166 4F             O
                    os9       I$ReadLn            * 0167 10 3F 8B       .?.
L016A               stx       >U00BA,U            * 016A AF C9 00 BA    /I.:
                    lbsr      L012D               * 016E 17 FF BC       ..<
                    lda       #1                  * 0171 86 01          ..
                    ldx       >U00BA,U            * 0173 AE C9 00 BA    .I.:
                    os9       I$Open              * 0177 10 3F 84       .?.
                    lbcs      L031D               * 017A 10 25 01 9F    .%..
                    sta       U0000,U             * 017E A7 C4          'D
                    leax      >L010A,PC           * 0180 30 8D FF 86    0...
                    ldy       #35                 * 0184 10 8E 00 23    ...#
                    lda       #1                  * 0188 86 01          ..
                    os9       I$Write             * 018A 10 3F 8A       .?.
                    lda       U0000,U             * 018D A6 C4          &D
                    ldb       #2                  * 018F C6 02          F.
                    pshs      U                   * 0191 34 40          4@
                    os9       I$GetStt            * 0193 10 3F 8D       .?.
                    tfr       U,Y                 * 0196 1F 32          .2
                    puls      U                   * 0198 35 40          5@
                    lda       #7                  * 019A 86 07          ..
                    sta       U0006,U             * 019C A7 46          'F
L019E               tfr       X,D                 * 019E 1F 10          ..
                    lsra                          * 01A0 44             D
                    rorb                          * 01A1 56             V
                    tfr       D,X                 * 01A2 1F 01          ..
                    tfr       Y,D                 * 01A4 1F 20          .
                    rora                          * 01A6 46             F
                    rorb                          * 01A7 56             V
                    tfr       D,Y                 * 01A8 1F 02          ..
                    dec       U0006,U             * 01AA 6A 46          jF
                    bne       L019E               * 01AC 26 F0          &p
                    tfr       Y,D                 * 01AE 1F 20          .
                    leax      U000B,U             * 01B0 30 4B          0K
                    addd      #1                  * 01B2 C3 00 01       C..
                    lbsr      L039D               * 01B5 17 01 E5       ..e
                    leax      U000B,U             * 01B8 30 4B          0K
                    ldy       #5                  * 01BA 10 8E 00 05    ....
                    lda       #1                  * 01BE 86 01          ..
                    os9       I$Write             * 01C0 10 3F 8A       .?.
                    leax      >L0108,PC           * 01C3 30 8D FF 41    0..A
                    ldy       #1                  * 01C7 10 8E 00 01    ....
                    lda       #1                  * 01CB 86 01          ..
                    os9       I$WritLn            * 01CD 10 3F 8C       .?.
                    leax      >L00EE,PC           * 01D0 30 8D FF 1A    0...
                    ldy       #200                * 01D4 10 8E 00 C8    ...H
                    lda       #1                  * 01D8 86 01          ..
                    os9       I$WritLn            * 01DA 10 3F 8C       .?.
                    leax      >L009E,PC           * 01DD 30 8D FE BD    0.~=
                    ldy       #200                * 01E1 10 8E 00 C8    ...H
                    lda       #1                  * 01E5 86 01          ..
                    os9       I$WritLn            * 01E7 10 3F 8C       .?.
L01EA               leax      U0001,U             * 01EA 30 41          0A
                    ldy       #1                  * 01EC 10 8E 00 01    ....
                    clra                          * 01F0 4F             O
                    os9       I$Read              * 01F1 10 3F 89       .?.
                    lda       U0001,U             * 01F4 A6 41          &A
                    cmpa      #67                 * 01F6 81 43          .C
                    beq       L0206               * 01F8 27 0C          '.
                    cmpa      #24                 * 01FA 81 18          ..
                    lbeq      L030F               * 01FC 10 27 01 0F    .'..
                    cmpa      #21                 * 0200 81 15          ..
                    bne       L01EA               * 0202 26 E6          &f
                    bra       L0208               * 0204 20 02           .
L0206               clr       U0002,U             * 0206 6F 42          oB
L0208               lda       #1                  * 0208 86 01          ..
                    sta       <U0015,U            * 020A A7 C8 15       'H.
                    sta       <U0016,U            * 020D A7 C8 16       'H.
                    coma                          * 0210 43             C
                    sta       <U0017,U            * 0211 A7 C8 17       'H.
L0214               leax      <U0018,U            * 0214 30 C8 18       0H.
                    ldy       #128                * 0217 10 8E 00 80    ....
                    lda       U0000,U             * 021B A6 C4          &D
                    os9       I$Read              * 021D 10 3F 89       .?.
                    lbcs      L02DD               * 0220 10 25 00 B9    .%.9
                    cmpy      #128                * 0224 10 8C 00 80    ....
                    beq       L023C               * 0228 27 12          '.
                    tfr       Y,D                 * 022A 1F 20          .
                    leax      D,X                 * 022C 30 8B          0.
                    clra                          * 022E 4F             O
L022F               sta       ,X+                 * 022F A7 80          '.
                    leay      $01,Y               * 0231 31 21          1!
                    cmpy      #128                * 0233 10 8C 00 80    ....
                    bcs       L022F               * 0237 25 F6          %v
                    leax      <U0018,U            * 0239 30 C8 18       0H.
L023C               tst       U0002,U             * 023C 6D 42          mB
                    beq       L0255               * 023E 27 15          '.
                    clr       >U0098,U            * 0240 6F C9 00 98    oI..
                    ldb       #128                * 0244 C6 80          F.
L0246               lda       ,X+                 * 0246 A6 80          &.
                    adda      >U0098,U            * 0248 AB C9 00 98    +I..
                    sta       >U0098,U            * 024C A7 C9 00 98    'I..
                    decb                          * 0250 5A             Z
                    bne       L0246               * 0251 26 F3          &s
                    bra       L029D               * 0253 20 48           H
L0255               ldd       #0                  * 0255 CC 00 00       L..
                    std       >U0098,U            * 0258 ED C9 00 98    mI..
                    lda       #128                * 025C 86 80          ..
                    sta       U0003,U             * 025E A7 43          'C
L0260               lda       ,X+                 * 0260 A6 80          &.
                    clrb                          * 0262 5F             _
                    eora      >U0098,U            * 0263 A8 C9 00 98    (I..
                    eorb      >U0099,U            * 0267 E8 C9 00 99    hI..
                    std       >U0098,U            * 026B ED C9 00 98    mI..
                    lda       #8                  * 026F 86 08          ..
                    sta       U0004,U             * 0271 A7 44          'D
L0273               lda       >U0098,U            * 0273 A6 C9 00 98    &I..
                    bita      #128                * 0277 85 80          ..
                    beq       L028B               * 0279 27 10          '.
                    ldd       >U0098,U            * 027B EC C9 00 98    lI..
                    aslb                          * 027F 58             X
                    rola                          * 0280 49             I
                    eora      #16                 * 0281 88 10          ..
                    eorb      #33                 * 0283 C8 21          H!
                    std       >U0098,U            * 0285 ED C9 00 98    mI..
                    bra       L0291               * 0289 20 06           .
L028B               aslb                          * 028B 58             X
                    rola                          * 028C 49             I
                    std       >U0098,U            * 028D ED C9 00 98    mI..
L0291               dec       U0004,U             * 0291 6A 44          jD
                    bne       L0273               * 0293 26 DE          &^
                    dec       U0003,U             * 0295 6A 43          jC
                    bne       L0260               * 0297 26 C7          &G
                    ldd       >U0098,U            * 0299 EC C9 00 98    lI..
L029D               leax      <U0015,U            * 029D 30 C8 15       0H.
                    tst       U0002,U             * 02A0 6D 42          mB
                    beq       L02AA               * 02A2 27 06          '.
                    ldy       #132                * 02A4 10 8E 00 84    ....
                    bra       L02AE               * 02A8 20 04           .
L02AA               ldy       #133                * 02AA 10 8E 00 85    ....
L02AE               lda       #1                  * 02AE 86 01          ..
                    os9       I$Write             * 02B0 10 3F 8A       .?.
                    leax      U0001,U             * 02B3 30 41          0A
                    ldy       #1                  * 02B5 10 8E 00 01    ....
                    clra                          * 02B9 4F             O
                    os9       I$Read              * 02BA 10 3F 89       .?.
                    lda       U0001,U             * 02BD A6 41          &A
                    cmpa      #21                 * 02BF 81 15          ..
                    beq       L029D               * 02C1 27 DA          'Z
                    cmpa      #6                  * 02C3 81 06          ..
                    beq       L02CF               * 02C5 27 08          '.
                    cmpa      #24                 * 02C7 81 18          ..
                    beq       L030F               * 02C9 27 44          'D
                    lda       #1                  * 02CB 86 01          ..
                    bra       L031D               * 02CD 20 4E           N
L02CF               lda       <U0016,U            * 02CF A6 C8 16       &H.
                    inca                          * 02D2 4C             L
                    sta       <U0016,U            * 02D3 A7 C8 16       'H.
                    coma                          * 02D6 43             C
                    sta       <U0017,U            * 02D7 A7 C8 17       'H.
                    lbra      L0214               * 02DA 16 FF 37       ..7
L02DD               cmpb      #211                * 02DD C1 D3          AS
                    lbne      L031D               * 02DF 10 26 00 3A    .&.:
                    leax      >L0107,PC           * 02E3 30 8D FE 20    0.~
                    ldy       #1                  * 02E7 10 8E 00 01    ....
                    lda       #1                  * 02EB 86 01          ..
                    os9       I$Write             * 02ED 10 3F 8A       .?.
                    leax      U0001,U             * 02F0 30 41          0A
                    ldy       #1                  * 02F2 10 8E 00 01    ....
                    clra                          * 02F6 4F             O
                    os9       I$Read              * 02F7 10 3F 89       .?.
                    lda       U0001,U             * 02FA A6 41          &A
                    cmpa      #6                  * 02FC 81 06          ..
                    bne       L030F               * 02FE 26 0F          &.
                    leax      >L00BA,PC           * 0300 30 8D FD B6    0.}6
                    ldy       #200                * 0304 10 8E 00 C8    ...H
                    lda       #1                  * 0308 86 01          ..
                    os9       I$WritLn            * 030A 10 3F 8C       .?.
                    bra       L031C               * 030D 20 0D           .
L030F               leax      >L00D3,PC           * 030F 30 8D FD C0    0.}@
                    ldy       #200                * 0313 10 8E 00 C8    ...H
                    lda       #1                  * 0317 86 01          ..
                    os9       I$WritLn            * 0319 10 3F 8C       .?.
L031C               clrb                          * 031C 5F             _
L031D               pshs      B                   * 031D 34 04          4.
                    bsr       L0326               * 031F 8D 05          ..
                    puls      B                   * 0321 35 04          5.
                    os9       F$Exit              * 0323 10 3F 06       .?.
L0326               leax      >U00BC,U            * 0326 30 C9 00 BC    0I.<
                    leax      -$20,X              * 032A 30 88 E0       0.`
                    lda       #1                  * 032D 86 01          ..
                    sta       <$0024,X            * 032F A7 88 24       '.$
                    leax      >U00BC,U            * 0332 30 C9 00 BC    0I.<
                    clra                          * 0336 4F             O
                    clrb                          * 0337 5F             _
                    os9       I$SetStt            * 0338 10 3F 8E       .?.
                    rts                           * 033B 39             9
                    fcb       $34                 * 033C 34             4
                    fcb       $20                 * 033D 20
                    fcb       $A6                 * 033E A6             &
                    fcb       $80                 * 033F 80             .
                    fcb       $81                 * 0340 81             .
                    fcb       $30                 * 0341 30             0
                    fcb       $25                 * 0342 25             %
                    fcb       $FA                 * 0343 FA             z
                    fcb       $81                 * 0344 81             .
                    fcb       $39                 * 0345 39             9
                    fcb       $22                 * 0346 22             "
                    fcb       $F6                 * 0347 F6             v
                    fcb       $30                 * 0348 30             0
                    fcb       $1F                 * 0349 1F             .
                    fcb       $A6                 * 034A A6             &
                    fcb       $80                 * 034B 80             .
                    fcb       $81                 * 034C 81             .
                    fcb       $30                 * 034D 30             0
                    fcb       $25                 * 034E 25             %
                    fcb       $06                 * 034F 06             .
                    fcb       $81                 * 0350 81             .
                    fcb       $39                 * 0351 39             9
                    fcb       $22                 * 0352 22             "
                    fcb       $02                 * 0353 02             .
                    fcb       $20                 * 0354 20
                    fcb       $F4                 * 0355 F4             t
                    fcb       $34                 * 0356 34             4
                    fcb       $10                 * 0357 10             .
                    fcb       $30                 * 0358 30             0
                    fcb       $1F                 * 0359 1F             .
                    fcc       "oGoH"              * 035A 6F 47 6F 48    oGoH
                    fcb       $CC                 * 035E CC             L
                    fcb       $00                 * 035F 00             .
                    fcb       $01                 * 0360 01             .
                    fcb       $ED                 * 0361 ED             m
                    fcb       $49                 * 0362 49             I
                    fcb       $A6                 * 0363 A6             &
                    fcb       $82                 * 0364 82             .
                    fcb       $81                 * 0365 81             .
                    fcc       "0%."               * 0366 30 25 2E       0%.
                    fcb       $81                 * 0369 81             .
                    fcc       /9"*/               * 036A 39 22 2A       9"*
                    fcb       $80                 * 036D 80             .
                    fcb       $30                 * 036E 30             0
                    fcb       $A7                 * 036F A7             '
                    fcb       $45                 * 0370 45             E
                    fcb       $CC                 * 0371 CC             L
                    fcb       $00                 * 0372 00             .
                    fcb       $00                 * 0373 00             .
                    fcc       "mE'"               * 0374 6D 45 27       mE'
                    fcb       $06                 * 0377 06             .
                    fcb       $E3                 * 0378 E3             c
                    fcc       "IjE "              * 0379 49 6A 45 20    IjE
                    fcb       $F6                 * 037D F6             v
                    fcb       $E3                 * 037E E3             c
                    fcb       $47                 * 037F 47             G
                    fcb       $ED                 * 0380 ED             m
                    fcb       $47                 * 0381 47             G
                    fcb       $86                 * 0382 86             .
                    fcb       $0A                 * 0383 0A             .
                    fcb       $A7                 * 0384 A7             '
                    fcb       $45                 * 0385 45             E
                    fcb       $CC                 * 0386 CC             L
                    fcb       $00                 * 0387 00             .
                    fcb       $00                 * 0388 00             .
                    fcc       "mE'"               * 0389 6D 45 27       mE'
                    fcb       $06                 * 038C 06             .
                    fcb       $E3                 * 038D E3             c
                    fcc       "IjE "              * 038E 49 6A 45 20    IjE
                    fcb       $F6                 * 0392 F6             v
                    fcb       $ED                 * 0393 ED             m
                    fcb       $49                 * 0394 49             I
                    fcb       $20                 * 0395 20
                    fcb       $CC                 * 0396 CC             L
                    fcb       $EC                 * 0397 EC             l
                    fcb       $47                 * 0398 47             G
                    fcb       $35                 * 0399 35             5
                    fcb       $10                 * 039A 10             .
                    fcb       $35                 * 039B 35             5
                    fcb       $A0                 * 039C A0
L039D               std       U0007,U             * 039D ED 47          mG
                    lda       #48                 * 039F 86 30          .0
                    sta       0,X                 * 03A1 A7 84          '.
                    sta       $01,X               * 03A3 A7 01          '.
                    sta       $02,X               * 03A5 A7 02          '.
                    sta       $03,X               * 03A7 A7 03          '.
                    sta       $04,X               * 03A9 A7 04          '.
                    ldd       #10000              * 03AB CC 27 10       L'.
                    std       U0009,U             * 03AE ED 49          mI
                    ldd       U0007,U             * 03B0 EC 47          lG
                    lbsr      L03DE               * 03B2 17 00 29       ..)
                    ldd       #1000               * 03B5 CC 03 E8       L.h
                    std       U0009,U             * 03B8 ED 49          mI
                    ldd       U0007,U             * 03BA EC 47          lG
                    bsr       L03DE               * 03BC 8D 20          .
                    ldd       #100                * 03BE CC 00 64       L.d
                    std       U0009,U             * 03C1 ED 49          mI
                    ldd       U0007,U             * 03C3 EC 47          lG
                    bsr       L03DE               * 03C5 8D 17          ..
                    ldd       #10                 * 03C7 CC 00 0A       L..
                    std       U0009,U             * 03CA ED 49          mI
                    ldd       U0007,U             * 03CC EC 47          lG
                    bsr       L03DE               * 03CE 8D 0E          ..
                    ldd       #1                  * 03D0 CC 00 01       L..
                    std       U0009,U             * 03D3 ED 49          mI
                    ldd       U0007,U             * 03D5 EC 47          lG
                    bsr       L03DE               * 03D7 8D 05          ..
                    lda       #13                 * 03D9 86 0D          ..
                    sta       0,X                 * 03DB A7 84          '.
                    rts                           * 03DD 39             9
L03DE               subd      U0009,U             * 03DE A3 49          #I
                    bcs       L03E6               * 03E0 25 04          %.
                    inc       0,X                 * 03E2 6C 84          l.
                    bra       L03DE               * 03E4 20 F8           x
L03E6               addd      U0009,U             * 03E6 E3 49          cI
                    std       U0007,U             * 03E8 ED 47          mG
                    leax      $01,X               * 03EA 30 01          0.
                    rts                           * 03EC 39             9

                    emod
eom                 equ       *
                    end
