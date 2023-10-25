                    nam       BBS.read
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
U0006               rmb       3
U0009               rmb       1
U000A               rmb       1
U000B               rmb       2
U000D               rmb       2
U000F               rmb       2
U0011               rmb       2
U0013               rmb       2
U0015               rmb       2
U0017               rmb       6
U001D               rmb       3
U0020               rmb       1
U0021               rmb       2
U0023               rmb       1
U0024               rmb       6
U002A               rmb       1
U002B               rmb       1
U002C               rmb       2
U002E               rmb       1
U002F               rmb       1
U0030               rmb       1
U0031               rmb       1
U0032               rmb       1
U0033               rmb       1
U0034               rmb       1
U0035               rmb       1
U0036               rmb       1
U0037               rmb       1
U0038               rmb       1
U0039               rmb       1
U003A               rmb       1
U003B               rmb       1
U003C               rmb       1
U003D               rmb       64
U007D               rmb       2
U007F               rmb       2
U0081               rmb       6
U0087               rmb       2
U0089               rmb       2
U008B               rmb       2
U008D               rmb       16
U009D               rmb       80
U00ED               rmb       2
U00EF               rmb       2
U00F1               rmb       20
U0105               rmb       30
U0123               rmb       1
U0124               rmb       1
U0125               rmb       1
U0126               rmb       1
U0127               rmb       4
U012B               rmb       2
U012D               rmb       24
U0145               rmb       40
U016D               rmb       1
U016E               rmb       399
size                equ       .

name                fcs       /BBS.read/          * 000D 42 42 53 2E 72 65 61 E4 BBS.read
                    fcc       "Copyright (C) 1988By Keith AlphonsoLicenced to Alpha Software TechnologiesAll rights reserved" * 0015 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 4C 69 63 65 6E 63 65 64
                    fcb       $EC                 * 0072 EC             l
                    fcb       $E6                 * 0073 E6             f
                    fcb       $EA                 * 0074 EA             j
                    fcb       $F5                 * 0075 F5             u
                    fcb       $E9                 * 0076 E9             i
                    fcb       $A0                 * 0077 A0
                    fcb       $E2                 * 0078 E2             b
                    fcb       $ED                 * 0079 ED             m
                    fcb       $F1                 * 007A F1             q
                    fcb       $E9                 * 007B E9             i
                    fcb       $F0                 * 007C F0             p
                    fcb       $EF                 * 007D EF             o
                    fcb       $F4                 * 007E F4             t
                    fcb       $F0                 * 007F F0             p
L0080               fcb       $0A                 * 0080 0A             .
                    fcc       "High    message is #" * 0081 48 69 67 68 20 20 20 20 6D 65 73 73 61 67 65 20 69 73 20 23 High    message is #
L0095               fcc       "Current message is #" * 0095 43 75 72 72 65 6E 74 20 6D 65 73 73 61 67 65 20 69 73 20 23 Current message is #
L00A9               fcc       "[N]ext, [P]revious, [T]hread, [R]eply, [Q]uit or Msg #" * 00A9 5B 4E 5D 65 78 74 2C 20 5B 50 5D 72 65 76 69 6F 75 73 2C 20 5B 54 5D 68 72 65 61 64 2C 20 5B 52 5D 65 70 6C 79 2C 20 5B 51 5D 75 69 74 20 6F 72 20 4D 73 67 20 23 [N]ex
                    fcb       $0D                 * 00DF 0D             .
L00E0               fcc       ">"                 * 00E0 3E             >
L00E1               fcc       "BBS.msg.inx"       * 00E1 42 42 53 2E 6D 73 67 2E 69 6E 78 BBS.msg.inx
                    fcb       $0D                 * 00EC 0D             .
L00ED               fcc       "BBS.msg"           * 00ED 42 42 53 2E 6D 73 67 BBS.msg
                    fcb       $0D                 * 00F4 0D             .
L00F5               fcc       "******   DELETED   ******" * 00F5 2A 2A 2A 2A 2A 2A 20 20 20 44 45 4C 45 54 45 44 20 20 20 2A 2A 2A 2A 2A 2A ******   DELETED   ******
                    fcb       $0D                 * 010E 0D             .
L010F               fcc       "Message :"         * 010F 4D 65 73 73 61 67 65 20 3A Message :
L0118               fcc       "From    :"         * 0118 46 72 6F 6D 20 20 20 20 3A From    :
L0121               fcc       "To      :"         * 0121 54 6F 20 20 20 20 20 20 3A To      :
L012A               fcc       "Left on :"         * 012A 4C 65 66 74 20 6F 6E 20 3A Left on :
L0133               fcc       "About   :"         * 0133 41 62 6F 75 74 20 20 20 3A About   :
L013C               fcb       $00                 * 013C 00             .
                    fcb       $09                 * 013D 09             .
L013E               fcc       "----------------------------------------------------------------" * 013E 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 017E 0D             .
L017F               fcb       $0A                 * 017F 0A             .
                    fcb       $0D                 * 0180 0D             .
L0181               fcc       "BBS.msg.lst"       * 0181 42 42 53 2E 6D 73 67 2E 6C 73 74 BBS.msg.lst
                    fcb       $0D                 * 018C 0D             .
L018D               fcc       "BBS.reply"         * 018D 42 42 53 2E 72 65 70 6C 79 BBS.reply
                    fcb       $0D                 * 0196 0D             .
