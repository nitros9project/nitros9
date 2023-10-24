                    nam       New_user
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
U000D               rmb       338
U015F               rmb       2
U0161               rmb       58
U019B               rmb       1
U019C               rmb       3
U019F               rmb       2
U01A1               rmb       1418
size                equ       .

name                fcs       /New_user/          * 000D 4E 65 77 5F 75 73 65 F2 New_user
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
                    leax      >$03AB,X            * 002E 30 89 03 AB    0..+
                    pshs      X                   * 0032 34 10          4.
                    leay      >L15F9,PC           * 0034 31 8D 15 C1    1..A
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
                    leax      0,PC                * 005A 30 8D FF A2    0.."
                    lbsr      L0164               * 005E 17 01 03       ...
L0061               ldd       ,Y++                * 0061 EC A1          l!
                    beq       L006A               * 0063 27 05          '.
                    leax      U0000,U             * 0065 30 C4          0D
                    lbsr      L0164               * 0067 17 00 FA       ..z
L006A               leas      $04,S               * 006A 32 64          2d
                    puls      X                   * 006C 35 10          5.
                    stx       >U019F,U            * 006E AF C9 01 9F    /I..
                    sty       >U015F,U            * 0072 10 AF C9 01 5F ./I._
                    ldd       #1                  * 0077 CC 00 01       L..
                    std       >U019B,U            * 007A ED C9 01 9B    mI..
                    leay      >U0161,U            * 007E 31 C9 01 61    1I.a
                    leax      0,S                 * 0082 30 E4          0d
                    lda       ,X+                 * 0084 A6 80          &.
L0086               ldb       >U019C,U            * 0086 E6 C9 01 9C    fI..
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
                    inc       >U019C,U            * 00A8 6C C9 01 9C    lI..
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
                    inc       >U019C,U            * 00CA 6C C9 01 9C    lI..
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
L00E2               leax      >U015F,U            * 00E2 30 C9 01 5F    0I._
                    pshs      X                   * 00E6 34 10          4.
                    ldd       >U019B,U            * 00E8 EC C9 01 9B    lI..
                    pshs      D                   * 00EC 34 06          4.
                    leay      U0000,U             * 00EE 31 C4          1D
                    bsr       L00FC               * 00F0 8D 0A          ..
                    lbsr      L017E               * 00F2 17 00 89       ...
                    clr       ,-S                 * 00F5 6F E2          ob
                    clr       ,-S                 * 00F7 6F E2          ob
                    lbsr      L15ED               * 00F9 17 14 F1       ..q
L00FC               leax      >$03AB,Y            * 00FC 30 A9 03 AB    0).+
                    stx       >$01A9,Y            * 0100 AF A9 01 A9    /).)
                    sts       >$019D,Y            * 0104 10 EF A9 01 9D .o)..
                    sts       >$01AB,Y            * 0109 10 EF A9 01 AB .o).+
                    ldd       #-126               * 010E CC FF 82       L..
L0111               leax      D,S                 * 0111 30 EB          0k
                    cmpx      >$01AB,Y            * 0113 AC A9 01 AB    ,).+
                    bcc       L0123               * 0117 24 0A          $.
                    cmpx      >$01A9,Y            * 0119 AC A9 01 A9    ,).)
                    bcs       L013D               * 011D 25 1E          %.
                    stx       >$01AB,Y            * 011F AF A9 01 AB    /).+
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
                    lbsr      L15F3               * 014F 17 14 A1       ..!
                    ldd       >$019D,Y            * 0152 EC A9 01 9D    l)..
                    subd      >$01AB,Y            * 0156 A3 A9 01 AB    #).+
                    rts                           * 015A 39             9
                    fcb       $EC                 * 015B EC             l
                    fcb       $A9                 * 015C A9             )
                    fcb       $01                 * 015D 01             .
                    fcb       $AB                 * 015E AB             +
                    fcb       $A3                 * 015F A3             #
                    fcb       $A9                 * 0160 A9             )
                    fcb       $01                 * 0161 01             .
                    fcb       $A9                 * 0162 A9             )
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
L017E               pshs      U                   * 017E 34 40          4@
                    ldd       #-77                * 0180 CC FF B3       L.3
                    lbsr      L0111               * 0183 17 FF 8B       ...
                    leas      -$03,S              * 0186 32 7D          2}
                    leax      >L03D2,PC           * 0188 30 8D 02 46    0..F
                    pshs      X                   * 018C 34 10          4.
                    ldx       $0B,S               * 018E AE 6B          .k
                    ldd       $02,X               * 0190 EC 02          l.
                    pshs      D                   * 0192 34 06          4.
                    lbsr      L0884               * 0194 17 06 ED       ..m
                    leas      $04,S               * 0197 32 64          2d
                    std       $01,S               * 0199 ED 61          ma
                    bne       L01AE               * 019B 26 11          &.
                    ldd       >$01AD,Y            * 019D EC A9 01 AD    l).-
                    pshs      D                   * 01A1 34 06          4.
                    leax      >L03D4,PC           * 01A3 30 8D 02 2D    0..-
                    pshs      X                   * 01A7 34 10          4.
                    lbsr      L03B0               * 01A9 17 02 04       ...
                    leas      $04,S               * 01AC 32 64          2d
L01AE               ldd       #78                 * 01AE CC 00 4E       L.N
                    lbra      L02E1               * 01B1 16 01 2D       ..-
L01B4               leax      >L03E5,PC           * 01B4 30 8D 02 2D    0..-
                    pshs      X                   * 01B8 34 10          4.
                    lbsr      L095A               * 01BA 17 07 9D       ...
                    leas      $02,S               * 01BD 32 62          2b
                    leax      >L042F,PC           * 01BF 30 8D 02 6C    0..l
                    pshs      X                   * 01C3 34 10          4.
                    lbsr      L095A               * 01C5 17 07 92       ...
                    leas      $02,S               * 01C8 32 62          2b
                    leax      >L0466,PC           * 01CA 30 8D 02 98    0...
                    pshs      X                   * 01CE 34 10          4.
                    lbsr      L095A               * 01D0 17 07 87       ...
                    leas      $02,S               * 01D3 32 62          2b
                    leax      >L04A5,PC           * 01D5 30 8D 02 CC    0..L
                    pshs      X                   * 01D9 34 10          4.
                    lbsr      L095A               * 01DB 17 07 7C       ..|
                    leas      $02,S               * 01DE 32 62          2b
                    leax      >L04F0,PC           * 01E0 30 8D 03 0C    0...
                    pshs      X                   * 01E4 34 10          4.
                    lbsr      L095A               * 01E6 17 07 71       ..q
                    leas      $02,S               * 01E9 32 62          2b
                    leax      >$01AF,Y            * 01EB 30 A9 01 AF    0)./
                    pshs      X                   * 01EF 34 10          4.
                    lbsr      L08D6               * 01F1 17 06 E2       ..b
                    leas      $02,S               * 01F4 32 62          2b
                    leax      >L0510,PC           * 01F6 30 8D 03 16    0...
                    pshs      X                   * 01FA 34 10          4.
                    lbsr      L095A               * 01FC 17 07 5B       ..[
                    leas      $02,S               * 01FF 32 62          2b
                    leax      >$01FF,Y            * 0201 30 A9 01 FF    0)..
                    pshs      X                   * 0205 34 10          4.
                    lbsr      L08D6               * 0207 17 06 CC       ..L
                    leas      $02,S               * 020A 32 62          2b
                    leax      >L0530,PC           * 020C 30 8D 03 20    0..
                    pshs      X                   * 0210 34 10          4.
                    lbsr      L095A               * 0212 17 07 45       ..E
                    leas      $02,S               * 0215 32 62          2b
                    leax      >$024F,Y            * 0217 30 A9 02 4F    0).O
                    pshs      X                   * 021B 34 10          4.
                    lbsr      L08D6               * 021D 17 06 B6       ..6
                    leas      $02,S               * 0220 32 62          2b
                    leax      >L0550,PC           * 0222 30 8D 03 2A    0..*
                    pshs      X                   * 0226 34 10          4.
                    lbsr      L095A               * 0228 17 07 2F       ../
                    leas      $02,S               * 022B 32 62          2b
                    leax      >$029F,Y            * 022D 30 A9 02 9F    0)..
                    pshs      X                   * 0231 34 10          4.
                    lbsr      L08D6               * 0233 17 06 A0       ..
                    leas      $02,S               * 0236 32 62          2b
                    leax      >L0570,PC           * 0238 30 8D 03 34    0..4
                    pshs      X                   * 023C 34 10          4.
                    lbsr      L095A               * 023E 17 07 19       ...
                    leas      $02,S               * 0241 32 62          2b
                    leax      >$02EF,Y            * 0243 30 A9 02 EF    0).o
                    pshs      X                   * 0247 34 10          4.
                    lbsr      L08D6               * 0249 17 06 8A       ...
                    leas      $02,S               * 024C 32 62          2b
                    leax      >L0590,PC           * 024E 30 8D 03 3E    0..>
                    pshs      X                   * 0252 34 10          4.
                    lbsr      L095A               * 0254 17 07 03       ...
                    leas      $02,S               * 0257 32 62          2b
                    leax      >$033F,Y            * 0259 30 A9 03 3F    0).?
                    pshs      X                   * 025D 34 10          4.
                    lbsr      L08D6               * 025F 17 06 74       ..t
                    leas      $02,S               * 0262 32 62          2b
                    leax      >$02EF,Y            * 0264 30 A9 02 EF    0).o
                    pshs      X                   * 0268 34 10          4.
                    leax      >$01AF,Y            * 026A 30 A9 01 AF    0)./
                    pshs      X                   * 026E 34 10          4.
                    leax      >L05B0,PC           * 0270 30 8D 03 3C    0..<
                    pshs      X                   * 0274 34 10          4.
                    lbsr      L095A               * 0276 17 06 E1       ..a
                    leas      $06,S               * 0279 32 66          2f
                    leax      >$024F,Y            * 027B 30 A9 02 4F    0).O
                    pshs      X                   * 027F 34 10          4.
                    leax      >$01FF,Y            * 0281 30 A9 01 FF    0)..
                    pshs      X                   * 0285 34 10          4.
                    leax      >L05C7,PC           * 0287 30 8D 03 3C    0..<
                    pshs      X                   * 028B 34 10          4.
                    lbsr      L095A               * 028D 17 06 CA       ..J
                    leas      $06,S               * 0290 32 66          2f
                    leax      >$029F,Y            * 0292 30 A9 02 9F    0)..
                    pshs      X                   * 0296 34 10          4.
                    leax      >L05DC,PC           * 0298 30 8D 03 40    0..@
                    pshs      X                   * 029C 34 10          4.
                    lbsr      L095A               * 029E 17 06 B9       ..9
                    leas      $04,S               * 02A1 32 64          2d
                    leax      >$033F,Y            * 02A3 30 A9 03 3F    0).?
                    pshs      X                   * 02A7 34 10          4.
                    leax      >L05E7,PC           * 02A9 30 8D 03 3A    0..:
                    pshs      X                   * 02AD 34 10          4.
                    lbsr      L095A               * 02AF 17 06 A8       ..(
                    leas      $04,S               * 02B2 32 64          2d
                    leax      >L05F4,PC           * 02B4 30 8D 03 3C    0..<
                    pshs      X                   * 02B8 34 10          4.
                    lbsr      L095A               * 02BA 17 06 9D       ...
                    leas      $02,S               * 02BD 32 62          2b
                    leax      >$001B,Y            * 02BF 30 A9 00 1B    0)..
                    pshs      X                   * 02C3 34 10          4.
                    lbsr      L0F89               * 02C5 17 0C C1       ..A
                    leas      $02,S               * 02C8 32 62          2b
                    ldd       #1                  * 02CA CC 00 01       L..
                    pshs      D                   * 02CD 34 06          4.
                    leax      $02,S               * 02CF 30 62          0b
                    pshs      X                   * 02D1 34 10          4.
                    clra                          * 02D3 4F             O
                    clrb                          * 02D4 5F             _
                    pshs      D                   * 02D5 34 06          4.
                    lbsr      L149A               * 02D7 17 11 C0       ..@
                    leas      $06,S               * 02DA 32 66          2f
                    ldb       0,S                 * 02DC E6 E4          fd
                    clra                          * 02DE 4F             O
                    andb      #223                * 02DF C4 DF          D_
L02E1               stb       0,S                 * 02E1 E7 E4          gd
                    ldb       0,S                 * 02E3 E6 E4          fd
                    cmpb      #89                 * 02E5 C1 59          AY
                    lbne      L01B4               * 02E7 10 26 FE C9    .&~I
                    leax      >L0611,PC           * 02EB 30 8D 03 22    0.."
                    pshs      X                   * 02EF 34 10          4.
                    lbsr      L095A               * 02F1 17 06 66       ..f
                    leas      $02,S               * 02F4 32 62          2b
                    leax      >L0628,PC           * 02F6 30 8D 03 2E    0...
                    pshs      X                   * 02FA 34 10          4.
                    ldd       $03,S               * 02FC EC 63          lc
                    pshs      D                   * 02FE 34 06          4.
                    lbsr      L096C               * 0300 17 06 69       ..i
                    leas      $04,S               * 0303 32 64          2d
                    leax      >L0636,PC           * 0305 30 8D 03 2D    0..-
                    pshs      X                   * 0309 34 10          4.
                    ldd       $03,S               * 030B EC 63          lc
                    pshs      D                   * 030D 34 06          4.
                    lbsr      L096C               * 030F 17 06 5A       ..Z
                    leas      $04,S               * 0312 32 64          2d
                    leax      >$01AF,Y            * 0314 30 A9 01 AF    0)./
                    pshs      X                   * 0318 34 10          4.
                    leax      >L066D,PC           * 031A 30 8D 03 4F    0..O
                    pshs      X                   * 031E 34 10          4.
                    ldd       $05,S               * 0320 EC 65          le
                    pshs      D                   * 0322 34 06          4.
                    lbsr      L096C               * 0324 17 06 45       ..E
                    leas      $06,S               * 0327 32 66          2f
                    leax      >$01FF,Y            * 0329 30 A9 01 FF    0)..
                    pshs      X                   * 032D 34 10          4.
                    leax      >L0682,PC           * 032F 30 8D 03 4F    0..O
                    pshs      X                   * 0333 34 10          4.
                    ldd       $05,S               * 0335 EC 65          le
                    pshs      D                   * 0337 34 06          4.
                    lbsr      L096C               * 0339 17 06 30       ..0
                    leas      $06,S               * 033C 32 66          2f
                    leax      >$024F,Y            * 033E 30 A9 02 4F    0).O
                    pshs      X                   * 0342 34 10          4.
                    leax      >L0697,PC           * 0344 30 8D 03 4F    0..O
                    pshs      X                   * 0348 34 10          4.
                    ldd       $05,S               * 034A EC 65          le
                    pshs      D                   * 034C 34 06          4.
                    lbsr      L096C               * 034E 17 06 1B       ...
                    leas      $06,S               * 0351 32 66          2f
                    leax      >$029F,Y            * 0353 30 A9 02 9F    0)..
                    pshs      X                   * 0357 34 10          4.
                    leax      >L06AC,PC           * 0359 30 8D 03 4F    0..O
                    pshs      X                   * 035D 34 10          4.
                    ldd       $05,S               * 035F EC 65          le
                    pshs      D                   * 0361 34 06          4.
                    lbsr      L096C               * 0363 17 06 06       ...
                    leas      $06,S               * 0366 32 66          2f
                    leax      >$02EF,Y            * 0368 30 A9 02 EF    0).o
                    pshs      X                   * 036C 34 10          4.
                    leax      >L06C1,PC           * 036E 30 8D 03 4F    0..O
                    pshs      X                   * 0372 34 10          4.
                    ldd       $05,S               * 0374 EC 65          le
                    pshs      D                   * 0376 34 06          4.
                    lbsr      L096C               * 0378 17 05 F1       ..q
                    leas      $06,S               * 037B 32 66          2f
                    leax      >$033F,Y            * 037D 30 A9 03 3F    0).?
                    pshs      X                   * 0381 34 10          4.
                    leax      >L06D6,PC           * 0383 30 8D 03 4F    0..O
                    pshs      X                   * 0387 34 10          4.
                    ldd       $05,S               * 0389 EC 65          le
                    pshs      D                   * 038B 34 06          4.
                    lbsr      L096C               * 038D 17 05 DC       ..\
                    leas      $06,S               * 0390 32 66          2f
                    leax      >L06EB,PC           * 0392 30 8D 03 55    0..U
                    pshs      X                   * 0396 34 10          4.
                    ldd       $03,S               * 0398 EC 63          lc
                    pshs      D                   * 039A 34 06          4.
                    lbsr      L096C               * 039C 17 05 CD       ..M
                    leas      $04,S               * 039F 32 64          2d
                    leax      >L06ED,PC           * 03A1 30 8D 03 48    0..H
                    pshs      X                   * 03A5 34 10          4.
                    lbsr      L095A               * 03A7 17 05 B0       ..0
                    leas      $02,S               * 03AA 32 62          2b
                    leas      $03,S               * 03AC 32 63          2c
                    puls      PC,U                * 03AE 35 C0          5@
L03B0               pshs      U                   * 03B0 34 40          4@
                    ldd       #-72                * 03B2 CC FF B8       L.8
                    lbsr      L0111               * 03B5 17 FD 59       .}Y
                    ldd       $04,S               * 03B8 EC 64          ld
                    pshs      D                   * 03BA 34 06          4.
                    leax      >L072A,PC           * 03BC 30 8D 03 6A    0..j
                    pshs      X                   * 03C0 34 10          4.
                    lbsr      L095A               * 03C2 17 05 95       ...
                    leas      $04,S               * 03C5 32 64          2d
                    ldd       $06,S               * 03C7 EC 66          lf
                    pshs      D                   * 03C9 34 06          4.
                    lbsr      L15ED               * 03CB 17 12 1F       ...
                    leas      $02,S               * 03CE 32 62          2b
                    puls      PC,U                * 03D0 35 C0          5@
L03D2               fcb       $61                 * 03D2 61             a
                    fcb       $00                 * 03D3 00             .
L03D4               fcc       "Cannot open file"  * 03D4 43 61 6E 6E 6F 74 20 6F 70 65 6E 20 66 69 6C 65 Cannot open file
                    fcb       $00                 * 03E4 00             .
L03E5               fcb       $0D                 * 03E5 0D             .
                    fcc       "To be validated on this system you must enter the following information" * 03E6 54 6F 20 62 65 20 76 61 6C 69 64 61 74 65 64 20 6F 6E 20 74 68 69 73 20 73 79 73 74 65 6D 20 79 6F 75 20 6D 75 73 74 20 65 6E 74 65 72 20 74 68 65 20
                    fcb       $0D                 * 042D 0D             .
                    fcb       $00                 * 042E 00             .
L042F               fcc       "Please enter the information as correctly as possible" * 042F 50 6C 65 61 73 65 20 65 6E 74 65 72 20 74 68 65 20 69 6E 66 6F 72 6D 61 74 69 6F 6E 20 61 73 20 63 6F 72 72 65 63 74 6C 79 20 61 73 20 70 6F 73 73 69 62 6C 65 Please en
                    fcb       $0D                 * 0464 0D             .
                    fcb       $00                 * 0465 00             .
L0466               fcc       "any false information will result in your not being validated" * 0466 61 6E 79 20 66 61 6C 73 65 20 69 6E 66 6F 72 6D 61 74 69 6F 6E 20 77 69 6C 6C 20 72 65 73 75 6C 74 20 69 6E 20 79 6F 75 72 20 6E 6F 74 20 62 65 69 6E 67 20 76 6
                    fcb       $0D                 * 04A3 0D             .
                    fcb       $00                 * 04A4 00             .
L04A5               fcc       "-------------------------------------------------------------------------" * 04A5 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 04EE 0D             .
                    fcb       $00                 * 04EF 00             .
L04F0               fcc       "Enter your name:==============>" * 04F0 45 6E 74 65 72 20 79 6F 75 72 20 6E 61 6D 65 3A 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3E Enter your name:==============>
                    fcb       $00                 * 050F 00             .
