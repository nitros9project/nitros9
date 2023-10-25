                    nam       BBS.archive
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       1
InxPath             rmb       1
MsgPath             rmb       1
AliasPath           rmb       1
TmpPath             rmb       2
U0006               rmb       2
U0008               rmb       2
U000A               rmb       2
U000C               rmb       36
U0030               rmb       1
U0031               rmb       1
ABuf                rmb       6
BBuf                rmb       6
U003E               rmb       3
U0041               rmb       1
U0042               rmb       2
U0044               rmb       1
U0045               rmb       10
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
U005C               rmb       1
U005D               rmb       1
buffer              rmb       64
U009E               rmb       80
U00EE               rmb       2
U00F0               rmb       2
U00F2               rmb       20
U0106               rmb       30
U0124               rmb       1
U0125               rmb       1
U0126               rmb       1
U0127               rmb       1
U0128               rmb       4
U012C               rmb       2
TmpName             rmb       200
U01F6               rmb       1
stack               rmb       399
size                equ       .

name                fcs       /BBS.archive/       * 000D 42 42 53 2E 61 72 63 68 69 76 E5 BBS.archive
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
HighMsg             fcc       "High message is #" * 0083 48 69 67 68 20 6D 65 73 73 61 67 65 20 69 73 20 23 High message is #
L0094               fcb       $00                 * 0094 00             .
                    fcb       $11                 * 0095 11             .
NewHigh             fcc       "Enter new high message #" * 0096 45 6E 74 65 72 20 6E 65 77 20 68 69 67 68 20 6D 65 73 73 61 67 65 20 23 Enter new high message #
                    fcb       $0D                 * 00AE 0D             .
FileName            fcc       "Enter output filename (BLANK = none)" * 00AF 45 6E 74 65 72 20 6F 75 74 70 75 74 20 66 69 6C 65 6E 61 6D 65 20 28 42 4C 41 4E 4B 20 3D 20 6E 6F 6E 65 29 Enter output filename (BLANK = none)
                    fcb       $0D                 * 00D3 0D             .
L00D4               fcc       ">"                 * 00D4 3E             >
bbsmsginx           fcc       "BBS.msg.inx"       * 00D5 42 42 53 2E 6D 73 67 2E 69 6E 78 BBS.msg.inx
                    fcb       $0D                 * 00E0 0D             .
bbsmsg              fcc       "BBS.msg"           * 00E1 42 42 53 2E 6D 73 67 BBS.msg
                    fcb       $0D                 * 00E8 0D             .
bbspack             fcc       "BBS.pack"          * 00E9 42 42 53 2E 70 61 63 6B BBS.pack
                    fcb       $0D                 * 00F1 0D             .
                    fcc       "******   DELETED   ******" * 00F2 2A 2A 2A 2A 2A 2A 20 20 20 44 45 4C 45 54 45 44 20 20 20 2A 2A 2A 2A 2A 2A ******   DELETED   ******
                    fcb       $0D                 * 010B 0D             .
message             fcc       "Message :"         * 010C 4D 65 73 73 61 67 65 20 3A Message :
L0115               fcc       "From    :"         * 0115 46 72 6F 6D 20 20 20 20 3A From    :
L011E               fcc       "To      :"         * 011E 54 6F 20 20 20 20 20 20 3A To      :
L0127               fcc       "Left on :"         * 0127 4C 65 66 74 20 6F 6E 20 3A Left on :
L0130               fcc       "About   :"         * 0130 41 62 6F 75 74 20 20 20 3A About   :
L0139               fcb       $00                 * 0139 00             .
                    fcb       $09                 * 013A 09             .
dashline            fcc       "----------------------------------------------------------------" * 013B 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 017B 0D             .
L017C               fcb       $0A                 * 017C 0A             .
                    fcb       $0A                 * 017D 0A             .
L017E               fcb       $0D                 * 017E 0D             .
                    fcc       "BBS.msg.lst"       * 017F 42 42 53 2E 6D 73 67 2E 6C 73 74 BBS.msg.lst
                    fcb       $0D                 * 018A 0D             .
                    fcc       "/dd/bbs/BBS.userstats" * 018B 2F 64 64 2F 62 62 73 2F 42 42 53 2E 75 73 65 72 73 74 61 74 73 /dd/bbs/BBS.userstats
                    fcb       $0D                 * 01A0 0D             .
