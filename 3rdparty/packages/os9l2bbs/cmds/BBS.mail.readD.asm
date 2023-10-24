                    nam       BBS.mail.readD
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
U00FC               rmb       62
U013A               rmb       1
U013B               rmb       139
size                equ       .

name                fcs       /BBS.mail.readD/    * 000D 42 42 53 2E 6D 61 69 6C 2E 72 65 61 64 C4 BBS.mail.readD
                    fcc       "Copyright (C) 1988" * 001B 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 Copyright (C) 1988
                    fcc       "By Keith Alphonso" * 002D 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F By Keith Alphonso
                    fcc       "Licenced to Alpha Software Technologies" * 003E 4C 69 63 65 6E 63 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licenced to Alpha Software Technologies
                    fcc       "All rights reserved" * 0065 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 All rights reserved
                    fcb       $EC                 * 0078 EC             l
                    fcb       $E6                 * 0079 E6             f
                    fcb       $EA                 * 007A EA             j
                    fcb       $F5                 * 007B F5             u
                    fcb       $E9                 * 007C E9             i
                    fcb       $A0                 * 007D A0
                    fcb       $E2                 * 007E E2             b
                    fcb       $ED                 * 007F ED             m
                    fcb       $F1                 * 0080 F1             q
                    fcb       $E9                 * 0081 E9             i
                    fcb       $F0                 * 0082 F0             p
                    fcb       $EF                 * 0083 EF             o
                    fcb       $F4                 * 0084 F4             t
                    fcb       $F0                 * 0085 F0             p
                    fcc       "High message is #" * 0086 48 69 67 68 20 6D 65 73 73 61 67 65 20 69 73 20 23 High message is #
                    fcb       $00                 * 0097 00             .
                    fcb       $11                 * 0098 11             .
                    fcc       "Enter message #"   * 0099 45 6E 74 65 72 20 6D 65 73 73 61 67 65 20 23 Enter message #
                    fcb       $0D                 * 00A8 0D             .
                    fcc       ">"                 * 00A9 3E             >
L00AA               fcc       "BBS.mail.inx"      * 00AA 42 42 53 2E 6D 61 69 6C 2E 69 6E 78 BBS.mail.inx
                    fcb       $0D                 * 00B6 0D             .
L00B7               fcc       "BBS.mail"          * 00B7 42 42 53 2E 6D 61 69 6C BBS.mail
                    fcb       $0D                 * 00BF 0D             .
                    fcc       "******   DELETED   ******" * 00C0 2A 2A 2A 2A 2A 2A 20 20 20 44 45 4C 45 54 45 44 20 20 20 2A 2A 2A 2A 2A 2A ******   DELETED   ******
                    fcb       $0D                 * 00D9 0D             .
L00DA               fcb       $0A                 * 00DA 0A             .
                    fcb       $0A                 * 00DB 0A             .
                    fcc       "From    :"         * 00DC 46 72 6F 6D 20 20 20 20 3A From    :
L00E5               fcc       "Left on :"         * 00E5 4C 65 66 74 20 6F 6E 20 3A Left on :
L00EE               fcc       "About   :"         * 00EE 41 62 6F 75 74 20 20 20 3A About   :
L00F7               fcb       $00                 * 00F7 00             .
                    fcb       $09                 * 00F8 09             .
L00F9               fcc       "---------------------------------------------------------------" * 00F9 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
                    fcb       $0D                 * 0138 0D             .
L0139               fcb       $0A                 * 0139 0A             .
                    fcb       $0D                 * 013A 0D             .
L013B               fcb       $0A                 * 013B 0A             .
                    fcc       "That's all the mail that was left for you" * 013C 54 68 61 74 27 73 20 61 6C 6C 20 74 68 65 20 6D 61 69 6C 20 74 68 61 74 20 77 61 73 20 6C 65 66 74 20 66 6F 72 20 79 6F 75 That's all the mail that was left for you
                    fcb       $0D                 * 0165 0D             .
L0166               fcc       "Sorry, you have no mail" * 0166 53 6F 72 72 79 2C 20 79 6F 75 20 68 61 76 65 20 6E 6F 20 6D 61 69 6C Sorry, you have no mail
                    fcb       $0D                 * 017D 0D             .
L017E               fcc       "Checking for mail..." * 017E 43 68 65 63 6B 69 6E 67 20 66 6F 72 20 6D 61 69 6C 2E 2E 2E Checking for mail...
                    fcb       $0A                 * 0192 0A             .
                    fcb       $0D                 * 0193 0D             .
