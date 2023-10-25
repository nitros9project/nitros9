                    nam       answer
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

ChatId              rmb       4
ReadBuf             rmb       1
U0005               rmb       1
ProcId              rmb       5
memtop              rmb       2
U000D               rmb       2
ProcDesc            rmb       512
ProcBuf             rmb       1
U0210               rmb       431
size                equ       .

name                fcs       /answer/            * 000D 61 6E 73 77 65 F2 answer
                    fcc       "Copyright (C) 1988By Keith Alphonso" * 0013 43 6F 70 79 72 69 67 68 74 20 28 43 29 20 31 39 38 38 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F Copyright (C) 1988By Keith Alphonso
                    fcc       "Licenced to Alpha Software Technologies" * 0036 4C 69 63 65 6E 63 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licenced to Alpha Software Technologies
                    fcc       "All rights reserved" * 005D 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 All rights reserved
                    fcb       $EC                 * 0070 EC             l
                    fcb       $E6                 * 0071 E6             f
                    fcb       $EA                 * 0072 EA             j
                    fcb       $F5                 * 0073 F5             u
                    fcb       $E9                 * 0074 E9             i
                    fcb       $A0                 * 0075 A0
                    fcb       $E2                 * 0076 E2             b
                    fcb       $ED                 * 0077 ED             m
                    fcb       $F1                 * 0078 F1             q
                    fcb       $E9                 * 0079 E9             i
                    fcb       $F0                 * 007A F0             p
                    fcb       $EF                 * 007B EF             o
                    fcb       $F4                 * 007C F4             t
                    fcb       $F0                 * 007D F0             p
Answer              fcc       "Answering call..." * 007E 41 6E 73 77 65 72 69 6E 67 20 63 61 6C 6C 2E 2E 2E Answering call...
                    fcc       "Press <ALT><X> when finished." * 008F 50 72 65 73 73 20 3C 41 4C 54 3E 3C 58 3E 20 77 68 65 6E 20 66 69 6E 69 73 68 65 64 2E Press <ALT><X> when finished.
                    fcb       $0D                 * 00AC 0D             .
lf_cr               fcb       $0A                 * 00AD 0A             .
                    fcb       $0D                 * 00AE 0D             .
BBS_Chat            fcs       "BBS.chat"          * 00AF 42 42 53 2E 63 68 61 F4 BBS.chat
NoChat              fcc       "Sorry, no one has requested to chat!" * 00B7 53 6F 72 72 79 2C 20 6E 6F 20 6F 6E 65 20 68 61 73 20 72 65 71 75 65 73 74 65 64 20 74 6F 20 63 68 61 74 21 Sorry, no one has requested to chat!
                    fcb       $0D                 * 00DB 0D             .
Line                fcc       "----------------------------------------------------------------" * 00DC 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2
                    fcb       $0D                 * 011C 0D             .
                    fcc       "/t2"               * 011D 2F 74 32       /t2
                    fcb       $0D                 * 0120 0D             .

start               stx       memtop,U            * 0121 AF 4B          /K
                    lda       #2                  * 0123 86 02          ..
                    sta       ProcId,U            * 0125 A7 46          'F

* Check all process descriptors until we find BBS_Chat
ProcLoop            lda       ProcId,U            * 0127 A6 46          &F
                    lbeq      L0257               * ProcId=0 so exit the loop                * 0129 10 27 01 2A    .'.*
                    leax      ProcDesc,U          * Point to process descriptor buffer       * 012D 30 4F          0O
                    os9       F$GPrDsc            * Get the process descriptor               * 012F 10 3F 18       .?.
                    bcs       NextProc            * Process does not exist, so skip it       * 0132 25 45          %E
                    leay      <$0040,X            * Point to P$DATImg                        * 0134 31 88 40       1.@
                    tfr       Y,D                 * Put P$DATImg in D                        * 0137 1F 20          .
                    ldx       <$0011,X            * Get the P$Modul offset                   * 0139 AE 88 11       ...
                    ldy       #9                  * Gonna copy 9 bytes                       * 013C 10 8E 00 09    ....
                    pshs      U                   * Save a copy of U                         * 0140 34 40          4@
                    leau      >ProcBuf,U          * Point to the buffer                      * 0142 33 C9 02 0F    3I..
                    os9       F$CpyMem            * Copy the module header                   * 0146 10 3F 1B       .?.
                    lbcs      ErrExit             * Exit on error                            * 0149 10 25 01 1C    .%..
                    pshs      D                   * Save the DAT image pointer               * 014D 34 06          4.
                    ldd       ReadBuf,U           * Get the M$Name offset                    * 014F EC 44          lD
                    leax      D,X                 * Point to the buffer                      * 0151 30 8B          0.
                    puls      D                   * Get the DAT image pointer                * 0153 35 06          5.
                    ldy       #32                 * Gonna copy 32 bytes                      * 0155 10 8E 00 20    ...
                    os9       F$CpyMem            * Copy the module name                     * 0159 10 3F 1B       .?.
                    lbcs      ErrExit             * Exit on error                            * 015C 10 25 01 09    .%..
                    puls      U                   * Restore U                                * 0160 35 40          5@

