                    nam       BBS.new
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
U0007               rmb       3
U000A               rmb       1
U000B               rmb       1
U000C               rmb       2
U000E               rmb       2
U0010               rmb       2
U0012               rmb       2
U0014               rmb       2
U0016               rmb       2
U0018               rmb       2
U001A               rmb       6
U0020               rmb       2
U0022               rmb       2
U0024               rmb       2
U0026               rmb       16
U0036               rmb       6
U003C               rmb       3
U003F               rmb       1
U0040               rmb       9
U0049               rmb       1
U004A               rmb       1
U004B               rmb       2
U004D               rmb       1
U004E               rmb       1
U004F               rmb       1
U0050               rmb       1
U0051               rmb       1
U0052               rmb       1
U0053               rmb       1
U0054               rmb       1
U0055               rmb       1
U0056               rmb       1
U0057               rmb       1
U0058               rmb       1
U0059               rmb       1
U005A               rmb       1
U005B               rmb       1
U005C               rmb       64
U009C               rmb       80
U00EC               rmb       2
U00EE               rmb       2
U00F0               rmb       20
U0104               rmb       30
U0122               rmb       1
U0123               rmb       1
U0124               rmb       1
U0125               rmb       1
U0126               rmb       4
U012A               rmb       2
U012C               rmb       1
U012D               rmb       399
size                equ       .

name                fcs       /BBS.new/           * 000D 42 42 53 2E 6E 65 F7 BBS.new
                    fcc       "Copyright (C) 1988" * 0014 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 Copyright (C) 1988
                    fcc       "By Keith Alphonso" * 0026 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F By Keith Alphonso
                    fcc       "Licenced to Alpha Software Technologies" * 0037 4C 69 63 65 6E 63 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licenced to Alpha Software Technologies
                    fcc       "All rights reserved" * 005E 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 All rights reserved
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
L007F               fcc       "BBS.msg.inx"       * 007F 42 42 53 2E 6D 73 67 2E 69 6E 78 BBS.msg.inx
                    fcb       $0D                 * 008A 0D             .
L008B               fcc       "BBS.msg"           * 008B 42 42 53 2E 6D 73 67 BBS.msg
                    fcb       $0D                 * 0092 0D             .
L0093               fcc       "******   DELETED   ******" * 0093 2A 2A 2A 2A 2A 2A 20 20 20 44 45 4C 45 54 45 44 20 20 20 2A 2A 2A 2A 2A 2A ******   DELETED   ******
                    fcb       $0D                 * 00AC 0D             .
L00AD               fcc       "Message :"         * 00AD 4D 65 73 73 61 67 65 20 3A Message :
L00B6               fcc       "From    :"         * 00B6 46 72 6F 6D 20 20 20 20 3A From    :
L00BF               fcc       "To      :"         * 00BF 54 6F 20 20 20 20 20 20 3A To      :
L00C8               fcc       "Left on :"         * 00C8 4C 65 66 74 20 6F 6E 20 3A Left on :
L00D1               fcc       "About   :"         * 00D1 41 62 6F 75 74 20 20 20 3A About   :
L00DA               fcb       $00                 * 00DA 00             .
                    fcb       $09                 * 00DB 09             .
L00DC               fcc       "----------------------------------------------------------------" * 00DC 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 011C 0D             .
L011D               fcb       $0A                 * 011D 0A             .
                    fcb       $0A                 * 011E 0A             .
                    fcb       $0D                 * 011F 0D             .
L0120               fcc       "Press <SPACE> to skip a message" * 0120 50 72 65 73 73 20 3C 53 50 41 43 45 3E 20 74 6F 20 73 6B 69 70 20 61 20 6D 65 73 73 61 67 65 Press <SPACE> to skip a message
                    fcb       $0A                 * 013F 0A             .
                    fcb       $0D                 * 0140 0D             .
L0141               fcc       "BBS.msg.lst"       * 0141 42 42 53 2E 6D 73 67 2E 6C 73 74 BBS.msg.lst
                    fcb       $0D                 * 014C 0D             .
L014D               fcc       "No new messages to read." * 014D 4E 6F 20 6E 65 77 20 6D 65 73 73 61 67 65 73 20 74 6F 20 72 65 61 64 2E No new messages to read.
                    fcb       $0D                 * 0165 0D             .
L0166               fcc       "/dd/bbs/BBS.userstats" * 0166 2F 64 64 2F 62 62 73 2F 42 42 53 2E 75 73 65 72 73 74 61 74 73 /dd/bbs/BBS.userstats
                    fcb       $0D                 * 017B 0D             .
L017C               fcc       "/dd/bbs/BBS.alias" * 017C 2F 64 64 2F 62 62 73 2F 42 42 53 2E 61 6C 69 61 73 /dd/bbs/BBS.alias
                    fcb       $0D                 * 018D 0D             .
