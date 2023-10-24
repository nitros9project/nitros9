                    nam       Quikterm
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
U0004               rmb       2
U0006               rmb       2
U0008               rmb       2
U000A               rmb       1
U000B               rmb       2
U000D               rmb       343
U0164               rmb       2
U0166               rmb       58
U01A0               rmb       1
U01A1               rmb       3
U01A4               rmb       2
U01A6               rmb       1250
size                equ       .

name                fcs       /Quikterm/          * 000D 51 75 69 6B 74 65 72 ED Quikterm
                    fcb       $01                 * 0015 01             .
L0016               lda       ,Y+                 * 0016 A6 A0          &
                    sta       ,U+                 * 0018 A7 C0          '@
                    leax      -$01,X              * 001A 30 1F          0.
                    bne       L0016               * 001C 26 F8          &x
                    rts                           * 001E 39             9
start               pshs      Y                   * 001F 34 20          4
                    pshs      U                   * 0021 34 40          4@
                    clra                          * 0023 4F             O
                    clrb                          * 0024 5F             _
L0025               sta       ,U+                 * 0025 A7 C0          '@
                    decb                          * 0027 5A             Z
                    bne       L0025               * 0028 26 FB          &{
                    ldx       0,S                 * 002A AE E4          .d
                    leau      0,X                 * 002C 33 84          3.
                    leax      >$0308,X            * 002E 30 89 03 08    0...
                    pshs      X                   * 0032 34 10          4.
                    leay      >L21E0,PC           * 0034 31 8D 21 A8    1.!(
                    ldx       ,Y++                * 0038 AE A1          .!
                    beq       L0040               * 003A 27 04          '.
                    bsr       L0016               * 003C 8D D8          .X
                    ldu       $02,S               * 003E EE 62          nb
L0040               leau      >U0001,U            * 0040 33 C9 00 01    3I..
                    ldx       ,Y++                * 0044 AE A1          .!
                    beq       L004B               * 0046 27 03          '.
                    bsr       L0016               * 0048 8D CC          .L
                    clra                          * 004A 4F             O
L004B               cmpu      0,S                 * 004B 11 A3 E4       .#d
                    beq       L0054               * 004E 27 04          '.
                    sta       ,U+                 * 0050 A7 C0          '@
                    bra       L004B               * 0052 20 F7           w
L0054               ldu       $02,S               * 0054 EE 62          nb
                    ldd       ,Y++                * 0056 EC A1          l!
                    beq       L0061               * 0058 27 07          '.
                    leax      >,PC                * 005A 30 8D FF A2    0.."
                    lbsr      L0164               * 005E 17 01 03       ...
L0061               ldd       ,Y++                * 0061 EC A1          l!
                    beq       L006A               * 0063 27 05          '.
                    leax      U0000,U             * 0065 30 C4          0D
                    lbsr      L0164               * 0067 17 00 FA       ..z
L006A               leas      $04,S               * 006A 32 64          2d
                    puls      X                   * 006C 35 10          5.
                    stx       >U01A4,U            * 006E AF C9 01 A4    /I.$
                    sty       >U0164,U            * 0072 10 AF C9 01 64 ./I.d
                    ldd       #1                  * 0077 CC 00 01       L..
                    std       >U01A0,U            * 007A ED C9 01 A0    mI.
                    leay      >U0166,U            * 007E 31 C9 01 66    1I.f
                    leax      0,S                 * 0082 30 E4          0d
                    lda       ,X+                 * 0084 A6 80          &.
L0086               ldb       >U01A1,U            * 0086 E6 C9 01 A1    fI.!
                    cmpb      #29                 * 008A C1 1D          A.
                    beq       L00E2               * 008C 27 54          'T
L008E               cmpa      #13                 * 008E 81 0D          ..
                    beq       L00E2               * 0090 27 50          'P
                    cmpa      #32                 * 0092 81 20          .
                    beq       L009A               * 0094 27 04          '.
                    cmpa      #44                 * 0096 81 2C          .,
                    bne       L009E               * 0098 26 04          &.
L009A               lda       ,X+                 * 009A A6 80          &.
                    bra       L008E               * 009C 20 F0           p
L009E               cmpa      #34                 * 009E 81 22          ."
                    beq       L00A6               * 00A0 27 04          '.
                    cmpa      #39                 * 00A2 81 27          .'
                    bne       L00C4               * 00A4 26 1E          &.
L00A6               stx       ,Y++                * 00A6 AF A1          /!
                    inc       >U01A1,U            * 00A8 6C C9 01 A1    lI.!
                    pshs      A                   * 00AC 34 02          4.
L00AE               lda       ,X+                 * 00AE A6 80          &.
                    cmpa      #13                 * 00B0 81 0D          ..
                    beq       L00B8               * 00B2 27 04          '.
                    cmpa      0,S                 * 00B4 A1 E4          !d
                    bne       L00AE               * 00B6 26 F6          &v
L00B8               puls      B                   * 00B8 35 04          5.
                    clr       -$01,X              * 00BA 6F 1F          o.
                    cmpa      #13                 * 00BC 81 0D          ..
                    beq       L00E2               * 00BE 27 22          '"
                    lda       ,X+                 * 00C0 A6 80          &.
                    bra       L0086               * 00C2 20 C2           B
L00C4               leax      -$01,X              * 00C4 30 1F          0.
                    stx       ,Y++                * 00C6 AF A1          /!
                    leax      $01,X               * 00C8 30 01          0.
                    inc       >U01A1,U            * 00CA 6C C9 01 A1    lI.!
L00CE               cmpa      #13                 * 00CE 81 0D          ..
                    beq       L00DE               * 00D0 27 0C          '.
                    cmpa      #32                 * 00D2 81 20          .
                    beq       L00DE               * 00D4 27 08          '.
                    cmpa      #44                 * 00D6 81 2C          .,
                    beq       L00DE               * 00D8 27 04          '.
                    lda       ,X+                 * 00DA A6 80          &.
                    bra       L00CE               * 00DC 20 F0           p
L00DE               clr       -$01,X              * 00DE 6F 1F          o.
                    bra       L0086               * 00E0 20 A4           $
L00E2               leax      >U0164,U            * 00E2 30 C9 01 64    0I.d
                    pshs      X                   * 00E6 34 10          4.
                    ldd       >U01A0,U            * 00E8 EC C9 01 A0    lI.
                    pshs      D                   * 00EC 34 06          4.
                    leay      U0000,U             * 00EE 31 C4          1D
                    bsr       L00FC               * 00F0 8D 0A          ..
                    lbsr      L022F               * 00F2 17 01 3A       ..:
                    clr       ,-S                 * 00F5 6F E2          ob
                    clr       ,-S                 * 00F7 6F E2          ob
                    lbsr      L2127               * 00F9 17 20 2B       . +
L00FC               leax      >$0308,Y            * 00FC 30 A9 03 08    0)..
                    stx       >$01AE,Y            * 0100 AF A9 01 AE    /)..
                    sts       >$01A2,Y            * 0104 10 EF A9 01 A2 .o)."
                    sts       >$01B0,Y            * 0109 10 EF A9 01 B0 .o).0
                    ldd       #-126               * 010E CC FF 82       L..
L0111               leax      D,S                 * 0111 30 EB          0k
                    cmpx      >$01B0,Y            * 0113 AC A9 01 B0    ,).0
                    bcc       L0123               * 0117 24 0A          $.
                    cmpx      >$01AE,Y            * 0119 AC A9 01 AE    ,)..
                    bcs       L013D               * 011D 25 1E          %.
                    stx       >$01B0,Y            * 011F AF A9 01 B0    /).0
L0123               rts                           * 0123 39             9
L0124               fcc       "**** STACK OVERFLOW ****" * 0124 2A 2A 2A 2A 20 53 54 41 43 4B 20 4F 56 45 52 46 4C 4F 57 20 2A 2A 2A 2A **** STACK OVERFLOW ****
                    fcb       $0D                 * 013C 0D             .
L013D               leax      <L0124,PC           * 013D 30 8C E4       0.d
                    ldb       #207                * 0140 C6 CF          FO
                    pshs      B                   * 0142 34 04          4.
                    lda       #2                  * 0144 86 02          ..
                    ldy       #100                * 0146 10 8E 00 64    ...d
                    os9       I$WritLn            * 014A 10 3F 8C       .?.
                    clr       ,-S                 * 014D 6F E2          ob
                    lbsr      L212D               * 014F 17 1F DB       ..[
                    ldd       >$01A2,Y            * 0152 EC A9 01 A2    l)."
                    subd      >$01B0,Y            * 0156 A3 A9 01 B0    #).0
                    rts                           * 015A 39             9
                    fcb       $EC                 * 015B EC             l
                    fcb       $A9                 * 015C A9             )
                    fcb       $01                 * 015D 01             .
                    fcb       $B0                 * 015E B0             0
                    fcb       $A3                 * 015F A3             #
                    fcb       $A9                 * 0160 A9             )
                    fcb       $01                 * 0161 01             .
                    fcb       $AE                 * 0162 AE             .
                    fcb       $39                 * 0163 39             9
L0164               pshs      X                   * 0164 34 10          4.
                    leax      D,Y                 * 0166 30 AB          0+
                    leax      D,X                 * 0168 30 8B          0.
                    pshs      X                   * 016A 34 10          4.
L016C               ldd       ,Y++                * 016C EC A1          l!
                    leax      D,U                 * 016E 30 CB          0K
                    ldd       0,X                 * 0170 EC 84          l.
                    addd      $02,S               * 0172 E3 62          cb
                    std       0,X                 * 0174 ED 84          m.
                    cmpy      0,S                 * 0176 10 AC E4       .,d
                    bne       L016C               * 0179 26 F1          &q
                    leas      $04,S               * 017B 32 64          2d
                    rts                           * 017D 39             9
L017E               fcb       $34                 * 017E 34             4
                    fcb       $40                 * 017F 40             @
                    fcb       $CC                 * 0180 CC             L
                    fcb       $FF                 * 0181 FF             .
                    fcb       $B0                 * 0182 B0             0
                    fcb       $17                 * 0183 17             .
                    fcb       $FF                 * 0184 FF             .
                    fcb       $8B                 * 0185 8B             .
                    fcb       $32                 * 0186 32             2
                    fcb       $7A                 * 0187 7A             z
                    fcb       $AE                 * 0188 AE             .
                    fcb       $6A                 * 0189 6A             j
                    fcb       $16                 * 018A 16             .
                    fcb       $00                 * 018B 00             .
                    fcb       $94                 * 018C 94             .
                    fcb       $EC                 * 018D EC             l
                    fcb       $A9                 * 018E A9             )
                    fcb       $01                 * 018F 01             .
                    fcb       $B6                 * 0190 B6             6
                    fcb       $34                 * 0191 34             4
                    fcb       $06                 * 0192 06             .
                    fcb       $17                 * 0193 17             .
                    fcb       $1F                 * 0194 1F             .
                    fcb       $9D                 * 0195 9D             .
                    fcb       $32                 * 0196 32             2
                    fcb       $62                 * 0197 62             b
                    fcb       $ED                 * 0198 ED             m
                    fcb       $64                 * 0199 64             d
                    fcb       $34                 * 019A 34             4
                    fcb       $06                 * 019B 06             .
                    fcb       $30                 * 019C 30             0
                    fcb       $A9                 * 019D A9             )
                    fcb       $01                 * 019E 01             .
                    fcb       $DA                 * 019F DA             Z
                    fcb       $34                 * 01A0 34             4
                    fcb       $10                 * 01A1 10             .
                    fcb       $EC                 * 01A2 EC             l
                    fcb       $A9                 * 01A3 A9             )
                    fcb       $01                 * 01A4 01             .
                    fcb       $B6                 * 01A5 B6             6
                    fcb       $34                 * 01A6 34             4
                    fcb       $06                 * 01A7 06             .
                    fcb       $17                 * 01A8 17             .
                    fcb       $1D                 * 01A9 1D             .
                    fcb       $D5                 * 01AA D5             U
                    fcb       $32                 * 01AB 32             2
                    fcb       $66                 * 01AC 66             f
                    fcb       $EC                 * 01AD EC             l
                    fcb       $64                 * 01AE 64             d
                    fcb       $34                 * 01AF 34             4
                    fcb       $06                 * 01B0 06             .
                    fcb       $30                 * 01B1 30             0
                    fcb       $A9                 * 01B2 A9             )
                    fcb       $01                 * 01B3 01             .
                    fcb       $DA                 * 01B4 DA             Z
                    fcb       $34                 * 01B5 34             4
                    fcb       $10                 * 01B6 10             .
                    fcb       $EC                 * 01B7 EC             l
                    fcb       $A9                 * 01B8 A9             )
                    fcb       $01                 * 01B9 01             .
                    fcb       $B4                 * 01BA B4             4
                    fcb       $34                 * 01BB 34             4
                    fcb       $06                 * 01BC 06             .
                    fcb       $17                 * 01BD 17             .
                    fcb       $1D                 * 01BE 1D             .
                    fcb       $F1                 * 01BF F1             q
                    fcb       $32                 * 01C0 32             2
                    fcb       $66                 * 01C1 66             f
                    fcb       $16                 * 01C2 16             .
                    fcb       $00                 * 01C3 00             .
                    fcb       $66                 * 01C4 66             f
                    fcb       $EC                 * 01C5 EC             l
                    fcb       $A9                 * 01C6 A9             )
                    fcb       $01                 * 01C7 01             .
                    fcb       $B6                 * 01C8 B6             6
                    fcb       $34                 * 01C9 34             4
                    fcb       $06                 * 01CA 06             .
                    fcb       $17                 * 01CB 17             .
                    fcb       $1D                 * 01CC 1D             .
                    fcc       "E2b0"              * 01CD 45 32 62 30    E2b0
                    fcb       $A9                 * 01D1 A9             )
                    fcb       $01                 * 01D2 01             .
                    fcb       $B8                 * 01D3 B8             8
                    fcb       $34                 * 01D4 34             4
                    fcb       $10                 * 01D5 10             .
                    fcb       $EC                 * 01D6 EC             l
                    fcb       $A9                 * 01D7 A9             )
                    fcb       $01                 * 01D8 01             .
                    fcb       $B4                 * 01D9 B4             4
                    fcb       $34                 * 01DA 34             4
                    fcb       $06                 * 01DB 06             .
                    fcc       "O_4"               * 01DC 4F 5F 34       O_4
                    fcb       $06                 * 01DF 06             .
                    fcb       $17                 * 01E0 17             .
                    fcb       $1C                 * 01E1 1C             .
                    fcb       $B2                 * 01E2 B2             2
                    fcb       $32                 * 01E3 32             2
                    fcb       $66                 * 01E4 66             f
                    fcb       $CC                 * 01E5 CC             L
                    fcb       $00                 * 01E6 00             .
                    fcb       $01                 * 01E7 01             .
                    fcb       $E7                 * 01E8 E7             g
                    fcb       $A9                 * 01E9 A9             )
                    fcb       $01                 * 01EA 01             .
                    fcb       $BC                 * 01EB BC             <
                    fcb       $CC                 * 01EC CC             L
                    fcb       $00                 * 01ED 00             .
                    fcb       $03                 * 01EE 03             .
                    fcb       $E7                 * 01EF E7             g
                    fcb       $A9                 * 01F0 A9             )
                    fcb       $01                 * 01F1 01             .
                    fcb       $C8                 * 01F2 C8             H
                    fcb       $CC                 * 01F3 CC             L
                    fcb       $00                 * 01F4 00             .
                    fcb       $05                 * 01F5 05             .
                    fcb       $E7                 * 01F6 E7             g
                    fcb       $A9                 * 01F7 A9             )
                    fcb       $01                 * 01F8 01             .
                    fcb       $C9                 * 01F9 C9             I
                    fcb       $CC                 * 01FA CC             L
                    fcb       $00                 * 01FB 00             .
                    fcb       $0D                 * 01FC 0D             .
                    fcb       $E7                 * 01FD E7             g
                    fcb       $A9                 * 01FE A9             )
                    fcb       $01                 * 01FF 01             .
                    fcb       $C3                 * 0200 C3             C
                    fcb       $30                 * 0201 30             0
                    fcb       $A9                 * 0202 A9             )
                    fcb       $01                 * 0203 01             .
                    fcb       $B8                 * 0204 B8             8
                    fcb       $34                 * 0205 34             4
                    fcb       $10                 * 0206 10             .
                    fcb       $EC                 * 0207 EC             l
                    fcb       $A9                 * 0208 A9             )
                    fcb       $01                 * 0209 01             .
                    fcb       $B4                 * 020A B4             4
                    fcb       $34                 * 020B 34             4
                    fcb       $06                 * 020C 06             .
                    fcc       "O_4"               * 020D 4F 5F 34       O_4
                    fcb       $06                 * 0210 06             .
                    fcb       $17                 * 0211 17             .
                    fcb       $1C                 * 0212 1C             .
                    fcb       $BC                 * 0213 BC             <
                    fcb       $32                 * 0214 32             2
                    fcb       $66                 * 0215 66             f
                    fcb       $EC                 * 0216 EC             l
                    fcb       $6A                 * 0217 6A             j
                    fcb       $34                 * 0218 34             4
                    fcb       $06                 * 0219 06             .
                    fcb       $17                 * 021A 17             .
                    fcb       $1F                 * 021B 1F             .
                    fcb       $0A                 * 021C 0A             .
                    fcc       "2b "               * 021D 32 62 20       2b
                    fcb       $0A                 * 0220 0A             .
                    fcb       $8C                 * 0221 8C             .
                    fcb       $00                 * 0222 00             .
                    fcb       $0A                 * 0223 0A             .
                    fcb       $10                 * 0224 10             .
                    fcb       $27                 * 0225 27             '
                    fcb       $FF                 * 0226 FF             .
                    fcb       $65                 * 0227 65             e
                    fcb       $16                 * 0228 16             .
                    fcb       $FF                 * 0229 FF             .
                    fcb       $9A                 * 022A 9A             .
                    fcc       "2f5"               * 022B 32 66 35       2f5
                    fcb       $C0                 * 022E C0             @
L022F               pshs      U                   * 022F 34 40          4@
                    ldd       #-75                * 0231 CC FF B5       L.5
                    lbsr      L0111               * 0234 17 FE DA       .~Z
                    leas      -$01,S              * 0237 32 7F          2.
                    clra                          * 0239 4F             O
                    clrb                          * 023A 5F             _
                    std       >$01B4,Y            * 023B ED A9 01 B4    m).4
                    ldd       $05,S               * 023F EC 65          le
                    cmpd      #1                  * 0241 10 83 00 01    ....
                    bne       L0274               * 0245 26 2D          &-
                    ldd       #3                  * 0247 CC 00 03       L..
                    pshs      D                   * 024A 34 06          4.
                    leax      >L0F04,PC           * 024C 30 8D 0C B4    0..4
                    pshs      X                   * 0250 34 10          4.
                    lbsr      L1F04               * 0252 17 1C AF       ../
                    leas      $04,S               * 0255 32 64          2d
                    std       >$01B6,Y            * 0257 ED A9 01 B6    m).6
                    cmpd      #-1                 * 025B 10 83 FF FF    ....
                    bne       L02AA               * 025F 26 49          &I
                    ldd       >$01B2,Y            * 0261 EC A9 01 B2    l).2
                    pshs      D                   * 0265 34 06          4.
                    leax      >L0F08,PC           * 0267 30 8D 0C 9D    0...
                    pshs      X                   * 026B 34 10          4.
                    lbsr      L0E44               * 026D 17 0B D4       ..T
                    leas      $04,S               * 0270 32 64          2d
                    bra       L02AA               * 0272 20 36           6
L0274               ldd       #3                  * 0274 CC 00 03       L..
                    pshs      D                   * 0277 34 06          4.
                    ldx       $09,S               * 0279 AE 69          .i
                    ldd       $02,X               * 027B EC 02          l.
                    pshs      D                   * 027D 34 06          4.
                    lbsr      L1F04               * 027F 17 1C 82       ...
                    leas      $04,S               * 0282 32 64          2d
                    std       >$01B6,Y            * 0284 ED A9 01 B6    m).6
                    cmpd      #-1                 * 0288 10 83 FF FF    ....
                    bne       L02AA               * 028C 26 1C          &.
                    ldx       $07,S               * 028E AE 67          .g
                    ldd       $02,X               * 0290 EC 02          l.
                    pshs      D                   * 0292 34 06          4.
                    leax      >L0F18,PC           * 0294 30 8D 0C 80    0...
                    pshs      X                   * 0298 34 10          4.
                    lbsr      L1440               * 029A 17 11 A3       ..#
                    leas      $04,S               * 029D 32 64          2d
                    ldd       >$01B2,Y            * 029F EC A9 01 B2    l).2
                    pshs      D                   * 02A3 34 06          4.
                    lbsr      L2127               * 02A5 17 1E 7F       ...
                    leas      $02,S               * 02A8 32 62          2b
