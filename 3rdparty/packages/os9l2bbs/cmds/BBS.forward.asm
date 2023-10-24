                    nam       BBS.forward
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
U0008               rmb       2
U000A               rmb       2
U000C               rmb       2
U000E               rmb       2
U0010               rmb       6
U0016               rmb       2
U0018               rmb       2
U001A               rmb       2
U001C               rmb       18
U002E               rmb       1
U002F               rmb       1
U0030               rmb       2
U0032               rmb       2
U0034               rmb       2
U0036               rmb       6
U003C               rmb       3
U003F               rmb       1
U0040               rmb       2
U0042               rmb       1
U0043               rmb       6
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

name                fcs       /BBS.forward/       * 000D 42 42 53 2E 66 6F 72 77 61 72 E4 BBS.forward
                    fcc       "Copyright (C) 1988" * 0018 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 Copyright (C) 1988
                    fcc       "By Keith Alphonso" * 002A 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F By Keith Alphonso
                    fcc       "Licenced to Alpha Software Technologies" * 003B 4C 69 63 65 6E 63 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licenced to Alpha Software Technologies
                    fcc       "All rights reserved" * 0062 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 All rights reserved
                    fcb       $EC                 * 0075 EC             l
                    fcb       $E6                 * 0076 E6             f
                    fcb       $EA                 * 0077 EA             j
                    fcb       $F5                 * 0078 F5             u
                    fcb       $E9                 * 0079 E9             i
                    fcb       $A0                 * 007A A0
                    fcb       $E2                 * 007B E2             b
                    fcb       $ED                 * 007C ED             m
                    fcb       $F1                 * 007D F1             q
                    fcb       $E9                 * 007E E9             i
                    fcb       $F0                 * 007F F0             p
                    fcb       $EF                 * 0080 EF             o
                    fcb       $F4                 * 0081 F4             t
                    fcb       $F0                 * 0082 F0             p
L0083               fcc       "High message is #" * 0083 48 69 67 68 20 6D 65 73 73 61 67 65 20 69 73 20 23 High message is #
L0094               fcb       $00                 * 0094 00             .
                    fcb       $11                 * 0095 11             .
L0096               fcc       "Enter starting message #" * 0096 45 6E 74 65 72 20 73 74 61 72 74 69 6E 67 20 6D 65 73 73 61 67 65 20 23 Enter starting message #
                    fcb       $0D                 * 00AE 0D             .
L00AF               fcc       ">"                 * 00AF 3E             >
L00B0               fcc       "BBS.msg.inx"       * 00B0 42 42 53 2E 6D 73 67 2E 69 6E 78 BBS.msg.inx
                    fcb       $0D                 * 00BB 0D             .
L00BC               fcc       "BBS.msg"           * 00BC 42 42 53 2E 6D 73 67 BBS.msg
                    fcb       $0D                 * 00C3 0D             .
L00C4               fcc       "******   DELETED   ******" * 00C4 2A 2A 2A 2A 2A 2A 20 20 20 44 45 4C 45 54 45 44 20 20 20 2A 2A 2A 2A 2A 2A ******   DELETED   ******
                    fcb       $0D                 * 00DD 0D             .
L00DE               fcc       "Message :"         * 00DE 4D 65 73 73 61 67 65 20 3A Message :
L00E7               fcc       "From    :"         * 00E7 46 72 6F 6D 20 20 20 20 3A From    :
L00F0               fcc       "To      :"         * 00F0 54 6F 20 20 20 20 20 20 3A To      :
L00F9               fcc       "Left on :"         * 00F9 4C 65 66 74 20 6F 6E 20 3A Left on :
L0102               fcc       "About   :"         * 0102 41 62 6F 75 74 20 20 20 3A About   :
L010B               fcb       $00                 * 010B 00             .
                    fcb       $09                 * 010C 09             .
L010D               fcc       "----------------------------------------------------------------" * 010D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 014D 0D             .
L014E               fcb       $0A                 * 014E 0A             .
                    fcb       $0A                 * 014F 0A             .
                    fcb       $0D                 * 0150 0D             .
L0151               fcc       "Press <SPACE> to skip a message" * 0151 50 72 65 73 73 20 3C 53 50 41 43 45 3E 20 74 6F 20 73 6B 69 70 20 61 20 6D 65 73 73 61 67 65 Press <SPACE> to skip a message
                    fcb       $0A                 * 0170 0A             .
                    fcb       $0D                 * 0171 0D             .
L0172               fcc       "BBS.msg.lst"       * 0172 42 42 53 2E 6D 73 67 2E 6C 73 74 BBS.msg.lst
                    fcb       $0D                 * 017D 0D             .
L017E               fcc       "/dd/bbs/BBS.userstats" * 017E 2F 64 64 2F 62 62 73 2F 42 42 53 2E 75 73 65 72 73 74 61 74 73 /dd/bbs/BBS.userstats
                    fcb       $0D                 * 0193 0D             .