L018E               fcc       "Unknown User"      * 018E 55 6E 6B 6E 6F 77 6E 20 55 73 65 72 Unknown User
                    fcb       $0D                 * 019A 0D             .
L019B               fcc       "All Users"         * 019B 41 6C 6C 20 55 73 65 72 73 All Users
                    fcb       $0D                 * 01A4 0D             .

start               os9       F$ID                * 01A5 10 3F 0C       .?.
                    sty       U000E,U             * 01A8 10 AF 4E       ./N
                    ldy       #0                  * 01AB 10 8E 00 00    ....
                    sty       <U0014,U            * 01AF 10 AF C8 14    ./H.
                    os9       F$SUser             * 01B3 10 3F 1C       .?.
                    leax      >L007F,PC           * 01B6 30 8D FE C5    0.~E
                    lda       #1                  * 01BA 86 01          ..
                    os9       I$Open              * 01BC 10 3F 84       .?.
                    lbcs      L061C               * 01BF 10 25 04 59    .%.Y
                    sta       U0001,U             * 01C3 A7 41          'A
                    leax      >L008B,PC           * 01C5 30 8D FE C2    0.~B
                    lda       #1                  * 01C9 86 01          ..
                    os9       I$Open              * 01CB 10 3F 84       .?.
                    lbcs      L061C               * 01CE 10 25 04 4A    .%.J
                    sta       U0002,U             * 01D2 A7 42          'B
                    leax      >L0141,PC           * 01D4 30 8D FF 69    0..i
                    lda       #3                  * 01D8 86 03          ..
                    os9       I$Open              * 01DA 10 3F 84       .?.
                    bcc       L01EE               * 01DD 24 0F          $.
                    cmpb      #216                * 01DF C1 D8          AX
                    lbne      L061C               * 01E1 10 26 04 37    .&.7
                    ldb       #3                  * 01E5 C6 03          F.
                    os9       I$Create            * 01E7 10 3F 83       .?.
                    lbcs      L061C               * 01EA 10 25 04 2E    .%..
L01EE               sta       U0003,U             * 01EE A7 43          'C
                    leax      <U005C,U            * 01F0 30 C8 5C       0H\
                    ldy       #64                 * 01F3 10 8E 00 40    ...@
                    lda       U0001,U             * 01F7 A6 41          &A
                    os9       I$Read              * 01F9 10 3F 89       .?.
                    lbcs      L061C               * 01FC 10 25 04 1C    .%..
L0200               lda       U0003,U             * 0200 A6 43          &C
                    leax      <U0010,U            * 0202 30 C8 10       0H.
                    ldy       #4                  * 0205 10 8E 00 04    ....
                    os9       I$Read              * 0209 10 3F 89       .?.
                    bcs       L0221               * 020C 25 13          %.
                    ldd       <U0010,U            * 020E EC C8 10       lH.
                    cmpd      U000E,U             * 0211 10 A3 4E       .#N
                    bne       L0200               * 0214 26 EA          &j
                    ldd       <U0012,U            * 0216 EC C8 12       lH.
                    addd      #1                  * 0219 C3 00 01       C..
                    std       <U0036,U            * 021C ED C8 36       mH6
                    bra       L022D               * 021F 20 0C           .
L0221               cmpb      #211                * 0221 C1 D3          AS
                    lbne      L061C               * 0223 10 26 03 F5    .&.u
                    ldd       #1                  * 0227 CC 00 01       L..
                    std       <U0036,U            * 022A ED C8 36       mH6
L022D               ldd       <U0036,U            * 022D EC C8 36       lH6
                    cmpd      <U005C,U            * 0230 10 A3 C8 5C    .#H\
                    lbhi      L060E               * 0234 10 22 03 D6    .".V
                    clr       <U0049,U            * 0238 6F C8 49       oHI
                    clr       <U004A,U            * 023B 6F C8 4A       oHJ
                    lda       #6                  * 023E 86 06          ..
                    sta       U0005,U             * 0240 A7 45          'E
                    ldd       <U0036,U            * 0242 EC C8 36       lH6