L0194               fcc       "Re-Read? (Y/N):"   * 0194 52 65 2D 52 65 61 64 3F 20 28 59 2F 4E 29 3A Re-Read? (Y/N):
                    fcb       $0D                 * 01A3 0D             .
L01A4               fcc       "BBS.mail.delete"   * 01A4 42 42 53 2E 6D 61 69 6C 2E 64 65 6C 65 74 65 BBS.mail.delete
                    fcb       $0D                 * 01B3 0D             .

start               os9       F$ID                * 01B4 10 3F 0C       .?.
                    sty       U000C,U             * 01B7 10 AF 4C       ./L
                    ldy       #0                  * 01BA 10 8E 00 00    ....
                    os9       F$SUser             * 01BE 10 3F 1C       .?.
                    leax      >L00AA,PC           * 01C1 30 8D FE E5    0.~e
                    lda       #1                  * 01C5 86 01          ..
                    os9       I$Open              * 01C7 10 3F 84       .?.
                    lbcs      L03A6               * 01CA 10 25 01 D8    .%.X
                    sta       U0000,U             * 01CE A7 C4          'D
                    leax      >L00B7,PC           * 01D0 30 8D FE E3    0.~c
                    lda       #1                  * 01D4 86 01          ..
                    os9       I$Open              * 01D6 10 3F 84       .?.
                    lbcs      L03A6               * 01D9 10 25 01 C9    .%.I
                    sta       U0001,U             * 01DD A7 41          'A
                    clr       U0004,U             * 01DF 6F 44          oD
                    leax      >L017E,PC           * 01E1 30 8D FF 99    0...
                    ldy       #200                * 01E5 10 8E 00 C8    ...H
                    lda       #1                  * 01E9 86 01          ..
                    os9       I$WritLn            * 01EB 10 3F 8C       .?.
                    leax      <U002E,U            * 01EE 30 C8 2E       0H.
                    ldy       #64                 * 01F1 10 8E 00 40    ...@
                    lda       U0000,U             * 01F5 A6 C4          &D
                    os9       I$Read              * 01F7 10 3F 89       .?.
                    lbcs      L03A6               * 01FA 10 25 01 A8    .%.(
L01FE               leax      >U00BE,U            * 01FE 30 C9 00 BE    0I.>
                    ldy       #64                 * 0202 10 8E 00 40    ...@
                    lda       U0000,U             * 0206 A6 C4          &D
                    os9       I$Read              * 0208 10 3F 89       .?.
                    bcs       L0218               * 020B 25 0B          %.
                    ldd       >U00FC,U            * 020D EC C9 00 FC    lI.|
                    cmpd      U000C,U             * 0211 10 A3 4C       .#L
                    bne       L01FE               * 0214 26 E8          &h
                    bra       L0262               * 0216 20 4A           J
L0218               cmpb      #211                * 0218 C1 D3          AS
                    lbne      L03A6               * 021A 10 26 01 88    .&..
                    tst       U0004,U             * 021E 6D 44          mD
                    beq       L0252               * 0220 27 30          '0
                    leax      >L013B,PC           * 0222 30 8D FF 15    0...
                    ldy       #200                * 0226 10 8E 00 C8    ...H
                    lda       #1                  * 022A 86 01          ..
                    os9       I$WritLn            * 022C 10 3F 8C       .?.
                    lda       U0001,U             * 022F A6 41          &A
                    os9       I$Close             * 0231 10 3F 8F       .?.
                    lda       U0000,U             * 0234 A6 C4          &D
                    os9       I$Close             * 0236 10 3F 8F       .?.
                    ldy       U000C,U             * 0239 10 AE 4C       ..L
                    os9       F$SUser             * 023C 10 3F 1C       .?.
                    leax      >L01A4,PC           * 023F 30 8D FF 61    0..a
                    ldy       #1                  * 0243 10 8E 00 01    ....
                    leau      >U013A,U            * 0247 33 C9 01 3A    3I.:
                    lda       #17                 * 024B 86 11          ..
                    ldb       #3                  * 024D C6 03          F.
                    os9       F$Chain             * 024F 10 3F 05       .?.
L0252               leax      >L0166,PC           * 0252 30 8D FF 10    0...
                    ldy       #200                * 0256 10 8E 00 C8    ...H
                    lda       #1                  * 025A 86 01          ..
                    os9       I$WritLn            * 025C 10 3F 8C       .?.
                    lbra      L03A5               * 025F 16 01 43       ..C
L0262               inc       U0004,U             * 0262 6C 44          lD
                    ldd       >U00BE,U            * 0264 EC C9 00 BE    lI.>
                    cmpd      #-1                 * 0268 10 83 FF FF    ....
                    lbeq      L01FE               * 026C 10 27 FF 8E    .'..
                    leax      >L00DA,PC           * 0270 30 8D FE 66    0.~f
                    ldy       >L00F7,PC           * 0274 10 AE 8D FE 7E ...~~
                    leay      $02,Y               * 0279 31 22          1"
                    lda       #1                  * 027B 86 01          ..
                    os9       I$Write             * 027D 10 3F 8A       .?.
                    leax      >U00C2,U            * 0280 30 C9 00 C2    0I.B
                    ldy       #200                * 0284 10 8E 00 C8    ...H
                    lda       #1                  * 0288 86 01          ..
                    os9       I$WritLn            * 028A 10 3F 8C       .?.
                    lbcs      L03A6               * 028D 10 25 01 15    .%..
                    leax      >L00E5,PC           * 0291 30 8D FE 50    0.~P
                    ldy       >L00F7,PC           * 0295 10 AE 8D FE 5D ...~]
                    lda       #1                  * 029A 86 01          ..
                    os9       I$Write             * 029C 10 3F 8A       .?.
                    leax      <U0014,U            * 029F 30 C8 14       0H.
                    ldb       >U00F5,U            * 02A2 E6 C9 00 F5    fI.u
                    clra                          * 02A6 4F             O
                    lbsr      L041A               * 02A7 17 01 70       ..p
                    lda       <U0017,U            * 02AA A6 C8 17       &H.
                    sta       <U0025,U            * 02AD A7 C8 25       'H%
                    lda       <U0018,U            * 02B0 A6 C8 18       &H.
                    sta       <U0026,U            * 02B3 A7 C8 26       'H&
                    lda       #47                 * 02B6 86 2F          ./
                    sta       <U0027,U            * 02B8 A7 C8 27       'H'
                    ldb       >U00F6,U            * 02BB E6 C9 00 F6    fI.v
                    clra                          * 02BF 4F             O
                    leax      <U0014,U            * 02C0 30 C8 14       0H.
                    lbsr      L041A               * 02C3 17 01 54       ..T
                    lda       <U0017,U            * 02C6 A6 C8 17       &H.
                    sta       <U0028,U            * 02C9 A7 C8 28       'H(
                    lda       <U0018,U            * 02CC A6 C8 18       &H.
                    sta       <U0029,U            * 02CF A7 C8 29       'H)
                    lda       #47                 * 02D2 86 2F          ./
                    sta       <U002A,U            * 02D4 A7 C8 2A       'H*
                    ldb       >U00F4,U            * 02D7 E6 C9 00 F4    fI.t
                    clra                          * 02DB 4F             O
                    leax      <U0014,U            * 02DC 30 C8 14       0H.
                    lbsr      L041A               * 02DF 17 01 38       ..8
                    lda       <U0017,U            * 02E2 A6 C8 17       &H.
                    sta       <U002B,U            * 02E5 A7 C8 2B       'H+
                    lda       <U0018,U            * 02E8 A6 C8 18       &H.
                    sta       <U002C,U            * 02EB A7 C8 2C       'H,
                    lda       #13                 * 02EE 86 0D          ..
                    sta       <U002D,U            * 02F0 A7 C8 2D       'H-
                    leax      <U0025,U            * 02F3 30 C8 25       0H%
