                    nam       BBS.page
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       8
U0008               rmb       41
U0031               rmb       463
U0200               rmb       1
U0201               rmb       1
U0202               rmb       1
U0203               rmb       1
U0204               rmb       2
U0206               rmb       2
U0208               rmb       2
U020A               rmb       2
U020C               rmb       1
U020D               rmb       1
U020E               rmb       2
U0210               rmb       2
U0212               rmb       64
U0252               rmb       64
U0292               rmb       1
U0293               rmb       64
U02D3               rmb       200
U039B               rmb       200
U0463               rmb       1
U0464               rmb       599
size                equ       .

name                fcs       /BBS.page/          * 000D 42 42 53 2E 70 61 67 E5 BBS.page
L0015               fcb       $00                 * 0015 00             .
                    fcb       $00                 * 0016 00             .
L0017               fcc       "/dd/bbs/BBS.alias" * 0017 2F 64 64 2F 62 62 73 2F 42 42 53 2E 61 6C 69 61 73 /dd/bbs/BBS.alias
                    fcb       $0D                 * 0028 0D             .
L0029               fcc       "User not currently on-line!" * 0029 55 73 65 72 20 6E 6F 74 20 63 75 72 72 65 6E 74 6C 79 20 6F 6E 2D 6C 69 6E 65 21 User not currently on-line!
                    fcb       $0D                 * 0044 0D             .
L0045               fcc       "User not in the alias list!" * 0045 55 73 65 72 20 6E 6F 74 20 69 6E 20 74 68 65 20 61 6C 69 61 73 20 6C 69 73 74 21 User not in the alias list!
                    fcb       $0D                 * 0060 0D             .
L0061               fcc       "User name to page:" * 0061 55 73 65 72 20 6E 61 6D 65 20 74 6F 20 70 61 67 65 3A User name to page:
L0073               fcc       "Sending message now..." * 0073 53 65 6E 64 69 6E 67 20 6D 65 73 73 61 67 65 20 6E 6F 77 2E 2E 2E Sending message now...
                    fcb       $0D                 * 0089 0D             .
L008A               fcc       "Message recieved by user" * 008A 4D 65 73 73 61 67 65 20 72 65 63 69 65 76 65 64 20 62 79 20 75 73 65 72 Message recieved by user
                    fcb       $0D                 * 00A2 0D             .
L00A3               fcc       "Enter message to send:" * 00A3 45 6E 74 65 72 20 6D 65 73 73 61 67 65 20 74 6F 20 73 65 6E 64 3A Enter message to send:
L00B9               fcb       $07                 * 00B9 07             .
                    fcb       $07                 * 00BA 07             .
                    fcb       $07                 * 00BB 07             .
                    fcb       $07                 * 00BC 07             .
                    fcc       "Page from "        * 00BD 50 61 67 65 20 66 72 6F 6D 20 Page from
start               leax      >L0061,PC           * 00C7 30 8D FF 96    0...
                    ldy       #18                 * 00CB 10 8E 00 12    ....
                    lda       #1                  * 00CF 86 01          ..
                    os9       I$Write             * 00D1 10 3F 8A       .?.
                    lbcs      L034A               * 00D4 10 25 02 72    .%.r
                    leax      >U039B,U            * 00D8 30 C9 03 9B    0I..
                    ldy       #200                * 00DC 10 8E 00 C8    ...H
                    clra                          * 00E0 4F             O
                    os9       I$ReadLn            * 00E1 10 3F 8B       .?.
                    lbcs      L034A               * 00E4 10 25 02 62    .%.b
                    leax      >L0017,PC           * 00E8 30 8D FF 2B    0..+
                    lda       #1                  * 00EC 86 01          ..
                    os9       I$Open              * 00EE 10 3F 84       .?.
                    lbcs      L034A               * 00F1 10 25 02 55    .%.U
                    sta       >U0200,U            * 00F5 A7 C9 02 00    'I..
