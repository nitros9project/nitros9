                    nam       Uloadxc
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
U0006               rmb       1
U0007               rmb       1
U0008               rmb       1
U0009               rmb       1
U000A               rmb       1
U000B               rmb       2
U000D               rmb       32
U002D               rmb       1
U002E               rmb       1
U002F               rmb       128
U00AF               rmb       2
U00B1               rmb       32
U00D1               rmb       1
U00D2               rmb       431
size                equ       .

name                fcs       /Uloadxc/           * 000D 55 6C 6F 61 64 78 E3 Uloadxc
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
L007F               fcc       "File open, ready to recieve..." * 007F 46 69 6C 65 20 6F 70 65 6E 2C 20 72 65 61 64 79 20 74 6F 20 72 65 63 69 65 76 65 2E 2E 2E File open, ready to recieve...
                    fcb       $0D                 * 009D 0D             .
L009E               fcc       "Enter filename to upload: " * 009E 45 6E 74 65 72 20 66 69 6C 65 6E 61 6D 65 20 74 6F 20 75 70 6C 6F 61 64 3A 20 Enter filename to upload:
L00B8               fcc       "Upload aborted!"   * 00B8 55 70 6C 6F 61 64 20 61 62 6F 72 74 65 64 21 Upload aborted!
                    fcb       $0D                 * 00C7 0D             .
L00C8               fcc       "Upload successful!" * 00C8 55 70 6C 6F 61 64 20 73 75 63 63 65 73 73 66 75 6C 21 Upload successful!
                    fcb       $0D                 * 00DA 0D             .
start               pshs      X                   * 00DB 34 10          4.
                    os9       F$ID                * 00DD 10 3F 0C       .?.
                    ldb       #255                * 00E0 C6 FF          F.
                    os9       F$SPrior            * 00E2 10 3F 0D       .?.
                    lda       0,X                 * 00E5 A6 84          &.
                    cmpa      #13                 * 00E7 81 0D          ..
                    bne       L0102               * 00E9 26 17          &.
                    leax      >L009E,PC           * 00EB 30 8D FF AF    0../
                    ldy       #25                 * 00EF 10 8E 00 19    ....
                    lda       #1                  * 00F3 86 01          ..
                    os9       I$Write             * 00F5 10 3F 8A       .?.
                    leax      U000D,U             * 00F8 30 4D          0M
                    ldy       #32                 * 00FA 10 8E 00 20    ...
                    clra                          * 00FE 4F             O
                    os9       I$ReadLn            * 00FF 10 3F 8B       .?.