* Have we found BBS_Chat yet?
                    leax      >ProcBuf,U          * 0162 30 C9 02 0F    0I..
                    leay      >BBS_Chat,PC        * 0166 31 8D FF 45    1..E

CmpNames            lda       ,X+                 * 016A A6 80          &.
                    cmpa      ,Y+                 * 016C A1 A0          !
                    bne       NextProc            * This isn't BBS_Chat, try again           * 016E 26 09          &.
                    tsta                          * 0170 4D             M
                    bpl       CmpNames            * Names match so far, try next char        * 0171 2A F7          *w

                    lda       ProcId,U            * 0173 A6 46          &F
                    sta       ChatId,U            * 0175 A7 C4          'D
                    bra       ChatSignl           * Found BBS_Chat, so exit loop             * 0177 20 04           .

NextProc            inc       ProcId,U            * 0179 6C 46          lF
                    bra       ProcLoop            * 017B 20 AA           *

ChatSignl           lda       ChatId,U            * Get BBS_Chat process Id                  * 017D A6 C4          &D
                    ldb       #129                * Signal code                              * 017F C6 81          F.
                    os9       F$Send              * Send $81 signal to BBS_Chat              * 0181 10 3F 08       .?.
                    bcc       L018E               * Branch if signal received                * 0184 24 08          $.
                    ldx       #1                  * BBS_Chat has signal pending...           * 0186 8E 00 01       ...
                    os9       F$Sleep             * ... so sleep a bit ...                   * 0189 10 3F 0A       .?.
                    bra       ChatSignl           * ... and try again                        * 018C 20 EF           o

* Write "answering call..."
L018E               leax      >Answer,PC          * 018E 30 8D FE EC    0.~l
                    ldy       #200                * 0192 10 8E 00 C8    ...H
                    lda       #1                  * 0196 86 01          ..
                    os9       I$WritLn            * 0198 10 3F 8C       .?.

* Write a line of dashes
                    leax      >Line,PC            * 019B 30 8D FF 3D    0..=
                    ldy       #65                 * 019F 10 8E 00 41    ...A
                    lda       #1                  * 01A3 86 01          ..
                    os9       I$WritLn            * 01A5 10 3F 8C       .?.

* Link to BBS_Chat
                    leax      >BBS_Chat,PC        * 01A8 30 8D FF 03    0...
                    lda       #17                 * 01AC 86 11          ..
                    pshs      U                   * 01AE 34 40          4@
                    os9       F$Link              * 01B0 10 3F 00       .?.
                    lbcs      ErrExit             * Exit on error                            * 01B3 10 25 00 B2    .%.2

                    puls      U                   * 01B7 35 40          5@
                    sty       U000D,U             * 01B9 10 AF 4D       ./M

ChkInput            clra                          * 01BC 4F             O
                    ldb       #1                  * SS.Ready                                 * 01BD C6 01          F.
                    os9       I$GetStt            * 01BF 10 3F 8D       .?.
                    bcc       L01F4               * Data is waiting so go read it            * 01C2 24 30          $0
                    ldx       U000D,U             * 01C4 AE 4D          .M
                    tst       $02,X               * 01C6 6D 02          m.
                    beq       ChkInput            * 01C8 27 F2          'r

