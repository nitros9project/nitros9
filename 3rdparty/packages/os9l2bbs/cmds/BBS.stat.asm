                    nam       BBS.stat
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
U0006               rmb       2
U0008               rmb       2
U000A               rmb       8
U0012               rmb       2
U0014               rmb       2
U0016               rmb       2
U0018               rmb       2
U001A               rmb       6
U0020               rmb       8
U0028               rmb       3
U002B               rmb       2
U002D               rmb       1
U002E               rmb       400
size                equ       .

name                fcs       /BBS.stat/
L0015               fcc       "User Statistics:"
                    fcb       $0D
L0026               fcc       "----------------------------------------------"
                    fcb       $0D
L0055               fcc       "Last on         : "
L0067               fcc       "Times called    : "
L0079               fcc       "Messages left   : "
L008B               fcc       "Messages read   : "
L009D               fcc       "Files downloaded: "
L00AF               fcc       "Files uploaded  : "
L00C1               fcc       "Time this login : "
L00D3               fcc       "User # to check:"
L00E3               fcc       "/dd/bbs/BBS.userstats"
L00F8               fcc       "           January February    March    April      May     June     July   AugustSeptember  October November December"
L016D               fcc       ", 19"              * 016D 2C 20 31 39    , 19
L0171               fcb       $3A                 * 0171 3A             :
start               leax      >L00E3,PC           * 0172 30 8D FF 6D    0..m
                    lda       #1                  * 0176 86 01          ..
                    os9       I$Open              * 0178 10 3F 84       .?.
                    lbcs      L0264               * 017B 10 25 00 E5    .%.e
                    sta       U0000,U             * 017F A7 C4          'D
                    os9       F$ID                * 0181 10 3F 0C       .?.
                    sty       U0006,U             * 0184 10 AF 46       ./F
                    lda       #13                 * 0187 86 0D          ..
                    sta       <U002D,U            * 0189 A7 C8 2D       'H-
                    ldd       U0006,U             * 018C EC 46          lF
                    cmpd      #0                  * 018E 10 83 00 00    ....
                    bne       L0197               * 0192 26 03          &.
                    lbsr      L03EA               * 0194 17 02 53       ..S
L0197               leax      U0008,U             * 0197 30 48          0H
                    ldy       #32                 * 0199 10 8E 00 20    ...
                    lda       U0000,U             * 019D A6 C4          &D
                    os9       I$Read              * 019F 10 3F 89       .?.
                    bcs       L01AD               * 01A2 25 09          %.
                    ldd       U0008,U             * 01A4 EC 48          lH
                    cmpd      U0006,U             * 01A6 10 A3 46       .#F
                    beq       L01B6               * 01A9 27 0B          '.
                    bra       L0197               * 01AB 20 EA           j
L01AD               cmpb      #211                * 01AD C1 D3          AS
                    lbne      L0265               * 01AF 10 26 00 B2    .&.2
                    lbra      L0264               * 01B3 16 00 AE       ...