L0197               fcc       "/dd/bbs/BBS.userstats" * 0197 2F 64 64 2F 62 62 73 2F 42 42 53 2E 75 73 65 72 73 74 61 74 73 /dd/bbs/BBS.userstats
                    fcb       $0D                 * 01AC 0D             .
L01AD               fcc       "/dd/bbs/BBS.alias" * 01AD 2F 64 64 2F 62 62 73 2F 42 42 53 2E 61 6C 69 61 73 /dd/bbs/BBS.alias
                    fcb       $0D                 * 01BE 0D             .
L01BF               fcc       "Unknown User"      * 01BF 55 6E 6B 6E 6F 77 6E 20 55 73 65 72 Unknown User
                    fcb       $0D                 * 01CB 0D             .
L01CC               fcc       "All Users"         * 01CC 41 6C 6C 20 55 73 65 72 73 All Users
                    fcb       $0D                 * 01D5 0D             .
start               os9       F$ID                * 01D6 10 3F 0C       .?.
                    sty       U000D,U             * 01D9 10 AF 4D       ./M
                    ldy       #0                  * 01DC 10 8E 00 00    ....
                    os9       F$SUser             * 01E0 10 3F 1C       .?.
                    sty       <U0015,U            * 01E3 10 AF C8 15    ./H.
                    leax      >L00E1,PC           * 01E7 30 8D FE F6    0.~v
                    lda       #1                  * 01EB 86 01          ..
                    os9       I$Open              * 01ED 10 3F 84       .?.
                    lbcs      L0700               * 01F0 10 25 05 0C    .%..
                    sta       U0000,U             * 01F4 A7 C4          'D
                    leax      >L0181,PC           * 01F6 30 8D FF 87    0...
                    lda       #3                  * 01FA 86 03          ..
                    os9       I$Open              * 01FC 10 3F 84       .?.
                    bcc       L020A               * 01FF 24 09          $.
                    ldb       #3                  * 0201 C6 03          F.
                    os9       I$Create            * 0203 10 3F 83       .?.
                    lbcs      L0700               * 0206 10 25 04 F6    .%.v
L020A               sta       U0002,U             * 020A A7 42          'B
                    leax      >L00ED,PC           * 020C 30 8D FE DD    0.~]
                    lda       #1                  * 0210 86 01          ..
                    os9       I$Open              * 0212 10 3F 84       .?.
                    lbcs      L0700               * 0215 10 25 04 E7    .%.g
                    sta       U0001,U             * 0219 A7 41          'A
                    leax      <U003D,U            * 021B 30 C8 3D       0H=
                    ldy       #64                 * 021E 10 8E 00 40    ...@
                    lda       U0000,U             * 0222 A6 C4          &D
                    os9       I$Read              * 0224 10 3F 89       .?.
                    lbcs      L0700               * 0227 10 25 04 D5    .%.U
                    ldd       #0                  * 022B CC 00 00       L..
                    std       <U0013,U            * 022E ED C8 13       mH.
L0231               ldd       <U003D,U            * 0231 EC C8 3D       lH=
                    leax      <U0017,U            * 0234 30 C8 17       0H.
                    lbsr      L076A               * 0237 17 05 30       ..0
                    leax      >L0080,PC           * 023A 30 8D FE 42    0.~B
                    ldy       #21                 * 023E 10 8E 00 15    ....
                    lda       #1                  * 0242 86 01          ..
                    os9       I$Write             * 0244 10 3F 8A       .?.
                    lbcs      L0700               * 0247 10 25 04 B5    .%.5
                    leax      <U0017,U            * 024B 30 C8 17       0H.
                    ldy       #6                  * 024E 10 8E 00 06    ....
                    os9       I$WritLn            * 0252 10 3F 8C       .?.
                    lbcs      L0700               * 0255 10 25 04 A7    .%.'
                    ldd       <U0013,U            * 0259 EC C8 13       lH.
                    leax      <U0017,U            * 025C 30 C8 17       0H.
                    lbsr      L076A               * 025F 17 05 08       ...
                    leax      >L0095,PC           * 0262 30 8D FE 2F    0.~/
                    ldy       #20                 * 0266 10 8E 00 14    ....
                    lda       #1                  * 026A 86 01          ..
                    os9       I$Write             * 026C 10 3F 8A       .?.
                    lbcs      L0700               * 026F 10 25 04 8D    .%..
                    leax      <U0017,U            * 0273 30 C8 17       0H.
                    ldy       #6                  * 0276 10 8E 00 06    ....
                    os9       I$WritLn            * 027A 10 3F 8C       .?.
                    lbcs      L0700               * 027D 10 25 04 7F    .%..
                    leax      >L00A9,PC           * 0281 30 8D FE 24    0.~$
                    ldy       #200                * 0285 10 8E 00 C8    ...H
                    lda       #1                  * 0289 86 01          ..
                    os9       I$WritLn            * 028B 10 3F 8C       .?.
                    lbcs      L0700               * 028E 10 25 04 6E    .%.n
                    leax      >L00E0,PC           * 0292 30 8D FE 4A    0.~J
                    ldy       #1                  * 0296 10 8E 00 01    ....
                    os9       I$Write             * 029A 10 3F 8A       .?.
                    lbcs      L0700               * 029D 10 25 04 5F    .%._
                    leax      <U0024,U            * 02A1 30 C8 24       0H$
                    ldy       #6                  * 02A4 10 8E 00 06    ....
                    clra                          * 02A8 4F             O
