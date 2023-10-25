                    nam       Suser
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
U0008               rmb       1
U0009               rmb       1
U000A               rmb       1
U000B               rmb       2
U000D               rmb       338
U015F               rmb       2
U0161               rmb       58
U019B               rmb       1
U019C               rmb       3
U019F               rmb       2
U01A1               rmb       938
size                equ       .

name                fcs       /Suser/             * 000D 53 75 73 65 F2 Suser
                    fcb       $01                 * 0012 01             .
L0013               lda       ,Y+                 * 0013 A6 A0          &
                    sta       ,U+                 * 0015 A7 C0          '@
                    leax      -$01,X              * 0017 30 1F          0.
                    bne       L0013               * 0019 26 F8          &x
                    rts                           * 001B 39             9
start               pshs      Y                   * 001C 34 20          4
                    pshs      U                   * 001E 34 40          4@
                    clra                          * 0020 4F             O
                    clrb                          * 0021 5F             _
L0022               sta       ,U+                 * 0022 A7 C0          '@
                    decb                          * 0024 5A             Z
                    bne       L0022               * 0025 26 FB          &{
                    ldx       0,S                 * 0027 AE E4          .d
                    leau      0,X                 * 0029 33 84          3.
                    leax      >$01CB,X            * 002B 30 89 01 CB    0..K
                    pshs      X                   * 002F 34 10          4.
                    leay      >L0F36,PC           * 0031 31 8D 0F 01    1...
                    ldx       ,Y++                * 0035 AE A1          .!
                    beq       L003D               * 0037 27 04          '.
                    bsr       L0013               * 0039 8D D8          .X
                    ldu       $02,S               * 003B EE 62          nb
L003D               leau      >U0001,U            * 003D 33 C9 00 01    3I..
                    ldx       ,Y++                * 0041 AE A1          .!
                    beq       L0048               * 0043 27 03          '.
                    bsr       L0013               * 0045 8D CC          .L
                    clra                          * 0047 4F             O
L0048               cmpu      0,S                 * 0048 11 A3 E4       .#d
L004B               beq       L0051               * 004B 27 04          '.
                    sta       ,U+                 * 004D A7 C0          '@
                    bra       L0048               * 004F 20 F7           w
L0051               ldu       $02,S               * 0051 EE 62          nb
                    ldd       ,Y++                * 0053 EC A1          l!
                    beq       L005E               * 0055 27 07          '.
                    leax      >,PC                * 0057 30 8D FF A5    0..%
                    lbsr      L0161               * 005B 17 01 03       ...
L005E               ldd       ,Y++                * 005E EC A1          l!
                    beq       L0067               * 0060 27 05          '.
                    leax      U0000,U             * 0062 30 C4          0D
                    lbsr      L0161               * 0064 17 00 FA       ..z
L0067               leas      $04,S               * 0067 32 64          2d
                    puls      X                   * 0069 35 10          5.
                    stx       >U019F,U            * 006B AF C9 01 9F    /I..
                    sty       >U015F,U            * 006F 10 AF C9 01 5F ./I._
                    ldd       #1                  * 0074 CC 00 01       L..
                    std       >U019B,U            * 0077 ED C9 01 9B    mI..
                    leay      >U0161,U            * 007B 31 C9 01 61    1I.a
                    leax      0,S                 * 007F 30 E4          0d
                    lda       ,X+                 * 0081 A6 80          &.
L0083               ldb       >U019C,U            * 0083 E6 C9 01 9C    fI..
                    cmpb      #29                 * 0087 C1 1D          A.
                    beq       L00DF               * 0089 27 54          'T
L008B               cmpa      #13                 * 008B 81 0D          ..
                    beq       L00DF               * 008D 27 50          'P
                    cmpa      #32                 * 008F 81 20          .
                    beq       L0097               * 0091 27 04          '.
                    cmpa      #44                 * 0093 81 2C          .,
                    bne       L009B               * 0095 26 04          &.
L0097               lda       ,X+                 * 0097 A6 80          &.
                    bra       L008B               * 0099 20 F0           p
L009B               cmpa      #34                 * 009B 81 22          ."
                    beq       L00A3               * 009D 27 04          '.
                    cmpa      #39                 * 009F 81 27          .'
                    bne       L00C1               * 00A1 26 1E          &.
L00A3               stx       ,Y++                * 00A3 AF A1          /!
                    inc       >U019C,U            * 00A5 6C C9 01 9C    lI..
                    pshs      A                   * 00A9 34 02          4.
L00AB               lda       ,X+                 * 00AB A6 80          &.
                    cmpa      #13                 * 00AD 81 0D          ..
                    beq       L00B5               * 00AF 27 04          '.
                    cmpa      0,S                 * 00B1 A1 E4          !d
                    bne       L00AB               * 00B3 26 F6          &v
L00B5               puls      B                   * 00B5 35 04          5.
                    clr       -$01,X              * 00B7 6F 1F          o.
                    cmpa      #13                 * 00B9 81 0D          ..
                    beq       L00DF               * 00BB 27 22          '"
                    lda       ,X+                 * 00BD A6 80          &.
                    bra       L0083               * 00BF 20 C2           B
L00C1               leax      -$01,X              * 00C1 30 1F          0.
                    stx       ,Y++                * 00C3 AF A1          /!
                    leax      $01,X               * 00C5 30 01          0.
                    inc       >U019C,U            * 00C7 6C C9 01 9C    lI..
L00CB               cmpa      #13                 * 00CB 81 0D          ..
                    beq       L00DB               * 00CD 27 0C          '.
                    cmpa      #32                 * 00CF 81 20          .
                    beq       L00DB               * 00D1 27 08          '.
                    cmpa      #44                 * 00D3 81 2C          .,
                    beq       L00DB               * 00D5 27 04          '.
                    lda       ,X+                 * 00D7 A6 80          &.
                    bra       L00CB               * 00D9 20 F0           p
L00DB               clr       -$01,X              * 00DB 6F 1F          o.
                    bra       L0083               * 00DD 20 A4           $
L00DF               leax      >U015F,U            * 00DF 30 C9 01 5F    0I._
                    pshs      X                   * 00E3 34 10          4.
                    ldd       >U019B,U            * 00E5 EC C9 01 9B    lI..
                    pshs      D                   * 00E9 34 06          4.
                    leay      U0000,U             * 00EB 31 C4          1D
                    bsr       L00F9               * 00ED 8D 0A          ..
                    lbsr      L017B               * 00EF 17 00 89       ...
                    clr       ,-S                 * 00F2 6F E2          ob
                    clr       ,-S                 * 00F4 6F E2          ob
                    lbsr      L0F2A               * 00F6 17 0E 31       ..1
L00F9               leax      >$01CB,Y            * 00F9 30 A9 01 CB    0).K
                    stx       >$01A9,Y            * 00FD AF A9 01 A9    /).)
                    sts       >$019D,Y            * 0101 10 EF A9 01 9D .o)..
                    sts       >$01AB,Y            * 0106 10 EF A9 01 AB .o).+
                    ldd       #-126               * 010B CC FF 82       L..
L010E               leax      D,S                 * 010E 30 EB          0k
                    cmpx      >$01AB,Y            * 0110 AC A9 01 AB    ,).+
                    bcc       L0120               * 0114 24 0A          $.
                    cmpx      >$01A9,Y            * 0116 AC A9 01 A9    ,).)
                    bcs       L013A               * 011A 25 1E          %.
                    stx       >$01AB,Y            * 011C AF A9 01 AB    /).+
L0120               rts                           * 0120 39             9
L0121               fcc       "**** STACK OVERFLOW ****" * 0121 2A 2A 2A 2A 20 53 54 41 43 4B 20 4F 56 45 52 46 4C 4F 57 20 2A 2A 2A 2A **** STACK OVERFLOW ****
                    fcb       $0D                 * 0139 0D             .
L013A               leax      <L0121,PC           * 013A 30 8C E4       0.d
                    ldb       #207                * 013D C6 CF          FO
                    pshs      B                   * 013F 34 04          4.
                    lda       #2                  * 0141 86 02          ..
                    ldy       #100                * 0143 10 8E 00 64    ...d
                    os9       I$WritLn            * 0147 10 3F 8C       .?.
                    clr       ,-S                 * 014A 6F E2          ob
                    lbsr      L0F30               * 014C 17 0D E1       ..a
                    ldd       >$019D,Y            * 014F EC A9 01 9D    l)..
                    subd      >$01AB,Y            * 0153 A3 A9 01 AB    #).+
                    rts                           * 0157 39             9
                    fcb       $EC                 * 0158 EC             l
                    fcb       $A9                 * 0159 A9             )
                    fcb       $01                 * 015A 01             .
                    fcb       $AB                 * 015B AB             +
                    fcb       $A3                 * 015C A3             #
                    fcb       $A9                 * 015D A9             )
                    fcb       $01                 * 015E 01             .
                    fcb       $A9                 * 015F A9             )
                    fcb       $39                 * 0160 39             9
L0161               pshs      X                   * 0161 34 10          4.
                    leax      D,Y                 * 0163 30 AB          0+
                    leax      D,X                 * 0165 30 8B          0.
                    pshs      X                   * 0167 34 10          4.
L0169               ldd       ,Y++                * 0169 EC A1          l!
                    leax      D,U                 * 016B 30 CB          0K
                    ldd       0,X                 * 016D EC 84          l.
                    addd      $02,S               * 016F E3 62          cb
                    std       0,X                 * 0171 ED 84          m.
                    cmpy      0,S                 * 0173 10 AC E4       .,d
                    bne       L0169               * 0176 26 F1          &q
                    leas      $04,S               * 0178 32 64          2d
                    rts                           * 017A 39             9
L017B               pshs      U                   * 017B 34 40          4@
                    ldd       #-284               * 017D CC FE E4       L~d
                    lbsr      L010E               * 0180 17 FF 8B       ...
                    leas      >$FF34,S            * 0183 32 E9 FF 34    2i.4
                    clra                          * 0187 4F             O
                    clrb                          * 0188 5F             _
                    stb       0,S                 * 0189 E7 E4          gd
                    ldd       >$00D0,S            * 018B EC E9 00 D0    li.P
                    cmpd      #1                  * 018F 10 83 00 01    ....
                    bne       L01A4               * 0193 26 0F          &.
                    clra                          * 0195 4F             O
                    clrb                          * 0196 5F             _
                    pshs      D                   * 0197 34 06          4.
                    leax      >L0274,PC           * 0199 30 8D 00 D7    0..W
                    pshs      X                   * 019D 34 10          4.
                    lbsr      L0252               * 019F 17 00 B0       ..0
                    leas      $04,S               * 01A2 32 64          2d
L01A4               ldx       >$00D2,S            * 01A4 AE E9 00 D2    .i.R
                    ldd       $02,X               * 01A8 EC 02          l.
                    pshs      D                   * 01AA 34 06          4.
                    lbsr      L0B4F               * 01AC 17 09 A0       ..
                    leas      $02,S               * 01AF 32 62          2b
                    std       >$00CA,S            * 01B1 ED E9 00 CA    mi.J
                    pshs      D                   * 01B5 34 06          4.
                    lbsr      L0EF8               * 01B7 17 0D 3E       ..>
                    leas      $02,S               * 01BA 32 62          2b
                    cmpd      #-1                 * 01BC 10 83 FF FF    ....
                    bne       L01D3               * 01C0 26 11          &.
                    ldd       >$01AD,Y            * 01C2 EC A9 01 AD    l).-
                    pshs      D                   * 01C6 34 06          4.
                    leax      >L0298,PC           * 01C8 30 8D 00 CC    0..L
                    pshs      X                   * 01CC 34 10          4.
                    lbsr      L0252               * 01CE 17 00 81       ...
                    leas      $04,S               * 01D1 32 64          2d
L01D3               ldd       #2                  * 01D3 CC 00 02       L..
                    bra       L0207               * 01D6 20 2F           /
L01D8               ldd       >$00C8,S            * 01D8 EC E9 00 C8    li.H
                    aslb                          * 01DC 58             X
                    rola                          * 01DD 49             I
                    ldx       >$00D2,S            * 01DE AE E9 00 D2    .i.R
                    leax      D,X                 * 01E2 30 8B          0.
                    ldd       0,X                 * 01E4 EC 84          l.
                    pshs      D                   * 01E6 34 06          4.
                    leax      $02,S               * 01E8 30 62          0b
                    pshs      X                   * 01EA 34 10          4.
                    lbsr      L0AF1               * 01EC 17 09 02       ...
                    leas      $04,S               * 01EF 32 64          2d
                    leax      >L02C1,PC           * 01F1 30 8D 00 CC    0..L
                    pshs      X                   * 01F5 34 10          4.
                    leax      $02,S               * 01F7 30 62          0b
                    pshs      X                   * 01F9 34 10          4.
                    lbsr      L0AF1               * 01FB 17 08 F3       ..s
                    leas      $04,S               * 01FE 32 64          2d
                    ldd       >$00C8,S            * 0200 EC E9 00 C8    li.H
                    addd      #1                  * 0204 C3 00 01       C..
L0207               std       >$00C8,S            * 0207 ED E9 00 C8    mi.H
                    ldd       >$00C8,S            * 020B EC E9 00 C8    li.H
                    cmpd      >$00D0,S            * 020F 10 A3 E9 00 D0 .#i.P
                    blt       L01D8               * 0214 2D C2          -B
                    leax      >L02C3,PC           * 0216 30 8D 00 A9    0..)
                    pshs      X                   * 021A 34 10          4.
                    leax      $02,S               * 021C 30 62          0b
                    pshs      X                   * 021E 34 10          4.
                    lbsr      L0AF1               * 0220 17 08 CE       ..N
                    leas      $04,S               * 0223 32 64          2d
                    ldd       #3                  * 0225 CC 00 03       L..
                    pshs      D                   * 0228 34 06          4.
                    ldd       #1                  * 022A CC 00 01       L..
                    pshs      D                   * 022D 34 06          4.
                    ldd       #16                 * 022F CC 00 10       L..
                    pshs      D                   * 0232 34 06          4.
                    leax      $06,S               * 0234 30 66          0f
                    pshs      X                   * 0236 34 10          4.
                    leax      $08,S               * 0238 30 68          0h
                    pshs      X                   * 023A 34 10          4.
                    lbsr      L0AC8               * 023C 17 08 89       ...
                    std       0,S                 * 023F ED E4          md
                    leax      >L02C5,PC           * 0241 30 8D 00 80    0...
                    pshs      X                   * 0245 34 10          4.
                    lbsr      L0E9D               * 0247 17 0C 53       ..S
                    leas      $0C,S               * 024A 32 6C          2l
                    leas      >$00CC,S            * 024C 32 E9 00 CC    2i.L
                    puls      PC,U                * 0250 35 C0          5@
L0252               pshs      U                   * 0252 34 40          4@
                    ldd       #-72                * 0254 CC FF B8       L.8
                    lbsr      L010E               * 0257 17 FE B4       .~4
                    ldd       $04,S               * 025A EC 64          ld
                    pshs      D                   * 025C 34 06          4.
                    leax      >L02CC,PC           * 025E 30 8D 00 6A    0..j
                    pshs      X                   * 0262 34 10          4.
                    lbsr      L02D0               * 0264 17 00 69       ..i
                    leas      $04,S               * 0267 32 64          2d
                    ldd       $06,S               * 0269 EC 66          lf
                    pshs      D                   * 026B 34 06          4.
                    lbsr      L0F2A               * 026D 17 0C BA       ..:
                    leas      $02,S               * 0270 32 62          2b
                    puls      PC,U                * 0272 35 C0          5@
L0274               fcc       "Usage is: Suser <number> [progname]" * 0274 55 73 61 67 65 20 69 73 3A 20 53 75 73 65 72 20 3C 6E 75 6D 62 65 72 3E 20 5B 70 72 6F 67 6E 61 6D 65 5D Usage is: Suser <number> [progname]
                    fcb       $00                 * 0297 00             .
L0298               fcc       "Sorry, you cannot change the user number" * 0298 53 6F 72 72 79 2C 20 79 6F 75 20 63 61 6E 6E 6F 74 20 63 68 61 6E 67 65 20 74 68 65 20 75 73 65 72 20 6E 75 6D 62 65 72 Sorry, you cannot change the user number
                    fcb       $00                 * 02C0 00             .
L02C1               fcb       $20                 * 02C1 20
                    fcb       $00                 * 02C2 00             .
L02C3               fcb       $0D                 * 02C3 0D             .
                    fcb       $00                 * 02C4 00             .
L02C5               fcc       "Shell"             * 02C5 53 68 65 6C 6C Shell
                    fcb       $0D                 * 02CA 0D             .
                    fcb       $00                 * 02CB 00             .
L02CC               fcb       $25                 * 02CC 25             %
                    fcb       $73                 * 02CD 73             s
                    fcb       $0D                 * 02CE 0D             .
                    fcb       $00                 * 02CF 00             .
