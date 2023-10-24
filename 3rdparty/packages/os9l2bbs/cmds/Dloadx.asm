                    nam       Dloadx
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
U0002               rmb       2
U0004               rmb       2
U0006               rmb       2
U0008               rmb       10
U0012               rmb       1
U0013               rmb       1
U0014               rmb       1
U0015               rmb       128
U0095               rmb       1
U0096               rmb       32
U00B6               rmb       2
U00B8               rmb       1
U00B9               rmb       231
size                equ       .

name                fcs       /Dloadx/            * 000D 44 6C 6F 61 64 F8 Dloadx
                    fcc       "Copyright (C) 1988By Keith AlphonsoLicenced to Alpha Software TechnologiesAll rights reserved" * 0013 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 4C 69 63 65 6E 63 65 64
                    fcb       $EC                 * 0070 EC             l
                    fcb       $E6                 * 0071 E6             f
                    fcb       $EA                 * 0072 EA             j
                    fcb       $F5                 * 0073 F5             u
                    fcb       $E9                 * 0074 E9             i
                    fcb       $A0                 * 0075 A0
                    fcb       $E2                 * 0076 E2             b
                    fcb       $ED                 * 0077 ED             m
                    fcb       $F1                 * 0078 F1             q
                    fcb       $E9                 * 0079 E9             i
                    fcb       $F0                 * 007A F0             p
                    fcb       $EF                 * 007B EF             o
                    fcb       $F4                 * 007C F4             t
                    fcb       $F0                 * 007D F0             p
L007E               fcc       "Enter filename to download-->" * 007E 45 6E 74 65 72 20 66 69 6C 65 6E 61 6D 65 20 74 6F 20 64 6F 77 6E 6C 6F 61 64 2D 2D 3E Enter filename to download-->
L009B               fcb       $00                 * 009B 00             .
                    fcb       $1D                 * 009C 1D             .
L009D               fcc       "File open, ready to send..." * 009D 46 69 6C 65 20 6F 70 65 6E 2C 20 72 65 61 64 79 20 74 6F 20 73 65 6E 64 2E 2E 2E File open, ready to send...
                    fcb       $0D                 * 00B8 0D             .
L00B9               fcc       "File transfer successful" * 00B9 46 69 6C 65 20 74 72 61 6E 73 66 65 72 20 73 75 63 63 65 73 73 66 75 6C File transfer successful
                    fcb       $0D                 * 00D1 0D             .
L00D2               fcc       "File transfer unsuccessful" * 00D2 46 69 6C 65 20 74 72 61 6E 73 66 65 72 20 75 6E 73 75 63 63 65 73 73 66 75 6C File transfer unsuccessful
                    fcb       $0D                 * 00EC 0D             .
L00ED               fcc       "Press <CTRL><X> to abort" * 00ED 50 72 65 73 73 20 3C 43 54 52 4C 3E 3C 58 3E 20 74 6F 20 61 62 6F 72 74 Press <CTRL><X> to abort
                    fcb       $0D                 * 0105 0D             .
L0106               fcb       $04                 * 0106 04             .
L0107               fcb       $0A                 * 0107 0A             .
                    fcb       $0D                 * 0108 0D             .