L02AA               leax      >$01B8,Y            * 02AA 30 A9 01 B8    0).8
                    pshs      X                   * 02AE 34 10          4.
                    ldd       >$01B4,Y            * 02B0 EC A9 01 B4    l).4
                    pshs      D                   * 02B4 34 06          4.
                    clra                          * 02B6 4F             O
                    clrb                          * 02B7 5F             _
                    pshs      D                   * 02B8 34 06          4.
                    lbsr      L1E95               * 02BA 17 1B D8       ..X
                    leas      $06,S               * 02BD 32 66          2f
                    clra                          * 02BF 4F             O
                    clrb                          * 02C0 5F             _
                    stb       >$01BC,Y            * 02C1 E7 A9 01 BC    g).<
                    clra                          * 02C5 4F             O
                    clrb                          * 02C6 5F             _
                    stb       >$01C9,Y            * 02C7 E7 A9 01 C9    g).I
                    clra                          * 02CB 4F             O
                    clrb                          * 02CC 5F             _
                    stb       >$01C8,Y            * 02CD E7 A9 01 C8    g).H
                    clra                          * 02D1 4F             O
                    clrb                          * 02D2 5F             _
                    stb       >$01C3,Y            * 02D3 E7 A9 01 C3    g).C
                    leax      >$01B8,Y            * 02D7 30 A9 01 B8    0).8
                    pshs      X                   * 02DB 34 10          4.
                    ldd       >$01B4,Y            * 02DD EC A9 01 B4    l).4
                    pshs      D                   * 02E1 34 06          4.
                    clra                          * 02E3 4F             O
                    clrb                          * 02E4 5F             _
                    pshs      D                   * 02E5 34 06          4.
                    lbsr      L1ED0               * 02E7 17 1B E6       ..f
                    leas      $06,S               * 02EA 32 66          2f
                    leax      >$01B8,Y            * 02EC 30 A9 01 B8    0).8
                    pshs      X                   * 02F0 34 10          4.
                    ldd       >$01B6,Y            * 02F2 EC A9 01 B6    l).6
                    pshs      D                   * 02F6 34 06          4.
                    clra                          * 02F8 4F             O
                    clrb                          * 02F9 5F             _
                    pshs      D                   * 02FA 34 06          4.
                    lbsr      L1E95               * 02FC 17 1B 96       ...
                    leas      $06,S               * 02FF 32 66          2f
                    clra                          * 0301 4F             O
                    clrb                          * 0302 5F             _
                    stb       >$01B9,Y            * 0303 E7 A9 01 B9    g).9
                    clra                          * 0307 4F             O
                    clrb                          * 0308 5F             _
                    stb       >$01BA,Y            * 0309 E7 A9 01 BA    g).:
                    clra                          * 030D 4F             O
                    clrb                          * 030E 5F             _
                    stb       >$01BB,Y            * 030F E7 A9 01 BB    g).;
                    clra                          * 0313 4F             O
                    clrb                          * 0314 5F             _
                    stb       >$01BC,Y            * 0315 E7 A9 01 BC    g).<
                    clra                          * 0319 4F             O
                    clrb                          * 031A 5F             _
                    stb       >$01BD,Y            * 031B E7 A9 01 BD    g).=
                    clra                          * 031F 4F             O
                    clrb                          * 0320 5F             _
                    stb       >$01BE,Y            * 0321 E7 A9 01 BE    g).>
                    clra                          * 0325 4F             O
                    clrb                          * 0326 5F             _
                    stb       >$01BF,Y            * 0327 E7 A9 01 BF    g).?
                    clra                          * 032B 4F             O
                    clrb                          * 032C 5F             _
                    stb       >$01C0,Y            * 032D E7 A9 01 C0    g).@
                    clra                          * 0331 4F             O
                    clrb                          * 0332 5F             _
                    stb       >$01C1,Y            * 0333 E7 A9 01 C1    g).A
                    clra                          * 0337 4F             O
                    clrb                          * 0338 5F             _
                    stb       >$01C2,Y            * 0339 E7 A9 01 C2    g).B
                    clra                          * 033D 4F             O
                    clrb                          * 033E 5F             _
                    stb       >$01C3,Y            * 033F E7 A9 01 C3    g).C
                    clra                          * 0343 4F             O
                    clrb                          * 0344 5F             _
                    stb       >$01C4,Y            * 0345 E7 A9 01 C4    g).D
                    clra                          * 0349 4F             O
                    clrb                          * 034A 5F             _
                    stb       >$01C5,Y            * 034B E7 A9 01 C5    g).E
                    clra                          * 034F 4F             O
                    clrb                          * 0350 5F             _
                    stb       >$01C6,Y            * 0351 E7 A9 01 C6    g).F
                    clra                          * 0355 4F             O
                    clrb                          * 0356 5F             _
                    stb       >$01C7,Y            * 0357 E7 A9 01 C7    g).G
                    clra                          * 035B 4F             O
                    clrb                          * 035C 5F             _
                    stb       >$01C8,Y            * 035D E7 A9 01 C8    g).H
                    clra                          * 0361 4F             O
                    clrb                          * 0362 5F             _
                    stb       >$01C9,Y            * 0363 E7 A9 01 C9    g).I
                    clra                          * 0367 4F             O
                    clrb                          * 0368 5F             _
                    stb       >$01CA,Y            * 0369 E7 A9 01 CA    g).J
                    clra                          * 036D 4F             O
                    clrb                          * 036E 5F             _
                    stb       >$01CB,Y            * 036F E7 A9 01 CB    g).K
                    clra                          * 0373 4F             O
                    clrb                          * 0374 5F             _
                    stb       >$01CC,Y            * 0375 E7 A9 01 CC    g).L
                    leax      >$01B8,Y            * 0379 30 A9 01 B8    0).8
                    pshs      X                   * 037D 34 10          4.
                    ldd       >$01B6,Y            * 037F EC A9 01 B6    l).6
                    pshs      D                   * 0383 34 06          4.
                    clra                          * 0385 4F             O
                    clrb                          * 0386 5F             _
                    pshs      D                   * 0387 34 06          4.
                    lbsr      L1ED0               * 0389 17 1B 44       ..D
                    leas      $06,S               * 038C 32 66          2f
                    leax      >L017E,PC           * 038E 30 8D FD EC    0.}l
                    pshs      X                   * 0392 34 10          4.
                    lbsr      L20F7               * 0394 17 1D 60       ..`
                    leas      $02,S               * 0397 32 62          2b
                    clra                          * 0399 4F             O
                    clrb                          * 039A 5F             _
                    pshs      D                   * 039B 34 06          4.
                    lbsr      L2184               * 039D 17 1D E4       ..d
                    leas      $02,S               * 03A0 32 62          2b
                    clra                          * 03A2 4F             O
                    clrb                          * 03A3 5F             _
                    pshs      D                   * 03A4 34 06          4.
                    lbsr      L2193               * 03A6 17 1D EA       ..j
                    leas      $02,S               * 03A9 32 62          2b
                    leax      >L0F28,PC           * 03AB 30 8D 0B 79    0..y
                    pshs      X                   * 03AF 34 10          4.
                    lbsr      L1440               * 03B1 17 10 8C       ...
                    leas      $02,S               * 03B4 32 62          2b
                    leax      >L0F48,PC           * 03B6 30 8D 0B 8E    0...
                    pshs      X                   * 03BA 34 10          4.
                    lbsr      L1440               * 03BC 17 10 81       ...
                    leas      $02,S               * 03BF 32 62          2b
                    leax      >L0F68,PC           * 03C1 30 8D 0B A3    0..#
                    pshs      X                   * 03C5 34 10          4.
                    lbsr      L1440               * 03C7 17 10 76       ..v
                    leas      $02,S               * 03CA 32 62          2b
                    clra                          * 03CC 4F             O
                    clrb                          * 03CD 5F             _
                    pshs      D                   * 03CE 34 06          4.
                    lbsr      L2198               * 03D0 17 1D C5       ..E
                    leas      $02,S               * 03D3 32 62          2b
                    leax      >L0F88,PC           * 03D5 30 8D 0B AF    0../
                    pshs      X                   * 03D9 34 10          4.
                    lbsr      L1440               * 03DB 17 10 62       ..b
                    leas      $02,S               * 03DE 32 62          2b
                    leax      >L0F8A,PC           * 03E0 30 8D 0B A6    0..&
                    pshs      X                   * 03E4 34 10          4.
                    lbsr      L1440               * 03E6 17 10 57       ..W
                    leas      $02,S               * 03E9 32 62          2b
                    leax      >L0FC6,PC           * 03EB 30 8D 0B D7    0..W
                    pshs      X                   * 03EF 34 10          4.
                    lbsr      L1440               * 03F1 17 10 4C       ..L
                    lbra      L0455               * 03F4 16 00 5E       ..^
L03F7               ldd       #10                 * 03F7 CC 00 0A       L..
                    pshs      D                   * 03FA 34 06          4.
                    ldd       >$01B6,Y            * 03FC EC A9 01 B6    l).6
                    pshs      D                   * 0400 34 06          4.
                    lbsr      L2140               * 0402 17 1D 3B       ..;
                    leas      $04,S               * 0405 32 64          2d
                    ldd       >$01B4,Y            * 0407 EC A9 01 B4    l).4
                    pshs      D                   * 040B 34 06          4.
                    lbsr      L2133               * 040D 17 1D 23       ..#
                    leas      $02,S               * 0410 32 62          2b
                    cmpd      #-1                 * 0412 10 83 FF FF    ....
                    beq       L044D               * 0416 27 35          '5
                    ldd       #1                  * 0418 CC 00 01       L..
                    pshs      D                   * 041B 34 06          4.
                    leax      $02,S               * 041D 30 62          0b
                    pshs      X                   * 041F 34 10          4.
                    ldd       >$01B4,Y            * 0421 EC A9 01 B4    l).4
                    pshs      D                   * 0425 34 06          4.
                    lbsr      L1F80               * 0427 17 1B 56       ..V
                    leas      $06,S               * 042A 32 66          2f
                    ldb       0,S                 * 042C E6 E4          fd
                    sex                           * 042E 1D             .
                    pshs      D                   * 042F 34 06          4.
                    bsr       L045A               * 0431 8D 27          .'
                    std       ,S++                * 0433 ED E1          ma
                    beq       L044B               * 0435 27 14          '.
                    ldd       #1                  * 0437 CC 00 01       L..
                    pshs      D                   * 043A 34 06          4.
                    leax      $02,S               * 043C 30 62          0b
                    pshs      X                   * 043E 34 10          4.
                    ldd       >$01B6,Y            * 0440 EC A9 01 B6    l).6
                    pshs      D                   * 0444 34 06          4.
                    lbsr      L1FB1               * 0446 17 1B 68       ..h
                    leas      $06,S               * 0449 32 66          2f
L044B               bra       L03F7               * 044B 20 AA           *
L044D               ldd       #1                  * 044D CC 00 01       L..
                    pshs      D                   * 0450 34 06          4.
                    lbsr      L2067               * 0452 17 1C 12       ...
L0455               leas      $02,S               * 0455 32 62          2b
                    lbra      L03F7               * 0457 16 FF 9D       ...
L045A               pshs      U                   * 045A 34 40          4@
                    ldd       #-74                * 045C CC FF B6       L.6
                    lbsr      L0111               * 045F 17 FC AF       .|/
                    ldb       $05,S               * 0462 E6 65          fe
                    sex                           * 0464 1D             .
                    tfr       D,X                 * 0465 1F 01          ..
                    lbra      L051C               * 0467 16 00 B2       ..2
L046A               ldd       >$01B6,Y            * 046A EC A9 01 B6    l).6
                    pshs      D                   * 046E 34 06          4.
                    lbsr      L1F13               * 0470 17 1A A0       ..
                    leas      $02,S               * 0473 32 62          2b
                    leax      >$01B8,Y            * 0475 30 A9 01 B8    0).8
                    pshs      X                   * 0479 34 10          4.
                    ldd       >$01B4,Y            * 047B EC A9 01 B4    l).4
                    pshs      D                   * 047F 34 06          4.
                    clra                          * 0481 4F             O
                    clrb                          * 0482 5F             _
                    pshs      D                   * 0483 34 06          4.
                    lbsr      L1E95               * 0485 17 1A 0D       ...
                    leas      $06,S               * 0488 32 66          2f
                    ldd       #1                  * 048A CC 00 01       L..
                    stb       >$01BC,Y            * 048D E7 A9 01 BC    g).<
                    ldd       #3                  * 0491 CC 00 03       L..
                    stb       >$01C8,Y            * 0494 E7 A9 01 C8    g).H
                    ldd       #5                  * 0498 CC 00 05       L..
                    stb       >$01C9,Y            * 049B E7 A9 01 C9    g).I
                    ldd       #13                 * 049F CC 00 0D       L..
                    stb       >$01C3,Y            * 04A2 E7 A9 01 C3    g).C
                    leax      >$01B8,Y            * 04A6 30 A9 01 B8    0).8
                    pshs      X                   * 04AA 34 10          4.
                    ldd       >$01B4,Y            * 04AC EC A9 01 B4    l).4
                    pshs      D                   * 04B0 34 06          4.
                    clra                          * 04B2 4F             O
                    clrb                          * 04B3 5F             _
                    pshs      D                   * 04B4 34 06          4.
                    lbsr      L1ED0               * 04B6 17 1A 17       ...
                    leas      $06,S               * 04B9 32 66          2f
                    clra                          * 04BB 4F             O
                    clrb                          * 04BC 5F             _
                    pshs      D                   * 04BD 34 06          4.
                    lbsr      L2184               * 04BF 17 1C C2       ..B
                    leas      $02,S               * 04C2 32 62          2b
                    leax      >L1008,PC           * 04C4 30 8D 0B 40    0..@
                    pshs      X                   * 04C8 34 10          4.
                    lbsr      L1440               * 04CA 17 0F 73       ..s
                    leas      $02,S               * 04CD 32 62          2b
                    leax      >L1020,PC           * 04CF 30 8D 0B 4D    0..M
                    pshs      X                   * 04D3 34 10          4.
                    lbsr      L1440               * 04D5 17 0F 68       ..h
                    leas      $02,S               * 04D8 32 62          2b
                    leax      >L1046,PC           * 04DA 30 8D 0B 68    0..h
                    pshs      X                   * 04DE 34 10          4.
                    lbsr      L1440               * 04E0 17 0F 5D       ..]
                    leas      $02,S               * 04E3 32 62          2b
                    leax      >L1064,PC           * 04E5 30 8D 0B 7B    0..{
                    pshs      X                   * 04E9 34 10          4.
                    lbsr      L1440               * 04EB 17 0F 52       ..R
                    leas      $02,S               * 04EE 32 62          2b
                    leax      >L1075,PC           * 04F0 30 8D 0B 81    0...
                    pshs      X                   * 04F4 34 10          4.
                    lbsr      L1440               * 04F6 17 0F 47       ..G
                    leas      $02,S               * 04F9 32 62          2b
                    leax      >L108B,PC           * 04FB 30 8D 0B 8C    0...
                    pshs      X                   * 04FF 34 10          4.
                    lbsr      L1440               * 0501 17 0F 3C       ..<
                    leas      $02,S               * 0504 32 62          2b
                    clra                          * 0506 4F             O
                    clrb                          * 0507 5F             _
                    pshs      D                   * 0508 34 06          4.
                    lbsr      L2127               * 050A 17 1C 1A       ...
                    leas      $02,S               * 050D 32 62          2b
                    bra       L052A               * 050F 20 19           .
L0511               bsr       L052C               * 0511 8D 19          ..
                    clra                          * 0513 4F             O
                    clrb                          * 0514 5F             _
                    puls      PC,U                * 0515 35 C0          5@
L0517               ldd       #1                  * 0517 CC 00 01       L..
                    puls      PC,U                * 051A 35 C0          5@
L051C               cmpx      #-8                 * 051C 8C FF F8       ..x
                    lbeq      L046A               * 051F 10 27 FF 47    .'.G
                    cmpx      #-12                * 0523 8C FF F4       ..t
                    beq       L0511               * 0526 27 E9          'i
                    bra       L0517               * 0528 20 ED           m
L052A               puls      PC,U                * 052A 35 C0          5@
L052C               pshs      U                   * 052C 34 40          4@
                    ldd       #-75                * 052E CC FF B5       L.5
                    lbsr      L0111               * 0531 17 FB DD       .{]
                    leas      -$01,S              * 0534 32 7F          2.
                    clra                          * 0536 4F             O
                    clrb                          * 0537 5F             _
                    pshs      D                   * 0538 34 06          4.
                    lbsr      L2184               * 053A 17 1C 47       ..G
                    leas      $02,S               * 053D 32 62          2b
                    leax      >L10B5,PC           * 053F 30 8D 0B 72    0..r
                    pshs      X                   * 0543 34 10          4.
                    lbsr      L1440               * 0545 17 0E F8       ..x
                    leas      $02,S               * 0548 32 62          2b
                    leax      >$0020,Y            * 054A 30 A9 00 20    0).
                    pshs      X                   * 054E 34 10          4.
                    lbsr      L1A6F               * 0550 17 15 1C       ...
                    leas      $02,S               * 0553 32 62          2b
                    ldd       #1                  * 0555 CC 00 01       L..
                    pshs      D                   * 0558 34 06          4.
                    leax      $02,S               * 055A 30 62          0b
                    pshs      X                   * 055C 34 10          4.
                    clra                          * 055E 4F             O
                    clrb                          * 055F 5F             _
                    pshs      D                   * 0560 34 06          4.
                    lbsr      L1F80               * 0562 17 1A 1B       ...
                    leas      $06,S               * 0565 32 66          2f
                    leax      >L10D1,PC           * 0567 30 8D 0B 66    0..f
                    pshs      X                   * 056B 34 10          4.
                    lbsr      L1440               * 056D 17 0E D0       ..P
                    leas      $02,S               * 0570 32 62          2b
                    ldb       0,S                 * 0572 E6 E4          fd
                    clra                          * 0574 4F             O
                    andb      #223                * 0575 C4 DF          D_
                    stb       0,S                 * 0577 E7 E4          gd
                    cmpb      #82                 * 0579 C1 52          AR
                    bne       L0580               * 057B 26 03          &.
                    lbsr      L08FD               * 057D 17 03 7D       ..}
L0580               leax      >$01B8,Y            * 0580 30 A9 01 B8    0).8
                    pshs      X                   * 0584 34 10          4.
                    ldd       >$01B6,Y            * 0586 EC A9 01 B6    l).6
                    pshs      D                   * 058A 34 06          4.
                    clra                          * 058C 4F             O
                    clrb                          * 058D 5F             _
                    pshs      D                   * 058E 34 06          4.
                    lbsr      L1E95               * 0590 17 19 02       ...
                    leas      $06,S               * 0593 32 66          2f
                    ldd       #4371               * 0595 CC 11 13       L..
                    std       >$01D0,Y            * 0598 ED A9 01 D0    m).P
                    leax      >$01B8,Y            * 059C 30 A9 01 B8    0).8
                    pshs      X                   * 05A0 34 10          4.
                    ldd       >$01B6,Y            * 05A2 EC A9 01 B6    l).6
                    pshs      D                   * 05A6 34 06          4.
                    clra                          * 05A8 4F             O
                    clrb                          * 05A9 5F             _
                    pshs      D                   * 05AA 34 06          4.
                    lbsr      L1ED0               * 05AC 17 19 21       ..!
                    leas      $06,S               * 05AF 32 66          2f
                    ldb       0,S                 * 05B1 E6 E4          fd
                    cmpb      #83                 * 05B3 C1 53          AS
                    bne       L05B9               * 05B5 26 02          &.
                    bsr       L05BD               * 05B7 8D 04          ..
L05B9               leas      $01,S               * 05B9 32 61          2a
                    puls      PC,U                * 05BB 35 C0          5@
L05BD               pshs      U                   * 05BD 34 40          4@
                    ldd       #-283               * 05BF CC FE E5       L~e
                    lbsr      L0111               * 05C2 17 FB 4C       .{L
                    leas      >$FF31,S            * 05C5 32 E9 FF 31    2i.1
                    ldd       #1                  * 05C9 CC 00 01       L..
                    std       0,S                 * 05CC ED E4          md
                    ldd       >$01B6,Y            * 05CE EC A9 01 B6    l).6
                    pshs      D                   * 05D2 34 06          4.
                    lbsr      L214C               * 05D4 17 1B 75       ..u
                    leas      $02,S               * 05D7 32 62          2b
                    leax      >$01B8,Y            * 05D9 30 A9 01 B8    0).8
                    pshs      X                   * 05DD 34 10          4.
                    ldd       >$01B4,Y            * 05DF EC A9 01 B4    l).4
                    pshs      D                   * 05E3 34 06          4.
                    clra                          * 05E5 4F             O
                    clrb                          * 05E6 5F             _
                    pshs      D                   * 05E7 34 06          4.
                    lbsr      L1E95               * 05E9 17 18 A9       ..)
                    leas      $06,S               * 05EC 32 66          2f
                    ldd       #1                  * 05EE CC 00 01       L..
                    stb       >$01BC,Y            * 05F1 E7 A9 01 BC    g).<
                    ldd       #13                 * 05F5 CC 00 0D       L..
                    stb       >$01C3,Y            * 05F8 E7 A9 01 C3    g).C
                    leax      >$01B8,Y            * 05FC 30 A9 01 B8    0).8
                    pshs      X                   * 0600 34 10          4.
                    ldd       >$01B4,Y            * 0602 EC A9 01 B4    l).4
                    pshs      D                   * 0606 34 06          4.
                    clra                          * 0608 4F             O
                    clrb                          * 0609 5F             _
                    pshs      D                   * 060A 34 06          4.
                    lbsr      L1ED0               * 060C 17 18 C1       ..A
                    leas      $06,S               * 060F 32 66          2f
                    leax      >L10D3,PC           * 0611 30 8D 0A BE    0..>
                    pshs      X                   * 0615 34 10          4.
                    lbsr      L1440               * 0617 17 0E 26       ..&
                    leas      $02,S               * 061A 32 62          2b
                    leax      >$0013,Y            * 061C 30 A9 00 13    0)..
                    pshs      X                   * 0620 34 10          4.
                    ldd       #200                * 0622 CC 00 C8       L.H
                    pshs      D                   * 0625 34 06          4.
                    leax      $0B,S               * 0627 30 6B          0k
                    pshs      X                   * 0629 34 10          4.
                    lbsr      L13F7               * 062B 17 0D C9       ..I
                    leas      $06,S               * 062E 32 66          2f
                    clra                          * 0630 4F             O
                    clrb                          * 0631 5F             _
                    stb       >$01BC,Y            * 0632 E7 A9 01 BC    g).<
                    clra                          * 0636 4F             O
                    clrb                          * 0637 5F             _
                    stb       >$01C3,Y            * 0638 E7 A9 01 C3    g).C
                    leax      >$01B8,Y            * 063C 30 A9 01 B8    0).8
                    pshs      X                   * 0640 34 10          4.
                    ldd       >$01B4,Y            * 0642 EC A9 01 B4    l).4
                    pshs      D                   * 0646 34 06          4.
                    clra                          * 0648 4F             O
                    clrb                          * 0649 5F             _
                    pshs      D                   * 064A 34 06          4.
                    lbsr      L1ED0               * 064C 17 18 81       ...
                    leas      $06,S               * 064F 32 66          2f
                    ldd       #1                  * 0651 CC 00 01       L..
                    pshs      D                   * 0654 34 06          4.
                    leax      $09,S               * 0656 30 69          0i
                    pshs      X                   * 0658 34 10          4.
                    lbsr      L1F04               * 065A 17 18 A7       ..'
                    leas      $04,S               * 065D 32 64          2d
                    std       $04,S               * 065F ED 64          md
                    cmpd      #-1                 * 0661 10 83 FF FF    ....
                    bne       L067B               * 0665 26 14          &.
                    ldd       >$01B2,Y            * 0667 EC A9 01 B2    l).2
                    pshs      D                   * 066B 34 06          4.
                    leax      >L10EB,PC           * 066D 30 8D 0A 7A    0..z
                    pshs      X                   * 0671 34 10          4.
                    lbsr      L1440               * 0673 17 0D CA       ..J
                    leas      $04,S               * 0676 32 64          2d
                    lbra      L0C6C               * 0678 16 05 F1       ..q
L067B               leax      >L1107,PC           * 067B 30 8D 0A 88    0...
                    pshs      X                   * 067F 34 10          4.
                    lbsr      L1440               * 0681 17 0D BC       ..<
                    leas      $02,S               * 0684 32 62          2b
                    leax      >L1140,PC           * 0686 30 8D 0A B6    0..6
                    pshs      X                   * 068A 34 10          4.
                    lbsr      L1440               * 068C 17 0D B1       ..1
                    leas      $02,S               * 068F 32 62          2b
                    leax      >$01B8,Y            * 0691 30 A9 01 B8    0).8
                    pshs      X                   * 0695 34 10          4.
                    ldd       >$01B4,Y            * 0697 EC A9 01 B4    l).4
                    pshs      D                   * 069B 34 06          4.
                    clra                          * 069D 4F             O
                    clrb                          * 069E 5F             _
                    pshs      D                   * 069F 34 06          4.
                    lbsr      L1E95               * 06A1 17 17 F1       ..q
                    leas      $06,S               * 06A4 32 66          2f
                    clra                          * 06A6 4F             O
                    clrb                          * 06A7 5F             _
                    stb       >$01BD,Y            * 06A8 E7 A9 01 BD    g).=
                    leax      >$01B8,Y            * 06AC 30 A9 01 B8    0).8
                    pshs      X                   * 06B0 34 10          4.
                    ldd       >$01B4,Y            * 06B2 EC A9 01 B4    l).4
                    pshs      D                   * 06B6 34 06          4.
                    clra                          * 06B8 4F             O
                    clrb                          * 06B9 5F             _
                    pshs      D                   * 06BA 34 06          4.
                    lbsr      L1ED0               * 06BC 17 18 11       ...
                    leas      $06,S               * 06BF 32 66          2f
                    ldd       #1                  * 06C1 CC 00 01       L..
                    stb       >$01D8,Y            * 06C4 E7 A9 01 D8    g).X
                    ldd       #1                  * 06C8 CC 00 01       L..
                    stb       >$01D9,Y            * 06CB E7 A9 01 D9    g).Y
                    sex                           * 06CF 1D             .
                    coma                          * 06D0 43             C
                    comb                          * 06D1 53             S
                    stb       >$01DA,Y            * 06D2 E7 A9 01 DA    g).Z
                    ldd       #128                * 06D6 CC 00 80       L..
                    pshs      D                   * 06D9 34 06          4.
                    leax      >$01DB,Y            * 06DB 30 A9 01 DB    0).[
                    pshs      X                   * 06DF 34 10          4.
                    ldd       $08,S               * 06E1 EC 68          lh
                    pshs      D                   * 06E3 34 06          4.
                    lbsr      L1F80               * 06E5 17 18 98       ...
                    leas      $06,S               * 06E8 32 66          2f
                    leax      >$01DB,Y            * 06EA 30 A9 01 DB    0).[
                    pshs      X                   * 06EE 34 10          4.
                    lbsr      L0E0B               * 06F0 17 07 18       ...
                    leas      $02,S               * 06F3 32 62          2b
                    stb       >$025B,Y            * 06F5 E7 A9 02 5B    g).[
                    ldd       0,S                 * 06F9 EC E4          ld
                    pshs      D                   * 06FB 34 06          4.
                    leax      >L1182,PC           * 06FD 30 8D 0A 81    0...
                    pshs      X                   * 0701 34 10          4.
                    lbsr      L1440               * 0703 17 0D 3A       ..:
                    leas      $04,S               * 0706 32 64          2d
                    leax      >$0020,Y            * 0708 30 A9 00 20    0).
                    pshs      X                   * 070C 34 10          4.
                    lbsr      L1A6F               * 070E 17 13 5E       ..^
                    leas      $02,S               * 0711 32 62          2b
                    lbra      L077A               * 0713 16 00 64       ..d
L0716               clra                          * 0716 4F             O
                    clrb                          * 0717 5F             _
                    pshs      D                   * 0718 34 06          4.
                    lbsr      L0EC9               * 071A 17 07 AC       ..,
                    leas      $02,S               * 071D 32 62          2b
                    cmpd      #-15                * 071F 10 83 FF F1    ...q
                    bne       L077A               * 0723 26 55          &U
                    leax      >$01B8,Y            * 0725 30 A9 01 B8    0).8
                    pshs      X                   * 0729 34 10          4.
                    ldd       >$01B4,Y            * 072B EC A9 01 B4    l).4
                    pshs      D                   * 072F 34 06          4.
                    clra                          * 0731 4F             O
                    clrb                          * 0732 5F             _
                    pshs      D                   * 0733 34 06          4.
                    lbsr      L1E95               * 0735 17 17 5D       ..]
                    leas      $06,S               * 0738 32 66          2f
                    ldd       #1                  * 073A CC 00 01       L..
                    stb       >$01BD,Y            * 073D E7 A9 01 BD    g).=
                    leax      >$01B8,Y            * 0741 30 A9 01 B8    0).8
                    pshs      X                   * 0745 34 10          4.
                    ldd       >$01B4,Y            * 0747 EC A9 01 B4    l).4
                    pshs      D                   * 074B 34 06          4.
                    clra                          * 074D 4F             O
                    clrb                          * 074E 5F             _
                    pshs      D                   * 074F 34 06          4.
                    lbsr      L1ED0               * 0751 17 17 7C       ..|
                    leas      $06,S               * 0754 32 66          2f
                    leax      >L1198,PC           * 0756 30 8D 0A 3E    0..>
                    pshs      X                   * 075A 34 10          4.
                    lbsr      L1440               * 075C 17 0C E1       ..a
                    leas      $02,S               * 075F 32 62          2b
                    ldd       #1                  * 0761 CC 00 01       L..
                    pshs      D                   * 0764 34 06          4.
                    leax      >$0005,Y            * 0766 30 A9 00 05    0)..
                    pshs      X                   * 076A 34 10          4.
                    ldd       >$01B6,Y            * 076C EC A9 01 B6    l).6
                    pshs      D                   * 0770 34 06          4.
                    lbsr      L1FB1               * 0772 17 18 3C       ..<
                    leas      $06,S               * 0775 32 66          2f
                    lbra      L0C6C               * 0777 16 04 F2       ..r
L077A               leax      $06,S               * 077A 30 66          0f
                    pshs      X                   * 077C 34 10          4.
                    ldd       #1                  * 077E CC 00 01       L..
                    pshs      D                   * 0781 34 06          4.
                    ldd       #1                  * 0783 CC 00 01       L..
                    pshs      D                   * 0786 34 06          4.
                    ldd       >$01B6,Y            * 0788 EC A9 01 B6    l).6
                    pshs      D                   * 078C 34 06          4.
                    lbsr      L0D73               * 078E 17 05 E2       ..b
                    leas      $08,S               * 0791 32 68          2h
                    cmpd      #-1                 * 0793 10 83 FF FF    ....
                    lbeq      L0716               * 0797 10 27 FF 7B    .'.{
                    ldb       $06,S               * 079B E6 66          ff
                    cmpb      #21                 * 079D C1 15          A.
                    bne       L07B7               * 079F 26 16          &.
                    ldd       #132                * 07A1 CC 00 84       L..
                    pshs      D                   * 07A4 34 06          4.
                    leax      >$01D8,Y            * 07A6 30 A9 01 D8    0).X
                    pshs      X                   * 07AA 34 10          4.
                    ldd       >$01B6,Y            * 07AC EC A9 01 B6    l).6
                    pshs      D                   * 07B0 34 06          4.
                    lbsr      L1FB1               * 07B2 17 17 FC       ..|
                    leas      $06,S               * 07B5 32 66          2f
L07B7               ldb       $06,S               * 07B7 E6 66          ff
                    cmpb      #24                 * 07B9 C1 18          A.
                    bne       L0803               * 07BB 26 46          &F
                    leax      >$01B8,Y            * 07BD 30 A9 01 B8    0).8
                    pshs      X                   * 07C1 34 10          4.
                    ldd       >$01B4,Y            * 07C3 EC A9 01 B4    l).4
                    pshs      D                   * 07C7 34 06          4.
                    clra                          * 07C9 4F             O
                    clrb                          * 07CA 5F             _
                    pshs      D                   * 07CB 34 06          4.
                    lbsr      L1E95               * 07CD 17 16 C5       ..E
                    leas      $06,S               * 07D0 32 66          2f
                    ldd       #1                  * 07D2 CC 00 01       L..
                    stb       >$01BD,Y            * 07D5 E7 A9 01 BD    g).=
                    leax      >$01B8,Y            * 07D9 30 A9 01 B8    0).8
                    pshs      X                   * 07DD 34 10          4.
                    ldd       >$01B4,Y            * 07DF EC A9 01 B4    l).4
                    pshs      D                   * 07E3 34 06          4.
                    clra                          * 07E5 4F             O
                    clrb                          * 07E6 5F             _
                    pshs      D                   * 07E7 34 06          4.
                    lbsr      L1ED0               * 07E9 17 16 E4       ..d
                    leas      $06,S               * 07EC 32 66          2f
                    leax      >L11B0,PC           * 07EE 30 8D 09 BE    0..>
                    pshs      X                   * 07F2 34 10          4.
                    lbsr      L1440               * 07F4 17 0C 49       ..I
                    leas      $02,S               * 07F7 32 62          2b
                    ldd       $04,S               * 07F9 EC 64          ld
                    pshs      D                   * 07FB 34 06          4.
                    lbsr      L1F13               * 07FD 17 17 13       ...
                    lbra      L0C12               * 0800 16 04 0F       ...
L0803               ldb       $06,S               * 0803 E6 66          ff
                    cmpb      #6                  * 0805 C1 06          A.
                    lbne      L077A               * 0807 10 26 FF 6F    .&.o
                    ldb       >$01D9,Y            * 080B E6 A9 01 D9    f).Y
                    addd      #1                  * 080F C3 00 01       C..
                    stb       >$01D9,Y            * 0812 E7 A9 01 D9    g).Y
                    sex                           * 0816 1D             .
                    coma                          * 0817 43             C
                    comb                          * 0818 53             S
                    stb       >$01DA,Y            * 0819 E7 A9 01 DA    g).Z
                    ldd       0,S                 * 081D EC E4          ld
                    addd      #1                  * 081F C3 00 01       C..
                    std       0,S                 * 0822 ED E4          md
                    clra                          * 0824 4F             O
                    clrb                          * 0825 5F             _
                    bra       L0839               * 0826 20 11           .
L0828               ldd       $02,S               * 0828 EC 62          lb
                    leax      >$01DB,Y            * 082A 30 A9 01 DB    0).[
                    leax      D,X                 * 082E 30 8B          0.
                    clra                          * 0830 4F             O
                    clrb                          * 0831 5F             _
                    stb       0,X                 * 0832 E7 84          g.
                    ldd       $02,S               * 0834 EC 62          lb
                    addd      #1                  * 0836 C3 00 01       C..
L0839               std       $02,S               * 0839 ED 62          mb
                    ldd       $02,S               * 083B EC 62          lb
                    cmpd      #127                * 083D 10 83 00 7F    ....
                    ble       L0828               * 0841 2F E5          /e
                    ldd       #128                * 0843 CC 00 80       L..
                    pshs      D                   * 0846 34 06          4.
                    leax      >$01DB,Y            * 0848 30 A9 01 DB    0).[
                    pshs      X                   * 084C 34 10          4.
                    ldd       $08,S               * 084E EC 68          lh
                    pshs      D                   * 0850 34 06          4.
                    lbsr      L1F80               * 0852 17 17 2B       ..+
                    leas      $06,S               * 0855 32 66          2f
                    std       -$02,S              * 0857 ED 7E          m~
                    lbne      L08BB               * 0859 10 26 00 5E    .&.^
                    ldd       #1                  * 085D CC 00 01       L..
                    pshs      D                   * 0860 34 06          4.
                    leax      >$0003,Y            * 0862 30 A9 00 03    0)..
                    pshs      X                   * 0866 34 10          4.
                    ldd       >$01B6,Y            * 0868 EC A9 01 B6    l).6
                    pshs      D                   * 086C 34 06          4.
                    lbsr      L1FB1               * 086E 17 17 40       ..@
                    leas      $06,S               * 0871 32 66          2f
                    leax      >$01B8,Y            * 0873 30 A9 01 B8    0).8
                    pshs      X                   * 0877 34 10          4.
                    ldd       >$01B4,Y            * 0879 EC A9 01 B4    l).4
                    pshs      D                   * 087D 34 06          4.
                    clra                          * 087F 4F             O
                    clrb                          * 0880 5F             _
                    pshs      D                   * 0881 34 06          4.
                    lbsr      L1E95               * 0883 17 16 0F       ...
                    leas      $06,S               * 0886 32 66          2f
                    ldd       #1                  * 0888 CC 00 01       L..
                    stb       >$01BD,Y            * 088B E7 A9 01 BD    g).=
                    leax      >$01B8,Y            * 088F 30 A9 01 B8    0).8
                    pshs      X                   * 0893 34 10          4.
                    ldd       >$01B4,Y            * 0895 EC A9 01 B4    l).4
                    pshs      D                   * 0899 34 06          4.
                    clra                          * 089B 4F             O
                    clrb                          * 089C 5F             _
                    pshs      D                   * 089D 34 06          4.
                    lbsr      L1ED0               * 089F 17 16 2E       ...
                    leas      $06,S               * 08A2 32 66          2f
                    leax      >L11C8,PC           * 08A4 30 8D 09 20    0..
                    pshs      X                   * 08A8 34 10          4.
                    lbsr      L1440               * 08AA 17 0B 93       ...
                    leas      $02,S               * 08AD 32 62          2b
                    ldd       $04,S               * 08AF EC 64          ld
                    pshs      D                   * 08B1 34 06          4.
                    lbsr      L1F13               * 08B3 17 16 5D       ..]
                    leas      $02,S               * 08B6 32 62          2b
                    lbra      L0B9A               * 08B8 16 02 DF       .._
L08BB               leax      >$01DB,Y            * 08BB 30 A9 01 DB    0).[
                    pshs      X                   * 08BF 34 10          4.
                    lbsr      L0E0B               * 08C1 17 05 47       ..G
                    leas      $02,S               * 08C4 32 62          2b
                    stb       >$025B,Y            * 08C6 E7 A9 02 5B    g).[
                    ldd       0,S                 * 08CA EC E4          ld
                    pshs      D                   * 08CC 34 06          4.
                    leax      >L11E1,PC           * 08CE 30 8D 09 0F    0...
                    pshs      X                   * 08D2 34 10          4.
                    lbsr      L1440               * 08D4 17 0B 69       ..i
                    leas      $04,S               * 08D7 32 64          2d
                    leax      >$0020,Y            * 08D9 30 A9 00 20    0).
                    pshs      X                   * 08DD 34 10          4.
                    lbsr      L1A6F               * 08DF 17 11 8D       ...
                    leas      $02,S               * 08E2 32 62          2b
                    ldd       #132                * 08E4 CC 00 84       L..
                    pshs      D                   * 08E7 34 06          4.
                    leax      >$01D8,Y            * 08E9 30 A9 01 D8    0).X
                    pshs      X                   * 08ED 34 10          4.
                    ldd       >$01B6,Y            * 08EF EC A9 01 B6    l).6
                    pshs      D                   * 08F3 34 06          4.
                    lbsr      L1FB1               * 08F5 17 16 B9       ..9
                    leas      $06,S               * 08F8 32 66          2f
                    lbra      L077A               * 08FA 16 FE 7D       .~}
L08FD               pshs      U                   * 08FD 34 40          4@
                    ldd       #-283               * 08FF CC FE E5       L~e
                    lbsr      L0111               * 0902 17 F8 0C       .x.
                    leas      >$FF31,S            * 0905 32 E9 FF 31    2i.1
                    ldd       #1                  * 0909 CC 00 01       L..
                    stb       $06,S               * 090C E7 66          gf
                    ldd       #1                  * 090E CC 00 01       L..
                    std       $04,S               * 0911 ED 64          md
                    ldd       >$01B6,Y            * 0913 EC A9 01 B6    l).6
                    pshs      D                   * 0917 34 06          4.
                    lbsr      L214C               * 0919 17 18 30       ..0
                    leas      $02,S               * 091C 32 62          2b
                    leax      >$01B8,Y            * 091E 30 A9 01 B8    0).8
                    pshs      X                   * 0922 34 10          4.
                    ldd       >$01B6,Y            * 0924 EC A9 01 B6    l).6
                    pshs      D                   * 0928 34 06          4.
                    clra                          * 092A 4F             O
                    clrb                          * 092B 5F             _
                    pshs      D                   * 092C 34 06          4.
                    lbsr      L1E95               * 092E 17 15 64       ..d
                    leas      $06,S               * 0931 32 66          2f
                    clra                          * 0933 4F             O
                    clrb                          * 0934 5F             _
                    std       >$01D0,Y            * 0935 ED A9 01 D0    m).P
                    leax      >$01B8,Y            * 0939 30 A9 01 B8    0).8
                    pshs      X                   * 093D 34 10          4.
                    ldd       >$01B6,Y            * 093F EC A9 01 B6    l).6
                    pshs      D                   * 0943 34 06          4.
                    clra                          * 0945 4F             O
                    clrb                          * 0946 5F             _
                    pshs      D                   * 0947 34 06          4.
                    lbsr      L1ED0               * 0949 17 15 84       ...
                    leas      $06,S               * 094C 32 66          2f
                    leax      >$01B8,Y            * 094E 30 A9 01 B8    0).8
                    pshs      X                   * 0952 34 10          4.
                    ldd       >$01B4,Y            * 0954 EC A9 01 B4    l).4
                    pshs      D                   * 0958 34 06          4.
                    clra                          * 095A 4F             O
                    clrb                          * 095B 5F             _
                    pshs      D                   * 095C 34 06          4.
                    lbsr      L1E95               * 095E 17 15 34       ..4
                    leas      $06,S               * 0961 32 66          2f
                    ldd       #1                  * 0963 CC 00 01       L..
                    stb       >$01BC,Y            * 0966 E7 A9 01 BC    g).<
                    ldd       #13                 * 096A CC 00 0D       L..
                    stb       >$01C3,Y            * 096D E7 A9 01 C3    g).C
                    leax      >$01B8,Y            * 0971 30 A9 01 B8    0).8
                    pshs      X                   * 0975 34 10          4.
                    ldd       >$01B4,Y            * 0977 EC A9 01 B4    l).4
                    pshs      D                   * 097B 34 06          4.
                    clra                          * 097D 4F             O
                    clrb                          * 097E 5F             _
                    pshs      D                   * 097F 34 06          4.
                    lbsr      L1ED0               * 0981 17 15 4C       ..L
                    leas      $06,S               * 0984 32 66          2f
                    leax      >L11F7,PC           * 0986 30 8D 08 6D    0..m
                    pshs      X                   * 098A 34 10          4.
                    lbsr      L1440               * 098C 17 0A B1       ..1
                    leas      $02,S               * 098F 32 62          2b
                    leax      >$0013,Y            * 0991 30 A9 00 13    0)..
                    pshs      X                   * 0995 34 10          4.
                    ldd       #200                * 0997 CC 00 C8       L.H
                    pshs      D                   * 099A 34 06          4.
                    leax      $0B,S               * 099C 30 6B          0k
                    pshs      X                   * 099E 34 10          4.
                    lbsr      L13F7               * 09A0 17 0A 54       ..T
                    leas      $06,S               * 09A3 32 66          2f
                    clra                          * 09A5 4F             O
                    clrb                          * 09A6 5F             _
                    stb       >$01BC,Y            * 09A7 E7 A9 01 BC    g).<
                    clra                          * 09AB 4F             O
                    clrb                          * 09AC 5F             _
                    stb       >$01C3,Y            * 09AD E7 A9 01 C3    g).C
                    leax      >$01B8,Y            * 09B1 30 A9 01 B8    0).8
                    pshs      X                   * 09B5 34 10          4.
                    ldd       >$01B4,Y            * 09B7 EC A9 01 B4    l).4
                    pshs      D                   * 09BB 34 06          4.
                    clra                          * 09BD 4F             O
                    clrb                          * 09BE 5F             _
                    pshs      D                   * 09BF 34 06          4.
                    lbsr      L1ED0               * 09C1 17 15 0C       ...
                    leas      $06,S               * 09C4 32 66          2f
                    ldd       #1                  * 09C6 CC 00 01       L..
                    pshs      D                   * 09C9 34 06          4.
                    leax      $09,S               * 09CB 30 69          0i
                    pshs      X                   * 09CD 34 10          4.
                    lbsr      L1EF5               * 09CF 17 15 23       ..#
                    leas      $04,S               * 09D2 32 64          2d
                    cmpd      #-1                 * 09D4 10 83 FF FF    ....
                    beq       L09E1               * 09D8 27 07          '.
                    leax      >L1212,PC           * 09DA 30 8D 08 34    0..4
                    lbra      L0AC4               * 09DE 16 00 E3       ..c
L09E1               ldd       #2                  * 09E1 CC 00 02       L..
                    pshs      D                   * 09E4 34 06          4.
                    leax      $09,S               * 09E6 30 69          0i
                    pshs      X                   * 09E8 34 10          4.
                    lbsr      L1F25               * 09EA 17 15 38       ..8
                    leas      $04,S               * 09ED 32 64          2d
                    std       $02,S               * 09EF ED 62          mb
                    cmpd      #-1                 * 09F1 10 83 FF FF    ....
                    bne       L0A0B               * 09F5 26 14          &.
                    ldd       >$01B2,Y            * 09F7 EC A9 01 B2    l).2
                    pshs      D                   * 09FB 34 06          4.
                    leax      >L1220,PC           * 09FD 30 8D 08 1F    0...
                    pshs      X                   * 0A01 34 10          4.
                    lbsr      L1440               * 0A03 17 0A 3A       ..:
                    leas      $04,S               * 0A06 32 64          2d
                    lbra      L0C6C               * 0A08 16 02 61       ..a
L0A0B               leax      >L123C,PC           * 0A0B 30 8D 08 2D    0..-
                    pshs      X                   * 0A0F 34 10          4.
                    lbsr      L1440               * 0A11 17 0A 2C       ..,
                    leas      $02,S               * 0A14 32 62          2b
                    leax      >L1275,PC           * 0A16 30 8D 08 5B    0..[
                    pshs      X                   * 0A1A 34 10          4.
                    lbsr      L1440               * 0A1C 17 0A 21       ..!
                    leas      $02,S               * 0A1F 32 62          2b
                    leax      >$01B8,Y            * 0A21 30 A9 01 B8    0).8
                    pshs      X                   * 0A25 34 10          4.
                    ldd       >$01B4,Y            * 0A27 EC A9 01 B4    l).4
                    pshs      D                   * 0A2B 34 06          4.
                    clra                          * 0A2D 4F             O
                    clrb                          * 0A2E 5F             _
                    pshs      D                   * 0A2F 34 06          4.
                    lbsr      L1E95               * 0A31 17 14 61       ..a
                    leas      $06,S               * 0A34 32 66          2f
                    clra                          * 0A36 4F             O
                    clrb                          * 0A37 5F             _
                    stb       >$01BD,Y            * 0A38 E7 A9 01 BD    g).=
                    leax      >$01B8,Y            * 0A3C 30 A9 01 B8    0).8
                    pshs      X                   * 0A40 34 10          4.
                    ldd       >$01B4,Y            * 0A42 EC A9 01 B4    l).4
                    pshs      D                   * 0A46 34 06          4.
                    clra                          * 0A48 4F             O
                    clrb                          * 0A49 5F             _
                    pshs      D                   * 0A4A 34 06          4.
                    lbsr      L1ED0               * 0A4C 17 14 81       ...
                    leas      $06,S               * 0A4F 32 66          2f
                    ldd       #1                  * 0A51 CC 00 01       L..
                    pshs      D                   * 0A54 34 06          4.
                    leax      >$0004,Y            * 0A56 30 A9 00 04    0)..
                    pshs      X                   * 0A5A 34 10          4.
                    ldd       >$01B6,Y            * 0A5C EC A9 01 B6    l).6
                    pshs      D                   * 0A60 34 06          4.
                    lbsr      L1FB1               * 0A62 17 15 4C       ..L
                    leas      $06,S               * 0A65 32 66          2f
                    lbra      L0D6A               * 0A67 16 03 00       ...
L0A6A               clra                          * 0A6A 4F             O
                    clrb                          * 0A6B 5F             _
                    pshs      D                   * 0A6C 34 06          4.
                    lbsr      L0EC9               * 0A6E 17 04 58       ..X
                    leas      $02,S               * 0A71 32 62          2b
                    cmpd      #-15                * 0A73 10 83 FF F1    ...q
                    bne       L0ACC               * 0A77 26 53          &S
                    ldd       #1                  * 0A79 CC 00 01       L..
                    pshs      D                   * 0A7C 34 06          4.
                    leax      >$0005,Y            * 0A7E 30 A9 00 05    0)..
                    pshs      X                   * 0A82 34 10          4.
                    ldd       >$01B6,Y            * 0A84 EC A9 01 B6    l).6
                    pshs      D                   * 0A88 34 06          4.
                    lbsr      L1FB1               * 0A8A 17 15 24       ..$
                    leas      $06,S               * 0A8D 32 66          2f
                    leax      >$01B8,Y            * 0A8F 30 A9 01 B8    0).8
                    pshs      X                   * 0A93 34 10          4.
                    ldd       >$01B4,Y            * 0A95 EC A9 01 B4    l).4
                    pshs      D                   * 0A99 34 06          4.
                    clra                          * 0A9B 4F             O
                    clrb                          * 0A9C 5F             _
                    pshs      D                   * 0A9D 34 06          4.
                    lbsr      L1E95               * 0A9F 17 13 F3       ..s
                    leas      $06,S               * 0AA2 32 66          2f
                    ldd       #1                  * 0AA4 CC 00 01       L..
                    stb       >$01BD,Y            * 0AA7 E7 A9 01 BD    g).=
                    leax      >$01B8,Y            * 0AAB 30 A9 01 B8    0).8
                    pshs      X                   * 0AAF 34 10          4.
                    ldd       >$01B4,Y            * 0AB1 EC A9 01 B4    l).4
                    pshs      D                   * 0AB5 34 06          4.
                    clra                          * 0AB7 4F             O
                    clrb                          * 0AB8 5F             _
                    pshs      D                   * 0AB9 34 06          4.
                    lbsr      L1ED0               * 0ABB 17 14 12       ...
                    leas      $06,S               * 0ABE 32 66          2f
                    leax      >L12B7,PC           * 0AC0 30 8D 07 F3    0..s
L0AC4               pshs      X                   * 0AC4 34 10          4.
                    lbsr      L1440               * 0AC6 17 09 77       ..w
                    lbra      L0C12               * 0AC9 16 01 46       ..F
L0ACC               clra                          * 0ACC 4F             O
                    clrb                          * 0ACD 5F             _
                    stb       >$01D8,Y            * 0ACE E7 A9 01 D8    g).X
                    clra                          * 0AD2 4F             O
                    clrb                          * 0AD3 5F             _
                    std       0,S                 * 0AD4 ED E4          md
                    ldd       $04,S               * 0AD6 EC 64          ld
                    pshs      D                   * 0AD8 34 06          4.
                    leax      >L12D0,PC           * 0ADA 30 8D 07 F2    0..r
                    pshs      X                   * 0ADE 34 10          4.
                    lbsr      L1440               * 0AE0 17 09 5D       ..]
                    leas      $04,S               * 0AE3 32 64          2d
                    leax      >$0020,Y            * 0AE5 30 A9 00 20    0).
                    pshs      X                   * 0AE9 34 10          4.
                    lbsr      L1A6F               * 0AEB 17 0F 81       ...
                    leas      $02,S               * 0AEE 32 62          2b
                    lbra      L0C72               * 0AF0 16 01 7F       ...
L0AF3               leax      >$01D8,Y            * 0AF3 30 A9 01 D8    0).X
                    pshs      X                   * 0AF7 34 10          4.
                    ldd       #10                 * 0AF9 CC 00 0A       L..
                    pshs      D                   * 0AFC 34 06          4.
                    ldd       #1                  * 0AFE CC 00 01       L..
                    pshs      D                   * 0B01 34 06          4.
                    ldd       >$01B6,Y            * 0B03 EC A9 01 B6    l).6
                    pshs      D                   * 0B07 34 06          4.
                    lbsr      L0D73               * 0B09 17 02 67       ..g
                    leas      $08,S               * 0B0C 32 68          2h
                    cmpd      #-1                 * 0B0E 10 83 FF FF    ....
                    bne       L0B35               * 0B12 26 21          &!
                    leax      >L12E8,PC           * 0B14 30 8D 07 D0    0..P
                    pshs      X                   * 0B18 34 10          4.
                    lbsr      L1440               * 0B1A 17 09 23       ..#
                    leas      $02,S               * 0B1D 32 62          2b
                    ldd       #1                  * 0B1F CC 00 01       L..
                    pshs      D                   * 0B22 34 06          4.
                    leax      >$0004,Y            * 0B24 30 A9 00 04    0)..
                    pshs      X                   * 0B28 34 10          4.
                    ldd       >$01B6,Y            * 0B2A EC A9 01 B6    l).6
                    pshs      D                   * 0B2E 34 06          4.
                    lbsr      L1FB1               * 0B30 17 14 7E       ..~
                    leas      $06,S               * 0B33 32 66          2f
L0B35               ldb       >$01D8,Y            * 0B35 E6 A9 01 D8    f).X
                    cmpb      #4                  * 0B39 C1 04          A.
                    lbne      L0B9F               * 0B3B 10 26 00 60    .&.`
                    ldd       #1                  * 0B3F CC 00 01       L..
                    pshs      D                   * 0B42 34 06          4.
                    leax      >$0002,Y            * 0B44 30 A9 00 02    0)..
                    pshs      X                   * 0B48 34 10          4.
                    ldd       >$01B6,Y            * 0B4A EC A9 01 B6    l).6
                    pshs      D                   * 0B4E 34 06          4.
                    lbsr      L1FB1               * 0B50 17 14 5E       ..^
                    leas      $06,S               * 0B53 32 66          2f
                    leax      >$01B8,Y            * 0B55 30 A9 01 B8    0).8
                    pshs      X                   * 0B59 34 10          4.
                    ldd       >$01B4,Y            * 0B5B EC A9 01 B4    l).4
                    pshs      D                   * 0B5F 34 06          4.
                    clra                          * 0B61 4F             O
                    clrb                          * 0B62 5F             _
                    pshs      D                   * 0B63 34 06          4.
                    lbsr      L1E95               * 0B65 17 13 2D       ..-
                    leas      $06,S               * 0B68 32 66          2f
                    ldd       #1                  * 0B6A CC 00 01       L..
                    stb       >$01BD,Y            * 0B6D E7 A9 01 BD    g).=
                    leax      >$01B8,Y            * 0B71 30 A9 01 B8    0).8
                    pshs      X                   * 0B75 34 10          4.
                    ldd       >$01B4,Y            * 0B77 EC A9 01 B4    l).4
                    pshs      D                   * 0B7B 34 06          4.
                    clra                          * 0B7D 4F             O
                    clrb                          * 0B7E 5F             _
                    pshs      D                   * 0B7F 34 06          4.
                    lbsr      L1ED0               * 0B81 17 13 4C       ..L
                    leas      $06,S               * 0B84 32 66          2f
                    leax      >L12FC,PC           * 0B86 30 8D 07 72    0..r
                    pshs      X                   * 0B8A 34 10          4.
                    lbsr      L1440               * 0B8C 17 08 B1       ..1
                    leas      $02,S               * 0B8F 32 62          2b
                    ldd       $02,S               * 0B91 EC 62          lb
                    pshs      D                   * 0B93 34 06          4.
                    lbsr      L1F13               * 0B95 17 13 7B       ..{
                    leas      $02,S               * 0B98 32 62          2b
L0B9A               clra                          * 0B9A 4F             O
                    clrb                          * 0B9B 5F             _
                    lbra      L0D6D               * 0B9C 16 01 CE       ..N
L0B9F               ldd       0,S                 * 0B9F EC E4          ld
                    addd      #1                  * 0BA1 C3 00 01       C..
                    std       0,S                 * 0BA4 ED E4          md
                    subd      #1                  * 0BA6 83 00 01       ...
                    cmpd      #10                 * 0BA9 10 83 00 0A    ....
                    lble      L0C17               * 0BAD 10 2F 00 66    ./.f
                    leax      >$01B8,Y            * 0BB1 30 A9 01 B8    0).8
                    pshs      X                   * 0BB5 34 10          4.
                    ldd       >$01B4,Y            * 0BB7 EC A9 01 B4    l).4
                    pshs      D                   * 0BBB 34 06          4.
                    clra                          * 0BBD 4F             O
                    clrb                          * 0BBE 5F             _
                    pshs      D                   * 0BBF 34 06          4.
                    lbsr      L1E95               * 0BC1 17 12 D1       ..Q
                    leas      $06,S               * 0BC4 32 66          2f
                    clra                          * 0BC6 4F             O
                    clrb                          * 0BC7 5F             _
                    stb       >$01BD,Y            * 0BC8 E7 A9 01 BD    g).=
                    leax      >$01B8,Y            * 0BCC 30 A9 01 B8    0).8
                    pshs      X                   * 0BD0 34 10          4.
                    ldd       >$01B4,Y            * 0BD2 EC A9 01 B4    l).4
                    pshs      D                   * 0BD6 34 06          4.
                    clra                          * 0BD8 4F             O
                    clrb                          * 0BD9 5F             _
                    pshs      D                   * 0BDA 34 06          4.
                    lbsr      L1ED0               * 0BDC 17 12 F1       ..q
                    leas      $06,S               * 0BDF 32 66          2f
                    leax      >L1316,PC           * 0BE1 30 8D 07 31    0..1
                    pshs      X                   * 0BE5 34 10          4.
                    lbsr      L1440               * 0BE7 17 08 56       ..V
                    leas      $02,S               * 0BEA 32 62          2b
                    ldd       #1                  * 0BEC CC 00 01       L..
                    pshs      D                   * 0BEF 34 06          4.
                    leax      >$0005,Y            * 0BF1 30 A9 00 05    0)..
                    pshs      X                   * 0BF5 34 10          4.
                    ldd       >$01B6,Y            * 0BF7 EC A9 01 B6    l).6
                    pshs      D                   * 0BFB 34 06          4.
                    lbsr      L1FB1               * 0BFD 17 13 B1       ..1
                    leas      $06,S               * 0C00 32 66          2f
                    ldd       $02,S               * 0C02 EC 62          lb
                    pshs      D                   * 0C04 34 06          4.
                    lbsr      L1F13               * 0C06 17 13 0A       ...
                    leas      $02,S               * 0C09 32 62          2b
                    leax      $07,S               * 0C0B 30 67          0g
                    pshs      X                   * 0C0D 34 10          4.
                    lbsr      L1F6B               * 0C0F 17 13 59       ..Y
