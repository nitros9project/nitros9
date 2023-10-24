                    nam       DLD.validate
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
U0008               rmb       80
U0058               rmb       32
U0078               rmb       2
U007A               rmb       2
U007C               rmb       2
U007E               rmb       2
U0080               rmb       2
U0082               rmb       2
U0084               rmb       1
U0085               rmb       1
U0086               rmb       2
U0088               rmb       1
U0089               rmb       1
U008A               rmb       2
U008C               rmb       2
U008E               rmb       3
U0091               rmb       12
U009D               rmb       2
U009F               rmb       2
U00A1               rmb       27
U00BC               rmb       2
U00BE               rmb       2
U00C0               rmb       1
U00C1               rmb       64
U0101               rmb       1
U0102               rmb       8399
size                equ       .

name                fcs       /DLD.validate/      * 000D 44 4C 44 2E 76 61 6C 69 64 61 74 E5 DLD.validate
                    fcc       "Copyright (C) 1988By Keith AlphonsoLicenced to Alpha Software TechnologiesAll rights reserved" * 0019 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 4C 69 63 65 6E 63 65 64
                    fcb       $EC                 * 0076 EC             l
                    fcb       $E6                 * 0077 E6             f
                    fcb       $EA                 * 0078 EA             j
                    fcb       $F5                 * 0079 F5             u
                    fcb       $E9                 * 007A E9             i
                    fcb       $A0                 * 007B A0
                    fcb       $E2                 * 007C E2             b
                    fcb       $ED                 * 007D ED             m
                    fcb       $F1                 * 007E F1             q
                    fcb       $E9                 * 007F E9             i
                    fcb       $F0                 * 0080 F0             p
                    fcb       $EF                 * 0081 EF             o
                    fcb       $F4                 * 0082 F4             t
                    fcb       $F0                 * 0083 F0             p
L0084               fcb       $0A                 * 0084 0A             .
                    fcb       $0A                 * 0085 0A             .
                    fcc       "   Enter long description now          (Blank line ends)" * 0086 20 20 20 45 6E 74 65 72 20 6C 6F 6E 67 20 64 65 73 63 72 69 70 74 69 6F 6E 20 6E 6F 77 20 20 20 20 20 20 20 20 20 20 28 42 6C 61 6E 6B 20 6C 69 6E 65 20 65 6E 64 73
                    fcb       $0D                 * 00BE 0D             .
L00BF               fcc       "----------------------------------------------------------------" * 00BF 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 00FF 0D             .
L0100               fcc       "     Enter file keywords now            (Blank line ends)" * 0100 20 20 20 20 20 45 6E 74 65 72 20 66 69 6C 65 20 6B 65 79 77 6F 72 64 73 20 6E 6F 77 20 20 20 20 20 20 20 20 20 20 20 20 28 42 6C 61 6E 6B 20 6C 69 6E 65 20 65 6E 64
                    fcb       $0D                 * 0139 0D             .
L013A               fcc       "Enter keyword:"    * 013A 45 6E 74 65 72 20 6B 65 79 77 6F 72 64 3A Enter keyword:
L0148               fcb       $0A                 * 0148 0A             .
                    fcc       "[D]one [E]dit [C]ontinue or [L]ist" * 0149 5B 44 5D 6F 6E 65 20 5B 45 5D 64 69 74 20 5B 43 5D 6F 6E 74 69 6E 75 65 20 6F 72 20 5B 4C 5D 69 73 74 [D]one [E]dit [C]ontinue or [L]ist
                    fcb       $0D                 * 016B 0D             .
L016C               fcc       "Enter line #"      * 016C 45 6E 74 65 72 20 6C 69 6E 65 20 23 Enter line #
                    fcb       $0D                 * 0178 0D             .
L0179               fcb       $3E                 * 0179 3E             >
L017A               fcb       $0A                 * 017A 0A             .
                    fcb       $0D                 * 017B 0D             .
L017C               fcb       $0A                 * 017C 0A             .
                    fcc       "Programs to be validated" * 017D 50 72 6F 67 72 61 6D 73 20 74 6F 20 62 65 20 76 61 6C 69 64 61 74 65 64 Programs to be validated
                    fcb       $0D                 * 0195 0D             .
L0196               fcc       "File name      Description" * 0196 46 69 6C 65 20 6E 61 6D 65 20 20 20 20 20 20 44 65 73 63 72 69 70 74 69 6F 6E File name      Description
                    fcb       $0D                 * 01B0 0D             .
L01B1               fcc       "----------------------------------------------------------------------------" * 01B1 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 01FD 0D             .
L01FE               fcc       "[D]ownload, [V]alidate [K]ill or [N]ext:" * 01FE 5B 44 5D 6F 77 6E 6C 6F 61 64 2C 20 5B 56 5D 61 6C 69 64 61 74 65 20 5B 4B 5D 69 6C 6C 20 6F 72 20 5B 4E 5D 65 78 74 3A [D]ownload, [V]alidate [K]ill or [N]ext:
L0226               fcc       "DLD.lst"           * 0226 44 4C 44 2E 6C 73 74 DLD.lst
                    fcb       $0D                 * 022D 0D             .
L022E               fcc       "DLD.dsc"           * 022E 44 4C 44 2E 64 73 63 DLD.dsc
                    fcb       $0D                 * 0235 0D             .
L0236               fcc       "DLD.key"           * 0236 44 4C 44 2E 6B 65 79 DLD.key
                    fcb       $0D                 * 023D 0D             .
L023E               fcc       "                                                                               " * 023E 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 2
L028D               fcb       $0D                 * 028D 0D             .
                    fcb       $0A                 * 028E 0A             .
                    fcc       "Enter your download protocol" * 028F 45 6E 74 65 72 20 79 6F 75 72 20 64 6F 77 6E 6C 6F 61 64 20 70 72 6F 74 6F 63 6F 6C Enter your download protocol
                    fcb       $0D                 * 02AB 0D             .
L02AC               fcb       $0A                 * 02AC 0A             .
                    fcb       $0D                 * 02AD 0D             .
                    fcc       "[X] xmodem"        * 02AE 5B 58 5D 20 78 6D 6F 64 65 6D [X] xmodem
                    fcb       $0A                 * 02B8 0A             .
                    fcb       $0D                 * 02B9 0D             .
                    fcc       "[C] xmodem (CRC)"  * 02BA 5B 43 5D 20 78 6D 6F 64 65 6D 20 28 43 52 43 29 [C] xmodem (CRC)
                    fcb       $0A                 * 02CA 0A             .
                    fcb       $0D                 * 02CB 0D             .
                    fcc       "[Y] ymodem"        * 02CC 5B 59 5D 20 79 6D 6F 64 65 6D [Y] ymodem
                    fcb       $0A                 * 02D6 0A             .
                    fcb       $0D                 * 02D7 0D             .
                    fcc       "[Q] quit"          * 02D8 5B 51 5D 20 71 75 69 74 [Q] quit
                    fcb       $0A                 * 02E0 0A             .
                    fcb       $0D                 * 02E1 0D             .
                    fcc       "Protocol?"         * 02E2 50 72 6F 74 6F 63 6F 6C 3F Protocol?
