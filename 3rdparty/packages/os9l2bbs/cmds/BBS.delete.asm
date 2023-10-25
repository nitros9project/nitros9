                    nam       BBS.delete
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
U0003               rmb       4
U0007               rmb       1
U0008               rmb       1
U0009               rmb       2
U000B               rmb       12
U0017               rmb       1
U0018               rmb       6
U001E               rmb       1
U001F               rmb       1
U0020               rmb       11
U002B               rmb       64
U006B               rmb       60
U00A7               rmb       1
U00A8               rmb       203
size                equ       .

name                fcs       /BBS.delete/        * 000D 42 42 53 2E 64 65 6C 65 74 E5 BBS.delete
                    fcc       "Copyright (C) 1988" * 0017 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 Copyright (C) 1988
                    fcc       "By Keith Alphonso" * 0029 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F By Keith Alphonso
                    fcc       "Licenced to Alpha Software Technologies" * 003A 4C 69 63 65 6E 63 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licenced to Alpha Software Technologies
                    fcc       "All rights reserved" * 0061 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 All rights reserved
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
L0082               fcc       "High message is #" * 0082 48 69 67 68 20 6D 65 73 73 61 67 65 20 69 73 20 23 High message is #
L0093               fcb       $00                 * 0093 00             .
                    fcb       $11                 * 0094 11             .
L0095               fcc       "Enter message number to delete" * 0095 45 6E 74 65 72 20 6D 65 73 73 61 67 65 20 6E 75 6D 62 65 72 20 74 6F 20 64 65 6C 65 74 65 Enter message number to delete
                    fcb       $0D                 * 00B3 0D             .
L00B4               fcc       ">Msg #    User name              Date        Subject" * 00B4 3E 4D 73 67 20 23 20 20 20 20 55 73 65 72 20 6E 61 6D 65 20 20 20 20 20 20 20 20 20 20 20 20 20 20 44 61 74 65 20 20 20 20 20 20 20 20 53 75 62 6A 65 63 74 >Msg #    Use
                    fcb       $0D                 * 00E8 0D             .
                    fcc       "-------------------------------------------------------------------------------" * 00E9 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 0138 0D             .
L0139               fcc       "BBS.msg.inx"       * 0139 42 42 53 2E 6D 73 67 2E 69 6E 78 BBS.msg.inx
                    fcb       $0D                 * 0144 0D             .
                    fcc       "                                       " * 0145 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
L016C               fcc       "          ******   DELETED   ******" * 016C 20 20 20 20 20 20 20 20 20 20 2A 2A 2A 2A 2A 2A 20 20 20 44 45 4C 45 54 45 44 20 20 20 2A 2A 2A 2A 2A 2A           ******   DELETED   ******
                    fcb       $0D                 * 018F 0D             .
L0190               fcc       "Sorry, you cannot delete that message" * 0190 53 6F 72 72 79 2C 20 79 6F 75 20 63 61 6E 6E 6F 74 20 64 65 6C 65 74 65 20 74 68 61 74 20 6D 65 73 73 61 67 65 Sorry, you cannot delete that message
                    fcb       $0D                 * 01B5 0D             .