L02F6               lda       ,X+                 * 02F6 A6 80          &.
                    cmpa      #32                 * 02F8 81 20          .
                    beq       L02F6               * 02FA 27 FA          'z
                    leax      -$01,X              * 02FC 30 1F          0.
                    ldy       #200                * 02FE 10 8E 00 C8    ...H
                    lda       #1                  * 0302 86 01          ..
                    os9       I$WritLn            * 0304 10 3F 8C       .?.
                    lbcs      L03A6               * 0307 10 25 00 9B    .%..
                    leax      >L00EE,PC           * 030B 30 8D FD DF    0.}_
                    ldy       >L00F7,PC           * 030F 10 AE 8D FD E3 ...}c
                    lda       #1                  * 0314 86 01          ..
                    os9       I$Write             * 0316 10 3F 8A       .?.
                    leax      >U00D6,U            * 0319 30 C9 00 D6    0I.V
                    ldy       #30                 * 031D 10 8E 00 1E    ....
                    os9       I$WritLn            * 0321 10 3F 8C       .?.
                    lbcs      L03A6               * 0324 10 25 00 7E    .%.~
                    bra       L032A               * 0328 20 00           .
L032A               leax      >L00F9,PC           * 032A 30 8D FD CB    0.}K
                    ldy       #64                 * 032E 10 8E 00 40    ...@
                    lda       #1                  * 0332 86 01          ..
                    os9       I$WritLn            * 0334 10 3F 8C       .?.
                    lda       U0001,U             * 0337 A6 41          &A
                    ldx       >U00BE,U            * 0339 AE C9 00 BE    .I.>
                    pshs      U                   * 033D 34 40          4@
                    ldu       >U00C0,U            * 033F EE C9 00 C0    nI.@
                    os9       I$Seek              * 0343 10 3F 88       .?.
                    lbcs      L03A6               * 0346 10 25 00 5C    .%.\
                    puls      U                   * 034A 35 40          5@
