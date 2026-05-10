                    nam       c.asm
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,_cstart,size

U0000               rmb       1
U0001               rmb       1
U0002               rmb       1
U0003               rmb       2
U0005               rmb       2
Y0007               rmb       2
Y0009               rmb       2
Y000B               rmb       2
Y000D               rmb       2
Y000F               rmb       2
Y0011               rmb       2
Y0013               rmb       2
U0015               rmb       2
U0017               rmb       2
U0019               rmb       2
U001B               rmb       2
U001D               rmb       2
U001F               rmb       2
U0021               rmb       2
U0023               rmb       2
U0025               rmb       2
U0027               rmb       2
U0029               rmb       2
U002B               rmb       2
U002D               rmb       2
U002F               rmb       2
U0031               rmb       1
U0032               rmb       1
U0033               rmb       2
U0035               rmb       2
U0037               rmb       2
U0039               rmb       4
U003D               rmb       2
U003F               rmb       2
U0041               rmb       2
U0043               rmb       2
U0045               rmb       2
U0047               rmb       2
Y0049               rmb       2
U004B               rmb       2
U004D               rmb       2
U004F               rmb       2
reldt               rmb       2
U0053               rmb       2
U0055               rmb       2
Y0057               rmb       2
Y0059               rmb       2
U005B               rmb       1
U005C               rmb       1
U005D               rmb       1
U005E               rmb       1
U005F               rmb       1
U0060               rmb       1
U0061               rmb       1
U0062               rmb       2
U0064               rmb       2
U0066               rmb       2
U0068               rmb       2
U006A               rmb       2
U006C               rmb       2
U006E               rmb       2
U0070               rmb       2
U0072               rmb       2
U0074               rmb       2
U0076               rmb       2
U0078               rmb       2
U007A               rmb       2
U007C               rmb       1
U007D               rmb       7
U0084               rmb       12
U0090               rmb       1
U0091               rmb       7
U0098               rmb       12
U00A4               rmb       1
U00A5               rmb       7
U00AC               rmb       12
U00B8               rmb       1
Y00B9               rmb       1
U00BA               rmb       1
U00BB               rmb       2
U00BD               rmb       2
U00BF               rmb       1
U00C0               rmb       1
U00C1               rmb       1
U00C2               rmb       1
U00C3               rmb       1
U00C4               rmb       1
U00C5               rmb       1
U00C6               rmb       1
U00C7               rmb       1
U00C8               rmb       2
U00CA               rmb       2
U00CC               rmb       2
U00CE               rmb       2
U00D0               rmb       2
U00D2               rmb       2
U00D4               rmb       2
U00D6               rmb       2
U00D8               rmb       2
U00DA               rmb       2
U00DC               rmb       2
U00DE               rmb       2
U00E0               rmb       2
U00E2               rmb       2
U00E4               rmb       2
U00E6               rmb       2
dpsiz               rmb       30
Y0106               rmb       16
Y0116               rmb       320
Y0256               rmb       8
Y025E               rmb       28
Y027A               rmb       8
Y0282               rmb       88
Y02DA               rmb       76
Y0326               rmb       12
Y0332               rmb       8
Y033A               rmb       28
Y0356               rmb       4
Y035A               rmb       4
Y035E               rmb       4
Y0362               rmb       30
Y0380               rmb       24
Y0398               rmb       22
Y03AE               rmb       24
Y03C6               rmb       14
Y03D4               rmb       4
Y03D8               rmb       4
Y03DC               rmb       2
Y03DE               rmb       1
Y03DF               rmb       5
Y03E4               rmb       2
Y03E6               rmb       2
Y03E8               rmb       2
Y03EA               rmb       2
Y03EC               rmb       2
Y03EE               rmb       2
Y03F0               rmb       2
Y03F2               rmb       2
Y03F4               rmb       2
Y03F6               rmb       2
Y03F8               rmb       2
Y03FA               rmb       2
Y03FC               rmb       128
Y047C               rmb       8
Y0484               rmb       2
Y0486               rmb       1
Y0487               rmb       2
_iob                rmb       13
Y0496               rmb       13
Y04A3               rmb       182
argv                rmb       62
_sttop              rmb       2
memend              rmb       2
Y059B               rmb       2
Y059D               rmb       6
_mtop               rmb       2
_stbot              rmb       2
errno               rmb       2
Y05A9               rmb       10
Y05B3               rmb       1
Y05B4               rmb       9
Y05BD               rmb       10
Y05C7               rmb       120
Y063F               rmb       120
Y06B7               rmb       10
Y06C1               rmb       4
Y06C5               rmb       256
Y07C5               rmb       2
Y07C7               rmb       30
Y07E5               rmb       2
Y07E7               rmb       2
Y07E9               rmb       4
Y07ED               rmb       4
Y07F1               rmb       4
Y07F5               rmb       4
Y07F9               rmb       1
Y07FA               rmb       1
Y07FB               rmb       1
Y07FC               rmb       1
Y07FD               rmb       2
Y07FF               rmb       24
Y0817               rmb       62
Y0855               rmb       2
Y0857               rmb       256
Y0957               rmb       80
Y09A7               rmb       2
Y09A9               rmb       10
Y09B3               rmb       10
Y09BD               rmb       2
Y09BF               rmb       2
Y09C1               rmb       1
Y09C2               rmb       2
Y09C4               rmb       2
end                 rmb       1
U09C7               rmb       3967
size                equ       .

name                fcs       /c.asm/             * 000D 63 2E 61 73 ED c.asm
                    fcb       $04                 * 0012 04             .

*
* move bytes (Y=From addr, U=To addr, X=Count)
*
movbytes            lda       ,Y+                 get a byte                               * 0013 A6 A0          &
                    sta       ,U+                 put a byte                               * 0015 A7 C0          '@
                    leax      -1,X                dec the count                            * 0017 30 1F          0.
                    bne       movbytes            and round again                          * 0019 26 F8          &x
                    rts                           * 001B 39             9

_cstart             pshs      Y                   save the to of mem                       * 001C 34 20          4
                    pshs      U                   save the data beginning address          * 001E 34 40          4@

                    clra                          setup to clear                           * 0020 4F             O
                    clrb                          256 bytes                                * 0021 5F             _
csta05              sta       ,U+                 clear dp bytes                           * 0022 A7 C0          '@
                    decb                          * 0024 5A             Z
                    bne       csta05              * 0025 26 FB          &{

csta10              ldx       ,S                  get the beginning of data address        * 0027 AE E4          .d
                    leau      ,X                  (tfr x,u)                                * 0029 33 84          3.
                    leax      >2502,X             get the end of bss address               * 002B 30 89 09 C6    0..F
                    pshs      X                   save it                                  * 002F 34 10          4.
                    leay      >etext,PC           point to dp-data count word              * 0031 31 8D 49 E7    1.Ig

                    ldx       ,Y++                get count of dp-data to be moved         * 0035 AE A1          .!
                    beq       csta15              bra if none                              * 0037 27 04          '.
                    bsr       movbytes            move dp data into position               * 0039 8D D8          .X

                    ldu       2,S                 get beginning address again              * 003B EE 62          nb
csta15              leau      >232,U              point to where non-dp should start       * 003D 33 C9 00 E8    3I.h
                    ldx       ,Y++                get count of non-dp data to be moved     * 0041 AE A1          .!
                    beq       clrbss              * 0043 27 03          '.
                    bsr       movbytes            move non-dp data into position           * 0045 8D CC          .L

* clear the bss area - starts where
* the transferred data finished
                    clra                          * 0047 4F             O
clrbss              cmpu      ,S                  reached the end?                         * 0048 11 A3 E4       .#d
                    beq       L0051               bra if so                                * 004B 27 04          '.
                    sta       ,U+                 clear it                                 * 004D A7 C0          '@
                    bra       clrbss              * 004F 20 F7           w

* now replace the data-text references
L0051               ldu       2,S                 store to data bottom                     * 0051 EE 62          nb
                    ldd       ,Y++                get data-text ref. count                 * 0053 EC A1          l!
                    beq       reldd               * 0055 27 07          '.
                    leax      >U0000,PC           point to text                            * 0057 30 8D FF A5    0..%
                    lbsr      patch               patch them                               * 005B 17 01 03       ...

* and the data-data refs.
reldd               ldd       ,Y++                get the count of data refs.              * 005E EC A1          l!
                    beq       restack             bra if none                              * 0060 27 05          '.
                    leax      ,U                  u was already pointing there             * 0062 30 C4          0D
                    lbsr      patch               * 0064 17 00 FA       ..z

restack             leas      4,S                 reset stack                              * 0067 32 64          2d
                    puls      X                   restore 'memend'                         * 0069 35 10          5.
                    stx       >1433,U             * 006B AF C9 05 99    /I..

* process the params
* the stack pointer is back where it started so is
* pointing at the params
*
* the objective is to insert null chars at the end of each argument
* and fill in the argv vector with pointers to them

* first store the program name address
* (an extra name is inserted here for just this purpose
* - undocumented as yet)
                    sty       >1369,U             * 006F 10 AF C9 05 59 ./I.Y

                    ldd       #1                  at least one arg                         * 0074 CC 00 01       L..
                    std       >1429,U             * 0077 ED C9 05 95    mI..
                    leay      >1371,U             point y at second slot                   * 007B 31 C9 05 5B    1I.[
                    leax      ,S                  point x at params                        * 007F 30 E4          0d
                    lda       ,X+                 initialize                               * 0081 A6 80          &.

aloop               ldb       >1430,U             * 0083 E6 C9 05 96    fI..
                    cmpb      #29                 about to overflow?                       * 0087 C1 1D          A.
                    beq       final               * 0089 27 54          'T
aloop10             cmpa      #13                 is it EOL?                               * 008B 81 0D          ..
                    beq       final               yes - reached the end of the list        * 008D 27 50          'P

                    cmpa      #32                 is it a space?                           * 008F 81 20          .
                    beq       aloop20             yes - try another                        * 0091 27 04          '.
                    cmpa      #44                 is it a comma?                           * 0093 81 2C          .,
                    bne       aloop30             no - a word has started                  * 0095 26 04          &.
aloop20             lda       ,X+                 yes - bump                               * 0097 A6 80          &.
                    bra       aloop10             and round again                          * 0099 20 F0           p

aloop30             cmpa      #34                 quoted string?                           * 009B 81 22          ."
                    beq       aloop40             yes                                      * 009D 27 04          '.
                    cmpa      #39                 the other one?                           * 009F 81 27          .'
                    bne       aloop60             no - ordinary                            * 00A1 26 1E          &.

aloop40             stx       ,Y++                save address in vector                   * 00A3 AF A1          /!
                    inc       >1430,U             bump the arg count                       * 00A5 6C C9 05 96    lI..
                    pshs      A                   save delimiter                           * 00A9 34 02          4.

qloop               lda       ,X+                 get another                              * 00AB A6 80          &.
                    cmpa      #13                 eol?                                     * 00AD 81 0D          ..
                    beq       aloop50             * 00AF 27 04          '.
                    cmpa      ,S                  delimiter?                               * 00B1 A1 E4          !d
                    bne       qloop               * 00B3 26 F6          &v

aloop50             puls      B                   clean stack                              * 00B5 35 04          5.
                    clr       -1,X                * 00B7 6F 1F          o.
                    cmpa      #13                 * 00B9 81 0D          ..
                    beq       final               * 00BB 27 22          '"
                    lda       ,X+                 * 00BD A6 80          &.
                    bra       aloop               * 00BF 20 C2           B

aloop60             leax      -1,X                point at first char                      * 00C1 30 1F          0.
                    stx       ,Y++                put address in vector                    * 00C3 AF A1          /!
                    leax      1,X                 bump it back                             * 00C5 30 01          0.
                    inc       >1430,U             bump the arg count                       * 00C7 6C C9 05 96    lI..

* at least one non-space char has been seen
aloop70             cmpa      #13                 have                                     * 00CB 81 0D          ..
                    beq       loopend             we                                       * 00CD 27 0C          '.
                    cmpa      #32                 reached                                  * 00CF 81 20          .
                    beq       loopend             the end?                                 * 00D1 27 08          '.
                    cmpa      #44                 comma?                                   * 00D3 81 2C          .,
                    beq       loopend             * 00D5 27 04          '.
                    lda       ,X+                 no - look further                        * 00D7 A6 80          &.
                    bra       aloop70             * 00D9 20 F0           p

loopend             clr       -1,X                yes - put in the null byte               * 00DB 6F 1F          o.
                    bra       aloop               and look for the next word               * 00DD 20 A4           $

* now put the pointers on the stack
final               leax      >1369,U             get the address of the arg vector        * 00DF 30 C9 05 59    0I.Y
                    pshs      X                   goes on the stack first                  * 00E3 34 10          4.
                    ldd       >1429,U             get the arg count                        * 00E5 EC C9 05 95    lI..
                    pshs      D                   stack it                                 * 00E9 34 06          4.
                    leay      ,U                  C progs. assume data & bss offset from y * 00EB 31 C4          1D

                    bsr       _fixtop             set various variables                    * 00ED 8D 0A          ..

                    lbsr      main                call the program                         * 00EF 17 00 89       ...

                    clr       ,-S                 put a zero                               * 00F2 6F E2          ob
                    clr       ,-S                 on the stack                             * 00F4 6F E2          ob
                    lbsr      exit                and a dummy 'return address'             * 00F6 17 49 17       .I.

* no return here
_fixtop             leax      >end,Y              get the initial memory end address       * 00F9 30 A9 09 C6    0).F
                    stx       >_mtop,Y            it's the current memory top              * 00FD AF A9 05 A3    /).#
                    sts       >_sttop,Y           this is really two bytes short!          * 0101 10 EF A9 05 97 .o)..
                    sts       >_stbot,Y           * 0106 10 EF A9 05 A5 .o).%
                    ldd       #-126               give ourselves some breathing space      * 010B CC FF 82       L..

* on entry here, d holds the negative of a stack reservation request
_stkcheck           leax      D,S                 calculate the requested size             * 010E 30 EB          0k
                    cmpx      >_stbot,Y           is it lower than already reserved?       * 0110 AC A9 05 A5    ,).%
                    bcc       stk10               no - return                              * 0114 24 0A          $.
                    cmpx      >_mtop,Y            yes - is it lower than possible?         * 0116 AC A9 05 A3    ,).#
                    bcs       fsterr              yes - can't cope                         * 011A 25 1E          %.
                    stx       >_stbot,Y           no - reserve it                          * 011C AF A9 05 A5    /).%
stk10               rts                           and return                               * 0120 39             9

fixserr             fcc       "**** STACK OVERFLOW ****" * 0121 2A 2A 2A 2A 20 53 54 41 43 4B 20 4F 56 45 52 46 4C 4F 57 20 2A 2A 2A 2A **** STACK OVERFLOW ****
                    fcb       $0D                 * 0139 0D             .

fsterr              leax      <fixserr,PC         address of error string                  * 013A 30 8C E4       0.d
                    ldb       #E$MemFul           MEMORY FULL error number                 * 013D C6 CF          FO

erexit              pshs      B                   stack the error number                   * 013F 34 04          4.
                    lda       #2                  standard error output                    * 0141 86 02          ..
                    ldy       #100                more than necessary                      * 0143 10 8E 00 64    ...d
                    os9       I$WritLn            write it                                 * 0147 10 3F 8C       .?.
                    clr       ,-S                 clear MSB of status                      * 014A 6F E2          ob
                    lbsr      _exit               and out                                  * 014C 17 48 C7       .HG
* no return here

* stacksize()
* the extent of stack requested
* can be used by programmer for guidance
* in sizing memory at compile time
stacksiz            ldd       >_sttop,Y           top of stack on entry                    * 014F EC A9 05 97    l)..
                    subd      >_stbot,Y           subtract current reserved limit          * 0153 A3 A9 05 A5    #).%
                    rts                           * 0157 39             9

* freemem()
* returns the current size of the free memory area
freemem             ldd       >_stbot,Y           * 0158 EC A9 05 A5    l).%
                    subd      >_mtop,Y            * 015C A3 A9 05 A3    #).#
                    rts                           * 0160 39             9

* patch - adjust initialized data which refer to memory locations.
* entry:
*       y -> list of offsets in the data area to be patched
*       u -> base of data
*       x -> base of either text or data area as appropriate
*       d =  count of offsets in the list
*
* exit:
*       u - unchanged
*       y - past the last entry in the list
*       x and d mangled

patch               pshs      X                   save the base                            * 0161 34 10          4.
                    leax      D,Y                 half way up the list                     * 0163 30 AB          0+
                    leax      D,X                 top of list                              * 0165 30 8B          0.
                    pshs      X                   save it as place to stop                 * 0167 34 10          4.

* we do not come to this routine with
* a zero count (check!) so a test at the loop top
* is unnecessary
patch10             ldd       ,Y++                get the offset                           * 0169 EC A1          l!
                    leax      D,U                 point to location                        * 016B 30 CB          0K
                    ldd       ,X                  get the relative reference               * 016D EC 84          l.
                    addd      2,S                 add in the base                          * 016F E3 62          cb
                    std       ,X                  store the absolute reference             * 0171 ED 84          m.
                    cmpy      ,S                  reached the top?                         * 0173 10 AC E4       .,d
                    bne       patch10             no - round again                         * 0176 26 F1          &q

                    leas      4,S                 reset the stack                          * 0178 32 64          2d
                    rts                           and return                               * 017A 39             9

main                pshs      U,D                 * 017B 34 46          4F
                    ldd       8,S                 * 017D EC 68          lh
                    pshs      D                   * 017F 34 06          4.
                    ldd       8,S                 * 0181 EC 68          lh
                    pshs      D                   * 0183 34 06          4.
                    lbsr      L2893               * 0185 17 27 0B       .'.
                    leas      4,S                 * 0188 32 64          2d
                    ldb       <U00C3              * 018A D6 C3          VC
                    beq       L0193               * 018C 27 05          '.
                    ldd       #1                  * 018E CC 00 01       L..
                    stb       <U00C4              * 0191 D7 C4          WD
L0193               ldd       #4                  * 0193 CC 00 04       L..
                    stb       <U007C              * 0196 D7 7C          W|
                    ldd       #3                  * 0198 CC 00 03       L..
                    stb       <U0090              * 019B D7 90          W.
                    ldd       #1                  * 019D CC 00 01       L..
                    stb       <U00A4              * 01A0 D7 A4          W$
                    ldd       #2                  * 01A2 CC 00 02       L..
                    stb       <U00A5              * 01A5 D7 A5          W%
                    stb       <U0091              * 01A7 D7 91          W.
                    stb       <U007D              * 01A9 D7 7D          W}
                    ldb       <U00C6              * 01AB D6 C6          VF
                    beq       L01C2               * 01AD 27 13          '.
                    leax      >L07AD,PC           * 01AF 30 8D 05 FA    0..z
                    pshs      X                   * 01B3 34 10          4.
                    ldd       >Y03F8,Y            * 01B5 EC A9 03 F8    l).x
                    pshs      D                   * 01B9 34 06          4.
                    lbsr      L2955               * 01BB 17 27 97       .'.
                    leas      4,S                 * 01BE 32 64          2d
                    std       <U0017              * 01C0 DD 17          ].
L01C2               leax      >Y0817,Y            * 01C2 30 A9 08 17    0)..
                    stx       ,S                  * 01C6 AF E4          /d
                    lbra      L0230               * 01C8 16 00 65       ..e
L01CB               leax      >L07AF,PC           * 01CB 30 8D 05 E0    0..`
                    pshs      X                   * 01CF 34 10          4.
                    ldd       [<$02,S]            * 01D1 EC F8 02       lx.
                    pshs      D                   * 01D4 34 06          4.
                    lbsr      L2955               * 01D6 17 27 7C       .'|
                    leas      4,S                 * 01D9 32 64          2d
                    std       <U0015              * 01DB DD 15          ].
                    clra                          * 01DD 4F             O
                    clrb                          * 01DE 5F             _
                    stb       >Y063F,Y            * 01DF E7 A9 06 3F    g).?
                    stb       >Y05C7,Y            * 01E3 E7 A9 05 C7    g).G
                    clra                          * 01E7 4F             O
                    clrb                          * 01E8 5F             _
                    std       <U00AC              * 01E9 DD AC          ],
                    std       <U0098              * 01EB DD 98          ].
                    std       <U0084              * 01ED DD 84          ].
                    clra                          * 01EF 4F             O
                    clrb                          * 01F0 5F             _
                    stb       <U005B              * 01F1 D7 5B          W[
                    lbsr      L0252               * 01F3 17 00 5C       ..\
                    ldd       <U0015              * 01F6 DC 15          \.
                    pshs      D                   * 01F8 34 06          4.
                    lbsr      L4042               * 01FA 17 3E 45       .>E
                    leas      2,S                 * 01FD 32 62          2b
                    ldd       #1                  * 01FF CC 00 01       L..
                    stb       <U005B              * 0202 D7 5B          W[
                    bsr       L0252               * 0204 8D 4C          .L
                    lbsr      L2DB3               * 0206 17 2B AA       .+*
                    lbsr      L2F35               * 0209 17 2D 29       .-)
                    ldd       <U0015              * 020C DC 15          \.
                    pshs      D                   * 020E 34 06          4.
                    lbsr      fclose              * 0210 17 3F 9F       .?.
                    std       ,S++                * 0213 ED E1          ma
                    beq       L0222               * 0215 27 0B          '.
                    leax      >L07B1,PC           * 0217 30 8D 05 96    0...
                    pshs      X                   * 021B 34 10          4.
                    lbsr      L074E               * 021D 17 05 2E       ...
                    leas      2,S                 * 0220 32 62          2b
L0222               ldb       <U00C7              * 0222 D6 C7          VG
                    ble       L0229               * 0224 2F 03          /.
                    lbsr      L2B29               * 0226 17 29 00       .).
L0229               ldd       ,S                  * 0229 EC E4          ld
                    addd      #2                  * 022B C3 00 02       C..
                    std       ,S                  * 022E ED E4          md
L0230               ldd       ,S                  * 0230 EC E4          ld
                    cmpd      >Y03F6,Y            * 0232 10 A3 A9 03 F6 .#).v
                    lbcs      L01CB               * 0237 10 25 FF 90    .%..
                    lbsr      L36FE               * 023B 17 34 C0       .4@
                    ldd       <U0023              * 023E DC 23          \#
                    beq       L0247               * 0240 27 05          '.
                    ldd       #1                  * 0242 CC 00 01       L..
                    bra       L0249               * 0245 20 02           .
L0247               clra                          * 0247 4F             O
                    clrb                          * 0248 5F             _
L0249               pshs      D                   * 0249 34 06          4.
                    lbsr      exit                * 024B 17 47 C2       .GB
                    leas      2,S                 * 024E 32 62          2b
                    puls      PC,U,X              * 0250 35 D0          5P
L0252               pshs      U                   * 0252 34 40          4@
                    leas      -1,S                * 0254 32 7F          2.
                    lbsr      L1C72               * 0256 17 1A 19       ...
                    clra                          * 0259 4F             O
                    clrb                          * 025A 5F             _
                    std       <U0025              * 025B DD 25          ]%
                    std       <U0023              * 025D DD 23          ]#
                    leax      >Y06C5,Y            * 025F 30 A9 06 C5    0).E
                    stx       <U0076              * 0263 9F 76          .v
                    clra                          * 0265 4F             O
                    clrb                          * 0266 5F             _
                    std       <U00D8              * 0267 DD D8          ]X
                    clra                          * 0269 4F             O
                    clrb                          * 026A 5F             _
                    std       <U00C8              * 026B DD C8          ]H
                    std       <U002D              * 026D DD 2D          ]-
                    std       <U002F              * 026F DD 2F          ]/
                    std       <U0027              * 0271 DD 27          ]'
                    std       <U002B              * 0273 DD 2B          ]+
                    std       <U0029              * 0275 DD 29          ])
                    ldb       <U005B              * 0277 D6 5B          V[
                    beq       L0288               * 0279 27 0D          '.
                    ldb       <U00C4              * 027B D6 C4          VD
                    beq       L0288               * 027D 27 09          '.
                    ldb       <U00C3              * 027F D6 C3          VC
                    ble       L0288               * 0281 2F 05          /.
                    ldd       #1                  * 0283 CC 00 01       L..
                    bra       L028A               * 0286 20 02           .
L0288               clra                          * 0288 4F             O
                    clrb                          * 0289 5F             _
L028A               std       <U003D              * 028A DD 3D          ]=
                    lbsr      L298C               * 028C 17 26 FD       .&}
                    bra       L029E               * 028F 20 0D           .
L0291               bsr       L02A9               * 0291 8D 16          ..
                    std       -2,S                * 0293 ED 7E          m~
                    beq       L029B               * 0295 27 04          '.
                    ldd       <U0062              * 0297 DC 62          \b
                    std       <U006C              * 0299 DD 6C          ]l
L029B               lbsr      L05C5               * 029B 17 03 27       ..'
L029E               lbsr      L2A7F               * 029E 17 27 DE       .'^
                    std       -2,S                * 02A1 ED 7E          m~
                    bne       L0291               * 02A3 26 EC          &l
                    leas      1,S                 * 02A5 32 61          2a
                    puls      PC,U                * 02A7 35 C0          5@
L02A9               pshs      U                   * 02A9 34 40          4@
                    leas      -3,S                * 02AB 32 7D          2}
                    clra                          * 02AD 4F             O
                    clrb                          * 02AE 5F             _
                    std       <U00BD              * 02AF DD BD          ]=
                    std       <U0039              * 02B1 DD 39          ]9
                    std       <U0037              * 02B3 DD 37          ]7
                    std       <U0021              * 02B5 DD 21          ]!
                    std       <U001D              * 02B7 DD 1D          ].
                    std       <U0033              * 02B9 DD 33          ]3
                    std       <U001B              * 02BB DD 1B          ].
                    ldd       <U004B              * 02BD DC 4B          \K
                    std       <U004F              * 02BF DD 4F          ]O
                    beq       L02CF               * 02C1 27 0C          '.
                    leax      >reldt,Y            * 02C3 30 A9 00 51    0).Q
                    stx       <U004F              * 02C7 9F 4F          .O
                    ldd       [>U004B,Y]          * 02C9 EC B9 00 4B    l9.K
                    std       ,X                  * 02CD ED 84          m.
L02CF               clra                          * 02CF 4F             O
                    clrb                          * 02D0 5F             _
                    std       <U00CA              * 02D1 DD CA          ]J
                    std       <U006C              * 02D3 DD 6C          ]l
                    std       <U006A              * 02D5 DD 6A          ]j
                    std       <U0066              * 02D7 DD 66          ]f
                    std       <U0064              * 02D9 DD 64          ]d
                    ldb       <U005C              * 02DB D6 5C          V\
                    stb       <U005D              * 02DD D7 5D          W]
                    ldb       <U005E              * 02DF D6 5E          V^
                    stb       <U005F              * 02E1 D7 5F          W_
                    ldb       <U0060              * 02E3 D6 60          V`
                    stb       <U0061              * 02E5 D7 61          Wa
                    leax      >Y07C7,Y            * 02E7 30 A9 07 C7    0).G
                    stx       >Y07E5,Y            * 02EB AF A9 07 E5    /).e
                    ldb       <U005B              * 02EF D6 5B          V[
                    beq       L0300               * 02F1 27 0D          '.
                    ldb       <U00C4              * 02F3 D6 C4          VD
                    beq       L0300               * 02F5 27 09          '.
                    ldb       <U00C3              * 02F7 D6 C3          VC
                    ble       L0300               * 02F9 2F 05          /.
                    ldd       #1                  * 02FB CC 00 01       L..
                    bra       L0302               * 02FE 20 02           .
L0300               clra                          * 0300 4F             O
                    clrb                          * 0301 5F             _
L0302               std       <U003D              * 0302 DD 3D          ]=
                    clra                          * 0304 4F             O
                    clrb                          * 0305 5F             _
                    std       <U00D6              * 0306 DD D6          ]V
                    ldd       <U00CE              * 0308 DC CE          \N
                    beq       L0310               * 030A 27 04          '.
                    ldb       <U0002              * 030C D6 02          V.
                    ble       L0318               * 030E 2F 08          /.
L0310               ldd       <U002B              * 0310 DC 2B          \+
                    beq       L031C               * 0312 27 08          '.
                    ldb       <U00BF              * 0314 D6 BF          V?
                    bgt       L031C               * 0316 2E 04          ..
L0318               clra                          * 0318 4F             O
                    clrb                          * 0319 5F             _
                    std       <U003D              * 031A DD 3D          ]=
L031C               ldb       [>U0062,Y]          * 031C E6 B9 00 62    f9.b
                    stb       2,S                 * 0320 E7 62          gb
                    lbeq      L05AD               * 0322 10 27 02 87    .'..
                    ldb       2,S                 * 0326 E6 62          fb
                    cmpb      #42                 * 0328 C1 2A          A*
                    lbeq      L05AD               * 032A 10 27 02 7F    .'..
                    ldb       2,S                 * 032E E6 62          fb
                    cmpb      #32                 * 0330 C1 20          A
                    beq       L037B               * 0332 27 47          'G
                    ldd       <U0062              * 0334 DC 62          \b
                    std       <U0064              * 0336 DD 64          ]d
                    ldd       <U00CC              * 0338 DC CC          \L
                    bne       L0361               * 033A 26 25          &%
                    ldd       <U002B              * 033C DC 2B          \+
                    bne       L0361               * 033E 26 21          &!
                    ldd       <U00D2              * 0340 DC D2          \R
                    bne       L0361               * 0342 26 1D          &.
                    lbsr      L1E7F               * 0344 17 1B 38       ..8
                    std       -2,S                * 0347 ED 7E          m~
                    bne       L0369               * 0349 26 1E          &.
                    leax      >L07C2,PC           * 034B 30 8D 04 73    0..s
                    lbra      L05BA               * 034F 16 02 68       ..h

                    bra       L0369               * 0352 20 15           .

L0354               ldb       2,S                 * 0354 E6 62          fb
                    cmpb      #32                 * 0356 C1 20          A
                    beq       L0369               * 0358 27 0F          '.
                    ldd       <U0062              * 035A DC 62          \b
                    addd      #1                  * 035C C3 00 01       C..
                    std       <U0062              * 035F DD 62          ]b
L0361               ldb       [>U0062,Y]          * 0361 E6 B9 00 62    f9.b
                    stb       2,S                 * 0365 E7 62          gb
                    bne       L0354               * 0367 26 EB          &k
L0369               ldb       [>U0062,Y]          * 0369 E6 B9 00 62    f9.b
                    cmpb      #32                 * 036D C1 20          A
                    bne       L037B               * 036F 26 0A          &.
                    clra                          * 0371 4F             O
                    clrb                          * 0372 5F             _
                    ldx       <U0062              * 0373 9E 62          .b
                    leax      1,X                 * 0375 30 01          0.
                    stx       <U0062              * 0377 9F 62          .b
                    stb       -1,X                * 0379 E7 1F          g.
L037B               lbsr      L2229               * 037B 17 1E AB       ..+
                    stb       2,S                 * 037E E7 62          gb
                    lbeq      L05AD               * 0380 10 27 02 29    .'.)
                    leax      >Y05B3,Y            * 0384 30 A9 05 B3    0).3
                    pshs      X                   * 0388 34 10          4.
                    lbsr      L1E0B               * 038A 17 1A 7E       ..~
                    std       ,S++                * 038D ED E1          ma
                    lbeq      L05B2               * 038F 10 27 02 1F    .'..
                    leax      >Y05B3,Y            * 0393 30 A9 05 B3    0).3
                    stx       <U0066              * 0397 9F 66          .f
                    lbsr      L2229               * 0399 17 1E 8D       ...
                    ldd       <U00D2              * 039C DC D2          \R
                    bne       L03C1               * 039E 26 21          &!
                    leax      >Y05B3,Y            * 03A0 30 A9 05 B3    0).3
                    pshs      X                   * 03A4 34 10          4.
                    lbsr      L3318               * 03A6 17 2F 6F       ./o
                    leas      2,S                 * 03A9 32 62          2b
                    std       ,S                  * 03AB ED E4          md
                    beq       L03C1               * 03AD 27 12          '.
                    ldd       <U00CC              * 03AF DC CC          \L
                    lbne      L048A               * 03B1 10 26 00 D5    .&.U
                    ldd       ,S                  * 03B5 EC E4          ld
                    pshs      D                   * 03B7 34 06          4.
                    lbsr      L3350               * 03B9 17 2F 94       ./.
                    leas      2,S                 * 03BC 32 62          2b
                    lbra      L0424               * 03BE 16 00 63       ..c
L03C1               ldd       >Y0011,Y            * 03C1 EC A9 00 11    l)..
                    pshs      D                   * 03C5 34 06          4.
                    leax      >Y0282,Y            * 03C7 30 A9 02 82    0)..
                    pshs      X                   * 03CB 34 10          4.
                    leax      >Y05B3,Y            * 03CD 30 A9 05 B3    0).3
                    pshs      X                   * 03D1 34 10          4.
                    lbsr      L0874               * 03D3 17 04 9E       ...
                    leas      6,S                 * 03D6 32 66          2f
                    std       <U0070              * 03D8 DD 70          ]p
                    lbeq      L047B               * 03DA 10 27 00 9D    .'..
                    ldx       <U0070              * 03DE 9E 70          .p
                    ldb       3,X                 * 03E0 E6 03          f.
                    clra                          * 03E2 4F             O
                    andb      #15                 * 03E3 C4 0F          D.
                    std       <U001F              * 03E5 DD 1F          ].
                    ldd       <U00D2              * 03E7 DC D2          \R
                    beq       L0401               * 03E9 27 16          '.
                    ldd       <U001F              * 03EB DC 1F          \.
                    lbne      L047F               * 03ED 10 26 00 8E    .&..
                    ldx       <U0070              * 03F1 9E 70          .p
                    ldb       2,X                 * 03F3 E6 02          f.
                    cmpb      #11                 * 03F5 C1 0B          A.
                    lbne      L047F               * 03F7 10 26 00 84    .&..
                    lbsr      L1D19               * 03FB 17 19 1B       ...
                    lbra      L05C1               * 03FE 16 01 C0       ..@
L0401               ldd       <U00CC              * 0401 DC CC          \L
                    beq       L0427               * 0403 27 22          '"
                    ldd       <U001F              * 0405 DC 1F          \.
                    cmpd      #4                  * 0407 10 83 00 04    ....
                    bne       L0413               * 040B 26 06          &.
                    lbsr      L0742               * 040D 17 03 32       ..2
                    lbra      L05C1               * 0410 16 01 AE       ...
L0413               ldd       <U001F              * 0413 DC 1F          \.
                    cmpd      #5                  * 0415 10 83 00 05    ....
                    lbne      L048A               * 0419 10 26 00 6D    .&.m
                    lbsr      L3300               * 041D 17 2E E0       ..`
                    clra                          * 0420 4F             O
                    clrb                          * 0421 5F             _
                    std       <U00CC              * 0422 DD CC          ]L
L0424               lbra      L05AD               * 0424 16 01 86       ...
L0427               ldd       <U002B              * 0427 DC 2B          \+
                    beq       L045C               * 0429 27 31          '1
                    ldd       <U001F              * 042B DC 1F          \.
                    cmpd      #1                  * 042D 10 83 00 01    ....
                    beq       L0452               * 0431 27 1F          '.
                    ldd       <U001F              * 0433 DC 1F          \.
                    cmpd      #2                  * 0435 10 83 00 02    ....
                    lbne      L05AD               * 0439 10 26 01 70    .&.p
                    ldd       <U002B              * 043D DC 2B          \+
                    addd      #-1                 * 043F C3 FF FF       C..
                    std       <U002B              * 0442 DD 2B          ]+
                    ldd       <U002B              * 0444 DC 2B          \+
                    lbeq      L05AD               * 0446 10 27 01 63    .'.c
                    ldx       <U0070              * 044A 9E 70          .p
                    ldb       2,X                 * 044C E6 02          f.
                    lbeq      L05AD               * 044E 10 27 01 5B    .'.[
L0452               ldd       <U002B              * 0452 DC 2B          \+
                    addd      #1                  * 0454 C3 00 01       C..
                    std       <U002B              * 0457 DD 2B          ]+
                    lbra      L05AD               * 0459 16 01 51       ..Q

L045C               ldx       <U0070              * 045C 9E 70          .p
                    ldb       2,X                 * 045E E6 02          f.
                    stb       <Y00B9              * 0460 D7 B9          W9
                    ldd       <U0062              * 0462 DC 62          \b
                    std       <U006A              * 0464 DD 6A          ]j
                    ldd       <U001F              * 0466 DC 1F          \.
                    aslb                          * 0468 58             X
                    rola                          * 0469 49             I
                    leax      >Y0326,Y            * 046A 30 A9 03 26    0).&
                    leax      D,X                 * 046E 30 8B          0.
                    jsr       [,X]                * 0470 AD 94          -.
                    std       -2,S                * 0472 ED 7E          m~
                    lbeq      L0578               * 0474 10 27 01 00    .'..
                    lbra      L0589               * 0478 16 01 0E       ...
L047B               ldd       <U00D2              * 047B DC D2          \R
                    beq       L0486               * 047D 27 07          '.
L047F               clra                          * 047F 4F             O
                    clrb                          * 0480 5F             _
                    std       <U003D              * 0481 DD 3D          ]=
                    lbra      L05AD               * 0483 16 01 27       ..'
L0486               ldd       <U00CC              * 0486 DC CC          \L
                    beq       L0490               * 0488 27 06          '.
L048A               lbsr      L329E               * 048A 17 2E 11       ...
                    lbra      L05AD               * 048D 16 01 1D       ...
L0490               ldd       <U002B              * 0490 DC 2B          \+
                    beq       L04CF               * 0492 27 3B          ';
                    ldd       <U003D              * 0494 DC 3D          \=
                    lbeq      L05AD               * 0496 10 27 01 13    .'..
                    ldb       [>U0062,Y]          * 049A E6 B9 00 62    f9.b
                    lbeq      L05AD               * 049E 10 27 01 0B    .'..
                    ldd       <U0062              * 04A2 DC 62          \b
                    std       <U006A              * 04A4 DD 6A          ]j
                    bra       L04B0               * 04A6 20 08           .
L04A8               ldb       [>U0062,Y]          * 04A8 E6 B9 00 62    f9.b
                    cmpb      #32                 * 04AC C1 20          A
                    beq       L04BA               * 04AE 27 0A          '.
L04B0               ldx       <U0062              * 04B0 9E 62          .b
                    leax      1,X                 * 04B2 30 01          0.
                    stx       <U0062              * 04B4 9F 62          .b
                    ldb       ,X                  * 04B6 E6 84          f.
                    bne       L04A8               * 04B8 26 EE          &n
L04BA               ldb       [>U0062,Y]          * 04BA E6 B9 00 62    f9.b
                    lbeq      L05AD               * 04BE 10 27 00 EB    .'.k
                    clra                          * 04C2 4F             O
                    clrb                          * 04C3 5F             _
                    ldx       <U0062              * 04C4 9E 62          .b
                    leax      1,X                 * 04C6 30 01          0.
                    stx       <U0062              * 04C8 9F 62          .b
                    stb       -1,X                * 04CA E7 1F          g.
                    lbra      L05AD               * 04CC 16 00 DE       ..^
L04CF               leax      >Y0116,Y            * 04CF 30 A9 01 16    0)..
                    cmpx      <U0072              * 04D3 9C 72          .r
                    bne       L0500               * 04D5 26 29          &)
                    ldb       >Y05B3,Y            * 04D7 E6 A9 05 B3    f).3
                    cmpb      #98                 * 04DB C1 62          Ab
                    beq       L04E7               * 04DD 27 08          '.
                    ldb       >Y05B3,Y            * 04DF E6 A9 05 B3    f).3
                    cmpb      #66                 * 04E3 C1 42          AB
                    bne       L0500               * 04E5 26 19          &.
L04E7               ldd       >Y0013,Y            * 04E7 EC A9 00 13    l)..
                    pshs      D                   * 04EB 34 06          4.
                    leax      >Y02DA,Y            * 04ED 30 A9 02 DA    0).Z
                    pshs      X                   * 04F1 34 10          4.
                    leax      >Y05B3,Y            * 04F3 30 A9 05 B3    0).3
                    pshs      X                   * 04F7 34 10          4.
                    lbsr      L0874               * 04F9 17 03 78       ..x
                    leas      6,S                 * 04FC 32 66          2f
                    std       <U0070              * 04FE DD 70          ]p
L0500               ldd       <U0070              * 0500 DC 70          \p
                    bne       L0519               * 0502 26 15          &.
                    ldd       <U0074              * 0504 DC 74          \t
                    pshs      D                   * 0506 34 06          4.
                    ldd       <U0072              * 0508 DC 72          \r
                    pshs      D                   * 050A 34 06          4.
                    leax      >Y05B3,Y            * 050C 30 A9 05 B3    0).3
                    pshs      X                   * 0510 34 10          4.
                    lbsr      L0874               * 0512 17 03 5F       .._
                    leas      6,S                 * 0515 32 66          2f
                    std       <U0070              * 0517 DD 70          ]p
L0519               ldd       <U0070              * 0519 DC 70          \p
                    lbeq      L05B2               * 051B 10 27 00 93    .'..
                    ldx       <U0070              * 051F 9E 70          .p
                    ldb       3,X                 * 0521 E6 03          f.
                    clra                          * 0523 4F             O
                    andb      #15                 * 0524 C4 0F          D.
                    std       <U001F              * 0526 DD 1F          ].
                    ldd       #1                  * 0528 CC 00 01       L..
                    std       <U001B              * 052B DD 1B          ].
                    leax      >Y00B9,Y            * 052D 30 A9 00 B9    0).9
                    stx       <U00CA              * 0531 9F CA          .J
                    ldx       <U0070              * 0533 9E 70          .p
                    ldb       3,X                 * 0535 E6 03          f.
                    clra                          * 0537 4F             O
                    andb      #48                 * 0538 C4 30          D0
                    stb       <U00B8              * 053A D7 B8          W8
                    beq       L055A               * 053C 27 1C          '.
                    ldb       <U00B8              * 053E D6 B8          V8
                    clra                          * 0540 4F             O
                    andb      #16                 * 0541 C4 10          D.
                    beq       L054A               * 0543 27 05          '.
                    ldd       #16                 * 0545 CC 00 10       L..
                    bra       L054D               * 0548 20 03           .
L054A               ldd       #17                 * 054A CC 00 11       L..
L054D               stb       <U00B8              * 054D D7 B8          W8
                    ldd       #2                  * 054F CC 00 02       L..
                    std       <U001B              * 0552 DD 1B          ].
                    leax      >U00B8,Y            * 0554 30 A9 00 B8    0).8
                    stx       <U00CA              * 0558 9F CA          .J
L055A               ldx       <U0070              * 055A 9E 70          .p
                    ldb       2,X                 * 055C E6 02          f.
                    stb       <Y00B9              * 055E D7 B9          W9
                    clra                          * 0560 4F             O
                    clrb                          * 0561 5F             _
                    std       <U00BB              * 0562 DD BB          ];
                    stb       <U00BA              * 0564 D7 BA          W:
                    ldd       <U0062              * 0566 DC 62          \b
                    std       <U006A              * 0568 DD 6A          ]j
                    ldd       <U001F              * 056A DC 1F          \.
                    aslb                          * 056C 58             X
                    rola                          * 056D 49             I
                    ldx       <U006E              * 056E 9E 6E          .n
                    leax      D,X                 * 0570 30 8B          0.
                    jsr       [,X]                * 0572 AD 94          -.
                    std       -2,S                * 0574 ED 7E          m~
                    bne       L057C               * 0576 26 04          &.
L0578               clra                          * 0578 4F             O
                    clrb                          * 0579 5F             _
                    bra       L05C1               * 057A 20 45           E
L057C               ldd       <U001B              * 057C DC 1B          \.
                    pshs      D                   * 057E 34 06          4.
                    ldd       <U00CA              * 0580 DC CA          \J
                    pshs      D                   * 0582 34 06          4.
                    lbsr      L2E3B               * 0584 17 28 B4       .(4
                    leas      4,S                 * 0587 32 64          2d
L0589               ldd       <U006A              * 0589 DC 6A          \j
                    cmpd      <U0062              * 058B 10 93 62       ..b
                    bne       L0596               * 058E 26 06          &.
                    clra                          * 0590 4F             O
                    clrb                          * 0591 5F             _
                    std       <U006A              * 0592 DD 6A          ]j
                    bra       L05AD               * 0594 20 17           .
L0596               ldd       <U006A              * 0596 DC 6A          \j
                    beq       L05AD               * 0598 27 13          '.
                    ldb       [>U0062,Y]          * 059A E6 B9 00 62    f9.b
                    beq       L05AD               * 059E 27 0D          '.
                    clra                          * 05A0 4F             O
                    clrb                          * 05A1 5F             _
                    ldx       <U0062              * 05A2 9E 62          .b
                    leax      1,X                 * 05A4 30 01          0.
                    stx       <U0062              * 05A6 9F 62          .b
                    stb       -1,X                * 05A8 E7 1F          g.
                    lbsr      L2229               * 05AA 17 1C 7C       ..|
L05AD               ldd       #1                  * 05AD CC 00 01       L..
                    bra       L05C1               * 05B0 20 0F           .
L05B2               ldd       <U0062              * 05B2 DC 62          \b
                    std       <U006C              * 05B4 DD 6C          ]l
                    leax      >L07CC,PC           * 05B6 30 8D 02 12    0...
L05BA               pshs      X                   * 05BA 34 10          4.
                    lbsr      L074E               * 05BC 17 01 8F       ...
                    leas      2,S                 * 05BF 32 62          2b
L05C1               leas      3,S                 * 05C1 32 63          2c
                    puls      PC,U                * 05C3 35 C0          5@
L05C5               pshs      U                   * 05C5 34 40          4@
                    ldd       <U003D              * 05C7 DC 3D          \=
                    lbeq      L0787               * 05C9 10 27 01 BA    .'.:
                    ldd       <U0003              * 05CD DC 03          \.
                    addd      #-3                 * 05CF C3 FF FD       C.}
                    cmpd      <U00C8              * 05D2 10 93 C8       ..H
                    bge       L05DA               * 05D5 2C 03          ,.
                    lbsr      L298C               * 05D7 17 23 B2       .#2
L05DA               clra                          * 05DA 4F             O
                    clrb                          * 05DB 5F             _
                    std       <U003D              * 05DC DD 3D          ]=
                    ldb       <U00C5              * 05DE D6 C5          VE
                    bne       L05F1               * 05E0 26 0F          &.
                    ldd       <U002F              * 05E2 DC 2F          \/
                    pshs      D                   * 05E4 34 06          4.
                    leax      >L07D9,PC           * 05E6 30 8D 01 EF    0..o
                    pshs      X                   * 05EA 34 10          4.
                    lbsr      L39FC               * 05EC 17 34 0D       .4.
                    leas      4,S                 * 05EF 32 64          2d
L05F1               ldd       <U0064              * 05F1 DC 64          \d
                    bne       L05FF               * 05F3 26 0A          &.
                    ldd       <U0066              * 05F5 DC 66          \f
                    bne       L05FF               * 05F7 26 06          &.
                    ldd       <U001B              * 05F9 DC 1B          \.
                    lble      L0696               * 05FB 10 2F 00 97    ./..
L05FF               leas      -2,S                * 05FF 32 7E          2~
                    ldu       <U00CA              * 0601 DE CA          ^J
                    ldd       <U004F              * 0603 DC 4F          \O
                    beq       L0618               * 0605 27 11          '.
                    ldd       [>U004F,Y]          * 0607 EC B9 00 4F    l9.O
                    pshs      D                   * 060B 34 06          4.
                    leax      >L07DE,PC           * 060D 30 8D 01 CD    0..M
                    pshs      X                   * 0611 34 10          4.
                    lbsr      L39FC               * 0613 17 33 E6       .3f
                    bra       L0627               * 0616 20 0F           .
L0618               leax      >Y0496,Y            * 0618 30 A9 04 96    0)..
                    pshs      X                   * 061C 34 10          4.
                    leax      >L07E4,PC           * 061E 30 8D 01 C2    0..B
                    pshs      X                   * 0622 34 10          4.
                    lbsr      L3992               * 0624 17 33 6B       .3k
L0627               leas      4,S                 * 0627 32 64          2d
                    leax      >Y0496,Y            * 0629 30 A9 04 96    0)..
                    pshs      X                   * 062D 34 10          4.
                    ldd       <U00BD              * 062F DC BD          \=
                    beq       L0638               * 0631 27 05          '.
                    ldd       #61                 * 0633 CC 00 3D       L.=
                    bra       L063B               * 0636 20 03           .
L0638               ldd       #32                 * 0638 CC 00 20       L.
L063B               pshs      D                   * 063B 34 06          4.
                    lbsr      L40C2               * 063D 17 3A 82       .:.
                    leas      4,S                 * 0640 32 64          2d
                    stu       -2,S                * 0642 EF 7E          o~
                    beq       L0683               * 0644 27 3D          '=
                    clra                          * 0646 4F             O
                    clrb                          * 0647 5F             _
                    bra       L0677               * 0648 20 2D           -
L064A               ldd       ,S                  * 064A EC E4          ld
                    cmpd      <U001B              * 064C 10 93 1B       ...
                    bge       L0661               * 064F 2C 10          ,.
                    ldb       ,U+                 * 0651 E6 C0          f@
                    clra                          * 0653 4F             O
                    pshs      D                   * 0654 34 06          4.
                    leax      >L07EA,PC           * 0656 30 8D 01 90    0...
                    pshs      X                   * 065A 34 10          4.
                    lbsr      L39FC               * 065C 17 33 9D       .3.
                    bra       L0670               * 065F 20 0F           .
L0661               leax      >Y0496,Y            * 0661 30 A9 04 96    0)..
                    pshs      X                   * 0665 34 10          4.
                    leax      >L07EF,PC           * 0667 30 8D 01 84    0...
                    pshs      X                   * 066B 34 10          4.
                    lbsr      L3992               * 066D 17 33 22       .3"
L0670               leas      4,S                 * 0670 32 64          2d
                    ldd       ,S                  * 0672 EC E4          ld
                    addd      #1                  * 0674 C3 00 01       C..
L0677               std       ,S                  * 0677 ED E4          md
                    ldd       ,S                  * 0679 EC E4          ld
                    cmpd      #5                  * 067B 10 83 00 05    ....
                    blt       L064A               * 067F 2D C9          -I
                    bra       L0694               * 0681 20 11           .
L0683               leax      >Y0496,Y            * 0683 30 A9 04 96    0)..
                    pshs      X                   * 0687 34 10          4.
                    leax      >L07F2,PC           * 0689 30 8D 01 65    0..e
                    pshs      X                   * 068D 34 10          4.
                    lbsr      L3992               * 068F 17 33 00       .3.
                    leas      4,S                 * 0692 32 64          2d
L0694               leas      2,S                 * 0694 32 62          2b
L0696               ldd       <U0064              * 0696 DC 64          \d
                    bne       L06A0               * 0698 26 06          &.
                    ldd       <U0066              * 069A DC 66          \f
                    lbeq      L06FE               * 069C 10 27 00 5E    .'.^
L06A0               ldd       <U0064              * 06A0 DC 64          \d
                    bne       L06AA               * 06A2 26 06          &.
                    leax      >L07FD,PC           * 06A4 30 8D 01 55    0..U
                    stx       <U0064              * 06A8 9F 64          .d
L06AA               ldd       <U0066              * 06AA DC 66          \f
                    bne       L06B4               * 06AC 26 06          &.
                    leax      >L07FE,PC           * 06AE 30 8D 01 4C    0..L
                    stx       <U0066              * 06B2 9F 66          .f
L06B4               ldd       <U006A              * 06B4 DC 6A          \j
                    bne       L06BE               * 06B6 26 06          &.
                    leax      >L07FF,PC           * 06B8 30 8D 01 43    0..C
                    stx       <U006A              * 06BC 9F 6A          .j
L06BE               ldd       <U0066              * 06BE DC 66          \f
                    pshs      D                   * 06C0 34 06          4.
                    ldd       <U0064              * 06C2 DC 64          \d
                    pshs      D                   * 06C4 34 06          4.
                    ldd       <U00CE              * 06C6 DC CE          \N
                    beq       L06D3               * 06C8 27 09          '.
                    ldd       <U00D6              * 06CA DC D6          \V
                    bne       L06D3               * 06CC 26 05          &.
                    ldd       #43                 * 06CE CC 00 2B       L.+
                    bra       L06D6               * 06D1 20 03           .
L06D3               ldd       #32                 * 06D3 CC 00 20       L.
L06D6               pshs      D                   * 06D6 34 06          4.
                    leax      >L0800,PC           * 06D8 30 8D 01 24    0..$
                    pshs      X                   * 06DC 34 10          4.
                    lbsr      L39FC               * 06DE 17 33 1B       .3.
                    leas      8,S                 * 06E1 32 68          2h
                    ldd       <U006A              * 06E3 DC 6A          \j
                    pshs      D                   * 06E5 34 06          4.
                    ldd       <U00D6              * 06E7 DC D6          \V
                    beq       L06F1               * 06E9 27 06          '.
                    leax      >L080D,PC           * 06EB 30 8D 01 1E    0...
                    bra       L06F5               * 06EF 20 04           .
L06F1               leax      >L0810,PC           * 06F1 30 8D 01 1B    0...
L06F5               tfr       X,D                 * 06F5 1F 10          ..
                    pshs      D                   * 06F7 34 06          4.
                    lbsr      L39FC               * 06F9 17 33 00       .3.
                    leas      4,S                 * 06FC 32 64          2d
L06FE               ldd       <U006C              * 06FE DC 6C          \l
                    beq       L0711               * 0700 27 0F          '.
                    ldd       <U006C              * 0702 DC 6C          \l
                    pshs      D                   * 0704 34 06          4.
                    leax      >L0816,PC           * 0706 30 8D 01 0C    0...
                    pshs      X                   * 070A 34 10          4.
                    lbsr      L39FC               * 070C 17 32 ED       .2m
                    leas      4,S                 * 070F 32 64          2d
L0711               leax      >Y0496,Y            * 0711 30 A9 04 96    0)..
                    pshs      X                   * 0715 34 10          4.
                    ldd       #13                 * 0717 CC 00 0D       L..
                    pshs      D                   * 071A 34 06          4.
                    lbsr      L40C2               * 071C 17 39 A3       .9#
                    leas      4,S                 * 071F 32 64          2d
                    ldd       <U00C8              * 0721 DC C8          \H
                    addd      #1                  * 0723 C3 00 01       C..
                    std       <U00C8              * 0726 DD C8          ]H
                    puls      PC,U                * 0728 35 C0          5@

L072A               pshs      U                   * 072A 34 40          4@
                    leax      >L081A,PC           * 072C 30 8D 00 EA    0..j
                    pshs      X                   * 0730 34 10          4.
                    bsr       L074E               * 0732 8D 1A          ..
                    puls      PC,U,X              * 0734 35 D0          5P
L0736               pshs      U                   * 0736 34 40          4@
                    leax      >L082C,PC           * 0738 30 8D 00 F0    0..p
                    pshs      X                   * 073C 34 10          4.
                    bsr       L074E               * 073E 8D 0E          ..
                    puls      PC,U,X              * 0740 35 D0          5P

L0742               pshs      U                   * 0742 34 40          4@
                    leax      >L083E,PC           * 0744 30 8D 00 F6    0..v
                    pshs      X                   * 0748 34 10          4.
                    bsr       L074E               * 074A 8D 02          ..
                    puls      PC,U,X              * 074C 35 D0          5P
L074E               pshs      U                   * 074E 34 40          4@
                    ldb       <U005B              * 0750 D6 5B          V[
                    beq       L0780               * 0752 27 2C          ',
                    ldd       #1                  * 0754 CC 00 01       L..
                    std       <U003D              * 0757 DD 3D          ]=
                    ldd       <U00C8              * 0759 DC C8          \H
                    beq       L0767               * 075B 27 0A          '.
                    ldd       <U0003              * 075D DC 03          \.
                    addd      #-4                 * 075F C3 FF FC       C.|
                    cmpd      <U00C8              * 0762 10 93 C8       ..H
                    bge       L076A               * 0765 2C 03          ,.
L0767               lbsr      L298C               * 0767 17 22 22       .""
L076A               ldd       4,S                 * 076A EC 64          ld
                    pshs      D                   * 076C 34 06          4.
                    leax      >L0857,PC           * 076E 30 8D 00 E5    0..e
                    pshs      X                   * 0772 34 10          4.
                    lbsr      L39FC               * 0774 17 32 85       .2.
                    leas      4,S                 * 0777 32 64          2d
                    ldd       <U00C8              * 0779 DC C8          \H
                    addd      #1                  * 077B C3 00 01       C..
                    std       <U00C8              * 077E DD C8          ]H
L0780               ldd       <U0023              * 0780 DC 23          \#
                    addd      #1                  * 0782 C3 00 01       C..
                    std       <U0023              * 0785 DD 23          ]#
L0787               clra                          * 0787 4F             O
                    clrb                          * 0788 5F             _
                    puls      PC,U                * 0789 35 C0          5@
L078B               pshs      U                   * 078B 34 40          4@
                    ldd       4,S                 * 078D EC 64          ld
                    pshs      D                   * 078F 34 06          4.
                    leax      >L086B,PC           * 0791 30 8D 00 D6    0..V
                    pshs      X                   * 0795 34 10          4.
                    leax      >Y04A3,Y            * 0797 30 A9 04 A3    0).#
                    pshs      X                   * 079B 34 10          4.
                    lbsr      L3A0E               * 079D 17 32 6E       .2n
                    leas      6,S                 * 07A0 32 66          2f
                    ldd       >errno,Y            * 07A2 EC A9 05 A7    l).'
                    pshs      D                   * 07A6 34 06          4.
                    lbsr      exit                * 07A8 17 42 65       .Be
                    puls      PC,U,X              * 07AB 35 D0          5P
L07AD               fcb       $77                 * 07AD 77             w
                    fcb       $00                 * 07AE 00             .
L07AF               fcb       $72                 * 07AF 72             r
                    fcb       $00                 * 07B0 00             .
L07B1               fcc       "file close error"  * 07B1 66 69 6C 65 20 63 6C 6F 73 65 20 65 72 72 6F 72 file close error
                    fcb       $00                 * 07C1 00             .
L07C2               fcc       "bad label"         * 07C2 62 61 64 20 6C 61 62 65 6C bad label
                    fcb       $00                 * 07CB 00             .
L07CC               fcc       "bad mnemonic"      * 07CC 62 61 64 20 6D 6E 65 6D 6F 6E 69 63 bad mnemonic
                    fcb       $00                 * 07D8 00             .
L07D9               fcc       "%05d"              * 07D9 25 30 35 64    %05d
                    fcb       $00                 * 07DD 00             .
L07DE               fcc       " %04x"             * 07DE 20 25 30 34 78  %04x
                    fcb       $00                 * 07E3 00             .
L07E4               fcc       "     "             * 07E4 20 20 20 20 20
                    fcb       $00                 * 07E9 00             .
L07EA               fcc       "%02x"              * 07EA 25 30 32 78    %02x
                    fcb       $00                 * 07EE 00             .
L07EF               fcc       "  "                * 07EF 20 20
                    fcb       $00                 * 07F1 00             .
L07F2               fcc       "          "        * 07F2 20 20 20 20 20 20 20 20 20 20
                    fcb       $00                 * 07FC 00             .
L07FD               fcb       $00                 * 07FD 00             .
L07FE               fcb       $00                 * 07FE 00             .
L07FF               fcb       $00                 * 07FF 00             .
L0800               fcc       "%c%-8s %-5s "      * 0800 25 63 25 2D 38 73 20 25 2D 35 73 20 %c%-8s %-5s
                    fcb       $00                 * 080C 00             .
L080D               fcc       "%s"                * 080D 25 73          %s
                    fcb       $00                 * 080F 00             .
L0810               fcc       "%-10s"             * 0810 25 2D 31 30 73 %-10s
                    fcb       $00                 * 0815 00             .
L0816               fcc       " %s"               * 0816 20 25 73        %s
                    fcb       $00                 * 0819 00             .
L081A               fcc       "bad register list" * 081A 62 61 64 20 72 65 67 69 73 74 65 72 20 6C 69 73 74 bad register list
                    fcb       $00                 * 082B 00             .
L082C               fcc       "bad register name" * 082C 62 61 64 20 72 65 67 69 73 74 65 72 20 6E 61 6D 65 bad register name
                    fcb       $00                 * 083D 00             .
L083E               fcc       "nested MACRO definitions" * 083E 6E 65 73 74 65 64 20 4D 41 43 52 4F 20 64 65 66 69 6E 69 74 69 6F 6E 73 nested MACRO definitions
                    fcb       $00                 * 0856 00             .
L0857               fcc       "*** error - %s ***" * 0857 2A 2A 2A 20 65 72 72 6F 72 20 2D 20 25 73 20 2A 2A 2A *** error - %s ***
                    fcb       $0D                 * 0869 0D             .
                    fcb       $00                 * 086A 00             .
L086B               fcc       "asm: %s"           * 086B 61 73 6D 3A 20 25 73 asm: %s
                    fcb       $0D                 * 0872 0D             .
                    fcb       $00                 * 0873 00             .
L0874               pshs      U,D                 * 0874 34 46          4F
                    leau      >Y06B7,Y            * 0876 33 A9 06 B7    3).7
                    bra       L08A4               * 087A 20 28           (
L087C               ldb       [<$06,S]            * 087C E6 F8 06       fx.
                    sex                           * 087F 1D             .
                    leax      >Y03FC,Y            * 0880 30 A9 03 FC    0).|
                    leax      D,X                 * 0884 30 8B          0.
                    ldb       ,X                  * 0886 E6 84          f.
                    clra                          * 0888 4F             O
                    andb      #4                  * 0889 C4 04          D.
                    beq       L0893               * 088B 27 06          '.
                    ldb       [<$06,S]            * 088D E6 F8 06       fx.
                    sex                           * 0890 1D             .
                    bra       L0899               * 0891 20 06           .
L0893               ldb       [<$06,S]            * 0893 E6 F8 06       fx.
                    sex                           * 0896 1D             .
                    orb       #32                 * 0897 CA 20          J
L0899               stb       ,U                  * 0899 E7 C4          gD
                    leau      1,U                 * 089B 33 41          3A
                    ldd       6,S                 * 089D EC 66          lf
                    addd      #1                  * 089F C3 00 01       C..
                    std       6,S                 * 08A2 ED 66          mf
L08A4               ldb       [<$06,S]            * 08A4 E6 F8 06       fx.
                    bne       L087C               * 08A7 26 D3          &S
                    clra                          * 08A9 4F             O
                    clrb                          * 08AA 5F             _
                    stb       ,U                  * 08AB E7 C4          gD
                    ldd       8,S                 * 08AD EC 68          lh
                    bra       L08E1               * 08AF 20 30           0
L08B1               ldu       [,S]                * 08B1 EE F4          nt
                    leax      >Y06B7,Y            * 08B3 30 A9 06 B7    0).7
                    stx       <U0068              * 08B7 9F 68          .h
                    bra       L08D0               * 08B9 20 15           .
L08BB               ldb       ,U                  * 08BB E6 C4          fD
                    sex                           * 08BD 1D             .
                    pshs      D                   * 08BE 34 06          4.
                    ldx       <U0068              * 08C0 9E 68          .h
                    leax      1,X                 * 08C2 30 01          0.
                    stx       <U0068              * 08C4 9F 68          .h
                    ldb       -1,X                * 08C6 E6 1F          f.
                    sex                           * 08C8 1D             .
                    cmpd      ,S++                * 08C9 10 A3 E1       .#a
                    bne       L08D4               * 08CC 26 06          &.
                    leau      1,U                 * 08CE 33 41          3A
L08D0               ldb       ,U                  * 08D0 E6 C4          fD
                    bne       L08BB               * 08D2 26 E7          &g
L08D4               ldb       ,U                  * 08D4 E6 C4          fD
                    bne       L08DC               * 08D6 26 04          &.
                    ldd       ,S                  * 08D8 EC E4          ld
                    puls      PC,U,X              * 08DA 35 D0          5P
L08DC               ldd       ,S                  * 08DC EC E4          ld
                    addd      #4                  * 08DE C3 00 04       C..
L08E1               std       ,S                  * 08E1 ED E4          md
                    ldd       ,S                  * 08E3 EC E4          ld
                    cmpd      10,S                * 08E5 10 A3 6A       .#j
                    bcs       L08B1               * 08E8 25 C7          %G
                    clra                          * 08EA 4F             O
                    clrb                          * 08EB 5F             _
                    puls      PC,U,X              * 08EC 35 D0          5P
                    fcc       "psect"             * 08EE 70 73 65 63 74 psect
                    fcb       $00                 * 08F3 00             .
                    fcc       "csect"             * 08F4 63 73 65 63 74 csect
                    fcb       $00                 * 08F9 00             .
                    fcc       "vsect"             * 08FA 76 73 65 63 74 vsect
                    fcb       $00                 * 08FF 00             .
                    fcc       "end"               * 0900 65 6E 64       end
                    fcb       $00                 * 0903 00             .
                    fcc       "lbra"              * 0904 6C 62 72 61    lbra
                    fcb       $00                 * 0908 00             .
                    fcc       "lbsr"              * 0909 6C 62 73 72    lbsr
                    fcb       $00                 * 090D 00             .
                    fcc       "orcc"              * 090E 6F 72 63 63    orcc
                    fcb       $00                 * 0912 00             .
                    fcc       "andcc"             * 0913 61 6E 64 63 63 andcc
                    fcb       $00                 * 0918 00             .
                    fcc       "cwai"              * 0919 63 77 61 69    cwai
                    fcb       $00                 * 091D 00             .
                    fcc       "addd"              * 091E 61 64 64 64    addd
                    fcb       $00                 * 0922 00             .
                    fcc       "subd"              * 0923 73 75 62 64    subd
                    fcb       $00                 * 0927 00             .
                    fcc       "ldd"               * 0928 6C 64 64       ldd
                    fcb       $00                 * 092B 00             .
                    fcc       "ldx"               * 092C 6C 64 78       ldx
                    fcb       $00                 * 092F 00             .
                    fcc       "ldu"               * 0930 6C 64 75       ldu
                    fcb       $00                 * 0933 00             .
                    fcc       "cmpx"              * 0934 63 6D 70 78    cmpx
                    fcb       $00                 * 0938 00             .
                    fcc       "jsr"               * 0939 6A 73 72       jsr
                    fcb       $00                 * 093C 00             .
                    fcc       "std"               * 093D 73 74 64       std
                    fcb       $00                 * 0940 00             .
                    fcc       "stx"               * 0941 73 74 78       stx
                    fcb       $00                 * 0944 00             .
                    fcc       "stu"               * 0945 73 74 75       stu
                    fcb       $00                 * 0948 00             .
                    fcc       "cmpu"              * 0949 63 6D 70 75    cmpu
                    fcb       $00                 * 094D 00             .
                    fcc       "cmps"              * 094E 63 6D 70 73    cmps
                    fcb       $00                 * 0952 00             .
                    fcc       "cmpd"              * 0953 63 6D 70 64    cmpd
                    fcb       $00                 * 0957 00             .
                    fcc       "cmpy"              * 0958 63 6D 70 79    cmpy
                    fcb       $00                 * 095C 00             .
                    fcc       "ldy"               * 095D 6C 64 79       ldy
                    fcb       $00                 * 0960 00             .
                    fcc       "lds"               * 0961 6C 64 73       lds
                    fcb       $00                 * 0964 00             .
                    fcc       "sty"               * 0965 73 74 79       sty
                    fcb       $00                 * 0968 00             .
                    fcc       "sts"               * 0969 73 74 73       sts
                    fcb       $00                 * 096C 00             .
                    fcc       "add"               * 096D 61 64 64       add
                    fcb       $00                 * 0970 00             .
                    fcc       "cmp"               * 0971 63 6D 70       cmp
                    fcb       $00                 * 0974 00             .
                    fcc       "sub"               * 0975 73 75 62       sub
                    fcb       $00                 * 0978 00             .
                    fcc       "sbc"               * 0979 73 62 63       sbc
                    fcb       $00                 * 097C 00             .
                    fcc       "and"               * 097D 61 6E 64       and
                    fcb       $00                 * 0980 00             .
                    fcc       "bit"               * 0981 62 69 74       bit
                    fcb       $00                 * 0984 00             .
                    fcc       "ld"                * 0985 6C 64          ld
                    fcb       $00                 * 0987 00             .
                    fcc       "st"                * 0988 73 74          st
                    fcb       $00                 * 098A 00             .
                    fcc       "eor"               * 098B 65 6F 72       eor
                    fcb       $00                 * 098E 00             .
                    fcc       "adc"               * 098F 61 64 63       adc
                    fcb       $00                 * 0992 00             .
                    fcc       "org"               * 0993 6F 72 67       org
                    fcb       $00                 * 0996 00             .
                    fcc       "or"                * 0997 6F 72          or
                    fcb       $00                 * 0999 00             .
                    fcc       "neg"               * 099A 6E 65 67       neg
                    fcb       $00                 * 099D 00             .
                    fcc       "com"               * 099E 63 6F 6D       com
                    fcb       $00                 * 09A1 00             .
                    fcc       "lsr"               * 09A2 6C 73 72       lsr
                    fcb       $00                 * 09A5 00             .
                    fcc       "ror"               * 09A6 72 6F 72       ror
                    fcb       $00                 * 09A9 00             .
                    fcc       "asr"               * 09AA 61 73 72       asr
                    fcb       $00                 * 09AD 00             .
                    fcc       "lsl"               * 09AE 6C 73 6C       lsl
                    fcb       $00                 * 09B1 00             .
                    fcc       "asl"               * 09B2 61 73 6C       asl
                    fcb       $00                 * 09B5 00             .
                    fcc       "rol"               * 09B6 72 6F 6C       rol
                    fcb       $00                 * 09B9 00             .
                    fcc       "dec"               * 09BA 64 65 63       dec
                    fcb       $00                 * 09BD 00             .
                    fcc       "inc"               * 09BE 69 6E 63       inc
                    fcb       $00                 * 09C1 00             .
                    fcc       "tst"               * 09C2 74 73 74       tst
                    fcb       $00                 * 09C5 00             .
                    fcc       "jmp"               * 09C6 6A 6D 70       jmp
                    fcb       $00                 * 09C9 00             .
                    fcc       "clr"               * 09CA 63 6C 72       clr
                    fcb       $00                 * 09CD 00             .
                    fcc       "rts"               * 09CE 72 74 73       rts
                    fcb       $00                 * 09D1 00             .
                    fcc       "mul"               * 09D2 6D 75 6C       mul
                    fcb       $00                 * 09D5 00             .
                    fcc       "nop"               * 09D6 6E 6F 70       nop
                    fcb       $00                 * 09D9 00             .
                    fcc       "sync"              * 09DA 73 79 6E 63    sync
                    fcb       $00                 * 09DE 00             .
                    fcc       "daa"               * 09DF 64 61 61       daa
                    fcb       $00                 * 09E2 00             .
                    fcc       "sex"               * 09E3 73 65 78       sex
                    fcb       $00                 * 09E6 00             .
                    fcc       "abx"               * 09E7 61 62 78       abx
                    fcb       $00                 * 09EA 00             .
                    fcc       "rti"               * 09EB 72 74 69       rti
                    fcb       $00                 * 09EE 00             .
                    fcc       "swi2"              * 09EF 73 77 69 32    swi2
                    fcb       $00                 * 09F3 00             .
                    fcc       "swi3"              * 09F4 73 77 69 33    swi3
                    fcb       $00                 * 09F8 00             .
                    fcc       "swi"               * 09F9 73 77 69       swi
                    fcb       $00                 * 09FC 00             .
                    fcc       "leax"              * 09FD 6C 65 61 78    leax
                    fcb       $00                 * 0A01 00             .
                    fcc       "leay"              * 0A02 6C 65 61 79    leay
                    fcb       $00                 * 0A06 00             .
                    fcc       "leas"              * 0A07 6C 65 61 73    leas
                    fcb       $00                 * 0A0B 00             .
                    fcc       "leau"              * 0A0C 6C 65 61 75    leau
                    fcb       $00                 * 0A10 00             .
                    fcc       "tfr"               * 0A11 74 66 72       tfr
                    fcb       $00                 * 0A14 00             .
                    fcc       "exg"               * 0A15 65 78 67       exg
                    fcb       $00                 * 0A18 00             .
                    fcc       "pshs"              * 0A19 70 73 68 73    pshs
                    fcb       $00                 * 0A1D 00             .
                    fcc       "puls"              * 0A1E 70 75 6C 73    puls
                    fcb       $00                 * 0A22 00             .
                    fcc       "pshu"              * 0A23 70 73 68 75    pshu
                    fcb       $00                 * 0A27 00             .
                    fcc       "pulu"              * 0A28 70 75 6C 75    pulu
                    fcb       $00                 * 0A2C 00             .
                    fcc       "lb"                * 0A2D 6C 62          lb
                    fcb       $00                 * 0A2F 00             .
                    fcc       "fcc"               * 0A30 66 63 63       fcc
                    fcb       $00                 * 0A33 00             .
                    fcc       "fdb"               * 0A34 66 64 62       fdb
                    fcb       $00                 * 0A37 00             .
                    fcc       "fcs"               * 0A38 66 63 73       fcs
                    fcb       $00                 * 0A3B 00             .
                    fcc       "fcb"               * 0A3C 66 63 62       fcb
                    fcb       $00                 * 0A3F 00             .
                    fcc       "rzb"               * 0A40 72 7A 62       rzb
                    fcb       $00                 * 0A43 00             .
                    fcc       "vsect"             * 0A44 76 73 65 63 74 vsect
                    fcb       $00                 * 0A49 00             .
                    fcc       "csect"             * 0A4A 63 73 65 63 74 csect
                    fcb       $00                 * 0A4F 00             .
                    fcc       "ends"              * 0A50 65 6E 64 73    ends
                    fcb       $00                 * 0A54 00             .
                    fcc       "setdp"             * 0A55 73 65 74 64 70 setdp
                    fcb       $00                 * 0A5A 00             .
                    fcc       "os9"               * 0A5B 6F 73 39       os9
                    fcb       $00                 * 0A5E 00             .
                    fcc       "rmb"               * 0A5F 72 6D 62       rmb
                    fcb       $00                 * 0A62 00             .
                    fcc       "ends"              * 0A63 65 6E 64 73    ends
                    fcb       $00                 * 0A67 00             .
                    fcc       "rmb"               * 0A68 72 6D 62       rmb
                    fcb       $00                 * 0A6B 00             .
                    fcc       "fcc"               * 0A6C 66 63 63       fcc
                    fcb       $00                 * 0A6F 00             .
                    fcc       "fdb"               * 0A70 66 64 62       fdb
                    fcb       $00                 * 0A73 00             .
                    fcc       "fcs"               * 0A74 66 63 73       fcs
                    fcb       $00                 * 0A77 00             .
                    fcc       "fcb"               * 0A78 66 63 62       fcb
                    fcb       $00                 * 0A7B 00             .
                    fcc       "rzb"               * 0A7C 72 7A 62       rzb
                    fcb       $00                 * 0A7F 00             .
                    fcc       "ends"              * 0A80 65 6E 64 73    ends
                    fcb       $00                 * 0A84 00             .
                    fcc       "rmb"               * 0A85 72 6D 62       rmb
                    fcb       $00                 * 0A88 00             .
                    fcc       "ends"              * 0A89 65 6E 64 73    ends
                    fcb       $00                 * 0A8D 00             .
                    fcc       "nam"               * 0A8E 6E 61 6D       nam
                    fcb       $00                 * 0A91 00             .
                    fcc       "opt"               * 0A92 6F 70 74       opt
                    fcb       $00                 * 0A95 00             .
                    fcc       "ttl"               * 0A96 74 74 6C       ttl
                    fcb       $00                 * 0A99 00             .
                    fcc       "pag"               * 0A9A 70 61 67       pag
                    fcb       $00                 * 0A9D 00             .
                    fcc       "spc"               * 0A9E 73 70 63       spc
                    fcb       $00                 * 0AA1 00             .
                    fcc       "use"               * 0AA2 75 73 65       use
                    fcb       $00                 * 0AA5 00             .
                    fcc       "fail"              * 0AA6 66 61 69 6C    fail
                    fcb       $00                 * 0AAA 00             .
                    fcc       "rept"              * 0AAB 72 65 70 74    rept
                    fcb       $00                 * 0AAF 00             .
                    fcc       "endr"              * 0AB0 65 6E 64 72    endr
                    fcb       $00                 * 0AB4 00             .
                    fcc       "ifeq"              * 0AB5 69 66 65 71    ifeq
                    fcb       $00                 * 0AB9 00             .
                    fcc       "ifne"              * 0ABA 69 66 6E 65    ifne
                    fcb       $00                 * 0ABE 00             .
                    fcc       "iflt"              * 0ABF 69 66 6C 74    iflt
                    fcb       $00                 * 0AC3 00             .
                    fcc       "ifle"              * 0AC4 69 66 6C 65    ifle
                    fcb       $00                 * 0AC8 00             .
                    fcc       "ifge"              * 0AC9 69 66 67 65    ifge
                    fcb       $00                 * 0ACD 00             .
                    fcc       "ifgt"              * 0ACE 69 66 67 74    ifgt
                    fcb       $00                 * 0AD2 00             .
                    fcc       "ifp1"              * 0AD3 69 66 70 31    ifp1
                    fcb       $00                 * 0AD7 00             .
                    fcc       "endc"              * 0AD8 65 6E 64 63    endc
                    fcb       $00                 * 0ADC 00             .
                    fcc       "else"              * 0ADD 65 6C 73 65    else
                    fcb       $00                 * 0AE1 00             .
                    fcc       "equ"               * 0AE2 65 71 75       equ
                    fcb       $00                 * 0AE5 00             .
                    fcc       "set"               * 0AE6 73 65 74       set
                    fcb       $00                 * 0AE9 00             .
                    fcc       "macro"             * 0AEA 6D 61 63 72 6F macro
                    fcb       $00                 * 0AEF 00             .
                    fcc       "endm"              * 0AF0 65 6E 64 6D    endm
                    fcb       $00                 * 0AF4 00             .
                    fcc       "bsr"               * 0AF5 62 73 72       bsr
                    fcb       $00                 * 0AF8 00             .
                    fcc       "bra"               * 0AF9 62 72 61       bra
                    fcb       $00                 * 0AFC 00             .
                    fcc       "brn"               * 0AFD 62 72 6E       brn
                    fcb       $00                 * 0B00 00             .
                    fcc       "bhi"               * 0B01 62 68 69       bhi
                    fcb       $00                 * 0B04 00             .
                    fcc       "bls"               * 0B05 62 6C 73       bls
                    fcb       $00                 * 0B08 00             .
                    fcc       "bhs"               * 0B09 62 68 73       bhs
                    fcb       $00                 * 0B0C 00             .
                    fcc       "bcc"               * 0B0D 62 63 63       bcc
                    fcb       $00                 * 0B10 00             .
                    fcc       "blo"               * 0B11 62 6C 6F       blo
                    fcb       $00                 * 0B14 00             .
                    fcc       "bcs"               * 0B15 62 63 73       bcs
                    fcb       $00                 * 0B18 00             .
                    fcc       "bne"               * 0B19 62 6E 65       bne
                    fcb       $00                 * 0B1C 00             .
                    fcc       "beq"               * 0B1D 62 65 71       beq
                    fcb       $00                 * 0B20 00             .
                    fcc       "bvc"               * 0B21 62 76 63       bvc
                    fcb       $00                 * 0B24 00             .
                    fcc       "bvs"               * 0B25 62 76 73       bvs
                    fcb       $00                 * 0B28 00             .
                    fcc       "bpl"               * 0B29 62 70 6C       bpl
                    fcb       $00                 * 0B2C 00             .
                    fcc       "bmi"               * 0B2D 62 6D 69       bmi
                    fcb       $00                 * 0B30 00             .
                    fcc       "bge"               * 0B31 62 67 65       bge
                    fcb       $00                 * 0B34 00             .
                    fcc       "blt"               * 0B35 62 6C 74       blt
                    fcb       $00                 * 0B38 00             .
                    fcc       "bgt"               * 0B39 62 67 74       bgt
                    fcb       $00                 * 0B3C 00             .
                    fcc       "ble"               * 0B3D 62 6C 65       ble
                    fcb       $00                 * 0B40 00             .

                    pshs      U                   * 0B41 34 40          4@
                    ldd       #3                  * 0B43 CC 00 03       L..
                    std       <U001B              * 0B46 DD 1B          ].
                    lbra      L0CF6               * 0B48 16 01 AB       ..+
                    pshs      U                   * 0B4B 34 40          4@
                    ldd       #2                  * 0B4D CC 00 02       L..
                    std       <U001B              * 0B50 DD 1B          ].
                    lbsr      L100E               * 0B52 17 04 B9       ..9
                    std       -2,S                * 0B55 ED 7E          m~
                    lbeq      L0C27               * 0B57 10 27 00 CC    .'.L
                    ldb       <U0061              * 0B5B D6 61          Va
                    sex                           * 0B5D 1D             .
                    orb       #8                  * 0B5E CA 08          J.
                    stb       <U0061              * 0B60 D7 61          Wa
                    lbsr      L23D4               * 0B62 17 18 6F       ..o
                    ldd       <U0031              * 0B65 DC 31          \1
                    stb       <U00BA              * 0B67 D7 BA          W:
                    lbra      L0F25               * 0B69 16 03 B9       ..9
                    pshs      U                   * 0B6C 34 40          4@
                    lbsr      L100E               * 0B6E 17 04 9D       ...
                    std       -2,S                * 0B71 ED 7E          m~
                    beq       L0BB8               * 0B73 27 43          'C
                    ldd       <U001B              * 0B75 DC 1B          \.
                    addd      #2                  * 0B77 C3 00 02       C..
                    std       <U001B              * 0B7A DD 1B          ].
                    lbsr      L23B8               * 0B7C 17 18 39       ..9
                    ldd       <U0031              * 0B7F DC 31          \1
                    std       <U00BA              * 0B81 DD BA          ]:
                    bra       L0BB3               * 0B83 20 2E           .
                    pshs      U                   * 0B85 34 40          4@
                    ldb       [>U0068,Y]          * 0B87 E6 B9 00 68    f9.h
                    sex                           * 0B8B 1D             .
                    tfr       D,X                 * 0B8C 1F 01          ..
                    bra       L0BBD               * 0B8E 20 2D           -
L0B90               ldb       <Y00B9              * 0B90 D6 B9          V9
                    sex                           * 0B92 1D             .
                    orb       #64                 * 0B93 CA 40          J@
                    stb       <Y00B9              * 0B95 D7 B9          W9
L0B97               lbsr      L100E               * 0B97 17 04 74       ..t
                    std       -2,S                * 0B9A ED 7E          m~
                    beq       L0BB8               * 0B9C 27 1A          '.
                    ldd       <U001B              * 0B9E DC 1B          \.
                    addd      #1                  * 0BA0 C3 00 01       C..
                    std       <U001B              * 0BA3 DD 1B          ].
                    ldb       <U0061              * 0BA5 D6 61          Va
                    sex                           * 0BA7 1D             .
                    orb       #8                  * 0BA8 CA 08          J.
                    stb       <U0061              * 0BAA D7 61          Wa
                    lbsr      L23D4               * 0BAC 17 18 25       ..%
                    ldd       <U0031              * 0BAF DC 31          \1
                    stb       <U00BA              * 0BB1 D7 BA          W:
L0BB3               lbsr      L1023               * 0BB3 17 04 6D       ..m
                    puls      PC,U                * 0BB6 35 C0          5@
L0BB8               lbsr      L1118               * 0BB8 17 05 5D       ..]
                    puls      PC,U                * 0BBB 35 C0          5@
L0BBD               cmpx      #98                 * 0BBD 8C 00 62       ..b
                    beq       L0B90               * 0BC0 27 CE          'N
                    cmpx      #97                 * 0BC2 8C 00 61       ..a
                    beq       L0B97               * 0BC5 27 D0          'P
                    bra       L0BE7               * 0BC7 20 1E           .
                    pshs      U                   * 0BC9 34 40          4@
                    ldb       <Y00B9              * 0BCB D6 B9          V9
                    cmpb      #14                 * 0BCD C1 0E          A.
                    beq       L0BF8               * 0BCF 27 27          ''
                    ldb       [>U0068,Y]          * 0BD1 E6 B9 00 68    f9.h
                    beq       L0BF8               * 0BD5 27 21          '!
                    ldb       [>U0068,Y]          * 0BD7 E6 B9 00 68    f9.h
                    sex                           * 0BDB 1D             .
                    tfr       D,X                 * 0BDC 1F 01          ..
                    bra       L0BEC               * 0BDE 20 0C           .
L0BE0               ldb       <Y00B9              * 0BE0 D6 B9          V9
                    sex                           * 0BE2 1D             .
                    orb       #80                 * 0BE3 CA 50          JP
                    bra       L0C0F               * 0BE5 20 28           (
L0BE7               lbsr      L0736               * 0BE7 17 FB 4C       .{L
                    puls      PC,U                * 0BEA 35 C0          5@
L0BEC               cmpx      #97                 * 0BEC 8C 00 61       ..a
                    beq       L0C0A               * 0BEF 27 19          '.
                    cmpx      #98                 * 0BF1 8C 00 62       ..b
                    beq       L0BE0               * 0BF4 27 EA          'j
                    bra       L0BE7               * 0BF6 20 EF           o
L0BF8               lbsr      L1118               * 0BF8 17 05 1D       ...
                    std       -2,S                * 0BFB ED 7E          m~
                    lbeq      L0EE4               * 0BFD 10 27 02 E3    .'.c
                    ldb       <Y00B9              * 0C01 D6 B9          V9
                    clra                          * 0C03 4F             O
                    andb      #240                * 0C04 C4 F0          Dp
                    lbeq      L0F25               * 0C06 10 27 03 1B    .'..
L0C0A               ldb       <Y00B9              * 0C0A D6 B9          V9
                    sex                           * 0C0C 1D             .
                    orb       #64                 * 0C0D CA 40          J@
L0C0F               stb       <Y00B9              * 0C0F D7 B9          W9
                    lbra      L0F25               * 0C11 16 03 11       ...
                    pshs      U                   * 0C14 34 40          4@
                    lbra      L0F25               * 0C16 16 03 0C       ...
                    pshs      U                   * 0C19 34 40          4@
                    lbsr      L1118               * 0C1B 17 04 FA       ..z
                    std       -2,S                * 0C1E ED 7E          m~
                    beq       L0C27               * 0C20 27 05          '.
                    ldd       #1                  * 0C22 CC 00 01       L..
                    bra       L0C2A               * 0C25 20 03           .
L0C27               lbsr      L12F8               * 0C27 17 06 CE       ..N
L0C2A               puls      PC,U                * 0C2A 35 C0          5@
                    pshs      U,X,D               * 0C2C 34 56          4V
                    ldd       #2                  * 0C2E CC 00 02       L..
                    std       <U001B              * 0C31 DD 1B          ].
                    clra                          * 0C33 4F             O
                    clrb                          * 0C34 5F             _
                    pshs      D                   * 0C35 34 06          4.
                    lbsr      L1070               * 0C37 17 04 36       ..6
                    leas      2,S                 * 0C3A 32 62          2b
                    std       2,S                 * 0C3C ED 62          mb
                    lbeq      L0C8B               * 0C3E 10 27 00 49    .'.I
                    ldb       [>U0062,Y]          * 0C42 E6 B9 00 62    f9.b
                    cmpb      #44                 * 0C46 C1 2C          A,
                    bne       L0C8B               * 0C48 26 41          &A
                    ldd       <U0062              * 0C4A DC 62          \b
                    addd      #1                  * 0C4C C3 00 01       C..
                    std       <U0062              * 0C4F DD 62          ]b
                    clra                          * 0C51 4F             O
                    clrb                          * 0C52 5F             _
                    pshs      D                   * 0C53 34 06          4.
                    lbsr      L1070               * 0C55 17 04 18       ...
                    leas      2,S                 * 0C58 32 62          2b
                    std       ,S                  * 0C5A ED E4          md
                    beq       L0C8B               * 0C5C 27 2D          '-
                    ldd       2,S                 * 0C5E EC 62          lb
                    eora      ,S                  * 0C60 A8 E4          (d
                    eorb      1,S                 * 0C62 E8 61          ha
                    clra                          * 0C64 4F             O
                    andb      #8                  * 0C65 C4 08          D.
                    bne       L0C7E               * 0C67 26 15          &.
                    ldd       2,S                 * 0C69 EC 62          lb
                    aslb                          * 0C6B 58             X
                    rola                          * 0C6C 49             I
                    aslb                          * 0C6D 58             X
                    rola                          * 0C6E 49             I
                    aslb                          * 0C6F 58             X
                    rola                          * 0C70 49             I
                    aslb                          * 0C71 58             X
                    rola                          * 0C72 49             I
                    ora       ,S                  * 0C73 AA E4          *d
                    orb       1,S                 * 0C75 EA 61          ja
                    stb       <U00BA              * 0C77 D7 BA          W:
                    ldd       #1                  * 0C79 CC 00 01       L..
                    bra       L0C8E               * 0C7C 20 10           .
L0C7E               leax      >L0F80,PC           * 0C7E 30 8D 02 FE    0..~
                    pshs      X                   * 0C82 34 10          4.
                    lbsr      L074E               * 0C84 17 FA C7       .zG
                    leas      2,S                 * 0C87 32 62          2b
                    bra       L0C8E               * 0C89 20 03           .
L0C8B               lbsr      L072A               * 0C8B 17 FA 9C       .z.
L0C8E               leas      4,S                 * 0C8E 32 64          2d
                    puls      PC,U                * 0C90 35 C0          5@
                    pshs      U,D                 * 0C92 34 46          4F
                    ldd       #2                  * 0C94 CC 00 02       L..
                    std       <U001B              * 0C97 DD 1B          ].
                    lbsr      L2229               * 0C99 17 15 8D       ...
                    bra       L0CBB               * 0C9C 20 1D           .
L0C9E               ldb       <U00BA              * 0C9E D6 BA          V:
                    sex                           * 0CA0 1D             .
                    ora       ,S                  * 0CA1 AA E4          *d
                    orb       1,S                 * 0CA3 EA 61          ja
                    stb       <U00BA              * 0CA5 D7 BA          W:
                    ldb       [>U0062,Y]          * 0CA7 E6 B9 00 62    f9.b
                    cmpb      #44                 * 0CAB C1 2C          A,
                    beq       L0CB4               * 0CAD 27 05          '.
                    ldd       #1                  * 0CAF CC 00 01       L..
                    puls      PC,U,X              * 0CB2 35 D0          5P
L0CB4               ldd       <U0062              * 0CB4 DC 62          \b
                    addd      #1                  * 0CB6 C3 00 01       C..
                    std       <U0062              * 0CB9 DD 62          ]b
L0CBB               ldd       #1                  * 0CBB CC 00 01       L..
                    pshs      D                   * 0CBE 34 06          4.
                    lbsr      L1070               * 0CC0 17 03 AD       ..-
                    leas      2,S                 * 0CC3 32 62          2b
                    std       ,S                  * 0CC5 ED E4          md
                    bne       L0C9E               * 0CC7 26 D5          &U
                    lbsr      L072A               * 0CC9 17 FA 5E       .z^
                    puls      PC,U,X              * 0CCC 35 D0          5P
                    pshs      U                   * 0CCE 34 40          4@
                    ldd       #4                  * 0CD0 CC 00 04       L..
                    std       <U001B              * 0CD3 DD 1B          ].
                    ldd       >Y0013,Y            * 0CD5 EC A9 00 13    l)..
                    pshs      D                   * 0CD9 34 06          4.
                    leax      >Y02DA,Y            * 0CDB 30 A9 02 DA    0).Z
                    pshs      X                   * 0CDF 34 10          4.
                    leax      >Y05B4,Y            * 0CE1 30 A9 05 B4    0).4
                    pshs      X                   * 0CE5 34 10          4.
                    lbsr      L0874               * 0CE7 17 FB 8A       .{.
                    leas      6,S                 * 0CEA 32 66          2f
                    std       <U0070              * 0CEC DD 70          ]p
                    beq       L0CFB               * 0CEE 27 0B          '.
                    ldx       <U0070              * 0CF0 9E 70          .p
                    ldb       2,X                 * 0CF2 E6 02          f.
                    stb       <Y00B9              * 0CF4 D7 B9          W9
L0CF6               lbsr      L1038               * 0CF6 17 03 3F       ..?
                    puls      PC,U                * 0CF9 35 C0          5@
L0CFB               leax      >L0F97,PC           * 0CFB 30 8D 02 98    0...
                    pshs      X                   * 0CFF 34 10          4.
                    lbsr      L074E               * 0D01 17 FA 4A       .zJ
                    puls      PC,U,X              * 0D04 35 D0          5P
                    pshs      U,D                 * 0D06 34 46          4F
                    ldd       #2                  * 0D08 CC 00 02       L..
                    std       <U001B              * 0D0B DD 1B          ].
                    lbsr      L2426               * 0D0D 17 17 16       ...
                    std       -2,S                * 0D10 ED 7E          m~
                    beq       L0D63               * 0D12 27 4F          'O
                    ldb       <U005B              * 0D14 D6 5B          V[
                    beq       L0D5E               * 0D16 27 46          'F
                    ldd       <U0031              * 0D18 DC 31          \1
                    subd      <U004D              * 0D1A 93 4D          .M
                    addd      #-2                 * 0D1C C3 FF FE       C.~
                    std       ,S                  * 0D1F ED E4          md
                    ldb       <U0061              * 0D21 D6 61          Va
                    sex                           * 0D23 1D             .
                    orb       #136                * 0D24 CA 88          J.
                    stb       <U0061              * 0D26 D7 61          Wa
                    lbsr      L1485               * 0D28 17 07 5A       ..Z
                    leax      >Y07C7,Y            * 0D2B 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 0D2F AC A9 07 E5    ,).e
                    bne       L0D57               * 0D33 26 22          &"
                    ldd       ,S                  * 0D35 EC E4          ld
                    cmpd      #127                * 0D37 10 83 00 7F    ....
                    bgt       L0D45               * 0D3B 2E 08          ..
                    ldd       ,S                  * 0D3D EC E4          ld
                    cmpd      #-128               * 0D3F 10 83 FF 80    ....
                    bge       L0D5A               * 0D43 2C 15          ,.
L0D45               ldd       #-2                 * 0D45 CC FF FE       L.~
                    std       ,S                  * 0D48 ED E4          md
                    leax      >L0FA4,PC           * 0D4A 30 8D 02 56    0..V
                    pshs      X                   * 0D4E 34 10          4.
                    lbsr      L074E               * 0D50 17 F9 FB       .y{
                    leas      2,S                 * 0D53 32 62          2b
                    bra       L0D5A               * 0D55 20 03           .
L0D57               lbsr      L13DA               * 0D57 17 06 80       ...
L0D5A               ldd       ,S                  * 0D5A EC E4          ld
                    stb       <U00BA              * 0D5C D7 BA          W:
L0D5E               ldd       #1                  * 0D5E CC 00 01       L..
                    puls      PC,U,X              * 0D61 35 D0          5P
L0D63               clra                          * 0D63 4F             O
                    clrb                          * 0D64 5F             _
                    puls      PC,U,X              * 0D65 35 D0          5P
                    pshs      U                   * 0D67 34 40          4@
                    clra                          * 0D69 4F             O
                    clrb                          * 0D6A 5F             _
                    std       <U001B              * 0D6B DD 1B          ].
                    ldb       <Y00B9              * 0D6D D6 B9          V9
                    sex                           * 0D6F 1D             .
                    aslb                          * 0D70 58             X
                    rola                          * 0D71 49             I
                    leax      >Y0398,Y            * 0D72 30 A9 03 98    0)..
                    bra       L0D87               * 0D76 20 0F           .
                    pshs      U                   * 0D78 34 40          4@
                    clra                          * 0D7A 4F             O
                    clrb                          * 0D7B 5F             _
                    std       <U001B              * 0D7C DD 1B          ].
                    ldb       <Y00B9              * 0D7E D6 B9          V9
                    sex                           * 0D80 1D             .
                    aslb                          * 0D81 58             X
                    rola                          * 0D82 49             I
                    leax      >Y03AE,Y            * 0D83 30 A9 03 AE    0)..
L0D87               leax      D,X                 * 0D87 30 8B          0.
                    jsr       [,X]                * 0D89 AD 94          -.
                    puls      PC,U                * 0D8B 35 C0          5@
                    pshs      U                   * 0D8D 34 40          4@
                    clra                          * 0D8F 4F             O
                    clrb                          * 0D90 5F             _
                    std       <U001B              * 0D91 DD 1B          ].
                    ldd       <U0029              * 0D93 DC 29          \)
                    addd      #1                  * 0D95 C3 00 01       C..
                    std       <U0029              * 0D98 DD 29          ])
                    ldb       <Y00B9              * 0D9A D6 B9          V9
                    sex                           * 0D9C 1D             .
                    aslb                          * 0D9D 58             X
                    rola                          * 0D9E 49             I
                    leax      >Y03C6,Y            * 0D9F 30 A9 03 C6    0).F
                    leax      D,X                 * 0DA3 30 8B          0.
                    ldd       ,X                  * 0DA5 EC 84          l.
                    pshs      D                   * 0DA7 34 06          4.
                    leax      >L1BBF,PC           * 0DA9 30 8D 0E 12    0...
                    cmpx      ,S++                * 0DAD AC E1          ,a
                    beq       L0DC6               * 0DAF 27 15          '.
                    lbsr      L2426               * 0DB1 17 16 72       ..r
                    std       -2,S                * 0DB4 ED 7E          m~
                    lbeq      L0EE4               * 0DB6 10 27 01 2A    .'.*
                    leax      >Y07C7,Y            * 0DBA 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 0DBE AC A9 07 E5    ,).e
                    lbne      L0EF2               * 0DC2 10 26 01 2C    .&.,
L0DC6               ldb       <Y00B9              * 0DC6 D6 B9          V9
                    sex                           * 0DC8 1D             .
                    aslb                          * 0DC9 58             X
                    rola                          * 0DCA 49             I
                    leax      >Y03C6,Y            * 0DCB 30 A9 03 C6    0).F
                    leax      D,X                 * 0DCF 30 8B          0.
                    jsr       [,X]                * 0DD1 AD 94          -.
                    std       -2,S                * 0DD3 ED 7E          m~
                    bne       L0DDE               * 0DD5 26 07          &.
                    ldd       <U002B              * 0DD7 DC 2B          \+
                    addd      #1                  * 0DD9 C3 00 01       C..
                    std       <U002B              * 0DDC DD 2B          ]+
L0DDE               ldd       <U003D              * 0DDE DC 3D          \=
                    pshs      D                   * 0DE0 34 06          4.
                    ldb       <U00BF              * 0DE2 D6 BF          V?
                    ble       L0E30               * 0DE4 2F 4A          /J
                    ldd       #1                  * 0DE6 CC 00 01       L..
                    bra       L0E32               * 0DE9 20 47           G
L0DEB               pshs      U                   * 0DEB 34 40          4@
                    leax      >L0FB8,PC           * 0DED 30 8D 01 C7    0..G
                    pshs      X                   * 0DF1 34 10          4.
                    lbsr      L074E               * 0DF3 17 F9 58       .yX
                    puls      PC,U,X              * 0DF6 35 D0          5P
                    pshs      U                   * 0DF8 34 40          4@
                    clra                          * 0DFA 4F             O
                    clrb                          * 0DFB 5F             _
                    std       <U001B              * 0DFC DD 1B          ].
                    ldd       <U0029              * 0DFE DC 29          \)
                    beq       L0E3B               * 0E00 27 39          '9
                    ldb       <Y00B9              * 0E02 D6 B9          V9
                    bne       L0E18               * 0E04 26 12          &.
                    ldd       <U0029              * 0E06 DC 29          \)
                    addd      #-1                 * 0E08 C3 FF FF       C..
                    std       <U0029              * 0E0B DD 29          ])
                    ldd       <U002B              * 0E0D DC 2B          \+
                    beq       L0E23               * 0E0F 27 12          '.
L0E11               ldd       <U002B              * 0E11 DC 2B          \+
                    addd      #-1                 * 0E13 C3 FF FF       C..
                    bra       L0E21               * 0E16 20 09           .
L0E18               ldd       <U002B              * 0E18 DC 2B          \+
                    bne       L0E11               * 0E1A 26 F5          &u
                    ldd       <U002B              * 0E1C DC 2B          \+
                    addd      #1                  * 0E1E C3 00 01       C..
L0E21               std       <U002B              * 0E21 DD 2B          ]+
L0E23               ldd       <U003D              * 0E23 DC 3D          \=
                    pshs      D                   * 0E25 34 06          4.
                    ldb       <U00BF              * 0E27 D6 BF          V?
                    ble       L0E30               * 0E29 2F 05          /.
                    ldd       #1                  * 0E2B CC 00 01       L..
                    bra       L0E32               * 0E2E 20 02           .
L0E30               clra                          * 0E30 4F             O
                    clrb                          * 0E31 5F             _
L0E32               anda      ,S+                 * 0E32 A4 E0          $`
                    andb      ,S+                 * 0E34 E4 E0          d`
                    std       <U003D              * 0E36 DD 3D          ]=
                    lbra      L0F25               * 0E38 16 00 EA       ..j
L0E3B               leax      >L0FD3,PC           * 0E3B 30 8D 01 94    0...
                    pshs      X                   * 0E3F 34 10          4.
                    lbsr      L074E               * 0E41 17 F9 0A       .y.
                    puls      PC,U,X              * 0E44 35 D0          5P
                    pshs      U                   * 0E46 34 40          4@
                    bsr       L0E5C               * 0E48 8D 12          ..
                    lbsr      L2BC2               * 0E4A 17 1D 75       ..u
                    clra                          * 0E4D 4F             O
                    clrb                          * 0E4E 5F             _
                    std       <U0041              * 0E4F DD 41          ]A
                    std       <U0045              * 0E51 DD 45          ]E
                    std       <U0043              * 0E53 DD 43          ]C
                    std       <U0047              * 0E55 DD 47          ]G
                    std       <U004D              * 0E57 DD 4D          ]M
                    lbra      L0F25               * 0E59 16 00 C9       ..I
L0E5C               pshs      U                   * 0E5C 34 40          4@
                    clra                          * 0E5E 4F             O
                    clrb                          * 0E5F 5F             _
                    std       <U001B              * 0E60 DD 1B          ].
                    leax      >Y0116,Y            * 0E62 30 A9 01 16    0)..
                    stx       <U0072              * 0E66 9F 72          .r
                    ldd       >Y0009,Y            * 0E68 EC A9 00 09    l)..
                    std       <U0074              * 0E6C DD 74          ]t
                    leax      >Y033A,Y            * 0E6E 30 A9 03 3A    0).:
                    stx       <U006E              * 0E72 9F 6E          .n
                    leax      >U007C,Y            * 0E74 30 A9 00 7C    0).|
                    stx       <U007A              * 0E78 9F 7A          .z
                    ldd       #4                  * 0E7A CC 00 04       L..
                    stb       <U005C              * 0E7D D7 5C          W\
                    ldd       #162                * 0E7F CC 00 A2       L."
                    stb       <U005E              * 0E82 D7 5E          W^
                    ldd       #32                 * 0E84 CC 00 20       L.
                    stb       <U0060              * 0E87 D7 60          W`
                    leax      >U004D,Y            * 0E89 30 A9 00 4D    0).M
                    stx       <U004B              * 0E8D 9F 4B          .K
                    clra                          * 0E8F 4F             O
                    clrb                          * 0E90 5F             _
                    std       <U0053              * 0E91 DD 53          ]S
                    lbra      L0F25               * 0E93 16 00 8F       ...
                    pshs      U                   * 0E96 34 40          4@
                    clra                          * 0E98 4F             O
                    clrb                          * 0E99 5F             _
                    std       <U001B              * 0E9A DD 1B          ].
                    leax      >Y0256,Y            * 0E9C 30 A9 02 56    0).V
                    stx       <U0072              * 0EA0 9F 72          .r
                    ldd       >Y000B,Y            * 0EA2 EC A9 00 0B    l)..
                    std       <U0074              * 0EA6 DD 74          ]t
                    leax      >Y0356,Y            * 0EA8 30 A9 03 56    0).V
                    stx       <U006E              * 0EAC 9F 6E          .n
                    clra                          * 0EAE 4F             O
                    clrb                          * 0EAF 5F             _
                    std       <U007A              * 0EB0 DD 7A          ]z
                    ldd       #6                  * 0EB2 CC 00 06       L..
                    stb       <U005C              * 0EB5 D7 5C          W\
                    ldb       <U005E              * 0EB7 D6 5E          V^
                    clra                          * 0EB9 4F             O
                    andb      #2                  * 0EBA C4 02          D.
                    orb       #128                * 0EBC CA 80          J.
                    stb       <U005E              * 0EBE D7 5E          W^
                    clra                          * 0EC0 4F             O
                    clrb                          * 0EC1 5F             _
                    stb       <U0060              * 0EC2 D7 60          W`
                    clra                          * 0EC4 4F             O
                    clrb                          * 0EC5 5F             _
                    std       <U004B              * 0EC6 DD 4B          ]K
                    leax      >Y0049,Y            * 0EC8 30 A9 00 49    0).I
                    stx       <U0053              * 0ECC 9F 53          .S
                    tfr       X,D                 * 0ECE 1F 10          ..
                    std       <U004F              * 0ED0 DD 4F          ]O
                    clra                          * 0ED2 4F             O
                    clrb                          * 0ED3 5F             _
                    std       <Y0049              * 0ED4 DD 49          ]I
                    lbsr      L2229               * 0ED6 17 13 50       ..P
                    std       -2,S                * 0ED9 ED 7E          m~
                    beq       L0F25               * 0EDB 27 48          'H
                    lbsr      L2426               * 0EDD 17 15 46       ..F
                    std       -2,S                * 0EE0 ED 7E          m~
                    bne       L0EE8               * 0EE2 26 04          &.
L0EE4               clra                          * 0EE4 4F             O
                    clrb                          * 0EE5 5F             _
                    puls      PC,U                * 0EE6 35 C0          5@
L0EE8               leax      >Y07C7,Y            * 0EE8 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 0EEC AC A9 07 E5    ,).e
                    beq       L0EF7               * 0EF0 27 05          '.
L0EF2               lbsr      L0DEB               * 0EF2 17 FE F6       .~v
                    puls      PC,U                * 0EF5 35 C0          5@
L0EF7               ldd       <U0031              * 0EF7 DC 31          \1
                    std       <Y0049              * 0EF9 DD 49          ]I
                    bra       L0F25               * 0EFB 20 28           (
                    pshs      U                   * 0EFD 34 40          4@
                    clra                          * 0EFF 4F             O
                    clrb                          * 0F00 5F             _
                    std       <U001B              * 0F01 DD 1B          ].
                    leax      >Y027A,Y            * 0F03 30 A9 02 7A    0).z
                    stx       <U0072              * 0F07 9F 72          .r
                    ldd       >Y000F,Y            * 0F09 EC A9 00 0F    l)..
                    std       <U0074              * 0F0D DD 74          ]t
                    leax      >Y035E,Y            * 0F0F 30 A9 03 5E    0).^
                    stx       <U006E              * 0F13 9F 6E          .n
                    clra                          * 0F15 4F             O
                    clrb                          * 0F16 5F             _
                    stb       <U005C              * 0F17 D7 5C          W\
                    lbsr      L1C27               * 0F19 17 0D 0B       ...
                    std       -2,S                * 0F1C ED 7E          m~
                    beq       L0F25               * 0F1E 27 05          '.
                    ldd       #2                  * 0F20 CC 00 02       L..
                    stb       <U005C              * 0F23 D7 5C          W\
L0F25               ldd       #1                  * 0F25 CC 00 01       L..
                    puls      PC,U                * 0F28 35 C0          5@
                    pshs      U                   * 0F2A 34 40          4@
                    ldd       <U0053              * 0F2C DC 53          \S
                    std       <U004F              * 0F2E DD 4F          ]O
                    ldb       <U005E              * 0F30 D6 5E          V^
                    clra                          * 0F32 4F             O
                    andb      #2                  * 0F33 C4 02          D.
                    beq       L0F3C               * 0F35 27 05          '.
                    lbsr      L0E5C               * 0F37 17 FF 22       .."
                    bra       L0F3F               * 0F3A 20 03           .
L0F3C               lbsr      L1C72               * 0F3C 17 0D 33       ..3
L0F3F               puls      PC,U                * 0F3F 35 C0          5@
                    pshs      U                   * 0F41 34 40          4@
                    ldd       <U00CC              * 0F43 DC CC          \L
                    beq       L0F4C               * 0F45 27 05          '.
                    lbsr      L0742               * 0F47 17 F7 F8       .wx
                    puls      PC,U                * 0F4A 35 C0          5@
L0F4C               ldd       <U0064              * 0F4C DC 64          \d
                    bne       L0F5B               * 0F4E 26 0B          &.
                    leax      >L0FED,PC           * 0F50 30 8D 00 99    0...
                    pshs      X                   * 0F54 34 10          4.
                    lbsr      L074E               * 0F56 17 F7 F5       .wu
                    puls      PC,U,X              * 0F59 35 D0          5P
L0F5B               ldd       #7                  * 0F5B CC 00 07       L..
                    pshs      D                   * 0F5E 34 06          4.
                    lbsr      L20A1               * 0F60 17 11 3E       ..>
                    leas      2,S                 * 0F63 32 62          2b
                    ldb       <U005B              * 0F65 D6 5B          V[
                    bne       L0F6C               * 0F67 26 03          &.
                    lbsr      L31E9               * 0F69 17 22 7D       ."}
L0F6C               ldd       #1                  * 0F6C CC 00 01       L..
                    std       <U00CC              * 0F6F DD CC          ]L
                    puls      PC,U                * 0F71 35 C0          5@
                    pshs      U                   * 0F73 34 40          4@
                    leax      >L0FFB,PC           * 0F75 30 8D 00 82    0...
                    pshs      X                   * 0F79 34 10          4.
                    lbsr      L074E               * 0F7B 17 F7 D0       .wP
                    puls      PC,U,X              * 0F7E 35 D0          5P
L0F80               fcc       "register size mismatch" * 0F80 72 65 67 69 73 74 65 72 20 73 69 7A 65 20 6D 69 73 6D 61 74 63 68 register size mismatch
                    fcb       $00                 * 0F96 00             .
L0F97               fcc       "bad mnemonic"      * 0F97 62 61 64 20 6D 6E 65 6D 6F 6E 69 63 bad mnemonic
                    fcb       $00                 * 0FA3 00             .
L0FA4               fcc       "branch out of range" * 0FA4 62 72 61 6E 63 68 20 6F 75 74 20 6F 66 20 72 61 6E 67 65 branch out of range
                    fcb       $00                 * 0FB7 00             .
L0FB8               fcc       "illegal external reference" * 0FB8 69 6C 6C 65 67 61 6C 20 65 78 74 65 72 6E 61 6C 20 72 65 66 65 72 65 6E 63 65 illegal external reference
                    fcb       $00                 * 0FD2 00             .
L0FD3               fcc       "conditional nesting error" * 0FD3 63 6F 6E 64 69 74 69 6F 6E 61 6C 20 6E 65 73 74 69 6E 67 20 65 72 72 6F 72 conditional nesting error
                    fcb       $00                 * 0FEC 00             .
L0FED               fcc       "label missing"     * 0FED 6C 61 62 65 6C 20 6D 69 73 73 69 6E 67 label missing
                    fcb       $00                 * 0FFA 00             .
L0FFB               fcc       "ENDM without MACRO" * 0FFB 45 4E 44 4D 20 77 69 74 68 6F 75 74 20 4D 41 43 52 4F ENDM without MACRO
                    fcb       $00                 * 100D 00             .
L100E               pshs      U                   * 100E 34 40          4@
                    lbsr      L2229               * 1010 17 12 16       ...
                    cmpd      #35                 * 1013 10 83 00 23    ...#
                    bne       L1048               * 1017 26 2F          &/
                    ldd       <U0062              * 1019 DC 62          \b
                    addd      #1                  * 101B C3 00 01       C..
                    std       <U0062              * 101E DD 62          ]b
                    lbra      L13C1               * 1020 16 03 9E       ...
L1023               pshs      U                   * 1023 34 40          4@
                    ldd       <U001F              * 1025 DC 1F          \.
                    clra                          * 1027 4F             O
                    andb      #64                 * 1028 C4 40          D@
                    lbeq      L13C1               * 102A 10 27 03 93    .'..
                    ldd       #3                  * 102E CC 00 03       L..
                    std       <U001B              * 1031 DD 1B          ].
                    lbsr      L12F8               * 1033 17 02 C2       ..B
                    puls      PC,U                * 1036 35 C0          5@
L1038               pshs      U                   * 1038 34 40          4@
                    ldb       <U0061              * 103A D6 61          Va
                    sex                           * 103C 1D             .
                    orb       #128                * 103D CA 80          J.
                    stb       <U0061              * 103F D7 61          Wa
                    lbsr      L23B8               * 1041 17 13 74       ..t
                    std       -2,S                * 1044 ED 7E          m~
                    bne       L104C               * 1046 26 04          &.
L1048               clra                          * 1048 4F             O
                    clrb                          * 1049 5F             _
                    puls      PC,U                * 104A 35 C0          5@
L104C               ldd       <U0031              * 104C DC 31          \1
                    subd      <U004D              * 104E 93 4D          .M
                    subd      <U001B              * 1050 93 1B          ..
                    std       <U00BA              * 1052 DD BA          ]:
                    ldd       <U00BA              * 1054 DC BA          \:
                    cmpd      #127                * 1056 10 83 00 7F    ....
                    bgt       L1064               * 105A 2E 08          ..
                    ldd       <U00BA              * 105C DC BA          \:
                    cmpd      #-128               * 105E 10 83 FF 80    ....
                    bge       L1069               * 1062 2C 05          ,.
L1064               ldd       #1                  * 1064 CC 00 01       L..
                    bra       L106B               * 1067 20 02           .
L1069               clra                          * 1069 4F             O
                    clrb                          * 106A 5F             _
L106B               std       <U0039              * 106B DD 39          ]9
                    lbra      L13C1               * 106D 16 03 51       ..Q
L1070               pshs      U                   * 1070 34 40          4@
                    leas      -3,S                * 1072 32 7D          2}
                    clra                          * 1074 4F             O
                    clrb                          * 1075 5F             _
                    lbra      L1106               * 1076 16 00 8D       ...
L1079               ldd       1,S                 * 1079 EC 61          la
                    pshs      D                   * 107B 34 06          4.
                    ldd       #3                  * 107D CC 00 03       L..
                    lbsr      L466A               * 1080 17 35 E7       .5g
                    leax      >Y0362,Y            * 1083 30 A9 03 62    0).b
                    leax      D,X                 * 1087 30 8B          0.
                    ldb       ,X                  * 1089 E6 84          f.
                    sex                           * 108B 1D             .
                    pshs      D                   * 108C 34 06          4.
                    ldb       [>U0062,Y]          * 108E E6 B9 00 62    f9.b
                    clra                          * 1092 4F             O
                    andb      #223                * 1093 C4 DF          D_
                    cmpd      ,S++                * 1095 10 A3 E1       .#a
                    lbne      L1101               * 1098 10 26 00 65    .&.e
                    ldd       1,S                 * 109C EC 61          la
                    pshs      D                   * 109E 34 06          4.
                    ldd       #3                  * 10A0 CC 00 03       L..
                    lbsr      L466A               * 10A3 17 35 C4       .5D
                    leax      >Y0362,Y            * 10A6 30 A9 03 62    0).b
                    leax      D,X                 * 10AA 30 8B          0.
                    ldb       1,X                 * 10AC E6 01          f.
                    stb       ,S                  * 10AE E7 E4          gd
                    beq       L10CA               * 10B0 27 18          '.
                    ldx       <U0062              * 10B2 9E 62          .b
                    ldb       1,X                 * 10B4 E6 01          f.
                    clra                          * 10B6 4F             O
                    andb      #223                * 10B7 C4 DF          D_
                    pshs      D                   * 10B9 34 06          4.
                    ldb       2,S                 * 10BB E6 62          fb
                    sex                           * 10BD 1D             .
                    cmpd      ,S++                * 10BE 10 A3 E1       .#a
                    bne       L1101               * 10C1 26 3E          &>
                    ldd       <U0062              * 10C3 DC 62          \b
                    addd      #1                  * 10C5 C3 00 01       C..
                    std       <U0062              * 10C8 DD 62          ]b
L10CA               ldd       <U0062              * 10CA DC 62          \b
                    addd      #1                  * 10CC C3 00 01       C..
                    std       <U0062              * 10CF DD 62          ]b
                    ldd       7,S                 * 10D1 EC 67          lg
                    bne       L10EC               * 10D3 26 17          &.
                    ldd       1,S                 * 10D5 EC 61          la
                    cmpd      #4                  * 10D7 10 83 00 04    ....
                    bge       L10E3               * 10DB 2C 06          ,.
                    ldd       1,S                 * 10DD EC 61          la
                    orb       #8                  * 10DF CA 08          J.
                    bra       L1114               * 10E1 20 31           1
L10E3               ldd       1,S                 * 10E3 EC 61          la
                    addd      #-4                 * 10E5 C3 FF FC       C.|
                    ora       #1                  * 10E8 8A 01          ..
                    bra       L1114               * 10EA 20 28           (
L10EC               ldd       1,S                 * 10EC EC 61          la
                    pshs      D                   * 10EE 34 06          4.
                    ldd       #3                  * 10F0 CC 00 03       L..
                    lbsr      L466A               * 10F3 17 35 74       .5t
                    leax      >Y0362,Y            * 10F6 30 A9 03 62    0).b
                    leax      D,X                 * 10FA 30 8B          0.
                    ldb       2,X                 * 10FC E6 02          f.
                    sex                           * 10FE 1D             .
                    bra       L1114               * 10FF 20 13           .
L1101               ldd       1,S                 * 1101 EC 61          la
                    addd      #1                  * 1103 C3 00 01       C..
L1106               std       1,S                 * 1106 ED 61          ma
                    ldd       1,S                 * 1108 EC 61          la
                    cmpd      #10                 * 110A 10 83 00 0A    ....
                    lblt      L1079               * 110E 10 2D FF 67    .-.g
                    clra                          * 1112 4F             O
                    clrb                          * 1113 5F             _
L1114               leas      3,S                 * 1114 32 63          2c
                    puls      PC,U                * 1116 35 C0          5@
L1118               pshs      U                   * 1118 34 40          4@
                    leas      -1,S                * 111A 32 7F          2.
                    lbsr      L2229               * 111C 17 11 0A       ...
                    stb       ,S                  * 111F E7 E4          gd
                    cmpb      #91                 * 1121 C1 5B          A[
                    bne       L112A               * 1123 26 05          &.
                    ldd       #1                  * 1125 CC 00 01       L..
                    bra       L112C               * 1128 20 02           .
L112A               clra                          * 112A 4F             O
                    clrb                          * 112B 5F             _
L112C               std       <U0035              * 112C DD 35          ]5
                    beq       L113A               * 112E 27 0A          '.
                    ldx       <U0062              * 1130 9E 62          .b
                    leax      1,X                 * 1132 30 01          0.
                    stx       <U0062              * 1134 9F 62          .b
                    ldb       ,X                  * 1136 E6 84          f.
                    stb       ,S                  * 1138 E7 E4          gd
L113A               ldb       ,S                  * 113A E6 E4          fd
                    sex                           * 113C 1D             .
                    pshs      D                   * 113D 34 06          4.
                    lbsr      L11C0               * 113F 17 00 7E       ..~
                    leas      2,S                 * 1142 32 62          2b
                    stb       ,S                  * 1144 E7 E4          gd
                    cmpb      #44                 * 1146 C1 2C          A,
                    bne       L1150               * 1148 26 06          &.
                    lbsr      L1260               * 114A 17 01 13       ...
                    lbra      L1364               * 114D 16 02 14       ...
L1150               ldx       <U0062              * 1150 9E 62          .b
                    ldb       1,X                 * 1152 E6 01          f.
                    cmpb      #44                 * 1154 C1 2C          A,
                    bne       L1185               * 1156 26 2D          &-
                    ldb       ,S                  * 1158 E6 E4          fd
                    clra                          * 115A 4F             O
                    andb      #223                * 115B C4 DF          D_
                    tfr       D,X                 * 115D 1F 01          ..
                    bra       L1176               * 115F 20 15           .
L1161               ldd       #134                * 1161 CC 00 86       L..
                    bra       L116E               * 1164 20 08           .
L1166               ldd       #133                * 1166 CC 00 85       L..
                    bra       L116E               * 1169 20 03           .
L116B               ldd       #139                * 116B CC 00 8B       L..
L116E               stb       <U00BA              * 116E D7 BA          W:
                    lbsr      L11F1               * 1170 17 00 7E       ..~
                    lbra      L1364               * 1173 16 01 EE       ..n
L1176               cmpx      #65                 * 1176 8C 00 41       ..A
                    beq       L1161               * 1179 27 E6          'f
                    cmpx      #66                 * 117B 8C 00 42       ..B
                    beq       L1166               * 117E 27 E6          'f
                    cmpx      #68                 * 1180 8C 00 44       ..D
                    beq       L116B               * 1183 27 E6          'f
L1185               lbsr      L2426               * 1185 17 12 9E       ...
                    ldd       <U0031              * 1188 DC 31          \1
                    std       <U0033              * 118A DD 33          ]3
                    ldb       [>U0062,Y]          * 118C E6 B9 00 62    f9.b
                    cmpb      #44                 * 1190 C1 2C          A,
                    bne       L119A               * 1192 26 06          &.
                    lbsr      L15A3               * 1194 17 04 0C       ...
                    lbra      L1364               * 1197 16 01 CA       ..J
L119A               ldd       <U0035              * 119A DC 35          \5
                    bne       L11BB               * 119C 26 1D          &.
                    ldd       <U0037              * 119E DC 37          \7
                    blt       L11BB               * 11A0 2D 19          -.
                    ldd       <U0037              * 11A2 DC 37          \7
                    bgt       L11B5               * 11A4 2E 0F          ..
                    ldd       <U0033              * 11A6 DC 33          \3
                    pshs      D                   * 11A8 34 06          4.
                    ldd       #256                * 11AA CC 01 00       L..
                    lbsr      L471E               * 11AD 17 35 6E       .5n
                    cmpd      <U0027              * 11B0 10 93 27       ..'
                    bne       L11BB               * 11B3 26 06          &.
L11B5               lbsr      L1233               * 11B5 17 00 7B       ..{
                    lbra      L1364               * 11B8 16 01 A9       ..)
L11BB               bsr       L1209               * 11BB 8D 4C          .L
                    lbra      L1364               * 11BD 16 01 A4       ..$
L11C0               pshs      U                   * 11C0 34 40          4@
                    ldb       5,S                 * 11C2 E6 65          fe
                    cmpb      #62                 * 11C4 C1 3E          A>
                    bne       L11CD               * 11C6 26 05          &.
                    ldd       #-1                 * 11C8 CC FF FF       L..
                    bra       L11DA               * 11CB 20 0D           .
L11CD               ldb       5,S                 * 11CD E6 65          fe
                    cmpb      #60                 * 11CF C1 3C          A<
                    bne       L11D8               * 11D1 26 05          &.
                    ldd       #1                  * 11D3 CC 00 01       L..
                    bra       L11DA               * 11D6 20 02           .
L11D8               clra                          * 11D8 4F             O
                    clrb                          * 11D9 5F             _
L11DA               std       <U0037              * 11DA DD 37          ]7
                    ldd       <U0037              * 11DC DC 37          \7
                    beq       L11EA               * 11DE 27 0A          '.
                    ldx       <U0062              * 11E0 9E 62          .b
                    leax      1,X                 * 11E2 30 01          0.
                    stx       <U0062              * 11E4 9F 62          .b
                    ldb       ,X                  * 11E6 E6 84          f.
                    bra       L11EC               * 11E8 20 02           .
L11EA               ldb       5,S                 * 11EA E6 65          fe
L11EC               sex                           * 11EC 1D             .
                    puls      PC,U                * 11ED 35 C0          5@
                    fcb       $35                 * 11EF 35             5
                    fcb       $C0                 * 11F0 C0             @
L11F1               pshs      U                   * 11F1 34 40          4@
                    ldd       <U0062              * 11F3 DC 62          \b
                    addd      #2                  * 11F5 C3 00 02       C..
                    std       <U0062              * 11F8 DD 62          ]b
                    lbsr      L1305               * 11FA 17 01 08       ...
                    std       -2,S                * 11FD ED 7E          m~
                    lbeq      L12A4               * 11FF 10 27 00 A1    .'.!
                    lbsr      L1375               * 1203 17 01 6F       ..o
                    lbra      L12A7               * 1206 16 00 9E       ...
L1209               pshs      U                   * 1209 34 40          4@
                    ldd       <U001B              * 120B DC 1B          \.
                    addd      #2                  * 120D C3 00 02       C..
                    std       <U001B              * 1210 DD 1B          ].
                    ldd       <U0035              * 1212 DC 35          \5
                    beq       L1222               * 1214 27 0C          '.
                    ldd       #159                * 1216 CC 00 9F       L..
                    stb       <U00BA              * 1219 D7 BA          W:
                    ldd       <U0033              * 121B DC 33          \3
                    std       <U00BB              * 121D DD BB          ];
                    lbra      L12E3               * 121F 16 00 C1       ..A
L1222               lbsr      L1485               * 1222 17 02 60       ..`
                    lbsr      L13DA               * 1225 17 01 B2       ..2
                    ldd       <U0033              * 1228 DC 33          \3
                    std       <U00BA              * 122A DD BA          ]:
                    ldb       <Y00B9              * 122C D6 B9          V9
                    sex                           * 122E 1D             .
                    orb       #48                 * 122F CA 30          J0
                    bra       L125B               * 1231 20 28           (
L1233               pshs      U                   * 1233 34 40          4@
                    ldd       <U001B              * 1235 DC 1B          \.
                    addd      #1                  * 1237 C3 00 01       C..
                    std       <U001B              * 123A DD 1B          ].
                    ldb       <U0061              * 123C D6 61          Va
                    sex                           * 123E 1D             .
                    orb       #8                  * 123F CA 08          J.
                    stb       <U0061              * 1241 D7 61          Wa
                    lbsr      L1485               * 1243 17 02 3F       ..?
                    lbsr      L13DA               * 1246 17 01 91       ...
                    ldd       <U0033              * 1249 DC 33          \3
                    stb       <U00BA              * 124B D7 BA          W:
                    ldb       <Y00B9              * 124D D6 B9          V9
                    clra                          * 124F 4F             O
                    andb      #240                * 1250 C4 F0          Dp
                    lbeq      L13C1               * 1252 10 27 01 6B    .'.k
                    ldb       <Y00B9              * 1256 D6 B9          V9
                    sex                           * 1258 1D             .
                    orb       #16                 * 1259 CA 10          J.
L125B               stb       <Y00B9              * 125B D7 B9          W9
                    lbra      L13C1               * 125D 16 01 61       ..a
L1260               pshs      U                   * 1260 34 40          4@
                    ldd       <U0062              * 1262 DC 62          \b
                    addd      #1                  * 1264 C3 00 01       C..
                    std       <U0062              * 1267 DD 62          ]b
                    clra                          * 1269 4F             O
                    clrb                          * 126A 5F             _
                    std       <U0033              * 126B DD 33          ]3
                    ldb       [>U0062,Y]          * 126D E6 B9 00 62    f9.b
                    cmpb      #45                 * 1271 C1 2D          A-
                    bne       L12A9               * 1273 26 34          &4
                    ldd       <U0062              * 1275 DC 62          \b
                    addd      #1                  * 1277 C3 00 01       C..
                    std       <U0062              * 127A DD 62          ]b
                    ldb       [>U0062,Y]          * 127C E6 B9 00 62    f9.b
                    cmpb      #45                 * 1280 C1 2D          A-
                    bne       L1290               * 1282 26 0C          &.
                    ldd       <U0062              * 1284 DC 62          \b
                    addd      #1                  * 1286 C3 00 01       C..
                    std       <U0062              * 1289 DD 62          ]b
                    ldd       #131                * 128B CC 00 83       L..
                    bra       L1296               * 128E 20 06           .
L1290               lbsr      L12ED               * 1290 17 00 5A       ..Z
                    ldd       #130                * 1293 CC 00 82       L..
L1296               stb       <U00BA              * 1296 D7 BA          W:
                    lbsr      L1305               * 1298 17 00 6A       ..j
                    std       -2,S                * 129B ED 7E          m~
                    beq       L12A4               * 129D 27 05          '.
                    lbsr      L1375               * 129F 17 00 D3       ..S
                    bra       L12A7               * 12A2 20 03           .
L12A4               lbsr      L1368               * 12A4 17 00 C1       ..A
L12A7               puls      PC,U                * 12A7 35 C0          5@
L12A9               lbsr      L1305               * 12A9 17 00 59       ..Y
                    std       -2,S                * 12AC ED 7E          m~
                    bne       L12B5               * 12AE 26 05          &.
                    lbsr      L163E               * 12B0 17 03 8B       ...
                    puls      PC,U                * 12B3 35 C0          5@
L12B5               ldb       [>U0062,Y]          * 12B5 E6 B9 00 62    f9.b
                    cmpb      #43                 * 12B9 C1 2B          A+
                    bne       L12E8               * 12BB 26 2B          &+
                    ldd       <U0062              * 12BD DC 62          \b
                    addd      #1                  * 12BF C3 00 01       C..
                    std       <U0062              * 12C2 DD 62          ]b
                    ldb       [>U0062,Y]          * 12C4 E6 B9 00 62    f9.b
                    cmpb      #43                 * 12C8 C1 2B          A+
                    bne       L12DA               * 12CA 26 0E          &.
                    ldd       <U0062              * 12CC DC 62          \b
                    addd      #1                  * 12CE C3 00 01       C..
                    std       <U0062              * 12D1 DD 62          ]b
                    ldb       <U00BA              * 12D3 D6 BA          V:
                    sex                           * 12D5 1D             .
                    orb       #129                * 12D6 CA 81          J.
                    bra       L12E1               * 12D8 20 07           .
L12DA               bsr       L12ED               * 12DA 8D 11          ..
                    ldb       <U00BA              * 12DC D6 BA          V:
                    sex                           * 12DE 1D             .
                    orb       #128                * 12DF CA 80          J.
L12E1               stb       <U00BA              * 12E1 D7 BA          W:
L12E3               lbsr      L1375               * 12E3 17 00 8F       ...
                    puls      PC,U                * 12E6 35 C0          5@
L12E8               lbsr      L15BC               * 12E8 17 02 D1       ..Q
                    puls      PC,U                * 12EB 35 C0          5@
L12ED               pshs      U                   * 12ED 34 40          4@
                    ldd       <U0035              * 12EF DC 35          \5
                    lbeq      L13C1               * 12F1 10 27 00 CC    .'.L
                    lbra      L13C6               * 12F5 16 00 CE       ..N
L12F8               pshs      U                   * 12F8 34 40          4@
                    leax      >L16CF,PC           * 12FA 30 8D 03 D1    0..Q
                    pshs      X                   * 12FE 34 10          4.
                    lbsr      L074E               * 1300 17 F4 4B       .tK
                    puls      PC,U,X              * 1303 35 D0          5P
L1305               pshs      U                   * 1305 34 40          4@
                    leas      -1,S                * 1307 32 7F          2.
                    ldd       #255                * 1309 CC 00 FF       L..
                    stb       ,S                  * 130C E7 E4          gd
                    ldb       [>U0062,Y]          * 130E E6 B9 00 62    f9.b
                    clra                          * 1312 4F             O
                    andb      #223                * 1313 C4 DF          D_
                    tfr       D,X                 * 1315 1F 01          ..
                    bra       L132E               * 1317 20 15           .
L1319               clra                          * 1319 4F             O
                    clrb                          * 131A 5F             _
                    bra       L132A               * 131B 20 0D           .
L131D               ldd       #32                 * 131D CC 00 20       L.
                    bra       L132A               * 1320 20 08           .
L1322               ldd       #64                 * 1322 CC 00 40       L.@
                    bra       L132A               * 1325 20 03           .
L1327               ldd       #96                 * 1327 CC 00 60       L.`
L132A               stb       ,S                  * 132A E7 E4          gd
                    bra       L1342               * 132C 20 14           .
L132E               cmpx      #88                 * 132E 8C 00 58       ..X
                    beq       L1319               * 1331 27 E6          'f
                    cmpx      #89                 * 1333 8C 00 59       ..Y
                    beq       L131D               * 1336 27 E5          'e
                    cmpx      #85                 * 1338 8C 00 55       ..U
                    beq       L1322               * 133B 27 E5          'e
                    cmpx      #83                 * 133D 8C 00 53       ..S
                    beq       L1327               * 1340 27 E5          'e
L1342               ldb       ,S                  * 1342 E6 E4          fd
                    cmpb      #255                * 1344 C1 FF          A.
                    beq       L1362               * 1346 27 1A          '.
                    ldd       <U0062              * 1348 DC 62          \b
                    addd      #1                  * 134A C3 00 01       C..
                    std       <U0062              * 134D DD 62          ]b
                    ldb       <U00BA              * 134F D6 BA          V:
                    sex                           * 1351 1D             .
                    pshs      D                   * 1352 34 06          4.
                    ldb       2,S                 * 1354 E6 62          fb
                    sex                           * 1356 1D             .
                    ora       ,S+                 * 1357 AA E0          *`
                    orb       ,S+                 * 1359 EA E0          j`
                    stb       <U00BA              * 135B D7 BA          W:
                    ldd       #1                  * 135D CC 00 01       L..
                    bra       L1364               * 1360 20 02           .
L1362               clra                          * 1362 4F             O
                    clrb                          * 1363 5F             _
L1364               leas      1,S                 * 1364 32 61          2a
                    puls      PC,U                * 1366 35 C0          5@
L1368               pshs      U                   * 1368 34 40          4@
                    leax      >L16E7,PC           * 136A 30 8D 03 79    0..y
                    pshs      X                   * 136E 34 10          4.
                    lbsr      L074E               * 1370 17 F3 DB       .s[
                    puls      PC,U,X              * 1373 35 D0          5P
L1375               pshs      U                   * 1375 34 40          4@
                    ldb       <Y00B9              * 1377 D6 B9          V9
                    sex                           * 1379 1D             .
                    orb       #32                 * 137A CA 20          J
                    stb       <Y00B9              * 137C D7 B9          W9
                    ldd       <U001B              * 137E DC 1B          \.
                    addd      #1                  * 1380 C3 00 01       C..
                    std       <U001B              * 1383 DD 1B          ].
                    ldd       <U0021              * 1385 DC 21          \!
                    addd      #1                  * 1387 C3 00 01       C..
                    std       <U0021              * 138A DD 21          ]!
                    ldd       <U0035              * 138C DC 35          \5
                    beq       L13B3               * 138E 27 23          '#
                    ldb       <U00BA              * 1390 D6 BA          V:
                    sex                           * 1392 1D             .
                    orb       #16                 * 1393 CA 10          J.
                    stb       <U00BA              * 1395 D7 BA          W:
                    ldb       [>U0062,Y]          * 1397 E6 B9 00 62    f9.b
                    cmpb      #93                 * 139B C1 5D          A]
                    beq       L13AC               * 139D 27 0D          '.
                    leax      >L16FE,PC           * 139F 30 8D 03 5B    0..[
                    pshs      X                   * 13A3 34 10          4.
                    lbsr      L074E               * 13A5 17 F3 A6       .s&
                    leas      2,S                 * 13A8 32 62          2b
                    bra       L13B3               * 13AA 20 07           .
L13AC               ldd       <U0062              * 13AC DC 62          \b
                    addd      #1                  * 13AE C3 00 01       C..
                    std       <U0062              * 13B1 DD 62          ]b
L13B3               ldb       [>U0062,Y]          * 13B3 E6 B9 00 62    f9.b
                    sex                           * 13B7 1D             .
                    tfr       D,X                 * 13B8 1F 01          ..
                    bra       L13CB               * 13BA 20 0F           .
L13BC               lbsr      L1485               * 13BC 17 00 C6       ..F
                    bsr       L13DA               * 13BF 8D 19          ..
L13C1               ldd       #1                  * 13C1 CC 00 01       L..
                    puls      PC,U                * 13C4 35 C0          5@
L13C6               lbsr      L12F8               * 13C6 17 FF 2F       ../
                    puls      PC,U                * 13C9 35 C0          5@
L13CB               cmpx      #32                 * 13CB 8C 00 20       ..
                    beq       L13BC               * 13CE 27 EC          'l
                    stx       -2,S                * 13D0 AF 7E          /~
                    lbeq      L13BC               * 13D2 10 27 FF E6    .'.f
                    bra       L13C6               * 13D6 20 EE           n
                    puls      PC,U                * 13D8 35 C0          5@
L13DA               pshs      U,X,D               * 13DA 34 56          4V
                    ldb       <U005B              * 13DC D6 5B          V[
                    lbeq      L157C               * 13DE 10 27 01 9A    .'..
                    leax      >Y07C7,Y            * 13E2 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 13E6 AC A9 07 E5    ,).e
                    lbcc      L157C               * 13EA 10 24 01 8E    .$..
                    ldd       <U004B              * 13EE DC 4B          \K
                    bne       L13F8               * 13F0 26 06          &.
                    lbsr      L0DEB               * 13F2 17 F9 F6       .yv
                    lbra      L157C               * 13F5 16 01 84       ...
L13F8               ldb       <U0061              * 13F8 D6 61          Va
                    clra                          * 13FA 4F             O
                    andb      #8                  * 13FB C4 08          D.
                    beq       L1404               * 13FD 27 05          '.
                    ldd       #1                  * 13FF CC 00 01       L..
                    bra       L1407               * 1402 20 03           .
L1404               ldd       #2                  * 1404 CC 00 02       L..
L1407               pshs      D                   * 1407 34 06          4.
                    ldd       [>U004B,Y]          * 1409 EC B9 00 4B    l9.K
                    addd      <U001B              * 140D D3 1B          S.
                    subd      ,S++                * 140F A3 E1          #a
                    std       2,S                 * 1411 ED 62          mb
                    lbra      L1476               * 1413 16 00 60       ..`
L1416               ldx       >Y07E5,Y            * 1416 AE A9 07 E5    .).e
                    leax      -3,X                * 141A 30 1D          0.
                    stx       >Y07E5,Y            * 141C AF A9 07 E5    /).e
                    ldu       1,X                 * 1420 EE 01          n.
                    ldb       ,U                  * 1422 E6 C4          fD
                    sex                           * 1424 1D             .
                    pshs      D                   * 1425 34 06          4.
                    ldb       <U0061              * 1427 D6 61          Va
                    sex                           * 1429 1D             .
                    ora       ,S+                 * 142A AA E0          *`
                    orb       ,S+                 * 142C EA E0          j`
                    pshs      D                   * 142E 34 06          4.
                    ldb       [>Y07E5,Y]          * 1430 E6 B9 07 E5    f9.e
                    sex                           * 1434 1D             .
                    ora       ,S+                 * 1435 AA E0          *`
                    orb       ,S+                 * 1437 EA E0          j`
                    std       ,S                  * 1439 ED E4          md
                    ldb       1,U                 * 143B E6 41          fA
                    clra                          * 143D 4F             O
                    andb      #66                 * 143E C4 42          DB
                    bne       L145E               * 1440 26 1C          &.
                    ldd       #1                  * 1442 CC 00 01       L..
                    std       <U00BD              * 1445 DD BD          ]=
                    ldd       8,U                 * 1447 EC 48          lH
                    bne       L1452               * 1449 26 07          &.
                    ldd       <Y0057              * 144B DC 57          \W
                    addd      #1                  * 144D C3 00 01       C..
                    std       <Y0057              * 1450 DD 57          ]W
L1452               ldd       2,S                 * 1452 EC 62          lb
                    pshs      D                   * 1454 34 06          4.
                    ldd       2,S                 * 1456 EC 62          lb
                    pshs      D                   * 1458 34 06          4.
                    pshs      U                   * 145A 34 40          4@
                    bra       L1471               * 145C 20 13           .
L145E               ldd       <Y0059              * 145E DC 59          \Y
                    addd      #1                  * 1460 C3 00 01       C..
                    std       <Y0059              * 1463 DD 59          ]Y
                    ldd       2,S                 * 1465 EC 62          lb
                    pshs      D                   * 1467 34 06          4.
                    ldd       2,S                 * 1469 EC 62          lb
                    pshs      D                   * 146B 34 06          4.
                    ldd       <U007A              * 146D DC 7A          \z
                    pshs      D                   * 146F 34 06          4.
L1471               lbsr      L2207               * 1471 17 0D 93       ...
                    leas      6,S                 * 1474 32 66          2f
L1476               leax      >Y07C7,Y            * 1476 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 147A AC A9 07 E5    ,).e
                    lbcs      L1416               * 147E 10 25 FF 94    .%..
                    lbra      L157C               * 1482 16 00 F7       ..w
L1485               pshs      U,D                 * 1485 34 46          4F
                    ldb       <U005B              * 1487 D6 5B          V[
                    beq       L14E2               * 1489 27 57          'W
                    leax      >Y07C7,Y            * 148B 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 148F AC A9 07 E5    ,).e
                    bcc       L14E2               * 1493 24 4D          $M
                    leau      >Y07C7,Y            * 1495 33 A9 07 C7    3).G
                    bra       L14DB               * 1499 20 40           @
L149B               pshs      U                   * 149B 34 40          4@
                    bsr       L14E6               * 149D 8D 47          .G
                    std       ,S++                * 149F ED E1          ma
                    bne       L14DB               * 14A1 26 38          &8
                    ldd       1,U                 * 14A3 EC 41          lA
                    pshs      D                   * 14A5 34 06          4.
                    lbsr      L1580               * 14A7 17 00 D6       ..V
                    std       ,S++                * 14AA ED E1          ma
                    beq       L14D9               * 14AC 27 2B          '+
                    stu       ,S                  * 14AE EF E4          od
                    bra       L14BE               * 14B0 20 0C           .
L14B2               ldb       ,U                  * 14B2 E6 C4          fD
                    ldx       ,S                  * 14B4 AE E4          .d
                    stb       -3,X                * 14B6 E7 1D          g.
                    ldd       1,U                 * 14B8 EC 41          lA
                    ldx       ,S                  * 14BA AE E4          .d
                    std       -2,X                * 14BC ED 1E          m.
L14BE               ldd       ,S                  * 14BE EC E4          ld
                    addd      #3                  * 14C0 C3 00 03       C..
                    std       ,S                  * 14C3 ED E4          md
                    cmpd      >Y07E5,Y            * 14C5 10 A3 A9 07 E5 .#).e
                    bcs       L14B2               * 14CA 25 E6          %f
                    ldd       >Y07E5,Y            * 14CC EC A9 07 E5    l).e
                    addd      #-3                 * 14D0 C3 FF FD       C.}
                    std       >Y07E5,Y            * 14D3 ED A9 07 E5    m).e
                    bra       L14DB               * 14D7 20 02           .
L14D9               leau      3,U                 * 14D9 33 43          3C
L14DB               cmpu      >Y07E5,Y            * 14DB 11 A3 A9 07 E5 .#).e
                    bcs       L149B               * 14E0 25 B9          %9
L14E2               clra                          * 14E2 4F             O
                    clrb                          * 14E3 5F             _
                    puls      PC,U,X              * 14E4 35 D0          5P
L14E6               pshs      U                   * 14E6 34 40          4@
                    ldu       4,S                 * 14E8 EE 64          nd
                    leas      -4,S                * 14EA 32 7C          2|
                    ldb       [<$01,U]            * 14EC E6 D8 01       fX.
                    sex                           * 14EF 1D             .
                    pshs      D                   * 14F0 34 06          4.
                    ldb       <U0061              * 14F2 D6 61          Va
                    sex                           * 14F4 1D             .
                    ora       ,S+                 * 14F5 AA E0          *`
                    orb       ,S+                 * 14F7 EA E0          j`
                    pshs      D                   * 14F9 34 06          4.
                    ldb       ,U                  * 14FB E6 C4          fD
                    sex                           * 14FD 1D             .
                    ora       ,S+                 * 14FE AA E0          *`
                    orb       ,S+                 * 1500 EA E0          j`
                    std       ,S                  * 1502 ED E4          md
                    stu       2,S                 * 1504 EF 62          ob
                    lbra      L156A               * 1506 16 00 61       ..a
L1509               ldx       2,S                 * 1509 AE 62          .b
                    ldb       [<$01,X]            * 150B E6 98 01       f..
                    sex                           * 150E 1D             .
                    pshs      D                   * 150F 34 06          4.
                    ldb       <U0061              * 1511 D6 61          Va
                    sex                           * 1513 1D             .
                    ora       ,S+                 * 1514 AA E0          *`
                    orb       ,S+                 * 1516 EA E0          j`
                    pshs      D                   * 1518 34 06          4.
                    ldb       [<$04,S]            * 151A E6 F8 04       fx.
                    sex                           * 151D 1D             .
                    ora       ,S+                 * 151E AA E0          *`
                    orb       ,S+                 * 1520 EA E0          j`
                    eora      ,S                  * 1522 A8 E4          (d
                    eorb      1,S                 * 1524 E8 61          ha
                    cmpd      #64                 * 1526 10 83 00 40    ...@
                    bne       L156A               * 152A 26 3E          &>
                    bra       L1538               * 152C 20 0A           .
L152E               ldb       3,U                 * 152E E6 43          fC
                    stb       ,U                  * 1530 E7 C4          gD
                    ldd       4,U                 * 1532 EC 44          lD
                    std       1,U                 * 1534 ED 41          mA
                    leau      3,U                 * 1536 33 43          3C
L1538               pshs      U                   * 1538 34 40          4@
                    ldd       #3                  * 153A CC 00 03       L..
                    addd      ,S++                * 153D E3 E1          ca
                    cmpd      2,S                 * 153F 10 A3 62       .#b
                    bcs       L152E               * 1542 25 EA          %j
                    bra       L1553               * 1544 20 0D           .
L1546               ldb       [<$02,S]            * 1546 E6 F8 02       fx.
                    stb       ,U                  * 1549 E7 C4          gD
                    ldx       2,S                 * 154B AE 62          .b
                    ldd       1,X                 * 154D EC 01          l.
                    std       1,U                 * 154F ED 41          mA
                    leau      3,U                 * 1551 33 43          3C
L1553               ldd       2,S                 * 1553 EC 62          lb
                    addd      #3                  * 1555 C3 00 03       C..
                    std       2,S                 * 1558 ED 62          mb
                    cmpd      >Y07E5,Y            * 155A 10 A3 A9 07 E5 .#).e
                    bcs       L1546               * 155F 25 E5          %e
                    stu       >Y07E5,Y            * 1561 EF A9 07 E5    o).e
                    ldd       #1                  * 1565 CC 00 01       L..
                    bra       L157C               * 1568 20 12           .
L156A               ldd       2,S                 * 156A EC 62          lb
                    addd      #3                  * 156C C3 00 03       C..
                    std       2,S                 * 156F ED 62          mb
                    cmpd      >Y07E5,Y            * 1571 10 A3 A9 07 E5 .#).e
                    lbcs      L1509               * 1576 10 25 FF 8F    .%..
                    clra                          * 157A 4F             O
                    clrb                          * 157B 5F             _
L157C               leas      4,S                 * 157C 32 64          2d
                    puls      PC,U                * 157E 35 C0          5@
L1580               pshs      U                   * 1580 34 40          4@
                    ldu       4,S                 * 1582 EE 64          nd
                    ldb       ,U                  * 1584 E6 C4          fD
                    clra                          * 1586 4F             O
                    andb      #7                  * 1587 C4 07          D.
                    cmpd      #4                  * 1589 10 83 00 04    ....
                    bne       L159F               * 158D 26 10          &.
                    ldb       <U0061              * 158F D6 61          Va
                    clra                          * 1591 4F             O
                    andb      #176                * 1592 C4 B0          D0
                    cmpd      #160                * 1594 10 83 00 A0    ...
                    bne       L159F               * 1598 26 05          &.
                    ldd       #1                  * 159A CC 00 01       L..
                    bra       L15A1               * 159D 20 02           .
L159F               clra                          * 159F 4F             O
                    clrb                          * 15A0 5F             _
L15A1               puls      PC,U                * 15A1 35 C0          5@
L15A3               pshs      U                   * 15A3 34 40          4@
                    ldd       <U0062              * 15A5 DC 62          \b
                    addd      #1                  * 15A7 C3 00 01       C..
                    std       <U0062              * 15AA DD 62          ]b
                    lbsr      L1305               * 15AC 17 FD 56       .}V
                    std       -2,S                * 15AF ED 7E          m~
                    bne       L15B8               * 15B1 26 05          &.
                    lbsr      L163E               * 15B3 17 00 88       ...
                    puls      PC,U                * 15B6 35 C0          5@
L15B8               bsr       L15BC               * 15B8 8D 02          ..
                    puls      PC,U                * 15BA 35 C0          5@
L15BC               pshs      U                   * 15BC 34 40          4@
                    ldd       <U0037              * 15BE DC 37          \7
                    blt       L15D6               * 15C0 2D 14          -.
                    ldd       <U0037              * 15C2 DC 37          \7
                    bne       L15E9               * 15C4 26 23          &#
                    ldd       <U0033              * 15C6 DC 33          \3
                    cmpd      #127                * 15C8 10 83 00 7F    ....
                    bgt       L15D6               * 15CC 2E 08          ..
                    ldd       <U0033              * 15CE DC 33          \3
                    cmpd      #-128               * 15D0 10 83 FF 80    ....
                    bge       L15E9               * 15D4 2C 13          ,.
L15D6               ldd       <U0033              * 15D6 DC 33          \3
                    std       <U00BB              * 15D8 DD BB          ];
                    ldd       <U001B              * 15DA DC 1B          \.
                    addd      #2                  * 15DC C3 00 02       C..
                    std       <U001B              * 15DF DD 1B          ].
                    ldb       <U00BA              * 15E1 D6 BA          V:
                    sex                           * 15E3 1D             .
                    orb       #137                * 15E4 CA 89          J.
                    lbra      L16C6               * 15E6 16 00 DD       ..]
L15E9               ldd       <U0037              * 15E9 DC 37          \7
                    bne       L15F9               * 15EB 26 0C          &.
                    ldd       <U0033              * 15ED DC 33          \3
                    bne       L15F9               * 15EF 26 08          &.
                    ldb       <U00BA              * 15F1 D6 BA          V:
                    sex                           * 15F3 1D             .
                    orb       #132                * 15F4 CA 84          J.
                    lbra      L16C6               * 15F6 16 00 CD       ..M
L15F9               ldd       <U0037              * 15F9 DC 37          \7
                    bgt       L1611               * 15FB 2E 14          ..
                    ldd       <U0035              * 15FD DC 35          \5
                    bne       L1611               * 15FF 26 10          &.
                    ldd       <U0033              * 1601 DC 33          \3
                    cmpd      #15                 * 1603 10 83 00 0F    ....
                    bgt       L1611               * 1607 2E 08          ..
                    ldd       <U0033              * 1609 DC 33          \3
                    cmpd      #-16                * 160B 10 83 FF F0    ...p
                    bge       L162B               * 160F 2C 1A          ,.
L1611               ldd       <U0033              * 1611 DC 33          \3
                    stb       <U00BB              * 1613 D7 BB          W;
                    ldd       <U001B              * 1615 DC 1B          \.
                    addd      #1                  * 1617 C3 00 01       C..
                    std       <U001B              * 161A DD 1B          ].
                    ldb       <U0061              * 161C D6 61          Va
                    sex                           * 161E 1D             .
                    orb       #8                  * 161F CA 08          J.
                    stb       <U0061              * 1621 D7 61          Wa
                    ldb       <U00BA              * 1623 D6 BA          V:
                    sex                           * 1625 1D             .
                    orb       #136                * 1626 CA 88          J.
                    lbra      L16C6               * 1628 16 00 9B       ...
L162B               ldb       <U00BA              * 162B D6 BA          V:
                    sex                           * 162D 1D             .
                    pshs      D                   * 162E 34 06          4.
                    ldd       <U0033              * 1630 DC 33          \3
                    clra                          * 1632 4F             O
                    andb      #31                 * 1633 C4 1F          D.
                    ora       ,S+                 * 1635 AA E0          *`
                    orb       ,S+                 * 1637 EA E0          j`
                    lbra      L16C6               * 1639 16 00 8A       ...
                    fcb       $35                 * 163C 35             5
                    fcb       $C0                 * 163D C0             @
L163E               pshs      U                   * 163E 34 40          4@
                    ldb       [>U0062,Y]          * 1640 E6 B9 00 62    f9.b
                    clra                          * 1644 4F             O
                    andb      #223                * 1645 C4 DF          D_
                    cmpd      #80                 * 1647 10 83 00 50    ...P
                    bne       L165A               * 164B 26 0D          &.
                    ldx       <U0062              * 164D 9E 62          .b
                    ldb       1,X                 * 164F E6 01          f.
                    clra                          * 1651 4F             O
                    andb      #223                * 1652 C4 DF          D_
                    cmpd      #67                 * 1654 10 83 00 43    ...C
                    beq       L165F               * 1658 27 05          '.
L165A               lbsr      L1368               * 165A 17 FD 0B       .}.
                    puls      PC,U                * 165D 35 C0          5@
L165F               ldd       <U0062              * 165F DC 62          \b
                    addd      #2                  * 1661 C3 00 02       C..
                    std       <U0062              * 1664 DD 62          ]b
                    ldb       [>U0062,Y]          * 1666 E6 B9 00 62    f9.b
                    clra                          * 166A 4F             O
                    andb      #223                * 166B C4 DF          D_
                    cmpd      #82                 * 166D 10 83 00 52    ...R
                    bne       L167A               * 1671 26 07          &.
                    ldd       <U0062              * 1673 DC 62          \b
                    addd      #1                  * 1675 C3 00 01       C..
                    std       <U0062              * 1678 DD 62          ]b
L167A               ldd       <U001B              * 167A DC 1B          \.
                    addd      #1                  * 167C C3 00 01       C..
                    std       <U001B              * 167F DD 1B          ].
                    ldb       <U0061              * 1681 D6 61          Va
                    sex                           * 1683 1D             .
                    orb       #128                * 1684 CA 80          J.
                    stb       <U0061              * 1686 D7 61          Wa
                    ldd       <U0033              * 1688 DC 33          \3
                    pshs      D                   * 168A 34 06          4.
                    ldd       <U004D              * 168C DC 4D          \M
                    addd      <U001B              * 168E D3 1B          S.
                    addd      #1                  * 1690 C3 00 01       C..
                    nega                          * 1693 40             @
                    negb                          * 1694 50             P
                    sbca      #0                  * 1695 82 00          ..
                    addd      ,S++                * 1697 E3 E1          ca
                    std       <U0033              * 1699 DD 33          ]3
                    ldd       <U0037              * 169B DC 37          \7
                    ble       L16B1               * 169D 2F 12          /.
                    ldd       <U0033              * 169F DC 33          \3
                    stb       <U00BB              * 16A1 D7 BB          W;
                    ldb       <U0061              * 16A3 D6 61          Va
                    sex                           * 16A5 1D             .
                    orb       #8                  * 16A6 CA 08          J.
                    stb       <U0061              * 16A8 D7 61          Wa
                    ldb       <U00BA              * 16AA D6 BA          V:
                    sex                           * 16AC 1D             .
                    orb       #140                * 16AD CA 8C          J.
                    bra       L16C6               * 16AF 20 15           .
L16B1               ldd       <U001B              * 16B1 DC 1B          \.
                    addd      #1                  * 16B3 C3 00 01       C..
                    std       <U001B              * 16B6 DD 1B          ].
                    ldd       <U0033              * 16B8 DC 33          \3
                    addd      #-1                 * 16BA C3 FF FF       C..
                    std       <U0033              * 16BD DD 33          ]3
                    std       <U00BB              * 16BF DD BB          ];
                    ldb       <U00BA              * 16C1 D6 BA          V:
                    sex                           * 16C3 1D             .
                    orb       #141                * 16C4 CA 8D          J.
L16C6               stb       <U00BA              * 16C6 D7 BA          W:
                    lbsr      L1375               * 16C8 17 FC AA       .|*
                    puls      PC,U                * 16CB 35 C0          5@
                    puls      PC,U                * 16CD 35 C0          5@
L16CF               fcc       "illegal addressing mode" * 16CF 69 6C 6C 65 67 61 6C 20 61 64 64 72 65 73 73 69 6E 67 20 6D 6F 64 65 illegal addressing mode
                    fcb       $00                 * 16E6 00             .
L16E7               fcc       "illegal index register" * 16E7 69 6C 6C 65 67 61 6C 20 69 6E 64 65 78 20 72 65 67 69 73 74 65 72 illegal index register
                    fcb       $00                 * 16FD 00             .
L16FE               fcc       "bracket missing"   * 16FE 62 72 61 63 6B 65 74 20 6D 69 73 73 69 6E 67 bracket missing
                    fcb       $00                 * 170D 00             .
                    pshs      U                   * 170E 34 40          4@
                    lbsr      L1771               * 1710 17 00 5E       ..^
                    std       -2,S                * 1713 ED 7E          m~
                    bne       L1725               * 1715 26 0E          &.
                    lbra      L17F8               * 1717 16 00 DE       ..^
                    bra       L1725               * 171A 20 09           .
L171C               clra                          * 171C 4F             O
                    clrb                          * 171D 5F             _
                    pshs      D                   * 171E 34 06          4.
                    lbsr      L1912               * 1720 17 01 EF       ..o
                    leas      2,S                 * 1723 32 62          2b
L1725               ldd       <U0031              * 1725 DC 31          \1
                    addd      #-1                 * 1727 C3 FF FF       C..
                    std       <U0031              * 172A DD 31          ]1
                    subd      #-1                 * 172C 83 FF FF       ...
                    bne       L171C               * 172F 26 EB          &k
                    lbra      L1D8B               * 1731 16 06 57       ..W
                    pshs      U                   * 1734 34 40          4@
                    bsr       L1771               * 1736 8D 39          .9
                    std       -2,S                * 1738 ED 7E          m~
                    lbeq      L17F8               * 173A 10 27 00 BA    .'.:
                    leax      >reldt,Y            * 173E 30 A9 00 51    0).Q
                    stx       <U004F              * 1742 9F 4F          .O
                    pshs      X                   * 1744 34 10          4.
                    lbsr      L179F               * 1746 17 00 56       ..V
                    std       [,S++]              * 1749 ED F1          mq
                    ldd       <U0064              * 174B DC 64          \d
                    beq       L1764               * 174D 27 15          '.
                    ldb       <U005D              * 174F D6 5D          V]
                    sex                           * 1751 1D             .
                    andb      #254                * 1752 C4 FE          D~
                    pshs      D                   * 1754 34 06          4.
                    lbsr      L20A1               * 1756 17 09 48       ..H
                    leas      2,S                 * 1759 32 62          2b
                    ldd       <reldt              * 175B DC 51          \Q
                    pshs      D                   * 175D 34 06          4.
                    lbsr      L20E0               * 175F 17 09 7E       ..~
                    leas      2,S                 * 1762 32 62          2b
L1764               ldd       <reldt              * 1764 DC 51          \Q
                    addd      <U0031              * 1766 D3 31          S1
                    pshs      D                   * 1768 34 06          4.
                    bsr       L17AF               * 176A 8D 43          .C
                    leas      2,S                 * 176C 32 62          2b
                    lbra      L1D8B               * 176E 16 06 1A       ...
L1771               pshs      U,D                 * 1771 34 46          4F
                    clra                          * 1773 4F             O
                    clrb                          * 1774 5F             _
                    std       ,S                  * 1775 ED E4          md
                    ldu       <U0078              * 1777 DE 78          ^x
                    lbsr      L2426               * 1779 17 0C AA       ..*
                    std       -2,S                * 177C ED 7E          m~
                    beq       L1799               * 177E 27 19          '.
                    lbsr      L1485               * 1780 17 FD 02       .}.
                    leax      >Y07C7,Y            * 1783 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 1787 AC A9 07 E5    ,).e
                    bne       L1794               * 178B 26 07          &.
                    ldd       #1                  * 178D CC 00 01       L..
                    std       ,S                  * 1790 ED E4          md
                    bra       L1799               * 1792 20 05           .
L1794               lbsr      L0DEB               * 1794 17 F6 54       .vT
                    std       <U0031              * 1797 DD 31          ]1
L1799               stu       <U0078              * 1799 DF 78          _x
                    ldd       ,S                  * 179B EC E4          ld
                    puls      PC,U,X              * 179D 35 D0          5P
L179F               pshs      U                   * 179F 34 40          4@
                    ldd       <U0053              * 17A1 DC 53          \S
                    bne       L17A9               * 17A3 26 04          &.
                    clra                          * 17A5 4F             O
                    clrb                          * 17A6 5F             _
                    bra       L17AD               * 17A7 20 04           .
L17A9               ldd       [>U0053,Y]          * 17A9 EC B9 00 53    l9.S
L17AD               puls      PC,U                * 17AD 35 C0          5@
L17AF               pshs      U                   * 17AF 34 40          4@
                    ldd       <U0053              * 17B1 DC 53          \S
                    beq       L17BB               * 17B3 27 06          '.
                    ldd       4,S                 * 17B5 EC 64          ld
                    std       [>U0053,Y]          * 17B7 ED B9 00 53    m9.S
L17BB               ldd       4,S                 * 17BB EC 64          ld
                    puls      PC,U                * 17BD 35 C0          5@
                    pshs      U                   * 17BF 34 40          4@
                    ldd       #6                  * 17C1 CC 00 06       L..
                    pshs      D                   * 17C4 34 06          4.
                    bsr       L17D5               * 17C6 8D 0D          ..
                    puls      PC,U,X              * 17C8 35 D0          5P
                    pshs      U                   * 17CA 34 40          4@
                    ldd       #5                  * 17CC CC 00 05       L..
                    pshs      D                   * 17CF 34 06          4.
                    bsr       L17D5               * 17D1 8D 02          ..
                    puls      PC,U,X              * 17D3 35 D0          5P
L17D5               pshs      U                   * 17D5 34 40          4@
                    ldd       <U0064              * 17D7 DC 64          \d
                    bne       L17E6               * 17D9 26 0B          &.
                    leax      >L1D90,PC           * 17DB 30 8D 05 B1    0..1
                    pshs      X                   * 17DF 34 10          4.
                    lbsr      L074E               * 17E1 17 EF 6A       .oj
                    puls      PC,U,X              * 17E4 35 D0          5P
L17E6               ldd       4,S                 * 17E6 EC 64          ld
                    pshs      D                   * 17E8 34 06          4.
                    lbsr      L20A1               * 17EA 17 08 B4       ..4
                    leas      2,S                 * 17ED 32 62          2b
                    ldu       <U0078              * 17EF DE 78          ^x
                    lbsr      L2426               * 17F1 17 0C 32       ..2
                    std       -2,S                * 17F4 ED 7E          m~
                    bne       L17FC               * 17F6 26 04          &.
L17F8               clra                          * 17F8 4F             O
                    clrb                          * 17F9 5F             _
                    puls      PC,U                * 17FA 35 C0          5@
L17FC               stu       <U0078              * 17FC DF 78          _x
                    lbsr      L1485               * 17FE 17 FC 84       .|.
                    ldd       <U0031              * 1801 DC 31          \1
                    pshs      D                   * 1803 34 06          4.
                    lbsr      L20E0               * 1805 17 08 D8       ..X
                    leas      2,S                 * 1808 32 62          2b
                    leax      >U0031,Y            * 180A 30 A9 00 31    0).1
                    stx       <U004F              * 180E 9F 4F          .O
                    lbra      L1D8B               * 1810 16 05 78       ..x
                    pshs      U                   * 1813 34 40          4@
                    ldd       #1                  * 1815 CC 00 01       L..
                    pshs      D                   * 1818 34 06          4.
                    bsr       L1829               * 181A 8D 0D          ..
                    puls      PC,U,X              * 181C 35 D0          5P
                    pshs      U                   * 181E 34 40          4@
                    ldd       #2                  * 1820 CC 00 02       L..
                    pshs      D                   * 1823 34 06          4.
                    bsr       L1829               * 1825 8D 02          ..
                    puls      PC,U,X              * 1827 35 D0          5P
L1829               pshs      U,X,D               * 1829 34 56          4V
                    ldb       [>U0062,Y]          * 182B E6 B9 00 62    f9.b
                    stb       1,S                 * 182F E7 61          ga
                    lbeq      L18B2               * 1831 10 27 00 7D    .'.}
                    ldd       <U0062              * 1835 DC 62          \b
                    std       2,S                 * 1837 ED 62          mb
                    bra       L1848               * 1839 20 0D           .
L183B               ldb       ,S                  * 183B E6 E4          fd
                    sex                           * 183D 1D             .
                    pshs      D                   * 183E 34 06          4.
                    ldb       3,S                 * 1840 E6 63          fc
                    sex                           * 1842 1D             .
                    cmpd      ,S++                * 1843 10 A3 E1       .#a
                    beq       L1854               * 1846 27 0C          '.
L1848               ldx       2,S                 * 1848 AE 62          .b
                    leax      1,X                 * 184A 30 01          0.
                    stx       2,S                 * 184C AF 62          /b
                    ldb       ,X                  * 184E E6 84          f.
                    stb       ,S                  * 1850 E7 E4          gd
                    bne       L183B               * 1852 26 E7          &g
L1854               ldb       ,S                  * 1854 E6 E4          fd
                    lbeq      L18AE               * 1856 10 27 00 54    .'.T
                    ldd       2,S                 * 185A EC 62          lb
                    subd      #2                  * 185C 83 00 02       ...
                    std       2,S                 * 185F ED 62          mb
                    cmpd      <U0062              * 1861 10 93 62       ..b
                    bcs       L18A2               * 1864 25 3C          %<
                    bra       L1878               * 1866 20 10           .
L1868               ldx       <U0062              * 1868 9E 62          .b
                    leax      1,X                 * 186A 30 01          0.
                    stx       <U0062              * 186C 9F 62          .b
                    ldb       ,X                  * 186E E6 84          f.
                    sex                           * 1870 1D             .
                    pshs      D                   * 1871 34 06          4.
                    lbsr      L1912               * 1873 17 00 9C       ...
                    leas      2,S                 * 1876 32 62          2b
L1878               ldd       <U0062              * 1878 DC 62          \b
                    cmpd      2,S                 * 187A 10 A3 62       .#b
                    bcs       L1868               * 187D 25 E9          %i
                    ldx       <U0062              * 187F 9E 62          .b
                    leax      1,X                 * 1881 30 01          0.
                    stx       <U0062              * 1883 9F 62          .b
                    ldb       ,X                  * 1885 E6 84          f.
                    stb       ,S                  * 1887 E7 E4          gd
                    ldd       8,S                 * 1889 EC 68          lh
                    cmpd      #2                  * 188B 10 83 00 02    ....
                    bne       L1898               * 188F 26 07          &.
                    ldb       ,S                  * 1891 E6 E4          fd
                    sex                           * 1893 1D             .
                    orb       #128                * 1894 CA 80          J.
                    stb       ,S                  * 1896 E7 E4          gd
L1898               ldb       ,S                  * 1898 E6 E4          fd
                    sex                           * 189A 1D             .
                    pshs      D                   * 189B 34 06          4.
                    lbsr      L1912               * 189D 17 00 72       ..r
                    leas      2,S                 * 18A0 32 62          2b
L18A2               ldd       <U0062              * 18A2 DC 62          \b
                    addd      #2                  * 18A4 C3 00 02       C..
                    std       <U0062              * 18A7 DD 62          ]b
                    ldd       #1                  * 18A9 CC 00 01       L..
                    bra       L18EF               * 18AC 20 41           A
L18AE               ldd       2,S                 * 18AE EC 62          lb
                    std       <U0062              * 18B0 DD 62          ]b
L18B2               bsr       L18B6               * 18B2 8D 02          ..
                    bra       L18EF               * 18B4 20 39           9
L18B6               pshs      U                   * 18B6 34 40          4@
                    leax      >L1D9E,PC           * 18B8 30 8D 04 E2    0..b
                    pshs      X                   * 18BC 34 10          4.
                    lbsr      L074E               * 18BE 17 EE 8D       .n.
                    puls      PC,U,X              * 18C1 35 D0          5P
                    pshs      U                   * 18C3 34 40          4@
                    leax      >U0032,Y            * 18C5 30 A9 00 32    0).2
                    stx       >U00CA,Y            * 18C9 AF A9 00 CA    /).J
                    ldd       #1                  * 18CD CC 00 01       L..
                    pshs      D                   * 18D0 34 06          4.
                    leax      >L23D4,PC           * 18D2 30 8D 0A FE    0..~
                    bra       L18EB               * 18D6 20 13           .
                    pshs      U                   * 18D8 34 40          4@
                    leax      >U0031,Y            * 18DA 30 A9 00 31    0).1
                    stx       >U00CA,Y            * 18DE AF A9 00 CA    /).J
                    ldd       #2                  * 18E2 CC 00 02       L..
                    pshs      D                   * 18E5 34 06          4.
                    leax      >L23B8,PC           * 18E7 30 8D 0A CD    0..M
L18EB               pshs      X                   * 18EB 34 10          4.
                    bsr       L18F3               * 18ED 8D 04          ..
L18EF               leas      4,S                 * 18EF 32 64          2d
                    puls      PC,U                * 18F1 35 C0          5@
L18F3               pshs      U                   * 18F3 34 40          4@
                    bra       L1900               * 18F5 20 09           .
L18F7               bsr       L1934               * 18F7 8D 3B          .;
                    ldd       <U0062              * 18F9 DC 62          \b
                    addd      #1                  * 18FB C3 00 01       C..
                    std       <U0062              * 18FE DD 62          ]b
L1900               ldd       6,S                 * 1900 EC 66          lf
                    std       <U001B              * 1902 DD 1B          ].
                    jsr       [<$04,S]            * 1904 AD F8 04       -x.
                    ldb       [>U0062,Y]          * 1907 E6 B9 00 62    f9.b
                    cmpb      #44                 * 190B C1 2C          A,
                    beq       L18F7               * 190D 27 E8          'h
                    lbra      L1D8B               * 190F 16 04 79       ..y
L1912               pshs      U                   * 1912 34 40          4@
                    ldd       <U001B              * 1914 DC 1B          \.
                    cmpd      #4                  * 1916 10 83 00 04    ....
                    blt       L191E               * 191A 2D 02          -.
                    bsr       L1934               * 191C 8D 16          ..
L191E               ldd       <U001B              * 191E DC 1B          \.
                    addd      #1                  * 1920 C3 00 01       C..
                    std       <U001B              * 1923 DD 1B          ].
                    subd      #1                  * 1925 83 00 01       ...
                    addd      >U00CA,Y            * 1928 E3 A9 00 CA    c).J
                    tfr       D,X                 * 192C 1F 01          ..
                    ldb       5,S                 * 192E E6 65          fe
                    stb       ,X                  * 1930 E7 84          g.
                    puls      PC,U                * 1932 35 C0          5@
L1934               pshs      U                   * 1934 34 40          4@
                    ldd       <U001B              * 1936 DC 1B          \.
                    pshs      D                   * 1938 34 06          4.
                    ldd       >U00CA,Y            * 193A EC A9 00 CA    l).J
                    pshs      D                   * 193E 34 06          4.
                    lbsr      L2E3B               * 1940 17 14 F8       ..x
                    leas      4,S                 * 1943 32 64          2d
                    ldd       <U003D              * 1945 DC 3D          \=
                    beq       L1979               * 1947 27 30          '0
                    lbsr      L05C5               * 1949 17 EC 79       .ly
                    ldb       <U005B              * 194C D6 5B          V[
                    beq       L1961               * 194E 27 11          '.
                    ldb       <U00C4              * 1950 D6 C4          VD
                    beq       L1961               * 1952 27 0D          '.
                    ldb       <U00C3              * 1954 D6 C3          VC
                    ble       L1961               * 1956 2F 09          /.
                    ldb       <U00C1              * 1958 D6 C1          VA
                    ble       L1961               * 195A 2F 05          /.
                    ldd       #1                  * 195C CC 00 01       L..
                    bra       L1963               * 195F 20 02           .
L1961               clra                          * 1961 4F             O
                    clrb                          * 1962 5F             _
L1963               std       <U003D              * 1963 DD 3D          ]=
                    clra                          * 1965 4F             O
                    clrb                          * 1966 5F             _
                    std       <U006C              * 1967 DD 6C          ]l
                    std       <U006A              * 1969 DD 6A          ]j
                    std       <U0066              * 196B DD 66          ]f
                    std       <U0064              * 196D DD 64          ]d
                    ldd       <U004B              * 196F DC 4B          \K
                    beq       L1979               * 1971 27 06          '.
                    ldd       [>U004B,Y]          * 1973 EC B9 00 4B    l9.K
                    std       <reldt              * 1977 DD 51          ]Q
L1979               clra                          * 1979 4F             O
                    clrb                          * 197A 5F             _
                    std       <U001B              * 197B DD 1B          ].
                    puls      PC,U                * 197D 35 C0          5@
                    pshs      U                   * 197F 34 40          4@
                    ldd       #3                  * 1981 CC 00 03       L..
                    std       <U001B              * 1984 DD 1B          ].
                    lbsr      L23D4               * 1986 17 0A 4B       ..K
                    ldd       #16                 * 1989 CC 00 10       L..
                    stb       <Y00B9              * 198C D7 B9          W9
                    ldd       #63                 * 198E CC 00 3F       L.?
                    stb       <U00BA              * 1991 D7 BA          W:
                    ldd       <U0031              * 1993 DC 31          \1
                    stb       <U00BB              * 1995 D7 BB          W;
                    lbra      L1D8B               * 1997 16 03 F1       ..q
L199A               pshs      U                   * 199A 34 40          4@
                    ldb       [>U0062,Y]          * 199C E6 B9 00 62    f9.b
                    cmpb      #44                 * 19A0 C1 2C          A,
                    bne       L19AB               * 19A2 26 07          &.
                    ldd       <U0062              * 19A4 DC 62          \b
                    addd      #1                  * 19A6 C3 00 01       C..
                    bra       L19F6               * 19A9 20 4B           K
L19AB               leax      >L1DB2,PC           * 19AB 30 8D 04 03    0...
                    pshs      X                   * 19AF 34 10          4.
                    lbsr      L074E               * 19B1 17 ED 9A       .m.
                    puls      PC,U,X              * 19B4 35 D0          5P
                    pshs      U                   * 19B6 34 40          4@
                    lbsr      L1771               * 19B8 17 FD B6       .}6
                    ldd       <U004B              * 19BB DC 4B          \K
                    beq       L19C5               * 19BD 27 06          '.
                    ldd       <U0031              * 19BF DC 31          \1
                    std       [>U004B,Y]          * 19C1 ED B9 00 4B    m9.K
L19C5               puls      PC,U                * 19C5 35 C0          5@
                    pshs      U                   * 19C7 34 40          4@
                    puls      PC,U                * 19C9 35 C0          5@
                    pshs      U                   * 19CB 34 40          4@
                    leax      >Y05C7,Y            * 19CD 30 A9 05 C7    0).G
                    pshs      X                   * 19D1 34 10          4.
                    bsr       L19D7               * 19D3 8D 02          ..
                    puls      PC,U,X              * 19D5 35 D0          5P
L19D7               pshs      U                   * 19D7 34 40          4@
                    ldu       4,S                 * 19D9 EE 64          nd
                    ldb       <U005B              * 19DB D6 5B          V[
                    bne       L19E5               * 19DD 26 06          &.
                    ldb       ,U                  * 19DF E6 C4          fD
                    lbne      L1D8B               * 19E1 10 26 03 A6    .&.&
L19E5               ldx       <U0062              * 19E5 9E 62          .b
                    leax      1,X                 * 19E7 30 01          0.
                    stx       <U0062              * 19E9 9F 62          .b
                    ldb       -1,X                * 19EB E6 1F          f.
                    stb       ,U+                 * 19ED E7 C0          g@
                    bne       L19E5               * 19EF 26 F4          &t
                    ldd       <U0062              * 19F1 DC 62          \b
                    addd      #-1                 * 19F3 C3 FF FF       C..
L19F6               std       <U0062              * 19F6 DD 62          ]b
                    lbra      L1D8B               * 19F8 16 03 90       ...
                    pshs      U                   * 19FB 34 40          4@
                    leax      >Y063F,Y            * 19FD 30 A9 06 3F    0).?
                    pshs      X                   * 1A01 34 10          4.
                    bsr       L19D7               * 1A03 8D D2          .R
                    puls      PC,U,X              * 1A05 35 D0          5P
                    pshs      U                   * 1A07 34 40          4@
                    lbsr      L298C               * 1A09 17 0F 80       ...
                    bra       L1A27               * 1A0C 20 19           .
                    pshs      U                   * 1A0E 34 40          4@
                    bsr       L1A2D               * 1A10 8D 1B          ..
                    std       -2,S                * 1A12 ED 7E          m~
                    beq       L1A2B               * 1A14 27 15          '.
                    bra       L1A1B               * 1A16 20 03           .
L1A18               lbsr      L2A4B               * 1A18 17 10 30       ..0
L1A1B               ldd       <U0031              * 1A1B DC 31          \1
                    addd      #-1                 * 1A1D C3 FF FF       C..
                    std       <U0031              * 1A20 DD 31          ]1
                    subd      #-1                 * 1A22 83 FF FF       ...
                    bne       L1A18               * 1A25 26 F1          &q
L1A27               clra                          * 1A27 4F             O
                    clrb                          * 1A28 5F             _
                    std       <U003D              * 1A29 DD 3D          ]=
L1A2B               puls      PC,U                * 1A2B 35 C0          5@

L1A2D               pshs      U                   * 1A2D 34 40          4@
                    lbsr      L274A               * 1A2F 17 0D 18       ...
                    std       -2,S                * 1A32 ED 7E          m~
                    beq       L1A3B               * 1A34 27 05          '.
                    ldd       #1                  * 1A36 CC 00 01       L..
                    bra       L1A46               * 1A39 20 0B           .
L1A3B               leax      >L1DC1,PC           * 1A3B 30 8D 03 82    0...
                    pshs      X                   * 1A3F 34 10          4.
                    lbsr      L074E               * 1A41 17 ED 0A       .m.
                    leas      2,S                 * 1A44 32 62          2b
L1A46               puls      PC,U                * 1A46 35 C0          5@
L1A48               pshs      U                   * 1A48 34 40          4@
                    leas      -3,S                * 1A4A 32 7D          2}
                    lbsr      L2229               * 1A4C 17 07 DA       ..Z
L1A4F               stb       ,S                  * 1A4F E7 E4          gd
                    ldb       ,S                  * 1A51 E6 E4          fd
                    cmpb      #45                 * 1A53 C1 2D          A-
                    beq       L1A5C               * 1A55 27 05          '.
                    ldd       #1                  * 1A57 CC 00 01       L..
                    bra       L1A5E               * 1A5A 20 02           .
L1A5C               clra                          * 1A5C 4F             O
                    clrb                          * 1A5D 5F             _
L1A5E               std       1,S                 * 1A5E ED 61          ma
                    bne       L1A71               * 1A60 26 0F          &.
                    ldd       #-1                 * 1A62 CC FF FF       L..
                    std       1,S                 * 1A65 ED 61          ma
                    ldx       <U0062              * 1A67 9E 62          .b
                    leax      1,X                 * 1A69 30 01          0.
                    stx       <U0062              * 1A6B 9F 62          .b
                    ldb       ,X                  * 1A6D E6 84          f.
                    stb       ,S                  * 1A6F E7 E4          gd
L1A71               ldb       ,S                  * 1A71 E6 E4          fd
                    sex                           * 1A73 1D             .
                    orb       #32                 * 1A74 CA 20          J
                    stb       ,S                  * 1A76 E7 E4          gd
                    leau      >Y0380,Y            * 1A78 33 A9 03 80    3)..
                    bra       L1A98               * 1A7C 20 1A           .
L1A7E               ldb       ,S                  * 1A7E E6 E4          fd
                    sex                           * 1A80 1D             .
                    pshs      D                   * 1A81 34 06          4.
                    ldb       ,U                  * 1A83 E6 C4          fD
                    sex                           * 1A85 1D             .
                    cmpd      ,S++                * 1A86 10 A3 E1       .#a
                    bne       L1A96               * 1A89 26 0B          &.
                    ldb       [<$01,U]            * 1A8B E6 D8 01       fX.
                    sex                           * 1A8E 1D             .
                    addd      1,S                 * 1A8F E3 61          ca
                    stb       [<$01,U]            * 1A91 E7 D8 01       gX.
                    bra       L1AA3               * 1A94 20 0D           .
L1A96               leau      3,U                 * 1A96 33 43          3C
L1A98               leax      >Y0398,Y            * 1A98 30 A9 03 98    0)..
                    pshs      X                   * 1A9C 34 10          4.
                    cmpu      ,S++                * 1A9E 11 A3 E1       .#a
                    bcs       L1A7E               * 1AA1 25 DB          %[
L1AA3               leax      >Y0398,Y            * 1AA3 30 A9 03 98    0)..
                    pshs      X                   * 1AA7 34 10          4.
                    cmpu      ,S++                * 1AA9 11 A3 E1       .#a
                    bcs       L1ADF               * 1AAC 25 31          %1
                    ldb       ,S                  * 1AAE E6 E4          fd
                    sex                           * 1AB0 1D             .
                    tfr       D,X                 * 1AB1 1F 01          ..
                    bra       L1AD3               * 1AB3 20 1E           .
L1AB5               lbsr      L1A2D               * 1AB5 17 FF 75       ..u
                    std       -2,S                * 1AB8 ED 7E          m~
                    beq       L1ACF               * 1ABA 27 13          '.
                    ldd       <U0031              * 1ABC DC 31          \1
                    std       <U0003              * 1ABE DD 03          ].
                    bra       L1ADF               * 1AC0 20 1D           .
L1AC2               lbsr      L1A2D               * 1AC2 17 FF 68       ..h
                    std       -2,S                * 1AC5 ED 7E          m~
                    beq       L1ACF               * 1AC7 27 06          '.
                    ldd       <U0031              * 1AC9 DC 31          \1
                    std       <U0005              * 1ACB DD 05          ].
                    bra       L1ADF               * 1ACD 20 10           .
L1ACF               bsr       L1AFD               * 1ACF 8D 2C          .,
                    bra       L1AF9               * 1AD1 20 26           &
L1AD3               cmpx      #100                * 1AD3 8C 00 64       ..d
                    beq       L1AB5               * 1AD6 27 DD          ']
                    cmpx      #119                * 1AD8 8C 00 77       ..w
                    beq       L1AC2               * 1ADB 27 E5          'e
                    bra       L1ACF               * 1ADD 20 F0           p
L1ADF               ldx       <U0062              * 1ADF 9E 62          .b
                    leax      1,X                 * 1AE1 30 01          0.
                    stx       <U0062              * 1AE3 9F 62          .b
                    ldb       ,X                  * 1AE5 E6 84          f.
                    cmpb      #44                 * 1AE7 C1 2C          A,
                    bne       L1AF6               * 1AE9 26 0B          &.
                    ldx       <U0062              * 1AEB 9E 62          .b
                    leax      1,X                 * 1AED 30 01          0.
                    stx       <U0062              * 1AEF 9F 62          .b
                    ldb       ,X                  * 1AF1 E6 84          f.
                    lbra      L1A4F               * 1AF3 16 FF 59       ..Y
L1AF6               ldd       #1                  * 1AF6 CC 00 01       L..
L1AF9               leas      3,S                 * 1AF9 32 63          2c
                    puls      PC,U                * 1AFB 35 C0          5@
L1AFD               pshs      U                   * 1AFD 34 40          4@
                    leax      >L1DCC,PC           * 1AFF 30 8D 02 C9    0..I
                    pshs      X                   * 1B03 34 10          4.
                    lbsr      L074E               * 1B05 17 EC 46       .lF
                    puls      PC,U,X              * 1B08 35 D0          5P
                    pshs      U                   * 1B0A 34 40          4@
                    lbsr      L2426               * 1B0C 17 09 17       ...
                    std       -2,S                * 1B0F ED 7E          m~
                    beq       L1B16               * 1B11 27 03          '.
                    lbsr      L1485               * 1B13 17 F9 6F       .yo
L1B16               leax      >Y07C7,Y            * 1B16 30 A9 07 C7    0).G
                    stx       >Y07E5,Y            * 1B1A AF A9 07 E5    /).e
                    lbeq      L1CEF               * 1B1E 10 27 01 CD    .'.M
                    ldd       <U0031              * 1B22 DC 31          \1
                    std       <U0027              * 1B24 DD 27          ]'
                    leax      >U0031,Y            * 1B26 30 A9 00 31    0).1
                    stx       <U004F              * 1B2A 9F 4F          .O
                    lbra      L1D8B               * 1B2C 16 02 5C       ..\
                    pshs      U                   * 1B2F 34 40          4@
                    leas      -1,S                * 1B31 32 7F          2.
                    ldd       <U0015              * 1B33 DC 15          \.
                    ldx       >Y03F4,Y            * 1B35 AE A9 03 F4    .).t
                    leax      2,X                 * 1B39 30 02          0.
                    stx       >Y03F4,Y            * 1B3B AF A9 03 F4    /).t
                    std       -2,X                * 1B3F ED 1E          m.
                    leax      >L1DD7,PC           * 1B41 30 8D 02 92    0...
                    pshs      X                   * 1B45 34 10          4.
                    ldd       <U0062              * 1B47 DC 62          \b
                    pshs      D                   * 1B49 34 06          4.
                    lbsr      L2955               * 1B4B 17 0E 07       ...
                    leas      4,S                 * 1B4E 32 64          2d
                    std       <U0015              * 1B50 DD 15          ].
                    bra       L1B5C               * 1B52 20 08           .
L1B54               ldb       ,S                  * 1B54 E6 E4          fd
                    cmpb      #32                 * 1B56 C1 20          A
                    lbeq      L1C5E               * 1B58 10 27 01 02    .'..
L1B5C               ldx       <U0062              * 1B5C 9E 62          .b
                    leax      1,X                 * 1B5E 30 01          0.
                    stx       <U0062              * 1B60 9F 62          .b
                    ldb       ,X                  * 1B62 E6 84          f.
                    stb       ,S                  * 1B64 E7 E4          gd
                    bne       L1B54               * 1B66 26 EC          &l
                    lbra      L1C5E               * 1B68 16 00 F3       ..s
                    pshs      U                   * 1B6B 34 40          4@
                    ldd       <U0031              * 1B6D DC 31          \1
                    lbne      L1CDE               * 1B6F 10 26 01 6B    .&.k
                    ldd       #1                  * 1B73 CC 00 01       L..
                    lbra      L1CE0               * 1B76 16 01 67       ..g
                    pshs      U                   * 1B79 34 40          4@
                    ldd       <U0031              * 1B7B DC 31          \1
                    lbeq      L1CDE               * 1B7D 10 27 01 5D    .'.]
                    ldd       #1                  * 1B81 CC 00 01       L..
                    lbra      L1CE0               * 1B84 16 01 59       ..Y
                    pshs      U                   * 1B87 34 40          4@
                    ldd       <U0031              * 1B89 DC 31          \1
                    lbge      L1CDE               * 1B8B 10 2C 01 4F    .,.O
                    ldd       #1                  * 1B8F CC 00 01       L..
                    lbra      L1CE0               * 1B92 16 01 4B       ..K
                    pshs      U                   * 1B95 34 40          4@
                    ldd       <U0031              * 1B97 DC 31          \1
                    lbgt      L1CDE               * 1B99 10 2E 01 41    ...A
                    ldd       #1                  * 1B9D CC 00 01       L..
                    lbra      L1CE0               * 1BA0 16 01 3D       ..=
                    pshs      U                   * 1BA3 34 40          4@
                    ldd       <U0031              * 1BA5 DC 31          \1
                    lblt      L1CDE               * 1BA7 10 2D 01 33    .-.3
                    ldd       #1                  * 1BAB CC 00 01       L..
                    lbra      L1CE0               * 1BAE 16 01 2F       ../
                    pshs      U                   * 1BB1 34 40          4@
                    ldd       <U0031              * 1BB3 DC 31          \1
                    lble      L1CDE               * 1BB5 10 2F 01 25    ./.%
                    ldd       #1                  * 1BB9 CC 00 01       L..
                    lbra      L1CE0               * 1BBC 16 01 21       ..!
L1BBF               pshs      U                   * 1BBF 34 40          4@
                    ldb       <U005B              * 1BC1 D6 5B          V[
                    lbne      L1CDE               * 1BC3 10 26 01 17    .&..
                    ldd       #1                  * 1BC7 CC 00 01       L..
                    lbra      L1CE0               * 1BCA 16 01 13       ...
                    pshs      U                   * 1BCD 34 40          4@
                    leax      >Y025E,Y            * 1BCF 30 A9 02 5E    0).^
                    stx       <U0072              * 1BD3 9F 72          .r
                    ldd       >Y000D,Y            * 1BD5 EC A9 00 0D    l)..
                    std       <U0074              * 1BD9 DD 74          ]t
                    leax      >Y035A,Y            * 1BDB 30 A9 03 5A    0).Z
                    stx       <U006E              * 1BDF 9F 6E          .n
                    leax      >U00A4,Y            * 1BE1 30 A9 00 A4    0).$
                    stx       <U007A              * 1BE5 9F 7A          .z
                    ldd       #1                  * 1BE7 CC 00 01       L..
                    stb       <U005C              * 1BEA D7 5C          W\
                    clra                          * 1BEC 4F             O
                    clrb                          * 1BED 5F             _
                    stb       <U0060              * 1BEE D7 60          W`
                    leax      >U0045,Y            * 1BF0 30 A9 00 45    0).E
                    stx       <U004B              * 1BF4 9F 4B          .K
                    leax      >U0041,Y            * 1BF6 30 A9 00 41    0).A
                    stx       <U0053              * 1BFA 9F 53          .S
                    bsr       L1C27               * 1BFC 8D 29          .)
                    std       -2,S                * 1BFE ED 7E          m~
                    beq       L1C1E               * 1C00 27 1C          '.
                    leax      >U0090,Y            * 1C02 30 A9 00 90    0)..
                    stx       <U007A              * 1C06 9F 7A          .z
                    ldd       #3                  * 1C08 CC 00 03       L..
                    stb       <U005C              * 1C0B D7 5C          W\
                    ldd       #16                 * 1C0D CC 00 10       L..
                    stb       <U0060              * 1C10 D7 60          W`
                    leax      >U0047,Y            * 1C12 30 A9 00 47    0).G
                    stx       <U004B              * 1C16 9F 4B          .K
                    leax      >U0043,Y            * 1C18 30 A9 00 43    0).C
                    stx       <U0053              * 1C1C 9F 53          .S
L1C1E               ldd       [>U004B,Y]          * 1C1E EC B9 00 4B    l9.K
                    std       <reldt              * 1C22 DD 51          ]Q
                    lbra      L1D8B               * 1C24 16 01 64       ..d
L1C27               pshs      U                   * 1C27 34 40          4@
                    leas      -1,S                * 1C29 32 7F          2.
                    ldb       [>U0062,Y]          * 1C2B E6 B9 00 62    f9.b
                    clra                          * 1C2F 4F             O
                    andb      #223                * 1C30 C4 DF          D_
                    stb       ,S                  * 1C32 E7 E4          gd
                    beq       L1C6E               * 1C34 27 38          '8
                    ldb       ,S                  * 1C36 E6 E4          fd
                    cmpb      #68                 * 1C38 C1 44          AD
                    bne       L1C6E               * 1C3A 26 32          &2
                    ldx       <U0062              * 1C3C 9E 62          .b
                    ldb       1,X                 * 1C3E E6 01          f.
                    clra                          * 1C40 4F             O
                    andb      #223                * 1C41 C4 DF          D_
                    cmpd      #80                 * 1C43 10 83 00 50    ...P
                    bne       L1C6E               * 1C47 26 25          &%
                    ldx       <U0062              * 1C49 9E 62          .b
                    ldb       2,X                 * 1C4B E6 02          f.
                    beq       L1C57               * 1C4D 27 08          '.
                    ldx       <U0062              * 1C4F 9E 62          .b
                    ldb       2,X                 * 1C51 E6 02          f.
                    cmpb      #32                 * 1C53 C1 20          A
                    bne       L1C63               * 1C55 26 0C          &.
L1C57               ldd       <U0062              * 1C57 DC 62          \b
                    addd      #2                  * 1C59 C3 00 02       C..
                    std       <U0062              * 1C5C DD 62          ]b
L1C5E               ldd       #1                  * 1C5E CC 00 01       L..
                    bra       L1C6E               * 1C61 20 0B           .
L1C63               leax      >L1DD9,PC           * 1C63 30 8D 01 72    0..r
                    pshs      X                   * 1C67 34 10          4.
                    lbsr      L074E               * 1C69 17 EA E2       .jb
                    leas      2,S                 * 1C6C 32 62          2b
L1C6E               leas      1,S                 * 1C6E 32 61          2a
                    puls      PC,U                * 1C70 35 C0          5@
L1C72               pshs      U                   * 1C72 34 40          4@
                    clra                          * 1C74 4F             O
                    clrb                          * 1C75 5F             _
                    std       <U001B              * 1C76 DD 1B          ].
                    leax      >Y0106,Y            * 1C78 30 A9 01 06    0)..
                    stx       <U0072              * 1C7C 9F 72          .r
                    ldd       >Y0007,Y            * 1C7E EC A9 00 07    l)..
                    std       <U0074              * 1C82 DD 74          ]t
                    leax      >Y0332,Y            * 1C84 30 A9 03 32    0).2
                    stx       <U006E              * 1C88 9F 6E          .n
                    clra                          * 1C8A 4F             O
                    clrb                          * 1C8B 5F             _
                    std       <U007A              * 1C8C DD 7A          ]z
                    ldd       #4                  * 1C8E CC 00 04       L..
                    stb       <U005C              * 1C91 D7 5C          W\
                    ldd       #160                * 1C93 CC 00 A0       L.
                    stb       <U005E              * 1C96 D7 5E          W^
                    clra                          * 1C98 4F             O
                    clrb                          * 1C99 5F             _
                    stb       <U0060              * 1C9A D7 60          W`
                    clra                          * 1C9C 4F             O
                    clrb                          * 1C9D 5F             _
                    std       <U0053              * 1C9E DD 53          ]S
                    std       <U004B              * 1CA0 DD 4B          ]K
                    lbra      L1D8B               * 1CA2 16 00 E6       ..f
                    pshs      U                   * 1CA5 34 40          4@
                    ldd       <U006A              * 1CA7 DC 6A          \j
                    beq       L1CAF               * 1CA9 27 04          '.
                    ldd       <U006A              * 1CAB DC 6A          \j
                    bra       L1CB5               * 1CAD 20 06           .
L1CAF               leax      >L1DE8,PC           * 1CAF 30 8D 01 35    0..5
                    tfr       X,D                 * 1CB3 1F 10          ..
L1CB5               pshs      D                   * 1CB5 34 06          4.
                    lbsr      L074E               * 1CB7 17 EA 94       .j.
                    puls      PC,U,X              * 1CBA 35 D0          5P
                    pshs      U                   * 1CBC 34 40          4@
                    leax      >Y06C1,Y            * 1CBE 30 A9 06 C1    0).A
                    lda       ,X                  * 1CC2 A6 84          &.
                    ora       1,X                 * 1CC4 AA 01          *.
                    ora       2,X                 * 1CC6 AA 02          *.
                    ora       3,X                 * 1CC8 AA 03          *.
                    beq       L1CD7               * 1CCA 27 0B          '.
                    leax      >L1DED,PC           * 1CCC 30 8D 01 1D    0...
                    pshs      X                   * 1CD0 34 10          4.
                    lbsr      L074E               * 1CD2 17 EA 79       .jy
                    puls      PC,U,X              * 1CD5 35 D0          5P
L1CD7               lbsr      L2426               * 1CD7 17 07 4C       ..L
                    std       -2,S                * 1CDA ED 7E          m~
                    bne       L1CE2               * 1CDC 26 04          &.
L1CDE               clra                          * 1CDE 4F             O
                    clrb                          * 1CDF 5F             _
L1CE0               puls      PC,U                * 1CE0 35 C0          5@
L1CE2               lbsr      L1485               * 1CE2 17 F7 A0       .w
                    leax      >Y07C7,Y            * 1CE5 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 1CE9 AC A9 07 E5    ,).e
                    beq       L1CF4               * 1CED 27 05          '.
L1CEF               lbsr      L0DEB               * 1CEF 17 F0 F9       .py
                    puls      PC,U                * 1CF2 35 C0          5@
L1CF4               ldd       <U0031              * 1CF4 DC 31          \1
                    std       <U00D0              * 1CF6 DD D0          ]P
                    beq       L1D14               * 1CF8 27 1A          '.
                    leax      >Y06C1,Y            * 1CFA 30 A9 06 C1    0).A
                    pshs      X                   * 1CFE 34 10          4.
                    ldd       <U00CE              * 1D00 DC CE          \N
                    beq       L1D08               * 1D02 27 04          '.
                    ldd       <U00DC              * 1D04 DC DC          \\
                    bra       L1D0A               * 1D06 20 02           .
L1D08               ldd       <U0015              * 1D08 DC 15          \.
L1D0A               pshs      D                   * 1D0A 34 06          4.
                    lbsr      L4059               * 1D0C 17 23 4A       .#J
                    leas      2,S                 * 1D0F 32 62          2b
                    lbra      L1D88               * 1D11 16 00 74       ..t
L1D14               ldd       #1                  * 1D14 CC 00 01       L..
                    bra       L1D21               * 1D17 20 08           .
L1D19               pshs      U                   * 1D19 34 40          4@
                    ldd       <U00D2              * 1D1B DC D2          \R
                    beq       L1D26               * 1D1D 27 07          '.
                    clra                          * 1D1F 4F             O
                    clrb                          * 1D20 5F             _
L1D21               std       <U00D2              * 1D21 DD D2          ]R
                    lbra      L1D8B               * 1D23 16 00 65       ..e
L1D26               leax      >Y06C1,Y            * 1D26 30 A9 06 C1    0).A
                    ldd       2,X                 * 1D2A EC 02          l.
                    pshs      D                   * 1D2C 34 06          4.
                    ldd       ,X                  * 1D2E EC 84          l.
                    pshs      D                   * 1D30 34 06          4.
                    bsr       L1D38               * 1D32 8D 04          ..
                    neg       <U0000              * 1D34 00 00          ..
                    neg       <U0000              * 1D36 00 00          ..
L1D38               puls      X                   * 1D38 35 10          5.
                    lbsr      L45D2               * 1D3A 17 28 95       .(.
                    bne       L1D4A               * 1D3D 26 0B          &.
                    leax      >L1DF9,PC           * 1D3F 30 8D 00 B6    0..6
                    pshs      X                   * 1D43 34 10          4.
                    lbsr      L074E               * 1D45 17 EA 06       .j.
                    puls      PC,U,X              * 1D48 35 D0          5P
L1D4A               ldd       <U00D0              * 1D4A DC D0          \P
                    addd      #-1                 * 1D4C C3 FF FF       C..
                    std       <U00D0              * 1D4F DD D0          ]P
                    ble       L1D7A               * 1D51 2F 27          /'
                    clra                          * 1D53 4F             O
                    clrb                          * 1D54 5F             _
                    pshs      D                   * 1D55 34 06          4.
                    leax      >Y06C1,Y            * 1D57 30 A9 06 C1    0).A
                    ldd       2,X                 * 1D5B EC 02          l.
                    pshs      D                   * 1D5D 34 06          4.
                    ldd       ,X                  * 1D5F EC 84          l.
                    pshs      D                   * 1D61 34 06          4.
                    ldd       <U00CE              * 1D63 DC CE          \N
                    beq       L1D6B               * 1D65 27 04          '.
                    ldd       <U00DC              * 1D67 DC DC          \\
                    bra       L1D6D               * 1D69 20 02           .
L1D6B               ldd       <U0015              * 1D6B DC 15          \.
L1D6D               pshs      D                   * 1D6D 34 06          4.
                    lbsr      L3F02               * 1D6F 17 21 90       .!.
                    leas      8,S                 * 1D72 32 68          2h
                    clra                          * 1D74 4F             O
                    clrb                          * 1D75 5F             _
                    std       <U003D              * 1D76 DD 3D          ]=
                    bra       L1D8B               * 1D78 20 11           .
L1D7A               leax      >Y06C1,Y            * 1D7A 30 A9 06 C1    0).A
                    pshs      X                   * 1D7E 34 10          4.
                    bsr       L1D86               * 1D80 8D 04          ..
                    neg       <U0000              * 1D82 00 00          ..
                    neg       <U0000              * 1D84 00 00          ..
L1D86               puls      X                   * 1D86 35 10          5.
L1D88               lbsr      L4636               * 1D88 17 28 AB       .(+
L1D8B               ldd       #1                  * 1D8B CC 00 01       L..
                    puls      PC,U                * 1D8E 35 C0          5@
L1D90               fcc       "label missing"     * 1D90 6C 61 62 65 6C 20 6D 69 73 73 69 6E 67 label missing
                    fcb       $00                 * 1D9D 00             .
L1D9E               fcc       "constant definition" * 1D9E 63 6F 6E 73 74 61 6E 74 20 64 65 66 69 6E 69 74 69 6F 6E constant definition
                    fcb       $00                 * 1DB1 00             .
L1DB2               fcc       "comma expected"    * 1DB2 63 6F 6D 6D 61 20 65 78 70 65 63 74 65 64 comma expected
                    fcb       $00                 * 1DC0 00             .
L1DC1               fcc       "bad number"        * 1DC1 62 61 64 20 6E 75 6D 62 65 72 bad number
                    fcb       $00                 * 1DCB 00             .
L1DCC               fcc       "bad option"        * 1DCC 62 61 64 20 6F 70 74 69 6F 6E bad option
                    fcb       $00                 * 1DD6 00             .
L1DD7               fcb       $72                 * 1DD7 72             r
                    fcb       $00                 * 1DD8 00             .
L1DD9               fcc       "DP section ???"    * 1DD9 44 50 20 73 65 63 74 69 6F 6E 20 3F 3F 3F DP section ???
                    fcb       $00                 * 1DE7 00             .
L1DE8               fcc       "fail"              * 1DE8 66 61 69 6C    fail
                    fcb       $00                 * 1DEC 00             .
L1DED               fcc       "nested REPT"       * 1DED 6E 65 73 74 65 64 20 52 45 50 54 nested REPT
                    fcb       $00                 * 1DF8 00             .
L1DF9               fcc       "ENDR without REPT" * 1DF9 45 4E 44 52 20 77 69 74 68 6F 75 74 20 52 45 50 54 ENDR without REPT
                    fcb       $00                 * 1E0A 00             .
L1E0B               pshs      U,D                 * 1E0B 34 46          4F
                    ldb       [>U0062,Y]          * 1E0D E6 B9 00 62    f9.b
                    sex                           * 1E11 1D             .
                    leax      >Y03FC,Y            * 1E12 30 A9 03 FC    0).|
                    leax      D,X                 * 1E16 30 8B          0.
                    ldb       ,X                  * 1E18 E6 84          f.
                    clra                          * 1E1A 4F             O
                    andb      #6                  * 1E1B C4 06          D.
                    lbeq      L1E7B               * 1E1D 10 27 00 5A    .'.Z
                    ldd       #9                  * 1E21 CC 00 09       L..
                    std       ,S                  * 1E24 ED E4          md
                    bra       L1E38               * 1E26 20 10           .
L1E28               ldx       <U0062              * 1E28 9E 62          .b
                    leax      1,X                 * 1E2A 30 01          0.
                    stx       <U0062              * 1E2C 9F 62          .b
                    ldb       -1,X                * 1E2E E6 1F          f.
                    ldx       6,S                 * 1E30 AE 66          .f
                    leax      1,X                 * 1E32 30 01          0.
                    stx       6,S                 * 1E34 AF 66          /f
                    stb       -1,X                * 1E36 E7 1F          g.
L1E38               ldd       ,S                  * 1E38 EC E4          ld
                    addd      #-1                 * 1E3A C3 FF FF       C..
                    std       ,S                  * 1E3D ED E4          md
                    subd      #-1                 * 1E3F 83 FF FF       ...
                    ble       L1E56               * 1E42 2F 12          /.
                    ldb       [>U0062,Y]          * 1E44 E6 B9 00 62    f9.b
                    sex                           * 1E48 1D             .
                    leax      >Y03FC,Y            * 1E49 30 A9 03 FC    0).|
                    leax      D,X                 * 1E4D 30 8B          0.
                    ldb       ,X                  * 1E4F E6 84          f.
                    clra                          * 1E51 4F             O
                    andb      #15                 * 1E52 C4 0F          D.
                    bne       L1E28               * 1E54 26 D2          &R
L1E56               clra                          * 1E56 4F             O
                    clrb                          * 1E57 5F             _
                    stb       [<$06,S]            * 1E58 E7 F8 06       gx.
                    bra       L1E64               * 1E5B 20 07           .
L1E5D               ldd       <U0062              * 1E5D DC 62          \b
                    addd      #1                  * 1E5F C3 00 01       C..
                    std       <U0062              * 1E62 DD 62          ]b
L1E64               ldb       [>U0062,Y]          * 1E64 E6 B9 00 62    f9.b
                    sex                           * 1E68 1D             .
                    leax      >Y03FC,Y            * 1E69 30 A9 03 FC    0).|
                    leax      D,X                 * 1E6D 30 8B          0.
                    ldb       ,X                  * 1E6F E6 84          f.
                    clra                          * 1E71 4F             O
                    andb      #15                 * 1E72 C4 0F          D.
                    bne       L1E5D               * 1E74 26 E7          &g
                    ldd       #1                  * 1E76 CC 00 01       L..
                    puls      PC,U,X              * 1E79 35 D0          5P
L1E7B               clra                          * 1E7B 4F             O
                    clrb                          * 1E7C 5F             _
                    puls      PC,U,X              * 1E7D 35 D0          5P
L1E7F               pshs      U,D                 * 1E7F 34 46          4F
                    clra                          * 1E81 4F             O
                    clrb                          * 1E82 5F             _
                    std       <U0078              * 1E83 DD 78          ]x
                    leax      >Y05A9,Y            * 1E85 30 A9 05 A9    0).)
                    pshs      X                   * 1E89 34 10          4.
                    lbsr      L1E0B               * 1E8B 17 FF 7D       ..}
                    std       ,S++                * 1E8E ED E1          ma
                    bne       L1E96               * 1E90 26 04          &.
                    clra                          * 1E92 4F             O
                    clrb                          * 1E93 5F             _
                    puls      PC,U,X              * 1E94 35 D0          5P
L1E96               ldb       [>U0062,Y]          * 1E96 E6 B9 00 62    f9.b
                    cmpb      #58                 * 1E9A C1 3A          A:
                    bne       L1EAC               * 1E9C 26 0E          &.
                    ldd       <U0062              * 1E9E DC 62          \b
                    addd      #1                  * 1EA0 C3 00 01       C..
                    std       <U0062              * 1EA3 DD 62          ]b
                    ldb       <U005F              * 1EA5 D6 5F          V_
                    sex                           * 1EA7 1D             .
                    orb       #4                  * 1EA8 CA 04          J.
                    stb       <U005F              * 1EAA D7 5F          W_
L1EAC               leax      >U0078,Y            * 1EAC 30 A9 00 78    0).x
                    pshs      X                   * 1EB0 34 10          4.
                    leax      >Y05A9,Y            * 1EB2 30 A9 05 A9    0).)
                    pshs      X                   * 1EB6 34 10          4.
                    lbsr      L22CC               * 1EB8 17 04 11       ...
                    leas      4,S                 * 1EBB 32 64          2d
                    std       ,S                  * 1EBD ED E4          md
                    ldu       <U0078              * 1EBF DE 78          ^x
                    ldb       <U005B              * 1EC1 D6 5B          V[
                    lbne      L1F40               * 1EC3 10 26 00 79    .&.y
                    ldd       ,S                  * 1EC7 EC E4          ld
                    beq       L1EE6               * 1EC9 27 1B          '.
                    ldd       ,S                  * 1ECB EC E4          ld
                    pshs      D                   * 1ECD 34 06          4.
                    leax      >U0078,Y            * 1ECF 30 A9 00 78    0).x
                    pshs      X                   * 1ED3 34 10          4.
                    leax      >Y05A9,Y            * 1ED5 30 A9 05 A9    0).)
                    pshs      X                   * 1ED9 34 10          4.
                    lbsr      L2252               * 1EDB 17 03 74       ..t
                    leas      6,S                 * 1EDE 32 66          2f
                    tfr       D,U                 * 1EE0 1F 03          ..
                    tfr       U,D                 * 1EE2 1F 30          .0
                    std       <U0078              * 1EE4 DD 78          ]x
L1EE6               ldb       1,U                 * 1EE6 E6 41          fA
                    clra                          * 1EE8 4F             O
                    andb      #128                * 1EE9 C4 80          D.
                    bne       L1F17               * 1EEB 26 2A          &*
                    ldb       ,U                  * 1EED E6 C4          fD
                    sex                           * 1EEF 1D             .
                    andb      #248                * 1EF0 C4 F8          Dx
                    pshs      D                   * 1EF2 34 06          4.
                    ldb       <U005D              * 1EF4 D6 5D          V]
                    sex                           * 1EF6 1D             .
                    ora       ,S+                 * 1EF7 AA E0          *`
                    orb       ,S+                 * 1EF9 EA E0          j`
                    stb       ,U                  * 1EFB E7 C4          gD
                    ldb       1,U                 * 1EFD E6 41          fA
                    sex                           * 1EFF 1D             .
                    pshs      D                   * 1F00 34 06          4.
                    ldb       <U005F              * 1F02 D6 5F          V_
                    sex                           * 1F04 1D             .
                    ora       ,S+                 * 1F05 AA E0          *`
                    orb       ,S+                 * 1F07 EA E0          j`
                    stb       1,U                 * 1F09 E7 41          gA
                    ldd       <U004B              * 1F0B DC 4B          \K
                    beq       L1F29               * 1F0D 27 1A          '.
                    ldd       [>U004B,Y]          * 1F0F EC B9 00 4B    l9.K
                    std       2,U                 * 1F13 ED 42          mB
                    bra       L1F29               * 1F15 20 12           .
L1F17               ldb       ,U                  * 1F17 E6 C4          fD
                    clra                          * 1F19 4F             O
                    andb      #7                  * 1F1A C4 07          D.
                    cmpd      #5                  * 1F1C 10 83 00 05    ....
                    beq       L1F29               * 1F20 27 07          '.
                    ldb       1,U                 * 1F22 E6 41          fA
                    sex                           * 1F24 1D             .
                    orb       #64                 * 1F25 CA 40          J@
                    stb       1,U                 * 1F27 E7 41          gA
L1F29               ldb       1,U                 * 1F29 E6 41          fA
                    clra                          * 1F2B 4F             O
                    andb      #198                * 1F2C C4 C6          DF
                    cmpd      #134                * 1F2E 10 83 00 86    ....
                    lbne      L1F94               * 1F32 10 26 00 5E    .&.^
                    ldd       <U0055              * 1F36 DC 55          \U
                    addd      #1                  * 1F38 C3 00 01       C..
                    std       <U0055              * 1F3B DD 55          ]U
                    lbra      L1F94               * 1F3D 16 00 54       ..T
L1F40               ldd       ,S                  * 1F40 EC E4          ld
                    bne       L1F4B               * 1F42 26 07          &.
                    ldb       1,U                 * 1F44 E6 41          fA
                    clra                          * 1F46 4F             O
                    andb      #128                * 1F47 C4 80          D.
                    bne       L1F56               * 1F49 26 0B          &.
L1F4B               leax      >L2360,PC           * 1F4B 30 8D 04 11    0...
                    pshs      X                   * 1F4F 34 10          4.
                    lbsr      L078B               * 1F51 17 E8 37       .h7
                    leas      2,S                 * 1F54 32 62          2b
L1F56               ldb       1,U                 * 1F56 E6 41          fA
                    sex                           * 1F58 1D             .
                    andb      #239                * 1F59 C4 EF          Do
                    stb       1,U                 * 1F5B E7 41          gA
                    clra                          * 1F5D 4F             O
                    andb      #64                 * 1F5E C4 40          D@
                    beq       L1F6F               * 1F60 27 0D          '.
                    leax      >L236E,PC           * 1F62 30 8D 04 08    0...
                    pshs      X                   * 1F66 34 10          4.
                    lbsr      L074E               * 1F68 17 E7 E3       .gc
                    leas      2,S                 * 1F6B 32 62          2b
                    bra       L1F94               * 1F6D 20 25           %
L1F6F               ldd       <U004B              * 1F6F DC 4B          \K
                    beq       L1F94               * 1F71 27 21          '!
                    ldb       ,U                  * 1F73 E6 C4          fD
                    clra                          * 1F75 4F             O
                    andb      #7                  * 1F76 C4 07          D.
                    pshs      D                   * 1F78 34 06          4.
                    ldb       <U005C              * 1F7A D6 5C          V\
                    sex                           * 1F7C 1D             .
                    cmpd      ,S++                * 1F7D 10 A3 E1       .#a
                    bne       L1F94               * 1F80 26 12          &.
                    ldd       2,U                 * 1F82 EC 42          lB
                    cmpd      [>U004B,Y]          * 1F84 10 A3 B9 00 4B .#9.K
                    beq       L1F94               * 1F89 27 09          '.
                    lbsr      L21FA               * 1F8B 17 02 6C       ..l
                    ldd       [>U004B,Y]          * 1F8E EC B9 00 4B    l9.K
                    std       2,U                 * 1F92 ED 42          mB
L1F94               ldd       #1                  * 1F94 CC 00 01       L..
                    puls      PC,U,X              * 1F97 35 D0          5P
L1F99               pshs      U,X,D               * 1F99 34 56          4V
                    leax      >U0078,Y            * 1F9B 30 A9 00 78    0).x
                    pshs      X                   * 1F9F 34 10          4.
                    leax      >Y05BD,Y            * 1FA1 30 A9 05 BD    0).=
                    pshs      X                   * 1FA5 34 10          4.
                    lbsr      L22CC               * 1FA7 17 03 22       .."
                    leas      4,S                 * 1FAA 32 64          2d
                    std       ,S                  * 1FAC ED E4          md
                    ldu       <U0078              * 1FAE DE 78          ^x
                    ldd       ,S                  * 1FB0 EC E4          ld
                    beq       L1FDE               * 1FB2 27 2A          '*
                    ldb       <U005B              * 1FB4 D6 5B          V[
                    bne       L1FD3               * 1FB6 26 1B          &.
                    ldd       ,S                  * 1FB8 EC E4          ld
                    pshs      D                   * 1FBA 34 06          4.
                    leax      >U0078,Y            * 1FBC 30 A9 00 78    0).x
                    pshs      X                   * 1FC0 34 10          4.
                    leax      >Y05BD,Y            * 1FC2 30 A9 05 BD    0).=
                    pshs      X                   * 1FC6 34 10          4.
                    lbsr      L2252               * 1FC8 17 02 87       ...
                    leas      6,S                 * 1FCB 32 66          2f
                    std       <U0078              * 1FCD DD 78          ]x
                    tfr       D,U                 * 1FCF 1F 03          ..
                    bra       L1FDE               * 1FD1 20 0B           .
L1FD3               leax      >L237D,PC           * 1FD3 30 8D 03 A6    0..&
                    pshs      X                   * 1FD7 34 10          4.
                    lbsr      L078B               * 1FD9 17 E7 AF       .g/
                    leas      2,S                 * 1FDC 32 62          2b
L1FDE               ldb       1,U                 * 1FDE E6 41          fA
                    sex                           * 1FE0 1D             .
                    eorb      #128                * 1FE1 C8 80          H.
                    clra                          * 1FE3 4F             O
                    andb      #160                * 1FE4 C4 A0          D
                    lbeq      L2067               * 1FE6 10 27 00 7D    .'.}
                    ldd       #1                  * 1FEA CC 00 01       L..
                    std       <U003F              * 1FED DD 3F          ]?
                    ldb       <U005B              * 1FEF D6 5B          V[
                    beq       L2043               * 1FF1 27 50          'P
                    ldb       1,U                 * 1FF3 E6 41          fA
                    clra                          * 1FF5 4F             O
                    andb      #128                * 1FF6 C4 80          D.
                    beq       L2043               * 1FF8 27 49          'I
                    ldb       ,U                  * 1FFA E6 C4          fD
                    clra                          * 1FFC 4F             O
                    andb      #7                  * 1FFD C4 07          D.
                    cmpd      #6                  * 1FFF 10 83 00 06    ....
                    beq       L2010               * 2003 27 0B          '.
                    ldb       ,U                  * 2005 E6 C4          fD
                    clra                          * 2007 4F             O
                    andb      #7                  * 2008 C4 07          D.
                    cmpd      #5                  * 200A 10 83 00 05    ....
                    bne       L2043               * 200E 26 33          &3
L2010               ldd       8,U                 * 2010 EC 48          lH
                    bra       L203B               * 2012 20 27           '
L2014               ldb       [<$02,S]            * 2014 E6 F8 02       fx.
                    stb       [>Y07E5,Y]          * 2017 E7 B9 07 E5    g9.e
                    ldx       2,S                 * 201B AE 62          .b
                    ldd       1,X                 * 201D EC 01          l.
                    ldx       >Y07E5,Y            * 201F AE A9 07 E5    .).e
                    std       1,X                 * 2023 ED 01          m.
                    pshs      D                   * 2025 34 06          4.
                    lbsr      L2082               * 2027 17 00 58       ..X
                    leas      2,S                 * 202A 32 62          2b
                    ldd       >Y07E5,Y            * 202C EC A9 07 E5    l).e
                    addd      #3                  * 2030 C3 00 03       C..
                    std       >Y07E5,Y            * 2033 ED A9 07 E5    m).e
                    ldx       2,S                 * 2037 AE 62          .b
                    ldd       3,X                 * 2039 EC 03          l.
L203B               std       2,S                 * 203B ED 62          mb
                    ldd       2,S                 * 203D EC 62          lb
                    bne       L2014               * 203F 26 D3          &S
                    bra       L2078               * 2041 20 35           5
L2043               ldb       <U005B              * 2043 D6 5B          V[
                    bne       L204E               * 2045 26 07          &.
                    ldb       1,U                 * 2047 E6 41          fA
                    sex                           * 2049 1D             .
                    orb       #16                 * 204A CA 10          J.
                    stb       1,U                 * 204C E7 41          gA
L204E               clra                          * 204E 4F             O
                    clrb                          * 204F 5F             _
                    stb       [>Y07E5,Y]          * 2050 E7 B9 07 E5    g9.e
                    ldx       >Y07E5,Y            * 2054 AE A9 07 E5    .).e
                    stu       1,X                 * 2058 EF 01          o.
                    ldd       >Y07E5,Y            * 205A EC A9 07 E5    l).e
                    addd      #3                  * 205E C3 00 03       C..
                    std       >Y07E5,Y            * 2061 ED A9 07 E5    m).e
                    bra       L2072               * 2065 20 0B           .
L2067               ldb       <U005B              * 2067 D6 5B          V[
                    beq       L2078               * 2069 27 0D          '.
                    ldb       1,U                 * 206B E6 41          fA
                    clra                          * 206D 4F             O
                    andb      #16                 * 206E C4 10          D.
                    beq       L2078               * 2070 27 06          '.
L2072               pshs      U                   * 2072 34 40          4@
                    bsr       L2082               * 2074 8D 0C          ..
                    leas      2,S                 * 2076 32 62          2b
L2078               ldd       2,U                 * 2078 EC 42          lB
                    std       <U0031              * 207A DD 31          ]1
                    ldd       #1                  * 207C CC 00 01       L..
                    lbra      L21F6               * 207F 16 01 74       ..t
L2082               pshs      U                   * 2082 34 40          4@
                    ldu       4,S                 * 2084 EE 64          nd
                    ldd       <U0037              * 2086 DC 37          \7
                    bne       L209F               * 2088 26 15          &.
                    ldb       ,U                  * 208A E6 C4          fD
                    clra                          * 208C 4F             O
                    andb      #6                  * 208D C4 06          D.
                    cmpd      #2                  * 208F 10 83 00 02    ....
                    bne       L209A               * 2093 26 05          &.
                    ldd       #1                  * 2095 CC 00 01       L..
                    bra       L209D               * 2098 20 03           .
L209A               ldd       #-1                 * 209A CC FF FF       L..
L209D               std       <U0037              * 209D DD 37          ]7
L209F               puls      PC,U                * 209F 35 C0          5@
L20A1               pshs      U                   * 20A1 34 40          4@
                    ldx       <U0078              * 20A3 9E 78          .x
                    ldb       1,X                 * 20A5 E6 01          f.
                    clra                          * 20A7 4F             O
                    andb      #64                 * 20A8 C4 40          D@
                    bne       L20DE               * 20AA 26 32          &2
                    ldb       5,S                 * 20AC E6 65          fe
                    cmpb      #5                  * 20AE C1 05          A.
                    beq       L20CA               * 20B0 27 18          '.
                    ldb       [>U0078,Y]          * 20B2 E6 B9 00 78    f9.x
                    clra                          * 20B6 4F             O
                    andb      #7                  * 20B7 C4 07          D.
                    cmpd      #5                  * 20B9 10 83 00 05    ....
                    bne       L20CA               * 20BD 26 0B          &.
                    ldx       <U0078              * 20BF 9E 78          .x
                    ldb       1,X                 * 20C1 E6 01          f.
                    sex                           * 20C3 1D             .
                    orb       #64                 * 20C4 CA 40          J@
                    stb       1,X                 * 20C6 E7 01          g.
                    bra       L20DE               * 20C8 20 14           .
L20CA               ldb       [>U0078,Y]          * 20CA E6 B9 00 78    f9.x
                    sex                           * 20CE 1D             .
                    andb      #248                * 20CF C4 F8          Dx
                    pshs      D                   * 20D1 34 06          4.
                    ldb       7,S                 * 20D3 E6 67          fg
                    sex                           * 20D5 1D             .
                    ora       ,S+                 * 20D6 AA E0          *`
                    orb       ,S+                 * 20D8 EA E0          j`
                    stb       [>U0078,Y]          * 20DA E7 B9 00 78    g9.x
L20DE               puls      PC,U                * 20DE 35 C0          5@
L20E0               pshs      U,X,D               * 20E0 34 56          4V
                    ldu       <U0078              * 20E2 DE 78          ^x
                    leax      >Y07C7,Y            * 20E4 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 20E8 AC A9 07 E5    ,).e
                    bne       L212E               * 20EC 26 40          &@
                    ldb       ,U                  * 20EE E6 C4          fD
                    clra                          * 20F0 4F             O
                    andb      #4                  * 20F1 C4 04          D.
                    beq       L2106               * 20F3 27 11          '.
                    ldb       1,U                 * 20F5 E6 41          fA
                    clra                          * 20F7 4F             O
                    andb      #32                 * 20F8 C4 20          D
                    beq       L2106               * 20FA 27 0A          '.
                    ldb       1,U                 * 20FC E6 41          fA
                    sex                           * 20FE 1D             .
                    andb      #223                * 20FF C4 DF          D_
                    stb       1,U                 * 2101 E7 41          gA
                    lbra      L21F2               * 2103 16 00 EC       ..l
L2106               ldb       <U005B              * 2106 D6 5B          V[
                    lble      L21F2               * 2108 10 2F 00 E6    ./.f
                    ldd       8,S                 * 210C EC 68          lh
                    cmpd      2,U                 * 210E 10 A3 42       .#B
                    lbeq      L21F2               * 2111 10 27 00 DD    .'.]
                    ldb       1,U                 * 2115 E6 41          fA
                    clra                          * 2117 4F             O
                    andb      #64                 * 2118 C4 40          D@
                    lbne      L21F2               * 211A 10 26 00 D4    .&.T
                    ldb       ,U                  * 211E E6 C4          fD
                    clra                          * 2120 4F             O
                    andb      #7                  * 2121 C4 07          D.
                    cmpd      #5                  * 2123 10 83 00 05    ....
                    lbeq      L21F2               * 2127 10 27 00 C7    .'.G
                    lbra      L21C6               * 212B 16 00 98       ...
L212E               ldb       <U005B              * 212E D6 5B          V[
                    bne       L2176               * 2130 26 44          &D
                    ldb       ,U                  * 2132 E6 C4          fD
                    clra                          * 2134 4F             O
                    andb      #7                  * 2135 C4 07          D.
                    cmpd      #6                  * 2137 10 83 00 06    ....
                    lbne      L21F2               * 213B 10 26 00 B3    .&.3
                    ldb       1,U                 * 213F E6 41          fA
                    sex                           * 2141 1D             .
                    orb       #32                 * 2142 CA 20          J
                    stb       1,U                 * 2144 E7 41          gA
                    bra       L2169               * 2146 20 21           !
L2148               ldd       >Y07E5,Y            * 2148 EC A9 07 E5    l).e
                    addd      #-3                 * 214C C3 FF FD       C.}
                    std       >Y07E5,Y            * 214F ED A9 07 E5    m).e
                    ldx       >Y07E5,Y            * 2153 AE A9 07 E5    .).e
                    ldd       1,X                 * 2157 EC 01          l.
                    pshs      D                   * 2159 34 06          4.
                    ldb       [>Y07E5,Y]          * 215B E6 B9 07 E5    f9.e
                    sex                           * 215F 1D             .
                    pshs      D                   * 2160 34 06          4.
                    pshs      U                   * 2162 34 40          4@
                    lbsr      L2207               * 2164 17 00 A0       ..
                    leas      6,S                 * 2167 32 66          2f
L2169               leax      >Y07C7,Y            * 2169 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 216D AC A9 07 E5    ,).e
                    bcs       L2148               * 2171 25 D5          %U
                    lbra      L21F2               * 2173 16 00 7C       ..|
L2176               ldb       ,U                  * 2176 E6 C4          fD
                    clra                          * 2178 4F             O
                    andb      #7                  * 2179 C4 07          D.
                    cmpd      #6                  * 217B 10 83 00 06    ....
                    lbne      L21EF               * 217F 10 26 00 6C    .&.l
                    ldd       8,U                 * 2183 EC 48          lH
                    std       ,S                  * 2185 ED E4          md
                    ldd       >Y07E5,Y            * 2187 EC A9 07 E5    l).e
                    std       2,S                 * 218B ED 62          mb
                    bra       L21A7               * 218D 20 18           .
L218F               ldd       2,S                 * 218F EC 62          lb
                    addd      #-3                 * 2191 C3 FF FD       C.}
                    std       2,S                 * 2194 ED 62          mb
                    ldx       ,S                  * 2196 AE E4          .d
                    ldd       1,X                 * 2198 EC 01          l.
                    ldx       2,S                 * 219A AE 62          .b
                    cmpd      1,X                 * 219C 10 A3 01       .#.
                    bne       L21B3               * 219F 26 12          &.
                    ldx       ,S                  * 21A1 AE E4          .d
                    ldd       3,X                 * 21A3 EC 03          l.
                    std       ,S                  * 21A5 ED E4          md
L21A7               ldd       ,S                  * 21A7 EC E4          ld
                    beq       L21B3               * 21A9 27 08          '.
                    leax      >Y07C7,Y            * 21AB 30 A9 07 C7    0).G
                    cmpx      2,S                 * 21AF AC 62          ,b
                    bcs       L218F               * 21B1 25 DC          %\
L21B3               ldd       ,S                  * 21B3 EC E4          ld
                    bne       L21C6               * 21B5 26 0F          &.
                    leax      >Y07C7,Y            * 21B7 30 A9 07 C7    0).G
                    cmpx      2,S                 * 21BB AC 62          ,b
                    bne       L21C6               * 21BD 26 07          &.
                    ldd       2,U                 * 21BF EC 42          lB
                    cmpd      8,S                 * 21C1 10 A3 68       .#h
                    beq       L21CA               * 21C4 27 04          '.
L21C6               bsr       L21FA               * 21C6 8D 32          .2
                    bra       L21F2               * 21C8 20 28           (
L21CA               ldb       1,U                 * 21CA E6 41          fA
                    clra                          * 21CC 4F             O
                    andb      #4                  * 21CD C4 04          D.
                    beq       L21F2               * 21CF 27 21          '!
                    ldd       8,U                 * 21D1 EC 48          lH
                    bra       L21E7               * 21D3 20 12           .
L21D5               ldx       ,S                  * 21D5 AE E4          .d
                    ldx       1,X                 * 21D7 AE 01          ..
                    ldb       1,X                 * 21D9 E6 01          f.
                    clra                          * 21DB 4F             O
                    andb      #66                 * 21DC C4 42          DB
                    bne       L21E3               * 21DE 26 03          &.
                    lbsr      L0DEB               * 21E0 17 EC 08       .l.
L21E3               ldx       ,S                  * 21E3 AE E4          .d
                    ldd       3,X                 * 21E5 EC 03          l.
L21E7               std       ,S                  * 21E7 ED E4          md
                    ldd       ,S                  * 21E9 EC E4          ld
                    bne       L21D5               * 21EB 26 E8          &h
                    bra       L21F2               * 21ED 20 03           .
L21EF               lbsr      L0DEB               * 21EF 17 EB F9       .ky
L21F2               ldd       8,S                 * 21F2 EC 68          lh
                    std       2,U                 * 21F4 ED 42          mB
L21F6               leas      4,S                 * 21F6 32 64          2d
                    puls      PC,U                * 21F8 35 C0          5@
L21FA               pshs      U                   * 21FA 34 40          4@
                    leax      >L2394,PC           * 21FC 30 8D 01 94    0...
                    pshs      X                   * 2200 34 10          4.
                    lbsr      L074E               * 2202 17 E5 49       .eI
                    puls      PC,U,X              * 2205 35 D0          5P
L2207               pshs      U                   * 2207 34 40          4@
                    ldd       #5                  * 2209 CC 00 05       L..
                    pshs      D                   * 220C 34 06          4.
                    lbsr      L233C               * 220E 17 01 2B       ..+
                    leas      2,S                 * 2211 32 62          2b
                    tfr       D,U                 * 2213 1F 03          ..
                    ldd       6,S                 * 2215 EC 66          lf
                    stb       ,U                  * 2217 E7 C4          gD
                    ldd       8,S                 * 2219 EC 68          lh
                    std       1,U                 * 221B ED 41          mA
                    ldx       4,S                 * 221D AE 64          .d
                    ldd       8,X                 * 221F EC 08          l.
                    std       3,U                 * 2221 ED 43          mC
                    ldx       4,S                 * 2223 AE 64          .d
                    stu       8,X                 * 2225 EF 08          o.
                    puls      PC,U                * 2227 35 C0          5@
L2229               ldx       <U0062              * 2229 9E 62          .b
L222B               ldb       ,X+                 * 222B E6 80          f.
                    cmpb      #32                 * 222D C1 20          A
                    beq       L222B               * 222F 27 FA          'z
                    sex                           * 2231 1D             .
                    leax      -1,X                * 2232 30 1F          0.
                    stx       <U0062              * 2234 9F 62          .b
                    rts                           * 2236 39             9
L2237               pshs      U                   * 2237 34 40          4@
                    ldx       4,S                 * 2239 AE 64          .d
                    ldu       6,X                 * 223B EE 06          n.
                    ldx       4,S                 * 223D AE 64          .d
                    ldb       1,X                 * 223F E6 01          f.
                    clra                          * 2241 4F             O
                    andb      #8                  * 2242 C4 08          D.
                    beq       L224E               * 2244 27 08          '.
                    bra       L224A               * 2246 20 02           .
L2248               ldu       4,U                 * 2248 EE 44          nD
L224A               ldd       4,U                 * 224A EC 44          lD
                    bne       L2248               * 224C 26 FA          &z
L224E               tfr       U,D                 * 224E 1F 30          .0
                    puls      PC,U                * 2250 35 C0          5@
L2252               pshs      U,D                 * 2252 34 46          4F
                    ldd       >Y07C5,Y            * 2254 EC A9 07 C5    l).E
                    beq       L2278               * 2258 27 1E          '.
                    ldu       >Y07C5,Y            * 225A EE A9 07 C5    n).E
                    ldx       >Y07C5,Y            * 225E AE A9 07 C5    .).E
                    ldd       4,X                 * 2262 EC 04          l.
                    std       >Y07C5,Y            * 2264 ED A9 07 C5    m).E
                    clra                          * 2268 4F             O
                    clrb                          * 2269 5F             _
                    std       2,U                 * 226A ED 42          mB
                    stb       1,U                 * 226C E7 41          gA
                    stb       ,U                  * 226E E7 C4          gD
                    clra                          * 2270 4F             O
                    clrb                          * 2271 5F             _
                    std       8,U                 * 2272 ED 48          mH
                    std       4,U                 * 2274 ED 44          mD
                    bra       L2284               * 2276 20 0C           .
L2278               ldd       #20                 * 2278 CC 00 14       L..
                    pshs      D                   * 227B 34 06          4.
                    lbsr      L233C               * 227D 17 00 BC       ..<
                    leas      2,S                 * 2280 32 62          2b
                    tfr       D,U                 * 2282 1F 03          ..
L2284               ldd       [<$08,S]            * 2284 EC F8 08       lx.
                    std       ,S                  * 2287 ED E4          md
                    beq       L22AE               * 2289 27 23          '#
                    ldd       10,S                * 228B EC 6A          lj
                    bge       L2299               * 228D 2C 0A          ,.
                    ldd       ,S                  * 228F EC E4          ld
                    std       6,U                 * 2291 ED 46          mF
                    ldx       ,S                  * 2293 AE E4          .d
                    stu       4,X                 * 2295 EF 04          o.
                    bra       L22B6               * 2297 20 1D           .
L2299               ldx       ,S                  * 2299 AE E4          .d
                    ldd       6,X                 * 229B EC 06          l.
                    std       6,U                 * 229D ED 46          mF
                    ldx       ,S                  * 229F AE E4          .d
                    stu       6,X                 * 22A1 EF 06          o.
                    ldx       ,S                  * 22A3 AE E4          .d
                    ldb       1,X                 * 22A5 E6 01          f.
                    sex                           * 22A7 1D             .
                    orb       #8                  * 22A8 CA 08          J.
                    stb       1,X                 * 22AA E7 01          g.
                    bra       L22B6               * 22AC 20 08           .
L22AE               stu       [>Y07E7,Y]          * 22AE EF B9 07 E7    o9.g
                    clra                          * 22B2 4F             O
                    clrb                          * 22B3 5F             _
                    std       6,U                 * 22B4 ED 46          mF
L22B6               ldd       6,S                 * 22B6 EC 66          lf
                    pshs      D                   * 22B8 34 06          4.
                    pshs      U                   * 22BA 34 40          4@
                    ldd       #10                 * 22BC CC 00 0A       L..
                    addd      ,S++                * 22BF E3 E1          ca
                    pshs      D                   * 22C1 34 06          4.
                    lbsr      L4514               * 22C3 17 22 4E       ."N
                    leas      4,S                 * 22C6 32 64          2d
                    tfr       U,D                 * 22C8 1F 30          .0
                    puls      PC,U,X              * 22CA 35 D0          5P
L22CC               pshs      U,D                 * 22CC 34 46          4F
                    ldd       #1                  * 22CE CC 00 01       L..
                    std       ,S                  * 22D1 ED E4          md
                    leas      -2,S                * 22D3 32 7E          2~
                    ldu       8,S                 * 22D5 EE 68          nh
                    clra                          * 22D7 4F             O
                    clrb                          * 22D8 5F             _
                    std       ,S                  * 22D9 ED E4          md
L22DB               ldd       ,S                  * 22DB EC E4          ld
                    pshs      D                   * 22DD 34 06          4.
                    ldb       ,U                  * 22DF E6 C4          fD
                    sex                           * 22E1 1D             .
                    addd      ,S++                * 22E2 E3 E1          ca
                    std       ,S                  * 22E4 ED E4          md
                    leau      1,U                 * 22E6 33 41          3A
                    ldb       ,U                  * 22E8 E6 C4          fD
                    bne       L22DB               * 22EA 26 EF          &o
                    ldd       ,S                  * 22EC EC E4          ld
                    clra                          * 22EE 4F             O
                    andb      #63                 * 22EF C4 3F          D?
                    aslb                          * 22F1 58             X
                    rola                          * 22F2 49             I
                    addd      <U0076              * 22F3 D3 76          Sv
                    std       >Y07E7,Y            * 22F5 ED A9 07 E7    m).g
                    leas      2,S                 * 22F9 32 62          2b
                    ldd       [>Y07E7,Y]          * 22FB EC B9 07 E7    l9.g
                    std       [<$08,S]            * 22FF ED F8 08       mx.
                    tfr       D,U                 * 2302 1F 03          ..
                    stu       -2,S                * 2304 EF 7E          o~
                    beq       L2338               * 2306 27 30          '0
L2308               stu       [<$08,S]            * 2308 EF F8 08       ox.
                    pshs      U                   * 230B 34 40          4@
                    ldd       #10                 * 230D CC 00 0A       L..
                    addd      ,S++                * 2310 E3 E1          ca
                    pshs      D                   * 2312 34 06          4.
                    ldd       8,S                 * 2314 EC 68          lh
                    pshs      D                   * 2316 34 06          4.
                    lbsr      L4559               * 2318 17 22 3E       .">
                    leas      4,S                 * 231B 32 64          2d
                    std       ,S                  * 231D ED E4          md
                    bge       L2325               * 231F 2C 04          ,.
                    ldu       4,U                 * 2321 EE 44          nD
                    bra       L2334               * 2323 20 0F           .
L2325               ldd       ,S                  * 2325 EC E4          ld
                    ble       L2338               * 2327 2F 0F          /.
                    ldb       1,U                 * 2329 E6 41          fA
                    clra                          * 232B 4F             O
                    andb      #8                  * 232C C4 08          D.
                    beq       L2338               * 232E 27 08          '.
                    ldu       6,U                 * 2330 EE 46          nF
                    bra       L2334               * 2332 20 00           .
L2334               stu       -2,S                * 2334 EF 7E          o~
                    bne       L2308               * 2336 26 D0          &P
L2338               ldd       ,S                  * 2338 EC E4          ld
                    puls      PC,U,X              * 233A 35 D0          5P
L233C               pshs      U,D                 * 233C 34 46          4F
                    ldd       6,S                 * 233E EC 66          lf
                    pshs      D                   * 2340 34 06          4.
                    lbsr      L496E               * 2342 17 26 29       .&)
                    leas      2,S                 * 2345 32 62          2b
                    std       ,S                  * 2347 ED E4          md
                    cmpd      #-1                 * 2349 10 83 FF FF    ....
                    beq       L2353               * 234D 27 04          '.
                    ldd       ,S                  * 234F EC E4          ld
                    bra       L235E               * 2351 20 0B           .
L2353               leax      >L23A2,PC           * 2353 30 8D 00 4B    0..K
                    pshs      X                   * 2357 34 10          4.
                    lbsr      L078B               * 2359 17 E4 2F       .d/
                    leas      2,S                 * 235C 32 62          2b
L235E               puls      PC,U,X              * 235E 35 D0          5P
L2360               fcc       "symbol lost!?"     * 2360 73 79 6D 62 6F 6C 20 6C 6F 73 74 21 3F symbol lost!?
                    fcb       $00                 * 236D 00             .
L236E               fcc       "redefined name"    * 236E 72 65 64 65 66 69 6E 65 64 20 6E 61 6D 65 redefined name
                    fcb       $00                 * 237C 00             .
L237D               fcc       "new symbol in pass two" * 237D 6E 65 77 20 73 79 6D 62 6F 6C 20 69 6E 20 70 61 73 73 20 74 77 6F new symbol in pass two
                    fcb       $00                 * 2393 00             .
L2394               fcc       "phasing error"     * 2394 70 68 61 73 69 6E 67 20 65 72 72 6F 72 phasing error
                    fcb       $00                 * 23A1 00             .
L23A2               fcc       "symbol table overflow" * 23A2 73 79 6D 62 6F 6C 20 74 61 62 6C 65 20 6F 76 65 72 66 6C 6F 77 symbol table overflow
                    fcb       $00                 * 23B7 00             .
L23B8               pshs      U                   * 23B8 34 40          4@
                    ldd       #-68                * 23BA CC FF BC       L.<
                    lbsr      _stkcheck           * 23BD 17 DD 4E       .]N
                    lbsr      L2426               * 23C0 17 00 63       ..c
                    std       -2,S                * 23C3 ED 7E          m~
                    beq       L23E2               * 23C5 27 1B          '.
                    lbsr      L1485               * 23C7 17 F0 BB       .p;
                    lbsr      L13DA               * 23CA 17 F0 0D       .p.
                    ldb       <U0061              * 23CD D6 61          Va
                    sex                           * 23CF 1D             .
                    andb      #127                * 23D0 C4 7F          D.
                    bra       L241F               * 23D2 20 4B           K
L23D4               pshs      U                   * 23D4 34 40          4@
                    ldd       #-70                * 23D6 CC FF BA       L.:
                    lbsr      _stkcheck           * 23D9 17 DD 32       .]2
                    bsr       L2426               * 23DC 8D 48          .H
                    std       -2,S                * 23DE ED 7E          m~
                    bne       L23E6               * 23E0 26 04          &.
L23E2               clra                          * 23E2 4F             O
                    clrb                          * 23E3 5F             _
                    puls      PC,U                * 23E4 35 C0          5@
L23E6               ldb       <U0061              * 23E6 D6 61          Va
                    sex                           * 23E8 1D             .
                    orb       #8                  * 23E9 CA 08          J.
                    stb       <U0061              * 23EB D7 61          Wa
                    lbsr      L1485               * 23ED 17 F0 95       .p.
                    leax      >Y07C7,Y            * 23F0 30 A9 07 C7    0).G
                    cmpx      >Y07E5,Y            * 23F4 AC A9 07 E5    ,).e
                    bcc       L23FF               * 23F8 24 05          $.
                    lbsr      L13DA               * 23FA 17 EF DD       .o]
                    bra       L241A               * 23FD 20 1B           .
L23FF               ldd       <U0031              * 23FF DC 31          \1
                    cmpd      #256                * 2401 10 83 01 00    ....
                    bge       L240F               * 2405 2C 08          ,.
                    ldd       <U0031              * 2407 DC 31          \1
                    cmpd      #-256               * 2409 10 83 FF 00    ....
                    bge       L241A               * 240D 2C 0B          ,.
L240F               leax      >L2837,PC           * 240F 30 8D 04 24    0..$
                    pshs      X                   * 2413 34 10          4.
                    lbsr      L074E               * 2415 17 E3 36       .c6
                    puls      PC,U,X              * 2418 35 D0          5P
L241A               ldb       <U0061              * 241A D6 61          Va
                    sex                           * 241C 1D             .
                    andb      #119                * 241D C4 77          Dw
L241F               stb       <U0061              * 241F D7 61          Wa
                    ldd       #1                  * 2421 CC 00 01       L..
                    puls      PC,U                * 2424 35 C0          5@
L2426               pshs      U                   * 2426 34 40          4@
                    ldd       #-68                * 2428 CC FF BC       L.<
                    lbsr      _stkcheck           * 242B 17 DC E0       .\`
                    lbsr      L2229               * 242E 17 FD F8       .}x
                    leax      >Y07C7,Y            * 2431 30 A9 07 C7    0).G
                    stx       >Y07E5,Y            * 2435 AF A9 07 E5    /).e
                    bsr       L244E               * 2439 8D 13          ..
                    puls      PC,U                * 243B 35 C0          5@
L243D               pshs      U                   * 243D 34 40          4@
                    ldd       #-68                * 243F CC FF BC       L.<
                    lbsr      _stkcheck           * 2442 17 DC C9       .\I
                    lbsr      L0DEB               * 2445 17 E9 A3       .i#
                    std       <U0031              * 2448 DD 31          ]1
                    std       <U003F              * 244A DD 3F          ]?
                    puls      PC,U                * 244C 35 C0          5@
L244E               pshs      U                   * 244E 34 40          4@
                    ldd       #-77                * 2450 CC FF B3       L.3
                    lbsr      _stkcheck           * 2453 17 DC B8       .\8
                    leas      -7,S                * 2456 32 79          2y
                    clra                          * 2458 4F             O
                    clrb                          * 2459 5F             _
                    std       <U003F              * 245A DD 3F          ]?
                    lbsr      L250D               * 245C 17 00 AE       ...
                    std       -2,S                * 245F ED 7E          m~
                    beq       L2489               * 2461 27 26          '&
                    lbra      L24C2               * 2463 16 00 5C       ..\
L2466               ldx       <U0062              * 2466 9E 62          .b
                    leax      1,X                 * 2468 30 01          0.
                    stx       <U0062              * 246A 9F 62          .b
                    ldb       -1,X                * 246C E6 1F          f.
                    stb       ,S                  * 246E E7 E4          gd
                    ldd       <U0031              * 2470 DC 31          \1
                    std       3,S                 * 2472 ED 63          mc
                    ldd       >Y07E5,Y            * 2474 EC A9 07 E5    l).e
                    std       5,S                 * 2478 ED 65          me
                    ldd       <U003F              * 247A DC 3F          \?
                    std       1,S                 * 247C ED 61          ma
                    clra                          * 247E 4F             O
                    clrb                          * 247F 5F             _
                    std       <U003F              * 2480 DD 3F          ]?
                    lbsr      L250D               * 2482 17 00 88       ...
                    std       -2,S                * 2485 ED 7E          m~
                    bne       L248E               * 2487 26 05          &.
L2489               clra                          * 2489 4F             O
                    clrb                          * 248A 5F             _
                    lbra      L2509               * 248B 16 00 7B       ..{
L248E               ldd       <U003F              * 248E DC 3F          \?
                    ora       1,S                 * 2490 AA 61          *a
                    orb       2,S                 * 2492 EA 62          jb
                    std       <U003F              * 2494 DD 3F          ]?
                    ldb       ,S                  * 2496 E6 E4          fd
                    cmpb      #43                 * 2498 C1 2B          A+
                    bne       L24A4               * 249A 26 08          &.
                    ldd       3,S                 * 249C EC 63          lc
                    addd      <U0031              * 249E D3 31          S1
                    std       <U0031              * 24A0 DD 31          ]1
                    bra       L24C2               * 24A2 20 1E           .
L24A4               ldd       3,S                 * 24A4 EC 63          lc
                    subd      <U0031              * 24A6 93 31          .1
                    std       <U0031              * 24A8 DD 31          ]1
                    bra       L24B9               * 24AA 20 0D           .
L24AC               ldx       5,S                 * 24AC AE 65          .e
                    leax      3,X                 * 24AE 30 03          0.
                    stx       5,S                 * 24B0 AF 65          /e
                    ldb       -3,X                * 24B2 E6 1D          f.
                    sex                           * 24B4 1D             .
                    eorb      #64                 * 24B5 C8 40          H@
                    stb       -3,X                * 24B7 E7 1D          g.
L24B9               ldd       5,S                 * 24B9 EC 65          le
                    cmpd      >Y07E5,Y            * 24BB 10 A3 A9 07 E5 .#).e
                    bcs       L24AC               * 24C0 25 EA          %j
L24C2               ldb       [>U0062,Y]          * 24C2 E6 B9 00 62    f9.b
                    cmpb      #43                 * 24C6 C1 2B          A+
                    lbeq      L2466               * 24C8 10 27 FF 9A    .'..
                    ldb       [>U0062,Y]          * 24CC E6 B9 00 62    f9.b
                    cmpb      #45                 * 24D0 C1 2D          A-
                    lbeq      L2466               * 24D2 10 27 FF 90    .'..
                    ldb       [>U0062,Y]          * 24D6 E6 B9 00 62    f9.b
                    sex                           * 24DA 1D             .
                    tfr       D,X                 * 24DB 1F 01          ..
                    bra       L24EC               * 24DD 20 0D           .
L24DF               leax      >L284A,PC           * 24DF 30 8D 03 67    0..g
                    pshs      X                   * 24E3 34 10          4.
                    lbsr      L074E               * 24E5 17 E2 66       .bf
                    leas      2,S                 * 24E8 32 62          2b
                    bra       L2509               * 24EA 20 1D           .
L24EC               cmpx      #32                 * 24EC 8C 00 20       ..
                    beq       L2506               * 24EF 27 15          '.
                    stx       -2,S                * 24F1 AF 7E          /~
                    beq       L2506               * 24F3 27 11          '.
                    cmpx      #44                 * 24F5 8C 00 2C       ..,
                    beq       L2506               * 24F8 27 0C          '.
                    cmpx      #41                 * 24FA 8C 00 29       ..)
                    beq       L2506               * 24FD 27 07          '.
                    cmpx      #93                 * 24FF 8C 00 5D       ..]
                    beq       L2506               * 2502 27 02          '.
                    bra       L24DF               * 2504 20 D9           Y
L2506               ldd       #1                  * 2506 CC 00 01       L..
L2509               leas      7,S                 * 2509 32 67          2g
                    puls      PC,U                * 250B 35 C0          5@
L250D               pshs      U                   * 250D 34 40          4@
                    ldd       #-73                * 250F CC FF B7       L.7
                    lbsr      _stkcheck           * 2512 17 DB F9       .[y
                    leas      -3,S                * 2515 32 7D          2}
                    lbsr      L2583               * 2517 17 00 69       ..i
                    std       -2,S                * 251A ED 7E          m~
                    lbeq      L2617               * 251C 10 27 00 F7    .'.w
                    bra       L256E               * 2520 20 4C           L
L2522               ldx       <U0062              * 2522 9E 62          .b
                    leax      1,X                 * 2524 30 01          0.
                    stx       <U0062              * 2526 9F 62          .b
                    ldb       -1,X                * 2528 E6 1F          f.
                    stb       ,S                  * 252A E7 E4          gd
                    ldd       <U0031              * 252C DC 31          \1
                    std       1,S                 * 252E ED 61          ma
                    bsr       L2583               * 2530 8D 51          .Q
                    std       -2,S                * 2532 ED 7E          m~
                    lbeq      L2617               * 2534 10 27 00 DF    .'._
                    ldd       <U003F              * 2538 DC 3F          \?
                    beq       L2541               * 253A 27 05          '.
                    lbsr      L243D               * 253C 17 FE FE       .~~
                    bra       L256E               * 253F 20 2D           -
L2541               ldb       ,S                  * 2541 E6 E4          fd
                    cmpb      #42                 * 2543 C1 2A          A*
                    bne       L2552               * 2545 26 0B          &.
                    ldd       1,S                 * 2547 EC 61          la
                    pshs      D                   * 2549 34 06          4.
                    ldd       <U0031              * 254B DC 31          \1
                    lbsr      L466A               * 254D 17 21 1A       .!.
                    bra       L256C               * 2550 20 1A           .
L2552               ldd       <U0031              * 2552 DC 31          \1
                    bne       L2563               * 2554 26 0D          &.
                    leax      >L2857,PC           * 2556 30 8D 02 FD    0..}
                    pshs      X                   * 255A 34 10          4.
                    lbsr      L074E               * 255C 17 E1 EF       .ao
                    leas      2,S                 * 255F 32 62          2b
                    bra       L256E               * 2561 20 0B           .
L2563               ldd       1,S                 * 2563 EC 61          la
                    pshs      D                   * 2565 34 06          4.
                    ldd       <U0031              * 2567 DC 31          \1
                    lbsr      L4705               * 2569 17 21 99       .!.
L256C               std       <U0031              * 256C DD 31          ]1
L256E               ldb       [>U0062,Y]          * 256E E6 B9 00 62    f9.b
                    cmpb      #42                 * 2572 C1 2A          A*
                    beq       L2522               * 2574 27 AC          ',
                    ldb       [>U0062,Y]          * 2576 E6 B9 00 62    f9.b
                    cmpb      #47                 * 257A C1 2F          A/
                    lbeq      L2522               * 257C 10 27 FF A2    .'."
                    lbra      L2658               * 2580 16 00 D5       ..U
L2583               pshs      U                   * 2583 34 40          4@
                    ldd       #-71                * 2585 CC FF B9       L.9
                    lbsr      _stkcheck           * 2588 17 DB 83       .[.
                    leas      -3,S                * 258B 32 7D          2}
                    lbsr      L25E2               * 258D 17 00 52       ..R
                    std       -2,S                * 2590 ED 7E          m~
                    lbeq      L2617               * 2592 10 27 00 81    .'..
                    bra       L25CD               * 2596 20 35           5
L2598               ldx       <U0062              * 2598 9E 62          .b
                    leax      1,X                 * 259A 30 01          0.
                    stx       <U0062              * 259C 9F 62          .b
                    ldb       -1,X                * 259E E6 1F          f.
                    stb       ,S                  * 25A0 E7 E4          gd
                    ldd       <U0031              * 25A2 DC 31          \1
                    std       1,S                 * 25A4 ED 61          ma
                    bsr       L25E2               * 25A6 8D 3A          .:
                    std       -2,S                * 25A8 ED 7E          m~
                    lbeq      L2617               * 25AA 10 27 00 69    .'.i
                    ldd       <U003F              * 25AE DC 3F          \?
                    beq       L25B7               * 25B0 27 05          '.
                    lbsr      L243D               * 25B2 17 FE 88       .~.
                    bra       L25CD               * 25B5 20 16           .
L25B7               ldb       ,S                  * 25B7 E6 E4          fd
                    cmpb      #38                 * 25B9 C1 26          A&
                    bne       L25C5               * 25BB 26 08          &.
                    ldd       1,S                 * 25BD EC 61          la
                    anda      <U0031              * 25BF 94 31          .1
                    andb      <U0032              * 25C1 D4 32          T2
                    bra       L25CB               * 25C3 20 06           .
L25C5               ldd       1,S                 * 25C5 EC 61          la
                    ora       <U0031              * 25C7 9A 31          .1
                    orb       <U0032              * 25C9 DA 32          Z2
L25CB               std       <U0031              * 25CB DD 31          ]1
L25CD               ldb       [>U0062,Y]          * 25CD E6 B9 00 62    f9.b
                    cmpb      #38                 * 25D1 C1 26          A&
                    beq       L2598               * 25D3 27 C3          'C
                    ldb       [>U0062,Y]          * 25D5 E6 B9 00 62    f9.b
                    cmpb      #33                 * 25D9 C1 21          A!
                    lbeq      L2598               * 25DB 10 27 FF B9    .'.9
                    lbra      L2658               * 25DF 16 00 76       ..v
L25E2               pshs      U                   * 25E2 34 40          4@
                    ldd       #-71                * 25E4 CC FF B9       L.9
                    lbsr      _stkcheck           * 25E7 17 DB 24       .[$
                    leas      -3,S                * 25EA 32 7D          2}
                    ldb       [>U0062,Y]          * 25EC E6 B9 00 62    f9.b
                    stb       ,S                  * 25F0 E7 E4          gd
                    cmpb      #43                 * 25F2 C1 2B          A+
                    beq       L2604               * 25F4 27 0E          '.
                    ldb       ,S                  * 25F6 E6 E4          fd
                    cmpb      #45                 * 25F8 C1 2D          A-
                    beq       L2604               * 25FA 27 08          '.
                    ldb       ,S                  * 25FC E6 E4          fd
                    cmpb      #94                 * 25FE C1 5E          A^
                    lbne      L265D               * 2600 10 26 00 59    .&.Y
L2604               ldd       <U0062              * 2604 DC 62          \b
                    addd      #1                  * 2606 C3 00 01       C..
                    std       <U0062              * 2609 DD 62          ]b
                    ldd       >Y07E5,Y            * 260B EC A9 07 E5    l).e
                    std       1,S                 * 260F ED 61          ma
                    bsr       L25E2               * 2611 8D CF          .O
                    std       -2,S                * 2613 ED 7E          m~
                    bne       L261B               * 2615 26 04          &.
L2617               clra                          * 2617 4F             O
                    clrb                          * 2618 5F             _
                    bra       L265F               * 2619 20 44           D
L261B               ldb       ,S                  * 261B E6 E4          fd
                    cmpb      #45                 * 261D C1 2D          A-
                    bne       L2643               * 261F 26 22          &"
                    ldd       <U0031              * 2621 DC 31          \1
                    nega                          * 2623 40             @
                    negb                          * 2624 50             P
                    sbca      #0                  * 2625 82 00          ..
                    std       <U0031              * 2627 DD 31          ]1
                    bra       L2638               * 2629 20 0D           .
L262B               ldx       1,S                 * 262B AE 61          .a
                    leax      3,X                 * 262D 30 03          0.
                    stx       1,S                 * 262F AF 61          /a
                    ldb       -3,X                * 2631 E6 1D          f.
                    sex                           * 2633 1D             .
                    eorb      #64                 * 2634 C8 40          H@
                    stb       -3,X                * 2636 E7 1D          g.
L2638               ldd       1,S                 * 2638 EC 61          la
                    cmpd      >Y07E5,Y            * 263A 10 A3 A9 07 E5 .#).e
                    bcs       L262B               * 263F 25 EA          %j
                    bra       L2658               * 2641 20 15           .
L2643               ldb       ,S                  * 2643 E6 E4          fd
                    cmpb      #94                 * 2645 C1 5E          A^
                    bne       L2658               * 2647 26 0F          &.
                    ldd       <U003F              * 2649 DC 3F          \?
                    beq       L2652               * 264B 27 05          '.
                    lbsr      L243D               * 264D 17 FD ED       .}m
                    bra       L2658               * 2650 20 06           .
L2652               ldd       <U0031              * 2652 DC 31          \1
                    coma                          * 2654 43             C
                    comb                          * 2655 53             S
                    std       <U0031              * 2656 DD 31          ]1
L2658               ldd       #1                  * 2658 CC 00 01       L..
                    bra       L265F               * 265B 20 02           .
L265D               bsr       L2663               * 265D 8D 04          ..
L265F               leas      3,S                 * 265F 32 63          2c
                    puls      PC,U                * 2661 35 C0          5@
L2663               pshs      U                   * 2663 34 40          4@
                    ldd       #-72                * 2665 CC FF B8       L.8
                    lbsr      _stkcheck           * 2668 17 DA A3       .Z#
                    leas      -2,S                * 266B 32 7E          2~
                    ldb       [>U0062,Y]          * 266D E6 B9 00 62    f9.b
                    sex                           * 2671 1D             .
                    tfr       D,X                 * 2672 1F 01          ..
                    lbra      L2730               * 2674 16 00 B9       ..9
L2677               ldd       <U003F              * 2677 DC 3F          \?
                    std       ,S                  * 2679 ED E4          md
                    ldd       <U0062              * 267B DC 62          \b
                    addd      #1                  * 267D C3 00 01       C..
                    std       <U0062              * 2680 DD 62          ]b
                    lbsr      L244E               * 2682 17 FD C9       .}I
                    std       -2,S                * 2685 ED 7E          m~
                    beq       L26A4               * 2687 27 1B          '.
                    ldb       [>U0062,Y]          * 2689 E6 B9 00 62    f9.b
                    cmpb      #41                 * 268D C1 29          A)
                    bne       L2699               * 268F 26 08          &.
                    ldd       <U003F              * 2691 DC 3F          \?
                    ora       ,S                  * 2693 AA E4          *d
                    orb       1,S                 * 2695 EA 61          ja
                    bra       L26E9               * 2697 20 50           P
L2699               leax      >L2865,PC           * 2699 30 8D 01 C8    0..H
                    pshs      X                   * 269D 34 10          4.
                    lbsr      L074E               * 269F 17 E0 AC       .`,
                    leas      2,S                 * 26A2 32 62          2b
L26A4               clra                          * 26A4 4F             O
                    clrb                          * 26A5 5F             _
                    puls      PC,U,X              * 26A6 35 D0          5P
L26A8               ldd       <U004B              * 26A8 DC 4B          \K
                    bne       L26C7               * 26AA 26 1B          &.
                    ldd       <U0053              * 26AC DC 53          \S
                    bne       L26BF               * 26AE 26 0F          &.
                    leax      >L2879,PC           * 26B0 30 8D 01 C5    0..E
                    pshs      X                   * 26B4 34 10          4.
                    lbsr      L074E               * 26B6 17 E0 95       .`.
                    leas      2,S                 * 26B9 32 62          2b
                    std       <U0031              * 26BB DD 31          ]1
                    puls      PC,U,X              * 26BD 35 D0          5P
L26BF               ldd       [>U0053,Y]          * 26BF EC B9 00 53    l9.S
                    std       <U0031              * 26C3 DD 31          ]1
                    bra       L26FE               * 26C5 20 37           7
L26C7               ldd       [>U004B,Y]          * 26C7 EC B9 00 4B    l9.K
                    std       <U0031              * 26CB DD 31          ]1
                    ldb       <U005D              * 26CD D6 5D          V]
                    stb       [>Y07E5,Y]          * 26CF E7 B9 07 E5    g9.e
                    ldd       <U007A              * 26D3 DC 7A          \z
                    ldx       >Y07E5,Y            * 26D5 AE A9 07 E5    .).e
                    std       1,X                 * 26D9 ED 01          m.
                    ldd       >Y07E5,Y            * 26DB EC A9 07 E5    l).e
                    addd      #3                  * 26DF C3 00 03       C..
                    std       >Y07E5,Y            * 26E2 ED A9 07 E5    m).e
                    ldd       #1                  * 26E6 CC 00 01       L..
L26E9               std       <U003F              * 26E9 DD 3F          ]?
                    bra       L26FE               * 26EB 20 11           .
L26ED               ldx       <U0062              * 26ED 9E 62          .b
                    leax      1,X                 * 26EF 30 01          0.
                    stx       <U0062              * 26F1 9F 62          .b
                    ldb       ,X                  * 26F3 E6 84          f.
                    sex                           * 26F5 1D             .
                    std       <U0031              * 26F6 DD 31          ]1
                    bne       L26FE               * 26F8 26 04          &.
                    clra                          * 26FA 4F             O
                    clrb                          * 26FB 5F             _
                    puls      PC,U,X              * 26FC 35 D0          5P
L26FE               ldd       <U0062              * 26FE DC 62          \b
                    addd      #1                  * 2700 C3 00 01       C..
                    std       <U0062              * 2703 DD 62          ]b
                    bra       L2745               * 2705 20 3E           >
L2707               bsr       L274A               * 2707 8D 41          .A
                    std       -2,S                * 2709 ED 7E          m~
                    bne       L2745               * 270B 26 38          &8
                    leax      >Y05BD,Y            * 270D 30 A9 05 BD    0).=
                    pshs      X                   * 2711 34 10          4.
                    lbsr      L1E0B               * 2713 17 F6 F5       .vu
                    std       ,S++                * 2716 ED E1          ma
                    beq       L271F               * 2718 27 05          '.
                    lbsr      L1F99               * 271A 17 F8 7C       .x|
                    bra       L2745               * 271D 20 26           &
L271F               leax      >L2887,PC           * 271F 30 8D 01 64    0..d
                    pshs      X                   * 2723 34 10          4.
                    lbsr      L074E               * 2725 17 E0 26       .`&
                    leas      2,S                 * 2728 32 62          2b
                    std       <U0031              * 272A DD 31          ]1
                    puls      PC,U,X              * 272C 35 D0          5P
                    bra       L2745               * 272E 20 15           .
L2730               cmpx      #40                 * 2730 8C 00 28       ..(
                    lbeq      L2677               * 2733 10 27 FF 40    .'.@
                    cmpx      #42                 * 2737 8C 00 2A       ..*
                    lbeq      L26A8               * 273A 10 27 FF 6A    .'.j
                    cmpx      #39                 * 273E 8C 00 27       ..'
                    beq       L26ED               * 2741 27 AA          '*
                    bra       L2707               * 2743 20 C2           B
L2745               ldd       #1                  * 2745 CC 00 01       L..
                    puls      PC,U,X              * 2748 35 D0          5P
L274A               pshs      U                   * 274A 34 40          4@
                    ldd       #-72                * 274C CC FF B8       L.8
                    lbsr      _stkcheck           * 274F 17 D9 BC       .Y<
                    leas      -6,S                * 2752 32 7A          2z
                    clra                          * 2754 4F             O
                    clrb                          * 2755 5F             _
                    std       4,S                 * 2756 ED 64          md
                    clra                          * 2758 4F             O
                    clrb                          * 2759 5F             _
                    std       2,S                 * 275A ED 62          mb
                    ldd       #8                  * 275C CC 00 08       L..
                    stb       1,S                 * 275F E7 61          ga
                    ldb       [>U0062,Y]          * 2761 E6 B9 00 62    f9.b
                    stb       ,S                  * 2765 E7 E4          gd
                    sex                           * 2767 1D             .
                    tfr       D,X                 * 2768 1F 01          ..
                    bra       L27AD               * 276A 20 41           A
L276C               ldx       <U0062              * 276C 9E 62          .b
                    leax      1,X                 * 276E 30 01          0.
                    stx       <U0062              * 2770 9F 62          .b
                    ldb       ,X                  * 2772 E6 84          f.
                    stb       ,S                  * 2774 E7 E4          gd
                    ldd       #2                  * 2776 CC 00 02       L..
                    std       4,S                 * 2779 ED 64          md
                    ldd       #16                 * 277B CC 00 10       L..
                    bra       L2792               * 277E 20 12           .
L2780               ldx       <U0062              * 2780 9E 62          .b
                    leax      1,X                 * 2782 30 01          0.
                    stx       <U0062              * 2784 9F 62          .b
                    ldb       ,X                  * 2786 E6 84          f.
                    stb       ,S                  * 2788 E7 E4          gd
                    ldd       #16                 * 278A CC 00 10       L..
                    std       4,S                 * 278D ED 64          md
                    ldd       #32                 * 278F CC 00 20       L.
L2792               stb       1,S                 * 2792 E7 61          ga
                    bra       L27B9               * 2794 20 23           #
L2796               ldb       ,S                  * 2796 E6 E4          fd
                    sex                           * 2798 1D             .
                    leax      >Y03FC,Y            * 2799 30 A9 03 FC    0).|
                    leax      D,X                 * 279D 30 8B          0.
                    ldb       ,X                  * 279F E6 84          f.
                    clra                          * 27A1 4F             O
                    andb      #8                  * 27A2 C4 08          D.
                    beq       L27B9               * 27A4 27 13          '.
                    ldd       #10                 * 27A6 CC 00 0A       L..
                    std       4,S                 * 27A9 ED 64          md
                    bra       L27B9               * 27AB 20 0C           .
L27AD               cmpx      #37                 * 27AD 8C 00 25       ..%
                    beq       L276C               * 27B0 27 BA          ':
                    cmpx      #36                 * 27B2 8C 00 24       ..$
                    beq       L2780               * 27B5 27 C9          'I
                    bra       L2796               * 27B7 20 DD           ]
L27B9               ldd       4,S                 * 27B9 EC 64          ld
                    bne       L27C2               * 27BB 26 05          &.
                    clra                          * 27BD 4F             O
                    clrb                          * 27BE 5F             _
                    lbra      L2833               * 27BF 16 00 71       ..q
L27C2               clra                          * 27C2 4F             O
                    clrb                          * 27C3 5F             _
                    std       <U0031              * 27C4 DD 31          ]1
                    bra       L27FC               * 27C6 20 34           4
L27C8               ldd       <U0031              * 27C8 DC 31          \1
                    pshs      D                   * 27CA 34 06          4.
                    ldd       6,S                 * 27CC EC 66          lf
                    lbsr      L466A               * 27CE 17 1E 99       ...
                    pshs      D                   * 27D1 34 06          4.
                    ldb       2,S                 * 27D3 E6 62          fb
                    cmpb      #65                 * 27D5 C1 41          AA
                    bge       L27E1               * 27D7 2C 08          ,.
                    ldb       2,S                 * 27D9 E6 62          fb
                    sex                           * 27DB 1D             .
                    addd      #-48                * 27DC C3 FF D0       C.P
                    bra       L27E7               * 27DF 20 06           .
L27E1               ldb       2,S                 * 27E1 E6 62          fb
                    sex                           * 27E3 1D             .
                    addd      #-55                * 27E4 C3 FF C9       C.I
L27E7               addd      ,S++                * 27E7 E3 E1          ca
                    std       <U0031              * 27E9 DD 31          ]1
                    ldd       2,S                 * 27EB EC 62          lb
                    addd      #1                  * 27ED C3 00 01       C..
                    std       2,S                 * 27F0 ED 62          mb
                    ldx       <U0062              * 27F2 9E 62          .b
                    leax      1,X                 * 27F4 30 01          0.
                    stx       <U0062              * 27F6 9F 62          .b
                    ldb       ,X                  * 27F8 E6 84          f.
                    stb       ,S                  * 27FA E7 E4          gd
L27FC               ldb       ,S                  * 27FC E6 E4          fd
                    sex                           * 27FE 1D             .
                    leax      >Y03FC,Y            * 27FF 30 A9 03 FC    0).|
                    leax      D,X                 * 2803 30 8B          0.
                    ldb       ,X                  * 2805 E6 84          f.
                    clra                          * 2807 4F             O
                    andb      #4                  * 2808 C4 04          D.
                    beq       L2813               * 280A 27 07          '.
                    ldb       ,S                  * 280C E6 E4          fd
                    clra                          * 280E 4F             O
                    andb      #223                * 280F C4 DF          D_
                    bra       L2816               * 2811 20 03           .
L2813               ldb       ,S                  * 2813 E6 E4          fd
                    sex                           * 2815 1D             .
L2816               stb       ,S                  * 2816 E7 E4          gd
                    sex                           * 2818 1D             .
                    leax      >Y03FC,Y            * 2819 30 A9 03 FC    0).|
                    leax      D,X                 * 281D 30 8B          0.
                    ldb       ,X                  * 281F E6 84          f.
                    sex                           * 2821 1D             .
                    pshs      D                   * 2822 34 06          4.
                    ldb       3,S                 * 2824 E6 63          fc
                    sex                           * 2826 1D             .
                    anda      ,S+                 * 2827 A4 E0          $`
                    andb      ,S+                 * 2829 E4 E0          d`
                    std       -2,S                * 282B ED 7E          m~
                    lbne      L27C8               * 282D 10 26 FF 97    .&..
                    ldd       2,S                 * 2831 EC 62          lb
L2833               leas      6,S                 * 2833 32 66          2f
                    puls      PC,U                * 2835 35 C0          5@
L2837               fcc       "value out of range" * 2837 76 61 6C 75 65 20 6F 75 74 20 6F 66 20 72 61 6E 67 65 value out of range
                    fcb       $00                 * 2849 00             .
L284A               fcc       "bad operator"      * 284A 62 61 64 20 6F 70 65 72 61 74 6F 72 bad operator
                    fcb       $00                 * 2856 00             .
L2857               fcc       "zero division"     * 2857 7A 65 72 6F 20 64 69 76 69 73 69 6F 6E zero division
                    fcb       $00                 * 2864 00             .
L2865               fcc       "parenthesis missing" * 2865 70 61 72 65 6E 74 68 65 73 69 73 20 6D 69 73 73 69 6E 67 parenthesis missing
                    fcb       $00                 * 2878 00             .
L2879               fcc       "undefined org"     * 2879 75 6E 64 65 66 69 6E 65 64 20 6F 72 67 undefined org
                    fcb       $00                 * 2886 00             .
L2887               fcc       "bad operand"       * 2887 62 61 64 20 6F 70 65 72 61 6E 64 bad operand
                    fcb       $00                 * 2892 00             .
L2893               pshs      U                   * 2893 34 40          4@
                    leas      -1,S                * 2895 32 7F          2.
                    clra                          * 2897 4F             O
                    clrb                          * 2898 5F             _
                    std       <U0017              * 2899 DD 17          ].
                    std       <U0015              * 289B DD 15          ].
                    leax      >Y0496,Y            * 289D 30 A9 04 96    0)..
                    stx       <U0019              * 28A1 9F 19          ..
                    lbra      L291C               * 28A3 16 00 76       ..v
L28A6               ldx       7,S                 * 28A6 AE 67          .g
                    ldb       [,X]                * 28A8 E6 94          f.
                    cmpb      #45                 * 28AA C1 2D          A-
                    bne       L28F8               * 28AC 26 4A          &J
                    ldd       [<$07,S]            * 28AE EC F8 07       lx.
                    addd      #1                  * 28B1 C3 00 01       C..
                    std       <U0062              * 28B4 DD 62          ]b
                    lbsr      L1A48               * 28B6 17 F1 8F       .q.
                    ldb       <U00C6              * 28B9 D6 C6          VF
                    lbeq      L291C               * 28BB 10 27 00 5D    .'.]
                    ldx       <U0062              * 28BF 9E 62          .b
                    ldb       -1,X                * 28C1 E6 1F          f.
                    clra                          * 28C3 4F             O
                    andb      #223                * 28C4 C4 DF          D_
                    stb       ,S                  * 28C6 E7 E4          gd
                    beq       L291C               * 28C8 27 52          'R
                    ldb       ,S                  * 28CA E6 E4          fd
                    cmpb      #79                 * 28CC C1 4F          AO
                    bne       L291C               * 28CE 26 4C          &L
                    ldb       [>U0062,Y]          * 28D0 E6 B9 00 62    f9.b
                    cmpb      #61                 * 28D4 C1 3D          A=
                    bne       L291C               * 28D6 26 44          &D
                    ldd       >Y03F8,Y            * 28D8 EC A9 03 F8    l).x
                    beq       L28EB               * 28DC 27 0D          '.
                    leax      >L30DB,PC           * 28DE 30 8D 07 F9    0..y
                    pshs      X                   * 28E2 34 10          4.
                    lbsr      L078B               * 28E4 17 DE A4       .^$
                    leas      2,S                 * 28E7 32 62          2b
                    bra       L291C               * 28E9 20 31           1
L28EB               ldd       <U0062              * 28EB DC 62          \b
                    addd      #1                  * 28ED C3 00 01       C..
                    std       <U0062              * 28F0 DD 62          ]b
                    std       >Y03F8,Y            * 28F2 ED A9 03 F8    m).x
                    bra       L291C               * 28F6 20 24           $
L28F8               leax      >Y0855,Y            * 28F8 30 A9 08 55    0).U
                    cmpx      >Y03F6,Y            * 28FC AC A9 03 F6    ,).v
                    bcc       L290D               * 2900 24 0B          $.
                    leax      >L30F1,PC           * 2902 30 8D 07 EB    0..k
                    pshs      X                   * 2906 34 10          4.
                    lbsr      L078B               * 2908 17 DE 80       .^.
                    leas      2,S                 * 290B 32 62          2b
L290D               ldd       [<$07,S]            * 290D EC F8 07       lx.
                    ldx       >Y03F6,Y            * 2910 AE A9 03 F6    .).v
                    leax      2,X                 * 2914 30 02          0.
                    stx       >Y03F6,Y            * 2916 AF A9 03 F6    /).v
                    std       -2,X                * 291A ED 1E          m.
L291C               ldd       7,S                 * 291C EC 67          lg
                    addd      #2                  * 291E C3 00 02       C..
                    std       7,S                 * 2921 ED 67          mg
                    ldd       5,S                 * 2923 EC 65          le
                    addd      #-1                 * 2925 C3 FF FF       C..
                    std       5,S                 * 2928 ED 65          me
                    lbne      L28A6               * 292A 10 26 FF 78    .&.x
                    leax      >Y0817,Y            * 292E 30 A9 08 17    0)..
                    cmpx      >Y03F6,Y            * 2932 AC A9 03 F6    ,).v
                    bne       L2943               * 2936 26 0B          &.
                    leax      >L3106,PC           * 2938 30 8D 07 CA    0..J
                    pshs      X                   * 293C 34 10          4.
                    lbsr      L078B               * 293E 17 DE 4A       .^J
                    leas      2,S                 * 2941 32 62          2b
L2943               ldd       >Y03F8,Y            * 2943 EC A9 03 F8    l).x
                    bne       L2951               * 2947 26 08          &.
                    leax      >L3114,PC           * 2949 30 8D 07 C7    0..G
                    stx       >Y03F8,Y            * 294D AF A9 03 F8    /).x
L2951               leas      1,S                 * 2951 32 61          2a
                    puls      PC,U                * 2953 35 C0          5@
L2955               pshs      U,D                 * 2955 34 46          4F
                    ldd       8,S                 * 2957 EC 68          lh
                    pshs      D                   * 2959 34 06          4.
                    ldd       8,S                 * 295B EC 68          lh
                    pshs      D                   * 295D 34 06          4.
                    lbsr      fopen               * 295F 17 0F BC       ..<
                    leas      4,S                 * 2962 32 64          2d
                    std       ,S                  * 2964 ED E4          md
                    bne       L2988               * 2966 26 20          &
                    ldd       6,S                 * 2968 EC 66          lf
                    pshs      D                   * 296A 34 06          4.
                    leax      >L311D,PC           * 296C 30 8D 07 AD    0..-
                    pshs      X                   * 2970 34 10          4.
                    leax      >Y04A3,Y            * 2972 30 A9 04 A3    0).#
                    pshs      X                   * 2976 34 10          4.
                    lbsr      L3A0E               * 2978 17 10 93       ...
                    leas      6,S                 * 297B 32 66          2f
                    leax      >L3125,PC           * 297D 30 8D 07 A4    0..$
                    pshs      X                   * 2981 34 10          4.
                    lbsr      L078B               * 2983 17 DE 05       .^.
                    leas      2,S                 * 2986 32 62          2b
L2988               ldd       ,S                  * 2988 EC E4          ld
                    puls      PC,U,X              * 298A 35 D0          5P
L298C               pshs      U                   * 298C 34 40          4@
                    ldb       <U005B              * 298E D6 5B          V[
                    lbeq      L2A7D               * 2990 10 27 00 E9    .'.i
                    ldd       <U003D              * 2994 DC 3D          \=
                    lbeq      L2A7D               * 2996 10 27 00 E3    .'.c
                    ldd       >U00C8,Y            * 299A EC A9 00 C8    l).H
                    beq       L29D6               * 299E 27 36          '6
                    ldb       <U00C0              * 29A0 D6 C0          V@
                    beq       L29CD               * 29A2 27 29          ')
                    ldd       <U0019              * 29A4 DC 19          \.
                    pshs      D                   * 29A6 34 06          4.
                    ldd       #12                 * 29A8 CC 00 0C       L..
                    pshs      D                   * 29AB 34 06          4.
                    lbsr      L40C2               * 29AD 17 17 12       ...
                    leas      4,S                 * 29B0 32 64          2d
                    bra       L29D6               * 29B2 20 22           "
L29B4               ldd       <U0019              * 29B4 DC 19          \.
                    pshs      D                   * 29B6 34 06          4.
                    ldd       #13                 * 29B8 CC 00 0D       L..
                    pshs      D                   * 29BB 34 06          4.
                    lbsr      L40C2               * 29BD 17 17 02       ...
                    leas      4,S                 * 29C0 32 64          2d
                    ldd       >U00C8,Y            * 29C2 EC A9 00 C8    l).H
                    addd      #1                  * 29C6 C3 00 01       C..
                    std       >U00C8,Y            * 29C9 ED A9 00 C8    m).H
L29CD               ldd       >U00C8,Y            * 29CD EC A9 00 C8    l).H
                    cmpd      <U0003              * 29D1 10 93 03       ...
                    blt       L29B4               * 29D4 2D DE          -^
L29D6               leax      >Y07F9,Y            * 29D6 30 A9 07 F9    0).y
                    pshs      X                   * 29DA 34 10          4.
                    lbsr      L49FA               * 29DC 17 20 1B       . .
                    leas      2,S                 * 29DF 32 62          2b
                    ldb       >Y07FD,Y            * 29E1 E6 A9 07 FD    f).}
                    sex                           * 29E5 1D             .
                    pshs      D                   * 29E6 34 06          4.
                    ldb       >Y07FC,Y            * 29E8 E6 A9 07 FC    f).|
                    sex                           * 29EC 1D             .
                    pshs      D                   * 29ED 34 06          4.
                    ldb       >Y07FB,Y            * 29EF E6 A9 07 FB    f).{
                    sex                           * 29F3 1D             .
                    pshs      D                   * 29F4 34 06          4.
                    ldb       >Y07FA,Y            * 29F6 E6 A9 07 FA    f).z
                    sex                           * 29FA 1D             .
                    pshs      D                   * 29FB 34 06          4.
                    ldb       >Y07F9,Y            * 29FD E6 A9 07 F9    f).y
                    sex                           * 2A01 1D             .
                    pshs      D                   * 2A02 34 06          4.
                    leax      >L3160,PC           * 2A04 30 8D 07 58    0..X
                    pshs      X                   * 2A08 34 10          4.
                    leax      >L3135,PC           * 2A0A 30 8D 07 27    0..'
                    pshs      X                   * 2A0E 34 10          4.
                    lbsr      L39FC               * 2A10 17 0F E9       ..i
                    leas      14,S                * 2A13 32 6E          2n
                    ldd       <U002D              * 2A15 DC 2D          \-
                    addd      #1                  * 2A17 C3 00 01       C..
                    std       <U002D              * 2A1A DD 2D          ]-
                    pshs      D                   * 2A1C 34 06          4.
                    ldd       >Y0817,Y            * 2A1E EC A9 08 17    l)..
                    pshs      D                   * 2A22 34 06          4.
                    leax      >L316B,PC           * 2A24 30 8D 07 43    0..C
                    pshs      X                   * 2A28 34 10          4.
                    lbsr      L39FC               * 2A2A 17 0F CF       ..O
                    leas      6,S                 * 2A2D 32 66          2f
                    leax      >Y063F,Y            * 2A2F 30 A9 06 3F    0).?
                    pshs      X                   * 2A33 34 10          4.
                    leax      >Y05C7,Y            * 2A35 30 A9 05 C7    0).G
                    pshs      X                   * 2A39 34 10          4.
                    leax      >L317E,PC           * 2A3B 30 8D 07 3F    0..?
                    pshs      X                   * 2A3F 34 10          4.
                    lbsr      L39FC               * 2A41 17 0F B8       ..8
                    leas      6,S                 * 2A44 32 66          2f
                    ldd       #3                  * 2A46 CC 00 03       L..
                    bra       L2A79               * 2A49 20 2E           .
L2A4B               pshs      U                   * 2A4B 34 40          4@
                    ldb       <U005B              * 2A4D D6 5B          V[
                    beq       L2A7D               * 2A4F 27 2C          ',
                    ldd       <U003D              * 2A51 DC 3D          \=
                    beq       L2A7D               * 2A53 27 28          '(
                    ldd       <U0003              * 2A55 DC 03          \.
                    addd      #-3                 * 2A57 C3 FF FD       C.}
                    cmpd      >U00C8,Y            * 2A5A 10 A3 A9 00 C8 .#).H
                    bge       L2A64               * 2A5F 2C 03          ,.
                    lbsr      L298C               * 2A61 17 FF 28       ..(
L2A64               ldd       <U0019              * 2A64 DC 19          \.
                    pshs      D                   * 2A66 34 06          4.
                    ldd       #13                 * 2A68 CC 00 0D       L..
                    pshs      D                   * 2A6B 34 06          4.
                    lbsr      L40C2               * 2A6D 17 16 52       ..R
                    leas      4,S                 * 2A70 32 64          2d
                    ldd       >U00C8,Y            * 2A72 EC A9 00 C8    l).H
                    addd      #1                  * 2A76 C3 00 01       C..
L2A79               std       >U00C8,Y            * 2A79 ED A9 00 C8    m).H
L2A7D               puls      PC,U                * 2A7D 35 C0          5@
L2A7F               pshs      U                   * 2A7F 34 40          4@
                    leas      -3,S                * 2A81 32 7D          2}
                    lbsr      L342B               * 2A83 17 09 A5       ..%
                    std       -2,S                * 2A86 ED 7E          m~
                    bne       L2AC1               * 2A88 26 37          &7
L2A8A               ldb       <U00C2              * 2A8A D6 C2          VB
                    beq       L2AA3               * 2A8C 27 15          '.
                    leax      >Y07FF,Y            * 2A8E 30 A9 07 FF    0)..
                    cmpx      >Y03F4,Y            * 2A92 AC A9 03 F4    ,).t
                    bne       L2AA3               * 2A96 26 0B          &.
                    leax      >L3188,PC           * 2A98 30 8D 06 EC    0..l
                    pshs      X                   * 2A9C 34 10          4.
                    lbsr      L39FC               * 2A9E 17 0F 5B       ..[
                    leas      2,S                 * 2AA1 32 62          2b
L2AA3               leax      >Y0857,Y            * 2AA3 30 A9 08 57    0).W
                    stx       <U0062              * 2AA7 9F 62          .b
                    tfr       X,D                 * 2AA9 1F 10          ..
                    std       1,S                 * 2AAB ED 61          ma
                    bra       L2AD0               * 2AAD 20 21           !
L2AAF               ldb       ,S                  * 2AAF E6 E4          fd
                    cmpb      #13                 * 2AB1 C1 0D          A.
                    bne       L2AC6               * 2AB3 26 11          &.
                    clra                          * 2AB5 4F             O
                    clrb                          * 2AB6 5F             _
                    stb       [<$01,S]            * 2AB7 E7 F8 01       gx.
                    ldd       <U002F              * 2ABA DC 2F          \/
                    addd      #1                  * 2ABC C3 00 01       C..
                    std       <U002F              * 2ABF DD 2F          ]/
L2AC1               ldd       #1                  * 2AC1 CC 00 01       L..
                    bra       L2AEC               * 2AC4 20 26           &
L2AC6               ldb       ,S                  * 2AC6 E6 E4          fd
                    ldx       1,S                 * 2AC8 AE 61          .a
                    leax      1,X                 * 2ACA 30 01          0.
                    stx       1,S                 * 2ACC AF 61          /a
                    stb       -1,X                * 2ACE E7 1F          g.
L2AD0               ldd       <U0015              * 2AD0 DC 15          \.
                    pshs      D                   * 2AD2 34 06          4.
                    lbsr      L42D5               * 2AD4 17 17 FE       ..~
                    leas      2,S                 * 2AD7 32 62          2b
                    stb       ,S                  * 2AD9 E7 E4          gd
                    sex                           * 2ADB 1D             .
                    cmpd      #-1                 * 2ADC 10 83 FF FF    ....
                    bne       L2AAF               * 2AE0 26 CD          &M
                    bsr       L2AF0               * 2AE2 8D 0C          ..
                    std       -2,S                * 2AE4 ED 7E          m~
                    lbne      L2A8A               * 2AE6 10 26 FF A0    .&.
                    clra                          * 2AEA 4F             O
                    clrb                          * 2AEB 5F             _
L2AEC               leas      3,S                 * 2AEC 32 63          2c
                    puls      PC,U                * 2AEE 35 C0          5@
L2AF0               pshs      U                   * 2AF0 34 40          4@
                    leax      >Y07FF,Y            * 2AF2 30 A9 07 FF    0)..
                    cmpx      >Y03F4,Y            * 2AF6 AC A9 03 F4    ,).t
                    bne       L2B00               * 2AFA 26 04          &.
                    clra                          * 2AFC 4F             O
                    clrb                          * 2AFD 5F             _
                    puls      PC,U                * 2AFE 35 C0          5@
L2B00               ldd       <U0015              * 2B00 DC 15          \.
                    pshs      D                   * 2B02 34 06          4.
                    lbsr      fclose              * 2B04 17 16 AB       ..+
                    std       ,S++                * 2B07 ED E1          ma
                    beq       L2B16               * 2B09 27 0B          '.
                    leax      >L318D,PC           * 2B0B 30 8D 06 7E    0..~
                    pshs      X                   * 2B0F 34 10          4.
                    lbsr      L074E               * 2B11 17 DC 3A       .\:
                    leas      2,S                 * 2B14 32 62          2b
L2B16               ldx       >Y03F4,Y            * 2B16 AE A9 03 F4    .).t
                    leax      -2,X                * 2B1A 30 1E          0.
                    stx       >Y03F4,Y            * 2B1C AF A9 03 F4    /).t
                    ldd       ,X                  * 2B20 EC 84          l.
                    std       <U0015              * 2B22 DD 15          ].
                    ldd       #1                  * 2B24 CC 00 01       L..
                    puls      PC,U                * 2B27 35 C0          5@
L2B29               pshs      U                   * 2B29 34 40          4@
                    leax      >L319E,PC           * 2B2B 30 8D 06 6F    0..o
                    pshs      X                   * 2B2F 34 10          4.
                    lbsr      L39FC               * 2B31 17 0E C8       ..H
                    leas      2,S                 * 2B34 32 62          2b
                    ldd       <U0005              * 2B36 DC 05          \.
                    subd      #24                 * 2B38 83 00 18       ...
                    std       <U0005              * 2B3B DD 05          ].
                    leax      >L2B64,PC           * 2B3D 30 8D 00 23    0..#
                    pshs      X                   * 2B41 34 10          4.
                    lbsr      L2EF2               * 2B43 17 03 AC       ..,
                    leas      2,S                 * 2B46 32 62          2b
                    ldd       >Y03FA,Y            * 2B48 EC A9 03 FA    l).z
                    ble       L2B59               * 2B4C 2F 0B          /.
                    leax      >L31AD,PC           * 2B4E 30 8D 06 5B    0..[
                    pshs      X                   * 2B52 34 10          4.
                    lbsr      L39FC               * 2B54 17 0E A5       ..%
                    leas      2,S                 * 2B57 32 62          2b
L2B59               leax      >L31AF,PC           * 2B59 30 8D 06 52    0..R
                    pshs      X                   * 2B5D 34 10          4.
                    lbsr      L39FC               * 2B5F 17 0E 9A       ...
                    puls      PC,U,X              * 2B62 35 D0          5P
L2B64               pshs      U                   * 2B64 34 40          4@
                    ldu       4,S                 * 2B66 EE 64          nd
                    ldd       >Y03FA,Y            * 2B68 EC A9 03 FA    l).z
                    ble       L2B79               * 2B6C 2F 0B          /.
                    leax      >L31B1,PC           * 2B6E 30 8D 06 3F    0..?
                    pshs      X                   * 2B72 34 10          4.
                    lbsr      L39FC               * 2B74 17 0E 85       ...
                    leas      2,S                 * 2B77 32 62          2b
L2B79               ldd       2,U                 * 2B79 EC 42          lB
                    pshs      D                   * 2B7B 34 06          4.
                    ldb       1,U                 * 2B7D E6 41          fA
                    clra                          * 2B7F 4F             O
                    pshs      D                   * 2B80 34 06          4.
                    ldb       ,U                  * 2B82 E6 C4          fD
                    clra                          * 2B84 4F             O
                    pshs      D                   * 2B85 34 06          4.
                    pshs      U                   * 2B87 34 40          4@
                    ldd       #10                 * 2B89 CC 00 0A       L..
                    addd      ,S++                * 2B8C E3 E1          ca
                    pshs      D                   * 2B8E 34 06          4.
                    leax      >L31B5,PC           * 2B90 30 8D 06 21    0..!
                    pshs      X                   * 2B94 34 10          4.
                    lbsr      L39FC               * 2B96 17 0E 63       ..c
                    leas      10,S                * 2B99 32 6A          2j
                    ldd       >Y03FA,Y            * 2B9B EC A9 03 FA    l).z
                    addd      #25                 * 2B9F C3 00 19       C..
                    std       >Y03FA,Y            * 2BA2 ED A9 03 FA    m).z
                    cmpd      <U0005              * 2BA6 10 93 05       ...
                    bgt       L2BAF               * 2BA9 2E 04          ..
                    ldb       <U00C5              * 2BAB D6 C5          VE
                    beq       L2BC0               * 2BAD 27 11          '.
L2BAF               leax      >L31CB,PC           * 2BAF 30 8D 06 18    0...
                    pshs      X                   * 2BB3 34 10          4.
                    lbsr      L39FC               * 2BB5 17 0E 44       ..D
                    leas      2,S                 * 2BB8 32 62          2b
                    clra                          * 2BBA 4F             O
                    clrb                          * 2BBB 5F             _
                    std       >Y03FA,Y            * 2BBC ED A9 03 FA    m).z
L2BC0               puls      PC,U                * 2BC0 35 C0          5@
L2BC2               pshs      U                   * 2BC2 34 40          4@
                    leas      -16,S               * 2BC4 32 70          2p
                    ldb       [>U0062,Y]          * 2BC6 E6 B9 00 62    f9.b
                    lbeq      L2C7A               * 2BCA 10 27 00 AC    .'.,
                    leas      -2,S                * 2BCE 32 7E          2~
                    leau      2,S                 * 2BD0 33 62          3b
                    ldd       #16                 * 2BD2 CC 00 10       L..
                    std       ,S                  * 2BD5 ED E4          md
                    bra       L2BE3               * 2BD7 20 0A           .
L2BD9               ldx       <U0062              * 2BD9 9E 62          .b
                    leax      1,X                 * 2BDB 30 01          0.
                    stx       <U0062              * 2BDD 9F 62          .b
                    ldb       -1,X                * 2BDF E6 1F          f.
                    stb       ,U+                 * 2BE1 E7 C0          g@
L2BE3               ldd       ,S                  * 2BE3 EC E4          ld
                    addd      #-1                 * 2BE5 C3 FF FF       C..
                    std       ,S                  * 2BE8 ED E4          md
                    subd      #-1                 * 2BEA 83 FF FF       ...
                    beq       L2BFD               * 2BED 27 0E          '.
                    ldb       [>U0062,Y]          * 2BEF E6 B9 00 62    f9.b
                    beq       L2BFD               * 2BF3 27 08          '.
                    ldb       [>U0062,Y]          * 2BF5 E6 B9 00 62    f9.b
                    cmpb      #44                 * 2BF9 C1 2C          A,
                    bne       L2BD9               * 2BFB 26 DC          &\
L2BFD               clra                          * 2BFD 4F             O
                    clrb                          * 2BFE 5F             _
                    stb       ,U                  * 2BFF E7 C4          gD
                    lbsr      L199A               * 2C01 17 ED 96       .m.
                    std       -2,S                * 2C04 ED 7E          m~
                    lbeq      L2C76               * 2C06 10 27 00 6C    .'.l
                    lbsr      L2426               * 2C0A 17 F8 19       .x.
                    lbsr      L2D99               * 2C0D 17 01 89       ...
                    ldd       <U0031              * 2C10 DC 31          \1
                    pshs      D                   * 2C12 34 06          4.
                    ldd       #8                  * 2C14 CC 00 08       L..
                    lbsr      L47AB               * 2C17 17 1B 91       ...
                    std       >Y03DC,Y            * 2C1A ED A9 03 DC    m).\
                    lbsr      L199A               * 2C1E 17 ED 79       .my
                    std       -2,S                * 2C21 ED 7E          m~
                    beq       L2C76               * 2C23 27 51          'Q
                    lbsr      L2426               * 2C25 17 F7 FE       .w~
                    lbsr      L2D99               * 2C28 17 01 6E       ..n
                    ldd       >Y03DC,Y            * 2C2B EC A9 03 DC    l).\
                    pshs      D                   * 2C2F 34 06          4.
                    ldd       <U0031              * 2C31 DC 31          \1
                    clra                          * 2C33 4F             O
                    ora       ,S+                 * 2C34 AA E0          *`
                    orb       ,S+                 * 2C36 EA E0          j`
                    std       >Y03DC,Y            * 2C38 ED A9 03 DC    m).\
                    lbsr      L199A               * 2C3C 17 ED 5B       .m[
                    std       -2,S                * 2C3F ED 7E          m~
                    beq       L2C76               * 2C41 27 33          '3
                    lbsr      L2426               * 2C43 17 F7 E0       .w`
                    lbsr      L2D99               * 2C46 17 01 50       ..P
                    ldd       <U0031              * 2C49 DC 31          \1
                    clra                          * 2C4B 4F             O
                    stb       >Y03E4,Y            * 2C4C E7 A9 03 E4    g).d
                    lbsr      L199A               * 2C50 17 ED 47       .mG
                    std       -2,S                * 2C53 ED 7E          m~
                    beq       L2C76               * 2C55 27 1F          '.
                    lbsr      L2426               * 2C57 17 F7 CC       .wL
                    lbsr      L2D99               * 2C5A 17 01 3C       ..<
                    ldd       <U0031              * 2C5D DC 31          \1
                    std       >Y03F0,Y            * 2C5F ED A9 03 F0    m).p
                    lbsr      L199A               * 2C63 17 ED 34       .m4
                    std       -2,S                * 2C66 ED 7E          m~
                    beq       L2C76               * 2C68 27 0C          '.
                    lbsr      L2426               * 2C6A 17 F7 B9       .w9
                    lbsr      L2D99               * 2C6D 17 01 29       ..)
                    ldd       <U0031              * 2C70 DC 31          \1
                    std       >Y03F2,Y            * 2C72 ED A9 03 F2    m).r
L2C76               leas      2,S                 * 2C76 32 62          2b
                    bra       L2C89               * 2C78 20 0F           .
L2C7A               leax      >L31CD,PC           * 2C7A 30 8D 05 4F    0..O
                    pshs      X                   * 2C7E 34 10          4.
                    leax      2,S                 * 2C80 30 62          0b
                    pshs      X                   * 2C82 34 10          4.
                    lbsr      L4514               * 2C84 17 18 8D       ...
                    leas      4,S                 * 2C87 32 64          2d
L2C89               leax      >Y07F9,Y            * 2C89 30 A9 07 F9    0).y
                    pshs      X                   * 2C8D 34 10          4.
                    lbsr      L49FA               * 2C8F 17 1D 68       ..h
                    leas      2,S                 * 2C92 32 62          2b
                    ldd       #5                  * 2C94 CC 00 05       L..
                    pshs      D                   * 2C97 34 06          4.
                    leax      >Y07F9,Y            * 2C99 30 A9 07 F9    0).y
                    pshs      X                   * 2C9D 34 10          4.
                    leax      >Y03DF,Y            * 2C9F 30 A9 03 DF    0)._
                    pshs      X                   * 2CA3 34 10          4.
                    lbsr      L458A               * 2CA5 17 18 E2       ..b
                    leas      6,S                 * 2CA8 32 66          2f
                    ldd       <U0023              * 2CAA DC 23          \#
                    stb       >Y03DE,Y            * 2CAC E7 A9 03 DE    g).^
                    ldd       <U0041              * 2CB0 DC 41          \A
                    std       >Y03E6,Y            * 2CB2 ED A9 03 E6    m).f
                    ldd       <U0043              * 2CB6 DC 43          \C
                    std       >Y03E8,Y            * 2CB8 ED A9 03 E8    m).h
                    ldd       <U0045              * 2CBC DC 45          \E
                    std       >Y03EA,Y            * 2CBE ED A9 03 EA    m).j
                    ldd       <U0047              * 2CC2 DC 47          \G
                    std       >Y03EC,Y            * 2CC4 ED A9 03 EC    m).l
                    ldd       <U004D              * 2CC8 DC 4D          \M
                    std       >Y03EE,Y            * 2CCA ED A9 03 EE    m).n
                    ldb       <U005B              * 2CCE D6 5B          V[
                    lbeq      L2D94               * 2CD0 10 27 00 C0    .'.@
                    ldd       <U0017              * 2CD4 DC 17          \.
                    lbeq      L2D94               * 2CD6 10 27 00 BA    .'.:
                    leax      >Y07E9,Y            * 2CDA 30 A9 07 E9    0).i
                    pshs      X                   * 2CDE 34 10          4.
                    ldd       <U0017              * 2CE0 DC 17          \.
                    pshs      D                   * 2CE2 34 06          4.
                    lbsr      L4059               * 2CE4 17 13 72       ..r
                    leas      2,S                 * 2CE7 32 62          2b
                    lbsr      L4636               * 2CE9 17 19 4A       ..J
                    ldd       <U0017              * 2CEC DC 17          \.
                    pshs      D                   * 2CEE 34 06          4.
                    ldd       #1                  * 2CF0 CC 00 01       L..
                    pshs      D                   * 2CF3 34 06          4.
                    ldd       #28                 * 2CF5 CC 00 1C       L..
                    pshs      D                   * 2CF8 34 06          4.
                    leax      >Y03D8,Y            * 2CFA 30 A9 03 D8    0).X
                    pshs      X                   * 2CFE 34 10          4.
                    lbsr      L39B2               * 2D00 17 0C AF       ../
                    leas      8,S                 * 2D03 32 68          2h
                    ldd       <U0017              * 2D05 DC 17          \.
                    pshs      D                   * 2D07 34 06          4.
                    leax      2,S                 * 2D09 30 62          0b
                    pshs      X                   * 2D0B 34 10          4.
                    lbsr      L3992               * 2D0D 17 0C 82       ...
                    leas      4,S                 * 2D10 32 64          2d
                    ldd       <U0017              * 2D12 DC 17          \.
                    pshs      D                   * 2D14 34 06          4.
                    clra                          * 2D16 4F             O
                    clrb                          * 2D17 5F             _
                    pshs      D                   * 2D18 34 06          4.
                    lbsr      L40C2               * 2D1A 17 13 A5       ..%
                    leas      4,S                 * 2D1D 32 64          2d
                    ldd       <U0017              * 2D1F DC 17          \.
                    pshs      D                   * 2D21 34 06          4.
                    ldd       #1                  * 2D23 CC 00 01       L..
                    pshs      D                   * 2D26 34 06          4.
                    ldd       #2                  * 2D28 CC 00 02       L..
                    pshs      D                   * 2D2B 34 06          4.
                    leax      >U0055,Y            * 2D2D 30 A9 00 55    0).U
                    pshs      X                   * 2D31 34 10          4.
                    lbsr      L39B2               * 2D33 17 0C 7C       ..|
                    leas      8,S                 * 2D36 32 68          2h
                    ldd       <U0055              * 2D38 DC 55          \U
                    beq       L2D47               * 2D3A 27 0B          '.
                    leax      >L2FC4,PC           * 2D3C 30 8D 02 84    0...
                    pshs      X                   * 2D40 34 10          4.
                    lbsr      L2EF2               * 2D42 17 01 AD       ..-
                    leas      2,S                 * 2D45 32 62          2b
L2D47               leax      >Y07F5,Y            * 2D47 30 A9 07 F5    0).u
                    pshs      X                   * 2D4B 34 10          4.
                    leax      >Y07F1,Y            * 2D4D 30 A9 07 F1    0).q
                    pshs      X                   * 2D51 34 10          4.
                    leax      >Y07ED,Y            * 2D53 30 A9 07 ED    0).m
                    pshs      X                   * 2D57 34 10          4.
                    leax      >Y03D4,Y            * 2D59 30 A9 03 D4    0).T
                    pshs      X                   * 2D5D 34 10          4.
                    ldd       <U0017              * 2D5F DC 17          \.
                    pshs      D                   * 2D61 34 06          4.
                    lbsr      L4059               * 2D63 17 12 F3       ..s
                    leas      2,S                 * 2D66 32 62          2b
                    lbsr      L4636               * 2D68 17 18 CB       ..K
                    lbsr      L4636               * 2D6B 17 18 C8       ..H
                    ldd       2,X                 * 2D6E EC 02          l.
                    pshs      D                   * 2D70 34 06          4.
                    ldd       ,X                  * 2D72 EC 84          l.
                    pshs      D                   * 2D74 34 06          4.
                    ldd       <U004D              * 2D76 DC 4D          \M
                    lbsr      L462B               * 2D78 17 18 B0       ..0
                    lbsr      L45A8               * 2D7B 17 18 2A       ..*
                    lbsr      L4636               * 2D7E 17 18 B5       ..5
                    ldd       2,X                 * 2D81 EC 02          l.
                    pshs      D                   * 2D83 34 06          4.
                    ldd       ,X                  * 2D85 EC 84          l.
                    pshs      D                   * 2D87 34 06          4.
                    ldd       <U0047              * 2D89 DC 47          \G
                    lbsr      L462B               * 2D8B 17 18 9D       ...
                    lbsr      L45A8               * 2D8E 17 18 17       ...
                    lbsr      L4636               * 2D91 17 18 A2       .."
L2D94               leas      <$10,S              * 2D94 32 E8 10       2h.
                    puls      PC,U                * 2D97 35 C0          5@
L2D99               pshs      U                   * 2D99 34 40          4@
                    ldb       <U005B              * 2D9B D6 5B          V[
                    lbeq      L2FC2               * 2D9D 10 27 02 21    .'.!
                    ldd       <U00BD              * 2DA1 DC BD          \=
                    lbeq      L2FC2               * 2DA3 10 27 02 1B    .'..
                    leax      >L31D5,PC           * 2DA7 30 8D 04 2A    0..*
                    pshs      X                   * 2DAB 34 10          4.
                    lbsr      L074E               * 2DAD 17 D9 9E       .Y.
                    lbra      L2FC0               * 2DB0 16 02 0D       ...
L2DB3               pshs      U,D                 * 2DB3 34 46          4F
                    leax      >Y03D8,Y            * 2DB5 30 A9 03 D8    0).X
                    tfr       X,D                 * 2DB9 1F 10          ..
                    leax      >Y03DE,Y            * 2DBB 30 A9 03 DE    0).^
                    nega                          * 2DBF 40             @
                    negb                          * 2DC0 50             P
                    sbca      #0                  * 2DC1 82 00          ..
                    leax      D,X                 * 2DC3 30 8B          0.
                    stx       ,S                  * 2DC5 AF E4          /d
                    ldd       <U0017              * 2DC7 DC 17          \.
                    lbeq      L2E39               * 2DC9 10 27 00 6C    .'.l
                    ldb       <U00C6              * 2DCD D6 C6          VF
                    lble      L2E39               * 2DCF 10 2F 00 66    ./.f
                    clra                          * 2DD3 4F             O
                    clrb                          * 2DD4 5F             _
                    pshs      D                   * 2DD5 34 06          4.
                    leax      >Y07E9,Y            * 2DD7 30 A9 07 E9    0).i
                    ldd       2,X                 * 2DDB EC 02          l.
                    pshs      D                   * 2DDD 34 06          4.
                    ldd       ,X                  * 2DDF EC 84          l.
                    pshs      D                   * 2DE1 34 06          4.
                    ldd       6,S                 * 2DE3 EC 66          lf
                    lbsr      L462B               * 2DE5 17 18 43       ..C
                    lbsr      L45A8               * 2DE8 17 17 BD       ..=
                    ldd       2,X                 * 2DEB EC 02          l.
                    pshs      D                   * 2DED 34 06          4.
                    ldd       ,X                  * 2DEF EC 84          l.
                    pshs      D                   * 2DF1 34 06          4.
                    ldd       <U0017              * 2DF3 DC 17          \.
                    pshs      D                   * 2DF5 34 06          4.
                    lbsr      L3F02               * 2DF7 17 11 08       ...
                    leas      8,S                 * 2DFA 32 68          2h
                    ldd       <U0017              * 2DFC DC 17          \.
                    pshs      D                   * 2DFE 34 06          4.
                    ldd       <U0023              * 2E00 DC 23          \#
                    pshs      D                   * 2E02 34 06          4.
                    lbsr      L40C2               * 2E04 17 12 BB       ..;
                    leas      4,S                 * 2E07 32 64          2d
                    leax      >Y03D4,Y            * 2E09 30 A9 03 D4    0).T
                    pshs      X                   * 2E0D 34 10          4.
                    leax      >Y07E9,Y            * 2E0F 30 A9 07 E9    0).i
                    ldd       2,X                 * 2E13 EC 02          l.
                    pshs      D                   * 2E15 34 06          4.
                    ldd       ,X                  * 2E17 EC 84          l.
                    pshs      D                   * 2E19 34 06          4.
                    ldd       6,S                 * 2E1B EC 66          lf
                    lbsr      L462B               * 2E1D 17 18 0B       ...
                    lbsr      L45A8               * 2E20 17 17 85       ...
                    ldd       2,X                 * 2E23 EC 02          l.
                    pshs      D                   * 2E25 34 06          4.
                    ldd       ,X                  * 2E27 EC 84          l.
                    pshs      D                   * 2E29 34 06          4.
                    bsr       L2E31               * 2E2B 8D 04          ..
                    neg       <U0000              * 2E2D 00 00          ..
                    neg       <U0001              * 2E2F 00 01          ..
L2E31               puls      X                   * 2E31 35 10          5.
                    lbsr      L45A8               * 2E33 17 17 72       ..r
                    lbsr      L4636               * 2E36 17 17 FD       ..}
L2E39               puls      PC,U,X              * 2E39 35 D0          5P
L2E3B               pshs      U                   * 2E3B 34 40          4@
                    ldd       <U004B              * 2E3D DC 4B          \K
                    lbeq      L2EF0               * 2E3F 10 27 00 AD    .'.-
                    ldd       6,S                 * 2E43 EC 66          lf
                    lbeq      L2EF0               * 2E45 10 27 00 A7    .'.'
                    ldd       [>U004B,Y]          * 2E49 EC B9 00 4B    l9.K
                    addd      6,S                 * 2E4D E3 66          cf
                    std       [>U004B,Y]          * 2E4F ED B9 00 4B    m9.K
                    ldb       <U005B              * 2E53 D6 5B          V[
                    lbeq      L2EF0               * 2E55 10 27 00 97    .'..
                    ldb       <U005E              * 2E59 D6 5E          V^
                    clra                          * 2E5B 4F             O
                    andb      #2                  * 2E5C C4 02          D.
                    lbeq      L2EF0               * 2E5E 10 27 00 8E    .'..
                    ldd       <U0017              * 2E62 DC 17          \.
                    lbeq      L2EF0               * 2E64 10 27 00 88    .'..
                    ldb       <U00C6              * 2E68 D6 C6          VF
                    lble      L2EF0               * 2E6A 10 2F 00 82    ./..
                    ldb       <U005D              * 2E6E D6 5D          V]
                    clra                          * 2E70 4F             O
                    andb      #4                  * 2E71 C4 04          D.
                    beq       L2E7B               * 2E73 27 06          '.
                    leax      >Y07ED,Y            * 2E75 30 A9 07 ED    0).m
                    bra       L2E8C               * 2E79 20 11           .
L2E7B               ldb       <U005D              * 2E7B D6 5D          V]
                    clra                          * 2E7D 4F             O
                    andb      #2                  * 2E7E C4 02          D.
                    beq       L2E88               * 2E80 27 06          '.
                    leax      >Y07F1,Y            * 2E82 30 A9 07 F1    0).q
                    bra       L2E8C               * 2E86 20 04           .
L2E88               leax      >Y07F5,Y            * 2E88 30 A9 07 F5    0).u
L2E8C               tfr       X,D                 * 2E8C 1F 10          ..
                    tfr       D,U                 * 2E8E 1F 03          ..
                    leax      >Y03D4,Y            * 2E90 30 A9 03 D4    0).T
                    ldd       2,X                 * 2E94 EC 02          l.
                    pshs      D                   * 2E96 34 06          4.
                    ldd       ,X                  * 2E98 EC 84          l.
                    pshs      D                   * 2E9A 34 06          4.
                    leax      ,U                  * 2E9C 30 C4          0D
                    lbsr      L45D2               * 2E9E 17 17 31       ..1
                    beq       L2EBA               * 2EA1 27 17          '.
                    clra                          * 2EA3 4F             O
                    clrb                          * 2EA4 5F             _
                    pshs      D                   * 2EA5 34 06          4.
                    leax      ,U                  * 2EA7 30 C4          0D
                    ldd       2,X                 * 2EA9 EC 02          l.
                    pshs      D                   * 2EAB 34 06          4.
                    ldd       ,X                  * 2EAD EC 84          l.
                    pshs      D                   * 2EAF 34 06          4.
                    ldd       <U0017              * 2EB1 DC 17          \.
                    pshs      D                   * 2EB3 34 06          4.
                    lbsr      L3F02               * 2EB5 17 10 4A       ..J
                    leas      8,S                 * 2EB8 32 68          2h
L2EBA               ldd       <U0017              * 2EBA DC 17          \.
                    pshs      D                   * 2EBC 34 06          4.
                    ldd       #1                  * 2EBE CC 00 01       L..
                    pshs      D                   * 2EC1 34 06          4.
                    ldd       10,S                * 2EC3 EC 6A          lj
                    pshs      D                   * 2EC5 34 06          4.
                    ldd       10,S                * 2EC7 EC 6A          lj
                    pshs      D                   * 2EC9 34 06          4.
                    lbsr      L39B2               * 2ECB 17 0A E4       ..d
                    leas      8,S                 * 2ECE 32 68          2h
                    leax      >Y03D4,Y            * 2ED0 30 A9 03 D4    0).T
                    pshs      X                   * 2ED4 34 10          4.
                    leax      ,U                  * 2ED6 30 C4          0D
                    pshs      X                   * 2ED8 34 10          4.
                    ldd       2,X                 * 2EDA EC 02          l.
                    pshs      D                   * 2EDC 34 06          4.
                    ldd       ,X                  * 2EDE EC 84          l.
                    pshs      D                   * 2EE0 34 06          4.
                    ldd       14,S                * 2EE2 EC 6E          ln
                    lbsr      L461D               * 2EE4 17 17 36       ..6
                    lbsr      L45A8               * 2EE7 17 16 BE       ..>
                    lbsr      L4636               * 2EEA 17 17 49       ..I
                    lbsr      L4636               * 2EED 17 17 46       ..F
L2EF0               puls      PC,U                * 2EF0 35 C0          5@
L2EF2               pshs      U,D                 * 2EF2 34 46          4F
                    clra                          * 2EF4 4F             O
                    clrb                          * 2EF5 5F             _
                    bra       L2F29               * 2EF6 20 31           1
L2EF8               ldd       ,S                  * 2EF8 EC E4          ld
                    aslb                          * 2EFA 58             X
                    rola                          * 2EFB 49             I
                    leax      >Y06C5,Y            * 2EFC 30 A9 06 C5    0).E
                    leax      D,X                 * 2F00 30 8B          0.
                    ldu       ,X                  * 2F02 EE 84          n.
                    stu       -2,S                * 2F04 EF 7E          o~
                    beq       L2F24               * 2F06 27 1C          '.
                    bra       L2F0C               * 2F08 20 02           .
L2F0A               ldu       4,U                 * 2F0A EE 44          nD
L2F0C               ldd       4,U                 * 2F0C EC 44          lD
                    bne       L2F0A               * 2F0E 26 FA          &z
L2F10               pshs      U                   * 2F10 34 40          4@
                    jsr       [<$08,S]            * 2F12 AD F8 08       -x.
                    leas      2,S                 * 2F15 32 62          2b
                    pshs      U                   * 2F17 34 40          4@
                    lbsr      L2237               * 2F19 17 F3 1B       .s.
                    leas      2,S                 * 2F1C 32 62          2b
                    tfr       D,U                 * 2F1E 1F 03          ..
                    stu       -2,S                * 2F20 EF 7E          o~
                    bne       L2F10               * 2F22 26 EC          &l
L2F24               ldd       ,S                  * 2F24 EC E4          ld
                    addd      #1                  * 2F26 C3 00 01       C..
L2F29               std       ,S                  * 2F29 ED E4          md
                    ldd       ,S                  * 2F2B EC E4          ld
                    cmpd      #64                 * 2F2D 10 83 00 40    ...@
                    blt       L2EF8               * 2F31 2D C5          -E
                    puls      PC,U,X              * 2F33 35 D0          5P
L2F35               pshs      U                   * 2F35 34 40          4@
                    ldd       <U0017              * 2F37 DC 17          \.
                    lbeq      L2FC2               * 2F39 10 27 00 85    .'..
                    clra                          * 2F3D 4F             O
                    clrb                          * 2F3E 5F             _
                    pshs      D                   * 2F3F 34 06          4.
                    leax      >Y07F5,Y            * 2F41 30 A9 07 F5    0).u
                    ldd       2,X                 * 2F45 EC 02          l.
                    pshs      D                   * 2F47 34 06          4.
                    ldd       ,X                  * 2F49 EC 84          l.
                    pshs      D                   * 2F4B 34 06          4.
                    ldd       <U0017              * 2F4D DC 17          \.
                    pshs      D                   * 2F4F 34 06          4.
                    lbsr      L3F02               * 2F51 17 0F AE       ...
                    leas      8,S                 * 2F54 32 68          2h
                    ldd       <U0017              * 2F56 DC 17          \.
                    pshs      D                   * 2F58 34 06          4.
                    ldd       #1                  * 2F5A CC 00 01       L..
                    pshs      D                   * 2F5D 34 06          4.
                    ldd       #2                  * 2F5F CC 00 02       L..
                    pshs      D                   * 2F62 34 06          4.
                    leax      >Y0057,Y            * 2F64 30 A9 00 57    0).W
                    pshs      X                   * 2F68 34 10          4.
                    lbsr      L39B2               * 2F6A 17 0A 45       ..E
                    leas      8,S                 * 2F6D 32 68          2h
                    ldd       <Y0057              * 2F6F DC 57          \W
                    beq       L2F7E               * 2F71 27 0B          '.
                    leax      >L3017,PC           * 2F73 30 8D 00 A0    0..
                    pshs      X                   * 2F77 34 10          4.
                    lbsr      L2EF2               * 2F79 17 FF 76       ..v
                    leas      2,S                 * 2F7C 32 62          2b
L2F7E               ldd       <U0017              * 2F7E DC 17          \.
                    pshs      D                   * 2F80 34 06          4.
                    ldd       #1                  * 2F82 CC 00 01       L..
                    pshs      D                   * 2F85 34 06          4.
                    ldd       #2                  * 2F87 CC 00 02       L..
                    pshs      D                   * 2F8A 34 06          4.
                    leax      >Y0059,Y            * 2F8C 30 A9 00 59    0).Y
                    pshs      X                   * 2F90 34 10          4.
                    lbsr      L39B2               * 2F92 17 0A 1D       ...
                    leas      8,S                 * 2F95 32 68          2h
                    ldd       <Y0059              * 2F97 DC 59          \Y
                    beq       L2FC2               * 2F99 27 27          ''
                    ldd       <U0084              * 2F9B DC 84          \.
                    beq       L2FA8               * 2F9D 27 09          '.
                    ldd       <U0084              * 2F9F DC 84          \.
                    pshs      D                   * 2FA1 34 06          4.
                    lbsr      L30BA               * 2FA3 17 01 14       ...
                    leas      2,S                 * 2FA6 32 62          2b
L2FA8               ldd       <U0098              * 2FA8 DC 98          \.
                    beq       L2FB5               * 2FAA 27 09          '.
                    ldd       <U0098              * 2FAC DC 98          \.
                    pshs      D                   * 2FAE 34 06          4.
                    lbsr      L30BA               * 2FB0 17 01 07       ...
                    leas      2,S                 * 2FB3 32 62          2b
L2FB5               ldd       <U00AC              * 2FB5 DC AC          \,
                    beq       L2FC2               * 2FB7 27 09          '.
                    ldd       <U00AC              * 2FB9 DC AC          \,
                    pshs      D                   * 2FBB 34 06          4.
                    lbsr      L30BA               * 2FBD 17 00 FA       ..z
L2FC0               leas      2,S                 * 2FC0 32 62          2b
L2FC2               puls      PC,U                * 2FC2 35 C0          5@
L2FC4               pshs      U                   * 2FC4 34 40          4@
                    ldu       4,S                 * 2FC6 EE 64          nd
                    leas      -3,S                * 2FC8 32 7D          2}
                    ldb       1,U                 * 2FCA E6 41          fA
                    clra                          * 2FCC 4F             O
                    andb      #198                * 2FCD C4 C6          DF
                    cmpd      #134                * 2FCF 10 83 00 86    ....
                    bne       L3013               * 2FD3 26 3E          &>
                    ldd       <U0017              * 2FD5 DC 17          \.
                    pshs      D                   * 2FD7 34 06          4.
                    pshs      U                   * 2FD9 34 40          4@
                    ldd       #10                 * 2FDB CC 00 0A       L..
                    addd      ,S++                * 2FDE E3 E1          ca
                    pshs      D                   * 2FE0 34 06          4.
                    lbsr      L3992               * 2FE2 17 09 AD       ..-
                    leas      4,S                 * 2FE5 32 64          2d
                    ldd       <U0017              * 2FE7 DC 17          \.
                    pshs      D                   * 2FE9 34 06          4.
                    clra                          * 2FEB 4F             O
                    clrb                          * 2FEC 5F             _
                    pshs      D                   * 2FED 34 06          4.
                    lbsr      L40C2               * 2FEF 17 10 D0       ..P
                    leas      4,S                 * 2FF2 32 64          2d
                    ldb       ,U                  * 2FF4 E6 C4          fD
                    stb       ,S                  * 2FF6 E7 E4          gd
                    ldd       2,U                 * 2FF8 EC 42          lB
                    std       1,S                 * 2FFA ED 61          ma
                    ldd       <U0017              * 2FFC DC 17          \.
                    pshs      D                   * 2FFE 34 06          4.
                    ldd       #1                  * 3000 CC 00 01       L..
                    pshs      D                   * 3003 34 06          4.
                    ldd       #3                  * 3005 CC 00 03       L..
                    pshs      D                   * 3008 34 06          4.
                    leax      6,S                 * 300A 30 66          0f
                    pshs      X                   * 300C 34 10          4.
                    lbsr      L39B2               * 300E 17 09 A1       ..!
                    leas      8,S                 * 3011 32 68          2h
L3013               leas      3,S                 * 3013 32 63          2c
                    puls      PC,U                * 3015 35 C0          5@
L3017               pshs      U                   * 3017 34 40          4@
                    ldu       4,S                 * 3019 EE 64          nd
                    leas      -2,S                * 301B 32 7E          2~
                    ldb       1,U                 * 301D E6 41          fA
                    clra                          * 301F 4F             O
                    andb      #66                 * 3020 C4 42          DB
                    lbne      L3089               * 3022 10 26 00 63    .&.c
                    ldd       8,U                 * 3026 EC 48          lH
                    lbeq      L3089               * 3028 10 27 00 5D    .'.]
                    ldb       ,U                  * 302C E6 C4          fD
                    clra                          * 302E 4F             O
                    andb      #7                  * 302F C4 07          D.
                    std       ,S                  * 3031 ED E4          md
                    cmpd      #6                  * 3033 10 83 00 06    ....
                    lbeq      L3089               * 3037 10 27 00 4E    .'.N
                    ldd       ,S                  * 303B EC E4          ld
                    cmpd      #5                  * 303D 10 83 00 05    ....
                    beq       L3089               * 3041 27 46          'F
                    ldd       <U0017              * 3043 DC 17          \.
                    pshs      D                   * 3045 34 06          4.
                    pshs      U                   * 3047 34 40          4@
                    ldd       #10                 * 3049 CC 00 0A       L..
                    addd      ,S++                * 304C E3 E1          ca
                    pshs      D                   * 304E 34 06          4.
                    lbsr      L3992               * 3050 17 09 3F       ..?
                    leas      4,S                 * 3053 32 64          2d
                    ldd       <U0017              * 3055 DC 17          \.
                    pshs      D                   * 3057 34 06          4.
                    clra                          * 3059 4F             O
                    clrb                          * 305A 5F             _
                    pshs      D                   * 305B 34 06          4.
                    lbsr      L40C2               * 305D 17 10 62       ..b
                    leas      4,S                 * 3060 32 64          2d
                    pshs      U                   * 3062 34 40          4@
                    bsr       L308B               * 3064 8D 25          .%
                    leas      2,S                 * 3066 32 62          2b
                    std       ,S                  * 3068 ED E4          md
                    ldd       <U0017              * 306A DC 17          \.
                    pshs      D                   * 306C 34 06          4.
                    ldd       #1                  * 306E CC 00 01       L..
                    pshs      D                   * 3071 34 06          4.
                    ldd       #2                  * 3073 CC 00 02       L..
                    pshs      D                   * 3076 34 06          4.
                    leax      6,S                 * 3078 30 66          0f
                    pshs      X                   * 307A 34 10          4.
                    lbsr      L39B2               * 307C 17 09 33       ..3
                    leas      8,S                 * 307F 32 68          2h
                    ldd       8,U                 * 3081 EC 48          lH
                    pshs      D                   * 3083 34 06          4.
                    bsr       L30BA               * 3085 8D 33          .3
                    leas      2,S                 * 3087 32 62          2b
L3089               puls      PC,U,X              * 3089 35 D0          5P
L308B               pshs      U,X,D               * 308B 34 56          4V
                    clra                          * 308D 4F             O
                    clrb                          * 308E 5F             _
                    std       ,S                  * 308F ED E4          md
                    ldx       8,S                 * 3091 AE 68          .h
                    ldu       8,X                 * 3093 EE 08          n.
                    clra                          * 3095 4F             O
                    clrb                          * 3096 5F             _
                    ldx       8,S                 * 3097 AE 68          .h
                    std       8,X                 * 3099 ED 08          m.
L309B               ldd       3,U                 * 309B EC 43          lC
                    std       2,S                 * 309D ED 62          mb
                    ldx       8,S                 * 309F AE 68          .h
                    ldd       8,X                 * 30A1 EC 08          l.
                    std       3,U                 * 30A3 ED 43          mC
                    ldx       8,S                 * 30A5 AE 68          .h
                    stu       8,X                 * 30A7 EF 08          o.
                    ldd       ,S                  * 30A9 EC E4          ld
                    addd      #1                  * 30AB C3 00 01       C..
                    std       ,S                  * 30AE ED E4          md
                    ldu       2,S                 * 30B0 EE 62          nb
                    bne       L309B               * 30B2 26 E7          &g
                    ldd       ,S                  * 30B4 EC E4          ld
                    leas      4,S                 * 30B6 32 64          2d
                    puls      PC,U                * 30B8 35 C0          5@
L30BA               pshs      U                   * 30BA 34 40          4@
                    ldu       4,S                 * 30BC EE 64          nd
L30BE               ldd       <U0017              * 30BE DC 17          \.
                    pshs      D                   * 30C0 34 06          4.
                    ldd       #1                  * 30C2 CC 00 01       L..
                    pshs      D                   * 30C5 34 06          4.
                    ldd       #3                  * 30C7 CC 00 03       L..
                    pshs      D                   * 30CA 34 06          4.
                    pshs      U                   * 30CC 34 40          4@
                    lbsr      L39B2               * 30CE 17 08 E1       ..a
                    leas      8,S                 * 30D1 32 68          2h
                    ldu       3,U                 * 30D3 EE 43          nC
                    stu       -2,S                * 30D5 EF 7E          o~
                    bne       L30BE               * 30D7 26 E5          &e
                    puls      PC,U                * 30D9 35 C0          5@
L30DB               fcc       "too many object files" * 30DB 74 6F 6F 20 6D 61 6E 79 20 6F 62 6A 65 63 74 20 66 69 6C 65 73 too many object files
                    fcb       $00                 * 30F0 00             .
L30F1               fcc       "too many input files" * 30F1 74 6F 6F 20 6D 61 6E 79 20 69 6E 70 75 74 20 66 69 6C 65 73 too many input files
                    fcb       $00                 * 3105 00             .
L3106               fcc       "no input file"     * 3106 6E 6F 20 69 6E 70 75 74 20 66 69 6C 65 no input file
                    fcb       $00                 * 3113 00             .
L3114               fcc       "output.r"          * 3114 6F 75 74 70 75 74 2E 72 output.r
                    fcb       $00                 * 311C 00             .
L311D               fcc       /"%s" - /           * 311D 22 25 73 22 20 2D 20 "%s" -
                    fcb       $00                 * 3124 00             .
L3125               fcc       "can't open file"   * 3125 63 61 6E 27 74 20 6F 70 65 6E 20 66 69 6C 65 can't open file
                    fcb       $00                 * 3134 00             .
L3135               fcc       "Microware OS-9 %s  %d/%02d/%02d  %02d:%02d" * 3135 4D 69 63 72 6F 77 61 72 65 20 4F 53 2D 39 20 25 73 20 20 25 64 2F 25 30 32 64 2F 25 30 32 64 20 20 25 30 32 64 3A 25 30 32 64 Microware OS-9 %s  %d/%02d/%02d  %02d:%02d
                    fcb       $00                 * 315F 00             .
L3160               fcc       "RMA - V1.0"        * 3160 52 4D 41 20 2D 20 56 31 2E 30 RMA - V1.0
                    fcb       $00                 * 316A 00             .
L316B               fcc       "   %-20s Page %5d" * 316B 20 20 20 25 2D 32 30 73 20 50 61 67 65 20 25 35 64    %-20s Page %5d
                    fcb       $0D                 * 317C 0D             .
                    fcb       $00                 * 317D 00             .
L317E               fcc       "%s - %s"           * 317E 25 73 20 2D 20 25 73 %s - %s
                    fcb       $0D                 * 3185 0D             .
                    fcb       $0D                 * 3186 0D             .
                    fcb       $00                 * 3187 00             .
L3188               fcc       "Asm:"              * 3188 41 73 6D 3A    Asm:
                    fcb       $00                 * 318C 00             .
L318D               fcc       "file close error"  * 318D 66 69 6C 65 20 63 6C 6F 73 65 20 65 72 72 6F 72 file close error
                    fcb       $00                 * 319D 00             .
L319E               fcb       $0D                 * 319E 0D             .
                    fcc       "Symbol Table"      * 319F 53 79 6D 62 6F 6C 20 54 61 62 6C 65 Symbol Table
                    fcb       $0D                 * 31AB 0D             .
                    fcb       $00                 * 31AC 00             .
L31AD               fcb       $0D                 * 31AD 0D             .
                    fcb       $00                 * 31AE 00             .
L31AF               fcb       $0D                 * 31AF 0D             .
                    fcb       $00                 * 31B0 00             .
L31B1               fcc       "  |"               * 31B1 20 20 7C         |
                    fcb       $00                 * 31B4 00             .
L31B5               fcc       "  %-9s %02x %02x %04x" * 31B5 20 20 25 2D 39 73 20 25 30 32 78 20 25 30 32 78 20 25 30 34 78   %-9s %02x %02x %04x
                    fcb       $00                 * 31CA 00             .
L31CB               fcb       $0D                 * 31CB 0D             .
                    fcb       $00                 * 31CC 00             .
L31CD               fcc       "program"           * 31CD 70 72 6F 67 72 61 6D program
                    fcb       $00                 * 31D4 00             .
L31D5               fcc       "no external allowed" * 31D5 6E 6F 20 65 78 74 65 72 6E 61 6C 20 61 6C 6C 6F 77 65 64 no external allowed
                    fcb       $00                 * 31E8 00             .
L31E9               pshs      U,D                 * 31E9 34 46          4F
                    ldb       <U005B              * 31EB D6 5B          V[
                    beq       L31F4               * 31ED 27 05          '.
                    ldd       #1                  * 31EF CC 00 01       L..
                    puls      PC,U,X              * 31F2 35 D0          5P
L31F4               ldd       <U00DA              * 31F4 DC DA          \Z
                    bne       L3221               * 31F6 26 29          &)
                    leax      >L3721,PC           * 31F8 30 8D 05 25    0..%
                    pshs      X                   * 31FC 34 10          4.
                    leax      >dpsiz,Y            * 31FE 30 A9 00 E8    0).h
                    pshs      X                   * 3202 34 10          4.
                    lbsr      fopen               * 3204 17 07 17       ...
                    leas      4,S                 * 3207 32 64          2d
                    std       <U00DA              * 3209 DD DA          ]Z
                    std       <U00DC              * 320B DD DC          ]\
                    bne       L321A               * 320D 26 0B          &.
                    leax      >L3724,PC           * 320F 30 8D 05 11    0...
                    pshs      X                   * 3213 34 10          4.
                    lbsr      L078B               * 3215 17 D5 73       .Us
                    leas      2,S                 * 3218 32 62          2b
L321A               ldd       #512                * 321A CC 02 00       L..
                    ldx       <U00DA              * 321D 9E DA          .Z
                    std       11,X                * 321F ED 0B          m.
L3221               ldd       #10                 * 3221 CC 00 0A       L..
                    pshs      D                   * 3224 34 06          4.
                    lbsr      L233C               * 3226 17 F1 13       .q.
                    leas      2,S                 * 3229 32 62          2b
                    tfr       D,U                 * 322B 1F 03          ..
                    ldd       <U00D4              * 322D DC D4          \T
                    std       ,U                  * 322F ED C4          mD
                    stu       <U00D4              * 3231 DF D4          _T
                    ldd       <U0078              * 3233 DC 78          \x
                    std       2,U                 * 3235 ED 42          mB
                    ldd       <U00DA              * 3237 DC DA          \Z
                    std       4,U                 * 3239 ED 44          mD
                    ldd       #2                  * 323B CC 00 02       L..
                    pshs      D                   * 323E 34 06          4.
                    clra                          * 3240 4F             O
                    clrb                          * 3241 5F             _
                    pshs      D                   * 3242 34 06          4.
                    pshs      D                   * 3244 34 06          4.
                    ldd       <U00DA              * 3246 DC DA          \Z
                    pshs      D                   * 3248 34 06          4.
                    lbsr      L3F02               * 324A 17 0C B5       ..5
                    leas      8,S                 * 324D 32 68          2h
                    ldd       <U0078              * 324F DC 78          \x
                    addd      #10                 * 3251 C3 00 0A       C..
                    std       ,S                  * 3254 ED E4          md
                    bra       L326C               * 3256 20 14           .
L3258               ldd       <U00DA              * 3258 DC DA          \Z
                    pshs      D                   * 325A 34 06          4.
                    ldx       2,S                 * 325C AE 62          .b
                    leax      1,X                 * 325E 30 01          0.
                    stx       2,S                 * 3260 AF 62          /b
                    ldb       -1,X                * 3262 E6 1F          f.
                    sex                           * 3264 1D             .
                    pshs      D                   * 3265 34 06          4.
                    lbsr      L40C2               * 3267 17 0E 58       ..X
                    leas      4,S                 * 326A 32 64          2d
L326C               ldb       [,S]                * 326C E6 F4          ft
                    bne       L3258               * 326E 26 E8          &h
                    ldd       <U00DA              * 3270 DC DA          \Z
                    pshs      D                   * 3272 34 06          4.
                    clra                          * 3274 4F             O
                    clrb                          * 3275 5F             _
                    pshs      D                   * 3276 34 06          4.
                    lbsr      L40C2               * 3278 17 0E 47       ..G
                    leas      4,S                 * 327B 32 64          2d
                    ldx       <U00DA              * 327D 9E DA          .Z
                    ldd       6,X                 * 327F EC 06          l.
                    clra                          * 3281 4F             O
                    andb      #32                 * 3282 C4 20          D
                    beq       L3289               * 3284 27 03          '.
                    lbsr      L3714               * 3286 17 04 8B       ...
L3289               leax      6,U                 * 3289 30 46          0F
                    pshs      X                   * 328B 34 10          4.
                    ldd       <U00DA              * 328D DC DA          \Z
                    pshs      D                   * 328F 34 06          4.
                    lbsr      L4059               * 3291 17 0D C5       ..E
                    leas      2,S                 * 3294 32 62          2b
                    lbsr      L4636               * 3296 17 13 9D       ...
                    ldd       #1                  * 3299 CC 00 01       L..
                    puls      PC,U,X              * 329C 35 D0          5P
L329E               pshs      U                   * 329E 34 40          4@
                    ldb       <U005B              * 32A0 D6 5B          V[
                    lbne      L3313               * 32A2 10 26 00 6D    .&.m
                    ldd       #32                 * 32A6 CC 00 20       L.
                    pshs      D                   * 32A9 34 06          4.
                    ldd       <U0064              * 32AB DC 64          \d
                    pshs      D                   * 32AD 34 06          4.
                    bsr       L32CD               * 32AF 8D 1C          ..
                    leas      4,S                 * 32B1 32 64          2d
                    ldd       #32                 * 32B3 CC 00 20       L.
                    pshs      D                   * 32B6 34 06          4.
                    ldd       <U0066              * 32B8 DC 66          \f
                    pshs      D                   * 32BA 34 06          4.
                    bsr       L32CD               * 32BC 8D 0F          ..
                    leas      4,S                 * 32BE 32 64          2d
                    ldd       #13                 * 32C0 CC 00 0D       L..
                    pshs      D                   * 32C3 34 06          4.
                    ldd       <U0062              * 32C5 DC 62          \b
                    pshs      D                   * 32C7 34 06          4.
                    bsr       L32CD               * 32C9 8D 02          ..
                    bra       L3311               * 32CB 20 44           D
L32CD               pshs      U                   * 32CD 34 40          4@
                    ldu       4,S                 * 32CF EE 64          nd
                    bra       L32E1               * 32D1 20 0E           .
L32D3               ldd       <U00DA              * 32D3 DC DA          \Z
                    pshs      D                   * 32D5 34 06          4.
                    ldb       ,U+                 * 32D7 E6 C0          f@
                    sex                           * 32D9 1D             .
                    pshs      D                   * 32DA 34 06          4.
                    lbsr      L40C2               * 32DC 17 0D E3       ..c
                    leas      4,S                 * 32DF 32 64          2d
L32E1               ldb       ,U                  * 32E1 E6 C4          fD
                    bne       L32D3               * 32E3 26 EE          &n
                    ldd       <U00DA              * 32E5 DC DA          \Z
                    pshs      D                   * 32E7 34 06          4.
                    ldd       8,S                 * 32E9 EC 68          lh
                    pshs      D                   * 32EB 34 06          4.
                    lbsr      L40C2               * 32ED 17 0D D2       ..R
                    leas      4,S                 * 32F0 32 64          2d
                    ldx       <U00DA              * 32F2 9E DA          .Z
                    ldd       6,X                 * 32F4 EC 06          l.
                    clra                          * 32F6 4F             O
                    andb      #32                 * 32F7 C4 20          D
                    beq       L32FE               * 32F9 27 03          '.
                    lbsr      L3714               * 32FB 17 04 16       ...
L32FE               puls      PC,U                * 32FE 35 C0          5@
L3300               pshs      U                   * 3300 34 40          4@
                    ldb       <U005B              * 3302 D6 5B          V[
                    bne       L3313               * 3304 26 0D          &.
                    ldd       <U00DA              * 3306 DC DA          \Z
                    pshs      D                   * 3308 34 06          4.
                    clra                          * 330A 4F             O
                    clrb                          * 330B 5F             _
                    pshs      D                   * 330C 34 06          4.
                    lbsr      L40C2               * 330E 17 0D B1       ..1
L3311               leas      4,S                 * 3311 32 64          2d
L3313               ldd       #1                  * 3313 CC 00 01       L..
                    puls      PC,U                * 3316 35 C0          5@
L3318               pshs      U                   * 3318 34 40          4@
                    ldu       <U00D4              * 331A DE D4          ^T
                    bra       L3348               * 331C 20 2A           *
L331E               ldb       [<$04,S]            * 331E E6 F8 04       fx.
                    sex                           * 3321 1D             .
                    pshs      D                   * 3322 34 06          4.
                    ldx       2,U                 * 3324 AE 42          .B
                    ldb       10,X                * 3326 E6 0A          f.
                    sex                           * 3328 1D             .
                    cmpd      ,S++                * 3329 10 A3 E1       .#a
                    bne       L3346               * 332C 26 18          &.
                    ldd       2,U                 * 332E EC 42          lB
                    addd      #10                 * 3330 C3 00 0A       C..
                    pshs      D                   * 3333 34 06          4.
                    ldd       6,S                 * 3335 EC 66          lf
                    pshs      D                   * 3337 34 06          4.
                    lbsr      L4559               * 3339 17 12 1D       ...
                    leas      4,S                 * 333C 32 64          2d
                    std       -2,S                * 333E ED 7E          m~
                    bne       L3346               * 3340 26 04          &.
                    tfr       U,D                 * 3342 1F 30          .0
                    puls      PC,U                * 3344 35 C0          5@
L3346               ldu       ,U                  * 3346 EE C4          nD
L3348               stu       -2,S                * 3348 EF 7E          o~
                    bne       L331E               * 334A 26 D2          &R
                    clra                          * 334C 4F             O
                    clrb                          * 334D 5F             _
                    puls      PC,U                * 334E 35 C0          5@
L3350               pshs      U                   * 3350 34 40          4@
                    ldd       <U00E2              * 3352 DC E2          \b
                    addd      #1                  * 3354 C3 00 01       C..
                    std       <U00E2              * 3357 DD E2          ]b
                    subd      #1                  * 3359 83 00 01       ...
                    pshs      D                   * 335C 34 06          4.
                    ldd       #10                 * 335E CC 00 0A       L..
                    lbsr      L466A               * 3361 17 13 06       ...
                    leax      >Y0957,Y            * 3364 30 A9 09 57    0).W
                    leax      D,X                 * 3368 30 8B          0.
                    leau      ,X                  * 336A 33 84          3.
                    ldd       <U00E2              * 336C DC E2          \b
                    cmpd      #8                  * 336E 10 83 00 08    ....
                    ble       L337F               * 3372 2F 0B          /.
                    leax      >L373F,PC           * 3374 30 8D 03 C7    0..G
                    pshs      X                   * 3378 34 10          4.
                    lbsr      L078B               * 337A 17 D4 0E       .T.
                    leas      2,S                 * 337D 32 62          2b
L337F               ldd       <U00DC              * 337F DC DC          \\
                    std       ,U                  * 3381 ED C4          mD
                    leax      2,U                 * 3383 30 42          0B
                    pshs      X                   * 3385 34 10          4.
                    ldd       <U00DC              * 3387 DC DC          \\
                    pshs      D                   * 3389 34 06          4.
                    lbsr      L4059               * 338B 17 0C CB       ..K
                    leas      2,S                 * 338E 32 62          2b
                    lbsr      L4636               * 3390 17 12 A3       ..#
                    ldd       <U00DE              * 3393 DC DE          \^
                    std       6,U                 * 3395 ED 46          mF
                    ldd       <U00E0              * 3397 DC E0          \`
                    std       8,U                 * 3399 ED 48          mH
                    ldx       4,S                 * 339B AE 64          .d
                    ldd       4,X                 * 339D EC 04          l.
                    std       <U00DC              * 339F DD DC          ]\
                    clra                          * 33A1 4F             O
                    clrb                          * 33A2 5F             _
                    pshs      D                   * 33A3 34 06          4.
                    ldx       6,S                 * 33A5 AE 66          .f
                    leax      6,X                 * 33A7 30 06          0.
                    ldd       2,X                 * 33A9 EC 02          l.
                    pshs      D                   * 33AB 34 06          4.
                    ldd       ,X                  * 33AD EC 84          l.
                    pshs      D                   * 33AF 34 06          4.
                    ldd       <U00DC              * 33B1 DC DC          \\
                    pshs      D                   * 33B3 34 06          4.
                    lbsr      L3F02               * 33B5 17 0B 4A       ..J
                    leas      8,S                 * 33B8 32 68          2h
                    ldd       <U00CC              * 33BA DC CC          \L
                    bne       L33C5               * 33BC 26 07          &.
                    ldd       <U00D8              * 33BE DC D8          \X
                    addd      #1                  * 33C0 C3 00 01       C..
                    std       <U00D8              * 33C3 DD D8          ]X
L33C5               ldd       <U00D8              * 33C5 DC D8          \X
                    std       <U00DE              * 33C7 DD DE          ]^
                    lbsr      L3556               * 33C9 17 01 8A       ...
                    std       <U00E0              * 33CC DD E0          ]`
                    ldd       #1                  * 33CE CC 00 01       L..
                    std       <U00CE              * 33D1 DD CE          ]N
                    puls      PC,U                * 33D3 35 C0          5@
L33D5               pshs      U                   * 33D5 34 40          4@
                    ldd       <U00E2              * 33D7 DC E2          \b
                    addd      #-1                 * 33D9 C3 FF FF       C..
                    std       <U00E2              * 33DC DD E2          ]b
                    pshs      D                   * 33DE 34 06          4.
                    ldd       #10                 * 33E0 CC 00 0A       L..
                    lbsr      L466A               * 33E3 17 12 84       ...
                    leax      >Y0957,Y            * 33E6 30 A9 09 57    0).W
                    leax      D,X                 * 33EA 30 8B          0.
                    leau      ,X                  * 33EC 33 84          3.
                    ldd       <U00E2              * 33EE DC E2          \b
                    bge       L33FD               * 33F0 2C 0B          ,.
                    leax      >L3756,PC           * 33F2 30 8D 03 60    0..`
                    pshs      X                   * 33F6 34 10          4.
                    lbsr      L078B               * 33F8 17 D3 90       .S.
                    leas      2,S                 * 33FB 32 62          2b
L33FD               ldd       ,U                  * 33FD EC C4          lD
                    std       <U00DC              * 33FF DD DC          ]\
                    clra                          * 3401 4F             O
                    clrb                          * 3402 5F             _
                    pshs      D                   * 3403 34 06          4.
                    leax      2,U                 * 3405 30 42          0B
                    ldd       2,X                 * 3407 EC 02          l.
                    pshs      D                   * 3409 34 06          4.
                    ldd       ,X                  * 340B EC 84          l.
                    pshs      D                   * 340D 34 06          4.
                    ldd       <U00DC              * 340F DC DC          \\
                    pshs      D                   * 3411 34 06          4.
                    lbsr      L3F02               * 3413 17 0A EC       ..l
                    leas      8,S                 * 3416 32 68          2h
                    ldd       6,U                 * 3418 EC 46          lF
                    std       <U00DE              * 341A DD DE          ]^
                    ldd       <U00E0              * 341C DC E0          \`
                    pshs      D                   * 341E 34 06          4.
                    lbsr      L3697               * 3420 17 02 74       ..t
                    leas      2,S                 * 3423 32 62          2b
                    ldd       8,U                 * 3425 EC 48          lH
                    std       <U00E0              * 3427 DD E0          ]`
                    puls      PC,U                * 3429 35 C0          5@
L342B               pshs      U,D                 * 342B 34 46          4F
                    lbra      L3495               * 342D 16 00 65       ..e
L3430               leax      >Y0857,Y            * 3430 30 A9 08 57    0).W
                    stx       <U0062              * 3434 9F 62          .b
                    tfr       X,D                 * 3436 1F 10          ..
                    std       <U00E4              * 3438 DD E4          ]d
                    bra       L347B               * 343A 20 3F           ?
L343C               ldd       ,S                  * 343C EC E4          ld
                    cmpd      #13                 * 343E 10 83 00 0D    ....
                    bne       L345A               * 3442 26 16          &.
                    clra                          * 3444 4F             O
                    clrb                          * 3445 5F             _
                    stb       [>U00E4,Y]          * 3446 E7 B9 00 E4    g9.d
                    ldb       <U0002              * 344A D6 02          V.
                    beq       L3455               * 344C 27 07          '.
                    ldd       <U002F              * 344E DC 2F          \/
                    addd      #1                  * 3450 C3 00 01       C..
                    std       <U002F              * 3453 DD 2F          ]/
L3455               ldd       #1                  * 3455 CC 00 01       L..
                    puls      PC,U,X              * 3458 35 D0          5P
L345A               ldd       ,S                  * 345A EC E4          ld
                    cmpd      #92                 * 345C 10 83 00 5C    ...\
                    bne       L3471               * 3460 26 0F          &.
                    ldd       <U00DC              * 3462 DC DC          \\
                    pshs      D                   * 3464 34 06          4.
                    lbsr      L42D5               * 3466 17 0E 6C       ..l
                    std       ,S                  * 3469 ED E4          md
                    bsr       L349F               * 346B 8D 32          .2
                    leas      2,S                 * 346D 32 62          2b
                    bra       L347B               * 346F 20 0A           .
L3471               ldd       ,S                  * 3471 EC E4          ld
                    ldx       <U00E4              * 3473 9E E4          .d
                    leax      1,X                 * 3475 30 01          0.
                    stx       <U00E4              * 3477 9F E4          .d
                    stb       -1,X                * 3479 E7 1F          g.
L347B               ldd       <U00DC              * 347B DC DC          \\
                    pshs      D                   * 347D 34 06          4.
                    lbsr      L42D5               * 347F 17 0E 53       ..S
                    leas      2,S                 * 3482 32 62          2b
                    std       ,S                  * 3484 ED E4          md
                    bgt       L343C               * 3486 2E B4          .4
                    ldd       <U00E2              * 3488 DC E2          \b
                    bne       L3492               * 348A 26 06          &.
                    clra                          * 348C 4F             O
                    clrb                          * 348D 5F             _
                    std       <U00CE              * 348E DD CE          ]N
                    bra       L349B               * 3490 20 09           .
L3492               lbsr      L33D5               * 3492 17 FF 40       ..@
L3495               ldd       <U00CE              * 3495 DC CE          \N
                    lbne      L3430               * 3497 10 26 FF 95    .&..
L349B               clra                          * 349B 4F             O
                    clrb                          * 349C 5F             _
                    puls      PC,U,X              * 349D 35 D0          5P
L349F               pshs      U                   * 349F 34 40          4@
                    ldd       4,S                 * 34A1 EC 64          ld
                    leax      >Y03FC,Y            * 34A3 30 A9 03 FC    0).|
                    leax      D,X                 * 34A7 30 8B          0.
                    ldb       ,X                  * 34A9 E6 84          f.
                    clra                          * 34AB 4F             O
                    andb      #8                  * 34AC C4 08          D.
                    beq       L34C0               * 34AE 27 10          '.
                    ldd       #1                  * 34B0 CC 00 01       L..
                    pshs      D                   * 34B3 34 06          4.
                    ldd       6,S                 * 34B5 EC 66          lf
                    pshs      D                   * 34B7 34 06          4.
                    lbsr      L36A4               * 34B9 17 01 E8       ..h
                    leas      4,S                 * 34BC 32 64          2d
                    puls      PC,U                * 34BE 35 C0          5@
L34C0               ldx       4,S                 * 34C0 AE 64          .d
                    lbra      L3538               * 34C2 16 00 73       ..s
L34C5               ldd       4,S                 * 34C5 EC 64          ld
                    ldx       <U00E4              * 34C7 9E E4          .d
                    leax      1,X                 * 34C9 30 01          0.
                    stx       <U00E4              * 34CB 9F E4          .d
                    stb       -1,X                * 34CD E7 1F          g.
                    ldd       <U00DE              * 34CF DC DE          \^
                    pshs      D                   * 34D1 34 06          4.
                    ldd       #100                * 34D3 CC 00 64       L.d
                    lbsr      L46BD               * 34D6 17 11 E4       ..d
                    pshs      D                   * 34D9 34 06          4.
                    leax      >L376A,PC           * 34DB 30 8D 02 8B    0...
                    pshs      X                   * 34DF 34 10          4.
                    ldd       <U00E4              * 34E1 DC E4          \d
                    pshs      D                   * 34E3 34 06          4.
                    lbsr      L3A2A               * 34E5 17 05 42       ..B
                    leas      6,S                 * 34E8 32 66          2f
                    ldd       <U00E4              * 34EA DC E4          \d
                    addd      #3                  * 34EC C3 00 03       C..
                    bra       L3528               * 34EF 20 37           7
L34F1               ldd       4,S                 * 34F1 EC 64          ld
                    cmpd      #35                 * 34F3 10 83 00 23    ...#
                    bne       L3500               * 34F7 26 07          &.
                    ldb       [>U00E0,Y]          * 34F9 E6 B9 00 E0    f9.`
                    sex                           * 34FD 1D             .
                    bra       L3512               * 34FE 20 12           .
L3500               clra                          * 3500 4F             O
                    clrb                          * 3501 5F             _
                    pshs      D                   * 3502 34 06          4.
                    ldd       <U00DC              * 3504 DC DC          \\
                    pshs      D                   * 3506 34 06          4.
                    lbsr      L42D5               * 3508 17 0D CA       ..J
                    std       ,S                  * 350B ED E4          md
                    lbsr      L36A4               * 350D 17 01 94       ...
                    leas      4,S                 * 3510 32 64          2d
L3512               pshs      D                   * 3512 34 06          4.
                    leax      >L376F,PC           * 3514 30 8D 02 57    0..W
                    pshs      X                   * 3518 34 10          4.
                    ldd       <U00E4              * 351A DC E4          \d
                    pshs      D                   * 351C 34 06          4.
                    lbsr      L3A2A               * 351E 17 05 09       ...
                    leas      6,S                 * 3521 32 66          2f
                    ldd       <U00E4              * 3523 DC E4          \d
                    addd      #2                  * 3525 C3 00 02       C..
L3528               std       <U00E4              * 3528 DD E4          ]d
                    bra       L3554               * 352A 20 28           (
L352C               ldd       4,S                 * 352C EC 64          ld
                    ldx       <U00E4              * 352E 9E E4          .d
                    leax      1,X                 * 3530 30 01          0.
                    stx       <U00E4              * 3532 9F E4          .d
                    stb       -1,X                * 3534 E7 1F          g.
                    bra       L3554               * 3536 20 1C           .
L3538               cmpx      #64                 * 3538 8C 00 40       ..@
                    lbeq      L34C5               * 353B 10 27 FF 86    .'..
                    cmpx      #76                 * 353F 8C 00 4C       ..L
                    beq       L34F1               * 3542 27 AD          '-
                    cmpx      #108                * 3544 8C 00 6C       ..l
                    lbeq      L34F1               * 3547 10 27 FF A6    .'.&
                    cmpx      #35                 * 354B 8C 00 23       ..#
                    lbeq      L34F1               * 354E 10 27 FF 9F    .'..
                    bra       L352C               * 3552 20 D8           X
L3554               puls      PC,U                * 3554 35 C0          5@
L3556               pshs      U,Y,X,D             * 3556 34 76          4v
                    clra                          * 3558 4F             O
                    clrb                          * 3559 5F             _
                    std       2,S                 * 355A ED 62          mb
                    ldd       #59                 * 355C CC 00 3B       L.;
                    std       ,S                  * 355F ED E4          md
                    ldd       <U00E6              * 3561 DC E6          \f
                    beq       L356F               * 3563 27 0A          '.
                    ldu       <U00E6              * 3565 DE E6          ^f
                    ldd       [>U00E6,Y]          * 3567 EC B9 00 E6    l9.f
                    std       <U00E6              * 356B DD E6          ]f
                    bra       L357B               * 356D 20 0C           .
L356F               ldd       #61                 * 356F CC 00 3D       L.=
                    pshs      D                   * 3572 34 06          4.
                    lbsr      L233C               * 3574 17 ED C5       .mE
                    leas      2,S                 * 3577 32 62          2b
                    tfr       D,U                 * 3579 1F 03          ..
L357B               lbsr      L2229               * 357B 17 EC AB       .l+
                    ldd       <U0062              * 357E DC 62          \b
                    std       <U006A              * 3580 DD 6A          ]j
                    ldd       #1                  * 3582 CC 00 01       L..
                    std       <U00D6              * 3585 DD D6          ]V
                    tfr       U,D                 * 3587 1F 30          .0
                    leau      1,U                 * 3589 33 41          3A
                    std       4,S                 * 358B ED 64          md
                    ldb       [>U0062,Y]          * 358D E6 B9 00 62    f9.b
                    lbeq      L3666               * 3591 10 27 00 D1    .'.Q
                    leas      -2,S                * 3595 32 7E          2~
                    lbra      L3645               * 3597 16 00 AB       ..+
L359A               ldb       [>U0062,Y]          * 359A E6 B9 00 62    f9.b
                    sex                           * 359E 1D             .
                    tfr       D,X                 * 359F 1F 01          ..
                    lbra      L361B               * 35A1 16 00 77       ..w
L35A4               clra                          * 35A4 4F             O
                    clrb                          * 35A5 5F             _
                    stb       ,U+                 * 35A6 E7 C0          g@
                    ldd       4,S                 * 35A8 EC 64          ld
                    addd      #1                  * 35AA C3 00 01       C..
                    std       4,S                 * 35AD ED 64          md
                    ldd       <U0062              * 35AF DC 62          \b
                    addd      #1                  * 35B1 C3 00 01       C..
                    std       <U0062              * 35B4 DD 62          ]b
                    lbra      L363E               * 35B6 16 00 85       ...
L35B9               leax      8,S                 * 35B9 30 68          0h
                    lbra      L3664               * 35BB 16 00 A6       ..&
L35BE               ldx       <U0062              * 35BE 9E 62          .b
                    leax      1,X                 * 35C0 30 01          0.
                    stx       <U0062              * 35C2 9F 62          .b
                    ldb       -1,X                * 35C4 E6 1F          f.
                    stb       1,S                 * 35C6 E7 61          ga
                    bra       L35DE               * 35C8 20 14           .
L35CA               ldb       ,S                  * 35CA E6 E4          fd
                    cmpb      #92                 * 35CC C1 5C          A\
                    bne       L35DA               * 35CE 26 0A          &.
                    ldx       <U0062              * 35D0 9E 62          .b
                    leax      1,X                 * 35D2 30 01          0.
                    stx       <U0062              * 35D4 9F 62          .b
                    ldb       -1,X                * 35D6 E6 1F          f.
                    stb       ,S                  * 35D8 E7 E4          gd
L35DA               ldb       ,S                  * 35DA E6 E4          fd
                    stb       ,U+                 * 35DC E7 C0          g@
L35DE               ldx       <U0062              * 35DE 9E 62          .b
                    leax      1,X                 * 35E0 30 01          0.
                    stx       <U0062              * 35E2 9F 62          .b
                    ldb       -1,X                * 35E4 E6 1F          f.
                    stb       ,S                  * 35E6 E7 E4          gd
                    beq       L35F7               * 35E8 27 0D          '.
                    ldb       ,S                  * 35EA E6 E4          fd
                    sex                           * 35EC 1D             .
                    pshs      D                   * 35ED 34 06          4.
                    ldb       3,S                 * 35EF E6 63          fc
                    sex                           * 35F1 1D             .
                    cmpd      ,S++                * 35F2 10 A3 E1       .#a
                    bne       L35CA               * 35F5 26 D3          &S
L35F7               ldb       ,S                  * 35F7 E6 E4          fd
                    bne       L363E               * 35F9 26 43          &C
                    leax      >L3774,PC           * 35FB 30 8D 01 75    0..u
                    pshs      X                   * 35FF 34 10          4.
                    lbsr      L074E               * 3601 17 D1 4A       .QJ
                    leas      2,S                 * 3604 32 62          2b
                    bra       L363E               * 3606 20 36           6
L3608               ldd       <U0062              * 3608 DC 62          \b
                    addd      #1                  * 360A C3 00 01       C..
                    std       <U0062              * 360D DD 62          ]b
L360F               ldx       <U0062              * 360F 9E 62          .b
                    leax      1,X                 * 3611 30 01          0.
                    stx       <U0062              * 3613 9F 62          .b
                    ldb       -1,X                * 3615 E6 1F          f.
                    stb       ,U+                 * 3617 E7 C0          g@
                    bra       L363E               * 3619 20 23           #
L361B               cmpx      #44                 * 361B 8C 00 2C       ..,
                    lbeq      L35A4               * 361E 10 27 FF 82    .'..
                    cmpx      #32                 * 3622 8C 00 20       ..
                    lbeq      L35B9               * 3625 10 27 FF 90    .'..
                    cmpx      #39                 * 3629 8C 00 27       ..'
                    lbeq      L35BE               * 362C 10 27 FF 8E    .'..
                    cmpx      #34                 * 3630 8C 00 22       .."
                    lbeq      L35BE               * 3633 10 27 FF 87    .'..
                    cmpx      #92                 * 3637 8C 00 5C       ..\
                    beq       L3608               * 363A 27 CC          'L
                    bra       L360F               * 363C 20 D1           Q
L363E               ldd       2,S                 * 363E EC 62          lb
                    addd      #-1                 * 3640 C3 FF FF       C..
                    std       2,S                 * 3643 ED 62          mb
L3645               ldd       2,S                 * 3645 EC 62          lb
                    beq       L3659               * 3647 27 10          '.
                    ldb       [>U0062,Y]          * 3649 E6 B9 00 62    f9.b
                    stb       ,S                  * 364D E7 E4          gd
                    beq       L3659               * 364F 27 08          '.
                    ldb       ,S                  * 3651 E6 E4          fd
                    cmpb      #32                 * 3653 C1 20          A
                    lbne      L359A               * 3655 10 26 FF 41    .&.A
L3659               ldd       4,S                 * 3659 EC 64          ld
                    addd      #1                  * 365B C3 00 01       C..
                    std       4,S                 * 365E ED 64          md
                    leas      2,S                 * 3660 32 62          2b
                    bra       L3666               * 3662 20 02           .
L3664               leas      -6,X                * 3664 32 1A          2.
L3666               clra                          * 3666 4F             O
                    clrb                          * 3667 5F             _
                    stb       ,U                  * 3668 E7 C4          gD
                    ldd       ,S                  * 366A EC E4          ld
                    bne       L3679               * 366C 26 0B          &.
                    leax      >L3785,PC           * 366E 30 8D 01 13    0...
                    pshs      X                   * 3672 34 10          4.
                    lbsr      L074E               * 3674 17 D0 D7       .PW
                    leas      2,S                 * 3677 32 62          2b
L3679               ldd       2,S                 * 3679 EC 62          lb
                    cmpd      #9                  * 367B 10 83 00 09    ....
                    ble       L368C               * 367F 2F 0B          /.
                    leax      >L3798,PC           * 3681 30 8D 01 13    0...
                    pshs      X                   * 3685 34 10          4.
                    lbsr      L074E               * 3687 17 D0 C4       .PD
                    leas      2,S                 * 368A 32 62          2b
L368C               ldd       2,S                 * 368C EC 62          lb
                    stb       [<$04,S]            * 368E E7 F8 04       gx.
                    ldd       4,S                 * 3691 EC 64          ld
                    leas      6,S                 * 3693 32 66          2f
                    puls      PC,U                * 3695 35 C0          5@
L3697               pshs      U                   * 3697 34 40          4@
                    ldd       <U00E6              * 3699 DC E6          \f
                    std       [<$04,S]            * 369B ED F8 04       mx.
                    ldd       4,S                 * 369E EC 64          ld
                    std       <U00E6              * 36A0 DD E6          ]f
                    puls      PC,U                * 36A2 35 C0          5@
L36A4               pshs      U,D                 * 36A4 34 46          4F
                    clra                          * 36A6 4F             O
                    clrb                          * 36A7 5F             _
                    std       ,S                  * 36A8 ED E4          md
                    ldd       6,S                 * 36AA EC 66          lf
                    subd      #48                 * 36AC 83 00 30       ..0
                    std       6,S                 * 36AF ED 66          mf
                    ble       L36FA               * 36B1 2F 47          /G
                    ldu       <U00E0              * 36B3 DE E0          ^`
                    ldb       ,U                  * 36B5 E6 C4          fD
                    sex                           * 36B7 1D             .
                    cmpd      6,S                 * 36B8 10 A3 66       .#f
                    blt       L36EF               * 36BB 2D 32          -2
                    leau      1,U                 * 36BD 33 41          3A
                    bra       L36C5               * 36BF 20 04           .
L36C1               ldb       ,U+                 * 36C1 E6 C0          f@
                    bne       L36C1               * 36C3 26 FC          &|
L36C5               ldd       6,S                 * 36C5 EC 66          lf
                    addd      #-1                 * 36C7 C3 FF FF       C..
                    std       6,S                 * 36CA ED 66          mf
                    lbgt      L36C1               * 36CC 10 2E FF F1    ...q
                    bra       L36E9               * 36D0 20 17           .
L36D2               ldd       8,S                 * 36D2 EC 68          lh
                    beq       L36E0               * 36D4 27 0A          '.
                    ldb       ,U                  * 36D6 E6 C4          fD
                    ldx       <U00E4              * 36D8 9E E4          .d
                    leax      1,X                 * 36DA 30 01          0.
                    stx       <U00E4              * 36DC 9F E4          .d
                    stb       -1,X                * 36DE E7 1F          g.
L36E0               leau      1,U                 * 36E0 33 41          3A
                    ldd       ,S                  * 36E2 EC E4          ld
                    addd      #1                  * 36E4 C3 00 01       C..
                    std       ,S                  * 36E7 ED E4          md
L36E9               ldb       ,U                  * 36E9 E6 C4          fD
                    bne       L36D2               * 36EB 26 E5          &e
                    bra       L36FA               * 36ED 20 0B           .
L36EF               leax      >L37A6,PC           * 36EF 30 8D 00 B3    0..3
                    pshs      X                   * 36F3 34 10          4.
                    lbsr      L074E               * 36F5 17 D0 56       .PV
                    leas      2,S                 * 36F8 32 62          2b
L36FA               ldd       ,S                  * 36FA EC E4          ld
                    puls      PC,U,X              * 36FC 35 D0          5P
L36FE               pshs      U                   * 36FE 34 40          4@
                    ldd       <U00DA              * 3700 DC DA          \Z
                    pshs      D                   * 3702 34 06          4.
                    lbsr      fclose              * 3704 17 0A AB       ..+
                    leas      2,S                 * 3707 32 62          2b
                    leax      >dpsiz,Y            * 3709 30 A9 00 E8    0).h
                    pshs      X                   * 370D 34 10          4.
                    lbsr      unlink              * 370F 17 11 86       ...
                    puls      PC,U,X              * 3712 35 D0          5P
L3714               pshs      U                   * 3714 34 40          4@
                    leax      >L37B7,PC           * 3716 30 8D 00 9D    0...
                    pshs      X                   * 371A 34 10          4.
                    lbsr      L078B               * 371C 17 D0 6C       .Pl
                    puls      PC,U,X              * 371F 35 D0          5P
L3721               fcc       "w+"                * 3721 77 2B          w+
                    fcb       $00                 * 3723 00             .
L3724               fcc       "can't open macro work file" * 3724 63 61 6E 27 74 20 6F 70 65 6E 20 6D 61 63 72 6F 20 77 6F 72 6B 20 66 69 6C 65 can't open macro work file
                    fcb       $00                 * 373E 00             .
L373F               fcc       "macro nesting too deep" * 373F 6D 61 63 72 6F 20 6E 65 73 74 69 6E 67 20 74 6F 6F 20 64 65 65 70 macro nesting too deep
                    fcb       $00                 * 3755 00             .
L3756               fcc       "asm err: macro nest" * 3756 61 73 6D 20 65 72 72 3A 20 6D 61 63 72 6F 20 6E 65 73 74 asm err: macro nest
                    fcb       $00                 * 3769 00             .
L376A               fcc       "%03d"              * 376A 25 30 33 64    %03d
                    fcb       $00                 * 376E 00             .
L376F               fcc       "%02d"              * 376F 25 30 32 64    %02d
                    fcb       $00                 * 3773 00             .
L3774               fcc       "unmatched quotes"  * 3774 75 6E 6D 61 74 63 68 65 64 20 71 75 6F 74 65 73 unmatched quotes
                    fcb       $00                 * 3784 00             .
L3785               fcc       "macro arg too long" * 3785 6D 61 63 72 6F 20 61 72 67 20 74 6F 6F 20 6C 6F 6E 67 macro arg too long
                    fcb       $00                 * 3797 00             .
L3798               fcc       "too many args"     * 3798 74 6F 6F 20 6D 61 6E 79 20 61 72 67 73 too many args
                    fcb       $00                 * 37A5 00             .
L37A6               fcc       "no param for arg"  * 37A6 6E 6F 20 70 61 72 61 6D 20 66 6F 72 20 61 72 67 no param for arg
                    fcb       $00                 * 37B6 00             .
L37B7               fcc       "macro file error"  * 37B7 6D 61 63 72 6F 20 66 69 6C 65 20 65 72 72 6F 72 macro file error
                    fcb       $00                 * 37C7 00             .

* fopen

L37C8               pshs      U                   * 37C8 34 40          4@
                    leau      >_iob,Y             * 37CA 33 A9 04 89    3)..
L37CE               ldd       6,U                 * 37CE EC 46          lF
                    clra                          * 37D0 4F             O
                    andb      #3                  * 37D1 C4 03          D.
                    lbeq      L383F               * 37D3 10 27 00 68    .'.h
                    leau      13,U                * 37D7 33 4D          3M
                    pshs      U                   * 37D9 34 40          4@
                    leax      >argv,Y             Should be _iob+208,y                     * 37DB 30 A9 05 59    0).Y
                    cmpx      ,S++                * 37DF AC E1          ,a
                    bhi       L37CE               * 37E1 22 EB          "k
                    ldd       #200                * 37E3 CC 00 C8       L.H
                    std       >errno,Y            * 37E6 ED A9 05 A7    m).'
                    lbra      L3843               * 37EA 16 00 56       ..V
                    puls      PC,U                * 37ED 35 C0          5@
L37EF               pshs      U                   * 37EF 34 40          4@
                    ldu       8,S                 * 37F1 EE 68          nh
                    bne       L37F9               * 37F3 26 04          &.
                    bsr       L37C8               * 37F5 8D D1          .Q
                    tfr       D,U                 * 37F7 1F 03          ..
L37F9               stu       -2,S                * 37F9 EF 7E          o~
                    beq       L3843               * 37FB 27 46          'F
                    ldd       4,S                 * 37FD EC 64          ld
                    std       8,U                 * 37FF ED 48          mH
                    ldx       6,S                 * 3801 AE 66          .f
                    ldb       1,X                 * 3803 E6 01          f.
                    cmpb      #43                 * 3805 C1 2B          A+
                    beq       L3811               * 3807 27 08          '.
                    ldx       6,S                 * 3809 AE 66          .f
                    ldb       2,X                 * 380B E6 02          f.
                    cmpb      #43                 * 380D C1 2B          A+
                    bne       L3817               * 380F 26 06          &.
L3811               ldd       6,U                 * 3811 EC 46          lF
                    orb       #3                  * 3813 CA 03          J.
                    bra       L3835               * 3815 20 1E           .
L3817               ldd       6,U                 * 3817 EC 46          lF
                    pshs      D                   * 3819 34 06          4.
                    ldb       [<$08,S]            * 381B E6 F8 08       fx.
                    cmpb      #114                * 381E C1 72          Ar
                    beq       L3829               * 3820 27 07          '.
                    ldb       [<$08,S]            * 3822 E6 F8 08       fx.
                    cmpb      #100                * 3825 C1 64          Ad
                    bne       L382E               * 3827 26 05          &.
L3829               ldd       #1                  * 3829 CC 00 01       L..
                    bra       L3831               * 382C 20 03           .
L382E               ldd       #2                  * 382E CC 00 02       L..
L3831               ora       ,S+                 * 3831 AA E0          *`
                    orb       ,S+                 * 3833 EA E0          j`
L3835               std       6,U                 * 3835 ED 46          mF
                    ldd       2,U                 * 3837 EC 42          lB
                    addd      11,U                * 3839 E3 4B          cK
                    std       4,U                 * 383B ED 44          mD
                    std       ,U                  * 383D ED C4          mD
L383F               tfr       U,D                 * 383F 1F 30          .0
                    puls      PC,U                * 3841 35 C0          5@
L3843               clra                          * 3843 4F             O
                    clrb                          * 3844 5F             _
                    puls      PC,U                * 3845 35 C0          5@
L3847               pshs      U                   * 3847 34 40          4@
                    ldu       4,S                 * 3849 EE 64          nd
                    leas      -4,S                * 384B 32 7C          2|
                    clra                          * 384D 4F             O
                    clrb                          * 384E 5F             _
                    std       ,S                  * 384F ED E4          md
                    ldx       10,S                * 3851 AE 6A          .j
                    ldb       1,X                 * 3853 E6 01          f.
                    sex                           * 3855 1D             .
                    tfr       D,X                 * 3856 1F 01          ..
                    bra       L3878               * 3858 20 1E           .
L385A               ldx       10,S                * 385A AE 6A          .j
                    ldb       2,X                 * 385C E6 02          f.
                    cmpb      #43                 * 385E C1 2B          A+
                    bne       L3867               * 3860 26 05          &.
                    ldd       #7                  * 3862 CC 00 07       L..
                    bra       L386F               * 3865 20 08           .
L3867               ldd       #4                  * 3867 CC 00 04       L..
                    bra       L386F               * 386A 20 03           .
L386C               ldd       #3                  * 386C CC 00 03       L..
L386F               std       ,S                  * 386F ED E4          md
                    bra       L3888               * 3871 20 15           .
L3873               leax      4,S                 * 3873 30 64          0d
                    lbra      L38E0               * 3875 16 00 68       ..h
L3878               stx       -2,S                * 3878 AF 7E          /~
                    beq       L3888               * 387A 27 0C          '.
                    cmpx      #120                * 387C 8C 00 78       ..x
                    beq       L385A               * 387F 27 D9          'Y
                    cmpx      #43                 * 3881 8C 00 2B       ..+
                    beq       L386C               * 3884 27 E6          'f
                    bra       L3873               * 3886 20 EB           k
L3888               ldb       [<$0A,S]            * 3888 E6 F8 0A       fx.
                    sex                           * 388B 1D             .
                    tfr       D,X                 * 388C 1F 01          ..
                    lbra      L38ED               * 388E 16 00 5C       ..\
L3891               ldd       ,S                  * 3891 EC E4          ld
                    orb       #1                  * 3893 CA 01          J.
                    bra       L38D3               * 3895 20 3C           <
L3897               ldd       ,S                  * 3897 EC E4          ld
                    orb       #2                  * 3899 CA 02          J.
                    pshs      D                   * 389B 34 06          4.
                    pshs      U                   * 389D 34 40          4@
                    lbsr      open                * 389F 17 0F 93       ...
                    leas      4,S                 * 38A2 32 64          2d
                    std       2,S                 * 38A4 ED 62          mb
                    cmpd      #-1                 * 38A6 10 83 FF FF    ....
                    beq       L38C2               * 38AA 27 16          '.
                    ldd       #2                  * 38AC CC 00 02       L..
                    pshs      D                   * 38AF 34 06          4.
                    clra                          * 38B1 4F             O
                    clrb                          * 38B2 5F             _
                    pshs      D                   * 38B3 34 06          4.
                    pshs      D                   * 38B5 34 06          4.
                    ldd       8,S                 * 38B7 EC 68          lh
                    pshs      D                   * 38B9 34 06          4.
                    lbsr      lseek               * 38BB 17 10 49       ..I
                    leas      8,S                 * 38BE 32 68          2h
                    bra       L3907               * 38C0 20 45           E
L38C2               ldd       ,S                  * 38C2 EC E4          ld
                    orb       #2                  * 38C4 CA 02          J.
                    pshs      D                   * 38C6 34 06          4.
                    pshs      U                   * 38C8 34 40          4@
                    lbsr      creat               * 38CA 17 0F 89       ...
                    bra       L38DA               * 38CD 20 0B           .
L38CF               ldd       ,S                  * 38CF EC E4          ld
                    orb       #129                * 38D1 CA 81          J.
L38D3               pshs      D                   * 38D3 34 06          4.
                    pshs      U                   * 38D5 34 40          4@
                    lbsr      open                * 38D7 17 0F 5B       ..[
L38DA               leas      4,S                 * 38DA 32 64          2d
                    std       2,S                 * 38DC ED 62          mb
                    bra       L3907               * 38DE 20 27           '
L38E0               leas      -4,X                * 38E0 32 1C          2.
L38E2               ldd       #203                * 38E2 CC 00 CB       L.K
                    std       >errno,Y            * 38E5 ED A9 05 A7    m).'
                    clra                          * 38E9 4F             O
                    clrb                          * 38EA 5F             _
                    bra       L3909               * 38EB 20 1C           .
L38ED               cmpx      #114                * 38ED 8C 00 72       ..r
                    lbeq      L3891               * 38F0 10 27 FF 9D    .'..
                    cmpx      #97                 * 38F4 8C 00 61       ..a
                    lbeq      L3897               * 38F7 10 27 FF 9C    .'..
                    cmpx      #119                * 38FB 8C 00 77       ..w
                    beq       L38C2               * 38FE 27 C2          'B
                    cmpx      #100                * 3900 8C 00 64       ..d
                    beq       L38CF               * 3903 27 CA          'J
                    bra       L38E2               * 3905 20 DB           [
L3907               ldd       2,S                 * 3907 EC 62          lb
L3909               leas      4,S                 * 3909 32 64          2d
                    puls      PC,U                * 390B 35 C0          5@
fdopen              pshs      U                   * 390D 34 40          4@
                    clra                          * 390F 4F             O
                    clrb                          * 3910 5F             _
                    pshs      D                   * 3911 34 06          4.
                    ldd       8,S                 * 3913 EC 68          lh
                    pshs      D                   * 3915 34 06          4.
                    ldd       8,S                 * 3917 EC 68          lh
                    pshs      D                   * 3919 34 06          4.
                    lbra      L3969               * 391B 16 00 4B       ..K
fopen               pshs      U                   * 391E 34 40          4@
                    ldd       6,S                 * 3920 EC 66          lf
                    pshs      D                   * 3922 34 06          4.
                    ldd       6,S                 * 3924 EC 66          lf
                    pshs      D                   * 3926 34 06          4.
                    lbsr      L3847               * 3928 17 FF 1C       ...
                    leas      4,S                 * 392B 32 64          2d
                    tfr       D,U                 * 392D 1F 03          ..
                    cmpu      #-1                 * 392F 11 83 FF FF    ....
                    bne       L3939               * 3933 26 04          &.
                    clra                          * 3935 4F             O
                    clrb                          * 3936 5F             _
                    bra       L396E               * 3937 20 35           5
L3939               clra                          * 3939 4F             O
                    clrb                          * 393A 5F             _
                    bra       L3961               * 393B 20 24           $
freopen             pshs      U                   * 393D 34 40          4@
                    ldd       8,S                 * 393F EC 68          lh
                    pshs      D                   * 3941 34 06          4.
                    lbsr      fclose              * 3943 17 08 6C       ..l
                    leas      2,S                 * 3946 32 62          2b
                    ldd       6,S                 * 3948 EC 66          lf
                    pshs      D                   * 394A 34 06          4.
                    ldd       6,S                 * 394C EC 66          lf
                    pshs      D                   * 394E 34 06          4.
                    lbsr      L3847               * 3950 17 FE F4       .~t
                    leas      4,S                 * 3953 32 64          2d
                    tfr       D,U                 * 3955 1F 03          ..
                    stu       -2,S                * 3957 EF 7E          o~
                    bge       L395F               * 3959 2C 04          ,.
                    clra                          * 395B 4F             O
                    clrb                          * 395C 5F             _
                    bra       L396E               * 395D 20 0F           .
L395F               ldd       8,S                 * 395F EC 68          lh
L3961               pshs      D                   * 3961 34 06          4.
                    ldd       8,S                 * 3963 EC 68          lh
                    pshs      D                   * 3965 34 06          4.
                    pshs      U                   * 3967 34 40          4@
L3969               lbsr      L37EF               * 3969 17 FE 83       .~.
                    leas      6,S                 * 396C 32 66          2f
L396E               puls      PC,U                * 396E 35 C0          5@
                    pshs      U                   * 3970 34 40          4@
                    leax      >Y0496,Y            * 3972 30 A9 04 96    0)..
                    pshs      X                   * 3976 34 10          4.
                    ldd       6,S                 * 3978 EC 66          lf
                    pshs      D                   * 397A 34 06          4.
                    bsr       L3992               * 397C 8D 14          ..
                    leas      4,S                 * 397E 32 64          2d
                    leax      >Y0496,Y            * 3980 30 A9 04 96    0)..
                    pshs      X                   * 3984 34 10          4.
                    ldd       #13                 * 3986 CC 00 0D       L..
                    pshs      D                   * 3989 34 06          4.
                    lbsr      L40C2               * 398B 17 07 34       ..4
                    leas      4,S                 * 398E 32 64          2d
                    puls      PC,U                * 3990 35 C0          5@
L3992               pshs      U                   * 3992 34 40          4@
                    ldu       4,S                 * 3994 EE 64          nd
                    leas      -1,S                * 3996 32 7F          2.
                    bra       L39A8               * 3998 20 0E           .
L399A               ldd       7,S                 * 399A EC 67          lg
                    pshs      D                   * 399C 34 06          4.
                    ldb       2,S                 * 399E E6 62          fb
                    sex                           * 39A0 1D             .
                    pshs      D                   * 39A1 34 06          4.
                    lbsr      L40C2               * 39A3 17 07 1C       ...
                    leas      4,S                 * 39A6 32 64          2d
L39A8               ldb       ,U+                 * 39A8 E6 C0          f@
                    stb       ,S                  * 39AA E7 E4          gd
                    bne       L399A               * 39AC 26 EC          &l
                    leas      1,S                 * 39AE 32 61          2a
                    puls      PC,U                * 39B0 35 C0          5@
L39B2               pshs      U                   * 39B2 34 40          4@
                    ldu       4,S                 * 39B4 EE 64          nd
                    leas      -4,S                * 39B6 32 7C          2|
                    clra                          * 39B8 4F             O
                    clrb                          * 39B9 5F             _
                    bra       L39ED               * 39BA 20 31           1
L39BC               clra                          * 39BC 4F             O
                    clrb                          * 39BD 5F             _
                    std       ,S                  * 39BE ED E4          md
                    bra       L39D9               * 39C0 20 17           .
L39C2               ldd       14,S                * 39C2 EC 6E          ln
                    pshs      D                   * 39C4 34 06          4.
                    ldb       ,U+                 * 39C6 E6 C0          f@
                    sex                           * 39C8 1D             .
                    pshs      D                   * 39C9 34 06          4.
                    lbsr      L40C2               * 39CB 17 06 F4       ..t
                    leas      4,S                 * 39CE 32 64          2d
                    ldx       14,S                * 39D0 AE 6E          .n
                    ldd       6,X                 * 39D2 EC 06          l.
                    clra                          * 39D4 4F             O
                    andb      #32                 * 39D5 C4 20          D
                    bne       L39F6               * 39D7 26 1D          &.
L39D9               ldd       ,S                  * 39D9 EC E4          ld
                    addd      #1                  * 39DB C3 00 01       C..
                    std       ,S                  * 39DE ED E4          md
                    subd      #1                  * 39E0 83 00 01       ...
                    cmpd      10,S                * 39E3 10 A3 6A       .#j
                    blt       L39C2               * 39E6 2D DA          -Z
                    ldd       2,S                 * 39E8 EC 62          lb
                    addd      #1                  * 39EA C3 00 01       C..
L39ED               std       2,S                 * 39ED ED 62          mb
                    ldd       2,S                 * 39EF EC 62          lb
                    cmpd      12,S                * 39F1 10 A3 6C       .#l
                    blt       L39BC               * 39F4 2D C6          -F
L39F6               ldd       2,S                 * 39F6 EC 62          lb
                    leas      4,S                 * 39F8 32 64          2d
                    puls      PC,U                * 39FA 35 C0          5@
L39FC               pshs      U                   * 39FC 34 40          4@
                    leax      >Y0496,Y            * 39FE 30 A9 04 96    0)..
                    stx       >Y09A7,Y            * 3A02 AF A9 09 A7    /).'
                    leax      6,S                 * 3A06 30 66          0f
                    pshs      X                   * 3A08 34 10          4.
                    ldd       6,S                 * 3A0A EC 66          lf
                    bra       L3A1C               * 3A0C 20 0E           .
L3A0E               pshs      U                   * 3A0E 34 40          4@
                    ldd       4,S                 * 3A10 EC 64          ld
                    std       >Y09A7,Y            * 3A12 ED A9 09 A7    m).'
                    leax      8,S                 * 3A16 30 68          0h
                    pshs      X                   * 3A18 34 10          4.
                    ldd       8,S                 * 3A1A EC 68          lh
L3A1C               pshs      D                   * 3A1C 34 06          4.
                    leax      >L3ED6,PC           * 3A1E 30 8D 04 B4    0..4
                    pshs      X                   * 3A22 34 10          4.
                    bsr       L3A4E               * 3A24 8D 28          .(
                    leas      6,S                 * 3A26 32 66          2f
                    puls      PC,U                * 3A28 35 C0          5@
L3A2A               pshs      U                   * 3A2A 34 40          4@
                    ldd       4,S                 * 3A2C EC 64          ld
                    std       >Y09A7,Y            * 3A2E ED A9 09 A7    m).'
                    leax      8,S                 * 3A32 30 68          0h
                    pshs      X                   * 3A34 34 10          4.
                    ldd       8,S                 * 3A36 EC 68          lh
                    pshs      D                   * 3A38 34 06          4.
                    leax      >L3EE9,PC           * 3A3A 30 8D 04 AB    0..+
                    pshs      X                   * 3A3E 34 10          4.
                    bsr       L3A4E               * 3A40 8D 0C          ..
                    leas      6,S                 * 3A42 32 66          2f
                    clra                          * 3A44 4F             O
                    clrb                          * 3A45 5F             _
                    stb       [>Y09A7,Y]          * 3A46 E7 B9 09 A7    g9.'
                    ldd       4,S                 * 3A4A EC 64          ld
                    puls      PC,U                * 3A4C 35 C0          5@
L3A4E               pshs      U                   * 3A4E 34 40          4@
                    ldu       6,S                 * 3A50 EE 66          nf
                    leas      -11,S               * 3A52 32 75          2u
                    bra       L3A66               * 3A54 20 10           .
L3A56               ldb       8,S                 * 3A56 E6 68          fh
                    lbeq      L3C97               * 3A58 10 27 02 3B    .'.;
                    ldb       8,S                 * 3A5C E6 68          fh
                    sex                           * 3A5E 1D             .
                    pshs      D                   * 3A5F 34 06          4.
                    jsr       [<$11,S]            * 3A61 AD F8 11       -x.
                    leas      2,S                 * 3A64 32 62          2b
L3A66               ldb       ,U+                 * 3A66 E6 C0          f@
                    stb       8,S                 * 3A68 E7 68          gh
                    cmpb      #37                 * 3A6A C1 25          A%
                    bne       L3A56               * 3A6C 26 E8          &h
                    ldb       ,U+                 * 3A6E E6 C0          f@
                    stb       8,S                 * 3A70 E7 68          gh
                    clra                          * 3A72 4F             O
                    clrb                          * 3A73 5F             _
                    std       2,S                 * 3A74 ED 62          mb
                    std       6,S                 * 3A76 ED 66          mf
                    ldb       8,S                 * 3A78 E6 68          fh
                    cmpb      #45                 * 3A7A C1 2D          A-
                    bne       L3A8B               * 3A7C 26 0D          &.
                    ldd       #1                  * 3A7E CC 00 01       L..
                    std       >Y09BD,Y            * 3A81 ED A9 09 BD    m).=
                    ldb       ,U+                 * 3A85 E6 C0          f@
                    stb       8,S                 * 3A87 E7 68          gh
                    bra       L3A91               * 3A89 20 06           .
L3A8B               clra                          * 3A8B 4F             O
                    clrb                          * 3A8C 5F             _
                    std       >Y09BD,Y            * 3A8D ED A9 09 BD    m).=
L3A91               ldb       8,S                 * 3A91 E6 68          fh
                    cmpb      #48                 * 3A93 C1 30          A0
                    bne       L3A9C               * 3A95 26 05          &.
                    ldd       #48                 * 3A97 CC 00 30       L.0
                    bra       L3A9F               * 3A9A 20 03           .
L3A9C               ldd       #32                 * 3A9C CC 00 20       L.
L3A9F               std       >Y09BF,Y            * 3A9F ED A9 09 BF    m).?
                    bra       L3ABF               * 3AA3 20 1A           .
L3AA5               ldd       6,S                 * 3AA5 EC 66          lf
                    pshs      D                   * 3AA7 34 06          4.
                    ldd       #10                 * 3AA9 CC 00 0A       L..
                    lbsr      L466A               * 3AAC 17 0B BB       ..;
                    pshs      D                   * 3AAF 34 06          4.
                    ldb       10,S                * 3AB1 E6 6A          fj
                    sex                           * 3AB3 1D             .
                    addd      #-48                * 3AB4 C3 FF D0       C.P
                    addd      ,S++                * 3AB7 E3 E1          ca
                    std       6,S                 * 3AB9 ED 66          mf
                    ldb       ,U+                 * 3ABB E6 C0          f@
                    stb       8,S                 * 3ABD E7 68          gh
L3ABF               ldb       8,S                 * 3ABF E6 68          fh
                    sex                           * 3AC1 1D             .
                    leax      >Y03FC,Y            * 3AC2 30 A9 03 FC    0).|
                    leax      D,X                 * 3AC6 30 8B          0.
                    ldb       ,X                  * 3AC8 E6 84          f.
                    clra                          * 3ACA 4F             O
                    andb      #8                  * 3ACB C4 08          D.
                    bne       L3AA5               * 3ACD 26 D6          &V
                    ldb       8,S                 * 3ACF E6 68          fh
                    cmpb      #46                 * 3AD1 C1 2E          A.
                    bne       L3B08               * 3AD3 26 33          &3
                    ldd       #1                  * 3AD5 CC 00 01       L..
                    std       4,S                 * 3AD8 ED 64          md
                    bra       L3AF2               * 3ADA 20 16           .
L3ADC               ldd       2,S                 * 3ADC EC 62          lb
                    pshs      D                   * 3ADE 34 06          4.
                    ldd       #10                 * 3AE0 CC 00 0A       L..
                    lbsr      L466A               * 3AE3 17 0B 84       ...
                    pshs      D                   * 3AE6 34 06          4.
                    ldb       10,S                * 3AE8 E6 6A          fj
                    sex                           * 3AEA 1D             .
                    addd      #-48                * 3AEB C3 FF D0       C.P
                    addd      ,S++                * 3AEE E3 E1          ca
                    std       2,S                 * 3AF0 ED 62          mb
L3AF2               ldb       ,U+                 * 3AF2 E6 C0          f@
                    stb       8,S                 * 3AF4 E7 68          gh
                    ldb       8,S                 * 3AF6 E6 68          fh
                    sex                           * 3AF8 1D             .
                    leax      >Y03FC,Y            * 3AF9 30 A9 03 FC    0).|
                    leax      D,X                 * 3AFD 30 8B          0.
                    ldb       ,X                  * 3AFF E6 84          f.
                    clra                          * 3B01 4F             O
                    andb      #8                  * 3B02 C4 08          D.
                    bne       L3ADC               * 3B04 26 D6          &V
                    bra       L3B0C               * 3B06 20 04           .
L3B08               clra                          * 3B08 4F             O
                    clrb                          * 3B09 5F             _
                    std       4,S                 * 3B0A ED 64          md
L3B0C               ldb       8,S                 * 3B0C E6 68          fh
                    sex                           * 3B0E 1D             .
                    tfr       D,X                 * 3B0F 1F 01          ..
                    lbra      L3C3A               * 3B11 16 01 26       ..&
L3B14               ldd       6,S                 * 3B14 EC 66          lf
                    pshs      D                   * 3B16 34 06          4.
                    ldx       <$15,S              * 3B18 AE E8 15       .h.
                    leax      2,X                 * 3B1B 30 02          0.
                    stx       <$15,S              * 3B1D AF E8 15       /h.
                    ldd       -2,X                * 3B20 EC 1E          l.
                    pshs      D                   * 3B22 34 06          4.
                    lbsr      L3C9B               * 3B24 17 01 74       ..t
                    bra       L3B3C               * 3B27 20 13           .
L3B29               ldd       6,S                 * 3B29 EC 66          lf
                    pshs      D                   * 3B2B 34 06          4.
                    ldx       <$15,S              * 3B2D AE E8 15       .h.
                    leax      2,X                 * 3B30 30 02          0.
                    stx       <$15,S              * 3B32 AF E8 15       /h.
                    ldd       -2,X                * 3B35 EC 1E          l.
                    pshs      D                   * 3B37 34 06          4.
                    lbsr      L3D5C               * 3B39 17 02 20       ..
L3B3C               std       ,S                  * 3B3C ED E4          md
                    lbra      L3C20               * 3B3E 16 00 DF       .._
L3B41               ldd       6,S                 * 3B41 EC 66          lf
                    pshs      D                   * 3B43 34 06          4.
                    ldb       10,S                * 3B45 E6 6A          fj
                    sex                           * 3B47 1D             .
                    leax      >Y03FC,Y            * 3B48 30 A9 03 FC    0).|
                    leax      D,X                 * 3B4C 30 8B          0.
                    ldb       ,X                  * 3B4E E6 84          f.
                    clra                          * 3B50 4F             O
                    andb      #2                  * 3B51 C4 02          D.
                    pshs      D                   * 3B53 34 06          4.
                    ldx       <$17,S              * 3B55 AE E8 17       .h.
                    leax      2,X                 * 3B58 30 02          0.
                    stx       <$17,S              * 3B5A AF E8 17       /h.
                    ldd       -2,X                * 3B5D EC 1E          l.
                    pshs      D                   * 3B5F 34 06          4.
                    lbsr      L3DA2               * 3B61 17 02 3E       ..>
                    lbra      L3C1C               * 3B64 16 00 B5       ..5
L3B67               ldd       6,S                 * 3B67 EC 66          lf
                    pshs      D                   * 3B69 34 06          4.
                    ldx       <$15,S              * 3B6B AE E8 15       .h.
                    leax      2,X                 * 3B6E 30 02          0.
                    stx       <$15,S              * 3B70 AF E8 15       /h.
                    ldd       -2,X                * 3B73 EC 1E          l.
                    pshs      D                   * 3B75 34 06          4.
                    leax      >Y09A9,Y            * 3B77 30 A9 09 A9    0).)
                    pshs      X                   * 3B7B 34 10          4.
                    lbsr      L3CE3               * 3B7D 17 01 63       ..c
                    lbra      L3C1C               * 3B80 16 00 99       ...
L3B83               ldd       4,S                 * 3B83 EC 64          ld
                    bne       L3B8C               * 3B85 26 05          &.
                    ldd       #6                  * 3B87 CC 00 06       L..
                    std       2,S                 * 3B8A ED 62          mb
L3B8C               ldd       6,S                 * 3B8C EC 66          lf
                    pshs      D                   * 3B8E 34 06          4.
                    leax      <$15,S              * 3B90 30 E8 15       0h.
                    pshs      X                   * 3B93 34 10          4.
                    ldd       6,S                 * 3B95 EC 66          lf
                    pshs      D                   * 3B97 34 06          4.
                    ldb       14,S                * 3B99 E6 6E          fn
                    sex                           * 3B9B 1D             .
                    pshs      D                   * 3B9C 34 06          4.
                    lbsr      L44F8               * 3B9E 17 09 57       ..W
                    leas      6,S                 * 3BA1 32 66          2f
                    lbra      L3C1E               * 3BA3 16 00 78       ..x
L3BA6               ldx       <$13,S              * 3BA6 AE E8 13       .h.
                    leax      2,X                 * 3BA9 30 02          0.
                    stx       <$13,S              * 3BAB AF E8 13       /h.
                    ldd       -2,X                * 3BAE EC 1E          l.
                    lbra      L3C30               * 3BB0 16 00 7D       ..}
L3BB3               ldx       <$13,S              * 3BB3 AE E8 13       .h.
                    leax      2,X                 * 3BB6 30 02          0.
                    stx       <$13,S              * 3BB8 AF E8 13       /h.
                    ldd       -2,X                * 3BBB EC 1E          l.
                    std       9,S                 * 3BBD ED 69          mi
                    ldd       4,S                 * 3BBF EC 64          ld
                    beq       L3BFB               * 3BC1 27 38          '8
                    ldd       9,S                 * 3BC3 EC 69          li
                    std       4,S                 * 3BC5 ED 64          md
                    bra       L3BD5               * 3BC7 20 0C           .
L3BC9               ldb       [<$09,S]            * 3BC9 E6 F8 09       fx.
                    beq       L3BE1               * 3BCC 27 13          '.
                    ldd       9,S                 * 3BCE EC 69          li
                    addd      #1                  * 3BD0 C3 00 01       C..
                    std       9,S                 * 3BD3 ED 69          mi
L3BD5               ldd       2,S                 * 3BD5 EC 62          lb
                    addd      #-1                 * 3BD7 C3 FF FF       C..
                    std       2,S                 * 3BDA ED 62          mb
                    subd      #-1                 * 3BDC 83 FF FF       ...
                    bne       L3BC9               * 3BDF 26 E8          &h
L3BE1               ldd       6,S                 * 3BE1 EC 66          lf
                    pshs      D                   * 3BE3 34 06          4.
                    ldd       11,S                * 3BE5 EC 6B          lk
                    subd      6,S                 * 3BE7 A3 66          #f
                    pshs      D                   * 3BE9 34 06          4.
                    ldd       8,S                 * 3BEB EC 68          lh
                    pshs      D                   * 3BED 34 06          4.
                    ldd       <$15,S              * 3BEF EC E8 15       lh.
                    pshs      D                   * 3BF2 34 06          4.
                    lbsr      L3E0D               * 3BF4 17 02 16       ...
                    leas      8,S                 * 3BF7 32 68          2h
                    bra       L3C2A               * 3BF9 20 2F           /
L3BFB               ldd       6,S                 * 3BFB EC 66          lf
                    pshs      D                   * 3BFD 34 06          4.
                    ldd       11,S                * 3BFF EC 6B          lk
                    bra       L3C1E               * 3C01 20 1B           .
L3C03               ldb       ,U+                 * 3C03 E6 C0          f@
                    stb       8,S                 * 3C05 E7 68          gh
                    bra       L3C0B               * 3C07 20 02           .
                    leas      -11,X               * 3C09 32 15          2.
L3C0B               ldd       6,S                 * 3C0B EC 66          lf
                    pshs      D                   * 3C0D 34 06          4.
                    leax      <$15,S              * 3C0F 30 E8 15       0h.
                    pshs      X                   * 3C12 34 10          4.
                    ldb       12,S                * 3C14 E6 6C          fl
                    sex                           * 3C16 1D             .
                    pshs      D                   * 3C17 34 06          4.
                    lbsr      L44BA               * 3C19 17 08 9E       ...
L3C1C               leas      4,S                 * 3C1C 32 64          2d
L3C1E               pshs      D                   * 3C1E 34 06          4.
L3C20               ldd       <$13,S              * 3C20 EC E8 13       lh.
                    pshs      D                   * 3C23 34 06          4.
                    lbsr      L3E6F               * 3C25 17 02 47       ..G
                    leas      6,S                 * 3C28 32 66          2f
L3C2A               lbra      L3A66               * 3C2A 16 FE 39       .~9
L3C2D               ldb       8,S                 * 3C2D E6 68          fh
                    sex                           * 3C2F 1D             .
L3C30               pshs      D                   * 3C30 34 06          4.
                    jsr       [<$11,S]            * 3C32 AD F8 11       -x.
                    leas      2,S                 * 3C35 32 62          2b
                    lbra      L3A66               * 3C37 16 FE 2C       .~,
L3C3A               cmpx      #100                * 3C3A 8C 00 64       ..d
                    lbeq      L3B14               * 3C3D 10 27 FE D3    .'~S
                    cmpx      #111                * 3C41 8C 00 6F       ..o
                    lbeq      L3B29               * 3C44 10 27 FE E1    .'~a
                    cmpx      #120                * 3C48 8C 00 78       ..x
                    lbeq      L3B41               * 3C4B 10 27 FE F2    .'~r
                    cmpx      #88                 * 3C4F 8C 00 58       ..X
                    lbeq      L3B41               * 3C52 10 27 FE EB    .'~k
                    cmpx      #117                * 3C56 8C 00 75       ..u
                    lbeq      L3B67               * 3C59 10 27 FF 0A    .'..
                    cmpx      #102                * 3C5D 8C 00 66       ..f
                    lbeq      L3B83               * 3C60 10 27 FF 1F    .'..
                    cmpx      #101                * 3C64 8C 00 65       ..e
                    lbeq      L3B83               * 3C67 10 27 FF 18    .'..
                    cmpx      #103                * 3C6B 8C 00 67       ..g
                    lbeq      L3B83               * 3C6E 10 27 FF 11    .'..
                    cmpx      #69                 * 3C72 8C 00 45       ..E
                    lbeq      L3B83               * 3C75 10 27 FF 0A    .'..
                    cmpx      #71                 * 3C79 8C 00 47       ..G
                    lbeq      L3B83               * 3C7C 10 27 FF 03    .'..
                    cmpx      #99                 * 3C80 8C 00 63       ..c
                    lbeq      L3BA6               * 3C83 10 27 FF 1F    .'..
                    cmpx      #115                * 3C87 8C 00 73       ..s
                    lbeq      L3BB3               * 3C8A 10 27 FF 25    .'.%
                    cmpx      #108                * 3C8E 8C 00 6C       ..l
                    lbeq      L3C03               * 3C91 10 27 FF 6E    .'.n
                    bra       L3C2D               * 3C95 20 96           .
L3C97               leas      11,S                * 3C97 32 6B          2k
                    puls      PC,U                * 3C99 35 C0          5@
L3C9B               pshs      U,D                 * 3C9B 34 46          4F
                    leax      >Y09A9,Y            * 3C9D 30 A9 09 A9    0).)
                    stx       ,S                  * 3CA1 AF E4          /d
                    ldd       6,S                 * 3CA3 EC 66          lf
                    bge       L3CCF               * 3CA5 2C 28          ,(
                    ldd       6,S                 * 3CA7 EC 66          lf
                    nega                          * 3CA9 40             @
                    negb                          * 3CAA 50             P
                    sbca      #0                  * 3CAB 82 00          ..
                    std       6,S                 * 3CAD ED 66          mf
                    bge       L3CC4               * 3CAF 2C 13          ,.
                    leax      >L3EFB,PC           * 3CB1 30 8D 02 46    0..F
                    pshs      X                   * 3CB5 34 10          4.
                    leax      >Y09A9,Y            * 3CB7 30 A9 09 A9    0).)
                    pshs      X                   * 3CBB 34 10          4.
                    lbsr      L4514               * 3CBD 17 08 54       ..T
                    leas      4,S                 * 3CC0 32 64          2d
                    puls      PC,U,X              * 3CC2 35 D0          5P
L3CC4               ldd       #45                 * 3CC4 CC 00 2D       L.-
                    ldx       ,S                  * 3CC7 AE E4          .d
                    leax      1,X                 * 3CC9 30 01          0.
                    stx       ,S                  * 3CCB AF E4          /d
                    stb       -1,X                * 3CCD E7 1F          g.
L3CCF               ldd       6,S                 * 3CCF EC 66          lf
                    pshs      D                   * 3CD1 34 06          4.
                    ldd       2,S                 * 3CD3 EC 62          lb
                    pshs      D                   * 3CD5 34 06          4.
                    bsr       L3CE3               * 3CD7 8D 0A          ..
                    leas      4,S                 * 3CD9 32 64          2d
                    leax      >Y09A9,Y            * 3CDB 30 A9 09 A9    0).)
                    tfr       X,D                 * 3CDF 1F 10          ..
                    puls      PC,U,X              * 3CE1 35 D0          5P
L3CE3               pshs      U,Y,X,D             * 3CE3 34 76          4v
                    ldu       10,S                * 3CE5 EE 6A          nj
                    clra                          * 3CE7 4F             O
                    clrb                          * 3CE8 5F             _
                    std       2,S                 * 3CE9 ED 62          mb
                    clra                          * 3CEB 4F             O
                    clrb                          * 3CEC 5F             _
                    std       ,S                  * 3CED ED E4          md
                    bra       L3D00               * 3CEF 20 0F           .
L3CF1               ldd       ,S                  * 3CF1 EC E4          ld
                    addd      #1                  * 3CF3 C3 00 01       C..
                    std       ,S                  * 3CF6 ED E4          md
                    ldd       12,S                * 3CF8 EC 6C          ll
                    subd      >Y047C,Y            * 3CFA A3 A9 04 7C    #).|
                    std       12,S                * 3CFE ED 6C          ml
L3D00               ldd       12,S                * 3D00 EC 6C          ll
                    blt       L3CF1               * 3D02 2D ED          -m
                    leax      >Y047C,Y            * 3D04 30 A9 04 7C    0).|
                    stx       4,S                 * 3D08 AF 64          /d
                    bra       L3D42               * 3D0A 20 36           6
L3D0C               ldd       ,S                  * 3D0C EC E4          ld
                    addd      #1                  * 3D0E C3 00 01       C..
                    std       ,S                  * 3D11 ED E4          md
L3D13               ldd       12,S                * 3D13 EC 6C          ll
                    subd      [<$04,S]            * 3D15 A3 F8 04       #x.
                    std       12,S                * 3D18 ED 6C          ml
                    bge       L3D0C               * 3D1A 2C F0          ,p
                    ldd       12,S                * 3D1C EC 6C          ll
                    addd      [<$04,S]            * 3D1E E3 F8 04       cx.
                    std       12,S                * 3D21 ED 6C          ml
                    ldd       ,S                  * 3D23 EC E4          ld
                    beq       L3D2C               * 3D25 27 05          '.
                    ldd       #1                  * 3D27 CC 00 01       L..
                    std       2,S                 * 3D2A ED 62          mb
L3D2C               ldd       2,S                 * 3D2C EC 62          lb
                    beq       L3D37               * 3D2E 27 07          '.
                    ldd       ,S                  * 3D30 EC E4          ld
                    addd      #48                 * 3D32 C3 00 30       C.0
                    stb       ,U+                 * 3D35 E7 C0          g@
L3D37               clra                          * 3D37 4F             O
                    clrb                          * 3D38 5F             _
                    std       ,S                  * 3D39 ED E4          md
                    ldd       4,S                 * 3D3B EC 64          ld
                    addd      #2                  * 3D3D C3 00 02       C..
                    std       4,S                 * 3D40 ED 64          md
L3D42               ldd       4,S                 * 3D42 EC 64          ld
                    cmpd      >Y0484,Y            * 3D44 10 A3 A9 04 84 .#)..
                    bne       L3D13               * 3D49 26 C8          &H
                    ldd       12,S                * 3D4B EC 6C          ll
                    addd      #48                 * 3D4D C3 00 30       C.0
                    stb       ,U+                 * 3D50 E7 C0          g@
                    clra                          * 3D52 4F             O
                    clrb                          * 3D53 5F             _
                    stb       ,U                  * 3D54 E7 C4          gD
                    ldd       10,S                * 3D56 EC 6A          lj
                    leas      6,S                 * 3D58 32 66          2f
                    puls      PC,U                * 3D5A 35 C0          5@
L3D5C               pshs      U,D                 * 3D5C 34 46          4F
                    leax      >Y09A9,Y            * 3D5E 30 A9 09 A9    0).)
                    stx       ,S                  * 3D62 AF E4          /d
                    leau      >Y09B3,Y            * 3D64 33 A9 09 B3    3).3
L3D68               ldd       6,S                 * 3D68 EC 66          lf
                    clra                          * 3D6A 4F             O
                    andb      #7                  * 3D6B C4 07          D.
                    addd      #48                 * 3D6D C3 00 30       C.0
                    stb       ,U+                 * 3D70 E7 C0          g@
                    ldd       6,S                 * 3D72 EC 66          lf
                    lsra                          * 3D74 44             D
                    rorb                          * 3D75 56             V
                    lsra                          * 3D76 44             D
                    rorb                          * 3D77 56             V
                    lsra                          * 3D78 44             D
                    rorb                          * 3D79 56             V
                    std       6,S                 * 3D7A ED 66          mf
                    bne       L3D68               * 3D7C 26 EA          &j
                    bra       L3D8A               * 3D7E 20 0A           .
L3D80               ldb       ,U                  * 3D80 E6 C4          fD
                    ldx       ,S                  * 3D82 AE E4          .d
                    leax      1,X                 * 3D84 30 01          0.
                    stx       ,S                  * 3D86 AF E4          /d
                    stb       -1,X                * 3D88 E7 1F          g.
L3D8A               leau      -1,U                * 3D8A 33 5F          3_
                    pshs      U                   * 3D8C 34 40          4@
                    leax      >Y09B3,Y            * 3D8E 30 A9 09 B3    0).3
                    cmpx      ,S++                * 3D92 AC E1          ,a
                    bls       L3D80               * 3D94 23 EA          #j
                    clra                          * 3D96 4F             O
                    clrb                          * 3D97 5F             _
                    stb       [,S]                * 3D98 E7 F4          gt
                    leax      >Y09A9,Y            * 3D9A 30 A9 09 A9    0).)
                    tfr       X,D                 * 3D9E 1F 10          ..
                    puls      PC,U,X              * 3DA0 35 D0          5P
L3DA2               pshs      U,X,D               * 3DA2 34 56          4V
                    leax      >Y09A9,Y            * 3DA4 30 A9 09 A9    0).)
                    stx       2,S                 * 3DA8 AF 62          /b
                    leau      >Y09B3,Y            * 3DAA 33 A9 09 B3    3).3
L3DAE               ldd       8,S                 * 3DAE EC 68          lh
                    clra                          * 3DB0 4F             O
                    andb      #15                 * 3DB1 C4 0F          D.
                    std       ,S                  * 3DB3 ED E4          md
                    pshs      D                   * 3DB5 34 06          4.
                    ldd       2,S                 * 3DB7 EC 62          lb
                    cmpd      #9                  * 3DB9 10 83 00 09    ....
                    ble       L3DD0               * 3DBD 2F 11          /.
                    ldd       12,S                * 3DBF EC 6C          ll
                    beq       L3DC8               * 3DC1 27 05          '.
                    ldd       #65                 * 3DC3 CC 00 41       L.A
                    bra       L3DCB               * 3DC6 20 03           .
L3DC8               ldd       #97                 * 3DC8 CC 00 61       L.a
L3DCB               addd      #-10                * 3DCB C3 FF F6       C.v
                    bra       L3DD3               * 3DCE 20 03           .
L3DD0               ldd       #48                 * 3DD0 CC 00 30       L.0
L3DD3               addd      ,S++                * 3DD3 E3 E1          ca
                    stb       ,U+                 * 3DD5 E7 C0          g@
                    ldd       8,S                 * 3DD7 EC 68          lh
                    lsra                          * 3DD9 44             D
                    rorb                          * 3DDA 56             V
                    lsra                          * 3DDB 44             D
                    rorb                          * 3DDC 56             V
                    lsra                          * 3DDD 44             D
                    rorb                          * 3DDE 56             V
                    lsra                          * 3DDF 44             D
                    rorb                          * 3DE0 56             V
                    anda      #15                 * 3DE1 84 0F          ..
                    std       8,S                 * 3DE3 ED 68          mh
                    bne       L3DAE               * 3DE5 26 C7          &G
                    bra       L3DF3               * 3DE7 20 0A           .
L3DE9               ldb       ,U                  * 3DE9 E6 C4          fD
                    ldx       2,S                 * 3DEB AE 62          .b
                    leax      1,X                 * 3DED 30 01          0.
                    stx       2,S                 * 3DEF AF 62          /b
                    stb       -1,X                * 3DF1 E7 1F          g.
L3DF3               leau      -1,U                * 3DF3 33 5F          3_
                    pshs      U                   * 3DF5 34 40          4@
                    leax      >Y09B3,Y            * 3DF7 30 A9 09 B3    0).3
                    cmpx      ,S++                * 3DFB AC E1          ,a
                    bls       L3DE9               * 3DFD 23 EA          #j
                    clra                          * 3DFF 4F             O
                    clrb                          * 3E00 5F             _
                    stb       [<$02,S]            * 3E01 E7 F8 02       gx.
                    leax      >Y09A9,Y            * 3E04 30 A9 09 A9    0).)
                    tfr       X,D                 * 3E08 1F 10          ..
                    lbra      L3EE5               * 3E0A 16 00 D8       ..X
L3E0D               pshs      U                   * 3E0D 34 40          4@
                    ldu       6,S                 * 3E0F EE 66          nf
                    ldd       10,S                * 3E11 EC 6A          lj
                    subd      8,S                 * 3E13 A3 68          #h
                    std       10,S                * 3E15 ED 6A          mj
                    ldd       >Y09BD,Y            * 3E17 EC A9 09 BD    l).=
                    bne       L3E42               * 3E1B 26 25          &%
                    bra       L3E2A               * 3E1D 20 0B           .
L3E1F               ldd       >Y09BF,Y            * 3E1F EC A9 09 BF    l).?
                    pshs      D                   * 3E23 34 06          4.
                    jsr       [<$06,S]            * 3E25 AD F8 06       -x.
                    leas      2,S                 * 3E28 32 62          2b
L3E2A               ldd       10,S                * 3E2A EC 6A          lj
                    addd      #-1                 * 3E2C C3 FF FF       C..
                    std       10,S                * 3E2F ED 6A          mj
                    subd      #-1                 * 3E31 83 FF FF       ...
                    bgt       L3E1F               * 3E34 2E E9          .i
                    bra       L3E42               * 3E36 20 0A           .
L3E38               ldb       ,U+                 * 3E38 E6 C0          f@
                    sex                           * 3E3A 1D             .
                    pshs      D                   * 3E3B 34 06          4.
                    jsr       [<$06,S]            * 3E3D AD F8 06       -x.
                    leas      2,S                 * 3E40 32 62          2b
L3E42               ldd       8,S                 * 3E42 EC 68          lh
                    addd      #-1                 * 3E44 C3 FF FF       C..
                    std       8,S                 * 3E47 ED 68          mh
                    subd      #-1                 * 3E49 83 FF FF       ...
                    bne       L3E38               * 3E4C 26 EA          &j
                    ldd       >Y09BD,Y            * 3E4E EC A9 09 BD    l).=
                    beq       L3E6D               * 3E52 27 19          '.
                    bra       L3E61               * 3E54 20 0B           .
L3E56               ldd       >Y09BF,Y            * 3E56 EC A9 09 BF    l).?
                    pshs      D                   * 3E5A 34 06          4.
                    jsr       [<$06,S]            * 3E5C AD F8 06       -x.
                    leas      2,S                 * 3E5F 32 62          2b
L3E61               ldd       10,S                * 3E61 EC 6A          lj
                    addd      #-1                 * 3E63 C3 FF FF       C..
                    std       10,S                * 3E66 ED 6A          mj
                    subd      #-1                 * 3E68 83 FF FF       ...
                    bgt       L3E56               * 3E6B 2E E9          .i
L3E6D               puls      PC,U                * 3E6D 35 C0          5@
L3E6F               pshs      U                   * 3E6F 34 40          4@
                    ldu       6,S                 * 3E71 EE 66          nf
                    ldd       8,S                 * 3E73 EC 68          lh
                    pshs      D                   * 3E75 34 06          4.
                    pshs      U                   * 3E77 34 40          4@
                    lbsr      L4503               * 3E79 17 06 87       ...
                    leas      2,S                 * 3E7C 32 62          2b
                    nega                          * 3E7E 40             @
                    negb                          * 3E7F 50             P
                    sbca      #0                  * 3E80 82 00          ..
                    addd      ,S++                * 3E82 E3 E1          ca
                    std       8,S                 * 3E84 ED 68          mh
                    ldd       >Y09BD,Y            * 3E86 EC A9 09 BD    l).=
                    bne       L3EB1               * 3E8A 26 25          &%
                    bra       L3E99               * 3E8C 20 0B           .
L3E8E               ldd       >Y09BF,Y            * 3E8E EC A9 09 BF    l).?
                    pshs      D                   * 3E92 34 06          4.
                    jsr       [<$06,S]            * 3E94 AD F8 06       -x.
                    leas      2,S                 * 3E97 32 62          2b
L3E99               ldd       8,S                 * 3E99 EC 68          lh
                    addd      #-1                 * 3E9B C3 FF FF       C..
                    std       8,S                 * 3E9E ED 68          mh
                    subd      #-1                 * 3EA0 83 FF FF       ...
                    bgt       L3E8E               * 3EA3 2E E9          .i
                    bra       L3EB1               * 3EA5 20 0A           .
L3EA7               ldb       ,U+                 * 3EA7 E6 C0          f@
                    sex                           * 3EA9 1D             .
                    pshs      D                   * 3EAA 34 06          4.
                    jsr       [<$06,S]            * 3EAC AD F8 06       -x.
                    leas      2,S                 * 3EAF 32 62          2b
L3EB1               ldb       ,U                  * 3EB1 E6 C4          fD
                    bne       L3EA7               * 3EB3 26 F2          &r
                    ldd       >Y09BD,Y            * 3EB5 EC A9 09 BD    l).=
                    beq       L3ED4               * 3EB9 27 19          '.
                    bra       L3EC8               * 3EBB 20 0B           .
L3EBD               ldd       >Y09BF,Y            * 3EBD EC A9 09 BF    l).?
                    pshs      D                   * 3EC1 34 06          4.
                    jsr       [<$06,S]            * 3EC3 AD F8 06       -x.
                    leas      2,S                 * 3EC6 32 62          2b
L3EC8               ldd       8,S                 * 3EC8 EC 68          lh
                    addd      #-1                 * 3ECA C3 FF FF       C..
                    std       8,S                 * 3ECD ED 68          mh
                    subd      #-1                 * 3ECF 83 FF FF       ...
                    bgt       L3EBD               * 3ED2 2E E9          .i
L3ED4               puls      PC,U                * 3ED4 35 C0          5@
L3ED6               pshs      U                   * 3ED6 34 40          4@
                    ldd       >Y09A7,Y            * 3ED8 EC A9 09 A7    l).'
                    pshs      D                   * 3EDC 34 06          4.
                    ldd       6,S                 * 3EDE EC 66          lf
                    pshs      D                   * 3EE0 34 06          4.
                    lbsr      L40C2               * 3EE2 17 01 DD       ..]
L3EE5               leas      4,S                 * 3EE5 32 64          2d
                    puls      PC,U                * 3EE7 35 C0          5@
L3EE9               pshs      U                   * 3EE9 34 40          4@
                    ldd       4,S                 * 3EEB EC 64          ld
                    ldx       >Y09A7,Y            * 3EED AE A9 09 A7    .).'
                    leax      1,X                 * 3EF1 30 01          0.
                    stx       >Y09A7,Y            * 3EF3 AF A9 09 A7    /).'
                    stb       -1,X                * 3EF7 E7 1F          g.
                    puls      PC,U                * 3EF9 35 C0          5@
L3EFB               fcc       "-32768"            * 3EFB 2D 33 32 37 36 38 -32768
                    fcb       $00                 * 3F01 00             .
L3F02               pshs      U                   * 3F02 34 40          4@
                    ldu       4,S                 * 3F04 EE 64          nd
                    leas      -6,S                * 3F06 32 7A          2z
                    cmpu      #0                  * 3F08 11 83 00 00    ....
                    beq       L3F15               * 3F0C 27 07          '.
                    ldd       6,U                 * 3F0E EC 46          lF
                    clra                          * 3F10 4F             O
                    andb      #3                  * 3F11 C4 03          D.
                    bne       L3F1B               * 3F13 26 06          &.
L3F15               ldd       #-1                 * 3F15 CC FF FF       L..
                    lbra      L403E               * 3F18 16 01 23       ..#
L3F1B               ldd       6,U                 * 3F1B EC 46          lF
                    anda      #128                * 3F1D 84 80          ..
                    clrb                          * 3F1F 5F             _
                    std       -2,S                * 3F20 ED 7E          m~
                    bne       L3F2E               * 3F22 26 0A          &.
                    pshs      U                   * 3F24 34 40          4@
                    lbsr      L442A               * 3F26 17 05 01       ...
                    leas      2,S                 * 3F29 32 62          2b
                    lbra      L4004               * 3F2B 16 00 D6       ..V
L3F2E               ldd       6,U                 * 3F2E EC 46          lF
                    anda      #1                  * 3F30 84 01          ..
                    clrb                          * 3F32 5F             _
                    std       -2,S                * 3F33 ED 7E          m~
                    beq       L3F4D               * 3F35 27 16          '.
                    pshs      U                   * 3F37 34 40          4@
                    lbsr      L41EB               * 3F39 17 02 AF       ../
                    leas      2,S                 * 3F3C 32 62          2b
                    ldd       6,U                 * 3F3E EC 46          lF
                    anda      #254                * 3F40 84 FE          .~
                    std       6,U                 * 3F42 ED 46          mF
                    ldd       2,U                 * 3F44 EC 42          lB
                    addd      11,U                * 3F46 E3 4B          cK
                    std       4,U                 * 3F48 ED 44          mD
                    lbra      L4002               * 3F4A 16 00 B5       ..5
L3F4D               ldd       ,U                  * 3F4D EC C4          lD
                    cmpd      4,U                 * 3F4F 10 A3 44       .#D
                    lbcc      L4004               * 3F52 10 24 00 AE    .$..
                    leax      2,S                 * 3F56 30 62          0b
                    pshs      X                   * 3F58 34 10          4.
                    leax      14,S                * 3F5A 30 6E          0n
                    lbsr      L4636               * 3F5C 17 06 D7       ..W
                    ldx       <$10,S              * 3F5F AE E8 10       .h.
                    lbra      L3FD1               * 3F62 16 00 6C       ..l
L3F65               leax      2,S                 * 3F65 30 62          0b
                    pshs      X                   * 3F67 34 10          4.
                    ldd       2,X                 * 3F69 EC 02          l.
                    pshs      D                   * 3F6B 34 06          4.
                    ldd       ,X                  * 3F6D EC 84          l.
                    pshs      D                   * 3F6F 34 06          4.
                    pshs      U                   * 3F71 34 40          4@
                    lbsr      L4059               * 3F73 17 00 E3       ..c
                    leas      2,S                 * 3F76 32 62          2b
                    lbsr      L45BD               * 3F78 17 06 42       ..B
                    lbsr      L4636               * 3F7B 17 06 B8       ..8
L3F7E               ldd       11,U                * 3F7E EC 4B          lK
                    lbsr      L461D               * 3F80 17 06 9A       ...
                    ldd       2,X                 * 3F83 EC 02          l.
                    pshs      D                   * 3F85 34 06          4.
                    ldd       ,X                  * 3F87 EC 84          l.
                    pshs      D                   * 3F89 34 06          4.
                    leax      6,S                 * 3F8B 30 66          0f
                    ldd       2,X                 * 3F8D EC 02          l.
                    pshs      D                   * 3F8F 34 06          4.
                    ldd       ,X                  * 3F91 EC 84          l.
                    pshs      D                   * 3F93 34 06          4.
                    bsr       L3F9B               * 3F95 8D 04          ..
                    neg       <U0000              * 3F97 00 00          ..
                    neg       <U0000              * 3F99 00 00          ..
L3F9B               puls      X                   * 3F9B 35 10          5.
                    lbsr      L45D2               * 3F9D 17 06 32       ..2
                    bge       L3FA9               * 3FA0 2C 07          ,.
                    leax      6,S                 * 3FA2 30 66          0f
                    lbsr      L45F6               * 3FA4 17 06 4F       ..O
                    bra       L3FAB               * 3FA7 20 02           .
L3FA9               leax      6,S                 * 3FA9 30 66          0f
L3FAB               lbsr      L45D2               * 3FAB 17 06 24       ..$
                    blt       L3FDE               * 3FAE 2D 2E          -.
                    ldd       4,S                 * 3FB0 EC 64          ld
                    addd      ,U                  * 3FB2 E3 C4          cD
                    std       ,S                  * 3FB4 ED E4          md
                    cmpd      2,U                 * 3FB6 10 A3 42       .#B
                    bcs       L3FDE               * 3FB9 25 23          %#
                    ldd       ,S                  * 3FBB EC E4          ld
                    cmpd      4,U                 * 3FBD 10 A3 44       .#D
                    bcc       L3FDE               * 3FC0 24 1C          $.
                    ldd       ,S                  * 3FC2 EC E4          ld
                    std       ,U                  * 3FC4 ED C4          mD
                    ldd       6,U                 * 3FC6 EC 46          lF
                    andb      #239                * 3FC8 C4 EF          Do
                    std       6,U                 * 3FCA ED 46          mF
                    lbra      L403C               * 3FCC 16 00 6D       ..m
                    bra       L3FDE               * 3FCF 20 0D           .
L3FD1               stx       -2,S                * 3FD1 AF 7E          /~
                    lbeq      L3F65               * 3FD3 10 27 FF 8E    .'..
                    cmpx      #1                  * 3FD7 8C 00 01       ...
                    lbeq      L3F7E               * 3FDA 10 27 FF A0    .'.
L3FDE               ldd       <$10,S              * 3FDE EC E8 10       lh.
                    cmpd      #1                  * 3FE1 10 83 00 01    ....
                    bne       L4000               * 3FE5 26 19          &.
                    leax      12,S                * 3FE7 30 6C          0l
                    pshs      X                   * 3FE9 34 10          4.
                    ldd       2,X                 * 3FEB EC 02          l.
                    pshs      D                   * 3FED 34 06          4.
                    ldd       ,X                  * 3FEF EC 84          l.
                    pshs      D                   * 3FF1 34 06          4.
                    ldd       4,U                 * 3FF3 EC 44          lD
                    subd      ,U                  * 3FF5 A3 C4          #D
                    lbsr      L461D               * 3FF7 17 06 23       ..#
                    lbsr      L45BD               * 3FFA 17 05 C0       ..@
                    lbsr      L4636               * 3FFD 17 06 36       ..6
L4000               ldd       4,U                 * 4000 EC 44          lD
L4002               std       ,U                  * 4002 ED C4          mD
L4004               ldd       6,U                 * 4004 EC 46          lF
                    andb      #239                * 4006 C4 EF          Do
                    std       6,U                 * 4008 ED 46          mF
                    ldd       <$10,S              * 400A EC E8 10       lh.
                    pshs      D                   * 400D 34 06          4.
                    leax      14,S                * 400F 30 6E          0n
                    ldd       2,X                 * 4011 EC 02          l.
                    pshs      D                   * 4013 34 06          4.
                    ldd       ,X                  * 4015 EC 84          l.
                    pshs      D                   * 4017 34 06          4.
                    ldd       8,U                 * 4019 EC 48          lH
                    pshs      D                   * 401B 34 06          4.
                    lbsr      lseek               * 401D 17 08 E7       ..g
                    leas      8,S                 * 4020 32 68          2h
                    ldd       2,X                 * 4022 EC 02          l.
                    pshs      D                   * 4024 34 06          4.
                    ldd       ,X                  * 4026 EC 84          l.
                    pshs      D                   * 4028 34 06          4.
                    bsr       L4030               * 402A 8D 04          ..
                    stu       >-1                 * 402C FF FF FF       ...
                    fcb       $FF                 * 402F FF             .
L4030               puls      X                   * 4030 35 10          5.
                    lbsr      L45D2               * 4032 17 05 9D       ...
                    bne       L403C               * 4035 26 05          &.
                    ldd       #-1                 * 4037 CC FF FF       L..
                    bra       L403E               * 403A 20 02           .
L403C               clra                          * 403C 4F             O
                    clrb                          * 403D 5F             _
L403E               leas      6,S                 * 403E 32 66          2f
                    puls      PC,U                * 4040 35 C0          5@
L4042               pshs      U                   * 4042 34 40          4@
                    clra                          * 4044 4F             O
                    clrb                          * 4045 5F             _
                    pshs      D                   * 4046 34 06          4.
                    clra                          * 4048 4F             O
                    clrb                          * 4049 5F             _
                    pshs      D                   * 404A 34 06          4.
                    pshs      D                   * 404C 34 06          4.
                    ldd       10,S                * 404E EC 6A          lj
                    pshs      D                   * 4050 34 06          4.
                    lbsr      L3F02               * 4052 17 FE AD       .~-
                    leas      8,S                 * 4055 32 68          2h
                    puls      PC,U                * 4057 35 C0          5@
L4059               pshs      U                   * 4059 34 40          4@
                    ldu       4,S                 * 405B EE 64          nd
                    beq       L4066               * 405D 27 07          '.
                    ldd       6,U                 * 405F EC 46          lF
                    clra                          * 4061 4F             O
                    andb      #3                  * 4062 C4 03          D.
                    bne       L4079               * 4064 26 13          &.
L4066               bsr       L406C               * 4066 8D 04          ..
                    stu       >-1                 * 4068 FF FF FF       ...
                    fcb       $FF                 * 406B FF             .
L406C               puls      X                   * 406C 35 10          5.
                    leau      >Y059B,Y            * 406E 33 A9 05 9B    3)..
                    pshs      U                   * 4072 34 40          4@
                    lbsr      L4636               * 4074 17 05 BF       ..?
                    puls      PC,U                * 4077 35 C0          5@
L4079               ldd       6,U                 * 4079 EC 46          lF
                    anda      #128                * 407B 84 80          ..
                    clrb                          * 407D 5F             _
                    std       -2,S                * 407E ED 7E          m~
                    bne       L4089               * 4080 26 07          &.
                    pshs      U                   * 4082 34 40          4@
                    lbsr      L442A               * 4084 17 03 A3       ..#
                    leas      2,S                 * 4087 32 62          2b
L4089               ldd       #1                  * 4089 CC 00 01       L..
                    pshs      D                   * 408C 34 06          4.
                    clra                          * 408E 4F             O
                    clrb                          * 408F 5F             _
                    pshs      D                   * 4090 34 06          4.
                    pshs      D                   * 4092 34 06          4.
                    ldd       8,U                 * 4094 EC 48          lH
                    pshs      D                   * 4096 34 06          4.
                    lbsr      lseek               * 4098 17 08 6C       ..l
                    leas      8,S                 * 409B 32 68          2h
                    ldd       2,X                 * 409D EC 02          l.
                    pshs      D                   * 409F 34 06          4.
                    ldd       ,X                  * 40A1 EC 84          l.
                    pshs      D                   * 40A3 34 06          4.
                    ldd       6,U                 * 40A5 EC 46          lF
                    anda      #1                  * 40A7 84 01          ..
                    clrb                          * 40A9 5F             _
                    std       -2,S                * 40AA ED 7E          m~
                    beq       L40B2               * 40AC 27 04          '.
                    ldd       2,U                 * 40AE EC 42          lB
                    bra       L40B4               * 40B0 20 02           .
L40B2               ldd       4,U                 * 40B2 EC 44          lD
L40B4               pshs      D                   * 40B4 34 06          4.
                    ldd       ,U                  * 40B6 EC C4          lD
                    subd      ,S++                * 40B8 A3 E1          #a
                    lbsr      L461D               * 40BA 17 05 60       ..`
                    lbsr      L45A8               * 40BD 17 04 E8       ..h
                    puls      PC,U                * 40C0 35 C0          5@
L40C2               pshs      U                   * 40C2 34 40          4@
                    ldu       6,S                 * 40C4 EE 66          nf
                    ldd       6,U                 * 40C6 EC 46          lF
                    anda      #128                * 40C8 84 80          ..
                    andb      #34                 * 40CA C4 22          D"
                    cmpd      #-32766             * 40CC 10 83 80 02    ....
                    beq       L40E6               * 40D0 27 14          '.
                    ldd       6,U                 * 40D2 EC 46          lF
                    clra                          * 40D4 4F             O
                    andb      #34                 * 40D5 C4 22          D"
                    cmpd      #2                  * 40D7 10 83 00 02    ....
                    lbne      L41FC               * 40DB 10 26 01 1D    .&..
                    pshs      U                   * 40DF 34 40          4@
                    lbsr      L442A               * 40E1 17 03 46       ..F
                    leas      2,S                 * 40E4 32 62          2b
L40E6               ldd       6,U                 * 40E6 EC 46          lF
                    clra                          * 40E8 4F             O
                    andb      #4                  * 40E9 C4 04          D.
                    beq       L4122               * 40EB 27 35          '5
                    ldd       #1                  * 40ED CC 00 01       L..
                    pshs      D                   * 40F0 34 06          4.
                    leax      7,S                 * 40F2 30 67          0g
                    pshs      X                   * 40F4 34 10          4.
                    ldd       8,U                 * 40F6 EC 48          lH
                    pshs      D                   * 40F8 34 06          4.
                    ldd       6,U                 * 40FA EC 46          lF
                    clra                          * 40FC 4F             O
                    andb      #64                 * 40FD C4 40          D@
                    beq       L4107               * 40FF 27 06          '.
                    leax      >L48F7,PC           * 4101 30 8D 07 F2    0..r
                    bra       L410B               * 4105 20 04           .
L4107               leax      >L48DE,PC           * 4107 30 8D 07 D3    0..S
L410B               tfr       X,D                 * 410B 1F 10          ..
                    tfr       D,X                 * 410D 1F 01          ..
                    jsr       ,X                  * 410F AD 84          -.
                    leas      6,S                 * 4111 32 66          2f
                    cmpd      #-1                 * 4113 10 83 FF FF    ....
                    bne       L4163               * 4117 26 4A          &J
                    ldd       6,U                 * 4119 EC 46          lF
                    orb       #32                 * 411B CA 20          J
                    std       6,U                 * 411D ED 46          mF
                    lbra      L41FC               * 411F 16 00 DA       ..Z
L4122               ldd       6,U                 * 4122 EC 46          lF
                    anda      #1                  * 4124 84 01          ..
                    clrb                          * 4126 5F             _
                    std       -2,S                * 4127 ED 7E          m~
                    bne       L4132               * 4129 26 07          &.
                    pshs      U                   * 412B 34 40          4@
                    lbsr      L4217               * 412D 17 00 E7       ..g
                    leas      2,S                 * 4130 32 62          2b
L4132               ldd       ,U                  * 4132 EC C4          lD
                    addd      #1                  * 4134 C3 00 01       C..
                    std       ,U                  * 4137 ED C4          mD
                    subd      #1                  * 4139 83 00 01       ...
                    tfr       D,X                 * 413C 1F 01          ..
                    ldd       4,S                 * 413E EC 64          ld
                    stb       ,X                  * 4140 E7 84          g.
                    ldd       ,U                  * 4142 EC C4          lD
                    cmpd      4,U                 * 4144 10 A3 44       .#D
                    bcc       L4158               * 4147 24 0F          $.
                    ldd       6,U                 * 4149 EC 46          lF
                    clra                          * 414B 4F             O
                    andb      #64                 * 414C C4 40          D@
                    beq       L4163               * 414E 27 13          '.
                    ldd       4,S                 * 4150 EC 64          ld
                    cmpd      #13                 * 4152 10 83 00 0D    ....
                    bne       L4163               * 4156 26 0B          &.
L4158               pshs      U                   * 4158 34 40          4@
                    lbsr      L4217               * 415A 17 00 BA       ..:
                    std       ,S++                * 415D ED E1          ma
                    lbne      L41FC               * 415F 10 26 00 99    .&..
L4163               ldd       4,S                 * 4163 EC 64          ld
                    puls      PC,U                * 4165 35 C0          5@
                    pshs      U                   * 4167 34 40          4@
                    ldu       4,S                 * 4169 EE 64          nd
                    ldd       6,S                 * 416B EC 66          lf
                    pshs      D                   * 416D 34 06          4.
                    pshs      U                   * 416F 34 40          4@
                    ldd       #8                  * 4171 CC 00 08       L..
                    lbsr      L4794               * 4174 17 06 1D       ...
                    pshs      D                   * 4177 34 06          4.
                    lbsr      L40C2               * 4179 17 FF 46       ..F
                    leas      4,S                 * 417C 32 64          2d
                    ldd       6,S                 * 417E EC 66          lf
                    pshs      D                   * 4180 34 06          4.
                    pshs      U                   * 4182 34 40          4@
                    lbsr      L40C2               * 4184 17 FF 3B       ..;
                    lbra      L42D1               * 4187 16 01 47       ..G
_tidyup             pshs      U,D                 * 418A 34 46          4F
                    leau      >_iob,Y             * 418C 33 A9 04 89    3)..
                    clra                          * 4190 4F             O
                    clrb                          * 4191 5F             _
                    std       ,S                  * 4192 ED E4          md
                    bra       L41A0               * 4194 20 0A           .
L4196               tfr       U,D                 * 4196 1F 30          .0
                    leau      13,U                * 4198 33 4D          3M
                    pshs      D                   * 419A 34 06          4.
                    bsr       fclose              * 419C 8D 14          ..
                    leas      2,S                 * 419E 32 62          2b
L41A0               ldd       ,S                  * 41A0 EC E4          ld
                    addd      #1                  * 41A2 C3 00 01       C..
                    std       ,S                  * 41A5 ED E4          md
                    subd      #1                  * 41A7 83 00 01       ...
                    cmpd      #16                 * 41AA 10 83 00 10    ....
                    blt       L4196               * 41AE 2D E6          -f
                    puls      PC,U,X              * 41B0 35 D0          5P
fclose              pshs      U                   * 41B2 34 40          4@
                    ldu       4,S                 * 41B4 EE 64          nd
                    leas      -2,S                * 41B6 32 7E          2~
                    cmpu      #0                  * 41B8 11 83 00 00    ....
                    beq       L41C2               * 41BC 27 04          '.
                    ldd       6,U                 * 41BE EC 46          lF
                    bne       L41C7               * 41C0 26 05          &.
L41C2               ldd       #-1                 * 41C2 CC FF FF       L..
                    puls      PC,U,X              * 41C5 35 D0          5P
L41C7               ldd       6,U                 * 41C7 EC 46          lF
                    clra                          * 41C9 4F             O
                    andb      #2                  * 41CA C4 02          D.
                    beq       L41D6               * 41CC 27 08          '.
                    pshs      U                   * 41CE 34 40          4@
                    bsr       L41EB               * 41D0 8D 19          ..
                    leas      2,S                 * 41D2 32 62          2b
                    bra       L41D8               * 41D4 20 02           .
L41D6               clra                          * 41D6 4F             O
                    clrb                          * 41D7 5F             _
L41D8               std       ,S                  * 41D8 ED E4          md
                    ldd       8,U                 * 41DA EC 48          lH
                    pshs      D                   * 41DC 34 06          4.
                    lbsr      close               * 41DE 17 06 63       ..c
                    leas      2,S                 * 41E1 32 62          2b
                    clra                          * 41E3 4F             O
                    clrb                          * 41E4 5F             _
                    std       6,U                 * 41E5 ED 46          mF
                    ldd       ,S                  * 41E7 EC E4          ld
                    puls      PC,U,X              * 41E9 35 D0          5P
L41EB               pshs      U                   * 41EB 34 40          4@
                    ldu       4,S                 * 41ED EE 64          nd
                    beq       L41FC               * 41EF 27 0B          '.
                    ldd       6,U                 * 41F1 EC 46          lF
                    clra                          * 41F3 4F             O
                    andb      #34                 * 41F4 C4 22          D"
                    cmpd      #2                  * 41F6 10 83 00 02    ....
                    beq       L4201               * 41FA 27 05          '.
L41FC               ldd       #-1                 * 41FC CC FF FF       L..
                    puls      PC,U                * 41FF 35 C0          5@
L4201               ldd       6,U                 * 4201 EC 46          lF
                    anda      #128                * 4203 84 80          ..
                    clrb                          * 4205 5F             _
                    std       -2,S                * 4206 ED 7E          m~
                    bne       L4211               * 4208 26 07          &.
                    pshs      U                   * 420A 34 40          4@
                    lbsr      L442A               * 420C 17 02 1B       ...
                    leas      2,S                 * 420F 32 62          2b
L4211               pshs      U                   * 4211 34 40          4@
                    bsr       L4217               * 4213 8D 02          ..
                    puls      PC,U,X              * 4215 35 D0          5P
L4217               pshs      U                   * 4217 34 40          4@
                    ldu       4,S                 * 4219 EE 64          nd
                    leas      -4,S                * 421B 32 7C          2|
                    ldd       6,U                 * 421D EC 46          lF
                    anda      #1                  * 421F 84 01          ..
                    clrb                          * 4221 5F             _
                    std       -2,S                * 4222 ED 7E          m~
                    bne       L4249               * 4224 26 23          &#
                    ldd       ,U                  * 4226 EC C4          lD
                    cmpd      4,U                 * 4228 10 A3 44       .#D
                    beq       L4249               * 422B 27 1C          '.
                    clra                          * 422D 4F             O
                    clrb                          * 422E 5F             _
                    pshs      D                   * 422F 34 06          4.
                    pshs      U                   * 4231 34 40          4@
                    lbsr      L4059               * 4233 17 FE 23       .~#
                    leas      2,S                 * 4236 32 62          2b
                    ldd       2,X                 * 4238 EC 02          l.
                    pshs      D                   * 423A 34 06          4.
                    ldd       ,X                  * 423C EC 84          l.
                    pshs      D                   * 423E 34 06          4.
                    ldd       8,U                 * 4240 EC 48          lH
                    pshs      D                   * 4242 34 06          4.
                    lbsr      lseek               * 4244 17 06 C0       ..@
                    leas      8,S                 * 4247 32 68          2h
L4249               ldd       ,U                  * 4249 EC C4          lD
                    subd      2,U                 * 424B A3 42          #B
                    std       2,S                 * 424D ED 62          mb
                    lbeq      L42C1               * 424F 10 27 00 6E    .'.n
                    ldd       6,U                 * 4253 EC 46          lF
                    anda      #1                  * 4255 84 01          ..
                    clrb                          * 4257 5F             _
                    std       -2,S                * 4258 ED 7E          m~
                    lbeq      L42C1               * 425A 10 27 00 63    .'.c
                    ldd       6,U                 * 425E EC 46          lF
                    clra                          * 4260 4F             O
                    andb      #64                 * 4261 C4 40          D@
                    beq       L4298               * 4263 27 33          '3
                    ldd       2,U                 * 4265 EC 42          lB
                    bra       L4290               * 4267 20 27           '
L4269               ldd       2,S                 * 4269 EC 62          lb
                    pshs      D                   * 426B 34 06          4.
                    ldd       ,U                  * 426D EC C4          lD
                    pshs      D                   * 426F 34 06          4.
                    ldd       8,U                 * 4271 EC 48          lH
                    pshs      D                   * 4273 34 06          4.
                    lbsr      L48F7               * 4275 17 06 7F       ...
                    leas      6,S                 * 4278 32 66          2f
                    std       ,S                  * 427A ED E4          md
                    cmpd      #-1                 * 427C 10 83 FF FF    ....
                    bne       L4286               * 4280 26 04          &.
                    leax      4,S                 * 4282 30 64          0d
                    bra       L42B0               * 4284 20 2A           *
L4286               ldd       2,S                 * 4286 EC 62          lb
                    subd      ,S                  * 4288 A3 E4          #d
                    std       2,S                 * 428A ED 62          mb
                    ldd       ,U                  * 428C EC C4          lD
                    addd      ,S                  * 428E E3 E4          cd
L4290               std       ,U                  * 4290 ED C4          mD
                    ldd       2,S                 * 4292 EC 62          lb
                    bne       L4269               * 4294 26 D3          &S
                    bra       L42C1               * 4296 20 29           )
L4298               ldd       2,S                 * 4298 EC 62          lb
                    pshs      D                   * 429A 34 06          4.
                    ldd       2,U                 * 429C EC 42          lB
                    pshs      D                   * 429E 34 06          4.
                    ldd       8,U                 * 42A0 EC 48          lH
                    pshs      D                   * 42A2 34 06          4.
                    lbsr      L48DE               * 42A4 17 06 37       ..7
                    leas      6,S                 * 42A7 32 66          2f
                    cmpd      2,S                 * 42A9 10 A3 62       .#b
                    beq       L42C1               * 42AC 27 13          '.
                    bra       L42B2               * 42AE 20 02           .
L42B0               leas      -4,X                * 42B0 32 1C          2.
L42B2               ldd       6,U                 * 42B2 EC 46          lF
                    orb       #32                 * 42B4 CA 20          J
                    std       6,U                 * 42B6 ED 46          mF
                    ldd       4,U                 * 42B8 EC 44          lD
                    std       ,U                  * 42BA ED C4          mD
                    ldd       #-1                 * 42BC CC FF FF       L..
                    bra       L42D1               * 42BF 20 10           .
L42C1               ldd       6,U                 * 42C1 EC 46          lF
                    ora       #1                  * 42C3 8A 01          ..
                    std       6,U                 * 42C5 ED 46          mF
                    ldd       2,U                 * 42C7 EC 42          lB
                    std       ,U                  * 42C9 ED C4          mD
                    addd      11,U                * 42CB E3 4B          cK
                    std       4,U                 * 42CD ED 44          mD
                    clra                          * 42CF 4F             O
                    clrb                          * 42D0 5F             _
L42D1               leas      4,S                 * 42D1 32 64          2d
                    puls      PC,U                * 42D3 35 C0          5@
L42D5               pshs      U                   * 42D5 34 40          4@
                    ldu       4,S                 * 42D7 EE 64          nd
                    beq       L4321               * 42D9 27 46          'F
                    ldd       6,U                 * 42DB EC 46          lF
                    anda      #1                  * 42DD 84 01          ..
                    clrb                          * 42DF 5F             _
                    std       -2,S                * 42E0 ED 7E          m~
                    bne       L4321               * 42E2 26 3D          &=
                    ldd       ,U                  * 42E4 EC C4          lD
                    cmpd      4,U                 * 42E6 10 A3 44       .#D
                    bcc       L42FC               * 42E9 24 11          $.
                    ldd       ,U                  * 42EB EC C4          lD
                    addd      #1                  * 42ED C3 00 01       C..
                    std       ,U                  * 42F0 ED C4          mD
                    subd      #1                  * 42F2 83 00 01       ...
                    tfr       D,X                 * 42F5 1F 01          ..
                    ldb       ,X                  * 42F7 E6 84          f.
                    clra                          * 42F9 4F             O
                    bra       L4303               * 42FA 20 07           .
L42FC               pshs      U                   * 42FC 34 40          4@
                    lbsr      L4370               * 42FE 17 00 6F       ..o
                    leas      2,S                 * 4301 32 62          2b
L4303               puls      PC,U                * 4303 35 C0          5@
                    pshs      U                   * 4305 34 40          4@
                    ldu       6,S                 * 4307 EE 66          nf
                    beq       L4321               * 4309 27 16          '.
                    ldd       6,U                 * 430B EC 46          lF
                    clra                          * 430D 4F             O
                    andb      #1                  * 430E C4 01          D.
                    beq       L4321               * 4310 27 0F          '.
                    ldd       4,S                 * 4312 EC 64          ld
                    cmpd      #-1                 * 4314 10 83 FF FF    ....
                    beq       L4321               * 4318 27 07          '.
                    ldd       ,U                  * 431A EC C4          lD
                    cmpd      2,U                 * 431C 10 A3 42       .#B
                    bhi       L4326               * 431F 22 05          ".
L4321               ldd       #-1                 * 4321 CC FF FF       L..
                    puls      PC,U                * 4324 35 C0          5@
L4326               ldd       ,U                  * 4326 EC C4          lD
                    addd      #-1                 * 4328 C3 FF FF       C..
                    std       ,U                  * 432B ED C4          mD
                    tfr       D,X                 * 432D 1F 01          ..
                    ldd       4,S                 * 432F EC 64          ld
                    stb       ,X                  * 4331 E7 84          g.
                    ldd       4,S                 * 4333 EC 64          ld
                    puls      PC,U                * 4335 35 C0          5@
                    pshs      U                   * 4337 34 40          4@
                    ldu       4,S                 * 4339 EE 64          nd
                    leas      -4,S                * 433B 32 7C          2|
                    pshs      U                   * 433D 34 40          4@
                    lbsr      L42D5               * 433F 17 FF 93       ...
                    leas      2,S                 * 4342 32 62          2b
                    std       2,S                 * 4344 ED 62          mb
                    cmpd      #-1                 * 4346 10 83 FF FF    ....
                    beq       L435B               * 434A 27 0F          '.
                    pshs      U                   * 434C 34 40          4@
                    lbsr      L42D5               * 434E 17 FF 84       ...
                    leas      2,S                 * 4351 32 62          2b
                    std       ,S                  * 4353 ED E4          md
                    cmpd      #-1                 * 4355 10 83 FF FF    ....
                    bne       L4360               * 4359 26 05          &.
L435B               ldd       #-1                 * 435B CC FF FF       L..
                    bra       L436C               * 435E 20 0C           .
L4360               ldd       2,S                 * 4360 EC 62          lb
                    pshs      D                   * 4362 34 06          4.
                    ldd       #8                  * 4364 CC 00 08       L..
                    lbsr      L47AB               * 4367 17 04 41       ..A
                    addd      ,S                  * 436A E3 E4          cd
L436C               leas      4,S                 * 436C 32 64          2d
                    puls      PC,U                * 436E 35 C0          5@
L4370               pshs      U                   * 4370 34 40          4@
                    ldu       4,S                 * 4372 EE 64          nd
                    leas      -2,S                * 4374 32 7E          2~
                    ldd       6,U                 * 4376 EC 46          lF
                    anda      #128                * 4378 84 80          ..
                    andb      #49                 * 437A C4 31          D1
                    cmpd      #-32767             * 437C 10 83 80 01    ....
                    beq       L4399               * 4380 27 17          '.
                    ldd       6,U                 * 4382 EC 46          lF
                    clra                          * 4384 4F             O
                    andb      #49                 * 4385 C4 31          D1
                    cmpd      #1                  * 4387 10 83 00 01    ....
                    beq       L4392               * 438B 27 05          '.
                    ldd       #-1                 * 438D CC FF FF       L..
                    puls      PC,U,X              * 4390 35 D0          5P
L4392               pshs      U                   * 4392 34 40          4@
                    lbsr      L442A               * 4394 17 00 93       ...
                    leas      2,S                 * 4397 32 62          2b
L4399               leax      >_iob,Y             * 4399 30 A9 04 89    0)..
                    pshs      X                   * 439D 34 10          4.
                    cmpu      ,S++                * 439F 11 A3 E1       .#a
                    bne       L43B6               * 43A2 26 12          &.
                    ldd       6,U                 * 43A4 EC 46          lF
                    clra                          * 43A6 4F             O
                    andb      #64                 * 43A7 C4 40          D@
                    beq       L43B6               * 43A9 27 0B          '.
                    leax      >Y0496,Y            * 43AB 30 A9 04 96    0)..
                    pshs      X                   * 43AF 34 10          4.
                    lbsr      L41EB               * 43B1 17 FE 37       .~7
                    leas      2,S                 * 43B4 32 62          2b
L43B6               ldd       6,U                 * 43B6 EC 46          lF
                    clra                          * 43B8 4F             O
                    andb      #8                  * 43B9 C4 08          D.
                    beq       L43E2               * 43BB 27 25          '%
                    ldd       11,U                * 43BD EC 4B          lK
                    pshs      D                   * 43BF 34 06          4.
                    ldd       2,U                 * 43C1 EC 42          lB
                    pshs      D                   * 43C3 34 06          4.
                    ldd       8,U                 * 43C5 EC 48          lH
                    pshs      D                   * 43C7 34 06          4.
                    ldd       6,U                 * 43C9 EC 46          lF
                    clra                          * 43CB 4F             O
                    andb      #64                 * 43CC C4 40          D@
                    beq       L43D6               * 43CE 27 06          '.
                    leax      >L48CE,PC           * 43D0 30 8D 04 FA    0..z
                    bra       L43DA               * 43D4 20 04           .
L43D6               leax      >L48AD,PC           * 43D6 30 8D 04 D3    0..S
L43DA               tfr       X,D                 * 43DA 1F 10          ..
                    tfr       D,X                 * 43DC 1F 01          ..
                    jsr       ,X                  * 43DE AD 84          -.
                    bra       L43F4               * 43E0 20 12           .
L43E2               ldd       #1                  * 43E2 CC 00 01       L..
                    pshs      D                   * 43E5 34 06          4.
                    leax      10,U                * 43E7 30 4A          0J
                    stx       2,U                 * 43E9 AF 42          /B
                    pshs      X                   * 43EB 34 10          4.
                    ldd       8,U                 * 43ED EC 48          lH
                    pshs      D                   * 43EF 34 06          4.
                    lbsr      L48AD               * 43F1 17 04 B9       ..9
L43F4               leas      6,S                 * 43F4 32 66          2f
                    std       ,S                  * 43F6 ED E4          md
                    ldd       ,S                  * 43F8 EC E4          ld
                    bgt       L4417               * 43FA 2E 1B          ..
                    ldd       6,U                 * 43FC EC 46          lF
                    pshs      D                   * 43FE 34 06          4.
                    ldd       2,S                 * 4400 EC 62          lb
                    beq       L4409               * 4402 27 05          '.
                    ldd       #32                 * 4404 CC 00 20       L.
                    bra       L440C               * 4407 20 03           .
L4409               ldd       #16                 * 4409 CC 00 10       L..
L440C               ora       ,S+                 * 440C AA E0          *`
                    orb       ,S+                 * 440E EA E0          j`
                    std       6,U                 * 4410 ED 46          mF
                    ldd       #-1                 * 4412 CC FF FF       L..
                    puls      PC,U,X              * 4415 35 D0          5P
L4417               ldd       2,U                 * 4417 EC 42          lB
                    addd      #1                  * 4419 C3 00 01       C..
                    std       ,U                  * 441C ED C4          mD
                    ldd       2,U                 * 441E EC 42          lB
                    addd      ,S                  * 4420 E3 E4          cd
                    std       4,U                 * 4422 ED 44          mD
                    ldb       [<$02,U]            * 4424 E6 D8 02       fX.
                    clra                          * 4427 4F             O
                    puls      PC,U,X              * 4428 35 D0          5P
L442A               pshs      U                   * 442A 34 40          4@
                    ldu       4,S                 * 442C EE 64          nd
                    ldd       6,U                 * 442E EC 46          lF
                    clra                          * 4430 4F             O
                    andb      #192                * 4431 C4 C0          D@
                    bne       L4462               * 4433 26 2D          &-
                    leas      <-$20,S             * 4435 32 E8 E0       2h`
                    leax      ,S                  * 4438 30 E4          0d
                    pshs      X                   * 443A 34 10          4.
                    ldd       8,U                 * 443C EC 48          lH
                    pshs      D                   * 443E 34 06          4.
                    clra                          * 4440 4F             O
                    clrb                          * 4441 5F             _
                    pshs      D                   * 4442 34 06          4.
                    lbsr      L47C6               * 4444 17 03 7F       ...
                    leas      6,S                 * 4447 32 66          2f
                    ldd       6,U                 * 4449 EC 46          lF
                    pshs      D                   * 444B 34 06          4.
                    ldb       2,S                 * 444D E6 62          fb
                    bne       L4456               * 444F 26 05          &.
                    ldd       #64                 * 4451 CC 00 40       L.@
                    bra       L4459               * 4454 20 03           .
L4456               ldd       #128                * 4456 CC 00 80       L..
L4459               ora       ,S+                 * 4459 AA E0          *`
                    orb       ,S+                 * 445B EA E0          j`
                    std       6,U                 * 445D ED 46          mF
                    leas      <$20,S              * 445F 32 E8 20       2h
L4462               ldd       6,U                 * 4462 EC 46          lF
                    ora       #128                * 4464 8A 80          ..
                    std       6,U                 * 4466 ED 46          mF
                    clra                          * 4468 4F             O
                    andb      #12                 * 4469 C4 0C          D.
                    beq       L446F               * 446B 27 02          '.
                    puls      PC,U                * 446D 35 C0          5@
L446F               ldd       11,U                * 446F EC 4B          lK
                    bne       L4484               * 4471 26 11          &.
                    ldd       6,U                 * 4473 EC 46          lF
                    clra                          * 4475 4F             O
                    andb      #64                 * 4476 C4 40          D@
                    beq       L447F               * 4478 27 05          '.
                    ldd       #128                * 447A CC 00 80       L..
                    bra       L4482               * 447D 20 03           .
L447F               ldd       #256                * 447F CC 01 00       L..
L4482               std       11,U                * 4482 ED 4B          mK
L4484               ldd       2,U                 * 4484 EC 42          lB
                    bne       L4499               * 4486 26 11          &.
                    ldd       11,U                * 4488 EC 4B          lK
                    pshs      D                   * 448A 34 06          4.
                    lbsr      L49C5               * 448C 17 05 36       ..6
                    leas      2,S                 * 448F 32 62          2b
                    std       2,U                 * 4491 ED 42          mB
                    cmpd      #-1                 * 4493 10 83 FF FF    ....
                    beq       L44A1               * 4497 27 08          '.
L4499               ldd       6,U                 * 4499 EC 46          lF
                    orb       #8                  * 449B CA 08          J.
                    std       6,U                 * 449D ED 46          mF
                    bra       L44B0               * 449F 20 0F           .
L44A1               ldd       6,U                 * 44A1 EC 46          lF
                    orb       #4                  * 44A3 CA 04          J.
                    std       6,U                 * 44A5 ED 46          mF
                    leax      10,U                * 44A7 30 4A          0J
                    stx       2,U                 * 44A9 AF 42          /B
                    ldd       #1                  * 44AB CC 00 01       L..
                    std       11,U                * 44AE ED 4B          mK
L44B0               ldd       2,U                 * 44B0 EC 42          lB
                    addd      11,U                * 44B2 E3 4B          cK
                    std       4,U                 * 44B4 ED 44          mD
                    std       ,U                  * 44B6 ED C4          mD
                    puls      PC,U                * 44B8 35 C0          5@
L44BA               pshs      U                   * 44BA 34 40          4@
                    ldb       5,S                 * 44BC E6 65          fe
                    sex                           * 44BE 1D             .
                    tfr       D,X                 * 44BF 1F 01          ..
                    bra       L44E0               * 44C1 20 1D           .
L44C3               ldd       [<$06,S]            * 44C3 EC F8 06       lx.
                    addd      #4                  * 44C6 C3 00 04       C..
                    std       [<$06,S]            * 44C9 ED F8 06       mx.
                    leax      >L44F7,PC           * 44CC 30 8D 00 27    0..'
                    bra       L44DC               * 44D0 20 0A           .
L44D2               ldb       5,S                 * 44D2 E6 65          fe
                    stb       >Y0487,Y            * 44D4 E7 A9 04 87    g)..
                    leax      >Y0486,Y            * 44D8 30 A9 04 86    0)..
L44DC               tfr       X,D                 * 44DC 1F 10          ..
                    puls      PC,U                * 44DE 35 C0          5@
L44E0               cmpx      #100                * 44E0 8C 00 64       ..d
                    beq       L44C3               * 44E3 27 DE          '^
                    cmpx      #111                * 44E5 8C 00 6F       ..o
                    lbeq      L44C3               * 44E8 10 27 FF D7    .'.W
                    cmpx      #120                * 44EC 8C 00 78       ..x
                    lbeq      L44C3               * 44EF 10 27 FF D0    .'.P
                    bra       L44D2               * 44F3 20 DD           ]
                    puls      PC,U                * 44F5 35 C0          5@
L44F7               fcb       $00                 * 44F7 00             .
L44F8               pshs      U                   * 44F8 34 40          4@
                    leax      >L4502,PC           * 44FA 30 8D 00 04    0...
                    tfr       X,D                 * 44FE 1F 10          ..
                    puls      PC,U                * 4500 35 C0          5@
L4502               fcb       $00                 * 4502 00             .
L4503               pshs      U                   * 4503 34 40          4@
                    ldu       4,S                 * 4505 EE 64          nd
L4507               ldb       ,U+                 * 4507 E6 C0          f@
                    bne       L4507               * 4509 26 FC          &|
                    tfr       U,D                 * 450B 1F 30          .0
                    subd      4,S                 * 450D A3 64          #d
                    addd      #-1                 * 450F C3 FF FF       C..
                    puls      PC,U                * 4512 35 C0          5@
L4514               pshs      U                   * 4514 34 40          4@
                    ldu       6,S                 * 4516 EE 66          nf
                    leas      -2,S                * 4518 32 7E          2~
                    ldd       6,S                 * 451A EC 66          lf
                    std       ,S                  * 451C ED E4          md
L451E               ldb       ,U+                 * 451E E6 C0          f@
                    ldx       ,S                  * 4520 AE E4          .d
                    leax      1,X                 * 4522 30 01          0.
                    stx       ,S                  * 4524 AF E4          /d
                    stb       -1,X                * 4526 E7 1F          g.
                    bne       L451E               * 4528 26 F4          &t
                    ldd       6,S                 * 452A EC 66          lf
                    puls      PC,U,X              * 452C 35 D0          5P
                    pshs      U                   * 452E 34 40          4@
                    ldu       6,S                 * 4530 EE 66          nf
                    leas      -2,S                * 4532 32 7E          2~
                    ldd       6,S                 * 4534 EC 66          lf
                    std       ,S                  * 4536 ED E4          md
L4538               ldx       ,S                  * 4538 AE E4          .d
                    leax      1,X                 * 453A 30 01          0.
                    stx       ,S                  * 453C AF E4          /d
                    ldb       -1,X                * 453E E6 1F          f.
                    bne       L4538               * 4540 26 F6          &v
                    ldd       ,S                  * 4542 EC E4          ld
                    addd      #-1                 * 4544 C3 FF FF       C..
                    std       ,S                  * 4547 ED E4          md
L4549               ldb       ,U+                 * 4549 E6 C0          f@
                    ldx       ,S                  * 454B AE E4          .d
                    leax      1,X                 * 454D 30 01          0.
                    stx       ,S                  * 454F AF E4          /d
                    stb       -1,X                * 4551 E7 1F          g.
                    bne       L4549               * 4553 26 F4          &t
                    ldd       6,S                 * 4555 EC 66          lf
                    puls      PC,U,X              * 4557 35 D0          5P
L4559               pshs      U                   * 4559 34 40          4@
                    ldu       4,S                 * 455B EE 64          nd
                    bra       L456F               * 455D 20 10           .
L455F               ldx       6,S                 * 455F AE 66          .f
                    leax      1,X                 * 4561 30 01          0.
                    stx       6,S                 * 4563 AF 66          /f
                    ldb       -1,X                * 4565 E6 1F          f.
                    bne       L456D               * 4567 26 04          &.
                    clra                          * 4569 4F             O
                    clrb                          * 456A 5F             _
                    puls      PC,U                * 456B 35 C0          5@
L456D               leau      1,U                 * 456D 33 41          3A
L456F               ldb       ,U                  * 456F E6 C4          fD
                    sex                           * 4571 1D             .
                    pshs      D                   * 4572 34 06          4.
                    ldb       [<$08,S]            * 4574 E6 F8 08       fx.
                    sex                           * 4577 1D             .
                    cmpd      ,S++                * 4578 10 A3 E1       .#a
                    beq       L455F               * 457B 27 E2          'b
                    ldb       [<$06,S]            * 457D E6 F8 06       fx.
                    sex                           * 4580 1D             .
                    pshs      D                   * 4581 34 06          4.
                    ldb       ,U                  * 4583 E6 C4          fD
                    sex                           * 4585 1D             .
                    subd      ,S++                * 4586 A3 E1          #a
                    puls      PC,U                * 4588 35 C0          5@
L458A               pshs      U                   * 458A 34 40          4@
                    ldu       4,S                 * 458C EE 64          nd
                    bra       L459A               * 458E 20 0A           .
L4590               ldx       6,S                 * 4590 AE 66          .f
                    leax      1,X                 * 4592 30 01          0.
                    stx       6,S                 * 4594 AF 66          /f
                    ldb       -1,X                * 4596 E6 1F          f.
                    stb       ,U+                 * 4598 E7 C0          g@
L459A               ldd       8,S                 * 459A EC 68          lh
                    addd      #-1                 * 459C C3 FF FF       C..
                    std       8,S                 * 459F ED 68          mh
                    subd      #-1                 * 45A1 83 FF FF       ...
                    bgt       L4590               * 45A4 2E EA          .j
                    puls      PC,U                * 45A6 35 C0          5@
L45A8               ldd       4,S                 * 45A8 EC 64          ld
                    addd      2,X                 * 45AA E3 02          c.
                    std       >Y059D,Y            * 45AC ED A9 05 9D    m)..
                    ldd       2,S                 * 45B0 EC 62          lb
                    adcb      1,X                 * 45B2 E9 01          i.
                    adca      ,X                  * 45B4 A9 84          ).
                    std       >Y059B,Y            * 45B6 ED A9 05 9B    m)..
                    lbra      L464C               * 45BA 16 00 8F       ...
L45BD               ldd       4,S                 * 45BD EC 64          ld
                    subd      2,X                 * 45BF A3 02          #.
                    std       >Y059D,Y            * 45C1 ED A9 05 9D    m)..
                    ldd       2,S                 * 45C5 EC 62          lb
                    sbcb      1,X                 * 45C7 E2 01          b.
                    sbca      ,X                  * 45C9 A2 84          ".
                    std       >Y059B,Y            * 45CB ED A9 05 9B    m)..
                    lbra      L464C               * 45CF 16 00 7A       ..z
L45D2               ldd       2,S                 * 45D2 EC 62          lb
                    cmpd      ,X                  * 45D4 10 A3 84       .#.
                    bne       L45EB               * 45D7 26 12          &.
                    ldd       4,S                 * 45D9 EC 64          ld
                    cmpd      2,X                 * 45DB 10 A3 02       .#.
                    beq       L45EB               * 45DE 27 0B          '.
                    bcs       L45E8               * 45E0 25 06          %.
                    lda       #1                  * 45E2 86 01          ..
                    andcc     #254                * 45E4 1C FE          .~
                    bra       L45EB               * 45E6 20 03           .
L45E8               clra                          * 45E8 4F             O
                    cmpa      #1                  * 45E9 81 01          ..
L45EB               pshs      CC                  * 45EB 34 01          4.
                    ldd       1,S                 * 45ED EC 61          la
                    std       5,S                 * 45EF ED 65          me
                    puls      CC                  * 45F1 35 01          5.
                    leas      4,S                 * 45F3 32 64          2d
                    rts                           * 45F5 39             9
L45F6               lbsr      L465B               * 45F6 17 00 62       ..b
                    ldd       #0                  * 45F9 CC 00 00       L..
                    subd      2,X                 * 45FC A3 02          #.
                    std       2,X                 * 45FE ED 02          m.
                    ldd       #0                  * 4600 CC 00 00       L..
                    sbcb      1,X                 * 4603 E2 01          b.
                    sbca      ,X                  * 4605 A2 84          ".
                    std       ,X                  * 4607 ED 84          m.
                    rts                           * 4609 39             9
                    ldd       ,X                  * 460A EC 84          l.
                    coma                          * 460C 43             C
                    comb                          * 460D 53             S
                    std       >Y059B,Y            * 460E ED A9 05 9B    m)..
                    ldd       2,X                 * 4612 EC 02          l.
                    coma                          * 4614 43             C
                    comb                          * 4615 53             S
                    leax      >Y059B,Y            * 4616 30 A9 05 9B    0)..
                    std       2,X                 * 461A ED 02          m.
                    rts                           * 461C 39             9
L461D               leax      >Y059B,Y            * 461D 30 A9 05 9B    0)..
                    std       2,X                 * 4621 ED 02          m.
                    tfr       A,B                 * 4623 1F 89          ..
                    sex                           * 4625 1D             .
                    tfr       A,B                 * 4626 1F 89          ..
                    std       ,X                  * 4628 ED 84          m.
                    rts                           * 462A 39             9
L462B               leax      >Y059B,Y            * 462B 30 A9 05 9B    0)..
                    std       2,X                 * 462F ED 02          m.
                    clr       ,X                  * 4631 6F 84          o.
                    clr       1,X                 * 4633 6F 01          o.
                    rts                           * 4635 39             9
L4636               pshs      Y                   * 4636 34 20          4
                    ldy       4,S                 * 4638 10 AE 64       ..d
                    ldd       ,X                  * 463B EC 84          l.
                    std       ,Y                  * 463D ED A4          m$
                    ldd       2,X                 * 463F EC 02          l.
                    std       U0002,Y             * 4641 ED 22          m"
                    puls      X                   * 4643 35 10          5.
                    exg       Y,X                 * 4645 1E 21          .!
                    puls      D                   * 4647 35 06          5.
                    std       ,S                  * 4649 ED E4          md
                    rts                           * 464B 39             9
L464C               tfr       CC,A                * 464C 1F A8          .(
                    puls      X                   * 464E 35 10          5.
                    stx       2,S                 * 4650 AF 62          /b
                    leas      2,S                 * 4652 32 62          2b
                    leax      >Y059B,Y            * 4654 30 A9 05 9B    0)..
                    tfr       A,CC                * 4658 1F 8A          ..
                    rts                           * 465A 39             9
L465B               ldd       ,X                  * 465B EC 84          l.
                    std       >Y059B,Y            * 465D ED A9 05 9B    m)..
                    ldd       2,X                 * 4661 EC 02          l.
                    leax      >Y059B,Y            * 4663 30 A9 05 9B    0)..
                    std       2,X                 * 4667 ED 02          m.
                    rts                           * 4669 39             9
L466A               tsta                          * 466A 4D             M
                    bne       L467F               * 466B 26 12          &.
                    tst       2,S                 * 466D 6D 62          mb
                    bne       L467F               * 466F 26 0E          &.
                    lda       3,S                 * 4671 A6 63          &c
                    mul                           * 4673 3D             =
                    ldx       ,S                  * 4674 AE E4          .d
                    stx       2,S                 * 4676 AF 62          /b
                    ldx       #0                  * 4678 8E 00 00       ...
                    std       ,S                  * 467B ED E4          md
                    puls      PC,D                * 467D 35 86          5.
L467F               pshs      D                   * 467F 34 06          4.
                    ldd       #0                  * 4681 CC 00 00       L..
                    pshs      D                   * 4684 34 06          4.
                    pshs      D                   * 4686 34 06          4.
                    lda       5,S                 * 4688 A6 65          &e
                    ldb       9,S                 * 468A E6 69          fi
                    mul                           * 468C 3D             =
                    std       2,S                 * 468D ED 62          mb
                    lda       5,S                 * 468F A6 65          &e
                    ldb       8,S                 * 4691 E6 68          fh
                    mul                           * 4693 3D             =
                    addd      1,S                 * 4694 E3 61          ca
                    std       1,S                 * 4696 ED 61          ma
                    bcc       L469C               * 4698 24 02          $.
                    inc       ,S                  * 469A 6C E4          ld
L469C               lda       4,S                 * 469C A6 64          &d
                    ldb       9,S                 * 469E E6 69          fi
                    mul                           * 46A0 3D             =
                    addd      1,S                 * 46A1 E3 61          ca
                    std       1,S                 * 46A3 ED 61          ma
                    bcc       L46A9               * 46A5 24 02          $.
                    inc       ,S                  * 46A7 6C E4          ld
L46A9               lda       4,S                 * 46A9 A6 64          &d
                    ldb       8,S                 * 46AB E6 68          fh
                    mul                           * 46AD 3D             =
                    addd      ,S                  * 46AE E3 E4          cd
                    std       ,S                  * 46B0 ED E4          md
                    ldx       6,S                 * 46B2 AE 66          .f
                    stx       8,S                 * 46B4 AF 68          /h
                    ldx       ,S                  * 46B6 AE E4          .d
                    ldd       2,S                 * 46B8 EC 62          lb
                    leas      8,S                 * 46BA 32 68          2h
                    rts                           * 46BC 39             9
L46BD               clr       >Y09C1,Y            * 46BD 6F A9 09 C1    o).A
                    leax      >L4705,PC           * 46C1 30 8D 00 40    0..@
                    stx       >Y09C2,Y            * 46C5 AF A9 09 C2    /).B
                    bra       L46DF               * 46C9 20 14           .
                    leax      >L471E,PC           * 46CB 30 8D 00 4F    0..O
                    stx       >Y09C2,Y            * 46CF AF A9 09 C2    /).B
                    clr       >Y09C1,Y            * 46D3 6F A9 09 C1    o).A
                    tst       2,S                 * 46D7 6D 62          mb
                    bpl       L46DF               * 46D9 2A 04          *.
                    inc       >Y09C1,Y            * 46DB 6C A9 09 C1    l).A
L46DF               subd      #0                  * 46DF 83 00 00       ...
                    bne       L46EA               * 46E2 26 06          &.
                    puls      X                   * 46E4 35 10          5.
                    ldd       ,S++                * 46E6 EC E1          la
                    jmp       ,X                  * 46E8 6E 84          n.
L46EA               ldx       2,S                 * 46EA AE 62          .b
                    pshs      X                   * 46EC 34 10          4.
                    jsr       [>Y09C2,Y]          * 46EE AD B9 09 C2    -9.B
                    ldd       ,S                  * 46F2 EC E4          ld
                    std       2,S                 * 46F4 ED 62          mb
                    tfr       X,D                 * 46F6 1F 10          ..
                    tst       >Y09C1,Y            * 46F8 6D A9 09 C1    m).A
                    beq       L4702               * 46FC 27 04          '.
                    nega                          * 46FE 40             @
                    negb                          * 46FF 50             P
                    sbca      #0                  * 4700 82 00          ..
L4702               std       ,S++                * 4702 ED E1          ma
                    rts                           * 4704 39             9
L4705               subd      #0                  * 4705 83 00 00       ...
                    beq       L4714               * 4708 27 0A          '.
                    pshs      D                   * 470A 34 06          4.
                    leas      -2,S                * 470C 32 7E          2~
                    clr       ,S                  * 470E 6F E4          od
                    clr       1,S                 * 4710 6F 61          oa
                    bra       L4742               * 4712 20 2E           .
L4714               puls      D                   * 4714 35 06          5.
                    std       ,S                  * 4716 ED E4          md
                    ldd       #45                 * 4718 CC 00 2D       L.-
                    lbra      L47B7               * 471B 16 00 99       ...
L471E               subd      #0                  * 471E 83 00 00       ...
                    beq       L4714               * 4721 27 F1          'q
                    pshs      D                   * 4723 34 06          4.
                    leas      -2,S                * 4725 32 7E          2~
                    clr       ,S                  * 4727 6F E4          od
                    clr       1,S                 * 4729 6F 61          oa
                    tsta                          * 472B 4D             M
                    bpl       L4736               * 472C 2A 08          *.
                    nega                          * 472E 40             @
                    negb                          * 472F 50             P
                    sbca      #0                  * 4730 82 00          ..
                    inc       1,S                 * 4732 6C 61          la
                    std       2,S                 * 4734 ED 62          mb
L4736               ldd       6,S                 * 4736 EC 66          lf
                    bpl       L4742               * 4738 2A 08          *.
                    nega                          * 473A 40             @
                    negb                          * 473B 50             P
                    sbca      #0                  * 473C 82 00          ..
                    com       1,S                 * 473E 63 61          ca
                    std       6,S                 * 4740 ED 66          mf
L4742               lda       #1                  * 4742 86 01          ..
L4744               inca                          * 4744 4C             L
                    asl       3,S                 * 4745 68 63          hc
                    rol       2,S                 * 4747 69 62          ib
                    bpl       L4744               * 4749 2A F9          *y
                    sta       ,S                  * 474B A7 E4          'd
                    ldd       6,S                 * 474D EC 66          lf
                    clr       6,S                 * 474F 6F 66          of
                    clr       7,S                 * 4751 6F 67          og
L4753               subd      2,S                 * 4753 A3 62          #b
                    bcc       L475D               * 4755 24 06          $.
                    addd      2,S                 * 4757 E3 62          cb
                    andcc     #254                * 4759 1C FE          .~
                    bra       L475F               * 475B 20 02           .
L475D               orcc      #1                  * 475D 1A 01          ..
L475F               rol       7,S                 * 475F 69 67          ig
                    rol       6,S                 * 4761 69 66          if
                    lsr       2,S                 * 4763 64 62          db
                    ror       3,S                 * 4765 66 63          fc
                    dec       ,S                  * 4767 6A E4          jd
                    bne       L4753               * 4769 26 E8          &h
                    std       2,S                 * 476B ED 62          mb
                    tst       1,S                 * 476D 6D 61          ma
                    beq       L4779               * 476F 27 08          '.
                    ldd       6,S                 * 4771 EC 66          lf
                    nega                          * 4773 40             @
                    negb                          * 4774 50             P
                    sbca      #0                  * 4775 82 00          ..
                    std       6,S                 * 4777 ED 66          mf
L4779               ldx       4,S                 * 4779 AE 64          .d
                    ldd       6,S                 * 477B EC 66          lf
                    std       4,S                 * 477D ED 64          md
                    stx       6,S                 * 477F AF 66          /f
                    ldx       2,S                 * 4781 AE 62          .b
                    ldd       4,S                 * 4783 EC 64          ld
                    leas      6,S                 * 4785 32 66          2f
                    rts                           * 4787 39             9
                    tstb                          * 4788 5D             ]
                    beq       L479E               * 4789 27 13          '.
L478B               asr       2,S                 * 478B 67 62          gb
                    ror       3,S                 * 478D 66 63          fc
                    decb                          * 478F 5A             Z
                    bne       L478B               * 4790 26 F9          &y
                    bra       L479E               * 4792 20 0A           .
L4794               tstb                          * 4794 5D             ]
                    beq       L479E               * 4795 27 07          '.
L4797               lsr       2,S                 * 4797 64 62          db
                    ror       3,S                 * 4799 66 63          fc
                    decb                          * 479B 5A             Z
                    bne       L4797               * 479C 26 F9          &y
L479E               ldd       2,S                 * 479E EC 62          lb
                    pshs      D                   * 47A0 34 06          4.
                    ldd       2,S                 * 47A2 EC 62          lb
                    std       4,S                 * 47A4 ED 64          md
                    ldd       ,S                  * 47A6 EC E4          ld
                    leas      4,S                 * 47A8 32 64          2d
                    rts                           * 47AA 39             9
L47AB               tstb                          * 47AB 5D             ]
                    beq       L479E               * 47AC 27 F0          'p
L47AE               asl       3,S                 * 47AE 68 63          hc
                    rol       2,S                 * 47B0 69 62          ib
                    decb                          * 47B2 5A             Z
                    bne       L47AE               * 47B3 26 F9          &y
                    bra       L479E               * 47B5 20 E7           g
L47B7               std       >errno,Y            * 47B7 ED A9 05 A7    m).'
                    pshs      Y,B                 * 47BB 34 24          4$
                    os9       F$ID                * 47BD 10 3F 0C       .?.
                    puls      Y,B                 * 47C0 35 24          5$
                    os9       F$Send              * 47C2 10 3F 08       .?.
                    rts                           * 47C5 39             9
L47C6               lda       5,S                 * 47C6 A6 65          &e
                    ldb       3,S                 * 47C8 E6 63          fc
                    beq       L47F9               * 47CA 27 2D          '-
                    cmpb      #1                  * 47CC C1 01          A.
                    beq       L47FB               * 47CE 27 2B          '+
                    cmpb      #6                  * 47D0 C1 06          A.
                    beq       L47FB               * 47D2 27 27          ''
                    cmpb      #2                  * 47D4 C1 02          A.
                    beq       L47E1               * 47D6 27 09          '.
                    cmpb      #5                  * 47D8 C1 05          A.
                    beq       L47E1               * 47DA 27 05          '.
                    ldb       #208                * 47DC C6 D0          FP
                    lbra      _os9err             * 47DE 16 02 21       ..!
L47E1               pshs      U                   * 47E1 34 40          4@
                    os9       I$GetStt            * 47E3 10 3F 8D       .?.
                    bcc       L47ED               * 47E6 24 05          $.
                    puls      U                   * 47E8 35 40          5@
                    lbra      _os9err             * 47EA 16 02 15       ...
L47ED               stx       [<$08,S]            * 47ED AF F8 08       /x.
                    ldx       8,S                 * 47F0 AE 68          .h
                    stu       2,X                 * 47F2 EF 02          o.
                    puls      U                   * 47F4 35 40          5@
                    clra                          * 47F6 4F             O
                    clrb                          * 47F7 5F             _
                    rts                           * 47F8 39             9
L47F9               ldx       6,S                 * 47F9 AE 66          .f
L47FB               os9       I$GetStt            * 47FB 10 3F 8D       .?.
                    lbra      _sysret             * 47FE 16 02 0A       ...
                    lda       5,S                 * 4801 A6 65          &e
                    ldb       3,S                 * 4803 E6 63          fc
                    beq       L4810               * 4805 27 09          '.
                    cmpb      #2                  * 4807 C1 02          A.
                    beq       L4818               * 4809 27 0D          '.
                    ldb       #208                * 480B C6 D0          FP
                    lbra      _os9err             * 480D 16 01 F2       ..r
L4810               ldx       6,S                 * 4810 AE 66          .f
                    os9       I$SetStt            * 4812 10 3F 8E       .?.
                    lbra      _sysret             * 4815 16 01 F3       ..s
L4818               pshs      U                   * 4818 34 40          4@
                    ldx       8,S                 * 481A AE 68          .h
                    ldu       10,S                * 481C EE 6A          nj
                    os9       I$SetStt            * 481E 10 3F 8E       .?.
                    puls      U                   * 4821 35 40          5@
                    lbra      _sysret             * 4823 16 01 E5       ..e
access              ldx       2,S                 * 4826 AE 62          .b
                    lda       5,S                 * 4828 A6 65          &e
                    os9       I$Open              * 482A 10 3F 84       .?.
                    bcs       L4832               * 482D 25 03          %.
                    os9       I$Close             * 482F 10 3F 8F       .?.
L4832               lbra      _sysret             * 4832 16 01 D6       ..V
open                ldx       2,S                 * 4835 AE 62          .b
                    lda       5,S                 * 4837 A6 65          &e
                    os9       I$Open              * 4839 10 3F 84       .?.
                    lbcs      _os9err             * 483C 10 25 01 C2    .%.B
                    tfr       A,B                 * 4840 1F 89          ..
                    clra                          * 4842 4F             O
                    rts                           * 4843 39             9
close               lda       3,S                 * 4844 A6 63          &c
                    os9       I$Close             * 4846 10 3F 8F       .?.
                    lbra      _sysret             * 4849 16 01 BF       ..?
mknod               ldx       2,S                 * 484C AE 62          .b
                    ldb       5,S                 * 484E E6 65          fe
                    os9       I$MakDir            * 4850 10 3F 85       .?.
                    lbra      _sysret             * 4853 16 01 B5       ..5
creat               ldx       2,S                 * 4856 AE 62          .b
                    lda       5,S                 * 4858 A6 65          &e
                    ldb       #11                 * 485A C6 0B          F.
                    os9       I$Create            * 485C 10 3F 83       .?.
                    bcs       L4865               * 485F 25 04          %.
L4861               tfr       A,B                 * 4861 1F 89          ..
                    clra                          * 4863 4F             O
                    rts                           * 4864 39             9
L4865               cmpb      #218                * 4865 C1 DA          AZ
                    lbne      _os9err             * 4867 10 26 01 97    .&..
                    lda       5,S                 * 486B A6 65          &e
                    bita      #128                * 486D 85 80          ..
                    lbne      _os9err             * 486F 10 26 01 8F    .&..
                    anda      #7                  * 4873 84 07          ..
                    ldx       2,S                 * 4875 AE 62          .b
                    os9       I$Open              * 4877 10 3F 84       .?.
                    lbcs      _os9err             * 487A 10 25 01 84    .%..
                    pshs      U,A                 * 487E 34 42          4B
                    ldx       #0                  * 4880 8E 00 00       ...
                    leau      ,X                  * 4883 33 84          3.
                    ldb       #2                  * 4885 C6 02          F.
                    os9       I$SetStt            * 4887 10 3F 8E       .?.
                    puls      U,A                 * 488A 35 42          5B
                    bcc       L4861               * 488C 24 D3          $S
                    pshs      B                   * 488E 34 04          4.
                    os9       I$Close             * 4890 10 3F 8F       .?.
                    puls      B                   * 4893 35 04          5.
                    lbra      _os9err             * 4895 16 01 6A       ..j
unlink              ldx       2,S                 * 4898 AE 62          .b
                    os9       I$Delete            * 489A 10 3F 87       .?.
                    lbra      _sysret             * 489D 16 01 6B       ..k
dup                 lda       3,S                 * 48A0 A6 63          &c
                    os9       I$Dup               * 48A2 10 3F 82       .?.
                    lbcs      _os9err             * 48A5 10 25 01 59    .%.Y
                    tfr       A,B                 * 48A9 1F 89          ..
                    clra                          * 48AB 4F             O
                    rts                           * 48AC 39             9
L48AD               pshs      Y                   * 48AD 34 20          4
                    ldx       6,S                 * 48AF AE 66          .f
                    lda       5,S                 * 48B1 A6 65          &e
                    ldy       8,S                 * 48B3 10 AE 68       ..h
                    pshs      Y                   * 48B6 34 20          4
                    os9       I$Read              * 48B8 10 3F 89       .?.
L48BB               bcc       L48CA               * 48BB 24 0D          $.
                    cmpb      #211                * 48BD C1 D3          AS
                    bne       L48C5               * 48BF 26 04          &.
                    clra                          * 48C1 4F             O
                    clrb                          * 48C2 5F             _
                    puls      PC,Y,X              * 48C3 35 B0          50
L48C5               puls      Y,X                 * 48C5 35 30          50
                    lbra      _os9err             * 48C7 16 01 38       ..8
L48CA               tfr       Y,D                 * 48CA 1F 20          .
                    puls      PC,Y,X              * 48CC 35 B0          50
L48CE               pshs      Y                   * 48CE 34 20          4
                    lda       5,S                 * 48D0 A6 65          &e
                    ldx       6,S                 * 48D2 AE 66          .f
                    ldy       8,S                 * 48D4 10 AE 68       ..h
                    pshs      Y                   * 48D7 34 20          4
                    os9       I$ReadLn            * 48D9 10 3F 8B       .?.
                    bra       L48BB               * 48DC 20 DD           ]
L48DE               pshs      Y                   * 48DE 34 20          4
                    ldy       8,S                 * 48E0 10 AE 68       ..h
                    beq       L48F3               * 48E3 27 0E          '.
                    lda       5,S                 * 48E5 A6 65          &e
                    ldx       6,S                 * 48E7 AE 66          .f
                    os9       I$Write             * 48E9 10 3F 8A       .?.
L48EC               bcc       L48F3               * 48EC 24 05          $.
                    puls      Y                   * 48EE 35 20          5
                    lbra      _os9err             * 48F0 16 01 0F       ...
L48F3               tfr       Y,D                 * 48F3 1F 20          .
                    puls      PC,Y                * 48F5 35 A0          5
L48F7               pshs      Y                   * 48F7 34 20          4
                    ldy       8,S                 * 48F9 10 AE 68       ..h
                    beq       L48F3               * 48FC 27 F5          'u
                    lda       5,S                 * 48FE A6 65          &e
                    ldx       6,S                 * 4900 AE 66          .f
                    os9       I$WritLn            * 4902 10 3F 8C       .?.
                    bra       L48EC               * 4905 20 E5           e
lseek               pshs      U                   * 4907 34 40          4@
                    ldd       10,S                * 4909 EC 6A          lj
                    bne       L4915               * 490B 26 08          &.
                    ldu       #0                  * 490D CE 00 00       N..
                    ldx       #0                  * 4910 8E 00 00       ...
                    bra       L4949               * 4913 20 34           4
L4915               cmpd      #1                  * 4915 10 83 00 01    ....
                    beq       L4940               * 4919 27 25          '%
                    cmpd      #2                  * 491B 10 83 00 02    ....
                    beq       L4935               * 491F 27 14          '.
                    ldb       #247                * 4921 C6 F7          Fw
L4923               clra                          * 4923 4F             O
                    std       >errno,Y            * 4924 ED A9 05 A7    m).'
                    ldd       #-1                 * 4928 CC FF FF       L..
                    leax      >Y059B,Y            * 492B 30 A9 05 9B    0)..
                    std       ,X                  * 492F ED 84          m.
                    std       2,X                 * 4931 ED 02          m.
                    puls      PC,U                * 4933 35 C0          5@
L4935               lda       5,S                 * 4935 A6 65          &e
                    ldb       #2                  * 4937 C6 02          F.
                    os9       I$GetStt            * 4939 10 3F 8D       .?.
                    bcs       L4923               * 493C 25 E5          %e
                    bra       L4949               * 493E 20 09           .
L4940               lda       5,S                 * 4940 A6 65          &e
                    ldb       #5                  * 4942 C6 05          F.
                    os9       I$GetStt            * 4944 10 3F 8D       .?.
                    bcs       L4923               * 4947 25 DA          %Z
L4949               tfr       U,D                 * 4949 1F 30          .0
                    addd      8,S                 * 494B E3 68          ch
                    std       >Y059D,Y            * 494D ED A9 05 9D    m)..
                    tfr       D,U                 * 4951 1F 03          ..
                    tfr       X,D                 * 4953 1F 10          ..
                    adcb      7,S                 * 4955 E9 67          ig
                    adca      6,S                 * 4957 A9 66          )f
                    bmi       L4923               * 4959 2B C8          +H
                    tfr       D,X                 * 495B 1F 01          ..
                    std       >Y059B,Y            * 495D ED A9 05 9B    m)..
                    lda       5,S                 * 4961 A6 65          &e
                    os9       I$Seek              * 4963 10 3F 88       .?.
                    bcs       L4923               * 4966 25 BB          %;
                    leax      >Y059B,Y            * 4968 30 A9 05 9B    0)..
                    puls      PC,U                * 496C 35 C0          5@
L496E               ldd       >memend,Y           * 496E EC A9 05 99    l)..
                    pshs      D                   * 4972 34 06          4.
                    ldd       4,S                 * 4974 EC 64          ld
                    cmpd      >Y09C4,Y            * 4976 10 A3 A9 09 C4 .#).D
                    bcs       L49A2               * 497B 25 25          %%
                    addd      >memend,Y           * 497D E3 A9 05 99    c)..
                    pshs      Y                   * 4981 34 20          4
                    subd      ,S                  * 4983 A3 E4          #d
                    os9       F$Mem               * 4985 10 3F 07       .?.
                    tfr       Y,D                 * 4988 1F 20          .
                    puls      Y                   * 498A 35 20          5
                    bcc       L4994               * 498C 24 06          $.
                    ldd       #-1                 * 498E CC FF FF       L..
                    leas      2,S                 * 4991 32 62          2b
                    rts                           * 4993 39             9
L4994               std       >memend,Y           * 4994 ED A9 05 99    m)..
                    addd      >Y09C4,Y            * 4998 E3 A9 09 C4    c).D
                    subd      ,S                  * 499C A3 E4          #d
                    std       >Y09C4,Y            * 499E ED A9 09 C4    m).D
L49A2               leas      2,S                 * 49A2 32 62          2b
                    ldd       >Y09C4,Y            * 49A4 EC A9 09 C4    l).D
                    pshs      D                   * 49A8 34 06          4.
                    subd      4,S                 * 49AA A3 64          #d
                    std       >Y09C4,Y            * 49AC ED A9 09 C4    m).D
                    ldd       >memend,Y           * 49B0 EC A9 05 99    l)..
                    subd      ,S++                * 49B4 A3 E1          #a
                    pshs      D                   * 49B6 34 06          4.
                    clra                          * 49B8 4F             O
                    ldx       ,S                  * 49B9 AE E4          .d
L49BB               sta       ,X+                 * 49BB A7 80          '.
                    cmpx      >memend,Y           * 49BD AC A9 05 99    ,)..
                    bcs       L49BB               * 49C1 25 F8          %x
                    puls      PC,D                * 49C3 35 86          5.
L49C5               ldd       2,S                 * 49C5 EC 62          lb
                    addd      >_mtop,Y            * 49C7 E3 A9 05 A3    c).#
                    bcs       L49EE               * 49CB 25 21          %!
                    cmpd      >_stbot,Y           * 49CD 10 A3 A9 05 A5 .#).%
                    bcc       L49EE               * 49D2 24 1A          $.
                    pshs      D                   * 49D4 34 06          4.
                    ldx       >_mtop,Y            * 49D6 AE A9 05 A3    .).#
                    clra                          * 49DA 4F             O
L49DB               cmpx      ,S                  * 49DB AC E4          ,d
                    bcc       L49E3               * 49DD 24 04          $.
                    sta       ,X+                 * 49DF A7 80          '.
                    bra       L49DB               * 49E1 20 F8           x
L49E3               ldd       >_mtop,Y            * 49E3 EC A9 05 A3    l).#
                    puls      X                   * 49E7 35 10          5.
                    stx       >_mtop,Y            * 49E9 AF A9 05 A3    /).#
                    rts                           * 49ED 39             9
L49EE               ldd       #-1                 * 49EE CC FF FF       L..
                    rts                           * 49F1 39             9
                    ldx       2,S                 * 49F2 AE 62          .b
                    os9       F$STime             * 49F4 10 3F 16       .?.
                    lbra      _sysret             * 49F7 16 00 11       ...
L49FA               ldx       2,S                 * 49FA AE 62          .b
                    os9       F$Time              * 49FC 10 3F 15       .?.
                    lbra      _sysret             * 49FF 16 00 09       ...
_os9err             clra                          * 4A02 4F             O
                    std       >errno,Y            * 4A03 ED A9 05 A7    m).'
                    ldd       #-1                 * 4A07 CC FF FF       L..
                    rts                           * 4A0A 39             9
_sysret             bcs       _os9err             * 4A0B 25 F5          %u
                    clra                          * 4A0D 4F             O
                    clrb                          * 4A0E 5F             _
                    rts                           * 4A0F 39             9

exit                lbsr      _dumprof            * 4A10 17 00 08       ...
                    lbsr      _tidyup             * 4A13 17 F7 74       .wt
_exit               ldd       2,S                 * 4A16 EC 62          lb
                    os9       F$Exit              * 4A18 10 3F 06       .?.

_dumprof            rts                           * 4A1B 39             9

etext               fcb       $00                 * 4A1C 00             .
                    fcb       $15                 * 4A1D 15             .
                    fcb       $00                 * 4A1E 00             .
                    fcb       $01                 * 4A1F 01             .
                    fcb       $01                 * 4A20 01             .
                    fcb       $00                 * 4A21 00             .
                    fcb       $42                 * 4A22 42             B
                    fcb       $00                 * 4A23 00             .
                    fcb       $50                 * 4A24 50             P
                    fcb       $01                 * 4A25 01             .
                    fcb       $16                 * 4A26 16             .
                    fcb       $02                 * 4A27 02             .
                    fcb       $56                 * 4A28 56             V
                    fcb       $02                 * 4A29 02             .
                    fcb       $5E                 * 4A2A 5E             ^
                    fcb       $02                 * 4A2B 02             .
                    fcb       $7A                 * 4A2C 7A             z
                    fcb       $02                 * 4A2D 02             .
                    fcb       $82                 * 4A2E 82             .
                    fcb       $02                 * 4A2F 02             .
                    fcb       $DA                 * 4A30 DA             Z
                    fcb       $03                 * 4A31 03             .
                    fcb       $26                 * 4A32 26             &
                    fcb       $04                 * 4A33 04             .
                    fcb       $71                 * 4A34 71             q
                    fcc       "rma.tmp"           * 4A35 72 6D 61 2E 74 6D 70 rma.tmp
                    fcb       $00                 * 4A3C 00             .
                    fcb       $00                 * 4A3D 00             .
                    fcb       $00                 * 4A3E 00             .
                    fcb       $00                 * 4A3F 00             .
                    fcb       $00                 * 4A40 00             .
                    fcb       $00                 * 4A41 00             .
                    fcb       $00                 * 4A42 00             .
                    fcb       $00                 * 4A43 00             .
                    fcb       $00                 * 4A44 00             .
                    fcb       $00                 * 4A45 00             .
                    fcb       $00                 * 4A46 00             .
                    fcb       $00                 * 4A47 00             .
                    fcb       $00                 * 4A48 00             .
                    fcb       $00                 * 4A49 00             .
                    fcb       $00                 * 4A4A 00             .
                    fcb       $00                 * 4A4B 00             .
                    fcb       $00                 * 4A4C 00             .
                    fcb       $00                 * 4A4D 00             .
                    fcb       $00                 * 4A4E 00             .
                    fcb       $00                 * 4A4F 00             .
                    fcb       $00                 * 4A50 00             .
                    fcb       $00                 * 4A51 00             .
                    fcb       $00                 * 4A52 00             .
                    fcb       $08                 * 4A53 08             .
                    fcb       $EE                 * 4A54 EE             n
                    fcb       $00                 * 4A55 00             .
                    fcb       $00                 * 4A56 00             .
                    fcb       $08                 * 4A57 08             .
                    fcb       $F4                 * 4A58 F4             t
                    fcb       $00                 * 4A59 00             .
                    fcb       $01                 * 4A5A 01             .
                    fcb       $08                 * 4A5B 08             .
                    fcb       $FA                 * 4A5C FA             z
                    fcb       $00                 * 4A5D 00             .
                    fcb       $02                 * 4A5E 02             .
                    fcb       $09                 * 4A5F 09             .
                    fcb       $00                 * 4A60 00             .
                    fcb       $06                 * 4A61 06             .
                    fcb       $03                 * 4A62 03             .
                    fcb       $09                 * 4A63 09             .
                    fcb       $04                 * 4A64 04             .
                    fcb       $16                 * 4A65 16             .
                    fcb       $00                 * 4A66 00             .
                    fcb       $09                 * 4A67 09             .
                    fcb       $09                 * 4A68 09             .
                    fcb       $17                 * 4A69 17             .
                    fcb       $00                 * 4A6A 00             .
                    fcb       $09                 * 4A6B 09             .
                    fcb       $0E                 * 4A6C 0E             .
                    fcb       $1A                 * 4A6D 1A             .
                    fcb       $01                 * 4A6E 01             .
                    fcb       $09                 * 4A6F 09             .
                    fcb       $13                 * 4A70 13             .
                    fcb       $1C                 * 4A71 1C             .
                    fcb       $01                 * 4A72 01             .
                    fcb       $09                 * 4A73 09             .
                    fcb       $19                 * 4A74 19             .
                    fcb       $3C                 * 4A75 3C             <
                    fcb       $01                 * 4A76 01             .
                    fcb       $09                 * 4A77 09             .
                    fcb       $1E                 * 4A78 1E             .
                    fcb       $C3                 * 4A79 C3             C
                    fcb       $02                 * 4A7A 02             .
                    fcb       $09                 * 4A7B 09             .
                    fcb       $23                 * 4A7C 23             #
                    fcb       $83                 * 4A7D 83             .
                    fcb       $02                 * 4A7E 02             .
                    fcb       $09                 * 4A7F 09             .
                    fcb       $28                 * 4A80 28             (
                    fcb       $CC                 * 4A81 CC             L
                    fcb       $02                 * 4A82 02             .
                    fcb       $09                 * 4A83 09             .
                    fcb       $2C                 * 4A84 2C             ,
                    fcb       $8E                 * 4A85 8E             .
                    fcb       $02                 * 4A86 02             .
                    fcb       $09                 * 4A87 09             .
                    fcb       $30                 * 4A88 30             0
                    fcb       $CE                 * 4A89 CE             N
                    fcb       $02                 * 4A8A 02             .
                    fcb       $09                 * 4A8B 09             .
                    fcb       $34                 * 4A8C 34             4
                    fcb       $8C                 * 4A8D 8C             .
                    fcb       $02                 * 4A8E 02             .
                    fcb       $09                 * 4A8F 09             .
                    fcb       $39                 * 4A90 39             9
                    fcb       $8D                 * 4A91 8D             .
                    fcb       $42                 * 4A92 42             B
                    fcb       $09                 * 4A93 09             .
                    fcb       $3D                 * 4A94 3D             =
                    fcb       $CD                 * 4A95 CD             M
                    fcb       $42                 * 4A96 42             B
                    fcb       $09                 * 4A97 09             .
                    fcb       $41                 * 4A98 41             A
                    fcb       $8F                 * 4A99 8F             .
                    fcb       $42                 * 4A9A 42             B
                    fcb       $09                 * 4A9B 09             .
                    fcb       $45                 * 4A9C 45             E
                    fcb       $CF                 * 4A9D CF             O
                    fcb       $42                 * 4A9E 42             B
                    fcb       $09                 * 4A9F 09             .
                    fcb       $49                 * 4AA0 49             I
                    fcb       $83                 * 4AA1 83             .
                    fcb       $22                 * 4AA2 22             "
                    fcb       $09                 * 4AA3 09             .
                    fcb       $4E                 * 4AA4 4E             N
                    fcb       $8C                 * 4AA5 8C             .
                    fcb       $22                 * 4AA6 22             "
                    fcb       $09                 * 4AA7 09             .
                    fcb       $53                 * 4AA8 53             S
                    fcb       $83                 * 4AA9 83             .
                    fcb       $12                 * 4AAA 12             .
                    fcb       $09                 * 4AAB 09             .
                    fcb       $58                 * 4AAC 58             X
                    fcb       $8C                 * 4AAD 8C             .
                    fcb       $12                 * 4AAE 12             .
                    fcb       $09                 * 4AAF 09             .
                    fcb       $5D                 * 4AB0 5D             ]
                    fcb       $8E                 * 4AB1 8E             .
                    fcb       $12                 * 4AB2 12             .
                    fcb       $09                 * 4AB3 09             .
                    fcb       $61                 * 4AB4 61             a
                    fcb       $CE                 * 4AB5 CE             N
                    fcb       $12                 * 4AB6 12             .
                    fcb       $09                 * 4AB7 09             .
                    fcb       $65                 * 4AB8 65             e
                    fcb       $8F                 * 4AB9 8F             .
                    fcb       $52                 * 4ABA 52             R
                    fcb       $09                 * 4ABB 09             .
                    fcb       $69                 * 4ABC 69             i
                    fcb       $CF                 * 4ABD CF             O
                    fcb       $52                 * 4ABE 52             R
                    fcb       $09                 * 4ABF 09             .
                    fcb       $6D                 * 4AC0 6D             m
                    fcb       $8B                 * 4AC1 8B             .
                    fcb       $03                 * 4AC2 03             .
                    fcb       $09                 * 4AC3 09             .
                    fcb       $71                 * 4AC4 71             q
                    fcb       $81                 * 4AC5 81             .
                    fcb       $03                 * 4AC6 03             .
                    fcb       $09                 * 4AC7 09             .
                    fcb       $75                 * 4AC8 75             u
                    fcb       $80                 * 4AC9 80             .
                    fcb       $03                 * 4ACA 03             .
                    fcb       $09                 * 4ACB 09             .
                    fcb       $79                 * 4ACC 79             y
                    fcb       $82                 * 4ACD 82             .
                    fcb       $03                 * 4ACE 03             .
                    fcb       $09                 * 4ACF 09             .
                    fcb       $7D                 * 4AD0 7D             }
                    fcb       $84                 * 4AD1 84             .
                    fcb       $03                 * 4AD2 03             .
                    fcb       $09                 * 4AD3 09             .
                    fcb       $81                 * 4AD4 81             .
                    fcb       $85                 * 4AD5 85             .
                    fcb       $03                 * 4AD6 03             .
                    fcb       $09                 * 4AD7 09             .
                    fcb       $85                 * 4AD8 85             .
                    fcb       $86                 * 4AD9 86             .
                    fcb       $03                 * 4ADA 03             .
                    fcb       $09                 * 4ADB 09             .
                    fcb       $88                 * 4ADC 88             .
                    fcb       $87                 * 4ADD 87             .
                    fcb       $43                 * 4ADE 43             C
                    fcb       $09                 * 4ADF 09             .
                    fcb       $8B                 * 4AE0 8B             .
                    fcb       $88                 * 4AE1 88             .
                    fcb       $03                 * 4AE2 03             .
                    fcb       $09                 * 4AE3 09             .
                    fcb       $8F                 * 4AE4 8F             .
                    fcb       $89                 * 4AE5 89             .
                    fcb       $03                 * 4AE6 03             .
                    fcb       $09                 * 4AE7 09             .
                    fcb       $93                 * 4AE8 93             .
                    fcb       $08                 * 4AE9 08             .
                    fcb       $0C                 * 4AEA 0C             .
                    fcb       $09                 * 4AEB 09             .
                    fcb       $97                 * 4AEC 97             .
                    fcb       $8A                 * 4AED 8A             .
                    fcb       $03                 * 4AEE 03             .
                    fcb       $09                 * 4AEF 09             .
                    fcb       $9A                 * 4AF0 9A             .
                    fcb       $00                 * 4AF1 00             .
                    fcb       $04                 * 4AF2 04             .
                    fcb       $09                 * 4AF3 09             .
                    fcb       $9E                 * 4AF4 9E             .
                    fcb       $03                 * 4AF5 03             .
                    fcb       $04                 * 4AF6 04             .
                    fcb       $09                 * 4AF7 09             .
                    fcb       $A2                 * 4AF8 A2             "
                    fcb       $04                 * 4AF9 04             .
                    fcb       $04                 * 4AFA 04             .
                    fcb       $09                 * 4AFB 09             .
                    fcb       $A6                 * 4AFC A6             &
                    fcb       $06                 * 4AFD 06             .
                    fcb       $04                 * 4AFE 04             .
                    fcb       $09                 * 4AFF 09             .
                    fcb       $AA                 * 4B00 AA             *
                    fcb       $07                 * 4B01 07             .
                    fcb       $04                 * 4B02 04             .
                    fcb       $09                 * 4B03 09             .
                    fcb       $AE                 * 4B04 AE             .
                    fcb       $08                 * 4B05 08             .
                    fcb       $04                 * 4B06 04             .
                    fcb       $09                 * 4B07 09             .
                    fcb       $B2                 * 4B08 B2             2
                    fcb       $08                 * 4B09 08             .
                    fcb       $04                 * 4B0A 04             .
                    fcb       $09                 * 4B0B 09             .
                    fcb       $B6                 * 4B0C B6             6
                    fcb       $09                 * 4B0D 09             .
                    fcb       $04                 * 4B0E 04             .
                    fcb       $09                 * 4B0F 09             .
                    fcb       $BA                 * 4B10 BA             :
                    fcb       $0A                 * 4B11 0A             .
                    fcb       $04                 * 4B12 04             .
                    fcb       $09                 * 4B13 09             .
                    fcb       $BE                 * 4B14 BE             >
                    fcb       $0C                 * 4B15 0C             .
                    fcb       $04                 * 4B16 04             .
                    fcb       $09                 * 4B17 09             .
                    fcb       $C2                 * 4B18 C2             B
                    fcb       $0D                 * 4B19 0D             .
                    fcb       $04                 * 4B1A 04             .
                    fcb       $09                 * 4B1B 09             .
                    fcb       $C6                 * 4B1C C6             F
                    fcb       $0E                 * 4B1D 0E             .
                    fcb       $44                 * 4B1E 44             D
                    fcb       $09                 * 4B1F 09             .
                    fcb       $CA                 * 4B20 CA             J
                    fcb       $0F                 * 4B21 0F             .
                    fcb       $04                 * 4B22 04             .
                    fcb       $09                 * 4B23 09             .
                    fcb       $CE                 * 4B24 CE             N
                    fcb       $39                 * 4B25 39             9
                    fcb       $05                 * 4B26 05             .
                    fcb       $09                 * 4B27 09             .
                    fcb       $D2                 * 4B28 D2             R
                    fcb       $3D                 * 4B29 3D             =
                    fcb       $05                 * 4B2A 05             .
                    fcb       $09                 * 4B2B 09             .
                    fcb       $D6                 * 4B2C D6             V
                    fcb       $12                 * 4B2D 12             .
                    fcb       $05                 * 4B2E 05             .
                    fcb       $09                 * 4B2F 09             .
                    fcb       $DA                 * 4B30 DA             Z
                    fcb       $13                 * 4B31 13             .
                    fcb       $05                 * 4B32 05             .
                    fcb       $09                 * 4B33 09             .
                    fcb       $DF                 * 4B34 DF             _
                    fcb       $19                 * 4B35 19             .
                    fcb       $05                 * 4B36 05             .
                    fcb       $09                 * 4B37 09             .
                    fcb       $E3                 * 4B38 E3             c
                    fcb       $1D                 * 4B39 1D             .
                    fcb       $05                 * 4B3A 05             .
                    fcb       $09                 * 4B3B 09             .
                    fcb       $E7                 * 4B3C E7             g
                    fcb       $3A                 * 4B3D 3A             :
                    fcb       $05                 * 4B3E 05             .
                    fcb       $09                 * 4B3F 09             .
                    fcb       $EB                 * 4B40 EB             k
                    fcb       $3B                 * 4B41 3B             ;
                    fcb       $05                 * 4B42 05             .
                    fcb       $09                 * 4B43 09             .
                    fcb       $EF                 * 4B44 EF             o
                    fcb       $3F                 * 4B45 3F             ?
                    fcb       $15                 * 4B46 15             .
                    fcb       $09                 * 4B47 09             .
                    fcb       $F4                 * 4B48 F4             t
                    fcb       $3F                 * 4B49 3F             ?
                    fcb       $25                 * 4B4A 25             %
                    fcb       $09                 * 4B4B 09             .
                    fcb       $F9                 * 4B4C F9             y
                    fcb       $3F                 * 4B4D 3F             ?
                    fcb       $05                 * 4B4E 05             .
                    fcb       $09                 * 4B4F 09             .
                    fcb       $FD                 * 4B50 FD             }
                    fcb       $30                 * 4B51 30             0
                    fcb       $06                 * 4B52 06             .
                    fcb       $0A                 * 4B53 0A             .
                    fcb       $02                 * 4B54 02             .
                    fcb       $31                 * 4B55 31             1
                    fcb       $06                 * 4B56 06             .
                    fcb       $0A                 * 4B57 0A             .
                    fcb       $07                 * 4B58 07             .
                    fcb       $32                 * 4B59 32             2
                    fcb       $06                 * 4B5A 06             .
                    fcb       $0A                 * 4B5B 0A             .
                    fcb       $0C                 * 4B5C 0C             .
                    fcb       $33                 * 4B5D 33             3
                    fcb       $06                 * 4B5E 06             .
                    fcb       $0A                 * 4B5F 0A             .
                    fcb       $11                 * 4B60 11             .
                    fcb       $1F                 * 4B61 1F             .
                    fcb       $07                 * 4B62 07             .
                    fcb       $0A                 * 4B63 0A             .
                    fcb       $15                 * 4B64 15             .
                    fcb       $1E                 * 4B65 1E             .
                    fcb       $07                 * 4B66 07             .
                    fcb       $0A                 * 4B67 0A             .
                    fcb       $19                 * 4B68 19             .
                    fcb       $34                 * 4B69 34             4
                    fcb       $08                 * 4B6A 08             .
                    fcb       $0A                 * 4B6B 0A             .
                    fcb       $1E                 * 4B6C 1E             .
                    fcb       $35                 * 4B6D 35             5
                    fcb       $08                 * 4B6E 08             .
                    fcb       $0A                 * 4B6F 0A             .
                    fcb       $23                 * 4B70 23             #
                    fcb       $36                 * 4B71 36             6
                    fcb       $08                 * 4B72 08             .
                    fcb       $0A                 * 4B73 0A             .
                    fcb       $28                 * 4B74 28             (
                    fcb       $37                 * 4B75 37             7
                    fcb       $08                 * 4B76 08             .
                    fcb       $0A                 * 4B77 0A             .
                    fcb       $2D                 * 4B78 2D             -
                    fcb       $00                 * 4B79 00             .
                    fcb       $19                 * 4B7A 19             .
                    fcb       $0A                 * 4B7B 0A             .
                    fcb       $30                 * 4B7C 30             0
                    fcb       $01                 * 4B7D 01             .
                    fcb       $0B                 * 4B7E 0B             .
                    fcb       $0A                 * 4B7F 0A             .
                    fcb       $34                 * 4B80 34             4
                    fcb       $02                 * 4B81 02             .
                    fcb       $0B                 * 4B82 0B             .
                    fcb       $0A                 * 4B83 0A             .
                    fcb       $38                 * 4B84 38             8
                    fcb       $03                 * 4B85 03             .
                    fcb       $0B                 * 4B86 0B             .
                    fcb       $0A                 * 4B87 0A             .
                    fcb       $3C                 * 4B88 3C             <
                    fcb       $04                 * 4B89 04             .
                    fcb       $0B                 * 4B8A 0B             .
                    fcb       $0A                 * 4B8B 0A             .
                    fcb       $40                 * 4B8C 40             @
                    fcb       $0A                 * 4B8D 0A             .
                    fcb       $0B                 * 4B8E 0B             .
                    fcb       $0A                 * 4B8F 0A             .
                    fcb       $44                 * 4B90 44             D
                    fcb       $06                 * 4B91 06             .
                    fcb       $0B                 * 4B92 0B             .
                    fcb       $0A                 * 4B93 0A             .
                    fcb       $4A                 * 4B94 4A             J
                    fcb       $00                 * 4B95 00             .
                    fcb       $0D                 * 4B96 0D             .
                    fcb       $0A                 * 4B97 0A             .
                    fcb       $50                 * 4B98 50             P
                    fcb       $07                 * 4B99 07             .
                    fcb       $0B                 * 4B9A 0B             .
                    fcb       $0A                 * 4B9B 0A             .
                    fcb       $55                 * 4B9C 55             U
                    fcb       $07                 * 4B9D 07             .
                    fcb       $0C                 * 4B9E 0C             .
                    fcb       $0A                 * 4B9F 0A             .
                    fcb       $5B                 * 4BA0 5B             [
                    fcb       $09                 * 4BA1 09             .
                    fcb       $0B                 * 4BA2 0B             .
                    fcb       $0A                 * 4BA3 0A             .
                    fcb       $5F                 * 4BA4 5F             _
                    fcb       $00                 * 4BA5 00             .
                    fcb       $00                 * 4BA6 00             .
                    fcb       $0A                 * 4BA7 0A             .
                    fcb       $63                 * 4BA8 63             c
                    fcb       $00                 * 4BA9 00             .
                    fcb       $01                 * 4BAA 01             .
                    fcb       $0A                 * 4BAB 0A             .
                    fcb       $68                 * 4BAC 68             h
                    fcb       $00                 * 4BAD 00             .
                    fcb       $00                 * 4BAE 00             .
                    fcb       $0A                 * 4BAF 0A             .
                    fcb       $6C                 * 4BB0 6C             l
                    fcb       $01                 * 4BB1 01             .
                    fcb       $00                 * 4BB2 00             .
                    fcb       $0A                 * 4BB3 0A             .
                    fcb       $70                 * 4BB4 70             p
                    fcb       $02                 * 4BB5 02             .
                    fcb       $00                 * 4BB6 00             .
                    fcb       $0A                 * 4BB7 0A             .
                    fcb       $74                 * 4BB8 74             t
                    fcb       $03                 * 4BB9 03             .
                    fcb       $00                 * 4BBA 00             .
                    fcb       $0A                 * 4BBB 0A             .
                    fcb       $78                 * 4BBC 78             x
                    fcb       $04                 * 4BBD 04             .
                    fcb       $00                 * 4BBE 00             .
                    fcb       $0A                 * 4BBF 0A             .
                    fcb       $7C                 * 4BC0 7C             |
                    fcb       $0A                 * 4BC1 0A             .
                    fcb       $00                 * 4BC2 00             .
                    fcb       $0A                 * 4BC3 0A             .
                    fcb       $80                 * 4BC4 80             .
                    fcb       $00                 * 4BC5 00             .
                    fcb       $01                 * 4BC6 01             .
                    fcb       $0A                 * 4BC7 0A             .
                    fcb       $85                 * 4BC8 85             .
                    fcb       $00                 * 4BC9 00             .
                    fcb       $00                 * 4BCA 00             .
                    fcb       $0A                 * 4BCB 0A             .
                    fcb       $89                 * 4BCC 89             .
                    fcb       $00                 * 4BCD 00             .
                    fcb       $01                 * 4BCE 01             .
                    fcb       $0A                 * 4BCF 0A             .
                    fcb       $8E                 * 4BD0 8E             .
                    fcb       $00                 * 4BD1 00             .
                    fcb       $00                 * 4BD2 00             .
                    fcb       $0A                 * 4BD3 0A             .
                    fcb       $92                 * 4BD4 92             .
                    fcb       $01                 * 4BD5 01             .
                    fcb       $00                 * 4BD6 00             .
                    fcb       $0A                 * 4BD7 0A             .
                    fcb       $96                 * 4BD8 96             .
                    fcb       $02                 * 4BD9 02             .
                    fcb       $00                 * 4BDA 00             .
                    fcb       $0A                 * 4BDB 0A             .
                    fcb       $9A                 * 4BDC 9A             .
                    fcb       $03                 * 4BDD 03             .
                    fcb       $00                 * 4BDE 00             .
                    fcb       $0A                 * 4BDF 0A             .
                    fcb       $9E                 * 4BE0 9E             .
                    fcb       $04                 * 4BE1 04             .
                    fcb       $00                 * 4BE2 00             .
                    fcb       $0A                 * 4BE3 0A             .
                    fcb       $A2                 * 4BE4 A2             "
                    fcb       $05                 * 4BE5 05             .
                    fcb       $00                 * 4BE6 00             .
                    fcb       $0A                 * 4BE7 0A             .
                    fcb       $A6                 * 4BE8 A6             &
                    fcb       $09                 * 4BE9 09             .
                    fcb       $00                 * 4BEA 00             .
                    fcb       $0A                 * 4BEB 0A             .
                    fcb       $AB                 * 4BEC AB             +
                    fcb       $0A                 * 4BED 0A             .
                    fcb       $00                 * 4BEE 00             .
                    fcb       $0A                 * 4BEF 0A             .
                    fcb       $B0                 * 4BF0 B0             0
                    fcb       $0B                 * 4BF1 0B             .
                    fcb       $00                 * 4BF2 00             .
                    fcb       $0A                 * 4BF3 0A             .
                    fcb       $B5                 * 4BF4 B5             5
                    fcb       $00                 * 4BF5 00             .
                    fcb       $01                 * 4BF6 01             .
                    fcb       $0A                 * 4BF7 0A             .
                    fcb       $BA                 * 4BF8 BA             :
                    fcb       $01                 * 4BF9 01             .
                    fcb       $01                 * 4BFA 01             .
                    fcb       $0A                 * 4BFB 0A             .
                    fcb       $BF                 * 4BFC BF             ?
                    fcb       $02                 * 4BFD 02             .
                    fcb       $01                 * 4BFE 01             .
                    fcb       $0A                 * 4BFF 0A             .
                    fcb       $C4                 * 4C00 C4             D
                    fcb       $03                 * 4C01 03             .
                    fcb       $01                 * 4C02 01             .
                    fcb       $0A                 * 4C03 0A             .
                    fcb       $C9                 * 4C04 C9             I
                    fcb       $04                 * 4C05 04             .
                    fcb       $01                 * 4C06 01             .
                    fcb       $0A                 * 4C07 0A             .
                    fcb       $CE                 * 4C08 CE             N
                    fcb       $05                 * 4C09 05             .
                    fcb       $01                 * 4C0A 01             .
                    fcb       $0A                 * 4C0B 0A             .
                    fcb       $D3                 * 4C0C D3             S
                    fcb       $06                 * 4C0D 06             .
                    fcb       $01                 * 4C0E 01             .
                    fcb       $0A                 * 4C0F 0A             .
                    fcb       $D8                 * 4C10 D8             X
                    fcb       $00                 * 4C11 00             .
                    fcb       $02                 * 4C12 02             .
                    fcb       $0A                 * 4C13 0A             .
                    fcb       $DD                 * 4C14 DD             ]
                    fcb       $01                 * 4C15 01             .
                    fcb       $02                 * 4C16 02             .
                    fcb       $0A                 * 4C17 0A             .
                    fcb       $E2                 * 4C18 E2             b
                    fcb       $05                 * 4C19 05             .
                    fcb       $03                 * 4C1A 03             .
                    fcb       $0A                 * 4C1B 0A             .
                    fcb       $E6                 * 4C1C E6             f
                    fcb       $08                 * 4C1D 08             .
                    fcb       $03                 * 4C1E 03             .
                    fcb       $0A                 * 4C1F 0A             .
                    fcb       $EA                 * 4C20 EA             j
                    fcb       $00                 * 4C21 00             .
                    fcb       $04                 * 4C22 04             .
                    fcb       $0A                 * 4C23 0A             .
                    fcb       $F0                 * 4C24 F0             p
                    fcb       $00                 * 4C25 00             .
                    fcb       $05                 * 4C26 05             .
                    fcb       $0A                 * 4C27 0A             .
                    fcb       $F5                 * 4C28 F5             u
                    fcb       $8D                 * 4C29 8D             .
                    fcb       $0A                 * 4C2A 0A             .
                    fcb       $0A                 * 4C2B 0A             .
                    fcb       $F9                 * 4C2C F9             y
                    fcb       $20                 * 4C2D 20
                    fcb       $0A                 * 4C2E 0A             .
                    fcb       $0A                 * 4C2F 0A             .
                    fcb       $FD                 * 4C30 FD             }
                    fcb       $21                 * 4C31 21             !
                    fcb       $0A                 * 4C32 0A             .
                    fcb       $0B                 * 4C33 0B             .
                    fcb       $01                 * 4C34 01             .
                    fcb       $22                 * 4C35 22             "
                    fcb       $0A                 * 4C36 0A             .
                    fcb       $0B                 * 4C37 0B             .
                    fcb       $05                 * 4C38 05             .
                    fcb       $23                 * 4C39 23             #
                    fcb       $0A                 * 4C3A 0A             .
                    fcb       $0B                 * 4C3B 0B             .
                    fcb       $09                 * 4C3C 09             .
                    fcb       $24                 * 4C3D 24             $
                    fcb       $0A                 * 4C3E 0A             .
                    fcb       $0B                 * 4C3F 0B             .
                    fcb       $0D                 * 4C40 0D             .
                    fcb       $24                 * 4C41 24             $
                    fcb       $0A                 * 4C42 0A             .
                    fcb       $0B                 * 4C43 0B             .
                    fcb       $11                 * 4C44 11             .
                    fcb       $25                 * 4C45 25             %
                    fcb       $0A                 * 4C46 0A             .
                    fcb       $0B                 * 4C47 0B             .
                    fcb       $15                 * 4C48 15             .
                    fcb       $25                 * 4C49 25             %
                    fcb       $0A                 * 4C4A 0A             .
                    fcb       $0B                 * 4C4B 0B             .
                    fcb       $19                 * 4C4C 19             .
                    fcb       $26                 * 4C4D 26             &
                    fcb       $0A                 * 4C4E 0A             .
                    fcb       $0B                 * 4C4F 0B             .
                    fcb       $1D                 * 4C50 1D             .
                    fcb       $27                 * 4C51 27             '
                    fcb       $0A                 * 4C52 0A             .
                    fcb       $0B                 * 4C53 0B             .
                    fcb       $21                 * 4C54 21             !
                    fcb       $28                 * 4C55 28             (
                    fcb       $0A                 * 4C56 0A             .
                    fcb       $0B                 * 4C57 0B             .
                    fcb       $25                 * 4C58 25             %
                    fcb       $29                 * 4C59 29             )
                    fcb       $0A                 * 4C5A 0A             .
                    fcb       $0B                 * 4C5B 0B             .
                    fcb       $29                 * 4C5C 29             )
                    fcb       $2A                 * 4C5D 2A             *
                    fcb       $0A                 * 4C5E 0A             .
                    fcb       $0B                 * 4C5F 0B             .
                    fcb       $2D                 * 4C60 2D             -
                    fcb       $2B                 * 4C61 2B             +
                    fcb       $0A                 * 4C62 0A             .
                    fcb       $0B                 * 4C63 0B             .
                    fcb       $31                 * 4C64 31             1
                    fcb       $2C                 * 4C65 2C             ,
                    fcb       $0A                 * 4C66 0A             .
                    fcb       $0B                 * 4C67 0B             .
                    fcb       $35                 * 4C68 35             5
                    fcb       $2D                 * 4C69 2D             -
                    fcb       $0A                 * 4C6A 0A             .
                    fcb       $0B                 * 4C6B 0B             .
                    fcb       $39                 * 4C6C 39             9
                    fcb       $2E                 * 4C6D 2E             .
                    fcb       $0A                 * 4C6E 0A             .
                    fcb       $0B                 * 4C6F 0B             .
                    fcb       $3D                 * 4C70 3D             =
                    fcb       $2F                 * 4C71 2F             /
                    fcb       $0A                 * 4C72 0A             .
                    fcb       $0D                 * 4C73 0D             .
                    fcb       $78                 * 4C74 78             x
                    fcb       $0D                 * 4C75 0D             .
                    fcb       $8D                 * 4C76 8D             .
                    fcb       $0D                 * 4C77 0D             .
                    fcb       $F8                 * 4C78 F8             x
                    fcb       $0D                 * 4C79 0D             .
                    fcb       $67                 * 4C7A 67             g
                    fcb       $0F                 * 4C7B 0F             .
                    fcb       $41                 * 4C7C 41             A
                    fcb       $0F                 * 4C7D 0F             .
                    fcb       $73                 * 4C7E 73             s
                    fcb       $0E                 * 4C7F 0E             .
                    fcb       $46                 * 4C80 46             F
                    fcb       $0E                 * 4C81 0E             .
                    fcb       $96                 * 4C82 96             .
                    fcb       $0E                 * 4C83 0E             .
                    fcb       $FD                 * 4C84 FD             }
                    fcb       $0D                 * 4C85 0D             .
                    fcb       $78                 * 4C86 78             x
                    fcb       $0B                 * 4C87 0B             .
                    fcb       $41                 * 4C88 41             A
                    fcb       $0B                 * 4C89 0B             .
                    fcb       $4B                 * 4C8A 4B             K
                    fcb       $0B                 * 4C8B 0B             .
                    fcb       $6C                 * 4C8C 6C             l
                    fcb       $0B                 * 4C8D 0B             .
                    fcb       $85                 * 4C8E 85             .
                    fcb       $0B                 * 4C8F 0B             .
                    fcb       $C9                 * 4C90 C9             I
                    fcb       $0C                 * 4C91 0C             .
                    fcb       $14                 * 4C92 14             .
                    fcb       $0C                 * 4C93 0C             .
                    fcb       $19                 * 4C94 19             .
                    fcb       $0C                 * 4C95 0C             .
                    fcb       $2C                 * 4C96 2C             ,
                    fcb       $0C                 * 4C97 0C             .
                    fcb       $92                 * 4C98 92             .
                    fcb       $0C                 * 4C99 0C             .
                    fcb       $CE                 * 4C9A CE             N
                    fcb       $0D                 * 4C9B 0D             .
                    fcb       $06                 * 4C9C 06             .
                    fcb       $0D                 * 4C9D 0D             .
                    fcb       $67                 * 4C9E 67             g
                    fcb       $0D                 * 4C9F 0D             .
                    fcb       $78                 * 4CA0 78             x
                    fcb       $0E                 * 4CA1 0E             .
                    fcb       $96                 * 4CA2 96             .
                    fcb       $0D                 * 4CA3 0D             .
                    fcb       $67                 * 4CA4 67             g
                    fcb       $0F                 * 4CA5 0F             .
                    fcb       $2A                 * 4CA6 2A             *
                    fcb       $0D                 * 4CA7 0D             .
                    fcb       $67                 * 4CA8 67             g
                    fcb       $0E                 * 4CA9 0E             .
                    fcb       $5C                 * 4CAA 5C             \
                    fcb       $0D                 * 4CAB 0D             .
                    fcb       $67                 * 4CAC 67             g
                    fcb       $1C                 * 4CAD 1C             .
                    fcb       $72                 * 4CAE 72             r
                    fcc       "A"                 * 4CAF 41             A
                    fcb       $00                 * 4CB0 00             .
                    fcb       $02                 * 4CB1 02             .
                    fcc       "B"                 * 4CB2 42             B
                    fcb       $00                 * 4CB3 00             .
                    fcb       $04                 * 4CB4 04             .
                    fcc       "CC"                * 4CB5 43 43          CC
                    fcb       $01                 * 4CB7 01             .
                    fcc       "DP"                * 4CB8 44 50          DP
                    fcb       $08                 * 4CBA 08             .
                    fcc       "D"                 * 4CBB 44             D
                    fcb       $00                 * 4CBC 00             .
                    fcb       $06                 * 4CBD 06             .
                    fcc       "X"                 * 4CBE 58             X
                    fcb       $00                 * 4CBF 00             .
                    fcb       $10                 * 4CC0 10             .
                    fcc       "Y"                 * 4CC1 59             Y
                    fcb       $00                 * 4CC2 00             .
                    fcb       $20                 * 4CC3 20
                    fcc       "U"                 * 4CC4 55             U
                    fcb       $00                 * 4CC5 00             .
                    fcb       $40                 * 4CC6 40             @
                    fcc       "S"                 * 4CC7 53             S
                    fcb       $00                 * 4CC8 00             .
                    fcb       $40                 * 4CC9 40             @
                    fcc       "PC"                * 4CCA 50 43          PC
                    fcb       $80                 * 4CCC 80             .
                    fcb       $6C                 * 4CCD 6C             l
                    fcb       $00                 * 4CCE 00             .
                    fcb       $C3                 * 4CCF C3             C
                    fcb       $6F                 * 4CD0 6F             o
                    fcb       $00                 * 4CD1 00             .
                    fcb       $C6                 * 4CD2 C6             F
                    fcb       $63                 * 4CD3 63             c
                    fcb       $00                 * 4CD4 00             .
                    fcb       $BF                 * 4CD5 BF             ?
                    fcb       $66                 * 4CD6 66             f
                    fcb       $00                 * 4CD7 00             .
                    fcb       $C0                 * 4CD8 C0             @
                    fcb       $67                 * 4CD9 67             g
                    fcb       $00                 * 4CDA 00             .
                    fcb       $C1                 * 4CDB C1             A
                    fcb       $65                 * 4CDC 65             e
                    fcb       $00                 * 4CDD 00             .
                    fcb       $01                 * 4CDE 01             .
                    fcb       $73                 * 4CDF 73             s
                    fcb       $00                 * 4CE0 00             .
                    fcb       $C7                 * 4CE1 C7             G
                    fcb       $78                 * 4CE2 78             x
                    fcb       $00                 * 4CE3 00             .
                    fcb       $02                 * 4CE4 02             .
                    fcb       $17                 * 4CE5 17             .
                    fcb       $34                 * 4CE6 34             4
                    fcb       $18                 * 4CE7 18             .
                    fcb       $13                 * 4CE8 13             .
                    fcb       $18                 * 4CE9 18             .
                    fcb       $D8                 * 4CEA D8             X
                    fcb       $18                 * 4CEB 18             .
                    fcb       $1E                 * 4CEC 1E             .
                    fcb       $18                 * 4CED 18             .
                    fcb       $C3                 * 4CEE C3             C
                    fcb       $17                 * 4CEF 17             .
                    fcb       $BF                 * 4CF0 BF             ?
                    fcb       $1B                 * 4CF1 1B             .
                    fcb       $CD                 * 4CF2 CD             M
                    fcb       $1C                 * 4CF3 1C             .
                    fcb       $72                 * 4CF4 72             r
                    fcb       $17                 * 4CF5 17             .
                    fcb       $CA                 * 4CF6 CA             J
                    fcb       $19                 * 4CF7 19             .
                    fcb       $7F                 * 4CF8 7F             .
                    fcb       $17                 * 4CF9 17             .
                    fcb       $0E                 * 4CFA 0E             .
                    fcb       $19                 * 4CFB 19             .
                    fcb       $CB                 * 4CFC CB             K
                    fcb       $1A                 * 4CFD 1A             .
                    fcb       $48                 * 4CFE 48             H
                    fcb       $19                 * 4CFF 19             .
                    fcb       $FB                 * 4D00 FB             {
                    fcb       $1A                 * 4D01 1A             .
                    fcb       $07                 * 4D02 07             .
                    fcb       $1A                 * 4D03 1A             .
                    fcb       $0E                 * 4D04 0E             .
                    fcb       $1B                 * 4D05 1B             .
                    fcb       $2F                 * 4D06 2F             /
                    fcb       $19                 * 4D07 19             .
                    fcb       $C7                 * 4D08 C7             G
                    fcb       $1B                 * 4D09 1B             .
                    fcb       $0A                 * 4D0A 0A             .
                    fcb       $19                 * 4D0B 19             .
                    fcb       $B6                 * 4D0C B6             6
                    fcb       $1C                 * 4D0D 1C             .
                    fcb       $A5                 * 4D0E A5             %
                    fcb       $1C                 * 4D0F 1C             .
                    fcb       $BC                 * 4D10 BC             <
                    fcb       $1D                 * 4D11 1D             .
                    fcb       $19                 * 4D12 19             .
                    fcb       $1B                 * 4D13 1B             .
                    fcb       $6B                 * 4D14 6B             k
                    fcb       $1B                 * 4D15 1B             .
                    fcb       $79                 * 4D16 79             y
                    fcb       $1B                 * 4D17 1B             .
                    fcb       $87                 * 4D18 87             .
                    fcb       $1B                 * 4D19 1B             .
                    fcb       $95                 * 4D1A 95             .
                    fcb       $1B                 * 4D1B 1B             .
                    fcb       $A3                 * 4D1C A3             #
                    fcb       $1B                 * 4D1D 1B             .
                    fcb       $B1                 * 4D1E B1             1
                    fcb       $1B                 * 4D1F 1B             .
                    fcb       $BF                 * 4D20 BF             ?
                    fcb       $00                 * 4D21 00             .
                    fcb       $00                 * 4D22 00             .
                    fcb       $00                 * 4D23 00             .
                    fcb       $00                 * 4D24 00             .
                    fcb       $62                 * 4D25 62             b
                    fcb       $CD                 * 4D26 CD             M
                    fcb       $23                 * 4D27 23             #
                    fcb       $87                 * 4D28 87             .
                    fcb       $00                 * 4D29 00             .
                    fcb       $00                 * 4D2A 00             .
                    fcb       $00                 * 4D2B 00             .
                    fcb       $00                 * 4D2C 00             .
                    fcb       $00                 * 4D2D 00             .
                    fcb       $00                 * 4D2E 00             .
                    fcb       $00                 * 4D2F 00             .
                    fcb       $00                 * 4D30 00             .
                    fcb       $00                 * 4D31 00             .
                    fcb       $00                 * 4D32 00             .
                    fcb       $00                 * 4D33 00             .
                    fcb       $00                 * 4D34 00             .
                    fcb       $00                 * 4D35 00             .
                    fcb       $00                 * 4D36 00             .
                    fcb       $00                 * 4D37 00             .
                    fcb       $00                 * 4D38 00             .
                    fcb       $00                 * 4D39 00             .
                    fcb       $00                 * 4D3A 00             .
                    fcb       $00                 * 4D3B 00             .
                    fcb       $00                 * 4D3C 00             .
                    fcb       $00                 * 4D3D 00             .
                    fcb       $00                 * 4D3E 00             .
                    fcb       $00                 * 4D3F 00             .
                    fcb       $00                 * 4D40 00             .
                    fcb       $07                 * 4D41 07             .
                    fcb       $FF                 * 4D42 FF             .
                    fcb       $08                 * 4D43 08             .
                    fcb       $17                 * 4D44 17             .
                    fcb       $00                 * 4D45 00             .
                    fcb       $00                 * 4D46 00             .
                    fcb       $00                 * 4D47 00             .
                    fcb       $00                 * 4D48 00             .
                    fcb       $00                 * 4D49 00             .
                    fcb       $00                 * 4D4A 00             .
                    fcb       $00                 * 4D4B 00             .
                    fcb       $00                 * 4D4C 00             .
                    fcb       $00                 * 4D4D 00             .
                    fcb       $00                 * 4D4E 00             .
                    fcb       $00                 * 4D4F 00             .
                    fcb       $00                 * 4D50 00             .
                    fcb       $00                 * 4D51 00             .
                    fcb       $00                 * 4D52 00             .
                    fcb       $00                 * 4D53 00             .
                    fcb       $00                 * 4D54 00             .
                    fcb       $00                 * 4D55 00             .
                    fcb       $00                 * 4D56 00             .
                    fcb       $00                 * 4D57 00             .
                    fcb       $00                 * 4D58 00             .
                    fcb       $00                 * 4D59 00             .
                    fcb       $00                 * 4D5A 00             .
                    fcb       $00                 * 4D5B 00             .
                    fcb       $00                 * 4D5C 00             .
                    fcb       $00                 * 4D5D 00             .
                    fcb       $00                 * 4D5E 00             .
                    fcb       $00                 * 4D5F 00             .
                    fcb       $00                 * 4D60 00             .
                    fcb       $00                 * 4D61 00             .
                    fcb       $00                 * 4D62 00             .
                    fcb       $00                 * 4D63 00             .
                    fcb       $00                 * 4D64 00             .
                    fcb       $00                 * 4D65 00             .
                    fcb       $00                 * 4D66 00             .
                    fcb       $00                 * 4D67 00             .
                    fcb       $00                 * 4D68 00             .
                    fcb       $00                 * 4D69 00             .
                    fcb       $00                 * 4D6A 00             .
                    fcb       $00                 * 4D6B 00             .
                    fcb       $00                 * 4D6C 00             .
                    fcb       $01                 * 4D6D 01             .
                    fcb       $00                 * 4D6E 00             .
                    fcb       $00                 * 4D6F 00             .
                    fcb       $00                 * 4D70 00             .
                    fcb       $00                 * 4D71 00             .
                    fcb       $00                 * 4D72 00             .
                    fcb       $00                 * 4D73 00             .
                    fcb       $00                 * 4D74 00             .
                    fcb       $00                 * 4D75 00             .
                    fcb       $00                 * 4D76 00             .
                    fcb       $02                 * 4D77 02             .
                    fcb       $00                 * 4D78 00             .
                    fcb       $38                 * 4D79 38             8
                    fcb       $38                 * 4D7A 38             8
                    fcb       $28                 * 4D7B 28             (
                    fcb       $28                 * 4D7C 28             (
                    fcb       $28                 * 4D7D 28             (
                    fcb       $28                 * 4D7E 28             (
                    fcb       $28                 * 4D7F 28             (
                    fcb       $28                 * 4D80 28             (
                    fcb       $28                 * 4D81 28             (
                    fcb       $28                 * 4D82 28             (
                    fcb       $00                 * 4D83 00             .
                    fcb       $00                 * 4D84 00             .
                    fcb       $00                 * 4D85 00             .
                    fcb       $00                 * 4D86 00             .
                    fcb       $00                 * 4D87 00             .
                    fcb       $00                 * 4D88 00             .
                    fcb       $02                 * 4D89 02             .
                    fcb       $22                 * 4D8A 22             "
                    fcb       $22                 * 4D8B 22             "
                    fcb       $22                 * 4D8C 22             "
                    fcb       $22                 * 4D8D 22             "
                    fcb       $22                 * 4D8E 22             "
                    fcb       $22                 * 4D8F 22             "
                    fcb       $02                 * 4D90 02             .
                    fcb       $02                 * 4D91 02             .
                    fcb       $02                 * 4D92 02             .
                    fcb       $02                 * 4D93 02             .
                    fcb       $02                 * 4D94 02             .
                    fcb       $02                 * 4D95 02             .
                    fcb       $02                 * 4D96 02             .
                    fcb       $02                 * 4D97 02             .
                    fcb       $02                 * 4D98 02             .
                    fcb       $02                 * 4D99 02             .
                    fcb       $02                 * 4D9A 02             .
                    fcb       $02                 * 4D9B 02             .
                    fcb       $02                 * 4D9C 02             .
                    fcb       $02                 * 4D9D 02             .
                    fcb       $02                 * 4D9E 02             .
                    fcb       $02                 * 4D9F 02             .
                    fcb       $02                 * 4DA0 02             .
                    fcb       $02                 * 4DA1 02             .
                    fcb       $02                 * 4DA2 02             .
                    fcb       $02                 * 4DA3 02             .
                    fcb       $00                 * 4DA4 00             .
                    fcb       $00                 * 4DA5 00             .
                    fcb       $00                 * 4DA6 00             .
                    fcb       $00                 * 4DA7 00             .
                    fcb       $02                 * 4DA8 02             .
                    fcb       $00                 * 4DA9 00             .
                    fcb       $04                 * 4DAA 04             .
                    fcb       $04                 * 4DAB 04             .
                    fcb       $04                 * 4DAC 04             .
                    fcb       $04                 * 4DAD 04             .
                    fcb       $04                 * 4DAE 04             .
                    fcb       $04                 * 4DAF 04             .
                    fcb       $04                 * 4DB0 04             .
                    fcb       $04                 * 4DB1 04             .
                    fcb       $04                 * 4DB2 04             .
                    fcb       $04                 * 4DB3 04             .
                    fcb       $04                 * 4DB4 04             .
                    fcb       $04                 * 4DB5 04             .
                    fcb       $04                 * 4DB6 04             .
                    fcb       $04                 * 4DB7 04             .
                    fcb       $04                 * 4DB8 04             .
                    fcb       $04                 * 4DB9 04             .
                    fcb       $04                 * 4DBA 04             .
                    fcb       $04                 * 4DBB 04             .
                    fcb       $04                 * 4DBC 04             .
                    fcb       $04                 * 4DBD 04             .
                    fcb       $04                 * 4DBE 04             .
                    fcb       $04                 * 4DBF 04             .
                    fcb       $04                 * 4DC0 04             .
                    fcb       $04                 * 4DC1 04             .
                    fcb       $04                 * 4DC2 04             .
                    fcb       $04                 * 4DC3 04             .
                    fcb       $00                 * 4DC4 00             .
                    fcb       $00                 * 4DC5 00             .
                    fcb       $00                 * 4DC6 00             .
                    fcb       $00                 * 4DC7 00             .
                    fcb       $00                 * 4DC8 00             .
                    fcb       $27                 * 4DC9 27             '
                    fcb       $10                 * 4DCA 10             .
                    fcb       $03                 * 4DCB 03             .
                    fcb       $E8                 * 4DCC E8             h
                    fcb       $00                 * 4DCD 00             .
                    fcb       $64                 * 4DCE 64             d
                    fcb       $00                 * 4DCF 00             .
                    fcb       $0A                 * 4DD0 0A             .
                    fcb       $04                 * 4DD1 04             .
                    fcb       $84                 * 4DD2 84             .
                    fcb       $6C                 * 4DD3 6C             l
                    fcb       $78                 * 4DD4 78             x
                    fcb       $00                 * 4DD5 00             .
                    fcb       $00                 * 4DD6 00             .
                    fcb       $00                 * 4DD7 00             .
                    fcb       $00                 * 4DD8 00             .
                    fcb       $00                 * 4DD9 00             .
                    fcb       $00                 * 4DDA 00             .
                    fcb       $00                 * 4DDB 00             .
                    fcb       $00                 * 4DDC 00             .
                    fcb       $01                 * 4DDD 01             .
                    fcb       $00                 * 4DDE 00             .
                    fcb       $00                 * 4DDF 00             .
                    fcb       $00                 * 4DE0 00             .
                    fcb       $00                 * 4DE1 00             .
                    fcb       $00                 * 4DE2 00             .
                    fcb       $00                 * 4DE3 00             .
                    fcb       $00                 * 4DE4 00             .
                    fcb       $00                 * 4DE5 00             .
                    fcb       $00                 * 4DE6 00             .
                    fcb       $00                 * 4DE7 00             .
                    fcb       $00                 * 4DE8 00             .
                    fcb       $00                 * 4DE9 00             .
                    fcb       $02                 * 4DEA 02             .
                    fcb       $00                 * 4DEB 00             .
                    fcb       $01                 * 4DEC 01             .
                    fcb       $00                 * 4DED 00             .
                    fcb       $00                 * 4DEE 00             .
                    fcb       $00                 * 4DEF 00             .
                    fcb       $00                 * 4DF0 00             .
                    fcb       $00                 * 4DF1 00             .
                    fcb       $00                 * 4DF2 00             .
                    fcb       $00                 * 4DF3 00             .
                    fcb       $00                 * 4DF4 00             .
                    fcb       $00                 * 4DF5 00             .
                    fcb       $00                 * 4DF6 00             .
                    fcb       $42                 * 4DF7 42             B
                    fcb       $00                 * 4DF8 00             .
                    fcb       $02                 * 4DF9 02             .
                    fcb       $00                 * 4DFA 00             .
                    fcb       $00                 * 4DFB 00             .
                    fcb       $00                 * 4DFC 00             .
                    fcb       $00                 * 4DFD 00             .
                    fcb       $00                 * 4DFE 00             .
                    fcb       $00                 * 4DFF 00             .
                    fcb       $00                 * 4E00 00             .
                    fcb       $00                 * 4E01 00             .
                    fcb       $00                 * 4E02 00             .
                    fcb       $00                 * 4E03 00             .
                    fcb       $00                 * 4E04 00             .
                    fcb       $00                 * 4E05 00             .
                    fcb       $00                 * 4E06 00             .
                    fcb       $00                 * 4E07 00             .
                    fcb       $00                 * 4E08 00             .
                    fcb       $00                 * 4E09 00             .
                    fcb       $00                 * 4E0A 00             .
                    fcb       $00                 * 4E0B 00             .
                    fcb       $00                 * 4E0C 00             .
                    fcb       $00                 * 4E0D 00             .
                    fcb       $00                 * 4E0E 00             .
                    fcb       $00                 * 4E0F 00             .
                    fcb       $00                 * 4E10 00             .
                    fcb       $00                 * 4E11 00             .
                    fcb       $00                 * 4E12 00             .
                    fcb       $00                 * 4E13 00             .
                    fcb       $00                 * 4E14 00             .
                    fcb       $00                 * 4E15 00             .
                    fcb       $00                 * 4E16 00             .
                    fcb       $00                 * 4E17 00             .
                    fcb       $00                 * 4E18 00             .
                    fcb       $00                 * 4E19 00             .
                    fcb       $00                 * 4E1A 00             .
                    fcb       $00                 * 4E1B 00             .
                    fcb       $00                 * 4E1C 00             .
                    fcb       $00                 * 4E1D 00             .
                    fcb       $00                 * 4E1E 00             .
                    fcb       $00                 * 4E1F 00             .
                    fcb       $00                 * 4E20 00             .
                    fcb       $00                 * 4E21 00             .
                    fcb       $00                 * 4E22 00             .
                    fcb       $00                 * 4E23 00             .
                    fcb       $00                 * 4E24 00             .
                    fcb       $00                 * 4E25 00             .
                    fcb       $00                 * 4E26 00             .
                    fcb       $00                 * 4E27 00             .
                    fcb       $00                 * 4E28 00             .
                    fcb       $00                 * 4E29 00             .
                    fcb       $00                 * 4E2A 00             .
                    fcb       $00                 * 4E2B 00             .
                    fcb       $00                 * 4E2C 00             .
                    fcb       $00                 * 4E2D 00             .
                    fcb       $00                 * 4E2E 00             .
                    fcb       $00                 * 4E2F 00             .
                    fcb       $00                 * 4E30 00             .
                    fcb       $00                 * 4E31 00             .
                    fcb       $00                 * 4E32 00             .
                    fcb       $00                 * 4E33 00             .
                    fcb       $00                 * 4E34 00             .
                    fcb       $00                 * 4E35 00             .
                    fcb       $00                 * 4E36 00             .
                    fcb       $00                 * 4E37 00             .
                    fcb       $00                 * 4E38 00             .
                    fcb       $00                 * 4E39 00             .
                    fcb       $00                 * 4E3A 00             .
                    fcb       $00                 * 4E3B 00             .
                    fcb       $00                 * 4E3C 00             .
                    fcb       $00                 * 4E3D 00             .
                    fcb       $00                 * 4E3E 00             .
                    fcb       $00                 * 4E3F 00             .
                    fcb       $00                 * 4E40 00             .
                    fcb       $00                 * 4E41 00             .
                    fcb       $00                 * 4E42 00             .
                    fcb       $00                 * 4E43 00             .
                    fcb       $00                 * 4E44 00             .
                    fcb       $00                 * 4E45 00             .
                    fcb       $00                 * 4E46 00             .
                    fcb       $00                 * 4E47 00             .
                    fcb       $00                 * 4E48 00             .
                    fcb       $00                 * 4E49 00             .
                    fcb       $00                 * 4E4A 00             .
                    fcb       $00                 * 4E4B 00             .
                    fcb       $00                 * 4E4C 00             .
                    fcb       $00                 * 4E4D 00             .
                    fcb       $00                 * 4E4E 00             .
                    fcb       $00                 * 4E4F 00             .
                    fcb       $00                 * 4E50 00             .
                    fcb       $00                 * 4E51 00             .
                    fcb       $00                 * 4E52 00             .
                    fcb       $00                 * 4E53 00             .
                    fcb       $00                 * 4E54 00             .
                    fcb       $00                 * 4E55 00             .
                    fcb       $00                 * 4E56 00             .
                    fcb       $00                 * 4E57 00             .
                    fcb       $00                 * 4E58 00             .
                    fcb       $00                 * 4E59 00             .
                    fcb       $00                 * 4E5A 00             .
                    fcb       $00                 * 4E5B 00             .
                    fcb       $00                 * 4E5C 00             .
                    fcb       $00                 * 4E5D 00             .
                    fcb       $00                 * 4E5E 00             .
                    fcb       $00                 * 4E5F 00             .
                    fcb       $00                 * 4E60 00             .
                    fcb       $00                 * 4E61 00             .
                    fcb       $00                 * 4E62 00             .
                    fcb       $00                 * 4E63 00             .
                    fcb       $00                 * 4E64 00             .
                    fcb       $00                 * 4E65 00             .
                    fcb       $00                 * 4E66 00             .
                    fcb       $00                 * 4E67 00             .
                    fcb       $00                 * 4E68 00             .
                    fcb       $00                 * 4E69 00             .
                    fcb       $00                 * 4E6A 00             .
                    fcb       $00                 * 4E6B 00             .
                    fcb       $00                 * 4E6C 00             .
                    fcb       $00                 * 4E6D 00             .
                    fcb       $00                 * 4E6E 00             .
                    fcb       $00                 * 4E6F 00             .
                    fcb       $00                 * 4E70 00             .
                    fcb       $00                 * 4E71 00             .
                    fcb       $00                 * 4E72 00             .
                    fcb       $00                 * 4E73 00             .
                    fcb       $00                 * 4E74 00             .
                    fcb       $00                 * 4E75 00             .
                    fcb       $00                 * 4E76 00             .
                    fcb       $00                 * 4E77 00             .
                    fcb       $00                 * 4E78 00             .
                    fcb       $00                 * 4E79 00             .
                    fcb       $00                 * 4E7A 00             .
                    fcb       $00                 * 4E7B 00             .
                    fcb       $00                 * 4E7C 00             .
                    fcb       $00                 * 4E7D 00             .
                    fcb       $00                 * 4E7E 00             .
                    fcb       $00                 * 4E7F 00             .
                    fcb       $00                 * 4E80 00             .
                    fcb       $00                 * 4E81 00             .
                    fcb       $00                 * 4E82 00             .
                    fcb       $00                 * 4E83 00             .
                    fcb       $00                 * 4E84 00             .
                    fcb       $00                 * 4E85 00             .
                    fcb       $00                 * 4E86 00             .
                    fcb       $00                 * 4E87 00             .
                    fcb       $00                 * 4E88 00             .
                    fcb       $00                 * 4E89 00             .
                    fcb       $00                 * 4E8A 00             .
                    fcb       $00                 * 4E8B 00             .
                    fcb       $00                 * 4E8C 00             .
                    fcb       $00                 * 4E8D 00             .
                    fcb       $00                 * 4E8E 00             .
                    fcb       $00                 * 4E8F 00             .
                    fcb       $00                 * 4E90 00             .
                    fcb       $00                 * 4E91 00             .
                    fcb       $00                 * 4E92 00             .
                    fcb       $00                 * 4E93 00             .
                    fcb       $00                 * 4E94 00             .
                    fcb       $00                 * 4E95 00             .
                    fcb       $00                 * 4E96 00             .
                    fcb       $00                 * 4E97 00             .
                    fcb       $00                 * 4E98 00             .
                    fcb       $00                 * 4E99 00             .
                    fcb       $00                 * 4E9A 00             .
                    fcb       $00                 * 4E9B 00             .
                    fcb       $00                 * 4E9C 00             .
                    fcb       $00                 * 4E9D 00             .
                    fcb       $00                 * 4E9E 00             .
                    fcb       $00                 * 4E9F 00             .
                    fcb       $00                 * 4EA0 00             .
                    fcb       $00                 * 4EA1 00             .
                    fcb       $00                 * 4EA2 00             .
                    fcb       $00                 * 4EA3 00             .
                    fcb       $00                 * 4EA4 00             .
                    fcb       $00                 * 4EA5 00             .
                    fcb       $00                 * 4EA6 00             .
                    fcb       $C4                 * 4EA7 C4             D
                    fcb       $03                 * 4EA8 03             .
                    fcb       $A4                 * 4EA9 A4             $
                    fcb       $03                 * 4EAA 03             .
                    fcb       $A2                 * 4EAB A2             "
                    fcb       $03                 * 4EAC 03             .
                    fcb       $A0                 * 4EAD A0
                    fcb       $03                 * 4EAE 03             .
                    fcb       $9E                 * 4EAF 9E             .
                    fcb       $03                 * 4EB0 03             .
                    fcb       $9C                 * 4EB1 9C             .
                    fcb       $03                 * 4EB2 03             .
                    fcb       $9A                 * 4EB3 9A             .
                    fcb       $03                 * 4EB4 03             .
                    fcb       $98                 * 4EB5 98             .
                    fcb       $03                 * 4EB6 03             .
                    fcb       $B2                 * 4EB7 B2             2
                    fcb       $03                 * 4EB8 03             .
                    fcb       $B0                 * 4EB9 B0             0
                    fcb       $03                 * 4EBA 03             .
                    fcb       $AE                 * 4EBB AE             .
                    fcb       $03                 * 4EBC 03             .
                    fcb       $AC                 * 4EBD AC             ,
                    fcb       $03                 * 4EBE 03             .
                    fcb       $AA                 * 4EBF AA             *
                    fcb       $03                 * 4EC0 03             .
                    fcb       $A8                 * 4EC1 A8             (
                    fcb       $03                 * 4EC2 03             .
                    fcb       $A6                 * 4EC3 A6             &
                    fcb       $03                 * 4EC4 03             .
                    fcb       $C0                 * 4EC5 C0             @
                    fcb       $03                 * 4EC6 03             .
                    fcb       $BE                 * 4EC7 BE             >
                    fcb       $03                 * 4EC8 03             .
                    fcb       $BC                 * 4EC9 BC             <
                    fcb       $03                 * 4ECA 03             .
                    fcb       $BA                 * 4ECB BA             :
                    fcb       $03                 * 4ECC 03             .
                    fcb       $B8                 * 4ECD B8             8
                    fcb       $03                 * 4ECE 03             .
                    fcb       $B6                 * 4ECF B6             6
                    fcb       $03                 * 4ED0 03             .
                    fcb       $B4                 * 4ED1 B4             4
                    fcb       $03                 * 4ED2 03             .
                    fcb       $CE                 * 4ED3 CE             N
                    fcb       $03                 * 4ED4 03             .
                    fcb       $CC                 * 4ED5 CC             L
                    fcb       $03                 * 4ED6 03             .
                    fcb       $CA                 * 4ED7 CA             J
                    fcb       $03                 * 4ED8 03             .
                    fcb       $C8                 * 4ED9 C8             H
                    fcb       $03                 * 4EDA 03             .
                    fcb       $C6                 * 4EDB C6             F
                    fcb       $03                 * 4EDC 03             .
                    fcb       $C4                 * 4EDD C4             D
                    fcb       $03                 * 4EDE 03             .
                    fcb       $C2                 * 4EDF C2             B
                    fcb       $03                 * 4EE0 03             .
                    fcb       $2E                 * 4EE1 2E             .
                    fcb       $03                 * 4EE2 03             .
                    fcb       $2C                 * 4EE3 2C             ,
                    fcb       $03                 * 4EE4 03             .
                    fcb       $2A                 * 4EE5 2A             *
                    fcb       $03                 * 4EE6 03             .
                    fcb       $28                 * 4EE7 28             (
                    fcb       $03                 * 4EE8 03             .
                    fcb       $26                 * 4EE9 26             &
                    fcb       $03                 * 4EEA 03             .
                    fcb       $D2                 * 4EEB D2             R
                    fcb       $03                 * 4EEC 03             .
                    fcb       $D0                 * 4EED D0             P
                    fcb       $03                 * 4EEE 03             .
                    fcb       $3C                 * 4EEF 3C             <
                    fcb       $03                 * 4EF0 03             .
                    fcb       $3A                 * 4EF1 3A             :
                    fcb       $03                 * 4EF2 03             .
                    fcb       $38                 * 4EF3 38             8
                    fcb       $03                 * 4EF4 03             .
                    fcb       $36                 * 4EF5 36             6
                    fcb       $03                 * 4EF6 03             .
                    fcb       $34                 * 4EF7 34             4
                    fcb       $03                 * 4EF8 03             .
                    fcb       $32                 * 4EF9 32             2
                    fcb       $03                 * 4EFA 03             .
                    fcb       $30                 * 4EFB 30             0
                    fcb       $03                 * 4EFC 03             .
                    fcb       $4A                 * 4EFD 4A             J
                    fcb       $03                 * 4EFE 03             .
                    fcb       $48                 * 4EFF 48             H
                    fcb       $03                 * 4F00 03             .
                    fcb       $46                 * 4F01 46             F
                    fcb       $03                 * 4F02 03             .
                    fcb       $44                 * 4F03 44             D
                    fcb       $03                 * 4F04 03             .
                    fcb       $42                 * 4F05 42             B
                    fcb       $03                 * 4F06 03             .
                    fcb       $40                 * 4F07 40             @
                    fcb       $03                 * 4F08 03             .
                    fcb       $3E                 * 4F09 3E             >
                    fcb       $03                 * 4F0A 03             .
                    fcb       $58                 * 4F0B 58             X
                    fcb       $03                 * 4F0C 03             .
                    fcb       $56                 * 4F0D 56             V
                    fcb       $03                 * 4F0E 03             .
                    fcb       $54                 * 4F0F 54             T
                    fcb       $03                 * 4F10 03             .
                    fcb       $52                 * 4F11 52             R
                    fcb       $03                 * 4F12 03             .
                    fcb       $50                 * 4F13 50             P
                    fcb       $03                 * 4F14 03             .
                    fcb       $4E                 * 4F15 4E             N
                    fcb       $03                 * 4F16 03             .
                    fcb       $4C                 * 4F17 4C             L
                    fcb       $01                 * 4F18 01             .
                    fcb       $0E                 * 4F19 0E             .
                    fcb       $01                 * 4F1A 01             .
                    fcb       $0A                 * 4F1B 0A             .
                    fcb       $01                 * 4F1C 01             .
                    fcb       $06                 * 4F1D 06             .
                    fcb       $03                 * 4F1E 03             .
                    fcb       $60                 * 4F1F 60             `
                    fcb       $03                 * 4F20 03             .
                    fcb       $5E                 * 4F21 5E             ^
                    fcb       $03                 * 4F22 03             .
                    fcb       $5C                 * 4F23 5C             \
                    fcb       $03                 * 4F24 03             .
                    fcb       $5A                 * 4F25 5A             Z
                    fcb       $01                 * 4F26 01             .
                    fcb       $2A                 * 4F27 2A             *
                    fcb       $01                 * 4F28 01             .
                    fcb       $26                 * 4F29 26             &
                    fcb       $01                 * 4F2A 01             .
                    fcb       $22                 * 4F2B 22             "
                    fcb       $01                 * 4F2C 01             .
                    fcb       $1E                 * 4F2D 1E             .
                    fcb       $01                 * 4F2E 01             .
                    fcb       $1A                 * 4F2F 1A             .
                    fcb       $01                 * 4F30 01             .
                    fcb       $16                 * 4F31 16             .
                    fcb       $01                 * 4F32 01             .
                    fcb       $12                 * 4F33 12             .
                    fcb       $01                 * 4F34 01             .
                    fcb       $46                 * 4F35 46             F
                    fcb       $01                 * 4F36 01             .
                    fcb       $42                 * 4F37 42             B
                    fcb       $01                 * 4F38 01             .
                    fcb       $3E                 * 4F39 3E             >
                    fcb       $01                 * 4F3A 01             .
                    fcb       $3A                 * 4F3B 3A             :
                    fcb       $01                 * 4F3C 01             .
                    fcb       $36                 * 4F3D 36             6
                    fcb       $01                 * 4F3E 01             .
                    fcb       $32                 * 4F3F 32             2
                    fcb       $01                 * 4F40 01             .
                    fcb       $2E                 * 4F41 2E             .
                    fcb       $01                 * 4F42 01             .
                    fcb       $62                 * 4F43 62             b
                    fcb       $01                 * 4F44 01             .
                    fcb       $5E                 * 4F45 5E             ^
                    fcb       $01                 * 4F46 01             .
                    fcb       $5A                 * 4F47 5A             Z
                    fcb       $01                 * 4F48 01             .
                    fcb       $56                 * 4F49 56             V
                    fcb       $01                 * 4F4A 01             .
                    fcb       $52                 * 4F4B 52             R
                    fcb       $01                 * 4F4C 01             .
                    fcb       $4E                 * 4F4D 4E             N
                    fcb       $01                 * 4F4E 01             .
                    fcb       $4A                 * 4F4F 4A             J
                    fcb       $01                 * 4F50 01             .
                    fcb       $7E                 * 4F51 7E             ~
                    fcb       $01                 * 4F52 01             .
                    fcb       $7A                 * 4F53 7A             z
                    fcb       $01                 * 4F54 01             .
                    fcb       $76                 * 4F55 76             v
                    fcb       $01                 * 4F56 01             .
                    fcb       $72                 * 4F57 72             r
                    fcb       $01                 * 4F58 01             .
                    fcb       $6E                 * 4F59 6E             n
                    fcb       $01                 * 4F5A 01             .
                    fcb       $6A                 * 4F5B 6A             j
                    fcb       $01                 * 4F5C 01             .
                    fcb       $66                 * 4F5D 66             f
                    fcb       $01                 * 4F5E 01             .
                    fcb       $9A                 * 4F5F 9A             .
                    fcb       $01                 * 4F60 01             .
                    fcb       $96                 * 4F61 96             .
                    fcb       $01                 * 4F62 01             .
                    fcb       $92                 * 4F63 92             .
                    fcb       $01                 * 4F64 01             .
                    fcb       $8E                 * 4F65 8E             .
                    fcb       $01                 * 4F66 01             .
                    fcb       $8A                 * 4F67 8A             .
                    fcb       $01                 * 4F68 01             .
                    fcb       $86                 * 4F69 86             .
                    fcb       $01                 * 4F6A 01             .
                    fcb       $82                 * 4F6B 82             .
                    fcb       $01                 * 4F6C 01             .
                    fcb       $B6                 * 4F6D B6             6
                    fcb       $01                 * 4F6E 01             .
                    fcb       $B2                 * 4F6F B2             2
                    fcb       $01                 * 4F70 01             .
                    fcb       $AE                 * 4F71 AE             .
                    fcb       $01                 * 4F72 01             .
                    fcb       $AA                 * 4F73 AA             *
                    fcb       $01                 * 4F74 01             .
                    fcb       $A6                 * 4F75 A6             &
                    fcb       $01                 * 4F76 01             .
                    fcb       $A2                 * 4F77 A2             "
                    fcb       $01                 * 4F78 01             .
                    fcb       $9E                 * 4F79 9E             .
                    fcb       $01                 * 4F7A 01             .
                    fcb       $D2                 * 4F7B D2             R
                    fcb       $01                 * 4F7C 01             .
                    fcb       $CE                 * 4F7D CE             N
                    fcb       $01                 * 4F7E 01             .
                    fcb       $CA                 * 4F7F CA             J
                    fcb       $01                 * 4F80 01             .
                    fcb       $C6                 * 4F81 C6             F
                    fcb       $01                 * 4F82 01             .
                    fcb       $C2                 * 4F83 C2             B
                    fcb       $01                 * 4F84 01             .
                    fcb       $BE                 * 4F85 BE             >
                    fcb       $01                 * 4F86 01             .
                    fcb       $BA                 * 4F87 BA             :
                    fcb       $01                 * 4F88 01             .
                    fcb       $EE                 * 4F89 EE             n
                    fcb       $01                 * 4F8A 01             .
                    fcb       $EA                 * 4F8B EA             j
                    fcb       $01                 * 4F8C 01             .
                    fcb       $E6                 * 4F8D E6             f
                    fcb       $01                 * 4F8E 01             .
                    fcb       $E2                 * 4F8F E2             b
                    fcb       $01                 * 4F90 01             .
                    fcb       $DE                 * 4F91 DE             ^
                    fcb       $01                 * 4F92 01             .
                    fcb       $DA                 * 4F93 DA             Z
                    fcb       $01                 * 4F94 01             .
                    fcb       $D6                 * 4F95 D6             V
                    fcb       $02                 * 4F96 02             .
                    fcb       $0A                 * 4F97 0A             .
                    fcb       $02                 * 4F98 02             .
                    fcb       $06                 * 4F99 06             .
                    fcb       $02                 * 4F9A 02             .
                    fcb       $02                 * 4F9B 02             .
                    fcb       $01                 * 4F9C 01             .
                    fcb       $FE                 * 4F9D FE             ~
                    fcb       $01                 * 4F9E 01             .
                    fcb       $FA                 * 4F9F FA             z
                    fcb       $01                 * 4FA0 01             .
                    fcb       $F6                 * 4FA1 F6             v
                    fcb       $01                 * 4FA2 01             .
                    fcb       $F2                 * 4FA3 F2             r
                    fcb       $02                 * 4FA4 02             .
                    fcb       $26                 * 4FA5 26             &
                    fcb       $02                 * 4FA6 02             .
                    fcb       $22                 * 4FA7 22             "
                    fcb       $02                 * 4FA8 02             .
                    fcb       $1E                 * 4FA9 1E             .
                    fcb       $02                 * 4FAA 02             .
                    fcb       $1A                 * 4FAB 1A             .
                    fcb       $02                 * 4FAC 02             .
                    fcb       $16                 * 4FAD 16             .
                    fcb       $02                 * 4FAE 02             .
                    fcb       $12                 * 4FAF 12             .
                    fcb       $02                 * 4FB0 02             .
                    fcb       $0E                 * 4FB1 0E             .
                    fcb       $02                 * 4FB2 02             .
                    fcb       $42                 * 4FB3 42             B
                    fcb       $02                 * 4FB4 02             .
                    fcb       $3E                 * 4FB5 3E             >
                    fcb       $02                 * 4FB6 02             .
                    fcb       $3A                 * 4FB7 3A             :
                    fcb       $02                 * 4FB8 02             .
                    fcb       $36                 * 4FB9 36             6
                    fcb       $02                 * 4FBA 02             .
                    fcb       $32                 * 4FBB 32             2
                    fcb       $02                 * 4FBC 02             .
                    fcb       $2E                 * 4FBD 2E             .
                    fcb       $02                 * 4FBE 02             .
                    fcb       $2A                 * 4FBF 2A             *
                    fcb       $02                 * 4FC0 02             .
                    fcb       $5E                 * 4FC1 5E             ^
                    fcb       $02                 * 4FC2 02             .
                    fcb       $5A                 * 4FC3 5A             Z
                    fcb       $02                 * 4FC4 02             .
                    fcb       $56                 * 4FC5 56             V
                    fcb       $02                 * 4FC6 02             .
                    fcb       $52                 * 4FC7 52             R
                    fcb       $02                 * 4FC8 02             .
                    fcb       $4E                 * 4FC9 4E             N
                    fcb       $02                 * 4FCA 02             .
                    fcb       $4A                 * 4FCB 4A             J
                    fcb       $02                 * 4FCC 02             .
                    fcb       $46                 * 4FCD 46             F
                    fcb       $02                 * 4FCE 02             .
                    fcb       $7A                 * 4FCF 7A             z
                    fcb       $02                 * 4FD0 02             .
                    fcb       $76                 * 4FD1 76             v
                    fcb       $02                 * 4FD2 02             .
                    fcb       $72                 * 4FD3 72             r
                    fcb       $02                 * 4FD4 02             .
                    fcb       $6E                 * 4FD5 6E             n
                    fcb       $02                 * 4FD6 02             .
                    fcb       $6A                 * 4FD7 6A             j
                    fcb       $02                 * 4FD8 02             .
                    fcb       $66                 * 4FD9 66             f
                    fcb       $02                 * 4FDA 02             .
                    fcb       $62                 * 4FDB 62             b
                    fcb       $02                 * 4FDC 02             .
                    fcb       $96                 * 4FDD 96             .
                    fcb       $02                 * 4FDE 02             .
                    fcb       $92                 * 4FDF 92             .
                    fcb       $02                 * 4FE0 02             .
                    fcb       $8E                 * 4FE1 8E             .
                    fcb       $02                 * 4FE2 02             .
                    fcb       $8A                 * 4FE3 8A             .
                    fcb       $02                 * 4FE4 02             .
                    fcb       $86                 * 4FE5 86             .
                    fcb       $02                 * 4FE6 02             .
                    fcb       $82                 * 4FE7 82             .
                    fcb       $02                 * 4FE8 02             .
                    fcb       $7E                 * 4FE9 7E             ~
                    fcb       $02                 * 4FEA 02             .
                    fcb       $B2                 * 4FEB B2             2
                    fcb       $02                 * 4FEC 02             .
                    fcb       $AE                 * 4FED AE             .
                    fcb       $02                 * 4FEE 02             .
                    fcb       $AA                 * 4FEF AA             *
                    fcb       $02                 * 4FF0 02             .
                    fcb       $A6                 * 4FF1 A6             &
                    fcb       $02                 * 4FF2 02             .
                    fcb       $A2                 * 4FF3 A2             "
                    fcb       $02                 * 4FF4 02             .
                    fcb       $9E                 * 4FF5 9E             .
                    fcb       $02                 * 4FF6 02             .
                    fcb       $9A                 * 4FF7 9A             .
                    fcb       $02                 * 4FF8 02             .
                    fcb       $CE                 * 4FF9 CE             N
                    fcb       $02                 * 4FFA 02             .
                    fcb       $CA                 * 4FFB CA             J
                    fcb       $02                 * 4FFC 02             .
                    fcb       $C6                 * 4FFD C6             F
                    fcb       $02                 * 4FFE 02             .
                    fcb       $C2                 * 4FFF C2             B
                    fcb       $02                 * 5000 02             .
                    fcb       $BE                 * 5001 BE             >
                    fcb       $02                 * 5002 02             .
                    fcb       $BA                 * 5003 BA             :
                    fcb       $02                 * 5004 02             .
                    fcb       $B6                 * 5005 B6             6
                    fcb       $02                 * 5006 02             .
                    fcb       $EA                 * 5007 EA             j
                    fcb       $02                 * 5008 02             .
                    fcb       $E6                 * 5009 E6             f
                    fcb       $02                 * 500A 02             .
                    fcb       $E2                 * 500B E2             b
                    fcb       $02                 * 500C 02             .
                    fcb       $DE                 * 500D DE             ^
                    fcb       $02                 * 500E 02             .
                    fcb       $DA                 * 500F DA             Z
                    fcb       $02                 * 5010 02             .
                    fcb       $D6                 * 5011 D6             V
                    fcb       $02                 * 5012 02             .
                    fcb       $D2                 * 5013 D2             R
                    fcb       $03                 * 5014 03             .
                    fcb       $06                 * 5015 06             .
                    fcb       $03                 * 5016 03             .
                    fcb       $02                 * 5017 02             .
                    fcb       $02                 * 5018 02             .
                    fcb       $FE                 * 5019 FE             ~
                    fcb       $02                 * 501A 02             .
                    fcb       $FA                 * 501B FA             z
                    fcb       $02                 * 501C 02             .
                    fcb       $F6                 * 501D F6             v
                    fcb       $02                 * 501E 02             .
                    fcb       $F2                 * 501F F2             r
                    fcb       $02                 * 5020 02             .
                    fcb       $EE                 * 5021 EE             n
                    fcb       $03                 * 5022 03             .
                    fcb       $22                 * 5023 22             "
                    fcb       $03                 * 5024 03             .
                    fcb       $1E                 * 5025 1E             .
                    fcb       $03                 * 5026 03             .
                    fcb       $1A                 * 5027 1A             .
                    fcb       $03                 * 5028 03             .
                    fcb       $16                 * 5029 16             .
                    fcb       $03                 * 502A 03             .
                    fcb       $12                 * 502B 12             .
                    fcb       $03                 * 502C 03             .
                    fcb       $0E                 * 502D 0E             .
                    fcb       $03                 * 502E 03             .
                    fcb       $0A                 * 502F 0A             .
                    fcb       $00                 * 5030 00             .
                    fcb       $12                 * 5031 12             .
                    fcb       $03                 * 5032 03             .
                    fcb       $81                 * 5033 81             .
                    fcb       $03                 * 5034 03             .
                    fcb       $F6                 * 5035 F6             v
                    fcb       $03                 * 5036 03             .
                    fcb       $F4                 * 5037 F4             t
                    fcb       $04                 * 5038 04             .
                    fcb       $84                 * 5039 84             .
                    fcb       $03                 * 503A 03             .
                    fcb       $84                 * 503B 84             .
                    fcb       $03                 * 503C 03             .
                    fcb       $93                 * 503D 93             .
                    fcb       $03                 * 503E 03             .
                    fcb       $96                 * 503F 96             .
                    fcb       $03                 * 5040 03             .
                    fcb       $87                 * 5041 87             .
                    fcb       $03                 * 5042 03             .
                    fcb       $90                 * 5043 90             .
                    fcb       $03                 * 5044 03             .
                    fcb       $8A                 * 5045 8A             .
                    fcb       $03                 * 5046 03             .
                    fcb       $8D                 * 5047 8D             .
                    fcb       $00                 * 5048 00             .
                    fcb       $13                 * 5049 13             .
                    fcb       $00                 * 504A 00             .
                    fcb       $11                 * 504B 11             .
                    fcb       $00                 * 504C 00             .
                    fcb       $0F                 * 504D 0F             .
                    fcb       $00                 * 504E 00             .
                    fcb       $0D                 * 504F 0D             .
                    fcb       $00                 * 5050 00             .
                    fcb       $0B                 * 5051 0B             .
                    fcb       $00                 * 5052 00             .
                    fcb       $09                 * 5053 09             .
                    fcb       $00                 * 5054 00             .
                    fcb       $07                 * 5055 07             .
                    fcc       "c.asm"             * 5056 63 2E 61 73 6D c.asm
                    fcb       $00                 * 505B 00             .

                    emod
eom                 equ       *
                    end
