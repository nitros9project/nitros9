                    nam       BBS.chat
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

DefCntr             rmb       1
BeepCntr            rmb       1
Flag                rmb       3
DotCntr             rmb       1
WPath               rmb       1
XSave               rmb       2
U0009               rmb       400
size                equ       .

name                fcs       /BBS.chat/          * 000D 42 42 53 2E 63 68 61 F4 BBS.chat

Paging              fcc       "Paging Sysop...Please wait" * 0015 50 61 67 69 6E 67 20 53 79 73 6F 70 2E 2E 2E 50 6C 65 61 73 65 20 77 61 69 74 Paging Sysop...Please wait
                    fcb       $0D                 * 002F 0D             .

NotHome             fcc       "Sorry, but the sysop does not seem to be home!" * 0030 53 6F 72 72 79 2C 20 62 75 74 20 74 68 65 20 73 79 73 6F 70 20 64 6F 65 73 20 6E 6F 74 20 73 65 65 6D 20 74 6F 20 62 65 20 68 6F 6D 65 21 Sorry, but the sysop does not seem to
                    fcb       $0D                 * 005E 0D             .

lf                  fcb       $0A                 * 005F 0A             .
                    fcb       $0D                 * 0060 0D             .

w                   fcc       "/w"                * 0061 2F 77          /w
                    fcb       $0D                 * 0063 0D             .

dot                 fcc       "."                 * 0064 2E             .
                    fcb       $0D                 * 0065 0D             .

bell                fcb       $07                 * 0066 07             .

start               bra       start_a             * 0067 20 02           .

DataRdy             fcb       $00                 * 0069 00             .
ChatBuf             fcb       $00                 * 006A 00             .

start_a             stx       XSave,U             * 006B AF 47          /G
                    lda       #10                 * 006D 86 0A          ..
                    sta       DefCntr,U           * Initialize the default counter           * 006F A7 C4          'D

