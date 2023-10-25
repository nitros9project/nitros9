                    nam       At
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

cntr_1              rmb       1
digit               rmb       1
U0002               rmb       1
U0003               rmb       1
U0004               rmb       2
Param               rmb       2
RunTime             rmb       5
CurTime             rmb       5
stack               rmb       401
size                equ       .

name                fcs       /At/                * 000D 41 F4          At

Usage               fcc       "Usage is: At YY/MM/DD HH:MM <commandline>" * 000F 55 73 61 67 65 20 69 73 3A 20 41 74 20 59 59 2F 4D 4D 2F 44 44 20 48 48 3A 4D 4D 20 3C 63 6F 6D 6D 61 6E 64 6C 69 6E 65 3E Usage is: At YY/MM/DD HH:MM <commandline>
                    fcb       $0D                 * 0038 0D             .

Sched               fcc       "Event scheduled"   * 0039 45 76 65 6E 74 20 73 63 68 65 64 75 6C 65 64 Event scheduled
                    fcb       $0D                 * 0048 0D             .

Shell               fcc       "Shell"             * 0049 53 68 65 6C 6C Shell
                    fcb       $0D                 * 004E 0D             .

* Signal intercept routine
Icpt                cmpb      #S$Abort            * 004F C1 02          A.
                    lbeq      ErrExit             * Exit with keyboard abort                 * 0051 10 27 00 B3    .'.3
                    cmpb      #S$Intrpt           * 0055 C1 03          A.
                    lbeq      ErrExit             * Exit with keyboard interrupt             * 0057 10 27 00 AD    .'.-
                    rti                           * Ignore all other signals                 * 005B 3B             ;

* at mm/dd/yy hh:mm <command line to exec>
* executes the command line once at the specified date and time

* at 00/00/00 hh:mm <command line to exec>
* executes the command line each day at the specified time

start               pshs      X                   * Save X                                   * 005C 34 10          4.
                    leax      >Icpt,PC            * Point to the intercept handler           * 005E 30 8D FF ED    0..m
                    os9       F$Icpt              * Set up the signal intercept handler      * 0062 10 3F 09       .?.
                    puls      X                   * Restore X                                * 0065 35 10          5.

                    leay      RunTime,U           * Get the time to run                      * 0067 31 48          1H
                    lda       #5                  * Compare 5 bytes (YY/MM/DD HH:MM)         * 0069 86 05          ..
                    sta       cntr_1,U            * Store the counter                        * 006B A7 C4          'D

L006D               lbsr      Parse               * Parse a byte                             * 006D 17 00 9B       ...
                    stb       ,Y+                 * Store it in the run time                 * 0070 E7 A0          g
                    dec       cntr_1,U            * Decrement the counter                    * 0072 6A C4          jD
                    bne       L006D               * Parse the next byte                      * 0074 26 F7          &w

* Treat the remainder of the command line
* as the command line to exec
                    stx       Param,U             * 0076 AF 46          /F

* Write "Event scheduled" to the output path
                    leax      >Sched,PC           * 0078 30 8D FF BD    0..=
                    ldy       #200                * 007C 10 8E 00 C8    ...H
                    lda       #1                  * 0080 86 01          ..
                    os9       I$WritLn            * 0082 10 3F 8C       .?.

ChkTime             leax      CurTime,U           * 0085 30 4D          0M
                    os9       F$Time              * Get the current time                     * 0087 10 3F 15       .?.
                    ldb       #5                  * 008A C6 05          F.
                    leay      RunTime,U           * Get the time to run                      * 008C 31 48          1H
                    lda       0,Y                 * Get the year                             * 008E A6 A4          &$
                    bne       ChkTime2            * Check the date and time if not zero      * 0090 26 0E          &.
                    lda       $01,Y               * Get the month                            * 0092 A6 21          &!
                    bne       ChkTime2            * Check the date and time if not zero      * 0094 26 0A          &.
                    lda       $02,Y               * Get the day                              * 0096 A6 22          &"
                    bne       ChkTime2            * Check the date and time if not zero      * 0098 26 06          &.
                    leay      $03,Y               * Point to the time portion                * 009A 31 23          1#
                    leax      $03,X               * Point to the time portion                * 009C 30 03          0.
                    ldb       #2                  * Compare the hour and minute              * 009E C6 02          F.

* Compare the run time or the run date+time with the current date or current date+time
ChkTime2            lda       ,X+                 * Get a time byte                          * 00A0 A6 80          &.
                    cmpa      ,Y+                 * Do the date/time match?                  * 00A2 A1 A0          !
                    bne       Sleep               * No match, so sleep for a while           * 00A4 26 05          &.
                    decb                          * Decrement the counter                    * 00A6 5A             Z
                    bne       ChkTime2            * Check the next byte                      * 00A7 26 F7          &w
                    bra       DoShell             * It's time, shell the parameter           * 00A9 20 08           .

* Sleep for 60 ticks
Sleep               ldx       #60                 * 00AB 8E 00 3C       ..<
                    os9       F$Sleep             * 00AE 10 3F 0A       .?.
                    bra       ChkTime             * 00B1 20 D2           R

