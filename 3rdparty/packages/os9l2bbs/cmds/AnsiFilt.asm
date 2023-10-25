                    nam       AnsiFilt
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

ReadBuf             rmb       1
ColCount            rmb       1
RowCount            rmb       1
U0003               rmb       1
U0004               rmb       1
InEscSeq            rmb       1
XSave               rmb       2
WriteBuf            rmb       1
U0009               rmb       499
size                equ       .

name                fcs       /AnsiFilt/          * 000D 41 6E 73 69 46 69 6C F4 AnsiFilt
                    fcb       $0A                 * 0015 0A             .

start               lbsr      Setup               * 0016 17 00 1F       ...
ReadLoop            clra                          * 0019 4F             O
                    leax      ReadBuf,U           * 001A 30 C4          0D
                    ldy       #1                  * 001C 10 8E 00 01    ....
                    os9       I$Read              * 0020 10 3F 89       .?.
                    bcs       Error               * 0023 25 07          %.
                    lda       ReadBuf,U           * 0025 A6 C4          &D
                    lbsr      L0049               * 0027 17 00 1F       ...
                    bra       ReadLoop            * 002A 20 ED           m

Error               cmpb      #E$EOF              * 002C C1 D3          AS
                    lbne      ErrExit             * 002E 10 26 00 03    .&..
                    bra       Exit                * 0032 20 00           .
Exit                clrb                          * 0034 5F             _
ErrExit             os9       F$Exit              * 0035 10 3F 06       .?.

Setup               clr       InEscSeq,U          * 0038 6F 45          oE
                    leax      WriteBuf,U          * 003A 30 48          0H
                    stx       XSave,U             * 003C AF 46          /F
                    lda       #1                  * 003E 86 01          ..
                    sta       ColCount,U          * 0040 A7 41          'A
                    sta       RowCount,U          * 0042 A7 42          'B
                    sta       U0003,U             * 0044 A7 43          'C
                    sta       U0004,U             * 0046 A7 44          'D
                    rts                           * 0048 39             9

L0049               cmpa      #32                 * Is it a space?                           * 0049 81 20          .
                    bcs       L007A               * no, go check others                      * 004B 25 2D          %-
                    tst       <InEscSeq           * In an ESC sequence?                      * 004D 0D 05          ..
                    lbne      L00F2               * Yes, go handle it                        * 004F 10 26 00 9F    .&..

* Write the character to the output path
                    pshs      A                   * 0053 34 02          4.
                    leax      0,S                 * 0055 30 E4          0d
                    ldy       #1                  * 0057 10 8E 00 01    ....
                    lda       #1                  * 005B 86 01          ..
                    os9       I$Write             * 005D 10 3F 8A       .?.

                    inc       ColCount,U          * Increment the number of chars written    * 0060 6C 41          lA
                    lda       ColCount,U          * 0062 A6 41          &A
                    cmpa      #128                * Have we written 128?                     * 0064 81 80          ..
                    bls       L0078               * No, so return                            * 0066 23 10          #.

                    lda       #1                  * Reset the column count                   * 0068 86 01          ..
                    sta       ColCount,U          * 006A A7 41          'A
                    inc       RowCount,U          * Increment the row count                  * 006C 6C 42          lB
                    lda       RowCount,U          * 006E A6 42          &B
                    cmpa      #23                 * Have we written 24 rows?                 * 0070 81 17          ..
                    bls       L0078               * No, so return                            * 0072 23 04          #.

                    lda       #23                 * Reset the row count                      * 0074 86 17          ..
                    sta       RowCount,U          * 0076 A7 42          'B
L0078               puls      PC,A                * Clean the stack and return               * 0078 35 82          5.

L007A               cmpa      #27                 * Is it an ESC?                            * 007A 81 1B          ..
                    beq       HandleESC           * Yes, go handle it                        * 007C 27 11          '.
                    cmpa      #7                  * Is it a BEL character?                   * 007E 81 07          ..
                    beq       HandleBEL           * Yes, go handle it                        * 0080 27 1A          '.
                    cmpa      #8                  * Is it a BS character?                    * 0082 81 08          ..
                    beq       HandleBS            * Yes, go handle it                        * 0084 27 25          '%
                    cmpa      #10                 * Is it an LF character?                   * 0086 81 0A          ..
                    beq       HandleLF            * Yes, go handle it                        * 0088 27 3A          ':
                    cmpa      #13                 * Is it a CR character?                    * 008A 81 0D          ..
                    beq       HandleCR            * Yes, go handle it                        * 008C 27 51          'Q
                    rts                           * Something else, so return                * 008E 39             9