L0510               fcc       "Enter your city:==============>" * 0510 45 6E 74 65 72 20 79 6F 75 72 20 63 69 74 79 3A 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3E Enter your city:==============>
                    fcb       $00                 * 052F 00             .
L0530               fcc       "Enter your state:=============>" * 0530 45 6E 74 65 72 20 79 6F 75 72 20 73 74 61 74 65 3A 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3E Enter your state:=============>
                    fcb       $00                 * 054F 00             .
L0550               fcc       "Enter your phone #:===========>" * 0550 45 6E 74 65 72 20 79 6F 75 72 20 70 68 6F 6E 65 20 23 3A 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3D 3E Enter your phone #:===========>
                    fcb       $00                 * 056F 00             .
L0570               fcc       "Enter your alias (if any):====>" * 0570 45 6E 74 65 72 20 79 6F 75 72 20 61 6C 69 61 73 20 28 69 66 20 61 6E 79 29 3A 3D 3D 3D 3D 3E Enter your alias (if any):====>
                    fcb       $00                 * 058F 00             .
L0590               fcc       "Enter your desired password:==>" * 0590 45 6E 74 65 72 20 79 6F 75 72 20 64 65 73 69 72 65 64 20 70 61 73 73 77 6F 72 64 3A 3D 3D 3E Enter your desired password:==>
                    fcb       $00                 * 05AF 00             .
L05B0               fcb       $0D                 * 05B0 0D             .
                    fcb       $0D                 * 05B1 0D             .
                    fcc       "You are %s alias %s" * 05B2 59 6F 75 20 61 72 65 20 25 73 20 61 6C 69 61 73 20 25 73 You are %s alias %s
                    fcb       $0D                 * 05C5 0D             .
                    fcb       $00                 * 05C6 00             .
L05C7               fcc       "Calling from %s, %s" * 05C7 43 61 6C 6C 69 6E 67 20 66 72 6F 6D 20 25 73 2C 20 25 73 Calling from %s, %s
                    fcb       $0D                 * 05DA 0D             .
                    fcb       $00                 * 05DB 00             .
L05DC               fcc       "Phone #%s"         * 05DC 50 68 6F 6E 65 20 23 25 73 Phone #%s
                    fcb       $0D                 * 05E5 0D             .
                    fcb       $00                 * 05E6 00             .
L05E7               fcc       "Password:%s"       * 05E7 50 61 73 73 77 6F 72 64 3A 25 73 Password:%s
                    fcb       $0D                 * 05F2 0D             .
                    fcb       $00                 * 05F3 00             .
L05F4               fcc       "Is this information correct?" * 05F4 49 73 20 74 68 69 73 20 69 6E 66 6F 72 6D 61 74 69 6F 6E 20 63 6F 72 72 65 63 74 3F Is this information correct?
                    fcb       $00                 * 0610 00             .
L0611               fcb       $0D                 * 0611 0D             .
                    fcc       "One moment please..." * 0612 4F 6E 65 20 6D 6F 6D 65 6E 74 20 70 6C 65 61 73 65 2E 2E 2E One moment please...
                    fcb       $0D                 * 0626 0D             .
                    fcb       $00                 * 0627 00             .
L0628               fcc       "New user log"      * 0628 4E 65 77 20 75 73 65 72 20 6C 6F 67 New user log
                    fcb       $0D                 * 0634 0D             .
                    fcb       $00                 * 0635 00             .
L0636               fcc       "-----------------------------------------------------" * 0636 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D ---------
                    fcb       $0D                 * 066B 0D             .
                    fcb       $00                 * 066C 00             .
L066D               fcc       "User name       :%s" * 066D 55 73 65 72 20 6E 61 6D 65 20 20 20 20 20 20 20 3A 25 73 User name       :%s
                    fcb       $0D                 * 0680 0D             .
                    fcb       $00                 * 0681 00             .
L0682               fcc       "City            :%s" * 0682 43 69 74 79 20 20 20 20 20 20 20 20 20 20 20 20 3A 25 73 City            :%s
                    fcb       $0D                 * 0695 0D             .
                    fcb       $00                 * 0696 00             .
L0697               fcc       "State           :%s" * 0697 53 74 61 74 65 20 20 20 20 20 20 20 20 20 20 20 3A 25 73 State           :%s
                    fcb       $0D                 * 06AA 0D             .
                    fcb       $00                 * 06AB 00             .
L06AC               fcc       "Phone #         :%s" * 06AC 50 68 6F 6E 65 20 23 20 20 20 20 20 20 20 20 20 3A 25 73 Phone #         :%s
                    fcb       $0D                 * 06BF 0D             .
                    fcb       $00                 * 06C0 00             .
L06C1               fcc       "Desired alias   :%s" * 06C1 44 65 73 69 72 65 64 20 61 6C 69 61 73 20 20 20 3A 25 73 Desired alias   :%s
                    fcb       $0D                 * 06D4 0D             .
                    fcb       $00                 * 06D5 00             .
L06D6               fcc       "Desired password:%s" * 06D6 44 65 73 69 72 65 64 20 70 61 73 73 77 6F 72 64 3A 25 73 Desired password:%s
                    fcb       $0D                 * 06E9 0D             .
                    fcb       $00                 * 06EA 00             .
L06EB               fcb       $0D                 * 06EB 0D             .
                    fcb       $00                 * 06EC 00             .
L06ED               fcc       "Thank you, the sysop will validate you as soon as possible." * 06ED 54 68 61 6E 6B 20 79 6F 75 2C 20 74 68 65 20 73 79 73 6F 70 20 77 69 6C 6C 20 76 61 6C 69 64 61 74 65 20 79 6F 75 20 61 73 20 73 6F 6F 6E 20 61 73 20 70 6F 73 73
                    fcb       $0D                 * 0728 0D             .
                    fcb       $00                 * 0729 00             .
L072A               fcb       $25                 * 072A 25             %
                    fcb       $73                 * 072B 73             s
                    fcb       $0D                 * 072C 0D             .
                    fcb       $00                 * 072D 00             .
L072E               pshs      U                   * 072E 34 40          4@
                    leau      >$000E,Y            * 0730 33 A9 00 0E    3)..
L0734               ldd       U0006,U             * 0734 EC 46          lF
                    clra                          * 0736 4F             O
                    andb      #3                  * 0737 C4 03          D.
                    lbeq      L07A5               * 0739 10 27 00 68    .'.h
                    leau      U000D,U             * 073D 33 4D          3M
                    pshs      U                   * 073F 34 40          4@
                    leax      >$00DE,Y            * 0741 30 A9 00 DE    0).^
                    cmpx      ,S++                * 0745 AC E1          ,a
                    bhi       L0734               * 0747 22 EB          "k
                    ldd       #200                * 0749 CC 00 C8       L.H
                    std       >$01AD,Y            * 074C ED A9 01 AD    m).-
                    lbra      L07A9               * 0750 16 00 56       ..V
                    fcb       $35                 * 0753 35             5
                    fcb       $C0                 * 0754 C0             @
L0755               pshs      U                   * 0755 34 40          4@
                    ldu       $08,S               * 0757 EE 68          nh
                    bne       L075F               * 0759 26 04          &.
                    bsr       L072E               * 075B 8D D1          .Q
                    tfr       D,U                 * 075D 1F 03          ..
L075F               stu       -$02,S              * 075F EF 7E          o~
                    beq       L07A9               * 0761 27 46          'F
                    ldd       $04,S               * 0763 EC 64          ld
                    std       U0008,U             * 0765 ED 48          mH
                    ldx       $06,S               * 0767 AE 66          .f
                    ldb       $01,X               * 0769 E6 01          f.
                    cmpb      #43                 * 076B C1 2B          A+
                    beq       L0777               * 076D 27 08          '.
                    ldx       $06,S               * 076F AE 66          .f
                    ldb       $02,X               * 0771 E6 02          f.
                    cmpb      #43                 * 0773 C1 2B          A+
                    bne       L077D               * 0775 26 06          &.
L0777               ldd       U0006,U             * 0777 EC 46          lF
                    orb       #3                  * 0779 CA 03          J.
                    bra       L079B               * 077B 20 1E           .
L077D               ldd       U0006,U             * 077D EC 46          lF
                    pshs      D                   * 077F 34 06          4.
                    ldb       [<$08,S]            * 0781 E6 F8 08       fx.
                    cmpb      #114                * 0784 C1 72          Ar
                    beq       L078F               * 0786 27 07          '.
                    ldb       [<$08,S]            * 0788 E6 F8 08       fx.
                    cmpb      #100                * 078B C1 64          Ad
                    bne       L0794               * 078D 26 05          &.
L078F               ldd       #1                  * 078F CC 00 01       L..
                    bra       L0797               * 0792 20 03           .
L0794               ldd       #2                  * 0794 CC 00 02       L..
L0797               ora       ,S+                 * 0797 AA E0          *`
                    orb       ,S+                 * 0799 EA E0          j`
L079B               std       U0006,U             * 079B ED 46          mF
                    ldd       U0002,U             * 079D EC 42          lB
                    addd      U000B,U             * 079F E3 4B          cK
                    std       U0004,U             * 07A1 ED 44          mD
                    std       U0000,U             * 07A3 ED C4          mD
L07A5               tfr       U,D                 * 07A5 1F 30          .0
                    puls      PC,U                * 07A7 35 C0          5@
L07A9               clra                          * 07A9 4F             O
                    clrb                          * 07AA 5F             _
                    puls      PC,U                * 07AB 35 C0          5@
L07AD               pshs      U                   * 07AD 34 40          4@
                    ldu       $04,S               * 07AF EE 64          nd
                    leas      -$04,S              * 07B1 32 7C          2|
                    clra                          * 07B3 4F             O
                    clrb                          * 07B4 5F             _
                    std       0,S                 * 07B5 ED E4          md
                    ldx       $0A,S               * 07B7 AE 6A          .j
                    ldb       $01,X               * 07B9 E6 01          f.
                    sex                           * 07BB 1D             .
                    tfr       D,X                 * 07BC 1F 01          ..
                    bra       L07DE               * 07BE 20 1E           .
L07C0               ldx       $0A,S               * 07C0 AE 6A          .j
                    ldb       $02,X               * 07C2 E6 02          f.
                    cmpb      #43                 * 07C4 C1 2B          A+
                    bne       L07CD               * 07C6 26 05          &.
                    ldd       #7                  * 07C8 CC 00 07       L..
                    bra       L07D5               * 07CB 20 08           .
L07CD               ldd       #4                  * 07CD CC 00 04       L..
                    bra       L07D5               * 07D0 20 03           .
L07D2               ldd       #3                  * 07D2 CC 00 03       L..
L07D5               std       0,S                 * 07D5 ED E4          md
                    bra       L07EE               * 07D7 20 15           .
L07D9               leax      $04,S               * 07D9 30 64          0d
                    lbra      L0846               * 07DB 16 00 68       ..h
L07DE               stx       -$02,S              * 07DE AF 7E          /~
                    beq       L07EE               * 07E0 27 0C          '.
                    cmpx      #120                * 07E2 8C 00 78       ..x
                    beq       L07C0               * 07E5 27 D9          'Y
                    cmpx      #43                 * 07E7 8C 00 2B       ..+
                    beq       L07D2               * 07EA 27 E6          'f
                    bra       L07D9               * 07EC 20 EB           k
L07EE               ldb       [<$0A,S]            * 07EE E6 F8 0A       fx.
                    sex                           * 07F1 1D             .
                    tfr       D,X                 * 07F2 1F 01          ..
                    lbra      L0853               * 07F4 16 00 5C       ..\
L07F7               ldd       0,S                 * 07F7 EC E4          ld
                    orb       #1                  * 07F9 CA 01          J.
                    bra       L0839               * 07FB 20 3C           <
L07FD               ldd       0,S                 * 07FD EC E4          ld
                    orb       #2                  * 07FF CA 02          J.
                    pshs      D                   * 0801 34 06          4.
                    pshs      U                   * 0803 34 40          4@
                    lbsr      L141E               * 0805 17 0C 16       ...
                    leas      $04,S               * 0808 32 64          2d
                    std       $02,S               * 080A ED 62          mb
                    cmpd      #-1                 * 080C 10 83 FF FF    ....
                    beq       L0828               * 0810 27 16          '.
                    ldd       #2                  * 0812 CC 00 02       L..
                    pshs      D                   * 0815 34 06          4.
                    clra                          * 0817 4F             O
                    clrb                          * 0818 5F             _
                    pshs      D                   * 0819 34 06          4.
                    pshs      D                   * 081B 34 06          4.
                    ldd       $08,S               * 081D EC 68          lh
                    pshs      D                   * 081F 34 06          4.
                    lbsr      L14F4               * 0821 17 0C D0       ..P
                    leas      $08,S               * 0824 32 68          2h
                    bra       L086D               * 0826 20 45           E
L0828               ldd       0,S                 * 0828 EC E4          ld
                    orb       #2                  * 082A CA 02          J.
                    pshs      D                   * 082C 34 06          4.
                    pshs      U                   * 082E 34 40          4@
                    lbsr      L143F               * 0830 17 0C 0C       ...
                    bra       L0840               * 0833 20 0B           .
L0835               ldd       0,S                 * 0835 EC E4          ld
                    orb       #129                * 0837 CA 81          J.
L0839               pshs      D                   * 0839 34 06          4.
                    pshs      U                   * 083B 34 40          4@
                    lbsr      L141E               * 083D 17 0B DE       ..^
L0840               leas      $04,S               * 0840 32 64          2d
                    std       $02,S               * 0842 ED 62          mb
                    bra       L086D               * 0844 20 27           '
L0846               leas      -$04,X              * 0846 32 1C          2.
L0848               ldd       #203                * 0848 CC 00 CB       L.K
                    std       >$01AD,Y            * 084B ED A9 01 AD    m).-
                    clra                          * 084F 4F             O
                    clrb                          * 0850 5F             _
                    bra       L086F               * 0851 20 1C           .
L0853               cmpx      #114                * 0853 8C 00 72       ..r
                    lbeq      L07F7               * 0856 10 27 FF 9D    .'..
                    cmpx      #97                 * 085A 8C 00 61       ..a
                    lbeq      L07FD               * 085D 10 27 FF 9C    .'..
                    cmpx      #119                * 0861 8C 00 77       ..w
                    beq       L0828               * 0864 27 C2          'B
                    cmpx      #100                * 0866 8C 00 64       ..d
                    beq       L0835               * 0869 27 CA          'J
                    bra       L0848               * 086B 20 DB           [
L086D               ldd       $02,S               * 086D EC 62          lb
L086F               leas      $04,S               * 086F 32 64          2d
                    puls      PC,U                * 0871 35 C0          5@
                    fcc       "4@O_4"             * 0873 34 40 4F 5F 34 4@O_4
                    fcb       $06                 * 0878 06             .
                    fcb       $EC                 * 0879 EC             l
                    fcb       $68                 * 087A 68             h
                    fcb       $34                 * 087B 34             4
                    fcb       $06                 * 087C 06             .
                    fcb       $EC                 * 087D EC             l
                    fcb       $68                 * 087E 68             h
                    fcb       $34                 * 087F 34             4
                    fcb       $06                 * 0880 06             .
                    fcb       $16                 * 0881 16             .
                    fcb       $00                 * 0882 00             .
                    fcc       "K"                 * 0883 4B             K
L0884               pshs      U                   * 0884 34 40          4@
                    ldd       $06,S               * 0886 EC 66          lf
                    pshs      D                   * 0888 34 06          4.
                    ldd       $06,S               * 088A EC 66          lf
                    pshs      D                   * 088C 34 06          4.
                    lbsr      L07AD               * 088E 17 FF 1C       ...
                    leas      $04,S               * 0891 32 64          2d
                    tfr       D,U                 * 0893 1F 03          ..
                    cmpu      #-1                 * 0895 11 83 FF FF    ....
                    bne       L089F               * 0899 26 04          &.
                    clra                          * 089B 4F             O
                    clrb                          * 089C 5F             _
                    bra       L08D4               * 089D 20 35           5
L089F               clra                          * 089F 4F             O
                    clrb                          * 08A0 5F             _
                    bra       L08C7               * 08A1 20 24           $
                    fcb       $34                 * 08A3 34             4
                    fcb       $40                 * 08A4 40             @
                    fcb       $EC                 * 08A5 EC             l
                    fcb       $68                 * 08A6 68             h
                    fcb       $34                 * 08A7 34             4
                    fcb       $06                 * 08A8 06             .
                    fcb       $17                 * 08A9 17             .
                    fcb       $06                 * 08AA 06             .
                    fcb       $A3                 * 08AB A3             #
                    fcb       $32                 * 08AC 32             2
                    fcb       $62                 * 08AD 62             b
                    fcb       $EC                 * 08AE EC             l
                    fcb       $66                 * 08AF 66             f
                    fcb       $34                 * 08B0 34             4
                    fcb       $06                 * 08B1 06             .
                    fcb       $EC                 * 08B2 EC             l
                    fcb       $66                 * 08B3 66             f
                    fcb       $34                 * 08B4 34             4
                    fcb       $06                 * 08B5 06             .
                    fcb       $17                 * 08B6 17             .
                    fcb       $FE                 * 08B7 FE             ~
                    fcb       $F4                 * 08B8 F4             t
                    fcb       $32                 * 08B9 32             2
                    fcb       $64                 * 08BA 64             d
                    fcb       $1F                 * 08BB 1F             .
                    fcb       $03                 * 08BC 03             .
                    fcb       $EF                 * 08BD EF             o
                    fcb       $7E                 * 08BE 7E             ~
                    fcb       $2C                 * 08BF 2C             ,
                    fcb       $04                 * 08C0 04             .
                    fcc       "O_ "               * 08C1 4F 5F 20       O_
                    fcb       $0F                 * 08C4 0F             .
                    fcb       $EC                 * 08C5 EC             l
                    fcb       $68                 * 08C6 68             h
L08C7               pshs      D                   * 08C7 34 06          4.
                    ldd       $08,S               * 08C9 EC 68          lh
                    pshs      D                   * 08CB 34 06          4.
                    pshs      U                   * 08CD 34 40          4@
                    lbsr      L0755               * 08CF 17 FE 83       .~.
                    leas      $06,S               * 08D2 32 66          2f
L08D4               puls      PC,U                * 08D4 35 C0          5@
L08D6               pshs      U,D                 * 08D6 34 46          4F
                    ldu       $06,S               * 08D8 EE 66          nf
                    bra       L08E0               * 08DA 20 04           .
L08DC               ldd       0,S                 * 08DC EC E4          ld
                    stb       ,U+                 * 08DE E7 C0          g@
L08E0               leax      >$000E,Y            * 08E0 30 A9 00 0E    0)..
                    pshs      X                   * 08E4 34 10          4.
                    lbsr      L1079               * 08E6 17 07 90       ...
                    leas      $02,S               * 08E9 32 62          2b
                    std       0,S                 * 08EB ED E4          md
                    cmpd      #13                 * 08ED 10 83 00 0D    ....
                    beq       L08FB               * 08F1 27 08          '.
                    ldd       0,S                 * 08F3 EC E4          ld
                    cmpd      #-1                 * 08F5 10 83 FF FF    ....
                    bne       L08DC               * 08F9 26 E1          &a
L08FB               ldd       0,S                 * 08FB EC E4          ld
                    cmpd      #-1                 * 08FD 10 83 FF FF    ....
                    bne       L0907               * 0901 26 04          &.
                    clra                          * 0903 4F             O
                    clrb                          * 0904 5F             _
                    bra       L090D               * 0905 20 06           .
L0907               clra                          * 0907 4F             O
                    clrb                          * 0908 5F             _
                    stb       U0000,U             * 0909 E7 C4          gD
                    ldd       $06,S               * 090B EC 66          lf
