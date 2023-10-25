                    nam       BBS.who
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
U0005               rmb       2
U0007               rmb       2
U0009               rmb       200
U00D1               rmb       200
U0199               rmb       1
U019A               rmb       911
size                equ       .

name                fcs       /BBS.who/           * 000D 42 42 53 2E 77 68 EF BBS.who
L0014               fcc       "Unknown User"      * 0014 55 6E 6B 6E 6F 77 6E 20 55 73 65 72 Unknown User
                    fcb       $0D                 * 0020 0D             .
L0021               fcc       "/dd/bbs/BBS.alias" * 0021 2F 64 64 2F 62 62 73 2F 42 42 53 2E 61 6C 69 61 73 /dd/bbs/BBS.alias
                    fcb       $0D                 * 0032 0D             .
L0033               fcc       "The following users are on-line" * 0033 54 68 65 20 66 6F 6C 6C 6F 77 69 6E 67 20 75 73 65 72 73 20 61 72 65 20 6F 6E 2D 6C 69 6E 65 The following users are on-line
                    fcb       $0D                 * 0052 0D             .
L0053               fcc       "-------------------------------" * 0053 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D -------------------------------
                    fcb       $0D                 * 0072 0D             .
start               clra                          * 0073 4F             O
                    leax      >U00D1,U            * 0074 30 C9 00 D1    0I.Q
                    ldb       #200                * 0078 C6 C8          FH
L007A               sta       ,X+                 * 007A A7 80          '.
                    decb                          * 007C 5A             Z
                    bne       L007A               * 007D 26 FB          &{
                    clr       U0001,U             * 007F 6F 41          oA
                    leax      >L0021,PC           * 0081 30 8D FF 9C    0...
                    lda       #1                  * 0085 86 01          ..
                    os9       I$Open              * 0087 10 3F 84       .?.
                    lbcs      L012E               * 008A 10 25 00 A0    .%.
                    sta       U0000,U             * 008E A7 C4          'D
                    leax      >L0033,PC           * 0090 30 8D FF 9F    0...
                    ldy       #200                * 0094 10 8E 00 C8    ...H
                    lda       #1                  * 0098 86 01          ..
                    os9       I$WritLn            * 009A 10 3F 8C       .?.
                    leax      >L0053,PC           * 009D 30 8D FF B2    0..2
                    ldy       #200                * 00A1 10 8E 00 C8    ...H
                    os9       I$WritLn            * 00A5 10 3F 8C       .?.
L00A8               leax      >U0199,U            * 00A8 30 C9 01 99    0I..
                    lda       U0001,U             * 00AC A6 41          &A
                    os9       F$GPrDsc            * 00AE 10 3F 18       .?.
                    bcs       L00B7               * 00B1 25 04          %.
                    ldd       $08,X               * 00B3 EC 08          l.
                    bsr       L00C3               * 00B5 8D 0C          ..
L00B7               lda       U0001,U             * 00B7 A6 41          &A
                    inca                          * 00B9 4C             L
                    sta       U0001,U             * 00BA A7 41          'A
                    cmpa      #255                * 00BC 81 FF          ..
                    bcs       L00A8               * 00BE 25 E8          %h
                    lbra      L012D               * 00C0 16 00 6A       ..j
L00C3               leax      >U00D1,U            * 00C3 30 C9 00 D1    0I.Q
L00C7               cmpd      0,X                 * 00C7 10 A3 84       .#.
                    beq       L00D6               * 00CA 27 0A          '.
                    pshs      D                   * 00CC 34 06          4.
                    ldd       ,X++                * 00CE EC 81          l.
                    beq       L00D7               * 00D0 27 05          '.
                    puls      D                   * 00D2 35 06          5.
                    bra       L00C7               * 00D4 20 F1           q
L00D6               rts                           * 00D6 39             9
L00D7               puls      D                   * 00D7 35 06          5.
                    std       -$02,X              * 00D9 ED 1E          m.
                    std       U0005,U             * 00DB ED 45          mE
                    lda       U0000,U             * 00DD A6 C4          &D
                    pshs      U                   * 00DF 34 40          4@
                    ldu       #0                  * 00E1 CE 00 00       N..
                    ldx       #0                  * 00E4 8E 00 00       ...
                    os9       I$Seek              * 00E7 10 3F 88       .?.
                    puls      U                   * 00EA 35 40          5@
L00EC               lda       U0000,U             * 00EC A6 C4          &D
                    leax      U0009,U             * 00EE 30 49          0I
                    ldy       #200                * 00F0 10 8E 00 C8    ...H
                    os9       I$ReadLn            * 00F4 10 3F 8B       .?.
                    bcs       L0113               * 00F7 25 1A          %.
L00F9               lda       ,X+                 * 00F9 A6 80          &.
                    cmpa      #44                 * 00FB 81 2C          .,
                    beq       L0105               * 00FD 27 06          '.
                    cmpa      #13                 * 00FF 81 0D          ..
                    bne       L00F9               * 0101 26 F6          &v
                    bra       L00EC               * 0103 20 E7           g
L0105               lda       #13                 * 0105 86 0D          ..
                    sta       -$01,X              * 0107 A7 1F          '.
                    lbsr      L0131               * 0109 17 00 25       ..%
                    cmpd      U0005,U             * 010C 10 A3 45       .#E
                    beq       L0121               * 010F 27 10          '.
                    bra       L00EC               * 0111 20 D9           Y
L0113               leax      >L0014,PC           * 0113 30 8D FE FD    0.~}
                    ldy       #200                * 0117 10 8E 00 C8    ...H
                    lda       #1                  * 011B 86 01          ..
                    os9       I$WritLn            * 011D 10 3F 8C       .?.
                    rts                           * 0120 39             9