L0109               fcc       "Total number of blocks to download:" * 0109 54 6F 74 61 6C 20 6E 75 6D 62 65 72 20 6F 66 20 62 6C 6F 63 6B 73 20 74 6F 20 64 6F 77 6E 6C 6F 61 64 3A Total number of blocks to download:
L012C               leax      >U00B8,U            * 012C 30 C9 00 B8    0I.8
                    clra                          * 0130 4F             O
                    clrb                          * 0131 5F             _
                    os9       I$GetStt            * 0132 10 3F 8D       .?.
                    leax      -$20,X              * 0135 30 88 E0       0.`
                    clr       <$0024,X            * 0138 6F 88 24       o.$
                    leax      >U00B8,U            * 013B 30 C9 00 B8    0I.8
                    clra                          * 013F 4F             O
                    clrb                          * 0140 5F             _
                    os9       I$SetStt            * 0141 10 3F 8E       .?.
                    rts                           * 0144 39             9
start               lda       0,X                 * 0145 A6 84          &.
                    cmpa      #13                 * 0147 81 0D          ..
                    bne       L0165               * 0149 26 1A          &.
                    leax      >L007E,PC           * 014B 30 8D FF 2F    0../
                    ldy       >L009B,PC           * 014F 10 AE 8D FF 47 ....G
                    lda       #1                  * 0154 86 01          ..
                    os9       I$Write             * 0156 10 3F 8A       .?.
                    leax      >U0096,U            * 0159 30 C9 00 96    0I..
                    ldy       #32                 * 015D 10 8E 00 20    ...
                    clra                          * 0161 4F             O
                    os9       I$ReadLn            * 0162 10 3F 8B       .?.
L0165               stx       >U00B6,U            * 0165 AF C9 00 B6    /I.6
                    lbsr      L012C               * 0169 17 FF C0       ..@
                    lda       #1                  * 016C 86 01          ..
                    ldx       >U00B6,U            * 016E AE C9 00 B6    .I.6
                    os9       I$Open              * 0172 10 3F 84       .?.
                    lbcs      L02B5               * 0175 10 25 01 3C    .%.<
                    sta       U0000,U             * 0179 A7 C4          'D
                    leax      >L0109,PC           * 017B 30 8D FF 8A    0...
                    ldy       #35                 * 017F 10 8E 00 23    ...#
                    lda       #1                  * 0183 86 01          ..
                    os9       I$Write             * 0185 10 3F 8A       .?.
                    lda       U0000,U             * 0188 A6 C4          &D
                    ldb       #2                  * 018A C6 02          F.
                    pshs      U                   * 018C 34 40          4@
                    os9       I$GetStt            * 018E 10 3F 8D       .?.
                    tfr       U,Y                 * 0191 1F 32          .2
                    puls      U                   * 0193 35 40          5@
                    lda       #7                  * 0195 86 07          ..
                    sta       U0002,U             * 0197 A7 42          'B
L0199               tfr       X,D                 * 0199 1F 10          ..
                    lsra                          * 019B 44             D
                    rorb                          * 019C 56             V
                    tfr       D,X                 * 019D 1F 01          ..
                    tfr       Y,D                 * 019F 1F 20          .
                    rora                          * 01A1 46             F
                    rorb                          * 01A2 56             V
                    tfr       D,Y                 * 01A3 1F 02          ..
                    dec       U0002,U             * 01A5 6A 42          jB
                    bne       L0199               * 01A7 26 F0          &p
                    tfr       Y,D                 * 01A9 1F 20          .
                    leax      U0008,U             * 01AB 30 48          0H
                    addd      #1                  * 01AD C3 00 01       C..
                    lbsr      L0335               * 01B0 17 01 82       ...
                    leax      U0008,U             * 01B3 30 48          0H
                    ldy       #5                  * 01B5 10 8E 00 05    ....
                    lda       #1                  * 01B9 86 01          ..
                    os9       I$Write             * 01BB 10 3F 8A       .?.
                    leax      >L0107,PC           * 01BE 30 8D FF 45    0..E
                    ldy       #1                  * 01C2 10 8E 00 01    ....
                    lda       #1                  * 01C6 86 01          ..
                    os9       I$WritLn            * 01C8 10 3F 8C       .?.
                    leax      >L00ED,PC           * 01CB 30 8D FF 1E    0...
                    ldy       #200                * 01CF 10 8E 00 C8    ...H
                    lda       #1                  * 01D3 86 01          ..
                    os9       I$WritLn            * 01D5 10 3F 8C       .?.
                    leax      >L009D,PC           * 01D8 30 8D FE C1    0.~A
                    ldy       #200                * 01DC 10 8E 00 C8    ...H
                    lda       #1                  * 01E0 86 01          ..
                    os9       I$WritLn            * 01E2 10 3F 8C       .?.
L01E5               leax      U0001,U             * 01E5 30 41          0A
                    ldy       #1                  * 01E7 10 8E 00 01    ....
                    clra                          * 01EB 4F             O
                    os9       I$Read              * 01EC 10 3F 89       .?.
                    lda       U0001,U             * 01EF A6 41          &A
                    cmpa      #24                 * 01F1 81 18          ..
                    lbeq      L02A7               * 01F3 10 27 00 B0    .'.0
                    cmpa      #21                 * 01F7 81 15          ..
                    bne       L01E5               * 01F9 26 EA          &j
                    lda       #1                  * 01FB 86 01          ..
                    sta       <U0012,U            * 01FD A7 C8 12       'H.
                    sta       <U0013,U            * 0200 A7 C8 13       'H.
                    coma                          * 0203 43             C
                    sta       <U0014,U            * 0204 A7 C8 14       'H.
L0207               leax      <U0015,U            * 0207 30 C8 15       0H.
                    ldy       #128                * 020A 10 8E 00 80    ....
                    lda       U0000,U             * 020E A6 C4          &D
                    os9       I$Read              * 0210 10 3F 89       .?.
                    bcs       L0275               * 0213 25 60          %`
                    cmpy      #128                * 0215 10 8C 00 80    ....
                    beq       L022D               * 0219 27 12          '.
                    tfr       Y,D                 * 021B 1F 20          .
                    leax      D,X                 * 021D 30 8B          0.
                    clra                          * 021F 4F             O