L090D               leas      $02,S               * 090D 32 62          2b
                    puls      PC,U                * 090F 35 C0          5@
                    fcb       $34                 * 0911 34             4
                    fcb       $40                 * 0912 40             @
                    fcb       $EE                 * 0913 EE             n
                    fcc       "f2|"               * 0914 66 32 7C       f2|
                    fcb       $EC                 * 0917 EC             l
                    fcb       $68                 * 0918 68             h
                    fcb       $ED                 * 0919 ED             m
                    fcb       $E4                 * 091A E4             d
                    fcb       $20                 * 091B 20
                    fcb       $0E                 * 091C 0E             .
                    fcb       $EC                 * 091D EC             l
                    fcb       $62                 * 091E 62             b
                    fcb       $AE                 * 091F AE             .
                    fcb       $E4                 * 0920 E4             d
                    fcb       $30                 * 0921 30             0
                    fcb       $01                 * 0922 01             .
                    fcb       $AF                 * 0923 AF             /
                    fcb       $E4                 * 0924 E4             d
                    fcb       $E7                 * 0925 E7             g
                    fcb       $1F                 * 0926 1F             .
                    fcb       $C1                 * 0927 C1             A
                    fcb       $0D                 * 0928 0D             .
                    fcb       $27                 * 0929 27             '
                    fcb       $19                 * 092A 19             .
                    fcb       $1F                 * 092B 1F             .
                    fcc       "03_"               * 092C 30 33 5F       03_
                    fcb       $ED                 * 092F ED             m
                    fcb       $7E                 * 0930 7E             ~
                    fcb       $2F                 * 0931 2F             /
                    fcb       $11                 * 0932 11             .
                    fcb       $EC                 * 0933 EC             l
                    fcb       $6C                 * 0934 6C             l
                    fcb       $34                 * 0935 34             4
                    fcb       $06                 * 0936 06             .
                    fcb       $17                 * 0937 17             .
                    fcb       $07                 * 0938 07             .
                    fcc       "?2b"               * 0939 3F 32 62       ?2b
                    fcb       $ED                 * 093C ED             m
                    fcb       $62                 * 093D 62             b
                    fcb       $10                 * 093E 10             .
                    fcb       $83                 * 093F 83             .
                    fcb       $FF                 * 0940 FF             .
                    fcb       $FF                 * 0941 FF             .
                    fcb       $26                 * 0942 26             &
                    fcb       $D9                 * 0943 D9             Y
                    fcb       $4F                 * 0944 4F             O
                    fcb       $5F                 * 0945 5F             _
                    fcb       $E7                 * 0946 E7             g
                    fcb       $F4                 * 0947 F4             t
                    fcb       $EC                 * 0948 EC             l
                    fcb       $62                 * 0949 62             b
                    fcb       $10                 * 094A 10             .
                    fcb       $83                 * 094B 83             .
                    fcb       $FF                 * 094C FF             .
                    fcb       $FF                 * 094D FF             .
                    fcb       $26                 * 094E 26             &
                    fcb       $04                 * 094F 04             .
                    fcc       "O_ "               * 0950 4F 5F 20       O_
                    fcb       $02                 * 0953 02             .
                    fcb       $EC                 * 0954 EC             l
                    fcc       "h2d5"              * 0955 68 32 64 35    h2d5
                    fcb       $C0                 * 0959 C0             @
L095A               pshs      U                   * 095A 34 40          4@
                    leax      >$001B,Y            * 095C 30 A9 00 1B    0)..
                    stx       >$038F,Y            * 0960 AF A9 03 8F    /)..
                    leax      $06,S               * 0964 30 66          0f
                    pshs      X                   * 0966 34 10          4.
                    ldd       $06,S               * 0968 EC 66          lf
                    bra       L097A               * 096A 20 0E           .
L096C               pshs      U                   * 096C 34 40          4@
                    ldd       $04,S               * 096E EC 64          ld
                    std       >$038F,Y            * 0970 ED A9 03 8F    m)..
                    leax      $08,S               * 0974 30 68          0h
                    pshs      X                   * 0976 34 10          4.
                    ldd       $08,S               * 0978 EC 68          lh
L097A               pshs      D                   * 097A 34 06          4.
                    leax      >L0E32,PC           * 097C 30 8D 04 B2    0..2
                    pshs      X                   * 0980 34 10          4.
                    bsr       L09AC               * 0982 8D 28          .(
                    leas      $06,S               * 0984 32 66          2f
                    puls      PC,U                * 0986 35 C0          5@
                    fcb       $34                 * 0988 34             4
                    fcb       $40                 * 0989 40             @
                    fcb       $EC                 * 098A EC             l
                    fcb       $64                 * 098B 64             d
                    fcb       $ED                 * 098C ED             m
                    fcb       $A9                 * 098D A9             )
                    fcb       $03                 * 098E 03             .
                    fcb       $8F                 * 098F 8F             .
                    fcc       "0h4"               * 0990 30 68 34       0h4
                    fcb       $10                 * 0993 10             .
                    fcb       $EC                 * 0994 EC             l
                    fcb       $68                 * 0995 68             h
                    fcb       $34                 * 0996 34             4
                    fcb       $06                 * 0997 06             .
                    fcb       $30                 * 0998 30             0
                    fcb       $8D                 * 0999 8D             .
                    fcb       $04                 * 099A 04             .
                    fcb       $A9                 * 099B A9             )
                    fcb       $34                 * 099C 34             4
                    fcb       $10                 * 099D 10             .
                    fcb       $8D                 * 099E 8D             .
                    fcb       $0C                 * 099F 0C             .
                    fcc       "2fO_"              * 09A0 32 66 4F 5F    2fO_
                    fcb       $E7                 * 09A4 E7             g
                    fcb       $B9                 * 09A5 B9             9
                    fcb       $03                 * 09A6 03             .
                    fcb       $8F                 * 09A7 8F             .
                    fcb       $EC                 * 09A8 EC             l
                    fcb       $64                 * 09A9 64             d
                    fcb       $35                 * 09AA 35             5
                    fcb       $C0                 * 09AB C0             @
L09AC               pshs      U                   * 09AC 34 40          4@
                    ldu       $06,S               * 09AE EE 66          nf
                    leas      -$0B,S              * 09B0 32 75          2u
                    bra       L09C4               * 09B2 20 10           .
L09B4               ldb       $08,S               * 09B4 E6 68          fh
                    lbeq      L0BF5               * 09B6 10 27 02 3B    .'.;
                    ldb       $08,S               * 09BA E6 68          fh
                    sex                           * 09BC 1D             .
                    pshs      D                   * 09BD 34 06          4.
                    jsr       [<$11,S]            * 09BF AD F8 11       -x.
                    leas      $02,S               * 09C2 32 62          2b
L09C4               ldb       ,U+                 * 09C4 E6 C0          f@
                    stb       $08,S               * 09C6 E7 68          gh
                    cmpb      #37                 * 09C8 C1 25          A%
                    bne       L09B4               * 09CA 26 E8          &h
                    ldb       ,U+                 * 09CC E6 C0          f@
                    stb       $08,S               * 09CE E7 68          gh
                    clra                          * 09D0 4F             O
                    clrb                          * 09D1 5F             _
                    std       $02,S               * 09D2 ED 62          mb
                    std       $06,S               * 09D4 ED 66          mf
                    ldb       $08,S               * 09D6 E6 68          fh
                    cmpb      #45                 * 09D8 C1 2D          A-
                    bne       L09E9               * 09DA 26 0D          &.
                    ldd       #1                  * 09DC CC 00 01       L..
                    std       >$03A5,Y            * 09DF ED A9 03 A5    m).%
                    ldb       ,U+                 * 09E3 E6 C0          f@
                    stb       $08,S               * 09E5 E7 68          gh
                    bra       L09EF               * 09E7 20 06           .
L09E9               clra                          * 09E9 4F             O
                    clrb                          * 09EA 5F             _
                    std       >$03A5,Y            * 09EB ED A9 03 A5    m).%
L09EF               ldb       $08,S               * 09EF E6 68          fh
                    cmpb      #48                 * 09F1 C1 30          A0
                    bne       L09FA               * 09F3 26 05          &.
                    ldd       #48                 * 09F5 CC 00 30       L.0
                    bra       L09FD               * 09F8 20 03           .
L09FA               ldd       #32                 * 09FA CC 00 20       L.
L09FD               std       >$03A7,Y            * 09FD ED A9 03 A7    m).'
                    bra       L0A1D               * 0A01 20 1A           .
L0A03               ldd       $06,S               * 0A03 EC 66          lf
                    pshs      D                   * 0A05 34 06          4.
                    ldd       #10                 * 0A07 CC 00 0A       L..
                    lbsr      L132D               * 0A0A 17 09 20       ..
                    pshs      D                   * 0A0D 34 06          4.
                    ldb       $0A,S               * 0A0F E6 6A          fj
                    sex                           * 0A11 1D             .
                    addd      #-48                * 0A12 C3 FF D0       C.P
                    addd      ,S++                * 0A15 E3 E1          ca
                    std       $06,S               * 0A17 ED 66          mf
                    ldb       ,U+                 * 0A19 E6 C0          f@
                    stb       $08,S               * 0A1B E7 68          gh
L0A1D               ldb       $08,S               * 0A1D E6 68          fh
                    sex                           * 0A1F 1D             .
                    leax      >$00DF,Y            * 0A20 30 A9 00 DF    0)._
                    leax      D,X                 * 0A24 30 8B          0.
                    ldb       0,X                 * 0A26 E6 84          f.
                    clra                          * 0A28 4F             O
                    andb      #8                  * 0A29 C4 08          D.
                    bne       L0A03               * 0A2B 26 D6          &V
                    ldb       $08,S               * 0A2D E6 68          fh
                    cmpb      #46                 * 0A2F C1 2E          A.
                    bne       L0A66               * 0A31 26 33          &3
                    ldd       #1                  * 0A33 CC 00 01       L..
                    std       $04,S               * 0A36 ED 64          md
                    bra       L0A50               * 0A38 20 16           .
L0A3A               ldd       $02,S               * 0A3A EC 62          lb
                    pshs      D                   * 0A3C 34 06          4.
                    ldd       #10                 * 0A3E CC 00 0A       L..
                    lbsr      L132D               * 0A41 17 08 E9       ..i
                    pshs      D                   * 0A44 34 06          4.
                    ldb       $0A,S               * 0A46 E6 6A          fj
                    sex                           * 0A48 1D             .
                    addd      #-48                * 0A49 C3 FF D0       C.P
                    addd      ,S++                * 0A4C E3 E1          ca
                    std       $02,S               * 0A4E ED 62          mb
L0A50               ldb       ,U+                 * 0A50 E6 C0          f@
                    stb       $08,S               * 0A52 E7 68          gh
                    ldb       $08,S               * 0A54 E6 68          fh
                    sex                           * 0A56 1D             .
                    leax      >$00DF,Y            * 0A57 30 A9 00 DF    0)._
                    leax      D,X                 * 0A5B 30 8B          0.
                    ldb       0,X                 * 0A5D E6 84          f.
                    clra                          * 0A5F 4F             O
                    andb      #8                  * 0A60 C4 08          D.
                    bne       L0A3A               * 0A62 26 D6          &V
                    bra       L0A6A               * 0A64 20 04           .
L0A66               clra                          * 0A66 4F             O
                    clrb                          * 0A67 5F             _
                    std       $04,S               * 0A68 ED 64          md
L0A6A               ldb       $08,S               * 0A6A E6 68          fh
                    sex                           * 0A6C 1D             .
                    tfr       D,X                 * 0A6D 1F 01          ..
                    lbra      L0B98               * 0A6F 16 01 26       ..&
L0A72               ldd       $06,S               * 0A72 EC 66          lf
                    pshs      D                   * 0A74 34 06          4.
                    ldx       <$0015,S            * 0A76 AE E8 15       .h.
                    leax      $02,X               * 0A79 30 02          0.
                    stx       <$0015,S            * 0A7B AF E8 15       /h.
                    ldd       -$02,X              * 0A7E EC 1E          l.
                    pshs      D                   * 0A80 34 06          4.
                    lbsr      L0BF9               * 0A82 17 01 74       ..t
                    bra       L0A9A               * 0A85 20 13           .
L0A87               ldd       $06,S               * 0A87 EC 66          lf
                    pshs      D                   * 0A89 34 06          4.
                    ldx       <$0015,S            * 0A8B AE E8 15       .h.
                    leax      $02,X               * 0A8E 30 02          0.
                    stx       <$0015,S            * 0A90 AF E8 15       /h.
                    ldd       -$02,X              * 0A93 EC 1E          l.
                    pshs      D                   * 0A95 34 06          4.
                    lbsr      L0CB6               * 0A97 17 02 1C       ...
L0A9A               std       0,S                 * 0A9A ED E4          md
                    lbra      L0B7E               * 0A9C 16 00 DF       .._
L0A9F               ldd       $06,S               * 0A9F EC 66          lf
                    pshs      D                   * 0AA1 34 06          4.
                    ldb       $0A,S               * 0AA3 E6 6A          fj
                    sex                           * 0AA5 1D             .
                    leax      >$00DF,Y            * 0AA6 30 A9 00 DF    0)._
                    leax      D,X                 * 0AAA 30 8B          0.
                    ldb       0,X                 * 0AAC E6 84          f.
                    clra                          * 0AAE 4F             O
                    andb      #2                  * 0AAF C4 02          D.
                    pshs      D                   * 0AB1 34 06          4.
                    ldx       <$0017,S            * 0AB3 AE E8 17       .h.
                    leax      $02,X               * 0AB6 30 02          0.
                    stx       <$0017,S            * 0AB8 AF E8 17       /h.
                    ldd       -$02,X              * 0ABB EC 1E          l.
                    pshs      D                   * 0ABD 34 06          4.
                    lbsr      L0CFE               * 0ABF 17 02 3C       ..<
                    lbra      L0B7A               * 0AC2 16 00 B5       ..5
L0AC5               ldd       $06,S               * 0AC5 EC 66          lf
                    pshs      D                   * 0AC7 34 06          4.
                    ldx       <$0015,S            * 0AC9 AE E8 15       .h.
                    leax      $02,X               * 0ACC 30 02          0.
                    stx       <$0015,S            * 0ACE AF E8 15       /h.
                    ldd       -$02,X              * 0AD1 EC 1E          l.
                    pshs      D                   * 0AD3 34 06          4.
                    leax      >$0391,Y            * 0AD5 30 A9 03 91    0)..
                    pshs      X                   * 0AD9 34 10          4.
                    lbsr      L0C3D               * 0ADB 17 01 5F       .._
                    lbra      L0B7A               * 0ADE 16 00 99       ...
L0AE1               ldd       $04,S               * 0AE1 EC 64          ld
                    bne       L0AEA               * 0AE3 26 05          &.
                    ldd       #6                  * 0AE5 CC 00 06       L..
                    std       $02,S               * 0AE8 ED 62          mb
L0AEA               ldd       $06,S               * 0AEA EC 66          lf
                    pshs      D                   * 0AEC 34 06          4.
                    leax      <$0015,S            * 0AEE 30 E8 15       0h.
                    pshs      X                   * 0AF1 34 10          4.
                    ldd       $06,S               * 0AF3 EC 66          lf
                    pshs      D                   * 0AF5 34 06          4.
                    ldb       $0E,S               * 0AF7 E6 6E          fn
                    sex                           * 0AF9 1D             .
                    pshs      D                   * 0AFA 34 06          4.
                    lbsr      L129B               * 0AFC 17 07 9C       ...
                    leas      $06,S               * 0AFF 32 66          2f
                    lbra      L0B7C               * 0B01 16 00 78       ..x
L0B04               ldx       <$0013,S            * 0B04 AE E8 13       .h.
                    leax      $02,X               * 0B07 30 02          0.
                    stx       <$0013,S            * 0B09 AF E8 13       /h.
                    ldd       -$02,X              * 0B0C EC 1E          l.
                    lbra      L0B8E               * 0B0E 16 00 7D       ..}
L0B11               ldx       <$0013,S            * 0B11 AE E8 13       .h.
                    leax      $02,X               * 0B14 30 02          0.
                    stx       <$0013,S            * 0B16 AF E8 13       /h.
                    ldd       -$02,X              * 0B19 EC 1E          l.
                    std       $09,S               * 0B1B ED 69          mi
                    ldd       $04,S               * 0B1D EC 64          ld
                    beq       L0B59               * 0B1F 27 38          '8
                    ldd       $09,S               * 0B21 EC 69          li
                    std       $04,S               * 0B23 ED 64          md
                    bra       L0B33               * 0B25 20 0C           .
L0B27               ldb       [<$09,S]            * 0B27 E6 F8 09       fx.
                    beq       L0B3F               * 0B2A 27 13          '.
                    ldd       $09,S               * 0B2C EC 69          li
                    addd      #1                  * 0B2E C3 00 01       C..
                    std       $09,S               * 0B31 ED 69          mi
L0B33               ldd       $02,S               * 0B33 EC 62          lb
                    addd      #-1                 * 0B35 C3 FF FF       C..
                    std       $02,S               * 0B38 ED 62          mb
                    subd      #-1                 * 0B3A 83 FF FF       ...
                    bne       L0B27               * 0B3D 26 E8          &h
L0B3F               ldd       $06,S               * 0B3F EC 66          lf
                    pshs      D                   * 0B41 34 06          4.
                    ldd       $0B,S               * 0B43 EC 6B          lk
                    subd      $06,S               * 0B45 A3 66          #f
                    pshs      D                   * 0B47 34 06          4.
                    ldd       $08,S               * 0B49 EC 68          lh
                    pshs      D                   * 0B4B 34 06          4.
                    ldd       <$0015,S            * 0B4D EC E8 15       lh.
                    pshs      D                   * 0B50 34 06          4.
                    lbsr      L0D69               * 0B52 17 02 14       ...
                    leas      $08,S               * 0B55 32 68          2h
                    bra       L0B88               * 0B57 20 2F           /
L0B59               ldd       $06,S               * 0B59 EC 66          lf
                    pshs      D                   * 0B5B 34 06          4.
                    ldd       $0B,S               * 0B5D EC 6B          lk
                    bra       L0B7C               * 0B5F 20 1B           .
L0B61               ldb       ,U+                 * 0B61 E6 C0          f@
                    stb       $08,S               * 0B63 E7 68          gh
                    bra       L0B69               * 0B65 20 02           .
                    fcb       $32                 * 0B67 32             2
                    fcb       $15                 * 0B68 15             .
L0B69               ldd       $06,S               * 0B69 EC 66          lf
                    pshs      D                   * 0B6B 34 06          4.
                    leax      <$0015,S            * 0B6D 30 E8 15       0h.
                    pshs      X                   * 0B70 34 10          4.
                    ldb       $0C,S               * 0B72 E6 6C          fl
                    sex                           * 0B74 1D             .
                    pshs      D                   * 0B75 34 06          4.
                    lbsr      L125D               * 0B77 17 06 E3       ..c
L0B7A               leas      $04,S               * 0B7A 32 64          2d
L0B7C               pshs      D                   * 0B7C 34 06          4.
L0B7E               ldd       <$0013,S            * 0B7E EC E8 13       lh.
                    pshs      D                   * 0B81 34 06          4.
                    lbsr      L0DCB               * 0B83 17 02 45       ..E
                    leas      $06,S               * 0B86 32 66          2f
L0B88               lbra      L09C4               * 0B88 16 FE 39       .~9
L0B8B               ldb       $08,S               * 0B8B E6 68          fh
                    sex                           * 0B8D 1D             .
L0B8E               pshs      D                   * 0B8E 34 06          4.
                    jsr       [<$11,S]            * 0B90 AD F8 11       -x.
                    leas      $02,S               * 0B93 32 62          2b
                    lbra      L09C4               * 0B95 16 FE 2C       .~,