L034C               lda       U0001,U             * 034C A6 41          &A
                    leax      <U006E,U            * 034E 30 C8 6E       0Hn
                    ldy       #80                 * 0351 10 8E 00 50    ...P
                    os9       I$ReadLn            * 0355 10 3F 8B       .?.
                    lda       #1                  * 0358 86 01          ..
                    os9       I$WritLn            * 035A 10 3F 8C       .?.
                    cmpy      #1                  * 035D 10 8C 00 01    ....
                    bhi       L034C               * 0361 22 E9          "i
                    leax      >L00F9,PC           * 0363 30 8D FD 92    0.}.
                    ldy       #64                 * 0367 10 8E 00 40    ...@
                    lda       #1                  * 036B 86 01          ..
                    os9       I$WritLn            * 036D 10 3F 8C       .?.
                    leax      >L0194,PC           * 0370 30 8D FE 20    0.~
                    ldy       #200                * 0374 10 8E 00 C8    ...H
                    lda       #1                  * 0378 86 01          ..
                    os9       I$WritLn            * 037A 10 3F 8C       .?.
                    leax      U0005,U             * 037D 30 45          0E
                    ldy       #1                  * 037F 10 8E 00 01    ....
                    clra                          * 0383 4F             O
                    os9       I$Read              * 0384 10 3F 89       .?.
                    leax      >L0139,PC           * 0387 30 8D FD AE    0.}.
                    ldy       #1                  * 038B 10 8E 00 01    ....
                    lda       #1                  * 038F 86 01          ..
                    os9       I$WritLn            * 0391 10 3F 8C       .?.
                    lda       U0005,U             * 0394 A6 45          &E
                    cmpa      #121                * 0396 81 79          .y
                    lbeq      L032A               * 0398 10 27 FF 8E    .'..
                    cmpa      #89                 * 039C 81 59          .Y
                    lbeq      L032A               * 039E 10 27 FF 88    .'..
                    lbra      L01FE               * 03A2 16 FE 59       .~Y
L03A5               clrb                          * 03A5 5F             _
L03A6               pshs      B                   * 03A6 34 04          4.
                    ldy       U000C,U             * 03A8 10 AE 4C       ..L
                    os9       F$SUser             * 03AB 10 3F 1C       .?.
                    puls      B                   * 03AE 35 04          5.
                    os9       F$Exit              * 03B0 10 3F 06       .?.

                    pshs      Y                   * 03B3 34 20          4
L03B5               lda       ,X+                 * 03B5 A6 80          &.
                    cmpa      #13                 * 03B7 81 0D          ..
                    lbeq      L0488               * 03B9 10 27 00 CB    .'.K
                    cmpa      #48                 * 03BD 81 30          .0
                    bcs       L03B5               * 03BF 25 F4          %t
                    cmpa      #57                 * 03C1 81 39          .9
                    bhi       L03B5               * 03C3 22 F0          "p
                    leax      -$01,X              * 03C5 30 1F          0.
L03C7               lda       ,X+                 * 03C7 A6 80          &.
                    cmpa      #48                 * 03C9 81 30          .0
                    bcs       L03D3               * 03CB 25 06          %.
                    cmpa      #57                 * 03CD 81 39          .9
                    bhi       L03D3               * 03CF 22 02          ".
                    bra       L03C7               * 03D1 20 F4           t
L03D3               pshs      X                   * 03D3 34 10          4.
                    leax      -$01,X              * 03D5 30 1F          0.
                    clr       U0008,U             * 03D7 6F 48          oH
                    clr       U0009,U             * 03D9 6F 49          oI
                    ldd       #1                  * 03DB CC 00 01       L..
                    std       U000A,U             * 03DE ED 4A          mJ
L03E0               lda       ,-X                 * 03E0 A6 82          &.
                    cmpa      #48                 * 03E2 81 30          .0
                    bcs       L0414               * 03E4 25 2E          %.
                    cmpa      #57                 * 03E6 81 39          .9
                    bhi       L0414               * 03E8 22 2A          "*
                    suba      #48                 * 03EA 80 30          .0
                    sta       U0003,U             * 03EC A7 43          'C
                    ldd       #0                  * 03EE CC 00 00       L..
