                    nam       BBS.mail.read
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
U0003               rmb       1
U0004               rmb       1
U0005               rmb       3
U0008               rmb       1
U0009               rmb       1
U000A               rmb       2
U000C               rmb       8
U0014               rmb       3
U0017               rmb       1
U0018               rmb       13
U0025               rmb       1
U0026               rmb       1
U0027               rmb       1
U0028               rmb       1
U0029               rmb       1
U002A               rmb       1
U002B               rmb       1
U002C               rmb       1
U002D               rmb       1
U002E               rmb       64
U006E               rmb       80
U00BE               rmb       2
U00C0               rmb       2
U00C2               rmb       20
U00D6               rmb       30
U00F4               rmb       1
U00F5               rmb       1
U00F6               rmb       6
U00FC               rmb       2
U00FE               rmb       200
size                equ       .

name                fcs       /BBS.mail.read/     * 000D 42 42 53 2E 6D 61 69 6C 2E 72 65 61 E4 BBS.mail.read
                    fcc       "Copyright (C) 1988" * 001A 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 Copyright (C) 1988
                    fcc       "By Keith Alphonso" * 002C 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F By Keith Alphonso
                    fcc       "Licenced to Alpha Software Technologies" * 003D 4C 69 63 65 6E 63 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licenced to Alpha Software Technologies
                    fcc       "All rights reserved" * 0064 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 All rights reserved
                    fcb       $EC                 * 0077 EC             l
                    fcb       $E6                 * 0078 E6             f
                    fcb       $EA                 * 0079 EA             j
                    fcb       $F5                 * 007A F5             u
                    fcb       $E9                 * 007B E9             i
                    fcb       $A0                 * 007C A0
                    fcb       $E2                 * 007D E2             b
                    fcb       $ED                 * 007E ED             m
                    fcb       $F1                 * 007F F1             q
                    fcb       $E9                 * 0080 E9             i
                    fcb       $F0                 * 0081 F0             p
                    fcb       $EF                 * 0082 EF             o
                    fcb       $F4                 * 0083 F4             t
                    fcb       $F0                 * 0084 F0             p
                    fcc       "High message is #" * 0085 48 69 67 68 20 6D 65 73 73 61 67 65 20 69 73 20 23 High message is #
                    fcb       $00                 * 0096 00             .
                    fcb       $11                 * 0097 11             .
                    fcc       "Enter message #"   * 0098 45 6E 74 65 72 20 6D 65 73 73 61 67 65 20 23 Enter message #
                    fcb       $0D                 * 00A7 0D             .
                    fcc       ">"                 * 00A8 3E             >
L00A9               fcc       "BBS.mail.inx"      * 00A9 42 42 53 2E 6D 61 69 6C 2E 69 6E 78 BBS.mail.inx
                    fcb       $0D                 * 00B5 0D             .
L00B6               fcc       "BBS.mail"          * 00B6 42 42 53 2E 6D 61 69 6C BBS.mail
                    fcb       $0D                 * 00BE 0D             .
                    fcc       "******   DELETED   ******" * 00BF 2A 2A 2A 2A 2A 2A 20 20 20 44 45 4C 45 54 45 44 20 20 20 2A 2A 2A 2A 2A 2A ******   DELETED   ******
                    fcb       $0D                 * 00D8 0D             .
L00D9               fcb       $0A                 * 00D9 0A             .
                    fcb       $0A                 * 00DA 0A             .
                    fcc       "From    :"         * 00DB 46 72 6F 6D 20 20 20 20 3A From    :
L00E4               fcc       "Left on :"         * 00E4 4C 65 66 74 20 6F 6E 20 3A Left on :
L00ED               fcc       "About   :"         * 00ED 41 62 6F 75 74 20 20 20 3A About   :
L00F6               fcb       $00                 * 00F6 00             .
                    fcb       $09                 * 00F7 09             .
L00F8               fcc       "---------------------------------------------------------------" * 00F8 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
                    fcb       $0D                 * 0137 0D             .
L0138               fcb       $0A                 * 0138 0A             .
                    fcb       $0D                 * 0139 0D             .
L013A               fcb       $0A                 * 013A 0A             .
                    fcc       "That's all the mail that was left for you" * 013B 54 68 61 74 27 73 20 61 6C 6C 20 74 68 65 20 6D 61 69 6C 20 74 68 61 74 20 77 61 73 20 6C 65 66 74 20 66 6F 72 20 79 6F 75 That's all the mail that was left for you
                    fcb       $0D                 * 0164 0D             .
