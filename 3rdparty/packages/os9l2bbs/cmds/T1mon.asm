                    nam       T1mon
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       1
U0001               rmb       2
U0003               rmb       1
U0004               rmb       1
U0005               rmb       1
U0006               rmb       2
U0008               rmb       32
U0028               rmb       1
U0029               rmb       599
size                equ       .

name                fcs       /T1mon/             * 000D 54 31 6D 6F EE T1mon
                    fcc       "Copyright (C) 1988By Keith AlphonsoLicenced to Alpha Software TechnologiesAll rights reserved" * 0012 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 4C 69 63 65 6E 63 65 64
                    fcb       $EC                 * 006F EC             l
                    fcb       $E6                 * 0070 E6             f
                    fcb       $EA                 * 0071 EA             j
                    fcb       $F5                 * 0072 F5             u
                    fcb       $E9                 * 0073 E9             i
                    fcb       $A0                 * 0074 A0
                    fcb       $E2                 * 0075 E2             b
                    fcb       $ED                 * 0076 ED             m
                    fcb       $F1                 * 0077 F1             q
                    fcb       $E9                 * 0078 E9             i
                    fcb       $F0                 * 0079 F0             p
                    fcb       $EF                 * 007A EF             o
                    fcb       $F4                 * 007B F4             t
                    fcb       $F0                 * 007C F0             p
L007D               fcc       "Login"             * 007D 4C 6F 67 69 6E Login
                    fcb       $0D                 * 0082 0D             .
                    fcc       "Monitor"           * 0083 4D 6F 6E 69 74 6F 72 Monitor
                    fcb       $0D                 * 008A 0D             .
L008B               fcb       $0D                 * 008B 0D             .
                    fcb       $0A                 * 008C 0A             .
                    fcc       "Monitoring "       * 008D 4D 6F 6E 69 74 6F 72 69 6E 67 20 Monitoring
L0098               fcc       "110  Baud 300  Baud 600  Baud 1200 Baud 2400 Baud " * 0098 31 31 30 20 20 42 61 75 64 20 33 30 30 20 20 42 61 75 64 20 36 30 30 20 20 42 61 75 64 20 31 32 30 30 20 42 61 75 64 20 32 34 30 30 20 42 61 75 64 20 110  Baud 300  Baud 6
L00CA               fcc       "8 bits, no parity" * 00CA 38 20 62 69 74 73 2C 20 6E 6F 20 70 61 72 69 74 79 8 bits, no parity
                    fcb       $0D                 * 00DB 0D             .
L00DC               fcc       "User name            Date                time" * 00DC 55 73 65 72 20 6E 61 6D 65 20 20 20 20 20 20 20 20 20 20 20 20 44 61 74 65 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 74 69 6D 65 User name            Date
                    fcb       $0D                 * 0109 0D             .
L010A               fcc       "------------------------------------------------------------------------" * 010A 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
                    fcb       $0D                 * 0152 0D             .
L0153               fcb       $2F                 * 0153 2F             /
                    fcb       $70                 * 0154 70             p
                    fcb       $0D                 * 0155 0D             .
L0156               fcc       "Modem.set"         * 0156 4D 6F 64 65 6D 2E 73 65 74 Modem.set
                    fcb       $0D                 * 015F 0D             .
start               clr       U0003,U             * 0160 6F 43          oC
                    stx       U0006,U             * 0162 AF 46          /F
                    lda       #255                * 0164 86 FF          ..
                    sta       U0003,U             * 0166 A7 43          'C
                    leax      >L0284,PC           * 0168 30 8D 01 18    0...
                    os9       F$Icpt              * 016C 10 3F 09       .?.
                    clra                          * 016F 4F             O
                    os9       I$Close             * 0170 10 3F 8F       .?.
                    inca                          * 0173 4C             L
                    os9       I$Close             * 0174 10 3F 8F       .?.
                    inca                          * 0177 4C             L
                    os9       I$Close             * 0178 10 3F 8F       .?.
                    leax      >L0153,PC           * 017B 30 8D FF D4    0..T
                    lda       #2                  * 017F 86 02          ..
                    os9       I$Open              * 0181 10 3F 84       .?.
                    leax      >L00DC,PC           * 0184 30 8D FF 54    0..T
                    ldy       #200                * 0188 10 8E 00 C8    ...H
                    os9       I$WritLn            * 018C 10 3F 8C       .?.
                    leax      >L010A,PC           * 018F 30 8D FF 77    0..w
                    ldy       #80                 * 0193 10 8E 00 50    ...P
                    os9       I$WritLn            * 0197 10 3F 8C       .?.
                    os9       I$Close             * 019A 10 3F 8F       .?.
L019D               ldx       U0006,U             * 019D AE 46          .F
                    lda       #3                  * 019F 86 03          ..
                    os9       I$Open              * 01A1 10 3F 84       .?.
                    lbcs      L027E               * 01A4 10 25 00 D6    .%.V
                    os9       I$Dup               * 01A8 10 3F 82       .?.
                    os9       I$Dup               * 01AB 10 3F 82       .?.
                    leax      >L0156,PC           * 01AE 30 8D FF A4    0..$
                    lda       #1                  * 01B2 86 01          ..
                    os9       I$Open              * 01B4 10 3F 84       .?.
                    bcs       L01D7               * 01B7 25 1E          %.