L0220               sta       ,X+                 * 0220 A7 80          '.
                    leay      $01,Y               * 0222 31 21          1!
                    cmpy      #128                * 0224 10 8C 00 80    ....
                    bcs       L0220               * 0228 25 F6          %v
                    leax      <U0015,U            * 022A 30 C8 15       0H.
L022D               clr       >U0095,U            * 022D 6F C9 00 95    oI..
                    ldb       #128                * 0231 C6 80          F.
L0233               lda       ,X+                 * 0233 A6 80          &.
                    adda      >U0095,U            * 0235 AB C9 00 95    +I..
                    sta       >U0095,U            * 0239 A7 C9 00 95    'I..
                    decb                          * 023D 5A             Z
                    bne       L0233               * 023E 26 F3          &s
L0240               leax      <U0012,U            * 0240 30 C8 12       0H.
                    ldy       #132                * 0243 10 8E 00 84    ....
                    lda       #1                  * 0247 86 01          ..
                    os9       I$Write             * 0249 10 3F 8A       .?.
                    leax      U0001,U             * 024C 30 41          0A
                    ldy       #1                  * 024E 10 8E 00 01    ....
                    clra                          * 0252 4F             O
                    os9       I$Read              * 0253 10 3F 89       .?.
                    lda       U0001,U             * 0256 A6 41          &A
                    cmpa      #21                 * 0258 81 15          ..
                    beq       L0240               * 025A 27 E4          'd
                    cmpa      #6                  * 025C 81 06          ..
                    beq       L0268               * 025E 27 08          '.
                    cmpa      #24                 * 0260 81 18          ..
                    beq       L02A7               * 0262 27 43          'C
                    lda       #1                  * 0264 86 01          ..
                    bra       L02B5               * 0266 20 4D           M
L0268               lda       <U0013,U            * 0268 A6 C8 13       &H.
                    inca                          * 026B 4C             L
                    sta       <U0013,U            * 026C A7 C8 13       'H.
                    coma                          * 026F 43             C
                    sta       <U0014,U            * 0270 A7 C8 14       'H.
                    bra       L0207               * 0273 20 92           .
L0275               cmpb      #211                * 0275 C1 D3          AS
                    lbne      L02B5               * 0277 10 26 00 3A    .&.:
                    leax      >L0106,PC           * 027B 30 8D FE 87    0.~.
                    ldy       #1                  * 027F 10 8E 00 01    ....
                    lda       #1                  * 0283 86 01          ..
                    os9       I$Write             * 0285 10 3F 8A       .?.
                    leax      U0001,U             * 0288 30 41          0A
                    ldy       #1                  * 028A 10 8E 00 01    ....
                    clra                          * 028E 4F             O
                    os9       I$Read              * 028F 10 3F 89       .?.
                    lda       U0001,U             * 0292 A6 41          &A
                    cmpa      #6                  * 0294 81 06          ..
                    bne       L02A7               * 0296 26 0F          &.
                    leax      >L00B9,PC           * 0298 30 8D FE 1D    0.~.
                    ldy       #200                * 029C 10 8E 00 C8    ...H
                    lda       #1                  * 02A0 86 01          ..
                    os9       I$WritLn            * 02A2 10 3F 8C       .?.
                    bra       L02B4               * 02A5 20 0D           .