L02D0               pshs      U                   * 02D0 34 40          4@
                    leax      >$001B,Y            * 02D2 30 A9 00 1B    0)..
                    stx       >$01AF,Y            * 02D6 AF A9 01 AF    /)./
                    leax      $06,S               * 02DA 30 66          0f
                    pshs      X                   * 02DC 34 10          4.
                    ldd       $06,S               * 02DE EC 66          lf
                    bra       L02F0               * 02E0 20 0E           .
                    fcb       $34                 * 02E2 34             4
                    fcb       $40                 * 02E3 40             @
                    fcb       $EC                 * 02E4 EC             l
                    fcb       $64                 * 02E5 64             d
                    fcb       $ED                 * 02E6 ED             m
                    fcb       $A9                 * 02E7 A9             )
                    fcb       $01                 * 02E8 01             .
                    fcb       $AF                 * 02E9 AF             /
                    fcc       "0h4"               * 02EA 30 68 34       0h4
                    fcb       $10                 * 02ED 10             .
                    fcb       $EC                 * 02EE EC             l
                    fcb       $68                 * 02EF 68             h
L02F0               pshs      D                   * 02F0 34 06          4.
                    leax      >L07A8,PC           * 02F2 30 8D 04 B2    0..2
                    pshs      X                   * 02F6 34 10          4.
                    bsr       L0322               * 02F8 8D 28          .(
                    leas      $06,S               * 02FA 32 66          2f
                    puls      PC,U                * 02FC 35 C0          5@
                    fcb       $34                 * 02FE 34             4
                    fcb       $40                 * 02FF 40             @
                    fcb       $EC                 * 0300 EC             l
                    fcb       $64                 * 0301 64             d
                    fcb       $ED                 * 0302 ED             m
                    fcb       $A9                 * 0303 A9             )
                    fcb       $01                 * 0304 01             .
                    fcb       $AF                 * 0305 AF             /
                    fcc       "0h4"               * 0306 30 68 34       0h4
                    fcb       $10                 * 0309 10             .
                    fcb       $EC                 * 030A EC             l
                    fcb       $68                 * 030B 68             h
                    fcb       $34                 * 030C 34             4
                    fcb       $06                 * 030D 06             .
                    fcb       $30                 * 030E 30             0
                    fcb       $8D                 * 030F 8D             .
                    fcb       $04                 * 0310 04             .
                    fcb       $A9                 * 0311 A9             )
                    fcb       $34                 * 0312 34             4
                    fcb       $10                 * 0313 10             .
                    fcb       $8D                 * 0314 8D             .
                    fcb       $0C                 * 0315 0C             .
                    fcc       "2fO_"              * 0316 32 66 4F 5F    2fO_
                    fcb       $E7                 * 031A E7             g
                    fcb       $B9                 * 031B B9             9
                    fcb       $01                 * 031C 01             .
                    fcb       $AF                 * 031D AF             /
                    fcb       $EC                 * 031E EC             l
                    fcb       $64                 * 031F 64             d
                    fcb       $35                 * 0320 35             5
                    fcb       $C0                 * 0321 C0             @
L0322               pshs      U                   * 0322 34 40          4@
                    ldu       $06,S               * 0324 EE 66          nf
                    leas      -$0B,S              * 0326 32 75          2u
                    bra       L033A               * 0328 20 10           .
L032A               ldb       $08,S               * 032A E6 68          fh
                    lbeq      L056B               * 032C 10 27 02 3B    .'.;
                    ldb       $08,S               * 0330 E6 68          fh
                    sex                           * 0332 1D             .
                    pshs      D                   * 0333 34 06          4.
                    jsr       [<$11,S]            * 0335 AD F8 11       -x.
                    leas      $02,S               * 0338 32 62          2b
L033A               ldb       ,U+                 * 033A E6 C0          f@
                    stb       $08,S               * 033C E7 68          gh
                    cmpb      #37                 * 033E C1 25          A%
                    bne       L032A               * 0340 26 E8          &h
                    ldb       ,U+                 * 0342 E6 C0          f@
                    stb       $08,S               * 0344 E7 68          gh
                    clra                          * 0346 4F             O
                    clrb                          * 0347 5F             _
                    std       $02,S               * 0348 ED 62          mb
                    std       $06,S               * 034A ED 66          mf
                    ldb       $08,S               * 034C E6 68          fh
                    cmpb      #45                 * 034E C1 2D          A-
                    bne       L035F               * 0350 26 0D          &.
                    ldd       #1                  * 0352 CC 00 01       L..
                    std       >$01C5,Y            * 0355 ED A9 01 C5    m).E
                    ldb       ,U+                 * 0359 E6 C0          f@
                    stb       $08,S               * 035B E7 68          gh
                    bra       L0365               * 035D 20 06           .
L035F               clra                          * 035F 4F             O
                    clrb                          * 0360 5F             _
                    std       >$01C5,Y            * 0361 ED A9 01 C5    m).E
L0365               ldb       $08,S               * 0365 E6 68          fh
                    cmpb      #48                 * 0367 C1 30          A0
                    bne       L0370               * 0369 26 05          &.
                    ldd       #48                 * 036B CC 00 30       L.0
                    bra       L0373               * 036E 20 03           .
L0370               ldd       #32                 * 0370 CC 00 20       L.
L0373               std       >$01C7,Y            * 0373 ED A9 01 C7    m).G
                    bra       L0393               * 0377 20 1A           .
L0379               ldd       $06,S               * 0379 EC 66          lf
                    pshs      D                   * 037B 34 06          4.
                    ldd       #10                 * 037D CC 00 0A       L..
                    lbsr      L0BC2               * 0380 17 08 3F       ..?
                    pshs      D                   * 0383 34 06          4.
                    ldb       $0A,S               * 0385 E6 6A          fj
                    sex                           * 0387 1D             .
                    addd      #-48                * 0388 C3 FF D0       C.P
                    addd      ,S++                * 038B E3 E1          ca
                    std       $06,S               * 038D ED 66          mf
                    ldb       ,U+                 * 038F E6 C0          f@
                    stb       $08,S               * 0391 E7 68          gh
L0393               ldb       $08,S               * 0393 E6 68          fh
                    sex                           * 0395 1D             .
                    leax      >$00DF,Y            * 0396 30 A9 00 DF    0)._
                    leax      D,X                 * 039A 30 8B          0.
                    ldb       0,X                 * 039C E6 84          f.
                    clra                          * 039E 4F             O
                    andb      #8                  * 039F C4 08          D.
                    bne       L0379               * 03A1 26 D6          &V
                    ldb       $08,S               * 03A3 E6 68          fh
                    cmpb      #46                 * 03A5 C1 2E          A.
                    bne       L03DC               * 03A7 26 33          &3
                    ldd       #1                  * 03A9 CC 00 01       L..
                    std       $04,S               * 03AC ED 64          md
                    bra       L03C6               * 03AE 20 16           .
L03B0               ldd       $02,S               * 03B0 EC 62          lb
                    pshs      D                   * 03B2 34 06          4.
                    ldd       #10                 * 03B4 CC 00 0A       L..
                    lbsr      L0BC2               * 03B7 17 08 08       ...
                    pshs      D                   * 03BA 34 06          4.
                    ldb       $0A,S               * 03BC E6 6A          fj
                    sex                           * 03BE 1D             .
                    addd      #-48                * 03BF C3 FF D0       C.P
                    addd      ,S++                * 03C2 E3 E1          ca
                    std       $02,S               * 03C4 ED 62          mb
L03C6               ldb       ,U+                 * 03C6 E6 C0          f@
                    stb       $08,S               * 03C8 E7 68          gh
                    ldb       $08,S               * 03CA E6 68          fh
                    sex                           * 03CC 1D             .
                    leax      >$00DF,Y            * 03CD 30 A9 00 DF    0)._
                    leax      D,X                 * 03D1 30 8B          0.
                    ldb       0,X                 * 03D3 E6 84          f.
                    clra                          * 03D5 4F             O
                    andb      #8                  * 03D6 C4 08          D.
                    bne       L03B0               * 03D8 26 D6          &V
                    bra       L03E0               * 03DA 20 04           .
L03DC               clra                          * 03DC 4F             O
                    clrb                          * 03DD 5F             _
                    std       $04,S               * 03DE ED 64          md
L03E0               ldb       $08,S               * 03E0 E6 68          fh
                    sex                           * 03E2 1D             .
                    tfr       D,X                 * 03E3 1F 01          ..
                    lbra      L050E               * 03E5 16 01 26       ..&
L03E8               ldd       $06,S               * 03E8 EC 66          lf
                    pshs      D                   * 03EA 34 06          4.
                    ldx       <$0015,S            * 03EC AE E8 15       .h.
                    leax      $02,X               * 03EF 30 02          0.
                    stx       <$0015,S            * 03F1 AF E8 15       /h.
                    ldd       -$02,X              * 03F4 EC 1E          l.
                    pshs      D                   * 03F6 34 06          4.
                    lbsr      L056F               * 03F8 17 01 74       ..t
                    bra       L0410               * 03FB 20 13           .
L03FD               ldd       $06,S               * 03FD EC 66          lf
                    pshs      D                   * 03FF 34 06          4.
                    ldx       <$0015,S            * 0401 AE E8 15       .h.
                    leax      $02,X               * 0404 30 02          0.
                    stx       <$0015,S            * 0406 AF E8 15       /h.
                    ldd       -$02,X              * 0409 EC 1E          l.
                    pshs      D                   * 040B 34 06          4.
                    lbsr      L062C               * 040D 17 02 1C       ...
L0410               std       0,S                 * 0410 ED E4          md
                    lbra      L04F4               * 0412 16 00 DF       .._
L0415               ldd       $06,S               * 0415 EC 66          lf
                    pshs      D                   * 0417 34 06          4.
                    ldb       $0A,S               * 0419 E6 6A          fj
                    sex                           * 041B 1D             .
                    leax      >$00DF,Y            * 041C 30 A9 00 DF    0)._
                    leax      D,X                 * 0420 30 8B          0.
                    ldb       0,X                 * 0422 E6 84          f.
                    clra                          * 0424 4F             O
                    andb      #2                  * 0425 C4 02          D.
                    pshs      D                   * 0427 34 06          4.
                    ldx       <$0017,S            * 0429 AE E8 17       .h.
                    leax      $02,X               * 042C 30 02          0.
                    stx       <$0017,S            * 042E AF E8 17       /h.
                    ldd       -$02,X              * 0431 EC 1E          l.
                    pshs      D                   * 0433 34 06          4.
                    lbsr      L0674               * 0435 17 02 3C       ..<
                    lbra      L04F0               * 0438 16 00 B5       ..5
L043B               ldd       $06,S               * 043B EC 66          lf
                    pshs      D                   * 043D 34 06          4.
                    ldx       <$0015,S            * 043F AE E8 15       .h.
                    leax      $02,X               * 0442 30 02          0.
                    stx       <$0015,S            * 0444 AF E8 15       /h.
                    ldd       -$02,X              * 0447 EC 1E          l.
                    pshs      D                   * 0449 34 06          4.
                    leax      >$01B1,Y            * 044B 30 A9 01 B1    0).1
                    pshs      X                   * 044F 34 10          4.
                    lbsr      L05B3               * 0451 17 01 5F       .._
                    lbra      L04F0               * 0454 16 00 99       ...
L0457               ldd       $04,S               * 0457 EC 64          ld
                    bne       L0460               * 0459 26 05          &.
                    ldd       #6                  * 045B CC 00 06       L..
                    std       $02,S               * 045E ED 62          mb
L0460               ldd       $06,S               * 0460 EC 66          lf
                    pshs      D                   * 0462 34 06          4.
                    leax      <$0015,S            * 0464 30 E8 15       0h.
                    pshs      X                   * 0467 34 10          4.
                    ldd       $06,S               * 0469 EC 66          lf
                    pshs      D                   * 046B 34 06          4.
                    ldb       $0E,S               * 046D E6 6E          fn
                    sex                           * 046F 1D             .
                    pshs      D                   * 0470 34 06          4.
                    lbsr      L0ABD               * 0472 17 06 48       ..H
                    leas      $06,S               * 0475 32 66          2f
                    lbra      L04F2               * 0477 16 00 78       ..x
L047A               ldx       <$0013,S            * 047A AE E8 13       .h.
                    leax      $02,X               * 047D 30 02          0.
                    stx       <$0013,S            * 047F AF E8 13       /h.
                    ldd       -$02,X              * 0482 EC 1E          l.
                    lbra      L0504               * 0484 16 00 7D       ..}
L0487               ldx       <$0013,S            * 0487 AE E8 13       .h.
                    leax      $02,X               * 048A 30 02          0.
                    stx       <$0013,S            * 048C AF E8 13       /h.
                    ldd       -$02,X              * 048F EC 1E          l.
                    std       $09,S               * 0491 ED 69          mi
                    ldd       $04,S               * 0493 EC 64          ld
                    beq       L04CF               * 0495 27 38          '8
                    ldd       $09,S               * 0497 EC 69          li
                    std       $04,S               * 0499 ED 64          md
                    bra       L04A9               * 049B 20 0C           .
L049D               ldb       [<$09,S]            * 049D E6 F8 09       fx.
                    beq       L04B5               * 04A0 27 13          '.
                    ldd       $09,S               * 04A2 EC 69          li
                    addd      #1                  * 04A4 C3 00 01       C..
                    std       $09,S               * 04A7 ED 69          mi
L04A9               ldd       $02,S               * 04A9 EC 62          lb
                    addd      #-1                 * 04AB C3 FF FF       C..
                    std       $02,S               * 04AE ED 62          mb
                    subd      #-1                 * 04B0 83 FF FF       ...
                    bne       L049D               * 04B3 26 E8          &h
L04B5               ldd       $06,S               * 04B5 EC 66          lf
                    pshs      D                   * 04B7 34 06          4.
                    ldd       $0B,S               * 04B9 EC 6B          lk
                    subd      $06,S               * 04BB A3 66          #f
                    pshs      D                   * 04BD 34 06          4.
                    ldd       $08,S               * 04BF EC 68          lh
                    pshs      D                   * 04C1 34 06          4.
                    ldd       <$0015,S            * 04C3 EC E8 15       lh.
                    pshs      D                   * 04C6 34 06          4.
                    lbsr      L06DF               * 04C8 17 02 14       ...
                    leas      $08,S               * 04CB 32 68          2h
                    bra       L04FE               * 04CD 20 2F           /
L04CF               ldd       $06,S               * 04CF EC 66          lf
                    pshs      D                   * 04D1 34 06          4.
                    ldd       $0B,S               * 04D3 EC 6B          lk
                    bra       L04F2               * 04D5 20 1B           .
L04D7               ldb       ,U+                 * 04D7 E6 C0          f@
                    stb       $08,S               * 04D9 E7 68          gh
                    bra       L04DF               * 04DB 20 02           .
                    fcb       $32                 * 04DD 32             2
                    fcb       $15                 * 04DE 15             .
L04DF               ldd       $06,S               * 04DF EC 66          lf
                    pshs      D                   * 04E1 34 06          4.
                    leax      <$0015,S            * 04E3 30 E8 15       0h.
                    pshs      X                   * 04E6 34 10          4.
                    ldb       $0C,S               * 04E8 E6 6C          fl
                    sex                           * 04EA 1D             .
                    pshs      D                   * 04EB 34 06          4.
                    lbsr      L0A7F               * 04ED 17 05 8F       ...
L04F0               leas      $04,S               * 04F0 32 64          2d
L04F2               pshs      D                   * 04F2 34 06          4.
L04F4               ldd       <$0013,S            * 04F4 EC E8 13       lh.
                    pshs      D                   * 04F7 34 06          4.
                    lbsr      L0741               * 04F9 17 02 45       ..E
                    leas      $06,S               * 04FC 32 66          2f
L04FE               lbra      L033A               * 04FE 16 FE 39       .~9
L0501               ldb       $08,S               * 0501 E6 68          fh
                    sex                           * 0503 1D             .
L0504               pshs      D                   * 0504 34 06          4.
                    jsr       [<$11,S]            * 0506 AD F8 11       -x.
                    leas      $02,S               * 0509 32 62          2b
                    lbra      L033A               * 050B 16 FE 2C       .~,