HandleESC           lda       #1                  * Parsing an ESC seq, so set the flag      * 008F 86 01          ..
                    sta       InEscSeq,U          * 0091 A7 45          'E
                    leax      WriteBuf,U          * Set X to the buffer                      * 0093 30 48          0H
                    lda       #27                 * Save the ESC code in the buffer          * 0095 86 1B          ..
                    sta       ,X+                 * Increment the buffer pointer             * 0097 A7 80          '.
                    stx       XSave,U             * Save a copy of the pointer               * 0099 AF 46          /F
                    rts                           * ... and return                           * 009B 39             9

* Write the BEL to the output path
HandleBEL           pshs      A                   * 009C 34 02          4.
                    leax      0,S                 * 009E 30 E4          0d
                    ldy       #1                  * 00A0 10 8E 00 01    ....
                    lda       #1                  * 00A4 86 01          ..
                    os9       I$Write             * 00A6 10 3F 8A       .?.
                    puls      PC,A                * 00A9 35 82          5.

HandleBS            pshs      A                   * 00AB 34 02          4.
                    dec       ColCount,U          * Decrement the column count               * 00AD 6A 41          jA
                    bne       bs1                 * Branch if col count not zero             * 00AF 26 06          &.
                    lda       #1                  * Reset the column count                   * 00B1 86 01          ..
                    sta       ColCount,U          * 00B3 A7 41          'A
                    bra       bsret               * ... and return                           * 00B5 20 0B           .

* Write the BS to the output path
bs1                 leax      0,S                 * 00B7 30 E4          0d
                    ldy       #1                  * 00B9 10 8E 00 01    ....
                    lda       #1                  * 00BD 86 01          ..
                    os9       I$Write             * 00BF 10 3F 8A       .?.
bsret               puls      PC,A                * Clean the stack and return               * 00C2 35 82          5.

* Write the LF to the output path
HandleLF            pshs      A                   * 00C4 34 02          4.
                    leax      0,S                 * 00C6 30 E4          0d
                    ldy       #1                  * 00C8 10 8E 00 01    ....
                    lda       #1                  * 00CC 86 01          ..
                    os9       I$Write             * 00CE 10 3F 8A       .?.

                    inc       RowCount,U          * Increment the row count                  * 00D1 6C 42          lB
                    lda       RowCount,U          * 00D3 A6 42          &B
                    cmpa      #23                 * 00D5 81 17          ..
                    bls       lfret               * Return if less than 24 rows              * 00D7 23 04          #.
                    lda       #23                 * Reset the row count                      * 00D9 86 17          ..
                    sta       RowCount,U          * 00DB A7 42          'B
lfret               puls      PC,A                * Clean the stack and return               * 00DD 35 82          5.

* Write the CR to the output path
HandleCR            pshs      A                   * 00DF 34 02          4.
                    leax      0,S                 * 00E1 30 E4          0d
                    ldy       #1                  * 00E3 10 8E 00 01    ....
                    lda       #1                  * 00E7 86 01          ..
                    os9       I$Write             * 00E9 10 3F 8A       .?.

                    lda       #1                  * Reset the col count                      * 00EC 86 01          ..
                    sta       ColCount,U          * 00EE A7 41          'A
                    puls      PC,A                * Clean the stack and return               * 00F0 35 82          5.

L00F2               cmpa      #65                 * Is it less than 'A'?                     * 00F2 81 41          .A
                    bcs       L0101               * Yes, append it to the save sequence      * 00F4 25 0B          %.
                    cmpa      #91                 * It is a '['?                             * 00F6 81 5B          .[
                    beq       L0101               * Yes, append it to the save sequence      * 00F8 27 07          '.
                    cmpa      #122                * Is it greater than 'z'?                  * 00FA 81 7A          .z
                    bhi       L0101               * Yes, append it to the save sequence      * 00FC 22 03          ".
                    lbra      L0108               * 00FE 16 00 07       ...