L0B98               cmpx      #100                * 0B98 8C 00 64       ..d
                    lbeq      L0A72               * 0B9B 10 27 FE D3    .'~S
                    cmpx      #111                * 0B9F 8C 00 6F       ..o
                    lbeq      L0A87               * 0BA2 10 27 FE E1    .'~a
                    cmpx      #120                * 0BA6 8C 00 78       ..x
                    lbeq      L0A9F               * 0BA9 10 27 FE F2    .'~r
                    cmpx      #88                 * 0BAD 8C 00 58       ..X
                    lbeq      L0A9F               * 0BB0 10 27 FE EB    .'~k
                    cmpx      #117                * 0BB4 8C 00 75       ..u
                    lbeq      L0AC5               * 0BB7 10 27 FF 0A    .'..
                    cmpx      #102                * 0BBB 8C 00 66       ..f
                    lbeq      L0AE1               * 0BBE 10 27 FF 1F    .'..
                    cmpx      #101                * 0BC2 8C 00 65       ..e
                    lbeq      L0AE1               * 0BC5 10 27 FF 18    .'..
                    cmpx      #103                * 0BC9 8C 00 67       ..g
                    lbeq      L0AE1               * 0BCC 10 27 FF 11    .'..
                    cmpx      #69                 * 0BD0 8C 00 45       ..E
                    lbeq      L0AE1               * 0BD3 10 27 FF 0A    .'..
                    cmpx      #71                 * 0BD7 8C 00 47       ..G
                    lbeq      L0AE1               * 0BDA 10 27 FF 03    .'..
                    cmpx      #99                 * 0BDE 8C 00 63       ..c
                    lbeq      L0B04               * 0BE1 10 27 FF 1F    .'..
                    cmpx      #115                * 0BE5 8C 00 73       ..s
                    lbeq      L0B11               * 0BE8 10 27 FF 25    .'.%
                    cmpx      #108                * 0BEC 8C 00 6C       ..l
                    lbeq      L0B61               * 0BEF 10 27 FF 6E    .'.n
                    bra       L0B8B               * 0BF3 20 96           .
L0BF5               leas      $0B,S               * 0BF5 32 6B          2k
                    puls      PC,U                * 0BF7 35 C0          5@
L0BF9               pshs      U,D                 * 0BF9 34 46          4F
                    leax      >$0391,Y            * 0BFB 30 A9 03 91    0)..
                    stx       0,S                 * 0BFF AF E4          /d
                    ldd       $06,S               * 0C01 EC 66          lf
                    bge       L0C2E               * 0C03 2C 29          ,)
                    ldd       $06,S               * 0C05 EC 66          lf
                    nega                          * 0C07 40             @
                    negb                          * 0C08 50             P
                    sbca      #0                  * 0C09 82 00          ..
                    std       $06,S               * 0C0B ED 66          mf
                    bge       L0C23               * 0C0D 2C 14          ,.
                    leax      >L0E57,PC           * 0C0F 30 8D 02 44    0..D
                    pshs      X                   * 0C13 34 10          4.
                    leax      >$0391,Y            * 0C15 30 A9 03 91    0)..
                    pshs      X                   * 0C19 34 10          4.
                    lbsr      L12B7               * 0C1B 17 06 99       ...
                    leas      $04,S               * 0C1E 32 64          2d
                    lbra      L0CFA               * 0C20 16 00 D7       ..W
L0C23               ldd       #45                 * 0C23 CC 00 2D       L.-
                    ldx       0,S                 * 0C26 AE E4          .d
                    leax      $01,X               * 0C28 30 01          0.
                    stx       0,S                 * 0C2A AF E4          /d
                    stb       -$01,X              * 0C2C E7 1F          g.
L0C2E               ldd       $06,S               * 0C2E EC 66          lf
                    pshs      D                   * 0C30 34 06          4.
                    ldd       $02,S               * 0C32 EC 62          lb
                    pshs      D                   * 0C34 34 06          4.
                    bsr       L0C3D               * 0C36 8D 05          ..
                    leas      $04,S               * 0C38 32 64          2d
                    lbra      L0CF4               * 0C3A 16 00 B7       ..7
L0C3D               pshs      U,Y,X,D             * 0C3D 34 76          4v
                    ldu       $0A,S               * 0C3F EE 6A          nj
                    clra                          * 0C41 4F             O
                    clrb                          * 0C42 5F             _
                    std       $02,S               * 0C43 ED 62          mb
                    clra                          * 0C45 4F             O
                    clrb                          * 0C46 5F             _
                    std       0,S                 * 0C47 ED E4          md
                    bra       L0C5A               * 0C49 20 0F           .
L0C4B               ldd       0,S                 * 0C4B EC E4          ld
                    addd      #1                  * 0C4D C3 00 01       C..
                    std       0,S                 * 0C50 ED E4          md
                    ldd       $0C,S               * 0C52 EC 6C          ll
                    subd      >$0001,Y            * 0C54 A3 A9 00 01    #)..
                    std       $0C,S               * 0C58 ED 6C          ml
L0C5A               ldd       $0C,S               * 0C5A EC 6C          ll
                    blt       L0C4B               * 0C5C 2D ED          -m
                    leax      >$0001,Y            * 0C5E 30 A9 00 01    0)..
                    stx       $04,S               * 0C62 AF 64          /d
                    bra       L0C9C               * 0C64 20 36           6
L0C66               ldd       0,S                 * 0C66 EC E4          ld
                    addd      #1                  * 0C68 C3 00 01       C..
                    std       0,S                 * 0C6B ED E4          md
L0C6D               ldd       $0C,S               * 0C6D EC 6C          ll
                    subd      [<$04,S]            * 0C6F A3 F8 04       #x.
                    std       $0C,S               * 0C72 ED 6C          ml
                    bge       L0C66               * 0C74 2C F0          ,p
                    ldd       $0C,S               * 0C76 EC 6C          ll
                    addd      [<$04,S]            * 0C78 E3 F8 04       cx.
                    std       $0C,S               * 0C7B ED 6C          ml
                    ldd       0,S                 * 0C7D EC E4          ld
                    beq       L0C86               * 0C7F 27 05          '.
                    ldd       #1                  * 0C81 CC 00 01       L..
                    std       $02,S               * 0C84 ED 62          mb
L0C86               ldd       $02,S               * 0C86 EC 62          lb
                    beq       L0C91               * 0C88 27 07          '.
                    ldd       0,S                 * 0C8A EC E4          ld
                    addd      #48                 * 0C8C C3 00 30       C.0
                    stb       ,U+                 * 0C8F E7 C0          g@
L0C91               clra                          * 0C91 4F             O
                    clrb                          * 0C92 5F             _
                    std       0,S                 * 0C93 ED E4          md
                    ldd       $04,S               * 0C95 EC 64          ld
                    addd      #2                  * 0C97 C3 00 02       C..
                    std       $04,S               * 0C9A ED 64          md
L0C9C               ldd       $04,S               * 0C9C EC 64          ld
                    cmpd      >$0009,Y            * 0C9E 10 A3 A9 00 09 .#)..
                    bne       L0C6D               * 0CA3 26 C8          &H
                    ldd       $0C,S               * 0CA5 EC 6C          ll
                    addd      #48                 * 0CA7 C3 00 30       C.0
                    stb       ,U+                 * 0CAA E7 C0          g@
                    clra                          * 0CAC 4F             O
                    clrb                          * 0CAD 5F             _
                    stb       U0000,U             * 0CAE E7 C4          gD
                    ldd       $0A,S               * 0CB0 EC 6A          lj
                    leas      $06,S               * 0CB2 32 66          2f
                    puls      PC,U                * 0CB4 35 C0          5@
L0CB6               pshs      U,D                 * 0CB6 34 46          4F
                    leax      >$0391,Y            * 0CB8 30 A9 03 91    0)..
                    stx       0,S                 * 0CBC AF E4          /d
                    leau      >$039B,Y            * 0CBE 33 A9 03 9B    3)..
L0CC2               ldd       $06,S               * 0CC2 EC 66          lf
                    clra                          * 0CC4 4F             O
                    andb      #7                  * 0CC5 C4 07          D.
                    addd      #48                 * 0CC7 C3 00 30       C.0
                    stb       ,U+                 * 0CCA E7 C0          g@
                    ldd       $06,S               * 0CCC EC 66          lf
                    lsra                          * 0CCE 44             D
                    rorb                          * 0CCF 56             V
                    lsra                          * 0CD0 44             D
                    rorb                          * 0CD1 56             V
                    lsra                          * 0CD2 44             D
                    rorb                          * 0CD3 56             V
                    std       $06,S               * 0CD4 ED 66          mf
                    bne       L0CC2               * 0CD6 26 EA          &j
                    bra       L0CE4               * 0CD8 20 0A           .
L0CDA               ldb       U0000,U             * 0CDA E6 C4          fD
                    ldx       0,S                 * 0CDC AE E4          .d
                    leax      $01,X               * 0CDE 30 01          0.
                    stx       0,S                 * 0CE0 AF E4          /d
                    stb       -$01,X              * 0CE2 E7 1F          g.
L0CE4               leau      -$01,U              * 0CE4 33 5F          3_
                    pshs      U                   * 0CE6 34 40          4@
                    leax      >$039B,Y            * 0CE8 30 A9 03 9B    0)..
                    cmpx      ,S++                * 0CEC AC E1          ,a
                    bls       L0CDA               * 0CEE 23 EA          #j
                    clra                          * 0CF0 4F             O
                    clrb                          * 0CF1 5F             _
                    stb       [,S]                * 0CF2 E7 F4          gt
L0CF4               leax      >$0391,Y            * 0CF4 30 A9 03 91    0)..
                    tfr       X,D                 * 0CF8 1F 10          ..
L0CFA               leas      $02,S               * 0CFA 32 62          2b
                    puls      PC,U                * 0CFC 35 C0          5@
L0CFE               pshs      U,X,D               * 0CFE 34 56          4V
                    leax      >$0391,Y            * 0D00 30 A9 03 91    0)..
                    stx       $02,S               * 0D04 AF 62          /b
                    leau      >$039B,Y            * 0D06 33 A9 03 9B    3)..
L0D0A               ldd       $08,S               * 0D0A EC 68          lh
                    clra                          * 0D0C 4F             O
                    andb      #15                 * 0D0D C4 0F          D.
                    std       0,S                 * 0D0F ED E4          md
                    pshs      D                   * 0D11 34 06          4.
                    ldd       $02,S               * 0D13 EC 62          lb
                    cmpd      #9                  * 0D15 10 83 00 09    ....
                    ble       L0D2C               * 0D19 2F 11          /.
                    ldd       $0C,S               * 0D1B EC 6C          ll
                    beq       L0D24               * 0D1D 27 05          '.
                    ldd       #65                 * 0D1F CC 00 41       L.A
                    bra       L0D27               * 0D22 20 03           .
L0D24               ldd       #97                 * 0D24 CC 00 61       L.a
L0D27               addd      #-10                * 0D27 C3 FF F6       C.v
                    bra       L0D2F               * 0D2A 20 03           .
L0D2C               ldd       #48                 * 0D2C CC 00 30       L.0
L0D2F               addd      ,S++                * 0D2F E3 E1          ca
                    stb       ,U+                 * 0D31 E7 C0          g@
                    ldd       $08,S               * 0D33 EC 68          lh
                    lsra                          * 0D35 44             D
                    rorb                          * 0D36 56             V
                    lsra                          * 0D37 44             D
                    rorb                          * 0D38 56             V
                    lsra                          * 0D39 44             D
                    rorb                          * 0D3A 56             V
                    lsra                          * 0D3B 44             D
                    rorb                          * 0D3C 56             V
                    anda      #15                 * 0D3D 84 0F          ..
                    std       $08,S               * 0D3F ED 68          mh
                    bne       L0D0A               * 0D41 26 C7          &G
                    bra       L0D4F               * 0D43 20 0A           .
L0D45               ldb       U0000,U             * 0D45 E6 C4          fD
                    ldx       $02,S               * 0D47 AE 62          .b
                    leax      $01,X               * 0D49 30 01          0.
                    stx       $02,S               * 0D4B AF 62          /b
                    stb       -$01,X              * 0D4D E7 1F          g.
L0D4F               leau      -$01,U              * 0D4F 33 5F          3_
                    pshs      U                   * 0D51 34 40          4@
                    leax      >$039B,Y            * 0D53 30 A9 03 9B    0)..
                    cmpx      ,S++                * 0D57 AC E1          ,a
                    bls       L0D45               * 0D59 23 EA          #j
                    clra                          * 0D5B 4F             O
                    clrb                          * 0D5C 5F             _
                    stb       [<$02,S]            * 0D5D E7 F8 02       gx.
                    leax      >$0391,Y            * 0D60 30 A9 03 91    0)..
                    tfr       X,D                 * 0D64 1F 10          ..
                    lbra      L0E41               * 0D66 16 00 D8       ..X
L0D69               pshs      U                   * 0D69 34 40          4@
                    ldu       $06,S               * 0D6B EE 66          nf
                    ldd       $0A,S               * 0D6D EC 6A          lj
                    subd      $08,S               * 0D6F A3 68          #h
                    std       $0A,S               * 0D71 ED 6A          mj
                    ldd       >$03A5,Y            * 0D73 EC A9 03 A5    l).%
                    bne       L0D9E               * 0D77 26 25          &%
                    bra       L0D86               * 0D79 20 0B           .
L0D7B               ldd       >$03A7,Y            * 0D7B EC A9 03 A7    l).'
                    pshs      D                   * 0D7F 34 06          4.
                    jsr       [<$06,S]            * 0D81 AD F8 06       -x.
                    leas      $02,S               * 0D84 32 62          2b
L0D86               ldd       $0A,S               * 0D86 EC 6A          lj
                    addd      #-1                 * 0D88 C3 FF FF       C..
                    std       $0A,S               * 0D8B ED 6A          mj
                    subd      #-1                 * 0D8D 83 FF FF       ...
                    bgt       L0D7B               * 0D90 2E E9          .i
                    bra       L0D9E               * 0D92 20 0A           .
L0D94               ldb       ,U+                 * 0D94 E6 C0          f@
                    sex                           * 0D96 1D             .
                    pshs      D                   * 0D97 34 06          4.
                    jsr       [<$06,S]            * 0D99 AD F8 06       -x.
                    leas      $02,S               * 0D9C 32 62          2b
L0D9E               ldd       $08,S               * 0D9E EC 68          lh
                    addd      #-1                 * 0DA0 C3 FF FF       C..
                    std       $08,S               * 0DA3 ED 68          mh
                    subd      #-1                 * 0DA5 83 FF FF       ...
                    bne       L0D94               * 0DA8 26 EA          &j
                    ldd       >$03A5,Y            * 0DAA EC A9 03 A5    l).%
                    beq       L0DC9               * 0DAE 27 19          '.
                    bra       L0DBD               * 0DB0 20 0B           .
L0DB2               ldd       >$03A7,Y            * 0DB2 EC A9 03 A7    l).'
                    pshs      D                   * 0DB6 34 06          4.
                    jsr       [<$06,S]            * 0DB8 AD F8 06       -x.
                    leas      $02,S               * 0DBB 32 62          2b
L0DBD               ldd       $0A,S               * 0DBD EC 6A          lj
                    addd      #-1                 * 0DBF C3 FF FF       C..
                    std       $0A,S               * 0DC2 ED 6A          mj
                    subd      #-1                 * 0DC4 83 FF FF       ...
                    bgt       L0DB2               * 0DC7 2E E9          .i
L0DC9               puls      PC,U                * 0DC9 35 C0          5@
L0DCB               pshs      U                   * 0DCB 34 40          4@
                    ldu       $06,S               * 0DCD EE 66          nf
                    ldd       $08,S               * 0DCF EC 68          lh
                    pshs      D                   * 0DD1 34 06          4.
                    pshs      U                   * 0DD3 34 40          4@
                    lbsr      L12A6               * 0DD5 17 04 CE       ..N
                    leas      $02,S               * 0DD8 32 62          2b
                    nega                          * 0DDA 40             @
                    negb                          * 0DDB 50             P
                    sbca      #0                  * 0DDC 82 00          ..
                    addd      ,S++                * 0DDE E3 E1          ca
                    std       $08,S               * 0DE0 ED 68          mh
                    ldd       >$03A5,Y            * 0DE2 EC A9 03 A5    l).%
                    bne       L0E0D               * 0DE6 26 25          &%
                    bra       L0DF5               * 0DE8 20 0B           .
L0DEA               ldd       >$03A7,Y            * 0DEA EC A9 03 A7    l).'
                    pshs      D                   * 0DEE 34 06          4.
                    jsr       [<$06,S]            * 0DF0 AD F8 06       -x.
                    leas      $02,S               * 0DF3 32 62          2b
L0DF5               ldd       $08,S               * 0DF5 EC 68          lh
                    addd      #-1                 * 0DF7 C3 FF FF       C..
                    std       $08,S               * 0DFA ED 68          mh
                    subd      #-1                 * 0DFC 83 FF FF       ...
                    bgt       L0DEA               * 0DFF 2E E9          .i
                    bra       L0E0D               * 0E01 20 0A           .
L0E03               ldb       ,U+                 * 0E03 E6 C0          f@
                    sex                           * 0E05 1D             .
                    pshs      D                   * 0E06 34 06          4.
                    jsr       [<$06,S]            * 0E08 AD F8 06       -x.
                    leas      $02,S               * 0E0B 32 62          2b
L0E0D               ldb       U0000,U             * 0E0D E6 C4          fD
                    bne       L0E03               * 0E0F 26 F2          &r
                    ldd       >$03A5,Y            * 0E11 EC A9 03 A5    l).%
                    beq       L0E30               * 0E15 27 19          '.
                    bra       L0E24               * 0E17 20 0B           .
L0E19               ldd       >$03A7,Y            * 0E19 EC A9 03 A7    l).'
                    pshs      D                   * 0E1D 34 06          4.
                    jsr       [<$06,S]            * 0E1F AD F8 06       -x.
                    leas      $02,S               * 0E22 32 62          2b
L0E24               ldd       $08,S               * 0E24 EC 68          lh
                    addd      #-1                 * 0E26 C3 FF FF       C..
                    std       $08,S               * 0E29 ED 68          mh
                    subd      #-1                 * 0E2B 83 FF FF       ...
                    bgt       L0E19               * 0E2E 2E E9          .i
L0E30               puls      PC,U                * 0E30 35 C0          5@
L0E32               fcb       $34                 * 0E32 34             4
                    fcb       $40                 * 0E33 40             @
                    fcb       $EC                 * 0E34 EC             l
                    fcb       $A9                 * 0E35 A9             )
                    fcb       $03                 * 0E36 03             .
                    fcb       $8F                 * 0E37 8F             .
                    fcb       $34                 * 0E38 34             4
                    fcb       $06                 * 0E39 06             .
                    fcb       $EC                 * 0E3A EC             l
                    fcb       $66                 * 0E3B 66             f
                    fcb       $34                 * 0E3C 34             4
                    fcb       $06                 * 0E3D 06             .
                    fcb       $17                 * 0E3E 17             .
                    fcb       $00                 * 0E3F 00             .
                    fcb       $1D                 * 0E40 1D             .
L0E41               leas      $04,S               * 0E41 32 64          2d
                    puls      PC,U                * 0E43 35 C0          5@
                    fcb       $34                 * 0E45 34             4
                    fcb       $40                 * 0E46 40             @
                    fcb       $EC                 * 0E47 EC             l
                    fcb       $64                 * 0E48 64             d
                    fcb       $AE                 * 0E49 AE             .
                    fcb       $A9                 * 0E4A A9             )
                    fcb       $03                 * 0E4B 03             .
                    fcb       $8F                 * 0E4C 8F             .
                    fcb       $30                 * 0E4D 30             0
                    fcb       $01                 * 0E4E 01             .
                    fcb       $AF                 * 0E4F AF             /
                    fcb       $A9                 * 0E50 A9             )
                    fcb       $03                 * 0E51 03             .
                    fcb       $8F                 * 0E52 8F             .
                    fcb       $E7                 * 0E53 E7             g
                    fcb       $1F                 * 0E54 1F             .
                    fcb       $35                 * 0E55 35             5
                    fcb       $C0                 * 0E56 C0             @