L050E               cmpx      #100                * 050E 8C 00 64       ..d
                    lbeq      L03E8               * 0511 10 27 FE D3    .'~S
                    cmpx      #111                * 0515 8C 00 6F       ..o
                    lbeq      L03FD               * 0518 10 27 FE E1    .'~a
                    cmpx      #120                * 051C 8C 00 78       ..x
                    lbeq      L0415               * 051F 10 27 FE F2    .'~r
                    cmpx      #88                 * 0523 8C 00 58       ..X
                    lbeq      L0415               * 0526 10 27 FE EB    .'~k
                    cmpx      #117                * 052A 8C 00 75       ..u
                    lbeq      L043B               * 052D 10 27 FF 0A    .'..
                    cmpx      #102                * 0531 8C 00 66       ..f
                    lbeq      L0457               * 0534 10 27 FF 1F    .'..
                    cmpx      #101                * 0538 8C 00 65       ..e
                    lbeq      L0457               * 053B 10 27 FF 18    .'..
                    cmpx      #103                * 053F 8C 00 67       ..g
                    lbeq      L0457               * 0542 10 27 FF 11    .'..
                    cmpx      #69                 * 0546 8C 00 45       ..E
                    lbeq      L0457               * 0549 10 27 FF 0A    .'..
                    cmpx      #71                 * 054D 8C 00 47       ..G
                    lbeq      L0457               * 0550 10 27 FF 03    .'..
                    cmpx      #99                 * 0554 8C 00 63       ..c
                    lbeq      L047A               * 0557 10 27 FF 1F    .'..
                    cmpx      #115                * 055B 8C 00 73       ..s
                    lbeq      L0487               * 055E 10 27 FF 25    .'.%
                    cmpx      #108                * 0562 8C 00 6C       ..l
                    lbeq      L04D7               * 0565 10 27 FF 6E    .'.n
                    bra       L0501               * 0569 20 96           .
L056B               leas      $0B,S               * 056B 32 6B          2k
                    puls      PC,U                * 056D 35 C0          5@
L056F               pshs      U,D                 * 056F 34 46          4F
                    leax      >$01B1,Y            * 0571 30 A9 01 B1    0).1
                    stx       0,S                 * 0575 AF E4          /d
                    ldd       $06,S               * 0577 EC 66          lf
                    bge       L05A4               * 0579 2C 29          ,)
                    ldd       $06,S               * 057B EC 66          lf
                    nega                          * 057D 40             @
                    negb                          * 057E 50             P
                    sbca      #0                  * 057F 82 00          ..
                    std       $06,S               * 0581 ED 66          mf
                    bge       L0599               * 0583 2C 14          ,.
                    leax      >L07CD,PC           * 0585 30 8D 02 44    0..D
                    pshs      X                   * 0589 34 10          4.
                    leax      >$01B1,Y            * 058B 30 A9 01 B1    0).1
                    pshs      X                   * 058F 34 10          4.
                    lbsr      L0AD9               * 0591 17 05 45       ..E
                    leas      $04,S               * 0594 32 64          2d
                    lbra      L0670               * 0596 16 00 D7       ..W
L0599               ldd       #45                 * 0599 CC 00 2D       L.-
                    ldx       0,S                 * 059C AE E4          .d
                    leax      $01,X               * 059E 30 01          0.
                    stx       0,S                 * 05A0 AF E4          /d
                    stb       -$01,X              * 05A2 E7 1F          g.
L05A4               ldd       $06,S               * 05A4 EC 66          lf
                    pshs      D                   * 05A6 34 06          4.
                    ldd       $02,S               * 05A8 EC 62          lb
                    pshs      D                   * 05AA 34 06          4.
                    bsr       L05B3               * 05AC 8D 05          ..
                    leas      $04,S               * 05AE 32 64          2d
                    lbra      L066A               * 05B0 16 00 B7       ..7
L05B3               pshs      U,Y,X,D             * 05B3 34 76          4v
                    ldu       $0A,S               * 05B5 EE 6A          nj
                    clra                          * 05B7 4F             O
                    clrb                          * 05B8 5F             _
                    std       $02,S               * 05B9 ED 62          mb
                    clra                          * 05BB 4F             O
                    clrb                          * 05BC 5F             _
                    std       0,S                 * 05BD ED E4          md
                    bra       L05D0               * 05BF 20 0F           .
L05C1               ldd       0,S                 * 05C1 EC E4          ld
                    addd      #1                  * 05C3 C3 00 01       C..
                    std       0,S                 * 05C6 ED E4          md
                    ldd       $0C,S               * 05C8 EC 6C          ll
                    subd      >$0001,Y            * 05CA A3 A9 00 01    #)..
                    std       $0C,S               * 05CE ED 6C          ml
L05D0               ldd       $0C,S               * 05D0 EC 6C          ll
                    blt       L05C1               * 05D2 2D ED          -m
                    leax      >$0001,Y            * 05D4 30 A9 00 01    0)..
                    stx       $04,S               * 05D8 AF 64          /d
                    bra       L0612               * 05DA 20 36           6
L05DC               ldd       0,S                 * 05DC EC E4          ld
                    addd      #1                  * 05DE C3 00 01       C..
                    std       0,S                 * 05E1 ED E4          md
L05E3               ldd       $0C,S               * 05E3 EC 6C          ll
                    subd      [<$04,S]            * 05E5 A3 F8 04       #x.
                    std       $0C,S               * 05E8 ED 6C          ml
                    bge       L05DC               * 05EA 2C F0          ,p
                    ldd       $0C,S               * 05EC EC 6C          ll
                    addd      [<$04,S]            * 05EE E3 F8 04       cx.
                    std       $0C,S               * 05F1 ED 6C          ml
                    ldd       0,S                 * 05F3 EC E4          ld
                    beq       L05FC               * 05F5 27 05          '.
                    ldd       #1                  * 05F7 CC 00 01       L..
                    std       $02,S               * 05FA ED 62          mb
L05FC               ldd       $02,S               * 05FC EC 62          lb
                    beq       L0607               * 05FE 27 07          '.
                    ldd       0,S                 * 0600 EC E4          ld
                    addd      #48                 * 0602 C3 00 30       C.0
                    stb       ,U+                 * 0605 E7 C0          g@
L0607               clra                          * 0607 4F             O
                    clrb                          * 0608 5F             _
                    std       0,S                 * 0609 ED E4          md
                    ldd       $04,S               * 060B EC 64          ld
                    addd      #2                  * 060D C3 00 02       C..
                    std       $04,S               * 0610 ED 64          md
L0612               ldd       $04,S               * 0612 EC 64          ld
                    cmpd      >$0009,Y            * 0614 10 A3 A9 00 09 .#)..
                    bne       L05E3               * 0619 26 C8          &H
                    ldd       $0C,S               * 061B EC 6C          ll
                    addd      #48                 * 061D C3 00 30       C.0
                    stb       ,U+                 * 0620 E7 C0          g@
                    clra                          * 0622 4F             O
                    clrb                          * 0623 5F             _
                    stb       U0000,U             * 0624 E7 C4          gD
                    ldd       $0A,S               * 0626 EC 6A          lj
                    leas      $06,S               * 0628 32 66          2f
                    puls      PC,U                * 062A 35 C0          5@
L062C               pshs      U,D                 * 062C 34 46          4F
                    leax      >$01B1,Y            * 062E 30 A9 01 B1    0).1
                    stx       0,S                 * 0632 AF E4          /d
                    leau      >$01BB,Y            * 0634 33 A9 01 BB    3).;
L0638               ldd       $06,S               * 0638 EC 66          lf
                    clra                          * 063A 4F             O
                    andb      #7                  * 063B C4 07          D.
                    addd      #48                 * 063D C3 00 30       C.0
                    stb       ,U+                 * 0640 E7 C0          g@
                    ldd       $06,S               * 0642 EC 66          lf
                    lsra                          * 0644 44             D
                    rorb                          * 0645 56             V
                    lsra                          * 0646 44             D
                    rorb                          * 0647 56             V
                    lsra                          * 0648 44             D
                    rorb                          * 0649 56             V
                    std       $06,S               * 064A ED 66          mf
                    bne       L0638               * 064C 26 EA          &j
                    bra       L065A               * 064E 20 0A           .
L0650               ldb       U0000,U             * 0650 E6 C4          fD
                    ldx       0,S                 * 0652 AE E4          .d
                    leax      $01,X               * 0654 30 01          0.
                    stx       0,S                 * 0656 AF E4          /d
                    stb       -$01,X              * 0658 E7 1F          g.
L065A               leau      -$01,U              * 065A 33 5F          3_
                    pshs      U                   * 065C 34 40          4@
                    leax      >$01BB,Y            * 065E 30 A9 01 BB    0).;
                    cmpx      ,S++                * 0662 AC E1          ,a
                    bls       L0650               * 0664 23 EA          #j
                    clra                          * 0666 4F             O
                    clrb                          * 0667 5F             _
                    stb       [,S]                * 0668 E7 F4          gt
L066A               leax      >$01B1,Y            * 066A 30 A9 01 B1    0).1
                    tfr       X,D                 * 066E 1F 10          ..
L0670               leas      $02,S               * 0670 32 62          2b
                    puls      PC,U                * 0672 35 C0          5@
L0674               pshs      U,X,D               * 0674 34 56          4V
                    leax      >$01B1,Y            * 0676 30 A9 01 B1    0).1
                    stx       $02,S               * 067A AF 62          /b
                    leau      >$01BB,Y            * 067C 33 A9 01 BB    3).;
L0680               ldd       $08,S               * 0680 EC 68          lh
                    clra                          * 0682 4F             O
                    andb      #15                 * 0683 C4 0F          D.
                    std       0,S                 * 0685 ED E4          md
                    pshs      D                   * 0687 34 06          4.
                    ldd       $02,S               * 0689 EC 62          lb
                    cmpd      #9                  * 068B 10 83 00 09    ....
                    ble       L06A2               * 068F 2F 11          /.
                    ldd       $0C,S               * 0691 EC 6C          ll
                    beq       L069A               * 0693 27 05          '.
                    ldd       #65                 * 0695 CC 00 41       L.A
                    bra       L069D               * 0698 20 03           .
L069A               ldd       #97                 * 069A CC 00 61       L.a
L069D               addd      #-10                * 069D C3 FF F6       C.v
                    bra       L06A5               * 06A0 20 03           .
L06A2               ldd       #48                 * 06A2 CC 00 30       L.0
L06A5               addd      ,S++                * 06A5 E3 E1          ca
                    stb       ,U+                 * 06A7 E7 C0          g@
                    ldd       $08,S               * 06A9 EC 68          lh
                    lsra                          * 06AB 44             D
                    rorb                          * 06AC 56             V
                    lsra                          * 06AD 44             D
                    rorb                          * 06AE 56             V
                    lsra                          * 06AF 44             D
                    rorb                          * 06B0 56             V
                    lsra                          * 06B1 44             D
                    rorb                          * 06B2 56             V
                    anda      #15                 * 06B3 84 0F          ..
                    std       $08,S               * 06B5 ED 68          mh
                    bne       L0680               * 06B7 26 C7          &G
                    bra       L06C5               * 06B9 20 0A           .
L06BB               ldb       U0000,U             * 06BB E6 C4          fD
                    ldx       $02,S               * 06BD AE 62          .b
                    leax      $01,X               * 06BF 30 01          0.
                    stx       $02,S               * 06C1 AF 62          /b
                    stb       -$01,X              * 06C3 E7 1F          g.
L06C5               leau      -$01,U              * 06C5 33 5F          3_
                    pshs      U                   * 06C7 34 40          4@
                    leax      >$01BB,Y            * 06C9 30 A9 01 BB    0).;
                    cmpx      ,S++                * 06CD AC E1          ,a
                    bls       L06BB               * 06CF 23 EA          #j
                    clra                          * 06D1 4F             O
                    clrb                          * 06D2 5F             _
                    stb       [<$02,S]            * 06D3 E7 F8 02       gx.
                    leax      >$01B1,Y            * 06D6 30 A9 01 B1    0).1
                    tfr       X,D                 * 06DA 1F 10          ..
                    lbra      L07B7               * 06DC 16 00 D8       ..X
L06DF               pshs      U                   * 06DF 34 40          4@
                    ldu       $06,S               * 06E1 EE 66          nf
                    ldd       $0A,S               * 06E3 EC 6A          lj
                    subd      $08,S               * 06E5 A3 68          #h
                    std       $0A,S               * 06E7 ED 6A          mj
                    ldd       >$01C5,Y            * 06E9 EC A9 01 C5    l).E
                    bne       L0714               * 06ED 26 25          &%
                    bra       L06FC               * 06EF 20 0B           .
L06F1               ldd       >$01C7,Y            * 06F1 EC A9 01 C7    l).G
                    pshs      D                   * 06F5 34 06          4.
                    jsr       [<$06,S]            * 06F7 AD F8 06       -x.
                    leas      $02,S               * 06FA 32 62          2b
L06FC               ldd       $0A,S               * 06FC EC 6A          lj
                    addd      #-1                 * 06FE C3 FF FF       C..
                    std       $0A,S               * 0701 ED 6A          mj
                    subd      #-1                 * 0703 83 FF FF       ...
                    bgt       L06F1               * 0706 2E E9          .i
                    bra       L0714               * 0708 20 0A           .
L070A               ldb       ,U+                 * 070A E6 C0          f@
                    sex                           * 070C 1D             .
                    pshs      D                   * 070D 34 06          4.
                    jsr       [<$06,S]            * 070F AD F8 06       -x.
                    leas      $02,S               * 0712 32 62          2b
L0714               ldd       $08,S               * 0714 EC 68          lh
                    addd      #-1                 * 0716 C3 FF FF       C..
                    std       $08,S               * 0719 ED 68          mh
                    subd      #-1                 * 071B 83 FF FF       ...
                    bne       L070A               * 071E 26 EA          &j
                    ldd       >$01C5,Y            * 0720 EC A9 01 C5    l).E
                    beq       L073F               * 0724 27 19          '.
                    bra       L0733               * 0726 20 0B           .
L0728               ldd       >$01C7,Y            * 0728 EC A9 01 C7    l).G
                    pshs      D                   * 072C 34 06          4.
                    jsr       [<$06,S]            * 072E AD F8 06       -x.
                    leas      $02,S               * 0731 32 62          2b
L0733               ldd       $0A,S               * 0733 EC 6A          lj
                    addd      #-1                 * 0735 C3 FF FF       C..
                    std       $0A,S               * 0738 ED 6A          mj
                    subd      #-1                 * 073A 83 FF FF       ...
                    bgt       L0728               * 073D 2E E9          .i
L073F               puls      PC,U                * 073F 35 C0          5@
L0741               pshs      U                   * 0741 34 40          4@
                    ldu       $06,S               * 0743 EE 66          nf
                    ldd       $08,S               * 0745 EC 68          lh
                    pshs      D                   * 0747 34 06          4.
                    pshs      U                   * 0749 34 40          4@
                    lbsr      L0AC8               * 074B 17 03 7A       ..z
                    leas      $02,S               * 074E 32 62          2b
                    nega                          * 0750 40             @
                    negb                          * 0751 50             P
                    sbca      #0                  * 0752 82 00          ..
                    addd      ,S++                * 0754 E3 E1          ca
                    std       $08,S               * 0756 ED 68          mh
                    ldd       >$01C5,Y            * 0758 EC A9 01 C5    l).E
                    bne       L0783               * 075C 26 25          &%
                    bra       L076B               * 075E 20 0B           .
L0760               ldd       >$01C7,Y            * 0760 EC A9 01 C7    l).G
                    pshs      D                   * 0764 34 06          4.
                    jsr       [<$06,S]            * 0766 AD F8 06       -x.
                    leas      $02,S               * 0769 32 62          2b
L076B               ldd       $08,S               * 076B EC 68          lh
                    addd      #-1                 * 076D C3 FF FF       C..
                    std       $08,S               * 0770 ED 68          mh
                    subd      #-1                 * 0772 83 FF FF       ...
                    bgt       L0760               * 0775 2E E9          .i
                    bra       L0783               * 0777 20 0A           .
L0779               ldb       ,U+                 * 0779 E6 C0          f@
                    sex                           * 077B 1D             .
                    pshs      D                   * 077C 34 06          4.
                    jsr       [<$06,S]            * 077E AD F8 06       -x.
                    leas      $02,S               * 0781 32 62          2b
L0783               ldb       U0000,U             * 0783 E6 C4          fD
                    bne       L0779               * 0785 26 F2          &r
                    ldd       >$01C5,Y            * 0787 EC A9 01 C5    l).E
                    beq       L07A6               * 078B 27 19          '.
                    bra       L079A               * 078D 20 0B           .
L078F               ldd       >$01C7,Y            * 078F EC A9 01 C7    l).G
                    pshs      D                   * 0793 34 06          4.
                    jsr       [<$06,S]            * 0795 AD F8 06       -x.
                    leas      $02,S               * 0798 32 62          2b
L079A               ldd       $08,S               * 079A EC 68          lh
                    addd      #-1                 * 079C C3 FF FF       C..
                    std       $08,S               * 079F ED 68          mh
                    subd      #-1                 * 07A1 83 FF FF       ...
                    bgt       L078F               * 07A4 2E E9          .i
L07A6               puls      PC,U                * 07A6 35 C0          5@
L07A8               fcb       $34                 * 07A8 34             4
                    fcb       $40                 * 07A9 40             @
                    fcb       $EC                 * 07AA EC             l
                    fcb       $A9                 * 07AB A9             )
                    fcb       $01                 * 07AC 01             .
                    fcb       $AF                 * 07AD AF             /
                    fcb       $34                 * 07AE 34             4
                    fcb       $06                 * 07AF 06             .
                    fcb       $EC                 * 07B0 EC             l
                    fcb       $66                 * 07B1 66             f
                    fcb       $34                 * 07B2 34             4
                    fcb       $06                 * 07B3 06             .
                    fcb       $17                 * 07B4 17             .
                    fcb       $00                 * 07B5 00             .
                    fcb       $1D                 * 07B6 1D             .
