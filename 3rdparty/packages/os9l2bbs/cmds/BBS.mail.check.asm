                    nam       BBS.mail.check
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
U0004               rmb       2
U0006               rmb       1
U0007               rmb       3
U000A               rmb       1
U000B               rmb       1
U000C               rmb       2
U000E               rmb       34
U0030               rmb       64
U0070               rmb       160
U0110               rmb       60
U014C               rmb       2
U014E               rmb       1
U014F               rmb       201
size                equ       .

name                fcs       /BBS.mail.check/    * 000D 42 42 53 2E 6D 61 69 6C 2E 63 68 65 63 EB BBS.mail.check
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
L0086               fcc       "BBS.mail.inx"      * 0086 42 42 53 2E 6D 61 69 6C 2E 69 6E 78 BBS.mail.inx
                    fcb       $0D                 * 0092 0D             .
                    fcc       "BBS.mail"          * 0093 42 42 53 2E 6D 61 69 6C BBS.mail
                    fcb       $0D                 * 009B 0D             .
L009C               fcc       "/dd/bbs/BBS.alias" * 009C 2F 64 64 2F 62 62 73 2F 42 42 53 2E 61 6C 69 61 73 /dd/bbs/BBS.alias
                    fcb       $0D                 * 00AD 0D             .
                    fcb       $0A                 * 00AE 0A             .
                    fcb       $0D                 * 00AF 0D             .
L00B0               fcb       $0A                 * 00B0 0A             .
                    fcc       "Checking mailbox..." * 00B1 43 68 65 63 6B 69 6E 67 20 6D 61 69 6C 62 6F 78 2E 2E 2E Checking mailbox...
                    fcb       $0D                 * 00C4 0D             .
L00C5               fcb       $0A                 * 00C5 0A             .
                    fcc       "All previously sent mail has been read." * 00C6 41 6C 6C 20 70 72 65 76 69 6F 75 73 6C 79 20 73 65 6E 74 20 6D 61 69 6C 20 68 61 73 20 62 65 65 6E 20 72 65 61 64 2E All previously sent mail has been read.
                    fcb       $0D                 * 00ED 0D             .
L00EE               fcc       "Mail to "          * 00EE 4D 61 69 6C 20 74 6F 20 Mail to
L00F6               fcc       " has not yet been read." * 00F6 20 68 61 73 20 6E 6F 74 20 79 65 74 20 62 65 65 6E 20 72 65 61 64 2E  has not yet been read.
                    fcb       $0D                 * 010D 0D             .

start               os9       F$ID                * 010E 10 3F 0C       .?.
                    sty       U000E,U             * 0111 10 AF 4E       ./N
                    ldy       #0                  * 0114 10 8E 00 00    ....
                    os9       F$SUser             * 0118 10 3F 1C       .?.
                    leax      >L0086,PC           * 011B 30 8D FF 67    0..g
                    lda       #1                  * 011F 86 01          ..
                    os9       I$Open              * 0121 10 3F 84       .?.
                    lbcs      L01F3               * 0124 10 25 00 CB    .%.K
                    sta       U0000,U             * 0128 A7 C4          'D
                    clr       U0004,U             * 012A 6F 44          oD
                    leax      >L009C,PC           * 012C 30 8D FF 6C    0..l
                    lda       #1                  * 0130 86 01          ..
                    os9       I$Open              * 0132 10 3F 84       .?.
                    lbcs      L01F3               * 0135 10 25 00 BA    .%.:
                    sta       U0007,U             * 0139 A7 47          'G
                    leax      >L00B0,PC           * 013B 30 8D FF 71    0..q
                    ldy       #200                * 013F 10 8E 00 C8    ...H
                    lda       #1                  * 0143 86 01          ..
                    os9       I$WritLn            * 0145 10 3F 8C       .?.
                    leax      <U0030,U            * 0148 30 C8 30       0H0
                    ldy       #64                 * 014B 10 8E 00 40    ...@
                    lda       U0000,U             * 014F A6 C4          &D
                    os9       I$Read              * 0151 10 3F 89       .?.
                    lbcs      L01F3               * 0154 10 25 00 9B    .%..
L0158               leax      >U0110,U            * 0158 30 C9 01 10    0I..
                    ldy       #64                 * 015C 10 8E 00 40    ...@
                    lda       U0000,U             * 0160 A6 C4          &D
                    os9       I$Read              * 0162 10 3F 89       .?.
                    bcs       L0172               * 0165 25 0B          %.
                    ldd       >U014C,U            * 0167 EC C9 01 4C    lI.L
                    cmpd      U000E,U             * 016B 10 A3 4E       .#N
                    bne       L0158               * 016E 26 E8          &h
                    bra       L018F               * 0170 20 1D           .
