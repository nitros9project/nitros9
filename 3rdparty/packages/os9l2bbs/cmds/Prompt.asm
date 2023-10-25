                    nam       Prompt
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       2
U0002               rmb       2
U0004               rmb       2
U0006               rmb       2
U0008               rmb       1
U0009               rmb       599
size                equ       .

name                fcs       /Prompt/            * 000D 50 72 6F 6D 70 F4 Prompt
start               stx       U0006,U             * 0013 AF 46          /F
L0015               lda       ,X+                 * 0015 A6 80          &.
                    cmpa      #32                 * 0017 81 20          .
                    beq       L0021               * 0019 27 06          '.
                    cmpa      #13                 * 001B 81 0D          ..
                    beq       L0021               * 001D 27 02          '.
                    bra       L0015               * 001F 20 F4           t
L0021               lda       #13                 * 0021 86 0D          ..
                    sta       -$01,X              * 0023 A7 1F          '.
                    leay      U0008,U             * 0025 31 48          1H
                    clr       U0000,U             * 0027 6F C4          oD
L0029               lda       ,X+                 * 0029 A6 80          &.
                    cmpa      #34                 * 002B 81 22          ."
                    beq       L003A               * 002D 27 0B          '.
                    sta       ,Y+                 * 002F A7 A0          '
                    inc       U0000,U             * 0031 6C C4          lD
                    cmpa      #13                 * 0033 81 0D          ..
                    bne       L0029               * 0035 26 F2          &r
                    lbra      L007A               * 0037 16 00 40       ..@
L003A               stx       U0002,U             * 003A AF 42          /B
                    clrb                          * 003C 5F             _
L003D               lda       ,X+                 * 003D A6 80          &.
                    cmpa      #13                 * 003F 81 0D          ..
                    beq       L004A               * 0041 27 07          '.
                    cmpa      #34                 * 0043 81 22          ."
                    beq       L004A               * 0045 27 03          '.
                    incb                          * 0047 5C             \
                    bra       L003D               * 0048 20 F3           s
L004A               stx       U0004,U             * 004A AF 44          /D
                    ldx       U0002,U             * 004C AE 42          .B
                    clra                          * 004E 4F             O
                    pshs      Y                   * 004F 34 20          4
                    tfr       D,Y                 * 0051 1F 02          ..
                    lda       #1                  * 0053 86 01          ..
                    os9       I$Write             * 0055 10 3F 8A       .?.
                    ldx       0,S                 * 0058 AE E4          .d
                    ldy       #80                 * 005A 10 8E 00 50    ...P
                    clra                          * 005E 4F             O
                    os9       I$ReadLn            * 005F 10 3F 8B       .?.
                    leay      -$01,Y              * 0062 31 3F          1?
                    tfr       Y,D                 * 0064 1F 20          .
                    puls      Y                   * 0066 35 20          5
                    leay      D,Y                 * 0068 31 AB          1+
                    addb      U0000,U             * 006A EB C4          kD
                    stb       U0000,U             * 006C E7 C4          gD
                    ldx       U0004,U             * 006E AE 44          .D
L0070               lda       ,X+                 * 0070 A6 80          &.
                    sta       ,Y+                 * 0072 A7 A0          '
                    inc       U0000,U             * 0074 6C C4          lD
                    cmpa      #13                 * 0076 81 0D          ..
                    bne       L0070               * 0078 26 F6          &v
L007A               ldx       U0006,U             * 007A AE 46          .F
                    ldb       U0000,U             * 007C E6 C4          fD
                    clra                          * 007E 4F             O
                    tfr       D,Y                 * 007F 1F 02          ..
                    lda       #17                 * 0081 86 11          ..
                    ldb       #3                  * 0083 C6 03          F.
                    pshs      U                   * 0085 34 40          4@
                    leau      U0008,U             * 0087 33 48          3H
                    os9       F$Fork              * 0089 10 3F 03       .?.
                    lbcs      L009A               * 008C 10 25 00 0A    .%..
                    os9       F$Wait              * 0090 10 3F 04       .?.
                    lbcs      L009A               * 0093 10 25 00 03    .%..
                    puls      U                   * 0097 35 40          5@
                    clrb                          * 0099 5F             _
L009A               os9       F$Exit              * 009A 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