L0165               fcc       "Sorry, you have no mail" * 0165 53 6F 72 72 79 2C 20 79 6F 75 20 68 61 76 65 20 6E 6F 20 6D 61 69 6C Sorry, you have no mail
                    fcb       $0D                 * 017C 0D             .
L017D               fcc       "Checking for mail..." * 017D 43 68 65 63 6B 69 6E 67 20 66 6F 72 20 6D 61 69 6C 2E 2E 2E Checking for mail...
                    fcb       $0A                 * 0191 0A             .
                    fcb       $0D                 * 0192 0D             .
L0193               fcc       "Re-Read? (Y/N):"   * 0193 52 65 2D 52 65 61 64 3F 20 28 59 2F 4E 29 3A Re-Read? (Y/N):
                    fcb       $0D                 * 01A2 0D             .

start               os9       F$ID                * 01A3 10 3F 0C       .?.
                    sty       U000C,U             * 01A6 10 AF 4C       ./L
                    ldy       #0                  * 01A9 10 8E 00 00    ....
                    os9       F$SUser             * 01AD 10 3F 1C       .?.
                    leax      >L00A9,PC           * 01B0 30 8D FE F5    0.~u
                    lda       #1                  * 01B4 86 01          ..
                    os9       I$Open              * 01B6 10 3F 84       .?.
                    lbcs      L0375               * 01B9 10 25 01 B8    .%.8
                    sta       U0000,U             * 01BD A7 C4          'D
                    leax      >L00B6,PC           * 01BF 30 8D FE F3    0.~s
                    lda       #1                  * 01C3 86 01          ..
                    os9       I$Open              * 01C5 10 3F 84       .?.
                    lbcs      L0375               * 01C8 10 25 01 A9    .%.)
                    sta       U0001,U             * 01CC A7 41          'A
                    clr       U0004,U             * 01CE 6F 44          oD
                    leax      >L017D,PC           * 01D0 30 8D FF A9    0..)
                    ldy       #200                * 01D4 10 8E 00 C8    ...H
                    lda       #1                  * 01D8 86 01          ..
                    os9       I$WritLn            * 01DA 10 3F 8C       .?.
                    leax      <U002E,U            * 01DD 30 C8 2E       0H.
                    ldy       #64                 * 01E0 10 8E 00 40    ...@
                    lda       U0000,U             * 01E4 A6 C4          &D
                    os9       I$Read              * 01E6 10 3F 89       .?.
                    lbcs      L0375               * 01E9 10 25 01 88    .%..
L01ED               leax      >U00BE,U            * 01ED 30 C9 00 BE    0I.>
                    ldy       #64                 * 01F1 10 8E 00 40    ...@
                    lda       U0000,U             * 01F5 A6 C4          &D
                    os9       I$Read              * 01F7 10 3F 89       .?.
                    bcs       L0207               * 01FA 25 0B          %.
                    ldd       >U00FC,U            * 01FC EC C9 00 FC    lI.|
                    cmpd      U000C,U             * 0200 10 A3 4C       .#L
                    bne       L01ED               * 0203 26 E8          &h
                    bra       L0231               * 0205 20 2A           *
L0207               cmpb      #211                * 0207 C1 D3          AS
                    lbne      L0375               * 0209 10 26 01 68    .&.h
                    tst       U0004,U             * 020D 6D 44          mD
                    beq       L0221               * 020F 27 10          '.
                    leax      >L013A,PC           * 0211 30 8D FF 25    0..%
                    ldy       #200                * 0215 10 8E 00 C8    ...H
                    lda       #1                  * 0219 86 01          ..
                    os9       I$WritLn            * 021B 10 3F 8C       .?.
                    lbra      L0374               * 021E 16 01 53       ..S
L0221               leax      >L0165,PC           * 0221 30 8D FF 40    0..@
                    ldy       #200                * 0225 10 8E 00 C8    ...H
                    lda       #1                  * 0229 86 01          ..
                    os9       I$WritLn            * 022B 10 3F 8C       .?.
                    lbra      L0374               * 022E 16 01 43       ..C
