                    nam       Uloady
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
U0006               rmb       2
U0008               rmb       2
U000A               rmb       2
U000C               rmb       2
U000E               rmb       1
U000F               rmb       1
U0010               rmb       2
U0012               rmb       32
U0032               rmb       1
U0033               rmb       1
U0034               rmb       128
U00B4               rmb       896
U0434               rmb       2
U0436               rmb       32
U0456               rmb       1
U0457               rmb       431
size                equ       .

name                fcs       /Uloady/            * 000D 55 6C 6F 61 64 F9 Uloady
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
L007E               fcc       "File open, ready to recieve..." * 007E 46 69 6C 65 20 6F 70 65 6E 2C 20 72 65 61 64 79 20 74 6F 20 72 65 63 69 65 76 65 2E 2E 2E File open, ready to recieve...
                    fcb       $0D                 * 009C 0D             .
L009D               fcc       "Enter filename to upload: " * 009D 45 6E 74 65 72 20 66 69 6C 65 6E 61 6D 65 20 74 6F 20 75 70 6C 6F 61 64 3A 20 Enter filename to upload:
L00B7               fcc       "Upload aborted!"   * 00B7 55 70 6C 6F 61 64 20 61 62 6F 72 74 65 64 21 Upload aborted!
                    fcb       $0D                 * 00C6 0D             .
L00C7               fcc       "Upload successful!" * 00C7 55 70 6C 6F 61 64 20 73 75 63 63 65 73 73 66 75 6C 21 Upload successful!
                    fcb       $0D                 * 00D9 0D             .
start               pshs      X                   * 00DA 34 10          4.
                    os9       F$ID                * 00DC 10 3F 0C       .?.
                    ldb       #255                * 00DF C6 FF          F.
                    os9       F$SPrior            * 00E1 10 3F 0D       .?.
                    lda       0,X                 * 00E4 A6 84          &.
                    cmpa      #13                 * 00E6 81 0D          ..
                    bne       L0102               * 00E8 26 18          &.
                    leax      >L009D,PC           * 00EA 30 8D FF AF    0../
                    ldy       #25                 * 00EE 10 8E 00 19    ....
                    lda       #1                  * 00F2 86 01          ..
                    os9       I$Write             * 00F4 10 3F 8A       .?.
                    leax      <U0012,U            * 00F7 30 C8 12       0H.
                    ldy       #32                 * 00FA 10 8E 00 20    ...
                    clra                          * 00FE 4F             O
                    os9       I$ReadLn            * 00FF 10 3F 8B       .?.