L01B6               leax      >L0015,PC           * 01B6 30 8D FE 5B    0.~[
                    ldy       #200                * 01BA 10 8E 00 C8    ...H
                    lda       #1                  * 01BE 86 01          ..
                    os9       I$WritLn            * 01C0 10 3F 8C       .?.
                    leax      >L0026,PC           * 01C3 30 8D FE 5F    0.~_
                    ldy       #200                * 01C7 10 8E 00 C8    ...H
                    os9       I$WritLn            * 01CB 10 3F 8C       .?.
                    leax      >L0055,PC           * 01CE 30 8D FE 83    0.~.
                    ldy       #18                 * 01D2 10 8E 00 12    ....
                    lda       #1                  * 01D6 86 01          ..
                    os9       I$Write             * 01D8 10 3F 8A       .?.
                    leax      <U001A,U            * 01DB 30 C8 1A       0H.
                    lbsr      L0289               * 01DE 17 00 A8       ..(
                    leax      >L0067,PC           * 01E1 30 8D FE 82    0.~.
                    ldy       #18                 * 01E5 10 8E 00 12    ....
                    lda       #1                  * 01E9 86 01          ..
                    os9       I$Write             * 01EB 10 3F 8A       .?.
                    ldd       U000A,U             * 01EE EC 4A          lJ
                    lbsr      L0268               * 01F0 17 00 75       ..u
                    leax      >L009D,PC           * 01F3 30 8D FE A6    0.~&
                    ldy       #18                 * 01F7 10 8E 00 12    ....
                    lda       #1                  * 01FB 86 01          ..
                    os9       I$Write             * 01FD 10 3F 8A       .?.
                    ldd       <U0016,U            * 0200 EC C8 16       lH.
                    lbsr      L0268               * 0203 17 00 62       ..b
                    leax      >L00AF,PC           * 0206 30 8D FE A5    0.~%
                    ldy       #18                 * 020A 10 8E 00 12    ....
                    lda       #1                  * 020E 86 01          ..
                    os9       I$Write             * 0210 10 3F 8A       .?.
                    ldd       <U0018,U            * 0213 EC C8 18       lH.
                    lbsr      L0268               * 0216 17 00 4F       ..O
                    leax      >L0079,PC           * 0219 30 8D FE 5C    0.~\
                    ldy       #18                 * 021D 10 8E 00 12    ....
                    lda       #1                  * 0221 86 01          ..
                    os9       I$Write             * 0223 10 3F 8A       .?.
                    ldd       <U0012,U            * 0226 EC C8 12       lH.
                    lbsr      L0268               * 0229 17 00 3C       ..<
                    leax      >L008B,PC           * 022C 30 8D FE 5B    0.~[
                    ldy       #18                 * 0230 10 8E 00 12    ....
                    lda       #1                  * 0234 86 01          ..
                    os9       I$Write             * 0236 10 3F 8A       .?.
                    ldd       <U0014,U            * 0239 EC C8 14       lH.
                    lbsr      L0268               * 023C 17 00 29       ..)
                    ldd       <U0020,U            * 023F EC C8 20       lH
                    beq       L0257               * 0242 27 13          '.
                    leax      >L00C1,PC           * 0244 30 8D FE 79    0.~y
                    ldy       #18                 * 0248 10 8E 00 12    ....
                    lda       #1                  * 024C 86 01          ..
                    os9       I$Write             * 024E 10 3F 8A       .?.
                    ldd       <U0020,U            * 0251 EC C8 20       lH
                    lbsr      L0268               * 0254 17 00 11       ...
L0257               leax      >L0026,PC           * 0257 30 8D FD CB    0.}K
                    lda       #1                  * 025B 86 01          ..
                    ldy       #200                * 025D 10 8E 00 C8    ...H
                    os9       I$WritLn            * 0261 10 3F 8C       .?.
L0264               clrb                          * 0264 5F             _
L0265               os9       F$Exit              * 0265 10 3F 06       .?.
L0268               leax      <U0028,U            * 0268 30 C8 28       0H(
                    lbsr      L0395               * 026B 17 01 27       ..'
                    leax      <U0028,U            * 026E 30 C8 28       0H(
L0271               lda       ,X+                 * 0271 A6 80          &.
                    cmpa      #48                 * 0273 81 30          .0
                    beq       L0271               * 0275 27 FA          'z
                    cmpa      #13                 * 0277 81 0D          ..
                    bne       L027D               * 0279 26 02          &.
                    leax      -$01,X              * 027B 30 1F          0.
L027D               leax      -$01,X              * 027D 30 1F          0.
                    ldy       #200                * 027F 10 8E 00 C8    ...H
                    lda       #1                  * 0283 86 01          ..
                    os9       I$WritLn            * 0285 10 3F 8C       .?.
                    rts                           * 0288 39             9
L0289               lda       $01,X               * 0289 A6 01          &.
                    ldb       #9                  * 028B C6 09          F.
                    mul                           * 028D 3D             =
                    pshs      X                   * 028E 34 10          4.
                    leax      >L00F8,PC           * 0290 30 8D FE 64    0.~d
                    leax      D,X                 * 0294 30 8B          0.
                    ldy       #10                 * 0296 10 8E 00 0A    ....
L029A               lda       ,X+                 * 029A A6 80          &.
                    cmpa      #32                 * 029C 81 20          .
                    bne       L02A4               * 029E 26 04          &.
                    leay      -$01,Y              * 02A0 31 3F          1?
                    bne       L029A               * 02A2 26 F6          &v
L02A4               leax      -$01,X              * 02A4 30 1F          0.
                    lda       #1                  * 02A6 86 01          ..
                    os9       I$Write             * 02A8 10 3F 8A       .?.
                    ldx       0,S                 * 02AB AE E4          .d
                    ldb       $02,X               * 02AD E6 02          f.
                    clra                          * 02AF 4F             O
                    leax      <U0028,U            * 02B0 30 C8 28       0H(
                    lbsr      L0395               * 02B3 17 00 DF       .._
                    leax      <U0028,U            * 02B6 30 C8 28       0H(
                    leax      $03,X               * 02B9 30 03          0.
                    ldy       #2                  * 02BB 10 8E 00 02    ....
                    lda       #1                  * 02BF 86 01          ..
                    os9       I$Write             * 02C1 10 3F 8A       .?.
                    leax      >L016D,PC           * 02C4 30 8D FE A5    0.~%
                    ldy       #4                  * 02C8 10 8E 00 04    ....
                    os9       I$Write             * 02CC 10 3F 8A       .?.
                    ldx       0,S                 * 02CF AE E4          .d
                    ldb       0,X                 * 02D1 E6 84          f.
                    clra                          * 02D3 4F             O
                    leax      <U0028,U            * 02D4 30 C8 28       0H(
                    lbsr      L0395               * 02D7 17 00 BB       ..;
                    leax      <U002B,U            * 02DA 30 C8 2B       0H+
                    ldy       #2                  * 02DD 10 8E 00 02    ....
                    lda       #1                  * 02E1 86 01          ..
                    os9       I$Write             * 02E3 10 3F 8A       .?.
                    leax      >L00F8,PC           * 02E6 30 8D FE 0E    0.~.
                    ldy       #1                  * 02EA 10 8E 00 01    ....
                    os9       I$Write             * 02EE 10 3F 8A       .?.
                    clra                          * 02F1 4F             O
                    ldx       0,S                 * 02F2 AE E4          .d
                    ldb       $03,X               * 02F4 E6 03          f.
                    leax      <U0028,U            * 02F6 30 C8 28       0H(
                    lbsr      L0395               * 02F9 17 00 99       ...
                    leax      <U002B,U            * 02FC 30 C8 2B       0H+
                    ldy       #2                  * 02FF 10 8E 00 02    ....
                    lda       #1                  * 0303 86 01          ..
                    os9       I$Write             * 0305 10 3F 8A       .?.
                    leax      >L0171,PC           * 0308 30 8D FE 65    0.~e
                    ldy       #1                  * 030C 10 8E 00 01    ....
                    os9       I$Write             * 0310 10 3F 8A       .?.
                    clra                          * 0313 4F             O
                    ldx       0,S                 * 0314 AE E4          .d
                    ldb       $04,X               * 0316 E6 04          f.
                    leax      <U0028,U            * 0318 30 C8 28       0H(
                    lbsr      L0395               * 031B 17 00 77       ..w
                    leax      <U0028,U            * 031E 30 C8 28       0H(
                    leax      $03,X               * 0321 30 03          0.
                    ldy       #200                * 0323 10 8E 00 C8    ...H
                    lda       #1                  * 0327 86 01          ..
                    os9       I$WritLn            * 0329 10 3F 8C       .?.
                    puls      PC,X                * 032C 35 90          5.
L032E               pshs      Y                   * 032E 34 20          4
L0330               lda       ,X+                 * 0330 A6 80          &.
                    cmpa      #13                 * 0332 81 0D          ..
                    lbeq      L03E5               * 0334 10 27 00 AD    .'.-
                    cmpa      #48                 * 0338 81 30          .0
                    bcs       L0330               * 033A 25 F4          %t
                    cmpa      #57                 * 033C 81 39          .9
                    bhi       L0330               * 033E 22 F0          "p
                    leax      -$01,X              * 0340 30 1F          0.
L0342               lda       ,X+                 * 0342 A6 80          &.
                    cmpa      #48                 * 0344 81 30          .0
                    bcs       L034E               * 0346 25 06          %.
                    cmpa      #57                 * 0348 81 39          .9
                    bhi       L034E               * 034A 22 02          ".
                    bra       L0342               * 034C 20 F4           t
L034E               pshs      X                   * 034E 34 10          4.
                    leax      -$01,X              * 0350 30 1F          0.
                    clr       U0002,U             * 0352 6F 42          oB
                    clr       U0003,U             * 0354 6F 43          oC
                    ldd       #1                  * 0356 CC 00 01       L..
                    std       U0004,U             * 0359 ED 44          mD
L035B               lda       ,-X                 * 035B A6 82          &.
                    cmpa      #48                 * 035D 81 30          .0
                    bcs       L038F               * 035F 25 2E          %.
                    cmpa      #57                 * 0361 81 39          .9
                    bhi       L038F               * 0363 22 2A          "*
                    suba      #48                 * 0365 80 30          .0
                    sta       U0001,U             * 0367 A7 41          'A
                    ldd       #0                  * 0369 CC 00 00       L..
L036C               tst       U0001,U             * 036C 6D 41          mA
                    beq       L0376               * 036E 27 06          '.
                    addd      U0004,U             * 0370 E3 44          cD
                    dec       U0001,U             * 0372 6A 41          jA
                    bra       L036C               * 0374 20 F6           v
L0376               addd      U0002,U             * 0376 E3 42          cB
                    std       U0002,U             * 0378 ED 42          mB
                    lda       #10                 * 037A 86 0A          ..
                    sta       U0001,U             * 037C A7 41          'A
                    ldd       #0                  * 037E CC 00 00       L..
L0381               tst       U0001,U             * 0381 6D 41          mA
                    beq       L038B               * 0383 27 06          '.
                    addd      U0004,U             * 0385 E3 44          cD
                    dec       U0001,U             * 0387 6A 41          jA
                    bra       L0381               * 0389 20 F6           v
L038B               std       U0004,U             * 038B ED 44          mD
                    bra       L035B               * 038D 20 CC           L
L038F               ldd       U0002,U             * 038F EC 42          lB
                    puls      X                   * 0391 35 10          5.
                    puls      PC,Y                * 0393 35 A0          5
L0395               std       U0002,U             * 0395 ED 42          mB
                    lda       #48                 * 0397 86 30          .0
                    sta       0,X                 * 0399 A7 84          '.
                    sta       $01,X               * 039B A7 01          '.
                    sta       $02,X               * 039D A7 02          '.
                    sta       $03,X               * 039F A7 03          '.
                    sta       $04,X               * 03A1 A7 04          '.
                    ldd       #10000              * 03A3 CC 27 10       L'.
                    std       U0004,U             * 03A6 ED 44          mD
                    ldd       U0002,U             * 03A8 EC 42          lB
                    lbsr      L03D6               * 03AA 17 00 29       ..)
                    ldd       #1000               * 03AD CC 03 E8       L.h
                    std       U0004,U             * 03B0 ED 44          mD
                    ldd       U0002,U             * 03B2 EC 42          lB
                    bsr       L03D6               * 03B4 8D 20          .
                    ldd       #100                * 03B6 CC 00 64       L.d
                    std       U0004,U             * 03B9 ED 44          mD
                    ldd       U0002,U             * 03BB EC 42          lB
                    bsr       L03D6               * 03BD 8D 17          ..
                    ldd       #10                 * 03BF CC 00 0A       L..
                    std       U0004,U             * 03C2 ED 44          mD
                    ldd       U0002,U             * 03C4 EC 42          lB
                    bsr       L03D6               * 03C6 8D 0E          ..
                    ldd       #1                  * 03C8 CC 00 01       L..
                    std       U0004,U             * 03CB ED 44          mD
                    ldd       U0002,U             * 03CD EC 42          lB
                    bsr       L03D6               * 03CF 8D 05          ..
                    lda       #13                 * 03D1 86 0D          ..
                    sta       0,X                 * 03D3 A7 84          '.
                    rts                           * 03D5 39             9
L03D6               subd      U0004,U             * 03D6 A3 44          #D
                    bcs       L03DE               * 03D8 25 04          %.
                    inc       0,X                 * 03DA 6C 84          l.
                    bra       L03D6               * 03DC 20 F8           x
L03DE               addd      U0004,U             * 03DE E3 44          cD
                    std       U0002,U             * 03E0 ED 42          mB
                    leax      $01,X               * 03E2 30 01          0.
                    rts                           * 03E4 39             9
L03E5               ldb       #1                  * 03E5 C6 01          F.
                    lbra      L0265               * 03E7 16 FE 7B       .~{
L03EA               leax      >L00D3,PC           * 03EA 30 8D FC E5    0.|e
                    ldy       #16                 * 03EE 10 8E 00 10    ....
                    lda       #1                  * 03F2 86 01          ..
                    os9       I$Write             * 03F4 10 3F 8A       .?.
                    leax      <U0028,U            * 03F7 30 C8 28       0H(
                    ldy       #5                  * 03FA 10 8E 00 05    ....
                    clra                          * 03FE 4F             O
                    os9       I$ReadLn            * 03FF 10 3F 8B       .?.
                    lbsr      L032E               * 0402 17 FF 29       ..)
                    std       U0006,U             * 0405 ED 46          mF
                    rts                           * 0407 39             9

                    emod
eom                 equ       *
                    end