L0C12               leas      $02,S               * 0C12 32 62          2b
                    lbra      L0C6C               * 0C14 16 00 55       ..U
L0C17               ldb       >$01D8,Y            * 0C17 E6 A9 01 D8    f).X
                    cmpb      #24                 * 0C1B C1 18          A.
                    bne       L0C72               * 0C1D 26 53          &S
                    leax      >L1334,PC           * 0C1F 30 8D 07 11    0...
                    pshs      X                   * 0C23 34 10          4.
                    lbsr      L1440               * 0C25 17 08 18       ...
                    leas      $02,S               * 0C28 32 62          2b
                    ldd       $02,S               * 0C2A EC 62          lb
                    pshs      D                   * 0C2C 34 06          4.
                    lbsr      L1F13               * 0C2E 17 12 E2       ..b
                    leas      $02,S               * 0C31 32 62          2b
                    leax      $07,S               * 0C33 30 67          0g
                    pshs      X                   * 0C35 34 10          4.
                    lbsr      L1F6B               * 0C37 17 13 31       ..1
                    leas      $02,S               * 0C3A 32 62          2b
                    leax      >$01B8,Y            * 0C3C 30 A9 01 B8    0).8
                    pshs      X                   * 0C40 34 10          4.
                    ldd       >$01B4,Y            * 0C42 EC A9 01 B4    l).4
                    pshs      D                   * 0C46 34 06          4.
                    clra                          * 0C48 4F             O
                    clrb                          * 0C49 5F             _
                    pshs      D                   * 0C4A 34 06          4.
                    lbsr      L1E95               * 0C4C 17 12 46       ..F
                    leas      $06,S               * 0C4F 32 66          2f
                    clra                          * 0C51 4F             O
                    clrb                          * 0C52 5F             _
                    stb       >$01BD,Y            * 0C53 E7 A9 01 BD    g).=
                    leax      >$01B8,Y            * 0C57 30 A9 01 B8    0).8
                    pshs      X                   * 0C5B 34 10          4.
                    ldd       >$01B4,Y            * 0C5D EC A9 01 B4    l).4
                    pshs      D                   * 0C61 34 06          4.
                    clra                          * 0C63 4F             O
                    clrb                          * 0C64 5F             _
                    pshs      D                   * 0C65 34 06          4.
                    lbsr      L1ED0               * 0C67 17 12 66       ..f
                    leas      $06,S               * 0C6A 32 66          2f
L0C6C               ldd       #-1                 * 0C6C CC FF FF       L..
                    lbra      L0D6D               * 0C6F 16 00 FB       ..{
L0C72               ldb       >$01D8,Y            * 0C72 E6 A9 01 D8    f).X
                    cmpb      #1                  * 0C76 C1 01          A.
                    lbne      L0AF3               * 0C78 10 26 FE 77    .&~w
                    leax      >$01D9,Y            * 0C7C 30 A9 01 D9    0).Y
                    pshs      X                   * 0C80 34 10          4.
                    ldd       #1                  * 0C82 CC 00 01       L..
                    pshs      D                   * 0C85 34 06          4.
                    ldd       #131                * 0C87 CC 00 83       L..
                    pshs      D                   * 0C8A 34 06          4.
                    ldd       >$01B6,Y            * 0C8C EC A9 01 B6    l).6
                    pshs      D                   * 0C90 34 06          4.
                    lbsr      L0D73               * 0C92 17 00 DE       ..^
                    leas      $08,S               * 0C95 32 68          2h
                    cmpd      #-1                 * 0C97 10 83 FF FF    ....
                    bne       L0CBA               * 0C9B 26 1D          &.
                    ldd       >$01B2,Y            * 0C9D EC A9 01 B2    l).2
                    pshs      D                   * 0CA1 34 06          4.
                    leax      >L134C,PC           * 0CA3 30 8D 06 A5    0..%
                    pshs      X                   * 0CA7 34 10          4.
                    lbsr      L1440               * 0CA9 17 07 94       ...
                    leas      $04,S               * 0CAC 32 64          2d
L0CAE               ldd       #1                  * 0CAE CC 00 01       L..
                    pshs      D                   * 0CB1 34 06          4.
                    leax      >$0004,Y            * 0CB3 30 A9 00 04    0)..
                    lbra      L0D5D               * 0CB7 16 00 A3       ..#
L0CBA               ldb       >$01D9,Y            * 0CBA E6 A9 01 D9    f).Y
                    sex                           * 0CBE 1D             .
                    pshs      D                   * 0CBF 34 06          4.
                    ldb       >$01DA,Y            * 0CC1 E6 A9 01 DA    f).Z
                    sex                           * 0CC5 1D             .
                    coma                          * 0CC6 43             C
                    comb                          * 0CC7 53             S
                    cmpd      ,S++                * 0CC8 10 A3 E1       .#a
                    beq       L0CDA               * 0CCB 27 0D          '.
                    leax      >L1365,PC           * 0CCD 30 8D 06 94    0...
                    pshs      X                   * 0CD1 34 10          4.
                    lbsr      L1440               * 0CD3 17 07 6A       ..j
                    leas      $02,S               * 0CD6 32 62          2b
                    bra       L0CAE               * 0CD8 20 D4           T
L0CDA               ldb       >$01D9,Y            * 0CDA E6 A9 01 D9    f).Y
                    sex                           * 0CDE 1D             .
                    pshs      D                   * 0CDF 34 06          4.
                    ldb       $08,S               * 0CE1 E6 68          fh
                    sex                           * 0CE3 1D             .
                    cmpd      ,S++                * 0CE4 10 A3 E1       .#a
                    beq       L0CF7               * 0CE7 27 0E          '.
                    leax      >L1379,PC           * 0CE9 30 8D 06 8C    0...
                    pshs      X                   * 0CED 34 10          4.
                    lbsr      L1440               * 0CEF 17 07 4E       ..N
                    leas      $02,S               * 0CF2 32 62          2b
                    lbra      L0CAE               * 0CF4 16 FF B7       ..7
L0CF7               leax      >$01DB,Y            * 0CF7 30 A9 01 DB    0).[
                    pshs      X                   * 0CFB 34 10          4.
                    lbsr      L0E0B               * 0CFD 17 01 0B       ...
                    leas      $02,S               * 0D00 32 62          2b
                    sex                           * 0D02 1D             .
                    pshs      D                   * 0D03 34 06          4.
                    ldb       >$025B,Y            * 0D05 E6 A9 02 5B    f).[
                    sex                           * 0D09 1D             .
                    cmpd      ,S++                * 0D0A 10 A3 E1       .#a
                    beq       L0D32               * 0D0D 27 23          '#
                    ldb       >$025B,Y            * 0D0F E6 A9 02 5B    f).[
                    sex                           * 0D13 1D             .
                    pshs      D                   * 0D14 34 06          4.
                    leax      >$01DB,Y            * 0D16 30 A9 01 DB    0).[
                    pshs      X                   * 0D1A 34 10          4.
                    lbsr      L0E0B               * 0D1C 17 00 EC       ..l
                    leas      $02,S               * 0D1F 32 62          2b
                    sex                           * 0D21 1D             .
                    pshs      D                   * 0D22 34 06          4.
                    leax      >L1387,PC           * 0D24 30 8D 06 5F    0.._
                    pshs      X                   * 0D28 34 10          4.
                    lbsr      L1440               * 0D2A 17 07 13       ...
                    leas      $06,S               * 0D2D 32 66          2f
                    lbra      L0CAE               * 0D2F 16 FF 7C       ..|
L0D32               ldd       #128                * 0D32 CC 00 80       L..
                    pshs      D                   * 0D35 34 06          4.
                    leax      >$01DB,Y            * 0D37 30 A9 01 DB    0).[
                    pshs      X                   * 0D3B 34 10          4.
                    ldd       $06,S               * 0D3D EC 66          lf
                    pshs      D                   * 0D3F 34 06          4.
                    lbsr      L1FB1               * 0D41 17 12 6D       ..m
                    leas      $06,S               * 0D44 32 66          2f
                    ldb       $06,S               * 0D46 E6 66          ff
                    addd      #1                  * 0D48 C3 00 01       C..
                    stb       $06,S               * 0D4B E7 66          gf
                    ldd       $04,S               * 0D4D EC 64          ld
                    addd      #1                  * 0D4F C3 00 01       C..
                    std       $04,S               * 0D52 ED 64          md
                    ldd       #1                  * 0D54 CC 00 01       L..
                    pshs      D                   * 0D57 34 06          4.
                    leax      >$0002,Y            * 0D59 30 A9 00 02    0)..
L0D5D               pshs      X                   * 0D5D 34 10          4.
                    ldd       >$01B6,Y            * 0D5F EC A9 01 B6    l).6
                    pshs      D                   * 0D63 34 06          4.
                    lbsr      L1FB1               * 0D65 17 12 49       ..I
                    leas      $06,S               * 0D68 32 66          2f
L0D6A               lbra      L0A6A               * 0D6A 16 FC FD       .|}
L0D6D               leas      >$00CF,S            * 0D6D 32 E9 00 CF    2i.O
                    puls      PC,U                * 0D71 35 C0          5@
L0D73               pshs      U                   * 0D73 34 40          4@
                    ldd       #-78                * 0D75 CC FF B2       L.2
                    lbsr      L0111               * 0D78 17 F3 96       .s.
                    leas      -$04,S              * 0D7B 32 7C          2|
                    clra                          * 0D7D 4F             O
                    clrb                          * 0D7E 5F             _
                    std       0,S                 * 0D7F ED E4          md
                    bra       L0D83               * 0D81 20 00           .
L0D83               ldd       $08,S               * 0D83 EC 68          lh
                    pshs      D                   * 0D85 34 06          4.
                    lbsr      L2133               * 0D87 17 13 A9       ..)
                    leas      $02,S               * 0D8A 32 62          2b
                    std       $02,S               * 0D8C ED 62          mb
                    cmpd      #-1                 * 0D8E 10 83 FF FF    ....
                    bne       L0DC7               * 0D92 26 33          &3
                    ldd       0,S                 * 0D94 EC E4          ld
                    addd      #1                  * 0D96 C3 00 01       C..
                    std       0,S                 * 0D99 ED E4          md
                    subd      #1                  * 0D9B 83 00 01       ...
                    cmpd      #60                 * 0D9E 10 83 00 3C    ...<
                    ble       L0DBB               * 0DA2 2F 17          /.
                    clra                          * 0DA4 4F             O
                    clrb                          * 0DA5 5F             _
                    std       0,S                 * 0DA6 ED E4          md
                    ldd       $0C,S               * 0DA8 EC 6C          ll
                    addd      #-1                 * 0DAA C3 FF FF       C..
                    std       $0C,S               * 0DAD ED 6C          ml
                    subd      #-1                 * 0DAF 83 FF FF       ...
                    bgt       L0DC5               * 0DB2 2E 11          ..
                    ldd       #-1                 * 0DB4 CC FF FF       L..
                    bra       L0E07               * 0DB7 20 4E           N
                    fcb       $20                 * 0DB9 20
                    fcb       $0A                 * 0DBA 0A             .