bbsalias            fcc       "/dd/bbs/BBS.alias" * 01A1 2F 64 64 2F 62 62 73 2F 42 42 53 2E 61 6C 69 61 73 /dd/bbs/BBS.alias
                    fcb       $0D                 * 01B2 0D             .
unkuser             fcc       "Unknown User"      * 01B3 55 6E 6B 6E 6F 77 6E 20 55 73 65 72 Unknown User
                    fcb       $0D                 * 01BF 0D             .
allusers            fcc       "All Users"         * 01C0 41 6C 6C 20 55 73 65 72 73 All Users
                    fcb       $0D                 * 01C9 0D             .
L01CA               fcb       $FF                 * 01CA FF             .
                    fcb       $FF                 * 01CB FF             .
saving              fcc       "Saving Messages..." * 01CC 53 61 76 69 6E 67 20 4D 65 73 73 61 67 65 73 2E 2E 2E Saving Messages...
                    fcb       $0D                 * 01DE 0D             .

start               os9       F$ID                * 01DF 10 3F 0C       .?.
                    ldb       #214                * 01E2 C6 D6          FV
                    cmpy      #0                  * 01E4 10 8C 00 00    ....
                    lbne      Exit                * 01E8 10 26 03 8E    .&..
                    sty       U000C,U             * 01EC 10 AF 4C       ./L
                    ldd       #0                  * 01EF CC 00 00       L..
                    std       U000A,U             * 01F2 ED 4A          mJ

* Open bbs.msg.inx
                    leax      >bbsmsginx,PC       * 01F4 30 8D FE DD    0.~]
                    lda       #3                  * 01F8 86 03          ..
                    os9       I$Open              * 01FA 10 3F 84       .?.
                    lbcs      Exit                * 01FD 10 25 03 79    .%.y
                    sta       InxPath,U           * 0201 A7 41          'A

* Open bbs.msg
                    leax      >bbsmsg,PC          * 0203 30 8D FE DA    0.~Z
                    lda       #1                  * 0207 86 01          ..
                    os9       I$Open              * 0209 10 3F 84       .?.
                    lbcs      Exit                * 020C 10 25 03 6A    .%.j
                    sta       MsgPath,U           * 0210 A7 42          'B