* Append the char to the ESC sequence buffer
L0101               ldx       XSave,U             * 0101 AE 46          .F
                    sta       ,X+                 * 0103 A7 80          '.
                    stx       XSave,U             * 0105 AF 46          /F
                    rts                           * 0107 39             9

L0108               clr       InEscSeq,U          * Reset the ESC sequence flag              * 0108 6F 45          oE
                    ldx       XSave,U             * Get the buffer pointer                   * 010A AE 46          .F
                    sta       ,X+                 * Save the current character               * 010C A7 80          '.
                    stx       XSave,U             * ... and save the new pointer             * 010E AF 46          /F
                    cmpa      #72                 * Is it an 'H'?                            * 0110 81 48          .H
                    lbeq      Esc_Hf              * Yes, handle it                           * 0112 10 27 00 83    .'..
                    cmpa      #65                 * Is it an 'A'?                            * 0116 81 41          .A
                    lbeq      Esc_A               * Yes, handle it                           * 0118 10 27 00 B7    .'.7
                    cmpa      #66                 * Is it a 'B'?                             * 011C 81 42          .B
                    lbeq      Esc_B               * Yes, handle it                           * 011E 10 27 00 DC    .'.\
                    cmpa      #67                 * Is it a 'C'?                             * 0122 81 43          .C
                    lbeq      Esc_C               * 0124 10 27 01 03    .'..
                    cmpa      #68                 * 0128 81 44          .D
                    lbeq      Esc_D               * 012A 10 27 01 2B    .'.+
                    cmpa      #102                * 012E 81 66          .f
                    lbeq      Esc_Hf              * 0130 10 27 00 65    .'.e
                    cmpa      #115                * 0134 81 73          .s
                    lbeq      Esc_s               * 0136 10 27 01 43    .'.C
                    cmpa      #117                * 013A 81 75          .u
                    lbeq      Esc_u               * 013C 10 27 01 46    .'.F
                    cmpa      #74                 * 0140 81 4A          .J
                    lbeq      Esc_J               * 0142 10 27 00 23    .'.#
                    cmpa      #107                * 0146 81 6B          .k
                    lbeq      Esc_k               * 0148 10 27 00 3B    .'.;
                    cmpa      #109                * 014C 81 6D          .m
                    lbeq      Esc_m               * 014E 10 27 01 5D    .'.]

* Write the buffer to the output path
L0152               leax      WriteBuf,U          * 0152 30 48          0H
                    pshs      X                   * 0154 34 10          4.
                    ldd       XSave,U             * 0156 EC 46          lF
                    subd      0,S                 * 0158 A3 E4          #d
                    leas      $02,S               * 015A 32 62          2b
                    tfr       D,Y                 * 015C 1F 02          ..
                    leax      WriteBuf,U          * 015E 30 48          0H
                    lda       #1                  * 0160 86 01          ..
                    os9       I$Write             * 0162 10 3F 8A       .?.
                    clr       InEscSeq,U          * 0165 6F 45          oE
                    rts                           * 0167 39             9