L0DBB               ldd       #1                  * 0DBB CC 00 01       L..
                    pshs      D                   * 0DBE 34 06          4.
                    lbsr      L2067               * 0DC0 17 12 A4       ..$
                    leas      $02,S               * 0DC3 32 62          2b
L0DC5               bra       L0D83               * 0DC5 20 BC           <
L0DC7               ldd       $02,S               * 0DC7 EC 62          lb
                    cmpd      $0A,S               * 0DC9 10 A3 6A       .#j
                    bge       L0DF3               * 0DCC 2C 25          ,%
                    ldd       $02,S               * 0DCE EC 62          lb
                    pshs      D                   * 0DD0 34 06          4.
                    ldd       <$0010,S            * 0DD2 EC E8 10       lh.
                    pshs      D                   * 0DD5 34 06          4.
                    ldd       $0C,S               * 0DD7 EC 6C          ll
                    pshs      D                   * 0DD9 34 06          4.
                    lbsr      L1F80               * 0DDB 17 11 A2       .."
                    leas      $06,S               * 0DDE 32 66          2f
                    ldd       $0E,S               * 0DE0 EC 6E          ln
                    addd      $02,S               * 0DE2 E3 62          cb
                    std       $0E,S               * 0DE4 ED 6E          mn
                    ldd       $0A,S               * 0DE6 EC 6A          lj
                    subd      $02,S               * 0DE8 A3 62          #b
                    std       $0A,S               * 0DEA ED 6A          mj
                    clra                          * 0DEC 4F             O
                    clrb                          * 0DED 5F             _
                    std       0,S                 * 0DEE ED E4          md
                    lbra      L0D83               * 0DF0 16 FF 90       ...
L0DF3               ldd       $0A,S               * 0DF3 EC 6A          lj
                    pshs      D                   * 0DF5 34 06          4.
                    ldd       <$0010,S            * 0DF7 EC E8 10       lh.
                    pshs      D                   * 0DFA 34 06          4.
                    ldd       >$01B6,Y            * 0DFC EC A9 01 B6    l).6
                    pshs      D                   * 0E00 34 06          4.
                    lbsr      L1F80               * 0E02 17 11 7B       ..{
                    leas      $06,S               * 0E05 32 66          2f
L0E07               leas      $04,S               * 0E07 32 64          2d
                    puls      PC,U                * 0E09 35 C0          5@
L0E0B               pshs      U                   * 0E0B 34 40          4@
                    ldd       #-69                * 0E0D CC FF BB       L.;
                    lbsr      L0111               * 0E10 17 F2 FE       .r~
                    leas      -$03,S              * 0E13 32 7D          2}
                    clra                          * 0E15 4F             O
                    clrb                          * 0E16 5F             _
                    stb       $02,S               * 0E17 E7 62          gb
                    clra                          * 0E19 4F             O
                    clrb                          * 0E1A 5F             _
                    bra       L0E34               * 0E1B 20 17           .
L0E1D               ldb       $02,S               * 0E1D E6 62          fb
                    sex                           * 0E1F 1D             .
                    pshs      D                   * 0E20 34 06          4.
                    ldx       $09,S               * 0E22 AE 69          .i
                    ldd       $02,S               * 0E24 EC 62          lb
                    leax      D,X                 * 0E26 30 8B          0.
                    ldb       0,X                 * 0E28 E6 84          f.
                    sex                           * 0E2A 1D             .
                    addd      ,S++                * 0E2B E3 E1          ca
                    stb       $02,S               * 0E2D E7 62          gb
                    ldd       0,S                 * 0E2F EC E4          ld
                    addd      #1                  * 0E31 C3 00 01       C..
L0E34               std       0,S                 * 0E34 ED E4          md
                    ldd       0,S                 * 0E36 EC E4          ld
                    cmpd      #127                * 0E38 10 83 00 7F    ....
                    ble       L0E1D               * 0E3C 2F DF          /_
                    ldb       $02,S               * 0E3E E6 62          fb
                    leas      $03,S               * 0E40 32 63          2c
                    puls      PC,U                * 0E42 35 C0          5@
L0E44               pshs      U                   * 0E44 34 40          4@
                    ldd       #-74                * 0E46 CC FF B6       L.6
                    lbsr      L0111               * 0E49 17 F2 C5       .rE
                    ldd       >$01B6,Y            * 0E4C EC A9 01 B6    l).6
                    pshs      D                   * 0E50 34 06          4.
                    lbsr      L1F13               * 0E52 17 10 BE       ..>
                    leas      $02,S               * 0E55 32 62          2b
                    leax      >$01B8,Y            * 0E57 30 A9 01 B8    0).8
                    pshs      X                   * 0E5B 34 10          4.
                    ldd       >$01B4,Y            * 0E5D EC A9 01 B4    l).4
                    pshs      D                   * 0E61 34 06          4.
                    clra                          * 0E63 4F             O
                    clrb                          * 0E64 5F             _
                    pshs      D                   * 0E65 34 06          4.
                    lbsr      L1E95               * 0E67 17 10 2B       ..+
                    leas      $06,S               * 0E6A 32 66          2f
                    ldd       #1                  * 0E6C CC 00 01       L..
                    stb       >$01BC,Y            * 0E6F E7 A9 01 BC    g).<
                    ldd       #3                  * 0E73 CC 00 03       L..
                    stb       >$01C8,Y            * 0E76 E7 A9 01 C8    g).H
                    ldd       #5                  * 0E7A CC 00 05       L..
                    stb       >$01C9,Y            * 0E7D E7 A9 01 C9    g).I
                    ldd       #13                 * 0E81 CC 00 0D       L..
                    stb       >$01C3,Y            * 0E84 E7 A9 01 C3    g).C
                    leax      >$01B8,Y            * 0E88 30 A9 01 B8    0).8
                    pshs      X                   * 0E8C 34 10          4.
                    ldd       >$01B4,Y            * 0E8E EC A9 01 B4    l).4
                    pshs      D                   * 0E92 34 06          4.
                    clra                          * 0E94 4F             O
                    clrb                          * 0E95 5F             _
                    pshs      D                   * 0E96 34 06          4.
                    lbsr      L1ED0               * 0E98 17 10 35       ..5
                    leas      $06,S               * 0E9B 32 66          2f
                    clra                          * 0E9D 4F             O
                    clrb                          * 0E9E 5F             _
                    pshs      D                   * 0E9F 34 06          4.
                    lbsr      L2184               * 0EA1 17 12 E0       ..`
                    leas      $02,S               * 0EA4 32 62          2b
                    ldd       $04,S               * 0EA6 EC 64          ld
                    pshs      D                   * 0EA8 34 06          4.
                    leax      >L139E,PC           * 0EAA 30 8D 04 F0    0..p
                    pshs      X                   * 0EAE 34 10          4.
                    lbsr      L1440               * 0EB0 17 05 8D       ...
                    leas      $04,S               * 0EB3 32 64          2d
                    leax      >L13A2,PC           * 0EB5 30 8D 04 E9    0..i
                    pshs      X                   * 0EB9 34 10          4.
                    lbsr      L1440               * 0EBB 17 05 82       ...
                    leas      $02,S               * 0EBE 32 62          2b
                    ldd       $06,S               * 0EC0 EC 66          lf
                    pshs      D                   * 0EC2 34 06          4.
                    lbsr      L2127               * 0EC4 17 12 60       ..`
                    bra       L0F00               * 0EC7 20 37           7
L0EC9               pshs      U                   * 0EC9 34 40          4@
                    ldd       #-76                * 0ECB CC FF B4       L.4
                    lbsr      L0111               * 0ECE 17 F2 40       .r@
                    leas      -$02,S              * 0ED1 32 7E          2~
                    ldd       $06,S               * 0ED3 EC 66          lf
                    pshs      D                   * 0ED5 34 06          4.
                    ldd       #1                  * 0ED7 CC 00 01       L..
                    pshs      D                   * 0EDA 34 06          4.
                    lbsr      L1E95               * 0EDC 17 0F B6       ..6
                    leas      $04,S               * 0EDF 32 64          2d
                    stb       $01,S               * 0EE1 E7 61          ga
                    bne       L0EF9               * 0EE3 26 14          &.
                    ldd       #1                  * 0EE5 CC 00 01       L..
                    pshs      D                   * 0EE8 34 06          4.
                    leax      $02,S               * 0EEA 30 62          0b
                    pshs      X                   * 0EEC 34 10          4.
                    ldd       $0A,S               * 0EEE EC 6A          lj
                    pshs      D                   * 0EF0 34 06          4.
                    lbsr      L1F80               * 0EF2 17 10 8B       ...
                    leas      $06,S               * 0EF5 32 66          2f
                    bra       L0EFD               * 0EF7 20 04           .
L0EF9               clra                          * 0EF9 4F             O
                    clrb                          * 0EFA 5F             _
                    stb       0,S                 * 0EFB E7 E4          gd
L0EFD               ldb       0,S                 * 0EFD E6 E4          fd
                    sex                           * 0EFF 1D             .
L0F00               leas      $02,S               * 0F00 32 62          2b
                    puls      PC,U                * 0F02 35 C0          5@
L0F04               fcc       "/t2"               * 0F04 2F 74 32       /t2
                    fcb       $00                 * 0F07 00             .
L0F08               fcc       "Cannot open /t2"   * 0F08 43 61 6E 6E 6F 74 20 6F 70 65 6E 20 2F 74 32 Cannot open /t2
                    fcb       $00                 * 0F17 00             .
L0F18               fcc       "Cannot open %s"    * 0F18 43 61 6E 6E 6F 74 20 6F 70 65 6E 20 25 73 Cannot open %s
                    fcb       $0D                 * 0F26 0D             .
                    fcb       $00                 * 0F27 00             .
L0F28               fcc       "Quik terminal Version 1.00    " * 0F28 51 75 69 6B 20 74 65 72 6D 69 6E 61 6C 20 56 65 72 73 69 6F 6E 20 31 2E 30 30 20 20 20 20 Quik terminal Version 1.00
                    fcb       $0D                 * 0F46 0D             .
                    fcb       $00                 * 0F47 00             .
L0F48               fcc       "By Alpha Software Technologies" * 0F48 42 79 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 By Alpha Software Technologies
                    fcb       $0D                 * 0F66 0D             .
                    fcb       $00                 * 0F67 00             .
L0F68               fcc       "Released for shareware, 1988  " * 0F68 52 65 6C 65 61 73 65 64 20 66 6F 72 20 73 68 61 72 65 77 61 72 65 2C 20 31 39 38 38 20 20 Released for shareware, 1988
                    fcb       $0D                 * 0F86 0D             .
                    fcb       $00                 * 0F87 00             .
L0F88               fcb       $0D                 * 0F88 0D             .
                    fcb       $00                 * 0F89 00             .
L0F8A               fcc       "Press <ALT><X> to exit          <ALT><T> to transfer files" * 0F8A 50 72 65 73 73 20 3C 41 4C 54 3E 3C 58 3E 20 74 6F 20 65 78 69 74 20 20 20 20 20 20 20 20 20 20 3C 41 4C 54 3E 3C 54 3E 20 74 6F 20 74 72 61 6E 73 66 65 72 20 66 6
                    fcb       $0D                 * 0FC4 0D             .
                    fcb       $00                 * 0FC5 00             .
L0FC6               fcc       "----------------------------------------------------------------" * 0FC6 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 1006 0D             .
                    fcb       $00                 * 1007 00             .
L1008               fcc       "Quik terminal...exited" * 1008 51 75 69 6B 20 74 65 72 6D 69 6E 61 6C 2E 2E 2E 65 78 69 74 65 64 Quik terminal...exited
                    fcb       $0D                 * 101E 0D             .
                    fcb       $00                 * 101F 00             .
L1020               fcb       $0D                 * 1020 0D             .
                    fcc       "For a free catalog please write to:" * 1021 46 6F 72 20 61 20 66 72 65 65 20 63 61 74 61 6C 6F 67 20 70 6C 65 61 73 65 20 77 72 69 74 65 20 74 6F 3A For a free catalog please write to:
                    fcb       $0D                 * 1044 0D             .
                    fcb       $00                 * 1045 00             .
L1046               fcb       $0D                 * 1046 0D             .
                    fcc       "Alpha Software Technologies" * 1047 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Alpha Software Technologies
                    fcb       $0D                 * 1062 0D             .
                    fcb       $00                 * 1063 00             .
L1064               fcc       "2810 Buffon St."   * 1064 32 38 31 30 20 42 75 66 66 6F 6E 20 53 74 2E 2810 Buffon St.
                    fcb       $0D                 * 1073 0D             .
                    fcb       $00                 * 1074 00             .
L1075               fcc       "Chalmette, La. 70043" * 1075 43 68 61 6C 6D 65 74 74 65 2C 20 4C 61 2E 20 37 30 30 34 33 Chalmette, La. 70043
                    fcb       $0D                 * 1089 0D             .
                    fcb       $00                 * 108A 00             .
L108B               fcb       $0D                 * 108B 0D             .
                    fcc       "or leave mail for 'ALPHASOFT' on DELPHI" * 108C 6F 72 20 6C 65 61 76 65 20 6D 61 69 6C 20 66 6F 72 20 27 41 4C 50 48 41 53 4F 46 54 27 20 6F 6E 20 44 45 4C 50 48 49 or leave mail for 'ALPHASOFT' on DELPHI
                    fcb       $0D                 * 10B3 0D             .
                    fcb       $00                 * 10B4 00             .
L10B5               fcc       "[R]ecieve or [S]end a file:" * 10B5 5B 52 5D 65 63 69 65 76 65 20 6F 72 20 5B 53 5D 65 6E 64 20 61 20 66 69 6C 65 3A [R]ecieve or [S]end a file:
                    fcb       $00                 * 10D0 00             .
L10D1               fcb       $0D                 * 10D1 0D             .
                    fcb       $00                 * 10D2 00             .
L10D3               fcc       "Enter filename to send:" * 10D3 45 6E 74 65 72 20 66 69 6C 65 6E 61 6D 65 20 74 6F 20 73 65 6E 64 3A Enter filename to send:
                    fcb       $00                 * 10EA 00             .
L10EB               fcc       "Cannot open file, error %d" * 10EB 43 61 6E 6E 6F 74 20 6F 70 65 6E 20 66 69 6C 65 2C 20 65 72 72 6F 72 20 25 64 Cannot open file, error %d
                    fcb       $0D                 * 1105 0D             .
                    fcb       $00                 * 1106 00             .
L1107               fcc       "Sending file                    press <ALT><Q> to abort" * 1107 53 65 6E 64 69 6E 67 20 66 69 6C 65 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 70 72 65 73 73 20 3C 41 4C 54 3E 3C 51 3E 20 74 6F 20 61 62 6F 72 74 S
                    fcb       $0D                 * 113E 0D             .
                    fcb       $00                 * 113F 00             .
L1140               fcc       "----------------------------------------------------------------" * 1140 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 1180 0D             .
                    fcb       $00                 * 1181 00             .
L1182               fcb       $0D                 * 1182 0D             .
                    fcc       "Sending block #%05u " * 1183 53 65 6E 64 69 6E 67 20 62 6C 6F 63 6B 20 23 25 30 35 75 20 Sending block #%05u
                    fcb       $00                 * 1197 00             .
L1198               fcc       "File transfer aborted!" * 1198 46 69 6C 65 20 74 72 61 6E 73 66 65 72 20 61 62 6F 72 74 65 64 21 File transfer aborted!
                    fcb       $0D                 * 11AE 0D             .
                    fcb       $00                 * 11AF 00             .
L11B0               fcc       "File transfer aborted!" * 11B0 46 69 6C 65 20 74 72 61 6E 73 66 65 72 20 61 62 6F 72 74 65 64 21 File transfer aborted!
                    fcb       $0D                 * 11C6 0D             .
                    fcb       $00                 * 11C7 00             .
L11C8               fcc       "File transfer complete." * 11C8 46 69 6C 65 20 74 72 61 6E 73 66 65 72 20 63 6F 6D 70 6C 65 74 65 2E File transfer complete.
                    fcb       $0D                 * 11DF 0D             .
                    fcb       $00                 * 11E0 00             .
L11E1               fcb       $0D                 * 11E1 0D             .
                    fcc       "Sending block #%05u " * 11E2 53 65 6E 64 69 6E 67 20 62 6C 6F 63 6B 20 23 25 30 35 75 20 Sending block #%05u
                    fcb       $00                 * 11F6 00             .
L11F7               fcc       "Enter filename to recieve:" * 11F7 45 6E 74 65 72 20 66 69 6C 65 6E 61 6D 65 20 74 6F 20 72 65 63 69 65 76 65 3A Enter filename to recieve:
                    fcb       $00                 * 1211 00             .
L1212               fcc       "File exists!"      * 1212 46 69 6C 65 20 65 78 69 73 74 73 21 File exists!
                    fcb       $0D                 * 121E 0D             .
                    fcb       $00                 * 121F 00             .
L1220               fcc       "Cannot open file, error %d" * 1220 43 61 6E 6E 6F 74 20 6F 70 65 6E 20 66 69 6C 65 2C 20 65 72 72 6F 72 20 25 64 Cannot open file, error %d
                    fcb       $0D                 * 123A 0D             .
                    fcb       $00                 * 123B 00             .
L123C               fcc       "Recieving file                  press <ALT><Q> to abort" * 123C 52 65 63 69 65 76 69 6E 67 20 66 69 6C 65 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 70 72 65 73 73 20 3C 41 4C 54 3E 3C 51 3E 20 74 6F 20 61 62 6F 72 74 R
                    fcb       $0D                 * 1273 0D             .
                    fcb       $00                 * 1274 00             .
L1275               fcc       "----------------------------------------------------------------" * 1275 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 12B5 0D             .
                    fcb       $00                 * 12B6 00             .
L12B7               fcb       $0D                 * 12B7 0D             .
                    fcc       "File transfer aborted!" * 12B8 46 69 6C 65 20 74 72 61 6E 73 66 65 72 20 61 62 6F 72 74 65 64 21 File transfer aborted!
                    fcb       $0D                 * 12CE 0D             .
                    fcb       $00                 * 12CF 00             .
L12D0               fcb       $0D                 * 12D0 0D             .
                    fcc       "Recieving block #%05u " * 12D1 52 65 63 69 65 76 69 6E 67 20 62 6C 6F 63 6B 20 23 25 30 35 75 20 Recieving block #%05u
                    fcb       $00                 * 12E7 00             .
L12E8               fcc       "Timeout/read error" * 12E8 54 69 6D 65 6F 75 74 2F 72 65 61 64 20 65 72 72 6F 72 Timeout/read error
                    fcb       $0D                 * 12FA 0D             .
                    fcb       $00                 * 12FB 00             .
L12FC               fcc       "File receive successful." * 12FC 46 69 6C 65 20 72 65 63 65 69 76 65 20 73 75 63 63 65 73 73 66 75 6C 2E File receive successful.
                    fcb       $0D                 * 1314 0D             .
                    fcb       $00                 * 1315 00             .
L1316               fcc       "Too many errors...I give up!" * 1316 54 6F 6F 20 6D 61 6E 79 20 65 72 72 6F 72 73 2E 2E 2E 49 20 67 69 76 65 20 75 70 21 Too many errors...I give up!
                    fcb       $0D                 * 1332 0D             .
                    fcb       $00                 * 1333 00             .
L1334               fcc       "File transfer aborted!" * 1334 46 69 6C 65 20 74 72 61 6E 73 66 65 72 20 61 62 6F 72 74 65 64 21 File transfer aborted!
                    fcb       $0D                 * 134A 0D             .
                    fcb       $00                 * 134B 00             .
L134C               fcc       "Timeout/read error %d!!" * 134C 54 69 6D 65 6F 75 74 2F 72 65 61 64 20 65 72 72 6F 72 20 25 64 21 21 Timeout/read error %d!!
                    fcb       $0D                 * 1363 0D             .
                    fcb       $00                 * 1364 00             .
L1365               fcc       "Block # scrambled!" * 1365 42 6C 6F 63 6B 20 23 20 73 63 72 61 6D 62 6C 65 64 21 Block # scrambled!
                    fcb       $0D                 * 1377 0D             .
                    fcb       $00                 * 1378 00             .
L1379               fcc       "Bad block #!"      * 1379 42 61 64 20 62 6C 6F 63 6B 20 23 21 Bad block #!
                    fcb       $0D                 * 1385 0D             .
                    fcb       $00                 * 1386 00             .
L1387               fcc       "Bad checksum! %d / %d" * 1387 42 61 64 20 63 68 65 63 6B 73 75 6D 21 20 25 64 20 2F 20 25 64 Bad checksum! %d / %d
                    fcb       $0D                 * 139C 0D             .
                    fcb       $00                 * 139D 00             .
L139E               fcb       $25                 * 139E 25             %
                    fcb       $73                 * 139F 73             s
                    fcb       $0D                 * 13A0 0D             .
                    fcb       $00                 * 13A1 00             .
L13A2               fcc       "Stupid terminal...exited" * 13A2 53 74 75 70 69 64 20 74 65 72 6D 69 6E 61 6C 2E 2E 2E 65 78 69 74 65 64 Stupid terminal...exited
                    fcb       $0D                 * 13BA 0D             .
                    fcb       $00                 * 13BB 00             .
                    fcb       $34                 * 13BC 34             4
                    fcb       $46                 * 13BD 46             F
                    fcb       $EE                 * 13BE EE             n
                    fcb       $66                 * 13BF 66             f
                    fcb       $20                 * 13C0 20
                    fcb       $04                 * 13C1 04             .
                    fcb       $EC                 * 13C2 EC             l
                    fcb       $E4                 * 13C3 E4             d
                    fcb       $E7                 * 13C4 E7             g
                    fcb       $C0                 * 13C5 C0             @
                    fcb       $30                 * 13C6 30             0
                    fcb       $A9                 * 13C7 A9             )
                    fcb       $00                 * 13C8 00             .
                    fcb       $13                 * 13C9 13             .
                    fcb       $34                 * 13CA 34             4
                    fcb       $10                 * 13CB 10             .
                    fcb       $17                 * 13CC 17             .
                    fcb       $07                 * 13CD 07             .
                    fcb       $90                 * 13CE 90             .
                    fcb       $32                 * 13CF 32             2
                    fcb       $62                 * 13D0 62             b
                    fcb       $ED                 * 13D1 ED             m
                    fcb       $E4                 * 13D2 E4             d
                    fcb       $10                 * 13D3 10             .
                    fcb       $83                 * 13D4 83             .
                    fcb       $00                 * 13D5 00             .
                    fcb       $0D                 * 13D6 0D             .
                    fcb       $27                 * 13D7 27             '
                    fcb       $08                 * 13D8 08             .
                    fcb       $EC                 * 13D9 EC             l
                    fcb       $E4                 * 13DA E4             d
                    fcb       $10                 * 13DB 10             .
                    fcb       $83                 * 13DC 83             .
                    fcb       $FF                 * 13DD FF             .
                    fcb       $FF                 * 13DE FF             .
                    fcb       $26                 * 13DF 26             &
                    fcb       $E1                 * 13E0 E1             a
                    fcb       $EC                 * 13E1 EC             l
                    fcb       $E4                 * 13E2 E4             d
                    fcb       $10                 * 13E3 10             .
                    fcb       $83                 * 13E4 83             .
                    fcb       $FF                 * 13E5 FF             .
                    fcb       $FF                 * 13E6 FF             .
                    fcb       $26                 * 13E7 26             &
                    fcb       $04                 * 13E8 04             .
                    fcc       "O_ "               * 13E9 4F 5F 20       O_
                    fcb       $06                 * 13EC 06             .
                    fcb       $4F                 * 13ED 4F             O
                    fcb       $5F                 * 13EE 5F             _
                    fcb       $E7                 * 13EF E7             g
                    fcb       $C4                 * 13F0 C4             D
                    fcb       $EC                 * 13F1 EC             l
                    fcc       "f2b5"              * 13F2 66 32 62 35    f2b5
                    fcb       $C0                 * 13F6 C0             @
L13F7               pshs      U                   * 13F7 34 40          4@
                    ldu       $06,S               * 13F9 EE 66          nf
                    leas      -$04,S              * 13FB 32 7C          2|
                    ldd       $08,S               * 13FD EC 68          lh
                    std       0,S                 * 13FF ED E4          md
                    bra       L1411               * 1401 20 0E           .
L1403               ldd       $02,S               * 1403 EC 62          lb
                    ldx       0,S                 * 1405 AE E4          .d
                    leax      $01,X               * 1407 30 01          0.
                    stx       0,S                 * 1409 AF E4          /d
                    stb       -$01,X              * 140B E7 1F          g.
                    cmpb      #13                 * 140D C1 0D          A.
                    beq       L142A               * 140F 27 19          '.
L1411               tfr       U,D                 * 1411 1F 30          .0
                    leau      -$01,U              * 1413 33 5F          3_
                    std       -$02,S              * 1415 ED 7E          m~
                    ble       L142A               * 1417 2F 11          /.
                    ldd       $0C,S               * 1419 EC 6C          ll
                    pshs      D                   * 141B 34 06          4.
                    lbsr      L1B5F               * 141D 17 07 3F       ..?
                    leas      $02,S               * 1420 32 62          2b
                    std       $02,S               * 1422 ED 62          mb
                    cmpd      #-1                 * 1424 10 83 FF FF    ....
                    bne       L1403               * 1428 26 D9          &Y
L142A               clra                          * 142A 4F             O
                    clrb                          * 142B 5F             _
                    stb       [,S]                * 142C E7 F4          gt
                    ldd       $02,S               * 142E EC 62          lb
                    cmpd      #-1                 * 1430 10 83 FF FF    ....
                    bne       L143A               * 1434 26 04          &.
                    clra                          * 1436 4F             O
                    clrb                          * 1437 5F             _
                    bra       L143C               * 1438 20 02           .
L143A               ldd       $08,S               * 143A EC 68          lh
L143C               leas      $04,S               * 143C 32 64          2d
                    puls      PC,U                * 143E 35 C0          5@
L1440               pshs      U                   * 1440 34 40          4@
                    leax      >$0020,Y            * 1442 30 A9 00 20    0).
                    stx       >$02DA,Y            * 1446 AF A9 02 DA    /).Z
                    leax      $06,S               * 144A 30 66          0f
                    pshs      X                   * 144C 34 10          4.
                    ldd       $06,S               * 144E EC 66          lf
                    bra       L1460               * 1450 20 0E           .
                    fcb       $34                 * 1452 34             4
                    fcb       $40                 * 1453 40             @
                    fcb       $EC                 * 1454 EC             l
                    fcb       $64                 * 1455 64             d
                    fcb       $ED                 * 1456 ED             m
                    fcb       $A9                 * 1457 A9             )
                    fcb       $02                 * 1458 02             .
                    fcb       $DA                 * 1459 DA             Z
                    fcc       "0h4"               * 145A 30 68 34       0h4
                    fcb       $10                 * 145D 10             .
                    fcb       $EC                 * 145E EC             l
                    fcb       $68                 * 145F 68             h
L1460               pshs      D                   * 1460 34 06          4.
                    leax      >L1918,PC           * 1462 30 8D 04 B2    0..2
                    pshs      X                   * 1466 34 10          4.
                    bsr       L1492               * 1468 8D 28          .(
                    leas      $06,S               * 146A 32 66          2f
                    puls      PC,U                * 146C 35 C0          5@
                    fcb       $34                 * 146E 34             4
                    fcb       $40                 * 146F 40             @
                    fcb       $EC                 * 1470 EC             l
                    fcb       $64                 * 1471 64             d
                    fcb       $ED                 * 1472 ED             m
                    fcb       $A9                 * 1473 A9             )
                    fcb       $02                 * 1474 02             .
                    fcb       $DA                 * 1475 DA             Z
                    fcc       "0h4"               * 1476 30 68 34       0h4
                    fcb       $10                 * 1479 10             .
                    fcb       $EC                 * 147A EC             l
                    fcb       $68                 * 147B 68             h
                    fcb       $34                 * 147C 34             4
                    fcb       $06                 * 147D 06             .
                    fcb       $30                 * 147E 30             0
                    fcb       $8D                 * 147F 8D             .
                    fcb       $04                 * 1480 04             .
                    fcb       $A9                 * 1481 A9             )
                    fcb       $34                 * 1482 34             4
                    fcb       $10                 * 1483 10             .
                    fcb       $8D                 * 1484 8D             .
                    fcb       $0C                 * 1485 0C             .
                    fcc       "2fO_"              * 1486 32 66 4F 5F    2fO_
                    fcb       $E7                 * 148A E7             g
                    fcb       $B9                 * 148B B9             9
                    fcb       $02                 * 148C 02             .
                    fcb       $DA                 * 148D DA             Z
                    fcb       $EC                 * 148E EC             l
                    fcb       $64                 * 148F 64             d
                    fcb       $35                 * 1490 35             5
                    fcb       $C0                 * 1491 C0             @
L1492               pshs      U                   * 1492 34 40          4@
                    ldu       $06,S               * 1494 EE 66          nf
                    leas      -$0B,S              * 1496 32 75          2u
                    bra       L14AA               * 1498 20 10           .
L149A               ldb       $08,S               * 149A E6 68          fh
                    lbeq      L16DB               * 149C 10 27 02 3B    .'.;
                    ldb       $08,S               * 14A0 E6 68          fh
                    sex                           * 14A2 1D             .
                    pshs      D                   * 14A3 34 06          4.
                    jsr       [<$11,S]            * 14A5 AD F8 11       -x.
                    leas      $02,S               * 14A8 32 62          2b
L14AA               ldb       ,U+                 * 14AA E6 C0          f@
                    stb       $08,S               * 14AC E7 68          gh
                    cmpb      #37                 * 14AE C1 25          A%
                    bne       L149A               * 14B0 26 E8          &h
                    ldb       ,U+                 * 14B2 E6 C0          f@
                    stb       $08,S               * 14B4 E7 68          gh
                    clra                          * 14B6 4F             O
                    clrb                          * 14B7 5F             _
                    std       $02,S               * 14B8 ED 62          mb
                    std       $06,S               * 14BA ED 66          mf
                    ldb       $08,S               * 14BC E6 68          fh
                    cmpb      #45                 * 14BE C1 2D          A-
                    bne       L14CF               * 14C0 26 0D          &.
                    ldd       #1                  * 14C2 CC 00 01       L..
                    std       >$02F0,Y            * 14C5 ED A9 02 F0    m).p
                    ldb       ,U+                 * 14C9 E6 C0          f@
                    stb       $08,S               * 14CB E7 68          gh
                    bra       L14D5               * 14CD 20 06           .
