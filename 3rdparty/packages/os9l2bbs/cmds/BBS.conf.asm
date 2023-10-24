                    nam       BBS.conf
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       2
U0002               rmb       2
U0004               rmb       2
U0006               rmb       2
U0008               rmb       2
U000A               rmb       2
U000C               rmb       200
buffer              rmb       1
U00D5               rmb       419
size                equ       .

name                fcs       /BBS.conf/          * 000D 42 42 53 2E 63 6F 6E E6 BBS.conf
confdat             fcc       "Conf.dat"          * 0015 43 6F 6E 66 2E 64 61 74 Conf.dat
L001D               fcb       $0D                 * 001D 0D             .
                    fcb       $0A                 * 001E 0A             .
handle              fcc       "Enter your handle:" * 001F 45 6E 74 65 72 20 79 6F 75 72 20 68 61 6E 64 6C 65 3A Enter your handle:
prompt              fcc       "Press <CTRL><Z> to exit         <CTRL><X> who's in conf mode" * 0031 50 72 65 73 73 20 3C 43 54 52 4C 3E 3C 5A 3E 20 74 6F 20 65 78 69 74 20 20 20 20 20 20 20 20 20 3C 43 54 52 4C 3E 3C 58 3E 20 77 68 6F 27 73 20 69 6E 20 63 6F 6E
                    fcb       $0D                 * 006D 0D             .
line                fcc       "------------------------------------------------------------" * 006E 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
                    fcb       $0D                 * 00AA 0D             .
confwho             fcc       "BBS.conf.who"      * 00AB 42 42 53 2E 63 6F 6E 66 2E 77 68 6F BBS.conf.who
                    fcb       $0D                 * 00B7 0D             .

Icpt                ldx       U0006,U             * 00B8 AE 46          .F
L00BA               ldd       ,X++                * 00BA EC 81          l.
                    leax      $01,X               * 00BC 30 01          0.
                    cmpd      U0002,U             * 00BE 10 A3 42       .#B
                    bne       L00BA               * 00C1 26 F7          &w
                    leax      -$03,X              * 00C3 30 1D          0.
                    clr       0,X                 * 00C5 6F 84          o.
                    clr       $01,X               * 00C7 6F 01          o.
                    clrb                          * 00C9 5F             _
                    pshs      U                   * 00CA 34 40          4@
                    ldu       U0004,U             * 00CC EE 44          nD
                    os9       F$UnLink            * 00CE 10 3F 02       .?.
                    puls      U                   * 00D1 35 40          5@
                    clrb                          * 00D3 5F             _
                    os9       F$Exit              * 00D4 10 3F 06       .?.
                    fcb       $3B                 * 00D7 3B             ;

start               leax      >Icpt,PC            * 00D8 30 8D FF DC    0..\
                    os9       F$Icpt              * 00DC 10 3F 09       .?.
                    os9       F$ID                * 00DF 10 3F 0C       .?.
                    leay      $01,Y               * 00E2 31 21          1!
                    sty       U0002,U             * 00E4 10 AF 42       ./B
                    leax      >handle,PC          * 00E7 30 8D FF 34    0..4
                    ldy       #18                 * 00EB 10 8E 00 12    ....
                    lda       #1                  * 00EF 86 01          ..
                    os9       I$Write             * 00F1 10 3F 8A       .?.
                    clra                          * 00F4 4F             O
                    leax      >buffer,U           * 00F5 30 C9 00 D4    0I.T
                    ldy       #20                 * 00F9 10 8E 00 14    ....
                    os9       I$ReadLn            * 00FD 10 3F 8B       .?.
                    leax      >prompt,PC          * 0100 30 8D FF 2D    0..-
                    ldy       #200                * 0104 10 8E 00 C8    ...H
                    lda       #1                  * 0108 86 01          ..
                    os9       I$WritLn            * 010A 10 3F 8C       .?.
                    leax      >line,PC            * 010D 30 8D FF 5D    0..]
                    ldy       #200                * 0111 10 8E 00 C8    ...H
                    os9       I$WritLn            * 0115 10 3F 8C       .?.
                    leax      >confdat,PC         * 0118 30 8D FE F9    0.~y
                    lda       #65                 * 011C 86 41          .A
                    pshs      U                   * 011E 34 40          4@
                    os9       F$Link              * 0120 10 3F 00       .?.
                    bcc       L0132               * 0123 24 0D          $.
                    cmpb      #221                * 0125 C1 DD          A]
                    lbne      L0263               * 0127 10 26 01 38    .&.8
                    os9       F$Load              * 012B 10 3F 01       .?.
                    lbcs      L0263               * 012E 10 25 01 31    .%.1
