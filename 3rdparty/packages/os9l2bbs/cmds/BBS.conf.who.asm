                    nam       BBS.conf.who
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
U0004               rmb       1
U0005               rmb       1
U0006               rmb       2
dataddr             rmb       2
U000A               rmb       2
U000C               rmb       200
U00D4               rmb       1
U00D5               rmb       599
size                equ       .

name                fcs       /BBS.conf.who/      * 000D 42 42 53 2E 63 6F 6E 66 2E 77 68 EF BBS.conf.who
confdat             fcc       "Conf.dat"          * 0019 43 6F 6E 66 2E 64 61 74 Conf.dat
                    fcb       $0D                 * 0021 0D             .
bbsalias            fcc       "/dd/bbs/BBS.alias" * 0022 2F 64 64 2F 62 62 73 2F 42 42 53 2E 61 6C 69 61 73 /dd/bbs/BBS.alias
                    fcb       $0D                 * 0033 0D             .
noone               fcc       "No one is in conference" * 0034 4E 6F 20 6F 6E 65 20 69 73 20 69 6E 20 63 6F 6E 66 65 72 65 6E 63 65 No one is in conference
                    fcb       $0D                 * 004B 0D             .
these               fcc       "These people are in conference" * 004C 54 68 65 73 65 20 70 65 6F 70 6C 65 20 61 72 65 20 69 6E 20 63 6F 6E 66 65 72 65 6E 63 65 These people are in conference
                    fcb       $0D                 * 006A 0D             .
line                fcc       "------------------------------" * 006B 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D ------------------------------
                    fcb       $0D                 * 0089 0D             .

start               leax      >confdat,PC         * 008A 30 8D FF 8B    0...
                    lda       #65                 * 008E 86 41          .A
                    pshs      U                   * 0090 34 40          4@
                    os9       F$Link              * Link to Conf.dat                         * 0092 10 3F 00       .?.
                    lbcs      L00E6               * Branch if conference empty               * 0095 10 25 00 4D    .%.M
                    tfr       U,D                 * Move module offset to D                  * 0099 1F 30          .0
                    puls      U                   * 009B 35 40          5@
                    std       dataddr,U           * Save module offset                       * 009D ED 48          mH
                    sty       U000A,U             * 009F 10 AF 4A       ./J
                    leax      >these,PC           * 00A2 30 8D FF A6    0..&
                    ldy       #200                * 00A6 10 8E 00 C8    ...H
                    lda       #1                  * 00AA 86 01          ..
                    os9       I$WritLn            * 00AC 10 3F 8C       .?.
                    leax      >line,PC            * 00AF 30 8D FF B8    0..8
                    ldy       #200                * 00B3 10 8E 00 C8    ...H
                    os9       I$WritLn            * 00B7 10 3F 8C       .?.
                    ldx       U000A,U             * 00BA AE 4A          .J
L00BC               ldd       ,X++                * 00BC EC 81          l.
                    cmpd      #-1                 * 00BE 10 83 FF FF    ....
                    beq       L00D8               * 00C2 27 14          '.
                    leax      $01,X               * 00C4 30 01          0.
                    cmpd      #0                  * 00C6 10 83 00 00    ....
                    beq       L00BC               * 00CA 27 F0          'p
                    pshs      X                   * 00CC 34 10          4.
                    subd      #1                  * 00CE 83 00 01       ...
                    lbsr      L00F7               * 00D1 17 00 23       ..#
                    puls      X                   * 00D4 35 10          5.
                    bra       L00BC               * 00D6 20 E4           d
L00D8               clrb                          * 00D8 5F             _
                    pshs      U                   * 00D9 34 40          4@
                    ldu       dataddr,U           * 00DB EE 48          nH
                    os9       F$UnLink            * 00DD 10 3F 02       .?.
                    puls      U                   * 00E0 35 40          5@
                    clrb                          * 00E2 5F             _
                    os9       F$Exit              * 00E3 10 3F 06       .?.