* Read 64 bytes from bbs.msg.inx
                    leax      <buffer,U           * 0212 30 C8 5E       0H^
                    ldy       #64                 * 0215 10 8E 00 40    ...@
                    lda       InxPath,U           * 0219 A6 41          &A
                    os9       I$Read              * 021B 10 3F 89       .?.
                    lbcs      Exit                * 021E 10 25 03 58    .%.X

                    ldd       <buffer,U           * 0222 EC C8 5E       lH^
                    leax      <BBuf,U             * 0225 30 C8 38       0H8
                    lbsr      CvtDec              * 0228 17 03 C2       ..B
                    leax      >HighMsg,PC         * 022B 30 8D FE 54    0.~T
                    ldy       >L0094,PC           * 022F 10 AE 8D FE 60 ...~`
                    lda       #1                  * 0234 86 01          ..
                    os9       I$Write             * 0236 10 3F 8A       .?.
                    lbcs      Exit                * 0239 10 25 03 3D    .%.=
                    leax      <BBuf,U             * 023D 30 C8 38       0H8
                    ldy       #6                  * 0240 10 8E 00 06    ....
                    os9       I$WritLn            * 0244 10 3F 8C       .?.
                    lbcs      Exit                * 0247 10 25 03 2F    .%./
                    ldd       #0                  * 024B CC 00 00       L..
                    std       <BBuf,U             * 024E ED C8 38       mH8
                    leax      >NewHigh,PC         * 0251 30 8D FE 41    0.~A
                    ldy       #200                * 0255 10 8E 00 C8    ...H
                    lda       #1                  * 0259 86 01          ..
                    os9       I$WritLn            * 025B 10 3F 8C       .?.
                    lbcs      Exit                * 025E 10 25 03 18    .%..
                    leax      >L00D4,PC           * 0262 30 8D FE 6E    0.~n
                    ldy       #1                  * 0266 10 8E 00 01    ....
                    os9       I$Write             * 026A 10 3F 8A       .?.
                    lbcs      Exit                * 026D 10 25 03 09    .%..
                    leax      <U0045,U            * 0271 30 C8 45       0HE
                    ldy       #6                  * 0274 10 8E 00 06    ....
                    clra                          * 0278 4F             O
                    os9       I$ReadLn            * 0279 10 3F 8B       .?.
                    lbcs      Exit                * 027C 10 25 02 FA    .%.z
                    clr       <U0044,U            * 0280 6F C8 44       oHD
                    leax      <U0045,U            * 0283 30 C8 45       0HE
                    lbsr      L057D               * 0286 17 02 F4       ..t
                    cmpd      #1                  * 0289 10 83 00 01    ....
                    lbcs      L054D               * 028D 10 25 02 BC    .%.<
                    cmpd      <buffer,U           * 0291 10 A3 C8 5E    .#H^
                    lbhi      L054D               * 0295 10 22 02 B4    .".4
                    std       U0008,U             * 0299 ED 48          mH
                    ldd       <buffer,U           * 029B EC C8 5E       lH^
                    subd      U0008,U             * 029E A3 48          #H
                    std       U0008,U             * 02A0 ED 48          mH
                    leax      >FileName,PC        * 02A2 30 8D FE 09    0.~.
                    ldy       #200                * 02A6 10 8E 00 C8    ...H
                    lda       #1                  * 02AA 86 01          ..
                    os9       I$WritLn            * 02AC 10 3F 8C       .?.
                    leax      >L00D4,PC           * 02AF 30 8D FE 21    0.~!
                    ldy       #1                  * 02B3 10 8E 00 01    ....
                    lda       #1                  * 02B7 86 01          ..
                    os9       I$Write             * 02B9 10 3F 8A       .?.
                    leax      >TmpName,U          * 02BC 30 C9 01 2E    0I..
                    ldy       #32                 * 02C0 10 8E 00 20    ...
                    clra                          * 02C4 4F             O
                    os9       I$ReadLn            * 02C5 10 3F 8B       .?.
                    cmpy      #1                  * 02C8 10 8C 00 01    ....
                    bls       L02E0               * 02CC 23 12          #.
                    lda       #3                  * 02CE 86 03          ..
                    os9       I$Open              * 02D0 10 3F 84       .?.
                    bcc       L02E6               * 02D3 24 11          $.
                    ldb       #3                  * 02D5 C6 03          F.
                    os9       I$Create            * 02D7 10 3F 83       .?.
                    lbcs      Exit                * 02DA 10 25 02 9C    .%..
                    bra       L02E6               * 02DE 20 06           .

L02E0               lda       #255                * 02E0 86 FF          ..
                    sta       TmpPath,U           * 02E2 A7 44          'D
                    bra       L0301               * 02E4 20 1B           .

L02E6               sta       TmpPath,U           * 02E6 A7 44          'D
                    pshs      U                   * 02E8 34 40          4@
                    ldb       #2                  * 02EA C6 02          F.
                    os9       I$GetStt            * 02EC 10 3F 8D       .?.
                    os9       I$Seek              * 02EF 10 3F 88       .?.
                    puls      U                   * 02F2 35 40          5@
                    leax      >saving,PC          * 02F4 30 8D FE D4    0.~T
                    ldy       #200                * 02F8 10 8E 00 C8    ...H
                    lda       #1                  * 02FC 86 01          ..
                    os9       I$WritLn            * 02FE 10 3F 8C       .?.
L0301               lda       InxPath,U           * 0301 A6 41          &A
                    leax      >U00EE,U            * 0303 30 C9 00 EE    0I.n
                    ldy       #2                  * 0307 10 8E 00 02    ....
                    os9       I$Read              * 030B 10 3F 89       .?.
                    ldb       #5                  * 030E C6 05          F.
                    pshs      U                   * 0310 34 40          4@
                    os9       I$GetStt            * 0312 10 3F 8D       .?.
                    leau      -$02,U              * 0315 33 5E          3^
                    cmpu      #0                  * 0317 11 83 00 00    ....
                    bge       L031F               * 031B 2C 02          ,.
                    leax      -$01,X              * 031D 30 1F          0.
L031F               os9       I$Seek              * 031F 10 3F 88       .?.
                    puls      U                   * 0322 35 40          5@
                    lbcs      Exit                * 0324 10 25 02 52    .%.R
                    leax      >L01CA,PC           * 0328 30 8D FE 9E    0.~.
                    ldy       #2                  * 032C 10 8E 00 02    ....
                    os9       I$Write             * 0330 10 3F 8A       .?.
                    ldy       #62                 * 0333 10 8E 00 3E    ...>
                    leax      >U00EE,U            * 0337 30 C9 00 EE    0I.n
                    leax      $02,X               * 033B 30 02          0.
                    os9       I$Read              * 033D 10 3F 89       .?.
                    lbcs      L054D               * 0340 10 25 02 09    .%..
                    ldd       <BBuf,U             * 0344 EC C8 38       lH8
                    addd      #1                  * 0347 C3 00 01       C..
                    std       <BBuf,U             * 034A ED C8 38       mH8
                    ldd       >U00EE,U            * 034D EC C9 00 EE    lI.n
                    cmpd      #-1                 * 0351 10 83 FF FF    ....
                    lbeq      L04CE               * 0355 10 27 01 75    .'.u
                    leax      >L0115,PC           * 0359 30 8D FD B8    0.}8
                    ldy       >L0139,PC           * 035D 10 AE 8D FD D7 ...}W
                    lda       TmpPath,U           * 0362 A6 44          &D
                    os9       I$Write             * 0364 10 3F 8A       .?.
                    leax      >U00F2,U            * 0367 30 C9 00 F2    0I.r
                    ldy       #200                * 036B 10 8E 00 C8    ...H
                    lda       <TmpPath            * 036F 96 04          ..
                    os9       I$WritLn            * 0371 10 3F 8C       .?.
                    lbcs      Exit                * 0374 10 25 02 02    .%..
                    leax      >L011E,PC           * 0378 30 8D FD A2    0.}"
                    ldy       >L0139,PC           * 037C 10 AE 8D FD B8 ...}8
                    lda       TmpPath,U           * 0381 A6 44          &D
                    os9       I$Write             * 0383 10 3F 8A       .?.
                    ldd       >U012C,U            * 0386 EC C9 01 2C    lI.,
                    cmpd      #-1                 * 038A 10 83 FF FF    ....
                    beq       L03F0               * 038E 27 60          '`
                    leax      >bbsalias,PC        * 0390 30 8D FE 0D    0.~.
                    lda       #1                  * 0394 86 01          ..
                    os9       I$Open              * 0396 10 3F 84       .?.
                    lbcs      Exit                * 0399 10 25 01 DD    .%.]
                    sta       AliasPath,U         * 039D A7 43          'C