L0231               inc       U0004,U             * 0231 6C 44          lD
                    ldd       >U00BE,U            * 0233 EC C9 00 BE    lI.>
                    cmpd      #-1                 * 0237 10 83 FF FF    ....
                    lbeq      L01ED               * 023B 10 27 FF AE    .'..
                    leax      >L00D9,PC           * 023F 30 8D FE 96    0.~.
                    ldy       >L00F6,PC           * 0243 10 AE 8D FE AE ...~.
                    leay      $02,Y               * 0248 31 22          1"
                    lda       #1                  * 024A 86 01          ..
                    os9       I$Write             * 024C 10 3F 8A       .?.
                    leax      >U00C2,U            * 024F 30 C9 00 C2    0I.B
                    ldy       #200                * 0253 10 8E 00 C8    ...H
                    lda       #1                  * 0257 86 01          ..
                    os9       I$WritLn            * 0259 10 3F 8C       .?.
                    lbcs      L0375               * 025C 10 25 01 15    .%..
                    leax      >L00E4,PC           * 0260 30 8D FE 80    0.~.
                    ldy       >L00F6,PC           * 0264 10 AE 8D FE 8D ...~.
                    lda       #1                  * 0269 86 01          ..
                    os9       I$Write             * 026B 10 3F 8A       .?.
                    leax      <U0014,U            * 026E 30 C8 14       0H.
                    ldb       >U00F5,U            * 0271 E6 C9 00 F5    fI.u
                    clra                          * 0275 4F             O
                    lbsr      L03E9               * 0276 17 01 70       ..p
                    lda       <U0017,U            * 0279 A6 C8 17       &H.
                    sta       <U0025,U            * 027C A7 C8 25       'H%
                    lda       <U0018,U            * 027F A6 C8 18       &H.
                    sta       <U0026,U            * 0282 A7 C8 26       'H&
                    lda       #47                 * 0285 86 2F          ./
                    sta       <U0027,U            * 0287 A7 C8 27       'H'
                    ldb       >U00F6,U            * 028A E6 C9 00 F6    fI.v
                    clra                          * 028E 4F             O
                    leax      <U0014,U            * 028F 30 C8 14       0H.
                    lbsr      L03E9               * 0292 17 01 54       ..T
                    lda       <U0017,U            * 0295 A6 C8 17       &H.
                    sta       <U0028,U            * 0298 A7 C8 28       'H(
                    lda       <U0018,U            * 029B A6 C8 18       &H.
                    sta       <U0029,U            * 029E A7 C8 29       'H)
                    lda       #47                 * 02A1 86 2F          ./
                    sta       <U002A,U            * 02A3 A7 C8 2A       'H*
                    ldb       >U00F4,U            * 02A6 E6 C9 00 F4    fI.t
                    clra                          * 02AA 4F             O
                    leax      <U0014,U            * 02AB 30 C8 14       0H.
                    lbsr      L03E9               * 02AE 17 01 38       ..8
                    lda       <U0017,U            * 02B1 A6 C8 17       &H.
                    sta       <U002B,U            * 02B4 A7 C8 2B       'H+
                    lda       <U0018,U            * 02B7 A6 C8 18       &H.
                    sta       <U002C,U            * 02BA A7 C8 2C       'H,
                    lda       #13                 * 02BD 86 0D          ..
                    sta       <U002D,U            * 02BF A7 C8 2D       'H-
                    leax      <U0025,U            * 02C2 30 C8 25       0H%
L02C5               lda       ,X+                 * 02C5 A6 80          &.
                    cmpa      #32                 * 02C7 81 20          .
                    beq       L02C5               * 02C9 27 FA          'z
                    leax      -$01,X              * 02CB 30 1F          0.
                    ldy       #200                * 02CD 10 8E 00 C8    ...H
                    lda       #1                  * 02D1 86 01          ..
                    os9       I$WritLn            * 02D3 10 3F 8C       .?.
                    lbcs      L0375               * 02D6 10 25 00 9B    .%..
                    leax      >L00ED,PC           * 02DA 30 8D FE 0F    0.~.
                    ldy       >L00F6,PC           * 02DE 10 AE 8D FE 13 ...~.
                    lda       #1                  * 02E3 86 01          ..
                    os9       I$Write             * 02E5 10 3F 8A       .?.
                    leax      >U00D6,U            * 02E8 30 C9 00 D6    0I.V
                    ldy       #30                 * 02EC 10 8E 00 1E    ....
                    os9       I$WritLn            * 02F0 10 3F 8C       .?.
                    lbcs      L0375               * 02F3 10 25 00 7E    .%.~
                    bra       L02F9               * 02F7 20 00           .