L14CF               clra                          * 14CF 4F             O
                    clrb                          * 14D0 5F             _
                    std       >$02F0,Y            * 14D1 ED A9 02 F0    m).p
L14D5               ldb       $08,S               * 14D5 E6 68          fh
                    cmpb      #48                 * 14D7 C1 30          A0
                    bne       L14E0               * 14D9 26 05          &.
                    ldd       #48                 * 14DB CC 00 30       L.0
                    bra       L14E3               * 14DE 20 03           .
L14E0               ldd       #32                 * 14E0 CC 00 20       L.
L14E3               std       >$02F2,Y            * 14E3 ED A9 02 F2    m).r
                    bra       L1503               * 14E7 20 1A           .
L14E9               ldd       $06,S               * 14E9 EC 66          lf
                    pshs      D                   * 14EB 34 06          4.
                    ldd       #10                 * 14ED CC 00 0A       L..
                    lbsr      L1E13               * 14F0 17 09 20       ..
                    pshs      D                   * 14F3 34 06          4.
                    ldb       $0A,S               * 14F5 E6 6A          fj
                    sex                           * 14F7 1D             .
                    addd      #-48                * 14F8 C3 FF D0       C.P
                    addd      ,S++                * 14FB E3 E1          ca
                    std       $06,S               * 14FD ED 66          mf
                    ldb       ,U+                 * 14FF E6 C0          f@
                    stb       $08,S               * 1501 E7 68          gh
L1503               ldb       $08,S               * 1503 E6 68          fh
                    sex                           * 1505 1D             .
                    leax      >$00E4,Y            * 1506 30 A9 00 E4    0).d
                    leax      D,X                 * 150A 30 8B          0.
                    ldb       0,X                 * 150C E6 84          f.
                    clra                          * 150E 4F             O
                    andb      #8                  * 150F C4 08          D.
                    bne       L14E9               * 1511 26 D6          &V
                    ldb       $08,S               * 1513 E6 68          fh
                    cmpb      #46                 * 1515 C1 2E          A.
                    bne       L154C               * 1517 26 33          &3
                    ldd       #1                  * 1519 CC 00 01       L..
                    std       $04,S               * 151C ED 64          md
                    bra       L1536               * 151E 20 16           .
L1520               ldd       $02,S               * 1520 EC 62          lb
                    pshs      D                   * 1522 34 06          4.
                    ldd       #10                 * 1524 CC 00 0A       L..
                    lbsr      L1E13               * 1527 17 08 E9       ..i
                    pshs      D                   * 152A 34 06          4.
                    ldb       $0A,S               * 152C E6 6A          fj
                    sex                           * 152E 1D             .
                    addd      #-48                * 152F C3 FF D0       C.P
                    addd      ,S++                * 1532 E3 E1          ca
                    std       $02,S               * 1534 ED 62          mb
L1536               ldb       ,U+                 * 1536 E6 C0          f@
                    stb       $08,S               * 1538 E7 68          gh
                    ldb       $08,S               * 153A E6 68          fh
                    sex                           * 153C 1D             .
                    leax      >$00E4,Y            * 153D 30 A9 00 E4    0).d
                    leax      D,X                 * 1541 30 8B          0.
                    ldb       0,X                 * 1543 E6 84          f.
                    clra                          * 1545 4F             O
                    andb      #8                  * 1546 C4 08          D.
                    bne       L1520               * 1548 26 D6          &V
                    bra       L1550               * 154A 20 04           .
L154C               clra                          * 154C 4F             O
                    clrb                          * 154D 5F             _
                    std       $04,S               * 154E ED 64          md
L1550               ldb       $08,S               * 1550 E6 68          fh
                    sex                           * 1552 1D             .
                    tfr       D,X                 * 1553 1F 01          ..
                    lbra      L167E               * 1555 16 01 26       ..&
L1558               ldd       $06,S               * 1558 EC 66          lf
                    pshs      D                   * 155A 34 06          4.
                    ldx       <$0015,S            * 155C AE E8 15       .h.
                    leax      $02,X               * 155F 30 02          0.
                    stx       <$0015,S            * 1561 AF E8 15       /h.
                    ldd       -$02,X              * 1564 EC 1E          l.
                    pshs      D                   * 1566 34 06          4.
                    lbsr      L16DF               * 1568 17 01 74       ..t
                    bra       L1580               * 156B 20 13           .
L156D               ldd       $06,S               * 156D EC 66          lf
                    pshs      D                   * 156F 34 06          4.
                    ldx       <$0015,S            * 1571 AE E8 15       .h.
                    leax      $02,X               * 1574 30 02          0.
                    stx       <$0015,S            * 1576 AF E8 15       /h.
                    ldd       -$02,X              * 1579 EC 1E          l.
                    pshs      D                   * 157B 34 06          4.
                    lbsr      L179C               * 157D 17 02 1C       ...
L1580               std       0,S                 * 1580 ED E4          md
                    lbra      L1664               * 1582 16 00 DF       .._
L1585               ldd       $06,S               * 1585 EC 66          lf
                    pshs      D                   * 1587 34 06          4.
                    ldb       $0A,S               * 1589 E6 6A          fj
                    sex                           * 158B 1D             .
                    leax      >$00E4,Y            * 158C 30 A9 00 E4    0).d
                    leax      D,X                 * 1590 30 8B          0.
                    ldb       0,X                 * 1592 E6 84          f.
                    clra                          * 1594 4F             O
                    andb      #2                  * 1595 C4 02          D.
                    pshs      D                   * 1597 34 06          4.
                    ldx       <$0017,S            * 1599 AE E8 17       .h.
                    leax      $02,X               * 159C 30 02          0.
                    stx       <$0017,S            * 159E AF E8 17       /h.
                    ldd       -$02,X              * 15A1 EC 1E          l.
                    pshs      D                   * 15A3 34 06          4.
                    lbsr      L17E4               * 15A5 17 02 3C       ..<
                    lbra      L1660               * 15A8 16 00 B5       ..5
L15AB               ldd       $06,S               * 15AB EC 66          lf
                    pshs      D                   * 15AD 34 06          4.
                    ldx       <$0015,S            * 15AF AE E8 15       .h.
                    leax      $02,X               * 15B2 30 02          0.
                    stx       <$0015,S            * 15B4 AF E8 15       /h.
                    ldd       -$02,X              * 15B7 EC 1E          l.
                    pshs      D                   * 15B9 34 06          4.
                    leax      >$02DC,Y            * 15BB 30 A9 02 DC    0).\
                    pshs      X                   * 15BF 34 10          4.
                    lbsr      L1723               * 15C1 17 01 5F       .._
                    lbra      L1660               * 15C4 16 00 99       ...
L15C7               ldd       $04,S               * 15C7 EC 64          ld
                    bne       L15D0               * 15C9 26 05          &.
                    ldd       #6                  * 15CB CC 00 06       L..
                    std       $02,S               * 15CE ED 62          mb
L15D0               ldd       $06,S               * 15D0 EC 66          lf
                    pshs      D                   * 15D2 34 06          4.
                    leax      <$0015,S            * 15D4 30 E8 15       0h.
                    pshs      X                   * 15D7 34 10          4.
                    ldd       $06,S               * 15D9 EC 66          lf
                    pshs      D                   * 15DB 34 06          4.
                    ldb       $0E,S               * 15DD E6 6E          fn
                    sex                           * 15DF 1D             .
                    pshs      D                   * 15E0 34 06          4.
                    lbsr      L1D81               * 15E2 17 07 9C       ...
                    leas      $06,S               * 15E5 32 66          2f
                    lbra      L1662               * 15E7 16 00 78       ..x
L15EA               ldx       <$0013,S            * 15EA AE E8 13       .h.
                    leax      $02,X               * 15ED 30 02          0.
                    stx       <$0013,S            * 15EF AF E8 13       /h.
                    ldd       -$02,X              * 15F2 EC 1E          l.
                    lbra      L1674               * 15F4 16 00 7D       ..}
L15F7               ldx       <$0013,S            * 15F7 AE E8 13       .h.
                    leax      $02,X               * 15FA 30 02          0.
                    stx       <$0013,S            * 15FC AF E8 13       /h.
                    ldd       -$02,X              * 15FF EC 1E          l.
                    std       $09,S               * 1601 ED 69          mi
                    ldd       $04,S               * 1603 EC 64          ld
                    beq       L163F               * 1605 27 38          '8
                    ldd       $09,S               * 1607 EC 69          li
                    std       $04,S               * 1609 ED 64          md
                    bra       L1619               * 160B 20 0C           .
L160D               ldb       [<$09,S]            * 160D E6 F8 09       fx.
                    beq       L1625               * 1610 27 13          '.
                    ldd       $09,S               * 1612 EC 69          li
                    addd      #1                  * 1614 C3 00 01       C..
                    std       $09,S               * 1617 ED 69          mi
L1619               ldd       $02,S               * 1619 EC 62          lb
                    addd      #-1                 * 161B C3 FF FF       C..
                    std       $02,S               * 161E ED 62          mb
                    subd      #-1                 * 1620 83 FF FF       ...
                    bne       L160D               * 1623 26 E8          &h
L1625               ldd       $06,S               * 1625 EC 66          lf
                    pshs      D                   * 1627 34 06          4.
                    ldd       $0B,S               * 1629 EC 6B          lk
                    subd      $06,S               * 162B A3 66          #f
                    pshs      D                   * 162D 34 06          4.
                    ldd       $08,S               * 162F EC 68          lh
                    pshs      D                   * 1631 34 06          4.
                    ldd       <$0015,S            * 1633 EC E8 15       lh.
                    pshs      D                   * 1636 34 06          4.
                    lbsr      L184F               * 1638 17 02 14       ...
                    leas      $08,S               * 163B 32 68          2h
                    bra       L166E               * 163D 20 2F           /
L163F               ldd       $06,S               * 163F EC 66          lf
                    pshs      D                   * 1641 34 06          4.
                    ldd       $0B,S               * 1643 EC 6B          lk
                    bra       L1662               * 1645 20 1B           .
L1647               ldb       ,U+                 * 1647 E6 C0          f@
                    stb       $08,S               * 1649 E7 68          gh
                    bra       L164F               * 164B 20 02           .
                    fcb       $32                 * 164D 32             2
                    fcb       $15                 * 164E 15             .
L164F               ldd       $06,S               * 164F EC 66          lf
                    pshs      D                   * 1651 34 06          4.
                    leax      <$0015,S            * 1653 30 E8 15       0h.
                    pshs      X                   * 1656 34 10          4.
                    ldb       $0C,S               * 1658 E6 6C          fl
                    sex                           * 165A 1D             .
                    pshs      D                   * 165B 34 06          4.
                    lbsr      L1D43               * 165D 17 06 E3       ..c
L1660               leas      $04,S               * 1660 32 64          2d
L1662               pshs      D                   * 1662 34 06          4.
L1664               ldd       <$0013,S            * 1664 EC E8 13       lh.
                    pshs      D                   * 1667 34 06          4.
                    lbsr      L18B1               * 1669 17 02 45       ..E
                    leas      $06,S               * 166C 32 66          2f
L166E               lbra      L14AA               * 166E 16 FE 39       .~9
L1671               ldb       $08,S               * 1671 E6 68          fh
                    sex                           * 1673 1D             .
L1674               pshs      D                   * 1674 34 06          4.
                    jsr       [<$11,S]            * 1676 AD F8 11       -x.
                    leas      $02,S               * 1679 32 62          2b
                    lbra      L14AA               * 167B 16 FE 2C       .~,
L167E               cmpx      #100                * 167E 8C 00 64       ..d
                    lbeq      L1558               * 1681 10 27 FE D3    .'~S
                    cmpx      #111                * 1685 8C 00 6F       ..o
                    lbeq      L156D               * 1688 10 27 FE E1    .'~a
                    cmpx      #120                * 168C 8C 00 78       ..x
                    lbeq      L1585               * 168F 10 27 FE F2    .'~r
                    cmpx      #88                 * 1693 8C 00 58       ..X
                    lbeq      L1585               * 1696 10 27 FE EB    .'~k
                    cmpx      #117                * 169A 8C 00 75       ..u
                    lbeq      L15AB               * 169D 10 27 FF 0A    .'..
                    cmpx      #102                * 16A1 8C 00 66       ..f
                    lbeq      L15C7               * 16A4 10 27 FF 1F    .'..
                    cmpx      #101                * 16A8 8C 00 65       ..e
                    lbeq      L15C7               * 16AB 10 27 FF 18    .'..
                    cmpx      #103                * 16AF 8C 00 67       ..g
                    lbeq      L15C7               * 16B2 10 27 FF 11    .'..
                    cmpx      #69                 * 16B6 8C 00 45       ..E
                    lbeq      L15C7               * 16B9 10 27 FF 0A    .'..
                    cmpx      #71                 * 16BD 8C 00 47       ..G
                    lbeq      L15C7               * 16C0 10 27 FF 03    .'..
                    cmpx      #99                 * 16C4 8C 00 63       ..c
                    lbeq      L15EA               * 16C7 10 27 FF 1F    .'..
                    cmpx      #115                * 16CB 8C 00 73       ..s
                    lbeq      L15F7               * 16CE 10 27 FF 25    .'.%
                    cmpx      #108                * 16D2 8C 00 6C       ..l
                    lbeq      L1647               * 16D5 10 27 FF 6E    .'.n
                    bra       L1671               * 16D9 20 96           .
L16DB               leas      $0B,S               * 16DB 32 6B          2k
                    puls      PC,U                * 16DD 35 C0          5@
L16DF               pshs      U,D                 * 16DF 34 46          4F
                    leax      >$02DC,Y            * 16E1 30 A9 02 DC    0).\
                    stx       0,S                 * 16E5 AF E4          /d
                    ldd       $06,S               * 16E7 EC 66          lf
                    bge       L1714               * 16E9 2C 29          ,)
                    ldd       $06,S               * 16EB EC 66          lf
                    nega                          * 16ED 40             @
                    negb                          * 16EE 50             P
                    sbca      #0                  * 16EF 82 00          ..
                    std       $06,S               * 16F1 ED 66          mf
                    bge       L1709               * 16F3 2C 14          ,.
                    leax      >L193D,PC           * 16F5 30 8D 02 44    0..D
                    pshs      X                   * 16F9 34 10          4.
                    leax      >$02DC,Y            * 16FB 30 A9 02 DC    0).\
                    pshs      X                   * 16FF 34 10          4.
                    lbsr      L1D9D               * 1701 17 06 99       ...
                    leas      $04,S               * 1704 32 64          2d
                    lbra      L17E0               * 1706 16 00 D7       ..W
L1709               ldd       #45                 * 1709 CC 00 2D       L.-
                    ldx       0,S                 * 170C AE E4          .d
                    leax      $01,X               * 170E 30 01          0.
                    stx       0,S                 * 1710 AF E4          /d
                    stb       -$01,X              * 1712 E7 1F          g.
L1714               ldd       $06,S               * 1714 EC 66          lf
                    pshs      D                   * 1716 34 06          4.
                    ldd       $02,S               * 1718 EC 62          lb
                    pshs      D                   * 171A 34 06          4.
                    bsr       L1723               * 171C 8D 05          ..
                    leas      $04,S               * 171E 32 64          2d
                    lbra      L17DA               * 1720 16 00 B7       ..7
L1723               pshs      U,Y,X,D             * 1723 34 76          4v
                    ldu       $0A,S               * 1725 EE 6A          nj
                    clra                          * 1727 4F             O
                    clrb                          * 1728 5F             _
                    std       $02,S               * 1729 ED 62          mb
                    clra                          * 172B 4F             O
                    clrb                          * 172C 5F             _
                    std       0,S                 * 172D ED E4          md
                    bra       L1740               * 172F 20 0F           .
L1731               ldd       0,S                 * 1731 EC E4          ld
                    addd      #1                  * 1733 C3 00 01       C..
                    std       0,S                 * 1736 ED E4          md
                    ldd       $0C,S               * 1738 EC 6C          ll
                    subd      >$0006,Y            * 173A A3 A9 00 06    #)..
                    std       $0C,S               * 173E ED 6C          ml
L1740               ldd       $0C,S               * 1740 EC 6C          ll
                    blt       L1731               * 1742 2D ED          -m
                    leax      >$0006,Y            * 1744 30 A9 00 06    0)..
                    stx       $04,S               * 1748 AF 64          /d
                    bra       L1782               * 174A 20 36           6
L174C               ldd       0,S                 * 174C EC E4          ld
                    addd      #1                  * 174E C3 00 01       C..
                    std       0,S                 * 1751 ED E4          md
L1753               ldd       $0C,S               * 1753 EC 6C          ll
                    subd      [<$04,S]            * 1755 A3 F8 04       #x.
                    std       $0C,S               * 1758 ED 6C          ml
                    bge       L174C               * 175A 2C F0          ,p
                    ldd       $0C,S               * 175C EC 6C          ll
                    addd      [<$04,S]            * 175E E3 F8 04       cx.
                    std       $0C,S               * 1761 ED 6C          ml
                    ldd       0,S                 * 1763 EC E4          ld
                    beq       L176C               * 1765 27 05          '.
                    ldd       #1                  * 1767 CC 00 01       L..
                    std       $02,S               * 176A ED 62          mb
L176C               ldd       $02,S               * 176C EC 62          lb
                    beq       L1777               * 176E 27 07          '.
                    ldd       0,S                 * 1770 EC E4          ld
                    addd      #48                 * 1772 C3 00 30       C.0
                    stb       ,U+                 * 1775 E7 C0          g@
L1777               clra                          * 1777 4F             O
                    clrb                          * 1778 5F             _
                    std       0,S                 * 1779 ED E4          md
                    ldd       $04,S               * 177B EC 64          ld
                    addd      #2                  * 177D C3 00 02       C..
                    std       $04,S               * 1780 ED 64          md
L1782               ldd       $04,S               * 1782 EC 64          ld
                    cmpd      >$000E,Y            * 1784 10 A3 A9 00 0E .#)..
                    bne       L1753               * 1789 26 C8          &H
                    ldd       $0C,S               * 178B EC 6C          ll
                    addd      #48                 * 178D C3 00 30       C.0
                    stb       ,U+                 * 1790 E7 C0          g@
                    clra                          * 1792 4F             O
                    clrb                          * 1793 5F             _
                    stb       U0000,U             * 1794 E7 C4          gD
                    ldd       $0A,S               * 1796 EC 6A          lj
                    leas      $06,S               * 1798 32 66          2f
                    puls      PC,U                * 179A 35 C0          5@
L179C               pshs      U,D                 * 179C 34 46          4F
                    leax      >$02DC,Y            * 179E 30 A9 02 DC    0).\
                    stx       0,S                 * 17A2 AF E4          /d
                    leau      >$02E6,Y            * 17A4 33 A9 02 E6    3).f
L17A8               ldd       $06,S               * 17A8 EC 66          lf
                    clra                          * 17AA 4F             O
                    andb      #7                  * 17AB C4 07          D.
                    addd      #48                 * 17AD C3 00 30       C.0
                    stb       ,U+                 * 17B0 E7 C0          g@
                    ldd       $06,S               * 17B2 EC 66          lf
                    lsra                          * 17B4 44             D
                    rorb                          * 17B5 56             V
                    lsra                          * 17B6 44             D
                    rorb                          * 17B7 56             V
                    lsra                          * 17B8 44             D
                    rorb                          * 17B9 56             V
                    std       $06,S               * 17BA ED 66          mf
                    bne       L17A8               * 17BC 26 EA          &j
                    bra       L17CA               * 17BE 20 0A           .
L17C0               ldb       U0000,U             * 17C0 E6 C4          fD
                    ldx       0,S                 * 17C2 AE E4          .d
                    leax      $01,X               * 17C4 30 01          0.
                    stx       0,S                 * 17C6 AF E4          /d
                    stb       -$01,X              * 17C8 E7 1F          g.
L17CA               leau      -$01,U              * 17CA 33 5F          3_
                    pshs      U                   * 17CC 34 40          4@
                    leax      >$02E6,Y            * 17CE 30 A9 02 E6    0).f
                    cmpx      ,S++                * 17D2 AC E1          ,a
                    bls       L17C0               * 17D4 23 EA          #j
                    clra                          * 17D6 4F             O
                    clrb                          * 17D7 5F             _
                    stb       [,S]                * 17D8 E7 F4          gt
L17DA               leax      >$02DC,Y            * 17DA 30 A9 02 DC    0).\
                    tfr       X,D                 * 17DE 1F 10          ..
L17E0               leas      $02,S               * 17E0 32 62          2b
                    puls      PC,U                * 17E2 35 C0          5@
L17E4               pshs      U,X,D               * 17E4 34 56          4V
                    leax      >$02DC,Y            * 17E6 30 A9 02 DC    0).\
                    stx       $02,S               * 17EA AF 62          /b
                    leau      >$02E6,Y            * 17EC 33 A9 02 E6    3).f
L17F0               ldd       $08,S               * 17F0 EC 68          lh
                    clra                          * 17F2 4F             O
                    andb      #15                 * 17F3 C4 0F          D.
                    std       0,S                 * 17F5 ED E4          md
                    pshs      D                   * 17F7 34 06          4.
                    ldd       $02,S               * 17F9 EC 62          lb
                    cmpd      #9                  * 17FB 10 83 00 09    ....
                    ble       L1812               * 17FF 2F 11          /.
                    ldd       $0C,S               * 1801 EC 6C          ll
                    beq       L180A               * 1803 27 05          '.
                    ldd       #65                 * 1805 CC 00 41       L.A
                    bra       L180D               * 1808 20 03           .
L180A               ldd       #97                 * 180A CC 00 61       L.a
L180D               addd      #-10                * 180D C3 FF F6       C.v
                    bra       L1815               * 1810 20 03           .
L1812               ldd       #48                 * 1812 CC 00 30       L.0
L1815               addd      ,S++                * 1815 E3 E1          ca
                    stb       ,U+                 * 1817 E7 C0          g@
                    ldd       $08,S               * 1819 EC 68          lh
                    lsra                          * 181B 44             D
                    rorb                          * 181C 56             V
                    lsra                          * 181D 44             D
                    rorb                          * 181E 56             V
                    lsra                          * 181F 44             D
                    rorb                          * 1820 56             V
                    lsra                          * 1821 44             D
                    rorb                          * 1822 56             V
                    anda      #15                 * 1823 84 0F          ..
                    std       $08,S               * 1825 ED 68          mh
                    bne       L17F0               * 1827 26 C7          &G
                    bra       L1835               * 1829 20 0A           .
L182B               ldb       U0000,U             * 182B E6 C4          fD
                    ldx       $02,S               * 182D AE 62          .b
                    leax      $01,X               * 182F 30 01          0.
                    stx       $02,S               * 1831 AF 62          /b
                    stb       -$01,X              * 1833 E7 1F          g.
L1835               leau      -$01,U              * 1835 33 5F          3_
                    pshs      U                   * 1837 34 40          4@
                    leax      >$02E6,Y            * 1839 30 A9 02 E6    0).f
                    cmpx      ,S++                * 183D AC E1          ,a
                    bls       L182B               * 183F 23 EA          #j
                    clra                          * 1841 4F             O
                    clrb                          * 1842 5F             _
                    stb       [<$02,S]            * 1843 E7 F8 02       gx.
                    leax      >$02DC,Y            * 1846 30 A9 02 DC    0).\
                    tfr       X,D                 * 184A 1F 10          ..
                    lbra      L1927               * 184C 16 00 D8       ..X
L184F               pshs      U                   * 184F 34 40          4@
                    ldu       $06,S               * 1851 EE 66          nf
                    ldd       $0A,S               * 1853 EC 6A          lj
                    subd      $08,S               * 1855 A3 68          #h
                    std       $0A,S               * 1857 ED 6A          mj
                    ldd       >$02F0,Y            * 1859 EC A9 02 F0    l).p
                    bne       L1884               * 185D 26 25          &%
                    bra       L186C               * 185F 20 0B           .
L1861               ldd       >$02F2,Y            * 1861 EC A9 02 F2    l).r
                    pshs      D                   * 1865 34 06          4.
                    jsr       [<$06,S]            * 1867 AD F8 06       -x.
                    leas      $02,S               * 186A 32 62          2b
L186C               ldd       $0A,S               * 186C EC 6A          lj
                    addd      #-1                 * 186E C3 FF FF       C..
                    std       $0A,S               * 1871 ED 6A          mj
                    subd      #-1                 * 1873 83 FF FF       ...
                    bgt       L1861               * 1876 2E E9          .i
                    bra       L1884               * 1878 20 0A           .
L187A               ldb       ,U+                 * 187A E6 C0          f@
                    sex                           * 187C 1D             .
                    pshs      D                   * 187D 34 06          4.
                    jsr       [<$06,S]            * 187F AD F8 06       -x.
                    leas      $02,S               * 1882 32 62          2b
L1884               ldd       $08,S               * 1884 EC 68          lh
                    addd      #-1                 * 1886 C3 FF FF       C..
                    std       $08,S               * 1889 ED 68          mh
                    subd      #-1                 * 188B 83 FF FF       ...
                    bne       L187A               * 188E 26 EA          &j
                    ldd       >$02F0,Y            * 1890 EC A9 02 F0    l).p
                    beq       L18AF               * 1894 27 19          '.
                    bra       L18A3               * 1896 20 0B           .
L1898               ldd       >$02F2,Y            * 1898 EC A9 02 F2    l).r
                    pshs      D                   * 189C 34 06          4.
                    jsr       [<$06,S]            * 189E AD F8 06       -x.
                    leas      $02,S               * 18A1 32 62          2b
L18A3               ldd       $0A,S               * 18A3 EC 6A          lj
                    addd      #-1                 * 18A5 C3 FF FF       C..
                    std       $0A,S               * 18A8 ED 6A          mj
                    subd      #-1                 * 18AA 83 FF FF       ...
                    bgt       L1898               * 18AD 2E E9          .i
L18AF               puls      PC,U                * 18AF 35 C0          5@
L18B1               pshs      U                   * 18B1 34 40          4@
                    ldu       $06,S               * 18B3 EE 66          nf
                    ldd       $08,S               * 18B5 EC 68          lh
                    pshs      D                   * 18B7 34 06          4.
                    pshs      U                   * 18B9 34 40          4@
                    lbsr      L1D8C               * 18BB 17 04 CE       ..N
                    leas      $02,S               * 18BE 32 62          2b
                    nega                          * 18C0 40             @
                    negb                          * 18C1 50             P
                    sbca      #0                  * 18C2 82 00          ..
                    addd      ,S++                * 18C4 E3 E1          ca
                    std       $08,S               * 18C6 ED 68          mh
                    ldd       >$02F0,Y            * 18C8 EC A9 02 F0    l).p
                    bne       L18F3               * 18CC 26 25          &%
                    bra       L18DB               * 18CE 20 0B           .
L18D0               ldd       >$02F2,Y            * 18D0 EC A9 02 F2    l).r
                    pshs      D                   * 18D4 34 06          4.
                    jsr       [<$06,S]            * 18D6 AD F8 06       -x.
                    leas      $02,S               * 18D9 32 62          2b
L18DB               ldd       $08,S               * 18DB EC 68          lh
                    addd      #-1                 * 18DD C3 FF FF       C..
                    std       $08,S               * 18E0 ED 68          mh
                    subd      #-1                 * 18E2 83 FF FF       ...
                    bgt       L18D0               * 18E5 2E E9          .i
                    bra       L18F3               * 18E7 20 0A           .
L18E9               ldb       ,U+                 * 18E9 E6 C0          f@
                    sex                           * 18EB 1D             .
                    pshs      D                   * 18EC 34 06          4.
                    jsr       [<$06,S]            * 18EE AD F8 06       -x.
                    leas      $02,S               * 18F1 32 62          2b
L18F3               ldb       U0000,U             * 18F3 E6 C4          fD
                    bne       L18E9               * 18F5 26 F2          &r
                    ldd       >$02F0,Y            * 18F7 EC A9 02 F0    l).p
                    beq       L1916               * 18FB 27 19          '.
                    bra       L190A               * 18FD 20 0B           .
L18FF               ldd       >$02F2,Y            * 18FF EC A9 02 F2    l).r
                    pshs      D                   * 1903 34 06          4.
                    jsr       [<$06,S]            * 1905 AD F8 06       -x.
                    leas      $02,S               * 1908 32 62          2b
L190A               ldd       $08,S               * 190A EC 68          lh
                    addd      #-1                 * 190C C3 FF FF       C..
                    std       $08,S               * 190F ED 68          mh
                    subd      #-1                 * 1911 83 FF FF       ...
                    bgt       L18FF               * 1914 2E E9          .i
L1916               puls      PC,U                * 1916 35 C0          5@
L1918               fcb       $34                 * 1918 34             4
                    fcb       $40                 * 1919 40             @
                    fcb       $EC                 * 191A EC             l
                    fcb       $A9                 * 191B A9             )
                    fcb       $02                 * 191C 02             .
                    fcb       $DA                 * 191D DA             Z
                    fcb       $34                 * 191E 34             4
                    fcb       $06                 * 191F 06             .
                    fcb       $EC                 * 1920 EC             l
                    fcb       $66                 * 1921 66             f
                    fcb       $34                 * 1922 34             4
                    fcb       $06                 * 1923 06             .
                    fcb       $17                 * 1924 17             .
                    fcb       $00                 * 1925 00             .
                    fcb       $1D                 * 1926 1D             .