L0132               tfr       U,D                 * 0132 1F 30          .0
                    puls      U                   * 0134 35 40          5@
                    std       U0004,U             * 0136 ED 44          mD
                    sty       U0006,U             * 0138 10 AF 46       ./F
                    leax      U000C,U             * 013B 30 4C          0L
                    stx       U0008,U             * 013D AF 48          /H
                    stx       U000A,U             * 013F AF 4A          /J
L0141               ldd       0,Y                 * 0141 EC A4          l$
                    beq       L014F               * 0143 27 0A          '.
                    cmpd      #-1                 * 0145 10 83 FF FF    ....
                    beq       L014F               * 0149 27 04          '.
                    leay      $03,Y               * 014B 31 23          1#
                    bra       L0141               * 014D 20 F2           r
L014F               ldd       U0002,U             * 014F EC 42          lB
                    std       ,Y++                * 0151 ED A1          m!
                    lda       #1                  * 0153 86 01          ..
                    sta       0,Y                 * 0155 A7 A4          '$
L0157               lbsr      L015F               * 0157 17 00 05       ...
                    lbsr      L01D3               * 015A 17 00 76       ..v
                    bra       L0157               * 015D 20 F8           x
L015F               ldx       U0006,U             * 015F AE 46          .F
L0161               ldd       ,X++                * 0161 EC 81          l.
                    cmpd      #-1                 * 0163 10 83 FF FF    ....
                    lbeq      L01CE               * 0167 10 27 00 63    .'.c
                    cmpd      U0002,U             * 016B 10 A3 42       .#B
                    beq       L0174               * 016E 27 04          '.
                    leax      $01,X               * 0170 30 01          0.
                    bra       L0161               * 0172 20 ED           m
L0174               lda       ,X+                 * 0174 A6 80          &.
                    beq       L0179               * 0176 27 01          '.
                    rts                           * 0178 39             9
L0179               lda       #1                  * 0179 86 01          ..
                    sta       -$01,X              * 017B A7 1F          '.
                    leax      >L001D,PC           * 017D 30 8D FE 9C    0.~.
                    ldy       #1                  * 0181 10 8E 00 01    ....
                    lda       #1                  * 0185 86 01          ..
                    os9       I$WritLn            * 0187 10 3F 8C       .?.
                    ldx       U0006,U             * 018A AE 46          .F
                    leax      >$0104,X            * 018C 30 89 01 04    0...
                    clrb                          * 0190 5F             _
L0191               lda       ,X+                 * 0191 A6 80          &.
                    incb                          * 0193 5C             \
                    cmpa      #58                 * 0194 81 3A          .:
                    beq       L019C               * 0196 27 04          '.
                    cmpa      #13                 * 0198 81 0D          ..
                    bne       L0191               * 019A 26 F5          &u
L019C               lda       #58                 * 019C 86 3A          .:
                    sta       -$01,X              * 019E A7 1F          '.
                    clra                          * 01A0 4F             O
                    tfr       D,Y                 * 01A1 1F 02          ..
                    ldx       U0006,U             * 01A3 AE 46          .F
                    leax      >$0104,X            * 01A5 30 89 01 04    0...
                    lda       #1                  * 01A9 86 01          ..
                    os9       I$Write             * 01AB 10 3F 8A       .?.
                    ldx       U0006,U             * 01AE AE 46          .F
                    leax      <$003C,X            * 01B0 30 88 3C       0.<
                    lda       #1                  * 01B3 86 01          ..
                    ldy       #200                * 01B5 10 8E 00 C8    ...H
                    os9       I$WritLn            * 01B9 10 3F 8C       .?.
                    leax      U000C,U             * 01BC 30 4C          0L
                    stx       U0000,U             * 01BE AF C4          /D
                    ldd       U0008,U             * 01C0 EC 48          lH
                    subd      U0000,U             * 01C2 A3 C4          #D
                    tfr       D,Y                 * 01C4 1F 02          ..
                    leax      U000C,U             * 01C6 30 4C          0L
                    lda       #1                  * 01C8 86 01          ..
                    os9       I$Write             * 01CA 10 3F 8A       .?.
                    rts                           * 01CD 39             9
L01CE               ldb       #1                  * 01CE C6 01          F.
                    lbra      L0263               * 01D0 16 00 90       ...