L02F9               leax      >L00F8,PC           * 02F9 30 8D FD FB    0.}{
                    ldy       #64                 * 02FD 10 8E 00 40    ...@
                    lda       #1                  * 0301 86 01          ..
                    os9       I$WritLn            * 0303 10 3F 8C       .?.
                    lda       U0001,U             * 0306 A6 41          &A
                    ldx       >U00BE,U            * 0308 AE C9 00 BE    .I.>
                    pshs      U                   * 030C 34 40          4@
                    ldu       >U00C0,U            * 030E EE C9 00 C0    nI.@
                    os9       I$Seek              * 0312 10 3F 88       .?.
                    lbcs      L0375               * 0315 10 25 00 5C    .%.\
                    puls      U                   * 0319 35 40          5@
L031B               lda       U0001,U             * 031B A6 41          &A
                    leax      <U006E,U            * 031D 30 C8 6E       0Hn
                    ldy       #80                 * 0320 10 8E 00 50    ...P
                    os9       I$ReadLn            * 0324 10 3F 8B       .?.
                    lda       #1                  * 0327 86 01          ..
                    os9       I$WritLn            * 0329 10 3F 8C       .?.
                    cmpy      #1                  * 032C 10 8C 00 01    ....
                    bhi       L031B               * 0330 22 E9          "i
                    leax      >L00F8,PC           * 0332 30 8D FD C2    0.}B
                    ldy       #64                 * 0336 10 8E 00 40    ...@
                    lda       #1                  * 033A 86 01          ..
                    os9       I$WritLn            * 033C 10 3F 8C       .?.
                    leax      >L0193,PC           * 033F 30 8D FE 50    0.~P
                    ldy       #200                * 0343 10 8E 00 C8    ...H
                    lda       #1                  * 0347 86 01          ..
                    os9       I$WritLn            * 0349 10 3F 8C       .?.
                    leax      U0005,U             * 034C 30 45          0E
                    ldy       #1                  * 034E 10 8E 00 01    ....
                    clra                          * 0352 4F             O
                    os9       I$Read              * 0353 10 3F 89       .?.
                    leax      >L0138,PC           * 0356 30 8D FD DE    0.}^
                    ldy       #1                  * 035A 10 8E 00 01    ....
                    lda       #1                  * 035E 86 01          ..
                    os9       I$WritLn            * 0360 10 3F 8C       .?.
                    lda       U0005,U             * 0363 A6 45          &E
                    cmpa      #121                * 0365 81 79          .y
                    lbeq      L02F9               * 0367 10 27 FF 8E    .'..
                    cmpa      #89                 * 036B 81 59          .Y
                    lbeq      L02F9               * 036D 10 27 FF 88    .'..
                    lbra      L01ED               * 0371 16 FE 79       .~y
L0374               clrb                          * 0374 5F             _
L0375               pshs      B                   * 0375 34 04          4.
                    ldy       U000C,U             * 0377 10 AE 4C       ..L
                    os9       F$SUser             * 037A 10 3F 1C       .?.
                    puls      B                   * 037D 35 04          5.
                    os9       F$Exit              * 037F 10 3F 06       .?.

                    pshs      Y                   * 0382 34 20          4
L0384               lda       ,X+                 * 0384 A6 80          &.
                    cmpa      #13                 * 0386 81 0D          ..
                    lbeq      L0457               * 0388 10 27 00 CB    .'.K
                    cmpa      #48                 * 038C 81 30          .0
                    bcs       L0384               * 038E 25 F4          %t
                    cmpa      #57                 * 0390 81 39          .9
                    bhi       L0384               * 0392 22 F0          "p
                    leax      -$01,X              * 0394 30 1F          0.
L0396               lda       ,X+                 * 0396 A6 80          &.
                    cmpa      #48                 * 0398 81 30          .0
                    bcs       L03A2               * 039A 25 06          %.
                    cmpa      #57                 * 039C 81 39          .9
                    bhi       L03A2               * 039E 22 02          ".
                    bra       L0396               * 03A0 20 F4           t
L03A2               pshs      X                   * 03A2 34 10          4.
                    leax      -$01,X              * 03A4 30 1F          0.
                    clr       U0008,U             * 03A6 6F 48          oH
                    clr       U0009,U             * 03A8 6F 49          oI
                    ldd       #1                  * 03AA CC 00 01       L..
                    std       U000A,U             * 03AD ED 4A          mJ
L03AF               lda       ,-X                 * 03AF A6 82          &.
                    cmpa      #48                 * 03B1 81 30          .0
                    bcs       L03E3               * 03B3 25 2E          %.
                    cmpa      #57                 * 03B5 81 39          .9
                    bhi       L03E3               * 03B7 22 2A          "*
                    suba      #48                 * 03B9 80 30          .0
                    sta       U0003,U             * 03BB A7 43          'C
                    ldd       #0                  * 03BD CC 00 00       L..