L0194               fcc       "/dd/bbs/BBS.alias" * 0194 2F 64 64 2F 62 62 73 2F 42 42 53 2E 61 6C 69 61 73 /dd/bbs/BBS.alias
                    fcb       $0D                 * 01A5 0D             .
L01A6               fcc       "Unknown User"      * 01A6 55 6E 6B 6E 6F 77 6E 20 55 73 65 72 Unknown User
                    fcb       $0D                 * 01B2 0D             .
L01B3               fcc       "All Users"         * 01B3 41 6C 6C 20 55 73 65 72 73 All Users
                    fcb       $0D                 * 01BC 0D             .

start               os9       F$ID                * 01BD 10 3F 0C       .?.
                    sty       U000A,U             * 01C0 10 AF 4A       ./J
                    ldd       #0                  * 01C3 CC 00 00       L..
                    std       U0008,U             * 01C6 ED 48          mH
                    ldy       #0                  * 01C8 10 8E 00 00    ....
                    os9       F$SUser             * 01CC 10 3F 1C       .?.
                    leax      >L00B0,PC           * 01CF 30 8D FE DD    0.~]
                    lda       #1                  * 01D3 86 01          ..
                    os9       I$Open              * 01D5 10 3F 84       .?.
                    lbcs      L062E               * 01D8 10 25 04 52    .%.R
                    sta       U0001,U             * 01DC A7 41          'A
                    leax      >L0172,PC           * 01DE 30 8D FF 90    0...
                    lda       #3                  * 01E2 86 03          ..
                    os9       I$Open              * 01E4 10 3F 84       .?.
                    bcc       L01F8               * 01E7 24 0F          $.
                    cmpb      #216                * 01E9 C1 D8          AX
                    lbne      L062E               * 01EB 10 26 04 3F    .&.?
                    ldb       #11                 * 01EF C6 0B          F.
                    os9       I$Create            * 01F1 10 3F 83       .?.
                    lbcs      L062E               * 01F4 10 25 04 36    .%.6