L039F               leax      >U01F6,U            * 039F 30 C9 01 F6    0I.v
                    ldy       #200                * 03A3 10 8E 00 C8    ...H
                    lda       AliasPath,U         * 03A7 A6 43          &C
                    os9       I$ReadLn            * 03A9 10 3F 8B       .?.
                    bcs       L03DB               * 03AC 25 2D          %-
                    leax      >U01F6,U            * 03AE 30 C9 01 F6    0I.v
L03B2               lda       ,X+                 * 03B2 A6 80          &.
                    cmpa      #44                 * 03B4 81 2C          .,
                    bne       L03B2               * 03B6 26 FA          &z
                    lda       #13                 * 03B8 86 0D          ..
                    sta       -$01,X              * 03BA A7 1F          '.
                    lbsr      L057D               * 03BC 17 01 BE       ..>
                    cmpd      >U012C,U            * 03BF 10 A3 C9 01 2C .#I.,
                    bne       L039F               * 03C4 26 D9          &Y
                    leax      >U01F6,U            * 03C6 30 C9 01 F6    0I.v
                    ldy       #200                * 03CA 10 8E 00 C8    ...H
                    lda       TmpPath,U           * 03CE A6 44          &D
                    os9       I$WritLn            * 03D0 10 3F 8C       .?.
                    lda       AliasPath,U         * 03D3 A6 43          &C
                    os9       I$Close             * 03D5 10 3F 8F       .?.
                    lbra      L03FD               * 03D8 16 00 22       .."