L0245               aslb                          * 0245 58             X
                    rola                          * 0246 49             I
                    rol       <U004A,U            * 0247 69 C8 4A       iHJ
                    dec       U0005,U             * 024A 6A 45          jE
                    bne       L0245               * 024C 26 F7          &w
                    std       <U004B,U            * 024E ED C8 4B       mHK
                    ldx       <U0049,U            * 0251 AE C8 49       .HI
                    lda       U0001,U             * 0254 A6 41          &A
                    pshs      U                   * 0256 34 40          4@
                    ldu       <U004B,U            * 0258 EE C8 4B       nHK
                    os9       I$Seek              * 025B 10 3F 88       .?.
                    lbcs      L061C               * 025E 10 25 03 BA    .%.:
                    puls      U                   * 0262 35 40          5@
                    ldd       <U0036,U            * 0264 EC C8 36       lH6
                    subd      #1                  * 0267 83 00 01       ...
                    std       <U0036,U            * 026A ED C8 36       mH6
                    lda       U0003,U             * 026D A6 43          &C
                    pshs      U                   * 026F 34 40          4@
                    ldu       #0                  * 0271 CE 00 00       N..
                    tfr       U,X                 * 0274 1F 31          .1
                    os9       I$Seek              * 0276 10 3F 88       .?.
                    puls      U                   * 0279 35 40          5@
                    lbcs      L061C               * 027B 10 25 03 9D    .%..
L027F               lda       U0003,U             * 027F A6 43          &C
                    leax      <U0010,U            * 0281 30 C8 10       0H.
                    ldy       #4                  * 0284 10 8E 00 04    ....
                    os9       I$Read              * 0288 10 3F 89       .?.
                    bcs       L02C6               * 028B 25 39          %9
                    ldd       <U0010,U            * 028D EC C8 10       lH.
                    cmpd      U000E,U             * 0290 10 A3 4E       .#N
                    bne       L027F               * 0293 26 EA          &j
                    ldd       <U0012,U            * 0295 EC C8 12       lH.
                    cmpd      <U005C,U            * 0298 10 A3 C8 5C    .#H\
                    bcc       L02E5               * 029C 24 47          $G
                    pshs      U                   * 029E 34 40          4@
                    lda       U0003,U             * 02A0 A6 43          &C
                    ldb       #5                  * 02A2 C6 05          F.
                    os9       I$GetStt            * 02A4 10 3F 8D       .?.
                    lbcs      L061C               * 02A7 10 25 03 71    .%.q
                    leau      -$02,U              * 02AB 33 5E          3^
                    os9       I$Seek              * 02AD 10 3F 88       .?.
                    puls      U                   * 02B0 35 40          5@
                    lbcs      L061C               * 02B2 10 25 03 66    .%.f
                    leax      <U005C,U            * 02B6 30 C8 5C       0H\
                    ldy       #2                  * 02B9 10 8E 00 02    ....
                    os9       I$Write             * 02BD 10 3F 8A       .?.
                    lbcs      L061C               * 02C0 10 25 03 58    .%.X
                    bra       L02E5               * 02C4 20 1F           .
L02C6               cmpb      #211                * 02C6 C1 D3          AS
                    lbne      L061C               * 02C8 10 26 03 50    .&.P
                    lda       U0003,U             * 02CC A6 43          &C
                    leax      U000E,U             * 02CE 30 4E          0N
                    ldy       #2                  * 02D0 10 8E 00 02    ....
                    os9       I$Write             * 02D4 10 3F 8A       .?.
                    lbcs      L061C               * 02D7 10 25 03 41    .%.A
                    leax      <U005C,U            * 02DB 30 C8 5C       0H\
                    os9       I$Write             * 02DE 10 3F 8A       .?.
                    lbcs      L061C               * 02E1 10 25 03 37    .%.7
L02E5               lda       U0003,U             * 02E5 A6 43          &C
                    os9       I$Close             * 02E7 10 3F 8F       .?.
                    lbcs      L061C               * 02EA 10 25 03 2E    .%..
                    leax      >L0120,PC           * 02EE 30 8D FE 2E    0.~.
                    ldy       #200                * 02F2 10 8E 00 C8    ...H
                    lda       #1                  * 02F6 86 01          ..
                    os9       I$WritLn            * 02F8 10 3F 8C       .?.
L02FB               lda       U0001,U             * 02FB A6 41          &A
                    ldy       #64                 * 02FD 10 8E 00 40    ...@
                    leax      >U00EC,U            * 0301 30 C9 00 EC    0I.l
                    os9       I$Read              * 0305 10 3F 89       .?.
                    lbcs      L055D               * 0308 10 25 02 51    .%.Q
                    ldd       <U0036,U            * 030C EC C8 36       lH6
                    addd      #1                  * 030F C3 00 01       C..
                    std       <U0036,U            * 0312 ED C8 36       mH6
                    leax      >L011D,PC           * 0315 30 8D FE 04    0.~.
                    ldy       #2                  * 0319 10 8E 00 02    ....
                    lda       #1                  * 031D 86 01          ..
                    os9       I$WritLn            * 031F 10 3F 8C       .?.
                    ldd       <U0036,U            * 0322 EC C8 36       lH6
                    leax      <U003C,U            * 0325 30 C8 3C       0H<
                    lbsr      L0686               * 0328 17 03 5B       ..[
                    leax      >L00AD,PC           * 032B 30 8D FD 7E    0.}~
                    ldy       >L00DA,PC           * 032F 10 AE 8D FD A6 ...}&
                    lda       #1                  * 0334 86 01          ..
                    os9       I$Write             * 0336 10 3F 8A       .?.
                    lbcs      L061C               * 0339 10 25 02 DF    .%._
                    leax      <U003C,U            * 033D 30 C8 3C       0H<