* Set up the signal intercept handler
                    leax      >Icpt,PC            * 0071 30 8D 00 FB    0..{
                    os9       F$Icpt              * 0075 10 3F 09       .?.

                    lda       #255                * 0078 86 FF          ..
                    sta       Flag,U              * Set the flag                             * 007A A7 42          'B
                    lda       #10                 * 007C 86 0A          ..
                    sta       DotCntr,U           * Initialize the counter                   * 007E A7 45          'E

* Open /w for read/write
                    leax      >w,PC               * 0080 30 8D FF DD    0..]
                    lda       #3                  * 0084 86 03          ..
                    os9       I$Open              * 0086 10 3F 84       .?.
                    lbcs      ErrExit             * Exit on error                            * 0089 10 25 00 E0    .%.`
                    sta       WPath,U             * Store the path                           * 008D A7 46          'F

* Inform the user we are paging the sysop
                    leax      >Paging,PC          * 008F 30 8D FF 82    0...
                    ldy       #200                * 0093 10 8E 00 C8    ...H
                    lda       #1                  * 0097 86 01          ..
                    os9       I$WritLn            * 0099 10 3F 8C       .?.

**************************************************
* Page the sysop to join the chat
PageLoop            lda       DefCntr,U           * Get the default counter                  * 009C A6 C4          &D
                    sta       BeepCntr,U          * Initialize the beep counter              * 009E A7 41          'A

* Ding the sysop
BeepBeep            leax      >bell,PC            * 00A0 30 8D FF C2    0..B
                    lda       WPath,U             * 00A4 A6 46          &F
                    ldy       #1                  * 00A6 10 8E 00 01    ....
                    os9       I$Write             * 00AA 10 3F 8A       .?.
                    lbcs      ErrExit             * Exit on error                            * 00AD 10 25 00 BC    .%.<
                    ldx       #4                  * 00B1 8E 00 04       ...
                    os9       F$Sleep             * Sleep 4 ticks                            * 00B4 10 3F 0A       .?.
                    dec       BeepCntr,U          * Decrement the counter                    * 00B7 6A 41          jA
                    bne       BeepBeep            * Beep again if the counter is not zero    * 00B9 26 E5          &e

                    ldx       #90                 * 00BB 8E 00 5A       ..Z
                    os9       F$Sleep             * Sleep 90 ticks                           * 00BE 10 3F 0A       .?.
                    tst       Flag,U              * Is the sysop home?                       * 00C1 6D 42          mB
                    beq       L00E6               * Yes, and he answered the chat            * 00C3 27 21          '!

* Write a dot on /w
                    leax      >dot,PC             * 00C5 30 8D FF 9B    0...
                    ldy       #1                  * 00C9 10 8E 00 01    ....
                    lda       #1                  * 00CD 86 01          ..
                    os9       I$Write             * 00CF 10 3F 8A       .?.
                    dec       DotCntr,U           * Decrement the counter                    * 00D2 6A 45          jE
                    bne       PageLoop            * Try again if the counter is not zero     * 00D4 26 C6          &F

* Nobody's home so inform the user and exit
                    leax      >NotHome,PC         * 00D6 30 8D FF 56    0..V
                    ldy       #200                * 00DA 10 8E 00 C8    ...H
                    lda       #1                  * 00DE 86 01          ..
                    os9       I$WritLn            * 00E0 10 3F 8C       .?.
                    lbra      Exit                * 00E3 16 00 86       ...

L00E6               clr       >DataRdy,PC         * No data is available yet                 * 00E6 6F 8D FF 7F    o...

* Wait for the user or the sysop to press a key
DataLoop            clra                          * 00EA 4F             O
                    ldb       #1                  * SS.Ready                                 * 00EB C6 01          F.
                    os9       I$GetStt            * Has the user pressed a key?              * 00ED 10 3F 8D       .?.
                    bcc       TestFlag            * Yes, so go read it                       * 00F0 24 2E          $.
                    tst       >DataRdy,PC         * Has the sysop pressed a key?             * 00F2 6D 8D FF 73    m..s
                    beq       DataLoop            * No, so continue polling                  * 00F6 27 F2          'r

* Echo the sysop's char to the user
Echo                leax      >ChatBuf,PC         * 00F8 30 8D FF 6E    0..n
                    ldy       #1                  * 00FC 10 8E 00 01    ....
                    lda       #1                  * 0100 86 01          ..
                    os9       I$Write             * 0102 10 3F 8A       .?.

                    lda       >ChatBuf,PC         * Get the char the sysop typed             * 0105 A6 8D FF 61    &..a
                    cmpa      #13                 * Is it a CR?                              * 0109 81 0D          ..
                    bne       ClrFlag             * No, clear the flag and poll for more     * 010B 26 0D          &.

* Append LF to CR on the output path
                    leax      >lf,PC              * 010D 30 8D FF 4E    0..N
                    ldy       #1                  * 0111 10 8E 00 01    ....
                    lda       #1                  * 0115 86 01          ..
                    os9       I$Write             * 0117 10 3F 8A       .?.

ClrFlag             clr       >DataRdy,PC         * We are ready for more data               * 011A 6F 8D FF 4B    o..K
                    bra       DataLoop            * Check for more data                      * 011E 20 CA           J

TestFlag            tst       >DataRdy,PC         * Is data available yet?                   * 0120 6D 8D FF 45    m..E
                    bne       Echo                * Yes, go read it                          * 0124 26 D2          &R

* Read one character from the user
                    leax      >ChatBuf,PC         * 0126 30 8D FF 40    0..@
                    ldy       #1                  * 012A 10 8E 00 01    ....
                    clra                          * 012E 4F             O
                    os9       I$Read              * 012F 10 3F 89       .?.

                    lda       0,X                 * Get the character read                   * 0132 A6 84          &.
                    cmpa      #13                 * Is it a CR?                              * 0134 81 0D          ..
                    bne       SetFlag             * No, so don't write an LF                 * 0136 26 0D          &.

* Append an LF to the CR
                    leax      >lf,PC              * 0138 30 8D FF 23    0..#
                    ldy       #1                  * 013C 10 8E 00 01    ....
                    lda       #1                  * 0140 86 01          ..
                    os9       I$Write             * 0142 10 3F 8A       .?.

SetFlag             pshs      CC                  * Save the condition codes                 * 0145 34 01          4.
                    orcc      #80                 * Disable interrupts                       * 0147 1A 50          .P
                    tst       >DataRdy,PC         * Is data available yet?                   * 0149 6D 8D FF 1C    m...
                    bne       SleepRet            * Yes, echo it to the user                 * 014D 26 18          &.
                    lda       #1                  * 014F 86 01          ..
                    sta       >DataRdy,PC         * Set the data available flag              * 0151 A7 8D FF 14    '...
                    puls      CC                  * 0155 35 01          5.

* Sleep until the flag is cleared
Sleep               lda       >DataRdy,PC         * Get the data available flag              * 0157 A6 8D FF 0E    &...
                    lbeq      DataLoop            * Flag reset, so continue the loop         * 015B 10 27 FF 8B    .'..
                    ldx       #1                  * 015F 8E 00 01       ...
                    os9       F$Sleep             * Sleep the remainder of the time slice    * 0162 10 3F 0A       .?.
                    bra       Sleep               * ... until the flag is cleared            * 0165 20 F0           p

SleepRet            puls      CC                  * Restore interrupts                       * 0167 35 01          5.
                    lbra      Echo                * Echo the character to the user           * 0169 16 FF 8C       ...

Exit                clrb                          * Clear the error flag...                  * 016C 5F             _
ErrExit             os9       F$Exit              * ... and exit                             * 016D 10 3F 06       .?.

* Interrupt service handler
Icpt                cmpb      #2                  * 0170 C1 02          A.
                    beq       Exit2               * Exit if signal 2                         * 0172 27 07          '.
                    cmpb      #3                  * 0174 C1 03          A.
                    beq       Return              * Return if signal 3                       * 0176 27 02          '.
                    clr       Flag,U              * Clear the flag...                        * 0178 6F 42          oB
Return              rti                           * ... and exit the interrupt handler       * 017A 3B             ;

Exit2               clrb                          * Clear the error flag...                  * 017B 5F             _
                    os9       F$Exit              * ... and exit                             * 017C 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
