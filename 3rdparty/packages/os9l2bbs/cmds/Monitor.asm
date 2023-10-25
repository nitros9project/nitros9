                    nam       Monitor
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
U0004               rmb       2
U0006               rmb       2
U0008               rmb       32
U0028               rmb       255
U0127               rmb       1
U0128               rmb       1
U0129               rmb       711
size                equ       .

name                fcs       /Monitor/           * 000D 4D 6F 6E 69 74 6F F2 Monitor
                    fcc       "Copyright (C) 1988By Keith AlphonsoLicenced to Alpha Software TechnologiesAll rights reserved" * 0014 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 4C 69 63 65 6E 63 65 64
                    fcb       $EC                 * 0071 EC             l
                    fcb       $E6                 * 0072 E6             f
                    fcb       $EA                 * 0073 EA             j
                    fcb       $F5                 * 0074 F5             u
                    fcb       $E9                 * 0075 E9             i
                    fcb       $A0                 * 0076 A0
                    fcb       $E2                 * 0077 E2             b
                    fcb       $ED                 * 0078 ED             m
                    fcb       $F1                 * 0079 F1             q
                    fcb       $E9                 * 007A E9             i
                    fcb       $F0                 * 007B F0             p
                    fcb       $EF                 * 007C EF             o
                    fcb       $F4                 * 007D F4             t
                    fcb       $F0                 * 007E F0             p
start               lda       0,X                 * 007F A6 84          &.
                    cmpa      #13                 * 0081 81 0D          ..
                    beq       L00A0               * 0083 27 1B          '.
                    clra                          * 0085 4F             O
                    os9       I$Close             * 0086 10 3F 8F       .?.
                    inca                          * 0089 4C             L
                    os9       I$Close             * 008A 10 3F 8F       .?.
                    inca                          * 008D 4C             L
                    os9       I$Close             * 008E 10 3F 8F       .?.
                    lda       #3                  * 0091 86 03          ..
                    os9       I$Open              * 0093 10 3F 84       .?.
                    lbcs      L0106               * 0096 10 25 00 6C    .%.l
                    os9       I$Dup               * 009A 10 3F 82       .?.
                    os9       I$Dup               * 009D 10 3F 82       .?.
L00A0               clra                          * 00A0 4F             O
                    ldb       #14                 * 00A1 C6 0E          F.
                    leax      U0008,U             * 00A3 30 48          0H
                    os9       I$GetStt            * 00A5 10 3F 8D       .?.
                    lbcs      L0106               * 00A8 10 25 00 5A    .%.Z
                    lda       #241                * 00AC 86 F1          .q
                    pshs      U                   * 00AE 34 40          4@
                    os9       F$Link              * 00B0 10 3F 00       .?.
                    lbcs      L0106               * 00B3 10 25 00 4F    .%.O
                    tfr       U,Y                 * 00B7 1F 32          .2
                    puls      U                   * 00B9 35 40          5@
                    ldx       $0F,Y               * 00BB AE 2F          ./
                    leax      $01,X               * 00BD 30 01          0.
                    stx       U0004,U             * 00BF AF 44          /D
L00C1               ldx       #1                  * 00C1 8E 00 01       ...
                    os9       F$Sleep             * 00C4 10 3F 0A       .?.
                    ldx       U0004,U             * 00C7 AE 44          .D
                    lda       0,X                 * 00C9 A6 84          &.
                    bita      #32                 * 00CB 85 20          .
                    beq       L00C1               * 00CD 27 F2          'r
                    os9       F$ID                * 00CF 10 3F 0C       .?.
                    sta       U0002,U             * 00D2 A7 42          'B
                    leax      >U0127,U            * 00D4 30 C9 01 27    0I.'
                    os9       F$GPrDsc            * 00D8 10 3F 18       .?.
                    lda       >U0128,U            * 00DB A6 C9 01 28    &I.(
                    sta       U0000,U             * 00DF A7 C4          'D
                    lda       #255                * 00E1 86 FF          ..
                    sta       U0001,U             * 00E3 A7 41          'A
                    clr       U0003,U             * 00E5 6F 43          oC
                    leax      <U0028,U            * 00E7 30 C8 28       0H(
                    stx       U0006,U             * 00EA AF 46          /F
L00EC               lda       U0001,U             * 00EC A6 41          &A
L00EE               leax      >U0127,U            * 00EE 30 C9 01 27    0I.'
                    os9       F$GPrDsc            * 00F2 10 3F 18       .?.
                    bcs       L0117               * 00F5 25 20          %
                    lda       >U0128,U            * 00F7 A6 C9 01 28    &I.(
                    cmpa      U0000,U             * 00FB A1 C4          !D
                    beq       L0109               * 00FD 27 0A          '.
                    cmpa      #0                  * 00FF 81 00          ..
                    beq       L0117               * 0101 27 14          '.
                    bra       L00EE               * 0103 20 E9           i
L0105               clrb                          * 0105 5F             _
L0106               os9       F$Exit              * 0106 10 3F 06       .?.
L0109               lda       U0001,U             * 0109 A6 41          &A
                    cmpa      U0002,U             * 010B A1 42          !B
                    beq       L0117               * 010D 27 08          '.
                    ldx       U0006,U             * 010F AE 46          .F
                    sta       ,X+                 * 0111 A7 80          '.
                    stx       U0006,U             * 0113 AF 46          /F
                    inc       U0003,U             * 0115 6C 43          lC
L0117               dec       U0001,U             * 0117 6A 41          jA
                    cmpa      #3                  * 0119 81 03          ..
                    beq       L011F               * 011B 27 02          '.
                    bra       L00EC               * 011D 20 CD           M
L011F               leax      <U0028,U            * 011F 30 C8 28       0H(
L0122               tst       U0003,U             * 0122 6D 43          mC
                    lbeq      L0105               * 0124 10 27 FF DD    .'.]
                    dec       U0003,U             * 0128 6A 43          jC
                    lda       ,X+                 * 012A A6 80          &.
                    clrb                          * 012C 5F             _
L012D               os9       F$Send              * 012D 10 3F 08       .?.
                    bcc       L0122               * 0130 24 F0          $p
                    pshs      X,A                 * 0132 34 12          4.
                    ldx       #1                  * 0134 8E 00 01       ...
                    os9       F$Sleep             * 0137 10 3F 0A       .?.
                    puls      X,A                 * 013A 35 12          5.
                    bra       L012D               * 013C 20 EF           o

                    emod
eom                 equ       *
                    end