L00E6               leax      >noone,PC           * 00E6 30 8D FF 4A    0..J
                    lda       #1                  * 00EA 86 01          ..
                    ldy       #200                * 00EC 10 8E 00 C8    ...H
                    os9       I$WritLn            * 00F0 10 3F 8C       .?.
                    clrb                          * 00F3 5F             _
                    os9       F$Exit              * 00F4 10 3F 06       .?.
L00F7               std       U0002,U             * 00F7 ED 42          mB
                    leax      >bbsalias,PC        * 00F9 30 8D FF 25    0..%
                    lda       #1                  * 00FD 86 01          ..
                    os9       I$Open              * 00FF 10 3F 84       .?.
                    lbcs      L0203               * 0102 10 25 00 FD    .%.}
                    sta       U0000,U             * 0106 A7 C4          'D
L0108               leax      U000C,U             * 0108 30 4C          0L
                    ldy       #200                * 010A 10 8E 00 C8    ...H
                    lda       U0000,U             * 010E A6 C4          &D
                    os9       I$ReadLn            * 0110 10 3F 8B       .?.
                    lbcs      L0203               * 0113 10 25 00 EC    .%.l
L0117               lda       ,X+                 * 0117 A6 80          &.
                    cmpa      #44                 * 0119 81 2C          .,
                    bne       L0117               * 011B 26 FA          &z
                    lbsr      L0147               * 011D 17 00 27       ..'
                    cmpd      U0002,U             * 0120 10 A3 42       .#B
                    bne       L0108               * 0123 26 E3          &c
                    leax      U000C,U             * 0125 30 4C          0L
                    leay      >U00D4,U            * 0127 31 C9 00 D4    1I.T
L012B               lda       ,X+                 * 012B A6 80          &.
                    cmpa      #44                 * 012D 81 2C          .,
                    beq       L0135               * 012F 27 04          '.
                    sta       ,Y+                 * 0131 A7 A0          '
                    bra       L012B               * 0133 20 F6           v
L0135               lda       #13                 * 0135 86 0D          ..
                    sta       0,Y                 * 0137 A7 A4          '$
                    leax      >U00D4,U            * 0139 30 C9 00 D4    0I.T
                    ldy       #200                * 013D 10 8E 00 C8    ...H
                    lda       #1                  * 0141 86 01          ..
                    os9       I$WritLn            * 0143 10 3F 8C       .?.
                    rts                           * 0146 39             9
L0147               pshs      Y                   * 0147 34 20          4
L0149               lda       ,X+                 * 0149 A6 80          &.
                    cmpa      #13                 * 014B 81 0D          ..
                    lbeq      L01FE               * 014D 10 27 00 AD    .'.-
                    cmpa      #48                 * 0151 81 30          .0
                    bcs       L0149               * 0153 25 F4          %t
                    cmpa      #57                 * 0155 81 39          .9
                    bhi       L0149               * 0157 22 F0          "p
                    leax      -$01,X              * 0159 30 1F          0.
L015B               lda       ,X+                 * 015B A6 80          &.
                    cmpa      #48                 * 015D 81 30          .0
                    bcs       L0167               * 015F 25 06          %.
                    cmpa      #57                 * 0161 81 39          .9
                    bhi       L0167               * 0163 22 02          ".
                    bra       L015B               * 0165 20 F4           t
L0167               pshs      X                   * 0167 34 10          4.
                    leax      -$01,X              * 0169 30 1F          0.
                    clr       U0004,U             * 016B 6F 44          oD
                    clr       U0005,U             * 016D 6F 45          oE
                    ldd       #1                  * 016F CC 00 01       L..
                    std       U0006,U             * 0172 ED 46          mF
L0174               lda       ,-X                 * 0174 A6 82          &.
                    cmpa      #48                 * 0176 81 30          .0
                    bcs       L01A8               * 0178 25 2E          %.
                    cmpa      #57                 * 017A 81 39          .9
                    bhi       L01A8               * 017C 22 2A          "*
                    suba      #48                 * 017E 80 30          .0
                    sta       U0001,U             * 0180 A7 41          'A
                    ldd       #0                  * 0182 CC 00 00       L..