L07B7               leas      $04,S               * 07B7 32 64          2d
                    puls      PC,U                * 07B9 35 C0          5@
                    fcb       $34                 * 07BB 34             4
                    fcb       $40                 * 07BC 40             @
                    fcb       $EC                 * 07BD EC             l
                    fcb       $64                 * 07BE 64             d
                    fcb       $AE                 * 07BF AE             .
                    fcb       $A9                 * 07C0 A9             )
                    fcb       $01                 * 07C1 01             .
                    fcb       $AF                 * 07C2 AF             /
                    fcb       $30                 * 07C3 30             0
                    fcb       $01                 * 07C4 01             .
                    fcb       $AF                 * 07C5 AF             /
                    fcb       $A9                 * 07C6 A9             )
                    fcb       $01                 * 07C7 01             .
                    fcb       $AF                 * 07C8 AF             /
                    fcb       $E7                 * 07C9 E7             g
                    fcb       $1F                 * 07CA 1F             .
                    fcb       $35                 * 07CB 35             5
                    fcb       $C0                 * 07CC C0             @
L07CD               fcc       "-32768"            * 07CD 2D 33 32 37 36 38 -32768
                    fcb       $00                 * 07D3 00             .
                    fcb       $34                 * 07D4 34             4
                    fcb       $40                 * 07D5 40             @
                    fcb       $EE                 * 07D6 EE             n
                    fcb       $66                 * 07D7 66             f
                    fcb       $EC                 * 07D8 EC             l
                    fcb       $46                 * 07D9 46             F
                    fcb       $84                 * 07DA 84             .
                    fcb       $80                 * 07DB 80             .
                    fcb       $C4                 * 07DC C4             D
                    fcb       $22                 * 07DD 22             "
                    fcb       $10                 * 07DE 10             .
                    fcb       $83                 * 07DF 83             .
                    fcb       $80                 * 07E0 80             .
                    fcb       $02                 * 07E1 02             .
                    fcb       $27                 * 07E2 27             '
                    fcb       $14                 * 07E3 14             .
                    fcb       $EC                 * 07E4 EC             l
                    fcb       $46                 * 07E5 46             F
                    fcb       $4F                 * 07E6 4F             O
                    fcb       $C4                 * 07E7 C4             D
                    fcb       $22                 * 07E8 22             "
                    fcb       $10                 * 07E9 10             .
                    fcb       $83                 * 07EA 83             .
                    fcb       $00                 * 07EB 00             .
                    fcb       $02                 * 07EC 02             .
                    fcb       $10                 * 07ED 10             .
                    fcb       $26                 * 07EE 26             &
                    fcb       $01                 * 07EF 01             .
                    fcb       $1F                 * 07F0 1F             .
                    fcb       $34                 * 07F1 34             4
                    fcb       $40                 * 07F2 40             @
                    fcb       $17                 * 07F3 17             .
                    fcb       $01                 * 07F4 01             .
                    fcb       $F9                 * 07F5 F9             y
                    fcb       $32                 * 07F6 32             2
                    fcb       $62                 * 07F7 62             b
                    fcb       $EC                 * 07F8 EC             l
                    fcb       $46                 * 07F9 46             F
                    fcb       $4F                 * 07FA 4F             O
                    fcb       $C4                 * 07FB C4             D
                    fcb       $04                 * 07FC 04             .
                    fcb       $27                 * 07FD 27             '
                    fcb       $35                 * 07FE 35             5
                    fcb       $CC                 * 07FF CC             L
                    fcb       $00                 * 0800 00             .
                    fcb       $01                 * 0801 01             .
                    fcb       $34                 * 0802 34             4
                    fcb       $06                 * 0803 06             .
                    fcc       "0g4"               * 0804 30 67 34       0g4
                    fcb       $10                 * 0807 10             .
                    fcb       $EC                 * 0808 EC             l
                    fcb       $48                 * 0809 48             H
                    fcb       $34                 * 080A 34             4
                    fcb       $06                 * 080B 06             .
                    fcb       $EC                 * 080C EC             l
                    fcb       $46                 * 080D 46             F
                    fcb       $4F                 * 080E 4F             O
                    fcb       $C4                 * 080F C4             D
                    fcb       $40                 * 0810 40             @
                    fcb       $27                 * 0811 27             '
                    fcb       $06                 * 0812 06             .
                    fcb       $30                 * 0813 30             0
                    fcb       $8D                 * 0814 8D             .
                    fcb       $05                 * 0815 05             .
                    fcb       $62                 * 0816 62             b
                    fcb       $20                 * 0817 20
                    fcb       $04                 * 0818 04             .
                    fcb       $30                 * 0819 30             0
                    fcb       $8D                 * 081A 8D             .
                    fcb       $05                 * 081B 05             .
                    fcb       $43                 * 081C 43             C
                    fcb       $1F                 * 081D 1F             .
                    fcb       $10                 * 081E 10             .
                    fcb       $1F                 * 081F 1F             .
                    fcb       $01                 * 0820 01             .
                    fcb       $AD                 * 0821 AD             -
                    fcb       $84                 * 0822 84             .
                    fcb       $32                 * 0823 32             2
                    fcb       $66                 * 0824 66             f
                    fcb       $10                 * 0825 10             .
                    fcb       $83                 * 0826 83             .
                    fcb       $FF                 * 0827 FF             .
                    fcb       $FF                 * 0828 FF             .
                    fcb       $26                 * 0829 26             &
                    fcb       $4A                 * 082A 4A             J
                    fcb       $EC                 * 082B EC             l
                    fcb       $46                 * 082C 46             F
                    fcb       $CA                 * 082D CA             J
                    fcb       $20                 * 082E 20
                    fcb       $ED                 * 082F ED             m
                    fcb       $46                 * 0830 46             F
                    fcb       $16                 * 0831 16             .
                    fcb       $00                 * 0832 00             .
                    fcb       $DC                 * 0833 DC             \
                    fcb       $EC                 * 0834 EC             l
                    fcb       $46                 * 0835 46             F
                    fcb       $84                 * 0836 84             .
                    fcb       $01                 * 0837 01             .
                    fcb       $5F                 * 0838 5F             _
                    fcb       $ED                 * 0839 ED             m
                    fcb       $7E                 * 083A 7E             ~
                    fcb       $26                 * 083B 26             &
                    fcb       $07                 * 083C 07             .
                    fcb       $34                 * 083D 34             4
                    fcb       $40                 * 083E 40             @
                    fcb       $17                 * 083F 17             .
                    fcb       $00                 * 0840 00             .
                    fcb       $EB                 * 0841 EB             k
                    fcb       $32                 * 0842 32             2
                    fcb       $62                 * 0843 62             b
                    fcb       $EC                 * 0844 EC             l
                    fcb       $C4                 * 0845 C4             D
                    fcb       $C3                 * 0846 C3             C
                    fcb       $00                 * 0847 00             .
                    fcb       $01                 * 0848 01             .
                    fcb       $ED                 * 0849 ED             m
                    fcb       $C4                 * 084A C4             D
                    fcb       $83                 * 084B 83             .
                    fcb       $00                 * 084C 00             .
                    fcb       $01                 * 084D 01             .
                    fcb       $1F                 * 084E 1F             .
                    fcb       $01                 * 084F 01             .
                    fcb       $EC                 * 0850 EC             l
                    fcb       $64                 * 0851 64             d
                    fcb       $E7                 * 0852 E7             g
                    fcb       $84                 * 0853 84             .
                    fcb       $EC                 * 0854 EC             l
                    fcb       $C4                 * 0855 C4             D
                    fcb       $10                 * 0856 10             .
                    fcb       $A3                 * 0857 A3             #
                    fcb       $44                 * 0858 44             D
                    fcb       $24                 * 0859 24             $
                    fcb       $0F                 * 085A 0F             .
                    fcb       $EC                 * 085B EC             l
                    fcb       $46                 * 085C 46             F
                    fcb       $4F                 * 085D 4F             O
                    fcb       $C4                 * 085E C4             D
                    fcb       $40                 * 085F 40             @
                    fcb       $27                 * 0860 27             '
                    fcb       $13                 * 0861 13             .
                    fcb       $EC                 * 0862 EC             l
                    fcb       $64                 * 0863 64             d
                    fcb       $10                 * 0864 10             .
                    fcb       $83                 * 0865 83             .
                    fcb       $00                 * 0866 00             .
                    fcb       $0D                 * 0867 0D             .
                    fcb       $26                 * 0868 26             &
                    fcb       $0B                 * 0869 0B             .
                    fcb       $34                 * 086A 34             4
                    fcb       $40                 * 086B 40             @
                    fcb       $17                 * 086C 17             .
                    fcb       $00                 * 086D 00             .
                    fcb       $BE                 * 086E BE             >
                    fcb       $ED                 * 086F ED             m
                    fcb       $E1                 * 0870 E1             a
                    fcb       $10                 * 0871 10             .
                    fcb       $26                 * 0872 26             &
                    fcb       $00                 * 0873 00             .
                    fcb       $9B                 * 0874 9B             .
                    fcb       $EC                 * 0875 EC             l
                    fcb       $64                 * 0876 64             d
                    fcb       $35                 * 0877 35             5
                    fcb       $C0                 * 0878 C0             @
                    fcb       $34                 * 0879 34             4
                    fcb       $40                 * 087A 40             @
                    fcb       $EE                 * 087B EE             n
                    fcb       $64                 * 087C 64             d
                    fcb       $EC                 * 087D EC             l
                    fcb       $66                 * 087E 66             f
                    fcb       $34                 * 087F 34             4
                    fcb       $06                 * 0880 06             .
                    fcb       $34                 * 0881 34             4
                    fcb       $40                 * 0882 40             @
                    fcb       $CC                 * 0883 CC             L
                    fcb       $00                 * 0884 00             .
                    fcb       $08                 * 0885 08             .
                    fcb       $17                 * 0886 17             .
                    fcb       $03                 * 0887 03             .
                    fcb       $98                 * 0888 98             .
                    fcb       $34                 * 0889 34             4
                    fcb       $06                 * 088A 06             .
                    fcb       $17                 * 088B 17             .
                    fcb       $FF                 * 088C FF             .
                    fcc       "F2d"               * 088D 46 32 64       F2d
                    fcb       $EC                 * 0890 EC             l
                    fcb       $66                 * 0891 66             f
                    fcb       $34                 * 0892 34             4
                    fcb       $06                 * 0893 06             .
                    fcb       $34                 * 0894 34             4
                    fcb       $40                 * 0895 40             @
                    fcb       $17                 * 0896 17             .
                    fcb       $FF                 * 0897 FF             .
                    fcb       $3B                 * 0898 3B             ;
                    fcb       $16                 * 0899 16             .
                    fcb       $01                 * 089A 01             .
                    fcc       "K"                 * 089B 4B             K
L089C               pshs      U,D                 * 089C 34 46          4F
                    leau      >$000E,Y            * 089E 33 A9 00 0E    3)..
                    clra                          * 08A2 4F             O
                    clrb                          * 08A3 5F             _
                    std       0,S                 * 08A4 ED E4          md
                    bra       L08B2               * 08A6 20 0A           .
L08A8               tfr       U,D                 * 08A8 1F 30          .0
                    leau      U000D,U             * 08AA 33 4D          3M
                    pshs      D                   * 08AC 34 06          4.
                    bsr       L08C5               * 08AE 8D 15          ..
                    leas      $02,S               * 08B0 32 62          2b
L08B2               ldd       0,S                 * 08B2 EC E4          ld
                    addd      #1                  * 08B4 C3 00 01       C..
                    std       0,S                 * 08B7 ED E4          md
                    subd      #1                  * 08B9 83 00 01       ...
                    cmpd      #16                 * 08BC 10 83 00 10    ....
                    blt       L08A8               * 08C0 2D E6          -f
                    lbra      L0929               * 08C2 16 00 64       ..d
L08C5               pshs      U                   * 08C5 34 40          4@
                    ldu       $04,S               * 08C7 EE 64          nd
                    leas      -$02,S              * 08C9 32 7E          2~
                    cmpu      #0                  * 08CB 11 83 00 00    ....
                    beq       L08D5               * 08CF 27 04          '.
                    ldd       U0006,U             * 08D1 EC 46          lF
                    bne       L08DB               * 08D3 26 06          &.
L08D5               ldd       #-1                 * 08D5 CC FF FF       L..
                    lbra      L0929               * 08D8 16 00 4E       ..N
L08DB               ldd       U0006,U             * 08DB EC 46          lF
                    clra                          * 08DD 4F             O
                    andb      #2                  * 08DE C4 02          D.
                    beq       L08EA               * 08E0 27 08          '.
                    pshs      U                   * 08E2 34 40          4@
                    bsr       L08FF               * 08E4 8D 19          ..
                    leas      $02,S               * 08E6 32 62          2b
                    bra       L08EC               * 08E8 20 02           .
L08EA               clra                          * 08EA 4F             O
                    clrb                          * 08EB 5F             _
L08EC               std       0,S                 * 08EC ED E4          md
                    ldd       U0008,U             * 08EE EC 48          lH
                    pshs      D                   * 08F0 34 06          4.
                    lbsr      L0CC2               * 08F2 17 03 CD       ..M
                    leas      $02,S               * 08F5 32 62          2b
                    clra                          * 08F7 4F             O
                    clrb                          * 08F8 5F             _
                    std       U0006,U             * 08F9 ED 46          mF
                    ldd       0,S                 * 08FB EC E4          ld
                    bra       L0929               * 08FD 20 2A           *
L08FF               pshs      U                   * 08FF 34 40          4@
                    ldu       $04,S               * 0901 EE 64          nd
                    beq       L0910               * 0903 27 0B          '.
                    ldd       U0006,U             * 0905 EC 46          lF
                    clra                          * 0907 4F             O
                    andb      #34                 * 0908 C4 22          D"
                    cmpd      #2                  * 090A 10 83 00 02    ....
                    beq       L0915               * 090E 27 05          '.
L0910               ldd       #-1                 * 0910 CC FF FF       L..
                    puls      PC,U                * 0913 35 C0          5@
L0915               ldd       U0006,U             * 0915 EC 46          lF
                    anda      #128                * 0917 84 80          ..
                    clrb                          * 0919 5F             _
                    std       -$02,S              * 091A ED 7E          m~
                    bne       L0925               * 091C 26 07          &.
                    pshs      U                   * 091E 34 40          4@
                    lbsr      L09EF               * 0920 17 00 CC       ..L
                    leas      $02,S               * 0923 32 62          2b
L0925               pshs      U                   * 0925 34 40          4@
                    bsr       L092D               * 0927 8D 04          ..
L0929               leas      $02,S               * 0929 32 62          2b
                    puls      PC,U                * 092B 35 C0          5@
L092D               pshs      U                   * 092D 34 40          4@
                    ldu       $04,S               * 092F EE 64          nd
                    leas      -$04,S              * 0931 32 7C          2|
                    ldd       U0006,U             * 0933 EC 46          lF
                    anda      #1                  * 0935 84 01          ..
                    clrb                          * 0937 5F             _
                    std       -$02,S              * 0938 ED 7E          m~
                    bne       L095F               * 093A 26 23          &#
                    ldd       U0000,U             * 093C EC C4          lD
                    cmpd      U0004,U             * 093E 10 A3 44       .#D
                    beq       L095F               * 0941 27 1C          '.
                    clra                          * 0943 4F             O
                    clrb                          * 0944 5F             _
                    pshs      D                   * 0945 34 06          4.
                    pshs      U                   * 0947 34 40          4@
                    lbsr      L09EB               * 0949 17 00 9F       ...
                    leas      $02,S               * 094C 32 62          2b
                    ldd       $02,X               * 094E EC 02          l.
                    pshs      D                   * 0950 34 06          4.
                    ldd       0,X                 * 0952 EC 84          l.
                    pshs      D                   * 0954 34 06          4.
                    ldd       U0008,U             * 0956 EC 48          lH
                    pshs      D                   * 0958 34 06          4.
                    lbsr      L0D89               * 095A 17 04 2C       ..,
                    leas      $08,S               * 095D 32 68          2h
L095F               ldd       U0000,U             * 095F EC C4          lD
                    subd      U0002,U             * 0961 A3 42          #B
                    std       $02,S               * 0963 ED 62          mb
                    lbeq      L09D7               * 0965 10 27 00 6E    .'.n
                    ldd       U0006,U             * 0969 EC 46          lF
                    anda      #1                  * 096B 84 01          ..
                    clrb                          * 096D 5F             _
                    std       -$02,S              * 096E ED 7E          m~
                    lbeq      L09D7               * 0970 10 27 00 63    .'.c
                    ldd       U0006,U             * 0974 EC 46          lF
                    clra                          * 0976 4F             O
                    andb      #64                 * 0977 C4 40          D@
                    beq       L09AE               * 0979 27 33          '3
                    ldd       U0002,U             * 097B EC 42          lB
                    bra       L09A6               * 097D 20 27           '