L02A9               os9       I$ReadLn            * 02A9 10 3F 8B       .?.
                    bcs       L02A9               * 02AC 25 FB          %{
                    lda       <U0024,U            * 02AE A6 C8 24       &H$
                    cmpa      #57                 * 02B1 81 39          .9
                    blt       L02D5               * 02B3 2D 20          -
                    anda      #223                * 02B5 84 DF          ._
                    cmpa      #81                 * 02B7 81 51          .Q
                    lbeq      L0649               * 02B9 10 27 03 8C    .'..
                    cmpa      #78                 * 02BD 81 4E          .N
                    lbeq      L02F4               * 02BF 10 27 00 31    .'.1
                    cmpa      #80                 * 02C3 81 50          .P
                    lbeq      L0308               * 02C5 10 27 00 3F    .'.?
                    cmpa      #84                 * 02C9 81 54          .T
                    lbeq      L0318               * 02CB 10 27 00 49    .'.I
                    cmpa      #82                 * 02CF 81 52          .R
                    lbeq      L035B               * 02D1 10 27 00 86    .'..
L02D5               clr       <U0023,U            * 02D5 6F C8 23       oH#
                    leax      <U0024,U            * 02D8 30 C8 24       0H$
                    lbsr      L0703               * 02DB 17 04 25       ..%
                    cmpd      #0                  * 02DE 10 83 00 00    ....
                    lbeq      L0231               * 02E2 10 27 FF 4B    .'.K
                    cmpd      <U003D,U            * 02E6 10 A3 C8 3D    .#H=
                    lbhi      L0231               * 02EA 10 22 FF 43    .".C
                    std       <U0013,U            * 02EE ED C8 13       mH.
                    lbra      L0398               * 02F1 16 00 A4       ..$
L02F4               ldd       <U0013,U            * 02F4 EC C8 13       lH.
                    addd      #1                  * 02F7 C3 00 01       C..
                    cmpd      <U003D,U            * 02FA 10 A3 C8 3D    .#H=
                    lbgt      L0231               * 02FE 10 2E FF 2F    .../
                    std       <U0013,U            * 0302 ED C8 13       mH.
                    lbra      L0398               * 0305 16 00 90       ...
L0308               ldd       <U0013,U            * 0308 EC C8 13       lH.
                    subd      #1                  * 030B 83 00 01       ...
                    lbeq      L0231               * 030E 10 27 FF 1F    .'..
                    std       <U0013,U            * 0312 ED C8 13       mH.
                    lbra      L0398               * 0315 16 00 80       ...
L0318               leax      >U012D,U            * 0318 30 C9 01 2D    0I.-
                    ldy       #64                 * 031C 10 8E 00 40    ...@
                    lda       U0000,U             * 0320 A6 C4          &D
                    os9       I$Read              * 0322 10 3F 89       .?.
                    bcs       L034C               * 0325 25 25          %%
                    ldd       <U0013,U            * 0327 EC C8 13       lH.
                    addd      #1                  * 032A C3 00 01       C..
                    std       <U0013,U            * 032D ED C8 13       mH.
                    leay      >U0105,U            * 0330 31 C9 01 05    1I..
                    leax      >U0145,U            * 0334 30 C9 01 45    0I.E
L0338               lda       0,X                 * 0338 A6 84          &.
                    anda      #223                * 033A 84 DF          ._
                    sta       0,X                 * 033C A7 84          '.
                    lda       ,Y+                 * 033E A6 A0          &
                    cmpa      #13                 * 0340 81 0D          ..
                    beq       L0355               * 0342 27 11          '.
                    anda      #223                * 0344 84 DF          ._
                    cmpa      ,X+                 * 0346 A1 80          !.
                    bne       L0318               * 0348 26 CE          &N
                    bra       L0338               * 034A 20 EC           l
L034C               cmpb      #211                * 034C C1 D3          AS
                    lbne      L0700               * 034E 10 26 03 AE    .&..
                    lbra      L0231               * 0352 16 FE DC       .~\
L0355               ldd       <U0013,U            * 0355 EC C8 13       lH.
                    lbra      L0398               * 0358 16 00 3D       ..=
L035B               ldy       U000D,U             * 035B 10 AE 4D       ..M
                    os9       F$SUser             * 035E 10 3F 1C       .?.
                    lda       #17                 * 0361 86 11          ..
                    ldb       #3                  * 0363 C6 03          F.
                    leax      >L018D,PC           * 0365 30 8D FE 24    0.~$
                    ldy       #80                 * 0369 10 8E 00 50    ...P
                    pshs      U                   * 036D 34 40          4@
                    leau      >U0105,U            * 036F 33 C9 01 05    3I..
                    os9       F$Fork              * 0373 10 3F 03       .?.
                    puls      U                   * 0376 35 40          5@
                    lbcs      L0231               * 0378 10 25 FE B5    .%~5
                    clrb                          * 037C 5F             _
                    os9       F$Wait              * 037D 10 3F 04       .?.
                    tstb                          * 0380 5D             ]
                    lbne      L0231               * 0381 10 26 FE AC    .&~,
                    ldy       #0                  * 0385 10 8E 00 00    ....
                    os9       F$SUser             * 0389 10 3F 1C       .?.
                    ldd       <U003D,U            * 038C EC C8 3D       lH=
                    addd      #1                  * 038F C3 00 01       C..
                    std       <U003D,U            * 0392 ED C8 3D       mH=
                    lbra      L0231               * 0395 16 FE 99       .~.