L02EB               fcc       "dloadx"            * 02EB 64 6C 6F 61 64 78 dloadx
                    fcb       $0D                 * 02F1 0D             .
L02F2               fcc       "dloadxc"           * 02F2 64 6C 6F 61 64 78 63 dloadxc
                    fcb       $0D                 * 02F9 0D             .
L02FA               fcc       "dloady"            * 02FA 64 6C 6F 61 64 79 dloady
                    fcb       $0D                 * 0300 0D             .
                    fcc       "dloadyb"           * 0301 64 6C 6F 61 64 79 62 dloadyb
                    fcb       $0D                 * 0308 0D             .
L0309               fcb       $0A                 * 0309 0A             .
                    fcc       "Enter a one line description" * 030A 45 6E 74 65 72 20 61 20 6F 6E 65 20 6C 69 6E 65 20 64 65 73 63 72 69 70 74 69 6F 6E Enter a one line description
                    fcb       $0D                 * 0326 0D             .
L0327               fcc       "Delete file? (Y/N):" * 0327 44 65 6C 65 74 65 20 66 69 6C 65 3F 20 28 59 2F 4E 29 3A Delete file? (Y/N):
L033A               fcb       $08                 * 033A 08             .
                    fcb       $20                 * 033B 20
                    fcb       $08                 * 033C 08             .
start               lda       0,X                 * 033D A6 84          &.
                    cmpa      #13                 * 033F 81 0D          ..
                    beq       L034C               * 0341 27 09          '.
                    lda       #1                  * 0343 86 01          ..
                    os9       I$ChgDir            * 0345 10 3F 86       .?.
                    lbcs      L088E               * 0348 10 25 05 42    .%.B
L034C               leax      >L0236,PC           * 034C 30 8D FE E6    0.~f
                    lda       #2                  * 0350 86 02          ..
                    os9       I$Open              * 0352 10 3F 84       .?.
                    bcc       L0366               * 0355 24 0F          $.
                    cmpb      #216                * 0357 C1 D8          AX
                    lbne      L088E               * 0359 10 26 05 31    .&.1
                    ldb       #27                 * 035D C6 1B          F.
                    os9       I$Create            * 035F 10 3F 83       .?.
                    lbcs      L088E               * 0362 10 25 05 28    .%.(
L0366               sta       U0003,U             * 0366 A7 43          'C
                    leax      >L022E,PC           * 0368 30 8D FE C2    0.~B
                    lda       #3                  * 036C 86 03          ..
                    os9       I$Open              * 036E 10 3F 84       .?.
                    bcc       L0382               * 0371 24 0F          $.
                    cmpb      #216                * 0373 C1 D8          AX
                    lbne      L088E               * 0375 10 26 05 15    .&..
                    ldb       #27                 * 0379 C6 1B          F.
                    os9       I$Create            * 037B 10 3F 83       .?.
                    lbcs      L088E               * 037E 10 25 05 0C    .%..
L0382               sta       U0004,U             * 0382 A7 44          'D
                    leax      >L017C,PC           * 0384 30 8D FD F4    0.}t
                    ldy       #200                * 0388 10 8E 00 C8    ...H
                    lda       #1                  * 038C 86 01          ..
                    os9       I$WritLn            * 038E 10 3F 8C       .?.
                    leax      >L0196,PC           * 0391 30 8D FE 01    0.~.
                    ldy       #200                * 0395 10 8E 00 C8    ...H
                    os9       I$WritLn            * 0399 10 3F 8C       .?.
                    leax      >L01B1,PC           * 039C 30 8D FE 11    0.~.
                    ldy       #200                * 03A0 10 8E 00 C8    ...H
                    os9       I$WritLn            * 03A4 10 3F 8C       .?.
                    ldx       #0                  * 03A7 8E 00 00       ...
                    stx       <U0078,U            * 03AA AF C8 78       /Hx
                    stx       <U007A,U            * 03AD AF C8 7A       /Hz
                    stx       <U007C,U            * 03B0 AF C8 7C       /H|
                    stx       <U007E,U            * 03B3 AF C8 7E       /H~
                    leax      >L0226,PC           * 03B6 30 8D FE 6C    0.~l
                    lda       #3                  * 03BA 86 03          ..
                    os9       I$Open              * 03BC 10 3F 84       .?.
                    lbcs      L088E               * 03BF 10 25 04 CB    .%.K
                    sta       U0002,U             * 03C3 A7 42          'B
L03C5               ldd       <U0078,U            * 03C5 EC C8 78       lHx
                    std       >U0080,U            * 03C8 ED C9 00 80    mI..
                    ldd       <U007A,U            * 03CC EC C8 7A       lHz
                    std       >U0082,U            * 03CF ED C9 00 82    mI..
                    lda       U0002,U             * 03D3 A6 42          &B
                    pshs      U                   * 03D5 34 40          4@
                    ldx       <U0078,U            * 03D7 AE C8 78       .Hx
                    ldu       <U007A,U            * 03DA EE C8 7A       nHz
                    os9       I$Seek              * 03DD 10 3F 88       .?.
                    puls      U                   * 03E0 35 40          5@
                    leax      >U00A1,U            * 03E2 30 C9 00 A1    0I.!
                    ldy       #96                 * 03E6 10 8E 00 60    ...`
                    os9       I$Read              * 03EA 10 3F 89       .?.
                    lbcs      L0507               * 03ED 10 25 01 16    .%..
                    pshs      U                   * 03F1 34 40          4@
                    ldb       #5                  * 03F3 C6 05          F.
                    os9       I$GetStt            * 03F5 10 3F 8D       .?.
                    tfr       U,Y                 * 03F8 1F 32          .2
                    puls      U                   * 03FA 35 40          5@
                    stx       <U0078,U            * 03FC AF C8 78       /Hx
                    sty       <U007A,U            * 03FF 10 AF C8 7A    ./Hz
                    tst       >U00C0,U            * 0403 6D C9 00 C0    mI.@
                    lbne      L07F2               * 0407 10 26 03 E7    .&.g
                    clrb                          * 040B 5F             _
                    leax      >U00A1,U            * 040C 30 C9 00 A1    0I.!
L0410               lda       ,X+                 * 0410 A6 80          &.
                    cmpa      #13                 * 0412 81 0D          ..
                    beq       L0419               * 0414 27 03          '.
                    incb                          * 0416 5C             \
                    bra       L0410               * 0417 20 F7           w