L03C0               tst       U0003,U             * 03C0 6D 43          mC
                    beq       L03CA               * 03C2 27 06          '.
                    addd      U000A,U             * 03C4 E3 4A          cJ
                    dec       U0003,U             * 03C6 6A 43          jC
                    bra       L03C0               * 03C8 20 F6           v
L03CA               addd      U0008,U             * 03CA E3 48          cH
                    std       U0008,U             * 03CC ED 48          mH
                    lda       #10                 * 03CE 86 0A          ..
                    sta       U0003,U             * 03D0 A7 43          'C
                    ldd       #0                  * 03D2 CC 00 00       L..
L03D5               tst       U0003,U             * 03D5 6D 43          mC
                    beq       L03DF               * 03D7 27 06          '.
                    addd      U000A,U             * 03D9 E3 4A          cJ
                    dec       U0003,U             * 03DB 6A 43          jC
                    bra       L03D5               * 03DD 20 F6           v
L03DF               std       U000A,U             * 03DF ED 4A          mJ
                    bra       L03AF               * 03E1 20 CC           L
L03E3               ldd       U0008,U             * 03E3 EC 48          lH
                    puls      X                   * 03E5 35 10          5.
                    puls      PC,Y                * 03E7 35 A0          5
L03E9               pshs      X                   * 03E9 34 10          4.
                    std       U0008,U             * 03EB ED 48          mH
                    lda       #48                 * 03ED 86 30          .0
                    sta       0,X                 * 03EF A7 84          '.
                    sta       $01,X               * 03F1 A7 01          '.
                    sta       $02,X               * 03F3 A7 02          '.
                    sta       $03,X               * 03F5 A7 03          '.
                    sta       $04,X               * 03F7 A7 04          '.
                    ldd       #10000              * 03F9 CC 27 10       L'.
                    std       U000A,U             * 03FC ED 4A          mJ
                    ldd       U0008,U             * 03FE EC 48          lH
                    lbsr      L0448               * 0400 17 00 45       ..E
                    ldd       #1000               * 0403 CC 03 E8       L.h
                    std       U000A,U             * 0406 ED 4A          mJ
                    ldd       U0008,U             * 0408 EC 48          lH
                    bsr       L0448               * 040A 8D 3C          .<
                    ldd       #100                * 040C CC 00 64       L.d
                    std       U000A,U             * 040F ED 4A          mJ
                    ldd       U0008,U             * 0411 EC 48          lH
                    bsr       L0448               * 0413 8D 33          .3
                    ldd       #10                 * 0415 CC 00 0A       L..
                    std       U000A,U             * 0418 ED 4A          mJ
                    ldd       U0008,U             * 041A EC 48          lH
                    bsr       L0448               * 041C 8D 2A          .*
                    ldd       #1                  * 041E CC 00 01       L..
                    std       U000A,U             * 0421 ED 4A          mJ
                    ldd       U0008,U             * 0423 EC 48          lH
                    bsr       L0448               * 0425 8D 21          .!
                    lda       #13                 * 0427 86 0D          ..
                    sta       0,X                 * 0429 A7 84          '.
                    puls      X                   * 042B 35 10          5.
                    ldb       #32                 * 042D C6 20          F
L042F               lda       0,X                 * 042F A6 84          &.
                    cmpa      #48                 * 0431 81 30          .0
                    bne       L0439               * 0433 26 04          &.
                    stb       ,X+                 * 0435 E7 80          g.
                    bra       L042F               * 0437 20 F6           v
L0439               lda       ,X+                 * 0439 A6 80          &.
                    cmpa      #48                 * 043B 81 30          .0
                    bcs       L0445               * 043D 25 06          %.
                    cmpa      #57                 * 043F 81 39          .9
                    bhi       L0445               * 0441 22 02          ".
                    bra       L0439               * 0443 20 F4           t
L0445               leax      -$01,X              * 0445 30 1F          0.
                    rts                           * 0447 39             9
L0448               subd      U000A,U             * 0448 A3 4A          #J
                    bcs       L0450               * 044A 25 04          %.
                    inc       0,X                 * 044C 6C 84          l.
                    bra       L0448               * 044E 20 F8           x
L0450               addd      U000A,U             * 0450 E3 4A          cJ
                    std       U0008,U             * 0452 ED 48          mH
                    leax      $01,X               * 0454 30 01          0.
                    rts                           * 0456 39             9
L0457               ldd       #-1                 * 0457 CC FF FF       L..
                    puls      PC,Y                * 045A 35 A0          5

                    emod
eom                 equ       *
                    end