L0172               cmpb      #211                * 0172 C1 D3          AS
                    lbne      L01F3               * 0174 10 26 00 7B    .&.{
                    tst       U0004,U             * 0178 6D 44          mD
                    beq       L017F               * 017A 27 03          '.
                    lbra      L01F2               * 017C 16 00 73       ..s
L017F               leax      >L00C5,PC           * 017F 30 8D FF 42    0..B
                    ldy       #200                * 0183 10 8E 00 C8    ...H
                    lda       #1                  * 0187 86 01          ..
                    os9       I$WritLn            * 0189 10 3F 8C       .?.
                    lbra      L01F2               * 018C 16 00 63       ..c
L018F               inc       <U0004              * 018F 0C 04          ..
                    pshs      U                   * 0191 34 40          4@
                    lda       U0007,U             * 0193 A6 47          &G
                    ldx       #0                  * 0195 8E 00 00       ...
                    ldu       #0                  * 0198 CE 00 00       N..
                    os9       I$Seek              * 019B 10 3F 88       .?.
                    puls      U                   * 019E 35 40          5@
                    lbcs      L01F3               * 01A0 10 25 00 4F    .%.O
L01A4               lda       U0007,U             * 01A4 A6 47          &G
                    ldy       #200                * 01A6 10 8E 00 C8    ...H
                    leax      <U0070,U            * 01AA 30 C8 70       0Hp
                    os9       I$ReadLn            * 01AD 10 3F 8B       .?.
                    lbcs      L0158               * 01B0 10 25 FF A4    .%.$
                    clr       U0006,U             * 01B4 6F 46          oF
L01B6               inc       U0006,U             * 01B6 6C 46          lF
                    lda       ,X+                 * 01B8 A6 80          &.
                    cmpa      #44                 * 01BA 81 2C          .,
                    bne       L01B6               * 01BC 26 F8          &x
                    dec       U0006,U             * 01BE 6A 46          jF
                    lbsr      L0200               * 01C0 17 00 3D       ..=
                    cmpd      >U014E,U            * 01C3 10 A3 C9 01 4E .#I.N
                    bne       L01A4               * 01C8 26 DA          &Z
                    leax      >L00EE,PC           * 01CA 30 8D FF 20    0..
                    ldy       #8                  * 01CE 10 8E 00 08    ....
                    lda       #1                  * 01D2 86 01          ..
                    os9       I$Write             * 01D4 10 3F 8A       .?.
                    leax      <U0070,U            * 01D7 30 C8 70       0Hp
                    ldb       U0006,U             * 01DA E6 46          fF
                    clra                          * 01DC 4F             O
                    tfr       D,Y                 * 01DD 1F 02          ..
                    lda       #1                  * 01DF 86 01          ..
                    os9       I$Write             * 01E1 10 3F 8A       .?.
                    leax      >L00F6,PC           * 01E4 30 8D FF 0E    0...
                    ldy       #200                * 01E8 10 8E 00 C8    ...H
                    os9       I$WritLn            * 01EC 10 3F 8C       .?.
                    lbra      L0158               * 01EF 16 FF 66       ..f
L01F2               clrb                          * 01F2 5F             _
L01F3               pshs      B                   * 01F3 34 04          4.
                    ldy       U000E,U             * 01F5 10 AE 4E       ..N
                    os9       F$SUser             * 01F8 10 3F 1C       .?.
                    puls      B                   * 01FB 35 04          5.
                    os9       F$Exit              * 01FD 10 3F 06       .?.
L0200               pshs      Y                   * 0200 34 20          4
L0202               lda       ,X+                 * 0202 A6 80          &.
                    cmpa      #13                 * 0204 81 0D          ..
                    lbeq      L02D5               * 0206 10 27 00 CB    .'.K
                    cmpa      #48                 * 020A 81 30          .0
                    bcs       L0202               * 020C 25 F4          %t
                    cmpa      #57                 * 020E 81 39          .9
                    bhi       L0202               * 0210 22 F0          "p
                    leax      -$01,X              * 0212 30 1F          0.
L0214               lda       ,X+                 * 0214 A6 80          &.
                    cmpa      #48                 * 0216 81 30          .0
                    bcs       L0220               * 0218 25 06          %.
                    cmpa      #57                 * 021A 81 39          .9
                    bhi       L0220               * 021C 22 02          ".
                    bra       L0214               * 021E 20 F4           t
L0220               pshs      X                   * 0220 34 10          4.
                    leax      -$01,X              * 0222 30 1F          0.
                    clr       U000A,U             * 0224 6F 4A          oJ
                    clr       U000B,U             * 0226 6F 4B          oK
                    ldd       #1                  * 0228 CC 00 01       L..
                    std       U000C,U             * 022B ED 4C          mL
L022D               lda       ,-X                 * 022D A6 82          &.
                    cmpa      #48                 * 022F 81 30          .0
                    bcs       L0261               * 0231 25 2E          %.
                    cmpa      #57                 * 0233 81 39          .9
                    bhi       L0261               * 0235 22 2A          "*
                    suba      #48                 * 0237 80 30          .0
                    sta       U0003,U             * 0239 A7 43          'C
                    ldd       #0                  * 023B CC 00 00       L..
L023E               tst       U0003,U             * 023E 6D 43          mC
                    beq       L0248               * 0240 27 06          '.
                    addd      U000C,U             * 0242 E3 4C          cL
                    dec       U0003,U             * 0244 6A 43          jC
                    bra       L023E               * 0246 20 F6           v
L0248               addd      U000A,U             * 0248 E3 4A          cJ
                    std       U000A,U             * 024A ED 4A          mJ
                    lda       #10                 * 024C 86 0A          ..
                    sta       U0003,U             * 024E A7 43          'C
                    ldd       #0                  * 0250 CC 00 00       L..
L0253               tst       U0003,U             * 0253 6D 43          mC
                    beq       L025D               * 0255 27 06          '.
                    addd      U000C,U             * 0257 E3 4C          cL
                    dec       U0003,U             * 0259 6A 43          jC
                    bra       L0253               * 025B 20 F6           v
L025D               std       U000C,U             * 025D ED 4C          mL
                    bra       L022D               * 025F 20 CC           L
L0261               ldd       U000A,U             * 0261 EC 4A          lJ
                    puls      X                   * 0263 35 10          5.
                    puls      PC,Y                * 0265 35 A0          5

                    pshs      X                   * 0267 34 10          4.
                    std       U000A,U             * 0269 ED 4A          mJ
                    lda       #48                 * 026B 86 30          .0
                    sta       0,X                 * 026D A7 84          '.
                    sta       $01,X               * 026F A7 01          '.
                    sta       $02,X               * 0271 A7 02          '.
                    sta       $03,X               * 0273 A7 03          '.
                    sta       $04,X               * 0275 A7 04          '.
                    ldd       #10000              * 0277 CC 27 10       L'.
                    std       U000C,U             * 027A ED 4C          mL
                    ldd       U000A,U             * 027C EC 4A          lJ
                    lbsr      L02C6               * 027E 17 00 45       ..E
                    ldd       #1000               * 0281 CC 03 E8       L.h
                    std       U000C,U             * 0284 ED 4C          mL
                    ldd       U000A,U             * 0286 EC 4A          lJ
                    bsr       L02C6               * 0288 8D 3C          .<
                    ldd       #100                * 028A CC 00 64       L.d
                    std       U000C,U             * 028D ED 4C          mL
                    ldd       U000A,U             * 028F EC 4A          lJ
                    bsr       L02C6               * 0291 8D 33          .3
                    ldd       #10                 * 0293 CC 00 0A       L..
                    std       U000C,U             * 0296 ED 4C          mL
                    ldd       U000A,U             * 0298 EC 4A          lJ
                    bsr       L02C6               * 029A 8D 2A          .*
                    ldd       #1                  * 029C CC 00 01       L..
                    std       U000C,U             * 029F ED 4C          mL
                    ldd       U000A,U             * 02A1 EC 4A          lJ
                    bsr       L02C6               * 02A3 8D 21          .!
                    lda       #13                 * 02A5 86 0D          ..
                    sta       0,X                 * 02A7 A7 84          '.
                    puls      X                   * 02A9 35 10          5.
                    ldb       #32                 * 02AB C6 20          F
L02AD               lda       0,X                 * 02AD A6 84          &.
                    cmpa      #48                 * 02AF 81 30          .0
                    bne       L02B7               * 02B1 26 04          &.
                    stb       ,X+                 * 02B3 E7 80          g.
                    bra       L02AD               * 02B5 20 F6           v
L02B7               lda       ,X+                 * 02B7 A6 80          &.
                    cmpa      #48                 * 02B9 81 30          .0
                    bcs       L02C3               * 02BB 25 06          %.
                    cmpa      #57                 * 02BD 81 39          .9
                    bhi       L02C3               * 02BF 22 02          ".
                    bra       L02B7               * 02C1 20 F4           t
L02C3               leax      -$01,X              * 02C3 30 1F          0.
                    rts                           * 02C5 39             9
L02C6               subd      U000C,U             * 02C6 A3 4C          #L
                    bcs       L02CE               * 02C8 25 04          %.
                    inc       0,X                 * 02CA 6C 84          l.
                    bra       L02C6               * 02CC 20 F8           x
L02CE               addd      U000C,U             * 02CE E3 4C          cL
                    std       U000A,U             * 02D0 ED 4A          mJ
                    leax      $01,X               * 02D2 30 01          0.
                    rts                           * 02D4 39             9
L02D5               ldd       #-1                 * 02D5 CC FF FF       L..
                    puls      PC,Y                * 02D8 35 A0          5

                    emod
eom                 equ       *
                    end
