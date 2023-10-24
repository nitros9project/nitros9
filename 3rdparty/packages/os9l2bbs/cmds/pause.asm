                    nam       pause
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
U0002               rmb       2
U0004               rmb       400
size                equ       .

name                fcs       /pause/             * 000D 70 61 75 73 E5 pause
L0012               fcb       $0A                 * 0012 0A             .
                    fcb       $0D                 * 0013 0D             .
start               lda       ,X+                 * 0014 A6 80          &.
                    cmpa      #34                 * 0016 81 22          ."
                    beq       L0028               * 0018 27 0E          '.
                    cmpa      #13                 * 001A 81 0D          ..
                    bne       start               * 001C 26 F6          &v
                    leax      >L0065,PC           * 001E 30 8D 00 43    0..C
                    ldy       #28                 * 0022 10 8E 00 1C    ....
                    bra       L0041               * 0026 20 19           .
L0028               clr       U0001,U             * 0028 6F 41          oA
                    stx       U0002,U             * 002A AF 42          /B
L002C               lda       ,X+                 * 002C A6 80          &.
                    cmpa      #34                 * 002E 81 22          ."
                    beq       L003A               * 0030 27 08          '.
                    cmpa      #13                 * 0032 81 0D          ..
                    beq       L003A               * 0034 27 04          '.
                    inc       U0001,U             * 0036 6C 41          lA
                    bra       L002C               * 0038 20 F2           r
L003A               ldb       U0001,U             * 003A E6 41          fA
                    clra                          * 003C 4F             O
                    tfr       D,Y                 * 003D 1F 02          ..
                    ldx       U0002,U             * 003F AE 42          .B
L0041               lda       #1                  * 0041 86 01          ..
                    os9       I$Write             * 0043 10 3F 8A       .?.
                    bcs       L0062               * 0046 25 1A          %.
                    clra                          * 0048 4F             O
                    ldy       #1                  * 0049 10 8E 00 01    ....
                    leax      U0000,U             * 004D 30 C4          0D
                    os9       I$Read              * 004F 10 3F 89       .?.
                    bcs       L0062               * 0052 25 0E          %.
                    lda       #1                  * 0054 86 01          ..
                    leax      >L0012,PC           * 0056 30 8D FF B8    0..8
                    ldy       #2                  * 005A 10 8E 00 02    ....
                    os9       I$WritLn            * 005E 10 3F 8C       .?.
                    clrb                          * 0061 5F             _
L0062               os9       F$Exit              * 0062 10 3F 06       .?.
L0065               fcc       "Press any key to continue..." * 0065 50 72 65 73 73 20 61 6E 79 20 6B 65 79 20 74 6F 20 63 6F 6E 74 69 6E 75 65 2E 2E 2E Press any key to continue...
                    fcb       $0D                 * 0081 0D             .

                    emod
eom                 equ       *
                    end
