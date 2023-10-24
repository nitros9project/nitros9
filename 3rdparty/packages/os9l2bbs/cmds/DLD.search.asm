                    nam       DLD.search
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
U0008               rmb       27
U0023               rmb       12
U002F               rmb       2
U0031               rmb       2
U0033               rmb       31
U0052               rmb       1
U0053               rmb       1
U0054               rmb       463
size                equ       .

name                fcs       /DLD.search/        * 000D 44 4C 44 2E 73 65 61 72 63 E8 DLD.search
L0017               fcc       "DLD.lst"           * 0017 44 4C 44 2E 6C 73 74 DLD.lst
                    fcb       $0D                 * 001E 0D             .
L001F               fcc       "DLD.key"           * 001F 44 4C 44 2E 6B 65 79 DLD.key
                    fcb       $0D                 * 0026 0D             .
L0027               fcc       "Enter keyword for search:" * 0027 45 6E 74 65 72 20 6B 65 79 77 6F 72 64 20 66 6F 72 20 73 65 61 72 63 68 3A Enter keyword for search:
L0040               fcc       "No files found."   * 0040 4E 6F 20 66 69 6C 65 73 20 66 6F 75 6E 64 2E No files found.
                    fcb       $0D                 * 004F 0D             .
L0050               fcc       "                                                                               " * 0050 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 2
                    fcb       $0D                 * 009F 0D             .
L00A0               fcb       $0A                 * 00A0 0A             .
                    fcc       "File name      Description" * 00A1 46 69 6C 65 20 6E 61 6D 65 20 20 20 20 20 20 44 65 73 63 72 69 70 74 69 6F 6E File name      Description
                    fcb       $0D                 * 00BB 0D             .
L00BC               fcc       "--------------------------------------------------------------------------" * 00BC 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
                    fcb       $0D                 * 0106 0D             .
start               clr       U0003,U             * 0107 6F 43          oC
                    lda       0,X                 * 0109 A6 84          &.
                    cmpa      #13                 * 010B 81 0D          ..
                    beq       L0118               * 010D 27 09          '.
                    lda       #1                  * 010F 86 01          ..
                    os9       I$ChgDir            * 0111 10 3F 86       .?.
                    lbcs      L0244               * 0114 10 25 01 2C    .%.,
L0118               ldd       #-1                 * 0118 CC FF FF       L..
                    std       U0006,U             * 011B ED 46          mF
                    std       U0004,U             * 011D ED 44          mD
                    leax      >L0017,PC           * 011F 30 8D FE F4    0.~t
                    lda       #1                  * 0123 86 01          ..
                    os9       I$Open              * 0125 10 3F 84       .?.
                    lbcs      L0244               * 0128 10 25 01 18    .%..
                    sta       U0001,U             * 012C A7 41          'A
                    leax      >L001F,PC           * 012E 30 8D FE ED    0.~m
                    lda       #1                  * 0132 86 01          ..
                    os9       I$Open              * 0134 10 3F 84       .?.
                    lbcs      L0244               * 0137 10 25 01 09    .%..
                    sta       U0000,U             * 013B A7 C4          'D
L013D               leax      >L0027,PC           * 013D 30 8D FE E6    0.~f
                    ldy       #25                 * 0141 10 8E 00 19    ....
                    lda       #1                  * 0145 86 01          ..
                    os9       I$Write             * 0147 10 3F 8A       .?.
                    leax      U0008,U             * 014A 30 48          0H
                    ldy       #27                 * 014C 10 8E 00 1B    ....
                    clra                          * 0150 4F             O
                    os9       I$ReadLn            * 0151 10 3F 8B       .?.
                    lbcs      L013D               * 0154 10 25 FF E5    .%.e
L0158               leax      <U0023,U            * 0158 30 C8 23       0H#
                    ldy       #16                 * 015B 10 8E 00 10    ....
                    lda       U0000,U             * 015F A6 C4          &D
                    os9       I$Read              * 0161 10 3F 89       .?.
                    lbcs      L0198               * 0164 10 25 00 30    .%.0
                    ldd       <U002F,U            * 0168 EC C8 2F       lH/
                    cmpd      U0004,U             * 016B 10 A3 44       .#D
                    bne       L017A               * 016E 26 0A          &.
                    ldd       <U0031,U            * 0170 EC C8 31       lH1
                    cmpd      U0006,U             * 0173 10 A3 46       .#F
                    bne       L017A               * 0176 26 02          &.
                    bra       L0158               * 0178 20 DE           ^
L017A               pshs      X                   * 017A 34 10          4.
L017C               lda       0,X                 * 017C A6 84          &.
                    anda      #223                * 017E 84 DF          ._
                    sta       ,X+                 * 0180 A7 80          '.
                    cmpa      #13                 * 0182 81 0D          ..
                    bne       L017C               * 0184 26 F6          &v
                    puls      X                   * 0186 35 10          5.
                    leay      U0008,U             * 0188 31 48          1H