L097F               ldd       $02,S               * 097F EC 62          lb
                    pshs      D                   * 0981 34 06          4.
                    ldd       U0000,U             * 0983 EC C4          lD
                    pshs      D                   * 0985 34 06          4.
                    ldd       U0008,U             * 0987 EC 48          lH
                    pshs      D                   * 0989 34 06          4.
                    lbsr      L0D79               * 098B 17 03 EB       ..k
                    leas      $06,S               * 098E 32 66          2f
                    std       0,S                 * 0990 ED E4          md
                    cmpd      #-1                 * 0992 10 83 FF FF    ....
                    bne       L099C               * 0996 26 04          &.
                    leax      $04,S               * 0998 30 64          0d
                    bra       L09C6               * 099A 20 2A           *
L099C               ldd       $02,S               * 099C EC 62          lb
                    subd      0,S                 * 099E A3 E4          #d
                    std       $02,S               * 09A0 ED 62          mb
                    ldd       U0000,U             * 09A2 EC C4          lD
                    addd      0,S                 * 09A4 E3 E4          cd
L09A6               std       U0000,U             * 09A6 ED C4          mD
                    ldd       $02,S               * 09A8 EC 62          lb
                    bne       L097F               * 09AA 26 D3          &S
                    bra       L09D7               * 09AC 20 29           )
L09AE               ldd       $02,S               * 09AE EC 62          lb
                    pshs      D                   * 09B0 34 06          4.
                    ldd       U0002,U             * 09B2 EC 42          lB
                    pshs      D                   * 09B4 34 06          4.
                    ldd       U0008,U             * 09B6 EC 48          lH
                    pshs      D                   * 09B8 34 06          4.
                    lbsr      L0D60               * 09BA 17 03 A3       ..#
                    leas      $06,S               * 09BD 32 66          2f
                    cmpd      $02,S               * 09BF 10 A3 62       .#b
                    beq       L09D7               * 09C2 27 13          '.
                    bra       L09C8               * 09C4 20 02           .
L09C6               leas      -$04,X              * 09C6 32 1C          2.
L09C8               ldd       U0006,U             * 09C8 EC 46          lF
                    orb       #32                 * 09CA CA 20          J
                    std       U0006,U             * 09CC ED 46          mF
                    ldd       U0004,U             * 09CE EC 44          lD
                    std       U0000,U             * 09D0 ED C4          mD
                    ldd       #-1                 * 09D2 CC FF FF       L..
                    bra       L09E7               * 09D5 20 10           .
L09D7               ldd       U0006,U             * 09D7 EC 46          lF
                    ora       #1                  * 09D9 8A 01          ..
                    std       U0006,U             * 09DB ED 46          mF
                    ldd       U0002,U             * 09DD EC 42          lB
                    std       U0000,U             * 09DF ED C4          mD
                    addd      U000B,U             * 09E1 E3 4B          cK
                    std       U0004,U             * 09E3 ED 44          mD
                    clra                          * 09E5 4F             O
                    clrb                          * 09E6 5F             _
L09E7               leas      $04,S               * 09E7 32 64          2d
                    puls      PC,U                * 09E9 35 C0          5@
L09EB               pshs      U                   * 09EB 34 40          4@
                    puls      PC,U                * 09ED 35 C0          5@