L03DB               leax      >unkuser,PC         * 03DB 30 8D FD D4    0.}T
                    ldy       #200                * 03DF 10 8E 00 C8    ...H
                    lda       TmpPath,U           * 03E3 A6 44          &D
                    os9       I$WritLn            * 03E5 10 3F 8C       .?.
                    lda       AliasPath,U         * 03E8 A6 43          &C
                    os9       I$Close             * 03EA 10 3F 8F       .?.
                    lbra      L03FD               * 03ED 16 00 0D       ...

L03F0               leax      >allusers,PC        * 03F0 30 8D FD CC    0.}L
                    ldy       #200                * 03F4 10 8E 00 C8    ...H
                    lda       TmpPath,U           * 03F8 A6 44          &D
                    os9       I$WritLn            * 03FA 10 3F 8C       .?.
L03FD               leax      >L0127,PC           * 03FD 30 8D FD 26    0.}&
                    ldy       >L0139,PC           * 0401 10 AE 8D FD 33 ...}3
                    lda       TmpPath,U           * 0406 A6 44          &D
                    os9       I$Write             * 0408 10 3F 8A       .?.
                    leax      <U003E,U            * 040B 30 C8 3E       0H>
                    ldb       >U0125,U            * 040E E6 C9 01 25    fI.%
                    clra                          * 0412 4F             O
                    lbsr      CvtDec              * 0413 17 01 D7       ..W
                    lda       <U0041,U            * 0416 A6 C8 41       &HA
                    sta       <U004F,U            * 0419 A7 C8 4F       'HO
                    lda       <U0042,U            * 041C A6 C8 42       &HB
                    sta       <U0050,U            * 041F A7 C8 50       'HP
                    lda       #47                 * 0422 86 2F          ./
                    sta       <U0051,U            * 0424 A7 C8 51       'HQ
                    ldb       >U0126,U            * 0427 E6 C9 01 26    fI.&
                    clra                          * 042B 4F             O
                    leax      <U003E,U            * 042C 30 C8 3E       0H>
                    lbsr      CvtDec              * 042F 17 01 BB       ..;
                    lda       <U0041,U            * 0432 A6 C8 41       &HA
                    sta       <U0052,U            * 0435 A7 C8 52       'HR
                    lda       <U0042,U            * 0438 A6 C8 42       &HB
                    sta       <U0053,U            * 043B A7 C8 53       'HS
                    lda       #47                 * 043E 86 2F          ./
                    sta       <U0054,U            * 0440 A7 C8 54       'HT
                    ldb       >U0124,U            * 0443 E6 C9 01 24    fI.$
                    clra                          * 0447 4F             O
                    leax      <U003E,U            * 0448 30 C8 3E       0H>
                    lbsr      CvtDec              * 044B 17 01 9F       ...
                    lda       <U0041,U            * 044E A6 C8 41       &HA
                    sta       <U0055,U            * 0451 A7 C8 55       'HU
                    lda       <U0042,U            * 0454 A6 C8 42       &HB
                    sta       <U0056,U            * 0457 A7 C8 56       'HV
                    lda       #32                 * 045A 86 20          .
                    sta       <U0057,U            * 045C A7 C8 57       'HW
                    ldb       >U0127,U            * 045F E6 C9 01 27    fI.'
                    clra                          * 0463 4F             O
                    leax      <U003E,U            * 0464 30 C8 3E       0H>
                    lbsr      CvtDec              * 0467 17 01 83       ...
                    lda       <U0041,U            * 046A A6 C8 41       &HA
                    sta       <U0058,U            * 046D A7 C8 58       'HX
                    lda       <U0042,U            * 0470 A6 C8 42       &HB
                    sta       <U0059,U            * 0473 A7 C8 59       'HY
                    lda       #58                 * 0476 86 3A          .:
                    sta       <U005A,U            * 0478 A7 C8 5A       'HZ
                    ldb       >U0128,U            * 047B E6 C9 01 28    fI.(
                    clra                          * 047F 4F             O
                    leax      <U003E,U            * 0480 30 C8 3E       0H>
                    lbsr      CvtDec              * 0483 17 01 67       ..g
                    lda       <U0041,U            * 0486 A6 C8 41       &HA
                    sta       <U005B,U            * 0489 A7 C8 5B       'H[
                    lda       <U0042,U            * 048C A6 C8 42       &HB
                    sta       <U005C,U            * 048F A7 C8 5C       'H\
                    lda       #13                 * 0492 86 0D          ..
                    sta       <U005D,U            * 0494 A7 C8 5D       'H]
                    leax      <U004F,U            * 0497 30 C8 4F       0HO
L049A               lda       ,X+                 * 049A A6 80          &.
                    cmpa      #32                 * 049C 81 20          .
                    beq       L049A               * 049E 27 FA          'z
                    leax      -$01,X              * 04A0 30 1F          0.
                    ldy       #200                * 04A2 10 8E 00 C8    ...H
                    lda       TmpPath,U           * 04A6 A6 44          &D
                    os9       I$WritLn            * 04A8 10 3F 8C       .?.
                    lbcs      Exit                * 04AB 10 25 00 CB    .%.K
                    leax      >L0130,PC           * 04AF 30 8D FC 7D    0.|}
                    ldy       >L0139,PC           * 04B3 10 AE 8D FC 81 ...|.
                    lda       TmpPath,U           * 04B8 A6 44          &D
                    os9       I$Write             * 04BA 10 3F 8A       .?.
                    leax      >U0106,U            * 04BD 30 C9 01 06    0I..
                    ldy       #30                 * 04C1 10 8E 00 1E    ....
                    os9       I$WritLn            * 04C5 10 3F 8C       .?.
                    lbcs      Exit                * 04C8 10 25 00 AE    .%..
                    bra       L04D1               * 04CC 20 03           .