L0102               stx       U000B,U             * 0102 AF 4B          /K
                    lda       #2                  * 0104 86 02          ..
                    ldb       #27                 * 0106 C6 1B          F.
                    os9       I$Create            * 0108 10 3F 83       .?.
                    lbcs      L0320               * 010B 10 25 02 11    .%..
                    sta       U0001,U             * 010F A7 41          'A
                    clr       U0003,U             * 0111 6F 43          oC
                    clr       U0002,U             * 0113 6F 42          oB
                    clr       >U00AF,U            * 0115 6F C9 00 AF    oI./
                    dec       >U00AF,U            * 0119 6A C9 00 AF    jI./
                    leax      >L007F,PC           * 011D 30 8D FF 5E    0..^
                    ldy       #200                * 0121 10 8E 00 C8    ...H
                    lda       #1                  * 0125 86 01          ..
                    os9       I$WritLn            * 0127 10 3F 8C       .?.
                    lda       #4                  * 012A 86 04          ..
                    sta       U0006,U             * 012C A7 46          'F
                    leax      >U00B1,U            * 012E 30 C9 00 B1    0I.1
                    clra                          * 0132 4F             O
                    clrb                          * 0133 5F             _
                    os9       I$GetStt            * 0134 10 3F 8D       .?.
                    lbcs      L0320               * 0137 10 25 01 E5    .%.e
                    leax      >U00D1,U            * 013B 30 C9 00 D1    0I.Q
                    clra                          * 013F 4F             O
                    clrb                          * 0140 5F             _
                    os9       I$GetStt            * 0141 10 3F 8D       .?.
                    lbcs      L0320               * 0144 10 25 01 D8    .%.X
                    leax      >U00D1,U            * 0148 30 C9 00 D1    0I.Q
                    leax      -$20,X              * 014C 30 88 E0       0.`
                    clr       <$002B,X            * 014F 6F 88 2B       o.+
                    clr       <$002C,X            * 0152 6F 88 2C       o.,
                    clr       <$002E,X            * 0155 6F 88 2E       o..
                    clr       <$002F,X            * 0158 6F 88 2F       o./
                    clr       <$0030,X            * 015B 6F 88 30       o.0
                    clr       <$0031,X            * 015E 6F 88 31       o.1
                    clr       <$0038,X            * 0161 6F 88 38       o.8
                    clr       <$0039,X            * 0164 6F 88 39       o.9
                    clr       <$0024,X            * 0167 6F 88 24       o.$
                    clr       <$002D,X            * 016A 6F 88 2D       o.-
                    clr       <$0027,X            * 016D 6F 88 27       o.'
                    clr       <$0028,X            * 0170 6F 88 28       o.(
                    clr       <$0029,X            * 0173 6F 88 29       o.)
                    clra                          * 0176 4F             O
                    clrb                          * 0177 5F             _
                    leax      >U00D1,U            * 0178 30 C9 00 D1    0I.Q
                    os9       I$SetStt            * 017C 10 3F 8E       .?.
L017F               tst       U0006,U             * 017F 6D 46          mF
                    beq       L018B               * 0181 27 08          '.
                    dec       U0006,U             * 0183 6A 46          jF
                    lda       #67                 * 0185 86 43          .C
                    sta       U0000,U             * 0187 A7 C4          'D
                    bra       L018F               * 0189 20 04           .
L018B               lda       #21                 * 018B 86 15          ..
                    sta       U0000,U             * 018D A7 C4          'D
L018F               leax      U0000,U             * 018F 30 C4          0D
                    lda       #1                  * 0191 86 01          ..
                    ldy       #1                  * 0193 10 8E 00 01    ....
                    os9       I$Write             * 0197 10 3F 8A       .?.
                    clr       U0004,U             * 019A 6F 44          oD
                    lda       U0003,U             * 019C A6 43          &C
                    inca                          * 019E 4C             L
                    sta       U0003,U             * 019F A7 43          'C
                    cmpa      #10                 * 01A1 81 0A          ..
                    bcs       L01AA               * 01A3 25 05          %.
                    ldb       #1                  * 01A5 C6 01          F.
                    lbra      L0319               * 01A7 16 01 6F       ..o
L01AA               clra                          * 01AA 4F             O
                    ldb       #1                  * 01AB C6 01          F.
                    os9       I$GetStt            * 01AD 10 3F 8D       .?.
                    bcc       L01C3               * 01B0 24 11          $.
                    lda       U0004,U             * 01B2 A6 44          &D
                    inca                          * 01B4 4C             L
                    sta       U0004,U             * 01B5 A7 44          'D
                    cmpa      #254                * 01B7 81 FE          .~
                    bcc       L017F               * 01B9 24 C4          $D
                    ldx       #2                  * 01BB 8E 00 02       ...
                    os9       F$Sleep             * 01BE 10 3F 0A       .?.
                    bra       L01AA               * 01C1 20 E7           g
L01C3               leax      U0000,U             * 01C3 30 C4          0D
                    ldy       #1                  * 01C5 10 8E 00 01    ....
                    clra                          * 01C9 4F             O
                    os9       I$Read              * 01CA 10 3F 89       .?.
                    lda       U0000,U             * 01CD A6 C4          &D
                    cmpa      #1                  * 01CF 81 01          ..
                    beq       L01E1               * 01D1 27 0E          '.
                    cmpa      #4                  * 01D3 81 04          ..
                    lbeq      L02F4               * 01D5 10 27 01 1B    .'..
                    cmpa      #24                 * 01D9 81 18          ..
                    lbeq      L0323               * 01DB 10 27 01 44    .'.D
                    bra       L01AA               * 01DF 20 C9           I
L01E1               leax      <U002D,U            * 01E1 30 C8 2D       0H-
                    tst       U0006,U             * 01E4 6D 46          mF
                    beq       L01EC               * 01E6 27 04          '.
                    lda       #132                * 01E8 86 84          ..
                    bra       L01EE               * 01EA 20 02           .
L01EC               lda       #131                * 01EC 86 83          ..
L01EE               sta       U0005,U             * 01EE A7 45          'E
                    clr       U0004,U             * 01F0 6F 44          oD
                    bsr       L01FD               * 01F2 8D 09          ..
                    lbcs      L018B               * 01F4 10 25 FF 93    .%..
                    inc       U0002,U             * 01F8 6C 42          lB
                    lbra      L0250               * 01FA 16 00 53       ..S
L01FD               clra                          * 01FD 4F             O
                    ldb       #1                  * 01FE C6 01          F.
                    os9       I$GetStt            * 0200 10 3F 8D       .?.
                    bcc       L0219               * 0203 24 14          $.
                    inc       U0004,U             * 0205 6C 44          lD
                    lda       U0004,U             * 0207 A6 44          &D
                    cmpa      #255                * 0209 81 FF          ..
                    bhi       L0232               * 020B 22 25          "%
                    pshs      X                   * 020D 34 10          4.
                    ldx       #1                  * 020F 8E 00 01       ...
                    os9       F$Sleep             * 0212 10 3F 0A       .?.
                    puls      X                   * 0215 35 10          5.
                    bra       L01FD               * 0217 20 E4           d
L0219               clr       U0004,U             * 0219 6F 44          oD
                    clra                          * 021B 4F             O
                    tfr       D,Y                 * 021C 1F 02          ..
                    os9       I$Read              * 021E 10 3F 89       .?.
                    bcs       L0236               * 0221 25 13          %.
                    tfr       Y,D                 * 0223 1F 20          .
                    leax      B,X                 * 0225 30 85          0.
                    lda       U0005,U             * 0227 A6 45          &E
                    stb       U0005,U             * 0229 E7 45          gE
                    suba      U0005,U             * 022B A0 45           E
                    sta       U0005,U             * 022D A7 45          'E
                    bne       L01FD               * 022F 26 CC          &L
                    rts                           * 0231 39             9
L0232               lda       #255                * 0232 86 FF          ..
                    rola                          * 0234 49             I
                    rts                           * 0235 39             9
L0236               pshs      X                   * 0236 34 10          4.
                    ldx       #60                 * 0238 8E 00 3C       ..<
                    os9       F$Sleep             * 023B 10 3F 0A       .?.
                    puls      X                   * 023E 35 10          5.
                    clra                          * 0240 4F             O
                    ldb       #1                  * 0241 C6 01          F.
                    os9       I$GetStt            * 0243 10 3F 8D       .?.
                    clra                          * 0246 4F             O
                    tfr       D,Y                 * 0247 1F 02          ..
                    os9       I$Read              * 0249 10 3F 89       .?.
                    lda       #255                * 024C 86 FF          ..
                    rola                          * 024E 49             I
                    rts                           * 024F 39             9
L0250               lda       <U002D,U            * 0250 A6 C8 2D       &H-
                    inca                          * 0253 4C             L
                    cmpa      U0002,U             * 0254 A1 42          !B
                    lbeq      L02D8               * 0256 10 27 00 7E    .'.~
                    deca                          * 025A 4A             J
                    cmpa      U0002,U             * 025B A1 42          !B
                    beq       L0264               * 025D 27 05          '.
                    dec       U0002,U             * 025F 6A 42          jB
                    lbra      L018B               * 0261 16 FF 27       ..'
L0264               coma                          * 0264 43             C
                    cmpa      <U002E,U            * 0265 A1 C8 2E       !H.
                    beq       L026F               * 0268 27 05          '.
                    dec       U0002,U             * 026A 6A 42          jB
                    lbra      L018B               * 026C 16 FF 1C       ...
L026F               leax      <U002F,U            * 026F 30 C8 2F       0H/
                    tst       U0006,U             * 0272 6D 46          mF
                    bne       L028B               * 0274 26 15          &.
                    ldb       #128                * 0276 C6 80          F.
                    clra                          * 0278 4F             O
L0279               adda      ,X+                 * 0279 AB 80          +.
                    decb                          * 027B 5A             Z
                    bne       L0279               * 027C 26 FB          &{
                    cmpa      >U00AF,U            * 027E A1 C9 00 AF    !I./
                    lbeq      L02CA               * 0282 10 27 00 44    .'.D
                    dec       U0002,U             * 0286 6A 42          jB
                    lbra      L018B               * 0288 16 FF 00       ...
L028B               lda       #128                * 028B 86 80          ..
                    sta       U0007,U             * 028D A7 47          'G
                    clra                          * 028F 4F             O
                    clrb                          * 0290 5F             _
                    std       U0009,U             * 0291 ED 49          mI
L0293               lda       ,X+                 * 0293 A6 80          &.
                    clrb                          * 0295 5F             _
                    eora      U0009,U             * 0296 A8 49          (I
                    eorb      U000A,U             * 0298 E8 4A          hJ
                    std       U0009,U             * 029A ED 49          mI
                    lda       #8                  * 029C 86 08          ..
                    sta       U0008,U             * 029E A7 48          'H
L02A0               ldd       U0009,U             * 02A0 EC 49          lI
                    bita      #128                * 02A2 85 80          ..
                    beq       L02B0               * 02A4 27 0A          '.
                    aslb                          * 02A6 58             X
                    rola                          * 02A7 49             I
                    eora      #16                 * 02A8 88 10          ..
                    eorb      #33                 * 02AA C8 21          H!
                    std       U0009,U             * 02AC ED 49          mI
                    bra       L02B4               * 02AE 20 04           .
L02B0               aslb                          * 02B0 58             X
                    rola                          * 02B1 49             I
                    std       U0009,U             * 02B2 ED 49          mI
L02B4               dec       U0008,U             * 02B4 6A 48          jH
                    bne       L02A0               * 02B6 26 E8          &h
                    dec       U0007,U             * 02B8 6A 47          jG
                    bne       L0293               * 02BA 26 D7          &W
                    ldd       U0009,U             * 02BC EC 49          lI
                    cmpd      >U00AF,U            * 02BE 10 A3 C9 00 AF .#I./
                    beq       L02CA               * 02C3 27 05          '.
                    dec       U0002,U             * 02C5 6A 42          jB
                    lbra      L018B               * 02C7 16 FE C1       .~A
L02CA               lda       U0001,U             * 02CA A6 41          &A
                    leax      <U002F,U            * 02CC 30 C8 2F       0H/
                    ldy       #128                * 02CF 10 8E 00 80    ....
                    os9       I$Write             * 02D3 10 3F 8A       .?.
                    bra       L02DA               * 02D6 20 02           .
L02D8               dec       U0002,U             * 02D8 6A 42          jB
L02DA               ldx       #60                 * 02DA 8E 00 3C       ..<
                    os9       F$Sleep             * 02DD 10 3F 0A       .?.
                    lda       #6                  * 02E0 86 06          ..
                    sta       U0000,U             * 02E2 A7 C4          'D
                    lda       #1                  * 02E4 86 01          ..
                    leax      U0000,U             * 02E6 30 C4          0D
                    ldy       #1                  * 02E8 10 8E 00 01    ....
                    os9       I$Write             * 02EC 10 3F 8A       .?.
                    clr       U0003,U             * 02EF 6F 43          oC
                    lbra      L01AA               * 02F1 16 FE B6       .~6
L02F4               lda       #6                  * 02F4 86 06          ..
                    sta       U0000,U             * 02F6 A7 C4          'D
                    lda       #1                  * 02F8 86 01          ..
                    leax      U0000,U             * 02FA 30 C4          0D
                    ldy       #1                  * 02FC 10 8E 00 01    ....
                    os9       I$Write             * 0300 10 3F 8A       .?.
                    lda       U0001,U             * 0303 A6 41          &A
                    os9       I$Close             * 0305 10 3F 8F       .?.
                    lbsr      L0344               * 0308 17 00 39       ..9
                    leax      >L00C8,PC           * 030B 30 8D FD B9    0.}9
                    ldy       #200                * 030F 10 8E 00 C8    ...H
                    lda       #1                  * 0313 86 01          ..
                    os9       I$WritLn            * 0315 10 3F 8C       .?.
                    clrb                          * 0318 5F             _
L0319               pshs      B                   * 0319 34 04          4.
                    lbsr      L0344               * 031B 17 00 26       ..&
                    puls      B                   * 031E 35 04          5.
L0320               os9       F$Exit              * 0320 10 3F 06       .?.
L0323               bsr       L0344               * 0323 8D 1F          ..
                    leax      >L00B8,PC           * 0325 30 8D FD 8F    0.}.
                    ldy       #200                * 0329 10 8E 00 C8    ...H
                    lda       #1                  * 032D 86 01          ..
                    os9       I$WritLn            * 032F 10 3F 8C       .?.
                    lda       U0001,U             * 0332 A6 41          &A
                    os9       I$Close             * 0334 10 3F 8F       .?.
                    ldx       U000B,U             * 0337 AE 4B          .K
                    os9       I$Delete            * 0339 10 3F 87       .?.
                    lbcs      L0319               * 033C 10 25 FF D9    .%.Y
                    ldb       #1                  * 0340 C6 01          F.
                    bra       L0319               * 0342 20 D5           U
L0344               leax      >U00B1,U            * 0344 30 C9 00 B1    0I.1
                    clra                          * 0348 4F             O
                    clrb                          * 0349 5F             _
                    os9       I$SetStt            * 034A 10 3F 8E       .?.
                    rts                           * 034D 39             9

                    emod
eom                 equ       *
                    end