L02A7               leax      >L00D2,PC           * 02A7 30 8D FE 27    0.~'
                    ldy       #200                * 02AB 10 8E 00 C8    ...H
                    lda       #1                  * 02AF 86 01          ..
                    os9       I$WritLn            * 02B1 10 3F 8C       .?.
L02B4               clrb                          * 02B4 5F             _
L02B5               pshs      B                   * 02B5 34 04          4.
                    bsr       L02BE               * 02B7 8D 05          ..
                    puls      B                   * 02B9 35 04          5.
                    os9       F$Exit              * 02BB 10 3F 06       .?.
L02BE               leax      >U00B8,U            * 02BE 30 C9 00 B8    0I.8
                    leax      -$20,X              * 02C2 30 88 E0       0.`
                    lda       #1                  * 02C5 86 01          ..
                    sta       <$0024,X            * 02C7 A7 88 24       '.$
                    leax      >U00B8,U            * 02CA 30 C9 00 B8    0I.8
                    clra                          * 02CE 4F             O
                    clrb                          * 02CF 5F             _
                    os9       I$SetStt            * 02D0 10 3F 8E       .?.
                    rts                           * 02D3 39             9
                    fcb       $34                 * 02D4 34             4
                    fcb       $20                 * 02D5 20
                    fcb       $A6                 * 02D6 A6             &
                    fcb       $80                 * 02D7 80             .
                    fcb       $81                 * 02D8 81             .
                    fcb       $30                 * 02D9 30             0
                    fcb       $25                 * 02DA 25             %
                    fcb       $FA                 * 02DB FA             z
                    fcb       $81                 * 02DC 81             .
                    fcb       $39                 * 02DD 39             9
                    fcb       $22                 * 02DE 22             "
                    fcb       $F6                 * 02DF F6             v
                    fcb       $30                 * 02E0 30             0
                    fcb       $1F                 * 02E1 1F             .
                    fcb       $A6                 * 02E2 A6             &
                    fcb       $80                 * 02E3 80             .
                    fcb       $81                 * 02E4 81             .
                    fcb       $30                 * 02E5 30             0
                    fcb       $25                 * 02E6 25             %
                    fcb       $06                 * 02E7 06             .
                    fcb       $81                 * 02E8 81             .
                    fcb       $39                 * 02E9 39             9
                    fcb       $22                 * 02EA 22             "
                    fcb       $02                 * 02EB 02             .
                    fcb       $20                 * 02EC 20
                    fcb       $F4                 * 02ED F4             t
                    fcb       $34                 * 02EE 34             4
                    fcb       $10                 * 02EF 10             .
                    fcb       $30                 * 02F0 30             0
                    fcb       $1F                 * 02F1 1F             .
                    fcc       "oDoE"              * 02F2 6F 44 6F 45    oDoE
                    fcb       $CC                 * 02F6 CC             L
                    fcb       $00                 * 02F7 00             .
                    fcb       $01                 * 02F8 01             .
                    fcb       $ED                 * 02F9 ED             m
                    fcb       $46                 * 02FA 46             F
                    fcb       $A6                 * 02FB A6             &
                    fcb       $82                 * 02FC 82             .
                    fcb       $81                 * 02FD 81             .
                    fcc       "0%."               * 02FE 30 25 2E       0%.
                    fcb       $81                 * 0301 81             .
                    fcc       /9"*/               * 0302 39 22 2A       9"*
                    fcb       $80                 * 0305 80             .
                    fcb       $30                 * 0306 30             0
                    fcb       $A7                 * 0307 A7             '
                    fcb       $43                 * 0308 43             C
                    fcb       $CC                 * 0309 CC             L
                    fcb       $00                 * 030A 00             .
                    fcb       $00                 * 030B 00             .
                    fcc       "mC'"               * 030C 6D 43 27       mC'
                    fcb       $06                 * 030F 06             .
                    fcb       $E3                 * 0310 E3             c
                    fcc       "FjC "              * 0311 46 6A 43 20    FjC
                    fcb       $F6                 * 0315 F6             v
                    fcb       $E3                 * 0316 E3             c
                    fcb       $44                 * 0317 44             D
                    fcb       $ED                 * 0318 ED             m
                    fcb       $44                 * 0319 44             D
                    fcb       $86                 * 031A 86             .
                    fcb       $0A                 * 031B 0A             .
                    fcb       $A7                 * 031C A7             '
                    fcb       $43                 * 031D 43             C
                    fcb       $CC                 * 031E CC             L
                    fcb       $00                 * 031F 00             .
                    fcb       $00                 * 0320 00             .
                    fcc       "mC'"               * 0321 6D 43 27       mC'
                    fcb       $06                 * 0324 06             .
                    fcb       $E3                 * 0325 E3             c
                    fcc       "FjC "              * 0326 46 6A 43 20    FjC
                    fcb       $F6                 * 032A F6             v
                    fcb       $ED                 * 032B ED             m
                    fcb       $46                 * 032C 46             F
                    fcb       $20                 * 032D 20
                    fcb       $CC                 * 032E CC             L
                    fcb       $EC                 * 032F EC             l
                    fcb       $44                 * 0330 44             D
                    fcb       $35                 * 0331 35             5
                    fcb       $10                 * 0332 10             .
                    fcb       $35                 * 0333 35             5
                    fcb       $A0                 * 0334 A0
L0335               std       U0004,U             * 0335 ED 44          mD
                    lda       #48                 * 0337 86 30          .0
                    sta       0,X                 * 0339 A7 84          '.
                    sta       $01,X               * 033B A7 01          '.
                    sta       $02,X               * 033D A7 02          '.
                    sta       $03,X               * 033F A7 03          '.
                    sta       $04,X               * 0341 A7 04          '.
                    ldd       #10000              * 0343 CC 27 10       L'.
                    std       U0006,U             * 0346 ED 46          mF
                    ldd       U0004,U             * 0348 EC 44          lD
                    lbsr      L0376               * 034A 17 00 29       ..)
                    ldd       #1000               * 034D CC 03 E8       L.h
                    std       U0006,U             * 0350 ED 46          mF
                    ldd       U0004,U             * 0352 EC 44          lD
                    bsr       L0376               * 0354 8D 20          .
                    ldd       #100                * 0356 CC 00 64       L.d
                    std       U0006,U             * 0359 ED 46          mF
                    ldd       U0004,U             * 035B EC 44          lD
                    bsr       L0376               * 035D 8D 17          ..
                    ldd       #10                 * 035F CC 00 0A       L..
                    std       U0006,U             * 0362 ED 46          mF
                    ldd       U0004,U             * 0364 EC 44          lD
                    bsr       L0376               * 0366 8D 0E          ..
                    ldd       #1                  * 0368 CC 00 01       L..
                    std       U0006,U             * 036B ED 46          mF
                    ldd       U0004,U             * 036D EC 44          lD
                    bsr       L0376               * 036F 8D 05          ..
                    lda       #13                 * 0371 86 0D          ..
                    sta       0,X                 * 0373 A7 84          '.
                    rts                           * 0375 39             9
L0376               subd      U0006,U             * 0376 A3 46          #F
                    bcs       L037E               * 0378 25 04          %.
                    inc       0,X                 * 037A 6C 84          l.
                    bra       L0376               * 037C 20 F8           x
L037E               addd      U0006,U             * 037E E3 46          cF
                    std       U0004,U             * 0380 ED 44          mD
                    leax      $01,X               * 0382 30 01          0.
                    rts                           * 0384 39             9

                    emod
eom                 equ       *
                    end