L1927               leas      $04,S               * 1927 32 64          2d
                    puls      PC,U                * 1929 35 C0          5@
                    fcb       $34                 * 192B 34             4
                    fcb       $40                 * 192C 40             @
                    fcb       $EC                 * 192D EC             l
                    fcb       $64                 * 192E 64             d
                    fcb       $AE                 * 192F AE             .
                    fcb       $A9                 * 1930 A9             )
                    fcb       $02                 * 1931 02             .
                    fcb       $DA                 * 1932 DA             Z
                    fcb       $30                 * 1933 30             0
                    fcb       $01                 * 1934 01             .
                    fcb       $AF                 * 1935 AF             /
                    fcb       $A9                 * 1936 A9             )
                    fcb       $02                 * 1937 02             .
                    fcb       $DA                 * 1938 DA             Z
                    fcb       $E7                 * 1939 E7             g
                    fcb       $1F                 * 193A 1F             .
                    fcb       $35                 * 193B 35             5
                    fcb       $C0                 * 193C C0             @
L193D               fcc       "-32768"            * 193D 2D 33 32 37 36 38 -32768
                    fcb       $00                 * 1943 00             .
                    fcb       $34                 * 1944 34             4
                    fcb       $40                 * 1945 40             @
                    fcb       $EE                 * 1946 EE             n
                    fcb       $66                 * 1947 66             f
                    fcb       $EC                 * 1948 EC             l
                    fcb       $46                 * 1949 46             F
                    fcb       $84                 * 194A 84             .
                    fcb       $80                 * 194B 80             .
                    fcb       $C4                 * 194C C4             D
                    fcb       $22                 * 194D 22             "
                    fcb       $10                 * 194E 10             .
                    fcb       $83                 * 194F 83             .
                    fcb       $80                 * 1950 80             .
                    fcb       $02                 * 1951 02             .
                    fcb       $27                 * 1952 27             '
                    fcb       $14                 * 1953 14             .
                    fcb       $EC                 * 1954 EC             l
                    fcb       $46                 * 1955 46             F
                    fcb       $4F                 * 1956 4F             O
                    fcb       $C4                 * 1957 C4             D
                    fcb       $22                 * 1958 22             "
                    fcb       $10                 * 1959 10             .
                    fcb       $83                 * 195A 83             .
                    fcb       $00                 * 195B 00             .
                    fcb       $02                 * 195C 02             .
                    fcb       $10                 * 195D 10             .
                    fcb       $26                 * 195E 26             &
                    fcb       $01                 * 195F 01             .
                    fcb       $1F                 * 1960 1F             .
                    fcb       $34                 * 1961 34             4
                    fcb       $40                 * 1962 40             @
                    fcb       $17                 * 1963 17             .
                    fcb       $03                 * 1964 03             .
                    fcc       "M2b"               * 1965 4D 32 62       M2b
                    fcb       $EC                 * 1968 EC             l
                    fcb       $46                 * 1969 46             F
                    fcb       $4F                 * 196A 4F             O
                    fcb       $C4                 * 196B C4             D
                    fcb       $04                 * 196C 04             .
                    fcb       $27                 * 196D 27             '
                    fcb       $35                 * 196E 35             5
                    fcb       $CC                 * 196F CC             L
                    fcb       $00                 * 1970 00             .
                    fcb       $01                 * 1971 01             .
                    fcb       $34                 * 1972 34             4
                    fcb       $06                 * 1973 06             .
                    fcc       "0g4"               * 1974 30 67 34       0g4
                    fcb       $10                 * 1977 10             .
                    fcb       $EC                 * 1978 EC             l
                    fcb       $48                 * 1979 48             H
                    fcb       $34                 * 197A 34             4
                    fcb       $06                 * 197B 06             .
                    fcb       $EC                 * 197C EC             l
                    fcb       $46                 * 197D 46             F
                    fcb       $4F                 * 197E 4F             O
                    fcb       $C4                 * 197F C4             D
                    fcb       $40                 * 1980 40             @
                    fcb       $27                 * 1981 27             '
                    fcb       $06                 * 1982 06             .
                    fcb       $30                 * 1983 30             0
                    fcb       $8D                 * 1984 8D             .
                    fcb       $06                 * 1985 06             .
                    fcb       $43                 * 1986 43             C
                    fcb       $20                 * 1987 20
                    fcb       $04                 * 1988 04             .
                    fcb       $30                 * 1989 30             0
                    fcb       $8D                 * 198A 8D             .
                    fcb       $06                 * 198B 06             .
                    fcb       $24                 * 198C 24             $
                    fcb       $1F                 * 198D 1F             .
                    fcb       $10                 * 198E 10             .
                    fcb       $1F                 * 198F 1F             .
                    fcb       $01                 * 1990 01             .
                    fcb       $AD                 * 1991 AD             -
                    fcb       $84                 * 1992 84             .
                    fcb       $32                 * 1993 32             2
                    fcb       $66                 * 1994 66             f
                    fcb       $10                 * 1995 10             .
                    fcb       $83                 * 1996 83             .
                    fcb       $FF                 * 1997 FF             .
                    fcb       $FF                 * 1998 FF             .
                    fcb       $26                 * 1999 26             &
                    fcb       $4A                 * 199A 4A             J
                    fcb       $EC                 * 199B EC             l
                    fcb       $46                 * 199C 46             F
                    fcb       $CA                 * 199D CA             J
                    fcb       $20                 * 199E 20
                    fcb       $ED                 * 199F ED             m
                    fcb       $46                 * 19A0 46             F
                    fcb       $16                 * 19A1 16             .
                    fcb       $00                 * 19A2 00             .
                    fcb       $DC                 * 19A3 DC             \
                    fcb       $EC                 * 19A4 EC             l
                    fcb       $46                 * 19A5 46             F
                    fcb       $84                 * 19A6 84             .
                    fcb       $01                 * 19A7 01             .
                    fcb       $5F                 * 19A8 5F             _
                    fcb       $ED                 * 19A9 ED             m
                    fcb       $7E                 * 19AA 7E             ~
                    fcb       $26                 * 19AB 26             &
                    fcb       $07                 * 19AC 07             .
                    fcb       $34                 * 19AD 34             4
                    fcb       $40                 * 19AE 40             @
                    fcb       $17                 * 19AF 17             .
                    fcb       $00                 * 19B0 00             .
                    fcb       $EB                 * 19B1 EB             k
                    fcb       $32                 * 19B2 32             2
                    fcb       $62                 * 19B3 62             b
                    fcb       $EC                 * 19B4 EC             l
                    fcb       $C4                 * 19B5 C4             D
                    fcb       $C3                 * 19B6 C3             C
                    fcb       $00                 * 19B7 00             .
                    fcb       $01                 * 19B8 01             .
                    fcb       $ED                 * 19B9 ED             m
                    fcb       $C4                 * 19BA C4             D
                    fcb       $83                 * 19BB 83             .
                    fcb       $00                 * 19BC 00             .
                    fcb       $01                 * 19BD 01             .
                    fcb       $1F                 * 19BE 1F             .
                    fcb       $01                 * 19BF 01             .
                    fcb       $EC                 * 19C0 EC             l
                    fcb       $64                 * 19C1 64             d
                    fcb       $E7                 * 19C2 E7             g
                    fcb       $84                 * 19C3 84             .
                    fcb       $EC                 * 19C4 EC             l
                    fcb       $C4                 * 19C5 C4             D
                    fcb       $10                 * 19C6 10             .
                    fcb       $A3                 * 19C7 A3             #
                    fcb       $44                 * 19C8 44             D
                    fcb       $24                 * 19C9 24             $
                    fcb       $0F                 * 19CA 0F             .
                    fcb       $EC                 * 19CB EC             l
                    fcb       $46                 * 19CC 46             F
                    fcb       $4F                 * 19CD 4F             O
                    fcb       $C4                 * 19CE C4             D
                    fcb       $40                 * 19CF 40             @
                    fcb       $27                 * 19D0 27             '
                    fcb       $13                 * 19D1 13             .
                    fcb       $EC                 * 19D2 EC             l
                    fcb       $64                 * 19D3 64             d
                    fcb       $10                 * 19D4 10             .
                    fcb       $83                 * 19D5 83             .
                    fcb       $00                 * 19D6 00             .
                    fcb       $0D                 * 19D7 0D             .
                    fcb       $26                 * 19D8 26             &
                    fcb       $0B                 * 19D9 0B             .
                    fcb       $34                 * 19DA 34             4
                    fcb       $40                 * 19DB 40             @
                    fcb       $17                 * 19DC 17             .
                    fcb       $00                 * 19DD 00             .
                    fcb       $BE                 * 19DE BE             >
                    fcb       $ED                 * 19DF ED             m
                    fcb       $E1                 * 19E0 E1             a
                    fcb       $10                 * 19E1 10             .
                    fcb       $26                 * 19E2 26             &
                    fcb       $00                 * 19E3 00             .
                    fcb       $9B                 * 19E4 9B             .
                    fcb       $EC                 * 19E5 EC             l
                    fcb       $64                 * 19E6 64             d
                    fcb       $35                 * 19E7 35             5
                    fcb       $C0                 * 19E8 C0             @
                    fcb       $34                 * 19E9 34             4
                    fcb       $40                 * 19EA 40             @
                    fcb       $EE                 * 19EB EE             n
                    fcb       $64                 * 19EC 64             d
                    fcb       $EC                 * 19ED EC             l
                    fcb       $66                 * 19EE 66             f
                    fcb       $34                 * 19EF 34             4
                    fcb       $06                 * 19F0 06             .
                    fcb       $34                 * 19F1 34             4
                    fcb       $40                 * 19F2 40             @
                    fcb       $CC                 * 19F3 CC             L
                    fcb       $00                 * 19F4 00             .
                    fcb       $08                 * 19F5 08             .
                    fcb       $17                 * 19F6 17             .
                    fcb       $04                 * 19F7 04             .
                    fcb       $79                 * 19F8 79             y
                    fcb       $34                 * 19F9 34             4
                    fcb       $06                 * 19FA 06             .
                    fcb       $17                 * 19FB 17             .
                    fcb       $FF                 * 19FC FF             .
                    fcc       "F2d"               * 19FD 46 32 64       F2d
                    fcb       $EC                 * 1A00 EC             l
                    fcb       $66                 * 1A01 66             f
                    fcb       $34                 * 1A02 34             4
                    fcb       $06                 * 1A03 06             .
                    fcb       $34                 * 1A04 34             4
                    fcb       $40                 * 1A05 40             @
                    fcb       $17                 * 1A06 17             .
                    fcb       $FF                 * 1A07 FF             .
                    fcb       $3B                 * 1A08 3B             ;
                    fcb       $16                 * 1A09 16             .
                    fcb       $01                 * 1A0A 01             .
                    fcc       "K"                 * 1A0B 4B             K
L1A0C               pshs      U,D                 * 1A0C 34 46          4F
                    leau      >$0013,Y            * 1A0E 33 A9 00 13    3)..
                    clra                          * 1A12 4F             O
                    clrb                          * 1A13 5F             _
                    std       0,S                 * 1A14 ED E4          md
                    bra       L1A22               * 1A16 20 0A           .
L1A18               tfr       U,D                 * 1A18 1F 30          .0
                    leau      U000D,U             * 1A1A 33 4D          3M
                    pshs      D                   * 1A1C 34 06          4.
                    bsr       L1A35               * 1A1E 8D 15          ..
                    leas      $02,S               * 1A20 32 62          2b
L1A22               ldd       0,S                 * 1A22 EC E4          ld
                    addd      #1                  * 1A24 C3 00 01       C..
                    std       0,S                 * 1A27 ED E4          md
                    subd      #1                  * 1A29 83 00 01       ...
                    cmpd      #16                 * 1A2C 10 83 00 10    ....
                    blt       L1A18               * 1A30 2D E6          -f
                    lbra      L1A99               * 1A32 16 00 64       ..d
L1A35               pshs      U                   * 1A35 34 40          4@
                    ldu       $04,S               * 1A37 EE 64          nd
                    leas      -$02,S              * 1A39 32 7E          2~
                    cmpu      #0                  * 1A3B 11 83 00 00    ....
                    beq       L1A45               * 1A3F 27 04          '.
                    ldd       U0006,U             * 1A41 EC 46          lF
                    bne       L1A4B               * 1A43 26 06          &.
L1A45               ldd       #-1                 * 1A45 CC FF FF       L..
                    lbra      L1A99               * 1A48 16 00 4E       ..N
L1A4B               ldd       U0006,U             * 1A4B EC 46          lF
                    clra                          * 1A4D 4F             O
                    andb      #2                  * 1A4E C4 02          D.
                    beq       L1A5A               * 1A50 27 08          '.
                    pshs      U                   * 1A52 34 40          4@
                    bsr       L1A6F               * 1A54 8D 19          ..
                    leas      $02,S               * 1A56 32 62          2b
                    bra       L1A5C               * 1A58 20 02           .
L1A5A               clra                          * 1A5A 4F             O
                    clrb                          * 1A5B 5F             _
L1A5C               std       0,S                 * 1A5C ED E4          md
                    ldd       U0008,U             * 1A5E EC 48          lH
                    pshs      D                   * 1A60 34 06          4.
                    lbsr      L1F13               * 1A62 17 04 AE       ...
                    leas      $02,S               * 1A65 32 62          2b
                    clra                          * 1A67 4F             O
                    clrb                          * 1A68 5F             _
                    std       U0006,U             * 1A69 ED 46          mF
                    ldd       0,S                 * 1A6B EC E4          ld
                    bra       L1A99               * 1A6D 20 2A           *
L1A6F               pshs      U                   * 1A6F 34 40          4@
                    ldu       $04,S               * 1A71 EE 64          nd
                    beq       L1A80               * 1A73 27 0B          '.
                    ldd       U0006,U             * 1A75 EC 46          lF
                    clra                          * 1A77 4F             O
                    andb      #34                 * 1A78 C4 22          D"
                    cmpd      #2                  * 1A7A 10 83 00 02    ....
                    beq       L1A85               * 1A7E 27 05          '.
L1A80               ldd       #-1                 * 1A80 CC FF FF       L..
                    puls      PC,U                * 1A83 35 C0          5@
L1A85               ldd       U0006,U             * 1A85 EC 46          lF
                    anda      #128                * 1A87 84 80          ..
                    clrb                          * 1A89 5F             _
                    std       -$02,S              * 1A8A ED 7E          m~
                    bne       L1A95               * 1A8C 26 07          &.
                    pshs      U                   * 1A8E 34 40          4@
                    lbsr      L1CB3               * 1A90 17 02 20       ..
                    leas      $02,S               * 1A93 32 62          2b
L1A95               pshs      U                   * 1A95 34 40          4@
                    bsr       L1A9D               * 1A97 8D 04          ..
L1A99               leas      $02,S               * 1A99 32 62          2b
                    puls      PC,U                * 1A9B 35 C0          5@
L1A9D               pshs      U                   * 1A9D 34 40          4@
                    ldu       $04,S               * 1A9F EE 64          nd
                    leas      -$04,S              * 1AA1 32 7C          2|
                    ldd       U0006,U             * 1AA3 EC 46          lF
                    anda      #1                  * 1AA5 84 01          ..
                    clrb                          * 1AA7 5F             _
                    std       -$02,S              * 1AA8 ED 7E          m~
                    bne       L1ACF               * 1AAA 26 23          &#
                    ldd       U0000,U             * 1AAC EC C4          lD
                    cmpd      U0004,U             * 1AAE 10 A3 44       .#D
                    beq       L1ACF               * 1AB1 27 1C          '.
                    clra                          * 1AB3 4F             O
                    clrb                          * 1AB4 5F             _
                    pshs      D                   * 1AB5 34 06          4.
                    pshs      U                   * 1AB7 34 40          4@
                    lbsr      L1B5B               * 1AB9 17 00 9F       ...
                    leas      $02,S               * 1ABC 32 62          2b
                    ldd       $02,X               * 1ABE EC 02          l.
                    pshs      D                   * 1AC0 34 06          4.
                    ldd       0,X                 * 1AC2 EC 84          l.
                    pshs      D                   * 1AC4 34 06          4.
                    ldd       U0008,U             * 1AC6 EC 48          lH
                    pshs      D                   * 1AC8 34 06          4.
                    lbsr      L1FDA               * 1ACA 17 05 0D       ...
                    leas      $08,S               * 1ACD 32 68          2h
L1ACF               ldd       U0000,U             * 1ACF EC C4          lD
                    subd      U0002,U             * 1AD1 A3 42          #B
                    std       $02,S               * 1AD3 ED 62          mb
                    lbeq      L1B47               * 1AD5 10 27 00 6E    .'.n
                    ldd       U0006,U             * 1AD9 EC 46          lF
                    anda      #1                  * 1ADB 84 01          ..
                    clrb                          * 1ADD 5F             _
                    std       -$02,S              * 1ADE ED 7E          m~
                    lbeq      L1B47               * 1AE0 10 27 00 63    .'.c
                    ldd       U0006,U             * 1AE4 EC 46          lF
                    clra                          * 1AE6 4F             O
                    andb      #64                 * 1AE7 C4 40          D@
                    beq       L1B1E               * 1AE9 27 33          '3
                    ldd       U0002,U             * 1AEB EC 42          lB
                    bra       L1B16               * 1AED 20 27           '
L1AEF               ldd       $02,S               * 1AEF EC 62          lb
                    pshs      D                   * 1AF1 34 06          4.
                    ldd       U0000,U             * 1AF3 EC C4          lD
                    pshs      D                   * 1AF5 34 06          4.
                    ldd       U0008,U             * 1AF7 EC 48          lH
                    pshs      D                   * 1AF9 34 06          4.
                    lbsr      L1FCA               * 1AFB 17 04 CC       ..L
                    leas      $06,S               * 1AFE 32 66          2f
                    std       0,S                 * 1B00 ED E4          md
                    cmpd      #-1                 * 1B02 10 83 FF FF    ....
                    bne       L1B0C               * 1B06 26 04          &.
                    leax      $04,S               * 1B08 30 64          0d
                    bra       L1B36               * 1B0A 20 2A           *
L1B0C               ldd       $02,S               * 1B0C EC 62          lb
                    subd      0,S                 * 1B0E A3 E4          #d
                    std       $02,S               * 1B10 ED 62          mb
                    ldd       U0000,U             * 1B12 EC C4          lD
                    addd      0,S                 * 1B14 E3 E4          cd
L1B16               std       U0000,U             * 1B16 ED C4          mD
                    ldd       $02,S               * 1B18 EC 62          lb
                    bne       L1AEF               * 1B1A 26 D3          &S
                    bra       L1B47               * 1B1C 20 29           )
L1B1E               ldd       $02,S               * 1B1E EC 62          lb
                    pshs      D                   * 1B20 34 06          4.
                    ldd       U0002,U             * 1B22 EC 42          lB
                    pshs      D                   * 1B24 34 06          4.
                    ldd       U0008,U             * 1B26 EC 48          lH
                    pshs      D                   * 1B28 34 06          4.
                    lbsr      L1FB1               * 1B2A 17 04 84       ...
                    leas      $06,S               * 1B2D 32 66          2f
                    cmpd      $02,S               * 1B2F 10 A3 62       .#b
                    beq       L1B47               * 1B32 27 13          '.
                    bra       L1B38               * 1B34 20 02           .
L1B36               leas      -$04,X              * 1B36 32 1C          2.
L1B38               ldd       U0006,U             * 1B38 EC 46          lF
                    orb       #32                 * 1B3A CA 20          J
                    std       U0006,U             * 1B3C ED 46          mF
                    ldd       U0004,U             * 1B3E EC 44          lD
                    std       U0000,U             * 1B40 ED C4          mD
                    ldd       #-1                 * 1B42 CC FF FF       L..
                    bra       L1B57               * 1B45 20 10           .
L1B47               ldd       U0006,U             * 1B47 EC 46          lF
                    ora       #1                  * 1B49 8A 01          ..
                    std       U0006,U             * 1B4B ED 46          mF
                    ldd       U0002,U             * 1B4D EC 42          lB
                    std       U0000,U             * 1B4F ED C4          mD
                    addd      U000B,U             * 1B51 E3 4B          cK
                    std       U0004,U             * 1B53 ED 44          mD
                    clra                          * 1B55 4F             O
                    clrb                          * 1B56 5F             _
L1B57               leas      $04,S               * 1B57 32 64          2d
                    puls      PC,U                * 1B59 35 C0          5@
L1B5B               pshs      U                   * 1B5B 34 40          4@
                    puls      PC,U                * 1B5D 35 C0          5@
L1B5F               pshs      U                   * 1B5F 34 40          4@
                    ldu       $04,S               * 1B61 EE 64          nd
                    beq       L1BAB               * 1B63 27 46          'F
                    ldd       U0006,U             * 1B65 EC 46          lF
                    anda      #1                  * 1B67 84 01          ..
                    clrb                          * 1B69 5F             _
                    std       -$02,S              * 1B6A ED 7E          m~
                    bne       L1BAB               * 1B6C 26 3D          &=
                    ldd       U0000,U             * 1B6E EC C4          lD
                    cmpd      U0004,U             * 1B70 10 A3 44       .#D
                    bcc       L1B87               * 1B73 24 12          $.
                    ldd       U0000,U             * 1B75 EC C4          lD
                    addd      #1                  * 1B77 C3 00 01       C..
                    std       U0000,U             * 1B7A ED C4          mD
                    subd      #1                  * 1B7C 83 00 01       ...
                    tfr       D,X                 * 1B7F 1F 01          ..
                    ldb       0,X                 * 1B81 E6 84          f.
                    clra                          * 1B83 4F             O
                    lbra      L1CB1               * 1B84 16 01 2A       ..*
L1B87               pshs      U                   * 1B87 34 40          4@
                    lbsr      L1BFA               * 1B89 17 00 6E       ..n
                    lbra      L1CAF               * 1B8C 16 01 20       ..
                    fcb       $34                 * 1B8F 34             4
                    fcb       $40                 * 1B90 40             @
                    fcb       $EE                 * 1B91 EE             n
                    fcb       $66                 * 1B92 66             f
                    fcb       $27                 * 1B93 27             '
                    fcb       $16                 * 1B94 16             .
                    fcb       $EC                 * 1B95 EC             l
                    fcb       $46                 * 1B96 46             F
                    fcb       $4F                 * 1B97 4F             O
                    fcb       $C4                 * 1B98 C4             D
                    fcb       $01                 * 1B99 01             .
                    fcb       $27                 * 1B9A 27             '
                    fcb       $0F                 * 1B9B 0F             .
                    fcb       $EC                 * 1B9C EC             l
                    fcb       $64                 * 1B9D 64             d
                    fcb       $10                 * 1B9E 10             .
                    fcb       $83                 * 1B9F 83             .
                    fcb       $FF                 * 1BA0 FF             .
                    fcb       $FF                 * 1BA1 FF             .
                    fcb       $27                 * 1BA2 27             '
                    fcb       $07                 * 1BA3 07             .
                    fcb       $EC                 * 1BA4 EC             l
                    fcb       $C4                 * 1BA5 C4             D
                    fcb       $10                 * 1BA6 10             .
                    fcb       $A3                 * 1BA7 A3             #
                    fcb       $42                 * 1BA8 42             B
                    fcb       $22                 * 1BA9 22             "
                    fcb       $05                 * 1BAA 05             .
L1BAB               ldd       #-1                 * 1BAB CC FF FF       L..
                    puls      PC,U                * 1BAE 35 C0          5@
                    fcb       $EC                 * 1BB0 EC             l
                    fcb       $C4                 * 1BB1 C4             D
                    fcb       $C3                 * 1BB2 C3             C
                    fcb       $FF                 * 1BB3 FF             .
                    fcb       $FF                 * 1BB4 FF             .
                    fcb       $ED                 * 1BB5 ED             m
                    fcb       $C4                 * 1BB6 C4             D
                    fcb       $1F                 * 1BB7 1F             .
                    fcb       $01                 * 1BB8 01             .
                    fcb       $EC                 * 1BB9 EC             l
                    fcb       $64                 * 1BBA 64             d
                    fcb       $E7                 * 1BBB E7             g
                    fcb       $84                 * 1BBC 84             .
                    fcb       $EC                 * 1BBD EC             l
                    fcb       $64                 * 1BBE 64             d
                    fcb       $35                 * 1BBF 35             5
                    fcb       $C0                 * 1BC0 C0             @
                    fcb       $34                 * 1BC1 34             4
                    fcb       $40                 * 1BC2 40             @
                    fcb       $EE                 * 1BC3 EE             n
                    fcc       "d2|4@"             * 1BC4 64 32 7C 34 40 d2|4@
                    fcb       $17                 * 1BC9 17             .
                    fcb       $FF                 * 1BCA FF             .
                    fcb       $93                 * 1BCB 93             .
                    fcb       $32                 * 1BCC 32             2
                    fcb       $62                 * 1BCD 62             b
                    fcb       $ED                 * 1BCE ED             m
                    fcb       $62                 * 1BCF 62             b
                    fcb       $10                 * 1BD0 10             .
                    fcb       $83                 * 1BD1 83             .
                    fcb       $FF                 * 1BD2 FF             .
                    fcb       $FF                 * 1BD3 FF             .
                    fcb       $27                 * 1BD4 27             '
                    fcb       $0F                 * 1BD5 0F             .
                    fcb       $34                 * 1BD6 34             4
                    fcb       $40                 * 1BD7 40             @
                    fcb       $17                 * 1BD8 17             .
                    fcb       $FF                 * 1BD9 FF             .
                    fcb       $84                 * 1BDA 84             .
                    fcb       $32                 * 1BDB 32             2
                    fcb       $62                 * 1BDC 62             b
                    fcb       $ED                 * 1BDD ED             m
                    fcb       $E4                 * 1BDE E4             d
                    fcb       $10                 * 1BDF 10             .
                    fcb       $83                 * 1BE0 83             .
                    fcb       $FF                 * 1BE1 FF             .
                    fcb       $FF                 * 1BE2 FF             .
                    fcb       $26                 * 1BE3 26             &
                    fcb       $05                 * 1BE4 05             .
                    fcb       $CC                 * 1BE5 CC             L
                    fcb       $FF                 * 1BE6 FF             .
                    fcb       $FF                 * 1BE7 FF             .
                    fcb       $20                 * 1BE8 20
                    fcb       $0C                 * 1BE9 0C             .
                    fcb       $EC                 * 1BEA EC             l
                    fcb       $62                 * 1BEB 62             b
                    fcb       $34                 * 1BEC 34             4
                    fcb       $06                 * 1BED 06             .
                    fcb       $CC                 * 1BEE CC             L
                    fcb       $00                 * 1BEF 00             .
                    fcb       $08                 * 1BF0 08             .
                    fcb       $17                 * 1BF1 17             .
                    fcb       $02                 * 1BF2 02             .
                    fcb       $95                 * 1BF3 95             .
                    fcb       $E3                 * 1BF4 E3             c
                    fcb       $E4                 * 1BF5 E4             d
                    fcc       "2d5"               * 1BF6 32 64 35       2d5
                    fcb       $C0                 * 1BF9 C0             @
L1BFA               pshs      U                   * 1BFA 34 40          4@
                    ldu       $04,S               * 1BFC EE 64          nd
                    leas      -$02,S              * 1BFE 32 7E          2~
                    ldd       U0006,U             * 1C00 EC 46          lF
                    anda      #128                * 1C02 84 80          ..
                    andb      #49                 * 1C04 C4 31          D1
                    cmpd      #-32767             * 1C06 10 83 80 01    ....
                    beq       L1C20               * 1C0A 27 14          '.
                    ldd       U0006,U             * 1C0C EC 46          lF
                    clra                          * 1C0E 4F             O
                    andb      #49                 * 1C0F C4 31          D1
                    cmpd      #1                  * 1C11 10 83 00 01    ....
                    lbne      L1C99               * 1C15 10 26 00 80    .&..
                    pshs      U                   * 1C19 34 40          4@
                    lbsr      L1CB3               * 1C1B 17 00 95       ...
                    leas      $02,S               * 1C1E 32 62          2b
L1C20               leax      >$0013,Y            * 1C20 30 A9 00 13    0)..
                    pshs      X                   * 1C24 34 10          4.
                    cmpu      ,S++                * 1C26 11 A3 E1       .#a
                    bne       L1C3D               * 1C29 26 12          &.
                    ldd       U0006,U             * 1C2B EC 46          lF
                    clra                          * 1C2D 4F             O
                    andb      #64                 * 1C2E C4 40          D@
                    beq       L1C3D               * 1C30 27 0B          '.
                    leax      >$0020,Y            * 1C32 30 A9 00 20    0).
                    pshs      X                   * 1C36 34 10          4.
                    lbsr      L1A6F               * 1C38 17 FE 34       .~4
                    leas      $02,S               * 1C3B 32 62          2b
L1C3D               ldd       U0006,U             * 1C3D EC 46          lF
                    clra                          * 1C3F 4F             O
                    andb      #8                  * 1C40 C4 08          D.
                    beq       L1C69               * 1C42 27 25          '%
                    ldd       U000B,U             * 1C44 EC 4B          lK
                    pshs      D                   * 1C46 34 06          4.
                    ldd       U0002,U             * 1C48 EC 42          lB
                    pshs      D                   * 1C4A 34 06          4.
                    ldd       U0008,U             * 1C4C EC 48          lH
                    pshs      D                   * 1C4E 34 06          4.
                    ldd       U0006,U             * 1C50 EC 46          lF
                    clra                          * 1C52 4F             O
                    andb      #64                 * 1C53 C4 40          D@
                    beq       L1C5D               * 1C55 27 06          '.
                    leax      >L1FA1,PC           * 1C57 30 8D 03 46    0..F
                    bra       L1C61               * 1C5B 20 04           .
L1C5D               leax      >L1F80,PC           * 1C5D 30 8D 03 1F    0...
L1C61               tfr       X,D                 * 1C61 1F 10          ..
                    tfr       D,X                 * 1C63 1F 01          ..
                    jsr       0,X                 * 1C65 AD 84          -.
                    bra       L1C7B               * 1C67 20 12           .
L1C69               ldd       #1                  * 1C69 CC 00 01       L..
                    pshs      D                   * 1C6C 34 06          4.
                    leax      U000A,U             * 1C6E 30 4A          0J
                    stx       U0002,U             * 1C70 AF 42          /B
                    pshs      X                   * 1C72 34 10          4.
                    ldd       U0008,U             * 1C74 EC 48          lH
                    pshs      D                   * 1C76 34 06          4.
                    lbsr      L1F80               * 1C78 17 03 05       ...