Loop                pshs      X                   * 01CA 34 10          4.
                    leax      $03,X               * 01CC 30 03          0.
                    ldy       #1                  * 01CE 10 8E 00 01    ....
                    lda       #1                  * 01D2 86 01          ..
                    os9       I$Write             * 01D4 10 3F 8A       .?.
                    puls      X                   * 01D7 35 10          5.
                    lda       $03,X               * 01D9 A6 03          &.
                    cmpa      #13                 * Is it a CR?                              * 01DB 81 0D          ..
                    bne       L01F0               * No, don't write LF                       * 01DD 26 11          &.

* Write LF after each CR
                    pshs      X                   * 01DF 34 10          4.
                    leax      >lf_cr,PC           * 01E1 30 8D FE C8    0.~H
                    ldy       #1                  * 01E5 10 8E 00 01    ....
                    lda       #1                  * 01E9 86 01          ..
                    os9       I$Write             * 01EB 10 3F 8A       .?.
                    puls      X                   * 01EE 35 10          5.

L01F0               clr       $02,X               * Clear the counter                        * 01F0 6F 02          o.
                    bra       ChkInput            * Check for more data                      * 01F2 20 C8           H

L01F4               leax      ReadBuf,U           * 01F4 30 44          0D
                    ldy       #1                  * 01F6 10 8E 00 01    ....
                    os9       I$Read              * Read one character                       * 01FA 10 3F 89       .?.
                    lbcs      ErrExit             * Exit on error                            * 01FD 10 25 00 68    .%.h
                    lda       0,X                 * Get the character read                   * 0201 A6 84          &.
                    cmpa      #248                * Is it ALT+X?                             * 0203 81 F8          .x
                    beq       L0243               * Yes, so exit                             * 0205 27 3C          '<
                    cmpa      #13                 * Is it a CR?                              * 0207 81 0D          ..
                    bne       L021A               * No, don't write LF                       * 0209 26 0F          &.

* Write LF after each CR
                    leax      >lf_cr,PC           * 020B 30 8D FE 9E    0.~.
                    ldy       #1                  * 020F 10 8E 00 01    ....
                    lda       #1                  * 0213 86 01          ..
                    os9       I$Write             * Write LF                                 * 0215 10 3F 8A       .?.

                    lda       #13                 * Put the CR back in A                     * 0218 86 0D          ..
L021A               ldx       U000D,U             * 021A AE 4D          .M
                    pshs      CC                  * 021C 34 01          4.
                    orcc      #80                 * 021E 1A 50          .P
                    tst       $02,X               * 0220 6D 02          m.
                    bne       L023E               * 0222 26 1A          &.
                    sta       $03,X               * 0224 A7 03          '.
                    lda       #1                  * 0226 86 01          ..
                    sta       $02,X               * 0228 A7 02          '.
                    puls      CC                  * 022A 35 01          5.

* Wait for something to reset the flag at 2,X
L022C               lda       $02,X               * 022C A6 02          &.
                    lbeq      ChkInput            * 022E 10 27 FF 8A    .'..
                    pshs      X                   * 0232 34 10          4.
                    ldx       #1                  * 0234 8E 00 01       ...
                    os9       F$Sleep             * 0237 10 3F 0A       .?.
                    puls      X                   * 023A 35 10          5.
                    bra       L022C               * 023C 20 EE           n

L023E               puls      CC                  * 023E 35 01          5.
                    lbra      Loop                * 0240 16 FF 87       ...

L0243               lda       U0005,U             * 0243 A6 45          &E
                    os9       I$Close             * 0245 10 3F 8F       .?.
                    lda       ChatId,U            * 0248 A6 C4          &D
                    ldb       #2                  * 024A C6 02          F.
                    os9       F$Send              * 024C 10 3F 08       .?.
                    ldx       #60                 * 024F 8E 00 3C       ..<
                    os9       F$Sleep             * 0252 10 3F 0A       .?.
                    bra       Exit                * 0255 20 11           .

L0257               leax      >NoChat,PC          * 0257 30 8D FE 5C    0.~\
                    ldy       #200                * 025B 10 8E 00 C8    ...H
                    lda       #1                  * 025F 86 01          ..
                    os9       I$WritLn            * 0261 10 3F 8C       .?.
                    ldb       #1                  * 0264 C6 01          F.
                    bra       ErrExit             * 0266 20 01           .

Exit                clrb                          * 0268 5F             _
ErrExit             os9       F$Exit              * 0269 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