L0340               lda       ,X+                 * 0340 A6 80          &.
                    cmpa      #32                 * 0342 81 20          .
                    beq       L0340               * 0344 27 FA          'z
                    leax      -$01,X              * 0346 30 1F          0.
                    ldy       #6                  * 0348 10 8E 00 06    ....
                    lda       #1                  * 034C 86 01          ..
                    os9       I$WritLn            * 034E 10 3F 8C       .?.
                    lbcs      L061C               * 0351 10 25 02 C7    .%.G
                    ldd       >U00EC,U            * 0355 EC C9 00 EC    lI.l
                    cmpd      #-1                 * 0359 10 83 FF FF    ....
                    lbeq      L04D6               * 035D 10 27 01 75    .'.u
                    leax      >L00B6,PC           * 0361 30 8D FD 51    0.}Q
                    ldy       >L00DA,PC           * 0365 10 AE 8D FD 70 ...}p
                    lda       #1                  * 036A 86 01          ..
                    os9       I$Write             * 036C 10 3F 8A       .?.
                    leax      >U00F0,U            * 036F 30 C9 00 F0    0I.p
                    ldy       #200                * 0373 10 8E 00 C8    ...H
                    lda       #1                  * 0377 86 01          ..
                    os9       I$WritLn            * 0379 10 3F 8C       .?.
                    lbcs      L061C               * 037C 10 25 02 9C    .%..
                    leax      >L00BF,PC           * 0380 30 8D FD 3B    0.};
                    ldy       >L00DA,PC           * 0384 10 AE 8D FD 51 ...}Q
                    lda       #1                  * 0389 86 01          ..
                    os9       I$Write             * 038B 10 3F 8A       .?.
                    ldd       >U012A,U            * 038E EC C9 01 2A    lI.*
                    cmpd      #-1                 * 0392 10 83 FF FF    ....
                    beq       L03F8               * 0396 27 60          '`
                    leax      >L017C,PC           * 0398 30 8D FD E0    0.}`
                    lda       #1                  * 039C 86 01          ..
                    os9       I$Open              * 039E 10 3F 84       .?.
                    lbcs      L061C               * 03A1 10 25 02 77    .%.w
                    sta       U0004,U             * 03A5 A7 44          'D
L03A7               leax      >U012C,U            * 03A7 30 C9 01 2C    0I.,
                    ldy       #200                * 03AB 10 8E 00 C8    ...H
                    lda       U0004,U             * 03AF A6 44          &D
                    os9       I$ReadLn            * 03B1 10 3F 8B       .?.
                    bcs       L03E3               * 03B4 25 2D          %-
                    leax      >U012C,U            * 03B6 30 C9 01 2C    0I.,
L03BA               lda       ,X+                 * 03BA A6 80          &.
                    cmpa      #44                 * 03BC 81 2C          .,
                    bne       L03BA               * 03BE 26 FA          &z
                    lda       #13                 * 03C0 86 0D          ..
                    sta       -$01,X              * 03C2 A7 1F          '.
                    lbsr      L061F               * 03C4 17 02 58       ..X
                    cmpd      >U012A,U            * 03C7 10 A3 C9 01 2A .#I.*
                    bne       L03A7               * 03CC 26 D9          &Y
                    leax      >U012C,U            * 03CE 30 C9 01 2C    0I.,
                    ldy       #200                * 03D2 10 8E 00 C8    ...H
                    lda       #1                  * 03D6 86 01          ..
                    os9       I$WritLn            * 03D8 10 3F 8C       .?.
                    lda       U0004,U             * 03DB A6 44          &D
                    os9       I$Close             * 03DD 10 3F 8F       .?.
                    lbra      L0405               * 03E0 16 00 22       .."
L03E3               leax      >L018E,PC           * 03E3 30 8D FD A7    0.}'
                    ldy       #200                * 03E7 10 8E 00 C8    ...H
                    lda       #1                  * 03EB 86 01          ..
                    os9       I$WritLn            * 03ED 10 3F 8C       .?.
                    lda       U0004,U             * 03F0 A6 44          &D
                    os9       I$Close             * 03F2 10 3F 8F       .?.
                    lbra      L0405               * 03F5 16 00 0D       ...
L03F8               leax      >L019B,PC           * 03F8 30 8D FD 9F    0.}.
                    ldy       #200                * 03FC 10 8E 00 C8    ...H
                    lda       #1                  * 0400 86 01          ..
                    os9       I$WritLn            * 0402 10 3F 8C       .?.
L0405               leax      >L00C8,PC           * 0405 30 8D FC BF    0.|?
                    ldy       >L00DA,PC           * 0409 10 AE 8D FC CC ...|L
                    lda       #1                  * 040E 86 01          ..
                    os9       I$Write             * 0410 10 3F 8A       .?.
                    leax      <U003C,U            * 0413 30 C8 3C       0H<
                    ldb       >U0123,U            * 0416 E6 C9 01 23    fI.#
                    clra                          * 041A 4F             O
                    lbsr      L0686               * 041B 17 02 68       ..h
                    lda       <U003F,U            * 041E A6 C8 3F       &H?
                    sta       <U004D,U            * 0421 A7 C8 4D       'HM
                    lda       <U0040,U            * 0424 A6 C8 40       &H@
                    sta       <U004E,U            * 0427 A7 C8 4E       'HN
                    lda       #47                 * 042A 86 2F          ./
                    sta       <U004F,U            * 042C A7 C8 4F       'HO
                    ldb       >U0124,U            * 042F E6 C9 01 24    fI.$
                    clra                          * 0433 4F             O
                    leax      <U003C,U            * 0434 30 C8 3C       0H<
                    lbsr      L0686               * 0437 17 02 4C       ..L
                    lda       <U003F,U            * 043A A6 C8 3F       &H?
                    sta       <U0050,U            * 043D A7 C8 50       'HP
                    lda       <U0040,U            * 0440 A6 C8 40       &H@
                    sta       <U0051,U            * 0443 A7 C8 51       'HQ
                    lda       #47                 * 0446 86 2F          ./
                    sta       <U0052,U            * 0448 A7 C8 52       'HR
                    ldb       >U0122,U            * 044B E6 C9 01 22    fI."
                    clra                          * 044F 4F             O
                    leax      <U003C,U            * 0450 30 C8 3C       0H<
                    lbsr      L0686               * 0453 17 02 30       ..0
                    lda       <U003F,U            * 0456 A6 C8 3F       &H?
                    sta       <U0053,U            * 0459 A7 C8 53       'HS
                    lda       <U0040,U            * 045C A6 C8 40       &H@
                    sta       <U0054,U            * 045F A7 C8 54       'HT
                    lda       #32                 * 0462 86 20          .
                    sta       <U0055,U            * 0464 A7 C8 55       'HU
                    ldb       >U0125,U            * 0467 E6 C9 01 25    fI.%
                    clra                          * 046B 4F             O
                    leax      <U003C,U            * 046C 30 C8 3C       0H<
                    lbsr      L0686               * 046F 17 02 14       ...
                    lda       <U003F,U            * 0472 A6 C8 3F       &H?
                    sta       <U0056,U            * 0475 A7 C8 56       'HV
                    lda       <U0040,U            * 0478 A6 C8 40       &H@
                    sta       <U0057,U            * 047B A7 C8 57       'HW
                    lda       #58                 * 047E 86 3A          .:
                    sta       <U0058,U            * 0480 A7 C8 58       'HX
                    ldb       >U0126,U            * 0483 E6 C9 01 26    fI.&
                    clra                          * 0487 4F             O
                    leax      <U003C,U            * 0488 30 C8 3C       0H<
                    lbsr      L0686               * 048B 17 01 F8       ..x
                    lda       <U003F,U            * 048E A6 C8 3F       &H?
                    sta       <U0059,U            * 0491 A7 C8 59       'HY
                    lda       <U0040,U            * 0494 A6 C8 40       &H@
                    sta       <U005A,U            * 0497 A7 C8 5A       'HZ
                    lda       #13                 * 049A 86 0D          ..
                    sta       <U005B,U            * 049C A7 C8 5B       'H[
                    leax      <U004D,U            * 049F 30 C8 4D       0HM
L04A2               lda       ,X+                 * 04A2 A6 80          &.
                    cmpa      #32                 * 04A4 81 20          .
                    beq       L04A2               * 04A6 27 FA          'z
                    leax      -$01,X              * 04A8 30 1F          0.
                    ldy       #200                * 04AA 10 8E 00 C8    ...H
                    lda       #1                  * 04AE 86 01          ..
                    os9       I$WritLn            * 04B0 10 3F 8C       .?.
                    lbcs      L061C               * 04B3 10 25 01 65    .%.e
                    leax      >L00D1,PC           * 04B7 30 8D FC 16    0.|.
                    ldy       >L00DA,PC           * 04BB 10 AE 8D FC 1A ...|.
                    lda       #1                  * 04C0 86 01          ..
                    os9       I$Write             * 04C2 10 3F 8A       .?.
                    leax      >U0104,U            * 04C5 30 C9 01 04    0I..
                    ldy       #30                 * 04C9 10 8E 00 1E    ....
                    os9       I$WritLn            * 04CD 10 3F 8C       .?.
                    lbcs      L061C               * 04D0 10 25 01 48    .%.H
                    bra       L04E6               * 04D4 20 10           .
L04D6               leax      >L0093,PC           * 04D6 30 8D FB B9    0.{9
                    ldy       #200                * 04DA 10 8E 00 C8    ...H
                    lda       #1                  * 04DE 86 01          ..
                    os9       I$WritLn            * 04E0 10 3F 8C       .?.
                    lbra      L02FB               * 04E3 16 FE 15       .~.
L04E6               leax      >L00DC,PC           * 04E6 30 8D FB F2    0.{r
                    ldy       #80                 * 04EA 10 8E 00 50    ...P
                    lda       #1                  * 04EE 86 01          ..
                    os9       I$WritLn            * 04F0 10 3F 8C       .?.
                    lda       U0002,U             * 04F3 A6 42          &B
                    ldx       >U00EC,U            * 04F5 AE C9 00 EC    .I.l
                    pshs      U                   * 04F9 34 40          4@
                    ldu       >U00EE,U            * 04FB EE C9 00 EE    nI.n
                    os9       I$Seek              * 04FF 10 3F 88       .?.
                    lbcs      L061C               * 0502 10 25 01 16    .%..
                    puls      U                   * 0506 35 40          5@
L0508               clra                          * 0508 4F             O
                    ldb       #1                  * 0509 C6 01          F.
                    os9       I$GetStt            * 050B 10 3F 8D       .?.
                    bcs       L0521               * 050E 25 11          %.
                    leax      U0000,U             * 0510 30 C4          0D
                    ldy       #1                  * 0512 10 8E 00 01    ....
                    os9       I$Read              * 0516 10 3F 89       .?.
                    lda       U0000,U             * 0519 A6 C4          &D
                    cmpa      #32                 * 051B 81 20          .
                    lbeq      L02FB               * 051D 10 27 FD DA    .'}Z
L0521               lda       U0002,U             * 0521 A6 42          &B
                    leax      >U009C,U            * 0523 30 C9 00 9C    0I..
                    ldy       #80                 * 0527 10 8E 00 50    ...P
                    os9       I$ReadLn            * 052B 10 3F 8B       .?.
                    lda       #1                  * 052E 86 01          ..
                    os9       I$WritLn            * 0530 10 3F 8C       .?.
                    cmpy      #1                  * 0533 10 8C 00 01    ....
                    bhi       L0508               * 0537 22 CF          "O
                    leax      >L00DC,PC           * 0539 30 8D FB 9F    0.{.
                    ldy       #200                * 053D 10 8E 00 C8    ...H
                    lda       #1                  * 0541 86 01          ..
                    os9       I$WritLn            * 0543 10 3F 8C       .?.
                    leax      >L011D,PC           * 0546 30 8D FB D3    0.{S
                    ldy       #5                  * 054A 10 8E 00 05    ....
                    os9       I$WritLn            * 054E 10 3F 8C       .?.
                    ldd       <U0014,U            * 0551 EC C8 14       lH.
                    addd      #1                  * 0554 C3 00 01       C..
                    std       <U0014,U            * 0557 ED C8 14       mH.
                    lbra      L02FB               * 055A 16 FD 9E       .}.
L055D               leax      >L0166,PC           * 055D 30 8D FC 05    0.|.
                    lda       #3                  * 0561 86 03          ..
                    os9       I$Open              * 0563 10 3F 84       .?.
                    bcc       L0571               * 0566 24 09          $.
                    ldb       #27                 * 0568 C6 1B          F.
                    os9       I$Create            * 056A 10 3F 83       .?.
                    lbcs      L061C               * 056D 10 25 00 AB    .%.+
L0571               sta       U0007,U             * 0571 A7 47          'G
L0573               leax      <U0016,U            * 0573 30 C8 16       0H.
                    ldy       #32                 * 0576 10 8E 00 20    ...
                    lda       U0007,U             * 057A A6 47          &G
                    os9       I$Read              * 057C 10 3F 89       .?.
                    bcs       L058B               * 057F 25 0A          %.
                    ldd       <U0016,U            * 0581 EC C8 16       lH.
                    cmpd      U000E,U             * 0584 10 A3 4E       .#N
                    bne       L0573               * 0587 26 EA          &j
                    bra       L0594               * 0589 20 09           .
L058B               cmpb      #211                * 058B C1 D3          AS
                    lbne      L061C               * 058D 10 26 00 8B    .&..
                    lbra      L05D2               * 0591 16 00 3E       ..>
L0594               ldd       <U0022,U            * 0594 EC C8 22       lH"
                    addd      <U0014,U            * 0597 E3 C8 14       cH.
                    std       <U0022,U            * 059A ED C8 22       mH"
                    lda       U0007,U             * 059D A6 47          &G
                    ldb       #5                  * 059F C6 05          F.
                    pshs      U                   * 05A1 34 40          4@
                    os9       I$GetStt            * 05A3 10 3F 8D       .?.
                    tfr       U,D                 * 05A6 1F 30          .0
                    subd      #32                 * 05A8 83 00 20       ..
                    bge       L05AF               * 05AB 2C 02          ,.
                    leax      -$01,X              * 05AD 30 1F          0.
L05AF               ldu       0,S                 * 05AF EE E4          nd
                    tfr       D,Y                 * 05B1 1F 02          ..
                    lda       U0007,U             * 05B3 A6 47          &G
                    tfr       Y,U                 * 05B5 1F 23          .#
                    os9       I$Seek              * 05B7 10 3F 88       .?.
                    lbcs      L061C               * 05BA 10 25 00 5E    .%.^
                    puls      U                   * 05BE 35 40          5@
                    leax      <U0016,U            * 05C0 30 C8 16       0H.
                    ldy       #32                 * 05C3 10 8E 00 20    ...
                    lda       U0007,U             * 05C7 A6 47          &G
                    os9       I$Write             * 05C9 10 3F 8A       .?.
                    os9       I$Close             * 05CC 10 3F 8F       .?.
                    lbra      L061B               * 05CF 16 00 49       ..I
L05D2               leax      <U0016,U            * 05D2 30 C8 16       0H.
                    ldd       #1                  * 05D5 CC 00 01       L..
                    std       <U0018,U            * 05D8 ED C8 18       mH.
                    std       <U0022,U            * 05DB ED C8 22       mH"
                    ldd       #0                  * 05DE CC 00 00       L..
                    std       <U0020,U            * 05E1 ED C8 20       mH
                    std       <U0026,U            * 05E4 ED C8 26       mH&
                    std       <U0024,U            * 05E7 ED C8 24       mH$
                    ldd       U000E,U             * 05EA EC 4E          lN
                    std       <U0016,U            * 05EC ED C8 16       mH.
                    leax      <U001A,U            * 05EF 30 C8 1A       0H.
                    os9       F$Time              * 05F2 10 3F 15       .?.
                    lbcs      L061C               * 05F5 10 25 00 23    .%.#
                    leax      <U0016,U            * 05F9 30 C8 16       0H.
                    ldy       #32                 * 05FC 10 8E 00 20    ...
                    lda       U0007,U             * 0600 A6 47          &G
                    os9       I$Write             * 0602 10 3F 8A       .?.
                    os9       I$Close             * 0605 10 3F 8F       .?.
                    lbcs      L061C               * 0608 10 25 00 10    .%..
                    bra       L061B               * 060C 20 0D           .
L060E               leax      >L014D,PC           * 060E 30 8D FB 3B    0.{;
                    ldy       #200                * 0612 10 8E 00 C8    ...H
                    lda       #1                  * 0616 86 01          ..
                    os9       I$WritLn            * 0618 10 3F 8C       .?.
L061B               clrb                          * 061B 5F             _
L061C               os9       F$Exit              * 061C 10 3F 06       .?.
L061F               pshs      Y                   * 061F 34 20          4
L0621               lda       ,X+                 * 0621 A6 80          &.
                    cmpa      #13                 * 0623 81 0D          ..
                    lbeq      L06F4               * 0625 10 27 00 CB    .'.K
                    cmpa      #48                 * 0629 81 30          .0
                    bcs       L0621               * 062B 25 F4          %t
                    cmpa      #57                 * 062D 81 39          .9
                    bhi       L0621               * 062F 22 F0          "p
                    leax      -$01,X              * 0631 30 1F          0.
L0633               lda       ,X+                 * 0633 A6 80          &.
                    cmpa      #48                 * 0635 81 30          .0
                    bcs       L063F               * 0637 25 06          %.
                    cmpa      #57                 * 0639 81 39          .9
                    bhi       L063F               * 063B 22 02          ".
                    bra       L0633               * 063D 20 F4           t
L063F               pshs      X                   * 063F 34 10          4.
                    leax      -$01,X              * 0641 30 1F          0.
                    clr       U000A,U             * 0643 6F 4A          oJ
                    clr       U000B,U             * 0645 6F 4B          oK
                    ldd       #1                  * 0647 CC 00 01       L..
                    std       U000C,U             * 064A ED 4C          mL
L064C               lda       ,-X                 * 064C A6 82          &.
                    cmpa      #48                 * 064E 81 30          .0
                    bcs       L0680               * 0650 25 2E          %.
                    cmpa      #57                 * 0652 81 39          .9
                    bhi       L0680               * 0654 22 2A          "*
                    suba      #48                 * 0656 80 30          .0
                    sta       U0006,U             * 0658 A7 46          'F
                    ldd       #0                  * 065A CC 00 00       L..
L065D               tst       U0006,U             * 065D 6D 46          mF
                    beq       L0667               * 065F 27 06          '.
                    addd      U000C,U             * 0661 E3 4C          cL
                    dec       U0006,U             * 0663 6A 46          jF
                    bra       L065D               * 0665 20 F6           v
L0667               addd      U000A,U             * 0667 E3 4A          cJ
                    std       U000A,U             * 0669 ED 4A          mJ
                    lda       #10                 * 066B 86 0A          ..
                    sta       U0006,U             * 066D A7 46          'F
                    ldd       #0                  * 066F CC 00 00       L..
L0672               tst       U0006,U             * 0672 6D 46          mF
                    beq       L067C               * 0674 27 06          '.
                    addd      U000C,U             * 0676 E3 4C          cL
                    dec       U0006,U             * 0678 6A 46          jF
                    bra       L0672               * 067A 20 F6           v
L067C               std       U000C,U             * 067C ED 4C          mL
                    bra       L064C               * 067E 20 CC           L
L0680               ldd       U000A,U             * 0680 EC 4A          lJ
                    puls      X                   * 0682 35 10          5.
                    puls      PC,Y                * 0684 35 A0          5
L0686               pshs      X                   * 0686 34 10          4.
                    std       U000A,U             * 0688 ED 4A          mJ
                    lda       #48                 * 068A 86 30          .0
                    sta       0,X                 * 068C A7 84          '.
                    sta       $01,X               * 068E A7 01          '.
                    sta       $02,X               * 0690 A7 02          '.
                    sta       $03,X               * 0692 A7 03          '.
                    sta       $04,X               * 0694 A7 04          '.
                    ldd       #10000              * 0696 CC 27 10       L'.
                    std       U000C,U             * 0699 ED 4C          mL
                    ldd       U000A,U             * 069B EC 4A          lJ
                    lbsr      L06E5               * 069D 17 00 45       ..E
                    ldd       #1000               * 06A0 CC 03 E8       L.h
                    std       U000C,U             * 06A3 ED 4C          mL
                    ldd       U000A,U             * 06A5 EC 4A          lJ
                    bsr       L06E5               * 06A7 8D 3C          .<
                    ldd       #100                * 06A9 CC 00 64       L.d
                    std       U000C,U             * 06AC ED 4C          mL
                    ldd       U000A,U             * 06AE EC 4A          lJ
                    bsr       L06E5               * 06B0 8D 33          .3
                    ldd       #10                 * 06B2 CC 00 0A       L..
                    std       U000C,U             * 06B5 ED 4C          mL
                    ldd       U000A,U             * 06B7 EC 4A          lJ
                    bsr       L06E5               * 06B9 8D 2A          .*
                    ldd       #1                  * 06BB CC 00 01       L..
                    std       U000C,U             * 06BE ED 4C          mL
                    ldd       U000A,U             * 06C0 EC 4A          lJ
                    bsr       L06E5               * 06C2 8D 21          .!
                    lda       #13                 * 06C4 86 0D          ..
                    sta       0,X                 * 06C6 A7 84          '.
                    puls      X                   * 06C8 35 10          5.
                    ldb       #32                 * 06CA C6 20          F
L06CC               lda       0,X                 * 06CC A6 84          &.
                    cmpa      #48                 * 06CE 81 30          .0
                    bne       L06D6               * 06D0 26 04          &.
                    stb       ,X+                 * 06D2 E7 80          g.
                    bra       L06CC               * 06D4 20 F6           v
L06D6               lda       ,X+                 * 06D6 A6 80          &.
                    cmpa      #48                 * 06D8 81 30          .0
                    bcs       L06E2               * 06DA 25 06          %.
                    cmpa      #57                 * 06DC 81 39          .9
                    bhi       L06E2               * 06DE 22 02          ".
                    bra       L06D6               * 06E0 20 F4           t
L06E2               leax      -$01,X              * 06E2 30 1F          0.
                    rts                           * 06E4 39             9
L06E5               subd      U000C,U             * 06E5 A3 4C          #L
                    bcs       L06ED               * 06E7 25 04          %.
                    inc       0,X                 * 06E9 6C 84          l.
                    bra       L06E5               * 06EB 20 F8           x
L06ED               addd      U000C,U             * 06ED E3 4C          cL
                    std       U000A,U             * 06EF ED 4A          mJ
                    leax      $01,X               * 06F1 30 01          0.
                    rts                           * 06F3 39             9
L06F4               ldd       #-1                 * 06F4 CC FF FF       L..
                    puls      PC,Y                * 06F7 35 A0          5

                    emod
eom                 equ       *
                    end