L09EF               pshs      U                   * 09EF 34 40          4@
                    ldu       $04,S               * 09F1 EE 64          nd
                    ldd       U0006,U             * 09F3 EC 46          lF
                    clra                          * 09F5 4F             O
                    andb      #192                * 09F6 C4 C0          D@
                    bne       L0A27               * 09F8 26 2D          &-
                    leas      -$20,S              * 09FA 32 E8 E0       2h`
                    leax      0,S                 * 09FD 30 E4          0d
                    pshs      X                   * 09FF 34 10          4.
                    ldd       U0008,U             * 0A01 EC 48          lH
                    pshs      D                   * 0A03 34 06          4.
                    clra                          * 0A05 4F             O
                    clrb                          * 0A06 5F             _
                    pshs      D                   * 0A07 34 06          4.
                    lbsr      L0C44               * 0A09 17 02 38       ..8
                    leas      $06,S               * 0A0C 32 66          2f
                    ldd       U0006,U             * 0A0E EC 46          lF
                    pshs      D                   * 0A10 34 06          4.
                    ldb       $02,S               * 0A12 E6 62          fb
                    bne       L0A1B               * 0A14 26 05          &.
                    ldd       #64                 * 0A16 CC 00 40       L.@
                    bra       L0A1E               * 0A19 20 03           .
L0A1B               ldd       #128                * 0A1B CC 00 80       L..
L0A1E               ora       ,S+                 * 0A1E AA E0          *`
                    orb       ,S+                 * 0A20 EA E0          j`
                    std       U0006,U             * 0A22 ED 46          mF
                    leas      <$0020,S            * 0A24 32 E8 20       2h
L0A27               ldd       U0006,U             * 0A27 EC 46          lF
                    ora       #128                * 0A29 8A 80          ..
                    std       U0006,U             * 0A2B ED 46          mF
                    clra                          * 0A2D 4F             O
                    andb      #12                 * 0A2E C4 0C          D.
                    beq       L0A34               * 0A30 27 02          '.
                    puls      PC,U                * 0A32 35 C0          5@
L0A34               ldd       U000B,U             * 0A34 EC 4B          lK
                    bne       L0A49               * 0A36 26 11          &.
                    ldd       U0006,U             * 0A38 EC 46          lF
                    clra                          * 0A3A 4F             O
                    andb      #64                 * 0A3B C4 40          D@
                    beq       L0A44               * 0A3D 27 05          '.
                    ldd       #128                * 0A3F CC 00 80       L..
                    bra       L0A47               * 0A42 20 03           .
L0A44               ldd       #256                * 0A44 CC 01 00       L..
L0A47               std       U000B,U             * 0A47 ED 4B          mK
L0A49               ldd       U0002,U             * 0A49 EC 42          lB
                    bne       L0A5E               * 0A4B 26 11          &.
                    ldd       U000B,U             * 0A4D EC 4B          lK
                    pshs      D                   * 0A4F 34 06          4.
                    lbsr      L0E47               * 0A51 17 03 F3       ..s
                    leas      $02,S               * 0A54 32 62          2b
                    std       U0002,U             * 0A56 ED 42          mB
                    cmpd      #-1                 * 0A58 10 83 FF FF    ....
                    beq       L0A66               * 0A5C 27 08          '.
L0A5E               ldd       U0006,U             * 0A5E EC 46          lF
                    orb       #8                  * 0A60 CA 08          J.
                    std       U0006,U             * 0A62 ED 46          mF
                    bra       L0A75               * 0A64 20 0F           .
L0A66               ldd       U0006,U             * 0A66 EC 46          lF
                    orb       #4                  * 0A68 CA 04          J.
                    std       U0006,U             * 0A6A ED 46          mF
                    leax      U000A,U             * 0A6C 30 4A          0J
                    stx       U0002,U             * 0A6E AF 42          /B
                    ldd       #1                  * 0A70 CC 00 01       L..
                    std       U000B,U             * 0A73 ED 4B          mK
L0A75               ldd       U0002,U             * 0A75 EC 42          lB
                    addd      U000B,U             * 0A77 E3 4B          cK
                    std       U0004,U             * 0A79 ED 44          mD
                    std       U0000,U             * 0A7B ED C4          mD
                    puls      PC,U                * 0A7D 35 C0          5@
L0A7F               pshs      U                   * 0A7F 34 40          4@
                    ldb       $05,S               * 0A81 E6 65          fe
                    sex                           * 0A83 1D             .
                    tfr       D,X                 * 0A84 1F 01          ..
                    bra       L0AA5               * 0A86 20 1D           .
L0A88               ldd       [<$06,S]            * 0A88 EC F8 06       lx.
                    addd      #4                  * 0A8B C3 00 04       C..
                    std       [<$06,S]            * 0A8E ED F8 06       mx.
                    leax      >L0ABC,PC           * 0A91 30 8D 00 27    0..'
                    bra       L0AA1               * 0A95 20 0A           .
L0A97               ldb       $05,S               * 0A97 E6 65          fe
                    stb       >$000C,Y            * 0A99 E7 A9 00 0C    g)..
                    leax      >$000B,Y            * 0A9D 30 A9 00 0B    0)..
L0AA1               tfr       X,D                 * 0AA1 1F 10          ..
                    puls      PC,U                * 0AA3 35 C0          5@
L0AA5               cmpx      #100                * 0AA5 8C 00 64       ..d
                    beq       L0A88               * 0AA8 27 DE          '^
                    cmpx      #111                * 0AAA 8C 00 6F       ..o
                    lbeq      L0A88               * 0AAD 10 27 FF D7    .'.W
                    cmpx      #120                * 0AB1 8C 00 78       ..x
                    lbeq      L0A88               * 0AB4 10 27 FF D0    .'.P
                    bra       L0A97               * 0AB8 20 DD           ]
                    fcb       $35                 * 0ABA 35             5
                    fcb       $C0                 * 0ABB C0             @
L0ABC               fcb       $00                 * 0ABC 00             .
L0ABD               pshs      U                   * 0ABD 34 40          4@
                    leax      >L0AC7,PC           * 0ABF 30 8D 00 04    0...
                    tfr       X,D                 * 0AC3 1F 10          ..
                    puls      PC,U                * 0AC5 35 C0          5@
L0AC7               fcb       $00                 * 0AC7 00             .
L0AC8               pshs      U                   * 0AC8 34 40          4@
                    ldu       $04,S               * 0ACA EE 64          nd
L0ACC               ldb       ,U+                 * 0ACC E6 C0          f@
                    bne       L0ACC               * 0ACE 26 FC          &|
                    tfr       U,D                 * 0AD0 1F 30          .0
                    subd      $04,S               * 0AD2 A3 64          #d
                    addd      #-1                 * 0AD4 C3 FF FF       C..
                    puls      PC,U                * 0AD7 35 C0          5@
L0AD9               pshs      U                   * 0AD9 34 40          4@
                    ldu       $06,S               * 0ADB EE 66          nf
                    leas      -$02,S              * 0ADD 32 7E          2~
                    ldd       $06,S               * 0ADF EC 66          lf
                    std       0,S                 * 0AE1 ED E4          md
L0AE3               ldb       ,U+                 * 0AE3 E6 C0          f@
                    ldx       0,S                 * 0AE5 AE E4          .d
                    leax      $01,X               * 0AE7 30 01          0.
                    stx       0,S                 * 0AE9 AF E4          /d
                    stb       -$01,X              * 0AEB E7 1F          g.
                    bne       L0AE3               * 0AED 26 F4          &t
                    bra       L0B18               * 0AEF 20 27           '
L0AF1               pshs      U                   * 0AF1 34 40          4@
                    ldu       $06,S               * 0AF3 EE 66          nf
                    leas      -$02,S              * 0AF5 32 7E          2~
                    ldd       $06,S               * 0AF7 EC 66          lf
                    std       0,S                 * 0AF9 ED E4          md
L0AFB               ldx       0,S                 * 0AFB AE E4          .d
                    leax      $01,X               * 0AFD 30 01          0.
                    stx       0,S                 * 0AFF AF E4          /d
                    ldb       -$01,X              * 0B01 E6 1F          f.
                    bne       L0AFB               * 0B03 26 F6          &v
                    ldd       0,S                 * 0B05 EC E4          ld
                    addd      #-1                 * 0B07 C3 FF FF       C..
                    std       0,S                 * 0B0A ED E4          md
L0B0C               ldb       ,U+                 * 0B0C E6 C0          f@
                    ldx       0,S                 * 0B0E AE E4          .d
                    leax      $01,X               * 0B10 30 01          0.
                    stx       0,S                 * 0B12 AF E4          /d
                    stb       -$01,X              * 0B14 E7 1F          g.
                    bne       L0B0C               * 0B16 26 F4          &t
L0B18               ldd       $06,S               * 0B18 EC 66          lf
                    leas      $02,S               * 0B1A 32 62          2b
                    puls      PC,U                * 0B1C 35 C0          5@
                    fcb       $34                 * 0B1E 34             4
                    fcb       $40                 * 0B1F 40             @
                    fcb       $EE                 * 0B20 EE             n
                    fcb       $64                 * 0B21 64             d
                    fcb       $20                 * 0B22 20
                    fcb       $10                 * 0B23 10             .
                    fcb       $AE                 * 0B24 AE             .
                    fcb       $66                 * 0B25 66             f
                    fcb       $30                 * 0B26 30             0
                    fcb       $01                 * 0B27 01             .
                    fcb       $AF                 * 0B28 AF             /
                    fcb       $66                 * 0B29 66             f
                    fcb       $E6                 * 0B2A E6             f
                    fcb       $1F                 * 0B2B 1F             .
                    fcb       $26                 * 0B2C 26             &
                    fcb       $04                 * 0B2D 04             .
                    fcc       "O_5"               * 0B2E 4F 5F 35       O_5
                    fcb       $C0                 * 0B31 C0             @
                    fcb       $33                 * 0B32 33             3
                    fcb       $41                 * 0B33 41             A
                    fcb       $E6                 * 0B34 E6             f
                    fcb       $C4                 * 0B35 C4             D
                    fcb       $1D                 * 0B36 1D             .
                    fcb       $34                 * 0B37 34             4
                    fcb       $06                 * 0B38 06             .
                    fcb       $E6                 * 0B39 E6             f
                    fcb       $F8                 * 0B3A F8             x
                    fcb       $08                 * 0B3B 08             .
                    fcb       $1D                 * 0B3C 1D             .
                    fcb       $10                 * 0B3D 10             .
                    fcb       $A3                 * 0B3E A3             #
                    fcb       $E1                 * 0B3F E1             a
                    fcb       $27                 * 0B40 27             '
                    fcb       $E2                 * 0B41 E2             b
                    fcb       $E6                 * 0B42 E6             f
                    fcb       $F8                 * 0B43 F8             x
                    fcb       $06                 * 0B44 06             .
                    fcb       $1D                 * 0B45 1D             .
                    fcb       $34                 * 0B46 34             4
                    fcb       $06                 * 0B47 06             .
                    fcb       $E6                 * 0B48 E6             f
                    fcb       $C4                 * 0B49 C4             D
                    fcb       $1D                 * 0B4A 1D             .
                    fcb       $A3                 * 0B4B A3             #
                    fcb       $E1                 * 0B4C E1             a
                    fcb       $35                 * 0B4D 35             5
                    fcb       $C0                 * 0B4E C0             @
L0B4F               pshs      U                   * 0B4F 34 40          4@
                    ldu       $04,S               * 0B51 EE 64          nd
                    leas      -$05,S              * 0B53 32 7B          2{
                    clra                          * 0B55 4F             O
                    clrb                          * 0B56 5F             _
                    std       $01,S               * 0B57 ED 61          ma
L0B59               ldb       ,U+                 * 0B59 E6 C0          f@
                    stb       0,S                 * 0B5B E7 E4          gd
                    cmpb      #32                 * 0B5D C1 20          A
                    beq       L0B59               * 0B5F 27 F8          'x
                    ldb       0,S                 * 0B61 E6 E4          fd
                    cmpb      #9                  * 0B63 C1 09          A.
                    lbeq      L0B59               * 0B65 10 27 FF F0    .'.p
                    ldb       0,S                 * 0B69 E6 E4          fd
                    cmpb      #45                 * 0B6B C1 2D          A-
                    bne       L0B74               * 0B6D 26 05          &.
                    ldd       #1                  * 0B6F CC 00 01       L..
                    bra       L0B76               * 0B72 20 02           .
L0B74               clra                          * 0B74 4F             O
                    clrb                          * 0B75 5F             _
L0B76               std       $03,S               * 0B76 ED 63          mc
                    ldb       0,S                 * 0B78 E6 E4          fd
                    cmpb      #45                 * 0B7A C1 2D          A-
                    beq       L0B9C               * 0B7C 27 1E          '.
                    ldb       0,S                 * 0B7E E6 E4          fd
                    cmpb      #43                 * 0B80 C1 2B          A+
                    bne       L0BA0               * 0B82 26 1C          &.
                    bra       L0B9C               * 0B84 20 16           .
L0B86               ldd       $01,S               * 0B86 EC 61          la
                    pshs      D                   * 0B88 34 06          4.
                    ldd       #10                 * 0B8A CC 00 0A       L..
                    lbsr      L0BC2               * 0B8D 17 00 32       ..2
                    pshs      D                   * 0B90 34 06          4.
                    ldb       $02,S               * 0B92 E6 62          fb
                    sex                           * 0B94 1D             .
                    addd      ,S++                * 0B95 E3 E1          ca
                    addd      #-48                * 0B97 C3 FF D0       C.P
                    std       $01,S               * 0B9A ED 61          ma
L0B9C               ldb       ,U+                 * 0B9C E6 C0          f@
                    stb       0,S                 * 0B9E E7 E4          gd
L0BA0               ldb       0,S                 * 0BA0 E6 E4          fd
                    sex                           * 0BA2 1D             .
                    leax      >$00DF,Y            * 0BA3 30 A9 00 DF    0)._
                    leax      D,X                 * 0BA7 30 8B          0.
                    ldb       0,X                 * 0BA9 E6 84          f.
                    clra                          * 0BAB 4F             O
                    andb      #8                  * 0BAC C4 08          D.
                    bne       L0B86               * 0BAE 26 D6          &V
                    ldd       $03,S               * 0BB0 EC 63          lc
                    beq       L0BBC               * 0BB2 27 08          '.
                    ldd       $01,S               * 0BB4 EC 61          la
                    nega                          * 0BB6 40             @
                    negb                          * 0BB7 50             P
                    sbca      #0                  * 0BB8 82 00          ..
                    bra       L0BBE               * 0BBA 20 02           .
L0BBC               ldd       $01,S               * 0BBC EC 61          la
L0BBE               leas      $05,S               * 0BBE 32 65          2e
                    puls      PC,U                * 0BC0 35 C0          5@
L0BC2               tsta                          * 0BC2 4D             M
                    bne       L0BD7               * 0BC3 26 12          &.
                    tst       $02,S               * 0BC5 6D 62          mb
                    bne       L0BD7               * 0BC7 26 0E          &.
                    lda       $03,S               * 0BC9 A6 63          &c
                    mul                           * 0BCB 3D             =
                    ldx       0,S                 * 0BCC AE E4          .d
                    stx       $02,S               * 0BCE AF 62          /b
                    ldx       #0                  * 0BD0 8E 00 00       ...
                    std       0,S                 * 0BD3 ED E4          md
                    puls      PC,D                * 0BD5 35 86          5.
L0BD7               pshs      D                   * 0BD7 34 06          4.
                    ldd       #0                  * 0BD9 CC 00 00       L..
                    pshs      D                   * 0BDC 34 06          4.
                    pshs      D                   * 0BDE 34 06          4.
                    lda       $05,S               * 0BE0 A6 65          &e
                    ldb       $09,S               * 0BE2 E6 69          fi
                    mul                           * 0BE4 3D             =
                    std       $02,S               * 0BE5 ED 62          mb
                    lda       $05,S               * 0BE7 A6 65          &e
                    ldb       $08,S               * 0BE9 E6 68          fh
                    mul                           * 0BEB 3D             =
                    addd      $01,S               * 0BEC E3 61          ca
                    std       $01,S               * 0BEE ED 61          ma
                    bcc       L0BF4               * 0BF0 24 02          $.
                    inc       0,S                 * 0BF2 6C E4          ld
L0BF4               lda       $04,S               * 0BF4 A6 64          &d
                    ldb       $09,S               * 0BF6 E6 69          fi
                    mul                           * 0BF8 3D             =
                    addd      $01,S               * 0BF9 E3 61          ca
                    std       $01,S               * 0BFB ED 61          ma
                    bcc       L0C01               * 0BFD 24 02          $.
                    inc       0,S                 * 0BFF 6C E4          ld
L0C01               lda       $04,S               * 0C01 A6 64          &d
                    ldb       $08,S               * 0C03 E6 68          fh
                    mul                           * 0C05 3D             =
                    addd      0,S                 * 0C06 E3 E4          cd
                    std       0,S                 * 0C08 ED E4          md
                    ldx       $06,S               * 0C0A AE 66          .f
                    stx       $08,S               * 0C0C AF 68          /h
                    ldx       0,S                 * 0C0E AE E4          .d
                    ldd       $02,S               * 0C10 EC 62          lb
                    leas      $08,S               * 0C12 32 68          2h
                    rts                           * 0C14 39             9
                    fcb       $5D                 * 0C15 5D             ]
                    fcb       $27                 * 0C16 27             '
                    fcb       $13                 * 0C17 13             .
                    fcc       "gbfcZ&"            * 0C18 67 62 66 63 5A 26 gbfcZ&
                    fcb       $F9                 * 0C1E F9             y
                    fcb       $20                 * 0C1F 20
                    fcb       $0A                 * 0C20 0A             .
                    fcb       $5D                 * 0C21 5D             ]
                    fcb       $27                 * 0C22 27             '
                    fcb       $07                 * 0C23 07             .
                    fcc       "dbfcZ&"            * 0C24 64 62 66 63 5A 26 dbfcZ&
                    fcb       $F9                 * 0C2A F9             y
                    fcb       $EC                 * 0C2B EC             l
                    fcb       $62                 * 0C2C 62             b
                    fcb       $34                 * 0C2D 34             4
                    fcb       $06                 * 0C2E 06             .
                    fcb       $EC                 * 0C2F EC             l
                    fcb       $62                 * 0C30 62             b
                    fcb       $ED                 * 0C31 ED             m
                    fcb       $64                 * 0C32 64             d
                    fcb       $EC                 * 0C33 EC             l
                    fcb       $E4                 * 0C34 E4             d
                    fcc       "2d9]'"             * 0C35 32 64 39 5D 27 2d9]'
                    fcb       $F0                 * 0C3A F0             p
                    fcc       "hcibZ&"            * 0C3B 68 63 69 62 5A 26 hcibZ&
                    fcb       $F9                 * 0C41 F9             y
                    fcb       $20                 * 0C42 20
                    fcb       $E7                 * 0C43 E7             g
L0C44               lda       $05,S               * 0C44 A6 65          &e
                    ldb       $03,S               * 0C46 E6 63          fc
                    beq       L0C77               * 0C48 27 2D          '-
                    cmpb      #1                  * 0C4A C1 01          A.
                    beq       L0C79               * 0C4C 27 2B          '+
                    cmpb      #6                  * 0C4E C1 06          A.
                    beq       L0C79               * 0C50 27 27          ''
                    cmpb      #2                  * 0C52 C1 02          A.
                    beq       L0C5F               * 0C54 27 09          '.
                    cmpb      #5                  * 0C56 C1 05          A.
                    beq       L0C5F               * 0C58 27 05          '.
                    ldb       #208                * 0C5A C6 D0          FP
                    lbra      L0F1C               * 0C5C 16 02 BD       ..=
L0C5F               pshs      U                   * 0C5F 34 40          4@
                    os9       I$GetStt            * 0C61 10 3F 8D       .?.
                    bcc       L0C6B               * 0C64 24 05          $.
                    puls      U                   * 0C66 35 40          5@
                    lbra      L0F1C               * 0C68 16 02 B1       ..1
L0C6B               stx       [<$08,S]            * 0C6B AF F8 08       /x.
                    ldx       $08,S               * 0C6E AE 68          .h
                    stu       $02,X               * 0C70 EF 02          o.
                    puls      U                   * 0C72 35 40          5@
                    clra                          * 0C74 4F             O
                    clrb                          * 0C75 5F             _
                    rts                           * 0C76 39             9
L0C77               ldx       $06,S               * 0C77 AE 66          .f
L0C79               os9       I$GetStt            * 0C79 10 3F 8D       .?.
                    lbra      L0F25               * 0C7C 16 02 A6       ..&
                    fcb       $A6                 * 0C7F A6             &
                    fcb       $65                 * 0C80 65             e
                    fcb       $E6                 * 0C81 E6             f
                    fcb       $63                 * 0C82 63             c
                    fcb       $27                 * 0C83 27             '
                    fcb       $09                 * 0C84 09             .
                    fcb       $C1                 * 0C85 C1             A
                    fcb       $02                 * 0C86 02             .
                    fcb       $27                 * 0C87 27             '
                    fcb       $0D                 * 0C88 0D             .
                    fcb       $C6                 * 0C89 C6             F
                    fcb       $D0                 * 0C8A D0             P
                    fcb       $16                 * 0C8B 16             .
                    fcb       $02                 * 0C8C 02             .
                    fcb       $8E                 * 0C8D 8E             .
                    fcb       $AE                 * 0C8E AE             .
                    fcb       $66                 * 0C8F 66             f
                    fcb       $10                 * 0C90 10             .
                    fcb       $3F                 * 0C91 3F             ?
                    fcb       $8E                 * 0C92 8E             .
                    fcb       $16                 * 0C93 16             .
                    fcb       $02                 * 0C94 02             .
                    fcb       $8F                 * 0C95 8F             .
                    fcb       $34                 * 0C96 34             4
                    fcb       $40                 * 0C97 40             @
                    fcb       $AE                 * 0C98 AE             .
                    fcb       $68                 * 0C99 68             h
                    fcb       $EE                 * 0C9A EE             n
                    fcb       $6A                 * 0C9B 6A             j
                    fcb       $10                 * 0C9C 10             .
                    fcb       $3F                 * 0C9D 3F             ?
                    fcb       $8E                 * 0C9E 8E             .
                    fcb       $35                 * 0C9F 35             5
                    fcb       $40                 * 0CA0 40             @
                    fcb       $16                 * 0CA1 16             .
                    fcb       $02                 * 0CA2 02             .
                    fcb       $81                 * 0CA3 81             .
                    fcb       $AE                 * 0CA4 AE             .
                    fcb       $62                 * 0CA5 62             b
                    fcb       $A6                 * 0CA6 A6             &
                    fcb       $65                 * 0CA7 65             e
                    fcb       $10                 * 0CA8 10             .
                    fcb       $3F                 * 0CA9 3F             ?
                    fcb       $84                 * 0CAA 84             .
                    fcb       $25                 * 0CAB 25             %
                    fcb       $03                 * 0CAC 03             .
                    fcb       $10                 * 0CAD 10             .
                    fcb       $3F                 * 0CAE 3F             ?
                    fcb       $8F                 * 0CAF 8F             .
                    fcb       $16                 * 0CB0 16             .
                    fcb       $02                 * 0CB1 02             .
                    fcb       $72                 * 0CB2 72             r
                    fcb       $AE                 * 0CB3 AE             .
                    fcb       $62                 * 0CB4 62             b
                    fcb       $A6                 * 0CB5 A6             &
                    fcb       $65                 * 0CB6 65             e
                    fcb       $10                 * 0CB7 10             .
                    fcb       $3F                 * 0CB8 3F             ?
                    fcb       $84                 * 0CB9 84             .
                    fcb       $10                 * 0CBA 10             .
                    fcb       $25                 * 0CBB 25             %
                    fcb       $02                 * 0CBC 02             .
                    fcb       $5E                 * 0CBD 5E             ^
                    fcb       $1F                 * 0CBE 1F             .
                    fcb       $89                 * 0CBF 89             .
                    fcb       $4F                 * 0CC0 4F             O
                    fcb       $39                 * 0CC1 39             9
L0CC2               lda       $03,S               * 0CC2 A6 63          &c
                    os9       I$Close             * 0CC4 10 3F 8F       .?.
                    lbra      L0F25               * 0CC7 16 02 5B       ..[
                    fcb       $AE                 * 0CCA AE             .
                    fcb       $62                 * 0CCB 62             b
                    fcb       $E6                 * 0CCC E6             f
                    fcb       $65                 * 0CCD 65             e
                    fcb       $10                 * 0CCE 10             .
                    fcb       $3F                 * 0CCF 3F             ?
                    fcb       $85                 * 0CD0 85             .
                    fcb       $16                 * 0CD1 16             .
                    fcb       $02                 * 0CD2 02             .
                    fcb       $51                 * 0CD3 51             Q
                    fcb       $AE                 * 0CD4 AE             .
                    fcb       $62                 * 0CD5 62             b
                    fcb       $A6                 * 0CD6 A6             &
                    fcb       $65                 * 0CD7 65             e
                    fcb       $1F                 * 0CD8 1F             .
                    fcb       $89                 * 0CD9 89             .
                    fcb       $C4                 * 0CDA C4             D
                    fcb       $24                 * 0CDB 24             $
                    fcb       $CA                 * 0CDC CA             J
                    fcb       $0B                 * 0CDD 0B             .
                    fcb       $10                 * 0CDE 10             .
                    fcb       $3F                 * 0CDF 3F             ?
                    fcb       $83                 * 0CE0 83             .
                    fcb       $25                 * 0CE1 25             %
                    fcb       $04                 * 0CE2 04             .
                    fcb       $1F                 * 0CE3 1F             .
                    fcb       $89                 * 0CE4 89             .
                    fcb       $4F                 * 0CE5 4F             O
                    fcb       $39                 * 0CE6 39             9
                    fcb       $C1                 * 0CE7 C1             A
                    fcb       $DA                 * 0CE8 DA             Z
                    fcb       $10                 * 0CE9 10             .
                    fcb       $26                 * 0CEA 26             &
                    fcb       $02                 * 0CEB 02             .
                    fcb       $2F                 * 0CEC 2F             /
                    fcb       $A6                 * 0CED A6             &
                    fcb       $65                 * 0CEE 65             e
                    fcb       $85                 * 0CEF 85             .
                    fcb       $80                 * 0CF0 80             .
                    fcb       $10                 * 0CF1 10             .
                    fcb       $26                 * 0CF2 26             &
                    fcb       $02                 * 0CF3 02             .
                    fcb       $27                 * 0CF4 27             '
                    fcb       $84                 * 0CF5 84             .
                    fcb       $07                 * 0CF6 07             .
                    fcb       $AE                 * 0CF7 AE             .
                    fcb       $62                 * 0CF8 62             b
                    fcb       $10                 * 0CF9 10             .
                    fcb       $3F                 * 0CFA 3F             ?
                    fcb       $84                 * 0CFB 84             .
                    fcb       $10                 * 0CFC 10             .
                    fcb       $25                 * 0CFD 25             %
                    fcb       $02                 * 0CFE 02             .
                    fcb       $1C                 * 0CFF 1C             .
                    fcb       $34                 * 0D00 34             4
                    fcb       $42                 * 0D01 42             B
                    fcb       $8E                 * 0D02 8E             .
                    fcb       $00                 * 0D03 00             .
                    fcb       $00                 * 0D04 00             .
                    fcb       $33                 * 0D05 33             3
                    fcb       $84                 * 0D06 84             .
                    fcb       $C6                 * 0D07 C6             F
                    fcb       $02                 * 0D08 02             .
                    fcb       $10                 * 0D09 10             .
                    fcb       $3F                 * 0D0A 3F             ?
                    fcb       $8E                 * 0D0B 8E             .
                    fcc       "5B$"               * 0D0C 35 42 24       5B$
                    fcb       $D3                 * 0D0F D3             S
                    fcb       $34                 * 0D10 34             4
                    fcb       $04                 * 0D11 04             .
                    fcb       $10                 * 0D12 10             .
                    fcb       $3F                 * 0D13 3F             ?
                    fcb       $8F                 * 0D14 8F             .
                    fcb       $35                 * 0D15 35             5
                    fcb       $04                 * 0D16 04             .
                    fcb       $16                 * 0D17 16             .
                    fcb       $02                 * 0D18 02             .
                    fcb       $02                 * 0D19 02             .
                    fcb       $AE                 * 0D1A AE             .
                    fcb       $62                 * 0D1B 62             b
                    fcb       $10                 * 0D1C 10             .
                    fcb       $3F                 * 0D1D 3F             ?
                    fcb       $87                 * 0D1E 87             .
                    fcb       $16                 * 0D1F 16             .
                    fcb       $02                 * 0D20 02             .
                    fcb       $03                 * 0D21 03             .
                    fcb       $A6                 * 0D22 A6             &
                    fcb       $63                 * 0D23 63             c
                    fcb       $10                 * 0D24 10             .
                    fcb       $3F                 * 0D25 3F             ?
                    fcb       $82                 * 0D26 82             .
                    fcb       $10                 * 0D27 10             .
                    fcb       $25                 * 0D28 25             %
                    fcb       $01                 * 0D29 01             .
                    fcb       $F1                 * 0D2A F1             q
                    fcb       $1F                 * 0D2B 1F             .
                    fcb       $89                 * 0D2C 89             .
                    fcc       "O94 "              * 0D2D 4F 39 34 20    O94
                    fcb       $AE                 * 0D31 AE             .
                    fcb       $66                 * 0D32 66             f
                    fcb       $A6                 * 0D33 A6             &
                    fcb       $65                 * 0D34 65             e
                    fcb       $10                 * 0D35 10             .
                    fcb       $AE                 * 0D36 AE             .
                    fcc       "h4 "               * 0D37 68 34 20       h4
                    fcb       $10                 * 0D3A 10             .
                    fcb       $3F                 * 0D3B 3F             ?
                    fcb       $89                 * 0D3C 89             .
                    fcb       $24                 * 0D3D 24             $
                    fcb       $0D                 * 0D3E 0D             .
                    fcb       $C1                 * 0D3F C1             A
                    fcb       $D3                 * 0D40 D3             S
                    fcb       $26                 * 0D41 26             &
                    fcb       $04                 * 0D42 04             .
                    fcc       "O_5"               * 0D43 4F 5F 35       O_5
                    fcb       $B0                 * 0D46 B0             0
                    fcb       $35                 * 0D47 35             5
                    fcb       $30                 * 0D48 30             0
                    fcb       $16                 * 0D49 16             .
                    fcb       $01                 * 0D4A 01             .
                    fcb       $D0                 * 0D4B D0             P
                    fcb       $1F                 * 0D4C 1F             .
                    fcb       $20                 * 0D4D 20
                    fcb       $35                 * 0D4E 35             5
                    fcb       $B0                 * 0D4F B0             0
                    fcb       $34                 * 0D50 34             4
                    fcb       $20                 * 0D51 20
                    fcb       $A6                 * 0D52 A6             &
                    fcb       $65                 * 0D53 65             e
                    fcb       $AE                 * 0D54 AE             .
                    fcb       $66                 * 0D55 66             f
                    fcb       $10                 * 0D56 10             .
                    fcb       $AE                 * 0D57 AE             .
                    fcc       "h4 "               * 0D58 68 34 20       h4
                    fcb       $10                 * 0D5B 10             .
                    fcb       $3F                 * 0D5C 3F             ?
                    fcb       $8B                 * 0D5D 8B             .
                    fcb       $20                 * 0D5E 20
                    fcb       $DD                 * 0D5F DD             ]
L0D60               pshs      Y                   * 0D60 34 20          4
                    ldy       $08,S               * 0D62 10 AE 68       ..h
                    beq       L0D75               * 0D65 27 0E          '.
                    lda       $05,S               * 0D67 A6 65          &e
                    ldx       $06,S               * 0D69 AE 66          .f
                    os9       I$Write             * 0D6B 10 3F 8A       .?.
L0D6E               bcc       L0D75               * 0D6E 24 05          $.
                    puls      Y                   * 0D70 35 20          5
                    lbra      L0F1C               * 0D72 16 01 A7       ..'
L0D75               tfr       Y,D                 * 0D75 1F 20          .
                    puls      PC,Y                * 0D77 35 A0          5
L0D79               pshs      Y                   * 0D79 34 20          4
                    ldy       $08,S               * 0D7B 10 AE 68       ..h
                    beq       L0D75               * 0D7E 27 F5          'u
                    lda       $05,S               * 0D80 A6 65          &e
                    ldx       $06,S               * 0D82 AE 66          .f
                    os9       I$WritLn            * 0D84 10 3F 8C       .?.
                    bra       L0D6E               * 0D87 20 E5           e
L0D89               pshs      U                   * 0D89 34 40          4@
                    ldd       $0A,S               * 0D8B EC 6A          lj
                    bne       L0D97               * 0D8D 26 08          &.
                    ldu       #0                  * 0D8F CE 00 00       N..
                    ldx       #0                  * 0D92 8E 00 00       ...
                    bra       L0DCB               * 0D95 20 34           4
L0D97               cmpd      #1                  * 0D97 10 83 00 01    ....
                    beq       L0DC2               * 0D9B 27 25          '%
                    cmpd      #2                  * 0D9D 10 83 00 02    ....
                    beq       L0DB7               * 0DA1 27 14          '.
                    ldb       #247                * 0DA3 C6 F7          Fw
L0DA5               clra                          * 0DA5 4F             O
                    std       >$01AD,Y            * 0DA6 ED A9 01 AD    m).-
                    ldd       #-1                 * 0DAA CC FF FF       L..
                    leax      >$01A1,Y            * 0DAD 30 A9 01 A1    0).!
                    std       0,X                 * 0DB1 ED 84          m.
                    std       $02,X               * 0DB3 ED 02          m.
                    puls      PC,U                * 0DB5 35 C0          5@
L0DB7               lda       $05,S               * 0DB7 A6 65          &e
                    ldb       #2                  * 0DB9 C6 02          F.
                    os9       I$GetStt            * 0DBB 10 3F 8D       .?.
                    bcs       L0DA5               * 0DBE 25 E5          %e
                    bra       L0DCB               * 0DC0 20 09           .
L0DC2               lda       $05,S               * 0DC2 A6 65          &e
                    ldb       #5                  * 0DC4 C6 05          F.
                    os9       I$GetStt            * 0DC6 10 3F 8D       .?.
                    bcs       L0DA5               * 0DC9 25 DA          %Z
L0DCB               tfr       U,D                 * 0DCB 1F 30          .0
                    addd      $08,S               * 0DCD E3 68          ch
                    std       >$01A3,Y            * 0DCF ED A9 01 A3    m).#
                    tfr       D,U                 * 0DD3 1F 03          ..
                    tfr       X,D                 * 0DD5 1F 10          ..
                    adcb      $07,S               * 0DD7 E9 67          ig
                    adca      $06,S               * 0DD9 A9 66          )f
                    bmi       L0DA5               * 0DDB 2B C8          +H
                    tfr       D,X                 * 0DDD 1F 01          ..
                    std       >$01A1,Y            * 0DDF ED A9 01 A1    m).!
                    lda       $05,S               * 0DE3 A6 65          &e
                    os9       I$Seek              * 0DE5 10 3F 88       .?.
                    bcs       L0DA5               * 0DE8 25 BB          %;
                    leax      >$01A1,Y            * 0DEA 30 A9 01 A1    0).!
                    puls      PC,U                * 0DEE 35 C0          5@
                    fcb       $EC                 * 0DF0 EC             l
                    fcb       $A9                 * 0DF1 A9             )
                    fcb       $01                 * 0DF2 01             .
                    fcb       $9F                 * 0DF3 9F             .
                    fcb       $34                 * 0DF4 34             4
                    fcb       $06                 * 0DF5 06             .
                    fcb       $EC                 * 0DF6 EC             l
                    fcb       $64                 * 0DF7 64             d
                    fcb       $10                 * 0DF8 10             .
                    fcb       $A3                 * 0DF9 A3             #
                    fcb       $A9                 * 0DFA A9             )
                    fcb       $01                 * 0DFB 01             .
                    fcb       $C9                 * 0DFC C9             I
                    fcb       $25                 * 0DFD 25             %
                    fcb       $25                 * 0DFE 25             %
                    fcb       $E3                 * 0DFF E3             c
                    fcb       $A9                 * 0E00 A9             )
                    fcb       $01                 * 0E01 01             .
                    fcb       $9F                 * 0E02 9F             .
                    fcb       $34                 * 0E03 34             4
                    fcb       $20                 * 0E04 20
                    fcb       $A3                 * 0E05 A3             #
                    fcb       $E4                 * 0E06 E4             d
                    fcb       $10                 * 0E07 10             .
                    fcb       $3F                 * 0E08 3F             ?
                    fcb       $07                 * 0E09 07             .
                    fcb       $1F                 * 0E0A 1F             .
                    fcc       " 5 $"              * 0E0B 20 35 20 24     5 $
                    fcb       $06                 * 0E0F 06             .
                    fcb       $CC                 * 0E10 CC             L
                    fcb       $FF                 * 0E11 FF             .
                    fcb       $FF                 * 0E12 FF             .
                    fcc       "2b9"               * 0E13 32 62 39       2b9
                    fcb       $ED                 * 0E16 ED             m
                    fcb       $A9                 * 0E17 A9             )
                    fcb       $01                 * 0E18 01             .
                    fcb       $9F                 * 0E19 9F             .
                    fcb       $E3                 * 0E1A E3             c
                    fcb       $A9                 * 0E1B A9             )
                    fcb       $01                 * 0E1C 01             .
                    fcb       $C9                 * 0E1D C9             I
                    fcb       $A3                 * 0E1E A3             #
                    fcb       $E4                 * 0E1F E4             d
                    fcb       $ED                 * 0E20 ED             m
                    fcb       $A9                 * 0E21 A9             )
                    fcb       $01                 * 0E22 01             .
                    fcb       $C9                 * 0E23 C9             I
                    fcb       $32                 * 0E24 32             2
                    fcb       $62                 * 0E25 62             b
                    fcb       $EC                 * 0E26 EC             l
                    fcb       $A9                 * 0E27 A9             )
                    fcb       $01                 * 0E28 01             .
                    fcb       $C9                 * 0E29 C9             I
                    fcb       $34                 * 0E2A 34             4
                    fcb       $06                 * 0E2B 06             .
                    fcb       $A3                 * 0E2C A3             #
                    fcb       $64                 * 0E2D 64             d
                    fcb       $ED                 * 0E2E ED             m
                    fcb       $A9                 * 0E2F A9             )
                    fcb       $01                 * 0E30 01             .
                    fcb       $C9                 * 0E31 C9             I
                    fcb       $EC                 * 0E32 EC             l
                    fcb       $A9                 * 0E33 A9             )
                    fcb       $01                 * 0E34 01             .
                    fcb       $9F                 * 0E35 9F             .
                    fcb       $A3                 * 0E36 A3             #
                    fcb       $E1                 * 0E37 E1             a
                    fcb       $34                 * 0E38 34             4
                    fcb       $06                 * 0E39 06             .
                    fcb       $4F                 * 0E3A 4F             O
                    fcb       $AE                 * 0E3B AE             .
                    fcb       $E4                 * 0E3C E4             d
                    fcb       $A7                 * 0E3D A7             '
                    fcb       $80                 * 0E3E 80             .
                    fcb       $AC                 * 0E3F AC             ,
                    fcb       $A9                 * 0E40 A9             )
                    fcb       $01                 * 0E41 01             .
                    fcb       $9F                 * 0E42 9F             .
                    fcb       $25                 * 0E43 25             %
                    fcb       $F8                 * 0E44 F8             x
                    fcb       $35                 * 0E45 35             5
                    fcb       $86                 * 0E46 86             .
L0E47               ldd       $02,S               * 0E47 EC 62          lb
                    addd      >$01A9,Y            * 0E49 E3 A9 01 A9    c).)
                    bcs       L0E70               * 0E4D 25 21          %!
                    cmpd      >$01AB,Y            * 0E4F 10 A3 A9 01 AB .#).+
                    bcc       L0E70               * 0E54 24 1A          $.
                    pshs      D                   * 0E56 34 06          4.
                    ldx       >$01A9,Y            * 0E58 AE A9 01 A9    .).)
                    clra                          * 0E5C 4F             O
L0E5D               cmpx      0,S                 * 0E5D AC E4          ,d
                    bcc       L0E65               * 0E5F 24 04          $.
                    sta       ,X+                 * 0E61 A7 80          '.
                    bra       L0E5D               * 0E63 20 F8           x
L0E65               ldd       >$01A9,Y            * 0E65 EC A9 01 A9    l).)
                    puls      X                   * 0E69 35 10          5.
                    stx       >$01A9,Y            * 0E6B AF A9 01 A9    /).)
                    rts                           * 0E6F 39             9
L0E70               ldd       #-1                 * 0E70 CC FF FF       L..
                    rts                           * 0E73 39             9
                    fcb       $A6                 * 0E74 A6             &
                    fcb       $63                 * 0E75 63             c
                    fcb       $E6                 * 0E76 E6             f
                    fcb       $65                 * 0E77 65             e
                    fcb       $10                 * 0E78 10             .
                    fcb       $3F                 * 0E79 3F             ?
                    fcb       $08                 * 0E7A 08             .
                    fcb       $16                 * 0E7B 16             .
                    fcb       $00                 * 0E7C 00             .
                    fcb       $A7                 * 0E7D A7             '
                    fcb       $4F                 * 0E7E 4F             O
                    fcb       $5F                 * 0E7F 5F             _
                    fcb       $10                 * 0E80 10             .
                    fcb       $3F                 * 0E81 3F             ?
                    fcb       $04                 * 0E82 04             .
                    fcb       $10                 * 0E83 10             .
                    fcb       $25                 * 0E84 25             %
                    fcb       $00                 * 0E85 00             .
                    fcb       $95                 * 0E86 95             .
                    fcb       $AE                 * 0E87 AE             .
                    fcb       $62                 * 0E88 62             b
                    fcb       $27                 * 0E89 27             '
                    fcb       $04                 * 0E8A 04             .
                    fcb       $E7                 * 0E8B E7             g
                    fcb       $01                 * 0E8C 01             .
                    fcb       $6F                 * 0E8D 6F             o
                    fcb       $84                 * 0E8E 84             .
                    fcb       $1F                 * 0E8F 1F             .
                    fcb       $89                 * 0E90 89             .
                    fcb       $4F                 * 0E91 4F             O
                    fcb       $39                 * 0E92 39             9
                    fcb       $A6                 * 0E93 A6             &
                    fcb       $63                 * 0E94 63             c
                    fcb       $E6                 * 0E95 E6             f
                    fcb       $65                 * 0E96 65             e
                    fcb       $10                 * 0E97 10             .
                    fcb       $3F                 * 0E98 3F             ?
                    fcb       $0D                 * 0E99 0D             .
                    fcb       $16                 * 0E9A 16             .
                    fcb       $00                 * 0E9B 00             .
                    fcb       $88                 * 0E9C 88             .
L0E9D               leau      0,S                 * 0E9D 33 E4          3d
                    leas      >$00FF,Y            * 0E9F 32 A9 00 FF    2)..
                    ldx       U0002,U             * 0EA3 AE 42          .B
                    ldy       U0004,U             * 0EA5 10 AE 44       ..D
                    lda       U0009,U             * 0EA8 A6 49          &I
                    asla                          * 0EAA 48             H
                    asla                          * 0EAB 48             H
                    asla                          * 0EAC 48             H
                    asla                          * 0EAD 48             H
                    ora       U000B,U             * 0EAE AA 4B          *K
                    ldb       U000D,U             * 0EB0 E6 4D          fM
                    ldu       U0006,U             * 0EB2 EE 46          nF
                    os9       F$Chain             * 0EB4 10 3F 05       .?.
                    os9       F$Exit              * 0EB7 10 3F 06       .?.
                    fcb       $34                 * 0EBA 34             4
                    fcb       $60                 * 0EBB 60             `
                    fcb       $AE                 * 0EBC AE             .
                    fcb       $66                 * 0EBD 66             f
                    fcb       $10                 * 0EBE 10             .
                    fcb       $AE                 * 0EBF AE             .
                    fcb       $68                 * 0EC0 68             h
                    fcb       $EE                 * 0EC1 EE             n
                    fcb       $6A                 * 0EC2 6A             j
                    fcb       $A6                 * 0EC3 A6             &
                    fcb       $6D                 * 0EC4 6D             m
                    fcb       $AA                 * 0EC5 AA             *
                    fcb       $6F                 * 0EC6 6F             o
                    fcb       $E6                 * 0EC7 E6             f
                    fcb       $E8                 * 0EC8 E8             h
                    fcb       $11                 * 0EC9 11             .
                    fcb       $10                 * 0ECA 10             .
                    fcb       $3F                 * 0ECB 3F             ?
                    fcb       $03                 * 0ECC 03             .
                    fcb       $35                 * 0ECD 35             5
                    fcb       $60                 * 0ECE 60             `
                    fcb       $10                 * 0ECF 10             .
                    fcb       $25                 * 0ED0 25             %
                    fcb       $00                 * 0ED1 00             .
                    fcb       $49                 * 0ED2 49             I
                    fcb       $1F                 * 0ED3 1F             .
                    fcb       $89                 * 0ED4 89             .
                    fcc       "O94 "              * 0ED5 4F 39 34 20    O94
                    fcb       $10                 * 0ED9 10             .
                    fcb       $3F                 * 0EDA 3F             ?
                    fcb       $0C                 * 0EDB 0C             .
                    fcc       "5 $"               * 0EDC 35 20 24       5 $
                    fcb       $04                 * 0EDF 04             .
                    fcb       $10                 * 0EE0 10             .
                    fcb       $25                 * 0EE1 25             %
                    fcb       $00                 * 0EE2 00             .
                    fcb       $38                 * 0EE3 38             8
                    fcb       $1F                 * 0EE4 1F             .
                    fcb       $89                 * 0EE5 89             .
                    fcc       "O9"                * 0EE6 4F 39          O9
L0EE8               pshs      Y                   * 0EE8 34 20          4
                    os9       F$ID                * 0EEA 10 3F 0C       .?.
                    bcc       L0EF4               * 0EED 24 05          $.
L0EEF               puls      Y                   * 0EEF 35 20          5
                    lbra      L0F1C               * 0EF1 16 00 28       ..(
L0EF4               tfr       Y,D                 * 0EF4 1F 20          .
                    puls      PC,Y                * 0EF6 35 A0          5
L0EF8               pshs      Y                   * 0EF8 34 20          4
                    bsr       L0EE8               * 0EFA 8D EC          .l
                    std       -$02,S              * 0EFC ED 7E          m~
                    beq       L0F04               * 0EFE 27 04          '.
                    ldb       #214                * 0F00 C6 D6          FV
                    bra       L0EEF               * 0F02 20 EB           k
L0F04               ldy       $04,S               * 0F04 10 AE 64       ..d
                    os9       F$SUser             * 0F07 10 3F 1C       .?.
                    bcc       L0F18               * 0F0A 24 0C          $.
                    cmpb      #208                * 0F0C C1 D0          AP
                    bne       L0EEF               * 0F0E 26 DF          &_
                    tfr       Y,D                 * 0F10 1F 20          .
                    ldy       >L004B              * 0F12 10 BE 00 4B    .>.K
                    std       $09,Y               * 0F16 ED 29          m)
L0F18               clra                          * 0F18 4F             O
                    clrb                          * 0F19 5F             _
                    puls      PC,Y                * 0F1A 35 A0          5
L0F1C               clra                          * 0F1C 4F             O
                    std       >$01AD,Y            * 0F1D ED A9 01 AD    m).-
                    ldd       #-1                 * 0F21 CC FF FF       L..
                    rts                           * 0F24 39             9
L0F25               bcs       L0F1C               * 0F25 25 F5          %u
                    clra                          * 0F27 4F             O
                    clrb                          * 0F28 5F             _
                    rts                           * 0F29 39             9
L0F2A               lbsr      L0F35               * 0F2A 17 00 08       ...
                    lbsr      L089C               * 0F2D 17 F9 6C       .yl
L0F30               ldd       $02,S               * 0F30 EC 62          lb
                    os9       F$Exit              * 0F32 10 3F 06       .?.
L0F35               rts                           * 0F35 39             9
L0F36               fcb       $00                 * 0F36 00             .
                    fcb       $01                 * 0F37 01             .
                    fcb       $00                 * 0F38 00             .
                    fcb       $01                 * 0F39 01             .
                    fcb       $5E                 * 0F3A 5E             ^
                    fcb       $27                 * 0F3B 27             '
                    fcb       $10                 * 0F3C 10             .
                    fcb       $03                 * 0F3D 03             .
                    fcb       $E8                 * 0F3E E8             h
                    fcb       $00                 * 0F3F 00             .
                    fcb       $64                 * 0F40 64             d
                    fcb       $00                 * 0F41 00             .
                    fcb       $0A                 * 0F42 0A             .
                    fcb       $00                 * 0F43 00             .
                    fcb       $09                 * 0F44 09             .
                    fcb       $6C                 * 0F45 6C             l
                    fcb       $78                 * 0F46 78             x
                    fcb       $00                 * 0F47 00             .
                    fcb       $00                 * 0F48 00             .
                    fcb       $00                 * 0F49 00             .
                    fcb       $00                 * 0F4A 00             .
                    fcb       $00                 * 0F4B 00             .
                    fcb       $00                 * 0F4C 00             .
                    fcb       $00                 * 0F4D 00             .
                    fcb       $00                 * 0F4E 00             .
                    fcb       $01                 * 0F4F 01             .
                    fcb       $00                 * 0F50 00             .
                    fcb       $00                 * 0F51 00             .
                    fcb       $00                 * 0F52 00             .
                    fcb       $00                 * 0F53 00             .
                    fcb       $00                 * 0F54 00             .
                    fcb       $00                 * 0F55 00             .
                    fcb       $00                 * 0F56 00             .
                    fcb       $00                 * 0F57 00             .
                    fcb       $00                 * 0F58 00             .
                    fcb       $00                 * 0F59 00             .
                    fcb       $00                 * 0F5A 00             .
                    fcb       $00                 * 0F5B 00             .
                    fcb       $02                 * 0F5C 02             .
                    fcb       $00                 * 0F5D 00             .
                    fcb       $01                 * 0F5E 01             .
                    fcb       $00                 * 0F5F 00             .
                    fcb       $00                 * 0F60 00             .
                    fcb       $00                 * 0F61 00             .
                    fcb       $00                 * 0F62 00             .
                    fcb       $00                 * 0F63 00             .
                    fcb       $00                 * 0F64 00             .
                    fcb       $00                 * 0F65 00             .
                    fcb       $00                 * 0F66 00             .
                    fcb       $00                 * 0F67 00             .
                    fcb       $00                 * 0F68 00             .
                    fcb       $42                 * 0F69 42             B
                    fcb       $00                 * 0F6A 00             .
                    fcb       $02                 * 0F6B 02             .
                    fcb       $00                 * 0F6C 00             .
                    fcb       $00                 * 0F6D 00             .
                    fcb       $00                 * 0F6E 00             .
                    fcb       $00                 * 0F6F 00             .
                    fcb       $00                 * 0F70 00             .
                    fcb       $00                 * 0F71 00             .
                    fcb       $00                 * 0F72 00             .
                    fcb       $00                 * 0F73 00             .
                    fcb       $00                 * 0F74 00             .
                    fcb       $00                 * 0F75 00             .
                    fcb       $00                 * 0F76 00             .
                    fcb       $00                 * 0F77 00             .
                    fcb       $00                 * 0F78 00             .
                    fcb       $00                 * 0F79 00             .
                    fcb       $00                 * 0F7A 00             .
                    fcb       $00                 * 0F7B 00             .
                    fcb       $00                 * 0F7C 00             .
                    fcb       $00                 * 0F7D 00             .
                    fcb       $00                 * 0F7E 00             .
                    fcb       $00                 * 0F7F 00             .
                    fcb       $00                 * 0F80 00             .
                    fcb       $00                 * 0F81 00             .
                    fcb       $00                 * 0F82 00             .
                    fcb       $00                 * 0F83 00             .
                    fcb       $00                 * 0F84 00             .
                    fcb       $00                 * 0F85 00             .
                    fcb       $00                 * 0F86 00             .
                    fcb       $00                 * 0F87 00             .
                    fcb       $00                 * 0F88 00             .
                    fcb       $00                 * 0F89 00             .
                    fcb       $00                 * 0F8A 00             .
                    fcb       $00                 * 0F8B 00             .
                    fcb       $00                 * 0F8C 00             .
                    fcb       $00                 * 0F8D 00             .
                    fcb       $00                 * 0F8E 00             .
                    fcb       $00                 * 0F8F 00             .
                    fcb       $00                 * 0F90 00             .
                    fcb       $00                 * 0F91 00             .
                    fcb       $00                 * 0F92 00             .
                    fcb       $00                 * 0F93 00             .
                    fcb       $00                 * 0F94 00             .
                    fcb       $00                 * 0F95 00             .
                    fcb       $00                 * 0F96 00             .
                    fcb       $00                 * 0F97 00             .
                    fcb       $00                 * 0F98 00             .
                    fcb       $00                 * 0F99 00             .
                    fcb       $00                 * 0F9A 00             .
                    fcb       $00                 * 0F9B 00             .
                    fcb       $00                 * 0F9C 00             .
                    fcb       $00                 * 0F9D 00             .
                    fcb       $00                 * 0F9E 00             .
                    fcb       $00                 * 0F9F 00             .
                    fcb       $00                 * 0FA0 00             .
                    fcb       $00                 * 0FA1 00             .
                    fcb       $00                 * 0FA2 00             .
                    fcb       $00                 * 0FA3 00             .
                    fcb       $00                 * 0FA4 00             .
                    fcb       $00                 * 0FA5 00             .
                    fcb       $00                 * 0FA6 00             .
                    fcb       $00                 * 0FA7 00             .
                    fcb       $00                 * 0FA8 00             .
                    fcb       $00                 * 0FA9 00             .
                    fcb       $00                 * 0FAA 00             .
                    fcb       $00                 * 0FAB 00             .
                    fcb       $00                 * 0FAC 00             .
                    fcb       $00                 * 0FAD 00             .
                    fcb       $00                 * 0FAE 00             .
                    fcb       $00                 * 0FAF 00             .
                    fcb       $00                 * 0FB0 00             .
                    fcb       $00                 * 0FB1 00             .
                    fcb       $00                 * 0FB2 00             .
                    fcb       $00                 * 0FB3 00             .
                    fcb       $00                 * 0FB4 00             .
                    fcb       $00                 * 0FB5 00             .
                    fcb       $00                 * 0FB6 00             .
                    fcb       $00                 * 0FB7 00             .
                    fcb       $00                 * 0FB8 00             .
                    fcb       $00                 * 0FB9 00             .
                    fcb       $00                 * 0FBA 00             .
                    fcb       $00                 * 0FBB 00             .
                    fcb       $00                 * 0FBC 00             .
                    fcb       $00                 * 0FBD 00             .
                    fcb       $00                 * 0FBE 00             .
                    fcb       $00                 * 0FBF 00             .
                    fcb       $00                 * 0FC0 00             .
                    fcb       $00                 * 0FC1 00             .
                    fcb       $00                 * 0FC2 00             .
                    fcb       $00                 * 0FC3 00             .
                    fcb       $00                 * 0FC4 00             .
                    fcb       $00                 * 0FC5 00             .
                    fcb       $00                 * 0FC6 00             .
                    fcb       $00                 * 0FC7 00             .
                    fcb       $00                 * 0FC8 00             .
                    fcb       $00                 * 0FC9 00             .
                    fcb       $00                 * 0FCA 00             .
                    fcb       $00                 * 0FCB 00             .
                    fcb       $00                 * 0FCC 00             .
                    fcb       $00                 * 0FCD 00             .
                    fcb       $00                 * 0FCE 00             .
                    fcb       $00                 * 0FCF 00             .
                    fcb       $00                 * 0FD0 00             .
                    fcb       $00                 * 0FD1 00             .
                    fcb       $00                 * 0FD2 00             .
                    fcb       $00                 * 0FD3 00             .
                    fcb       $00                 * 0FD4 00             .
                    fcb       $00                 * 0FD5 00             .
                    fcb       $00                 * 0FD6 00             .
                    fcb       $00                 * 0FD7 00             .
                    fcb       $00                 * 0FD8 00             .
                    fcb       $00                 * 0FD9 00             .
                    fcb       $00                 * 0FDA 00             .
                    fcb       $00                 * 0FDB 00             .
                    fcb       $00                 * 0FDC 00             .
                    fcb       $00                 * 0FDD 00             .
                    fcb       $00                 * 0FDE 00             .
                    fcb       $00                 * 0FDF 00             .
                    fcb       $00                 * 0FE0 00             .
                    fcb       $00                 * 0FE1 00             .
                    fcb       $00                 * 0FE2 00             .
                    fcb       $00                 * 0FE3 00             .
                    fcb       $00                 * 0FE4 00             .
                    fcb       $00                 * 0FE5 00             .
                    fcb       $00                 * 0FE6 00             .
                    fcb       $00                 * 0FE7 00             .
                    fcb       $00                 * 0FE8 00             .
                    fcb       $00                 * 0FE9 00             .
                    fcb       $00                 * 0FEA 00             .
                    fcb       $00                 * 0FEB 00             .
                    fcb       $00                 * 0FEC 00             .
                    fcb       $00                 * 0FED 00             .
                    fcb       $00                 * 0FEE 00             .
                    fcb       $00                 * 0FEF 00             .
                    fcb       $00                 * 0FF0 00             .
                    fcb       $00                 * 0FF1 00             .
                    fcb       $00                 * 0FF2 00             .
                    fcb       $00                 * 0FF3 00             .
                    fcb       $00                 * 0FF4 00             .
                    fcb       $00                 * 0FF5 00             .
                    fcb       $00                 * 0FF6 00             .
                    fcb       $00                 * 0FF7 00             .
                    fcb       $00                 * 0FF8 00             .
                    fcb       $00                 * 0FF9 00             .
                    fcb       $00                 * 0FFA 00             .
                    fcb       $00                 * 0FFB 00             .
                    fcb       $00                 * 0FFC 00             .
                    fcb       $00                 * 0FFD 00             .
                    fcb       $00                 * 0FFE 00             .
                    fcb       $00                 * 0FFF 00             .
                    fcb       $00                 * 1000 00             .
                    fcb       $00                 * 1001 00             .
                    fcb       $00                 * 1002 00             .
                    fcb       $00                 * 1003 00             .
                    fcb       $00                 * 1004 00             .
                    fcb       $00                 * 1005 00             .
                    fcb       $00                 * 1006 00             .
                    fcb       $00                 * 1007 00             .
                    fcb       $00                 * 1008 00             .
                    fcb       $00                 * 1009 00             .
                    fcb       $00                 * 100A 00             .
                    fcb       $00                 * 100B 00             .
                    fcb       $00                 * 100C 00             .
                    fcb       $00                 * 100D 00             .
                    fcb       $00                 * 100E 00             .
                    fcb       $00                 * 100F 00             .
                    fcb       $00                 * 1010 00             .
                    fcb       $00                 * 1011 00             .
                    fcb       $00                 * 1012 00             .
                    fcb       $00                 * 1013 00             .
                    fcb       $00                 * 1014 00             .
                    fcb       $00                 * 1015 00             .
                    fcb       $00                 * 1016 00             .
                    fcb       $00                 * 1017 00             .
                    fcb       $00                 * 1018 00             .
                    fcb       $01                 * 1019 01             .
                    fcb       $01                 * 101A 01             .
                    fcb       $01                 * 101B 01             .
                    fcb       $01                 * 101C 01             .
                    fcb       $01                 * 101D 01             .
                    fcb       $01                 * 101E 01             .
                    fcb       $01                 * 101F 01             .
                    fcb       $01                 * 1020 01             .
                    fcb       $01                 * 1021 01             .
                    fcb       $11                 * 1022 11             .
                    fcb       $11                 * 1023 11             .
                    fcb       $01                 * 1024 01             .
                    fcb       $11                 * 1025 11             .
                    fcb       $11                 * 1026 11             .
                    fcb       $01                 * 1027 01             .
                    fcb       $01                 * 1028 01             .
                    fcb       $01                 * 1029 01             .
                    fcb       $01                 * 102A 01             .
                    fcb       $01                 * 102B 01             .
                    fcb       $01                 * 102C 01             .
                    fcb       $01                 * 102D 01             .
                    fcb       $01                 * 102E 01             .
                    fcb       $01                 * 102F 01             .
                    fcb       $01                 * 1030 01             .
                    fcb       $01                 * 1031 01             .
                    fcb       $01                 * 1032 01             .
                    fcb       $01                 * 1033 01             .
                    fcb       $01                 * 1034 01             .
                    fcb       $01                 * 1035 01             .
                    fcb       $01                 * 1036 01             .
                    fcb       $01                 * 1037 01             .
                    fcb       $01                 * 1038 01             .
                    fcc       "0               HHHHHHHHHH       BBBBBB" * 1039 30 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 48 48 48 48 48 48 48 48 48 48 20 20 20 20 20 20 20 42 42 42 42 42 42 0               HHHHHHHHHH       BBBBBB
                    fcb       $02                 * 1060 02             .
                    fcb       $02                 * 1061 02             .
                    fcb       $02                 * 1062 02             .
                    fcb       $02                 * 1063 02             .
                    fcb       $02                 * 1064 02             .
                    fcb       $02                 * 1065 02             .
                    fcb       $02                 * 1066 02             .
                    fcb       $02                 * 1067 02             .
                    fcb       $02                 * 1068 02             .
                    fcb       $02                 * 1069 02             .
                    fcb       $02                 * 106A 02             .
                    fcb       $02                 * 106B 02             .
                    fcb       $02                 * 106C 02             .
                    fcb       $02                 * 106D 02             .
                    fcb       $02                 * 106E 02             .
                    fcb       $02                 * 106F 02             .
                    fcb       $02                 * 1070 02             .
                    fcb       $02                 * 1071 02             .
                    fcb       $02                 * 1072 02             .
                    fcb       $02                 * 1073 02             .
                    fcc       "      DDDDDD"      * 1074 20 20 20 20 20 20 44 44 44 44 44 44       DDDDDD
                    fcb       $04                 * 1080 04             .
                    fcb       $04                 * 1081 04             .
                    fcb       $04                 * 1082 04             .
                    fcb       $04                 * 1083 04             .
                    fcb       $04                 * 1084 04             .
                    fcb       $04                 * 1085 04             .
                    fcb       $04                 * 1086 04             .
                    fcb       $04                 * 1087 04             .
                    fcb       $04                 * 1088 04             .
                    fcb       $04                 * 1089 04             .
                    fcb       $04                 * 108A 04             .
                    fcb       $04                 * 108B 04             .
                    fcb       $04                 * 108C 04             .
                    fcb       $04                 * 108D 04             .
                    fcb       $04                 * 108E 04             .
                    fcb       $04                 * 108F 04             .
                    fcb       $04                 * 1090 04             .
                    fcb       $04                 * 1091 04             .
                    fcb       $04                 * 1092 04             .
                    fcb       $04                 * 1093 04             .
                    fcc       "    "              * 1094 20 20 20 20
                    fcb       $01                 * 1098 01             .
                    fcb       $00                 * 1099 00             .
                    fcb       $00                 * 109A 00             .
                    fcb       $00                 * 109B 00             .
                    fcb       $01                 * 109C 01             .
                    fcb       $00                 * 109D 00             .
                    fcb       $09                 * 109E 09             .
                    fcc       "Suser"             * 109F 53 75 73 65 72 Suser
                    fcb       $00                 * 10A4 00             .

                    emod
eom                 equ       *
                    end