L00F9               leax      >U02D3,U            * 00F9 30 C9 02 D3    0I.S
                    ldy       #200                * 00FD 10 8E 00 C8    ...H
                    lda       >U0200,U            * 0101 A6 C9 02 00    &I..
                    os9       I$ReadLn            * 0105 10 3F 8B       .?.
                    lbcs      L0134               * 0108 10 25 00 28    .%.(
                    leay      >U039B,U            * 010C 31 C9 03 9B    1I..
L0110               lda       0,X                 * 0110 A6 84          &.
                    cmpa      #44                 * 0112 81 2C          .,
                    beq       L011E               * 0114 27 08          '.
                    anda      #223                * 0116 84 DF          ._
                    sta       ,X+                 * 0118 A7 80          '.
                    cmpa      #13                 * 011A 81 0D          ..
                    bne       L0110               * 011C 26 F2          &r
L011E               leax      >U02D3,U            * 011E 30 C9 02 D3    0I.S
                    leay      >U039B,U            * 0122 31 C9 03 9B    1I..
L0126               lda       ,Y+                 * 0126 A6 A0          &
                    cmpa      #13                 * 0128 81 0D          ..
                    beq       L0144               * 012A 27 18          '.
                    anda      #223                * 012C 84 DF          ._
                    cmpa      ,X+                 * 012E A1 80          !.
                    bne       L00F9               * 0130 26 C7          &G
                    bra       L0126               * 0132 20 F2           r
L0134               leax      >L0045,PC           * 0134 30 8D FF 0D    0...
                    ldy       #200                * 0138 10 8E 00 C8    ...H
                    lda       #1                  * 013C 86 01          ..
                    os9       I$WritLn            * 013E 10 3F 8C       .?.
                    lbra      L0349               * 0141 16 02 05       ...
L0144               lda       ,X+                 * 0144 A6 80          &.
                    cmpa      #44                 * 0146 81 2C          .,
                    bne       L00F9               * 0148 26 AF          &/
                    lbsr      L034D               * 014A 17 02 00       ...
                    std       >U020A,U            * 014D ED C9 02 0A    mI..
                    lda       >U0200,U            * 0151 A6 C9 02 00    &I..
                    pshs      U                   * 0155 34 40          4@
                    ldu       #0                  * 0157 CE 00 00       N..
                    ldx       #0                  * 015A 8E 00 00       ...
                    os9       I$Seek              * 015D 10 3F 88       .?.
                    lbcs      L034A               * 0160 10 25 01 E6    .%.f
                    os9       F$ID                * 0164 10 3F 0C       .?.
                    sty       >U0210,U            * 0167 10 AF C9 02 10 ./I..
L016C               leax      >U0463,U            * 016C 30 C9 04 63    0I.c
                    ldy       #200                * 0170 10 8E 00 C8    ...H
                    lda       >U0200,U            * 0174 A6 C9 02 00    &I..
                    os9       I$ReadLn            * 0178 10 3F 8B       .?.
                    lbcs      L034A               * 017B 10 25 01 CB    .%.K
L017F               lda       ,X+                 * 017F A6 80          &.
                    cmpa      #44                 * 0181 81 2C          .,
                    bne       L017F               * 0183 26 FA          &z
                    lda       #13                 * 0185 86 0D          ..
                    sta       -$01,X              * 0187 A7 1F          '.
                    lbsr      L034D               * 0189 17 01 C1       ..A
                    cmpd      >U0210,U            * 018C 10 A3 C9 02 10 .#I..
                    bne       L016C               * 0191 26 D9          &Y
                    clr       >U0202,U            * 0193 6F C9 02 02    oI..
L0197               lda       >U0202,U            * 0197 A6 C9 02 02    &I..
                    inca                          * 019B 4C             L
                    sta       >U0202,U            * 019C A7 C9 02 02    'I..
                    beq       L01B4               * 01A0 27 12          '.
                    leax      U0000,U             * 01A2 30 C4          0D
                    os9       F$GPrDsc            * 01A4 10 3F 18       .?.
                    bcs       L0197               * 01A7 25 EE          %n
                    ldd       U0008,U             * 01A9 EC 48          lH
                    cmpd      >U020A,U            * 01AB 10 A3 C9 02 0A .#I..
                    bne       L0197               * 01B0 26 E5          &e
                    bra       L01C4               * 01B2 20 10           .
L01B4               leax      >L0029,PC           * 01B4 30 8D FE 71    0.~q
                    ldy       #200                * 01B8 10 8E 00 C8    ...H
                    lda       #1                  * 01BC 86 01          ..
                    os9       I$WritLn            * 01BE 10 3F 8C       .?.
                    lbra      L0349               * 01C1 16 01 85       ...
L01C4               lbsr      L0245               * 01C4 17 00 7E       ..~
                    leax      >L00A3,PC           * 01C7 30 8D FE D8    0.~X
                    ldy       #22                 * 01CB 10 8E 00 16    ....
                    lda       #1                  * 01CF 86 01          ..
                    os9       I$Write             * 01D1 10 3F 8A       .?.
                    leax      >U02D3,U            * 01D4 30 C9 02 D3    0I.S
                    ldy       #200                * 01D8 10 8E 00 C8    ...H
                    clra                          * 01DC 4F             O
                    os9       I$ReadLn            * 01DD 10 3F 8B       .?.
                    lbcs      L034A               * 01E0 10 25 01 66    .%.f
                    leax      >L0073,PC           * 01E4 30 8D FE 8B    0.~.
                    ldy       #200                * 01E8 10 8E 00 C8    ...H
                    lda       #1                  * 01EC 86 01          ..
                    os9       I$WritLn            * 01EE 10 3F 8C       .?.
                    lda       #47                 * 01F1 86 2F          ./
                    sta       >U0292,U            * 01F3 A7 C9 02 92    'I..
                    leax      >U0292,U            * 01F7 30 C9 02 92    0I..
                    lda       #2                  * 01FB 86 02          ..
                    os9       I$Open              * 01FD 10 3F 84       .?.
                    lbcs      L034A               * 0200 10 25 01 46    .%.F
                    sta       >U0201,U            * 0204 A7 C9 02 01    'I..
                    leax      >L00B9,PC           * 0208 30 8D FE AD    0.~-
                    ldy       #14                 * 020C 10 8E 00 0E    ....
                    lda       >U0201,U            * 0210 A6 C9 02 01    &I..
                    os9       I$Write             * 0214 10 3F 8A       .?.
                    leax      >U0463,U            * 0217 30 C9 04 63    0I.c
                    ldy       #200                * 021B 10 8E 00 C8    ...H
                    os9       I$WritLn            * 021F 10 3F 8C       .?.
                    leax      >U02D3,U            * 0222 30 C9 02 D3    0I.S
                    ldy       #200                * 0226 10 8E 00 C8    ...H
                    lda       >U0201,U            * 022A A6 C9 02 01    &I..
                    os9       I$WritLn            * 022E 10 3F 8C       .?.
                    lbcs      L034A               * 0231 10 25 01 15    .%..
                    leax      >L008A,PC           * 0235 30 8D FE 51    0.~Q
                    ldy       #200                * 0239 10 8E 00 C8    ...H
                    lda       #1                  * 023D 86 01          ..
                    os9       I$WritLn            * 023F 10 3F 8C       .?.
                    lbra      L0349               * 0242 16 01 04       ...
L0245               leax      >L0015,PC           * 0245 30 8D FD CC    0.}L
                    tfr       X,D                 * 0249 1F 10          ..
                    ldx       #76                 * 024B 8E 00 4C       ..L
                    ldy       #2                  * 024E 10 8E 00 02    ....
                    pshs      U                   * 0252 34 40          4@
                    leau      >U0212,U            * 0254 33 C9 02 12    3I..
                    os9       F$CpyMem            * 0258 10 3F 1B       .?.
                    lbcs      L034A               * 025B 10 25 00 EB    .%.k
                    puls      U                   * 025F 35 40          5@
                    leax      >L0015,PC           * 0261 30 8D FD B0    0.}0
                    tfr       X,D                 * 0265 1F 10          ..
                    ldx       >U0212,U            * 0267 AE C9 02 12    .I..
                    ldy       #64                 * 026B 10 8E 00 40    ...@
                    pshs      U                   * 026F 34 40          4@
                    leau      >U0212,U            * 0271 33 C9 02 12    3I..
                    os9       F$CpyMem            * 0275 10 3F 1B       .?.
                    puls      U                   * 0278 35 40          5@
                    leax      >U0212,U            * 027A 30 C9 02 12    0I..
                    tfr       X,D                 * 027E 1F 10          ..
                    ldx       #136                * 0280 8E 00 88       ...
                    ldy       #2                  * 0283 10 8E 00 02    ....
                    pshs      U                   * 0287 34 40          4@
                    leau      >U0204,U            * 0289 33 C9 02 04    3I..
                    os9       F$CpyMem            * 028D 10 3F 1B       .?.
                    lbcs      L034A               * 0290 10 25 00 B6    .%.6
                    puls      U                   * 0294 35 40          5@
                    leax      >U0212,U            * 0296 30 C9 02 12    0I..
                    tfr       X,D                 * 029A 1F 10          ..
                    ldx       >U0204,U            * 029C AE C9 02 04    .I..
                    ldy       #64                 * 02A0 10 8E 00 40    ...@
                    pshs      U                   * 02A4 34 40          4@
                    leau      >U0252,U            * 02A6 33 C9 02 52    3I.R
                    os9       F$CpyMem            * 02AA 10 3F 1B       .?.
                    lbcs      L034A               * 02AD 10 25 00 99    .%..
                    puls      U                   * 02B1 35 40          5@
                    ldb       <U0031,U            * 02B3 E6 C8 31       fH1
                    lsrb                          * 02B6 54             T
                    lsrb                          * 02B7 54             T
                    leax      >U0252,U            * 02B8 30 C9 02 52    0I.R
                    lda       B,X                 * 02BC A6 85          &.
                    pshs      A                   * 02BE 34 02          4.
                    ldb       <U0031,U            * 02C0 E6 C8 31       fH1
                    andb      #3                  * 02C3 C4 03          D.
                    lda       #64                 * 02C5 86 40          .@
                    mul                           * 02C7 3D             =
                    puls      A                   * 02C8 35 02          5.
                    addb      #3                  * 02CA CB 03          K.
                    tfr       D,X                 * 02CC 1F 01          ..
                    leay      >U0212,U            * 02CE 31 C9 02 12    1I..
                    tfr       Y,D                 * 02D2 1F 20          .
                    ldy       #2                  * 02D4 10 8E 00 02    ....
                    pshs      U                   * 02D8 34 40          4@
                    leau      >U0206,U            * 02DA 33 C9 02 06    3I..
                    os9       F$CpyMem            * 02DE 10 3F 1B       .?.
                    puls      U                   * 02E1 35 40          5@
                    ldx       >U0206,U            * 02E3 AE C9 02 06    .I..
                    leax      $04,X               * 02E7 30 04          0.
                    leay      >U0212,U            * 02E9 31 C9 02 12    1I..
                    tfr       Y,D                 * 02ED 1F 20          .
                    ldy       #2                  * 02EF 10 8E 00 02    ....
                    pshs      U                   * 02F3 34 40          4@
                    leau      >U0206,U            * 02F5 33 C9 02 06    3I..
                    os9       F$CpyMem            * 02F9 10 3F 1B       .?.
                    puls      U                   * 02FC 35 40          5@
                    leax      >U0212,U            * 02FE 30 C9 02 12    0I..
                    tfr       X,D                 * 0302 1F 10          ..
                    ldx       >U0206,U            * 0304 AE C9 02 06    .I..
                    leax      $04,X               * 0308 30 04          0.
                    ldy       #2                  * 030A 10 8E 00 02    ....
                    pshs      U                   * 030E 34 40          4@
                    leau      >U0208,U            * 0310 33 C9 02 08    3I..
                    os9       F$CpyMem            * 0314 10 3F 1B       .?.
                    puls      U                   * 0317 35 40          5@
                    ldx       >U0206,U            * 0319 AE C9 02 06    .I..
                    ldd       >U0208,U            * 031D EC C9 02 08    lI..
                    leax      D,X                 * 0321 30 8B          0.
                    leay      >U0212,U            * 0323 31 C9 02 12    1I..
                    tfr       Y,D                 * 0327 1F 20          .
                    ldy       #64                 * 0329 10 8E 00 40    ...@
                    pshs      U                   * 032D 34 40          4@
                    leau      >U0293,U            * 032F 33 C9 02 93    3I..
                    os9       F$CpyMem            * 0333 10 3F 1B       .?.
                    puls      U                   * 0336 35 40          5@
                    leax      >U0293,U            * 0338 30 C9 02 93    0I..
