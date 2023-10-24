                    nam       DLD.read
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
U0002               rmb       80
U0052               rmb       27
U006D               rmb       27
U0088               rmb       2
U008A               rmb       2
U008C               rmb       1
U008D               rmb       1
U008E               rmb       463
size                equ       .

name                fcs       /DLD.read/          * 000D 44 4C 44 2E 72 65 61 E4 DLD.read
L0015               fcc       "DLD.lst"           * 0015 44 4C 44 2E 6C 73 74 DLD.lst
                    fcb       $0D                 * 001C 0D             .
L001D               fcc       "DLD.dsc"           * 001D 44 4C 44 2E 64 73 63 DLD.dsc
                    fcb       $0D                 * 0024 0D             .
L0025               fcc       "Enter filename to read:" * 0025 45 6E 74 65 72 20 66 69 6C 65 6E 61 6D 65 20 74 6F 20 72 65 61 64 3A Enter filename to read:
L003C               fcc       "Filename not found." * 003C 46 69 6C 65 6E 61 6D 65 20 6E 6F 74 20 66 6F 75 6E 64 2E Filename not found.
                    fcb       $0D                 * 004F 0D             .
L0050               fcb       $0A                 * 0050 0A             .
                    fcb       $0D                 * 0051 0D             .
                    fcc       "Name:"             * 0052 4E 61 6D 65 3A Name:
L0057               fcc       "Desc:"             * 0057 44 65 73 63 3A Desc:
L005C               fcc       "--------------------------------------------------------------" * 005C 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
                    fcb       $0D                 * 009A 0D             .
start               lda       0,X                 * 009B A6 84          &.
                    cmpa      #13                 * 009D 81 0D          ..
                    beq       L00AA               * 009F 27 09          '.
                    lda       #1                  * 00A1 86 01          ..
                    os9       I$ChgDir            * 00A3 10 3F 86       .?.
                    lbcs      L01A7               * 00A6 10 25 00 FD    .%.}
L00AA               leax      >L0015,PC           * 00AA 30 8D FF 67    0..g
                    lda       #1                  * 00AE 86 01          ..
                    os9       I$Open              * 00B0 10 3F 84       .?.
                    lbcs      L01A7               * 00B3 10 25 00 F0    .%.p
                    sta       U0000,U             * 00B7 A7 C4          'D
                    leax      >L001D,PC           * 00B9 30 8D FF 60    0..`
                    lda       #1                  * 00BD 86 01          ..
                    os9       I$Open              * 00BF 10 3F 84       .?.
                    lbcs      L01A7               * 00C2 10 25 00 E1    .%.a
                    sta       U0001,U             * 00C6 A7 41          'A
L00C8               leax      >L0025,PC           * 00C8 30 8D FF 59    0..Y
                    ldy       #23                 * 00CC 10 8E 00 17    ....
                    lda       #1                  * 00D0 86 01          ..
                    os9       I$Write             * 00D2 10 3F 8A       .?.
                    leax      <U0052,U            * 00D5 30 C8 52       0HR
                    ldy       #27                 * 00D8 10 8E 00 1B    ....
                    clra                          * 00DC 4F             O
                    os9       I$ReadLn            * 00DD 10 3F 8B       .?.
                    lbcs      L00C8               * 00E0 10 25 FF E4    .%.d
                    cmpy      #1                  * 00E4 10 8C 00 01    ....
                    lble      L01A6               * 00E8 10 2F 00 BA    ./.:
L00EC               lda       0,X                 * 00EC A6 84          &.
                    anda      #223                * 00EE 84 DF          ._
                    sta       ,X+                 * 00F0 A7 80          '.
                    cmpa      #13                 * 00F2 81 0D          ..
                    bne       L00EC               * 00F4 26 F6          &v
L00F6               leax      <U006D,U            * 00F6 30 C8 6D       0Hm
                    lda       U0000,U             * 00F9 A6 C4          &D
                    ldy       #96                 * 00FB 10 8E 00 60    ...`
                    clrb                          * 00FF 5F             _
                    os9       I$Read              * 0100 10 3F 89       .?.
                    lbcs      L0120               * 0103 10 25 00 19    .%..
                    tst       >U008C,U            * 0107 6D C9 00 8C    mI..
                    beq       L00F6               * 010B 27 E9          'i
                    leay      <U0052,U            * 010D 31 C8 52       1HR