L01F8               sta       U0003,U             * 01F8 A7 43          'C
                    leax      >L00BC,PC           * 01FA 30 8D FE BE    0.~>
                    lda       #1                  * 01FE 86 01          ..
                    os9       I$Open              * 0200 10 3F 84       .?.
                    lbcs      L062E               * 0203 10 25 04 27    .%.'
                    sta       U0002,U             * 0207 A7 42          'B
                    leax      <U005C,U            * 0209 30 C8 5C       0H\
                    ldy       #64                 * 020C 10 8E 00 40    ...@
                    lda       U0001,U             * 0210 A6 41          &A
                    os9       I$Read              * 0212 10 3F 89       .?.
                    lbcs      L062E               * 0215 10 25 04 15    .%..
                    ldd       <U005C,U            * 0219 EC C8 5C       lH\
                    leax      <U0036,U            * 021C 30 C8 36       0H6
                    lbsr      L06A1               * 021F 17 04 7F       ...
                    leax      >L0083,PC           * 0222 30 8D FE 5D    0.~]
                    ldy       >L0094,PC           * 0226 10 AE 8D FE 69 ...~i
                    lda       #1                  * 022B 86 01          ..
                    os9       I$Write             * 022D 10 3F 8A       .?.
                    lbcs      L062E               * 0230 10 25 03 FA    .%.z
                    leax      <U0036,U            * 0234 30 C8 36       0H6
                    ldy       #6                  * 0237 10 8E 00 06    ....
                    os9       I$WritLn            * 023B 10 3F 8C       .?.
                    lbcs      L062E               * 023E 10 25 03 EC    .%.l
                    leax      >L0096,PC           * 0242 30 8D FE 50    0.~P
                    ldy       #200                * 0246 10 8E 00 C8    ...H
                    lda       #1                  * 024A 86 01          ..
                    os9       I$WritLn            * 024C 10 3F 8C       .?.
                    lbcs      L062E               * 024F 10 25 03 DB    .%.[
                    leax      >L00AF,PC           * 0253 30 8D FE 58    0.~X
                    ldy       #1                  * 0257 10 8E 00 01    ....
                    os9       I$Write             * 025B 10 3F 8A       .?.
                    lbcs      L062E               * 025E 10 25 03 CC    .%.L
                    leax      <U0043,U            * 0262 30 C8 43       0HC
                    ldy       #6                  * 0265 10 8E 00 06    ....
                    clra                          * 0269 4F             O
                    os9       I$ReadLn            * 026A 10 3F 8B       .?.
                    lbcs      L062E               * 026D 10 25 03 BD    .%.=
                    clr       <U0042,U            * 0271 6F C8 42       oHB
                    leax      <U0043,U            * 0274 30 C8 43       0HC
                    lbsr      L0631               * 0277 17 03 B7       ..7
                    cmpd      #1                  * 027A 10 83 00 01    ....
                    lbcs      L062D               * 027E 10 25 03 AB    .%.+
                    cmpd      <U005C,U            * 0282 10 A3 C8 5C    .#H\
                    lbhi      L062D               * 0286 10 22 03 A3    .".#
                    std       <U0036,U            * 028A ED C8 36       mH6
                    clr       <U0049,U            * 028D 6F C8 49       oHI
                    clr       <U004A,U            * 0290 6F C8 4A       oHJ
                    lda       #6                  * 0293 86 06          ..
                    sta       U0005,U             * 0295 A7 45          'E
                    ldd       <U0036,U            * 0297 EC C8 36       lH6
L029A               aslb                          * 029A 58             X
                    rola                          * 029B 49             I
                    rol       <U004A,U            * 029C 69 C8 4A       iHJ
                    dec       U0005,U             * 029F 6A 45          jE
                    bne       L029A               * 02A1 26 F7          &w
                    std       <U004B,U            * 02A3 ED C8 4B       mHK
                    ldx       <U0049,U            * 02A6 AE C8 49       .HI
                    lda       U0001,U             * 02A9 A6 41          &A
                    pshs      U                   * 02AB 34 40          4@
                    ldu       <U004B,U            * 02AD EE C8 4B       nHK
                    os9       I$Seek              * 02B0 10 3F 88       .?.
                    lbcs      L062E               * 02B3 10 25 03 77    .%.w
                    puls      U                   * 02B7 35 40          5@
                    ldd       <U0036,U            * 02B9 EC C8 36       lH6
                    subd      #1                  * 02BC 83 00 01       ...
                    std       <U0036,U            * 02BF ED C8 36       mH6
L02C2               lda       U0003,U             * 02C2 A6 43          &C
                    leax      <U0032,U            * 02C4 30 C8 32       0H2
                    ldy       #4                  * 02C7 10 8E 00 04    ....
                    os9       I$Read              * 02CB 10 3F 89       .?.
                    bcs       L02FD               * 02CE 25 2D          %-
                    ldd       <U0032,U            * 02D0 EC C8 32       lH2
                    cmpd      U000A,U             * 02D3 10 A3 4A       .#J
                    bne       L02C2               * 02D6 26 EA          &j
                    ldd       <U0034,U            * 02D8 EC C8 34       lH4
                    cmpd      <U005C,U            * 02DB 10 A3 C8 5C    .#H\
                    bcc       L0314               * 02DF 24 33          $3
                    pshs      U                   * 02E1 34 40          4@
                    lda       U0003,U             * 02E3 A6 43          &C
                    ldb       #5                  * 02E5 C6 05          F.
                    os9       I$GetStt            * 02E7 10 3F 8D       .?.
                    leau      -$02,U              * 02EA 33 5E          3^
                    os9       I$Seek              * 02EC 10 3F 88       .?.
                    puls      U                   * 02EF 35 40          5@
                    leax      <U005C,U            * 02F1 30 C8 5C       0H\
                    ldy       #2                  * 02F4 10 8E 00 02    ....
                    os9       I$Write             * 02F8 10 3F 8A       .?.
                    bra       L0314               * 02FB 20 17           .
L02FD               cmpb      #211                * 02FD C1 D3          AS
                    lbne      L062E               * 02FF 10 26 03 2B    .&.+
                    lda       U0003,U             * 0303 A6 43          &C
                    leax      U000A,U             * 0305 30 4A          0J
                    ldy       #2                  * 0307 10 8E 00 02    ....
                    os9       I$Write             * 030B 10 3F 8A       .?.
                    leax      <U005C,U            * 030E 30 C8 5C       0H\
                    os9       I$Write             * 0311 10 3F 8A       .?.
L0314               lda       U0003,U             * 0314 A6 43          &C
                    os9       I$Close             * 0316 10 3F 8F       .?.
                    leax      >L0151,PC           * 0319 30 8D FE 34    0.~4
                    ldy       #200                * 031D 10 8E 00 C8    ...H
                    lda       #1                  * 0321 86 01          ..
                    os9       I$WritLn            * 0323 10 3F 8C       .?.
L0326               lda       U0001,U             * 0326 A6 41          &A
                    ldy       #64                 * 0328 10 8E 00 40    ...@
                    leax      >U00EC,U            * 032C 30 C9 00 EC    0I.l
                    os9       I$Read              * 0330 10 3F 89       .?.
                    lbcs      L0586               * 0333 10 25 02 4F    .%.O
                    ldd       <U0036,U            * 0337 EC C8 36       lH6
                    addd      #1                  * 033A C3 00 01       C..
                    std       <U0036,U            * 033D ED C8 36       mH6
                    leax      >L014E,PC           * 0340 30 8D FE 0A    0.~.
                    ldy       #2                  * 0344 10 8E 00 02    ....
                    lda       #1                  * 0348 86 01          ..
                    os9       I$WritLn            * 034A 10 3F 8C       .?.
                    ldd       <U0036,U            * 034D EC C8 36       lH6
                    leax      <U003C,U            * 0350 30 C8 3C       0H<
                    lbsr      L06A1               * 0353 17 03 4B       ..K
                    leax      >L00DE,PC           * 0356 30 8D FD 84    0.}.
                    ldy       >L010B,PC           * 035A 10 AE 8D FD AC ...},
                    lda       #1                  * 035F 86 01          ..
                    os9       I$Write             * 0361 10 3F 8A       .?.
                    lbcs      L062E               * 0364 10 25 02 C6    .%.F
                    leax      <U003C,U            * 0368 30 C8 3C       0H<