L1C7B               leas      $06,S               * 1C7B 32 66          2f
                    std       0,S                 * 1C7D ED E4          md
                    ldd       0,S                 * 1C7F EC E4          ld
                    bgt       L1C9E               * 1C81 2E 1B          ..
                    ldd       U0006,U             * 1C83 EC 46          lF
                    pshs      D                   * 1C85 34 06          4.
                    ldd       $02,S               * 1C87 EC 62          lb
                    beq       L1C90               * 1C89 27 05          '.
                    ldd       #32                 * 1C8B CC 00 20       L.
                    bra       L1C93               * 1C8E 20 03           .
L1C90               ldd       #16                 * 1C90 CC 00 10       L..
L1C93               ora       ,S+                 * 1C93 AA E0          *`
                    orb       ,S+                 * 1C95 EA E0          j`
                    std       U0006,U             * 1C97 ED 46          mF
L1C99               ldd       #-1                 * 1C99 CC FF FF       L..
                    bra       L1CAF               * 1C9C 20 11           .
L1C9E               ldd       U0002,U             * 1C9E EC 42          lB
                    addd      #1                  * 1CA0 C3 00 01       C..
                    std       U0000,U             * 1CA3 ED C4          mD
                    ldd       U0002,U             * 1CA5 EC 42          lB
                    addd      0,S                 * 1CA7 E3 E4          cd
                    std       U0004,U             * 1CA9 ED 44          mD
                    ldb       [<$02,U]            * 1CAB E6 D8 02       fX.
                    clra                          * 1CAE 4F             O