L0419               stb       U0006,U             * 0419 E7 46          gF
                    clra                          * 041B 4F             O
                    tfr       D,Y                 * 041C 1F 02          ..
                    leax      >U00A1,U            * 041E 30 C9 00 A1    0I.!
                    lda       #1                  * 0422 86 01          ..
                    os9       I$Write             * 0424 10 3F 8A       .?.
                    ldb       #15                 * 0427 C6 0F          F.
                    subb      U0006,U             * 0429 E0 46          `F
                    blt       L0439               * 042B 2D 0C          -.
                    clra                          * 042D 4F             O
                    tfr       D,Y                 * 042E 1F 02          ..
                    lda       #1                  * 0430 86 01          ..
                    leax      >L023E,PC           * 0432 30 8D FE 08    0.~.
                    os9       I$Write             * 0436 10 3F 8A       .?.
L0439               leax      >U00C1,U            * 0439 30 C9 00 C1    0I.A
                    ldy       #65                 * 043D 10 8E 00 41    ...A
                    lda       #1                  * 0441 86 01          ..
                    os9       I$WritLn            * 0443 10 3F 8C       .?.
L0446               leax      >L01FE,PC           * 0446 30 8D FD B4    0.}4
                    ldy       #40                 * 044A 10 8E 00 28    ...(
                    lda       #1                  * 044E 86 01          ..
                    os9       I$Write             * 0450 10 3F 8A       .?.
                    leax      U0005,U             * 0453 30 45          0E
                    ldy       #1                  * 0455 10 8E 00 01    ....
                    clra                          * 0459 4F             O
                    os9       I$Read              * 045A 10 3F 89       .?.
                    leax      >L028D,PC           * 045D 30 8D FE 2C    0.~,
                    ldy       #1                  * 0461 10 8E 00 01    ....
                    lda       #1                  * 0465 86 01          ..
                    os9       I$WritLn            * 0467 10 3F 8C       .?.
                    lda       U0005,U             * 046A A6 45          &E
                    anda      #223                * 046C 84 DF          ._
                    cmpa      #86                 * 046E 81 56          .V
                    lbeq      L0489               * 0470 10 27 00 15    .'..
                    cmpa      #68                 * 0474 81 44          .D
                    lbeq      L077A               * 0476 10 27 03 00    .'..
                    cmpa      #78                 * 047A 81 4E          .N
                    lbeq      L07F2               * 047C 10 27 03 72    .'.r
                    cmpa      #75                 * 0480 81 4B          .K
                    lbeq      L0821               * 0482 10 27 03 9B    .'..
                    lbra      L0446               * 0486 16 FF BD       ..=
L0489               leax      >L0309,PC           * 0489 30 8D FE 7C    0.~|
                    ldy       #200                * 048D 10 8E 00 C8    ...H
                    lda       #1                  * 0491 86 01          ..
                    os9       I$WritLn            * 0493 10 3F 8C       .?.
                    leax      >L0179,PC           * 0496 30 8D FC DF    0.|_
                    ldy       #1                  * 049A 10 8E 00 01    ....
                    lda       #1                  * 049E 86 01          ..
                    os9       I$Write             * 04A0 10 3F 8A       .?.
                    leax      >U00C1,U            * 04A3 30 C9 00 C1    0I.A
                    ldy       #64                 * 04A7 10 8E 00 40    ...@
                    clra                          * 04AB 4F             O
                    os9       I$ReadLn            * 04AC 10 3F 8B       .?.
                    lda       #255                * 04AF 86 FF          ..
                    sta       >U00C0,U            * 04B1 A7 C9 00 C0    'I.@
                    lda       U0004,U             * 04B5 A6 44          &D
                    ldb       #2                  * 04B7 C6 02          F.
                    pshs      U                   * 04B9 34 40          4@
                    os9       I$GetStt            * 04BB 10 3F 8D       .?.
                    lbcs      L088E               * 04BE 10 25 03 CC    .%.L
                    os9       I$Seek              * 04C2 10 3F 88       .?.
                    lbcs      L088E               * 04C5 10 25 03 C5    .%.E
                    tfr       U,Y                 * 04C9 1F 32          .2
                    puls      U                   * 04CB 35 40          5@
                    stx       >U00BC,U            * 04CD AF C9 00 BC    /I.<
                    sty       >U00BE,U            * 04D1 10 AF C9 00 BE ./I.>
                    lda       U0002,U             * 04D6 A6 42          &B
                    pshs      U                   * 04D8 34 40          4@
                    ldx       <U007C,U            * 04DA AE C8 7C       .H|
                    ldu       <U007E,U            * 04DD EE C8 7E       nH~
                    os9       I$Seek              * 04E0 10 3F 88       .?.
                    puls      U                   * 04E3 35 40          5@
                    leax      >U00A1,U            * 04E5 30 C9 00 A1    0I.!
                    ldy       #96                 * 04E9 10 8E 00 60    ...`
                    lda       U0002,U             * 04ED A6 42          &B
                    os9       I$Write             * 04EF 10 3F 8A       .?.
                    pshs      U                   * 04F2 34 40          4@
                    ldb       #5                  * 04F4 C6 05          F.
                    os9       I$GetStt            * 04F6 10 3F 8D       .?.
                    tfr       U,Y                 * 04F9 1F 32          .2
                    puls      U                   * 04FB 35 40          5@
                    stx       <U007C,U            * 04FD AF C8 7C       /H|
                    sty       <U007E,U            * 0500 10 AF C8 7E    ./H~
                    lbra      L0521               * 0504 16 00 1A       ...
L0507               cmpb      #211                * 0507 C1 D3          AS
                    lbne      L088E               * 0509 10 26 03 81    .&..
                    lda       U0002,U             * 050D A6 42          &B
                    ldb       #2                  * 050F C6 02          F.
                    pshs      U                   * 0511 34 40          4@
                    ldx       <U007C,U            * 0513 AE C8 7C       .H|
                    ldu       <U007E,U            * 0516 EE C8 7E       nH~
                    os9       I$SetStt            * 0519 10 3F 8E       .?.
                    puls      U                   * 051C 35 40          5@
                    lbra      L088D               * 051E 16 03 6C       ..l