L036B               lda       ,X+                 * 036B A6 80          &.
                    cmpa      #32                 * 036D 81 20          .
                    beq       L036B               * 036F 27 FA          'z
                    leax      -$01,X              * 0371 30 1F          0.
                    ldy       #6                  * 0373 10 8E 00 06    ....
                    lda       #1                  * 0377 86 01          ..
                    os9       I$WritLn            * 0379 10 3F 8C       .?.
                    lbcs      L062E               * 037C 10 25 02 AE    .%..
                    ldd       >U00EC,U            * 0380 EC C9 00 EC    lI.l
                    cmpd      #-1                 * 0384 10 83 FF FF    ....
                    lbeq      L0501               * 0388 10 27 01 75    .'.u
                    leax      >L00E7,PC           * 038C 30 8D FD 57    0.}W
                    ldy       >L010B,PC           * 0390 10 AE 8D FD 76 ...}v
                    lda       #1                  * 0395 86 01          ..
                    os9       I$Write             * 0397 10 3F 8A       .?.
                    leax      >U00F0,U            * 039A 30 C9 00 F0    0I.p
                    ldy       #200                * 039E 10 8E 00 C8    ...H
                    lda       #1                  * 03A2 86 01          ..
                    os9       I$WritLn            * 03A4 10 3F 8C       .?.
                    lbcs      L062E               * 03A7 10 25 02 83    .%..
                    leax      >L00F0,PC           * 03AB 30 8D FD 41    0.}A
                    ldy       >L010B,PC           * 03AF 10 AE 8D FD 57 ...}W
                    lda       #1                  * 03B4 86 01          ..
                    os9       I$Write             * 03B6 10 3F 8A       .?.
                    ldd       >U012A,U            * 03B9 EC C9 01 2A    lI.*
                    cmpd      #-1                 * 03BD 10 83 FF FF    ....
                    beq       L0423               * 03C1 27 60          '`
                    leax      >L0194,PC           * 03C3 30 8D FD CD    0.}M
                    lda       #1                  * 03C7 86 01          ..
                    os9       I$Open              * 03C9 10 3F 84       .?.
                    lbcs      L062E               * 03CC 10 25 02 5E    .%.^
                    sta       U0004,U             * 03D0 A7 44          'D
L03D2               leax      >U012C,U            * 03D2 30 C9 01 2C    0I.,
                    ldy       #200                * 03D6 10 8E 00 C8    ...H
                    lda       U0004,U             * 03DA A6 44          &D
                    os9       I$ReadLn            * 03DC 10 3F 8B       .?.
                    bcs       L040E               * 03DF 25 2D          %-
                    leax      >U012C,U            * 03E1 30 C9 01 2C    0I.,
L03E5               lda       ,X+                 * 03E5 A6 80          &.
                    cmpa      #44                 * 03E7 81 2C          .,
                    bne       L03E5               * 03E9 26 FA          &z
                    lda       #13                 * 03EB 86 0D          ..
                    sta       -$01,X              * 03ED A7 1F          '.
                    lbsr      L0631               * 03EF 17 02 3F       ..?
                    cmpd      >U012A,U            * 03F2 10 A3 C9 01 2A .#I.*
                    bne       L03D2               * 03F7 26 D9          &Y
                    leax      >U012C,U            * 03F9 30 C9 01 2C    0I.,
                    ldy       #200                * 03FD 10 8E 00 C8    ...H
                    lda       #1                  * 0401 86 01          ..
                    os9       I$WritLn            * 0403 10 3F 8C       .?.
                    lda       U0004,U             * 0406 A6 44          &D
                    os9       I$Close             * 0408 10 3F 8F       .?.
                    lbra      L0430               * 040B 16 00 22       .."