L0121               leax      U0009,U             * 0121 30 49          0I
                    ldy       #200                * 0123 10 8E 00 C8    ...H
                    lda       #1                  * 0127 86 01          ..
                    os9       I$WritLn            * 0129 10 3F 8C       .?.
                    rts                           * 012C 39             9
L012D               clrb                          * 012D 5F             _
L012E               os9       F$Exit              * 012E 10 3F 06       .?.
L0131               pshs      Y                   * 0131 34 20          4
L0133               lda       ,X+                 * 0133 A6 80          &.
                    cmpa      #13                 * 0135 81 0D          ..
                    lbeq      L01E8               * 0137 10 27 00 AD    .'.-
                    cmpa      #48                 * 013B 81 30          .0
                    bcs       L0133               * 013D 25 F4          %t
                    cmpa      #57                 * 013F 81 39          .9
                    bhi       L0133               * 0141 22 F0          "p
                    leax      -$01,X              * 0143 30 1F          0.
L0145               lda       ,X+                 * 0145 A6 80          &.
                    cmpa      #48                 * 0147 81 30          .0
                    bcs       L0151               * 0149 25 06          %.
                    cmpa      #57                 * 014B 81 39          .9
                    bhi       L0151               * 014D 22 02          ".
                    bra       L0145               * 014F 20 F4           t
L0151               pshs      X                   * 0151 34 10          4.
                    leax      -$01,X              * 0153 30 1F          0.
                    clr       U0003,U             * 0155 6F 43          oC
                    clr       U0004,U             * 0157 6F 44          oD
                    ldd       #1                  * 0159 CC 00 01       L..
                    std       U0007,U             * 015C ED 47          mG
L015E               lda       ,-X                 * 015E A6 82          &.
                    cmpa      #48                 * 0160 81 30          .0
                    bcs       L0192               * 0162 25 2E          %.
                    cmpa      #57                 * 0164 81 39          .9
                    bhi       L0192               * 0166 22 2A          "*
                    suba      #48                 * 0168 80 30          .0
                    sta       U0002,U             * 016A A7 42          'B
                    ldd       #0                  * 016C CC 00 00       L..
L016F               tst       U0002,U             * 016F 6D 42          mB
                    beq       L0179               * 0171 27 06          '.
                    addd      U0007,U             * 0173 E3 47          cG
                    dec       U0002,U             * 0175 6A 42          jB
                    bra       L016F               * 0177 20 F6           v
L0179               addd      U0003,U             * 0179 E3 43          cC
                    std       U0003,U             * 017B ED 43          mC
                    lda       #10                 * 017D 86 0A          ..
                    sta       U0002,U             * 017F A7 42          'B
                    ldd       #0                  * 0181 CC 00 00       L..
L0184               tst       U0002,U             * 0184 6D 42          mB
                    beq       L018E               * 0186 27 06          '.
                    addd      U0007,U             * 0188 E3 47          cG
                    dec       U0002,U             * 018A 6A 42          jB
                    bra       L0184               * 018C 20 F6           v
L018E               std       U0007,U             * 018E ED 47          mG
                    bra       L015E               * 0190 20 CC           L