L033C               lda       ,X+                 * 033C A6 80          &.
                    bpl       L033C               * 033E 2A FC          *|
                    anda      #127                * 0340 84 7F          ..
                    sta       -$01,X              * 0342 A7 1F          '.
                    lda       #13                 * 0344 86 0D          ..
                    sta       0,X                 * 0346 A7 84          '.
                    rts                           * 0348 39             9
L0349               clrb                          * 0349 5F             _
L034A               os9       F$Exit              * 034A 10 3F 06       .?.
L034D               pshs      Y                   * 034D 34 20          4
L034F               lda       ,X+                 * 034F A6 80          &.
                    cmpa      #13                 * 0351 81 0D          ..
                    lbeq      L043E               * 0353 10 27 00 E7    .'.g
                    cmpa      #48                 * 0357 81 30          .0
                    bcs       L034F               * 0359 25 F4          %t
                    cmpa      #57                 * 035B 81 39          .9
                    bhi       L034F               * 035D 22 F0          "p
                    leax      -$01,X              * 035F 30 1F          0.
L0361               lda       ,X+                 * 0361 A6 80          &.
                    cmpa      #48                 * 0363 81 30          .0
                    bcs       L036D               * 0365 25 06          %.
                    cmpa      #57                 * 0367 81 39          .9
                    bhi       L036D               * 0369 22 02          ".
                    bra       L0361               * 036B 20 F4           t