L0185               tst       U0001,U             * 0185 6D 41          mA
                    beq       L018F               * 0187 27 06          '.
                    addd      U0006,U             * 0189 E3 46          cF
                    dec       U0001,U             * 018B 6A 41          jA
                    bra       L0185               * 018D 20 F6           v
L018F               addd      U0004,U             * 018F E3 44          cD
                    std       U0004,U             * 0191 ED 44          mD
                    lda       #10                 * 0193 86 0A          ..
                    sta       U0001,U             * 0195 A7 41          'A
                    ldd       #0                  * 0197 CC 00 00       L..
L019A               tst       U0001,U             * 019A 6D 41          mA
                    beq       L01A4               * 019C 27 06          '.
                    addd      U0006,U             * 019E E3 46          cF
                    dec       U0001,U             * 01A0 6A 41          jA
                    bra       L019A               * 01A2 20 F6           v
L01A4               std       U0006,U             * 01A4 ED 46          mF
                    bra       L0174               * 01A6 20 CC           L
L01A8               ldd       U0004,U             * 01A8 EC 44          lD
                    puls      X                   * 01AA 35 10          5.
                    puls      PC,Y                * 01AC 35 A0          5

unused              std       U0004,U             * 01AE ED 44          mD
                    lda       #48                 * 01B0 86 30          .0
                    sta       0,X                 * 01B2 A7 84          '.
                    sta       $01,X               * 01B4 A7 01          '.
                    sta       $02,X               * 01B6 A7 02          '.
                    sta       $03,X               * 01B8 A7 03          '.
                    sta       $04,X               * 01BA A7 04          '.
                    ldd       #10000              * 01BC CC 27 10       L'.
                    std       U0006,U             * 01BF ED 46          mF
                    ldd       U0004,U             * 01C1 EC 44          lD
                    lbsr      L01EF               * 01C3 17 00 29       ..)
                    ldd       #1000               * 01C6 CC 03 E8       L.h
                    std       U0006,U             * 01C9 ED 46          mF
                    ldd       U0004,U             * 01CB EC 44          lD
                    bsr       L01EF               * 01CD 8D 20          .
                    ldd       #100                * 01CF CC 00 64       L.d
                    std       U0006,U             * 01D2 ED 46          mF
                    ldd       U0004,U             * 01D4 EC 44          lD
                    bsr       L01EF               * 01D6 8D 17          ..
                    ldd       #10                 * 01D8 CC 00 0A       L..
                    std       U0006,U             * 01DB ED 46          mF
                    ldd       U0004,U             * 01DD EC 44          lD
                    bsr       L01EF               * 01DF 8D 0E          ..
                    ldd       #1                  * 01E1 CC 00 01       L..
                    std       U0006,U             * 01E4 ED 46          mF
                    ldd       U0004,U             * 01E6 EC 44          lD
                    bsr       L01EF               * 01E8 8D 05          ..
                    lda       #13                 * 01EA 86 0D          ..
                    sta       0,X                 * 01EC A7 84          '.
                    rts                           * 01EE 39             9
L01EF               subd      U0006,U             * 01EF A3 46          #F
                    bcs       L01F7               * 01F1 25 04          %.
                    inc       0,X                 * 01F3 6C 84          l.
                    bra       L01EF               * 01F5 20 F8           x
L01F7               addd      U0006,U             * 01F7 E3 46          cF
                    std       U0004,U             * 01F9 ED 44          mD
                    leax      $01,X               * 01FB 30 01          0.
                    rts                           * 01FD 39             9
L01FE               lda       #1                  * 01FE 86 01          ..
                    bra       L0203               * 0200 20 01           .
                    fcb       $5F                 * 0202 5F             _
L0203               os9       F$Exit              * 0203 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