L01D3               clra                          * 01D3 4F             O
                    ldb       #1                  * 01D4 C6 01          F.
                    os9       I$GetStt            * 01D6 10 3F 8D       .?.
                    bcs       L023D               * 01D9 25 62          %b
                    ldy       #1                  * 01DB 10 8E 00 01    ....
                    ldx       U0008,U             * 01DF AE 48          .H
                    os9       I$Read              * 01E1 10 3F 89       .?.
                    lda       ,X+                 * 01E4 A6 80          &.
                    cmpa      #8                  * 01E6 81 08          ..
                    beq       L023F               * 01E8 27 55          'U
                    cmpa      #26                 * 01EA 81 1A          ..
                    lbeq      L0248               * 01EC 10 27 00 58    .'.X
                    cmpa      #24                 * 01F0 81 18          ..
                    lbeq      L0266               * 01F2 10 27 00 70    .'.p
                    cmpa      #13                 * 01F6 81 0D          ..
                    beq       L020B               * 01F8 27 11          '.
                    leay      >buffer,U           * 01FA 31 C9 00 D4    1I.T
                    sty       U0000,U             * 01FE 10 AF C4       ./D
                    cmpx      U0000,U             * 0201 AC C4          ,D
                    lbeq      L023D               * 0203 10 27 00 36    .'.6
                    stx       U0008,U             * 0207 AF 48          /H
                    bra       L023E               * 0209 20 33           3
L020B               leax      >L001D,PC           * 020B 30 8D FE 0E    0.~.
                    ldy       #1                  * 020F 10 8E 00 01    ....
                    lda       #1                  * 0213 86 01          ..
                    os9       I$WritLn            * 0215 10 3F 8C       .?.
                    ldx       U0006,U             * 0218 AE 46          .F
                    leax      <$003C,X            * 021A 30 88 3C       0.<
                    leay      U000C,U             * 021D 31 4C          1L
                    sty       U0008,U             * 021F 10 AF 48       ./H
                    ldb       #255                * 0222 C6 FF          F.
L0224               lda       ,Y+                 * 0224 A6 A0          &
                    sta       ,X+                 * 0226 A7 80          '.
                    decb                          * 0228 5A             Z
                    bne       L0224               * 0229 26 F9          &y
                    lda       #58                 * 022B 86 3A          .:
                    sta       ,X+                 * 022D A7 80          '.
                    ldx       U0006,U             * 022F AE 46          .F
L0231               ldd       ,X++                * 0231 EC 81          l.
                    cmpd      #-1                 * 0233 10 83 FF FF    ....
                    beq       L023D               * 0237 27 04          '.
                    clr       ,X+                 * 0239 6F 80          o.
                    bra       L0231               * 023B 20 F4           t
L023D               clra                          * 023D 4F             O
L023E               rts                           * 023E 39             9
L023F               leax      -$02,X              * 023F 30 1E          0.
                    cmpx      U000A,U             * 0241 AC 4A          ,J
                    bls       L0247               * 0243 23 02          #.
                    stx       U0008,U             * 0245 AF 48          /H
L0247               rts                           * 0247 39             9
L0248               ldx       U0006,U             * 0248 AE 46          .F
L024A               ldd       ,X++                * 024A EC 81          l.
                    leax      $01,X               * 024C 30 01          0.
                    cmpd      U0002,U             * 024E 10 A3 42       .#B
                    bne       L024A               * 0251 26 F7          &w
                    leax      -$03,X              * 0253 30 1D          0.
                    clr       0,X                 * 0255 6F 84          o.
                    clr       $01,X               * 0257 6F 01          o.
                    pshs      U                   * 0259 34 40          4@
                    ldu       U0004,U             * 025B EE 44          nD
                    os9       F$UnLink            * 025D 10 3F 02       .?.
                    puls      U                   * 0260 35 40          5@
                    clrb                          * 0262 5F             _
L0263               os9       F$Exit              * 0263 10 3F 06       .?.
L0266               lda       #17                 * 0266 86 11          ..
                    ldb       #3                  * 0268 C6 03          F.
                    ldy       #1                  * 026A 10 8E 00 01    ....
                    leax      >confwho,PC         * 026E 30 8D FE 39    0.~9
                    pshs      U                   * 0272 34 40          4@
                    leau      >L001D,PC           * 0274 33 8D FD A5    3.}%
                    os9       F$Fork              * 0278 10 3F 03       .?.
                    os9       F$Wait              * 027B 10 3F 04       .?.
                    puls      U                   * 027E 35 40          5@
                    rts                           * 0280 39             9

                    emod
eom                 equ       *
                    end