L1CAF               leas      $02,S               * 1CAF 32 62          2b
L1CB1               puls      PC,U                * 1CB1 35 C0          5@
L1CB3               pshs      U                   * 1CB3 34 40          4@
                    ldu       $04,S               * 1CB5 EE 64          nd
                    ldd       U0006,U             * 1CB7 EC 46          lF
                    clra                          * 1CB9 4F             O
                    andb      #192                * 1CBA C4 C0          D@
                    bne       L1CEB               * 1CBC 26 2D          &-
                    leas      -$20,S              * 1CBE 32 E8 E0       2h`
                    leax      0,S                 * 1CC1 30 E4          0d
                    pshs      X                   * 1CC3 34 10          4.
                    ldd       U0008,U             * 1CC5 EC 48          lH
                    pshs      D                   * 1CC7 34 06          4.
                    clra                          * 1CC9 4F             O
                    clrb                          * 1CCA 5F             _
                    pshs      D                   * 1CCB 34 06          4.
                    lbsr      L1E95               * 1CCD 17 01 C5       ..E
                    leas      $06,S               * 1CD0 32 66          2f
                    ldd       U0006,U             * 1CD2 EC 46          lF
                    pshs      D                   * 1CD4 34 06          4.
                    ldb       $02,S               * 1CD6 E6 62          fb
                    bne       L1CDF               * 1CD8 26 05          &.
                    ldd       #64                 * 1CDA CC 00 40       L.@
                    bra       L1CE2               * 1CDD 20 03           .
L1CDF               ldd       #128                * 1CDF CC 00 80       L..
L1CE2               ora       ,S+                 * 1CE2 AA E0          *`
                    orb       ,S+                 * 1CE4 EA E0          j`
                    std       U0006,U             * 1CE6 ED 46          mF
                    leas      <$0020,S            * 1CE8 32 E8 20       2h
L1CEB               ldd       U0006,U             * 1CEB EC 46          lF
                    ora       #128                * 1CED 8A 80          ..
                    std       U0006,U             * 1CEF ED 46          mF
                    clra                          * 1CF1 4F             O
                    andb      #12                 * 1CF2 C4 0C          D.
                    beq       L1CF8               * 1CF4 27 02          '.
                    puls      PC,U                * 1CF6 35 C0          5@
L1CF8               ldd       U000B,U             * 1CF8 EC 4B          lK
                    bne       L1D0D               * 1CFA 26 11          &.
                    ldd       U0006,U             * 1CFC EC 46          lF
                    clra                          * 1CFE 4F             O
                    andb      #64                 * 1CFF C4 40          D@
                    beq       L1D08               * 1D01 27 05          '.
                    ldd       #128                * 1D03 CC 00 80       L..
                    bra       L1D0B               * 1D06 20 03           .
L1D08               ldd       #256                * 1D08 CC 01 00       L..
L1D0B               std       U000B,U             * 1D0B ED 4B          mK
L1D0D               ldd       U0002,U             * 1D0D EC 42          lB
                    bne       L1D22               * 1D0F 26 11          &.
                    ldd       U000B,U             * 1D11 EC 4B          lK
                    pshs      D                   * 1D13 34 06          4.
                    lbsr      L20CA               * 1D15 17 03 B2       ..2
                    leas      $02,S               * 1D18 32 62          2b
                    std       U0002,U             * 1D1A ED 42          mB
                    cmpd      #-1                 * 1D1C 10 83 FF FF    ....
                    beq       L1D2A               * 1D20 27 08          '.
L1D22               ldd       U0006,U             * 1D22 EC 46          lF
                    orb       #8                  * 1D24 CA 08          J.
                    std       U0006,U             * 1D26 ED 46          mF
                    bra       L1D39               * 1D28 20 0F           .
L1D2A               ldd       U0006,U             * 1D2A EC 46          lF
                    orb       #4                  * 1D2C CA 04          J.
                    std       U0006,U             * 1D2E ED 46          mF
                    leax      U000A,U             * 1D30 30 4A          0J
                    stx       U0002,U             * 1D32 AF 42          /B
                    ldd       #1                  * 1D34 CC 00 01       L..
                    std       U000B,U             * 1D37 ED 4B          mK
L1D39               ldd       U0002,U             * 1D39 EC 42          lB
                    addd      U000B,U             * 1D3B E3 4B          cK
                    std       U0004,U             * 1D3D ED 44          mD
                    std       U0000,U             * 1D3F ED C4          mD
                    puls      PC,U                * 1D41 35 C0          5@
L1D43               pshs      U                   * 1D43 34 40          4@
                    ldb       $05,S               * 1D45 E6 65          fe
                    sex                           * 1D47 1D             .
                    tfr       D,X                 * 1D48 1F 01          ..
                    bra       L1D69               * 1D4A 20 1D           .
L1D4C               ldd       [<$06,S]            * 1D4C EC F8 06       lx.
                    addd      #4                  * 1D4F C3 00 04       C..
                    std       [<$06,S]            * 1D52 ED F8 06       mx.
                    leax      >L1D80,PC           * 1D55 30 8D 00 27    0..'
                    bra       L1D65               * 1D59 20 0A           .
L1D5B               ldb       $05,S               * 1D5B E6 65          fe
                    stb       >$0011,Y            * 1D5D E7 A9 00 11    g)..
                    leax      >$0010,Y            * 1D61 30 A9 00 10    0)..
L1D65               tfr       X,D                 * 1D65 1F 10          ..
                    puls      PC,U                * 1D67 35 C0          5@
L1D69               cmpx      #100                * 1D69 8C 00 64       ..d
                    beq       L1D4C               * 1D6C 27 DE          '^
                    cmpx      #111                * 1D6E 8C 00 6F       ..o
                    lbeq      L1D4C               * 1D71 10 27 FF D7    .'.W
                    cmpx      #120                * 1D75 8C 00 78       ..x
                    lbeq      L1D4C               * 1D78 10 27 FF D0    .'.P
                    bra       L1D5B               * 1D7C 20 DD           ]
                    fcb       $35                 * 1D7E 35             5
                    fcb       $C0                 * 1D7F C0             @
L1D80               fcb       $00                 * 1D80 00             .
L1D81               pshs      U                   * 1D81 34 40          4@
                    leax      >L1D8B,PC           * 1D83 30 8D 00 04    0...
                    tfr       X,D                 * 1D87 1F 10          ..
                    puls      PC,U                * 1D89 35 C0          5@
L1D8B               fcb       $00                 * 1D8B 00             .
L1D8C               pshs      U                   * 1D8C 34 40          4@
                    ldu       $04,S               * 1D8E EE 64          nd
L1D90               ldb       ,U+                 * 1D90 E6 C0          f@
                    bne       L1D90               * 1D92 26 FC          &|
                    tfr       U,D                 * 1D94 1F 30          .0
                    subd      $04,S               * 1D96 A3 64          #d
                    addd      #-1                 * 1D98 C3 FF FF       C..
                    puls      PC,U                * 1D9B 35 C0          5@
L1D9D               pshs      U                   * 1D9D 34 40          4@
                    ldu       $06,S               * 1D9F EE 66          nf
                    leas      -$02,S              * 1DA1 32 7E          2~
                    ldd       $06,S               * 1DA3 EC 66          lf
                    std       0,S                 * 1DA5 ED E4          md
L1DA7               ldb       ,U+                 * 1DA7 E6 C0          f@
                    ldx       0,S                 * 1DA9 AE E4          .d
                    leax      $01,X               * 1DAB 30 01          0.
                    stx       0,S                 * 1DAD AF E4          /d
                    stb       -$01,X              * 1DAF E7 1F          g.
                    bne       L1DA7               * 1DB1 26 F4          &t
                    bra       L1DDC               * 1DB3 20 27           '
                    fcb       $34                 * 1DB5 34             4
                    fcb       $40                 * 1DB6 40             @
                    fcb       $EE                 * 1DB7 EE             n
                    fcc       "f2~"               * 1DB8 66 32 7E       f2~
                    fcb       $EC                 * 1DBB EC             l
                    fcb       $66                 * 1DBC 66             f
                    fcb       $ED                 * 1DBD ED             m
                    fcb       $E4                 * 1DBE E4             d
                    fcb       $AE                 * 1DBF AE             .
                    fcb       $E4                 * 1DC0 E4             d
                    fcb       $30                 * 1DC1 30             0
                    fcb       $01                 * 1DC2 01             .
                    fcb       $AF                 * 1DC3 AF             /
                    fcb       $E4                 * 1DC4 E4             d
                    fcb       $E6                 * 1DC5 E6             f
                    fcb       $1F                 * 1DC6 1F             .
                    fcb       $26                 * 1DC7 26             &
                    fcb       $F6                 * 1DC8 F6             v
                    fcb       $EC                 * 1DC9 EC             l
                    fcb       $E4                 * 1DCA E4             d
                    fcb       $C3                 * 1DCB C3             C
                    fcb       $FF                 * 1DCC FF             .
                    fcb       $FF                 * 1DCD FF             .
                    fcb       $ED                 * 1DCE ED             m
                    fcb       $E4                 * 1DCF E4             d
                    fcb       $E6                 * 1DD0 E6             f
                    fcb       $C0                 * 1DD1 C0             @
                    fcb       $AE                 * 1DD2 AE             .
                    fcb       $E4                 * 1DD3 E4             d
                    fcb       $30                 * 1DD4 30             0
                    fcb       $01                 * 1DD5 01             .
                    fcb       $AF                 * 1DD6 AF             /
                    fcb       $E4                 * 1DD7 E4             d
                    fcb       $E7                 * 1DD8 E7             g
                    fcb       $1F                 * 1DD9 1F             .
                    fcb       $26                 * 1DDA 26             &
                    fcb       $F4                 * 1DDB F4             t
L1DDC               ldd       $06,S               * 1DDC EC 66          lf
                    leas      $02,S               * 1DDE 32 62          2b
                    puls      PC,U                * 1DE0 35 C0          5@
                    fcb       $34                 * 1DE2 34             4
                    fcb       $40                 * 1DE3 40             @
                    fcb       $EE                 * 1DE4 EE             n
                    fcb       $64                 * 1DE5 64             d
                    fcb       $20                 * 1DE6 20
                    fcb       $10                 * 1DE7 10             .
                    fcb       $AE                 * 1DE8 AE             .
                    fcb       $66                 * 1DE9 66             f
                    fcb       $30                 * 1DEA 30             0
                    fcb       $01                 * 1DEB 01             .
                    fcb       $AF                 * 1DEC AF             /
                    fcb       $66                 * 1DED 66             f
                    fcb       $E6                 * 1DEE E6             f
                    fcb       $1F                 * 1DEF 1F             .
                    fcb       $26                 * 1DF0 26             &
                    fcb       $04                 * 1DF1 04             .
                    fcc       "O_5"               * 1DF2 4F 5F 35       O_5
                    fcb       $C0                 * 1DF5 C0             @
                    fcb       $33                 * 1DF6 33             3
                    fcb       $41                 * 1DF7 41             A
                    fcb       $E6                 * 1DF8 E6             f
                    fcb       $C4                 * 1DF9 C4             D
                    fcb       $1D                 * 1DFA 1D             .
                    fcb       $34                 * 1DFB 34             4
                    fcb       $06                 * 1DFC 06             .
                    fcb       $E6                 * 1DFD E6             f
                    fcb       $F8                 * 1DFE F8             x
                    fcb       $08                 * 1DFF 08             .
                    fcb       $1D                 * 1E00 1D             .
                    fcb       $10                 * 1E01 10             .
                    fcb       $A3                 * 1E02 A3             #
                    fcb       $E1                 * 1E03 E1             a
                    fcb       $27                 * 1E04 27             '
                    fcb       $E2                 * 1E05 E2             b
                    fcb       $E6                 * 1E06 E6             f
                    fcb       $F8                 * 1E07 F8             x
                    fcb       $06                 * 1E08 06             .
                    fcb       $1D                 * 1E09 1D             .
                    fcb       $34                 * 1E0A 34             4
                    fcb       $06                 * 1E0B 06             .
                    fcb       $E6                 * 1E0C E6             f
                    fcb       $C4                 * 1E0D C4             D
                    fcb       $1D                 * 1E0E 1D             .
                    fcb       $A3                 * 1E0F A3             #
                    fcb       $E1                 * 1E10 E1             a
                    fcb       $35                 * 1E11 35             5
                    fcb       $C0                 * 1E12 C0             @
L1E13               tsta                          * 1E13 4D             M
                    bne       L1E28               * 1E14 26 12          &.
                    tst       $02,S               * 1E16 6D 62          mb
                    bne       L1E28               * 1E18 26 0E          &.
                    lda       $03,S               * 1E1A A6 63          &c
                    mul                           * 1E1C 3D             =
                    ldx       0,S                 * 1E1D AE E4          .d
                    stx       $02,S               * 1E1F AF 62          /b
                    ldx       #0                  * 1E21 8E 00 00       ...
                    std       0,S                 * 1E24 ED E4          md
                    puls      PC,D                * 1E26 35 86          5.
L1E28               pshs      D                   * 1E28 34 06          4.
                    ldd       #0                  * 1E2A CC 00 00       L..
                    pshs      D                   * 1E2D 34 06          4.
                    pshs      D                   * 1E2F 34 06          4.
                    lda       $05,S               * 1E31 A6 65          &e
                    ldb       $09,S               * 1E33 E6 69          fi
                    mul                           * 1E35 3D             =
                    std       $02,S               * 1E36 ED 62          mb
                    lda       $05,S               * 1E38 A6 65          &e
                    ldb       $08,S               * 1E3A E6 68          fh
                    mul                           * 1E3C 3D             =
                    addd      $01,S               * 1E3D E3 61          ca
                    std       $01,S               * 1E3F ED 61          ma
                    bcc       L1E45               * 1E41 24 02          $.
                    inc       0,S                 * 1E43 6C E4          ld
L1E45               lda       $04,S               * 1E45 A6 64          &d
                    ldb       $09,S               * 1E47 E6 69          fi
                    mul                           * 1E49 3D             =
                    addd      $01,S               * 1E4A E3 61          ca
                    std       $01,S               * 1E4C ED 61          ma
                    bcc       L1E52               * 1E4E 24 02          $.
                    inc       0,S                 * 1E50 6C E4          ld
L1E52               lda       $04,S               * 1E52 A6 64          &d
                    ldb       $08,S               * 1E54 E6 68          fh
                    mul                           * 1E56 3D             =
                    addd      0,S                 * 1E57 E3 E4          cd
                    std       0,S                 * 1E59 ED E4          md
                    ldx       $06,S               * 1E5B AE 66          .f
                    stx       $08,S               * 1E5D AF 68          /h
                    ldx       0,S                 * 1E5F AE E4          .d
                    ldd       $02,S               * 1E61 EC 62          lb
                    leas      $08,S               * 1E63 32 68          2h
                    rts                           * 1E65 39             9
                    fcb       $5D                 * 1E66 5D             ]
                    fcb       $27                 * 1E67 27             '
                    fcb       $13                 * 1E68 13             .
                    fcc       "gbfcZ&"            * 1E69 67 62 66 63 5A 26 gbfcZ&
                    fcb       $F9                 * 1E6F F9             y
                    fcb       $20                 * 1E70 20
                    fcb       $0A                 * 1E71 0A             .
                    fcb       $5D                 * 1E72 5D             ]
                    fcb       $27                 * 1E73 27             '
                    fcb       $07                 * 1E74 07             .
                    fcc       "dbfcZ&"            * 1E75 64 62 66 63 5A 26 dbfcZ&
                    fcb       $F9                 * 1E7B F9             y
                    fcb       $EC                 * 1E7C EC             l
                    fcb       $62                 * 1E7D 62             b
                    fcb       $34                 * 1E7E 34             4
                    fcb       $06                 * 1E7F 06             .
                    fcb       $EC                 * 1E80 EC             l
                    fcb       $62                 * 1E81 62             b
                    fcb       $ED                 * 1E82 ED             m
                    fcb       $64                 * 1E83 64             d
                    fcb       $EC                 * 1E84 EC             l
                    fcb       $E4                 * 1E85 E4             d
                    fcc       "2d9]'"             * 1E86 32 64 39 5D 27 2d9]'
                    fcb       $F0                 * 1E8B F0             p
                    fcc       "hcibZ&"            * 1E8C 68 63 69 62 5A 26 hcibZ&
                    fcb       $F9                 * 1E92 F9             y
                    fcb       $20                 * 1E93 20
                    fcb       $E7                 * 1E94 E7             g
L1E95               lda       $05,S               * 1E95 A6 65          &e
                    ldb       $03,S               * 1E97 E6 63          fc
                    beq       L1EC8               * 1E99 27 2D          '-
                    cmpb      #1                  * 1E9B C1 01          A.
                    beq       L1ECA               * 1E9D 27 2B          '+
                    cmpb      #6                  * 1E9F C1 06          A.
                    beq       L1ECA               * 1EA1 27 27          ''
                    cmpb      #2                  * 1EA3 C1 02          A.
                    beq       L1EB0               * 1EA5 27 09          '.
                    cmpb      #5                  * 1EA7 C1 05          A.
                    beq       L1EB0               * 1EA9 27 05          '.
                    ldb       #208                * 1EAB C6 D0          FP
                    lbra      L2119               * 1EAD 16 02 69       ..i
L1EB0               pshs      U                   * 1EB0 34 40          4@
                    os9       I$GetStt            * 1EB2 10 3F 8D       .?.
                    bcc       L1EBC               * 1EB5 24 05          $.
                    puls      U                   * 1EB7 35 40          5@
                    lbra      L2119               * 1EB9 16 02 5D       ..]
L1EBC               stx       [<$08,S]            * 1EBC AF F8 08       /x.
                    ldx       $08,S               * 1EBF AE 68          .h
                    stu       $02,X               * 1EC1 EF 02          o.
                    puls      U                   * 1EC3 35 40          5@
                    clra                          * 1EC5 4F             O
                    clrb                          * 1EC6 5F             _
                    rts                           * 1EC7 39             9
L1EC8               ldx       $06,S               * 1EC8 AE 66          .f
L1ECA               os9       I$GetStt            * 1ECA 10 3F 8D       .?.
                    lbra      L2122               * 1ECD 16 02 52       ..R
L1ED0               lda       $05,S               * 1ED0 A6 65          &e
                    ldb       $03,S               * 1ED2 E6 63          fc
                    beq       L1EDF               * 1ED4 27 09          '.
                    cmpb      #2                  * 1ED6 C1 02          A.
                    beq       L1EE7               * 1ED8 27 0D          '.
                    ldb       #208                * 1EDA C6 D0          FP
                    lbra      L2119               * 1EDC 16 02 3A       ..:
L1EDF               ldx       $06,S               * 1EDF AE 66          .f
                    os9       I$SetStt            * 1EE1 10 3F 8E       .?.
                    lbra      L2122               * 1EE4 16 02 3B       ..;
L1EE7               pshs      U                   * 1EE7 34 40          4@
                    ldx       $08,S               * 1EE9 AE 68          .h
                    ldu       $0A,S               * 1EEB EE 6A          nj
                    os9       I$SetStt            * 1EED 10 3F 8E       .?.
                    puls      U                   * 1EF0 35 40          5@
                    lbra      L2122               * 1EF2 16 02 2D       ..-
L1EF5               ldx       $02,S               * 1EF5 AE 62          .b
                    lda       $05,S               * 1EF7 A6 65          &e
                    os9       I$Open              * 1EF9 10 3F 84       .?.
                    bcs       L1F01               * 1EFC 25 03          %.
                    os9       I$Close             * 1EFE 10 3F 8F       .?.
L1F01               lbra      L2122               * 1F01 16 02 1E       ...
L1F04               ldx       $02,S               * 1F04 AE 62          .b
                    lda       $05,S               * 1F06 A6 65          &e
                    os9       I$Open              * 1F08 10 3F 84       .?.
                    lbcs      L2119               * 1F0B 10 25 02 0A    .%..
                    tfr       A,B                 * 1F0F 1F 89          ..
                    clra                          * 1F11 4F             O
                    rts                           * 1F12 39             9
L1F13               lda       $03,S               * 1F13 A6 63          &c
                    os9       I$Close             * 1F15 10 3F 8F       .?.
                    lbra      L2122               * 1F18 16 02 07       ...
                    fcb       $AE                 * 1F1B AE             .
                    fcb       $62                 * 1F1C 62             b
                    fcb       $E6                 * 1F1D E6             f
                    fcb       $65                 * 1F1E 65             e
                    fcb       $10                 * 1F1F 10             .
                    fcb       $3F                 * 1F20 3F             ?
                    fcb       $85                 * 1F21 85             .
                    fcb       $16                 * 1F22 16             .
                    fcb       $01                 * 1F23 01             .
                    fcb       $FD                 * 1F24 FD             }
L1F25               ldx       $02,S               * 1F25 AE 62          .b
                    lda       $05,S               * 1F27 A6 65          &e
                    tfr       A,B                 * 1F29 1F 89          ..
                    andb      #36                 * 1F2B C4 24          D$
                    orb       #11                 * 1F2D CA 0B          J.
                    os9       I$Create            * 1F2F 10 3F 83       .?.
                    bcs       L1F38               * 1F32 25 04          %.
L1F34               tfr       A,B                 * 1F34 1F 89          ..
                    clra                          * 1F36 4F             O
                    rts                           * 1F37 39             9
L1F38               cmpb      #218                * 1F38 C1 DA          AZ
                    lbne      L2119               * 1F3A 10 26 01 DB    .&.[
                    lda       $05,S               * 1F3E A6 65          &e
                    bita      #128                * 1F40 85 80          ..
                    lbne      L2119               * 1F42 10 26 01 D3    .&.S
                    anda      #7                  * 1F46 84 07          ..
                    ldx       $02,S               * 1F48 AE 62          .b
                    os9       I$Open              * 1F4A 10 3F 84       .?.
                    lbcs      L2119               * 1F4D 10 25 01 C8    .%.H
                    pshs      U,A                 * 1F51 34 42          4B
                    ldx       #0                  * 1F53 8E 00 00       ...
                    leau      0,X                 * 1F56 33 84          3.
                    ldb       #2                  * 1F58 C6 02          F.
                    os9       I$SetStt            * 1F5A 10 3F 8E       .?.
                    puls      U,A                 * 1F5D 35 42          5B
                    bcc       L1F34               * 1F5F 24 D3          $S
                    pshs      B                   * 1F61 34 04          4.
                    os9       I$Close             * 1F63 10 3F 8F       .?.
                    puls      B                   * 1F66 35 04          5.
                    lbra      L2119               * 1F68 16 01 AE       ...
L1F6B               ldx       $02,S               * 1F6B AE 62          .b
                    os9       I$Delete            * 1F6D 10 3F 87       .?.
                    lbra      L2122               * 1F70 16 01 AF       ../
                    fcb       $A6                 * 1F73 A6             &
                    fcb       $63                 * 1F74 63             c
                    fcb       $10                 * 1F75 10             .
                    fcb       $3F                 * 1F76 3F             ?
                    fcb       $82                 * 1F77 82             .
                    fcb       $10                 * 1F78 10             .
                    fcb       $25                 * 1F79 25             %
                    fcb       $01                 * 1F7A 01             .
                    fcb       $9D                 * 1F7B 9D             .
                    fcb       $1F                 * 1F7C 1F             .
                    fcb       $89                 * 1F7D 89             .
                    fcc       "O9"                * 1F7E 4F 39          O9
L1F80               pshs      Y                   * 1F80 34 20          4
                    ldx       $06,S               * 1F82 AE 66          .f
                    lda       $05,S               * 1F84 A6 65          &e
                    ldy       $08,S               * 1F86 10 AE 68       ..h
                    pshs      Y                   * 1F89 34 20          4
                    os9       I$Read              * 1F8B 10 3F 89       .?.
                    bcc       L1F9D               * 1F8E 24 0D          $.
                    cmpb      #211                * 1F90 C1 D3          AS
                    bne       L1F98               * 1F92 26 04          &.
                    clra                          * 1F94 4F             O
                    clrb                          * 1F95 5F             _
                    puls      PC,Y,X              * 1F96 35 B0          50
L1F98               puls      Y,X                 * 1F98 35 30          50
                    lbra      L2119               * 1F9A 16 01 7C       ..|
L1F9D               tfr       Y,D                 * 1F9D 1F 20          .
                    puls      PC,Y,X              * 1F9F 35 B0          50
L1FA1               fcb       $34                 * 1FA1 34             4
                    fcb       $20                 * 1FA2 20
                    fcb       $A6                 * 1FA3 A6             &
                    fcb       $65                 * 1FA4 65             e
                    fcb       $AE                 * 1FA5 AE             .
                    fcb       $66                 * 1FA6 66             f
                    fcb       $10                 * 1FA7 10             .
                    fcb       $AE                 * 1FA8 AE             .
                    fcc       "h4 "               * 1FA9 68 34 20       h4
                    fcb       $10                 * 1FAC 10             .
                    fcb       $3F                 * 1FAD 3F             ?
                    fcb       $8B                 * 1FAE 8B             .
                    fcb       $20                 * 1FAF 20
                    fcb       $DD                 * 1FB0 DD             ]
L1FB1               pshs      Y                   * 1FB1 34 20          4
                    ldy       $08,S               * 1FB3 10 AE 68       ..h
                    beq       L1FC6               * 1FB6 27 0E          '.
                    lda       $05,S               * 1FB8 A6 65          &e
                    ldx       $06,S               * 1FBA AE 66          .f
                    os9       I$Write             * 1FBC 10 3F 8A       .?.
L1FBF               bcc       L1FC6               * 1FBF 24 05          $.
                    puls      Y                   * 1FC1 35 20          5
                    lbra      L2119               * 1FC3 16 01 53       ..S
L1FC6               tfr       Y,D                 * 1FC6 1F 20          .
                    puls      PC,Y                * 1FC8 35 A0          5
L1FCA               pshs      Y                   * 1FCA 34 20          4
                    ldy       $08,S               * 1FCC 10 AE 68       ..h
                    beq       L1FC6               * 1FCF 27 F5          'u
                    lda       $05,S               * 1FD1 A6 65          &e
                    ldx       $06,S               * 1FD3 AE 66          .f
                    os9       I$WritLn            * 1FD5 10 3F 8C       .?.
                    bra       L1FBF               * 1FD8 20 E5           e
L1FDA               pshs      U                   * 1FDA 34 40          4@
                    ldd       $0A,S               * 1FDC EC 6A          lj
                    bne       L1FE8               * 1FDE 26 08          &.
                    ldu       #0                  * 1FE0 CE 00 00       N..
                    ldx       #0                  * 1FE3 8E 00 00       ...
                    bra       L201C               * 1FE6 20 34           4
L1FE8               cmpd      #1                  * 1FE8 10 83 00 01    ....
                    beq       L2013               * 1FEC 27 25          '%
                    cmpd      #2                  * 1FEE 10 83 00 02    ....
                    beq       L2008               * 1FF2 27 14          '.
                    ldb       #247                * 1FF4 C6 F7          Fw
L1FF6               clra                          * 1FF6 4F             O
                    std       >$01B2,Y            * 1FF7 ED A9 01 B2    m).2
                    ldd       #-1                 * 1FFB CC FF FF       L..
                    leax      >$01A6,Y            * 1FFE 30 A9 01 A6    0).&
                    std       0,X                 * 2002 ED 84          m.
                    std       $02,X               * 2004 ED 02          m.
                    puls      PC,U                * 2006 35 C0          5@
L2008               lda       $05,S               * 2008 A6 65          &e
                    ldb       #2                  * 200A C6 02          F.
                    os9       I$GetStt            * 200C 10 3F 8D       .?.
                    bcs       L1FF6               * 200F 25 E5          %e
                    bra       L201C               * 2011 20 09           .
L2013               lda       $05,S               * 2013 A6 65          &e
                    ldb       #5                  * 2015 C6 05          F.
                    os9       I$GetStt            * 2017 10 3F 8D       .?.
                    bcs       L1FF6               * 201A 25 DA          %Z
L201C               tfr       U,D                 * 201C 1F 30          .0
                    addd      $08,S               * 201E E3 68          ch
                    std       >$01A8,Y            * 2020 ED A9 01 A8    m).(
                    tfr       D,U                 * 2024 1F 03          ..
                    tfr       X,D                 * 2026 1F 10          ..
                    adcb      $07,S               * 2028 E9 67          ig
                    adca      $06,S               * 202A A9 66          )f
                    bmi       L1FF6               * 202C 2B C8          +H
                    tfr       D,X                 * 202E 1F 01          ..
                    std       >$01A6,Y            * 2030 ED A9 01 A6    m).&
                    lda       $05,S               * 2034 A6 65          &e
                    os9       I$Seek              * 2036 10 3F 88       .?.
                    bcs       L1FF6               * 2039 25 BB          %;
                    leax      >$01A6,Y            * 203B 30 A9 01 A6    0).&
                    puls      PC,U                * 203F 35 C0          5@
                    fcb       $39                 * 2041 39             9
                    fcb       $8E                 * 2042 8E             .
                    fcb       $00                 * 2043 00             .
                    fcb       $00                 * 2044 00             .
                    fcb       $5F                 * 2045 5F             _
                    fcb       $10                 * 2046 10             .
                    fcb       $3F                 * 2047 3F             ?
                    fcb       $0A                 * 2048 0A             .
                    fcb       $16                 * 2049 16             .
                    fcb       $00                 * 204A 00             .
                    fcb       $CD                 * 204B CD             M
                    fcc       "94`"               * 204C 39 34 60       94`
                    fcb       $AE                 * 204F AE             .
                    fcb       $66                 * 2050 66             f
                    fcb       $10                 * 2051 10             .
                    fcb       $AE                 * 2052 AE             .
                    fcb       $68                 * 2053 68             h
                    fcb       $EE                 * 2054 EE             n
                    fcb       $6A                 * 2055 6A             j
                    fcb       $10                 * 2056 10             .
                    fcb       $3F                 * 2057 3F             ?
                    fcb       $17                 * 2058 17             .
                    fcb       $35                 * 2059 35             5
                    fcb       $E0                 * 205A E0             `
                    fcb       $A6                 * 205B A6             &
                    fcb       $63                 * 205C 63             c
                    fcb       $E6                 * 205D E6             f
                    fcb       $65                 * 205E 65             e
                    fcb       $10                 * 205F 10             .
                    fcb       $3F                 * 2060 3F             ?
                    fcb       $0F                 * 2061 0F             .
                    fcb       $10                 * 2062 10             .
                    fcb       $25                 * 2063 25             %
                    fcb       $00                 * 2064 00             .
                    fcb       $B3                 * 2065 B3             3
                    fcb       $39                 * 2066 39             9
L2067               ldx       $02,S               * 2067 AE 62          .b
                    os9       F$Sleep             * 2069 10 3F 0A       .?.
                    lbcs      L2119               * 206C 10 25 00 A9    .%.)
                    tfr       X,D                 * 2070 1F 10          ..
                    rts                           * 2072 39             9
                    fcb       $EC                 * 2073 EC             l
                    fcb       $A9                 * 2074 A9             )
                    fcb       $01                 * 2075 01             .
                    fcb       $A4                 * 2076 A4             $
                    fcb       $34                 * 2077 34             4
                    fcb       $06                 * 2078 06             .
                    fcb       $EC                 * 2079 EC             l
                    fcb       $64                 * 207A 64             d
                    fcb       $10                 * 207B 10             .
                    fcb       $A3                 * 207C A3             #
                    fcb       $A9                 * 207D A9             )
                    fcb       $02                 * 207E 02             .
                    fcb       $F4                 * 207F F4             t
                    fcb       $25                 * 2080 25             %
                    fcb       $25                 * 2081 25             %
                    fcb       $E3                 * 2082 E3             c
                    fcb       $A9                 * 2083 A9             )
                    fcb       $01                 * 2084 01             .
                    fcb       $A4                 * 2085 A4             $
                    fcb       $34                 * 2086 34             4
                    fcb       $20                 * 2087 20
                    fcb       $A3                 * 2088 A3             #
                    fcb       $E4                 * 2089 E4             d
                    fcb       $10                 * 208A 10             .
                    fcb       $3F                 * 208B 3F             ?
                    fcb       $07                 * 208C 07             .
                    fcb       $1F                 * 208D 1F             .
                    fcc       " 5 $"              * 208E 20 35 20 24     5 $
                    fcb       $06                 * 2092 06             .
                    fcb       $CC                 * 2093 CC             L
                    fcb       $FF                 * 2094 FF             .
                    fcb       $FF                 * 2095 FF             .
                    fcc       "2b9"               * 2096 32 62 39       2b9
                    fcb       $ED                 * 2099 ED             m
                    fcb       $A9                 * 209A A9             )
                    fcb       $01                 * 209B 01             .
                    fcb       $A4                 * 209C A4             $
                    fcb       $E3                 * 209D E3             c
                    fcb       $A9                 * 209E A9             )
                    fcb       $02                 * 209F 02             .
                    fcb       $F4                 * 20A0 F4             t
                    fcb       $A3                 * 20A1 A3             #
                    fcb       $E4                 * 20A2 E4             d
                    fcb       $ED                 * 20A3 ED             m
                    fcb       $A9                 * 20A4 A9             )
                    fcb       $02                 * 20A5 02             .
                    fcb       $F4                 * 20A6 F4             t
                    fcb       $32                 * 20A7 32             2
                    fcb       $62                 * 20A8 62             b
                    fcb       $EC                 * 20A9 EC             l
                    fcb       $A9                 * 20AA A9             )
                    fcb       $02                 * 20AB 02             .
                    fcb       $F4                 * 20AC F4             t
                    fcb       $34                 * 20AD 34             4
                    fcb       $06                 * 20AE 06             .
                    fcb       $A3                 * 20AF A3             #
                    fcb       $64                 * 20B0 64             d
                    fcb       $ED                 * 20B1 ED             m
                    fcb       $A9                 * 20B2 A9             )
                    fcb       $02                 * 20B3 02             .
                    fcb       $F4                 * 20B4 F4             t
                    fcb       $EC                 * 20B5 EC             l
                    fcb       $A9                 * 20B6 A9             )
                    fcb       $01                 * 20B7 01             .
                    fcb       $A4                 * 20B8 A4             $
                    fcb       $A3                 * 20B9 A3             #
                    fcb       $E1                 * 20BA E1             a
                    fcb       $34                 * 20BB 34             4
                    fcb       $06                 * 20BC 06             .
                    fcb       $4F                 * 20BD 4F             O
                    fcb       $AE                 * 20BE AE             .
                    fcb       $E4                 * 20BF E4             d
                    fcb       $A7                 * 20C0 A7             '
                    fcb       $80                 * 20C1 80             .
                    fcb       $AC                 * 20C2 AC             ,
                    fcb       $A9                 * 20C3 A9             )
                    fcb       $01                 * 20C4 01             .
                    fcb       $A4                 * 20C5 A4             $
                    fcb       $25                 * 20C6 25             %
                    fcb       $F8                 * 20C7 F8             x
                    fcb       $35                 * 20C8 35             5
                    fcb       $86                 * 20C9 86             .
L20CA               ldd       $02,S               * 20CA EC 62          lb
                    addd      >$01AE,Y            * 20CC E3 A9 01 AE    c)..
                    bcs       L20F3               * 20D0 25 21          %!
                    cmpd      >$01B0,Y            * 20D2 10 A3 A9 01 B0 .#).0
                    bcc       L20F3               * 20D7 24 1A          $.
                    pshs      D                   * 20D9 34 06          4.
                    ldx       >$01AE,Y            * 20DB AE A9 01 AE    .)..
                    clra                          * 20DF 4F             O
L20E0               cmpx      0,S                 * 20E0 AC E4          ,d
                    bcc       L20E8               * 20E2 24 04          $.
                    sta       ,X+                 * 20E4 A7 80          '.
                    bra       L20E0               * 20E6 20 F8           x
L20E8               ldd       >$01AE,Y            * 20E8 EC A9 01 AE    l)..
                    puls      X                   * 20EC 35 10          5.
                    stx       >$01AE,Y            * 20EE AF A9 01 AE    /)..
                    rts                           * 20F2 39             9
L20F3               ldd       #-1                 * 20F3 CC FF FF       L..
                    rts                           * 20F6 39             9
L20F7               pshs      U                   * 20F7 34 40          4@
                    tfr       Y,U                 * 20F9 1F 23          .#
                    ldx       $04,S               * 20FB AE 64          .d
                    stx       >$02F6,Y            * 20FD AF A9 02 F6    /).v
                    leax      >L210D,PC           * 2101 30 8D 00 08    0...
                    os9       F$Icpt              * 2105 10 3F 09       .?.
                    puls      U                   * 2108 35 40          5@
                    lbra      L2122               * 210A 16 00 15       ...
L210D               fcb       $1F                 * 210D 1F             .
                    fcc       "2O4"               * 210E 32 4F 34       2O4
                    fcb       $06                 * 2111 06             .
                    fcb       $AD                 * 2112 AD             -
                    fcb       $B9                 * 2113 B9             9
                    fcb       $02                 * 2114 02             .
                    fcb       $F6                 * 2115 F6             v
                    fcc       "2b;"               * 2116 32 62 3B       2b;
L2119               clra                          * 2119 4F             O
                    std       >$01B2,Y            * 211A ED A9 01 B2    m).2
                    ldd       #-1                 * 211E CC FF FF       L..
                    rts                           * 2121 39             9
L2122               bcs       L2119               * 2122 25 F5          %u
                    clra                          * 2124 4F             O
                    clrb                          * 2125 5F             _
                    rts                           * 2126 39             9
L2127               lbsr      L2132               * 2127 17 00 08       ...
                    lbsr      L1A0C               * 212A 17 F8 DF       .x_
L212D               ldd       $02,S               * 212D EC 62          lb
                    os9       F$Exit              * 212F 10 3F 06       .?.
L2132               rts                           * 2132 39             9
L2133               lda       $03,S               * 2133 A6 63          &c
                    ldb       #1                  * 2135 C6 01          F.
                    os9       I$GetStt            * 2137 10 3F 8D       .?.
                    lbcs      L2119               * 213A 10 25 FF DB    .%.[
                    clra                          * 213E 4F             O
                    rts                           * 213F 39             9
L2140               lda       $03,S               * 2140 A6 63          &c
                    ldb       #26                 * 2142 C6 1A          F.
                    ldx       $04,S               * 2144 AE 64          .d
                    os9       I$SetStt            * 2146 10 3F 8E       .?.
                    lbra      L2122               * 2149 16 FF D6       ..V
L214C               lda       $03,S               * 214C A6 63          &c
                    ldb       #27                 * 214E C6 1B          F.
                    os9       I$SetStt            * 2150 10 3F 8E       .?.
                    lbra      L2122               * 2153 16 FF CC       ..L
                    fcb       $C6                 * 2156 C6             F
                    fcb       $01                 * 2157 01             .
                    fcb       $20                 * 2158 20
                    fcb       $30                 * 2159 30             0
                    fcb       $C6                 * 215A C6             F
                    fcb       $03                 * 215B 03             .
                    fcb       $20                 * 215C 20
                    fcb       $2C                 * 215D 2C             ,
                    fcb       $C6                 * 215E C6             F
                    fcb       $04                 * 215F 04             .
                    fcb       $20                 * 2160 20
                    fcb       $28                 * 2161 28             (
                    fcb       $CC                 * 2162 CC             L
                    fcb       $05                 * 2163 05             .
                    fcc       "  R"               * 2164 20 20 52         R
                    fcb       $CC                 * 2167 CC             L
                    fcb       $05                 * 2168 05             .
                    fcc       "! M"               * 2169 21 20 4D       ! M
                    fcb       $C6                 * 216C C6             F
                    fcb       $06                 * 216D 06             .
                    fcb       $20                 * 216E 20
                    fcb       $1A                 * 216F 1A             .
                    fcb       $C6                 * 2170 C6             F
                    fcb       $07                 * 2171 07             .
                    fcb       $20                 * 2172 20
                    fcb       $16                 * 2173 16             .
                    fcb       $C6                 * 2174 C6             F
                    fcb       $08                 * 2175 08             .
                    fcb       $20                 * 2176 20
                    fcb       $12                 * 2177 12             .
                    fcb       $C6                 * 2178 C6             F
                    fcb       $09                 * 2179 09             .
                    fcb       $20                 * 217A 20
                    fcb       $0E                 * 217B 0E             .
                    fcb       $C6                 * 217C C6             F
                    fcb       $0A                 * 217D 0A             .
                    fcb       $20                 * 217E 20
                    fcb       $0A                 * 217F 0A             .
                    fcb       $C6                 * 2180 C6             F
                    fcb       $0B                 * 2181 0B             .
                    fcb       $20                 * 2182 20
                    fcb       $06                 * 2183 06             .
L2184               ldb       #12                 * 2184 C6 0C          F.
                    bra       L218A               * 2186 20 02           .
                    fcb       $C6                 * 2188 C6             F
                    fcb       $0D                 * 2189 0D             .
L218A               stb       >$02F8,Y            * 218A E7 A9 02 F8    g).x
                    ldb       #1                  * 218E C6 01          F.
                    lbra      L21C2               * 2190 16 00 2F       ../
L2193               ldd       #7968               * 2193 CC 1F 20       L.
                    bra       L21B9               * 2196 20 21           !
L2198               ldd       #7969               * 2198 CC 1F 21       L.!
                    bra       L21B9               * 219B 20 1C           .
                    fcb       $CC                 * 219D CC             L
                    fcb       $1F                 * 219E 1F             .
                    fcb       $22                 * 219F 22             "
                    fcb       $20                 * 21A0 20
                    fcb       $17                 * 21A1 17             .
                    fcb       $CC                 * 21A2 CC             L
                    fcb       $1F                 * 21A3 1F             .
                    fcb       $23                 * 21A4 23             #
                    fcb       $20                 * 21A5 20
                    fcb       $12                 * 21A6 12             .
                    fcb       $CC                 * 21A7 CC             L
                    fcb       $1F                 * 21A8 1F             .
                    fcb       $24                 * 21A9 24             $
                    fcb       $20                 * 21AA 20
                    fcb       $0D                 * 21AB 0D             .
                    fcb       $CC                 * 21AC CC             L
                    fcb       $1F                 * 21AD 1F             .
                    fcb       $25                 * 21AE 25             %
                    fcb       $20                 * 21AF 20
                    fcb       $08                 * 21B0 08             .
                    fcb       $CC                 * 21B1 CC             L
                    fcb       $1F                 * 21B2 1F             .
                    fcb       $30                 * 21B3 30             0
                    fcb       $20                 * 21B4 20
                    fcb       $03                 * 21B5 03             .
                    fcb       $CC                 * 21B6 CC             L
                    fcb       $1F                 * 21B7 1F             .
                    fcb       $31                 * 21B8 31             1
L21B9               std       >$02F8,Y            * 21B9 ED A9 02 F8    m).x
                    ldb       #2                  * 21BD C6 02          F.
                    lbra      L21C2               * 21BF 16 00 00       ...
L21C2               clra                          * 21C2 4F             O
                    leax      >$02F8,Y            * 21C3 30 A9 02 F8    0).x
                    pshs      Y                   * 21C7 34 20          4
                    tfr       D,Y                 * 21C9 1F 02          ..
                    lda       $05,S               * 21CB A6 65          &e
                    os9       I$Write             * 21CD 10 3F 8A       .?.
                    puls      Y                   * 21D0 35 20          5
                    bcs       L21D7               * 21D2 25 03          %.
                    clra                          * 21D4 4F             O
                    clrb                          * 21D5 5F             _
                    rts                           * 21D6 39             9
L21D7               clra                          * 21D7 4F             O
                    std       >$01B2,Y            * 21D8 ED A9 01 B2    m).2
                    ldd       #-1                 * 21DC CC FF FF       L..
                    rts                           * 21DF 39             9
L21E0               fcb       $00                 * 21E0 00             .
                    fcb       $01                 * 21E1 01             .
                    fcb       $00                 * 21E2 00             .
                    fcb       $01                 * 21E3 01             .
                    fcb       $63                 * 21E4 63             c
                    fcb       $01                 * 21E5 01             .
                    fcb       $06                 * 21E6 06             .
                    fcb       $04                 * 21E7 04             .
                    fcb       $15                 * 21E8 15             .
                    fcb       $18                 * 21E9 18             .
                    fcb       $27                 * 21EA 27             '
                    fcb       $10                 * 21EB 10             .
                    fcb       $03                 * 21EC 03             .
                    fcb       $E8                 * 21ED E8             h
                    fcb       $00                 * 21EE 00             .
                    fcb       $64                 * 21EF 64             d
                    fcb       $00                 * 21F0 00             .
                    fcb       $0A                 * 21F1 0A             .
                    fcb       $00                 * 21F2 00             .
                    fcb       $0E                 * 21F3 0E             .
                    fcb       $6C                 * 21F4 6C             l
                    fcb       $78                 * 21F5 78             x
                    fcb       $00                 * 21F6 00             .
                    fcb       $00                 * 21F7 00             .
                    fcb       $00                 * 21F8 00             .
                    fcb       $00                 * 21F9 00             .
                    fcb       $00                 * 21FA 00             .
                    fcb       $00                 * 21FB 00             .
                    fcb       $00                 * 21FC 00             .
                    fcb       $00                 * 21FD 00             .
                    fcb       $01                 * 21FE 01             .
                    fcb       $00                 * 21FF 00             .
                    fcb       $00                 * 2200 00             .
                    fcb       $00                 * 2201 00             .
                    fcb       $00                 * 2202 00             .
                    fcb       $00                 * 2203 00             .
                    fcb       $00                 * 2204 00             .
                    fcb       $00                 * 2205 00             .
                    fcb       $00                 * 2206 00             .
                    fcb       $00                 * 2207 00             .
                    fcb       $00                 * 2208 00             .
                    fcb       $00                 * 2209 00             .
                    fcb       $00                 * 220A 00             .
                    fcb       $02                 * 220B 02             .
                    fcb       $00                 * 220C 00             .
                    fcb       $01                 * 220D 01             .
                    fcb       $00                 * 220E 00             .
                    fcb       $00                 * 220F 00             .
                    fcb       $00                 * 2210 00             .
                    fcb       $00                 * 2211 00             .
                    fcb       $00                 * 2212 00             .
                    fcb       $00                 * 2213 00             .
                    fcb       $00                 * 2214 00             .
                    fcb       $00                 * 2215 00             .
                    fcb       $00                 * 2216 00             .
                    fcb       $00                 * 2217 00             .
                    fcb       $42                 * 2218 42             B
                    fcb       $00                 * 2219 00             .
                    fcb       $02                 * 221A 02             .
                    fcb       $00                 * 221B 00             .
                    fcb       $00                 * 221C 00             .
                    fcb       $00                 * 221D 00             .
                    fcb       $00                 * 221E 00             .
                    fcb       $00                 * 221F 00             .
                    fcb       $00                 * 2220 00             .
                    fcb       $00                 * 2221 00             .
                    fcb       $00                 * 2222 00             .
                    fcb       $00                 * 2223 00             .
                    fcb       $00                 * 2224 00             .
                    fcb       $00                 * 2225 00             .
                    fcb       $00                 * 2226 00             .
                    fcb       $00                 * 2227 00             .
                    fcb       $00                 * 2228 00             .
                    fcb       $00                 * 2229 00             .
                    fcb       $00                 * 222A 00             .
                    fcb       $00                 * 222B 00             .
                    fcb       $00                 * 222C 00             .
                    fcb       $00                 * 222D 00             .
                    fcb       $00                 * 222E 00             .
                    fcb       $00                 * 222F 00             .
                    fcb       $00                 * 2230 00             .
                    fcb       $00                 * 2231 00             .
                    fcb       $00                 * 2232 00             .
                    fcb       $00                 * 2233 00             .
                    fcb       $00                 * 2234 00             .
                    fcb       $00                 * 2235 00             .
                    fcb       $00                 * 2236 00             .
                    fcb       $00                 * 2237 00             .
                    fcb       $00                 * 2238 00             .
                    fcb       $00                 * 2239 00             .
                    fcb       $00                 * 223A 00             .
                    fcb       $00                 * 223B 00             .
                    fcb       $00                 * 223C 00             .
                    fcb       $00                 * 223D 00             .
                    fcb       $00                 * 223E 00             .
                    fcb       $00                 * 223F 00             .
                    fcb       $00                 * 2240 00             .
                    fcb       $00                 * 2241 00             .
                    fcb       $00                 * 2242 00             .
                    fcb       $00                 * 2243 00             .
                    fcb       $00                 * 2244 00             .
                    fcb       $00                 * 2245 00             .
                    fcb       $00                 * 2246 00             .
                    fcb       $00                 * 2247 00             .
                    fcb       $00                 * 2248 00             .
                    fcb       $00                 * 2249 00             .
                    fcb       $00                 * 224A 00             .
                    fcb       $00                 * 224B 00             .
                    fcb       $00                 * 224C 00             .
                    fcb       $00                 * 224D 00             .
                    fcb       $00                 * 224E 00             .
                    fcb       $00                 * 224F 00             .
                    fcb       $00                 * 2250 00             .
                    fcb       $00                 * 2251 00             .
                    fcb       $00                 * 2252 00             .
                    fcb       $00                 * 2253 00             .
                    fcb       $00                 * 2254 00             .
                    fcb       $00                 * 2255 00             .
                    fcb       $00                 * 2256 00             .
                    fcb       $00                 * 2257 00             .
                    fcb       $00                 * 2258 00             .
                    fcb       $00                 * 2259 00             .
                    fcb       $00                 * 225A 00             .
                    fcb       $00                 * 225B 00             .
                    fcb       $00                 * 225C 00             .
                    fcb       $00                 * 225D 00             .
                    fcb       $00                 * 225E 00             .
                    fcb       $00                 * 225F 00             .
                    fcb       $00                 * 2260 00             .
                    fcb       $00                 * 2261 00             .
                    fcb       $00                 * 2262 00             .
                    fcb       $00                 * 2263 00             .
                    fcb       $00                 * 2264 00             .
                    fcb       $00                 * 2265 00             .
                    fcb       $00                 * 2266 00             .
                    fcb       $00                 * 2267 00             .
                    fcb       $00                 * 2268 00             .
                    fcb       $00                 * 2269 00             .
                    fcb       $00                 * 226A 00             .
                    fcb       $00                 * 226B 00             .
                    fcb       $00                 * 226C 00             .
                    fcb       $00                 * 226D 00             .
                    fcb       $00                 * 226E 00             .
                    fcb       $00                 * 226F 00             .
                    fcb       $00                 * 2270 00             .
                    fcb       $00                 * 2271 00             .
                    fcb       $00                 * 2272 00             .
                    fcb       $00                 * 2273 00             .
                    fcb       $00                 * 2274 00             .
                    fcb       $00                 * 2275 00             .
                    fcb       $00                 * 2276 00             .
                    fcb       $00                 * 2277 00             .
                    fcb       $00                 * 2278 00             .
                    fcb       $00                 * 2279 00             .
                    fcb       $00                 * 227A 00             .
                    fcb       $00                 * 227B 00             .
                    fcb       $00                 * 227C 00             .
                    fcb       $00                 * 227D 00             .
                    fcb       $00                 * 227E 00             .
                    fcb       $00                 * 227F 00             .
                    fcb       $00                 * 2280 00             .
                    fcb       $00                 * 2281 00             .
                    fcb       $00                 * 2282 00             .
                    fcb       $00                 * 2283 00             .
                    fcb       $00                 * 2284 00             .
                    fcb       $00                 * 2285 00             .
                    fcb       $00                 * 2286 00             .
                    fcb       $00                 * 2287 00             .
                    fcb       $00                 * 2288 00             .
                    fcb       $00                 * 2289 00             .
                    fcb       $00                 * 228A 00             .
                    fcb       $00                 * 228B 00             .
                    fcb       $00                 * 228C 00             .
                    fcb       $00                 * 228D 00             .
                    fcb       $00                 * 228E 00             .
                    fcb       $00                 * 228F 00             .
                    fcb       $00                 * 2290 00             .
                    fcb       $00                 * 2291 00             .
                    fcb       $00                 * 2292 00             .
                    fcb       $00                 * 2293 00             .
                    fcb       $00                 * 2294 00             .
                    fcb       $00                 * 2295 00             .
                    fcb       $00                 * 2296 00             .
                    fcb       $00                 * 2297 00             .
                    fcb       $00                 * 2298 00             .
                    fcb       $00                 * 2299 00             .
                    fcb       $00                 * 229A 00             .
                    fcb       $00                 * 229B 00             .
                    fcb       $00                 * 229C 00             .
                    fcb       $00                 * 229D 00             .
                    fcb       $00                 * 229E 00             .
                    fcb       $00                 * 229F 00             .
                    fcb       $00                 * 22A0 00             .
                    fcb       $00                 * 22A1 00             .
                    fcb       $00                 * 22A2 00             .
                    fcb       $00                 * 22A3 00             .
                    fcb       $00                 * 22A4 00             .
                    fcb       $00                 * 22A5 00             .
                    fcb       $00                 * 22A6 00             .
                    fcb       $00                 * 22A7 00             .
                    fcb       $00                 * 22A8 00             .
                    fcb       $00                 * 22A9 00             .
                    fcb       $00                 * 22AA 00             .
                    fcb       $00                 * 22AB 00             .
                    fcb       $00                 * 22AC 00             .
                    fcb       $00                 * 22AD 00             .
                    fcb       $00                 * 22AE 00             .
                    fcb       $00                 * 22AF 00             .
                    fcb       $00                 * 22B0 00             .
                    fcb       $00                 * 22B1 00             .
                    fcb       $00                 * 22B2 00             .
                    fcb       $00                 * 22B3 00             .
                    fcb       $00                 * 22B4 00             .
                    fcb       $00                 * 22B5 00             .
                    fcb       $00                 * 22B6 00             .
                    fcb       $00                 * 22B7 00             .
                    fcb       $00                 * 22B8 00             .
                    fcb       $00                 * 22B9 00             .
                    fcb       $00                 * 22BA 00             .
                    fcb       $00                 * 22BB 00             .
                    fcb       $00                 * 22BC 00             .
                    fcb       $00                 * 22BD 00             .
                    fcb       $00                 * 22BE 00             .
                    fcb       $00                 * 22BF 00             .
                    fcb       $00                 * 22C0 00             .
                    fcb       $00                 * 22C1 00             .
                    fcb       $00                 * 22C2 00             .
                    fcb       $00                 * 22C3 00             .
                    fcb       $00                 * 22C4 00             .
                    fcb       $00                 * 22C5 00             .
                    fcb       $00                 * 22C6 00             .
                    fcb       $00                 * 22C7 00             .
                    fcb       $01                 * 22C8 01             .
                    fcb       $01                 * 22C9 01             .
                    fcb       $01                 * 22CA 01             .
                    fcb       $01                 * 22CB 01             .
                    fcb       $01                 * 22CC 01             .
                    fcb       $01                 * 22CD 01             .
                    fcb       $01                 * 22CE 01             .
                    fcb       $01                 * 22CF 01             .
                    fcb       $01                 * 22D0 01             .
                    fcb       $11                 * 22D1 11             .
                    fcb       $11                 * 22D2 11             .
                    fcb       $01                 * 22D3 01             .
                    fcb       $11                 * 22D4 11             .
                    fcb       $11                 * 22D5 11             .
                    fcb       $01                 * 22D6 01             .
                    fcb       $01                 * 22D7 01             .
                    fcb       $01                 * 22D8 01             .
                    fcb       $01                 * 22D9 01             .
                    fcb       $01                 * 22DA 01             .
                    fcb       $01                 * 22DB 01             .
                    fcb       $01                 * 22DC 01             .
                    fcb       $01                 * 22DD 01             .
                    fcb       $01                 * 22DE 01             .
                    fcb       $01                 * 22DF 01             .
                    fcb       $01                 * 22E0 01             .
                    fcb       $01                 * 22E1 01             .
                    fcb       $01                 * 22E2 01             .
                    fcb       $01                 * 22E3 01             .
                    fcb       $01                 * 22E4 01             .
                    fcb       $01                 * 22E5 01             .
                    fcb       $01                 * 22E6 01             .
                    fcb       $01                 * 22E7 01             .
                    fcc       "0               HHHHHHHHHH       BBBBBB" * 22E8 30 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 48 48 48 48 48 48 48 48 48 48 20 20 20 20 20 20 20 42 42 42 42 42 42 0               HHHHHHHHHH       BBBBBB
                    fcb       $02                 * 230F 02             .
                    fcb       $02                 * 2310 02             .
                    fcb       $02                 * 2311 02             .
                    fcb       $02                 * 2312 02             .
                    fcb       $02                 * 2313 02             .
                    fcb       $02                 * 2314 02             .
                    fcb       $02                 * 2315 02             .
                    fcb       $02                 * 2316 02             .
                    fcb       $02                 * 2317 02             .
                    fcb       $02                 * 2318 02             .
                    fcb       $02                 * 2319 02             .
                    fcb       $02                 * 231A 02             .
                    fcb       $02                 * 231B 02             .
                    fcb       $02                 * 231C 02             .
                    fcb       $02                 * 231D 02             .
                    fcb       $02                 * 231E 02             .
                    fcb       $02                 * 231F 02             .
                    fcb       $02                 * 2320 02             .
                    fcb       $02                 * 2321 02             .
                    fcb       $02                 * 2322 02             .
                    fcc       "      DDDDDD"      * 2323 20 20 20 20 20 20 44 44 44 44 44 44       DDDDDD
                    fcb       $04                 * 232F 04             .
                    fcb       $04                 * 2330 04             .
                    fcb       $04                 * 2331 04             .
                    fcb       $04                 * 2332 04             .
                    fcb       $04                 * 2333 04             .
                    fcb       $04                 * 2334 04             .
                    fcb       $04                 * 2335 04             .
                    fcb       $04                 * 2336 04             .
                    fcb       $04                 * 2337 04             .
                    fcb       $04                 * 2338 04             .
                    fcb       $04                 * 2339 04             .
                    fcb       $04                 * 233A 04             .
                    fcb       $04                 * 233B 04             .
                    fcb       $04                 * 233C 04             .
                    fcb       $04                 * 233D 04             .
                    fcb       $04                 * 233E 04             .
                    fcb       $04                 * 233F 04             .
                    fcb       $04                 * 2340 04             .
                    fcb       $04                 * 2341 04             .
                    fcb       $04                 * 2342 04             .
                    fcc       "    "              * 2343 20 20 20 20
                    fcb       $01                 * 2347 01             .
                    fcb       $00                 * 2348 00             .
                    fcb       $00                 * 2349 00             .
                    fcb       $00                 * 234A 00             .
                    fcb       $01                 * 234B 01             .
                    fcb       $00                 * 234C 00             .
                    fcb       $0E                 * 234D 0E             .
                    fcc       "Terminal"          * 234E 54 65 72 6D 69 6E 61 6C Terminal
                    fcb       $00                 * 2356 00             .

                    emod
eom                 equ       *
                    end
