                    nam       BBS.Form
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
U0003               rmb       2
U0005               rmb       402
U0197               rmb       1
U0198               rmb       7779
size                equ       .

name                fcs       /BBS.Form/          * 000D 42 42 53 2E 46 6F 72 ED BBS.Form
L0015               fcc       "------------------------------------------" * 0015 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D ------------------------------------------
                    fcb       $0D                 * 003F 0D             .
L0040               fcc       "Is all information correct?" * 0040 49 73 20 61 6C 6C 20 69 6E 66 6F 72 6D 61 74 69 6F 6E 20 63 6F 72 72 65 63 74 3F Is all information correct?
L005B               fcb       $0A                 * 005B 0A             .
                    fcb       $0D                 * 005C 0D             .

start               stx       U0003,U             * 005D AF 43          /C
L005F               lda       ,X+                 * 005F A6 80          &.
                    cmpa      #32                 * 0061 81 20          .
                    bne       L005F               * 0063 26 FA          &z
                    lda       #13                 * 0065 86 0D          ..
                    sta       -$01,X              * 0067 A7 1F          '.
                    lda       #2                  * 0069 86 02          ..
                    os9       I$Open              * 006B 10 3F 84       .?.
                    lbcs      L0082               * 006E 10 25 00 10    .%..
                    sta       U0000,U             * 0072 A7 C4          'D
                    ldb       #2                  * 0074 C6 02          F.
                    pshs      U                   * 0076 34 40          4@
                    os9       I$GetStt            * 0078 10 3F 8D       .?.
                    os9       I$Seek              * 007B 10 3F 88       .?.
                    puls      U                   * 007E 35 40          5@
                    bra       L008D               * 0080 20 0B           .
L0082               ldb       #27                 * 0082 C6 1B          F.
                    os9       I$Create            * 0084 10 3F 83       .?.
                    lbcs      L0131               * 0087 10 25 00 A6    .%.&
                    sta       U0000,U             * 008B A7 C4          'D
L008D               ldx       U0003,U             * 008D AE 43          .C
                    lda       #1                  * 008F 86 01          ..
                    os9       I$Open              * 0091 10 3F 84       .?.
                    lbcs      L0131               * 0094 10 25 00 99    .%..
                    sta       U0001,U             * 0098 A7 41          'A
                    leax      >U0197,U            * 009A 30 C9 01 97    0I..
                    stx       U0005,U             * 009E AF 45          /E
L00A0               lda       U0001,U             * 00A0 A6 41          &A
                    ldx       U0005,U             * 00A2 AE 45          .E
                    ldy       #200                * 00A4 10 8E 00 C8    ...H
                    os9       I$ReadLn            * 00A8 10 3F 8B       .?.
                    lbcs      L00CA               * 00AB 10 25 00 1B    .%..
                    leay      -$01,Y              * 00AF 31 3F          1?
                    lda       #1                  * 00B1 86 01          ..
                    os9       I$Write             * 00B3 10 3F 8A       .?.
                    tfr       Y,D                 * 00B6 1F 20          .
                    leax      D,X                 * 00B8 30 8B          0.
                    ldy       #200                * 00BA 10 8E 00 C8    ...H
                    clra                          * 00BE 4F             O
                    os9       I$ReadLn            * 00BF 10 3F 8B       .?.
                    tfr       Y,D                 * 00C2 1F 20          .
                    leax      D,X                 * 00C4 30 8B          0.
                    stx       U0005,U             * 00C6 AF 45          /E
                    bra       L00A0               * 00C8 20 D6           V
L00CA               leax      >L0040,PC           * 00CA 30 8D FF 72    0..r
                    ldy       #27                 * 00CE 10 8E 00 1B    ....
                    lda       #1                  * 00D2 86 01          ..
                    os9       I$Write             * 00D4 10 3F 8A       .?.
                    leax      U0002,U             * 00D7 30 42          0B
                    clra                          * 00D9 4F             O
                    ldy       #1                  * 00DA 10 8E 00 01    ....
                    os9       I$Read              * 00DE 10 3F 89       .?.
                    leax      >L005B,PC           * 00E1 30 8D FF 76    0..v
                    ldy       #2                  * 00E5 10 8E 00 02    ....
                    lda       #1                  * 00E9 86 01          ..
                    os9       I$WritLn            * 00EB 10 3F 8C       .?.
                    lda       U0002,U             * 00EE A6 42          &B
                    anda      #223                * 00F0 84 DF          ._
                    cmpa      #89                 * 00F2 81 59          .Y
                    beq       L0112               * 00F4 27 1C          '.
                    leax      >U0197,U            * 00F6 30 C9 01 97    0I..
                    stx       U0005,U             * 00FA AF 45          /E
                    lda       U0001,U             * 00FC A6 41          &A
                    pshs      U                   * 00FE 34 40          4@
                    ldu       #0                  * 0100 CE 00 00       N..
                    ldx       #0                  * 0103 8E 00 00       ...
                    os9       I$Seek              * 0106 10 3F 88       .?.
                    lbcs      L0131               * 0109 10 25 00 24    .%.$
                    puls      U                   * 010D 35 40          5@
                    lbra      L00A0               * 010F 16 FF 8E       ...
L0112               leax      >U0197,U            * 0112 30 C9 01 97    0I..
                    pshs      X                   * 0116 34 10          4.
                    ldd       U0005,U             * 0118 EC 45          lE
                    subd      0,S                 * 011A A3 E4          #d
                    tfr       D,Y                 * 011C 1F 02          ..
                    puls      X                   * 011E 35 10          5.
                    lda       U0000,U             * 0120 A6 C4          &D
                    os9       I$Write             * 0122 10 3F 8A       .?.
                    leax      >L0015,PC           * 0125 30 8D FE EC    0.~l
                    ldy       #200                * 0129 10 8E 00 C8    ...H
                    os9       I$WritLn            * 012D 10 3F 8C       .?.
                    clrb                          * 0130 5F             _
L0131               os9       F$Exit              * 0131 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