L01B9               leax      <U0028,U            * 01B9 30 C8 28       0H(
                    ldy       #200                * 01BC 10 8E 00 C8    ...H
                    os9       I$ReadLn            * 01C0 10 3F 8B       .?.
                    bcs       L01D4               * 01C3 25 0F          %.
                    pshs      A                   * 01C5 34 02          4.
                    lda       #1                  * 01C7 86 01          ..
                    ldy       #200                * 01C9 10 8E 00 C8    ...H
                    os9       I$WritLn            * 01CD 10 3F 8C       .?.
                    puls      A                   * 01D0 35 02          5.
                    bra       L01B9               * 01D2 20 E5           e
L01D4               os9       I$Close             * 01D4 10 3F 8F       .?.
L01D7               leax      U0008,U             * 01D7 30 48          0H
                    clra                          * 01D9 4F             O
                    clrb                          * 01DA 5F             _
                    os9       I$GetStt            * 01DB 10 3F 8D       .?.
                    leax      -$20,X              * 01DE 30 88 E0       0.`
                    lda       #1                  * 01E1 86 01          ..
                    sta       U0005,U             * 01E3 A7 45          'E
                    sta       <$0035,X            * 01E5 A7 88 35       '.5
                    clr       <$0024,X            * 01E8 6F 88 24       o.$
                    leax      U0008,U             * 01EB 30 48          0H
                    clra                          * 01ED 4F             O
                    clrb                          * 01EE 5F             _
                    os9       I$SetStt            * 01EF 10 3F 8E       .?.
                    clr       U0004,U             * 01F2 6F 44          oD
L01F4               leax      U0000,U             * 01F4 30 C4          0D
                    clr       0,X                 * 01F6 6F 84          o.
                    ldy       #1                  * 01F8 10 8E 00 01    ....
                    clra                          * 01FC 4F             O
                    os9       I$Read              * 01FD 10 3F 89       .?.
                    bcc       L020A               * 0200 24 08          $.
                    ldx       #10                 * 0202 8E 00 0A       ...
                    os9       F$Sleep             * 0205 10 3F 0A       .?.
                    bra       L01F4               * 0208 20 EA           j
L020A               lda       U0000,U             * 020A A6 C4          &D
                    cmpa      #13                 * 020C 81 0D          ..
                    beq       L0212               * 020E 27 02          '.
                    bra       L01F4               * 0210 20 E2           b
L0212               leax      U0008,U             * 0212 30 48          0H
                    leax      -$20,X              * 0214 30 88 E0       0.`
                    lda       #1                  * 0217 86 01          ..
                    sta       <$0024,X            * 0219 A7 88 24       '.$
                    leax      U0008,U             * 021C 30 48          0H
                    clra                          * 021E 4F             O
                    clrb                          * 021F 5F             _
                    os9       I$SetStt            * 0220 10 3F 8E       .?.
                    leax      -$20,X              * 0223 30 88 E0       0.`
                    ldb       <$0035,X            * 0226 E6 88 35       f.5
                    lda       #10                 * 0229 86 0A          ..
                    mul                           * 022B 3D             =
                    leax      >L0098,PC           * 022C 30 8D FE 68    0.~h
                    leax      D,X                 * 0230 30 8B          0.
                    ldy       #10                 * 0232 10 8E 00 0A    ....
                    lda       #1                  * 0236 86 01          ..
                    os9       I$Write             * 0238 10 3F 8A       .?.
                    leax      >L00CA,PC           * 023B 30 8D FE 8B    0.~.
                    ldy       #200                * 023F 10 8E 00 C8    ...H
                    os9       I$WritLn            * 0243 10 3F 8C       .?.
                    leax      >L007D,PC           * 0246 30 8D FE 33    0.~3
                    ldy       #1                  * 024A 10 8E 00 01    ....
                    pshs      U                   * 024E 34 40          4@
                    leau      >L008B,PC           * 0250 33 8D FE 37    3.~7
                    lda       #17                 * 0254 86 11          ..
                    ldb       #3                  * 0256 C6 03          F.
                    os9       F$Fork              * 0258 10 3F 03       .?.
                    lbcs      L027E               * 025B 10 25 00 1F    .%..
                    ldu       0,S                 * 025F EE E4          nd
                    sta       U0001,U             * 0261 A7 41          'A
                    puls      U                   * 0263 35 40          5@
                    os9       F$Wait              * 0265 10 3F 04       .?.
                    lbcs      L027E               * 0268 10 25 00 12    .%..
                    clra                          * 026C 4F             O
                    os9       I$Close             * 026D 10 3F 8F       .?.
                    inca                          * 0270 4C             L
                    os9       I$Close             * 0271 10 3F 8F       .?.
                    inca                          * 0274 4C             L
                    os9       I$Close             * 0275 10 3F 8F       .?.
                    os9       F$Wait              * 0278 10 3F 04       .?.
                    lbra      L019D               * 027B 16 FF 1F       ...
L027E               os9       F$PErr              * 027E 10 3F 0F       .?.
                    lbra      L019D               * 0281 16 FF 19       ...
L0284               rti                           * 0284 3B             ;

                    emod
eom                 equ       *
                    end