L0521               lda       U0003,U             * 0521 A6 43          &C
                    ldb       #2                  * 0523 C6 02          F.
                    pshs      U                   * 0525 34 40          4@
                    os9       I$GetStt            * 0527 10 3F 8D       .?.
                    lbcs      L088E               * 052A 10 25 03 60    .%.`
                    os9       I$Seek              * 052E 10 3F 88       .?.
                    lbcs      L088E               * 0531 10 25 03 59    .%.Y
                    puls      U                   * 0535 35 40          5@
                    leax      >L0100,PC           * 0537 30 8D FB C5    0.{E
                    ldy       #200                * 053B 10 8E 00 C8    ...H
                    lda       #1                  * 053F 86 01          ..
                    os9       I$WritLn            * 0541 10 3F 8C       .?.
                    leax      >L00BF,PC           * 0544 30 8D FB 77    0.{w
                    ldy       #65                 * 0548 10 8E 00 41    ...A
                    lda       #1                  * 054C 86 01          ..
                    os9       I$WritLn            * 054E 10 3F 8C       .?.
                    ldd       >U0080,U            * 0551 EC C9 00 80    lI..
                    std       >U009D,U            * 0555 ED C9 00 9D    mI..
                    ldd       >U0082,U            * 0559 EC C9 00 82    lI..
                    std       >U009F,U            * 055D ED C9 00 9F    mI..
L0561               leax      >L013A,PC           * 0561 30 8D FB D5    0.{U
                    ldy       #14                 * 0565 10 8E 00 0E    ....
                    lda       #1                  * 0569 86 01          ..
                    os9       I$Write             * 056B 10 3F 8A       .?.
                    leax      >U0091,U            * 056E 30 C9 00 91    0I..
                    ldy       #12                 * 0572 10 8E 00 0C    ....
                    clra                          * 0576 4F             O
                    os9       I$ReadLn            * 0577 10 3F 8B       .?.
                    lbcs      L0561               * 057A 10 25 FF E3    .%.c
                    cmpy      #1                  * 057E 10 8C 00 01    ....
                    lbls      L0591               * 0582 10 23 00 0B    .#..
                    lda       U0003,U             * 0586 A6 43          &C
                    ldy       #16                 * 0588 10 8E 00 10    ....
                    os9       I$Write             * 058C 10 3F 8A       .?.
                    bra       L0561               * 058F 20 D0           P
L0591               leax      >L0084,PC           * 0591 30 8D FA EF    0.zo
                    ldy       #200                * 0595 10 8E 00 C8    ...H
                    lda       #1                  * 0599 86 01          ..
                    os9       I$WritLn            * 059B 10 3F 8C       .?.
                    lbcs      L088E               * 059E 10 25 02 EC    .%.l
                    leax      >L00BF,PC           * 05A2 30 8D FB 19    0.{.
                    ldy       #80                 * 05A6 10 8E 00 50    ...P
                    os9       I$WritLn            * 05AA 10 3F 8C       .?.
                    lbcs      L088E               * 05AD 10 25 02 DD    .%.]
                    ldd       #0                  * 05B1 CC 00 00       L..
                    std       >U0084,U            * 05B4 ED C9 00 84    mI..
                    sta       U0007,U             * 05B8 A7 47          'G
L05BA               ldd       >U0084,U            * 05BA EC C9 00 84    lI..
                    addd      #1                  * 05BE C3 00 01       C..
                    std       >U0084,U            * 05C1 ED C9 00 84    mI..
                    cmpd      #99                 * 05C5 10 83 00 63    ...c
                    bge       L05D6               * 05C9 2C 0B          ,.
                    lbsr      L06EF               * 05CB 17 01 21       ..!
                    cmpy      #1                  * 05CE 10 8C 00 01    ....
                    bls       L05D6               * 05D2 23 02          #.
                    bra       L05BA               * 05D4 20 E4           d
L05D6               leax      >L0148,PC           * 05D6 30 8D FB 6E    0.{n
                    ldy       #200                * 05DA 10 8E 00 C8    ...H
                    lda       #1                  * 05DE 86 01          ..
                    os9       I$WritLn            * 05E0 10 3F 8C       .?.
                    leax      >L0179,PC           * 05E3 30 8D FB 92    0.{.
                    ldy       #1                  * 05E7 10 8E 00 01    ....
                    os9       I$Write             * 05EB 10 3F 8A       .?.
                    leax      U0005,U             * 05EE 30 45          0E
                    clra                          * 05F0 4F             O
                    ldy       #1                  * 05F1 10 8E 00 01    ....
                    os9       I$Read              * 05F5 10 3F 89       .?.
                    leax      >L017A,PC           * 05F8 30 8D FB 7E    0.{~
                    ldy       #1                  * 05FC 10 8E 00 01    ....
                    lda       #1                  * 0600 86 01          ..
                    os9       I$WritLn            * 0602 10 3F 8C       .?.
                    lda       U0005,U             * 0605 A6 45          &E
                    anda      #223                * 0607 84 DF          ._
                    cmpa      #68                 * 0609 81 44          .D
                    lbeq      L0742               * 060B 10 27 01 33    .'.3
                    cmpa      #69                 * 060F 81 45          .E
                    beq       L062C               * 0611 27 19          '.
                    cmpa      #67                 * 0613 81 43          .C
                    beq       L061F               * 0615 27 08          '.
                    cmpa      #76                 * 0617 81 4C          .L
                    lbeq      L06A6               * 0619 10 27 00 89    .'..
                    bra       L05D6               * 061D 20 B7           7
L061F               ldd       >U0084,U            * 061F EC C9 00 84    lI..
                    subd      #1                  * 0623 83 00 01       ...
                    std       >U0084,U            * 0626 ED C9 00 84    mI..
                    bra       L05BA               * 062A 20 8E           .
L062C               leax      >L016C,PC           * 062C 30 8D FB 3C    0.{<
                    ldy       #200                * 0630 10 8E 00 C8    ...H
                    lda       #1                  * 0634 86 01          ..
                    os9       I$WritLn            * 0636 10 3F 8C       .?.
                    leax      >L0179,PC           * 0639 30 8D FB 3C    0.{<
                    ldy       #1                  * 063D 10 8E 00 01    ....
                    os9       I$Write             * 0641 10 3F 8A       .?.
                    clra                          * 0644 4F             O
                    leax      >U008E,U            * 0645 30 C9 00 8E    0I..
                    ldy       #3                  * 0649 10 8E 00 03    ....
                    os9       I$ReadLn            * 064D 10 3F 8B       .?.
                    lbsr      L0A1D               * 0650 17 03 CA       ..J
                    cmpd      >U0084,U            * 0653 10 A3 C9 00 84 .#I..
                    lbcc      L05D6               * 0658 10 24 FF 7A    .$.z
                    std       >U008C,U            * 065C ED C9 00 8C    mI..
                    leax      >U008E,U            * 0660 30 C9 00 8E    0I..
                    lbsr      L0A96               * 0664 17 04 2F       ../
                    leax      >U008E,U            * 0667 30 C9 00 8E    0I..
                    lda       #58                 * 066B 86 3A          .:
                    sta       $02,X               * 066D A7 02          '.
                    ldy       #3                  * 066F 10 8E 00 03    ....
                    lda       #1                  * 0673 86 01          ..
                    os9       I$Write             * 0675 10 3F 8A       .?.
                    ldd       >U008C,U            * 0678 EC C9 00 8C    lI..
                    leax      >U0101,U            * 067C 30 C9 01 01    0I..
                    lda       #80                 * 0680 86 50          .P
                    mul                           * 0682 3D             =
                    leax      D,X                 * 0683 30 8B          0.
                    ldy       #80                 * 0685 10 8E 00 50    ...P
                    lda       #1                  * 0689 86 01          ..
                    os9       I$WritLn            * 068B 10 3F 8C       .?.
                    tfr       Y,D                 * 068E 1F 20          .
                    stb       U0007,U             * 0690 E7 47          gG
                    dec       U0007,U             * 0692 6A 47          jG
                    leay      U0008,U             * 0694 31 48          1H
L0696               lda       ,X+                 * 0696 A6 80          &.
                    sta       ,Y+                 * 0698 A7 A0          '
                    decb                          * 069A 5A             Z
                    bne       L0696               * 069B 26 F9          &y
                    ldd       >U008C,U            * 069D EC C9 00 8C    lI..
                    bsr       L06EF               * 06A1 8D 4C          .L
                    lbra      L05D6               * 06A3 16 FF 30       ..0
L06A6               ldd       #0                  * 06A6 CC 00 00       L..
                    std       >U0084,U            * 06A9 ED C9 00 84    mI..
L06AD               ldd       >U0084,U            * 06AD EC C9 00 84    lI..
                    addd      #1                  * 06B1 C3 00 01       C..
                    std       >U0084,U            * 06B4 ED C9 00 84    mI..
                    leax      >U008E,U            * 06B8 30 C9 00 8E    0I..
                    lbsr      L0A96               * 06BC 17 03 D7       ..W
                    leax      >U008E,U            * 06BF 30 C9 00 8E    0I..
                    lda       #58                 * 06C3 86 3A          .:
                    sta       $02,X               * 06C5 A7 02          '.
                    lda       #1                  * 06C7 86 01          ..
                    ldy       #3                  * 06C9 10 8E 00 03    ....
                    os9       I$Write             * 06CD 10 3F 8A       .?.
                    leax      >U0101,U            * 06D0 30 C9 01 01    0I..
                    ldd       >U0084,U            * 06D4 EC C9 00 84    lI..
                    lda       #80                 * 06D8 86 50          .P
                    mul                           * 06DA 3D             =
                    leax      D,X                 * 06DB 30 8B          0.
                    ldy       #80                 * 06DD 10 8E 00 50    ...P
                    lda       #1                  * 06E1 86 01          ..
                    os9       I$WritLn            * 06E3 10 3F 8C       .?.
                    cmpy      #1                  * 06E6 10 8C 00 01    ....
                    bhi       L06AD               * 06EA 22 C1          "A
                    lbra      L05D6               * 06EC 16 FE E7       .~g
L06EF               leax      >U008E,U            * 06EF 30 C9 00 8E    0I..
                    pshs      D                   * 06F3 34 06          4.
                    lbsr      L0A96               * 06F5 17 03 9E       ...
                    leax      >U008E,U            * 06F8 30 C9 00 8E    0I..
                    lda       #58                 * 06FC 86 3A          .:
                    sta       $02,X               * 06FE A7 02          '.
                    lda       #1                  * 0700 86 01          ..
                    ldy       #3                  * 0702 10 8E 00 03    ....
                    os9       I$Write             * 0706 10 3F 8A       .?.
                    lbcs      L088E               * 0709 10 25 01 81    .%..
                    leax      U0008,U             * 070D 30 48          0H
                    ldb       U0007,U             * 070F E6 47          fG
                    clra                          * 0711 4F             O
                    tfr       D,Y                 * 0712 1F 02          ..
                    lda       #1                  * 0714 86 01          ..
                    os9       I$Write             * 0716 10 3F 8A       .?.
                    puls      D                   * 0719 35 06          5.
                    lda       #80                 * 071B 86 50          .P
                    mul                           * 071D 3D             =
                    leax      >U0101,U            * 071E 30 C9 01 01    0I..
                    leax      D,X                 * 0722 30 8B          0.
                    leay      U0008,U             * 0724 31 48          1H
                    ldb       #80                 * 0726 C6 50          FP
                    lda       U0007,U             * 0728 A6 47          &G
                    beq       L073B               * 072A 27 0F          '.
                    sta       >U0088,U            * 072C A7 C9 00 88    'I..
L0730               lda       ,Y+                 * 0730 A6 A0          &
                    sta       ,X+                 * 0732 A7 80          '.
                    decb                          * 0734 5A             Z
                    dec       >U0088,U            * 0735 6A C9 00 88    jI..
                    bne       L0730               * 0739 26 F5          &u
L073B               clra                          * 073B 4F             O
                    tfr       D,Y                 * 073C 1F 02          ..
                    lbsr      L0891               * 073E 17 01 50       ..P
                    rts                           * 0741 39             9
L0742               lda       #0                  * 0742 86 00          ..
                    sta       >U0086,U            * 0744 A7 C9 00 86    'I..
L0748               lda       >U0086,U            * 0748 A6 C9 00 86    &I..
                    inca                          * 074C 4C             L
                    sta       >U0086,U            * 074D A7 C9 00 86    'I..
                    cmpa      >U0085,U            * 0751 A1 C9 00 85    !I..
                    bhi       L0777               * 0755 22 20          "
                    ldb       #80                 * 0757 C6 50          FP
                    mul                           * 0759 3D             =
                    leax      >U0101,U            * 075A 30 C9 01 01    0I..
                    leax      D,X                 * 075E 30 8B          0.
                    ldy       #80                 * 0760 10 8E 00 50    ...P
                    lda       U0004,U             * 0764 A6 44          &D
                    os9       I$WritLn            * 0766 10 3F 8C       .?.
                    lbcs      L088E               * 0769 10 25 01 21    .%.!
                    cmpy      #1                  * 076D 10 8C 00 01    ....
                    bls       L0777               * 0771 23 04          #.
                    tfr       Y,D                 * 0773 1F 20          .
                    bra       L0748               * 0775 20 D1           Q
L0777               lbra      L03C5               * 0777 16 FC 4B       .|K
L077A               leax      >L02AC,PC           * 077A 30 8D FB 2E    0.{.
                    ldy       #63                 * 077E 10 8E 00 3F    ...?
                    lda       #1                  * 0782 86 01          ..
                    os9       I$Write             * 0784 10 3F 8A       .?.
                    leax      U0005,U             * 0787 30 45          0E
                    ldy       #1                  * 0789 10 8E 00 01    ....
                    clra                          * 078D 4F             O
                    os9       I$Read              * 078E 10 3F 89       .?.
                    leax      >L028D,PC           * 0791 30 8D FA F8    0.zx
                    ldy       #1                  * 0795 10 8E 00 01    ....
                    lda       #1                  * 0799 86 01          ..
                    os9       I$WritLn            * 079B 10 3F 8C       .?.
                    lda       U0005,U             * 079E A6 45          &E
                    anda      #223                * 07A0 84 DF          ._
                    cmpa      #88                 * 07A2 81 58          .X
                    beq       L07B6               * 07A4 27 10          '.
                    cmpa      #67                 * 07A6 81 43          .C
                    beq       L07BC               * 07A8 27 12          '.
                    cmpa      #89                 * 07AA 81 59          .Y
                    beq       L07C2               * 07AC 27 14          '.
                    cmpa      #81                 * 07AE 81 51          .Q
                    lbeq      L088D               * 07B0 10 27 00 D9    .'.Y
                    bra       L077A               * 07B4 20 C4           D
L07B6               leax      >L02EB,PC           * 07B6 30 8D FB 31    0.{1
                    bra       L07CC               * 07BA 20 10           .
L07BC               leax      >L02F2,PC           * 07BC 30 8D FB 32    0.{2
                    bra       L07CC               * 07C0 20 0A           .
L07C2               leax      >L02FA,PC           * 07C2 30 8D FB 34    0.{4
                    bra       L07CC               * 07C6 20 04           .
                    fcb       $30                 * 07C8 30             0
                    fcb       $8D                 * 07C9 8D             .
                    fcb       $FB                 * 07CA FB             {
                    fcb       $35                 * 07CB 35             5
L07CC               ldb       U0006,U             * 07CC E6 46          fF
                    incb                          * 07CE 5C             \
                    clra                          * 07CF 4F             O
                    tfr       D,Y                 * 07D0 1F 02          ..
                    lda       #17                 * 07D2 86 11          ..
                    ldb       #3                  * 07D4 C6 03          F.
                    pshs      U                   * 07D6 34 40          4@
                    leau      >U00A1,U            * 07D8 33 C9 00 A1    3I.!
                    os9       F$Fork              * 07DC 10 3F 03       .?.
                    lbcs      L088E               * 07DF 10 25 00 AB    .%.+
                    clrb                          * 07E3 5F             _
                    os9       F$Wait              * 07E4 10 3F 04       .?.
                    lbcs      L088E               * 07E7 10 25 00 A3    .%.#
                    puls      U                   * 07EB 35 40          5@
                    tstb                          * 07ED 5D             ]
                    lbne      L077A               * 07EE 10 26 FF 88    .&..
L07F2               lda       U0002,U             * 07F2 A6 42          &B
                    pshs      U                   * 07F4 34 40          4@
                    ldx       <U007C,U            * 07F6 AE C8 7C       .H|
                    ldu       <U007E,U            * 07F9 EE C8 7E       nH~
                    os9       I$Seek              * 07FC 10 3F 88       .?.
                    puls      U                   * 07FF 35 40          5@
                    leax      >U00A1,U            * 0801 30 C9 00 A1    0I.!
                    ldy       #96                 * 0805 10 8E 00 60    ...`
                    os9       I$Write             * 0809 10 3F 8A       .?.
                    pshs      U                   * 080C 34 40          4@
                    ldb       #5                  * 080E C6 05          F.
                    os9       I$GetStt            * 0810 10 3F 8D       .?.
                    tfr       U,Y                 * 0813 1F 32          .2
                    puls      U                   * 0815 35 40          5@
                    stx       <U007C,U            * 0817 AF C8 7C       /H|
                    sty       <U007E,U            * 081A 10 AF C8 7E    ./H~
                    lbra      L03C5               * 081E 16 FB A4       .{$
L0821               leax      >L0327,PC           * 0821 30 8D FB 02    0.{.
                    ldy       #19                 * 0825 10 8E 00 13    ....
                    lda       #1                  * 0829 86 01          ..
                    os9       I$Write             * 082B 10 3F 8A       .?.
                    leax      U0005,U             * 082E 30 45          0E
                    ldy       #1                  * 0830 10 8E 00 01    ....
                    clra                          * 0834 4F             O
                    os9       I$Read              * 0835 10 3F 89       .?.
                    leax      >L017A,PC           * 0838 30 8D F9 3E    0.y>
                    ldy       #1                  * 083C 10 8E 00 01    ....
                    lda       #1                  * 0840 86 01          ..
                    os9       I$WritLn            * 0842 10 3F 8C       .?.
                    lda       U0005,U             * 0845 A6 45          &E
                    anda      #223                * 0847 84 DF          ._
                    cmpa      #89                 * 0849 81 59          .Y
                    lbne      L07F2               * 084B 10 26 FF A3    .&.#
                    leax      >U00A1,U            * 084F 30 C9 00 A1    0I.!
                    os9       I$Delete            * 0853 10 3F 87       .?.
                    lda       #1                  * 0856 86 01          ..
                    sta       >U00C0,U            * 0858 A7 C9 00 C0    'I.@
                    lda       U0002,U             * 085C A6 42          &B
                    pshs      U                   * 085E 34 40          4@
                    ldx       <U007C,U            * 0860 AE C8 7C       .H|
                    ldu       <U007E,U            * 0863 EE C8 7E       nH~
                    os9       I$Seek              * 0866 10 3F 88       .?.
                    puls      U                   * 0869 35 40          5@
                    leax      >U00A1,U            * 086B 30 C9 00 A1    0I.!
                    ldy       #96                 * 086F 10 8E 00 60    ...`
                    lda       U0002,U             * 0873 A6 42          &B
                    os9       I$Write             * 0875 10 3F 8A       .?.
                    pshs      U                   * 0878 34 40          4@
                    ldb       #5                  * 087A C6 05          F.
                    os9       I$GetStt            * 087C 10 3F 8D       .?.
                    tfr       U,Y                 * 087F 1F 32          .2
                    puls      U                   * 0881 35 40          5@
                    stx       <U007C,U            * 0883 AF C8 7C       /H|
                    sty       <U007E,U            * 0886 10 AF C8 7E    ./H~
                    lbra      L03C5               * 088A 16 FB 38       .{8
L088D               clrb                          * 088D 5F             _
L088E               os9       F$Exit              * 088E 10 3F 06       .?.
L0891               lbsr      L09E8               * 0891 17 01 54       ..T
                    ldb       U0007,U             * 0894 E6 47          fG
                    leay      B,Y                 * 0896 31 A5          1%
                    pshs      Y                   * 0898 34 20          4
                    negb                          * 089A 50             P
                    sex                           * 089B 1D             .
                    leay      D,Y                 * 089C 31 AB          1+
                    clr       U0007,U             * 089E 6F 47          oG
                    cmpy      #0                  * 08A0 10 8C 00 00    ....
                    lbeq      L0960               * 08A4 10 27 00 B8    .'.8
                    pshs      Y,X                 * 08A8 34 30          40
                    lda       #13                 * 08AA 86 0D          ..
L08AC               sta       ,X+                 * 08AC A7 80          '.
                    leay      -$01,Y              * 08AE 31 3F          1?
                    bne       L08AC               * 08B0 26 FA          &z
                    puls      Y,X                 * 08B2 35 30          50
L08B4               pshs      Y,X                 * 08B4 34 30          40
                    leax      U0005,U             * 08B6 30 45          0E
                    ldy       #1                  * 08B8 10 8E 00 01    ....
                    clra                          * 08BC 4F             O
                    os9       I$Read              * 08BD 10 3F 89       .?.
                    bcs       L08ED               * 08C0 25 2B          %+
                    lda       U0005,U             * 08C2 A6 45          &E
                    cmpa      #1                  * 08C4 81 01          ..
                    beq       L08F1               * 08C6 27 29          ')
                    cmpa      #8                  * 08C8 81 08          ..
                    beq       L0913               * 08CA 27 47          'G
                    cmpa      #24                 * 08CC 81 18          ..
                    beq       L0937               * 08CE 27 67          'g
                    cmpa      #13                 * 08D0 81 0D          ..
                    lbeq      L095E               * 08D2 10 27 00 88    .'..
                    cmpa      #32                 * 08D6 81 20          .
                    bcs       L08ED               * 08D8 25 13          %.
                    lda       #1                  * 08DA 86 01          ..
                    os9       I$Write             * 08DC 10 3F 8A       .?.
                    puls      Y,X                 * 08DF 35 30          50
                    lda       U0005,U             * 08E1 A6 45          &E
                    sta       ,X+                 * 08E3 A7 80          '.
                    leay      -$01,Y              * 08E5 31 3F          1?
                    lbeq      L0987               * 08E7 10 27 00 9C    .'..
                    bra       L08B4               * 08EB 20 C7           G
L08ED               puls      Y,X                 * 08ED 35 30          50
                    bra       L08B4               * 08EF 20 C3           C
L08F1               puls      Y,X                 * 08F1 35 30          50
                    leay      -$01,Y              * 08F3 31 3F          1?
                    beq       L090E               * 08F5 27 17          '.
                    lda       ,X+                 * 08F7 A6 80          &.
                    cmpa      #13                 * 08F9 81 0D          ..
                    beq       L090C               * 08FB 27 0F          '.
                    pshs      Y,X                 * 08FD 34 30          40
                    leax      -$01,X              * 08FF 30 1F          0.
                    ldy       #1                  * 0901 10 8E 00 01    ....
                    lda       #1                  * 0905 86 01          ..
                    os9       I$Write             * 0907 10 3F 8A       .?.
                    bra       L08F1               * 090A 20 E5           e
L090C               leax      -$01,X              * 090C 30 1F          0.
L090E               leay      $01,Y               * 090E 31 21          1!
                    lbra      L08B4               * 0910 16 FF A1       ..!
L0913               puls      Y,X                 * 0913 35 30          50
                    leay      $01,Y               * 0915 31 21          1!
                    cmpy      0,S                 * 0917 10 AC E4       .,d
                    bhi       L0932               * 091A 22 16          ".
                    pshs      Y,X                 * 091C 34 30          40
                    leax      >L033A,PC           * 091E 30 8D FA 18    0.z.
                    ldy       #3                  * 0922 10 8E 00 03    ....
                    lda       #1                  * 0926 86 01          ..
                    os9       I$Write             * 0928 10 3F 8A       .?.
                    puls      Y,X                 * 092B 35 30          50
                    leax      -$01,X              * 092D 30 1F          0.
                    lbra      L08B4               * 092F 16 FF 82       ...
L0932               leay      -$01,Y              * 0932 31 3F          1?
                    lbra      L08B4               * 0934 16 FF 7D       ..}
L0937               puls      Y,X                 * 0937 35 30          50
                    leay      $01,Y               * 0939 31 21          1!
                    cmpy      0,S                 * 093B 10 AC E4       .,d
                    bhi       L0932               * 093E 22 F2          "r
                    pshs      Y,X                 * 0940 34 30          40
                    leax      >L033A,PC           * 0942 30 8D F9 F4    0.yt
                    ldy       #3                  * 0946 10 8E 00 03    ....
                    lda       #1                  * 094A 86 01          ..
                    os9       I$Write             * 094C 10 3F 8A       .?.
                    puls      Y,X                 * 094F 35 30          50
                    leax      -$01,X              * 0951 30 1F          0.
                    cmpy      0,S                 * 0953 10 AC E4       .,d
                    lbhi      L08B4               * 0956 10 22 FF 5A    .".Z
                    pshs      Y,X                 * 095A 34 30          40
                    bra       L0937               * 095C 20 D9           Y
L095E               puls      Y,X                 * 095E 35 30          50
L0960               lda       #13                 * 0960 86 0D          ..
                    sta       ,X+                 * 0962 A7 80          '.
                    pshs      Y,X                 * 0964 34 30          40
                    leax      >L017A,PC           * 0966 30 8D F8 10    0.x.
                    ldy       #1                  * 096A 10 8E 00 01    ....
                    lda       #1                  * 096E 86 01          ..
                    os9       I$WritLn            * 0970 10 3F 8C       .?.
                    puls      Y,X                 * 0973 35 30          50
                    puls      D                   * 0975 35 06          5.
                    pshs      Y                   * 0977 34 20          4
                    subd      0,S                 * 0979 A3 E4          #d
                    leas      $02,S               * 097B 32 62          2b
                    tfr       D,Y                 * 097D 1F 02          ..
                    leay      $01,Y               * 097F 31 21          1!
                    lbsr      L0A01               * 0981 17 00 7D       ..}
                    rts                           * 0984 39             9
                    fcc       "50"                * 0985 35 30          50
L0987               puls      D                   * 0987 35 06          5.
                    pshs      Y                   * 0989 34 20          4
                    subd      0,S                 * 098B A3 E4          #d
                    leas      $02,S               * 098D 32 62          2b
                    addd      #1                  * 098F C3 00 01       C..
                    tfr       D,Y                 * 0992 1F 02          ..
                    clrb                          * 0994 5F             _
L0995               leay      -$01,Y              * 0995 31 3F          1?
                    beq       L09B3               * 0997 27 1A          '.
                    lda       ,-X                 * 0999 A6 82          &.
                    cmpa      #32                 * 099B 81 20          .
                    beq       L09C4               * 099D 27 25          '%
                    pshs      Y,X                 * 099F 34 30          40
                    leax      >L033A,PC           * 09A1 30 8D F9 95    0.y.
                    ldy       #3                  * 09A5 10 8E 00 03    ....
                    lda       #1                  * 09A9 86 01          ..
                    os9       I$Write             * 09AB 10 3F 8A       .?.
                    incb                          * 09AE 5C             \
                    puls      Y,X                 * 09AF 35 30          50
                    bra       L0995               * 09B1 20 E2           b
L09B3               lda       #13                 * 09B3 86 0D          ..
                    sta       <$004F,X            * 09B5 A7 88 4F       '.O
                    ldy       #200                * 09B8 10 8E 00 C8    ...H
                    lda       #1                  * 09BC 86 01          ..
                    os9       I$WritLn            * 09BE 10 3F 8C       .?.
                    puls      Y                   * 09C1 35 20          5
                    rts                           * 09C3 39             9
L09C4               lda       #13                 * 09C4 86 0D          ..
                    sta       ,X+                 * 09C6 A7 80          '.
                    pshs      Y,X                 * 09C8 34 30          40
                    stb       U0007,U             * 09CA E7 47          gG
                    leay      U0008,U             * 09CC 31 48          1H
L09CE               lda       ,X+                 * 09CE A6 80          &.
                    sta       ,Y+                 * 09D0 A7 A0          '
                    decb                          * 09D2 5A             Z
                    bne       L09CE               * 09D3 26 F9          &y
                    leax      >L017A,PC           * 09D5 30 8D F7 A1    0.w!
                    ldy       #1                  * 09D9 10 8E 00 01    ....
                    lda       #1                  * 09DD 86 01          ..
                    os9       I$WritLn            * 09DF 10 3F 8C       .?.
                    puls      Y,X                 * 09E2 35 30          50
                    lbsr      L0A01               * 09E4 17 00 1A       ...
                    rts                           * 09E7 39             9
L09E8               pshs      Y,X,D               * 09E8 34 36          46
                    leax      <U0058,U            * 09EA 30 C8 58       0HX
                    clra                          * 09ED 4F             O
                    ldb       #0                  * 09EE C6 00          F.
                    os9       I$GetStt            * 09F0 10 3F 8D       .?.
                    leax      -$20,X              * 09F3 30 88 E0       0.`
                    clr       <$0024,X            * 09F6 6F 88 24       o.$
                    leax      <$0020,X            * 09F9 30 88 20       0.
                    os9       I$SetStt            * 09FC 10 3F 8E       .?.
                    puls      PC,Y,X,D            * 09FF 35 B6          56
L0A01               pshs      Y,X,D               * 0A01 34 36          46
                    leax      <U0058,U            * 0A03 30 C8 58       0HX
                    clra                          * 0A06 4F             O
                    ldb       #0                  * 0A07 C6 00          F.
                    os9       I$GetStt            * 0A09 10 3F 8D       .?.
                    leax      -$20,X              * 0A0C 30 88 E0       0.`
                    lda       #1                  * 0A0F 86 01          ..
                    sta       <$0024,X            * 0A11 A7 88 24       '.$
                    leax      <$0020,X            * 0A14 30 88 20       0.
                    clra                          * 0A17 4F             O
                    os9       I$SetStt            * 0A18 10 3F 8E       .?.
                    puls      PC,Y,X,D            * 0A1B 35 B6          56
L0A1D               pshs      Y                   * 0A1D 34 20          4
L0A1F               lda       ,X+                 * 0A1F A6 80          &.
                    cmpa      #13                 * 0A21 81 0D          ..
                    lbeq      L0AD7               * 0A23 10 27 00 B0    .'.0
                    cmpa      #48                 * 0A27 81 30          .0
                    bcs       L0A1F               * 0A29 25 F4          %t
                    cmpa      #57                 * 0A2B 81 39          .9
                    bhi       L0A1F               * 0A2D 22 F0          "p
                    leax      -$01,X              * 0A2F 30 1F          0.
L0A31               lda       ,X+                 * 0A31 A6 80          &.
                    cmpa      #48                 * 0A33 81 30          .0
                    bcs       L0A3D               * 0A35 25 06          %.
                    cmpa      #57                 * 0A37 81 39          .9
                    bhi       L0A3D               * 0A39 22 02          ".
                    bra       L0A31               * 0A3B 20 F4           t
L0A3D               pshs      X                   * 0A3D 34 10          4.
                    leax      -$01,X              * 0A3F 30 1F          0.
                    clr       >U0088,U            * 0A41 6F C9 00 88    oI..
                    clr       >U0089,U            * 0A45 6F C9 00 89    oI..
                    ldd       #1                  * 0A49 CC 00 01       L..
                    std       >U008A,U            * 0A4C ED C9 00 8A    mI..
L0A50               lda       ,-X                 * 0A50 A6 82          &.
                    cmpa      #48                 * 0A52 81 30          .0
                    bcs       L0A8E               * 0A54 25 38          %8
                    cmpa      #57                 * 0A56 81 39          .9
                    bhi       L0A8E               * 0A58 22 34          "4
                    suba      #48                 * 0A5A 80 30          .0
                    sta       U0001,U             * 0A5C A7 41          'A
                    ldd       #0                  * 0A5E CC 00 00       L..
L0A61               tst       U0001,U             * 0A61 6D 41          mA
                    beq       L0A6D               * 0A63 27 08          '.
                    addd      >U008A,U            * 0A65 E3 C9 00 8A    cI..
                    dec       U0001,U             * 0A69 6A 41          jA
                    bra       L0A61               * 0A6B 20 F4           t
L0A6D               addd      >U0088,U            * 0A6D E3 C9 00 88    cI..
                    std       >U0088,U            * 0A71 ED C9 00 88    mI..
                    lda       #10                 * 0A75 86 0A          ..
                    sta       U0001,U             * 0A77 A7 41          'A
                    ldd       #0                  * 0A79 CC 00 00       L..
L0A7C               tst       U0001,U             * 0A7C 6D 41          mA
                    beq       L0A88               * 0A7E 27 08          '.
                    addd      >U008A,U            * 0A80 E3 C9 00 8A    cI..
                    dec       U0001,U             * 0A84 6A 41          jA
                    bra       L0A7C               * 0A86 20 F4           t
L0A88               std       >U008A,U            * 0A88 ED C9 00 8A    mI..
                    bra       L0A50               * 0A8C 20 C2           B
L0A8E               ldd       >U0088,U            * 0A8E EC C9 00 88    lI..
                    puls      X                   * 0A92 35 10          5.
                    puls      PC,Y                * 0A94 35 A0          5
L0A96               pshs      Y                   * 0A96 34 20          4
                    std       >U0088,U            * 0A98 ED C9 00 88    mI..
                    lda       #48                 * 0A9C 86 30          .0
                    sta       0,X                 * 0A9E A7 84          '.
                    sta       $01,X               * 0AA0 A7 01          '.
                    ldd       #10                 * 0AA2 CC 00 0A       L..
                    std       >U008A,U            * 0AA5 ED C9 00 8A    mI..
                    ldd       >U0088,U            * 0AA9 EC C9 00 88    lI..
                    bsr       L0AC2               * 0AAD 8D 13          ..
                    ldd       #1                  * 0AAF CC 00 01       L..
                    std       >U008A,U            * 0AB2 ED C9 00 8A    mI..
                    ldd       >U0088,U            * 0AB6 EC C9 00 88    lI..
                    bsr       L0AC2               * 0ABA 8D 06          ..
                    lda       #13                 * 0ABC 86 0D          ..
                    sta       0,X                 * 0ABE A7 84          '.
                    puls      PC,Y                * 0AC0 35 A0          5
L0AC2               subd      >U008A,U            * 0AC2 A3 C9 00 8A    #I..
                    bcs       L0ACC               * 0AC6 25 04          %.
                    inc       0,X                 * 0AC8 6C 84          l.
                    bra       L0AC2               * 0ACA 20 F6           v
L0ACC               addd      >U008A,U            * 0ACC E3 C9 00 8A    cI..
                    std       >U0088,U            * 0AD0 ED C9 00 88    mI..
                    leax      $01,X               * 0AD4 30 01          0.
                    rts                           * 0AD6 39             9
L0AD7               ldd       #-1                 * 0AD7 CC FF FF       L..
                    puls      PC,Y                * 0ADA 35 A0          5

                    emod
eom                 equ       *
                    end