L0E57               fcc       "-32768"            * 0E57 2D 33 32 37 36 38 -32768
                    fcb       $00                 * 0E5D 00             .
                    fcb       $34                 * 0E5E 34             4
                    fcb       $40                 * 0E5F 40             @
                    fcb       $EE                 * 0E60 EE             n
                    fcb       $66                 * 0E61 66             f
                    fcb       $EC                 * 0E62 EC             l
                    fcb       $46                 * 0E63 46             F
                    fcb       $84                 * 0E64 84             .
                    fcb       $80                 * 0E65 80             .
                    fcb       $C4                 * 0E66 C4             D
                    fcb       $22                 * 0E67 22             "
                    fcb       $10                 * 0E68 10             .
                    fcb       $83                 * 0E69 83             .
                    fcb       $80                 * 0E6A 80             .
                    fcb       $02                 * 0E6B 02             .
                    fcb       $27                 * 0E6C 27             '
                    fcb       $14                 * 0E6D 14             .
                    fcb       $EC                 * 0E6E EC             l
                    fcb       $46                 * 0E6F 46             F
                    fcb       $4F                 * 0E70 4F             O
                    fcb       $C4                 * 0E71 C4             D
                    fcb       $22                 * 0E72 22             "
                    fcb       $10                 * 0E73 10             .
                    fcb       $83                 * 0E74 83             .
                    fcb       $00                 * 0E75 00             .
                    fcb       $02                 * 0E76 02             .
                    fcb       $10                 * 0E77 10             .
                    fcb       $26                 * 0E78 26             &
                    fcb       $01                 * 0E79 01             .
                    fcb       $1F                 * 0E7A 1F             .
                    fcb       $34                 * 0E7B 34             4
                    fcb       $40                 * 0E7C 40             @
                    fcb       $17                 * 0E7D 17             .
                    fcb       $03                 * 0E7E 03             .
                    fcc       "M2b"               * 0E7F 4D 32 62       M2b
                    fcb       $EC                 * 0E82 EC             l
                    fcb       $46                 * 0E83 46             F
                    fcb       $4F                 * 0E84 4F             O
                    fcb       $C4                 * 0E85 C4             D
                    fcb       $04                 * 0E86 04             .
                    fcb       $27                 * 0E87 27             '
                    fcb       $35                 * 0E88 35             5
                    fcb       $CC                 * 0E89 CC             L
                    fcb       $00                 * 0E8A 00             .
                    fcb       $01                 * 0E8B 01             .
                    fcb       $34                 * 0E8C 34             4
                    fcb       $06                 * 0E8D 06             .
                    fcc       "0g4"               * 0E8E 30 67 34       0g4
                    fcb       $10                 * 0E91 10             .
                    fcb       $EC                 * 0E92 EC             l
                    fcb       $48                 * 0E93 48             H
                    fcb       $34                 * 0E94 34             4
                    fcb       $06                 * 0E95 06             .
                    fcb       $EC                 * 0E96 EC             l
                    fcb       $46                 * 0E97 46             F
                    fcb       $4F                 * 0E98 4F             O
                    fcb       $C4                 * 0E99 C4             D
                    fcb       $40                 * 0E9A 40             @
                    fcb       $27                 * 0E9B 27             '
                    fcb       $06                 * 0E9C 06             .
                    fcb       $30                 * 0E9D 30             0
                    fcb       $8D                 * 0E9E 8D             .
                    fcb       $06                 * 0E9F 06             .
                    fcb       $43                 * 0EA0 43             C
                    fcb       $20                 * 0EA1 20
                    fcb       $04                 * 0EA2 04             .
                    fcb       $30                 * 0EA3 30             0
                    fcb       $8D                 * 0EA4 8D             .
                    fcb       $06                 * 0EA5 06             .
                    fcb       $24                 * 0EA6 24             $
                    fcb       $1F                 * 0EA7 1F             .
                    fcb       $10                 * 0EA8 10             .
                    fcb       $1F                 * 0EA9 1F             .
                    fcb       $01                 * 0EAA 01             .
                    fcb       $AD                 * 0EAB AD             -
                    fcb       $84                 * 0EAC 84             .
                    fcb       $32                 * 0EAD 32             2
                    fcb       $66                 * 0EAE 66             f
                    fcb       $10                 * 0EAF 10             .
                    fcb       $83                 * 0EB0 83             .
                    fcb       $FF                 * 0EB1 FF             .
                    fcb       $FF                 * 0EB2 FF             .
                    fcb       $26                 * 0EB3 26             &
                    fcb       $4A                 * 0EB4 4A             J
                    fcb       $EC                 * 0EB5 EC             l
                    fcb       $46                 * 0EB6 46             F
                    fcb       $CA                 * 0EB7 CA             J
                    fcb       $20                 * 0EB8 20
                    fcb       $ED                 * 0EB9 ED             m
                    fcb       $46                 * 0EBA 46             F
                    fcb       $16                 * 0EBB 16             .
                    fcb       $00                 * 0EBC 00             .
                    fcb       $DC                 * 0EBD DC             \
                    fcb       $EC                 * 0EBE EC             l
                    fcb       $46                 * 0EBF 46             F
                    fcb       $84                 * 0EC0 84             .
                    fcb       $01                 * 0EC1 01             .
                    fcb       $5F                 * 0EC2 5F             _
                    fcb       $ED                 * 0EC3 ED             m
                    fcb       $7E                 * 0EC4 7E             ~
                    fcb       $26                 * 0EC5 26             &
                    fcb       $07                 * 0EC6 07             .
                    fcb       $34                 * 0EC7 34             4
                    fcb       $40                 * 0EC8 40             @
                    fcb       $17                 * 0EC9 17             .
                    fcb       $00                 * 0ECA 00             .
                    fcb       $EB                 * 0ECB EB             k
                    fcb       $32                 * 0ECC 32             2
                    fcb       $62                 * 0ECD 62             b
                    fcb       $EC                 * 0ECE EC             l
                    fcb       $C4                 * 0ECF C4             D
                    fcb       $C3                 * 0ED0 C3             C
                    fcb       $00                 * 0ED1 00             .
                    fcb       $01                 * 0ED2 01             .
                    fcb       $ED                 * 0ED3 ED             m
                    fcb       $C4                 * 0ED4 C4             D
                    fcb       $83                 * 0ED5 83             .
                    fcb       $00                 * 0ED6 00             .
                    fcb       $01                 * 0ED7 01             .
                    fcb       $1F                 * 0ED8 1F             .
                    fcb       $01                 * 0ED9 01             .
                    fcb       $EC                 * 0EDA EC             l
                    fcb       $64                 * 0EDB 64             d
                    fcb       $E7                 * 0EDC E7             g
                    fcb       $84                 * 0EDD 84             .
                    fcb       $EC                 * 0EDE EC             l
                    fcb       $C4                 * 0EDF C4             D
                    fcb       $10                 * 0EE0 10             .
                    fcb       $A3                 * 0EE1 A3             #
                    fcb       $44                 * 0EE2 44             D
                    fcb       $24                 * 0EE3 24             $
                    fcb       $0F                 * 0EE4 0F             .
                    fcb       $EC                 * 0EE5 EC             l
                    fcb       $46                 * 0EE6 46             F
                    fcb       $4F                 * 0EE7 4F             O
                    fcb       $C4                 * 0EE8 C4             D
                    fcb       $40                 * 0EE9 40             @
                    fcb       $27                 * 0EEA 27             '
                    fcb       $13                 * 0EEB 13             .
                    fcb       $EC                 * 0EEC EC             l
                    fcb       $64                 * 0EED 64             d
                    fcb       $10                 * 0EEE 10             .
                    fcb       $83                 * 0EEF 83             .
                    fcb       $00                 * 0EF0 00             .
                    fcb       $0D                 * 0EF1 0D             .
                    fcb       $26                 * 0EF2 26             &
                    fcb       $0B                 * 0EF3 0B             .
                    fcb       $34                 * 0EF4 34             4
                    fcb       $40                 * 0EF5 40             @
                    fcb       $17                 * 0EF6 17             .
                    fcb       $00                 * 0EF7 00             .
                    fcb       $BE                 * 0EF8 BE             >
                    fcb       $ED                 * 0EF9 ED             m
                    fcb       $E1                 * 0EFA E1             a
                    fcb       $10                 * 0EFB 10             .
                    fcb       $26                 * 0EFC 26             &
                    fcb       $00                 * 0EFD 00             .
                    fcb       $9B                 * 0EFE 9B             .
                    fcb       $EC                 * 0EFF EC             l
                    fcb       $64                 * 0F00 64             d
                    fcb       $35                 * 0F01 35             5
                    fcb       $C0                 * 0F02 C0             @
                    fcb       $34                 * 0F03 34             4
                    fcb       $40                 * 0F04 40             @
                    fcb       $EE                 * 0F05 EE             n
                    fcb       $64                 * 0F06 64             d
                    fcb       $EC                 * 0F07 EC             l
                    fcb       $66                 * 0F08 66             f
                    fcb       $34                 * 0F09 34             4
                    fcb       $06                 * 0F0A 06             .
                    fcb       $34                 * 0F0B 34             4
                    fcb       $40                 * 0F0C 40             @
                    fcb       $CC                 * 0F0D CC             L
                    fcb       $00                 * 0F0E 00             .
                    fcb       $08                 * 0F0F 08             .
                    fcb       $17                 * 0F10 17             .
                    fcb       $04                 * 0F11 04             .
                    fcb       $79                 * 0F12 79             y
                    fcb       $34                 * 0F13 34             4
                    fcb       $06                 * 0F14 06             .
                    fcb       $17                 * 0F15 17             .
                    fcb       $FF                 * 0F16 FF             .
                    fcc       "F2d"               * 0F17 46 32 64       F2d
                    fcb       $EC                 * 0F1A EC             l
                    fcb       $66                 * 0F1B 66             f
                    fcb       $34                 * 0F1C 34             4
                    fcb       $06                 * 0F1D 06             .
                    fcb       $34                 * 0F1E 34             4
                    fcb       $40                 * 0F1F 40             @
                    fcb       $17                 * 0F20 17             .
                    fcb       $FF                 * 0F21 FF             .
                    fcb       $3B                 * 0F22 3B             ;
                    fcb       $16                 * 0F23 16             .
                    fcb       $01                 * 0F24 01             .
                    fcc       "K"                 * 0F25 4B             K
L0F26               pshs      U,D                 * 0F26 34 46          4F
                    leau      >$000E,Y            * 0F28 33 A9 00 0E    3)..
                    clra                          * 0F2C 4F             O
                    clrb                          * 0F2D 5F             _
                    std       0,S                 * 0F2E ED E4          md
                    bra       L0F3C               * 0F30 20 0A           .
L0F32               tfr       U,D                 * 0F32 1F 30          .0
                    leau      U000D,U             * 0F34 33 4D          3M
                    pshs      D                   * 0F36 34 06          4.
                    bsr       L0F4F               * 0F38 8D 15          ..
                    leas      $02,S               * 0F3A 32 62          2b
L0F3C               ldd       0,S                 * 0F3C EC E4          ld
                    addd      #1                  * 0F3E C3 00 01       C..
                    std       0,S                 * 0F41 ED E4          md
                    subd      #1                  * 0F43 83 00 01       ...
                    cmpd      #16                 * 0F46 10 83 00 10    ....
                    blt       L0F32               * 0F4A 2D E6          -f
                    lbra      L0FB3               * 0F4C 16 00 64       ..d
L0F4F               pshs      U                   * 0F4F 34 40          4@
                    ldu       $04,S               * 0F51 EE 64          nd
                    leas      -$02,S              * 0F53 32 7E          2~
                    cmpu      #0                  * 0F55 11 83 00 00    ....
                    beq       L0F5F               * 0F59 27 04          '.
                    ldd       U0006,U             * 0F5B EC 46          lF
                    bne       L0F65               * 0F5D 26 06          &.
L0F5F               ldd       #-1                 * 0F5F CC FF FF       L..
                    lbra      L0FB3               * 0F62 16 00 4E       ..N
L0F65               ldd       U0006,U             * 0F65 EC 46          lF
                    clra                          * 0F67 4F             O
                    andb      #2                  * 0F68 C4 02          D.
                    beq       L0F74               * 0F6A 27 08          '.
                    pshs      U                   * 0F6C 34 40          4@
                    bsr       L0F89               * 0F6E 8D 19          ..
                    leas      $02,S               * 0F70 32 62          2b
                    bra       L0F76               * 0F72 20 02           .
L0F74               clra                          * 0F74 4F             O
                    clrb                          * 0F75 5F             _
L0F76               std       0,S                 * 0F76 ED E4          md
                    ldd       U0008,U             * 0F78 EC 48          lH
                    pshs      D                   * 0F7A 34 06          4.
                    lbsr      L142D               * 0F7C 17 04 AE       ...
                    leas      $02,S               * 0F7F 32 62          2b
                    clra                          * 0F81 4F             O
                    clrb                          * 0F82 5F             _
                    std       U0006,U             * 0F83 ED 46          mF
                    ldd       0,S                 * 0F85 EC E4          ld
                    bra       L0FB3               * 0F87 20 2A           *
L0F89               pshs      U                   * 0F89 34 40          4@
                    ldu       $04,S               * 0F8B EE 64          nd
                    beq       L0F9A               * 0F8D 27 0B          '.
                    ldd       U0006,U             * 0F8F EC 46          lF
                    clra                          * 0F91 4F             O
                    andb      #34                 * 0F92 C4 22          D"
                    cmpd      #2                  * 0F94 10 83 00 02    ....
                    beq       L0F9F               * 0F98 27 05          '.
L0F9A               ldd       #-1                 * 0F9A CC FF FF       L..
                    puls      PC,U                * 0F9D 35 C0          5@
L0F9F               ldd       U0006,U             * 0F9F EC 46          lF
                    anda      #128                * 0FA1 84 80          ..
                    clrb                          * 0FA3 5F             _
                    std       -$02,S              * 0FA4 ED 7E          m~
                    bne       L0FAF               * 0FA6 26 07          &.
                    pshs      U                   * 0FA8 34 40          4@
                    lbsr      L11CD               * 0FAA 17 02 20       ..
                    leas      $02,S               * 0FAD 32 62          2b
L0FAF               pshs      U                   * 0FAF 34 40          4@
                    bsr       L0FB7               * 0FB1 8D 04          ..
L0FB3               leas      $02,S               * 0FB3 32 62          2b
                    puls      PC,U                * 0FB5 35 C0          5@
L0FB7               pshs      U                   * 0FB7 34 40          4@
                    ldu       $04,S               * 0FB9 EE 64          nd
                    leas      -$04,S              * 0FBB 32 7C          2|
                    ldd       U0006,U             * 0FBD EC 46          lF
                    anda      #1                  * 0FBF 84 01          ..
                    clrb                          * 0FC1 5F             _
                    std       -$02,S              * 0FC2 ED 7E          m~
                    bne       L0FE9               * 0FC4 26 23          &#
                    ldd       U0000,U             * 0FC6 EC C4          lD
                    cmpd      U0004,U             * 0FC8 10 A3 44       .#D
                    beq       L0FE9               * 0FCB 27 1C          '.
                    clra                          * 0FCD 4F             O
                    clrb                          * 0FCE 5F             _
                    pshs      D                   * 0FCF 34 06          4.
                    pshs      U                   * 0FD1 34 40          4@
                    lbsr      L1075               * 0FD3 17 00 9F       ...
                    leas      $02,S               * 0FD6 32 62          2b
                    ldd       $02,X               * 0FD8 EC 02          l.
                    pshs      D                   * 0FDA 34 06          4.
                    ldd       0,X                 * 0FDC EC 84          l.
                    pshs      D                   * 0FDE 34 06          4.
                    ldd       U0008,U             * 0FE0 EC 48          lH
                    pshs      D                   * 0FE2 34 06          4.
                    lbsr      L14F4               * 0FE4 17 05 0D       ...
                    leas      $08,S               * 0FE7 32 68          2h
L0FE9               ldd       U0000,U             * 0FE9 EC C4          lD
                    subd      U0002,U             * 0FEB A3 42          #B
                    std       $02,S               * 0FED ED 62          mb
                    lbeq      L1061               * 0FEF 10 27 00 6E    .'.n
                    ldd       U0006,U             * 0FF3 EC 46          lF
                    anda      #1                  * 0FF5 84 01          ..
                    clrb                          * 0FF7 5F             _
                    std       -$02,S              * 0FF8 ED 7E          m~
                    lbeq      L1061               * 0FFA 10 27 00 63    .'.c
                    ldd       U0006,U             * 0FFE EC 46          lF
                    clra                          * 1000 4F             O
                    andb      #64                 * 1001 C4 40          D@
                    beq       L1038               * 1003 27 33          '3
                    ldd       U0002,U             * 1005 EC 42          lB
                    bra       L1030               * 1007 20 27           '
L1009               ldd       $02,S               * 1009 EC 62          lb
                    pshs      D                   * 100B 34 06          4.
                    ldd       U0000,U             * 100D EC C4          lD
                    pshs      D                   * 100F 34 06          4.
                    ldd       U0008,U             * 1011 EC 48          lH
                    pshs      D                   * 1013 34 06          4.
                    lbsr      L14E4               * 1015 17 04 CC       ..L
                    leas      $06,S               * 1018 32 66          2f
                    std       0,S                 * 101A ED E4          md
                    cmpd      #-1                 * 101C 10 83 FF FF    ....
                    bne       L1026               * 1020 26 04          &.
                    leax      $04,S               * 1022 30 64          0d
                    bra       L1050               * 1024 20 2A           *
L1026               ldd       $02,S               * 1026 EC 62          lb
                    subd      0,S                 * 1028 A3 E4          #d
                    std       $02,S               * 102A ED 62          mb
                    ldd       U0000,U             * 102C EC C4          lD
                    addd      0,S                 * 102E E3 E4          cd
L1030               std       U0000,U             * 1030 ED C4          mD
                    ldd       $02,S               * 1032 EC 62          lb
                    bne       L1009               * 1034 26 D3          &S
                    bra       L1061               * 1036 20 29           )
L1038               ldd       $02,S               * 1038 EC 62          lb
                    pshs      D                   * 103A 34 06          4.
                    ldd       U0002,U             * 103C EC 42          lB
                    pshs      D                   * 103E 34 06          4.
                    ldd       U0008,U             * 1040 EC 48          lH
                    pshs      D                   * 1042 34 06          4.
                    lbsr      L14CB               * 1044 17 04 84       ...
                    leas      $06,S               * 1047 32 66          2f
                    cmpd      $02,S               * 1049 10 A3 62       .#b
                    beq       L1061               * 104C 27 13          '.
                    bra       L1052               * 104E 20 02           .
L1050               leas      -$04,X              * 1050 32 1C          2.
L1052               ldd       U0006,U             * 1052 EC 46          lF
                    orb       #32                 * 1054 CA 20          J
                    std       U0006,U             * 1056 ED 46          mF
                    ldd       U0004,U             * 1058 EC 44          lD
                    std       U0000,U             * 105A ED C4          mD
                    ldd       #-1                 * 105C CC FF FF       L..
                    bra       L1071               * 105F 20 10           .
L1061               ldd       U0006,U             * 1061 EC 46          lF
                    ora       #1                  * 1063 8A 01          ..
                    std       U0006,U             * 1065 ED 46          mF
                    ldd       U0002,U             * 1067 EC 42          lB
                    std       U0000,U             * 1069 ED C4          mD
                    addd      U000B,U             * 106B E3 4B          cK
                    std       U0004,U             * 106D ED 44          mD
                    clra                          * 106F 4F             O
                    clrb                          * 1070 5F             _
L1071               leas      $04,S               * 1071 32 64          2d
                    puls      PC,U                * 1073 35 C0          5@
L1075               pshs      U                   * 1075 34 40          4@
                    puls      PC,U                * 1077 35 C0          5@
L1079               pshs      U                   * 1079 34 40          4@
                    ldu       $04,S               * 107B EE 64          nd
                    beq       L10C5               * 107D 27 46          'F
                    ldd       U0006,U             * 107F EC 46          lF
                    anda      #1                  * 1081 84 01          ..
                    clrb                          * 1083 5F             _
                    std       -$02,S              * 1084 ED 7E          m~
                    bne       L10C5               * 1086 26 3D          &=
                    ldd       U0000,U             * 1088 EC C4          lD
                    cmpd      U0004,U             * 108A 10 A3 44       .#D
                    bcc       L10A1               * 108D 24 12          $.
                    ldd       U0000,U             * 108F EC C4          lD
                    addd      #1                  * 1091 C3 00 01       C..
                    std       U0000,U             * 1094 ED C4          mD
                    subd      #1                  * 1096 83 00 01       ...
                    tfr       D,X                 * 1099 1F 01          ..
                    ldb       0,X                 * 109B E6 84          f.
                    clra                          * 109D 4F             O
                    lbra      L11CB               * 109E 16 01 2A       ..*