L036D               pshs      X                   * 036D 34 10          4.
                    leax      -$01,X              * 036F 30 1F          0.
                    clr       >U020C,U            * 0371 6F C9 02 0C    oI..
                    clr       >U020D,U            * 0375 6F C9 02 0D    oI..
                    ldd       #1                  * 0379 CC 00 01       L..
                    std       >U020E,U            * 037C ED C9 02 0E    mI..
L0380               lda       ,-X                 * 0380 A6 82          &.
                    cmpa      #48                 * 0382 81 30          .0
                    bcs       L03CA               * 0384 25 44          %D
                    cmpa      #57                 * 0386 81 39          .9
                    bhi       L03CA               * 0388 22 40          "@
                    suba      #48                 * 038A 80 30          .0
                    sta       >U0203,U            * 038C A7 C9 02 03    'I..
                    ldd       #0                  * 0390 CC 00 00       L..
L0393               tst       >U0203,U            * 0393 6D C9 02 03    mI..
                    beq       L03A3               * 0397 27 0A          '.
                    addd      >U020E,U            * 0399 E3 C9 02 0E    cI..
                    dec       >U0203,U            * 039D 6A C9 02 03    jI..
                    bra       L0393               * 03A1 20 F0           p
L03A3               addd      >U020C,U            * 03A3 E3 C9 02 0C    cI..
                    std       >U020C,U            * 03A7 ED C9 02 0C    mI..
                    lda       #10                 * 03AB 86 0A          ..
                    sta       >U0203,U            * 03AD A7 C9 02 03    'I..
                    ldd       #0                  * 03B1 CC 00 00       L..