L0398               lda       U0002,U             * 0398 A6 42          &B
                    leax      U000F,U             * 039A 30 4F          0O
                    ldy       #4                  * 039C 10 8E 00 04    ....
                    os9       I$Read              * 03A0 10 3F 89       .?.
                    bcs       L03D1               * 03A3 25 2C          %,
                    ldd       U000F,U             * 03A5 EC 4F          lO
                    cmpd      U000D,U             * 03A7 10 A3 4D       .#M
                    bne       L0398               * 03AA 26 EC          &l
                    ldd       <U0011,U            * 03AC EC C8 11       lH.
                    cmpd      <U0013,U            * 03AF 10 A3 C8 13    .#H.
                    bcc       L03E8               * 03B3 24 33          $3
                    pshs      U                   * 03B5 34 40          4@
                    lda       U0002,U             * 03B7 A6 42          &B
                    ldb       #5                  * 03B9 C6 05          F.
                    os9       I$GetStt            * 03BB 10 3F 8D       .?.
                    leau      -$02,U              * 03BE 33 5E          3^
                    os9       I$Seek              * 03C0 10 3F 88       .?.
                    puls      U                   * 03C3 35 40          5@
                    leax      <U0013,U            * 03C5 30 C8 13       0H.
                    ldy       #2                  * 03C8 10 8E 00 02    ....
                    os9       I$Write             * 03CC 10 3F 8A       .?.
                    bra       L03E8               * 03CF 20 17           .
L03D1               cmpb      #211                * 03D1 C1 D3          AS
                    lbne      L0700               * 03D3 10 26 03 29    .&.)
                    lda       U0002,U             * 03D7 A6 42          &B
                    leax      U000D,U             * 03D9 30 4D          0M
                    ldy       #2                  * 03DB 10 8E 00 02    ....
                    os9       I$Write             * 03DF 10 3F 8A       .?.
                    leax      <U0013,U            * 03E2 30 C8 13       0H.
                    os9       I$Write             * 03E5 10 3F 8A       .?.
L03E8               clr       <U002A,U            * 03E8 6F C8 2A       oH*
                    clr       <U002B,U            * 03EB 6F C8 2B       oH+
                    lda       #6                  * 03EE 86 06          ..
                    sta       U0004,U             * 03F0 A7 44          'D
                    ldd       <U0013,U            * 03F2 EC C8 13       lH.
L03F5               aslb                          * 03F5 58             X
                    rola                          * 03F6 49             I
                    rol       <U002B,U            * 03F7 69 C8 2B       iH+
                    dec       U0004,U             * 03FA 6A 44          jD
                    bne       L03F5               * 03FC 26 F7          &w
                    std       <U002C,U            * 03FE ED C8 2C       mH,
                    ldx       <U002A,U            * 0401 AE C8 2A       .H*
                    lda       U0000,U             * 0404 A6 C4          &D
                    pshs      U                   * 0406 34 40          4@
                    ldu       <U002C,U            * 0408 EE C8 2C       nH,
                    os9       I$Seek              * 040B 10 3F 88       .?.
                    lbcs      L0700               * 040E 10 25 02 EE    .%.n
                    puls      U                   * 0412 35 40          5@
                    lda       U0000,U             * 0414 A6 C4          &D
                    ldy       #64                 * 0416 10 8E 00 40    ...@
                    leax      >U00ED,U            * 041A 30 C9 00 ED    0I.m
                    os9       I$Read              * 041E 10 3F 89       .?.
                    lbcs      L0231               * 0421 10 25 FE 0C    .%~.
                    leax      >L017F,PC           * 0425 30 8D FD 56    0.}V
                    ldy       #2                  * 0429 10 8E 00 02    ....
                    lda       #1                  * 042D 86 01          ..
                    os9       I$WritLn            * 042F 10 3F 8C       .?.
                    ldd       <U0013,U            * 0432 EC C8 13       lH.
                    leax      <U001D,U            * 0435 30 C8 1D       0H.
                    lbsr      L076A               * 0438 17 03 2F       ../
                    leax      >L010F,PC           * 043B 30 8D FC D0    0.|P
                    ldy       >L013C,PC           * 043F 10 AE 8D FC F8 ...|x
                    lda       #1                  * 0444 86 01          ..
                    os9       I$Write             * 0446 10 3F 8A       .?.
                    lbcs      L0700               * 0449 10 25 02 B3    .%.3
                    leax      <U001D,U            * 044D 30 C8 1D       0H.
