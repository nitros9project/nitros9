                    nam       DLD.list
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
U0003               rmb       31
U0022               rmb       1
U0023               rmb       1
U0024               rmb       463
size                equ       .

name                fcs       /DLD.list/          * 000D 44 4C 44 2E 6C 69 73 F4 DLD.list
L0015               fcc       "DLD.lst"           * 0015 44 4C 44 2E 6C 73 74 DLD.lst
                    fcb       $0D                 * 001C 0D             .
L001D               fcc       "No files found."   * 001D 4E 6F 20 66 69 6C 65 73 20 66 6F 75 6E 64 2E No files found.
                    fcb       $0D                 * 002C 0D             .
L002D               fcc       "                                                                               " * 002D 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 2
                    fcb       $0D                 * 007C 0D             .
L007D               fcc       "File name      Description" * 007D 46 69 6C 65 20 6E 61 6D 65 20 20 20 20 20 20 44 65 73 63 72 69 70 74 69 6F 6E File name      Description
                    fcb       $0D                 * 0097 0D             .
L0098               fcc       "--------------------------------------------------------------------------" * 0098 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
                    fcb       $0D                 * 00E2 0D             .
start               clr       U0002,U             * 00E3 6F 42          oB
                    lda       0,X                 * 00E5 A6 84          &.
                    cmpa      #13                 * 00E7 81 0D          ..
                    beq       L00F4               * 00E9 27 09          '.
                    lda       #1                  * 00EB 86 01          ..
                    os9       I$ChgDir            * 00ED 10 3F 86       .?.
                    lbcs      L0192               * 00F0 10 25 00 9E    .%..
L00F4               leax      >L0015,PC           * 00F4 30 8D FF 1D    0...
                    lda       #1                  * 00F8 86 01          ..
                    os9       I$Open              * 00FA 10 3F 84       .?.
                    lbcs      L0192               * 00FD 10 25 00 91    .%..
                    sta       U0000,U             * 0101 A7 C4          'D
L0103               clra                          * 0103 4F             O
                    ldb       #1                  * 0104 C6 01          F.
                    os9       I$GetStt            * 0106 10 3F 8D       .?.
                    lbcc      L0191               * 0109 10 24 00 84    .$..
                    lda       U0000,U             * 010D A6 C4          &D
                    leax      U0003,U             * 010F 30 43          0C
                    ldy       #96                 * 0111 10 8E 00 60    ...`
                    os9       I$Read              * 0115 10 3F 89       .?.
                    lbcs      L017C               * 0118 10 25 00 60    .%.`
                    lda       <U0022,U            * 011C A6 C8 22       &H"
                    cmpa      #255                * 011F 81 FF          ..
                    bne       L0103               * 0121 26 E0          &`
                    tst       U0002,U             * 0123 6D 42          mB
                    bne       L0143               * 0125 26 1C          &.
                    leax      >L007D,PC           * 0127 30 8D FF 52    0..R
                    ldy       #200                * 012B 10 8E 00 C8    ...H
                    lda       #1                  * 012F 86 01          ..
                    os9       I$WritLn            * 0131 10 3F 8C       .?.
                    leax      >L0098,PC           * 0134 30 8D FF 60    0..`
                    ldy       #200                * 0138 10 8E 00 C8    ...H
                    os9       I$WritLn            * 013C 10 3F 8C       .?.
                    lda       #255                * 013F 86 FF          ..
                    sta       U0002,U             * 0141 A7 42          'B
L0143               clrb                          * 0143 5F             _
                    leax      U0003,U             * 0144 30 43          0C
L0146               lda       ,X+                 * 0146 A6 80          &.
                    cmpa      #13                 * 0148 81 0D          ..
                    beq       L014F               * 014A 27 03          '.
                    incb                          * 014C 5C             \
                    bra       L0146               * 014D 20 F7           w
L014F               stb       U0001,U             * 014F E7 41          gA
                    clra                          * 0151 4F             O
                    tfr       D,Y                 * 0152 1F 02          ..
                    leax      U0003,U             * 0154 30 43          0C
                    lda       #1                  * 0156 86 01          ..
                    os9       I$Write             * 0158 10 3F 8A       .?.
                    ldb       #15                 * 015B C6 0F          F.
                    subb      U0001,U             * 015D E0 41          `A
                    blt       L016D               * 015F 2D 0C          -.
                    clra                          * 0161 4F             O
                    tfr       D,Y                 * 0162 1F 02          ..
                    lda       #1                  * 0164 86 01          ..
                    leax      >L002D,PC           * 0166 30 8D FE C3    0.~C
                    os9       I$Write             * 016A 10 3F 8A       .?.
L016D               leax      <U0023,U            * 016D 30 C8 23       0H#
                    ldy       #65                 * 0170 10 8E 00 41    ...A
                    lda       #1                  * 0174 86 01          ..
                    os9       I$WritLn            * 0176 10 3F 8C       .?.
                    lbra      L0103               * 0179 16 FF 87       ...
L017C               cmpb      #211                * 017C C1 D3          AS
                    bne       L0192               * 017E 26 12          &.
                    tst       U0002,U             * 0180 6D 42          mB
                    bne       L0191               * 0182 26 0D          &.
                    leax      >L001D,PC           * 0184 30 8D FE 95    0.~.
                    ldy       #200                * 0188 10 8E 00 C8    ...H
                    lda       #1                  * 018C 86 01          ..
                    os9       I$WritLn            * 018E 10 3F 8C       .?.
L0191               clrb                          * 0191 5F             _
L0192               os9       F$Exit              * 0192 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