DoShell             ldx       Param,U             * Point to the parameter                   * 00B3 AE 46          .F
                    clrb                          * Clear the counter                        * 00B5 5F             _

* Loop until we find CR in the parameter string
DoShell2            incb                          * Increment the counter                    * 00B6 5C             \
                    lda       ,X+                 * Get the next character                   * 00B7 A6 80          &.
                    cmpa      #13                 * Is it a CR?                              * 00B9 81 0D          ..
                    bne       DoShell2            * No, loop until we find CR                * 00BB 26 F9          &y

                    clra                          * Clear the most significant byte          * 00BD 4F             O
                    tfr       D,Y                 * Size of the parameter area               * 00BE 1F 02          ..
                    leax      >Shell,PC           * Get the address of the module name       * 00C0 30 8D FF 85    0...
                    pshs      U                   * Save U                                   * 00C4 34 40          4@
                    ldu       Param,U             * Point to the parameters to the shell     * 00C6 EE 46          nF
                    lda       #Prgrm+Objct        * Type/Language code                       * 00C8 86 11          ..
                    ldb       #3                  * Set the optional data area to 3 pages    * 00CA C6 03          F.
                    os9       F$Fork              * Fork the shell                           * 00CC 10 3F 03       .?.

                    puls      U                   * Restore U                                * 00CF 35 40          5@
                    lbcs      ErrExit             * Exit on error                            * 00D1 10 25 00 33    .%.3

                    os9       F$Wait              * Wait for shell to exit                   * 00D5 10 3F 04       .?.
                    lbcs      ErrExit             * Exit on error                            * 00D8 10 25 00 2C    .%.,

                    leay      RunTime,U           * Get the time to run                      * 00DC 31 48          1H
                    lda       0,Y                 * Get the year                             * 00DE A6 A4          &$
                    bne       Exit                * It's not zero so exit                    * 00E0 26 25          &%
                    lda       $01,Y               * Get the month                            * 00E2 A6 21          &!
                    bne       Exit                * It's not zero so exit                    * 00E4 26 21          &!
                    lda       $02,Y               * Get the day                              * 00E6 A6 22          &"
                    bne       Exit                * It's not zero so exit                    * 00E8 26 1D          &.

                    leax      CurTime,U           * 00EA 30 4D          0M
                    os9       F$Time              * Get the current time                     * 00EC 10 3F 15       .?.
                    lda       $04,X               * Get the minute                           * 00EF A6 04          &.
                    sta       U0002,U             * Store it in the data area                * 00F1 A7 42          'B

Wait                ldx       #60                 * 00F3 8E 00 3C       ..<
                    os9       F$Sleep             * Sleep for 60 ticks                       * 00F6 10 3F 0A       .?.
                    leax      CurTime,U           * 00F9 30 4D          0M
                    os9       F$Time              * Get the current time                     * 00FB 10 3F 15       .?.
                    lda       $04,X               * 00FE A6 04          &.
                    cmpa      U0002,U             * Have we slept enough?                    * 0100 A1 42          !B
                    beq       Wait                * No, sleep some more                      * 0102 27 EF          'o
                    lbra      ChkTime             * Check the time again                     * 0104 16 FF 7E       ..~

Exit                clrb                          * Clear the error flag...                  * 0107 5F             _
ErrExit             os9       F$Exit              * ... and exit                             * 0108 10 3F 06       .?.

* Y = U0008
* A = 5
* U0000 = 5
Parse               pshs      Y                   * Save Y                                   * 010B 34 20          4

* Find the first character in the date/time string
FindDate            lda       ,X+                 * Get the next character                   * 010D A6 80          &.
                    cmpa      #13                 * Is it a CR?                              * 010F 81 0D          ..
                    lbeq      ShowHelp            * Yes, invalid command line parameters     * 0111 10 27 00 AD    .'.-
                    cmpa      #48                 * Is it less than '0'?                     * 0115 81 30          .0
                    bcs       FindDate            * Yes, skip this character                 * 0117 25 F4          %t
                    cmpa      #57                 * Is it greater than '9'?                  * 0119 81 39          .9
                    bhi       FindDate            * Yes, skip this character                 * 011B 22 F0          "p
                    leax      -$01,X              * Back to the start of the date/time string * 011D 30 1F          0.

* Find the last digit of the year
Loop                lda       ,X+                 * Get the character at X                   * 011F A6 80          &.
                    cmpa      #48                 * Is it less than '0'?                     * 0121 81 30          .0
                    bcs       L012B               * Yes, jump                                * 0123 25 06          %.
                    cmpa      #57                 * Is it greater than '9'?                  * 0125 81 39          .9
                    bhi       L012B               * Yes, jump                                * 0127 22 02          ".
                    bra       Loop                * Repeat for the next character            * 0129 20 F4           t

L012B               pshs      X                   * Save X                                   * 012B 34 10          4.
                    leax      -$01,X              * Back up to the last digit                * 012D 30 1F          0.
                    clr       U0002,U             * 012F 6F 42          oB
                    clr       U0003,U             * 0131 6F 43          oC
                    ldd       #1                  * 0133 CC 00 01       L..
                    std       U0004,U             * 0136 ED 44          mD