L10A1               pshs      U                   * 10A1 34 40          4@
                    lbsr      L1114               * 10A3 17 00 6E       ..n
                    lbra      L11C9               * 10A6 16 01 20       ..
                    fcb       $34                 * 10A9 34             4
                    fcb       $40                 * 10AA 40             @
                    fcb       $EE                 * 10AB EE             n
                    fcb       $66                 * 10AC 66             f
                    fcb       $27                 * 10AD 27             '
                    fcb       $16                 * 10AE 16             .
                    fcb       $EC                 * 10AF EC             l
                    fcb       $46                 * 10B0 46             F
                    fcb       $4F                 * 10B1 4F             O
                    fcb       $C4                 * 10B2 C4             D
                    fcb       $01                 * 10B3 01             .
                    fcb       $27                 * 10B4 27             '
                    fcb       $0F                 * 10B5 0F             .
                    fcb       $EC                 * 10B6 EC             l
                    fcb       $64                 * 10B7 64             d
                    fcb       $10                 * 10B8 10             .
                    fcb       $83                 * 10B9 83             .
                    fcb       $FF                 * 10BA FF             .
                    fcb       $FF                 * 10BB FF             .
                    fcb       $27                 * 10BC 27             '
                    fcb       $07                 * 10BD 07             .
                    fcb       $EC                 * 10BE EC             l
                    fcb       $C4                 * 10BF C4             D
                    fcb       $10                 * 10C0 10             .
                    fcb       $A3                 * 10C1 A3             #
                    fcb       $42                 * 10C2 42             B
                    fcb       $22                 * 10C3 22             "
                    fcb       $05                 * 10C4 05             .
L10C5               ldd       #-1                 * 10C5 CC FF FF       L..
                    puls      PC,U                * 10C8 35 C0          5@
                    fcb       $EC                 * 10CA EC             l
                    fcb       $C4                 * 10CB C4             D
                    fcb       $C3                 * 10CC C3             C
                    fcb       $FF                 * 10CD FF             .
                    fcb       $FF                 * 10CE FF             .
                    fcb       $ED                 * 10CF ED             m
                    fcb       $C4                 * 10D0 C4             D
                    fcb       $1F                 * 10D1 1F             .
                    fcb       $01                 * 10D2 01             .
                    fcb       $EC                 * 10D3 EC             l
                    fcb       $64                 * 10D4 64             d
                    fcb       $E7                 * 10D5 E7             g
                    fcb       $84                 * 10D6 84             .
                    fcb       $EC                 * 10D7 EC             l
                    fcb       $64                 * 10D8 64             d
                    fcb       $35                 * 10D9 35             5
                    fcb       $C0                 * 10DA C0             @
                    fcb       $34                 * 10DB 34             4
                    fcb       $40                 * 10DC 40             @
                    fcb       $EE                 * 10DD EE             n
                    fcc       "d2|4@"             * 10DE 64 32 7C 34 40 d2|4@
                    fcb       $17                 * 10E3 17             .
                    fcb       $FF                 * 10E4 FF             .
                    fcb       $93                 * 10E5 93             .
                    fcb       $32                 * 10E6 32             2
                    fcb       $62                 * 10E7 62             b
                    fcb       $ED                 * 10E8 ED             m
                    fcb       $62                 * 10E9 62             b
                    fcb       $10                 * 10EA 10             .
                    fcb       $83                 * 10EB 83             .
                    fcb       $FF                 * 10EC FF             .
                    fcb       $FF                 * 10ED FF             .
                    fcb       $27                 * 10EE 27             '
                    fcb       $0F                 * 10EF 0F             .
                    fcb       $34                 * 10F0 34             4
                    fcb       $40                 * 10F1 40             @
                    fcb       $17                 * 10F2 17             .
                    fcb       $FF                 * 10F3 FF             .
                    fcb       $84                 * 10F4 84             .
                    fcb       $32                 * 10F5 32             2
                    fcb       $62                 * 10F6 62             b
                    fcb       $ED                 * 10F7 ED             m
                    fcb       $E4                 * 10F8 E4             d
                    fcb       $10                 * 10F9 10             .
                    fcb       $83                 * 10FA 83             .
                    fcb       $FF                 * 10FB FF             .
                    fcb       $FF                 * 10FC FF             .
                    fcb       $26                 * 10FD 26             &
                    fcb       $05                 * 10FE 05             .
                    fcb       $CC                 * 10FF CC             L
                    fcb       $FF                 * 1100 FF             .
                    fcb       $FF                 * 1101 FF             .
                    fcb       $20                 * 1102 20
                    fcb       $0C                 * 1103 0C             .
                    fcb       $EC                 * 1104 EC             l
                    fcb       $62                 * 1105 62             b
                    fcb       $34                 * 1106 34             4
                    fcb       $06                 * 1107 06             .
                    fcb       $CC                 * 1108 CC             L
                    fcb       $00                 * 1109 00             .
                    fcb       $08                 * 110A 08             .
                    fcb       $17                 * 110B 17             .
                    fcb       $02                 * 110C 02             .
                    fcb       $95                 * 110D 95             .
                    fcb       $E3                 * 110E E3             c
                    fcb       $E4                 * 110F E4             d
                    fcc       "2d5"               * 1110 32 64 35       2d5
                    fcb       $C0                 * 1113 C0             @
L1114               pshs      U                   * 1114 34 40          4@
                    ldu       $04,S               * 1116 EE 64          nd
                    leas      -$02,S              * 1118 32 7E          2~
                    ldd       U0006,U             * 111A EC 46          lF
                    anda      #128                * 111C 84 80          ..
                    andb      #49                 * 111E C4 31          D1
                    cmpd      #-32767             * 1120 10 83 80 01    ....
                    beq       L113A               * 1124 27 14          '.
                    ldd       U0006,U             * 1126 EC 46          lF
                    clra                          * 1128 4F             O
                    andb      #49                 * 1129 C4 31          D1
                    cmpd      #1                  * 112B 10 83 00 01    ....
                    lbne      L11B3               * 112F 10 26 00 80    .&..
                    pshs      U                   * 1133 34 40          4@
                    lbsr      L11CD               * 1135 17 00 95       ...
                    leas      $02,S               * 1138 32 62          2b
L113A               leax      >$000E,Y            * 113A 30 A9 00 0E    0)..
                    pshs      X                   * 113E 34 10          4.
                    cmpu      ,S++                * 1140 11 A3 E1       .#a
                    bne       L1157               * 1143 26 12          &.
                    ldd       U0006,U             * 1145 EC 46          lF
                    clra                          * 1147 4F             O
                    andb      #64                 * 1148 C4 40          D@
                    beq       L1157               * 114A 27 0B          '.
                    leax      >$001B,Y            * 114C 30 A9 00 1B    0)..
                    pshs      X                   * 1150 34 10          4.
                    lbsr      L0F89               * 1152 17 FE 34       .~4
                    leas      $02,S               * 1155 32 62          2b
L1157               ldd       U0006,U             * 1157 EC 46          lF
                    clra                          * 1159 4F             O
                    andb      #8                  * 115A C4 08          D.
                    beq       L1183               * 115C 27 25          '%
                    ldd       U000B,U             * 115E EC 4B          lK
                    pshs      D                   * 1160 34 06          4.
                    ldd       U0002,U             * 1162 EC 42          lB
                    pshs      D                   * 1164 34 06          4.
                    ldd       U0008,U             * 1166 EC 48          lH
                    pshs      D                   * 1168 34 06          4.
                    ldd       U0006,U             * 116A EC 46          lF
                    clra                          * 116C 4F             O
                    andb      #64                 * 116D C4 40          D@
                    beq       L1177               * 116F 27 06          '.
                    leax      >L14BB,PC           * 1171 30 8D 03 46    0..F
                    bra       L117B               * 1175 20 04           .
L1177               leax      >L149A,PC           * 1177 30 8D 03 1F    0...
L117B               tfr       X,D                 * 117B 1F 10          ..
                    tfr       D,X                 * 117D 1F 01          ..
                    jsr       0,X                 * 117F AD 84          -.
                    bra       L1195               * 1181 20 12           .
L1183               ldd       #1                  * 1183 CC 00 01       L..
                    pshs      D                   * 1186 34 06          4.
                    leax      U000A,U             * 1188 30 4A          0J
                    stx       U0002,U             * 118A AF 42          /B
                    pshs      X                   * 118C 34 10          4.
                    ldd       U0008,U             * 118E EC 48          lH
                    pshs      D                   * 1190 34 06          4.
                    lbsr      L149A               * 1192 17 03 05       ...
L1195               leas      $06,S               * 1195 32 66          2f
                    std       0,S                 * 1197 ED E4          md
                    ldd       0,S                 * 1199 EC E4          ld
                    bgt       L11B8               * 119B 2E 1B          ..
                    ldd       U0006,U             * 119D EC 46          lF
                    pshs      D                   * 119F 34 06          4.
                    ldd       $02,S               * 11A1 EC 62          lb
                    beq       L11AA               * 11A3 27 05          '.
                    ldd       #32                 * 11A5 CC 00 20       L.
                    bra       L11AD               * 11A8 20 03           .
L11AA               ldd       #16                 * 11AA CC 00 10       L..
L11AD               ora       ,S+                 * 11AD AA E0          *`
                    orb       ,S+                 * 11AF EA E0          j`
                    std       U0006,U             * 11B1 ED 46          mF
L11B3               ldd       #-1                 * 11B3 CC FF FF       L..
                    bra       L11C9               * 11B6 20 11           .
L11B8               ldd       U0002,U             * 11B8 EC 42          lB
                    addd      #1                  * 11BA C3 00 01       C..
                    std       U0000,U             * 11BD ED C4          mD
                    ldd       U0002,U             * 11BF EC 42          lB
                    addd      0,S                 * 11C1 E3 E4          cd
                    std       U0004,U             * 11C3 ED 44          mD
                    ldb       [<$02,U]            * 11C5 E6 D8 02       fX.
                    clra                          * 11C8 4F             O
