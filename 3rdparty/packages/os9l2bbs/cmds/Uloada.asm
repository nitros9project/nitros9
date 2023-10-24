                    nam       Uloada
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       1
U0001               rmb       200
U00C9               rmb       1
U00CA               rmb       599
size                equ       .

name                fcs       /Uloada/            * 000D 55 6C 6F 61 64 E1 Uloada
L0013               fcc       "Enter filename to upload" * 0013 45 6E 74 65 72 20 66 69 6C 65 6E 61 6D 65 20 74 6F 20 75 70 6C 6F 61 64 Enter filename to upload
L002B               fcc       "Press <CTRL><T> to terminal upload" * 002B 50 72 65 73 73 20 3C 43 54 52 4C 3E 3C 54 3E 20 74 6F 20 74 65 72 6D 69 6E 61 6C 20 75 70 6C 6F 61 64 Press <CTRL><T> to terminal upload
                    fcb       $0A                 * 004D 0A             .
                    fcb       $0D                 * 004E 0D             .
                    fcc       "Press <CTRL><X> to cancel" * 004F 50 72 65 73 73 20 3C 43 54 52 4C 3E 3C 58 3E 20 74 6F 20 63 61 6E 63 65 6C Press <CTRL><X> to cancel
                    fcb       $0A                 * 0068 0A             .
                    fcb       $0D                 * 0069 0D             .
L006A               fcb       $0A                 * 006A 0A             .
                    fcb       $3A                 * 006B 3A             :
start               lda       0,X                 * 006C A6 84          &.
                    cmpa      #13                 * 006E 81 0D          ..
                    bne       L008B               * 0070 26 19          &.
                    leax      >L0013,PC           * 0072 30 8D FF 9D    0...
                    ldy       #24                 * 0076 10 8E 00 18    ....
                    lda       #1                  * 007A 86 01          ..
                    os9       I$Write             * 007C 10 3F 8A       .?.
                    leax      U0001,U             * 007F 30 41          0A
                    ldy       #200                * 0081 10 8E 00 C8    ...H
                    clra                          * 0085 4F             O
                    os9       I$ReadLn            * 0086 10 3F 8B       .?.
                    leax      U0001,U             * 0089 30 41          0A
L008B               lda       #3                  * 008B 86 03          ..
                    ldb       #27                 * 008D C6 1B          F.
                    os9       I$Create            * 008F 10 3F 83       .?.
                    lbcs      L00F0               * 0092 10 25 00 5A    .%.Z
                    sta       U0000,U             * 0096 A7 C4          'D
                    leax      >L002B,PC           * 0098 30 8D FF 8F    0...
                    ldy       #63                 * 009C 10 8E 00 3F    ...?
                    lda       #1                  * 00A0 86 01          ..
                    os9       I$Write             * 00A2 10 3F 8A       .?.
                    leax      >L006A,PC           * 00A5 30 8D FF C1    0..A
                    ldy       #2                  * 00A9 10 8E 00 02    ....
                    lda       #1                  * 00AD 86 01          ..
                    os9       I$Write             * 00AF 10 3F 8A       .?.
L00B2               clra                          * 00B2 4F             O
                    ldb       #1                  * 00B3 C6 01          F.
                    os9       I$GetStt            * 00B5 10 3F 8D       .?.
                    bcs       L00B2               * 00B8 25 F8          %x
                    ldy       #1                  * 00BA 10 8E 00 01    ....
                    leax      >U00C9,U            * 00BE 30 C9 00 C9    0I.I
                    os9       I$Read              * 00C2 10 3F 89       .?.
                    lda       0,X                 * 00C5 A6 84          &.
                    cmpa      #20                 * 00C7 81 14          ..
                    beq       L00EF               * 00C9 27 24          '$
                    cmpa      #24                 * 00CB 81 18          ..
                    beq       L00EB               * 00CD 27 1C          '.
                    lda       U0000,U             * 00CF A6 C4          &D
                    os9       I$Write             * 00D1 10 3F 8A       .?.
                    lda       0,X                 * 00D4 A6 84          &.
                    cmpa      #13                 * 00D6 81 0D          ..
                    beq       L00DC               * 00D8 27 02          '.
                    bra       L00B2               * 00DA 20 D6           V
L00DC               leax      >L006A,PC           * 00DC 30 8D FF 8A    0...
                    ldy       #2                  * 00E0 10 8E 00 02    ....
                    lda       #1                  * 00E4 86 01          ..
                    os9       I$Write             * 00E6 10 3F 8A       .?.
                    bra       L00B2               * 00E9 20 C7           G
L00EB               lda       #1                  * 00EB 86 01          ..
                    bra       L00F0               * 00ED 20 01           .
L00EF               clrb                          * 00EF 5F             _
L00F0               os9       F$Exit              * 00F0 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