L040E               leax      >L01A6,PC           * 040E 30 8D FD 94    0.}.
                    ldy       #200                * 0412 10 8E 00 C8    ...H
                    lda       #1                  * 0416 86 01          ..
                    os9       I$WritLn            * 0418 10 3F 8C       .?.
                    lda       U0004,U             * 041B A6 44          &D
                    os9       I$Close             * 041D 10 3F 8F       .?.
                    lbra      L0430               * 0420 16 00 0D       ...
L0423               leax      >L01B3,PC           * 0423 30 8D FD 8C    0.}.
                    ldy       #200                * 0427 10 8E 00 C8    ...H
                    lda       #1                  * 042B 86 01          ..
                    os9       I$WritLn            * 042D 10 3F 8C       .?.
L0430               leax      >L00F9,PC           * 0430 30 8D FC C5    0.|E
                    ldy       >L010B,PC           * 0434 10 AE 8D FC D2 ...|R
                    lda       #1                  * 0439 86 01          ..
                    os9       I$Write             * 043B 10 3F 8A       .?.
                    leax      <U003C,U            * 043E 30 C8 3C       0H<
                    ldb       >U0123,U            * 0441 E6 C9 01 23    fI.#
                    clra                          * 0445 4F             O
                    lbsr      L06A1               * 0446 17 02 58       ..X
                    lda       <U003F,U            * 0449 A6 C8 3F       &H?
                    sta       <U004D,U            * 044C A7 C8 4D       'HM
                    lda       <U0040,U            * 044F A6 C8 40       &H@
                    sta       <U004E,U            * 0452 A7 C8 4E       'HN
                    lda       #47                 * 0455 86 2F          ./
                    sta       <U004F,U            * 0457 A7 C8 4F       'HO
                    ldb       >U0124,U            * 045A E6 C9 01 24    fI.$
                    clra                          * 045E 4F             O
                    leax      <U003C,U            * 045F 30 C8 3C       0H<
                    lbsr      L06A1               * 0462 17 02 3C       ..<
                    lda       <U003F,U            * 0465 A6 C8 3F       &H?
                    sta       <U0050,U            * 0468 A7 C8 50       'HP
                    lda       <U0040,U            * 046B A6 C8 40       &H@
                    sta       <U0051,U            * 046E A7 C8 51       'HQ
                    lda       #47                 * 0471 86 2F          ./
                    sta       <U0052,U            * 0473 A7 C8 52       'HR
                    ldb       >U0122,U            * 0476 E6 C9 01 22    fI."
                    clra                          * 047A 4F             O
                    leax      <U003C,U            * 047B 30 C8 3C       0H<
                    lbsr      L06A1               * 047E 17 02 20       ..
                    lda       <U003F,U            * 0481 A6 C8 3F       &H?
                    sta       <U0053,U            * 0484 A7 C8 53       'HS
                    lda       <U0040,U            * 0487 A6 C8 40       &H@
                    sta       <U0054,U            * 048A A7 C8 54       'HT
                    lda       #32                 * 048D 86 20          .
                    sta       <U0055,U            * 048F A7 C8 55       'HU
                    ldb       >U0125,U            * 0492 E6 C9 01 25    fI.%
                    clra                          * 0496 4F             O
                    leax      <U003C,U            * 0497 30 C8 3C       0H<
                    lbsr      L06A1               * 049A 17 02 04       ...
                    lda       <U003F,U            * 049D A6 C8 3F       &H?
                    sta       <U0056,U            * 04A0 A7 C8 56       'HV
                    lda       <U0040,U            * 04A3 A6 C8 40       &H@
                    sta       <U0057,U            * 04A6 A7 C8 57       'HW
                    lda       #58                 * 04A9 86 3A          .:
                    sta       <U0058,U            * 04AB A7 C8 58       'HX
                    ldb       >U0126,U            * 04AE E6 C9 01 26    fI.&
                    clra                          * 04B2 4F             O
                    leax      <U003C,U            * 04B3 30 C8 3C       0H<
                    lbsr      L06A1               * 04B6 17 01 E8       ..h
                    lda       <U003F,U            * 04B9 A6 C8 3F       &H?
                    sta       <U0059,U            * 04BC A7 C8 59       'HY
                    lda       <U0040,U            * 04BF A6 C8 40       &H@
                    sta       <U005A,U            * 04C2 A7 C8 5A       'HZ
                    lda       #13                 * 04C5 86 0D          ..
                    sta       <U005B,U            * 04C7 A7 C8 5B       'H[
                    leax      <U004D,U            * 04CA 30 C8 4D       0HM