L03F1               tst       U0003,U             * 03F1 6D 43          mC
                    beq       L03FB               * 03F3 27 06          '.
                    addd      U000A,U             * 03F5 E3 4A          cJ
                    dec       U0003,U             * 03F7 6A 43          jC
                    bra       L03F1               * 03F9 20 F6           v
L03FB               addd      U0008,U             * 03FB E3 48          cH
                    std       U0008,U             * 03FD ED 48          mH
                    lda       #10                 * 03FF 86 0A          ..
                    sta       U0003,U             * 0401 A7 43          'C
                    ldd       #0                  * 0403 CC 00 00       L..
L0406               tst       U0003,U             * 0406 6D 43          mC
                    beq       L0410               * 0408 27 06          '.
                    addd      U000A,U             * 040A E3 4A          cJ
                    dec       U0003,U             * 040C 6A 43          jC
                    bra       L0406               * 040E 20 F6           v
L0410               std       U000A,U             * 0410 ED 4A          mJ
                    bra       L03E0               * 0412 20 CC           L
L0414               ldd       U0008,U             * 0414 EC 48          lH
                    puls      X                   * 0416 35 10          5.
                    puls      PC,Y                * 0418 35 A0          5
L041A               pshs      X                   * 041A 34 10          4.
                    std       U0008,U             * 041C ED 48          mH
                    lda       #48                 * 041E 86 30          .0
                    sta       0,X                 * 0420 A7 84          '.
                    sta       $01,X               * 0422 A7 01          '.
                    sta       $02,X               * 0424 A7 02          '.
                    sta       $03,X               * 0426 A7 03          '.
                    sta       $04,X               * 0428 A7 04          '.
                    ldd       #10000              * 042A CC 27 10       L'.
                    std       U000A,U             * 042D ED 4A          mJ
                    ldd       U0008,U             * 042F EC 48          lH
                    lbsr      L0479               * 0431 17 00 45       ..E
                    ldd       #1000               * 0434 CC 03 E8       L.h
                    std       U000A,U             * 0437 ED 4A          mJ
                    ldd       U0008,U             * 0439 EC 48          lH
                    bsr       L0479               * 043B 8D 3C          .<
                    ldd       #100                * 043D CC 00 64       L.d
                    std       U000A,U             * 0440 ED 4A          mJ
                    ldd       U0008,U             * 0442 EC 48          lH
                    bsr       L0479               * 0444 8D 33          .3
                    ldd       #10                 * 0446 CC 00 0A       L..
                    std       U000A,U             * 0449 ED 4A          mJ
                    ldd       U0008,U             * 044B EC 48          lH
                    bsr       L0479               * 044D 8D 2A          .*
                    ldd       #1                  * 044F CC 00 01       L..
                    std       U000A,U             * 0452 ED 4A          mJ
                    ldd       U0008,U             * 0454 EC 48          lH
                    bsr       L0479               * 0456 8D 21          .!
                    lda       #13                 * 0458 86 0D          ..
                    sta       0,X                 * 045A A7 84          '.
                    puls      X                   * 045C 35 10          5.
                    ldb       #32                 * 045E C6 20          F
L0460               lda       0,X                 * 0460 A6 84          &.
                    cmpa      #48                 * 0462 81 30          .0
                    bne       L046A               * 0464 26 04          &.
                    stb       ,X+                 * 0466 E7 80          g.
                    bra       L0460               * 0468 20 F6           v
L046A               lda       ,X+                 * 046A A6 80          &.
                    cmpa      #48                 * 046C 81 30          .0
                    bcs       L0476               * 046E 25 06          %.
                    cmpa      #57                 * 0470 81 39          .9
                    bhi       L0476               * 0472 22 02          ".
                    bra       L046A               * 0474 20 F4           t
L0476               leax      -$01,X              * 0476 30 1F          0.
                    rts                           * 0478 39             9
L0479               subd      U000A,U             * 0479 A3 4A          #J
                    bcs       L0481               * 047B 25 04          %.
                    inc       0,X                 * 047D 6C 84          l.
                    bra       L0479               * 047F 20 F8           x
L0481               addd      U000A,U             * 0481 E3 4A          cJ
                    std       U0008,U             * 0483 ED 48          mH
                    leax      $01,X               * 0485 30 01          0.
                    rts                           * 0487 39             9
L0488               ldd       #-1                 * 0488 CC FF FF       L..
                    puls      PC,Y                * 048B 35 A0          5

                    emod
eom                 equ       *
                    end