L11C9               leas      $02,S               * 11C9 32 62          2b
L11CB               puls      PC,U                * 11CB 35 C0          5@
L11CD               pshs      U                   * 11CD 34 40          4@
                    ldu       $04,S               * 11CF EE 64          nd
                    ldd       U0006,U             * 11D1 EC 46          lF
                    clra                          * 11D3 4F             O
                    andb      #192                * 11D4 C4 C0          D@
                    bne       L1205               * 11D6 26 2D          &-
                    leas      -$20,S              * 11D8 32 E8 E0       2h`
                    leax      0,S                 * 11DB 30 E4          0d
                    pshs      X                   * 11DD 34 10          4.
                    ldd       U0008,U             * 11DF EC 48          lH
                    pshs      D                   * 11E1 34 06          4.
                    clra                          * 11E3 4F             O
                    clrb                          * 11E4 5F             _
                    pshs      D                   * 11E5 34 06          4.
                    lbsr      L13AF               * 11E7 17 01 C5       ..E
                    leas      $06,S               * 11EA 32 66          2f
                    ldd       U0006,U             * 11EC EC 46          lF
                    pshs      D                   * 11EE 34 06          4.
                    ldb       $02,S               * 11F0 E6 62          fb
                    bne       L11F9               * 11F2 26 05          &.
                    ldd       #64                 * 11F4 CC 00 40       L.@
                    bra       L11FC               * 11F7 20 03           .
L11F9               ldd       #128                * 11F9 CC 00 80       L..
L11FC               ora       ,S+                 * 11FC AA E0          *`
                    orb       ,S+                 * 11FE EA E0          j`
                    std       U0006,U             * 1200 ED 46          mF
                    leas      <$0020,S            * 1202 32 E8 20       2h
L1205               ldd       U0006,U             * 1205 EC 46          lF
                    ora       #128                * 1207 8A 80          ..
                    std       U0006,U             * 1209 ED 46          mF
                    clra                          * 120B 4F             O
                    andb      #12                 * 120C C4 0C          D.
                    beq       L1212               * 120E 27 02          '.
                    puls      PC,U                * 1210 35 C0          5@
L1212               ldd       U000B,U             * 1212 EC 4B          lK
                    bne       L1227               * 1214 26 11          &.
                    ldd       U0006,U             * 1216 EC 46          lF
                    clra                          * 1218 4F             O
                    andb      #64                 * 1219 C4 40          D@
                    beq       L1222               * 121B 27 05          '.
                    ldd       #128                * 121D CC 00 80       L..
                    bra       L1225               * 1220 20 03           .
L1222               ldd       #256                * 1222 CC 01 00       L..
L1225               std       U000B,U             * 1225 ED 4B          mK
L1227               ldd       U0002,U             * 1227 EC 42          lB
                    bne       L123C               * 1229 26 11          &.
                    ldd       U000B,U             * 122B EC 4B          lK
                    pshs      D                   * 122D 34 06          4.
                    lbsr      L15B2               * 122F 17 03 80       ...
                    leas      $02,S               * 1232 32 62          2b
                    std       U0002,U             * 1234 ED 42          mB
                    cmpd      #-1                 * 1236 10 83 FF FF    ....
                    beq       L1244               * 123A 27 08          '.
L123C               ldd       U0006,U             * 123C EC 46          lF
                    orb       #8                  * 123E CA 08          J.
                    std       U0006,U             * 1240 ED 46          mF
                    bra       L1253               * 1242 20 0F           .
L1244               ldd       U0006,U             * 1244 EC 46          lF
                    orb       #4                  * 1246 CA 04          J.
                    std       U0006,U             * 1248 ED 46          mF
                    leax      U000A,U             * 124A 30 4A          0J
                    stx       U0002,U             * 124C AF 42          /B
                    ldd       #1                  * 124E CC 00 01       L..
                    std       U000B,U             * 1251 ED 4B          mK
L1253               ldd       U0002,U             * 1253 EC 42          lB
                    addd      U000B,U             * 1255 E3 4B          cK
                    std       U0004,U             * 1257 ED 44          mD
                    std       U0000,U             * 1259 ED C4          mD
                    puls      PC,U                * 125B 35 C0          5@
L125D               pshs      U                   * 125D 34 40          4@
                    ldb       $05,S               * 125F E6 65          fe
                    sex                           * 1261 1D             .
                    tfr       D,X                 * 1262 1F 01          ..
                    bra       L1283               * 1264 20 1D           .
L1266               ldd       [<$06,S]            * 1266 EC F8 06       lx.
                    addd      #4                  * 1269 C3 00 04       C..
                    std       [<$06,S]            * 126C ED F8 06       mx.
                    leax      >L129A,PC           * 126F 30 8D 00 27    0..'
                    bra       L127F               * 1273 20 0A           .
L1275               ldb       $05,S               * 1275 E6 65          fe
                    stb       >$000C,Y            * 1277 E7 A9 00 0C    g)..
                    leax      >$000B,Y            * 127B 30 A9 00 0B    0)..
L127F               tfr       X,D                 * 127F 1F 10          ..
                    puls      PC,U                * 1281 35 C0          5@
L1283               cmpx      #100                * 1283 8C 00 64       ..d
                    beq       L1266               * 1286 27 DE          '^
                    cmpx      #111                * 1288 8C 00 6F       ..o
                    lbeq      L1266               * 128B 10 27 FF D7    .'.W
                    cmpx      #120                * 128F 8C 00 78       ..x
                    lbeq      L1266               * 1292 10 27 FF D0    .'.P
                    bra       L1275               * 1296 20 DD           ]
                    fcb       $35                 * 1298 35             5
                    fcb       $C0                 * 1299 C0             @
L129A               fcb       $00                 * 129A 00             .
L129B               pshs      U                   * 129B 34 40          4@
                    leax      >L12A5,PC           * 129D 30 8D 00 04    0...
                    tfr       X,D                 * 12A1 1F 10          ..
                    puls      PC,U                * 12A3 35 C0          5@
L12A5               fcb       $00                 * 12A5 00             .
L12A6               pshs      U                   * 12A6 34 40          4@
                    ldu       $04,S               * 12A8 EE 64          nd
L12AA               ldb       ,U+                 * 12AA E6 C0          f@
                    bne       L12AA               * 12AC 26 FC          &|
                    tfr       U,D                 * 12AE 1F 30          .0
                    subd      $04,S               * 12B0 A3 64          #d
                    addd      #-1                 * 12B2 C3 FF FF       C..
                    puls      PC,U                * 12B5 35 C0          5@
L12B7               pshs      U                   * 12B7 34 40          4@
                    ldu       $06,S               * 12B9 EE 66          nf
                    leas      -$02,S              * 12BB 32 7E          2~
                    ldd       $06,S               * 12BD EC 66          lf
                    std       0,S                 * 12BF ED E4          md
L12C1               ldb       ,U+                 * 12C1 E6 C0          f@
                    ldx       0,S                 * 12C3 AE E4          .d
                    leax      $01,X               * 12C5 30 01          0.
                    stx       0,S                 * 12C7 AF E4          /d
                    stb       -$01,X              * 12C9 E7 1F          g.
                    bne       L12C1               * 12CB 26 F4          &t
                    bra       L12F6               * 12CD 20 27           '
                    fcb       $34                 * 12CF 34             4
                    fcb       $40                 * 12D0 40             @
                    fcb       $EE                 * 12D1 EE             n
                    fcc       "f2~"               * 12D2 66 32 7E       f2~
                    fcb       $EC                 * 12D5 EC             l
                    fcb       $66                 * 12D6 66             f
                    fcb       $ED                 * 12D7 ED             m
                    fcb       $E4                 * 12D8 E4             d
                    fcb       $AE                 * 12D9 AE             .
                    fcb       $E4                 * 12DA E4             d
                    fcb       $30                 * 12DB 30             0
                    fcb       $01                 * 12DC 01             .
                    fcb       $AF                 * 12DD AF             /
                    fcb       $E4                 * 12DE E4             d
                    fcb       $E6                 * 12DF E6             f
                    fcb       $1F                 * 12E0 1F             .
                    fcb       $26                 * 12E1 26             &
                    fcb       $F6                 * 12E2 F6             v
                    fcb       $EC                 * 12E3 EC             l
                    fcb       $E4                 * 12E4 E4             d
                    fcb       $C3                 * 12E5 C3             C
                    fcb       $FF                 * 12E6 FF             .
                    fcb       $FF                 * 12E7 FF             .
                    fcb       $ED                 * 12E8 ED             m
                    fcb       $E4                 * 12E9 E4             d
                    fcb       $E6                 * 12EA E6             f
                    fcb       $C0                 * 12EB C0             @
                    fcb       $AE                 * 12EC AE             .
                    fcb       $E4                 * 12ED E4             d
                    fcb       $30                 * 12EE 30             0
                    fcb       $01                 * 12EF 01             .
                    fcb       $AF                 * 12F0 AF             /
                    fcb       $E4                 * 12F1 E4             d
                    fcb       $E7                 * 12F2 E7             g
                    fcb       $1F                 * 12F3 1F             .
                    fcb       $26                 * 12F4 26             &
                    fcb       $F4                 * 12F5 F4             t
L12F6               ldd       $06,S               * 12F6 EC 66          lf
                    leas      $02,S               * 12F8 32 62          2b
                    puls      PC,U                * 12FA 35 C0          5@
                    fcb       $34                 * 12FC 34             4
                    fcb       $40                 * 12FD 40             @
                    fcb       $EE                 * 12FE EE             n
                    fcb       $64                 * 12FF 64             d
                    fcb       $20                 * 1300 20
                    fcb       $10                 * 1301 10             .
                    fcb       $AE                 * 1302 AE             .
                    fcb       $66                 * 1303 66             f
                    fcb       $30                 * 1304 30             0
                    fcb       $01                 * 1305 01             .
                    fcb       $AF                 * 1306 AF             /
                    fcb       $66                 * 1307 66             f
                    fcb       $E6                 * 1308 E6             f
                    fcb       $1F                 * 1309 1F             .
                    fcb       $26                 * 130A 26             &
                    fcb       $04                 * 130B 04             .
                    fcc       "O_5"               * 130C 4F 5F 35       O_5
                    fcb       $C0                 * 130F C0             @
                    fcb       $33                 * 1310 33             3
                    fcb       $41                 * 1311 41             A
                    fcb       $E6                 * 1312 E6             f
                    fcb       $C4                 * 1313 C4             D
                    fcb       $1D                 * 1314 1D             .
                    fcb       $34                 * 1315 34             4
                    fcb       $06                 * 1316 06             .
                    fcb       $E6                 * 1317 E6             f
                    fcb       $F8                 * 1318 F8             x
                    fcb       $08                 * 1319 08             .
                    fcb       $1D                 * 131A 1D             .
                    fcb       $10                 * 131B 10             .
                    fcb       $A3                 * 131C A3             #
                    fcb       $E1                 * 131D E1             a
                    fcb       $27                 * 131E 27             '
                    fcb       $E2                 * 131F E2             b
                    fcb       $E6                 * 1320 E6             f
                    fcb       $F8                 * 1321 F8             x
                    fcb       $06                 * 1322 06             .
                    fcb       $1D                 * 1323 1D             .
                    fcb       $34                 * 1324 34             4
                    fcb       $06                 * 1325 06             .
                    fcb       $E6                 * 1326 E6             f
                    fcb       $C4                 * 1327 C4             D
                    fcb       $1D                 * 1328 1D             .
                    fcb       $A3                 * 1329 A3             #
                    fcb       $E1                 * 132A E1             a
                    fcb       $35                 * 132B 35             5
                    fcb       $C0                 * 132C C0             @
L132D               tsta                          * 132D 4D             M
                    bne       L1342               * 132E 26 12          &.
                    tst       $02,S               * 1330 6D 62          mb
                    bne       L1342               * 1332 26 0E          &.
                    lda       $03,S               * 1334 A6 63          &c
                    mul                           * 1336 3D             =
                    ldx       0,S                 * 1337 AE E4          .d
                    stx       $02,S               * 1339 AF 62          /b
                    ldx       #0                  * 133B 8E 00 00       ...
                    std       0,S                 * 133E ED E4          md
                    puls      PC,D                * 1340 35 86          5.
L1342               pshs      D                   * 1342 34 06          4.
                    ldd       #0                  * 1344 CC 00 00       L..
                    pshs      D                   * 1347 34 06          4.
                    pshs      D                   * 1349 34 06          4.
                    lda       $05,S               * 134B A6 65          &e
                    ldb       $09,S               * 134D E6 69          fi
                    mul                           * 134F 3D             =
                    std       $02,S               * 1350 ED 62          mb
                    lda       $05,S               * 1352 A6 65          &e
                    ldb       $08,S               * 1354 E6 68          fh
                    mul                           * 1356 3D             =
                    addd      $01,S               * 1357 E3 61          ca
                    std       $01,S               * 1359 ED 61          ma
                    bcc       L135F               * 135B 24 02          $.
                    inc       0,S                 * 135D 6C E4          ld
L135F               lda       $04,S               * 135F A6 64          &d
                    ldb       $09,S               * 1361 E6 69          fi
                    mul                           * 1363 3D             =
                    addd      $01,S               * 1364 E3 61          ca
                    std       $01,S               * 1366 ED 61          ma
                    bcc       L136C               * 1368 24 02          $.
                    inc       0,S                 * 136A 6C E4          ld
L136C               lda       $04,S               * 136C A6 64          &d
                    ldb       $08,S               * 136E E6 68          fh
                    mul                           * 1370 3D             =
                    addd      0,S                 * 1371 E3 E4          cd
                    std       0,S                 * 1373 ED E4          md
                    ldx       $06,S               * 1375 AE 66          .f
                    stx       $08,S               * 1377 AF 68          /h
                    ldx       0,S                 * 1379 AE E4          .d
                    ldd       $02,S               * 137B EC 62          lb
                    leas      $08,S               * 137D 32 68          2h
                    rts                           * 137F 39             9
                    fcb       $5D                 * 1380 5D             ]
                    fcb       $27                 * 1381 27             '
                    fcb       $13                 * 1382 13             .
                    fcc       "gbfcZ&"            * 1383 67 62 66 63 5A 26 gbfcZ&
                    fcb       $F9                 * 1389 F9             y
                    fcb       $20                 * 138A 20
                    fcb       $0A                 * 138B 0A             .
                    fcb       $5D                 * 138C 5D             ]
                    fcb       $27                 * 138D 27             '
                    fcb       $07                 * 138E 07             .
                    fcc       "dbfcZ&"            * 138F 64 62 66 63 5A 26 dbfcZ&
                    fcb       $F9                 * 1395 F9             y
                    fcb       $EC                 * 1396 EC             l
                    fcb       $62                 * 1397 62             b
                    fcb       $34                 * 1398 34             4
                    fcb       $06                 * 1399 06             .
                    fcb       $EC                 * 139A EC             l
                    fcb       $62                 * 139B 62             b
                    fcb       $ED                 * 139C ED             m
                    fcb       $64                 * 139D 64             d
                    fcb       $EC                 * 139E EC             l
                    fcb       $E4                 * 139F E4             d
                    fcc       "2d9]'"             * 13A0 32 64 39 5D 27 2d9]'
                    fcb       $F0                 * 13A5 F0             p
                    fcc       "hcibZ&"            * 13A6 68 63 69 62 5A 26 hcibZ&
                    fcb       $F9                 * 13AC F9             y
                    fcb       $20                 * 13AD 20
                    fcb       $E7                 * 13AE E7             g
L13AF               lda       $05,S               * 13AF A6 65          &e
                    ldb       $03,S               * 13B1 E6 63          fc
                    beq       L13E2               * 13B3 27 2D          '-
                    cmpb      #1                  * 13B5 C1 01          A.
                    beq       L13E4               * 13B7 27 2B          '+
                    cmpb      #6                  * 13B9 C1 06          A.
                    beq       L13E4               * 13BB 27 27          ''
                    cmpb      #2                  * 13BD C1 02          A.
                    beq       L13CA               * 13BF 27 09          '.
                    cmpb      #5                  * 13C1 C1 05          A.
                    beq       L13CA               * 13C3 27 05          '.
                    ldb       #208                * 13C5 C6 D0          FP
                    lbra      L15DF               * 13C7 16 02 15       ...
L13CA               pshs      U                   * 13CA 34 40          4@
                    os9       I$GetStt            * 13CC 10 3F 8D       .?.
                    bcc       L13D6               * 13CF 24 05          $.
                    puls      U                   * 13D1 35 40          5@
                    lbra      L15DF               * 13D3 16 02 09       ...
L13D6               stx       [<$08,S]            * 13D6 AF F8 08       /x.
                    ldx       $08,S               * 13D9 AE 68          .h
                    stu       $02,X               * 13DB EF 02          o.
                    puls      U                   * 13DD 35 40          5@
                    clra                          * 13DF 4F             O
                    clrb                          * 13E0 5F             _
                    rts                           * 13E1 39             9
L13E2               ldx       $06,S               * 13E2 AE 66          .f
L13E4               os9       I$GetStt            * 13E4 10 3F 8D       .?.
                    lbra      L15E8               * 13E7 16 01 FE       ..~
                    fcb       $A6                 * 13EA A6             &
                    fcb       $65                 * 13EB 65             e
                    fcb       $E6                 * 13EC E6             f
                    fcb       $63                 * 13ED 63             c
                    fcb       $27                 * 13EE 27             '
                    fcb       $09                 * 13EF 09             .
                    fcb       $C1                 * 13F0 C1             A
                    fcb       $02                 * 13F1 02             .
                    fcb       $27                 * 13F2 27             '
                    fcb       $0D                 * 13F3 0D             .
                    fcb       $C6                 * 13F4 C6             F
                    fcb       $D0                 * 13F5 D0             P
                    fcb       $16                 * 13F6 16             .
                    fcb       $01                 * 13F7 01             .
                    fcb       $E6                 * 13F8 E6             f
                    fcb       $AE                 * 13F9 AE             .
                    fcb       $66                 * 13FA 66             f
                    fcb       $10                 * 13FB 10             .
                    fcb       $3F                 * 13FC 3F             ?
                    fcb       $8E                 * 13FD 8E             .
                    fcb       $16                 * 13FE 16             .
                    fcb       $01                 * 13FF 01             .
                    fcb       $E7                 * 1400 E7             g
                    fcb       $34                 * 1401 34             4
                    fcb       $40                 * 1402 40             @
                    fcb       $AE                 * 1403 AE             .
                    fcb       $68                 * 1404 68             h
                    fcb       $EE                 * 1405 EE             n
                    fcb       $6A                 * 1406 6A             j
                    fcb       $10                 * 1407 10             .
                    fcb       $3F                 * 1408 3F             ?
                    fcb       $8E                 * 1409 8E             .
                    fcb       $35                 * 140A 35             5
                    fcb       $40                 * 140B 40             @
                    fcb       $16                 * 140C 16             .
                    fcb       $01                 * 140D 01             .
                    fcb       $D9                 * 140E D9             Y
                    fcb       $AE                 * 140F AE             .
                    fcb       $62                 * 1410 62             b
                    fcb       $A6                 * 1411 A6             &
                    fcb       $65                 * 1412 65             e
                    fcb       $10                 * 1413 10             .
                    fcb       $3F                 * 1414 3F             ?
                    fcb       $84                 * 1415 84             .
                    fcb       $25                 * 1416 25             %
                    fcb       $03                 * 1417 03             .
                    fcb       $10                 * 1418 10             .
                    fcb       $3F                 * 1419 3F             ?
                    fcb       $8F                 * 141A 8F             .
                    fcb       $16                 * 141B 16             .
                    fcb       $01                 * 141C 01             .
                    fcb       $CA                 * 141D CA             J
L141E               ldx       $02,S               * 141E AE 62          .b
                    lda       $05,S               * 1420 A6 65          &e
                    os9       I$Open              * 1422 10 3F 84       .?.
                    lbcs      L15DF               * 1425 10 25 01 B6    .%.6
                    tfr       A,B                 * 1429 1F 89          ..
                    clra                          * 142B 4F             O
                    rts                           * 142C 39             9
L142D               lda       $03,S               * 142D A6 63          &c
                    os9       I$Close             * 142F 10 3F 8F       .?.
                    lbra      L15E8               * 1432 16 01 B3       ..3
                    fcb       $AE                 * 1435 AE             .
                    fcb       $62                 * 1436 62             b
                    fcb       $E6                 * 1437 E6             f
                    fcb       $65                 * 1438 65             e
                    fcb       $10                 * 1439 10             .
                    fcb       $3F                 * 143A 3F             ?
                    fcb       $85                 * 143B 85             .
                    fcb       $16                 * 143C 16             .
                    fcb       $01                 * 143D 01             .
                    fcb       $A9                 * 143E A9             )
L143F               ldx       $02,S               * 143F AE 62          .b
                    lda       $05,S               * 1441 A6 65          &e
                    tfr       A,B                 * 1443 1F 89          ..
                    andb      #36                 * 1445 C4 24          D$
                    orb       #11                 * 1447 CA 0B          J.
                    os9       I$Create            * 1449 10 3F 83       .?.
                    bcs       L1452               * 144C 25 04          %.
L144E               tfr       A,B                 * 144E 1F 89          ..
                    clra                          * 1450 4F             O
                    rts                           * 1451 39             9
L1452               cmpb      #218                * 1452 C1 DA          AZ
                    lbne      L15DF               * 1454 10 26 01 87    .&..
                    lda       $05,S               * 1458 A6 65          &e
                    bita      #128                * 145A 85 80          ..
                    lbne      L15DF               * 145C 10 26 01 7F    .&..
                    anda      #7                  * 1460 84 07          ..
                    ldx       $02,S               * 1462 AE 62          .b
                    os9       I$Open              * 1464 10 3F 84       .?.
                    lbcs      L15DF               * 1467 10 25 01 74    .%.t
                    pshs      U,A                 * 146B 34 42          4B
                    ldx       #0                  * 146D 8E 00 00       ...
                    leau      0,X                 * 1470 33 84          3.
                    ldb       #2                  * 1472 C6 02          F.
                    os9       I$SetStt            * 1474 10 3F 8E       .?.
                    puls      U,A                 * 1477 35 42          5B
                    bcc       L144E               * 1479 24 D3          $S
                    pshs      B                   * 147B 34 04          4.
                    os9       I$Close             * 147D 10 3F 8F       .?.
                    puls      B                   * 1480 35 04          5.
                    lbra      L15DF               * 1482 16 01 5A       ..Z
                    fcb       $AE                 * 1485 AE             .
                    fcb       $62                 * 1486 62             b
                    fcb       $10                 * 1487 10             .
                    fcb       $3F                 * 1488 3F             ?
                    fcb       $87                 * 1489 87             .
                    fcb       $16                 * 148A 16             .
                    fcb       $01                 * 148B 01             .
                    fcb       $5B                 * 148C 5B             [
                    fcb       $A6                 * 148D A6             &
                    fcb       $63                 * 148E 63             c
                    fcb       $10                 * 148F 10             .
                    fcb       $3F                 * 1490 3F             ?
                    fcb       $82                 * 1491 82             .
                    fcb       $10                 * 1492 10             .
                    fcb       $25                 * 1493 25             %
                    fcb       $01                 * 1494 01             .
                    fcb       $49                 * 1495 49             I
                    fcb       $1F                 * 1496 1F             .
                    fcb       $89                 * 1497 89             .
                    fcc       "O9"                * 1498 4F 39          O9
L149A               pshs      Y                   * 149A 34 20          4
                    ldx       $06,S               * 149C AE 66          .f
                    lda       $05,S               * 149E A6 65          &e
                    ldy       $08,S               * 14A0 10 AE 68       ..h
                    pshs      Y                   * 14A3 34 20          4
                    os9       I$Read              * 14A5 10 3F 89       .?.
                    bcc       L14B7               * 14A8 24 0D          $.
                    cmpb      #211                * 14AA C1 D3          AS
                    bne       L14B2               * 14AC 26 04          &.
                    clra                          * 14AE 4F             O
                    clrb                          * 14AF 5F             _
                    puls      PC,Y,X              * 14B0 35 B0          50
L14B2               puls      Y,X                 * 14B2 35 30          50
                    lbra      L15DF               * 14B4 16 01 28       ..(
L14B7               tfr       Y,D                 * 14B7 1F 20          .
                    puls      PC,Y,X              * 14B9 35 B0          50
L14BB               fcb       $34                 * 14BB 34             4
                    fcb       $20                 * 14BC 20
                    fcb       $A6                 * 14BD A6             &
                    fcb       $65                 * 14BE 65             e
                    fcb       $AE                 * 14BF AE             .
                    fcb       $66                 * 14C0 66             f
                    fcb       $10                 * 14C1 10             .
                    fcb       $AE                 * 14C2 AE             .
                    fcc       "h4 "               * 14C3 68 34 20       h4
                    fcb       $10                 * 14C6 10             .
                    fcb       $3F                 * 14C7 3F             ?
                    fcb       $8B                 * 14C8 8B             .
                    fcb       $20                 * 14C9 20
                    fcb       $DD                 * 14CA DD             ]
L14CB               pshs      Y                   * 14CB 34 20          4
                    ldy       $08,S               * 14CD 10 AE 68       ..h
                    beq       L14E0               * 14D0 27 0E          '.
                    lda       $05,S               * 14D2 A6 65          &e
                    ldx       $06,S               * 14D4 AE 66          .f
                    os9       I$Write             * 14D6 10 3F 8A       .?.
L14D9               bcc       L14E0               * 14D9 24 05          $.
                    puls      Y                   * 14DB 35 20          5
                    lbra      L15DF               * 14DD 16 00 FF       ...
L14E0               tfr       Y,D                 * 14E0 1F 20          .
                    puls      PC,Y                * 14E2 35 A0          5
L14E4               pshs      Y                   * 14E4 34 20          4
                    ldy       $08,S               * 14E6 10 AE 68       ..h
                    beq       L14E0               * 14E9 27 F5          'u
                    lda       $05,S               * 14EB A6 65          &e
                    ldx       $06,S               * 14ED AE 66          .f
                    os9       I$WritLn            * 14EF 10 3F 8C       .?.
                    bra       L14D9               * 14F2 20 E5           e
L14F4               pshs      U                   * 14F4 34 40          4@
                    ldd       $0A,S               * 14F6 EC 6A          lj
                    bne       L1502               * 14F8 26 08          &.
                    ldu       #0                  * 14FA CE 00 00       N..
                    ldx       #0                  * 14FD 8E 00 00       ...
                    bra       L1536               * 1500 20 34           4
L1502               cmpd      #1                  * 1502 10 83 00 01    ....
                    beq       L152D               * 1506 27 25          '%
                    cmpd      #2                  * 1508 10 83 00 02    ....
                    beq       L1522               * 150C 27 14          '.
                    ldb       #247                * 150E C6 F7          Fw
L1510               clra                          * 1510 4F             O
                    std       >$01AD,Y            * 1511 ED A9 01 AD    m).-
                    ldd       #-1                 * 1515 CC FF FF       L..
                    leax      >$01A1,Y            * 1518 30 A9 01 A1    0).!
                    std       0,X                 * 151C ED 84          m.
                    std       $02,X               * 151E ED 02          m.
                    puls      PC,U                * 1520 35 C0          5@
L1522               lda       $05,S               * 1522 A6 65          &e
                    ldb       #2                  * 1524 C6 02          F.
                    os9       I$GetStt            * 1526 10 3F 8D       .?.
                    bcs       L1510               * 1529 25 E5          %e
                    bra       L1536               * 152B 20 09           .
L152D               lda       $05,S               * 152D A6 65          &e
                    ldb       #5                  * 152F C6 05          F.
                    os9       I$GetStt            * 1531 10 3F 8D       .?.
                    bcs       L1510               * 1534 25 DA          %Z
L1536               tfr       U,D                 * 1536 1F 30          .0
                    addd      $08,S               * 1538 E3 68          ch
                    std       >$01A3,Y            * 153A ED A9 01 A3    m).#
                    tfr       D,U                 * 153E 1F 03          ..
                    tfr       X,D                 * 1540 1F 10          ..
                    adcb      $07,S               * 1542 E9 67          ig
                    adca      $06,S               * 1544 A9 66          )f
                    bmi       L1510               * 1546 2B C8          +H
                    tfr       D,X                 * 1548 1F 01          ..
                    std       >$01A1,Y            * 154A ED A9 01 A1    m).!
                    lda       $05,S               * 154E A6 65          &e
                    os9       I$Seek              * 1550 10 3F 88       .?.
                    bcs       L1510               * 1553 25 BB          %;
                    leax      >$01A1,Y            * 1555 30 A9 01 A1    0).!
                    puls      PC,U                * 1559 35 C0          5@
                    fcb       $EC                 * 155B EC             l
                    fcb       $A9                 * 155C A9             )
                    fcb       $01                 * 155D 01             .
                    fcb       $9F                 * 155E 9F             .
                    fcb       $34                 * 155F 34             4
                    fcb       $06                 * 1560 06             .
                    fcb       $EC                 * 1561 EC             l
                    fcb       $64                 * 1562 64             d
                    fcb       $10                 * 1563 10             .
                    fcb       $A3                 * 1564 A3             #
                    fcb       $A9                 * 1565 A9             )
                    fcb       $03                 * 1566 03             .
                    fcb       $A9                 * 1567 A9             )
                    fcb       $25                 * 1568 25             %
                    fcb       $25                 * 1569 25             %
                    fcb       $E3                 * 156A E3             c
                    fcb       $A9                 * 156B A9             )
                    fcb       $01                 * 156C 01             .
                    fcb       $9F                 * 156D 9F             .
                    fcb       $34                 * 156E 34             4
                    fcb       $20                 * 156F 20
                    fcb       $A3                 * 1570 A3             #
                    fcb       $E4                 * 1571 E4             d
                    fcb       $10                 * 1572 10             .
                    fcb       $3F                 * 1573 3F             ?
                    fcb       $07                 * 1574 07             .
                    fcb       $1F                 * 1575 1F             .
                    fcc       " 5 $"              * 1576 20 35 20 24     5 $
                    fcb       $06                 * 157A 06             .
                    fcb       $CC                 * 157B CC             L
                    fcb       $FF                 * 157C FF             .
                    fcb       $FF                 * 157D FF             .
                    fcc       "2b9"               * 157E 32 62 39       2b9
                    fcb       $ED                 * 1581 ED             m
                    fcb       $A9                 * 1582 A9             )
                    fcb       $01                 * 1583 01             .
                    fcb       $9F                 * 1584 9F             .
                    fcb       $E3                 * 1585 E3             c
                    fcb       $A9                 * 1586 A9             )
                    fcb       $03                 * 1587 03             .
                    fcb       $A9                 * 1588 A9             )
                    fcb       $A3                 * 1589 A3             #
                    fcb       $E4                 * 158A E4             d
                    fcb       $ED                 * 158B ED             m
                    fcb       $A9                 * 158C A9             )
                    fcb       $03                 * 158D 03             .
                    fcb       $A9                 * 158E A9             )
                    fcb       $32                 * 158F 32             2
                    fcb       $62                 * 1590 62             b
                    fcb       $EC                 * 1591 EC             l
                    fcb       $A9                 * 1592 A9             )
                    fcb       $03                 * 1593 03             .
                    fcb       $A9                 * 1594 A9             )
                    fcb       $34                 * 1595 34             4
                    fcb       $06                 * 1596 06             .
                    fcb       $A3                 * 1597 A3             #
                    fcb       $64                 * 1598 64             d
                    fcb       $ED                 * 1599 ED             m
                    fcb       $A9                 * 159A A9             )
                    fcb       $03                 * 159B 03             .
                    fcb       $A9                 * 159C A9             )
                    fcb       $EC                 * 159D EC             l
                    fcb       $A9                 * 159E A9             )
                    fcb       $01                 * 159F 01             .
                    fcb       $9F                 * 15A0 9F             .
                    fcb       $A3                 * 15A1 A3             #
                    fcb       $E1                 * 15A2 E1             a
                    fcb       $34                 * 15A3 34             4
                    fcb       $06                 * 15A4 06             .
                    fcb       $4F                 * 15A5 4F             O
                    fcb       $AE                 * 15A6 AE             .
                    fcb       $E4                 * 15A7 E4             d
                    fcb       $A7                 * 15A8 A7             '
                    fcb       $80                 * 15A9 80             .
                    fcb       $AC                 * 15AA AC             ,
                    fcb       $A9                 * 15AB A9             )
                    fcb       $01                 * 15AC 01             .
                    fcb       $9F                 * 15AD 9F             .
                    fcb       $25                 * 15AE 25             %
                    fcb       $F8                 * 15AF F8             x
                    fcb       $35                 * 15B0 35             5
                    fcb       $86                 * 15B1 86             .
L15B2               ldd       $02,S               * 15B2 EC 62          lb
                    addd      >$01A9,Y            * 15B4 E3 A9 01 A9    c).)
                    bcs       L15DB               * 15B8 25 21          %!
                    cmpd      >$01AB,Y            * 15BA 10 A3 A9 01 AB .#).+
                    bcc       L15DB               * 15BF 24 1A          $.
                    pshs      D                   * 15C1 34 06          4.
                    ldx       >$01A9,Y            * 15C3 AE A9 01 A9    .).)
                    clra                          * 15C7 4F             O
L15C8               cmpx      0,S                 * 15C8 AC E4          ,d
                    bcc       L15D0               * 15CA 24 04          $.
                    sta       ,X+                 * 15CC A7 80          '.
                    bra       L15C8               * 15CE 20 F8           x
L15D0               ldd       >$01A9,Y            * 15D0 EC A9 01 A9    l).)
                    puls      X                   * 15D4 35 10          5.
                    stx       >$01A9,Y            * 15D6 AF A9 01 A9    /).)
                    rts                           * 15DA 39             9
L15DB               ldd       #-1                 * 15DB CC FF FF       L..
                    rts                           * 15DE 39             9
L15DF               clra                          * 15DF 4F             O
                    std       >$01AD,Y            * 15E0 ED A9 01 AD    m).-
                    ldd       #-1                 * 15E4 CC FF FF       L..
                    rts                           * 15E7 39             9
L15E8               bcs       L15DF               * 15E8 25 F5          %u
                    clra                          * 15EA 4F             O
                    clrb                          * 15EB 5F             _
                    rts                           * 15EC 39             9
L15ED               lbsr      L15F8               * 15ED 17 00 08       ...
                    lbsr      L0F26               * 15F0 17 F9 33       .y3
L15F3               ldd       $02,S               * 15F3 EC 62          lb
                    os9       F$Exit              * 15F5 10 3F 06       .?.
L15F8               rts                           * 15F8 39             9
L15F9               fcb       $00                 * 15F9 00             .
                    fcb       $01                 * 15FA 01             .
                    fcb       $00                 * 15FB 00             .
                    fcb       $01                 * 15FC 01             .
                    fcb       $5E                 * 15FD 5E             ^
                    fcb       $27                 * 15FE 27             '
                    fcb       $10                 * 15FF 10             .
                    fcb       $03                 * 1600 03             .
                    fcb       $E8                 * 1601 E8             h
                    fcb       $00                 * 1602 00             .
                    fcb       $64                 * 1603 64             d
                    fcb       $00                 * 1604 00             .
                    fcb       $0A                 * 1605 0A             .
                    fcb       $00                 * 1606 00             .
                    fcb       $09                 * 1607 09             .
                    fcb       $6C                 * 1608 6C             l
                    fcb       $78                 * 1609 78             x
                    fcb       $00                 * 160A 00             .
                    fcb       $00                 * 160B 00             .
                    fcb       $00                 * 160C 00             .
                    fcb       $00                 * 160D 00             .
                    fcb       $00                 * 160E 00             .
                    fcb       $00                 * 160F 00             .
                    fcb       $00                 * 1610 00             .
                    fcb       $00                 * 1611 00             .
                    fcb       $01                 * 1612 01             .
                    fcb       $00                 * 1613 00             .
                    fcb       $00                 * 1614 00             .
                    fcb       $00                 * 1615 00             .
                    fcb       $00                 * 1616 00             .
                    fcb       $00                 * 1617 00             .
                    fcb       $00                 * 1618 00             .
                    fcb       $00                 * 1619 00             .
                    fcb       $00                 * 161A 00             .
                    fcb       $00                 * 161B 00             .
                    fcb       $00                 * 161C 00             .
                    fcb       $00                 * 161D 00             .
                    fcb       $00                 * 161E 00             .
                    fcb       $02                 * 161F 02             .
                    fcb       $00                 * 1620 00             .
                    fcb       $01                 * 1621 01             .
                    fcb       $00                 * 1622 00             .
                    fcb       $00                 * 1623 00             .
                    fcb       $00                 * 1624 00             .
                    fcb       $00                 * 1625 00             .
                    fcb       $00                 * 1626 00             .
                    fcb       $00                 * 1627 00             .
                    fcb       $00                 * 1628 00             .
                    fcb       $00                 * 1629 00             .
                    fcb       $00                 * 162A 00             .
                    fcb       $00                 * 162B 00             .
                    fcb       $42                 * 162C 42             B
                    fcb       $00                 * 162D 00             .
                    fcb       $02                 * 162E 02             .
                    fcb       $00                 * 162F 00             .
                    fcb       $00                 * 1630 00             .
                    fcb       $00                 * 1631 00             .
                    fcb       $00                 * 1632 00             .
                    fcb       $00                 * 1633 00             .
                    fcb       $00                 * 1634 00             .
                    fcb       $00                 * 1635 00             .
                    fcb       $00                 * 1636 00             .
                    fcb       $00                 * 1637 00             .
                    fcb       $00                 * 1638 00             .
                    fcb       $00                 * 1639 00             .
                    fcb       $00                 * 163A 00             .
                    fcb       $00                 * 163B 00             .
                    fcb       $00                 * 163C 00             .
                    fcb       $00                 * 163D 00             .
                    fcb       $00                 * 163E 00             .
                    fcb       $00                 * 163F 00             .
                    fcb       $00                 * 1640 00             .
                    fcb       $00                 * 1641 00             .
                    fcb       $00                 * 1642 00             .
                    fcb       $00                 * 1643 00             .
                    fcb       $00                 * 1644 00             .
                    fcb       $00                 * 1645 00             .
                    fcb       $00                 * 1646 00             .
                    fcb       $00                 * 1647 00             .
                    fcb       $00                 * 1648 00             .
                    fcb       $00                 * 1649 00             .
                    fcb       $00                 * 164A 00             .
                    fcb       $00                 * 164B 00             .
                    fcb       $00                 * 164C 00             .
                    fcb       $00                 * 164D 00             .
                    fcb       $00                 * 164E 00             .
                    fcb       $00                 * 164F 00             .
                    fcb       $00                 * 1650 00             .
                    fcb       $00                 * 1651 00             .
                    fcb       $00                 * 1652 00             .
                    fcb       $00                 * 1653 00             .
                    fcb       $00                 * 1654 00             .
                    fcb       $00                 * 1655 00             .
                    fcb       $00                 * 1656 00             .
                    fcb       $00                 * 1657 00             .
                    fcb       $00                 * 1658 00             .
                    fcb       $00                 * 1659 00             .
                    fcb       $00                 * 165A 00             .
                    fcb       $00                 * 165B 00             .
                    fcb       $00                 * 165C 00             .
                    fcb       $00                 * 165D 00             .
                    fcb       $00                 * 165E 00             .
                    fcb       $00                 * 165F 00             .
                    fcb       $00                 * 1660 00             .
                    fcb       $00                 * 1661 00             .
                    fcb       $00                 * 1662 00             .
                    fcb       $00                 * 1663 00             .
                    fcb       $00                 * 1664 00             .
                    fcb       $00                 * 1665 00             .
                    fcb       $00                 * 1666 00             .
                    fcb       $00                 * 1667 00             .
                    fcb       $00                 * 1668 00             .
                    fcb       $00                 * 1669 00             .
                    fcb       $00                 * 166A 00             .
                    fcb       $00                 * 166B 00             .
                    fcb       $00                 * 166C 00             .
                    fcb       $00                 * 166D 00             .
                    fcb       $00                 * 166E 00             .
                    fcb       $00                 * 166F 00             .
                    fcb       $00                 * 1670 00             .
                    fcb       $00                 * 1671 00             .
                    fcb       $00                 * 1672 00             .
                    fcb       $00                 * 1673 00             .
                    fcb       $00                 * 1674 00             .
                    fcb       $00                 * 1675 00             .
                    fcb       $00                 * 1676 00             .
                    fcb       $00                 * 1677 00             .
                    fcb       $00                 * 1678 00             .
                    fcb       $00                 * 1679 00             .
                    fcb       $00                 * 167A 00             .
                    fcb       $00                 * 167B 00             .
                    fcb       $00                 * 167C 00             .
                    fcb       $00                 * 167D 00             .
                    fcb       $00                 * 167E 00             .
                    fcb       $00                 * 167F 00             .
                    fcb       $00                 * 1680 00             .
                    fcb       $00                 * 1681 00             .
                    fcb       $00                 * 1682 00             .
                    fcb       $00                 * 1683 00             .
                    fcb       $00                 * 1684 00             .
                    fcb       $00                 * 1685 00             .
                    fcb       $00                 * 1686 00             .
                    fcb       $00                 * 1687 00             .
                    fcb       $00                 * 1688 00             .
                    fcb       $00                 * 1689 00             .
                    fcb       $00                 * 168A 00             .
                    fcb       $00                 * 168B 00             .
                    fcb       $00                 * 168C 00             .
                    fcb       $00                 * 168D 00             .
                    fcb       $00                 * 168E 00             .
                    fcb       $00                 * 168F 00             .
                    fcb       $00                 * 1690 00             .
                    fcb       $00                 * 1691 00             .
                    fcb       $00                 * 1692 00             .
                    fcb       $00                 * 1693 00             .
                    fcb       $00                 * 1694 00             .
                    fcb       $00                 * 1695 00             .
                    fcb       $00                 * 1696 00             .
                    fcb       $00                 * 1697 00             .
                    fcb       $00                 * 1698 00             .
                    fcb       $00                 * 1699 00             .
                    fcb       $00                 * 169A 00             .
                    fcb       $00                 * 169B 00             .
                    fcb       $00                 * 169C 00             .
                    fcb       $00                 * 169D 00             .
                    fcb       $00                 * 169E 00             .
                    fcb       $00                 * 169F 00             .
                    fcb       $00                 * 16A0 00             .
                    fcb       $00                 * 16A1 00             .
                    fcb       $00                 * 16A2 00             .
                    fcb       $00                 * 16A3 00             .
                    fcb       $00                 * 16A4 00             .
                    fcb       $00                 * 16A5 00             .
                    fcb       $00                 * 16A6 00             .
                    fcb       $00                 * 16A7 00             .
                    fcb       $00                 * 16A8 00             .
                    fcb       $00                 * 16A9 00             .
                    fcb       $00                 * 16AA 00             .
                    fcb       $00                 * 16AB 00             .
                    fcb       $00                 * 16AC 00             .
                    fcb       $00                 * 16AD 00             .
                    fcb       $00                 * 16AE 00             .
                    fcb       $00                 * 16AF 00             .
                    fcb       $00                 * 16B0 00             .
                    fcb       $00                 * 16B1 00             .
                    fcb       $00                 * 16B2 00             .
                    fcb       $00                 * 16B3 00             .
                    fcb       $00                 * 16B4 00             .
                    fcb       $00                 * 16B5 00             .
                    fcb       $00                 * 16B6 00             .
                    fcb       $00                 * 16B7 00             .
                    fcb       $00                 * 16B8 00             .
                    fcb       $00                 * 16B9 00             .
                    fcb       $00                 * 16BA 00             .
                    fcb       $00                 * 16BB 00             .
                    fcb       $00                 * 16BC 00             .
                    fcb       $00                 * 16BD 00             .
                    fcb       $00                 * 16BE 00             .
                    fcb       $00                 * 16BF 00             .
                    fcb       $00                 * 16C0 00             .
                    fcb       $00                 * 16C1 00             .
                    fcb       $00                 * 16C2 00             .
                    fcb       $00                 * 16C3 00             .
                    fcb       $00                 * 16C4 00             .
                    fcb       $00                 * 16C5 00             .
                    fcb       $00                 * 16C6 00             .
                    fcb       $00                 * 16C7 00             .
                    fcb       $00                 * 16C8 00             .
                    fcb       $00                 * 16C9 00             .
                    fcb       $00                 * 16CA 00             .
                    fcb       $00                 * 16CB 00             .
                    fcb       $00                 * 16CC 00             .
                    fcb       $00                 * 16CD 00             .
                    fcb       $00                 * 16CE 00             .
                    fcb       $00                 * 16CF 00             .
                    fcb       $00                 * 16D0 00             .
                    fcb       $00                 * 16D1 00             .
                    fcb       $00                 * 16D2 00             .
                    fcb       $00                 * 16D3 00             .
                    fcb       $00                 * 16D4 00             .
                    fcb       $00                 * 16D5 00             .
                    fcb       $00                 * 16D6 00             .
                    fcb       $00                 * 16D7 00             .
                    fcb       $00                 * 16D8 00             .
                    fcb       $00                 * 16D9 00             .
                    fcb       $00                 * 16DA 00             .
                    fcb       $00                 * 16DB 00             .
                    fcb       $01                 * 16DC 01             .
                    fcb       $01                 * 16DD 01             .
                    fcb       $01                 * 16DE 01             .
                    fcb       $01                 * 16DF 01             .
                    fcb       $01                 * 16E0 01             .
                    fcb       $01                 * 16E1 01             .
                    fcb       $01                 * 16E2 01             .
                    fcb       $01                 * 16E3 01             .
                    fcb       $01                 * 16E4 01             .
                    fcb       $11                 * 16E5 11             .
                    fcb       $11                 * 16E6 11             .
                    fcb       $01                 * 16E7 01             .
                    fcb       $11                 * 16E8 11             .
                    fcb       $11                 * 16E9 11             .
                    fcb       $01                 * 16EA 01             .
                    fcb       $01                 * 16EB 01             .
                    fcb       $01                 * 16EC 01             .
                    fcb       $01                 * 16ED 01             .
                    fcb       $01                 * 16EE 01             .
                    fcb       $01                 * 16EF 01             .
                    fcb       $01                 * 16F0 01             .
                    fcb       $01                 * 16F1 01             .
                    fcb       $01                 * 16F2 01             .
                    fcb       $01                 * 16F3 01             .
                    fcb       $01                 * 16F4 01             .
                    fcb       $01                 * 16F5 01             .
                    fcb       $01                 * 16F6 01             .
                    fcb       $01                 * 16F7 01             .
                    fcb       $01                 * 16F8 01             .
                    fcb       $01                 * 16F9 01             .
                    fcb       $01                 * 16FA 01             .
                    fcb       $01                 * 16FB 01             .
                    fcc       "0               HHHHHHHHHH       BBBBBB" * 16FC 30 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 48 48 48 48 48 48 48 48 48 48 20 20 20 20 20 20 20 42 42 42 42 42 42 0               HHHHHHHHHH       BBBBBB
                    fcb       $02                 * 1723 02             .
                    fcb       $02                 * 1724 02             .
                    fcb       $02                 * 1725 02             .
                    fcb       $02                 * 1726 02             .
                    fcb       $02                 * 1727 02             .
                    fcb       $02                 * 1728 02             .
                    fcb       $02                 * 1729 02             .
                    fcb       $02                 * 172A 02             .
                    fcb       $02                 * 172B 02             .
                    fcb       $02                 * 172C 02             .
                    fcb       $02                 * 172D 02             .
                    fcb       $02                 * 172E 02             .
                    fcb       $02                 * 172F 02             .
                    fcb       $02                 * 1730 02             .
                    fcb       $02                 * 1731 02             .
                    fcb       $02                 * 1732 02             .
                    fcb       $02                 * 1733 02             .
                    fcb       $02                 * 1734 02             .
                    fcb       $02                 * 1735 02             .
                    fcb       $02                 * 1736 02             .
                    fcc       "      DDDDDD"      * 1737 20 20 20 20 20 20 44 44 44 44 44 44       DDDDDD
                    fcb       $04                 * 1743 04             .
                    fcb       $04                 * 1744 04             .
                    fcb       $04                 * 1745 04             .
                    fcb       $04                 * 1746 04             .
                    fcb       $04                 * 1747 04             .
                    fcb       $04                 * 1748 04             .
                    fcb       $04                 * 1749 04             .
                    fcb       $04                 * 174A 04             .
                    fcb       $04                 * 174B 04             .
                    fcb       $04                 * 174C 04             .
                    fcb       $04                 * 174D 04             .
                    fcb       $04                 * 174E 04             .
                    fcb       $04                 * 174F 04             .
                    fcb       $04                 * 1750 04             .
                    fcb       $04                 * 1751 04             .
                    fcb       $04                 * 1752 04             .
                    fcb       $04                 * 1753 04             .
                    fcb       $04                 * 1754 04             .
                    fcb       $04                 * 1755 04             .
                    fcb       $04                 * 1756 04             .
                    fcc       "    "              * 1757 20 20 20 20
                    fcb       $01                 * 175B 01             .
                    fcb       $00                 * 175C 00             .
                    fcb       $00                 * 175D 00             .
                    fcb       $00                 * 175E 00             .
                    fcb       $01                 * 175F 01             .
                    fcb       $00                 * 1760 00             .
                    fcb       $09                 * 1761 09             .
                    fcc       "New_user"          * 1762 4E 65 77 5F 75 73 65 72 New_user
                    fcb       $00                 * 176A 00             .

                    emod
eom                 equ       *
                    end