L0192               ldd       U0003,U             * 0192 EC 43          lC
                    puls      X                   * 0194 35 10          5.
                    puls      PC,Y                * 0196 35 A0          5
                    fcb       $ED                 * 0198 ED             m
                    fcb       $43                 * 0199 43             C
                    fcb       $86                 * 019A 86             .
                    fcb       $30                 * 019B 30             0
                    fcb       $A7                 * 019C A7             '
                    fcb       $84                 * 019D 84             .
                    fcb       $A7                 * 019E A7             '
                    fcb       $01                 * 019F 01             .
                    fcb       $A7                 * 01A0 A7             '
                    fcb       $02                 * 01A1 02             .
                    fcb       $A7                 * 01A2 A7             '
                    fcb       $03                 * 01A3 03             .
                    fcb       $A7                 * 01A4 A7             '
                    fcb       $04                 * 01A5 04             .
                    fcb       $CC                 * 01A6 CC             L
                    fcb       $27                 * 01A7 27             '
                    fcb       $10                 * 01A8 10             .
                    fcb       $ED                 * 01A9 ED             m
                    fcb       $47                 * 01AA 47             G
                    fcb       $EC                 * 01AB EC             l
                    fcb       $43                 * 01AC 43             C
                    fcb       $17                 * 01AD 17             .
                    fcb       $00                 * 01AE 00             .
                    fcb       $29                 * 01AF 29             )
                    fcb       $CC                 * 01B0 CC             L
                    fcb       $03                 * 01B1 03             .
                    fcb       $E8                 * 01B2 E8             h
                    fcb       $ED                 * 01B3 ED             m
                    fcb       $47                 * 01B4 47             G
                    fcb       $EC                 * 01B5 EC             l
                    fcb       $43                 * 01B6 43             C
                    fcb       $8D                 * 01B7 8D             .
                    fcb       $20                 * 01B8 20
                    fcb       $CC                 * 01B9 CC             L
                    fcb       $00                 * 01BA 00             .
                    fcb       $64                 * 01BB 64             d
                    fcb       $ED                 * 01BC ED             m
                    fcb       $47                 * 01BD 47             G
                    fcb       $EC                 * 01BE EC             l
                    fcb       $43                 * 01BF 43             C
                    fcb       $8D                 * 01C0 8D             .
                    fcb       $17                 * 01C1 17             .
                    fcb       $CC                 * 01C2 CC             L
                    fcb       $00                 * 01C3 00             .
                    fcb       $0A                 * 01C4 0A             .
                    fcb       $ED                 * 01C5 ED             m
                    fcb       $47                 * 01C6 47             G
                    fcb       $EC                 * 01C7 EC             l
                    fcb       $43                 * 01C8 43             C
                    fcb       $8D                 * 01C9 8D             .
                    fcb       $0E                 * 01CA 0E             .
                    fcb       $CC                 * 01CB CC             L
                    fcb       $00                 * 01CC 00             .
                    fcb       $01                 * 01CD 01             .
                    fcb       $ED                 * 01CE ED             m
                    fcb       $47                 * 01CF 47             G
                    fcb       $EC                 * 01D0 EC             l
                    fcb       $43                 * 01D1 43             C
                    fcb       $8D                 * 01D2 8D             .
                    fcb       $05                 * 01D3 05             .
                    fcb       $86                 * 01D4 86             .
                    fcb       $0D                 * 01D5 0D             .
                    fcb       $A7                 * 01D6 A7             '
                    fcb       $84                 * 01D7 84             .
                    fcb       $39                 * 01D8 39             9
                    fcb       $A3                 * 01D9 A3             #
                    fcb       $47                 * 01DA 47             G
                    fcb       $25                 * 01DB 25             %
                    fcb       $04                 * 01DC 04             .
                    fcb       $6C                 * 01DD 6C             l
                    fcb       $84                 * 01DE 84             .
                    fcb       $20                 * 01DF 20
                    fcb       $F8                 * 01E0 F8             x
                    fcb       $E3                 * 01E1 E3             c
                    fcb       $47                 * 01E2 47             G
                    fcb       $ED                 * 01E3 ED             m
                    fcb       $43                 * 01E4 43             C
                    fcb       $30                 * 01E5 30             0
                    fcb       $01                 * 01E6 01             .
                    fcb       $39                 * 01E7 39             9
L01E8               ldd       #0                  * 01E8 CC 00 00       L..
                    rts                           * 01EB 39             9

                    emod
eom                 equ       *
                    end