L0102               stx       <U0010,U            * 0102 AF C8 10       /H.
                    lda       #2                  * 0105 86 02          ..
                    ldb       #27                 * 0107 C6 1B          F.
                    os9       I$Create            * 0109 10 3F 83       .?.
                    lbcs      L03ED               * 010C 10 25 02 DD    .%.]
                    sta       U0001,U             * 0110 A7 41          'A
                    clr       U0003,U             * 0112 6F 43          oC
                    clr       U0002,U             * 0114 6F 42          oB
                    clr       >U00B4,U            * 0116 6F C9 00 B4    oI.4
                    dec       >U00B4,U            * 011A 6A C9 00 B4    jI.4
                    leax      >L007E,PC           * 011E 30 8D FF 5C    0..\
                    ldy       #200                * 0122 10 8E 00 C8    ...H
                    lda       #1                  * 0126 86 01          ..
                    os9       I$WritLn            * 0128 10 3F 8C       .?.
                    lda       #6                  * 012B 86 06          ..
                    sta       U0008,U             * 012D A7 48          'H
                    leax      >U0436,U            * 012F 30 C9 04 36    0I.6
                    clra                          * 0133 4F             O
                    clrb                          * 0134 5F             _
                    os9       I$GetStt            * 0135 10 3F 8D       .?.
                    lbcs      L03ED               * 0138 10 25 02 B1    .%.1
                    leax      >U0456,U            * 013C 30 C9 04 56    0I.V
                    clra                          * 0140 4F             O
                    clrb                          * 0141 5F             _
                    os9       I$GetStt            * 0142 10 3F 8D       .?.
                    lbcs      L03ED               * 0145 10 25 02 A4    .%.$
                    leax      >U0456,U            * 0149 30 C9 04 56    0I.V
                    leax      -$20,X              * 014D 30 88 E0       0.`
                    clr       <$002B,X            * 0150 6F 88 2B       o.+
                    clr       <$002C,X            * 0153 6F 88 2C       o.,
                    clr       <$002E,X            * 0156 6F 88 2E       o..
                    clr       <$002F,X            * 0159 6F 88 2F       o./
                    clr       <$0030,X            * 015C 6F 88 30       o.0
                    clr       <$0031,X            * 015F 6F 88 31       o.1
                    clr       <$0038,X            * 0162 6F 88 38       o.8
                    clr       <$0039,X            * 0165 6F 88 39       o.9
                    clr       <$0024,X            * 0168 6F 88 24       o.$
                    clr       <$002D,X            * 016B 6F 88 2D       o.-
                    clr       <$0027,X            * 016E 6F 88 27       o.'
                    clr       <$0028,X            * 0171 6F 88 28       o.(
                    clr       <$0029,X            * 0174 6F 88 29       o.)
                    clra                          * 0177 4F             O
                    clrb                          * 0178 5F             _
                    leax      >U0456,U            * 0179 30 C9 04 56    0I.V
                    os9       I$SetStt            * 017D 10 3F 8E       .?.
L0180               tst       U0008,U             * 0180 6D 48          mH
                    beq       L018C               * 0182 27 08          '.
                    dec       U0008,U             * 0184 6A 48          jH
                    lda       #67                 * 0186 86 43          .C
                    sta       U0000,U             * 0188 A7 C4          'D
                    bra       L0190               * 018A 20 04           .
L018C               lda       #21                 * 018C 86 15          ..
                    sta       U0000,U             * 018E A7 C4          'D
L0190               leax      U0000,U             * 0190 30 C4          0D
                    lda       #1                  * 0192 86 01          ..
                    ldy       #1                  * 0194 10 8E 00 01    ....
                    os9       I$Write             * 0198 10 3F 8A       .?.
                    clr       U0004,U             * 019B 6F 44          oD
                    clr       U0005,U             * 019D 6F 45          oE
                    lda       U0003,U             * 019F A6 43          &C
                    inca                          * 01A1 4C             L
                    sta       U0003,U             * 01A2 A7 43          'C
                    cmpa      #10                 * 01A4 81 0A          ..
                    bcs       L01AD               * 01A6 25 05          %.
                    ldb       #1                  * 01A8 C6 01          F.
                    lbra      L03E6               * 01AA 16 02 39       ..9
L01AD               clra                          * 01AD 4F             O
                    ldb       #1                  * 01AE C6 01          F.
                    os9       I$GetStt            * 01B0 10 3F 8D       .?.
                    bcc       L01C5               * 01B3 24 10          $.
                    ldy       U0004,U             * 01B5 10 AE 44       ..D
                    leay      $01,Y               * 01B8 31 21          1!
                    sty       U0004,U             * 01BA 10 AF 44       ./D
                    cmpy      #5376               * 01BD 10 8C 15 00    ....
                    bcc       L0180               * 01C1 24 BD          $=
                    bra       L01AD               * 01C3 20 E8           h
L01C5               leax      U0000,U             * 01C5 30 C4          0D
                    ldy       #1                  * 01C7 10 8E 00 01    ....
                    clra                          * 01CB 4F             O
                    os9       I$Read              * 01CC 10 3F 89       .?.
                    lda       U0000,U             * 01CF A6 C4          &D
                    cmpa      #1                  * 01D1 81 01          ..
                    beq       L020A               * 01D3 27 35          '5
                    cmpa      #2                  * 01D5 81 02          ..
                    beq       L01E7               * 01D7 27 0E          '.
                    cmpa      #4                  * 01D9 81 04          ..
                    lbeq      L03C1               * 01DB 10 27 01 E2    .'.b
                    cmpa      #24                 * 01DF 81 18          ..
                    lbeq      L03F0               * 01E1 10 27 02 0B    .'..
                    bra       L01AD               * 01E5 20 C6           F
L01E7               leax      <U0032,U            * 01E7 30 C8 32       0H2
                    tst       U0008,U             * 01EA 6D 48          mH
                    beq       L01F4               * 01EC 27 06          '.
                    ldy       #1028               * 01EE 10 8E 04 04    ....
                    bra       L01F8               * 01F2 20 04           .
L01F4               ldy       #1027               * 01F4 10 8E 04 03    ....
L01F8               sty       U0006,U             * 01F8 10 AF 46       ./F
                    clr       U0004,U             * 01FB 6F 44          oD
                    clr       U0005,U             * 01FD 6F 45          oE
                    bsr       L022D               * 01FF 8D 2C          .,
                    lbcs      L018C               * 0201 10 25 FF 87    .%..
                    inc       U0002,U             * 0205 6C 42          lB
                    lbra      L0311               * 0207 16 01 07       ...
L020A               leax      <U0032,U            * 020A 30 C8 32       0H2
                    tst       U0008,U             * 020D 6D 48          mH
                    beq       L0217               * 020F 27 06          '.
                    ldy       #132                * 0211 10 8E 00 84    ....
                    bra       L021B               * 0215 20 04           .
L0217               ldy       #131                * 0217 10 8E 00 83    ....
L021B               sty       U0006,U             * 021B 10 AF 46       ./F
                    clr       U0004,U             * 021E 6F 44          oD
                    clr       U0005,U             * 0220 6F 45          oE
                    bsr       L022D               * 0222 8D 09          ..
                    lbcs      L018C               * 0224 10 25 FF 64    .%.d
                    inc       U0002,U             * 0228 6C 42          lB
                    lbra      L027F               * 022A 16 00 52       ..R
L022D               clra                          * 022D 4F             O
                    ldb       #1                  * 022E C6 01          F.
                    os9       I$GetStt            * 0230 10 3F 8D       .?.
                    bcc       L0245               * 0233 24 10          $.
                    ldy       U0004,U             * 0235 10 AE 44       ..D
                    leay      $01,Y               * 0238 31 21          1!
                    sty       U0004,U             * 023A 10 AF 44       ./D
                    cmpy      #4096               * 023D 10 8C 10 00    ....
                    bhi       L0261               * 0241 22 1E          ".
                    bra       L022D               * 0243 20 E8           h
L0245               clr       U0004,U             * 0245 6F 44          oD
                    clr       U0005,U             * 0247 6F 45          oE
                    clra                          * 0249 4F             O
                    tfr       D,Y                 * 024A 1F 02          ..
                    os9       I$Read              * 024C 10 3F 89       .?.
                    bcs       L0265               * 024F 25 14          %.
                    tfr       Y,D                 * 0251 1F 20          .
                    leax      D,X                 * 0253 30 8B          0.
                    ldd       U0006,U             * 0255 EC 46          lF
                    sty       U0006,U             * 0257 10 AF 46       ./F
                    subd      U0006,U             * 025A A3 46          #F
                    std       U0006,U             * 025C ED 46          mF
                    bne       L022D               * 025E 26 CD          &M
                    rts                           * 0260 39             9
L0261               lda       #255                * 0261 86 FF          ..
                    rola                          * 0263 49             I
                    rts                           * 0264 39             9
L0265               pshs      X                   * 0265 34 10          4.
                    ldx       #60                 * 0267 8E 00 3C       ..<
                    os9       F$Sleep             * 026A 10 3F 0A       .?.
                    puls      X                   * 026D 35 10          5.
                    clra                          * 026F 4F             O
                    ldb       #1                  * 0270 C6 01          F.
                    os9       I$GetStt            * 0272 10 3F 8D       .?.
                    clra                          * 0275 4F             O
                    tfr       D,Y                 * 0276 1F 02          ..
                    os9       I$Read              * 0278 10 3F 89       .?.
                    lda       #255                * 027B 86 FF          ..
                    rola                          * 027D 49             I
                    rts                           * 027E 39             9
L027F               lda       <U0032,U            * 027F A6 C8 32       &H2
                    inca                          * 0282 4C             L
                    cmpa      U0002,U             * 0283 A1 42          !B
                    lbeq      L03A5               * 0285 10 27 01 1C    .'..
                    deca                          * 0289 4A             J
                    cmpa      U0002,U             * 028A A1 42          !B
                    beq       L0293               * 028C 27 05          '.
                    dec       U0002,U             * 028E 6A 42          jB
                    lbra      L018C               * 0290 16 FE F9       .~y
L0293               coma                          * 0293 43             C
                    cmpa      <U0033,U            * 0294 A1 C8 33       !H3
                    beq       L029E               * 0297 27 05          '.
                    dec       U0002,U             * 0299 6A 42          jB
                    lbra      L018C               * 029B 16 FE EE       .~n
L029E               leax      <U0034,U            * 029E 30 C8 34       0H4
                    tst       U0008,U             * 02A1 6D 48          mH
                    bne       L02BA               * 02A3 26 15          &.
                    ldb       #128                * 02A5 C6 80          F.
                    clra                          * 02A7 4F             O
L02A8               adda      ,X+                 * 02A8 AB 80          +.
                    decb                          * 02AA 5A             Z
                    bne       L02A8               * 02AB 26 FB          &{
                    cmpa      >U00B4,U            * 02AD A1 C9 00 B4    !I.4
                    lbeq      L0302               * 02B1 10 27 00 4D    .'.M
                    dec       U0002,U             * 02B5 6A 42          jB
                    lbra      L018C               * 02B7 16 FE D2       .~R
L02BA               ldy       #128                * 02BA 10 8E 00 80    ....
                    sty       U000A,U             * 02BE 10 AF 4A       ./J
                    clra                          * 02C1 4F             O
                    clrb                          * 02C2 5F             _
                    std       U000E,U             * 02C3 ED 4E          mN
L02C5               lda       ,X+                 * 02C5 A6 80          &.
                    clrb                          * 02C7 5F             _
                    eora      U000E,U             * 02C8 A8 4E          (N
                    eorb      U000F,U             * 02CA E8 4F          hO
                    std       U000E,U             * 02CC ED 4E          mN
                    lda       #8                  * 02CE 86 08          ..
                    sta       U000C,U             * 02D0 A7 4C          'L
L02D2               ldd       U000E,U             * 02D2 EC 4E          lN
                    bita      #128                * 02D4 85 80          ..
                    beq       L02E2               * 02D6 27 0A          '.
                    aslb                          * 02D8 58             X
                    rola                          * 02D9 49             I
                    eora      #16                 * 02DA 88 10          ..
                    eorb      #33                 * 02DC C8 21          H!
                    std       U000E,U             * 02DE ED 4E          mN
                    bra       L02E6               * 02E0 20 04           .
L02E2               aslb                          * 02E2 58             X
                    rola                          * 02E3 49             I
                    std       U000E,U             * 02E4 ED 4E          mN
L02E6               dec       U000C,U             * 02E6 6A 4C          jL
                    bne       L02D2               * 02E8 26 E8          &h
                    ldy       U000A,U             * 02EA 10 AE 4A       ..J
                    leay      -$01,Y              * 02ED 31 3F          1?
                    sty       U000A,U             * 02EF 10 AF 4A       ./J
                    bne       L02C5               * 02F2 26 D1          &Q
                    ldd       U000E,U             * 02F4 EC 4E          lN
                    cmpd      >U00B4,U            * 02F6 10 A3 C9 00 B4 .#I.4
                    beq       L0302               * 02FB 27 05          '.
                    dec       U0002,U             * 02FD 6A 42          jB
                    lbra      L018C               * 02FF 16 FE 8A       .~.
L0302               lda       U0001,U             * 0302 A6 41          &A
                    leax      <U0034,U            * 0304 30 C8 34       0H4
                    ldy       #128                * 0307 10 8E 00 80    ....
                    os9       I$Write             * 030B 10 3F 8A       .?.
                    lbra      L03A7               * 030E 16 00 96       ...
L0311               lda       <U0032,U            * 0311 A6 C8 32       &H2
                    inca                          * 0314 4C             L
                    cmpa      U0002,U             * 0315 A1 42          !B
                    lbeq      L03A5               * 0317 10 27 00 8A    .'..
                    deca                          * 031B 4A             J
                    cmpa      U0002,U             * 031C A1 42          !B
                    beq       L0325               * 031E 27 05          '.
                    dec       U0002,U             * 0320 6A 42          jB
                    lbra      L018C               * 0322 16 FE 67       .~g
L0325               coma                          * 0325 43             C
                    cmpa      <U0033,U            * 0326 A1 C8 33       !H3
                    beq       L0330               * 0329 27 05          '.
                    dec       U0002,U             * 032B 6A 42          jB
                    lbra      L018C               * 032D 16 FE 5C       .~\
L0330               leax      <U0034,U            * 0330 30 C8 34       0H4
                    tst       U0008,U             * 0333 6D 48          mH
                    bne       L034F               * 0335 26 18          &.
                    ldy       #1024               * 0337 10 8E 04 00    ....
                    clra                          * 033B 4F             O
L033C               adda      ,X+                 * 033C AB 80          +.
                    leay      -$01,Y              * 033E 31 3F          1?
                    bne       L033C               * 0340 26 FA          &z
                    cmpa      >U0434,U            * 0342 A1 C9 04 34    !I.4
                    lbeq      L0302               * 0346 10 27 FF B8    .'.8
                    dec       U0002,U             * 034A 6A 42          jB
                    lbra      L018C               * 034C 16 FE 3D       .~=
L034F               ldy       #1024               * 034F 10 8E 04 00    ....
                    sty       U000A,U             * 0353 10 AF 4A       ./J
                    clra                          * 0356 4F             O
                    clrb                          * 0357 5F             _
                    std       U000E,U             * 0358 ED 4E          mN
L035A               lda       ,X+                 * 035A A6 80          &.
                    clrb                          * 035C 5F             _
                    eora      U000E,U             * 035D A8 4E          (N
                    eorb      U000F,U             * 035F E8 4F          hO
                    std       U000E,U             * 0361 ED 4E          mN
                    lda       #8                  * 0363 86 08          ..
                    sta       U000C,U             * 0365 A7 4C          'L
L0367               ldd       U000E,U             * 0367 EC 4E          lN
                    bita      #128                * 0369 85 80          ..
                    beq       L0377               * 036B 27 0A          '.
                    aslb                          * 036D 58             X
                    rola                          * 036E 49             I
                    eora      #16                 * 036F 88 10          ..
                    eorb      #33                 * 0371 C8 21          H!
                    std       U000E,U             * 0373 ED 4E          mN
                    bra       L037B               * 0375 20 04           .
L0377               aslb                          * 0377 58             X
                    rola                          * 0378 49             I
                    std       U000E,U             * 0379 ED 4E          mN
L037B               dec       U000C,U             * 037B 6A 4C          jL
                    bne       L0367               * 037D 26 E8          &h
                    ldy       U000A,U             * 037F 10 AE 4A       ..J
                    leay      -$01,Y              * 0382 31 3F          1?
                    sty       U000A,U             * 0384 10 AF 4A       ./J
                    bne       L035A               * 0387 26 D1          &Q
                    ldd       U000E,U             * 0389 EC 4E          lN
                    cmpd      >U0434,U            * 038B 10 A3 C9 04 34 .#I.4
                    beq       L0397               * 0390 27 05          '.
                    dec       U0002,U             * 0392 6A 42          jB
                    lbra      L018C               * 0394 16 FD F5       .}u
L0397               lda       U0001,U             * 0397 A6 41          &A
                    leax      <U0034,U            * 0399 30 C8 34       0H4
                    ldy       #1024               * 039C 10 8E 04 00    ....
                    os9       I$Write             * 03A0 10 3F 8A       .?.
                    bra       L03A7               * 03A3 20 02           .
L03A5               dec       U0002,U             * 03A5 6A 42          jB
L03A7               ldx       #10                 * 03A7 8E 00 0A       ...
                    os9       F$Sleep             * 03AA 10 3F 0A       .?.
                    lda       #6                  * 03AD 86 06          ..
                    sta       U0000,U             * 03AF A7 C4          'D
                    lda       #1                  * 03B1 86 01          ..
                    leax      U0000,U             * 03B3 30 C4          0D
                    ldy       #1                  * 03B5 10 8E 00 01    ....
                    os9       I$Write             * 03B9 10 3F 8A       .?.
                    clr       U0003,U             * 03BC 6F 43          oC
                    lbra      L01AD               * 03BE 16 FD EC       .}l
L03C1               lda       #6                  * 03C1 86 06          ..
                    sta       U0000,U             * 03C3 A7 C4          'D
                    lda       #1                  * 03C5 86 01          ..
                    leax      U0000,U             * 03C7 30 C4          0D
                    ldy       #1                  * 03C9 10 8E 00 01    ....
                    os9       I$Write             * 03CD 10 3F 8A       .?.
                    lda       U0001,U             * 03D0 A6 41          &A
                    os9       I$Close             * 03D2 10 3F 8F       .?.
                    lbsr      L0412               * 03D5 17 00 3A       ..:
                    leax      >L00C7,PC           * 03D8 30 8D FC EB    0.|k
                    ldy       #200                * 03DC 10 8E 00 C8    ...H
                    lda       #1                  * 03E0 86 01          ..
                    os9       I$WritLn            * 03E2 10 3F 8C       .?.
                    clrb                          * 03E5 5F             _
L03E6               pshs      B                   * 03E6 34 04          4.
                    lbsr      L0412               * 03E8 17 00 27       ..'
                    puls      B                   * 03EB 35 04          5.
L03ED               os9       F$Exit              * 03ED 10 3F 06       .?.
L03F0               bsr       L0412               * 03F0 8D 20          .
                    leax      >L00B7,PC           * 03F2 30 8D FC C1    0.|A
                    ldy       #200                * 03F6 10 8E 00 C8    ...H
                    lda       #1                  * 03FA 86 01          ..
                    os9       I$WritLn            * 03FC 10 3F 8C       .?.
                    lda       U0001,U             * 03FF A6 41          &A
                    os9       I$Close             * 0401 10 3F 8F       .?.
                    ldx       <U0010,U            * 0404 AE C8 10       .H.
                    os9       I$Delete            * 0407 10 3F 87       .?.
                    lbcs      L03E6               * 040A 10 25 FF D8    .%.X
                    ldb       #1                  * 040E C6 01          F.
                    bra       L03E6               * 0410 20 D4           T
L0412               leax      >U0436,U            * 0412 30 C9 04 36    0I.6
                    clra                          * 0416 4F             O
                    clrb                          * 0417 5F             _
                    os9       I$SetStt            * 0418 10 3F 8E       .?.
                    rts                           * 041B 39             9

                    emod
eom                 equ       *
                    end