L04CE               lbra      L0301               * 04CE 16 FE 30       .~0

L04D1               leax      >dashline,PC        * 04D1 30 8D FC 66    0.|f
                    ldy       #80                 * 04D5 10 8E 00 50    ...P
                    lda       TmpPath,U           * 04D9 A6 44          &D
                    os9       I$WritLn            * 04DB 10 3F 8C       .?.
                    lda       MsgPath,U           * 04DE A6 42          &B
                    ldx       >U00EE,U            * 04E0 AE C9 00 EE    .I.n
                    pshs      U                   * 04E4 34 40          4@
                    ldu       >U00F0,U            * 04E6 EE C9 00 F0    nI.p
                    os9       I$Seek              * 04EA 10 3F 88       .?.
                    lbcs      Exit                * 04ED 10 25 00 89    .%..
                    puls      U                   * 04F1 35 40          5@
L04F3               clra                          * 04F3 4F             O
                    ldb       #1                  * 04F4 C6 01          F.
                    os9       I$GetStt            * 04F6 10 3F 8D       .?.
                    bcs       L050C               * 04F9 25 11          %.
                    leax      U0000,U             * 04FB 30 C4          0D
                    ldy       #1                  * 04FD 10 8E 00 01    ....
                    os9       I$Read              * 0501 10 3F 89       .?.
                    lda       U0000,U             * 0504 A6 C4          &D
                    cmpa      #32                 * 0506 81 20          .
                    lbeq      L0301               * 0508 10 27 FD F5    .'}u
L050C               lda       MsgPath,U           * 050C A6 42          &B
                    leax      >U009E,U            * 050E 30 C9 00 9E    0I..
                    ldy       #80                 * 0512 10 8E 00 50    ...P
                    os9       I$ReadLn            * 0516 10 3F 8B       .?.
                    lda       TmpPath,U           * 0519 A6 44          &D
                    os9       I$WritLn            * 051B 10 3F 8C       .?.
                    cmpy      #1                  * 051E 10 8C 00 01    ....
                    bhi       L04F3               * 0522 22 CF          "O
                    leax      >dashline,PC        * 0524 30 8D FC 13    0.|.
                    ldy       #200                * 0528 10 8E 00 C8    ...H
                    lda       TmpPath,U           * 052C A6 44          &D
                    os9       I$WritLn            * 052E 10 3F 8C       .?.
                    leax      >L017C,PC           * 0531 30 8D FC 47    0.|G
                    ldy       #5                  * 0535 10 8E 00 05    ....
                    os9       I$WritLn            * 0539 10 3F 8C       .?.
                    ldd       U000A,U             * 053C EC 4A          lJ
                    addd      #1                  * 053E C3 00 01       C..
                    std       U000A,U             * 0541 ED 4A          mJ
                    ldd       <BBuf,U             * 0543 EC C8 38       lH8
                    cmpd      U0008,U             * 0546 10 A3 48       .#H
                    lbcs      L0301               * 0549 10 25 FD B4    .%}4