L03B4               tst       >U0203,U            * 03B4 6D C9 02 03    mI..
                    beq       L03C4               * 03B8 27 0A          '.
                    addd      >U020E,U            * 03BA E3 C9 02 0E    cI..
                    dec       >U0203,U            * 03BE 6A C9 02 03    jI..
                    bra       L03B4               * 03C2 20 F0           p
L03C4               std       >U020E,U            * 03C4 ED C9 02 0E    mI..
                    bra       L0380               * 03C8 20 B6           6
L03CA               ldd       >U020C,U            * 03CA EC C9 02 0C    lI..
                    puls      X                   * 03CE 35 10          5.
                    puls      PC,Y                * 03D0 35 A0          5
                    fcb       $ED                 * 03D2 ED             m
                    fcb       $C9                 * 03D3 C9             I
                    fcb       $02                 * 03D4 02             .
                    fcb       $0C                 * 03D5 0C             .
                    fcb       $86                 * 03D6 86             .
                    fcb       $30                 * 03D7 30             0
                    fcb       $A7                 * 03D8 A7             '
                    fcb       $84                 * 03D9 84             .
                    fcb       $A7                 * 03DA A7             '
                    fcb       $01                 * 03DB 01             .
                    fcb       $A7                 * 03DC A7             '
                    fcb       $02                 * 03DD 02             .
                    fcb       $A7                 * 03DE A7             '
                    fcb       $03                 * 03DF 03             .
                    fcb       $A7                 * 03E0 A7             '
                    fcb       $04                 * 03E1 04             .
                    fcb       $CC                 * 03E2 CC             L
                    fcb       $27                 * 03E3 27             '
                    fcb       $10                 * 03E4 10             .
                    fcb       $ED                 * 03E5 ED             m
                    fcb       $C9                 * 03E6 C9             I
                    fcb       $02                 * 03E7 02             .
                    fcb       $0E                 * 03E8 0E             .
                    fcb       $EC                 * 03E9 EC             l
                    fcb       $C9                 * 03EA C9             I
                    fcb       $02                 * 03EB 02             .
                    fcb       $0C                 * 03EC 0C             .
                    fcb       $17                 * 03ED 17             .
                    fcb       $00                 * 03EE 00             .
                    fcb       $39                 * 03EF 39             9
                    fcb       $CC                 * 03F0 CC             L
                    fcb       $03                 * 03F1 03             .
                    fcb       $E8                 * 03F2 E8             h
                    fcb       $ED                 * 03F3 ED             m
                    fcb       $C9                 * 03F4 C9             I
                    fcb       $02                 * 03F5 02             .
                    fcb       $0E                 * 03F6 0E             .
                    fcb       $EC                 * 03F7 EC             l
                    fcb       $C9                 * 03F8 C9             I
                    fcb       $02                 * 03F9 02             .
                    fcb       $0C                 * 03FA 0C             .
                    fcb       $8D                 * 03FB 8D             .
                    fcb       $2C                 * 03FC 2C             ,
                    fcb       $CC                 * 03FD CC             L
                    fcb       $00                 * 03FE 00             .
                    fcb       $64                 * 03FF 64             d
                    fcb       $ED                 * 0400 ED             m
                    fcb       $C9                 * 0401 C9             I
                    fcb       $02                 * 0402 02             .
                    fcb       $0E                 * 0403 0E             .
                    fcb       $EC                 * 0404 EC             l
                    fcb       $C9                 * 0405 C9             I
                    fcb       $02                 * 0406 02             .
                    fcb       $0C                 * 0407 0C             .
                    fcb       $8D                 * 0408 8D             .
                    fcb       $1F                 * 0409 1F             .
                    fcb       $CC                 * 040A CC             L
                    fcb       $00                 * 040B 00             .
                    fcb       $0A                 * 040C 0A             .
                    fcb       $ED                 * 040D ED             m
                    fcb       $C9                 * 040E C9             I
                    fcb       $02                 * 040F 02             .
                    fcb       $0E                 * 0410 0E             .
                    fcb       $EC                 * 0411 EC             l
                    fcb       $C9                 * 0412 C9             I
                    fcb       $02                 * 0413 02             .
                    fcb       $0C                 * 0414 0C             .
                    fcb       $8D                 * 0415 8D             .
                    fcb       $12                 * 0416 12             .
                    fcb       $CC                 * 0417 CC             L
                    fcb       $00                 * 0418 00             .
                    fcb       $01                 * 0419 01             .
                    fcb       $ED                 * 041A ED             m
                    fcb       $C9                 * 041B C9             I
                    fcb       $02                 * 041C 02             .
                    fcb       $0E                 * 041D 0E             .
                    fcb       $EC                 * 041E EC             l
                    fcb       $C9                 * 041F C9             I
                    fcb       $02                 * 0420 02             .
                    fcb       $0C                 * 0421 0C             .
                    fcb       $8D                 * 0422 8D             .
                    fcb       $05                 * 0423 05             .
                    fcb       $86                 * 0424 86             .
                    fcb       $0D                 * 0425 0D             .
                    fcb       $A7                 * 0426 A7             '
                    fcb       $84                 * 0427 84             .
                    fcb       $39                 * 0428 39             9
                    fcb       $A3                 * 0429 A3             #
                    fcb       $C9                 * 042A C9             I
                    fcb       $02                 * 042B 02             .
                    fcb       $0E                 * 042C 0E             .
                    fcb       $25                 * 042D 25             %
                    fcb       $04                 * 042E 04             .
                    fcb       $6C                 * 042F 6C             l
                    fcb       $84                 * 0430 84             .
                    fcb       $20                 * 0431 20
                    fcb       $F6                 * 0432 F6             v
                    fcb       $E3                 * 0433 E3             c
                    fcb       $C9                 * 0434 C9             I
                    fcb       $02                 * 0435 02             .
                    fcb       $0E                 * 0436 0E             .
                    fcb       $ED                 * 0437 ED             m
                    fcb       $C9                 * 0438 C9             I
                    fcb       $02                 * 0439 02             .
                    fcb       $0C                 * 043A 0C             .
                    fcb       $30                 * 043B 30             0
                    fcb       $01                 * 043C 01             .
                    fcb       $39                 * 043D 39             9
L043E               ldb       #1                  * 043E C6 01          F.
                    lbra      L034A               * 0440 16 FF 07       ...

                    emod
eom                 equ       *
                    end