L0450               lda       ,X+                 * 0450 A6 80          &.
                    cmpa      #32                 * 0452 81 20          .
                    beq       L0450               * 0454 27 FA          'z
                    leax      -$01,X              * 0456 30 1F          0.
                    ldy       #6                  * 0458 10 8E 00 06    ....
                    lda       #1                  * 045C 86 01          ..
                    os9       I$WritLn            * 045E 10 3F 8C       .?.
                    lbcs      L0700               * 0461 10 25 02 9B    .%..
                    ldd       >U00ED,U            * 0465 EC C9 00 ED    lI.m
                    cmpd      #-1                 * 0469 10 83 FF FF    ....
                    lbeq      L05E6               * 046D 10 27 01 75    .'.u
                    leax      >L0118,PC           * 0471 30 8D FC A3    0.|#
                    ldy       >L013C,PC           * 0475 10 AE 8D FC C2 ...|B
                    lda       #1                  * 047A 86 01          ..
                    os9       I$Write             * 047C 10 3F 8A       .?.
                    leax      >U00F1,U            * 047F 30 C9 00 F1    0I.q
                    ldy       #200                * 0483 10 8E 00 C8    ...H
                    lda       #1                  * 0487 86 01          ..
                    os9       I$WritLn            * 0489 10 3F 8C       .?.
                    lbcs      L0700               * 048C 10 25 02 70    .%.p
                    leax      >L0121,PC           * 0490 30 8D FC 8D    0.|.
                    ldy       >L013C,PC           * 0494 10 AE 8D FC A3 ...|#
                    lda       #1                  * 0499 86 01          ..
                    os9       I$Write             * 049B 10 3F 8A       .?.
                    ldd       >U012B,U            * 049E EC C9 01 2B    lI.+
                    cmpd      #-1                 * 04A2 10 83 FF FF    ....
                    beq       L0508               * 04A6 27 60          '`
                    leax      >L01AD,PC           * 04A8 30 8D FD 01    0.}.
                    lda       #1                  * 04AC 86 01          ..
                    os9       I$Open              * 04AE 10 3F 84       .?.
                    lbcs      L0700               * 04B1 10 25 02 4B    .%.K
                    sta       U0003,U             * 04B5 A7 43          'C
L04B7               leax      >U016D,U            * 04B7 30 C9 01 6D    0I.m
                    ldy       #200                * 04BB 10 8E 00 C8    ...H
                    lda       U0003,U             * 04BF A6 43          &C
                    os9       I$ReadLn            * 04C1 10 3F 8B       .?.
                    bcs       L04F3               * 04C4 25 2D          %-
                    leax      >U016D,U            * 04C6 30 C9 01 6D    0I.m
L04CA               lda       ,X+                 * 04CA A6 80          &.
                    cmpa      #44                 * 04CC 81 2C          .,
                    bne       L04CA               * 04CE 26 FA          &z
                    lda       #13                 * 04D0 86 0D          ..
                    sta       -$01,X              * 04D2 A7 1F          '.
                    lbsr      L0703               * 04D4 17 02 2C       ..,
                    cmpd      >U012B,U            * 04D7 10 A3 C9 01 2B .#I.+
                    bne       L04B7               * 04DC 26 D9          &Y
                    leax      >U016D,U            * 04DE 30 C9 01 6D    0I.m
                    ldy       #200                * 04E2 10 8E 00 C8    ...H
                    lda       #1                  * 04E6 86 01          ..
                    os9       I$WritLn            * 04E8 10 3F 8C       .?.
                    lda       U0003,U             * 04EB A6 43          &C
                    os9       I$Close             * 04ED 10 3F 8F       .?.
                    lbra      L0515               * 04F0 16 00 22       .."
L04F3               leax      >L01BF,PC           * 04F3 30 8D FC C8    0.|H
                    ldy       #200                * 04F7 10 8E 00 C8    ...H
                    lda       #1                  * 04FB 86 01          ..
                    os9       I$WritLn            * 04FD 10 3F 8C       .?.
                    lda       U0003,U             * 0500 A6 43          &C
                    os9       I$Close             * 0502 10 3F 8F       .?.
                    lbra      L0515               * 0505 16 00 0D       ...
L0508               leax      >L01CC,PC           * 0508 30 8D FC C0    0.|@
                    ldy       #200                * 050C 10 8E 00 C8    ...H
                    lda       #1                  * 0510 86 01          ..
                    os9       I$WritLn            * 0512 10 3F 8C       .?.