L054D               lda       InxPath,U           * 054D A6 41          &A
                    os9       I$Close             * 054F 10 3F 8F       .?.
                    lda       MsgPath,U           * 0552 A6 42          &B
                    os9       I$Close             * 0554 10 3F 8F       .?.
                    lda       AliasPath,U         * 0557 A6 43          &C
                    os9       I$Close             * 0559 10 3F 8F       .?.
                    lda       TmpPath,U           * 055C A6 44          &D
                    os9       I$Close             * 055E 10 3F 8F       .?.
                    leax      >bbspack,PC         * 0561 30 8D FB 84    0.{.
                    leau      >L017E,PC           * 0565 33 8D FC 15    3.|.
                    ldy       #1                  * 0569 10 8E 00 01    ....
                    lda       #17                 * 056D 86 11          ..
                    ldb       #3                  * 056F C6 03          F.
                    os9       F$Fork              * 0571 10 3F 03       .?.
                    bcs       Exit                * 0574 25 04          %.
                    clrb                          * 0576 5F             _
                    os9       F$Wait              * 0577 10 3F 04       .?.

Exit                os9       F$Exit              * 057A 10 3F 06       .?.

L057D               pshs      Y                   * 057D 34 20          4
L057F               lda       ,X+                 * 057F A6 80          &.
                    cmpa      #13                 * 0581 81 0D          ..
                    lbeq      L0669               * 0583 10 27 00 E2    .'.b
                    cmpa      #48                 * 0587 81 30          .0
                    bcs       L057F               * 0589 25 F4          %t
                    cmpa      #57                 * 058B 81 39          .9
                    bhi       L057F               * 058D 22 F0          "p
                    leax      -$01,X              * 058F 30 1F          0.
L0591               lda       ,X+                 * 0591 A6 80          &.
                    cmpa      #48                 * 0593 81 30          .0
                    bcs       L059D               * 0595 25 06          %.
                    cmpa      #57                 * 0597 81 39          .9
                    bhi       L059D               * 0599 22 02          ".
                    bra       L0591               * 059B 20 F4           t
L059D               pshs      X                   * 059D 34 10          4.
                    leax      -$01,X              * 059F 30 1F          0.
                    clr       <U0030,U            * 05A1 6F C8 30       oH0
                    clr       <U0031,U            * 05A4 6F C8 31       oH1
                    ldd       #1                  * 05A7 CC 00 01       L..
                    std       <ABuf,U             * 05AA ED C8 32       mH2
L05AD               lda       ,-X                 * 05AD A6 82          &.
                    cmpa      #48                 * 05AF 81 30          .0
                    bcs       L05E6               * 05B1 25 33          %3
                    cmpa      #57                 * 05B3 81 39          .9
                    bhi       L05E6               * 05B5 22 2F          "/
                    suba      #48                 * 05B7 80 30          .0
                    sta       U0006,U             * 05B9 A7 46          'F
                    ldd       #0                  * 05BB CC 00 00       L..
L05BE               tst       U0006,U             * 05BE 6D 46          mF
                    beq       L05C9               * 05C0 27 07          '.
                    addd      <ABuf,U             * 05C2 E3 C8 32       cH2
                    dec       U0006,U             * 05C5 6A 46          jF
                    bra       L05BE               * 05C7 20 F5           u

L05C9               addd      <U0030,U            * 05C9 E3 C8 30       cH0
                    std       <U0030,U            * 05CC ED C8 30       mH0
                    lda       #10                 * 05CF 86 0A          ..
                    sta       U0006,U             * 05D1 A7 46          'F
                    ldd       #0                  * 05D3 CC 00 00       L..
L05D6               tst       U0006,U             * 05D6 6D 46          mF
                    beq       L05E1               * 05D8 27 07          '.
                    addd      <ABuf,U             * 05DA E3 C8 32       cH2
                    dec       U0006,U             * 05DD 6A 46          jF
                    bra       L05D6               * 05DF 20 F5           u

L05E1               std       <ABuf,U             * 05E1 ED C8 32       mH2
                    bra       L05AD               * 05E4 20 C7           G

L05E6               ldd       <U0030,U            * 05E6 EC C8 30       lH0
                    puls      X                   * 05E9 35 10          5.
                    puls      PC,Y                * 05EB 35 A0          5

* Convert the number in D to a decimal string
CvtDec              pshs      X                   * 05ED 34 10          4.
                    std       <U0030,U            * 05EF ED C8 30       mH0
                    lda       #48                 * 05F2 86 30          .0
                    sta       0,X                 * 05F4 A7 84          '.
                    sta       $01,X               * 05F6 A7 01          '.
                    sta       $02,X               * 05F8 A7 02          '.
                    sta       $03,X               * 05FA A7 03          '.
                    sta       $04,X               * 05FC A7 04          '.
                    ldd       #10000              * 05FE CC 27 10       L'.
                    std       <ABuf,U             * 0601 ED C8 32       mH2
                    ldd       <U0030,U            * 0604 EC C8 30       lH0
                    lbsr      L0657               * 0607 17 00 4D       ..M
                    ldd       #1000               * 060A CC 03 E8       L.h
                    std       <ABuf,U             * 060D ED C8 32       mH2
                    ldd       <U0030,U            * 0610 EC C8 30       lH0
                    bsr       L0657               * 0613 8D 42          .B
                    ldd       #100                * 0615 CC 00 64       L.d
                    std       <ABuf,U             * 0618 ED C8 32       mH2
                    ldd       <U0030,U            * 061B EC C8 30       lH0
                    bsr       L0657               * 061E 8D 37          .7
                    ldd       #10                 * 0620 CC 00 0A       L..
                    std       <ABuf,U             * 0623 ED C8 32       mH2
                    ldd       <U0030,U            * 0626 EC C8 30       lH0
                    bsr       L0657               * 0629 8D 2C          .,
                    ldd       #1                  * 062B CC 00 01       L..
                    std       <ABuf,U             * 062E ED C8 32       mH2
                    ldd       <U0030,U            * 0631 EC C8 30       lH0
                    bsr       L0657               * 0634 8D 21          .!
                    lda       #13                 * 0636 86 0D          ..
                    sta       0,X                 * 0638 A7 84          '.
                    puls      X                   * 063A 35 10          5.
                    ldb       #32                 * 063C C6 20          F
L063E               lda       0,X                 * 063E A6 84          &.
                    cmpa      #48                 * 0640 81 30          .0
                    bne       L0648               * 0642 26 04          &.
                    stb       ,X+                 * 0644 E7 80          g.
                    bra       L063E               * 0646 20 F6           v

L0648               lda       ,X+                 * 0648 A6 80          &.
                    cmpa      #48                 * 064A 81 30          .0
                    bcs       L0654               * 064C 25 06          %.
                    cmpa      #57                 * 064E 81 39          .9
                    bhi       L0654               * 0650 22 02          ".
                    bra       L0648               * 0652 20 F4           t

L0654               leax      -$01,X              * 0654 30 1F          0.
                    rts                           * 0656 39             9

L0657               subd      <ABuf,U             * 0657 A3 C8 32       #H2
                    bcs       L0660               * 065A 25 04          %.
                    inc       0,X                 * 065C 6C 84          l.
                    bra       L0657               * 065E 20 F7           w

L0660               addd      <ABuf,U             * 0660 E3 C8 32       cH2
                    std       <U0030,U            * 0663 ED C8 30       mH0
                    leax      $01,X               * 0666 30 01          0.
                    rts                           * 0668 39             9

L0669               ldd       #-1                 * 0669 CC FF FF       L..
                    puls      PC,Y                * 066C 35 A0          5

                    emod
eom                 equ       *
                    end