L04CD               lda       ,X+                 * 04CD A6 80          &.
                    cmpa      #32                 * 04CF 81 20          .
                    beq       L04CD               * 04D1 27 FA          'z
                    leax      -$01,X              * 04D3 30 1F          0.
                    ldy       #200                * 04D5 10 8E 00 C8    ...H
                    lda       #1                  * 04D9 86 01          ..
                    os9       I$WritLn            * 04DB 10 3F 8C       .?.
                    lbcs      L062E               * 04DE 10 25 01 4C    .%.L
                    leax      >L0102,PC           * 04E2 30 8D FC 1C    0.|.
                    ldy       >L010B,PC           * 04E6 10 AE 8D FC 20 ...|
                    lda       #1                  * 04EB 86 01          ..
                    os9       I$Write             * 04ED 10 3F 8A       .?.
                    leax      >U0104,U            * 04F0 30 C9 01 04    0I..
                    ldy       #30                 * 04F4 10 8E 00 1E    ....
                    os9       I$WritLn            * 04F8 10 3F 8C       .?.
                    lbcs      L062E               * 04FB 10 25 01 2F    .%./
                    bra       L0511               * 04FF 20 10           .
L0501               leax      >L00C4,PC           * 0501 30 8D FB BF    0.{?
                    ldy       #200                * 0505 10 8E 00 C8    ...H
                    lda       #1                  * 0509 86 01          ..
                    os9       I$WritLn            * 050B 10 3F 8C       .?.
                    lbra      L0326               * 050E 16 FE 15       .~.
L0511               leax      >L010D,PC           * 0511 30 8D FB F8    0.{x
                    ldy       #80                 * 0515 10 8E 00 50    ...P
                    lda       #1                  * 0519 86 01          ..
                    os9       I$WritLn            * 051B 10 3F 8C       .?.
                    lda       U0002,U             * 051E A6 42          &B
                    ldx       >U00EC,U            * 0520 AE C9 00 EC    .I.l
                    pshs      U                   * 0524 34 40          4@
                    ldu       >U00EE,U            * 0526 EE C9 00 EE    nI.n
                    os9       I$Seek              * 052A 10 3F 88       .?.
                    lbcs      L062E               * 052D 10 25 00 FD    .%.}
                    puls      U                   * 0531 35 40          5@
L0533               clra                          * 0533 4F             O
                    ldb       #1                  * 0534 C6 01          F.
                    os9       I$GetStt            * 0536 10 3F 8D       .?.
                    bcs       L054C               * 0539 25 11          %.
                    leax      U0000,U             * 053B 30 C4          0D
                    ldy       #1                  * 053D 10 8E 00 01    ....
                    os9       I$Read              * 0541 10 3F 89       .?.
                    lda       U0000,U             * 0544 A6 C4          &D
                    cmpa      #32                 * 0546 81 20          .
                    lbeq      L0326               * 0548 10 27 FD DA    .'}Z
L054C               lda       U0002,U             * 054C A6 42          &B
                    leax      >U009C,U            * 054E 30 C9 00 9C    0I..
                    ldy       #80                 * 0552 10 8E 00 50    ...P
                    os9       I$ReadLn            * 0556 10 3F 8B       .?.
                    lda       #1                  * 0559 86 01          ..
                    os9       I$WritLn            * 055B 10 3F 8C       .?.
                    cmpy      #1                  * 055E 10 8C 00 01    ....
                    bhi       L0533               * 0562 22 CF          "O
                    leax      >L010D,PC           * 0564 30 8D FB A5    0.{%
                    ldy       #200                * 0568 10 8E 00 C8    ...H
                    lda       #1                  * 056C 86 01          ..
                    os9       I$WritLn            * 056E 10 3F 8C       .?.
                    leax      >L014E,PC           * 0571 30 8D FB D9    0.{Y
                    ldy       #5                  * 0575 10 8E 00 05    ....
                    os9       I$WritLn            * 0579 10 3F 8C       .?.
                    ldd       U0008,U             * 057C EC 48          lH
                    addd      #1                  * 057E C3 00 01       C..
                    std       U0008,U             * 0581 ED 48          mH
                    lbra      L0326               * 0583 16 FD A0       .}
L0586               leax      >L017E,PC           * 0586 30 8D FB F4    0.{t
                    lda       #3                  * 058A 86 03          ..
                    os9       I$Open              * 058C 10 3F 84       .?.
                    bcc       L059A               * 058F 24 09          $.
                    ldb       #27                 * 0591 C6 1B          F.
                    os9       I$Create            * 0593 10 3F 83       .?.
                    lbcs      L062E               * 0596 10 25 00 94    .%..
L059A               sta       U0007,U             * 059A A7 47          'G
L059C               leax      U000C,U             * 059C 30 4C          0L
                    ldy       #32                 * 059E 10 8E 00 20    ...
                    lda       U0007,U             * 05A2 A6 47          &G
                    os9       I$Read              * 05A4 10 3F 89       .?.
                    bcs       L05B2               * 05A7 25 09          %.
                    ldd       U000C,U             * 05A9 EC 4C          lL
                    cmpd      U000A,U             * 05AB 10 A3 4A       .#J
                    bne       L059C               * 05AE 26 EC          &l
                    bra       L05BB               * 05B0 20 09           .
L05B2               cmpb      #211                * 05B2 C1 D3          AS
                    lbne      L062E               * 05B4 10 26 00 76    .&.v
                    lbra      L05F7               * 05B8 16 00 3C       ..<
L05BB               ldd       <U0018,U            * 05BB EC C8 18       lH.
                    addd      U0008,U             * 05BE E3 48          cH
                    std       <U0018,U            * 05C0 ED C8 18       mH.
                    lda       U0007,U             * 05C3 A6 47          &G
                    ldb       #5                  * 05C5 C6 05          F.
                    pshs      U                   * 05C7 34 40          4@
                    os9       I$GetStt            * 05C9 10 3F 8D       .?.
                    tfr       U,D                 * 05CC 1F 30          .0
                    subd      #32                 * 05CE 83 00 20       ..
                    bge       L05D5               * 05D1 2C 02          ,.
                    leax      -$01,X              * 05D3 30 1F          0.
L05D5               ldu       0,S                 * 05D5 EE E4          nd
                    tfr       D,Y                 * 05D7 1F 02          ..
                    lda       U0007,U             * 05D9 A6 47          &G
                    tfr       Y,U                 * 05DB 1F 23          .#
                    os9       I$Seek              * 05DD 10 3F 88       .?.
                    lbcs      L062E               * 05E0 10 25 00 4A    .%.J
                    puls      U                   * 05E4 35 40          5@
                    leax      U000C,U             * 05E6 30 4C          0L
                    ldy       #32                 * 05E8 10 8E 00 20    ...
                    lda       U0007,U             * 05EC A6 47          &G
                    os9       I$Write             * 05EE 10 3F 8A       .?.
                    os9       I$Close             * 05F1 10 3F 8F       .?.
                    lbra      L062D               * 05F4 16 00 36       ..6
L05F7               leax      U000C,U             * 05F7 30 4C          0L
                    ldd       #1                  * 05F9 CC 00 01       L..
                    std       U000E,U             * 05FC ED 4E          mN
                    std       <U0018,U            * 05FE ED C8 18       mH.
                    ldd       #0                  * 0601 CC 00 00       L..
                    std       <U0016,U            * 0604 ED C8 16       mH.
                    std       <U001C,U            * 0607 ED C8 1C       mH.
                    std       <U001A,U            * 060A ED C8 1A       mH.
                    ldd       U000A,U             * 060D EC 4A          lJ
                    std       U000C,U             * 060F ED 4C          mL
                    leax      <U0010,U            * 0611 30 C8 10       0H.
                    os9       F$Time              * 0614 10 3F 15       .?.
                    lbcs      L062E               * 0617 10 25 00 13    .%..
                    leax      U000C,U             * 061B 30 4C          0L
                    ldy       #32                 * 061D 10 8E 00 20    ...
                    lda       U0007,U             * 0621 A6 47          &G
                    os9       I$Write             * 0623 10 3F 8A       .?.
                    os9       I$Close             * 0626 10 3F 8F       .?.
                    lbcs      L062E               * 0629 10 25 00 01    .%..
L062D               clrb                          * 062D 5F             _
L062E               os9       F$Exit              * 062E 10 3F 06       .?.
L0631               pshs      Y                   * 0631 34 20          4
L0633               lda       ,X+                 * 0633 A6 80          &.
                    cmpa      #13                 * 0635 81 0D          ..
                    lbeq      L071D               * 0637 10 27 00 E2    .'.b
                    cmpa      #48                 * 063B 81 30          .0
                    bcs       L0633               * 063D 25 F4          %t
                    cmpa      #57                 * 063F 81 39          .9
                    bhi       L0633               * 0641 22 F0          "p
                    leax      -$01,X              * 0643 30 1F          0.
L0645               lda       ,X+                 * 0645 A6 80          &.
                    cmpa      #48                 * 0647 81 30          .0
                    bcs       L0651               * 0649 25 06          %.
                    cmpa      #57                 * 064B 81 39          .9
                    bhi       L0651               * 064D 22 02          ".
                    bra       L0645               * 064F 20 F4           t
L0651               pshs      X                   * 0651 34 10          4.
                    leax      -$01,X              * 0653 30 1F          0.
                    clr       <U002E,U            * 0655 6F C8 2E       oH.
                    clr       <U002F,U            * 0658 6F C8 2F       oH/
                    ldd       #1                  * 065B CC 00 01       L..
                    std       <U0030,U            * 065E ED C8 30       mH0
L0661               lda       ,-X                 * 0661 A6 82          &.
                    cmpa      #48                 * 0663 81 30          .0
                    bcs       L069A               * 0665 25 33          %3
                    cmpa      #57                 * 0667 81 39          .9
                    bhi       L069A               * 0669 22 2F          "/
                    suba      #48                 * 066B 80 30          .0
                    sta       U0006,U             * 066D A7 46          'F
                    ldd       #0                  * 066F CC 00 00       L..
L0672               tst       U0006,U             * 0672 6D 46          mF
                    beq       L067D               * 0674 27 07          '.
                    addd      <U0030,U            * 0676 E3 C8 30       cH0
                    dec       U0006,U             * 0679 6A 46          jF
                    bra       L0672               * 067B 20 F5           u
L067D               addd      <U002E,U            * 067D E3 C8 2E       cH.
                    std       <U002E,U            * 0680 ED C8 2E       mH.
                    lda       #10                 * 0683 86 0A          ..
                    sta       U0006,U             * 0685 A7 46          'F
                    ldd       #0                  * 0687 CC 00 00       L..
L068A               tst       U0006,U             * 068A 6D 46          mF
                    beq       L0695               * 068C 27 07          '.
                    addd      <U0030,U            * 068E E3 C8 30       cH0
                    dec       U0006,U             * 0691 6A 46          jF
                    bra       L068A               * 0693 20 F5           u
L0695               std       <U0030,U            * 0695 ED C8 30       mH0
                    bra       L0661               * 0698 20 C7           G
L069A               ldd       <U002E,U            * 069A EC C8 2E       lH.
                    puls      X                   * 069D 35 10          5.
                    puls      PC,Y                * 069F 35 A0          5
L06A1               pshs      X                   * 06A1 34 10          4.
                    std       <U002E,U            * 06A3 ED C8 2E       mH.
                    lda       #48                 * 06A6 86 30          .0
                    sta       0,X                 * 06A8 A7 84          '.
                    sta       $01,X               * 06AA A7 01          '.
                    sta       $02,X               * 06AC A7 02          '.
                    sta       $03,X               * 06AE A7 03          '.
                    sta       $04,X               * 06B0 A7 04          '.
                    ldd       #10000              * 06B2 CC 27 10       L'.
                    std       <U0030,U            * 06B5 ED C8 30       mH0
                    ldd       <U002E,U            * 06B8 EC C8 2E       lH.
                    lbsr      L070B               * 06BB 17 00 4D       ..M
                    ldd       #1000               * 06BE CC 03 E8       L.h
                    std       <U0030,U            * 06C1 ED C8 30       mH0
                    ldd       <U002E,U            * 06C4 EC C8 2E       lH.
                    bsr       L070B               * 06C7 8D 42          .B
                    ldd       #100                * 06C9 CC 00 64       L.d
                    std       <U0030,U            * 06CC ED C8 30       mH0
                    ldd       <U002E,U            * 06CF EC C8 2E       lH.
                    bsr       L070B               * 06D2 8D 37          .7
                    ldd       #10                 * 06D4 CC 00 0A       L..
                    std       <U0030,U            * 06D7 ED C8 30       mH0
                    ldd       <U002E,U            * 06DA EC C8 2E       lH.
                    bsr       L070B               * 06DD 8D 2C          .,
                    ldd       #1                  * 06DF CC 00 01       L..
                    std       <U0030,U            * 06E2 ED C8 30       mH0
                    ldd       <U002E,U            * 06E5 EC C8 2E       lH.
                    bsr       L070B               * 06E8 8D 21          .!
                    lda       #13                 * 06EA 86 0D          ..
                    sta       0,X                 * 06EC A7 84          '.
                    puls      X                   * 06EE 35 10          5.
                    ldb       #32                 * 06F0 C6 20          F
L06F2               lda       0,X                 * 06F2 A6 84          &.
                    cmpa      #48                 * 06F4 81 30          .0
                    bne       L06FC               * 06F6 26 04          &.
                    stb       ,X+                 * 06F8 E7 80          g.
                    bra       L06F2               * 06FA 20 F6           v
L06FC               lda       ,X+                 * 06FC A6 80          &.
                    cmpa      #48                 * 06FE 81 30          .0
                    bcs       L0708               * 0700 25 06          %.
                    cmpa      #57                 * 0702 81 39          .9
                    bhi       L0708               * 0704 22 02          ".
                    bra       L06FC               * 0706 20 F4           t
L0708               leax      -$01,X              * 0708 30 1F          0.
                    rts                           * 070A 39             9
L070B               subd      <U0030,U            * 070B A3 C8 30       #H0
                    bcs       L0714               * 070E 25 04          %.
                    inc       0,X                 * 0710 6C 84          l.
                    bra       L070B               * 0712 20 F7           w
L0714               addd      <U0030,U            * 0714 E3 C8 30       cH0
                    std       <U002E,U            * 0717 ED C8 2E       mH.
                    leax      $01,X               * 071A 30 01          0.
                    rts                           * 071C 39             9
L071D               ldd       #-1                 * 071D CC FF FF       L..
                    puls      PC,Y                * 0720 35 A0          5

                    emod
eom                 equ       *
                    end