L0515               leax      >L012A,PC           * 0515 30 8D FC 11    0.|.
                    ldy       >L013C,PC           * 0519 10 AE 8D FC 1E ...|.
                    lda       #1                  * 051E 86 01          ..
                    os9       I$Write             * 0520 10 3F 8A       .?.
                    leax      <U001D,U            * 0523 30 C8 1D       0H.
                    ldb       >U0124,U            * 0526 E6 C9 01 24    fI.$
                    clra                          * 052A 4F             O
                    lbsr      L076A               * 052B 17 02 3C       ..<
                    lda       <U0020,U            * 052E A6 C8 20       &H
                    sta       <U002E,U            * 0531 A7 C8 2E       'H.
                    lda       <U0021,U            * 0534 A6 C8 21       &H!
                    sta       <U002F,U            * 0537 A7 C8 2F       'H/
                    lda       #47                 * 053A 86 2F          ./
                    sta       <U0030,U            * 053C A7 C8 30       'H0
                    ldb       >U0125,U            * 053F E6 C9 01 25    fI.%
                    clra                          * 0543 4F             O
                    leax      <U001D,U            * 0544 30 C8 1D       0H.
                    lbsr      L076A               * 0547 17 02 20       ..
                    lda       <U0020,U            * 054A A6 C8 20       &H
                    sta       <U0031,U            * 054D A7 C8 31       'H1
                    lda       <U0021,U            * 0550 A6 C8 21       &H!
                    sta       <U0032,U            * 0553 A7 C8 32       'H2
                    lda       #47                 * 0556 86 2F          ./
                    sta       <U0033,U            * 0558 A7 C8 33       'H3
                    ldb       >U0123,U            * 055B E6 C9 01 23    fI.#
                    clra                          * 055F 4F             O
                    leax      <U001D,U            * 0560 30 C8 1D       0H.
                    lbsr      L076A               * 0563 17 02 04       ...
                    lda       <U0020,U            * 0566 A6 C8 20       &H
                    sta       <U0034,U            * 0569 A7 C8 34       'H4
                    lda       <U0021,U            * 056C A6 C8 21       &H!
                    sta       <U0035,U            * 056F A7 C8 35       'H5
                    lda       #32                 * 0572 86 20          .
                    sta       <U0036,U            * 0574 A7 C8 36       'H6
                    ldb       >U0126,U            * 0577 E6 C9 01 26    fI.&
                    clra                          * 057B 4F             O
                    leax      <U001D,U            * 057C 30 C8 1D       0H.
                    lbsr      L076A               * 057F 17 01 E8       ..h
                    lda       <U0020,U            * 0582 A6 C8 20       &H
                    sta       <U0037,U            * 0585 A7 C8 37       'H7
                    lda       <U0021,U            * 0588 A6 C8 21       &H!
                    sta       <U0038,U            * 058B A7 C8 38       'H8
                    lda       #58                 * 058E 86 3A          .:
                    sta       <U0039,U            * 0590 A7 C8 39       'H9
                    ldb       >U0127,U            * 0593 E6 C9 01 27    fI.'
                    clra                          * 0597 4F             O
                    leax      <U001D,U            * 0598 30 C8 1D       0H.
                    lbsr      L076A               * 059B 17 01 CC       ..L
                    lda       <U0020,U            * 059E A6 C8 20       &H
                    sta       <U003A,U            * 05A1 A7 C8 3A       'H:
                    lda       <U0021,U            * 05A4 A6 C8 21       &H!
                    sta       <U003B,U            * 05A7 A7 C8 3B       'H;
                    lda       #13                 * 05AA 86 0D          ..
                    sta       <U003C,U            * 05AC A7 C8 3C       'H<
                    leax      <U002E,U            * 05AF 30 C8 2E       0H.