L0110               lda       0,Y                 * 0110 A6 A4          &$
                    cmpa      #13                 * 0112 81 0D          ..
                    beq       L0136               * 0114 27 20          '
                    lda       ,X+                 * 0116 A6 80          &.
                    anda      #223                * 0118 84 DF          ._
                    cmpa      ,Y+                 * 011A A1 A0          !
                    bne       L00F6               * 011C 26 D8          &X
                    bra       L0110               * 011E 20 F0           p
L0120               cmpb      #211                * 0120 C1 D3          AS
                    lbne      L01A7               * 0122 10 26 00 81    .&..
                    leax      >L003C,PC           * 0126 30 8D FF 12    0...
                    ldy       #200                * 012A 10 8E 00 C8    ...H
                    lda       #1                  * 012E 86 01          ..
                    os9       I$WritLn            * 0130 10 3F 8C       .?.
                    lbra      L01A6               * 0133 16 00 70       ..p
L0136               leax      >L0050,PC           * 0136 30 8D FF 16    0...
                    ldy       #7                  * 013A 10 8E 00 07    ....
                    lda       #1                  * 013E 86 01          ..
                    os9       I$Write             * 0140 10 3F 8A       .?.
                    leax      <U006D,U            * 0143 30 C8 6D       0Hm
                    ldy       #30                 * 0146 10 8E 00 1E    ....
                    os9       I$WritLn            * 014A 10 3F 8C       .?.
                    leax      >L0057,PC           * 014D 30 8D FF 06    0...
                    ldy       #5                  * 0151 10 8E 00 05    ....
                    os9       I$Write             * 0155 10 3F 8A       .?.
                    leax      >U008D,U            * 0158 30 C9 00 8D    0I..
                    ldy       #65                 * 015C 10 8E 00 41    ...A
                    os9       I$WritLn            * 0160 10 3F 8C       .?.
                    leax      >L005C,PC           * 0163 30 8D FE F5    0.~u
                    ldy       #65                 * 0167 10 8E 00 41    ...A
                    os9       I$WritLn            * 016B 10 3F 8C       .?.
                    lda       U0001,U             * 016E A6 41          &A
                    ldx       >U0088,U            * 0170 AE C9 00 88    .I..
                    pshs      U                   * 0174 34 40          4@
                    ldu       >U008A,U            * 0176 EE C9 00 8A    nI..
                    os9       I$Seek              * 017A 10 3F 88       .?.
                    puls      U                   * 017D 35 40          5@
L017F               lda       U0001,U             * 017F A6 41          &A
                    leax      U0002,U             * 0181 30 42          0B
                    ldy       #200                * 0183 10 8E 00 C8    ...H
                    os9       I$ReadLn            * 0187 10 3F 8B       .?.
                    lbcs      L01A7               * 018A 10 25 00 19    .%..
                    lda       #1                  * 018E 86 01          ..
                    os9       I$WritLn            * 0190 10 3F 8C       .?.
                    cmpy      #1                  * 0193 10 8C 00 01    ....
                    bgt       L017F               * 0197 2E E6          .f
                    leax      >L005C,PC           * 0199 30 8D FE BF    0.~?
                    ldy       #65                 * 019D 10 8E 00 41    ...A
                    lda       #1                  * 01A1 86 01          ..
                    os9       I$WritLn            * 01A3 10 3F 8C       .?.
L01A6               clrb                          * 01A6 5F             _
L01A7               os9       F$Exit              * 01A7 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