L018A               lda       ,Y+                 * 018A A6 A0          &
                    cmpa      #13                 * 018C 81 0D          ..
                    beq       L01B4               * 018E 27 24          '$
                    anda      #223                * 0190 84 DF          ._
                    cmpa      ,X+                 * 0192 A1 80          !.
                    bne       L0158               * 0194 26 C2          &B
                    bra       L018A               * 0196 20 F2           r
L0198               cmpb      #211                * 0198 C1 D3          AS
                    lbne      L0244               * 019A 10 26 00 A6    .&.&
                    tst       U0003,U             * 019E 6D 43          mC
                    lbne      L0243               * 01A0 10 26 00 9F    .&..
                    leax      >L0040,PC           * 01A4 30 8D FE 98    0.~.
                    ldy       #200                * 01A8 10 8E 00 C8    ...H
                    lda       #1                  * 01AC 86 01          ..
                    os9       I$WritLn            * 01AE 10 3F 8C       .?.
                    lbra      L0243               * 01B1 16 00 8F       ...
L01B4               pshs      U                   * 01B4 34 40          4@
                    lda       U0001,U             * 01B6 A6 41          &A
                    ldx       <U002F,U            * 01B8 AE C8 2F       .H/
                    ldu       <U0031,U            * 01BB EE C8 31       nH1
                    os9       I$Seek              * 01BE 10 3F 88       .?.
                    lbcs      L0244               * 01C1 10 25 00 7F    .%..
                    puls      U                   * 01C5 35 40          5@
                    leax      <U0033,U            * 01C7 30 C8 33       0H3
                    ldy       #96                 * 01CA 10 8E 00 60    ...`
                    lda       U0001,U             * 01CE A6 41          &A
                    os9       I$Read              * 01D0 10 3F 89       .?.
                    lbcs      L0244               * 01D3 10 25 00 6D    .%.m
                    tst       <U0052,U            * 01D7 6D C8 52       mHR
                    lbeq      L0158               * 01DA 10 27 FF 7A    .'.z
                    tst       U0003,U             * 01DE 6D 43          mC
                    bne       L01FE               * 01E0 26 1C          &.
                    leax      >L00A0,PC           * 01E2 30 8D FE BA    0.~:
                    ldy       #200                * 01E6 10 8E 00 C8    ...H
                    lda       #1                  * 01EA 86 01          ..
                    os9       I$WritLn            * 01EC 10 3F 8C       .?.
                    leax      >L00BC,PC           * 01EF 30 8D FE C9    0.~I
                    ldy       #200                * 01F3 10 8E 00 C8    ...H
                    os9       I$WritLn            * 01F7 10 3F 8C       .?.
                    lda       #255                * 01FA 86 FF          ..
                    sta       U0003,U             * 01FC A7 43          'C
L01FE               clrb                          * 01FE 5F             _
                    leax      <U0033,U            * 01FF 30 C8 33       0H3
L0202               lda       ,X+                 * 0202 A6 80          &.
                    cmpa      #13                 * 0204 81 0D          ..
                    beq       L020B               * 0206 27 03          '.
                    incb                          * 0208 5C             \
                    bra       L0202               * 0209 20 F7           w
L020B               stb       U0002,U             * 020B E7 42          gB
                    clra                          * 020D 4F             O
                    tfr       D,Y                 * 020E 1F 02          ..
                    leax      <U0033,U            * 0210 30 C8 33       0H3
                    lda       #1                  * 0213 86 01          ..
                    os9       I$Write             * 0215 10 3F 8A       .?.
                    ldb       #15                 * 0218 C6 0F          F.
                    subb      U0002,U             * 021A E0 42          `B
                    blt       L022A               * 021C 2D 0C          -.
                    clra                          * 021E 4F             O
                    tfr       D,Y                 * 021F 1F 02          ..
                    lda       #1                  * 0221 86 01          ..
                    leax      >L0050,PC           * 0223 30 8D FE 29    0.~)
                    os9       I$Write             * 0227 10 3F 8A       .?.
L022A               leax      <U0053,U            * 022A 30 C8 53       0HS
                    ldy       #65                 * 022D 10 8E 00 41    ...A
                    lda       #1                  * 0231 86 01          ..
                    os9       I$WritLn            * 0233 10 3F 8C       .?.
                    ldd       <U002F,U            * 0236 EC C8 2F       lH/
                    std       U0004,U             * 0239 ED 44          mD
                    ldd       <U0031,U            * 023B EC C8 31       lH1
                    std       U0006,U             * 023E ED 46          mF
                    lbra      L0158               * 0240 16 FF 15       ...
L0243               clrb                          * 0243 5F             _
L0244               os9       F$Exit              * 0244 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