L05B2               lda       ,X+                 * 05B2 A6 80          &.
                    cmpa      #32                 * 05B4 81 20          .
                    beq       L05B2               * 05B6 27 FA          'z
                    leax      -$01,X              * 05B8 30 1F          0.
                    ldy       #200                * 05BA 10 8E 00 C8    ...H
                    lda       #1                  * 05BE 86 01          ..
                    os9       I$WritLn            * 05C0 10 3F 8C       .?.
                    lbcs      L0700               * 05C3 10 25 01 39    .%.9
                    leax      >L0133,PC           * 05C7 30 8D FB 68    0.{h
                    ldy       >L013C,PC           * 05CB 10 AE 8D FB 6C ...{l
                    lda       #1                  * 05D0 86 01          ..
                    os9       I$Write             * 05D2 10 3F 8A       .?.
                    leax      >U0105,U            * 05D5 30 C9 01 05    0I..
                    ldy       #30                 * 05D9 10 8E 00 1E    ....
                    os9       I$WritLn            * 05DD 10 3F 8C       .?.
                    lbcs      L0700               * 05E0 10 25 01 1C    .%..
                    bra       L05F6               * 05E4 20 10           .
L05E6               leax      >L00F5,PC           * 05E6 30 8D FB 0B    0.{.
                    ldy       #200                * 05EA 10 8E 00 C8    ...H
                    lda       #1                  * 05EE 86 01          ..
                    os9       I$WritLn            * 05F0 10 3F 8C       .?.
                    lbra      L0231               * 05F3 16 FC 3B       .|;
L05F6               leax      >L013E,PC           * 05F6 30 8D FB 44    0.{D
                    ldy       #80                 * 05FA 10 8E 00 50    ...P
                    lda       #1                  * 05FE 86 01          ..
                    os9       I$WritLn            * 0600 10 3F 8C       .?.
                    lda       U0001,U             * 0603 A6 41          &A
                    ldx       >U00ED,U            * 0605 AE C9 00 ED    .I.m
                    pshs      U                   * 0609 34 40          4@
                    ldu       >U00EF,U            * 060B EE C9 00 EF    nI.o
                    os9       I$Seek              * 060F 10 3F 88       .?.
                    lbcs      L0700               * 0612 10 25 00 EA    .%.j
                    puls      U                   * 0616 35 40          5@
L0618               lda       U0001,U             * 0618 A6 41          &A
                    leax      >U009D,U            * 061A 30 C9 00 9D    0I..
                    ldy       #80                 * 061E 10 8E 00 50    ...P
                    os9       I$ReadLn            * 0622 10 3F 8B       .?.
                    lda       #1                  * 0625 86 01          ..
                    os9       I$WritLn            * 0627 10 3F 8C       .?.
                    cmpy      #1                  * 062A 10 8C 00 01    ....
                    bhi       L0618               * 062E 22 E8          "h
                    leax      >L013E,PC           * 0630 30 8D FB 0A    0.{.
                    ldy       #80                 * 0634 10 8E 00 50    ...P
                    lda       #1                  * 0638 86 01          ..
                    os9       I$WritLn            * 063A 10 3F 8C       .?.
                    ldd       <U0015,U            * 063D EC C8 15       lH.
                    addd      #1                  * 0640 C3 00 01       C..
                    std       <U0015,U            * 0643 ED C8 15       mH.
                    lbra      L0231               * 0646 16 FB E8       .{h
L0649               leax      >L0197,PC           * 0649 30 8D FB 4A    0.{J
                    lda       #3                  * 064D 86 03          ..
                    os9       I$Open              * 064F 10 3F 84       .?.
                    bcc       L065D               * 0652 24 09          $.
                    ldb       #27                 * 0654 C6 1B          F.
                    os9       I$Create            * 0656 10 3F 83       .?.
                    lbcs      L0700               * 0659 10 25 00 A3    .%.#
L065D               sta       U0006,U             * 065D A7 46          'F
L065F               leax      <U007D,U            * 065F 30 C8 7D       0H}
                    ldy       #32                 * 0662 10 8E 00 20    ...
                    lda       U0006,U             * 0666 A6 46          &F
                    os9       I$Read              * 0668 10 3F 89       .?.
                    bcs       L0677               * 066B 25 0A          %.
                    ldd       <U007D,U            * 066D EC C8 7D       lH}
                    cmpd      U000D,U             * 0670 10 A3 4D       .#M
                    bne       L065F               * 0673 26 EA          &j
                    bra       L0680               * 0675 20 09           .
L0677               cmpb      #211                * 0677 C1 D3          AS
                    lbne      L0700               * 0679 10 26 00 83    .&..
                    lbra      L06C0               * 067D 16 00 40       ..@
L0680               ldd       >U0089,U            * 0680 EC C9 00 89    lI..
                    addd      <U0015,U            * 0684 E3 C8 15       cH.
                    std       >U0089,U            * 0687 ED C9 00 89    mI..
                    lda       U0006,U             * 068B A6 46          &F
                    ldb       #5                  * 068D C6 05          F.
                    pshs      U                   * 068F 34 40          4@
                    os9       I$GetStt            * 0691 10 3F 8D       .?.
                    tfr       U,D                 * 0694 1F 30          .0
                    subd      #32                 * 0696 83 00 20       ..
                    bge       L069D               * 0699 2C 02          ,.
                    leax      -$01,X              * 069B 30 1F          0.
L069D               ldu       0,S                 * 069D EE E4          nd
                    tfr       D,Y                 * 069F 1F 02          ..
                    lda       U0006,U             * 06A1 A6 46          &F
                    tfr       Y,U                 * 06A3 1F 23          .#
                    os9       I$Seek              * 06A5 10 3F 88       .?.
                    lbcs      L0700               * 06A8 10 25 00 54    .%.T
                    puls      U                   * 06AC 35 40          5@
                    leax      <U007D,U            * 06AE 30 C8 7D       0H}
                    ldy       #32                 * 06B1 10 8E 00 20    ...
                    lda       U0006,U             * 06B5 A6 46          &F
                    os9       I$Write             * 06B7 10 3F 8A       .?.
                    os9       I$Close             * 06BA 10 3F 8F       .?.
                    lbra      L06FF               * 06BD 16 00 3F       ..?
L06C0               leax      <U007D,U            * 06C0 30 C8 7D       0H}
                    ldd       #1                  * 06C3 CC 00 01       L..
                    std       <U007F,U            * 06C6 ED C8 7F       mH.
                    std       >U0089,U            * 06C9 ED C9 00 89    mI..
                    ldd       #0                  * 06CD CC 00 00       L..
                    std       >U0087,U            * 06D0 ED C9 00 87    mI..
                    std       >U008D,U            * 06D4 ED C9 00 8D    mI..
                    std       >U008B,U            * 06D8 ED C9 00 8B    mI..
                    ldd       U000D,U             * 06DC EC 4D          lM
                    std       <U007D,U            * 06DE ED C8 7D       mH}
                    leax      >U0081,U            * 06E1 30 C9 00 81    0I..
                    os9       F$Time              * 06E5 10 3F 15       .?.
                    lbcs      L0700               * 06E8 10 25 00 14    .%..
                    leax      <U007D,U            * 06EC 30 C8 7D       0H}
                    ldy       #32                 * 06EF 10 8E 00 20    ...
                    lda       U0006,U             * 06F3 A6 46          &F
                    os9       I$Write             * 06F5 10 3F 8A       .?.
                    os9       I$Close             * 06F8 10 3F 8F       .?.
                    lbcs      L0700               * 06FB 10 25 00 01    .%..
L06FF               clrb                          * 06FF 5F             _
L0700               os9       F$Exit              * 0700 10 3F 06       .?.
L0703               pshs      Y                   * 0703 34 20          4
L0705               lda       ,X+                 * 0705 A6 80          &.
                    cmpa      #13                 * 0707 81 0D          ..
                    lbeq      L07D8               * 0709 10 27 00 CB    .'.K
                    cmpa      #48                 * 070D 81 30          .0
                    bcs       L0705               * 070F 25 F4          %t
                    cmpa      #57                 * 0711 81 39          .9
                    bhi       L0705               * 0713 22 F0          "p
                    leax      -$01,X              * 0715 30 1F          0.
L0717               lda       ,X+                 * 0717 A6 80          &.
                    cmpa      #48                 * 0719 81 30          .0
                    bcs       L0723               * 071B 25 06          %.
                    cmpa      #57                 * 071D 81 39          .9
                    bhi       L0723               * 071F 22 02          ".
                    bra       L0717               * 0721 20 F4           t
L0723               pshs      X                   * 0723 34 10          4.
                    leax      -$01,X              * 0725 30 1F          0.
                    clr       U0009,U             * 0727 6F 49          oI
                    clr       U000A,U             * 0729 6F 4A          oJ
                    ldd       #1                  * 072B CC 00 01       L..
                    std       U000B,U             * 072E ED 4B          mK
L0730               lda       ,-X                 * 0730 A6 82          &.
                    cmpa      #48                 * 0732 81 30          .0
                    bcs       L0764               * 0734 25 2E          %.
                    cmpa      #57                 * 0736 81 39          .9
                    bhi       L0764               * 0738 22 2A          "*
                    suba      #48                 * 073A 80 30          .0
                    sta       U0005,U             * 073C A7 45          'E
                    ldd       #0                  * 073E CC 00 00       L..
L0741               tst       U0005,U             * 0741 6D 45          mE
                    beq       L074B               * 0743 27 06          '.
                    addd      U000B,U             * 0745 E3 4B          cK
                    dec       U0005,U             * 0747 6A 45          jE
                    bra       L0741               * 0749 20 F6           v
L074B               addd      U0009,U             * 074B E3 49          cI
                    std       U0009,U             * 074D ED 49          mI
                    lda       #10                 * 074F 86 0A          ..
                    sta       U0005,U             * 0751 A7 45          'E
                    ldd       #0                  * 0753 CC 00 00       L..
L0756               tst       U0005,U             * 0756 6D 45          mE
                    beq       L0760               * 0758 27 06          '.
                    addd      U000B,U             * 075A E3 4B          cK
                    dec       U0005,U             * 075C 6A 45          jE
                    bra       L0756               * 075E 20 F6           v
L0760               std       U000B,U             * 0760 ED 4B          mK
                    bra       L0730               * 0762 20 CC           L
L0764               ldd       U0009,U             * 0764 EC 49          lI
                    puls      X                   * 0766 35 10          5.
                    puls      PC,Y                * 0768 35 A0          5
L076A               pshs      X                   * 076A 34 10          4.
                    std       U0009,U             * 076C ED 49          mI
                    lda       #48                 * 076E 86 30          .0
                    sta       0,X                 * 0770 A7 84          '.
                    sta       $01,X               * 0772 A7 01          '.
                    sta       $02,X               * 0774 A7 02          '.
                    sta       $03,X               * 0776 A7 03          '.
                    sta       $04,X               * 0778 A7 04          '.
                    ldd       #10000              * 077A CC 27 10       L'.
                    std       U000B,U             * 077D ED 4B          mK
                    ldd       U0009,U             * 077F EC 49          lI
                    lbsr      L07C9               * 0781 17 00 45       ..E
                    ldd       #1000               * 0784 CC 03 E8       L.h
                    std       U000B,U             * 0787 ED 4B          mK
                    ldd       U0009,U             * 0789 EC 49          lI
                    bsr       L07C9               * 078B 8D 3C          .<
                    ldd       #100                * 078D CC 00 64       L.d
                    std       U000B,U             * 0790 ED 4B          mK
                    ldd       U0009,U             * 0792 EC 49          lI
                    bsr       L07C9               * 0794 8D 33          .3
                    ldd       #10                 * 0796 CC 00 0A       L..
                    std       U000B,U             * 0799 ED 4B          mK
                    ldd       U0009,U             * 079B EC 49          lI
                    bsr       L07C9               * 079D 8D 2A          .*
                    ldd       #1                  * 079F CC 00 01       L..
                    std       U000B,U             * 07A2 ED 4B          mK
                    ldd       U0009,U             * 07A4 EC 49          lI
                    bsr       L07C9               * 07A6 8D 21          .!
                    lda       #13                 * 07A8 86 0D          ..
                    sta       0,X                 * 07AA A7 84          '.
                    puls      X                   * 07AC 35 10          5.
                    ldb       #32                 * 07AE C6 20          F
L07B0               lda       0,X                 * 07B0 A6 84          &.
                    cmpa      #48                 * 07B2 81 30          .0
                    bne       L07BA               * 07B4 26 04          &.
                    stb       ,X+                 * 07B6 E7 80          g.
                    bra       L07B0               * 07B8 20 F6           v
L07BA               lda       ,X+                 * 07BA A6 80          &.
                    cmpa      #48                 * 07BC 81 30          .0
                    bcs       L07C6               * 07BE 25 06          %.
                    cmpa      #57                 * 07C0 81 39          .9
                    bhi       L07C6               * 07C2 22 02          ".
                    bra       L07BA               * 07C4 20 F4           t
L07C6               leax      -$01,X              * 07C6 30 1F          0.
                    rts                           * 07C8 39             9
L07C9               subd      U000B,U             * 07C9 A3 4B          #K
                    bcs       L07D1               * 07CB 25 04          %.
                    inc       0,X                 * 07CD 6C 84          l.
                    bra       L07C9               * 07CF 20 F8           x
L07D1               addd      U000B,U             * 07D1 E3 4B          cK
                    std       U0009,U             * 07D3 ED 49          mI
                    leax      $01,X               * 07D5 30 01          0.
                    rts                           * 07D7 39             9
L07D8               ldd       #-1                 * 07D8 CC FF FF       L..
                    puls      PC,Y                * 07DB 35 A0          5

                    emod
eom                 equ       *
                    end