* Clear the screen
L0168               fcb       $0C                 * 0168 0C             .
Esc_J               lbsr      L0397               * 0169 17 02 2B       ..+
                    lda       ,X+                 * 016C A6 80          &.
                    cmpa      #50                 * 016E 81 32          .2
                    bne       L0152               * 0170 26 E0          &`
                    leax      >L0168,PC           * 0172 30 8D FF F2    0..r
                    ldy       #1                  * 0176 10 8E 00 01    ....
                    lda       #1                  * 017A 86 01          ..
                    os9       I$Write             * 017C 10 3F 8A       .?.
                    lda       #1                  * 017F 86 01          ..
                    sta       ColCount,U          * 0181 A7 41          'A
                    sta       RowCount,U          * 0183 A7 42          'B
                    rts                           * 0185 39             9

L0186               fcb       $04                 * 0186 04             .
Esc_k               lbsr      L0397               * 0187 17 02 0D       ...
                    leax      >L0186,PC           * 018A 30 8D FF F8    0..x
                    ldy       #1                  * 018E 10 8E 00 01    ....
                    lda       #1                  * 0192 86 01          ..
                    os9       I$Write             * 0194 10 3F 8A       .?.
                    rts                           * 0197 39             9

L0198               fcb       $02                 * 0198 02             .
Esc_Hf              lbsr      L0397               * 0199 17 01 FB       ..{
                    lbsr      L03A7               * 019C 17 02 08       ...
                    sta       RowCount,U          * 019F A7 42          'B
                    adda      #31                 * 01A1 8B 1F          ..
                    pshs      A                   * 01A3 34 02          4.
                    lda       ,X+                 * 01A5 A6 80          &.
                    cmpa      #59                 * 01A7 81 3B          .;
                    beq       L01B0               * 01A9 27 05          '.
                    puls      A                   * 01AB 35 02          5.
                    lbra      L0152               * 01AD 16 FF A2       .."
L01B0               lbsr      L03A7               * 01B0 17 01 F4       ..t
                    sta       ColCount,U          * 01B3 A7 41          'A
                    adda      #31                 * 01B5 8B 1F          ..
                    pshs      A                   * 01B7 34 02          4.
                    leax      >L0198,PC           * 01B9 30 8D FF DB    0..[
                    ldy       #1                  * 01BD 10 8E 00 01    ....
                    lda       #1                  * 01C1 86 01          ..
                    os9       I$Write             * 01C3 10 3F 8A       .?.
                    leax      0,S                 * 01C6 30 E4          0d
                    ldy       #2                  * 01C8 10 8E 00 02    ....
                    os9       I$Write             * 01CC 10 3F 8A       .?.
                    leas      $02,S               * 01CF 32 62          2b
                    rts                           * 01D1 39             9

L01D2               fcb       $09                 * 01D2 09             .
Esc_A               lbsr      L0397               * 01D3 17 01 C1       ..A
                    lbsr      L03A7               * 01D6 17 01 CE       ..N
                    pshs      A                   * 01D9 34 02          4.
                    lda       RowCount,U          * 01DB A6 42          &B
                    suba      0,S                 * 01DD A0 E4           d
                    bgt       L01E3               * 01DF 2E 02          ..
                    lda       #1                  * 01E1 86 01          ..
L01E3               sta       RowCount,U          * 01E3 A7 42          'B
                    leax      >L01D2,PC           * 01E5 30 8D FF E9    0..i
                    ldy       #1                  * 01E9 10 8E 00 01    ....
                    lda       #1                  * 01ED 86 01          ..
L01EF               tst       0,S                 * 01EF 6D E4          md
                    beq       L01FA               * 01F1 27 07          '.
                    os9       I$Write             * 01F3 10 3F 8A       .?.
                    dec       0,S                 * 01F6 6A E4          jd
                    bne       L01EF               * 01F8 26 F5          &u
L01FA               leas      $01,S               * 01FA 32 61          2a
                    rts                           * 01FC 39             9

L01FD               fcb       $0A                 * 01FD 0A             .
Esc_B               lbsr      L0397               * 01FE 17 01 96       ...
                    lbsr      L03A7               * 0201 17 01 A3       ..#
                    pshs      A                   * 0204 34 02          4.
                    lda       RowCount,U          * 0206 A6 42          &B
                    adda      0,S                 * 0208 AB E4          +d
                    cmpa      #23                 * 020A 81 17          ..
                    bls       L021C               * 020C 23 0E          #.
                    suba      #23                 * 020E 80 17          ..
                    pshs      A                   * 0210 34 02          4.
                    lda       $01,S               * 0212 A6 61          &a
                    suba      0,S                 * 0214 A0 E4           d
                    leas      $01,S               * 0216 32 61          2a
                    sta       0,S                 * 0218 A7 E4          'd
                    lda       #23                 * 021A 86 17          ..
L021C               sta       RowCount,U          * 021C A7 42          'B
                    leax      >L01FD,PC           * 021E 30 8D FF DB    0..[
                    ldy       #1                  * 0222 10 8E 00 01    ....
                    lda       #1                  * 0226 86 01          ..
                    bra       L01EF               * 0228 20 C5           E

L022A               fcb       $06                 * 022A 06             .
Esc_C               lbsr      L0397               * 022B 17 01 69       ..i
                    lbsr      L03A7               * 022E 17 01 76       ..v
                    pshs      A                   * 0231 34 02          4.
                    lda       ColCount,U          * 0233 A6 41          &A
                    adda      0,S                 * 0235 AB E4          +d
                    cmpa      #80                 * 0237 81 50          .P
                    bls       L0249               * 0239 23 0E          #.
                    suba      #80                 * 023B 80 50          .P
                    pshs      A                   * 023D 34 02          4.
                    lda       $01,S               * 023F A6 61          &a
                    suba      0,S                 * 0241 A0 E4           d
                    sta       $01,S               * 0243 A7 61          'a
                    leas      $01,S               * 0245 32 61          2a
                    lda       #80                 * 0247 86 50          .P
L0249               sta       ColCount,U          * 0249 A7 41          'A
                    leax      >L022A,PC           * 024B 30 8D FF DB    0..[
                    ldy       #1                  * 024F 10 8E 00 01    ....
                    lda       #1                  * 0253 86 01          ..
                    lbra      L01EF               * 0255 16 FF 97       ...

L0258               fcb       $08                 * 0258 08             .
Esc_D               lbsr      L0397               * 0259 17 01 3B       ..;
                    lbsr      L03A7               * 025C 17 01 48       ..H
                    pshs      A                   * 025F 34 02          4.
                    lda       ColCount,U          * 0261 A6 41          &A
                    suba      0,S                 * 0263 A0 E4           d
                    bgt       L026E               * 0265 2E 07          ..
                    deca                          * 0267 4A             J
                    adda      0,S                 * 0268 AB E4          +d
                    sta       0,S                 * 026A A7 E4          'd
                    lda       #1                  * 026C 86 01          ..
L026E               sta       ColCount,U          * 026E A7 41          'A
                    leax      >L0258,PC           * 0270 30 8D FF E4    0..d
                    ldy       #1                  * 0274 10 8E 00 01    ....
                    lda       #1                  * 0278 86 01          ..
                    lbra      L01EF               * 027A 16 FF 72       ..r

Esc_s               lda       ColCount,U          * 027D A6 41          &A
                    sta       U0003,U             * 027F A7 43          'C
                    lda       RowCount,U          * 0281 A6 42          &B
                    sta       U0004,U             * 0283 A7 44          'D
                    rts                           * 0285 39             9

Esc_u               lda       U0004,U             * 0286 A6 44          &D
                    sta       RowCount,U          * 0288 A7 42          'B
                    adda      #31                 * 028A 8B 1F          ..
                    pshs      A                   * 028C 34 02          4.
                    lda       U0003,U             * 028E A6 43          &C
                    sta       ColCount,U          * 0290 A7 41          'A
                    adda      #31                 * 0292 8B 1F          ..
                    pshs      A                   * 0294 34 02          4.
                    leax      >L0198,PC           * 0296 30 8D FE FE    0.~~
                    ldy       #1                  * 029A 10 8E 00 01    ....
                    lda       #1                  * 029E 86 01          ..
                    os9       I$Write             * 02A0 10 3F 8A       .?.
                    leax      0,S                 * 02A3 30 E4          0d
                    ldy       #2                  * 02A5 10 8E 00 02    ....
                    os9       I$Write             * 02A9 10 3F 8A       .?.
                    leas      $02,S               * 02AC 32 62          2b
                    rts                           * 02AE 39             9

Esc_m               lbsr      L0397               * 02AF 17 00 E5       ..e
L02B2               lda       0,X                 * 02B2 A6 84          &.
                    cmpa      #109                * 02B4 81 6D          .m
                    beq       L02C3               * 02B6 27 0B          '.
                    lbsr      L03A7               * 02B8 17 00 EC       ..l
                    bsr       L02C4               * 02BB 8D 07          ..
                    lda       ,X+                 * 02BD A6 80          &.
                    cmpa      #59                 * 02BF 81 3B          .;
                    beq       L02B2               * 02C1 27 EF          'o
L02C3               rts                           * 02C3 39             9

L02C4               pshs      X                   * 02C4 34 10          4.
                    cmpa      #0                  * 02C6 81 00          ..
                    beq       L02F2               * 02C8 27 28          '(
                    cmpa      #4                  * 02CA 81 04          ..
                    beq       L0303               * 02CC 27 35          '5
                    cmpa      #5                  * 02CE 81 05          ..
                    beq       L0314               * 02D0 27 42          'B
                    cmpa      #7                  * 02D2 81 07          ..
                    beq       L031C               * 02D4 27 46          'F
                    cmpa      #8                  * 02D6 81 08          ..
                    beq       L0328               * 02D8 27 4E          'N
                    cmpa      #40                 * 02DA 81 28          .(
                    lbge      L0365               * 02DC 10 2C 00 85    .,..
                    cmpa      #30                 * 02E0 81 1E          ..
                    bge       L0339               * 02E2 2C 55          ,U
                    puls      PC,X                * 02E4 35 90          5.

L02E6               fcb       $1B                 * 02E6 1B             .
                    fcb       $32                 * 02E7 32             2
                    fcb       $00                 * 02E8 00             .
                    fcb       $1B                 * 02E9 1B             .
                    fcb       $33                 * 02EA 33             3
                    fcb       $02                 * 02EB 02             .
                    fcb       $1F                 * 02EC 1F             .
                    fcb       $21                 * 02ED 21             !
                    fcb       $1F                 * 02EE 1F             .
                    fcb       $23                 * 02EF 23             #
                    fcb       $1F                 * 02F0 1F             .
                    fcb       $25                 * 02F1 25             %

L02F2               leax      >L02E6,PC           * 02F2 30 8D FF F0    0..p
                    ldy       #12                 * 02F6 10 8E 00 0C    ....
                    lda       #1                  * 02FA 86 01          ..
                    os9       I$Write             * 02FC 10 3F 8A       .?.
                    puls      PC,X                * 02FF 35 90          5.

L0301               fcb       $1F                 * 0301 1F             .
                    fcb       $22                 * 0302 22             "

L0303               leax      >L0301,PC           * 0303 30 8D FF FA    0..z
L0307               ldy       #2                  * 0307 10 8E 00 02    ....
                    lda       #1                  * 030B 86 01          ..
                    os9       I$Write             * 030D 10 3F 8A       .?.
                    puls      PC,X                * 0310 35 90          5.

L0312               fcb       $1F                 * 0312 1F             .
                    fcb       $24                 * 0313 24             $

L0314               leax      >L0312,PC           * 0314 30 8D FF FA    0..z
                    bra       L0307               * 0318 20 ED           m

L031A               fcb       $1F                 * 031A 1F             .
                    fcb       $20                 * 031B 20

L031C               leax      >L031A,PC           * 031C 30 8D FF FA    0..z
                    bra       L0307               * 0320 20 E5           e

L0322               fcb       $1B                 * 0322 1B             .
                    fcb       $32                 * 0323 32             2
                    fcb       $02                 * 0324 02             .
                    fcb       $1B                 * 0325 1B             .
                    fcb       $33                 * 0326 33             3
                    fcb       $02                 * 0327 02             .

L0328               leax      >L0322,PC           * 0328 30 8D FF F6    0..v
                    ldy       #6                  * 032C 10 8E 00 06    ....
                    lda       #1                  * 0330 86 01          ..
                    os9       I$Write             * 0332 10 3F 8A       .?.
                    puls      PC,X                * 0335 35 90          5.

L0337               fcb       $1B                 * 0337 1B             .
                    fcb       $32                 * 0338 32             2

L0339               cmpa      #37                 * 0339 81 25          .%
                    ble       L033F               * 033B 2F 02          /.
                    puls      PC,X                * 033D 35 90          5.

L033F               suba      #30                 * 033F 80 1E          ..
                    pshs      A                   * 0341 34 02          4.
                    leax      >L0337,PC           * 0343 30 8D FF F0    0..p
                    ldy       #2                  * 0347 10 8E 00 02    ....
                    lda       #1                  * 034B 86 01          ..
                    os9       I$Write             * 034D 10 3F 8A       .?.
                    puls      A                   * 0350 35 02          5.
                    leax      >L038F,PC           * 0352 30 8D 00 39    0..9
                    leax      A,X                 * 0356 30 86          0.
                    ldy       #1                  * 0358 10 8E 00 01    ....
                    lda       #1                  * 035C 86 01          ..
                    os9       I$Write             * 035E 10 3F 8A       .?.
                    puls      PC,X                * 0361 35 90          5.

L0363               fcb       $1B                 * 0363 1B             .
                    fcb       $33                 * 0364 33             3

L0365               cmpa      #47                 * 0365 81 2F          ./
                    ble       L036B               * 0367 2F 02          /.
                    puls      PC,X                * 0369 35 90          5.

L036B               suba      #40                 * 036B 80 28          .(
                    pshs      A                   * 036D 34 02          4.
                    leax      >L0363,PC           * 036F 30 8D FF F0    0..p
                    ldy       #2                  * 0373 10 8E 00 02    ....
                    lda       #1                  * 0377 86 01          ..
                    os9       I$Write             * 0379 10 3F 8A       .?.
                    leax      >L038F,PC           * 037C 30 8D 00 0F    0...
                    puls      A                   * 0380 35 02          5.
                    leax      A,X                 * 0382 30 86          0.
                    ldy       #1                  * 0384 10 8E 00 01    ....
                    lda       #1                  * 0388 86 01          ..
                    os9       I$Write             * 038A 10 3F 8A       .?.

                    puls      PC,X                * 038D 35 90          5.

L038F               fcb       $02                 * 038F 02             .
                    fcb       $04                 * 0390 04             .
                    fcb       $03                 * 0391 03             .
                    fcb       $05                 * 0392 05             .
                    fcb       $01                 * 0393 01             .
                    fcb       $06                 * 0394 06             .
                    fcb       $07                 * 0395 07             .
                    fcb       $00                 * 0396 00             .

L0397               leax      WriteBuf,U          * 0397 30 48          0H
                    leax      $01,X               * 0399 30 01          0.
                    lda       ,X+                 * 039B A6 80          &.
                    cmpa      #91                 * 039D 81 5B          .[
                    beq       L03A6               * 039F 27 05          '.
                    leas      $02,S               * 03A1 32 62          2b
                    lbra      L0152               * 03A3 16 FD AC       .},
L03A6               rts                           * 03A6 39             9

L03A7               lda       0,X                 * 03A7 A6 84          &.
                    cmpa      #48                 * 03A9 81 30          .0
                    blt       L03E7               * 03AB 2D 3A          -:
                    cmpa      #57                 * 03AD 81 39          .9
                    bgt       L03E7               * 03AF 2E 36          .6
L03B1               lda       ,X+                 * 03B1 A6 80          &.
                    cmpa      #48                 * 03B3 81 30          .0
                    blt       L03BD               * 03B5 2D 06          -.
                    cmpa      #57                 * 03B7 81 39          .9
                    bgt       L03BD               * 03B9 2E 02          ..
                    bra       L03B1               * 03BB 20 F4           t
L03BD               leax      -$01,X              * 03BD 30 1F          0.
                    tfr       X,Y                 * 03BF 1F 12          ..
                    pshs      X                   * 03C1 34 10          4.
                    ldb       #1                  * 03C3 C6 01          F.
                    ldx       #0                  * 03C5 8E 00 00       ...
L03C8               pshs      B                   * 03C8 34 04          4.
                    lda       ,-Y                 * 03CA A6 A2          &"
                    cmpa      #48                 * 03CC 81 30          .0
                    blt       L03DF               * 03CE 2D 0F          -.
                    cmpa      #57                 * 03D0 81 39          .9
                    bgt       L03DF               * 03D2 2E 0B          ..
                    suba      #48                 * 03D4 80 30          .0
                    mul                           * 03D6 3D             =
                    abx                           * 03D7 3A             :
                    puls      B                   * 03D8 35 04          5.
                    lda       #10                 * 03DA 86 0A          ..
                    mul                           * 03DC 3D             =
                    bra       L03C8               * 03DD 20 E9           i

L03DF               puls      B                   * 03DF 35 04          5.
                    tfr       X,D                 * 03E1 1F 10          ..
                    tfr       B,A                 * 03E3 1F 98          ..
                    puls      PC,X                * 03E5 35 90          5.

L03E7               lda       #1                  * 03E7 86 01          ..
                    rts                           * 03E9 39             9

                    emod
eom                 equ       *
                    end