PrsNum              lda       ,-X                 * Get a digit                              * 0138 A6 82          &.
                    cmpa      #48                 * Is it less than '0'?                     * 013A 81 30          .0
                    bcs       Return              * Yes, invalid digit                       * 013C 25 2E          %.
                    cmpa      #57                 * Is it greater than '9'?                  * 013E 81 39          .9
                    bhi       Return              * Yes, invalid digit                       * 0140 22 2A          "*

                    suba      #48                 * Convert it to a number                   * 0142 80 30          .0
                    sta       digit,U             * Store the number                         * 0144 A7 41          'A
                    ldd       #0                  * Clear D                                  * 0146 CC 00 00       L..

* Convert nn to a binary number
L0149               tst       digit,U             * Is the digit zero?                       * 0149 6D 41          mA
                    beq       L0153               * Yes, don't do the math                   * 014B 27 06          '.
                    addd      U0004,U             * Add 1                                    * 014D E3 44          cD
                    dec       digit,U             * Decrement the digit                      * 014F 6A 41          jA
                    bra       L0149               * And round again                          * 0151 20 F6           v

L0153               addd      U0002,U             * 0153 E3 42          cB
                    std       U0002,U             * 0155 ED 42          mB
                    lda       #10                 * 0157 86 0A          ..
                    sta       digit,U             * 0159 A7 41          'A
                    ldd       #0                  * 015B CC 00 00       L..

L015E               tst       digit,U             * Have we reached zero?                    * 015E 6D 41          mA
                    beq       L0168               * Yes, jump out of the loop                * 0160 27 06          '.
                    addd      U0004,U             * Add 10 to D                              * 0162 E3 44          cD
                    dec       digit,U             * Decrement the digit                      * 0164 6A 41          jA
                    bra       L015E               * And round again                          * 0166 20 F6           v

L0168               std       U0004,U             * Store the translated number              * 0168 ED 44          mD
                    bra       PrsNum              * Back to the top                          * 016A 20 CC           L

Return              ldd       U0002,U             * 016C EC 42          lB
                    puls      X                   * Restore X                                * 016E 35 10          5.
                    puls      PC,Y                * Restore Y and return                     * 0170 35 A0          5

* I can't find any code paths that reach here
unused              std       U0002,U             * 0172 ED 42          mB
                    lda       #48                 * 0174 86 30          .0
                    sta       0,X                 * 0176 A7 84          '.
                    sta       $01,X               * 0178 A7 01          '.
                    sta       $02,X               * 017A A7 02          '.
                    sta       $03,X               * 017C A7 03          '.
                    sta       $04,X               * 017E A7 04          '.
                    ldd       #10000              * 0180 CC 27 10       L'.
                    std       U0004,U             * 0183 ED 44          mD
                    ldd       U0002,U             * 0185 EC 42          lB
                    lbsr      unused_1            * 0187 17 00 29       ..)
                    ldd       #1000               * 018A CC 03 E8       L.h
                    std       U0004,U             * 018D ED 44          mD
                    ldd       U0002,U             * 018F EC 42          lB
                    bsr       unused_1            * 0191 8D 20          .
                    ldd       #100                * 0193 CC 00 64       L.d
                    std       U0004,U             * 0196 ED 44          mD
                    ldd       U0002,U             * 0198 EC 42          lB
                    bsr       unused_1            * 019A 8D 17          ..
                    ldd       #10                 * 019C CC 00 0A       L..
                    std       U0004,U             * 019F ED 44          mD
                    ldd       U0002,U             * 01A1 EC 42          lB
                    bsr       unused_1            * 01A3 8D 0E          ..
                    ldd       #1                  * 01A5 CC 00 01       L..
                    std       U0004,U             * 01A8 ED 44          mD
                    ldd       U0002,U             * 01AA EC 42          lB
                    bsr       unused_1            * 01AC 8D 05          ..
                    lda       #13                 * 01AE 86 0D          ..
                    sta       0,X                 * 01B0 A7 84          '.
                    rts                           * 01B2 39             9

unused_1            subd      U0004,U             * 01B3 A3 44          #D
                    bcs       unused_2            * 01B5 25 04          %.
                    inc       0,X                 * 01B7 6C 84          l.
                    bra       unused_1            * 01B9 20 F8           x

unused_2            addd      U0004,U             * 01BB E3 44          cD
                    std       U0002,U             * 01BD ED 42          mB
                    leax      $01,X               * 01BF 30 01          0.
                    rts                           * 01C1 39             9

* Print the usage syntax and exit
ShowHelp            leax      >Usage,PC           * 01C2 30 8D FE 49    0.~I
                    ldy       #200                * 01C6 10 8E 00 C8    ...H
                    lda       #1                  * 01CA 86 01          ..
                    os9       I$WritLn            * 01CC 10 3F 8C       .?.
                    clrb                          * 01CF 5F             _
                    os9       F$Exit              * 01D0 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