start               os9       F$ID                * 01B6 10 3F 0C       .?.
                    sty       U0003,U             * 01B9 10 AF 43       ./C
                    ldy       #0                  * 01BC 10 8E 00 00    ....
                    os9       F$SUser             * 01C0 10 3F 1C       .?.
                    leax      >L0139,PC           * 01C3 30 8D FF 72    0..r
                    lda       #3                  * 01C7 86 03          ..
                    os9       I$Open              * 01C9 10 3F 84       .?.
                    lbcs      L02C4               * 01CC 10 25 00 F4    .%.t
                    sta       U0000,U             * 01D0 A7 C4          'D
                    leax      <U002B,U            * 01D2 30 C8 2B       0H+
                    ldy       #64                 * 01D5 10 8E 00 40    ...@
                    lda       U0000,U             * 01D9 A6 C4          &D
                    os9       I$Read              * 01DB 10 3F 89       .?.
                    lbcs      L02C4               * 01DE 10 25 00 E2    .%.b
                    ldd       <U002B,U            * 01E2 EC C8 2B       lH+
                    leax      U000B,U             * 01E5 30 4B          0K
                    lbsr      L0347               * 01E7 17 01 5D       ..]
                    leax      >L0082,PC           * 01EA 30 8D FE 94    0.~.
                    ldy       >L0093,PC           * 01EE 10 AE 8D FE A0 ...~
                    lda       #1                  * 01F3 86 01          ..
                    os9       I$Write             * 01F5 10 3F 8A       .?.
                    lbcs      L02C4               * 01F8 10 25 00 C8    .%.H
                    leax      U000B,U             * 01FC 30 4B          0K
                    ldy       #6                  * 01FE 10 8E 00 06    ....
                    os9       I$WritLn            * 0202 10 3F 8C       .?.
                    lbcs      L02C4               * 0205 10 25 00 BB    .%.;
                    leax      >L0095,PC           * 0209 30 8D FE 88    0.~.
                    ldy       #200                * 020D 10 8E 00 C8    ...H
                    lda       #1                  * 0211 86 01          ..
                    os9       I$WritLn            * 0213 10 3F 8C       .?.
                    lbcs      L02C4               * 0216 10 25 00 AA    .%.*
                    leax      >L00B4,PC           * 021A 30 8D FE 96    0.~.
                    ldy       #1                  * 021E 10 8E 00 01    ....
                    os9       I$Write             * 0222 10 3F 8A       .?.
                    lbcs      L02C4               * 0225 10 25 00 9B    .%..
                    leax      <U0018,U            * 0229 30 C8 18       0H.
                    ldy       #6                  * 022C 10 8E 00 06    ....
                    clra                          * 0230 4F             O
                    os9       I$ReadLn            * 0231 10 3F 8B       .?.
                    lbcs      L02C4               * 0234 10 25 00 8C    .%..
                    clr       <U0017,U            * 0238 6F C8 17       oH.
                    leax      <U0018,U            * 023B 30 C8 18       0H.
                    lda       #13                 * 023E 86 0D          ..
                    sta       $02,X               * 0240 A7 02          '.
                    lbsr      L02E0               * 0242 17 00 9B       ...
                    cmpd      #1                  * 0245 10 83 00 01    ....
                    lbcs      L02C3               * 0249 10 25 00 76    .%.v
                    cmpd      <U002B,U            * 024D 10 A3 C8 2B    .#H+
                    lbhi      L02C3               * 0251 10 22 00 6E    .".n
                    std       U000B,U             * 0255 ED 4B          mK
                    ldy       U0003,U             * 0257 10 AE 43       ..C
                    beq       L0276               * 025A 27 1A          '.
                    bsr       L0298               * 025C 8D 3A          .:
                    leax      <U006B,U            * 025E 30 C8 6B       0Hk
                    ldy       #64                 * 0261 10 8E 00 40    ...@
                    lda       U0000,U             * 0265 A6 C4          &D
                    os9       I$Read              * 0267 10 3F 89       .?.
                    ldy       U0003,U             * 026A 10 AE 43       ..C
                    cmpy      >U00A7,U            * 026D 10 AC C9 00 A7 .,I.'
                    lbne      L02D1               * 0272 10 26 00 5B    .&.[
L0276               bsr       L0298               * 0276 8D 20          .
                    leax      <U006B,U            * 0278 30 C8 6B       0Hk
                    ldd       #-1                 * 027B CC FF FF       L..
                    std       0,X                 * 027E ED 84          m.
                    ldy       #64                 * 0280 10 8E 00 40    ...@
                    lda       U0000,U             * 0284 A6 C4          &D
                    os9       I$Write             * 0286 10 3F 8A       .?.
                    leax      >L016C,PC           * 0289 30 8D FE DF    0.~_
                    ldy       #200                * 028D 10 8E 00 C8    ...H
                    lda       #1                  * 0291 86 01          ..
                    os9       I$WritLn            * 0293 10 3F 8C       .?.
                    bra       L02C3               * 0296 20 2B           +
L0298               clr       <U001E,U            * 0298 6F C8 1E       oH.
                    clr       <U001F,U            * 029B 6F C8 1F       oH.
                    lda       #6                  * 029E 86 06          ..
                    sta       U0001,U             * 02A0 A7 41          'A
                    ldd       U000B,U             * 02A2 EC 4B          lK
L02A4               aslb                          * 02A4 58             X
                    rola                          * 02A5 49             I
                    rol       <U001F,U            * 02A6 69 C8 1F       iH.
                    dec       U0001,U             * 02A9 6A 41          jA
                    bne       L02A4               * 02AB 26 F7          &w
                    std       <U0020,U            * 02AD ED C8 20       mH
                    ldx       <U001E,U            * 02B0 AE C8 1E       .H.
                    lda       U0000,U             * 02B3 A6 C4          &D
                    pshs      U                   * 02B5 34 40          4@
                    ldu       <U0020,U            * 02B7 EE C8 20       nH
                    os9       I$Seek              * 02BA 10 3F 88       .?.
                    lbcs      L02C4               * 02BD 10 25 00 03    .%..
                    puls      PC,U                * 02C1 35 C0          5@
L02C3               clrb                          * 02C3 5F             _
L02C4               pshs      B                   * 02C4 34 04          4.
                    ldy       U0003,U             * 02C6 10 AE 43       ..C
                    os9       F$SUser             * 02C9 10 3F 1C       .?.
                    puls      B                   * 02CC 35 04          5.
                    os9       F$Exit              * 02CE 10 3F 06       .?.
L02D1               leax      >L0190,PC           * 02D1 30 8D FE BB    0.~;
                    ldy       #200                * 02D5 10 8E 00 C8    ...H
                    lda       #1                  * 02D9 86 01          ..
                    os9       I$WritLn            * 02DB 10 3F 8C       .?.
                    bra       L02C3               * 02DE 20 E3           c
L02E0               pshs      Y                   * 02E0 34 20          4
L02E2               lda       ,X+                 * 02E2 A6 80          &.
                    cmpa      #13                 * 02E4 81 0D          ..
                    lbeq      L03B5               * 02E6 10 27 00 CB    .'.K
                    cmpa      #48                 * 02EA 81 30          .0
                    bcs       L02E2               * 02EC 25 F4          %t
                    cmpa      #57                 * 02EE 81 39          .9
                    bhi       L02E2               * 02F0 22 F0          "p
                    leax      -$01,X              * 02F2 30 1F          0.
L02F4               lda       ,X+                 * 02F4 A6 80          &.
                    cmpa      #48                 * 02F6 81 30          .0
                    bcs       L0300               * 02F8 25 06          %.
                    cmpa      #57                 * 02FA 81 39          .9
                    bhi       L0300               * 02FC 22 02          ".
                    bra       L02F4               * 02FE 20 F4           t
L0300               pshs      X                   * 0300 34 10          4.
                    leax      -$01,X              * 0302 30 1F          0.
                    clr       U0007,U             * 0304 6F 47          oG
                    clr       U0008,U             * 0306 6F 48          oH
                    ldd       #1                  * 0308 CC 00 01       L..
                    std       U0009,U             * 030B ED 49          mI
L030D               lda       ,-X                 * 030D A6 82          &.
                    cmpa      #48                 * 030F 81 30          .0
                    bcs       L0341               * 0311 25 2E          %.
                    cmpa      #57                 * 0313 81 39          .9
                    bhi       L0341               * 0315 22 2A          "*
                    suba      #48                 * 0317 80 30          .0
                    sta       U0002,U             * 0319 A7 42          'B
                    ldd       #0                  * 031B CC 00 00       L..
L031E               tst       U0002,U             * 031E 6D 42          mB
                    beq       L0328               * 0320 27 06          '.
                    addd      U0009,U             * 0322 E3 49          cI
                    dec       U0002,U             * 0324 6A 42          jB
                    bra       L031E               * 0326 20 F6           v
L0328               addd      U0007,U             * 0328 E3 47          cG
                    std       U0007,U             * 032A ED 47          mG
                    lda       #10                 * 032C 86 0A          ..
                    sta       U0002,U             * 032E A7 42          'B
                    ldd       #0                  * 0330 CC 00 00       L..
L0333               tst       U0002,U             * 0333 6D 42          mB
                    beq       L033D               * 0335 27 06          '.
                    addd      U0009,U             * 0337 E3 49          cI
                    dec       U0002,U             * 0339 6A 42          jB
                    bra       L0333               * 033B 20 F6           v
L033D               std       U0009,U             * 033D ED 49          mI
                    bra       L030D               * 033F 20 CC           L
L0341               ldd       U0007,U             * 0341 EC 47          lG
                    puls      X                   * 0343 35 10          5.
                    puls      PC,Y                * 0345 35 A0          5
L0347               pshs      X                   * 0347 34 10          4.
                    std       U0007,U             * 0349 ED 47          mG
                    lda       #48                 * 034B 86 30          .0
                    sta       0,X                 * 034D A7 84          '.
                    sta       $01,X               * 034F A7 01          '.
                    sta       $02,X               * 0351 A7 02          '.
                    sta       $03,X               * 0353 A7 03          '.
                    sta       $04,X               * 0355 A7 04          '.
                    ldd       #10000              * 0357 CC 27 10       L'.
                    std       U0009,U             * 035A ED 49          mI
                    ldd       U0007,U             * 035C EC 47          lG
                    lbsr      L03A6               * 035E 17 00 45       ..E
                    ldd       #1000               * 0361 CC 03 E8       L.h
                    std       U0009,U             * 0364 ED 49          mI
                    ldd       U0007,U             * 0366 EC 47          lG
                    bsr       L03A6               * 0368 8D 3C          .<
                    ldd       #100                * 036A CC 00 64       L.d
                    std       U0009,U             * 036D ED 49          mI
                    ldd       U0007,U             * 036F EC 47          lG
                    bsr       L03A6               * 0371 8D 33          .3
                    ldd       #10                 * 0373 CC 00 0A       L..
                    std       U0009,U             * 0376 ED 49          mI
                    ldd       U0007,U             * 0378 EC 47          lG
                    bsr       L03A6               * 037A 8D 2A          .*
                    ldd       #1                  * 037C CC 00 01       L..
                    std       U0009,U             * 037F ED 49          mI
                    ldd       U0007,U             * 0381 EC 47          lG
                    bsr       L03A6               * 0383 8D 21          .!
                    lda       #13                 * 0385 86 0D          ..
                    sta       0,X                 * 0387 A7 84          '.
                    puls      X                   * 0389 35 10          5.
                    ldb       #32                 * 038B C6 20          F
L038D               lda       0,X                 * 038D A6 84          &.
                    cmpa      #48                 * 038F 81 30          .0
                    bne       L0397               * 0391 26 04          &.
                    stb       ,X+                 * 0393 E7 80          g.
                    bra       L038D               * 0395 20 F6           v
L0397               lda       ,X+                 * 0397 A6 80          &.
                    cmpa      #48                 * 0399 81 30          .0
                    bcs       L03A3               * 039B 25 06          %.
                    cmpa      #57                 * 039D 81 39          .9
                    bhi       L03A3               * 039F 22 02          ".
                    bra       L0397               * 03A1 20 F4           t
L03A3               leax      -$01,X              * 03A3 30 1F          0.
                    rts                           * 03A5 39             9
L03A6               subd      U0009,U             * 03A6 A3 49          #I
                    bcs       L03AE               * 03A8 25 04          %.
                    inc       0,X                 * 03AA 6C 84          l.
                    bra       L03A6               * 03AC 20 F8           x
L03AE               addd      U0009,U             * 03AE E3 49          cI
                    std       U0007,U             * 03B0 ED 47          mG
                    leax      $01,X               * 03B2 30 01          0.
                    rts                           * 03B4 39             9
L03B5               ldd       #-1                 * 03B5 CC FF FF       L..
                    puls      PC,Y                * 03B8 35 A0          5

                    emod
eom                 equ       *
                    end
