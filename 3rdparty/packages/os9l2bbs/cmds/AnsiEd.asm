                    nam       AnsiEd
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,_cstart,size

U0000               rmb       1
dpsiz               rmb       1
U0002               rmb       1
U0003               rmb       1
U0004               rmb       1
U0005               rmb       1
U0006               rmb       1
U0007               rmb       1
U0008               rmb       1
U0009               rmb       1
U000A               rmb       1
U000B               rmb       2
U000D               rmb       2
U000F               rmb       16
U001F               rmb       16
U002F               rmb       8
U0037               rmb       2
U0039               rmb       1
U003A               rmb       2
U003C               rmb       13
U0049               rmb       196
U010D               rmb       128
argv                rmb       2
argv_2              rmb       58
argc                rmb       1
argc_1              rmb       1
_sttop              rmb       2
memend              rmb       2
U01CF               rmb       2
U01D1               rmb       6
_mtop               rmb       2
_stbot              rmb       2
U01DB               rmb       2
U01DD               rmb       1
U01DE               rmb       9
U01E7               rmb       50
U0219               rmb       2
U021B               rmb       2
U021D               rmb       2
U021F               rmb       2
U0221               rmb       2
U0223               rmb       2
U0225               rmb       8192
U2225               rmb       1840
U2955               rmb       3680
U37B5               rmb       2
U37B7               rmb       10
U37C1               rmb       10
U37CB               rmb       2
U37CD               rmb       2
U37CF               rmb       1
U37D0               rmb       2
U37D2               rmb       2
U37D4               rmb       2
U37D6               rmb       14
end                 rmb       1
U37E5               rmb       895
size                equ       .

name                fcs       /AnsiEd/            * 000D 41 6E 73 69 45 E4 AnsiEd
                    fcb       $01                 * 0013 01             .

* ===== cstart.a =====

*
* move bytes (Y=From addr, U=To addr, X=Count)
*
movbytes            lda       ,Y+                 * get a byte                               * 0014 A6 A0          &
                    sta       ,U+                 * put a byte                               * 0016 A7 C0          '@
                    leax      -$01,X              * dec the count                            * 0018 30 1F          0.
                    bne       movbytes            * and round again                          * 001A 26 F8          &x
                    rts                           * 001C 39             9

_cstart             pshs      Y                   * save the top of mem                      * 001D 34 20          4
                    pshs      U                   * save the data beginning address          * 001F 34 40          4@

                    clra                          * setup to clear                           * 0021 4F             O
                    clrb                          * 256 bytes                                * 0022 5F             _
csta05              sta       ,U+                 * clear dp bytes                           * 0023 A7 C0          '@
                    decb                          * 0025 5A             Z
                    bne       csta05              * 0026 26 FB          &{

csta10              ldx       0,S                 * get the beginning of data address        * 0028 AE E4          .d
                    leau      0,X                 * (tfr x,u)                                * 002A 33 84          3.
                    leax      >$37E4,X            * get the end of bss address               * 002C 30 89 37 E4    0.7d
                    pshs      X                   * save it                                  * 0030 34 10          4.
                    leay      >etext,PC           * point to dp-data count word              * 0032 31 8D 3B 2B    1.;+

                    ldx       ,Y++                * get count of dp-data to be moved         * 0036 AE A1          .!
                    beq       csta15              * bra if none                              * 0038 27 04          '.
                    bsr       movbytes            * move dp data into position               * 003A 8D D8          .X
                    ldu       $02,S               * get beginning address again              * 003C EE 62          nb
csta15              leau      >dpsiz,U            * point to where non-dp should start       * 003E 33 C9 00 01    3I..
                    ldx       ,Y++                * get count of non-dp data to be moved     * 0042 AE A1          .!
                    beq       clrbss              * 0044 27 03          '.
                    bsr       movbytes            * move non-dp data into position           * 0046 8D CC          .L

* Clear the bss area - starts where
* the transferred data finished
                    clra                          * 0048 4F             O
clrbss              cmpu      0,S                 * reached the end?                         * 0049 11 A3 E4       .#d
                    beq       reldt               * bra if so                                * 004C 27 04          '.
                    sta       ,U+                 * clear it                                 * 004E A7 C0          '@
                    bra       clrbss              * 0050 20 F7           w

* now relocate the data-text references
reldt               ldu       $02,S               * restore to data bottom                   * 0052 EE 62          nb
                    ldd       ,Y++                * get data-text ref. count                 * 0054 EC A1          l!
                    beq       reldd               * 0056 27 07          '.
                    leax      >,PC                * point to text                            * 0058 30 8D FF A4    0..$
                    lbsr      patch               * patch them                               * 005C 17 01 03       ...

* and the data-data refs.
reldd               ldd       ,Y++                * get the count of data refs.              * 005F EC A1          l!
                    beq       restack             * bra if none                              * 0061 27 05          '.
                    leax      U0000,U             * u was already pointing there             * 0063 30 C4          0D
                    lbsr      patch               * 0065 17 00 FA       ..z

restack             leas      $04,S               * reset stack                              * 0068 32 64          2d
                    puls      X                   * restore 'memend'                         * 006A 35 10          5.
                    stx       >memend,U           * 006C AF C9 01 CD    /I.M

* process the params
* the stack pointer is back where it started so is
* pointing at the params
*
* the objective is to insert null chars at the end of each argument
* and fill in the argv vector with pointers to them

* first store the program name address
* (an extra name inserted here for just this purpose
* - undocumented as yet)
                    sty       >argv,U             * 0070 10 AF C9 01 8D ./I..

                    ldd       #1                  * at least one arg                         * 0075 CC 00 01       L..
                    std       >argc,U             * 0078 ED C9 01 C9    mI.I
                    leay      >argv_2,U           * point y at second slot                   * 007C 31 C9 01 8F    1I..
                    leax      0,S                 * point x at params                        * 0080 30 E4          0d
                    lda       ,X+                 * initialize                               * 0082 A6 80          &.

aloop               ldb       >argc_1,U           * 0084 E6 C9 01 CA    fI.J
                    cmpb      #29                 * about to overflow?                       * 0088 C1 1D          A.
                    beq       final               * 008A 27 54          'T
aloop10             cmpa      #13                 * is it EOL?                               * 008C 81 0D          ..
                    beq       final               * yes - reached the end of the list        * 008E 27 50          'P

                    cmpa      #32                 * is it a space?                           * 0090 81 20          .
                    beq       aloop20             * yes - try another                        * 0092 27 04          '.
                    cmpa      #44                 * is it a comma?                           * 0094 81 2C          .,
                    bne       aloop30             * no - a word has started                  * 0096 26 04          &.
aloop20             lda       ,X+                 * yes - bump                               * 0098 A6 80          &.
                    bra       aloop10             * and round again                          * 009A 20 F0           p

aloop30             cmpa      #34                 * quoted string?                           * 009C 81 22          ."
                    beq       aloop40             * yes                                      * 009E 27 04          '.
                    cmpa      #39                 * the other one?                           * 00A0 81 27          .'
                    bne       aloop60             * no - ordinary                            * 00A2 26 1E          &.

aloop40             stx       ,Y++                * save address in vector                   * 00A4 AF A1          /!
                    inc       >argc_1,U           * bump the arg count                       * 00A6 6C C9 01 CA    lI.J
                    pshs      A                   * save delimiter                           * 00AA 34 02          4.

qloop               lda       ,X+                 * get another                              * 00AC A6 80          &.
                    cmpa      #13                 * eol?                                     * 00AE 81 0D          ..
                    beq       aloop50             * 00B0 27 04          '.
                    cmpa      0,S                 * delimiter?                               * 00B2 A1 E4          !d
                    bne       qloop               * 00B4 26 F6          &v

aloop50             puls      B                   * clean stack                              * 00B6 35 04          5.
                    clr       -$01,X              * 00B8 6F 1F          o.
                    cmpa      #13                 * 00BA 81 0D          ..
                    beq       final               * 00BC 27 22          '"
                    lda       ,X+                 * 00BE A6 80          &.
                    bra       aloop               * 00C0 20 C2           B

aloop60             leax      -$01,X              * point at first char                      * 00C2 30 1F          0.
                    stx       ,Y++                * put address in vector                    * 00C4 AF A1          /!
                    leax      $01,X               * bump it back                             * 00C6 30 01          0.
                    inc       >argc_1,U           * bump the arg count                       * 00C8 6C C9 01 CA    lI.J

* at least one non-space char has been seen
aloop70             cmpa      #13                 * have                                     * 00CC 81 0D          ..
                    beq       loopend             * we                                       * 00CE 27 0C          '.
                    cmpa      #32                 * reached                                  * 00D0 81 20          .
                    beq       loopend             * the end?                                 * 00D2 27 08          '.
                    cmpa      #44                 * comma?                                   * 00D4 81 2C          .,
                    beq       loopend             * 00D6 27 04          '.
                    lda       ,X+                 * no - look further                        * 00D8 A6 80          &.
                    bra       aloop70             * 00DA 20 F0           p

loopend             clr       -$01,X              * yes - put in the null byte               * 00DC 6F 1F          o.
                    bra       aloop               * and look for the next word               * 00DE 20 A4           $

* now put the pointers on the stack
final               leax      >argv,U             * get the address of the arg vector        * 00E0 30 C9 01 8D    0I..
                    pshs      X                   * goes on the stack first                  * 00E4 34 10          4.
                    ldd       >argc,U             * get the arg count                        * 00E6 EC C9 01 C9    lI.I
                    pshs      D                   * stack it                                 * 00EA 34 06          4.
                    leay      U0000,U             * C progs. assume data & bss offset from y * 00EC 31 C4          1D

                    bsr       _fixtop             * set various variables                    * 00EE 8D 0A          ..

                    lbsr      main                * call the program                         * 00F0 17 00 89       ...

                    clr       ,-S                 * put a zero                               * 00F3 6F E2          ob
                    clr       ,-S                 * on the stack                             * 00F5 6F E2          ob
                    lbsr      exit                * and a dummy 'return address'             * 00F7 17 39 2F       .9/

* no return here
_fixtop             leax      >end,Y              * get the initial memory end address       * 00FA 30 A9 37 E4    0)7d
                    stx       >_mtop,Y            * it's the current memory top              * 00FE AF A9 01 D7    /).W
                    sts       >_sttop,Y           * this is really two bytes short!          * 0102 10 EF A9 01 CB .o).K
                    sts       >_stbot,Y           * 0107 10 EF A9 01 D9 .o).Y
                    ldd       #-126               * give ourselves some breating space       * 010C CC FF 82       L..

* on entry here, d holds the negative of a stack reservation request
_stkcheck           leax      D,S                 * calculate the requested size             * 010F 30 EB          0k
                    cmpx      >_stbot,Y           * is it lower than already reserved?       * 0111 AC A9 01 D9    ,).Y
                    bcc       stk10               * no - return                              * 0115 24 0A          $.
                    cmpx      >_mtop,Y            * yes - is it lower than possible?         * 0117 AC A9 01 D7    ,).W
                    bcs       fsterr              * yes - can't cope                         * 011B 25 1E          %.
                    stx       >_stbot,Y           * no - reserve it                          * 011D AF A9 01 D9    /).Y
stk10               rts                           * 0121 39             9

fixserr             fcc       "**** STACK OVERFLOW ****" * 0122 2A 2A 2A 2A 20 53 54 41 43 4B 20 4F 56 45 52 46 4C 4F 57 20 2A 2A 2A 2A **** STACK OVERFLOW ****
                    fcb       $0D                 * 013A 0D             .

fsterr              leax      <fixserr,PC         * address of error string                  * 013B 30 8C E4       0.d
                    ldb       #E$MemFul           * MEMORY FULL error number                 * 013E C6 CF          FO

erexit              pshs      B                   * stack the error number                   * 0140 34 04          4.
                    lda       #2                  * standard error output                    * 0142 86 02          ..
                    ldy       #100                * more than necessary                      * 0144 10 8E 00 64    ...d
                    os9       I$WritLn            * write it                                 * 0148 10 3F 8C       .?.
                    clr       ,-S                 * clear MSB of status                      * 014B 6F E2          ob
                    lbsr      _exit               * and out                                  * 014D 17 38 DF       .8_
* no return here

* stacksize()
* returns the extent of stack requested
* can be used by programmer for guidance
* in sizing memory at compile time
stacksiz            ldd       >_sttop,Y           * top of stack on entry                    * 0150 EC A9 01 CB    l).K
                    subd      >_stbot,Y           * subtract current reserved limit          * 0154 A3 A9 01 D9    #).Y
                    rts                           * 0158 39             9

* freemem()
* returns the current size of the free memory area
freemem             ldd       >_stbot,Y           * 0159 EC A9 01 D9    l).Y
                    subd      >_mtop,Y            * 015D A3 A9 01 D7    #).W
                    rts                           * 0161 39             9

* patch - adjust initialized data which refer to memory locations
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

patch               pshs      X                   * save the base                            * 0162 34 10          4.
                    leax      D,Y                 * half way up the list                     * 0164 30 AB          0+
                    leax      D,X                 * top of list                              * 0166 30 8B          0.
                    pshs      X                   * save it as place to stop                 * 0168 34 10          4.

* we do not come to this routine with
* a zero count (check!) so a test at the loop top
* is unnecessary
patch10             ldd       ,Y++                * get the offset                           * 016A EC A1          l!
                    leax      D,U                 * point to location                        * 016C 30 CB          0K
                    ldd       0,X                 * get the relative reference               * 016E EC 84          l.
                    addd      $02,S               * add in the base                          * 0170 E3 62          cb
                    std       0,X                 * store the absolute reference             * 0172 ED 84          m.
                    cmpy      0,S                 * reached the top?                         * 0174 10 AC E4       .,d
                    bne       patch10             * no - round again                         * 0177 26 F1          &q

                    leas      $04,S               * reset the stack                          * 0179 32 64          2d
                    rts                           * and return                               * 017B 39             9

main                pshs      U                   * 017C 34 40          4@
                    ldd       #-118               * 017E CC FF 8A       L..
                    lbsr      _stkcheck           * 0181 17 FF 8B       ...
                    leas      <$FFDE,S            * 0184 32 E8 DE       2h^
                    lbsr      L02DF               * 0187 17 01 55       ..U
                    lbsr      L035D               * 018A 17 01 D0       ..P
                    ldd       <$0026,S            * 018D EC E8 26       lh&
                    cmpd      #1                  * 0190 10 83 00 01    ....
                    ble       L01A2               * 0194 2F 0C          /.
                    ldx       <$0028,S            * 0196 AE E8 28       .h(
                    ldd       $02,X               * 0199 EC 02          l.
                    pshs      D                   * 019B 34 06          4.
                    lbsr      L0555               * 019D 17 03 B5       ..5
                    leas      $02,S               * 01A0 32 62          2b
L01A2               lbsr      L07B7               * 01A2 17 06 12       ...
                    ldd       <$0026,S            * 01A5 EC E8 26       lh&
                    cmpd      #2                  * 01A8 10 83 00 02    ....
                    ble       L01BB               * 01AC 2F 0D          /.
                    ldx       <$0028,S            * 01AE AE E8 28       .h(
                    ldd       $04,X               * 01B1 EC 04          l.
                    pshs      D                   * 01B3 34 06          4.
                    lbsr      L03E2               * 01B5 17 02 2A       ..*
                    lbra      L0284               * 01B8 16 00 C9       ..I
L01BB               ldd       #4                  * 01BB CC 00 04       L..
                    pshs      D                   * 01BE 34 06          4.
                    ldd       #4                  * 01C0 CC 00 04       L..
                    pshs      D                   * 01C3 34 06          4.
                    ldd       #6                  * 01C5 CC 00 06       L..
                    pshs      D                   * 01C8 34 06          4.
                    ldd       #40                 * 01CA CC 00 28       L.(
                    pshs      D                   * 01CD 34 06          4.
                    ldd       #6                  * 01CF CC 00 06       L..
                    pshs      D                   * 01D2 34 06          4.
                    ldd       #20                 * 01D4 CC 00 14       L..
                    pshs      D                   * 01D7 34 06          4.
                    ldd       #1                  * 01D9 CC 00 01       L..
                    pshs      D                   * 01DC 34 06          4.
                    ldd       #1                  * 01DE CC 00 01       L..
                    pshs      D                   * 01E1 34 06          4.
                    lbsr      L3A52               * 01E3 17 38 6C       .8l
                    leas      <$0010,S            * 01E6 32 E8 10       2h.
                    ldd       #2                  * 01E9 CC 00 02       L..
                    pshs      D                   * 01EC 34 06          4.
                    clra                          * 01EE 4F             O
                    clrb                          * 01EF 5F             _
                    pshs      D                   * 01F0 34 06          4.
                    ldd       #4                  * 01F2 CC 00 04       L..
                    pshs      D                   * 01F5 34 06          4.
                    ldd       #38                 * 01F7 CC 00 26       L.&
                    pshs      D                   * 01FA 34 06          4.
                    ldd       #7                  * 01FC CC 00 07       L..
                    pshs      D                   * 01FF 34 06          4.
                    ldd       #21                 * 0201 CC 00 15       L..
                    pshs      D                   * 0204 34 06          4.
                    clra                          * 0206 4F             O
                    clrb                          * 0207 5F             _
                    pshs      D                   * 0208 34 06          4.
                    ldd       #1                  * 020A CC 00 01       L..
                    pshs      D                   * 020D 34 06          4.
                    lbsr      L3A52               * 020F 17 38 40       .8@
                    leas      <$0010,S            * 0212 32 E8 10       2h.
                    ldd       #1                  * 0215 CC 00 01       L..
                    pshs      D                   * 0218 34 06          4.
                    lbsr      L252A               * 021A 17 23 0D       .#.
                    leas      $02,S               * 021D 32 62          2b
                    ldd       #1                  * 021F CC 00 01       L..
                    pshs      D                   * 0222 34 06          4.
                    lbsr      L3AEC               * 0224 17 38 C5       .8E
                    leas      $02,S               * 0227 32 62          2b
                    leax      >savprmpt,PC        * 0229 30 8D 24 41    0.$A
                    pshs      X                   * 022D 34 10          4.
                    lbsr      printf              * 022F 17 2B 1B       .+.
                    leas      $02,S               * 0232 32 62          2b
                    leax      >U0049,Y            * 0234 30 A9 00 49    0).I
                    pshs      X                   * 0238 34 10          4.
                    lbsr      L337C               * 023A 17 31 3F       .1?
                    leas      $02,S               * 023D 32 62          2b
                    ldd       #32                 * 023F CC 00 20       L.
                    pshs      D                   * 0242 34 06          4.
                    leax      $04,S               * 0244 30 64          0d
                    pshs      X                   * 0246 34 10          4.
                    clra                          * 0248 4F             O
                    clrb                          * 0249 5F             _
                    pshs      D                   * 024A 34 06          4.
                    lbsr      readln              * 024C 17 36 76       .6v
                    leas      $06,S               * 024F 32 66          2f
                    std       0,S                 * 0251 ED E4          md
                    cmpd      #1                  * 0253 10 83 00 01    ....
                    bgt       L0269               * 0257 2E 10          ..
                    ldx       <$0028,S            * 0259 AE E8 28       .h(
                    ldd       $02,X               * 025C EC 02          l.
                    pshs      D                   * 025E 34 06          4.
                    leax      $04,S               * 0260 30 64          0d
                    pshs      X                   * 0262 34 10          4.
                    lbsr      L3556               * 0264 17 32 EF       .2o
                    leas      $04,S               * 0267 32 64          2d
L0269               leax      $02,S               * 0269 30 62          0b
                    pshs      X                   * 026B 34 10          4.
                    lbsr      L03E2               * 026D 17 01 72       ..r
                    leas      $02,S               * 0270 32 62          2b
                    ldd       #1                  * 0272 CC 00 01       L..
                    pshs      D                   * 0275 34 06          4.
                    lbsr      L3A82               * 0277 17 38 08       .8.
                    leas      $02,S               * 027A 32 62          2b
                    ldd       #1                  * 027C CC 00 01       L..
                    pshs      D                   * 027F 34 06          4.
                    lbsr      L3A82               * 0281 17 37 FE       .7~
L0284               leas      $02,S               * 0284 32 62          2b
                    ldd       #1                  * 0286 CC 00 01       L..
                    pshs      D                   * 0289 34 06          4.
                    lbsr      L3A82               * 028B 17 37 F4       .7t
                    leas      $02,S               * 028E 32 62          2b
                    ldd       #1                  * 0290 CC 00 01       L..
                    pshs      D                   * 0293 34 06          4.
                    lbsr      L3AEC               * 0295 17 38 54       .8T
                    leas      $02,S               * 0298 32 62          2b
                    ldd       #1                  * 029A CC 00 01       L..
                    pshs      D                   * 029D 34 06          4.
                    lbsr      L3AFB               * 029F 17 38 59       .8Y
                    leas      $02,S               * 02A2 32 62          2b
                    leax      >Title,PC           * 02A4 30 8D 23 DA    0.#Z
                    pshs      X                   * 02A8 34 10          4.
                    lbsr      printf              * 02AA 17 2A A0       .*
                    leas      $02,S               * 02AD 32 62          2b
                    leax      >Copyright,PC       * 02AF 30 8D 23 F8    0.#x
                    pshs      X                   * 02B3 34 10          4.
                    lbsr      printf              * 02B5 17 2A 95       .*.
                    leas      $02,S               * 02B8 32 62          2b
                    leax      >License,PC         * 02BA 30 8D 24 16    0.$.
                    pshs      X                   * 02BE 34 10          4.
                    lbsr      printf              * 02C0 17 2A 8A       .*.
                    leas      $02,S               * 02C3 32 62          2b
                    leax      >Rights,PC          * 02C5 30 8D 24 34    0.$4
                    pshs      X                   * 02C9 34 10          4.
                    lbsr      printf              * 02CB 17 2A 7F       .*.
                    leas      $02,S               * 02CE 32 62          2b
                    ldd       #1                  * 02D0 CC 00 01       L..
                    pshs      D                   * 02D3 34 06          4.
                    lbsr      L3B00               * 02D5 17 38 28       .8(
                    leas      $02,S               * 02D8 32 62          2b
                    leas      <$0022,S            * 02DA 32 E8 22       2h"
                    puls      PC,U                * 02DD 35 C0          5@

* -- method --
L02DF               pshs      U                   * 02DF 34 40          4@
                    ldd       #-84                * 02E1 CC FF AC       L.,
                    lbsr      _stkcheck           * 02E4 17 FE 28       .~(
                    ldd       #1                  * 02E7 CC 00 01       L..
                    pshs      D                   * 02EA 34 06          4.
                    lbsr      L3AEC               * 02EC 17 37 FD       .7}
                    leas      $02,S               * 02EF 32 62          2b
                    ldd       #2                  * 02F1 CC 00 02       L..
                    pshs      D                   * 02F4 34 06          4.
                    clra                          * 02F6 4F             O
                    clrb                          * 02F7 5F             _
                    pshs      D                   * 02F8 34 06          4.
                    ldd       #23                 * 02FA CC 00 17       L..
                    pshs      D                   * 02FD 34 06          4.
                    ldd       #80                 * 02FF CC 00 50       L.P
                    pshs      D                   * 0302 34 06          4.
                    clra                          * 0304 4F             O
                    clrb                          * 0305 5F             _
                    pshs      D                   * 0306 34 06          4.
                    clra                          * 0308 4F             O
                    clrb                          * 0309 5F             _
                    pshs      D                   * 030A 34 06          4.
                    ldd       #1                  * 030C CC 00 01       L..
                    pshs      D                   * 030F 34 06          4.
                    ldd       #1                  * 0311 CC 00 01       L..
                    pshs      D                   * 0314 34 06          4.
                    lbsr      L3A52               * 0316 17 37 39       .79
                    leas      <$0010,S            * 0319 32 E8 10       2h.
                    clra                          * 031C 4F             O
                    clrb                          * 031D 5F             _
                    pshs      D                   * 031E 34 06          4.
                    ldd       #2                  * 0320 CC 00 02       L..
                    pshs      D                   * 0323 34 06          4.
                    ldd       #1                  * 0325 CC 00 01       L..
                    pshs      D                   * 0328 34 06          4.
                    ldd       #80                 * 032A CC 00 50       L.P
                    pshs      D                   * 032D 34 06          4.
                    ldd       #23                 * 032F CC 00 17       L..
                    pshs      D                   * 0332 34 06          4.
                    clra                          * 0334 4F             O
                    clrb                          * 0335 5F             _
                    pshs      D                   * 0336 34 06          4.
                    clra                          * 0338 4F             O
                    clrb                          * 0339 5F             _
                    pshs      D                   * 033A 34 06          4.
                    ldd       #1                  * 033C CC 00 01       L..
                    pshs      D                   * 033F 34 06          4.
                    lbsr      L3A52               * 0341 17 37 0E       .7.
                    leas      <$0010,S            * 0344 32 E8 10       2h.
                    ldd       #1                  * 0347 CC 00 01       L..
                    pshs      D                   * 034A 34 06          4.
                    lbsr      L3AEC               * 034C 17 37 9D       .7.
                    leas      $02,S               * 034F 32 62          2b
                    ldd       #1                  * 0351 CC 00 01       L..
                    pshs      D                   * 0354 34 06          4.
                    lbsr      L3A82               * 0356 17 37 29       .7)
                    leas      $02,S               * 0359 32 62          2b
                    puls      PC,U                * 035B 35 C0          5@

* -- method --
L035D               pshs      U                   * 035D 34 40          4@
                    ldd       #-75                * 035F CC FF B5       L.5
                    lbsr      _stkcheck           * 0362 17 FD AA       .}*
                    leas      -$05,S              * 0365 32 7B          2{
                    clra                          * 0367 4F             O
                    clrb                          * 0368 5F             _
                    lbra      L03BE               * 0369 16 00 52       ..R
L036C               clra                          * 036C 4F             O
                    clrb                          * 036D 5F             _
                    bra       L03AF               * 036E 20 3F           ?
L0370               ldd       $01,S               * 0370 EC 61          la
                    pshs      D                   * 0372 34 06          4.
                    ldd       #80                 * 0374 CC 00 50       L.P
                    lbsr      L365D               * 0377 17 32 E3       .2c
                    leax      >U2225,Y            * 037A 30 A9 22 25    0)"%
                    leax      D,X                 * 037E 30 8B          0.
                    ldd       $03,S               * 0380 EC 63          lc
                    leax      D,X                 * 0382 30 8B          0.
                    clra                          * 0384 4F             O
                    clrb                          * 0385 5F             _
                    stb       0,X                 * 0386 E7 84          g.
                    ldd       $01,S               * 0388 EC 61          la
                    pshs      D                   * 038A 34 06          4.
                    ldd       #160                * 038C CC 00 A0       L.
                    lbsr      L365D               * 038F 17 32 CB       .2K
                    leax      >U2955,Y            * 0392 30 A9 29 55    0))U
                    leax      D,X                 * 0396 30 8B          0.
                    tfr       X,D                 * 0398 1F 10          ..
                    pshs      D                   * 039A 34 06          4.
                    ldd       $05,S               * 039C EC 65          le
                    aslb                          * 039E 58             X
                    rola                          * 039F 49             I
                    addd      ,S++                * 03A0 E3 E1          ca
                    tfr       D,X                 * 03A2 1F 01          ..
                    ldd       >U0009,Y            * 03A4 EC A9 00 09    l)..
                    std       0,X                 * 03A8 ED 84          m.
                    ldd       $01,S               * 03AA EC 61          la
                    addd      #1                  * 03AC C3 00 01       C..
L03AF               std       $01,S               * 03AF ED 61          ma
                    ldd       $01,S               * 03B1 EC 61          la
                    cmpd      #23                 * 03B3 10 83 00 17    ....
                    blt       L0370               * 03B7 2D B7          -7
                    ldd       $03,S               * 03B9 EC 63          lc
                    addd      #1                  * 03BB C3 00 01       C..
L03BE               std       $03,S               * 03BE ED 63          mc
                    ldd       $03,S               * 03C0 EC 63          lc
                    cmpd      #80                 * 03C2 10 83 00 50    ...P
                    lblt      L036C               * 03C6 10 2D FF A2    .-."
                    ldd       #1                  * 03CA CC 00 01       L..
                    pshs      D                   * 03CD 34 06          4.
                    lbsr      L3AEC               * 03CF 17 37 1A       .7.
                    leas      $02,S               * 03D2 32 62          2b
                    ldd       #1                  * 03D4 CC 00 01       L..
                    std       >U0007,Y            * 03D7 ED A9 00 07    m)..
                    lbsr      L20F0               * 03DB 17 1D 12       ...
                    leas      $05,S               * 03DE 32 65          2e
                    puls      PC,U                * 03E0 35 C0          5@

* -- method --
L03E2               pshs      U                   * 03E2 34 40          4@
                    ldd       #-99                * 03E4 CC FF 9D       L..
                    lbsr      _stkcheck           * 03E7 17 FD 25       .}%
                    leas      -$0F,S              * 03EA 32 71          2q
                    clra                          * 03EC 4F             O
                    clrb                          * 03ED 5F             _
                    std       >U0009,Y            * 03EE ED A9 00 09    m)..
                    ldd       #2                  * 03F2 CC 00 02       L..
                    pshs      D                   * 03F5 34 06          4.
                    ldd       <$0015,S            * 03F7 EC E8 15       lh.
                    pshs      D                   * 03FA 34 06          4.
                    lbsr      creat               * 03FC 17 34 4A       .4J
                    leas      $04,S               * 03FF 32 64          2d
                    std       $0D,S               * 0401 ED 6D          mm
                    cmpd      #-1                 * 0403 10 83 FF FF    ....
                    bne       L0420               * 0407 26 17          &.
                    ldd       >U01DB,Y            * 0409 EC A9 01 DB    l).[
                    pshs      D                   * 040D 34 06          4.
                    leax      >CantOpen1,PC       * 040F 30 8D 23 13    0.#.
                    pshs      X                   * 0413 34 10          4.
                    lbsr      L2561               * 0415 17 21 49       .!I
                    leas      $04,S               * 0418 32 64          2d
                    ldd       #-1                 * 041A CC FF FF       L..
                    lbra      L0551               * 041D 16 01 31       ..1
L0420               ldd       #4                  * 0420 CC 00 04       L..
                    pshs      D                   * 0423 34 06          4.
                    ldd       #4                  * 0425 CC 00 04       L..
                    pshs      D                   * 0428 34 06          4.
                    ldd       #6                  * 042A CC 00 06       L..
                    pshs      D                   * 042D 34 06          4.
                    ldd       #30                 * 042F CC 00 1E       L..
                    pshs      D                   * 0432 34 06          4.
                    ldd       #3                  * 0434 CC 00 03       L..
                    pshs      D                   * 0437 34 06          4.
                    ldd       #10                 * 0439 CC 00 0A       L..
                    pshs      D                   * 043C 34 06          4.
                    ldd       #1                  * 043E CC 00 01       L..
                    pshs      D                   * 0441 34 06          4.
                    ldd       #1                  * 0443 CC 00 01       L..
                    pshs      D                   * 0446 34 06          4.
                    lbsr      L3A52               * 0448 17 36 07       .6.
                    leas      <$0010,S            * 044B 32 E8 10       2h.
                    ldd       #2                  * 044E CC 00 02       L..
                    pshs      D                   * 0451 34 06          4.
                    clra                          * 0453 4F             O
                    clrb                          * 0454 5F             _
                    pshs      D                   * 0455 34 06          4.
                    ldd       #4                  * 0457 CC 00 04       L..
                    pshs      D                   * 045A 34 06          4.
                    ldd       #28                 * 045C CC 00 1C       L..
                    pshs      D                   * 045F 34 06          4.
                    ldd       #4                  * 0461 CC 00 04       L..
                    pshs      D                   * 0464 34 06          4.
                    ldd       #11                 * 0466 CC 00 0B       L..
                    pshs      D                   * 0469 34 06          4.
                    clra                          * 046B 4F             O
                    clrb                          * 046C 5F             _
                    pshs      D                   * 046D 34 06          4.
                    ldd       #1                  * 046F CC 00 01       L..
                    pshs      D                   * 0472 34 06          4.
                    lbsr      L3A52               * 0474 17 35 DB       .5[
                    leas      <$0010,S            * 0477 32 E8 10       2h.
                    ldd       #1                  * 047A CC 00 01       L..
                    pshs      D                   * 047D 34 06          4.
                    lbsr      L3AEC               * 047F 17 36 6A       .6j
                    leas      $02,S               * 0482 32 62          2b
                    leax      >PutScrn,PC         * 0484 30 8D 22 B6    0."6
                    pshs      X                   * 0488 34 10          4.
                    lbsr      printf              * 048A 17 28 C0       .(@
                    leas      $02,S               * 048D 32 62          2b
                    leax      >U0049,Y            * 048F 30 A9 00 49    0).I
                    pshs      X                   * 0493 34 10          4.
                    lbsr      L337C               * 0495 17 2E E4       ..d
                    leas      $02,S               * 0498 32 62          2b
                    ldd       #1                  * 049A CC 00 01       L..
                    pshs      D                   * 049D 34 06          4.
                    leax      $02,S               * 049F 30 62          0b
                    pshs      X                   * 04A1 34 10          4.
                    clra                          * 04A3 4F             O
                    clrb                          * 04A4 5F             _
                    pshs      D                   * 04A5 34 06          4.
                    lbsr      read                * 04A7 17 33 FA       .3z
                    leas      $06,S               * 04AA 32 66          2f
                    ldb       0,S                 * 04AC E6 E4          fd
                    clra                          * 04AE 4F             O
                    andb      #223                * 04AF C4 DF          D_
                    cmpd      #78                 * 04B1 10 83 00 4E    ...N
                    beq       L04BA               * 04B5 27 03          '.
                    lbsr      L212A               * 04B7 17 1C 70       ..p
L04BA               ldd       #1                  * 04BA CC 00 01       L..
                    pshs      D                   * 04BD 34 06          4.
                    lbsr      L3AEC               * 04BF 17 36 2A       .6*
                    leas      $02,S               * 04C2 32 62          2b
                    leax      >ClrScrn,PC         * 04C4 30 8D 22 8F    0.".
                    pshs      X                   * 04C8 34 10          4.
                    lbsr      printf              * 04CA 17 28 80       .(.
                    leas      $02,S               * 04CD 32 62          2b
                    leax      >U0049,Y            * 04CF 30 A9 00 49    0).I
                    pshs      X                   * 04D3 34 10          4.
                    lbsr      L337C               * 04D5 17 2E A4       ..$
                    leas      $02,S               * 04D8 32 62          2b
                    ldd       #1                  * 04DA CC 00 01       L..
                    pshs      D                   * 04DD 34 06          4.
                    leax      $02,S               * 04DF 30 62          0b
                    pshs      X                   * 04E1 34 10          4.
                    clra                          * 04E3 4F             O
                    clrb                          * 04E4 5F             _
                    pshs      D                   * 04E5 34 06          4.
                    lbsr      read                * 04E7 17 33 BA       .3:
                    leas      $06,S               * 04EA 32 66          2f
                    ldb       0,S                 * 04EC E6 E4          fd
                    clra                          * 04EE 4F             O
                    andb      #223                * 04EF C4 DF          D_
                    cmpd      #89                 * 04F1 10 83 00 59    ...Y
                    bne       L051E               * 04F5 26 27          &'
                    ldd       #27                 * 04F7 CC 00 1B       L..
                    stb       $01,S               * 04FA E7 61          ga
                    ldd       #91                 * 04FC CC 00 5B       L.[
                    stb       $02,S               * 04FF E7 62          gb
                    ldd       #50                 * 0501 CC 00 32       L.2
                    stb       $03,S               * 0504 E7 63          gc
                    ldd       #74                 * 0506 CC 00 4A       L.J
                    stb       $04,S               * 0509 E7 64          gd
                    ldd       #4                  * 050B CC 00 04       L..
                    pshs      D                   * 050E 34 06          4.
                    leax      $03,S               * 0510 30 63          0c
                    pshs      X                   * 0512 34 10          4.
                    ldd       <$0011,S            * 0514 EC E8 11       lh.
                    pshs      D                   * 0517 34 06          4.
                    lbsr      write               * 0519 17 33 B9       .39
                    leas      $06,S               * 051C 32 66          2f
L051E               ldd       #1                  * 051E CC 00 01       L..
                    pshs      D                   * 0521 34 06          4.
                    lbsr      L3A82               * 0523 17 35 5C       .5\
                    leas      $02,S               * 0526 32 62          2b
                    ldd       #1                  * 0528 CC 00 01       L..
                    pshs      D                   * 052B 34 06          4.
                    lbsr      L3A82               * 052D 17 35 52       .5R
                    leas      $02,S               * 0530 32 62          2b
                    ldd       >U000D,Y            * 0532 EC A9 00 0D    l)..
                    pshs      D                   * 0536 34 06          4.
                    leax      >U0225,Y            * 0538 30 A9 02 25    0).%
                    pshs      X                   * 053C 34 10          4.
                    ldd       <$0011,S            * 053E EC E8 11       lh.
                    pshs      D                   * 0541 34 06          4.
                    lbsr      write               * 0543 17 33 8F       .3.
                    leas      $06,S               * 0546 32 66          2f
                    ldd       $0D,S               * 0548 EC 6D          lm
                    pshs      D                   * 054A 34 06          4.
                    lbsr      close               * 054C 17 32 E8       .2h
                    leas      $02,S               * 054F 32 62          2b
L0551               leas      $0F,S               * 0551 32 6F          2o
                    puls      PC,U                * 0553 35 C0          5@

* -- method --
L0555               pshs      U                   * 0555 34 40          4@
                    ldd       #-88                * 0557 CC FF A8       L.(
                    lbsr      _stkcheck           * 055A 17 FB B2       .{2
                    leas      -$04,S              * 055D 32 7C          2|
                    ldd       #1                  * 055F CC 00 01       L..
                    pshs      D                   * 0562 34 06          4.
                    ldd       $0A,S               * 0564 EC 6A          lj
                    pshs      D                   * 0566 34 06          4.
                    lbsr      open                * 0568 17 32 BD       .2=
                    leas      $04,S               * 056B 32 64          2d
                    std       $02,S               * 056D ED 62          mb
                    cmpd      #-1                 * 056F 10 83 FF FF    ....
                    bne       L058C               * 0573 26 17          &.
                    ldd       >U01DB,Y            * 0575 EC A9 01 DB    l).[
                    pshs      D                   * 0579 34 06          4.
                    leax      >CantOpen2,PC       * 057B 30 8D 21 F2    0.!r
                    pshs      X                   * 057F 34 10          4.
                    lbsr      L2561               * 0581 17 1F DD       ..]
                    leas      $04,S               * 0584 32 64          2d
                    ldd       #-1                 * 0586 CC FF FF       L..
                    lbra      L07B3               * 0589 16 02 27       ..'
L058C               clra                          * 058C 4F             O
                    clrb                          * 058D 5F             _
                    std       >U0219,Y            * 058E ED A9 02 19    m)..
                    clra                          * 0592 4F             O
                    clrb                          * 0593 5F             _
                    std       >U021B,Y            * 0594 ED A9 02 1B    m)..
                    clra                          * 0598 4F             O
                    clrb                          * 0599 5F             _
                    std       >U0221,Y            * 059A ED A9 02 21    m).!
                    clra                          * 059E 4F             O
                    clrb                          * 059F 5F             _
                    std       >U0223,Y            * 05A0 ED A9 02 23    m).#
                    clra                          * 05A4 4F             O
                    clrb                          * 05A5 5F             _
                    std       >U021D,Y            * 05A6 ED A9 02 1D    m)..
                    clra                          * 05AA 4F             O
                    clrb                          * 05AB 5F             _
                    std       >U021F,Y            * 05AC ED A9 02 1F    m)..
                    clra                          * 05B0 4F             O
                    clrb                          * 05B1 5F             _
                    pshs      D                   * 05B2 34 06          4.
                    ldd       #2                  * 05B4 CC 00 02       L..
                    pshs      D                   * 05B7 34 06          4.
                    ldd       #1                  * 05B9 CC 00 01       L..
                    pshs      D                   * 05BC 34 06          4.
                    ldd       #80                 * 05BE CC 00 50       L.P
                    pshs      D                   * 05C1 34 06          4.
                    ldd       #23                 * 05C3 CC 00 17       L..
                    pshs      D                   * 05C6 34 06          4.
                    clra                          * 05C8 4F             O
                    clrb                          * 05C9 5F             _
                    pshs      D                   * 05CA 34 06          4.
                    clra                          * 05CC 4F             O
                    clrb                          * 05CD 5F             _
                    pshs      D                   * 05CE 34 06          4.
                    ldd       #1                  * 05D0 CC 00 01       L..
                    pshs      D                   * 05D3 34 06          4.
                    lbsr      L3A52               * 05D5 17 34 7A       .4z
                    leas      <$0010,S            * 05D8 32 E8 10       2h.
                    leax      >ReadFile,PC        * 05DB 30 8D 21 A3    0.!#
                    pshs      X                   * 05DF 34 10          4.
                    lbsr      printf              * 05E1 17 27 69       .'i
                    leas      $02,S               * 05E4 32 62          2b
                    leax      >U0049,Y            * 05E6 30 A9 00 49    0).I
                    pshs      X                   * 05EA 34 10          4.
                    lbsr      L337C               * 05EC 17 2D 8D       .-.
                    leas      $02,S               * 05EF 32 62          2b
                    clra                          * 05F1 4F             O
                    clrb                          * 05F2 5F             _
                    bra       L060C               * 05F3 20 17           .
L05F5               ldd       #1                  * 05F5 CC 00 01       L..
                    pshs      D                   * 05F8 34 06          4.
                    leax      $03,S               * 05FA 30 63          0c
                    pshs      X                   * 05FC 34 10          4.
                    clra                          * 05FE 4F             O
                    clrb                          * 05FF 5F             _
                    pshs      D                   * 0600 34 06          4.
                    lbsr      read                * 0602 17 32 9F       .2.
                    leas      $06,S               * 0605 32 66          2f
                    ldb       $01,S               * 0607 E6 61          fa
                    clra                          * 0609 4F             O
                    andb      #223                * 060A C4 DF          D_
L060C               stb       $01,S               * 060C E7 61          ga
                    ldb       $01,S               * 060E E6 61          fa
                    cmpb      #79                 * 0610 C1 4F          AO
                    beq       L061A               * 0612 27 06          '.
                    ldb       $01,S               * 0614 E6 61          fa
                    cmpb      #83                 * 0616 C1 53          AS
                    bne       L05F5               * 0618 26 DB          &[
L061A               ldb       $01,S               * 061A E6 61          fa
                    cmpb      #83                 * 061C C1 53          AS
                    bne       L0625               * 061E 26 05          &.
                    ldd       #1                  * 0620 CC 00 01       L..
                    bra       L0627               * 0623 20 02           .
L0625               clra                          * 0625 4F             O
                    clrb                          * 0626 5F             _
L0627               std       >U0007,Y            * 0627 ED A9 00 07    m)..
                    leax      >AddLf,PC           * 062B 30 8D 21 84    0.!.
                    pshs      X                   * 062F 34 10          4.
                    lbsr      printf              * 0631 17 27 19       .'.
                    leas      $02,S               * 0634 32 62          2b
                    leax      >U0049,Y            * 0636 30 A9 00 49    0).I
                    pshs      X                   * 063A 34 10          4.
                    lbsr      L337C               * 063C 17 2D 3D       .-=
                    leas      $02,S               * 063F 32 62          2b
                    clra                          * 0641 4F             O
                    clrb                          * 0642 5F             _
                    bra       L065C               * 0643 20 17           .
L0645               ldd       #1                  * 0645 CC 00 01       L..
                    pshs      D                   * 0648 34 06          4.
                    leax      $02,S               * 064A 30 62          0b
                    pshs      X                   * 064C 34 10          4.
                    clra                          * 064E 4F             O
                    clrb                          * 064F 5F             _
                    pshs      D                   * 0650 34 06          4.
                    lbsr      read                * 0652 17 32 4F       .2O
                    leas      $06,S               * 0655 32 66          2f
                    ldb       0,S                 * 0657 E6 E4          fd
                    clra                          * 0659 4F             O
                    andb      #223                * 065A C4 DF          D_
L065C               stb       0,S                 * 065C E7 E4          gd
                    ldb       0,S                 * 065E E6 E4          fd
                    cmpb      #89                 * 0660 C1 59          AY
                    beq       L066A               * 0662 27 06          '.
                    ldb       0,S                 * 0664 E6 E4          fd
                    cmpb      #78                 * 0666 C1 4E          AN
                    bne       L0645               * 0668 26 DB          &[
L066A               ldd       #1                  * 066A CC 00 01       L..
                    pshs      D                   * 066D 34 06          4.
                    lbsr      L3A82               * 066F 17 34 10       .4.
                    lbra      L0790               * 0672 16 01 1B       ...
L0675               ldd       >U0007,Y            * 0675 EC A9 00 07    l)..
                    bne       L06B2               * 0679 26 37          &7
                    ldd       >U000D,Y            * 067B EC A9 00 0D    l)..
                    addd      #1                  * 067F C3 00 01       C..
                    std       >U000D,Y            * 0682 ED A9 00 0D    m)..
                    subd      #1                  * 0686 83 00 01       ...
                    leax      >U0225,Y            * 0689 30 A9 02 25    0).%
                    leax      D,X                 * 068D 30 8B          0.
                    ldb       $01,S               * 068F E6 61          fa
                    stb       0,X                 * 0691 E7 84          g.
                    ldd       >U000D,Y            * 0693 EC A9 00 0D    l)..
                    cmpd      #8192               * 0697 10 83 20 00    .. .
                    blt       L06B2               * 069B 2D 15          -.
                    ldd       #1                  * 069D CC 00 01       L..
                    pshs      D                   * 06A0 34 06          4.
                    lbsr      L3AD8               * 06A2 17 34 33       .43
                    leas      $02,S               * 06A5 32 62          2b
                    ldd       >U000D,Y            * 06A7 EC A9 00 0D    l)..
                    addd      #-1                 * 06AB C3 FF FF       C..
                    std       >U000D,Y            * 06AE ED A9 00 0D    m)..
L06B2               ldb       $01,S               * 06B2 E6 61          fa
                    cmpb      #27                 * 06B4 C1 1B          A.
                    lbne      L076D               * 06B6 10 26 00 B3    .&.3
                    ldd       >U0005,Y            * 06BA EC A9 00 05    l)..
                    lbne      L076D               * 06BE 10 26 00 AB    .&.+
                    ldd       #1                  * 06C2 CC 00 01       L..
                    pshs      D                   * 06C5 34 06          4.
                    leax      $03,S               * 06C7 30 63          0c
                    pshs      X                   * 06C9 34 10          4.
                    ldd       $06,S               * 06CB EC 66          lf
                    pshs      D                   * 06CD 34 06          4.
                    lbsr      read                * 06CF 17 31 D2       .1R
                    leas      $06,S               * 06D2 32 66          2f
                    ldd       >U0007,Y            * 06D4 EC A9 00 07    l)..
                    bne       L0711               * 06D8 26 37          &7
                    ldd       >U000D,Y            * 06DA EC A9 00 0D    l)..
                    addd      #1                  * 06DE C3 00 01       C..
                    std       >U000D,Y            * 06E1 ED A9 00 0D    m)..
                    subd      #1                  * 06E5 83 00 01       ...
                    leax      >U0225,Y            * 06E8 30 A9 02 25    0).%
                    leax      D,X                 * 06EC 30 8B          0.
                    ldb       $01,S               * 06EE E6 61          fa
                    stb       0,X                 * 06F0 E7 84          g.
                    ldd       >U000D,Y            * 06F2 EC A9 00 0D    l)..
                    cmpd      #8192               * 06F6 10 83 20 00    .. .
                    blt       L0711               * 06FA 2D 15          -.
                    ldd       #1                  * 06FC CC 00 01       L..
                    pshs      D                   * 06FF 34 06          4.
                    lbsr      L3AD8               * 0701 17 33 D4       .3T
                    leas      $02,S               * 0704 32 62          2b
                    ldd       >U000D,Y            * 0706 EC A9 00 0D    l)..
                    addd      #-1                 * 070A C3 FF FF       C..
                    std       >U000D,Y            * 070D ED A9 00 0D    m)..
L0711               ldb       $01,S               * 0711 E6 61          fa
                    cmpb      #91                 * 0713 C1 5B          A[
                    bne       L076D               * 0715 26 56          &V
                    ldd       #1                  * 0717 CC 00 01       L..
                    std       >U0005,Y            * 071A ED A9 00 05    m)..
                    ldd       #1                  * 071E CC 00 01       L..
                    pshs      D                   * 0721 34 06          4.
                    leax      $03,S               * 0723 30 63          0c
                    pshs      X                   * 0725 34 10          4.
                    ldd       $06,S               * 0727 EC 66          lf
                    pshs      D                   * 0729 34 06          4.
                    lbsr      read                * 072B 17 31 76       .1v
                    leas      $06,S               * 072E 32 66          2f
                    ldd       >U0007,Y            * 0730 EC A9 00 07    l)..
                    bne       L076D               * 0734 26 37          &7
                    ldd       >U000D,Y            * 0736 EC A9 00 0D    l)..
                    addd      #1                  * 073A C3 00 01       C..
                    std       >U000D,Y            * 073D ED A9 00 0D    m)..
                    subd      #1                  * 0741 83 00 01       ...
                    leax      >U0225,Y            * 0744 30 A9 02 25    0).%
                    leax      D,X                 * 0748 30 8B          0.
                    ldb       $01,S               * 074A E6 61          fa
                    stb       0,X                 * 074C E7 84          g.
                    ldd       >U000D,Y            * 074E EC A9 00 0D    l)..
                    cmpd      #8192               * 0752 10 83 20 00    .. .
                    blt       L076D               * 0756 2D 15          -.
                    ldd       #1                  * 0758 CC 00 01       L..
                    pshs      D                   * 075B 34 06          4.
                    lbsr      L3AD8               * 075D 17 33 78       .3x
                    leas      $02,S               * 0760 32 62          2b
                    ldd       >U000D,Y            * 0762 EC A9 00 0D    l)..
                    addd      #-1                 * 0766 C3 FF FF       C..
                    std       >U000D,Y            * 0769 ED A9 00 0D    m)..
L076D               ldb       0,S                 * 076D E6 E4          fd
                    cmpb      #89                 * 076F C1 59          AY
                    bne       L0788               * 0771 26 15          &.
                    ldb       $01,S               * 0773 E6 61          fa
                    cmpb      #13                 * 0775 C1 0D          A.
                    bne       L0788               * 0777 26 0F          &.
                    ldb       $01,S               * 0779 E6 61          fa
                    sex                           * 077B 1D             .
                    pshs      D                   * 077C 34 06          4.
                    lbsr      L19C1               * 077E 17 12 40       ..@
                    leas      $02,S               * 0781 32 62          2b
                    ldd       #10                 * 0783 CC 00 0A       L..
                    bra       L078B               * 0786 20 03           .
L0788               ldb       $01,S               * 0788 E6 61          fa
                    sex                           * 078A 1D             .
L078B               pshs      D                   * 078B 34 06          4.
                    lbsr      L19C1               * 078D 17 12 31       ..1
L0790               leas      $02,S               * 0790 32 62          2b
                    ldd       #1                  * 0792 CC 00 01       L..
                    pshs      D                   * 0795 34 06          4.
                    leax      $03,S               * 0797 30 63          0c
                    pshs      X                   * 0799 34 10          4.
                    ldd       $06,S               * 079B EC 66          lf
                    pshs      D                   * 079D 34 06          4.
                    lbsr      read                * 079F 17 31 02       .1.
                    leas      $06,S               * 07A2 32 66          2f
                    std       -$02,S              * 07A4 ED 7E          m~
                    lbne      L0675               * 07A6 10 26 FE CB    .&~K
                    ldd       $02,S               * 07AA EC 62          lb
                    pshs      D                   * 07AC 34 06          4.
                    lbsr      close               * 07AE 17 30 86       .0.
                    leas      $02,S               * 07B1 32 62          2b
L07B3               leas      $04,S               * 07B3 32 64          2d
                    puls      PC,U                * 07B5 35 C0          5@

* -- method --
L07B7               pshs      U                   * 07B7 34 40          4@
                    ldd       #-120               * 07B9 CC FF 88       L..
                    lbsr      _stkcheck           * 07BC 17 F9 50       .yP
                    leas      <$FFDC,S            * 07BF 32 E8 DC       2h\
                    clra                          * 07C2 4F             O
                    clrb                          * 07C3 5F             _
                    pshs      D                   * 07C4 34 06          4.
                    lbsr      L252A               * 07C6 17 1D 61       ..a
                    leas      $02,S               * 07C9 32 62          2b
                    clra                          * 07CB 4F             O
                    clrb                          * 07CC 5F             _
                    pshs      D                   * 07CD 34 06          4.
                    ldd       #2                  * 07CF CC 00 02       L..
                    pshs      D                   * 07D2 34 06          4.
                    ldd       #1                  * 07D4 CC 00 01       L..
                    pshs      D                   * 07D7 34 06          4.
                    ldd       #80                 * 07D9 CC 00 50       L.P
                    pshs      D                   * 07DC 34 06          4.
                    ldd       #23                 * 07DE CC 00 17       L..
                    pshs      D                   * 07E1 34 06          4.
                    clra                          * 07E3 4F             O
                    clrb                          * 07E4 5F             _
                    pshs      D                   * 07E5 34 06          4.
                    clra                          * 07E7 4F             O
                    clrb                          * 07E8 5F             _
                    pshs      D                   * 07E9 34 06          4.
                    ldd       #1                  * 07EB CC 00 01       L..
                    pshs      D                   * 07EE 34 06          4.
                    lbsr      L3A52               * 07F0 17 32 5F       .2_
                    leas      <$0010,S            * 07F3 32 E8 10       2h.
                    ldd       #1                  * 07F6 CC 00 01       L..
                    pshs      D                   * 07F9 34 06          4.
                    lbsr      L3AEC               * 07FB 17 32 EE       .2n
                    leas      $02,S               * 07FE 32 62          2b
                    ldd       #1                  * 0800 CC 00 01       L..
                    pshs      D                   * 0803 34 06          4.
                    lbsr      L3A82               * 0805 17 32 7A       .2z
                    leas      $02,S               * 0808 32 62          2b
                    lbra      L14E4               * 080A 16 0C D7       ..W
L080D               clra                          * 080D 4F             O
                    clrb                          * 080E 5F             _
                    pshs      D                   * 080F 34 06          4.
                    ldd       #2                  * 0811 CC 00 02       L..
                    pshs      D                   * 0814 34 06          4.
                    ldd       #1                  * 0816 CC 00 01       L..
                    pshs      D                   * 0819 34 06          4.
                    ldd       #80                 * 081B CC 00 50       L.P
                    pshs      D                   * 081E 34 06          4.
                    ldd       #23                 * 0820 CC 00 17       L..
                    pshs      D                   * 0823 34 06          4.
                    clra                          * 0825 4F             O
                    clrb                          * 0826 5F             _
                    pshs      D                   * 0827 34 06          4.
                    clra                          * 0829 4F             O
                    clrb                          * 082A 5F             _
                    pshs      D                   * 082B 34 06          4.
                    ldd       #1                  * 082D CC 00 01       L..
                    pshs      D                   * 0830 34 06          4.
                    lbsr      L3A52               * 0832 17 32 1D       .2.
                    leas      <$0010,S            * 0835 32 E8 10       2h.
                    ldd       >U021B,Y            * 0838 EC A9 02 1B    l)..
                    addd      #1                  * 083C C3 00 01       C..
                    pshs      D                   * 083F 34 06          4.
                    ldd       >U0219,Y            * 0841 EC A9 02 19    l)..
                    addd      #1                  * 0845 C3 00 01       C..
                    pshs      D                   * 0848 34 06          4.
                    leax      >Status,PC          * 084A 30 8D 1F 8A    0...
                    pshs      X                   * 084E 34 10          4.
                    lbsr      printf              * 0850 17 24 FA       .$z
                    leas      $06,S               * 0853 32 66          2f
                    ldd       >U0007,Y            * 0855 EC A9 00 07    l)..
                    beq       L0861               * 0859 27 06          '.
                    leax      >Editing,PC         * 085B 30 8D 1F 8F    0...
                    bra       L0865               * 085F 20 04           .
L0861               leax      >Recording,PC       * 0861 30 8D 1F 93    0...
L0865               pshs      X                   * 0865 34 10          4.
                    lbsr      printf              * 0867 17 24 E3       .$c
                    leas      $02,S               * 086A 32 62          2b
                    ldd       >U021B,Y            * 086C EC A9 02 1B    l)..
                    pshs      D                   * 0870 34 06          4.
                    ldd       #80                 * 0872 CC 00 50       L.P
                    lbsr      L365D               * 0875 17 2D E5       .-e
                    leax      >U2225,Y            * 0878 30 A9 22 25    0)"%
                    leax      D,X                 * 087C 30 8B          0.
                    ldd       >U0219,Y            * 087E EC A9 02 19    l)..
                    leax      D,X                 * 0882 30 8B          0.
                    ldb       0,X                 * 0884 E6 84          f.
                    beq       L08B2               * 0886 27 2A          '*
                    ldd       >U021B,Y            * 0888 EC A9 02 1B    l)..
                    pshs      D                   * 088C 34 06          4.
                    ldd       #80                 * 088E CC 00 50       L.P
                    lbsr      L365D               * 0891 17 2D C9       .-I
                    leax      >U2225,Y            * 0894 30 A9 22 25    0)"%
                    leax      D,X                 * 0898 30 8B          0.
                    ldd       >U0219,Y            * 089A EC A9 02 19    l)..
                    leax      D,X                 * 089E 30 8B          0.
                    ldb       0,X                 * 08A0 E6 84          f.
                    sex                           * 08A2 1D             .
                    pshs      D                   * 08A3 34 06          4.
                    leax      >CharDump,PC        * 08A5 30 8D 1F 59    0..Y
                    pshs      X                   * 08A9 34 10          4.
                    lbsr      printf              * 08AB 17 24 9F       .$.
                    leas      $04,S               * 08AE 32 64          2d
                    bra       L08BD               * 08B0 20 0B           .
L08B2               leax      >Char,PC            * 08B2 30 8D 1F 57    0..W
                    pshs      X                   * 08B6 34 10          4.
                    lbsr      printf              * 08B8 17 24 92       .$.
                    leas      $02,S               * 08BB 32 62          2b
L08BD               leax      >Attrs,PC           * 08BD 30 8D 1F 55    0..U
                    pshs      X                   * 08C1 34 10          4.
                    lbsr      printf              * 08C3 17 24 87       .$.
                    leas      $02,S               * 08C6 32 62          2b
                    ldd       >U0009,Y            * 08C8 EC A9 00 09    l)..
                    anda      #1                  * 08CC 84 01          ..
                    clrb                          * 08CE 5F             _
                    std       -$02,S              * 08CF ED 7E          m~
                    beq       L08D9               * 08D1 27 06          '.
                    leax      >L281F,PC           * 08D3 30 8D 1F 48    0..H
                    bra       L08DD               * 08D7 20 04           .
L08D9               leax      >L2821,PC           * 08D9 30 8D 1F 44    0..D
L08DD               pshs      X                   * 08DD 34 10          4.
                    lbsr      printf              * 08DF 17 24 6B       .$k
                    leas      $02,S               * 08E2 32 62          2b
                    ldd       >U0009,Y            * 08E4 EC A9 00 09    l)..
                    anda      #2                  * 08E8 84 02          ..
                    clrb                          * 08EA 5F             _
                    std       -$02,S              * 08EB ED 7E          m~
                    beq       L08F5               * 08ED 27 06          '.
                    leax      >L2823,PC           * 08EF 30 8D 1F 30    0..0
                    bra       L08F9               * 08F3 20 04           .
L08F5               leax      >L2825,PC           * 08F5 30 8D 1F 2C    0..,
L08F9               pshs      X                   * 08F9 34 10          4.
                    lbsr      printf              * 08FB 17 24 4F       .$O
                    leas      $02,S               * 08FE 32 62          2b
                    ldd       >U0009,Y            * 0900 EC A9 00 09    l)..
                    anda      #4                  * 0904 84 04          ..
                    clrb                          * 0906 5F             _
                    std       -$02,S              * 0907 ED 7E          m~
                    beq       L0911               * 0909 27 06          '.
                    leax      >L2827,PC           * 090B 30 8D 1F 18    0...
                    bra       L0915               * 090F 20 04           .
L0911               leax      >L2829,PC           * 0911 30 8D 1F 14    0...
L0915               pshs      X                   * 0915 34 10          4.
                    lbsr      printf              * 0917 17 24 33       .$3
                    leas      $02,S               * 091A 32 62          2b
                    ldd       >U0009,Y            * 091C EC A9 00 09    l)..
                    anda      #8                  * 0920 84 08          ..
                    clrb                          * 0922 5F             _
                    std       -$02,S              * 0923 ED 7E          m~
                    beq       L092D               * 0925 27 06          '.
                    leax      >L282B,PC           * 0927 30 8D 1F 00    0...
                    bra       L0931               * 092B 20 04           .
L092D               leax      >L282D,PC           * 092D 30 8D 1E FC    0..|
L0931               pshs      X                   * 0931 34 10          4.
                    lbsr      printf              * 0933 17 24 17       .$.
                    leas      $02,S               * 0936 32 62          2b
                    ldd       >U0009,Y            * 0938 EC A9 00 09    l)..
                    anda      #16                 * 093C 84 10          ..
                    clrb                          * 093E 5F             _
                    std       -$02,S              * 093F ED 7E          m~
                    beq       L0949               * 0941 27 06          '.
                    leax      >L282F,PC           * 0943 30 8D 1E E8    0..h
                    bra       L094D               * 0947 20 04           .
L0949               leax      >L2831,PC           * 0949 30 8D 1E E4    0..d
L094D               pshs      X                   * 094D 34 10          4.
                    lbsr      printf              * 094F 17 23 FB       .#{
                    leas      $02,S               * 0952 32 62          2b
                    ldd       >U0009,Y            * 0954 EC A9 00 09    l)..
                    pshs      D                   * 0958 34 06          4.
                    ldd       #256                * 095A CC 01 00       L..
                    lbsr      L36BE               * 095D 17 2D 5E       .-^
                    beq       L09A2               * 0960 27 40          '@
                    ldd       >U0009,Y            * 0962 EC A9 00 09    l)..
                    pshs      D                   * 0966 34 06          4.
                    ldd       #16                 * 0968 CC 00 10       L..
                    lbsr      L36BE               * 096B 17 2D 50       .-P
                    aslb                          * 096E 58             X
                    rola                          * 096F 49             I
                    leax      >U001F,Y            * 0970 30 A9 00 1F    0)..
                    leax      D,X                 * 0974 30 8B          0.
                    ldd       0,X                 * 0976 EC 84          l.
                    pshs      D                   * 0978 34 06          4.
                    ldd       >U0009,Y            * 097A EC A9 00 09    l)..
                    clra                          * 097E 4F             O
                    andb      #240                * 097F C4 F0          Dp
                    pshs      D                   * 0981 34 06          4.
                    ldd       #16                 * 0983 CC 00 10       L..
                    lbsr      L3711               * 0986 17 2D 88       .-.
                    aslb                          * 0989 58             X
                    rola                          * 098A 49             I
                    leax      >U001F,Y            * 098B 30 A9 00 1F    0)..
                    leax      D,X                 * 098F 30 8B          0.
                    ldd       0,X                 * 0991 EC 84          l.
                    pshs      D                   * 0993 34 06          4.
                    leax      >ColorsOn,PC        * 0995 30 8D 1E 9A    0...
                    pshs      X                   * 0999 34 10          4.
                    lbsr      printf              * 099B 17 23 AF       .#/
                    leas      $06,S               * 099E 32 66          2f
                    bra       L09AD               * 09A0 20 0B           .
L09A2               leax      >ColorsBW,PC        * 09A2 30 8D 1E A0    0..
                    pshs      X                   * 09A6 34 10          4.
                    lbsr      printf              * 09A8 17 23 A2       .#"
                    leas      $02,S               * 09AB 32 62          2b
L09AD               leax      >U0049,Y            * 09AD 30 A9 00 49    0).I
                    pshs      X                   * 09B1 34 10          4.
                    lbsr      L337C               * 09B3 17 29 C6       .)F
                    leas      $02,S               * 09B6 32 62          2b
                    ldd       #1                  * 09B8 CC 00 01       L..
                    pshs      D                   * 09BB 34 06          4.
                    lbsr      L3A82               * 09BD 17 30 C2       .0B
                    leas      $02,S               * 09C0 32 62          2b
                    ldd       #1                  * 09C2 CC 00 01       L..
                    pshs      D                   * 09C5 34 06          4.
                    leax      <$0025,S            * 09C7 30 E8 25       0h%
                    pshs      X                   * 09CA 34 10          4.
                    clra                          * 09CC 4F             O
                    clrb                          * 09CD 5F             _
                    pshs      D                   * 09CE 34 06          4.
                    lbsr      read                * 09D0 17 2E D1       ..Q
                    leas      $06,S               * 09D3 32 66          2f
                    ldd       #1                  * 09D5 CC 00 01       L..
                    std       >U0005,Y            * 09D8 ED A9 00 05    m)..
                    ldb       <$0023,S            * 09DC E6 E8 23       fh#
                    sex                           * 09DF 1D             .
                    tfr       D,X                 * 09E0 1F 01          ..
                    lbra      L1463               * 09E2 16 0A 7E       ..~
L09E5               ldd       #4                  * 09E5 CC 00 04       L..
                    pshs      D                   * 09E8 34 06          4.
                    ldd       #4                  * 09EA CC 00 04       L..
                    pshs      D                   * 09ED 34 06          4.
                    ldd       #19                 * 09EF CC 00 13       L..
                    pshs      D                   * 09F2 34 06          4.
                    ldd       #40                 * 09F4 CC 00 28       L.(
                    pshs      D                   * 09F7 34 06          4.
                    ldd       #2                  * 09F9 CC 00 02       L..
                    pshs      D                   * 09FC 34 06          4.
                    ldd       #20                 * 09FE CC 00 14       L..
                    pshs      D                   * 0A01 34 06          4.
                    ldd       #1                  * 0A03 CC 00 01       L..
                    pshs      D                   * 0A06 34 06          4.
                    ldd       #1                  * 0A08 CC 00 01       L..
                    pshs      D                   * 0A0B 34 06          4.
                    lbsr      L3A52               * 0A0D 17 30 42       .0B
                    leas      <$0010,S            * 0A10 32 E8 10       2h.
                    ldd       #2                  * 0A13 CC 00 02       L..
                    pshs      D                   * 0A16 34 06          4.
                    clra                          * 0A18 4F             O
                    clrb                          * 0A19 5F             _
                    pshs      D                   * 0A1A 34 06          4.
                    ldd       #17                 * 0A1C CC 00 11       L..
                    pshs      D                   * 0A1F 34 06          4.
                    ldd       #38                 * 0A21 CC 00 26       L.&
                    pshs      D                   * 0A24 34 06          4.
                    ldd       #3                  * 0A26 CC 00 03       L..
                    pshs      D                   * 0A29 34 06          4.
                    ldd       #21                 * 0A2B CC 00 15       L..
                    pshs      D                   * 0A2E 34 06          4.
                    clra                          * 0A30 4F             O
                    clrb                          * 0A31 5F             _
                    pshs      D                   * 0A32 34 06          4.
                    ldd       #1                  * 0A34 CC 00 01       L..
                    pshs      D                   * 0A37 34 06          4.
                    lbsr      L3A52               * 0A39 17 30 16       .0.
                    leas      <$0010,S            * 0A3C 32 E8 10       2h.
                    ldd       #1                  * 0A3F CC 00 01       L..
                    pshs      D                   * 0A42 34 06          4.
                    lbsr      L3AEC               * 0A44 17 30 A5       .0%
                    leas      $02,S               * 0A47 32 62          2b
                    leax      >Help,PC            * 0A49 30 8D 1E 14    0...
                    pshs      X                   * 0A4D 34 10          4.
                    lbsr      printf              * 0A4F 17 22 FB       ."{
                    leas      $02,S               * 0A52 32 62          2b
                    leax      >Line,PC            * 0A54 30 8D 1E 27    0..'
                    pshs      X                   * 0A58 34 10          4.
                    lbsr      printf              * 0A5A 17 22 F0       ."p
                    leas      $02,S               * 0A5D 32 62          2b
                    leax      >AltG,PC            * 0A5F 30 8D 1E 44    0..D
                    pshs      X                   * 0A63 34 10          4.
                    lbsr      printf              * 0A65 17 22 E5       ."e
                    leas      $02,S               * 0A68 32 62          2b
                    leax      >AltR,PC            * 0A6A 30 8D 1E 53    0..S
                    pshs      X                   * 0A6E 34 10          4.
                    lbsr      printf              * 0A70 17 22 DA       ."Z
                    leas      $02,S               * 0A73 32 62          2b
                    leax      >AltE,PC            * 0A75 30 8D 1E 61    0..a
                    pshs      X                   * 0A79 34 10          4.
                    lbsr      printf              * 0A7B 17 22 CF       ."O
                    leas      $02,S               * 0A7E 32 62          2b
                    leax      >AltC,PC            * 0A80 30 8D 1E 6D    0..m
                    pshs      X                   * 0A84 34 10          4.
                    lbsr      printf              * 0A86 17 22 C4       ."D
                    leas      $02,S               * 0A89 32 62          2b
                    leax      >AltN,PC            * 0A8B 30 8D 1E 7C    0..|
                    pshs      X                   * 0A8F 34 10          4.
                    lbsr      printf              * 0A91 17 22 B9       ."9
                    leas      $02,S               * 0A94 32 62          2b
                    leax      >AltS,PC            * 0A96 30 8D 1E 93    0...
                    pshs      X                   * 0A9A 34 10          4.
                    lbsr      printf              * 0A9C 17 22 AE       .".
                    leas      $02,S               * 0A9F 32 62          2b
                    leax      >AltA,PC            * 0AA1 30 8D 1E AA    0..*
                    pshs      X                   * 0AA5 34 10          4.
                    lbsr      printf              * 0AA7 17 22 A3       ."#
                    leas      $02,S               * 0AAA 32 62          2b
                    leax      >AltP,PC            * 0AAC 30 8D 1E C4    0..D
                    pshs      X                   * 0AB0 34 10          4.
                    lbsr      printf              * 0AB2 17 22 98       .".
                    leas      $02,S               * 0AB5 32 62          2b
                    leax      >AltL,PC            * 0AB7 30 8D 1E DD    0..]
                    pshs      X                   * 0ABB 34 10          4.
                    lbsr      printf              * 0ABD 17 22 8D       .".
                    leas      $02,S               * 0AC0 32 62          2b
                    leax      >AltK,PC            * 0AC2 30 8D 1E EE    0..n
                    pshs      X                   * 0AC6 34 10          4.
                    lbsr      printf              * 0AC8 17 22 82       .".
                    leas      $02,S               * 0ACB 32 62          2b
                    leax      >AltZ,PC            * 0ACD 30 8D 1E FD    0..}
                    pshs      X                   * 0AD1 34 10          4.
                    lbsr      printf              * 0AD3 17 22 77       ."w
                    leas      $02,S               * 0AD6 32 62          2b
                    leax      >AltX,PC            * 0AD8 30 8D 1F 0B    0...
                    pshs      X                   * 0ADC 34 10          4.
                    lbsr      printf              * 0ADE 17 22 6C       ."l
                    leas      $02,S               * 0AE1 32 62          2b
                    leax      >AltQ,PC            * 0AE3 30 8D 1F 19    0...
                    pshs      X                   * 0AE7 34 10          4.
                    lbsr      printf              * 0AE9 17 22 61       ."a
                    leas      $02,S               * 0AEC 32 62          2b
                    ldd       #1                  * 0AEE CC 00 01       L..
                    pshs      D                   * 0AF1 34 06          4.
                    lbsr      L3ACA               * 0AF3 17 2F D4       ./T
                    leas      $02,S               * 0AF6 32 62          2b
L0AF8               clra                          * 0AF8 4F             O
                    clrb                          * 0AF9 5F             _
                    pshs      D                   * 0AFA 34 06          4.
                    lbsr      L3A35               * 0AFC 17 2F 36       ./6
                    leas      $02,S               * 0AFF 32 62          2b
                    cmpd      #-1                 * 0B01 10 83 FF FF    ....
                    beq       L0AF8               * 0B05 27 F1          'q
                    ldd       #1                  * 0B07 CC 00 01       L..
                    pshs      D                   * 0B0A 34 06          4.
                    lbsr      L3ACF               * 0B0C 17 2F C0       ./@
                    leas      $02,S               * 0B0F 32 62          2b
                    ldd       #1                  * 0B11 CC 00 01       L..
                    pshs      D                   * 0B14 34 06          4.
                    lbsr      L3A82               * 0B16 17 2F 69       ./i
                    leas      $02,S               * 0B19 32 62          2b
                    ldd       #1                  * 0B1B CC 00 01       L..
                    pshs      D                   * 0B1E 34 06          4.
                    lbsr      L3A82               * 0B20 17 2F 5F       ./_
                    lbra      L145E               * 0B23 16 09 38       ..8
L0B26               ldd       #4                  * 0B26 CC 00 04       L..
                    pshs      D                   * 0B29 34 06          4.
                    ldd       #4                  * 0B2B CC 00 04       L..
                    pshs      D                   * 0B2E 34 06          4.
                    ldd       #6                  * 0B30 CC 00 06       L..
                    pshs      D                   * 0B33 34 06          4.
                    ldd       #20                 * 0B35 CC 00 14       L..
                    pshs      D                   * 0B38 34 06          4.
                    ldd       #3                  * 0B3A CC 00 03       L..
                    pshs      D                   * 0B3D 34 06          4.
                    ldd       #5                  * 0B3F CC 00 05       L..
                    pshs      D                   * 0B42 34 06          4.
                    ldd       #1                  * 0B44 CC 00 01       L..
                    pshs      D                   * 0B47 34 06          4.
                    ldd       #1                  * 0B49 CC 00 01       L..
                    pshs      D                   * 0B4C 34 06          4.
                    lbsr      L3A52               * 0B4E 17 2F 01       ./.
                    leas      <$0010,S            * 0B51 32 E8 10       2h.
                    ldd       #2                  * 0B54 CC 00 02       L..
                    pshs      D                   * 0B57 34 06          4.
                    clra                          * 0B59 4F             O
                    clrb                          * 0B5A 5F             _
                    pshs      D                   * 0B5B 34 06          4.
                    ldd       #4                  * 0B5D CC 00 04       L..
                    pshs      D                   * 0B60 34 06          4.
                    ldd       #18                 * 0B62 CC 00 12       L..
                    pshs      D                   * 0B65 34 06          4.
                    ldd       #4                  * 0B67 CC 00 04       L..
                    pshs      D                   * 0B6A 34 06          4.
                    ldd       #6                  * 0B6C CC 00 06       L..
                    pshs      D                   * 0B6F 34 06          4.
                    clra                          * 0B71 4F             O
                    clrb                          * 0B72 5F             _
                    pshs      D                   * 0B73 34 06          4.
                    ldd       #1                  * 0B75 CC 00 01       L..
                    pshs      D                   * 0B78 34 06          4.
                    lbsr      L3A52               * 0B7A 17 2E D5       ..U
                    leas      <$0010,S            * 0B7D 32 E8 10       2h.
                    ldd       #1                  * 0B80 CC 00 01       L..
                    pshs      D                   * 0B83 34 06          4.
                    lbsr      L3AEC               * 0B85 17 2F 64       ./d
                    leas      $02,S               * 0B88 32 62          2b
                    leax      >Sure,PC            * 0B8A 30 8D 1E 91    0...
                    pshs      X                   * 0B8E 34 10          4.
                    lbsr      printf              * 0B90 17 21 BA       .!:
                    leas      $02,S               * 0B93 32 62          2b
                    leax      >U0049,Y            * 0B95 30 A9 00 49    0).I
                    pshs      X                   * 0B99 34 10          4.
                    lbsr      L337C               * 0B9B 17 27 DE       .'^
                    leas      $02,S               * 0B9E 32 62          2b
                    ldd       #1                  * 0BA0 CC 00 01       L..
                    pshs      D                   * 0BA3 34 06          4.
                    leax      <$0025,S            * 0BA5 30 E8 25       0h%
                    pshs      X                   * 0BA8 34 10          4.
                    clra                          * 0BAA 4F             O
                    clrb                          * 0BAB 5F             _
                    pshs      D                   * 0BAC 34 06          4.
                    lbsr      read                * 0BAE 17 2C F3       .,s
                    leas      $06,S               * 0BB1 32 66          2f
                    ldd       #1                  * 0BB3 CC 00 01       L..
                    pshs      D                   * 0BB6 34 06          4.
                    lbsr      L3A82               * 0BB8 17 2E C7       ..G
                    leas      $02,S               * 0BBB 32 62          2b
                    ldd       #1                  * 0BBD CC 00 01       L..
                    pshs      D                   * 0BC0 34 06          4.
                    lbsr      L3A82               * 0BC2 17 2E BD       ..=
                    leas      $02,S               * 0BC5 32 62          2b
                    ldb       <$0023,S            * 0BC7 E6 E8 23       fh#
                    clra                          * 0BCA 4F             O
                    andb      #223                * 0BCB C4 DF          D_
                    cmpd      #89                 * 0BCD 10 83 00 59    ...Y
                    lbne      L14E4               * 0BD1 10 26 09 0F    .&..
                    ldd       #1                  * 0BD5 CC 00 01       L..
                    pshs      D                   * 0BD8 34 06          4.
                    lbsr      L3A82               * 0BDA 17 2E A5       ..%
                    leas      $02,S               * 0BDD 32 62          2b
                    ldd       #1                  * 0BDF CC 00 01       L..
                    pshs      D                   * 0BE2 34 06          4.
                    lbsr      L3AEC               * 0BE4 17 2F 05       ./.
                    leas      $02,S               * 0BE7 32 62          2b
                    ldd       #1                  * 0BE9 CC 00 01       L..
                    pshs      D                   * 0BEC 34 06          4.
                    lbsr      L3AFB               * 0BEE 17 2F 0A       ./.
                    leas      $02,S               * 0BF1 32 62          2b
                    leax      >Title2,PC          * 0BF3 30 8D 1E 39    0..9
                    pshs      X                   * 0BF7 34 10          4.
                    lbsr      printf              * 0BF9 17 21 51       .!Q
                    leas      $02,S               * 0BFC 32 62          2b
                    leax      >CpyRite2,PC        * 0BFE 30 8D 1E 57    0..W
                    pshs      X                   * 0C02 34 10          4.
                    lbsr      printf              * 0C04 17 21 46       .!F
                    leas      $02,S               * 0C07 32 62          2b
                    leax      >License2,PC        * 0C09 30 8D 1E 75    0..u
                    pshs      X                   * 0C0D 34 10          4.
                    lbsr      printf              * 0C0F 17 21 3B       .!;
                    leas      $02,S               * 0C12 32 62          2b
                    leax      >Rights2,PC         * 0C14 30 8D 1E 93    0...
                    pshs      X                   * 0C18 34 10          4.
                    lbsr      printf              * 0C1A 17 21 30       .!0
                    leas      $02,S               * 0C1D 32 62          2b
                    ldd       #1                  * 0C1F CC 00 01       L..
                    pshs      D                   * 0C22 34 06          4.
                    lbsr      L3B00               * 0C24 17 2E D9       ..Y
                    leas      $02,S               * 0C27 32 62          2b
                    ldd       #1                  * 0C29 CC 00 01       L..
                    pshs      D                   * 0C2C 34 06          4.
                    lbsr      L252A               * 0C2E 17 18 F9       ..y
                    leas      $02,S               * 0C31 32 62          2b
                    clra                          * 0C33 4F             O
                    clrb                          * 0C34 5F             _
                    pshs      D                   * 0C35 34 06          4.
                    lbsr      exit                * 0C37 17 2D EF       .-o
                    lbra      L145E               * 0C3A 16 08 21       ..!
L0C3D               ldd       #4                  * 0C3D CC 00 04       L..
                    pshs      D                   * 0C40 34 06          4.
                    ldd       #4                  * 0C42 CC 00 04       L..
                    pshs      D                   * 0C45 34 06          4.
                    ldd       #6                  * 0C47 CC 00 06       L..
                    pshs      D                   * 0C4A 34 06          4.
                    ldd       #40                 * 0C4C CC 00 28       L.(
                    pshs      D                   * 0C4F 34 06          4.
                    ldd       #6                  * 0C51 CC 00 06       L..
                    pshs      D                   * 0C54 34 06          4.
                    ldd       #20                 * 0C56 CC 00 14       L..
                    pshs      D                   * 0C59 34 06          4.
                    ldd       #1                  * 0C5B CC 00 01       L..
                    pshs      D                   * 0C5E 34 06          4.
                    ldd       #1                  * 0C60 CC 00 01       L..
                    pshs      D                   * 0C63 34 06          4.
                    lbsr      L3A52               * 0C65 17 2D EA       .-j
                    leas      <$0010,S            * 0C68 32 E8 10       2h.
                    ldd       #2                  * 0C6B CC 00 02       L..
                    pshs      D                   * 0C6E 34 06          4.
                    clra                          * 0C70 4F             O
                    clrb                          * 0C71 5F             _
                    pshs      D                   * 0C72 34 06          4.
                    ldd       #4                  * 0C74 CC 00 04       L..
                    pshs      D                   * 0C77 34 06          4.
                    ldd       #38                 * 0C79 CC 00 26       L.&
                    pshs      D                   * 0C7C 34 06          4.
                    ldd       #7                  * 0C7E CC 00 07       L..
                    pshs      D                   * 0C81 34 06          4.
                    ldd       #21                 * 0C83 CC 00 15       L..
                    pshs      D                   * 0C86 34 06          4.
                    clra                          * 0C88 4F             O
                    clrb                          * 0C89 5F             _
                    pshs      D                   * 0C8A 34 06          4.
                    ldd       #1                  * 0C8C CC 00 01       L..
                    pshs      D                   * 0C8F 34 06          4.
                    lbsr      L3A52               * 0C91 17 2D BE       .->
                    leas      <$0010,S            * 0C94 32 E8 10       2h.
                    ldd       #1                  * 0C97 CC 00 01       L..
                    pshs      D                   * 0C9A 34 06          4.
                    lbsr      L252A               * 0C9C 17 18 8B       ...
                    leas      $02,S               * 0C9F 32 62          2b
                    ldd       #1                  * 0CA1 CC 00 01       L..
                    pshs      D                   * 0CA4 34 06          4.
                    lbsr      L3AEC               * 0CA6 17 2E 43       ..C
                    leas      $02,S               * 0CA9 32 62          2b
                    leax      >LoadPrompt,PC      * 0CAB 30 8D 1E 25    0..%
                    pshs      X                   * 0CAF 34 10          4.
                    lbsr      printf              * 0CB1 17 20 99       . .
                    leas      $02,S               * 0CB4 32 62          2b
                    leax      >U0049,Y            * 0CB6 30 A9 00 49    0).I
                    pshs      X                   * 0CBA 34 10          4.
                    lbsr      L337C               * 0CBC 17 26 BD       .&=
                    leas      $02,S               * 0CBF 32 62          2b
                    ldd       #32                 * 0CC1 CC 00 20       L.
                    pshs      D                   * 0CC4 34 06          4.
                    leax      $04,S               * 0CC6 30 64          0d
                    pshs      X                   * 0CC8 34 10          4.
                    clra                          * 0CCA 4F             O
                    clrb                          * 0CCB 5F             _
                    pshs      D                   * 0CCC 34 06          4.
                    lbsr      readln              * 0CCE 17 2B F4       .+t
                    leas      $06,S               * 0CD1 32 66          2f
                    std       0,S                 * 0CD3 ED E4          md
                    ldd       #1                  * 0CD5 CC 00 01       L..
                    pshs      D                   * 0CD8 34 06          4.
                    lbsr      L3A82               * 0CDA 17 2D A5       .-%
                    leas      $02,S               * 0CDD 32 62          2b
                    ldd       #1                  * 0CDF CC 00 01       L..
                    pshs      D                   * 0CE2 34 06          4.
                    lbsr      L3A82               * 0CE4 17 2D 9B       .-.
                    leas      $02,S               * 0CE7 32 62          2b
                    clra                          * 0CE9 4F             O
                    clrb                          * 0CEA 5F             _
                    pshs      D                   * 0CEB 34 06          4.
                    lbsr      L252A               * 0CED 17 18 3A       ..:
                    leas      $02,S               * 0CF0 32 62          2b
                    ldd       0,S                 * 0CF2 EC E4          ld
                    cmpd      #1                  * 0CF4 10 83 00 01    ....
                    bgt       L0CFD               * 0CF8 2E 03          ..
                    lbra      L14E4               * 0CFA 16 07 E7       ..g
L0CFD               leax      $02,S               * 0CFD 30 62          0b
                    pshs      X                   * 0CFF 34 10          4.
                    lbsr      L0555               * 0D01 17 F8 51       .xQ
                    lbra      L145E               * 0D04 16 07 57       ..W
L0D07               ldd       #4                  * 0D07 CC 00 04       L..
                    pshs      D                   * 0D0A 34 06          4.
                    ldd       #4                  * 0D0C CC 00 04       L..
                    pshs      D                   * 0D0F 34 06          4.
                    ldd       #6                  * 0D11 CC 00 06       L..
                    pshs      D                   * 0D14 34 06          4.
                    ldd       #40                 * 0D16 CC 00 28       L.(
                    pshs      D                   * 0D19 34 06          4.
                    ldd       #6                  * 0D1B CC 00 06       L..
                    pshs      D                   * 0D1E 34 06          4.
                    ldd       #20                 * 0D20 CC 00 14       L..
                    pshs      D                   * 0D23 34 06          4.
                    ldd       #1                  * 0D25 CC 00 01       L..
                    pshs      D                   * 0D28 34 06          4.
                    ldd       #1                  * 0D2A CC 00 01       L..
                    pshs      D                   * 0D2D 34 06          4.
                    lbsr      L3A52               * 0D2F 17 2D 20       .-
                    leas      <$0010,S            * 0D32 32 E8 10       2h.
                    ldd       #2                  * 0D35 CC 00 02       L..
                    pshs      D                   * 0D38 34 06          4.
                    clra                          * 0D3A 4F             O
                    clrb                          * 0D3B 5F             _
                    pshs      D                   * 0D3C 34 06          4.
                    ldd       #4                  * 0D3E CC 00 04       L..
                    pshs      D                   * 0D41 34 06          4.
                    ldd       #38                 * 0D43 CC 00 26       L.&
                    pshs      D                   * 0D46 34 06          4.
                    ldd       #7                  * 0D48 CC 00 07       L..
                    pshs      D                   * 0D4B 34 06          4.
                    ldd       #21                 * 0D4D CC 00 15       L..
                    pshs      D                   * 0D50 34 06          4.
                    clra                          * 0D52 4F             O
                    clrb                          * 0D53 5F             _
                    pshs      D                   * 0D54 34 06          4.
                    ldd       #1                  * 0D56 CC 00 01       L..
                    pshs      D                   * 0D59 34 06          4.
                    lbsr      L3A52               * 0D5B 17 2C F4       .,t
                    leas      <$0010,S            * 0D5E 32 E8 10       2h.
                    ldd       #1                  * 0D61 CC 00 01       L..
                    pshs      D                   * 0D64 34 06          4.
                    lbsr      L252A               * 0D66 17 17 C1       ..A
                    leas      $02,S               * 0D69 32 62          2b
                    ldd       #1                  * 0D6B CC 00 01       L..
                    pshs      D                   * 0D6E 34 06          4.
                    lbsr      L3AEC               * 0D70 17 2D 79       .-y
                    leas      $02,S               * 0D73 32 62          2b
                    leax      >SavePrompt,PC      * 0D75 30 8D 1D 6F    0..o
                    pshs      X                   * 0D79 34 10          4.
                    lbsr      printf              * 0D7B 17 1F CF       ..O
                    leas      $02,S               * 0D7E 32 62          2b
                    leax      >U0049,Y            * 0D80 30 A9 00 49    0).I
                    pshs      X                   * 0D84 34 10          4.
                    lbsr      L337C               * 0D86 17 25 F3       .%s
                    leas      $02,S               * 0D89 32 62          2b
                    ldd       #32                 * 0D8B CC 00 20       L.
                    pshs      D                   * 0D8E 34 06          4.
                    leax      $04,S               * 0D90 30 64          0d
                    pshs      X                   * 0D92 34 10          4.
                    clra                          * 0D94 4F             O
                    clrb                          * 0D95 5F             _
                    pshs      D                   * 0D96 34 06          4.
                    lbsr      readln              * 0D98 17 2B 2A       .+*
                    leas      $06,S               * 0D9B 32 66          2f
                    std       0,S                 * 0D9D ED E4          md
                    ldd       #1                  * 0D9F CC 00 01       L..
                    pshs      D                   * 0DA2 34 06          4.
                    lbsr      L3A82               * 0DA4 17 2C DB       .,[
                    leas      $02,S               * 0DA7 32 62          2b
                    ldd       #1                  * 0DA9 CC 00 01       L..
                    pshs      D                   * 0DAC 34 06          4.
                    lbsr      L3A82               * 0DAE 17 2C D1       .,Q
                    leas      $02,S               * 0DB1 32 62          2b
                    clra                          * 0DB3 4F             O
                    clrb                          * 0DB4 5F             _
                    pshs      D                   * 0DB5 34 06          4.
                    lbsr      L252A               * 0DB7 17 17 70       ..p
                    leas      $02,S               * 0DBA 32 62          2b
                    ldd       0,S                 * 0DBC EC E4          ld
                    cmpd      #1                  * 0DBE 10 83 00 01    ....
                    bgt       L0DC7               * 0DC2 2E 03          ..
                    lbra      L14E4               * 0DC4 16 07 1D       ...
L0DC7               leax      $02,S               * 0DC7 30 62          0b
                    pshs      X                   * 0DC9 34 10          4.
                    lbsr      L03E2               * 0DCB 17 F6 14       .v.
                    lbra      L145E               * 0DCE 16 06 8D       ...
L0DD1               ldd       #65                 * 0DD1 CC 00 41       L.A
                    pshs      D                   * 0DD4 34 06          4.
                    lbsr      L19C1               * 0DD6 17 0B E8       ..h
                    leas      $02,S               * 0DD9 32 62          2b
                    ldd       >U0007,Y            * 0DDB EC A9 00 07    l)..
                    lbne      L14E4               * 0DDF 10 26 07 01    .&..
                    ldd       #65                 * 0DE3 CC 00 41       L.A
                    lbra      L0FA6               * 0DE6 16 01 BD       ..=
L0DE9               ldd       #66                 * 0DE9 CC 00 42       L.B
                    pshs      D                   * 0DEC 34 06          4.
                    lbsr      L19C1               * 0DEE 17 0B D0       ..P
                    leas      $02,S               * 0DF1 32 62          2b
                    ldd       >U0007,Y            * 0DF3 EC A9 00 07    l)..
                    lbne      L14E4               * 0DF7 10 26 06 E9    .&.i
                    ldd       #66                 * 0DFB CC 00 42       L.B
                    lbra      L0FA6               * 0DFE 16 01 A5       ..%
L0E01               ldd       #68                 * 0E01 CC 00 44       L.D
                    pshs      D                   * 0E04 34 06          4.
                    lbsr      L19C1               * 0E06 17 0B B8       ..8
                    leas      $02,S               * 0E09 32 62          2b
                    ldd       >U0007,Y            * 0E0B EC A9 00 07    l)..
                    lbne      L14E4               * 0E0F 10 26 06 D1    .&.Q
                    ldd       #68                 * 0E13 CC 00 44       L.D
                    lbra      L0FA6               * 0E16 16 01 8D       ...
L0E19               ldd       #67                 * 0E19 CC 00 43       L.C
                    pshs      D                   * 0E1C 34 06          4.
                    lbsr      L19C1               * 0E1E 17 0B A0       ..
                    leas      $02,S               * 0E21 32 62          2b
                    ldd       >U0007,Y            * 0E23 EC A9 00 07    l)..
                    lbne      L14E4               * 0E27 10 26 06 B9    .&.9
                    ldd       #67                 * 0E2B CC 00 43       L.C
                    lbra      L0FA6               * 0E2E 16 01 75       ..u
L0E31               ldd       #4                  * 0E31 CC 00 04       L..
                    pshs      D                   * 0E34 34 06          4.
                    ldd       #4                  * 0E36 CC 00 04       L..
                    pshs      D                   * 0E39 34 06          4.
                    ldd       #6                  * 0E3B CC 00 06       L..
                    pshs      D                   * 0E3E 34 06          4.
                    ldd       #20                 * 0E40 CC 00 14       L..
                    pshs      D                   * 0E43 34 06          4.
                    ldd       #3                  * 0E45 CC 00 03       L..
                    pshs      D                   * 0E48 34 06          4.
                    ldd       #10                 * 0E4A CC 00 0A       L..
                    pshs      D                   * 0E4D 34 06          4.
                    ldd       #1                  * 0E4F CC 00 01       L..
                    pshs      D                   * 0E52 34 06          4.
                    ldd       #1                  * 0E54 CC 00 01       L..
                    pshs      D                   * 0E57 34 06          4.
                    lbsr      L3A52               * 0E59 17 2B F6       .+v
                    leas      <$0010,S            * 0E5C 32 E8 10       2h.
                    ldd       #2                  * 0E5F CC 00 02       L..
                    pshs      D                   * 0E62 34 06          4.
                    clra                          * 0E64 4F             O
                    clrb                          * 0E65 5F             _
                    pshs      D                   * 0E66 34 06          4.
                    ldd       #4                  * 0E68 CC 00 04       L..
                    pshs      D                   * 0E6B 34 06          4.
                    ldd       #18                 * 0E6D CC 00 12       L..
                    pshs      D                   * 0E70 34 06          4.
                    ldd       #4                  * 0E72 CC 00 04       L..
                    pshs      D                   * 0E75 34 06          4.
                    ldd       #11                 * 0E77 CC 00 0B       L..
                    pshs      D                   * 0E7A 34 06          4.
                    clra                          * 0E7C 4F             O
                    clrb                          * 0E7D 5F             _
                    pshs      D                   * 0E7E 34 06          4.
                    ldd       #1                  * 0E80 CC 00 01       L..
                    pshs      D                   * 0E83 34 06          4.
                    lbsr      L3A52               * 0E85 17 2B CA       .+J
                    leas      <$0010,S            * 0E88 32 E8 10       2h.
                    ldd       #1                  * 0E8B CC 00 01       L..
                    pshs      D                   * 0E8E 34 06          4.
                    lbsr      L3AEC               * 0E90 17 2C 59       .,Y
                    leas      $02,S               * 0E93 32 62          2b
                    leax      >PosSaved,PC        * 0E95 30 8D 1C 63    0..c
                    pshs      X                   * 0E99 34 10          4.
                    lbsr      printf              * 0E9B 17 1E AF       ../
                    leas      $02,S               * 0E9E 32 62          2b
                    ldd       #5                  * 0EA0 CC 00 05       L..
                    pshs      D                   * 0EA3 34 06          4.
                    lbsr      L363F               * 0EA5 17 27 97       .'.
                    leas      $02,S               * 0EA8 32 62          2b
                    ldd       #1                  * 0EAA CC 00 01       L..
                    pshs      D                   * 0EAD 34 06          4.
                    lbsr      L3A82               * 0EAF 17 2B D0       .+P
                    leas      $02,S               * 0EB2 32 62          2b
                    ldd       #1                  * 0EB4 CC 00 01       L..
                    pshs      D                   * 0EB7 34 06          4.
                    lbsr      L3A82               * 0EB9 17 2B C6       .+F
                    leas      $02,S               * 0EBC 32 62          2b
                    ldd       #115                * 0EBE CC 00 73       L.s
                    pshs      D                   * 0EC1 34 06          4.
                    lbsr      L19C1               * 0EC3 17 0A FB       ..{
                    leas      $02,S               * 0EC6 32 62          2b
                    ldd       >U0007,Y            * 0EC8 EC A9 00 07    l)..
                    lbne      L14E4               * 0ECC 10 26 06 14    .&..
                    ldd       #115                * 0ED0 CC 00 73       L.s
                    lbra      L0FA6               * 0ED3 16 00 D0       ..P
L0ED6               ldd       #4                  * 0ED6 CC 00 04       L..
                    pshs      D                   * 0ED9 34 06          4.
                    ldd       #4                  * 0EDB CC 00 04       L..
                    pshs      D                   * 0EDE 34 06          4.
                    ldd       #6                  * 0EE0 CC 00 06       L..
                    pshs      D                   * 0EE3 34 06          4.
                    ldd       #20                 * 0EE5 CC 00 14       L..
                    pshs      D                   * 0EE8 34 06          4.
                    ldd       #3                  * 0EEA CC 00 03       L..
                    pshs      D                   * 0EED 34 06          4.
                    ldd       #10                 * 0EEF CC 00 0A       L..
                    pshs      D                   * 0EF2 34 06          4.
                    ldd       #1                  * 0EF4 CC 00 01       L..
                    pshs      D                   * 0EF7 34 06          4.
                    ldd       #1                  * 0EF9 CC 00 01       L..
                    pshs      D                   * 0EFC 34 06          4.
                    lbsr      L3A52               * 0EFE 17 2B 51       .+Q
                    leas      <$0010,S            * 0F01 32 E8 10       2h.
                    ldd       #2                  * 0F04 CC 00 02       L..
                    pshs      D                   * 0F07 34 06          4.
                    clra                          * 0F09 4F             O
                    clrb                          * 0F0A 5F             _
                    pshs      D                   * 0F0B 34 06          4.
                    ldd       #4                  * 0F0D CC 00 04       L..
                    pshs      D                   * 0F10 34 06          4.
                    ldd       #18                 * 0F12 CC 00 12       L..
                    pshs      D                   * 0F15 34 06          4.
                    ldd       #4                  * 0F17 CC 00 04       L..
                    pshs      D                   * 0F1A 34 06          4.
                    ldd       #11                 * 0F1C CC 00 0B       L..
                    pshs      D                   * 0F1F 34 06          4.
                    clra                          * 0F21 4F             O
                    clrb                          * 0F22 5F             _
                    pshs      D                   * 0F23 34 06          4.
                    ldd       #1                  * 0F25 CC 00 01       L..
                    pshs      D                   * 0F28 34 06          4.
                    lbsr      L3A52               * 0F2A 17 2B 25       .+%
                    leas      <$0010,S            * 0F2D 32 E8 10       2h.
                    ldd       #1                  * 0F30 CC 00 01       L..
                    pshs      D                   * 0F33 34 06          4.
                    lbsr      L3AEC               * 0F35 17 2B B4       .+4
                    leas      $02,S               * 0F38 32 62          2b
                    leax      >PosRestrd,PC       * 0F3A 30 8D 1B D1    0..Q
                    pshs      X                   * 0F3E 34 10          4.
                    lbsr      printf              * 0F40 17 1E 0A       ...
                    leas      $02,S               * 0F43 32 62          2b
                    ldd       #5                  * 0F45 CC 00 05       L..
                    pshs      D                   * 0F48 34 06          4.
                    lbsr      L363F               * 0F4A 17 26 F2       .&r
                    leas      $02,S               * 0F4D 32 62          2b
                    ldd       #1                  * 0F4F CC 00 01       L..
                    pshs      D                   * 0F52 34 06          4.
                    lbsr      L3A82               * 0F54 17 2B 2B       .++
                    leas      $02,S               * 0F57 32 62          2b
                    ldd       #1                  * 0F59 CC 00 01       L..
                    pshs      D                   * 0F5C 34 06          4.
                    lbsr      L3A82               * 0F5E 17 2B 21       .+!
                    leas      $02,S               * 0F61 32 62          2b
                    ldd       #117                * 0F63 CC 00 75       L.u
                    pshs      D                   * 0F66 34 06          4.
                    lbsr      L19C1               * 0F68 17 0A 56       ..V
                    leas      $02,S               * 0F6B 32 62          2b
                    ldd       >U0007,Y            * 0F6D EC A9 00 07    l)..
                    lbne      L14E4               * 0F71 10 26 05 6F    .&.o
                    ldd       #117                * 0F75 CC 00 75       L.u
                    bra       L0FA6               * 0F78 20 2C           ,
L0F7A               ldd       #74                 * 0F7A CC 00 4A       L.J
                    pshs      D                   * 0F7D 34 06          4.
                    lbsr      L19C1               * 0F7F 17 0A 3F       ..?
                    leas      $02,S               * 0F82 32 62          2b
                    ldd       >U0007,Y            * 0F84 EC A9 00 07    l)..
                    lbne      L14E4               * 0F88 10 26 05 58    .&.X
                    ldd       #74                 * 0F8C CC 00 4A       L.J
                    bra       L0FA6               * 0F8F 20 15           .
L0F91               ldd       #107                * 0F91 CC 00 6B       L.k
                    pshs      D                   * 0F94 34 06          4.
                    lbsr      L19C1               * 0F96 17 0A 28       ..(
                    leas      $02,S               * 0F99 32 62          2b
                    ldd       >U0007,Y            * 0F9B EC A9 00 07    l)..
                    lbne      L14E4               * 0F9F 10 26 05 41    .&.A
                    ldd       #107                * 0FA3 CC 00 6B       L.k
L0FA6               pshs      D                   * 0FA6 34 06          4.
                    lbsr      L1933               * 0FA8 17 09 88       ...
                    lbra      L145E               * 0FAB 16 04 B0       ..0
L0FAE               lbsr      L14EC               * 0FAE 17 05 3B       ..;
                    lbra      L14E4               * 0FB1 16 05 30       ..0
L0FB4               ldd       >U0219,Y            * 0FB4 EC A9 02 19    l)..
                    cmpd      >U021D,Y            * 0FB8 10 A3 A9 02 1D .#)..
                    bne       L0FCC               * 0FBD 26 0D          &.
                    ldd       >U021B,Y            * 0FBF EC A9 02 1B    l)..
                    cmpd      >U021F,Y            * 0FC3 10 A3 A9 02 1F .#)..
                    lbeq      L10F3               * 0FC8 10 27 01 27    .'.'
L0FCC               ldd       >U000D,Y            * 0FCC EC A9 00 0D    l)..
                    addd      #8                  * 0FD0 C3 00 08       C..
                    cmpd      #8192               * 0FD3 10 83 20 00    .. .
                    lbge      L10E9               * 0FD7 10 2C 01 0E    .,..
                    ldd       >U000D,Y            * 0FDB EC A9 00 0D    l)..
                    addd      #1                  * 0FDF C3 00 01       C..
                    std       >U000D,Y            * 0FE2 ED A9 00 0D    m)..
                    subd      #1                  * 0FE6 83 00 01       ...
                    leax      >U0225,Y            * 0FE9 30 A9 02 25    0).%
                    leax      D,X                 * 0FED 30 8B          0.
                    ldd       #27                 * 0FEF CC 00 1B       L..
                    stb       0,X                 * 0FF2 E7 84          g.
                    ldd       >U000D,Y            * 0FF4 EC A9 00 0D    l)..
                    addd      #1                  * 0FF8 C3 00 01       C..
                    std       >U000D,Y            * 0FFB ED A9 00 0D    m)..
                    subd      #1                  * 0FFF 83 00 01       ...
                    leax      >U0225,Y            * 1002 30 A9 02 25    0).%
                    leax      D,X                 * 1006 30 8B          0.
                    ldd       #91                 * 1008 CC 00 5B       L.[
                    stb       0,X                 * 100B E7 84          g.
                    ldd       >U000D,Y            * 100D EC A9 00 0D    l)..
                    addd      #1                  * 1011 C3 00 01       C..
                    std       >U000D,Y            * 1014 ED A9 00 0D    m)..
                    subd      #1                  * 1018 83 00 01       ...
                    leax      >U0225,Y            * 101B 30 A9 02 25    0).%
                    leax      D,X                 * 101F 30 8B          0.
                    pshs      X                   * 1021 34 10          4.
                    ldd       >U021B,Y            * 1023 EC A9 02 1B    l)..
                    addd      #1                  * 1027 C3 00 01       C..
                    pshs      D                   * 102A 34 06          4.
                    ldd       #10                 * 102C CC 00 0A       L..
                    lbsr      L3711               * 102F 17 26 DF       .&_
                    addd      #48                 * 1032 C3 00 30       C.0
                    stb       [,S++]              * 1035 E7 F1          gq
                    ldd       >U000D,Y            * 1037 EC A9 00 0D    l)..
                    addd      #1                  * 103B C3 00 01       C..
                    std       >U000D,Y            * 103E ED A9 00 0D    m)..
                    subd      #1                  * 1042 83 00 01       ...
                    leax      >U0225,Y            * 1045 30 A9 02 25    0).%
                    leax      D,X                 * 1049 30 8B          0.
                    pshs      X                   * 104B 34 10          4.
                    ldd       >U021B,Y            * 104D EC A9 02 1B    l)..
                    addd      #1                  * 1051 C3 00 01       C..
                    pshs      D                   * 1054 34 06          4.
                    ldd       #10                 * 1056 CC 00 0A       L..
                    lbsr      L36BE               * 1059 17 26 62       .&b
                    addd      #48                 * 105C C3 00 30       C.0
                    stb       [,S++]              * 105F E7 F1          gq
                    ldd       >U000D,Y            * 1061 EC A9 00 0D    l)..
                    addd      #1                  * 1065 C3 00 01       C..
                    std       >U000D,Y            * 1068 ED A9 00 0D    m)..
                    subd      #1                  * 106C 83 00 01       ...
                    leax      >U0225,Y            * 106F 30 A9 02 25    0).%
                    leax      D,X                 * 1073 30 8B          0.
                    ldd       #59                 * 1075 CC 00 3B       L.;
                    stb       0,X                 * 1078 E7 84          g.
                    ldd       >U000D,Y            * 107A EC A9 00 0D    l)..
                    addd      #1                  * 107E C3 00 01       C..
                    std       >U000D,Y            * 1081 ED A9 00 0D    m)..
                    subd      #1                  * 1085 83 00 01       ...
                    leax      >U0225,Y            * 1088 30 A9 02 25    0).%
                    leax      D,X                 * 108C 30 8B          0.
                    pshs      X                   * 108E 34 10          4.
                    ldd       >U0219,Y            * 1090 EC A9 02 19    l)..
                    addd      #1                  * 1094 C3 00 01       C..
                    pshs      D                   * 1097 34 06          4.
                    ldd       #10                 * 1099 CC 00 0A       L..
                    lbsr      L3711               * 109C 17 26 72       .&r
                    addd      #48                 * 109F C3 00 30       C.0
                    stb       [,S++]              * 10A2 E7 F1          gq
                    ldd       >U000D,Y            * 10A4 EC A9 00 0D    l)..
                    addd      #1                  * 10A8 C3 00 01       C..
                    std       >U000D,Y            * 10AB ED A9 00 0D    m)..
                    subd      #1                  * 10AF 83 00 01       ...
                    leax      >U0225,Y            * 10B2 30 A9 02 25    0).%
                    leax      D,X                 * 10B6 30 8B          0.
                    pshs      X                   * 10B8 34 10          4.
                    ldd       >U0219,Y            * 10BA EC A9 02 19    l)..
                    addd      #1                  * 10BE C3 00 01       C..
                    pshs      D                   * 10C1 34 06          4.
                    ldd       #10                 * 10C3 CC 00 0A       L..
                    lbsr      L36BE               * 10C6 17 25 F5       .%u
                    addd      #48                 * 10C9 C3 00 30       C.0
                    stb       [,S++]              * 10CC E7 F1          gq
                    ldd       >U000D,Y            * 10CE EC A9 00 0D    l)..
                    addd      #1                  * 10D2 C3 00 01       C..
                    std       >U000D,Y            * 10D5 ED A9 00 0D    m)..
                    subd      #1                  * 10D9 83 00 01       ...
                    leax      >U0225,Y            * 10DC 30 A9 02 25    0).%
                    leax      D,X                 * 10E0 30 8B          0.
                    ldd       #72                 * 10E2 CC 00 48       L.H
                    stb       0,X                 * 10E5 E7 84          g.
                    bra       L10F3               * 10E7 20 0A           .
L10E9               ldd       #1                  * 10E9 CC 00 01       L..
                    pshs      D                   * 10EC 34 06          4.
                    lbsr      L3AD8               * 10EE 17 29 E7       .)g
                    leas      $02,S               * 10F1 32 62          2b
L10F3               clra                          * 10F3 4F             O
                    clrb                          * 10F4 5F             _
                    std       >U0007,Y            * 10F5 ED A9 00 07    m)..
                    ldd       >U0219,Y            * 10F9 EC A9 02 19    l)..
                    std       >U021D,Y            * 10FD ED A9 02 1D    m)..
                    ldd       >U021B,Y            * 1101 EC A9 02 1B    l)..
                    std       >U021F,Y            * 1105 ED A9 02 1F    m)..
                    lbra      L14E4               * 1109 16 03 D8       ..X
L110C               ldd       #1                  * 110C CC 00 01       L..
                    std       >U0007,Y            * 110F ED A9 00 07    m)..
                    lbra      L14E4               * 1113 16 03 CE       ..N
L1116               ldd       #4                  * 1116 CC 00 04       L..
                    pshs      D                   * 1119 34 06          4.
                    ldd       #4                  * 111B CC 00 04       L..
                    pshs      D                   * 111E 34 06          4.
                    ldd       #6                  * 1120 CC 00 06       L..
                    pshs      D                   * 1123 34 06          4.
                    ldd       #30                 * 1125 CC 00 1E       L..
                    pshs      D                   * 1128 34 06          4.
                    ldd       #3                  * 112A CC 00 03       L..
                    pshs      D                   * 112D 34 06          4.
                    ldd       #10                 * 112F CC 00 0A       L..
                    pshs      D                   * 1132 34 06          4.
                    ldd       #1                  * 1134 CC 00 01       L..
                    pshs      D                   * 1137 34 06          4.
                    ldd       #1                  * 1139 CC 00 01       L..
                    pshs      D                   * 113C 34 06          4.
                    lbsr      L3A52               * 113E 17 29 11       .).
                    leas      <$0010,S            * 1141 32 E8 10       2h.
                    ldd       #2                  * 1144 CC 00 02       L..
                    pshs      D                   * 1147 34 06          4.
                    clra                          * 1149 4F             O
                    clrb                          * 114A 5F             _
                    pshs      D                   * 114B 34 06          4.
                    ldd       #4                  * 114D CC 00 04       L..
                    pshs      D                   * 1150 34 06          4.
                    ldd       #28                 * 1152 CC 00 1C       L..
                    pshs      D                   * 1155 34 06          4.
                    ldd       #4                  * 1157 CC 00 04       L..
                    pshs      D                   * 115A 34 06          4.
                    ldd       #11                 * 115C CC 00 0B       L..
                    pshs      D                   * 115F 34 06          4.
                    clra                          * 1161 4F             O
                    clrb                          * 1162 5F             _
                    pshs      D                   * 1163 34 06          4.
                    ldd       #1                  * 1165 CC 00 01       L..
                    pshs      D                   * 1168 34 06          4.
                    lbsr      L3A52               * 116A 17 28 E5       .(e
                    leas      <$0010,S            * 116D 32 E8 10       2h.
                    ldd       #1                  * 1170 CC 00 01       L..
                    pshs      D                   * 1173 34 06          4.
                    lbsr      L3AEC               * 1175 17 29 74       .)t
                    leas      $02,S               * 1178 32 62          2b
                    leax      >MovBuff,PC         * 117A 30 8D 19 A5    0..%
                    pshs      X                   * 117E 34 10          4.
                    lbsr      printf              * 1180 17 1B CA       ..J
                    leas      $02,S               * 1183 32 62          2b
                    lbsr      L212A               * 1185 17 0F A2       .."
                    ldd       #1                  * 1188 CC 00 01       L..
                    pshs      D                   * 118B 34 06          4.
                    lbsr      L3A82               * 118D 17 28 F2       .(r
                    leas      $02,S               * 1190 32 62          2b
                    ldd       #1                  * 1192 CC 00 01       L..
                    pshs      D                   * 1195 34 06          4.
                    lbsr      L3A82               * 1197 17 28 E8       .(h
                    lbra      L145E               * 119A 16 02 C1       ..A
L119D               ldd       #1                  * 119D CC 00 01       L..
                    pshs      D                   * 11A0 34 06          4.
                    lbsr      L252A               * 11A2 17 13 85       ...
                    leas      $02,S               * 11A5 32 62          2b
                    leas      <$0024,S            * 11A7 32 E8 24       2h$
                    puls      PC,U                * 11AA 35 C0          5@
L11AC               ldd       #4                  * 11AC CC 00 04       L..
                    pshs      D                   * 11AF 34 06          4.
                    ldd       #4                  * 11B1 CC 00 04       L..
                    pshs      D                   * 11B4 34 06          4.
                    ldd       #10                 * 11B6 CC 00 0A       L..
                    pshs      D                   * 11B9 34 06          4.
                    ldd       #30                 * 11BB CC 00 1E       L..
                    pshs      D                   * 11BE 34 06          4.
                    ldd       #3                  * 11C0 CC 00 03       L..
                    pshs      D                   * 11C3 34 06          4.
                    ldd       #5                  * 11C5 CC 00 05       L..
                    pshs      D                   * 11C8 34 06          4.
                    ldd       #1                  * 11CA CC 00 01       L..
                    pshs      D                   * 11CD 34 06          4.
                    ldd       #1                  * 11CF CC 00 01       L..
                    pshs      D                   * 11D2 34 06          4.
                    lbsr      L3A52               * 11D4 17 28 7B       .({
                    leas      <$0010,S            * 11D7 32 E8 10       2h.
                    ldd       #2                  * 11DA CC 00 02       L..
                    pshs      D                   * 11DD 34 06          4.
                    clra                          * 11DF 4F             O
                    clrb                          * 11E0 5F             _
                    pshs      D                   * 11E1 34 06          4.
                    ldd       #8                  * 11E3 CC 00 08       L..
                    pshs      D                   * 11E6 34 06          4.
                    ldd       #28                 * 11E8 CC 00 1C       L..
                    pshs      D                   * 11EB 34 06          4.
                    ldd       #4                  * 11ED CC 00 04       L..
                    pshs      D                   * 11F0 34 06          4.
                    ldd       #6                  * 11F2 CC 00 06       L..
                    pshs      D                   * 11F5 34 06          4.
                    clra                          * 11F7 4F             O
                    clrb                          * 11F8 5F             _
                    pshs      D                   * 11F9 34 06          4.
                    ldd       #1                  * 11FB CC 00 01       L..
                    pshs      D                   * 11FE 34 06          4.
                    lbsr      L3A52               * 1200 17 28 4F       .(O
                    leas      <$0010,S            * 1203 32 E8 10       2h.
                    ldd       #1                  * 1206 CC 00 01       L..
                    pshs      D                   * 1209 34 06          4.
                    lbsr      L3AEC               * 120B 17 28 DE       .(^
                    leas      $02,S               * 120E 32 62          2b
                    leax      >Zap,PC             * 1210 30 8D 19 2A    0..*
                    pshs      X                   * 1214 34 10          4.
                    lbsr      printf              * 1216 17 1B 34       ..4
                    leas      $02,S               * 1219 32 62          2b
                    leax      >RecBuff,PC         * 121B 30 8D 19 39    0..9
                    pshs      X                   * 121F 34 10          4.
                    lbsr      printf              * 1221 17 1B 29       ..)
                    leas      $02,S               * 1224 32 62          2b
                    leax      >BothBuffs,PC       * 1226 30 8D 19 47    0..G
                    pshs      X                   * 122A 34 10          4.
                    lbsr      printf              * 122C 17 1B 1E       ...
                    leas      $02,S               * 122F 32 62          2b
                    leax      >ScrnChar,PC        * 1231 30 8D 19 56    0..V
                    pshs      X                   * 1235 34 10          4.
                    lbsr      printf              * 1237 17 1B 13       ...
                    leas      $02,S               * 123A 32 62          2b
                    leax      >RecChar,PC         * 123C 30 8D 19 67    0..g
                    pshs      X                   * 1240 34 10          4.
                    lbsr      printf              * 1242 17 1B 08       ...
                    leas      $02,S               * 1245 32 62          2b
                    leax      >Choose,PC          * 1247 30 8D 19 78    0..x
                    pshs      X                   * 124B 34 10          4.
                    lbsr      printf              * 124D 17 1A FD       ..}
                    leas      $02,S               * 1250 32 62          2b
                    leax      >U0049,Y            * 1252 30 A9 00 49    0).I
                    pshs      X                   * 1256 34 10          4.
                    lbsr      L337C               * 1258 17 21 21       .!!
                    leas      $02,S               * 125B 32 62          2b
                    ldd       #1                  * 125D CC 00 01       L..
                    pshs      D                   * 1260 34 06          4.
                    leax      <$0024,S            * 1262 30 E8 24       0h$
                    pshs      X                   * 1265 34 10          4.
                    clra                          * 1267 4F             O
                    clrb                          * 1268 5F             _
                    pshs      D                   * 1269 34 06          4.
                    lbsr      read                * 126B 17 26 36       .&6
                    leas      $06,S               * 126E 32 66          2f
                    ldb       <$0022,S            * 1270 E6 E8 22       fh"
                    clra                          * 1273 4F             O
                    andb      #223                * 1274 C4 DF          D_
                    stb       <$0022,S            * 1276 E7 E8 22       gh"
                    clra                          * 1279 4F             O
                    clrb                          * 127A 5F             _
                    stb       <$0023,S            * 127B E7 E8 23       gh#
                    ldb       <$0022,S            * 127E E6 E8 22       fh"
                    cmpb      #83                 * 1281 C1 53          AS
                    beq       L12A1               * 1283 27 1C          '.
                    ldb       <$0022,S            * 1285 E6 E8 22       fh"
                    cmpb      #82                 * 1288 C1 52          AR
                    beq       L12A1               * 128A 27 15          '.
                    ldb       <$0022,S            * 128C E6 E8 22       fh"
                    cmpb      #66                 * 128F C1 42          AB
                    beq       L12A1               * 1291 27 0E          '.
                    ldb       <$0022,S            * 1293 E6 E8 22       fh"
                    cmpb      #68                 * 1296 C1 44          AD
                    beq       L12A1               * 1298 27 07          '.
                    ldb       <$0022,S            * 129A E6 E8 22       fh"
                    cmpb      #84                 * 129D C1 54          AT
                    bne       L12CA               * 129F 26 29          &)
L12A1               leax      >Sure2,PC           * 12A1 30 8D 19 2B    0..+
                    pshs      X                   * 12A5 34 10          4.
                    lbsr      printf              * 12A7 17 1A A3       ..#
                    leas      $02,S               * 12AA 32 62          2b
                    leax      >U0049,Y            * 12AC 30 A9 00 49    0).I
                    pshs      X                   * 12B0 34 10          4.
                    lbsr      L337C               * 12B2 17 20 C7       . G
                    leas      $02,S               * 12B5 32 62          2b
                    ldd       #1                  * 12B7 CC 00 01       L..
                    pshs      D                   * 12BA 34 06          4.
                    leax      <$0025,S            * 12BC 30 E8 25       0h%
                    pshs      X                   * 12BF 34 10          4.
                    clra                          * 12C1 4F             O
                    clrb                          * 12C2 5F             _
                    pshs      D                   * 12C3 34 06          4.
                    lbsr      read                * 12C5 17 25 DC       .%\
                    leas      $06,S               * 12C8 32 66          2f
L12CA               ldd       #1                  * 12CA CC 00 01       L..
                    pshs      D                   * 12CD 34 06          4.
                    lbsr      L3A82               * 12CF 17 27 B0       .'0
                    leas      $02,S               * 12D2 32 62          2b
                    ldd       #1                  * 12D4 CC 00 01       L..
                    pshs      D                   * 12D7 34 06          4.
                    lbsr      L3A82               * 12D9 17 27 A6       .'&
                    leas      $02,S               * 12DC 32 62          2b
                    ldb       <$0023,S            * 12DE E6 E8 23       fh#
                    clra                          * 12E1 4F             O
                    andb      #223                * 12E2 C4 DF          D_
                    cmpd      #89                 * 12E4 10 83 00 59    ...Y
                    lbne      L14E4               * 12E8 10 26 01 F8    .&.x
                    ldb       <$0022,S            * 12EC E6 E8 22       fh"
                    clra                          * 12EF 4F             O
                    andb      #223                * 12F0 C4 DF          D_
                    tfr       D,X                 * 12F2 1F 01          ..
                    lbra      L13F0               * 12F4 16 00 F9       ..y
L12F7               clra                          * 12F7 4F             O
                    clrb                          * 12F8 5F             _
                    std       >U0009,Y            * 12F9 ED A9 00 09    m)..
                    clra                          * 12FD 4F             O
                    clrb                          * 12FE 5F             _
                    pshs      D                   * 12FF 34 06          4.
                    ldd       #1                  * 1301 CC 00 01       L..
                    pshs      D                   * 1304 34 06          4.
                    lbsr      L3A9F               * 1306 17 27 96       .'.
                    leas      $04,S               * 1309 32 64          2d
                    ldd       #2                  * 130B CC 00 02       L..
                    pshs      D                   * 130E 34 06          4.
                    ldd       #1                  * 1310 CC 00 01       L..
                    pshs      D                   * 1313 34 06          4.
                    lbsr      L3AA3               * 1315 17 27 8B       .'.
                    leas      $04,S               * 1318 32 64          2d
                    lbsr      L035D               * 131A 17 F0 40       .p@
                    ldd       #74                 * 131D CC 00 4A       L.J
                    pshs      D                   * 1320 34 06          4.
                    lbsr      L19C1               * 1322 17 06 9C       ...
                    lbra      L13EB               * 1325 16 00 C3       ..C
L1328               clra                          * 1328 4F             O
                    clrb                          * 1329 5F             _
                    pshs      D                   * 132A 34 06          4.
                    ldd       #1                  * 132C CC 00 01       L..
                    pshs      D                   * 132F 34 06          4.
                    lbsr      L3A9F               * 1331 17 27 6B       .'k
                    leas      $04,S               * 1334 32 64          2d
                    ldd       #2                  * 1336 CC 00 02       L..
                    pshs      D                   * 1339 34 06          4.
                    ldd       #1                  * 133B CC 00 01       L..
                    pshs      D                   * 133E 34 06          4.
                    lbsr      L3AA3               * 1340 17 27 60       .'`
                    leas      $04,S               * 1343 32 64          2d
                    lbsr      L035D               * 1345 17 F0 15       .p.
                    ldd       #74                 * 1348 CC 00 4A       L.J
                    pshs      D                   * 134B 34 06          4.
                    lbsr      L19C1               * 134D 17 06 71       ..q
                    leas      $02,S               * 1350 32 62          2b
L1352               clra                          * 1352 4F             O
                    clrb                          * 1353 5F             _
                    std       >U0009,Y            * 1354 ED A9 00 09    m)..
                    clra                          * 1358 4F             O
                    clrb                          * 1359 5F             _
                    std       >U000D,Y            * 135A ED A9 00 0D    m)..
                    lbra      L14E4               * 135E 16 01 83       ...
L1361               ldd       >U0219,Y            * 1361 EC A9 02 19    l)..
                    pshs      D                   * 1365 34 06          4.
                    ldd       #80                 * 1367 CC 00 50       L.P
                    lbsr      L365D               * 136A 17 22 F0       ."p
                    leax      >U2225,Y            * 136D 30 A9 22 25    0)"%
                    leax      D,X                 * 1371 30 8B          0.
                    ldd       >U021B,Y            * 1373 EC A9 02 1B    l)..
                    leax      D,X                 * 1377 30 8B          0.
                    clra                          * 1379 4F             O
                    clrb                          * 137A 5F             _
                    stb       0,X                 * 137B E7 84          g.
                    ldd       >U0219,Y            * 137D EC A9 02 19    l)..
                    pshs      D                   * 1381 34 06          4.
                    ldd       #160                * 1383 CC 00 A0       L.
                    lbsr      L365D               * 1386 17 22 D4       ."T
                    leax      >U2955,Y            * 1389 30 A9 29 55    0))U
                    leax      D,X                 * 138D 30 8B          0.
                    tfr       X,D                 * 138F 1F 10          ..
                    pshs      D                   * 1391 34 06          4.
                    ldd       >U021B,Y            * 1393 EC A9 02 1B    l)..
                    aslb                          * 1397 58             X
                    rola                          * 1398 49             I
                    addd      ,S++                * 1399 E3 E1          ca
                    tfr       D,X                 * 139B 1F 01          ..
                    clra                          * 139D 4F             O
                    clrb                          * 139E 5F             _
                    std       0,X                 * 139F ED 84          m.
                    ldd       #1                  * 13A1 CC 00 01       L..
                    pshs      D                   * 13A4 34 06          4.
                    leax      >L2BE6,PC           * 13A6 30 8D 18 3C    0..<
                    pshs      X                   * 13AA 34 10          4.
                    ldd       #1                  * 13AC CC 00 01       L..
                    pshs      D                   * 13AF 34 06          4.
                    lbsr      write               * 13B1 17 25 21       .%!
                    leas      $06,S               * 13B4 32 66          2f
                    lbra      L14E4               * 13B6 16 01 2B       ..+
L13B9               ldd       >U000D,Y            * 13B9 EC A9 00 0D    l)..
                    addd      #-1                 * 13BD C3 FF FF       C..
                    std       >U000D,Y            * 13C0 ED A9 00 0D    m)..
                    ldd       #1                  * 13C4 CC 00 01       L..
                    pshs      D                   * 13C7 34 06          4.
                    lbsr      L3ADC               * 13C9 17 27 10       .'.
                    leas      $02,S               * 13CC 32 62          2b
                    ldd       #1                  * 13CE CC 00 01       L..
                    pshs      D                   * 13D1 34 06          4.
                    leax      >L2BE8,PC           * 13D3 30 8D 18 11    0...
                    pshs      X                   * 13D7 34 10          4.
                    ldd       #1                  * 13D9 CC 00 01       L..
                    pshs      D                   * 13DC 34 06          4.
                    lbsr      write               * 13DE 17 24 F4       .$t
                    leas      $06,S               * 13E1 32 66          2f
                    ldd       #1                  * 13E3 CC 00 01       L..
                    pshs      D                   * 13E6 34 06          4.
                    lbsr      L3ADC               * 13E8 17 26 F1       .&q
L13EB               leas      $02,S               * 13EB 32 62          2b
                    lbra      L14E4               * 13ED 16 00 F4       ..t
L13F0               cmpx      #83                 * 13F0 8C 00 53       ..S
                    lbeq      L12F7               * 13F3 10 27 FF 00    .'..
                    cmpx      #82                 * 13F7 8C 00 52       ..R
                    lbeq      L1352               * 13FA 10 27 FF 54    .'.T
                    cmpx      #66                 * 13FE 8C 00 42       ..B
                    lbeq      L1328               * 1401 10 27 FF 23    .'.#
                    cmpx      #68                 * 1405 8C 00 44       ..D
                    lbeq      L1361               * 1408 10 27 FF 55    .'.U
                    cmpx      #84                 * 140C 8C 00 54       ..T
                    beq       L13B9               * 140F 27 A8          '(
                    lbra      L14E4               * 1411 16 00 D0       ..P
L1414               clra                          * 1414 4F             O
                    clrb                          * 1415 5F             _
                    std       >U0005,Y            * 1416 ED A9 00 05    m)..
                    ldb       <$0023,S            * 141A E6 E8 23       fh#
                    sex                           * 141D 1D             .
                    pshs      D                   * 141E 34 06          4.
                    lbsr      L19C1               * 1420 17 05 9E       ...
                    leas      $02,S               * 1423 32 62          2b
                    ldd       >U0007,Y            * 1425 EC A9 00 07    l)..
                    lbne      L14E4               * 1429 10 26 00 B7    .&.7
                    ldd       >U000D,Y            * 142D EC A9 00 0D    l)..
                    addd      #1                  * 1431 C3 00 01       C..
                    cmpd      #8192               * 1434 10 83 20 00    .. .
                    bge       L1456               * 1438 2C 1C          ,.
                    ldd       >U000D,Y            * 143A EC A9 00 0D    l)..
                    addd      #1                  * 143E C3 00 01       C..
                    std       >U000D,Y            * 1441 ED A9 00 0D    m)..
                    subd      #1                  * 1445 83 00 01       ...
                    leax      >U0225,Y            * 1448 30 A9 02 25    0).%
                    leax      D,X                 * 144C 30 8B          0.
                    ldb       <$0023,S            * 144E E6 E8 23       fh#
                    stb       0,X                 * 1451 E7 84          g.
                    lbra      L14E4               * 1453 16 00 8E       ...
L1456               ldd       #1                  * 1456 CC 00 01       L..
                    pshs      D                   * 1459 34 06          4.
                    lbsr      L3AD8               * 145B 17 26 7A       .&z
L145E               leas      $02,S               * 145E 32 62          2b
                    lbra      L14E4               * 1460 16 00 81       ...
L1463               cmpx      #-81                * 1463 8C FF AF       ../
                    lbeq      L09E5               * 1466 10 27 F5 7B    .'u{
                    cmpx      #-15                * 146A 8C FF F1       ..q
                    lbeq      L0B26               * 146D 10 27 F6 B5    .'v5
                    cmpx      #-20                * 1471 8C FF EC       ..l
                    lbeq      L0C3D               * 1474 10 27 F7 C5    .'wE
                    cmpx      #-21                * 1478 8C FF EB       ..k
                    lbeq      L0D07               * 147B 10 27 F8 88    .'x.
                    cmpx      #12                 * 147F 8C 00 0C       ...
                    lbeq      L0DD1               * 1482 10 27 F9 4B    .'yK
                    cmpx      #10                 * 1486 8C 00 0A       ...
                    lbeq      L0DE9               * 1489 10 27 F9 5C    .'y\
                    cmpx      #8                  * 148D 8C 00 08       ...
                    lbeq      L0E01               * 1490 10 27 F9 6D    .'ym
                    cmpx      #9                  * 1494 8C 00 09       ...
                    lbeq      L0E19               * 1497 10 27 F9 7E    .'y~
                    cmpx      #-13                * 149B 8C FF F3       ..s
                    lbeq      L0E31               * 149E 10 27 F9 8F    .'y.
                    cmpx      #-31                * 14A2 8C FF E1       ..a
                    lbeq      L0ED6               * 14A5 10 27 FA 2D    .'z-
                    cmpx      #-29                * 14A9 8C FF E3       ..c
                    lbeq      L0F7A               * 14AC 10 27 FA CA    .'zJ
                    cmpx      #-18                * 14B0 8C FF EE       ..n
                    lbeq      L0F91               * 14B3 10 27 FA DA    .'zZ
                    cmpx      #-25                * 14B7 8C FF E7       ..g
                    lbeq      L0FAE               * 14BA 10 27 FA F0    .'zp
                    cmpx      #-14                * 14BE 8C FF F2       ..r
                    lbeq      L0FB4               * 14C1 10 27 FA EF    .'zo
                    cmpx      #-27                * 14C5 8C FF E5       ..e
                    lbeq      L110C               * 14C8 10 27 FC 40    .'|@
                    cmpx      #-16                * 14CC 8C FF F0       ..p
                    lbeq      L1116               * 14CF 10 27 FC 43    .'|C
                    cmpx      #-8                 * 14D3 8C FF F8       ..x
                    lbeq      L119D               * 14D6 10 27 FC C3    .'|C
                    cmpx      #-6                 * 14DA 8C FF FA       ..z
                    lbeq      L11AC               * 14DD 10 27 FC CB    .'|K
                    lbra      L1414               * 14E1 16 FF 30       ..0
L14E4               lbra      L080D               * 14E4 16 F3 26       .s&
                    leas      <$0024,S            * 14E7 32 E8 24       2h$
                    puls      PC,U                * 14EA 35 C0          5@

* -- method --
L14EC               pshs      U                   * 14EC 34 40          4@
                    ldd       #-86                * 14EE CC FF AA       L.*
                    lbsr      _stkcheck           * 14F1 17 EC 1B       .l.
                    leas      -$02,S              * 14F4 32 7E          2~
                    ldd       >U0007,Y            * 14F6 EC A9 00 07    l)..
                    bne       L1547               * 14FA 26 4B          &K
                    ldd       >U000D,Y            * 14FC EC A9 00 0D    l)..
                    addd      #2                  * 1500 C3 00 02       C..
                    cmpd      #8192               * 1503 10 83 20 00    .. .
                    bge       L153D               * 1507 2C 34          ,4
                    ldd       >U000D,Y            * 1509 EC A9 00 0D    l)..
                    addd      #1                  * 150D C3 00 01       C..
                    std       >U000D,Y            * 1510 ED A9 00 0D    m)..
                    subd      #1                  * 1514 83 00 01       ...
                    leax      >U0225,Y            * 1517 30 A9 02 25    0).%
                    leax      D,X                 * 151B 30 8B          0.
                    ldd       #27                 * 151D CC 00 1B       L..
                    stb       0,X                 * 1520 E7 84          g.
                    ldd       >U000D,Y            * 1522 EC A9 00 0D    l)..
                    addd      #1                  * 1526 C3 00 01       C..
                    std       >U000D,Y            * 1529 ED A9 00 0D    m)..
                    subd      #1                  * 152D 83 00 01       ...
                    leax      >U0225,Y            * 1530 30 A9 02 25    0).%
                    leax      D,X                 * 1534 30 8B          0.
                    ldd       #91                 * 1536 CC 00 5B       L.[
                    stb       0,X                 * 1539 E7 84          g.
                    bra       L1547               * 153B 20 0A           .
L153D               ldd       #1                  * 153D CC 00 01       L..
                    pshs      D                   * 1540 34 06          4.
                    lbsr      L3AD8               * 1542 17 25 93       .%.
                    leas      $02,S               * 1545 32 62          2b
L1547               clra                          * 1547 4F             O
                    clrb                          * 1548 5F             _
                    stb       $01,S               * 1549 E7 61          ga
                    lbra      L17EA               * 154B 16 02 9C       ...
L154E               ldd       #3                  * 154E CC 00 03       L..
                    pshs      D                   * 1551 34 06          4.
                    ldd       #3                  * 1553 CC 00 03       L..
                    pshs      D                   * 1556 34 06          4.
                    ldd       #17                 * 1558 CC 00 11       L..
                    pshs      D                   * 155B 34 06          4.
                    ldd       #40                 * 155D CC 00 28       L.(
                    pshs      D                   * 1560 34 06          4.
                    ldd       #6                  * 1562 CC 00 06       L..
                    pshs      D                   * 1565 34 06          4.
                    ldd       #20                 * 1567 CC 00 14       L..
                    pshs      D                   * 156A 34 06          4.
                    ldd       #1                  * 156C CC 00 01       L..
                    pshs      D                   * 156F 34 06          4.
                    ldd       #1                  * 1571 CC 00 01       L..
                    pshs      D                   * 1574 34 06          4.
                    lbsr      L3A52               * 1576 17 24 D9       .$Y
                    leas      <$0010,S            * 1579 32 E8 10       2h.
                    ldd       #2                  * 157C CC 00 02       L..
                    pshs      D                   * 157F 34 06          4.
                    clra                          * 1581 4F             O
                    clrb                          * 1582 5F             _
                    pshs      D                   * 1583 34 06          4.
                    ldd       #15                 * 1585 CC 00 0F       L..
                    pshs      D                   * 1588 34 06          4.
                    ldd       #38                 * 158A CC 00 26       L.&
                    pshs      D                   * 158D 34 06          4.
                    ldd       #7                  * 158F CC 00 07       L..
                    pshs      D                   * 1592 34 06          4.
                    ldd       #21                 * 1594 CC 00 15       L..
                    pshs      D                   * 1597 34 06          4.
                    clra                          * 1599 4F             O
                    clrb                          * 159A 5F             _
                    pshs      D                   * 159B 34 06          4.
                    ldd       #1                  * 159D CC 00 01       L..
                    pshs      D                   * 15A0 34 06          4.
                    lbsr      L3A52               * 15A2 17 24 AD       .$-
                    leas      <$0010,S            * 15A5 32 E8 10       2h.
                    ldd       #1                  * 15A8 CC 00 01       L..
                    pshs      D                   * 15AB 34 06          4.
                    lbsr      L3AEC               * 15AD 17 25 3C       .%<
                    leas      $02,S               * 15B0 32 62          2b
                    leax      >SetGraphs,PC       * 15B2 30 8D 16 34    0..4
                    pshs      X                   * 15B6 34 10          4.
                    lbsr      printf              * 15B8 17 17 92       ...
                    leas      $02,S               * 15BB 32 62          2b
                    leax      >Line2,PC           * 15BD 30 8D 16 45    0..E
                    pshs      X                   * 15C1 34 10          4.
                    lbsr      printf              * 15C3 17 17 87       ...
                    leas      $02,S               * 15C6 32 62          2b
                    leax      >RestGraph,PC       * 15C8 30 8D 16 59    0..Y
                    pshs      X                   * 15CC 34 10          4.
                    lbsr      printf              * 15CE 17 17 7C       ..|
                    leas      $02,S               * 15D1 32 62          2b
                    leax      >BoldOn,PC          * 15D3 30 8D 16 75    0..u
                    pshs      X                   * 15D7 34 10          4.
                    lbsr      printf              * 15D9 17 17 71       ..q
                    leas      $02,S               * 15DC 32 62          2b
                    leax      >UndrOn,PC          * 15DE 30 8D 16 79    0..y
                    pshs      X                   * 15E2 34 10          4.
                    lbsr      printf              * 15E4 17 17 66       ..f
                    leas      $02,S               * 15E7 32 62          2b
                    leax      >BlnkOn,PC          * 15E9 30 8D 16 83    0...
                    pshs      X                   * 15ED 34 10          4.
                    lbsr      printf              * 15EF 17 17 5B       ..[
                    leas      $02,S               * 15F2 32 62          2b
                    leax      >RevVidOn,PC        * 15F4 30 8D 16 88    0...
                    pshs      X                   * 15F8 34 10          4.
                    lbsr      printf              * 15FA 17 17 50       ..P
                    leas      $02,S               * 15FD 32 62          2b
                    leax      >InvisOn,PC         * 15FF 30 8D 16 95    0...
                    pshs      X                   * 1603 34 10          4.
                    lbsr      printf              * 1605 17 17 45       ..E
                    leas      $02,S               * 1608 32 62          2b
                    leax      >SetForClr,PC       * 160A 30 8D 16 9E    0...
                    pshs      X                   * 160E 34 10          4.
                    lbsr      printf              * 1610 17 17 3A       ..:
                    leas      $02,S               * 1613 32 62          2b
                    leax      >SetBckClr,PC       * 1615 30 8D 16 AF    0../
                    pshs      X                   * 1619 34 10          4.
                    lbsr      printf              * 161B 17 17 2F       ../
                    leas      $02,S               * 161E 32 62          2b
                    leax      >Done,PC            * 1620 30 8D 16 C0    0..@
                    pshs      X                   * 1624 34 10          4.
                    lbsr      printf              * 1626 17 17 24       ..$
                    leas      $02,S               * 1629 32 62          2b
                    leax      >SelChoice,PC       * 162B 30 8D 16 C1    0..A
                    pshs      X                   * 162F 34 10          4.
                    lbsr      printf              * 1631 17 17 19       ...
                    leas      $02,S               * 1634 32 62          2b
                    leax      >U0049,Y            * 1636 30 A9 00 49    0).I
                    pshs      X                   * 163A 34 10          4.
                    lbsr      L337C               * 163C 17 1D 3D       ..=
                    leas      $02,S               * 163F 32 62          2b
                    ldd       #1                  * 1641 CC 00 01       L..
                    pshs      D                   * 1644 34 06          4.
                    leax      $03,S               * 1646 30 63          0c
                    pshs      X                   * 1648 34 10          4.
                    clra                          * 164A 4F             O
                    clrb                          * 164B 5F             _
                    pshs      D                   * 164C 34 06          4.
                    lbsr      read                * 164E 17 22 53       ."S
                    leas      $06,S               * 1651 32 66          2f
                    ldb       $01,S               * 1653 E6 61          fa
                    clra                          * 1655 4F             O
                    andb      #223                * 1656 C4 DF          D_
                    stb       $01,S               * 1658 E7 61          ga
                    ldd       #1                  * 165A CC 00 01       L..
                    pshs      D                   * 165D 34 06          4.
                    lbsr      L3A82               * 165F 17 24 20       .$
                    leas      $02,S               * 1662 32 62          2b
                    ldd       #1                  * 1664 CC 00 01       L..
                    pshs      D                   * 1667 34 06          4.
                    lbsr      L3A82               * 1669 17 24 16       .$.
                    leas      $02,S               * 166C 32 62          2b
                    ldb       $01,S               * 166E E6 61          fa
                    sex                           * 1670 1D             .
                    tfr       D,X                 * 1671 1F 01          ..
                    lbra      L17B2               * 1673 16 01 3C       ..<
L1676               ldd       #48                 * 1676 CC 00 30       L.0
                    pshs      D                   * 1679 34 06          4.
                    lbsr      L19C1               * 167B 17 03 43       ..C
                    leas      $02,S               * 167E 32 62          2b
                    ldd       #59                 * 1680 CC 00 3B       L.;
                    pshs      D                   * 1683 34 06          4.
                    lbsr      L19C1               * 1685 17 03 39       ..9
                    leas      $02,S               * 1688 32 62          2b
                    ldd       >U0007,Y            * 168A EC A9 00 07    l)..
                    lbne      L17EA               * 168E 10 26 01 58    .&.X
                    clra                          * 1692 4F             O
                    clrb                          * 1693 5F             _
                    lbra      L17A9               * 1694 16 01 12       ...
L1697               ldd       #49                 * 1697 CC 00 31       L.1
                    pshs      D                   * 169A 34 06          4.
                    lbsr      L19C1               * 169C 17 03 22       .."
                    leas      $02,S               * 169F 32 62          2b
                    ldd       #59                 * 16A1 CC 00 3B       L.;
                    pshs      D                   * 16A4 34 06          4.
                    lbsr      L19C1               * 16A6 17 03 18       ...
                    leas      $02,S               * 16A9 32 62          2b
                    ldd       >U0007,Y            * 16AB EC A9 00 07    l)..
                    lbne      L17EA               * 16AF 10 26 01 37    .&.7
                    ldd       #1                  * 16B3 CC 00 01       L..
                    lbra      L17A9               * 16B6 16 00 F0       ..p
L16B9               ldd       #52                 * 16B9 CC 00 34       L.4
                    pshs      D                   * 16BC 34 06          4.
                    lbsr      L19C1               * 16BE 17 03 00       ...
                    leas      $02,S               * 16C1 32 62          2b
                    ldd       #59                 * 16C3 CC 00 3B       L.;
                    pshs      D                   * 16C6 34 06          4.
                    lbsr      L19C1               * 16C8 17 02 F6       ..v
                    leas      $02,S               * 16CB 32 62          2b
                    ldd       >U0007,Y            * 16CD EC A9 00 07    l)..
                    lbne      L17EA               * 16D1 10 26 01 15    .&..
                    ldd       #4                  * 16D5 CC 00 04       L..
                    lbra      L17A9               * 16D8 16 00 CE       ..N
L16DB               ldd       #53                 * 16DB CC 00 35       L.5
                    pshs      D                   * 16DE 34 06          4.
                    lbsr      L19C1               * 16E0 17 02 DE       ..^
                    leas      $02,S               * 16E3 32 62          2b
                    ldd       #59                 * 16E5 CC 00 3B       L.;
                    pshs      D                   * 16E8 34 06          4.
                    lbsr      L19C1               * 16EA 17 02 D4       ..T
                    leas      $02,S               * 16ED 32 62          2b
                    ldd       >U0007,Y            * 16EF EC A9 00 07    l)..
                    lbne      L17EA               * 16F3 10 26 00 F3    .&.s
                    ldd       #5                  * 16F7 CC 00 05       L..
                    lbra      L17A9               * 16FA 16 00 AC       ..,
L16FD               ldd       #55                 * 16FD CC 00 37       L.7
                    pshs      D                   * 1700 34 06          4.
                    lbsr      L19C1               * 1702 17 02 BC       ..<
                    leas      $02,S               * 1705 32 62          2b
                    ldd       #59                 * 1707 CC 00 3B       L.;
                    pshs      D                   * 170A 34 06          4.
                    lbsr      L19C1               * 170C 17 02 B2       ..2
                    leas      $02,S               * 170F 32 62          2b
                    ldd       >U0007,Y            * 1711 EC A9 00 07    l)..
                    lbne      L17EA               * 1715 10 26 00 D1    .&.Q
                    ldd       #7                  * 1719 CC 00 07       L..
                    lbra      L17A9               * 171C 16 00 8A       ...
L171F               ldd       #56                 * 171F CC 00 38       L.8
                    pshs      D                   * 1722 34 06          4.
                    lbsr      L19C1               * 1724 17 02 9A       ...
                    leas      $02,S               * 1727 32 62          2b
                    ldd       #59                 * 1729 CC 00 3B       L.;
                    pshs      D                   * 172C 34 06          4.
                    lbsr      L19C1               * 172E 17 02 90       ...
                    leas      $02,S               * 1731 32 62          2b
                    ldd       >U0007,Y            * 1733 EC A9 00 07    l)..
                    lbne      L17EA               * 1737 10 26 00 AF    .&./
                    ldd       #8                  * 173B CC 00 08       L..
                    lbra      L17A9               * 173E 16 00 68       ..h
L1741               lbsr      L1819               * 1741 17 00 D5       ..U
                    stb       0,S                 * 1744 E7 E4          gd
                    ldd       #51                 * 1746 CC 00 33       L.3
                    pshs      D                   * 1749 34 06          4.
                    lbsr      L19C1               * 174B 17 02 73       ..s
                    leas      $02,S               * 174E 32 62          2b
                    ldb       0,S                 * 1750 E6 E4          fd
                    sex                           * 1752 1D             .
                    addd      #48                 * 1753 C3 00 30       C.0
                    pshs      D                   * 1756 34 06          4.
                    lbsr      L19C1               * 1758 17 02 66       ..f
                    leas      $02,S               * 175B 32 62          2b
                    ldd       #59                 * 175D CC 00 3B       L.;
                    pshs      D                   * 1760 34 06          4.
                    lbsr      L19C1               * 1762 17 02 5C       ..\
                    leas      $02,S               * 1765 32 62          2b
                    ldd       >U0007,Y            * 1767 EC A9 00 07    l)..
                    lbne      L17EA               * 176B 10 26 00 7B    .&.{
                    ldb       0,S                 * 176F E6 E4          fd
                    sex                           * 1771 1D             .
                    addd      #30                 * 1772 C3 00 1E       C..
                    bra       L17A9               * 1775 20 32           2
L1777               lbsr      L1819               * 1777 17 00 9F       ...
                    stb       0,S                 * 177A E7 E4          gd
                    ldd       #52                 * 177C CC 00 34       L.4
                    pshs      D                   * 177F 34 06          4.
                    lbsr      L19C1               * 1781 17 02 3D       ..=
                    leas      $02,S               * 1784 32 62          2b
                    ldb       0,S                 * 1786 E6 E4          fd
                    sex                           * 1788 1D             .
                    addd      #48                 * 1789 C3 00 30       C.0
                    pshs      D                   * 178C 34 06          4.
                    lbsr      L19C1               * 178E 17 02 30       ..0
                    leas      $02,S               * 1791 32 62          2b
                    ldd       #59                 * 1793 CC 00 3B       L.;
                    pshs      D                   * 1796 34 06          4.
                    lbsr      L19C1               * 1798 17 02 26       ..&
                    leas      $02,S               * 179B 32 62          2b
                    ldd       >U0007,Y            * 179D EC A9 00 07    l)..
                    bne       L17EA               * 17A1 26 47          &G
                    ldb       0,S                 * 17A3 E6 E4          fd
                    sex                           * 17A5 1D             .
                    addd      #40                 * 17A6 C3 00 28       C.(
L17A9               pshs      D                   * 17A9 34 06          4.
                    lbsr      L249A               * 17AB 17 0C EC       ..l
                    leas      $02,S               * 17AE 32 62          2b
                    bra       L17EA               * 17B0 20 38           8
L17B2               cmpx      #82                 * 17B2 8C 00 52       ..R
                    lbeq      L1676               * 17B5 10 27 FE BD    .'~=
                    cmpx      #79                 * 17B9 8C 00 4F       ..O
                    lbeq      L1697               * 17BC 10 27 FE D7    .'~W
                    cmpx      #85                 * 17C0 8C 00 55       ..U
                    lbeq      L16B9               * 17C3 10 27 FE F2    .'~r
                    cmpx      #76                 * 17C7 8C 00 4C       ..L
                    lbeq      L16DB               * 17CA 10 27 FF 0D    .'..
                    cmpx      #86                 * 17CE 8C 00 56       ..V
                    lbeq      L16FD               * 17D1 10 27 FF 28    .'.(
                    cmpx      #73                 * 17D5 8C 00 49       ..I
                    lbeq      L171F               * 17D8 10 27 FF 43    .'.C
                    cmpx      #70                 * 17DC 8C 00 46       ..F
                    lbeq      L1741               * 17DF 10 27 FF 5E    .'.^
                    cmpx      #66                 * 17E3 8C 00 42       ..B
                    lbeq      L1777               * 17E6 10 27 FF 8D    .'..
L17EA               ldb       $01,S               * 17EA E6 61          fa
                    cmpb      #68                 * 17EC C1 44          AD
                    lbne      L154E               * 17EE 10 26 FD 5C    .&}\
                    ldd       #109                * 17F2 CC 00 6D       L.m
                    pshs      D                   * 17F5 34 06          4.
                    lbsr      L19C1               * 17F7 17 01 C7       ..G
                    leas      $02,S               * 17FA 32 62          2b
                    ldd       >U0007,Y            * 17FC EC A9 00 07    l)..
                    lbne      L1C74               * 1800 10 26 04 70    .&.p
                    ldd       >U000D,Y            * 1804 EC A9 00 0D    l)..
                    addd      #-1                 * 1808 C3 FF FF       C..
                    leax      >U0225,Y            * 180B 30 A9 02 25    0).%
                    leax      D,X                 * 180F 30 8B          0.
                    ldd       #109                * 1811 CC 00 6D       L.m
                    stb       0,X                 * 1814 E7 84          g.
                    lbra      L1C74               * 1816 16 04 5B       ..[

* -- method --
L1819               pshs      U                   * 1819 34 40          4@
                    ldd       #-87                * 181B CC FF A9       L.)
                    lbsr      _stkcheck           * 181E 17 E8 EE       .hn
                    leas      -$03,S              * 1821 32 7D          2}
                    ldd       #4                  * 1823 CC 00 04       L..
                    pshs      D                   * 1826 34 06          4.
                    ldd       #4                  * 1828 CC 00 04       L..
                    pshs      D                   * 182B 34 06          4.
                    ldd       #12                 * 182D CC 00 0C       L..
                    pshs      D                   * 1830 34 06          4.
                    ldd       #20                 * 1832 CC 00 14       L..
                    pshs      D                   * 1835 34 06          4.
                    ldd       #2                  * 1837 CC 00 02       L..
                    pshs      D                   * 183A 34 06          4.
                    ldd       #40                 * 183C CC 00 28       L.(
                    pshs      D                   * 183F 34 06          4.
                    ldd       #1                  * 1841 CC 00 01       L..
                    pshs      D                   * 1844 34 06          4.
                    ldd       #1                  * 1846 CC 00 01       L..
                    pshs      D                   * 1849 34 06          4.
                    lbsr      L3A52               * 184B 17 22 04       .".
                    leas      <$0010,S            * 184E 32 E8 10       2h.
                    ldd       #2                  * 1851 CC 00 02       L..
                    pshs      D                   * 1854 34 06          4.
                    clra                          * 1856 4F             O
                    clrb                          * 1857 5F             _
                    pshs      D                   * 1858 34 06          4.
                    ldd       #10                 * 185A CC 00 0A       L..
                    pshs      D                   * 185D 34 06          4.
                    ldd       #18                 * 185F CC 00 12       L..
                    pshs      D                   * 1862 34 06          4.
                    ldd       #3                  * 1864 CC 00 03       L..
                    pshs      D                   * 1867 34 06          4.
                    ldd       #41                 * 1869 CC 00 29       L.)
                    pshs      D                   * 186C 34 06          4.
                    clra                          * 186E 4F             O
                    clrb                          * 186F 5F             _
                    pshs      D                   * 1870 34 06          4.
                    ldd       #1                  * 1872 CC 00 01       L..
                    pshs      D                   * 1875 34 06          4.
                    lbsr      L3A52               * 1877 17 21 D8       .!X
                    leas      <$0010,S            * 187A 32 E8 10       2h.
                    ldd       #1                  * 187D CC 00 01       L..
                    pshs      D                   * 1880 34 06          4.
                    lbsr      L3AEC               * 1882 17 22 67       ."g
                    leas      $02,S               * 1885 32 62          2b
                    clra                          * 1887 4F             O
                    clrb                          * 1888 5F             _
                    lbra      L18DC               * 1889 16 00 50       ..P
L188C               ldd       $01,S               * 188C EC 61          la
                    pshs      D                   * 188E 34 06          4.
                    clra                          * 1890 4F             O
                    clrb                          * 1891 5F             _
                    pshs      D                   * 1892 34 06          4.
                    ldd       #1                  * 1894 CC 00 01       L..
                    pshs      D                   * 1897 34 06          4.
                    lbsr      L3B2A               * 1899 17 22 8E       .".
                    leas      $06,S               * 189C 32 66          2f
                    ldd       $01,S               * 189E EC 61          la
                    beq       L18BA               * 18A0 27 18          '.
                    ldd       $01,S               * 18A2 EC 61          la
                    aslb                          * 18A4 58             X
                    rola                          * 18A5 49             I
                    leax      >U000F,Y            * 18A6 30 A9 00 0F    0)..
                    leax      D,X                 * 18AA 30 8B          0.
                    ldd       0,X                 * 18AC EC 84          l.
                    pshs      D                   * 18AE 34 06          4.
                    ldd       #1                  * 18B0 CC 00 01       L..
                    pshs      D                   * 18B3 34 06          4.
                    lbsr      L3A9F               * 18B5 17 21 E7       .!g
                    leas      $04,S               * 18B8 32 64          2d
L18BA               ldd       $01,S               * 18BA EC 61          la
                    aslb                          * 18BC 58             X
                    rola                          * 18BD 49             I
                    leax      >U001F,Y            * 18BE 30 A9 00 1F    0)..
                    leax      D,X                 * 18C2 30 8B          0.
                    ldd       0,X                 * 18C4 EC 84          l.
                    pshs      D                   * 18C6 34 06          4.
                    ldd       $03,S               * 18C8 EC 63          lc
                    pshs      D                   * 18CA 34 06          4.
                    leax      >NumString,PC       * 18CC 30 8D 14 35    0..5
                    pshs      X                   * 18D0 34 10          4.
                    lbsr      printf              * 18D2 17 14 78       ..x
                    leas      $06,S               * 18D5 32 66          2f
                    ldd       $01,S               * 18D7 EC 61          la
                    addd      #1                  * 18D9 C3 00 01       C..
L18DC               std       $01,S               * 18DC ED 61          ma
                    ldd       $01,S               * 18DE EC 61          la
                    cmpd      #8                  * 18E0 10 83 00 08    ....
                    lblt      L188C               * 18E4 10 2D FF A4    .-.$
                    leax      >ClrNum,PC          * 18E8 30 8D 14 22    0.."
                    pshs      X                   * 18EC 34 10          4.
                    lbsr      printf              * 18EE 17 14 5C       ..\
                    leas      $02,S               * 18F1 32 62          2b
                    leax      >U0049,Y            * 18F3 30 A9 00 49    0).I
                    pshs      X                   * 18F7 34 10          4.
                    lbsr      L337C               * 18F9 17 1A 80       ...
                    leas      $02,S               * 18FC 32 62          2b
                    ldd       #1                  * 18FE CC 00 01       L..
                    pshs      D                   * 1901 34 06          4.
                    leax      $02,S               * 1903 30 62          0b
                    pshs      X                   * 1905 34 10          4.
                    clra                          * 1907 4F             O
                    clrb                          * 1908 5F             _
                    pshs      D                   * 1909 34 06          4.
                    lbsr      read                * 190B 17 1F 96       ...
                    leas      $06,S               * 190E 32 66          2f
                    ldb       0,S                 * 1910 E6 E4          fd
                    sex                           * 1912 1D             .
                    subd      #48                 * 1913 83 00 30       ..0
                    stb       0,S                 * 1916 E7 E4          gd
                    ldd       #1                  * 1918 CC 00 01       L..
                    pshs      D                   * 191B 34 06          4.
                    lbsr      L3A82               * 191D 17 21 62       .!b
                    leas      $02,S               * 1920 32 62          2b
                    ldd       #1                  * 1922 CC 00 01       L..
                    pshs      D                   * 1925 34 06          4.
                    lbsr      L3A82               * 1927 17 21 58       .!X
                    leas      $02,S               * 192A 32 62          2b
                    ldb       0,S                 * 192C E6 E4          fd
                    sex                           * 192E 1D             .
                    leas      $03,S               * 192F 32 63          2c
                    puls      PC,U                * 1931 35 C0          5@

* -- method --
L1933               pshs      U                   * 1933 34 40          4@
                    ldd       #-70                * 1935 CC FF BA       L.:
                    lbsr      _stkcheck           * 1938 17 E7 D4       .gT
                    ldd       >U000D,Y            * 193B EC A9 00 0D    l)..
                    addd      #3                  * 193F C3 00 03       C..
                    cmpd      #8192               * 1942 10 83 20 00    .. .
                    lbge      L19B6               * 1946 10 2C 00 6C    .,.l
                    ldd       >U000D,Y            * 194A EC A9 00 0D    l)..
                    addd      #1                  * 194E C3 00 01       C..
                    std       >U000D,Y            * 1951 ED A9 00 0D    m)..
                    subd      #1                  * 1955 83 00 01       ...
                    leax      >U0225,Y            * 1958 30 A9 02 25    0).%
                    leax      D,X                 * 195C 30 8B          0.
                    ldd       #27                 * 195E CC 00 1B       L..
                    stb       0,X                 * 1961 E7 84          g.
                    ldd       >U000D,Y            * 1963 EC A9 00 0D    l)..
                    addd      #1                  * 1967 C3 00 01       C..
                    std       >U000D,Y            * 196A ED A9 00 0D    m)..
                    subd      #1                  * 196E 83 00 01       ...
                    leax      >U0225,Y            * 1971 30 A9 02 25    0).%
                    leax      D,X                 * 1975 30 8B          0.
                    ldd       #91                 * 1977 CC 00 5B       L.[
                    stb       0,X                 * 197A E7 84          g.
                    ldb       $05,S               * 197C E6 65          fe
                    cmpb      #74                 * 197E C1 4A          AJ
                    bne       L199B               * 1980 26 19          &.
                    ldd       >U000D,Y            * 1982 EC A9 00 0D    l)..
                    addd      #1                  * 1986 C3 00 01       C..
                    std       >U000D,Y            * 1989 ED A9 00 0D    m)..
                    subd      #1                  * 198D 83 00 01       ...
                    leax      >U0225,Y            * 1990 30 A9 02 25    0).%
                    leax      D,X                 * 1994 30 8B          0.
                    ldd       #50                 * 1996 CC 00 32       L.2
                    stb       0,X                 * 1999 E7 84          g.
L199B               ldd       >U000D,Y            * 199B EC A9 00 0D    l)..
                    addd      #1                  * 199F C3 00 01       C..
                    std       >U000D,Y            * 19A2 ED A9 00 0D    m)..
                    subd      #1                  * 19A6 83 00 01       ...
                    leax      >U0225,Y            * 19A9 30 A9 02 25    0).%
                    leax      D,X                 * 19AD 30 8B          0.
                    ldb       $05,S               * 19AF E6 65          fe
                    stb       0,X                 * 19B1 E7 84          g.
                    lbra      L1C76               * 19B3 16 02 C0       ..@
L19B6               ldd       #1                  * 19B6 CC 00 01       L..
                    pshs      D                   * 19B9 34 06          4.
                    lbsr      L3AD8               * 19BB 17 21 1A       .!.
                    lbra      L1C74               * 19BE 16 02 B3       ..3

* -- method --
L19C1               pshs      U                   * 19C1 34 40          4@
                    ldd       #-76                * 19C3 CC FF B4       L.4
                    lbsr      _stkcheck           * 19C6 17 E7 46       .gF
                    leas      -$02,S              * 19C9 32 7E          2~
                    ldd       >U0005,Y            * 19CB EC A9 00 05    l)..
                    lbeq      L1B18               * 19CF 10 27 01 45    .'.E
                    ldb       $07,S               * 19D3 E6 67          fg
                    sex                           * 19D5 1D             .
                    leax      >U010D,Y            * 19D6 30 A9 01 0D    0)..
                    leax      D,X                 * 19DA 30 8B          0.
                    ldb       0,X                 * 19DC E6 84          f.
                    clra                          * 19DE 4F             O
                    andb      #8                  * 19DF C4 08          D.
                    beq       L1A0F               * 19E1 27 2C          ',
                    ldd       >dpsiz,Y            * 19E3 EC A9 00 01    l)..
                    pshs      D                   * 19E7 34 06          4.
                    ldd       #5                  * 19E9 CC 00 05       L..
                    lbsr      L365D               * 19EC 17 1C 6E       ..n
                    leax      >U01E7,Y            * 19EF 30 A9 01 E7    0).g
                    leax      D,X                 * 19F3 30 8B          0.
                    tfr       X,D                 * 19F5 1F 10          ..
                    pshs      D                   * 19F7 34 06          4.
                    ldd       >U0003,Y            * 19F9 EC A9 00 03    l)..
                    addd      #1                  * 19FD C3 00 01       C..
                    std       >U0003,Y            * 1A00 ED A9 00 03    m)..
                    subd      #1                  * 1A04 83 00 01       ...
                    addd      ,S++                * 1A07 E3 E1          ca
                    tfr       D,X                 * 1A09 1F 01          ..
                    ldb       $07,S               * 1A0B E6 67          fg
                    stb       0,X                 * 1A0D E7 84          g.
L1A0F               ldb       $07,S               * 1A0F E6 67          fg
                    sex                           * 1A11 1D             .
                    leax      >U010D,Y            * 1A12 30 A9 01 0D    0)..
                    leax      D,X                 * 1A16 30 8B          0.
                    ldb       0,X                 * 1A18 E6 84          f.
                    clra                          * 1A1A 4F             O
                    andb      #6                  * 1A1B C4 06          D.
                    lbeq      L1AA2               * 1A1D 10 27 00 81    .'..
                    ldd       >U0003,Y            * 1A21 EC A9 00 03    l)..
                    ble       L1A6C               * 1A25 2F 45          /E
                    ldd       >dpsiz,Y            * 1A27 EC A9 00 01    l)..
                    pshs      D                   * 1A2B 34 06          4.
                    ldd       #5                  * 1A2D CC 00 05       L..
                    lbsr      L365D               * 1A30 17 1C 2A       ..*
                    leax      >U01E7,Y            * 1A33 30 A9 01 E7    0).g
                    leax      D,X                 * 1A37 30 8B          0.
                    ldd       >U0003,Y            * 1A39 EC A9 00 03    l)..
                    leax      D,X                 * 1A3D 30 8B          0.
                    clra                          * 1A3F 4F             O
                    clrb                          * 1A40 5F             _
                    stb       0,X                 * 1A41 E7 84          g.
                    ldd       >dpsiz,Y            * 1A43 EC A9 00 01    l)..
                    leax      >U01DD,Y            * 1A47 30 A9 01 DD    0).]
                    leax      D,X                 * 1A4B 30 8B          0.
                    pshs      X                   * 1A4D 34 10          4.
                    ldd       >dpsiz,Y            * 1A4F EC A9 00 01    l)..
                    pshs      D                   * 1A53 34 06          4.
                    ldd       #5                  * 1A55 CC 00 05       L..
                    lbsr      L365D               * 1A58 17 1C 02       ...
                    leax      >U01E7,Y            * 1A5B 30 A9 01 E7    0).g
                    leax      D,X                 * 1A5F 30 8B          0.
                    pshs      X                   * 1A61 34 10          4.
                    lbsr      L35CC               * 1A63 17 1B 66       ..f
                    leas      $02,S               * 1A66 32 62          2b
                    stb       [,S++]              * 1A68 E7 F1          gq
                    bra       L1A7B               * 1A6A 20 0F           .
L1A6C               ldd       >dpsiz,Y            * 1A6C EC A9 00 01    l)..
                    leax      >U01DD,Y            * 1A70 30 A9 01 DD    0).]
                    leax      D,X                 * 1A74 30 8B          0.
                    ldd       #1                  * 1A76 CC 00 01       L..
                    stb       0,X                 * 1A79 E7 84          g.
L1A7B               ldd       >U0003,Y            * 1A7B EC A9 00 03    l)..
                    bgt       L1A87               * 1A7F 2E 06          ..
                    ldb       $07,S               * 1A81 E6 67          fg
                    cmpb      #109                * 1A83 C1 6D          Am
                    beq       L1A92               * 1A85 27 0B          '.
L1A87               ldd       >dpsiz,Y            * 1A87 EC A9 00 01    l)..
                    addd      #1                  * 1A8B C3 00 01       C..
                    std       >dpsiz,Y            * 1A8E ED A9 00 01    m)..
L1A92               clra                          * 1A92 4F             O
                    clrb                          * 1A93 5F             _
                    std       >U0003,Y            * 1A94 ED A9 00 03    m)..
                    ldb       $07,S               * 1A98 E6 67          fg
                    sex                           * 1A9A 1D             .
                    pshs      D                   * 1A9B 34 06          4.
                    lbsr      L1C78               * 1A9D 17 01 D8       ..X
                    leas      $02,S               * 1AA0 32 62          2b
L1AA2               ldb       $07,S               * 1AA2 E6 67          fg
                    cmpb      #59                 * 1AA4 C1 3B          A;
                    lbne      L1C74               * 1AA6 10 26 01 CA    .&.J
                    ldd       >U0003,Y            * 1AAA EC A9 00 03    l)..
                    ble       L1AF5               * 1AAE 2F 45          /E
                    ldd       >dpsiz,Y            * 1AB0 EC A9 00 01    l)..
                    pshs      D                   * 1AB4 34 06          4.
                    ldd       #5                  * 1AB6 CC 00 05       L..
                    lbsr      L365D               * 1AB9 17 1B A1       ..!
                    leax      >U01E7,Y            * 1ABC 30 A9 01 E7    0).g
                    leax      D,X                 * 1AC0 30 8B          0.
                    ldd       >U0003,Y            * 1AC2 EC A9 00 03    l)..
                    leax      D,X                 * 1AC6 30 8B          0.
                    clra                          * 1AC8 4F             O
                    clrb                          * 1AC9 5F             _
                    stb       0,X                 * 1ACA E7 84          g.
                    ldd       >dpsiz,Y            * 1ACC EC A9 00 01    l)..
                    leax      >U01DD,Y            * 1AD0 30 A9 01 DD    0).]
                    leax      D,X                 * 1AD4 30 8B          0.
                    pshs      X                   * 1AD6 34 10          4.
                    ldd       >dpsiz,Y            * 1AD8 EC A9 00 01    l)..
                    pshs      D                   * 1ADC 34 06          4.
                    ldd       #5                  * 1ADE CC 00 05       L..
                    lbsr      L365D               * 1AE1 17 1B 79       ..y
                    leax      >U01E7,Y            * 1AE4 30 A9 01 E7    0).g
                    leax      D,X                 * 1AE8 30 8B          0.
                    pshs      X                   * 1AEA 34 10          4.
                    lbsr      L35CC               * 1AEC 17 1A DD       ..]
                    leas      $02,S               * 1AEF 32 62          2b
                    stb       [,S++]              * 1AF1 E7 F1          gq
                    bra       L1B04               * 1AF3 20 0F           .
L1AF5               ldd       >dpsiz,Y            * 1AF5 EC A9 00 01    l)..
                    leax      >U01DD,Y            * 1AF9 30 A9 01 DD    0).]
                    leax      D,X                 * 1AFD 30 8B          0.
                    ldd       #1                  * 1AFF CC 00 01       L..
                    stb       0,X                 * 1B02 E7 84          g.
L1B04               ldd       >dpsiz,Y            * 1B04 EC A9 00 01    l)..
                    addd      #1                  * 1B08 C3 00 01       C..
                    std       >dpsiz,Y            * 1B0B ED A9 00 01    m)..
                    clra                          * 1B0F 4F             O
                    clrb                          * 1B10 5F             _
                    std       >U0003,Y            * 1B11 ED A9 00 03    m)..
                    lbra      L1C74               * 1B15 16 01 5C       ..\
L1B18               ldd       #1                  * 1B18 CC 00 01       L..
                    pshs      D                   * 1B1B 34 06          4.
                    leax      $09,S               * 1B1D 30 69          0i
                    pshs      X                   * 1B1F 34 10          4.
                    ldd       #1                  * 1B21 CC 00 01       L..
                    pshs      D                   * 1B24 34 06          4.
                    lbsr      write               * 1B26 17 1D AC       ..,
                    leas      $06,S               * 1B29 32 66          2f
                    ldb       $07,S               * 1B2B E6 67          fg
                    sex                           * 1B2D 1D             .
                    tfr       D,X                 * 1B2E 1F 01          ..
                    lbra      L1C5C               * 1B30 16 01 29       ..)
L1B33               ldd       >U021B,Y            * 1B33 EC A9 02 1B    l)..
                    addd      #1                  * 1B37 C3 00 01       C..
                    std       >U021B,Y            * 1B3A ED A9 02 1B    m)..
                    cmpd      #23                 * 1B3E 10 83 00 17    ....
                    lble      L1C74               * 1B42 10 2F 01 2E    ./..
                    ldd       #23                 * 1B46 CC 00 17       L..
                    lbra      L1C56               * 1B49 16 01 0A       ...
L1B4C               clra                          * 1B4C 4F             O
                    clrb                          * 1B4D 5F             _
                    lbra      L1BB3               * 1B4E 16 00 62       ..b
L1B51               clra                          * 1B51 4F             O
                    clrb                          * 1B52 5F             _
                    bra       L1B9E               * 1B53 20 49           I
L1B55               ldd       >U021B,Y            * 1B55 EC A9 02 1B    l)..
                    pshs      D                   * 1B59 34 06          4.
                    ldd       #80                 * 1B5B CC 00 50       L.P
                    lbsr      L365D               * 1B5E 17 1A FC       ..|
                    leax      >U2225,Y            * 1B61 30 A9 22 25    0)"%
                    leax      D,X                 * 1B65 30 8B          0.
                    ldd       >U0219,Y            * 1B67 EC A9 02 19    l)..
                    leax      D,X                 * 1B6B 30 8B          0.
                    clra                          * 1B6D 4F             O
                    clrb                          * 1B6E 5F             _
                    stb       0,X                 * 1B6F E7 84          g.
                    ldd       >U021B,Y            * 1B71 EC A9 02 1B    l)..
                    pshs      D                   * 1B75 34 06          4.
                    ldd       #160                * 1B77 CC 00 A0       L.
                    lbsr      L365D               * 1B7A 17 1A E0       ..`
                    leax      >U2955,Y            * 1B7D 30 A9 29 55    0))U
                    leax      D,X                 * 1B81 30 8B          0.
                    tfr       X,D                 * 1B83 1F 10          ..
                    pshs      D                   * 1B85 34 06          4.
                    ldd       >U0219,Y            * 1B87 EC A9 02 19    l)..
                    aslb                          * 1B8B 58             X
                    rola                          * 1B8C 49             I
                    addd      ,S++                * 1B8D E3 E1          ca
                    tfr       D,X                 * 1B8F 1F 01          ..
                    ldd       >U0009,Y            * 1B91 EC A9 00 09    l)..
                    std       0,X                 * 1B95 ED 84          m.
                    ldd       >U021B,Y            * 1B97 EC A9 02 1B    l)..
                    addd      #1                  * 1B9B C3 00 01       C..
L1B9E               std       >U021B,Y            * 1B9E ED A9 02 1B    m)..
                    ldd       >U021B,Y            * 1BA2 EC A9 02 1B    l)..
                    cmpd      #23                 * 1BA6 10 83 00 17    ....
                    blt       L1B55               * 1BAA 2D A9          -)
                    ldd       >U0219,Y            * 1BAC EC A9 02 19    l)..
                    addd      #1                  * 1BB0 C3 00 01       C..
L1BB3               std       >U0219,Y            * 1BB3 ED A9 02 19    m)..
                    ldd       >U0219,Y            * 1BB7 EC A9 02 19    l)..
                    cmpd      #80                 * 1BBB 10 83 00 50    ...P
                    lblt      L1B51               * 1BBF 10 2D FF 8E    .-..
                    clra                          * 1BC3 4F             O
                    clrb                          * 1BC4 5F             _
                    std       >U0219,Y            * 1BC5 ED A9 02 19    m)..
                    clra                          * 1BC9 4F             O
                    clrb                          * 1BCA 5F             _
                    lbra      L1C56               * 1BCB 16 00 88       ...
L1BCE               clra                          * 1BCE 4F             O
                    clrb                          * 1BCF 5F             _
                    std       >U0219,Y            * 1BD0 ED A9 02 19    m)..
                    lbra      L1C74               * 1BD4 16 00 9D       ...
L1BD7               ldb       $07,S               * 1BD7 E6 67          fg
                    cmpb      #32                 * 1BD9 C1 20          A
                    bge       L1BE3               * 1BDB 2C 06          ,.
                    ldb       $07,S               * 1BDD E6 67          fg
                    lbge      L1C74               * 1BDF 10 2C 00 91    .,..
L1BE3               ldd       >U0007,Y            * 1BE3 EC A9 00 07    l)..
                    beq       L1C2B               * 1BE7 27 42          'B
                    ldd       >U021B,Y            * 1BE9 EC A9 02 1B    l)..
                    pshs      D                   * 1BED 34 06          4.
                    ldd       #80                 * 1BEF CC 00 50       L.P
                    lbsr      L365D               * 1BF2 17 1A 68       ..h
                    leax      >U2225,Y            * 1BF5 30 A9 22 25    0)"%
                    leax      D,X                 * 1BF9 30 8B          0.
                    ldd       >U0219,Y            * 1BFB EC A9 02 19    l)..
                    leax      D,X                 * 1BFF 30 8B          0.
                    ldb       $07,S               * 1C01 E6 67          fg
                    stb       0,X                 * 1C03 E7 84          g.
                    ldd       >U021B,Y            * 1C05 EC A9 02 1B    l)..
                    pshs      D                   * 1C09 34 06          4.
                    ldd       #160                * 1C0B CC 00 A0       L.
                    lbsr      L365D               * 1C0E 17 1A 4C       ..L
                    leax      >U2955,Y            * 1C11 30 A9 29 55    0))U
                    leax      D,X                 * 1C15 30 8B          0.
                    tfr       X,D                 * 1C17 1F 10          ..
                    pshs      D                   * 1C19 34 06          4.
                    ldd       >U0219,Y            * 1C1B EC A9 02 19    l)..
                    aslb                          * 1C1F 58             X
                    rola                          * 1C20 49             I
                    addd      ,S++                * 1C21 E3 E1          ca
                    tfr       D,X                 * 1C23 1F 01          ..
                    ldd       >U0009,Y            * 1C25 EC A9 00 09    l)..
                    std       0,X                 * 1C29 ED 84          m.
L1C2B               ldd       >U0219,Y            * 1C2B EC A9 02 19    l)..
                    addd      #1                  * 1C2F C3 00 01       C..
                    std       >U0219,Y            * 1C32 ED A9 02 19    m)..
                    cmpd      #80                 * 1C36 10 83 00 50    ...P
                    blt       L1C74               * 1C3A 2D 38          -8
                    clra                          * 1C3C 4F             O
                    clrb                          * 1C3D 5F             _
                    std       >U0219,Y            * 1C3E ED A9 02 19    m)..
                    ldd       >U021B,Y            * 1C42 EC A9 02 1B    l)..
                    addd      #1                  * 1C46 C3 00 01       C..
                    std       >U021B,Y            * 1C49 ED A9 02 1B    m)..
                    cmpd      #23                 * 1C4D 10 83 00 17    ....
                    blt       L1C74               * 1C51 2D 21          -!
                    ldd       #22                 * 1C53 CC 00 16       L..
L1C56               std       >U021B,Y            * 1C56 ED A9 02 1B    m)..
                    bra       L1C74               * 1C5A 20 18           .
L1C5C               cmpx      #10                 * 1C5C 8C 00 0A       ...
                    lbeq      L1B33               * 1C5F 10 27 FE D0    .'~P
                    cmpx      #12                 * 1C63 8C 00 0C       ...
                    lbeq      L1B4C               * 1C66 10 27 FE E2    .'~b
                    cmpx      #13                 * 1C6A 8C 00 0D       ...
                    lbeq      L1BCE               * 1C6D 10 27 FF 5D    .'.]
                    lbra      L1BD7               * 1C71 16 FF 63       ..c
L1C74               leas      $02,S               * 1C74 32 62          2b
L1C76               puls      PC,U                * 1C76 35 C0          5@

* -- method --
L1C78               pshs      U                   * 1C78 34 40          4@
                    ldd       #-79                * 1C7A CC FF B1       L.1
                    lbsr      _stkcheck           * 1C7D 17 E4 8F       .d.
                    leas      -$05,S              * 1C80 32 7B          2{
                    clra                          * 1C82 4F             O
                    clrb                          * 1C83 5F             _
                    std       >U0005,Y            * 1C84 ED A9 00 05    m)..
                    ldb       $0A,S               * 1C88 E6 6A          fj
                    sex                           * 1C8A 1D             .
                    tfr       D,X                 * 1C8B 1F 01          ..
                    lbra      L209D               * 1C8D 16 04 0D       ...
L1C90               ldb       >U01DD,Y            * 1C90 E6 A9 01 DD    f).]
                    sex                           * 1C94 1D             .
                    addd      #-1                 * 1C95 C3 FF FF       C..
                    pshs      D                   * 1C98 34 06          4.
                    ldb       >U01DE,Y            * 1C9A E6 A9 01 DE    f).^
                    sex                           * 1C9E 1D             .
                    addd      #-1                 * 1C9F C3 FF FF       C..
                    pshs      D                   * 1CA2 34 06          4.
                    ldd       #1                  * 1CA4 CC 00 01       L..
                    pshs      D                   * 1CA7 34 06          4.
                    lbsr      L3B2A               * 1CA9 17 1E 7E       ..~
                    leas      $06,S               * 1CAC 32 66          2f
                    ldb       >U01DE,Y            * 1CAE E6 A9 01 DE    f).^
                    sex                           * 1CB2 1D             .
                    addd      #-1                 * 1CB3 C3 FF FF       C..
                    std       >U0219,Y            * 1CB6 ED A9 02 19    m)..
                    ldb       >U01DD,Y            * 1CBA E6 A9 01 DD    f).]
                    sex                           * 1CBE 1D             .
                    addd      #-1                 * 1CBF C3 FF FF       C..
                    std       >U021B,Y            * 1CC2 ED A9 02 1B    m)..
                    lbra      L20EA               * 1CC6 16 04 21       ..!
L1CC9               clra                          * 1CC9 4F             O
                    clrb                          * 1CCA 5F             _
                    bra       L1CEF               * 1CCB 20 22           "
L1CCD               ldd       #1                  * 1CCD CC 00 01       L..
                    pshs      D                   * 1CD0 34 06          4.
                    lbsr      L3AE0               * 1CD2 17 1E 0B       ...
                    leas      $02,S               * 1CD5 32 62          2b
                    ldd       >U021B,Y            * 1CD7 EC A9 02 1B    l)..
                    addd      #-1                 * 1CDB C3 FF FF       C..
                    std       >U021B,Y            * 1CDE ED A9 02 1B    m)..
                    bge       L1CEA               * 1CE2 2C 06          ,.
                    clra                          * 1CE4 4F             O
                    clrb                          * 1CE5 5F             _
                    std       >U021B,Y            * 1CE6 ED A9 02 1B    m)..
L1CEA               ldd       $03,S               * 1CEA EC 63          lc
                    addd      #1                  * 1CEC C3 00 01       C..
L1CEF               std       $03,S               * 1CEF ED 63          mc
                    ldb       >U01DD,Y            * 1CF1 E6 A9 01 DD    f).]
                    sex                           * 1CF5 1D             .
                    cmpd      $03,S               * 1CF6 10 A3 63       .#c
                    bgt       L1CCD               * 1CF9 2E D2          .R
                    lbra      L20EA               * 1CFB 16 03 EC       ..l
L1CFE               clra                          * 1CFE 4F             O
                    clrb                          * 1CFF 5F             _
                    bra       L1D2B               * 1D00 20 29           )
L1D02               ldd       >U021B,Y            * 1D02 EC A9 02 1B    l)..
                    addd      #1                  * 1D06 C3 00 01       C..
                    std       >U021B,Y            * 1D09 ED A9 02 1B    m)..
                    cmpd      #23                 * 1D0D 10 83 00 17    ....
                    blt       L1D1C               * 1D11 2D 09          -.
                    ldd       #22                 * 1D13 CC 00 16       L..
                    std       >U021B,Y            * 1D16 ED A9 02 1B    m)..
                    bra       L1D26               * 1D1A 20 0A           .
L1D1C               ldd       #1                  * 1D1C CC 00 01       L..
                    pshs      D                   * 1D1F 34 06          4.
                    lbsr      L3AE4               * 1D21 17 1D C0       ..@
                    leas      $02,S               * 1D24 32 62          2b
L1D26               ldd       $03,S               * 1D26 EC 63          lc
                    addd      #1                  * 1D28 C3 00 01       C..
L1D2B               std       $03,S               * 1D2B ED 63          mc
                    ldb       >U01DD,Y            * 1D2D E6 A9 01 DD    f).]
                    sex                           * 1D31 1D             .
                    cmpd      $03,S               * 1D32 10 A3 63       .#c
                    bgt       L1D02               * 1D35 2E CB          .K
                    lbra      L20EA               * 1D37 16 03 B0       ..0
L1D3A               clra                          * 1D3A 4F             O
                    clrb                          * 1D3B 5F             _
                    bra       L1D67               * 1D3C 20 29           )
L1D3E               ldd       >U0219,Y            * 1D3E EC A9 02 19    l)..
                    addd      #1                  * 1D42 C3 00 01       C..
                    std       >U0219,Y            * 1D45 ED A9 02 19    m)..
                    cmpd      #79                 * 1D49 10 83 00 4F    ...O
                    ble       L1D58               * 1D4D 2F 09          /.
                    ldd       #79                 * 1D4F CC 00 4F       L.O
                    std       >U0219,Y            * 1D52 ED A9 02 19    m)..
                    bra       L1D62               * 1D56 20 0A           .
L1D58               ldd       #1                  * 1D58 CC 00 01       L..
                    pshs      D                   * 1D5B 34 06          4.
                    lbsr      L3AD4               * 1D5D 17 1D 74       ..t
                    leas      $02,S               * 1D60 32 62          2b
L1D62               ldd       $03,S               * 1D62 EC 63          lc
                    addd      #1                  * 1D64 C3 00 01       C..
L1D67               std       $03,S               * 1D67 ED 63          mc
                    ldb       >U01DD,Y            * 1D69 E6 A9 01 DD    f).]
                    sex                           * 1D6D 1D             .
                    cmpd      $03,S               * 1D6E 10 A3 63       .#c
                    bgt       L1D3E               * 1D71 2E CB          .K
                    lbra      L20EA               * 1D73 16 03 74       ..t
L1D76               clra                          * 1D76 4F             O
                    clrb                          * 1D77 5F             _
                    bra       L1D9E               * 1D78 20 24           $
L1D7A               ldd       >U0219,Y            * 1D7A EC A9 02 19    l)..
                    addd      #-1                 * 1D7E C3 FF FF       C..
                    std       >U0219,Y            * 1D81 ED A9 02 19    m)..
                    bge       L1D8F               * 1D85 2C 08          ,.
                    clra                          * 1D87 4F             O
                    clrb                          * 1D88 5F             _
                    std       >U0219,Y            * 1D89 ED A9 02 19    m)..
                    bra       L1D99               * 1D8D 20 0A           .
L1D8F               ldd       #1                  * 1D8F CC 00 01       L..
                    pshs      D                   * 1D92 34 06          4.
                    lbsr      L3ADC               * 1D94 17 1D 45       ..E
                    leas      $02,S               * 1D97 32 62          2b
L1D99               ldd       $03,S               * 1D99 EC 63          lc
                    addd      #1                  * 1D9B C3 00 01       C..
L1D9E               std       $03,S               * 1D9E ED 63          mc
                    ldb       >U01DD,Y            * 1DA0 E6 A9 01 DD    f).]
                    sex                           * 1DA4 1D             .
                    cmpd      $03,S               * 1DA5 10 A3 63       .#c
                    bgt       L1D7A               * 1DA8 2E D0          .P
                    lbra      L20EA               * 1DAA 16 03 3D       ..=
L1DAD               ldd       >U0219,Y            * 1DAD EC A9 02 19    l)..
                    std       >U0221,Y            * 1DB1 ED A9 02 21    m).!
                    ldd       >U021B,Y            * 1DB5 EC A9 02 1B    l)..
                    std       >U0223,Y            * 1DB9 ED A9 02 23    m).#
                    lbra      L20EA               * 1DBD 16 03 2A       ..*
L1DC0               ldd       >U0221,Y            * 1DC0 EC A9 02 21    l).!
                    std       >U0219,Y            * 1DC4 ED A9 02 19    m)..
                    ldd       >U0223,Y            * 1DC8 EC A9 02 23    l).#
                    std       >U021B,Y            * 1DCC ED A9 02 1B    m)..
                    pshs      D                   * 1DD0 34 06          4.
                    ldd       >U0219,Y            * 1DD2 EC A9 02 19    l)..
                    pshs      D                   * 1DD6 34 06          4.
                    ldd       #1                  * 1DD8 CC 00 01       L..
                    pshs      D                   * 1DDB 34 06          4.
                    lbsr      L3B2A               * 1DDD 17 1D 4A       ..J
                    leas      $06,S               * 1DE0 32 66          2f
                    lbra      L20EA               * 1DE2 16 03 05       ...
L1DE5               ldd       #1                  * 1DE5 CC 00 01       L..
                    pshs      D                   * 1DE8 34 06          4.
                    lbsr      L3AEC               * 1DEA 17 1C FF       ...
                    leas      $02,S               * 1DED 32 62          2b
                    clra                          * 1DEF 4F             O
                    clrb                          * 1DF0 5F             _
                    lbra      L1E56               * 1DF1 16 00 62       ..b
L1DF4               clra                          * 1DF4 4F             O
                    clrb                          * 1DF5 5F             _
                    bra       L1E41               * 1DF6 20 49           I
L1DF8               ldd       >U021B,Y            * 1DF8 EC A9 02 1B    l)..
                    pshs      D                   * 1DFC 34 06          4.
                    ldd       #80                 * 1DFE CC 00 50       L.P
                    lbsr      L365D               * 1E01 17 18 59       ..Y
                    leax      >U2225,Y            * 1E04 30 A9 22 25    0)"%
                    leax      D,X                 * 1E08 30 8B          0.
                    ldd       >U0219,Y            * 1E0A EC A9 02 19    l)..
                    leax      D,X                 * 1E0E 30 8B          0.
                    clra                          * 1E10 4F             O
                    clrb                          * 1E11 5F             _
                    stb       0,X                 * 1E12 E7 84          g.
                    ldd       >U021B,Y            * 1E14 EC A9 02 1B    l)..
                    pshs      D                   * 1E18 34 06          4.
                    ldd       #160                * 1E1A CC 00 A0       L.
                    lbsr      L365D               * 1E1D 17 18 3D       ..=
                    leax      >U2955,Y            * 1E20 30 A9 29 55    0))U
                    leax      D,X                 * 1E24 30 8B          0.
                    tfr       X,D                 * 1E26 1F 10          ..
                    pshs      D                   * 1E28 34 06          4.
                    ldd       >U0219,Y            * 1E2A EC A9 02 19    l)..
                    aslb                          * 1E2E 58             X
                    rola                          * 1E2F 49             I
                    addd      ,S++                * 1E30 E3 E1          ca
                    tfr       D,X                 * 1E32 1F 01          ..
                    ldd       >U0009,Y            * 1E34 EC A9 00 09    l)..
                    std       0,X                 * 1E38 ED 84          m.
                    ldd       >U021B,Y            * 1E3A EC A9 02 1B    l)..
                    addd      #1                  * 1E3E C3 00 01       C..
L1E41               std       >U021B,Y            * 1E41 ED A9 02 1B    m)..
                    ldd       >U021B,Y            * 1E45 EC A9 02 1B    l)..
                    cmpd      #23                 * 1E49 10 83 00 17    ....
                    blt       L1DF8               * 1E4D 2D A9          -)
                    ldd       >U0219,Y            * 1E4F EC A9 02 19    l)..
                    addd      #1                  * 1E53 C3 00 01       C..
L1E56               std       >U0219,Y            * 1E56 ED A9 02 19    m)..
                    ldd       >U0219,Y            * 1E5A EC A9 02 19    l)..
                    cmpd      #80                 * 1E5E 10 83 00 50    ...P
                    lblt      L1DF4               * 1E62 10 2D FF 8E    .-..
                    clra                          * 1E66 4F             O
                    clrb                          * 1E67 5F             _
                    std       >U021B,Y            * 1E68 ED A9 02 1B    m)..
                    std       >U0219,Y            * 1E6C ED A9 02 19    m)..
                    lbra      L20EA               * 1E70 16 02 77       ..w
L1E73               ldd       #1                  * 1E73 CC 00 01       L..
                    pshs      D                   * 1E76 34 06          4.
                    lbsr      L3AC6               * 1E78 17 1C 4B       ..K
                    leas      $02,S               * 1E7B 32 62          2b
                    ldd       >U0219,Y            * 1E7D EC A9 02 19    l)..
                    bra       L1EC4               * 1E81 20 41           A
L1E83               ldd       >U021B,Y            * 1E83 EC A9 02 1B    l)..
                    pshs      D                   * 1E87 34 06          4.
                    ldd       #80                 * 1E89 CC 00 50       L.P
                    lbsr      L365D               * 1E8C 17 17 CE       ..N
                    leax      >U2225,Y            * 1E8F 30 A9 22 25    0)"%
                    leax      D,X                 * 1E93 30 8B          0.
                    ldd       $03,S               * 1E95 EC 63          lc
                    leax      D,X                 * 1E97 30 8B          0.
                    clra                          * 1E99 4F             O
                    clrb                          * 1E9A 5F             _
                    stb       0,X                 * 1E9B E7 84          g.
                    ldd       >U021B,Y            * 1E9D EC A9 02 1B    l)..
                    pshs      D                   * 1EA1 34 06          4.
                    ldd       #160                * 1EA3 CC 00 A0       L.
                    lbsr      L365D               * 1EA6 17 17 B4       ..4
                    leax      >U2955,Y            * 1EA9 30 A9 29 55    0))U
                    leax      D,X                 * 1EAD 30 8B          0.
                    tfr       X,D                 * 1EAF 1F 10          ..
                    pshs      D                   * 1EB1 34 06          4.
                    ldd       $05,S               * 1EB3 EC 65          le
                    aslb                          * 1EB5 58             X
                    rola                          * 1EB6 49             I
                    addd      ,S++                * 1EB7 E3 E1          ca
                    tfr       D,X                 * 1EB9 1F 01          ..
                    clra                          * 1EBB 4F             O
                    clrb                          * 1EBC 5F             _
                    std       0,X                 * 1EBD ED 84          m.
                    ldd       $03,S               * 1EBF EC 63          lc
                    addd      #1                  * 1EC1 C3 00 01       C..
L1EC4               std       $03,S               * 1EC4 ED 63          mc
                    ldd       $03,S               * 1EC6 EC 63          lc
                    cmpd      #80                 * 1EC8 10 83 00 50    ...P
                    blt       L1E83               * 1ECC 2D B5          -5
                    lbra      L20EA               * 1ECE 16 02 19       ...
L1ED1               clra                          * 1ED1 4F             O
                    clrb                          * 1ED2 5F             _
                    lbra      L208E               * 1ED3 16 01 B8       ..8
L1ED6               ldd       $03,S               * 1ED6 EC 63          lc
                    leax      >U01DD,Y            * 1ED8 30 A9 01 DD    0).]
                    leax      D,X                 * 1EDC 30 8B          0.
                    ldb       0,X                 * 1EDE E6 84          f.
                    sex                           * 1EE0 1D             .
                    tfr       D,X                 * 1EE1 1F 01          ..
                    lbra      L205D               * 1EE3 16 01 77       ..w
L1EE6               ldd       #2                  * 1EE6 CC 00 02       L..
                    pshs      D                   * 1EE9 34 06          4.
                    ldd       #1                  * 1EEB CC 00 01       L..
                    pshs      D                   * 1EEE 34 06          4.
                    lbsr      L3AA3               * 1EF0 17 1B B0       ..0
                    leas      $04,S               * 1EF3 32 64          2d
                    clra                          * 1EF5 4F             O
                    clrb                          * 1EF6 5F             _
                    pshs      D                   * 1EF7 34 06          4.
                    ldd       #1                  * 1EF9 CC 00 01       L..
                    pshs      D                   * 1EFC 34 06          4.
                    lbsr      L3A9F               * 1EFE 17 1B 9E       ...
                    leas      $04,S               * 1F01 32 64          2d
                    ldd       #1                  * 1F03 CC 00 01       L..
                    pshs      D                   * 1F06 34 06          4.
                    lbsr      L3B0A               * 1F08 17 1B FF       ...
                    leas      $02,S               * 1F0B 32 62          2b
                    ldd       #1                  * 1F0D CC 00 01       L..
                    pshs      D                   * 1F10 34 06          4.
                    lbsr      L3B14               * 1F12 17 1B FF       ...
                    leas      $02,S               * 1F15 32 62          2b
                    ldd       #1                  * 1F17 CC 00 01       L..
                    pshs      D                   * 1F1A 34 06          4.
                    lbsr      L3B00               * 1F1C 17 1B E1       ..a
                    leas      $02,S               * 1F1F 32 62          2b
                    clra                          * 1F21 4F             O
                    clrb                          * 1F22 5F             _
                    lbra      L2057               * 1F23 16 01 31       ..1
L1F26               ldd       >U0009,Y            * 1F26 EC A9 00 09    l)..
                    ora       #16                 * 1F2A 8A 10          ..
                    lbra      L2057               * 1F2C 16 01 28       ..(
L1F2F               ldd       #1                  * 1F2F CC 00 01       L..
                    pshs      D                   * 1F32 34 06          4.
                    lbsr      L3B05               * 1F34 17 1B CE       ..N
                    leas      $02,S               * 1F37 32 62          2b
                    ldd       >U0009,Y            * 1F39 EC A9 00 09    l)..
                    ora       #1                  * 1F3D 8A 01          ..
                    lbra      L2057               * 1F3F 16 01 15       ...
L1F42               ldd       #1                  * 1F42 CC 00 01       L..
                    pshs      D                   * 1F45 34 06          4.
                    lbsr      L3B0F               * 1F47 17 1B C5       ..E
                    leas      $02,S               * 1F4A 32 62          2b
                    ldd       >U0009,Y            * 1F4C EC A9 00 09    l)..
                    ora       #2                  * 1F50 8A 02          ..
                    lbra      L2057               * 1F52 16 01 02       ...
L1F55               ldd       #1                  * 1F55 CC 00 01       L..
                    pshs      D                   * 1F58 34 06          4.
                    lbsr      L3AFB               * 1F5A 17 1B 9E       ...
                    leas      $02,S               * 1F5D 32 62          2b
                    ldd       >U0009,Y            * 1F5F EC A9 00 09    l)..
                    ora       #4                  * 1F63 8A 04          ..
                    lbra      L2057               * 1F65 16 00 EF       ..o
L1F68               ldd       >U0009,Y            * 1F68 EC A9 00 09    l)..
                    clra                          * 1F6C 4F             O
                    andb      #15                 * 1F6D C4 0F          D.
                    aslb                          * 1F6F 58             X
                    rola                          * 1F70 49             I
                    leax      >U000F,Y            * 1F71 30 A9 00 0F    0)..
                    leax      D,X                 * 1F75 30 8B          0.
                    ldd       0,X                 * 1F77 EC 84          l.
                    pshs      D                   * 1F79 34 06          4.
                    ldd       #1                  * 1F7B CC 00 01       L..
                    pshs      D                   * 1F7E 34 06          4.
                    lbsr      L3A9F               * 1F80 17 1B 1C       ...
                    leas      $04,S               * 1F83 32 64          2d
                    ldd       >U0009,Y            * 1F85 EC A9 00 09    l)..
                    ora       #8                  * 1F89 8A 08          ..
                    lbra      L2057               * 1F8B 16 00 C9       ..I
L1F8E               ldd       $03,S               * 1F8E EC 63          lc
                    leax      >U01DD,Y            * 1F90 30 A9 01 DD    0).]
                    leax      D,X                 * 1F94 30 8B          0.
                    ldb       0,X                 * 1F96 E6 84          f.
                    cmpb      #30                 * 1F98 C1 1E          A.
                    lblt      L1FF5               * 1F9A 10 2D 00 57    .-.W
                    ldd       $03,S               * 1F9E EC 63          lc
                    leax      >U01DD,Y            * 1FA0 30 A9 01 DD    0).]
                    leax      D,X                 * 1FA4 30 8B          0.
                    ldb       0,X                 * 1FA6 E6 84          f.
                    cmpb      #38                 * 1FA8 C1 26          A&
                    bge       L1FF5               * 1FAA 2C 49          ,I
                    ldd       $03,S               * 1FAC EC 63          lc
                    leax      >U01DD,Y            * 1FAE 30 A9 01 DD    0).]
                    leax      D,X                 * 1FB2 30 8B          0.
                    ldb       0,X                 * 1FB4 E6 84          f.
                    sex                           * 1FB6 1D             .
                    addd      #-30                * 1FB7 C3 FF E2       C.b
                    aslb                          * 1FBA 58             X
                    rola                          * 1FBB 49             I
                    leax      >U000F,Y            * 1FBC 30 A9 00 0F    0)..
                    leax      D,X                 * 1FC0 30 8B          0.
                    ldd       0,X                 * 1FC2 EC 84          l.
                    pshs      D                   * 1FC4 34 06          4.
                    ldd       #1                  * 1FC6 CC 00 01       L..
                    pshs      D                   * 1FC9 34 06          4.
                    lbsr      L3A9F               * 1FCB 17 1A D1       ..Q
                    leas      $04,S               * 1FCE 32 64          2d
                    ldd       >U0009,Y            * 1FD0 EC A9 00 09    l)..
                    andb      #15                 * 1FD4 C4 0F          D.
                    std       >U0009,Y            * 1FD6 ED A9 00 09    m)..
                    pshs      D                   * 1FDA 34 06          4.
                    ldd       $05,S               * 1FDC EC 65          le
                    leax      >U01DD,Y            * 1FDE 30 A9 01 DD    0).]
                    leax      D,X                 * 1FE2 30 8B          0.
                    ldb       0,X                 * 1FE4 E6 84          f.
                    sex                           * 1FE6 1D             .
                    addd      #-30                * 1FE7 C3 FF E2       C.b
                    aslb                          * 1FEA 58             X
                    rola                          * 1FEB 49             I
                    aslb                          * 1FEC 58             X
                    rola                          * 1FED 49             I
                    aslb                          * 1FEE 58             X
                    rola                          * 1FEF 49             I
                    aslb                          * 1FF0 58             X
                    rola                          * 1FF1 49             I
                    lbra      L2053               * 1FF2 16 00 5E       ..^
L1FF5               ldd       $03,S               * 1FF5 EC 63          lc
                    leax      >U01DD,Y            * 1FF7 30 A9 01 DD    0).]
                    leax      D,X                 * 1FFB 30 8B          0.
                    ldb       0,X                 * 1FFD E6 84          f.
                    cmpb      #40                 * 1FFF C1 28          A(
                    lblt      L2089               * 2001 10 2D 00 84    .-..
                    ldd       $03,S               * 2005 EC 63          lc
                    leax      >U01DD,Y            * 2007 30 A9 01 DD    0).]
                    leax      D,X                 * 200B 30 8B          0.
                    ldb       0,X                 * 200D E6 84          f.
                    cmpb      #48                 * 200F C1 30          A0
                    lbge      L2089               * 2011 10 2C 00 74    .,.t
                    ldd       $03,S               * 2015 EC 63          lc
                    leax      >U01DD,Y            * 2017 30 A9 01 DD    0).]
                    leax      D,X                 * 201B 30 8B          0.
                    ldb       0,X                 * 201D E6 84          f.
                    sex                           * 201F 1D             .
                    addd      #-40                * 2020 C3 FF D8       C.X
                    aslb                          * 2023 58             X
                    rola                          * 2024 49             I
                    leax      >U000F,Y            * 2025 30 A9 00 0F    0)..
                    leax      D,X                 * 2029 30 8B          0.
                    ldd       0,X                 * 202B EC 84          l.
                    pshs      D                   * 202D 34 06          4.
                    ldd       #1                  * 202F CC 00 01       L..
                    pshs      D                   * 2032 34 06          4.
                    lbsr      L3AA3               * 2034 17 1A 6C       ..l
                    leas      $04,S               * 2037 32 64          2d
                    ldd       >U0009,Y            * 2039 EC A9 00 09    l)..
                    andb      #240                * 203D C4 F0          Dp
                    std       >U0009,Y            * 203F ED A9 00 09    m)..
                    pshs      D                   * 2043 34 06          4.
                    ldd       $05,S               * 2045 EC 65          le
                    leax      >U01DD,Y            * 2047 30 A9 01 DD    0).]
                    leax      D,X                 * 204B 30 8B          0.
                    ldb       0,X                 * 204D E6 84          f.
                    sex                           * 204F 1D             .
                    addd      #-40                * 2050 C3 FF D8       C.X
L2053               ora       ,S+                 * 2053 AA E0          *`
                    orb       ,S+                 * 2055 EA E0          j`
L2057               std       >U0009,Y            * 2057 ED A9 00 09    m)..
                    bra       L2089               * 205B 20 2C           ,
L205D               stx       -$02,S              * 205D AF 7E          /~
                    lbeq      L1EE6               * 205F 10 27 FE 83    .'~.
                    cmpx      #1                  * 2063 8C 00 01       ...
                    lbeq      L1F26               * 2066 10 27 FE BC    .'~<
                    cmpx      #4                  * 206A 8C 00 04       ...
                    lbeq      L1F2F               * 206D 10 27 FE BE    .'~>
                    cmpx      #5                  * 2071 8C 00 05       ...
                    lbeq      L1F42               * 2074 10 27 FE CA    .'~J
                    cmpx      #7                  * 2078 8C 00 07       ...
                    lbeq      L1F55               * 207B 10 27 FE D6    .'~V
                    cmpx      #8                  * 207F 8C 00 08       ...
                    lbeq      L1F68               * 2082 10 27 FE E2    .'~b
                    lbra      L1F8E               * 2086 16 FF 05       ...
L2089               ldd       $03,S               * 2089 EC 63          lc
                    addd      #1                  * 208B C3 00 01       C..
L208E               std       $03,S               * 208E ED 63          mc
                    ldd       $03,S               * 2090 EC 63          lc
                    cmpd      >dpsiz,Y            * 2092 10 A3 A9 00 01 .#)..
                    lblt      L1ED6               * 2097 10 2D FE 3B    .-~;
                    bra       L20EA               * 209B 20 4D           M
L209D               cmpx      #72                 * 209D 8C 00 48       ..H
                    lbeq      L1C90               * 20A0 10 27 FB EC    .'{l
                    cmpx      #102                * 20A4 8C 00 66       ..f
                    lbeq      L1C90               * 20A7 10 27 FB E5    .'{e
                    cmpx      #65                 * 20AB 8C 00 41       ..A
                    lbeq      L1CC9               * 20AE 10 27 FC 17    .'|.
                    cmpx      #66                 * 20B2 8C 00 42       ..B
                    lbeq      L1CFE               * 20B5 10 27 FC 45    .'|E
                    cmpx      #67                 * 20B9 8C 00 43       ..C
                    lbeq      L1D3A               * 20BC 10 27 FC 7A    .'|z
                    cmpx      #68                 * 20C0 8C 00 44       ..D
                    lbeq      L1D76               * 20C3 10 27 FC AF    .'|/
                    cmpx      #115                * 20C7 8C 00 73       ..s
                    lbeq      L1DAD               * 20CA 10 27 FC DF    .'|_
                    cmpx      #117                * 20CE 8C 00 75       ..u
                    lbeq      L1DC0               * 20D1 10 27 FC EB    .'|k
                    cmpx      #74                 * 20D5 8C 00 4A       ..J
                    lbeq      L1DE5               * 20D8 10 27 FD 09    .'}.
                    cmpx      #107                * 20DC 8C 00 6B       ..k
                    lbeq      L1E73               * 20DF 10 27 FD 90    .'}.
                    cmpx      #109                * 20E3 8C 00 6D       ..m
                    lbeq      L1ED1               * 20E6 10 27 FD E7    .'}g
L20EA               bsr       L20F0               * 20EA 8D 04          ..
                    leas      $05,S               * 20EC 32 65          2e
                    puls      PC,U                * 20EE 35 C0          5@

* -- method --
L20F0               pshs      U                   * 20F0 34 40          4@
                    ldd       #-66                * 20F2 CC FF BE       L.>
                    lbsr      _stkcheck           * 20F5 17 E0 17       .`.
                    leas      -$02,S              * 20F8 32 7E          2~
                    clra                          * 20FA 4F             O
                    clrb                          * 20FB 5F             _
                    bra       L2110               * 20FC 20 12           .
L20FE               ldd       0,S                 * 20FE EC E4          ld
                    leax      >U01DD,Y            * 2100 30 A9 01 DD    0).]
                    leax      D,X                 * 2104 30 8B          0.
                    ldd       #1                  * 2106 CC 00 01       L..
                    stb       0,X                 * 2109 E7 84          g.
                    ldd       0,S                 * 210B EC E4          ld
                    addd      #1                  * 210D C3 00 01       C..
L2110               std       0,S                 * 2110 ED E4          md
                    ldd       0,S                 * 2112 EC E4          ld
                    cmpd      #10                 * 2114 10 83 00 0A    ....
                    blt       L20FE               * 2118 2D E4          -d
                    clra                          * 211A 4F             O
                    clrb                          * 211B 5F             _
                    std       >dpsiz,Y            * 211C ED A9 00 01    m)..
                    clra                          * 2120 4F             O
                    clrb                          * 2121 5F             _
                    std       >U0003,Y            * 2122 ED A9 00 03    m)..
                    leas      $02,S               * 2126 32 62          2b
                    puls      PC,U                * 2128 35 C0          5@

* -- method --
L212A               pshs      U                   * 212A 34 40          4@
                    ldd       #-80                * 212C CC FF B0       L.0
                    lbsr      _stkcheck           * 212F 17 DF DD       ._]
                    leas      -$08,S              * 2132 32 78          2x
                    clra                          * 2134 4F             O
                    clrb                          * 2135 5F             _
                    std       $02,S               * 2136 ED 62          mb
                    clra                          * 2138 4F             O
                    clrb                          * 2139 5F             _
                    std       0,S                 * 213A ED E4          md
                    clra                          * 213C 4F             O
                    clrb                          * 213D 5F             _
                    lbra      L2396               * 213E 16 02 55       ..U
L2141               clra                          * 2141 4F             O
                    clrb                          * 2142 5F             _
                    lbra      L2385               * 2143 16 02 3F       ..?
L2146               ldd       $04,S               * 2146 EC 64          ld
                    pshs      D                   * 2148 34 06          4.
                    ldd       #80                 * 214A CC 00 50       L.P
                    lbsr      L365D               * 214D 17 15 0D       ...
                    leax      >U2225,Y            * 2150 30 A9 22 25    0)"%
                    leax      D,X                 * 2154 30 8B          0.
                    ldd       $06,S               * 2156 EC 66          lf
                    leax      D,X                 * 2158 30 8B          0.
                    ldb       0,X                 * 215A E6 84          f.
                    lbeq      L2348               * 215C 10 27 01 E8    .'.h
                    ldd       $02,S               * 2160 EC 62          lb
                    cmpd      $06,S               * 2162 10 A3 66       .#f
                    bne       L2170               * 2165 26 09          &.
                    ldd       0,S                 * 2167 EC E4          ld
                    cmpd      $04,S               * 2169 10 A3 64       .#d
                    lbeq      L22AD               * 216C 10 27 01 3D    .'.=
L2170               ldd       >U000D,Y            * 2170 EC A9 00 0D    l)..
                    addd      #8                  * 2174 C3 00 08       C..
                    cmpd      #8192               * 2177 10 83 20 00    .. .
                    lbge      L22A3               * 217B 10 2C 01 24    .,.$
                    ldd       >U000D,Y            * 217F EC A9 00 0D    l)..
                    addd      #1                  * 2183 C3 00 01       C..
                    std       >U000D,Y            * 2186 ED A9 00 0D    m)..
                    subd      #1                  * 218A 83 00 01       ...
                    leax      >U0225,Y            * 218D 30 A9 02 25    0).%
                    leax      D,X                 * 2191 30 8B          0.
                    ldd       #27                 * 2193 CC 00 1B       L..
                    stb       0,X                 * 2196 E7 84          g.
                    ldd       >U000D,Y            * 2198 EC A9 00 0D    l)..
                    addd      #1                  * 219C C3 00 01       C..
                    std       >U000D,Y            * 219F ED A9 00 0D    m)..
                    subd      #1                  * 21A3 83 00 01       ...
                    leax      >U0225,Y            * 21A6 30 A9 02 25    0).%
                    leax      D,X                 * 21AA 30 8B          0.
                    ldd       #91                 * 21AC CC 00 5B       L.[
                    stb       0,X                 * 21AF E7 84          g.
                    ldd       $04,S               * 21B1 EC 64          ld
                    addd      #1                  * 21B3 C3 00 01       C..
                    cmpd      #10                 * 21B6 10 83 00 0A    ....
                    blt       L21E4               * 21BA 2D 28          -(
                    ldd       >U000D,Y            * 21BC EC A9 00 0D    l)..
                    addd      #1                  * 21C0 C3 00 01       C..
                    std       >U000D,Y            * 21C3 ED A9 00 0D    m)..
                    subd      #1                  * 21C7 83 00 01       ...
                    leax      >U0225,Y            * 21CA 30 A9 02 25    0).%
                    leax      D,X                 * 21CE 30 8B          0.
                    pshs      X                   * 21D0 34 10          4.
                    ldd       $06,S               * 21D2 EC 66          lf
                    addd      #1                  * 21D4 C3 00 01       C..
                    pshs      D                   * 21D7 34 06          4.
                    ldd       #10                 * 21D9 CC 00 0A       L..
                    lbsr      L3711               * 21DC 17 15 32       ..2
                    addd      #48                 * 21DF C3 00 30       C.0
                    stb       [,S++]              * 21E2 E7 F1          gq
L21E4               ldd       >U000D,Y            * 21E4 EC A9 00 0D    l)..
                    addd      #1                  * 21E8 C3 00 01       C..
                    std       >U000D,Y            * 21EB ED A9 00 0D    m)..
                    subd      #1                  * 21EF 83 00 01       ...
                    leax      >U0225,Y            * 21F2 30 A9 02 25    0).%
                    leax      D,X                 * 21F6 30 8B          0.
                    pshs      X                   * 21F8 34 10          4.
                    ldd       $06,S               * 21FA EC 66          lf
                    addd      #1                  * 21FC C3 00 01       C..
                    pshs      D                   * 21FF 34 06          4.
                    ldd       #10                 * 2201 CC 00 0A       L..
                    lbsr      L36BE               * 2204 17 14 B7       ..7
                    addd      #48                 * 2207 C3 00 30       C.0
                    stb       [,S++]              * 220A E7 F1          gq
                    ldd       >U000D,Y            * 220C EC A9 00 0D    l)..
                    addd      #1                  * 2210 C3 00 01       C..
                    std       >U000D,Y            * 2213 ED A9 00 0D    m)..
                    subd      #1                  * 2217 83 00 01       ...
                    leax      >U0225,Y            * 221A 30 A9 02 25    0).%
                    leax      D,X                 * 221E 30 8B          0.
                    ldd       #59                 * 2220 CC 00 3B       L.;
                    stb       0,X                 * 2223 E7 84          g.
                    ldd       $06,S               * 2225 EC 66          lf
                    addd      #1                  * 2227 C3 00 01       C..
                    cmpd      #10                 * 222A 10 83 00 0A    ....
                    blt       L2258               * 222E 2D 28          -(
                    ldd       >U000D,Y            * 2230 EC A9 00 0D    l)..
                    addd      #1                  * 2234 C3 00 01       C..
                    std       >U000D,Y            * 2237 ED A9 00 0D    m)..
                    subd      #1                  * 223B 83 00 01       ...
                    leax      >U0225,Y            * 223E 30 A9 02 25    0).%
                    leax      D,X                 * 2242 30 8B          0.
                    pshs      X                   * 2244 34 10          4.
                    ldd       $08,S               * 2246 EC 68          lh
                    addd      #1                  * 2248 C3 00 01       C..
                    pshs      D                   * 224B 34 06          4.
                    ldd       #10                 * 224D CC 00 0A       L..
                    lbsr      L3711               * 2250 17 14 BE       ..>
                    addd      #48                 * 2253 C3 00 30       C.0
                    stb       [,S++]              * 2256 E7 F1          gq
L2258               ldd       >U000D,Y            * 2258 EC A9 00 0D    l)..
                    addd      #1                  * 225C C3 00 01       C..
                    std       >U000D,Y            * 225F ED A9 00 0D    m)..
                    subd      #1                  * 2263 83 00 01       ...
                    leax      >U0225,Y            * 2266 30 A9 02 25    0).%
                    leax      D,X                 * 226A 30 8B          0.
                    pshs      X                   * 226C 34 10          4.
                    ldd       $08,S               * 226E EC 68          lh
                    addd      #1                  * 2270 C3 00 01       C..
                    pshs      D                   * 2273 34 06          4.
                    ldd       #10                 * 2275 CC 00 0A       L..
                    lbsr      L36BE               * 2278 17 14 43       ..C
                    addd      #48                 * 227B C3 00 30       C.0
                    stb       [,S++]              * 227E E7 F1          gq
                    ldd       >U000D,Y            * 2280 EC A9 00 0D    l)..
                    addd      #1                  * 2284 C3 00 01       C..
                    std       >U000D,Y            * 2287 ED A9 00 0D    m)..
                    subd      #1                  * 228B 83 00 01       ...
                    leax      >U0225,Y            * 228E 30 A9 02 25    0).%
                    leax      D,X                 * 2292 30 8B          0.
                    ldd       #72                 * 2294 CC 00 48       L.H
                    stb       0,X                 * 2297 E7 84          g.
                    ldd       $06,S               * 2299 EC 66          lf
                    std       $02,S               * 229B ED 62          mb
                    ldd       $04,S               * 229D EC 64          ld
                    std       0,S                 * 229F ED E4          md
                    bra       L22AD               * 22A1 20 0A           .
L22A3               ldd       #1                  * 22A3 CC 00 01       L..
                    pshs      D                   * 22A6 34 06          4.
                    lbsr      L3AD8               * 22A8 17 18 2D       ..-
                    leas      $02,S               * 22AB 32 62          2b
L22AD               ldd       $04,S               * 22AD EC 64          ld
                    pshs      D                   * 22AF 34 06          4.
                    ldd       #160                * 22B1 CC 00 A0       L.
                    lbsr      L365D               * 22B4 17 13 A6       ..&
                    leax      >U2955,Y            * 22B7 30 A9 29 55    0))U
                    leax      D,X                 * 22BB 30 8B          0.
                    tfr       X,D                 * 22BD 1F 10          ..
                    pshs      D                   * 22BF 34 06          4.
                    ldd       $08,S               * 22C1 EC 68          lh
                    aslb                          * 22C3 58             X
                    rola                          * 22C4 49             I
                    addd      ,S++                * 22C5 E3 E1          ca
                    tfr       D,X                 * 22C7 1F 01          ..
                    ldd       0,X                 * 22C9 EC 84          l.
                    cmpd      >U0009,Y            * 22CB 10 A3 A9 00 09 .#)..
                    beq       L22F7               * 22D0 27 25          '%
                    ldd       $04,S               * 22D2 EC 64          ld
                    pshs      D                   * 22D4 34 06          4.
                    ldd       #160                * 22D6 CC 00 A0       L.
                    lbsr      L365D               * 22D9 17 13 81       ...
                    leax      >U2955,Y            * 22DC 30 A9 29 55    0))U
                    leax      D,X                 * 22E0 30 8B          0.
                    tfr       X,D                 * 22E2 1F 10          ..
                    pshs      D                   * 22E4 34 06          4.
                    ldd       $08,S               * 22E6 EC 68          lh
                    aslb                          * 22E8 58             X
                    rola                          * 22E9 49             I
                    addd      ,S++                * 22EA E3 E1          ca
                    tfr       D,X                 * 22EC 1F 01          ..
                    ldd       0,X                 * 22EE EC 84          l.
                    pshs      D                   * 22F0 34 06          4.
                    lbsr      L23A6               * 22F2 17 00 B1       ..1
                    leas      $02,S               * 22F5 32 62          2b
L22F7               ldd       >U000D,Y            * 22F7 EC A9 00 0D    l)..
                    addd      #1                  * 22FB C3 00 01       C..
                    std       >U000D,Y            * 22FE ED A9 00 0D    m)..
                    subd      #1                  * 2302 83 00 01       ...
                    leax      >U0225,Y            * 2305 30 A9 02 25    0).%
                    leax      D,X                 * 2309 30 8B          0.
                    pshs      X                   * 230B 34 10          4.
                    ldd       $06,S               * 230D EC 66          lf
                    pshs      D                   * 230F 34 06          4.
                    ldd       #80                 * 2311 CC 00 50       L.P
                    lbsr      L365D               * 2314 17 13 46       ..F
                    leax      >U2225,Y            * 2317 30 A9 22 25    0)"%
                    leax      D,X                 * 231B 30 8B          0.
                    ldd       $08,S               * 231D EC 68          lh
                    leax      D,X                 * 231F 30 8B          0.
                    ldb       0,X                 * 2321 E6 84          f.
                    stb       [,S++]              * 2323 E7 F1          gq
                    ldd       $02,S               * 2325 EC 62          lb
                    addd      #1                  * 2327 C3 00 01       C..
                    std       $02,S               * 232A ED 62          mb
                    cmpd      #79                 * 232C 10 83 00 4F    ...O
                    ble       L2348               * 2330 2F 16          /.
                    ldd       0,S                 * 2332 EC E4          ld
                    addd      #1                  * 2334 C3 00 01       C..
                    std       0,S                 * 2337 ED E4          md
                    cmpd      #22                 * 2339 10 83 00 16    ....
                    ble       L2344               * 233D 2F 05          /.
                    ldd       #22                 * 233F CC 00 16       L..
                    std       0,S                 * 2342 ED E4          md
L2344               clra                          * 2344 4F             O
                    clrb                          * 2345 5F             _
                    std       $02,S               * 2346 ED 62          mb
L2348               ldd       $04,S               * 2348 EC 64          ld
                    pshs      D                   * 234A 34 06          4.
                    ldd       #80                 * 234C CC 00 50       L.P
                    lbsr      L365D               * 234F 17 13 0B       ...
                    leax      >U2225,Y            * 2352 30 A9 22 25    0)"%
                    leax      D,X                 * 2356 30 8B          0.
                    ldd       $06,S               * 2358 EC 66          lf
                    leax      D,X                 * 235A 30 8B          0.
                    clra                          * 235C 4F             O
                    clrb                          * 235D 5F             _
                    stb       0,X                 * 235E E7 84          g.
                    ldd       $04,S               * 2360 EC 64          ld
                    pshs      D                   * 2362 34 06          4.
                    ldd       #160                * 2364 CC 00 A0       L.
                    lbsr      L365D               * 2367 17 12 F3       ..s
                    leax      >U2955,Y            * 236A 30 A9 29 55    0))U
                    leax      D,X                 * 236E 30 8B          0.
                    tfr       X,D                 * 2370 1F 10          ..
                    pshs      D                   * 2372 34 06          4.
                    ldd       $08,S               * 2374 EC 68          lh
                    aslb                          * 2376 58             X
                    rola                          * 2377 49             I
                    addd      ,S++                * 2378 E3 E1          ca
                    tfr       D,X                 * 237A 1F 01          ..
                    clra                          * 237C 4F             O
                    clrb                          * 237D 5F             _
                    std       0,X                 * 237E ED 84          m.
                    ldd       $06,S               * 2380 EC 66          lf
                    addd      #1                  * 2382 C3 00 01       C..
L2385               std       $06,S               * 2385 ED 66          mf
                    ldd       $06,S               * 2387 EC 66          lf
                    cmpd      #80                 * 2389 10 83 00 50    ...P
                    lblt      L2146               * 238D 10 2D FD B5    .-}5
                    ldd       $04,S               * 2391 EC 64          ld
                    addd      #1                  * 2393 C3 00 01       C..
L2396               std       $04,S               * 2396 ED 64          md
                    ldd       $04,S               * 2398 EC 64          ld
                    cmpd      #23                 * 239A 10 83 00 17    ....
                    lblt      L2141               * 239E 10 2D FD 9F    .-}.
                    leas      $08,S               * 23A2 32 68          2h
                    puls      PC,U                * 23A4 35 C0          5@

* -- method --
L23A6               pshs      U                   * 23A6 34 40          4@
                    ldd       #-70                * 23A8 CC FF BA       L.:
                    lbsr      _stkcheck           * 23AB 17 DD 61       .]a
                    ldd       >U000D,Y            * 23AE EC A9 00 0D    l)..
                    addd      #2                  * 23B2 C3 00 02       C..
                    cmpd      #8192               * 23B5 10 83 20 00    .. .
                    bge       L23EF               * 23B9 2C 34          ,4
                    ldd       >U000D,Y            * 23BB EC A9 00 0D    l)..
                    addd      #1                  * 23BF C3 00 01       C..
                    std       >U000D,Y            * 23C2 ED A9 00 0D    m)..
                    subd      #1                  * 23C6 83 00 01       ...
                    leax      >U0225,Y            * 23C9 30 A9 02 25    0).%
                    leax      D,X                 * 23CD 30 8B          0.
                    ldd       #27                 * 23CF CC 00 1B       L..
                    stb       0,X                 * 23D2 E7 84          g.
                    ldd       >U000D,Y            * 23D4 EC A9 00 0D    l)..
                    addd      #1                  * 23D8 C3 00 01       C..
                    std       >U000D,Y            * 23DB ED A9 00 0D    m)..
                    subd      #1                  * 23DF 83 00 01       ...
                    leax      >U0225,Y            * 23E2 30 A9 02 25    0).%
                    leax      D,X                 * 23E6 30 8B          0.
                    ldd       #91                 * 23E8 CC 00 5B       L.[
                    stb       0,X                 * 23EB E7 84          g.
                    bra       L23F9               * 23ED 20 0A           .
L23EF               ldd       #1                  * 23EF CC 00 01       L..
                    pshs      D                   * 23F2 34 06          4.
                    lbsr      L3AD8               * 23F4 17 16 E1       ..a
                    leas      $02,S               * 23F7 32 62          2b
L23F9               clra                          * 23F9 4F             O
                    clrb                          * 23FA 5F             _
                    pshs      D                   * 23FB 34 06          4.
                    lbsr      L249A               * 23FD 17 00 9A       ...
                    leas      $02,S               * 2400 32 62          2b
                    ldd       $04,S               * 2402 EC 64          ld
                    anda      #16                 * 2404 84 10          ..
                    clrb                          * 2406 5F             _
                    std       -$02,S              * 2407 ED 7E          m~
                    beq       L2415               * 2409 27 0A          '.
                    ldd       #1                  * 240B CC 00 01       L..
                    pshs      D                   * 240E 34 06          4.
                    lbsr      L249A               * 2410 17 00 87       ...
                    leas      $02,S               * 2413 32 62          2b
L2415               ldd       $04,S               * 2415 EC 64          ld
                    anda      #1                  * 2417 84 01          ..
                    clrb                          * 2419 5F             _
                    std       -$02,S              * 241A ED 7E          m~
                    beq       L2428               * 241C 27 0A          '.
                    ldd       #4                  * 241E CC 00 04       L..
                    pshs      D                   * 2421 34 06          4.
                    lbsr      L249A               * 2423 17 00 74       ..t
                    leas      $02,S               * 2426 32 62          2b
L2428               ldd       $04,S               * 2428 EC 64          ld
                    anda      #2                  * 242A 84 02          ..
                    clrb                          * 242C 5F             _
                    std       -$02,S              * 242D ED 7E          m~
                    beq       L243B               * 242F 27 0A          '.
                    ldd       #5                  * 2431 CC 00 05       L..
                    pshs      D                   * 2434 34 06          4.
                    lbsr      L249A               * 2436 17 00 61       ..a
                    leas      $02,S               * 2439 32 62          2b
L243B               ldd       $04,S               * 243B EC 64          ld
                    anda      #4                  * 243D 84 04          ..
                    clrb                          * 243F 5F             _
                    std       -$02,S              * 2440 ED 7E          m~
                    beq       L244E               * 2442 27 0A          '.
                    ldd       #7                  * 2444 CC 00 07       L..
                    pshs      D                   * 2447 34 06          4.
                    lbsr      L249A               * 2449 17 00 4E       ..N
                    leas      $02,S               * 244C 32 62          2b
L244E               ldd       $04,S               * 244E EC 64          ld
                    clra                          * 2450 4F             O
                    andb      #240                * 2451 C4 F0          Dp
                    beq       L246B               * 2453 27 16          '.
                    ldd       $04,S               * 2455 EC 64          ld
                    clra                          * 2457 4F             O
                    andb      #240                * 2458 C4 F0          Dp
                    lsra                          * 245A 44             D
                    rorb                          * 245B 56             V
                    lsra                          * 245C 44             D
                    rorb                          * 245D 56             V
                    lsra                          * 245E 44             D
                    rorb                          * 245F 56             V
                    lsra                          * 2460 44             D
                    rorb                          * 2461 56             V
                    addd      #30                 * 2462 C3 00 1E       C..
                    pshs      D                   * 2465 34 06          4.
                    bsr       L249A               * 2467 8D 31          .1
                    leas      $02,S               * 2469 32 62          2b
L246B               ldd       $04,S               * 246B EC 64          ld
                    clra                          * 246D 4F             O
                    andb      #15                 * 246E C4 0F          D.
                    beq       L2480               * 2470 27 0E          '.
                    ldd       $04,S               * 2472 EC 64          ld
                    clra                          * 2474 4F             O
                    andb      #15                 * 2475 C4 0F          D.
                    addd      #40                 * 2477 C3 00 28       C.(
                    pshs      D                   * 247A 34 06          4.
                    bsr       L249A               * 247C 8D 1C          ..
                    leas      $02,S               * 247E 32 62          2b
L2480               ldd       $04,S               * 2480 EC 64          ld
                    std       >U0009,Y            * 2482 ED A9 00 09    m)..
                    ldd       >U000D,Y            * 2486 EC A9 00 0D    l)..
                    addd      #-1                 * 248A C3 FF FF       C..
                    leax      >U0225,Y            * 248D 30 A9 02 25    0).%
                    leax      D,X                 * 2491 30 8B          0.
                    ldd       #109                * 2493 CC 00 6D       L.m
                    stb       0,X                 * 2496 E7 84          g.
                    puls      PC,U                * 2498 35 C0          5@

* -- method --
L249A               pshs      U                   * 249A 34 40          4@
                    ldd       #-72                * 249C CC FF B8       L.8
                    lbsr      _stkcheck           * 249F 17 DC 6D       .\m
                    ldd       >U000D,Y            * 24A2 EC A9 00 0D    l)..
                    addd      #3                  * 24A6 C3 00 03       C..
                    cmpd      #8192               * 24A9 10 83 20 00    .. .
                    lbge      L251E               * 24AD 10 2C 00 6D    .,.m
                    ldd       $04,S               * 24B1 EC 64          ld
                    cmpd      #10                 * 24B3 10 83 00 0A    ....
                    blt       L24DE               * 24B7 2D 25          -%
                    ldd       >U000D,Y            * 24B9 EC A9 00 0D    l)..
                    addd      #1                  * 24BD C3 00 01       C..
                    std       >U000D,Y            * 24C0 ED A9 00 0D    m)..
                    subd      #1                  * 24C4 83 00 01       ...
                    leax      >U0225,Y            * 24C7 30 A9 02 25    0).%
                    leax      D,X                 * 24CB 30 8B          0.
                    pshs      X                   * 24CD 34 10          4.
                    ldd       $06,S               * 24CF EC 66          lf
                    pshs      D                   * 24D1 34 06          4.
                    ldd       #10                 * 24D3 CC 00 0A       L..
                    lbsr      L3711               * 24D6 17 12 38       ..8
                    addd      #48                 * 24D9 C3 00 30       C.0
                    stb       [,S++]              * 24DC E7 F1          gq
L24DE               ldd       >U000D,Y            * 24DE EC A9 00 0D    l)..
                    addd      #1                  * 24E2 C3 00 01       C..
                    std       >U000D,Y            * 24E5 ED A9 00 0D    m)..
                    subd      #1                  * 24E9 83 00 01       ...
                    leax      >U0225,Y            * 24EC 30 A9 02 25    0).%
                    leax      D,X                 * 24F0 30 8B          0.
                    pshs      X                   * 24F2 34 10          4.
                    ldd       $06,S               * 24F4 EC 66          lf
                    pshs      D                   * 24F6 34 06          4.
                    ldd       #10                 * 24F8 CC 00 0A       L..
                    lbsr      L36BE               * 24FB 17 11 C0       ..@
                    addd      #48                 * 24FE C3 00 30       C.0
                    stb       [,S++]              * 2501 E7 F1          gq
                    ldd       >U000D,Y            * 2503 EC A9 00 0D    l)..
                    addd      #1                  * 2507 C3 00 01       C..
                    std       >U000D,Y            * 250A ED A9 00 0D    m)..
                    subd      #1                  * 250E 83 00 01       ...
                    leax      >U0225,Y            * 2511 30 A9 02 25    0).%
                    leax      D,X                 * 2515 30 8B          0.
                    ldd       #59                 * 2517 CC 00 3B       L.;
                    stb       0,X                 * 251A E7 84          g.
                    bra       L2528               * 251C 20 0A           .
L251E               ldd       #1                  * 251E CC 00 01       L..
                    pshs      D                   * 2521 34 06          4.
                    lbsr      L3AD8               * 2523 17 15 B2       ..2
                    leas      $02,S               * 2526 32 62          2b
L2528               puls      PC,U                * 2528 35 C0          5@

* -- method --
L252A               pshs      U                   * 252A 34 40          4@
                    ldd       #-106               * 252C CC FF 96       L..
                    lbsr      _stkcheck           * 252F 17 DB DD       .[]
                    leas      -$20,S              * 2532 32 E8 E0       2h`
                    leax      0,S                 * 2535 30 E4          0d
                    pshs      X                   * 2537 34 10          4.
                    clra                          * 2539 4F             O
                    clrb                          * 253A 5F             _
                    pshs      D                   * 253B 34 06          4.
                    clra                          * 253D 4F             O
                    clrb                          * 253E 5F             _
                    pshs      D                   * 253F 34 06          4.
                    lbsr      L37B9               * 2541 17 12 75       ..u
                    leas      $06,S               * 2544 32 66          2f
                    ldb       <$0025,S            * 2546 E6 E8 25       fh%
                    stb       $04,S               * 2549 E7 64          gd
                    leax      0,S                 * 254B 30 E4          0d
                    pshs      X                   * 254D 34 10          4.
                    clra                          * 254F 4F             O
                    clrb                          * 2550 5F             _
                    pshs      D                   * 2551 34 06          4.
                    clra                          * 2553 4F             O
                    clrb                          * 2554 5F             _
                    pshs      D                   * 2555 34 06          4.
                    lbsr      L37F4               * 2557 17 12 9A       ...
                    leas      $06,S               * 255A 32 66          2f
                    leas      <$0020,S            * 255C 32 E8 20       2h
                    puls      PC,U                * 255F 35 C0          5@

* -- method --
L2561               pshs      U                   * 2561 34 40          4@
                    ldd       #-85                * 2563 CC FF AB       L.+
                    lbsr      _stkcheck           * 2566 17 DB A6       .[&
                    leas      -$01,S              * 2569 32 7F          2.
                    ldd       #4                  * 256B CC 00 04       L..
                    pshs      D                   * 256E 34 06          4.
                    ldd       #4                  * 2570 CC 00 04       L..
                    pshs      D                   * 2573 34 06          4.
                    ldd       #6                  * 2575 CC 00 06       L..
                    pshs      D                   * 2578 34 06          4.
                    ldd       #40                 * 257A CC 00 28       L.(
                    pshs      D                   * 257D 34 06          4.
                    ldd       #3                  * 257F CC 00 03       L..
                    pshs      D                   * 2582 34 06          4.
                    ldd       #10                 * 2584 CC 00 0A       L..
                    pshs      D                   * 2587 34 06          4.
                    ldd       #1                  * 2589 CC 00 01       L..
                    pshs      D                   * 258C 34 06          4.
                    ldd       #1                  * 258E CC 00 01       L..
                    pshs      D                   * 2591 34 06          4.
                    lbsr      L3A52               * 2593 17 14 BC       ..<
                    leas      <$0010,S            * 2596 32 E8 10       2h.
                    ldd       #2                  * 2599 CC 00 02       L..
                    pshs      D                   * 259C 34 06          4.
                    clra                          * 259E 4F             O
                    clrb                          * 259F 5F             _
                    pshs      D                   * 25A0 34 06          4.
                    ldd       #4                  * 25A2 CC 00 04       L..
                    pshs      D                   * 25A5 34 06          4.
                    ldd       #38                 * 25A7 CC 00 26       L.&
                    pshs      D                   * 25AA 34 06          4.
                    ldd       #4                  * 25AC CC 00 04       L..
                    pshs      D                   * 25AF 34 06          4.
                    ldd       #11                 * 25B1 CC 00 0B       L..
                    pshs      D                   * 25B4 34 06          4.
                    clra                          * 25B6 4F             O
                    clrb                          * 25B7 5F             _
                    pshs      D                   * 25B8 34 06          4.
                    ldd       #1                  * 25BA CC 00 01       L..
                    pshs      D                   * 25BD 34 06          4.
                    lbsr      L3A52               * 25BF 17 14 90       ...
                    leas      <$0010,S            * 25C2 32 E8 10       2h.
                    ldd       #1                  * 25C5 CC 00 01       L..
                    pshs      D                   * 25C8 34 06          4.
                    lbsr      L3AEC               * 25CA 17 15 1F       ...
                    leas      $02,S               * 25CD 32 62          2b
                    ldd       $05,S               * 25CF EC 65          le
                    pshs      D                   * 25D1 34 06          4.
                    lbsr      L3545               * 25D3 17 0F 6F       ..o
                    std       0,S                 * 25D6 ED E4          md
                    ldd       #2                  * 25D8 CC 00 02       L..
                    lbsr      L3711               * 25DB 17 11 33       ..3
                    pshs      D                   * 25DE 34 06          4.
                    ldd       #19                 * 25E0 CC 00 13       L..
                    subd      ,S++                * 25E3 A3 E1          #a
                    pshs      D                   * 25E5 34 06          4.
                    leax      >Spaces,PC          * 25E7 30 8D 07 2D    0..-
                    pshs      X                   * 25EB 34 10          4.
                    ldd       #1                  * 25ED CC 00 01       L..
                    pshs      D                   * 25F0 34 06          4.
                    lbsr      write               * 25F2 17 12 E0       ..`
                    leas      $06,S               * 25F5 32 66          2f
                    ldd       $05,S               * 25F7 EC 65          le
                    pshs      D                   * 25F9 34 06          4.
                    leax      >String,PC          * 25FB 30 8D 07 2E    0...
                    pshs      X                   * 25FF 34 10          4.
                    lbsr      printf              * 2601 17 07 49       ..I
                    leas      $04,S               * 2604 32 64          2d
                    ldd       $07,S               * 2606 EC 67          lg
                    pshs      D                   * 2608 34 06          4.
                    leax      >ErrNum,PC          * 260A 30 8D 07 23    0..#
                    pshs      X                   * 260E 34 10          4.
                    lbsr      printf              * 2610 17 07 3A       ..:
                    leas      $04,S               * 2613 32 64          2d
                    ldd       #1                  * 2615 CC 00 01       L..
                    pshs      D                   * 2618 34 06          4.
                    leax      $02,S               * 261A 30 62          0b
                    pshs      X                   * 261C 34 10          4.
                    clra                          * 261E 4F             O
                    clrb                          * 261F 5F             _
                    pshs      D                   * 2620 34 06          4.
                    lbsr      read                * 2622 17 12 7F       ...
                    leas      $06,S               * 2625 32 66          2f
                    ldd       #1                  * 2627 CC 00 01       L..
                    pshs      D                   * 262A 34 06          4.
                    lbsr      L3A82               * 262C 17 14 53       ..S
                    leas      $02,S               * 262F 32 62          2b
                    ldd       #1                  * 2631 CC 00 01       L..
                    pshs      D                   * 2634 34 06          4.
                    lbsr      L3A82               * 2636 17 14 49       ..I
                    leas      $02,S               * 2639 32 62          2b
                    leas      $01,S               * 263B 32 61          2a
                    puls      PC,U                * 263D 35 C0          5@
                    fcc       "Black"             * 263F 42 6C 61 63 6B Black
                    fcb       $00                 * 2644 00             .
                    fcc       "Red"               * 2645 52 65 64       Red
                    fcb       $00                 * 2648 00             .
                    fcc       "Green"             * 2649 47 72 65 65 6E Green
                    fcb       $00                 * 264E 00             .
                    fcc       "Yellow"            * 264F 59 65 6C 6C 6F 77 Yellow
                    fcb       $00                 * 2655 00             .
                    fcc       "Blue"              * 2656 42 6C 75 65    Blue
                    fcb       $00                 * 265A 00             .
                    fcc       "Magenta"           * 265B 4D 61 67 65 6E 74 61 Magenta
                    fcb       $00                 * 2662 00             .
                    fcc       "Cyan"              * 2663 43 79 61 6E    Cyan
                    fcb       $00                 * 2667 00             .
                    fcc       "White"             * 2668 57 68 69 74 65 White
                    fcb       $00                 * 266D 00             .
savprmpt            fcb       $0D                 * 266E 0D             .
                    fcc       " Filename to save:" * 266F 20 46 69 6C 65 6E 61 6D 65 20 74 6F 20 73 61 76 65 3A  Filename to save:
                    fcb       $00                 * 2681 00             .
Title               fcc       "Ansi Graphic"      * 2682 41 6E 73 69 20 47 72 61 70 68 69 63 Ansi Graphic
                    fcb       $7F                 * 268E 7F             .
                    fcc       " Editor, Version 1.0      " * 268F 20 45 64 69 74 6F 72 2C 20 56 65 72 73 69 6F 6E 20 31 2E 30 20 20 20 20 20 20  Editor, Version 1.0
                    fcb       $0D                 * 26A9 0D             .
                    fcb       $00                 * 26AA 00             .
Copyright           fcc       "Copyright (c) 1989, By Keith Alphonso  " * 26AB 43 6F 70 79 72 69 67 68 74 20 28 63 29 20 31 39 38 39 2C 20 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 20 20 Copyright (c) 1989, By Keith Alphonso
                    fcb       $0D                 * 26D2 0D             .
                    fcb       $00                 * 26D3 00             .
License             fcc       "Licensed to Alpha Software Technologies" * 26D4 4C 69 63 65 6E 73 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licensed to Alpha Software Technologies
                    fcb       $0D                 * 26FB 0D             .
                    fcb       $00                 * 26FC 00             .
Rights              fcc       "All rights reserved                    " * 26FD 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 All rights reserved
                    fcb       $0D                 * 2724 0D             .
                    fcb       $00                 * 2725 00             .
CantOpen1           fcc       "Cannot open output file" * 2726 43 61 6E 6E 6F 74 20 6F 70 65 6E 20 6F 75 74 70 75 74 20 66 69 6C 65 Cannot open output file
                    fcb       $00                 * 273D 00             .
PutScrn             fcb       $0D                 * 273E 0D             .
                    fcc       "Put Screen into Buffer?" * 273F 50 75 74 20 53 63 72 65 65 6E 20 69 6E 74 6F 20 42 75 66 66 65 72 3F Put Screen into Buffer?
                    fcb       $00                 * 2756 00             .
ClrScrn             fcb       $0D                 * 2757 0D             .
                    fcc       "Start with clear screen?" * 2758 53 74 61 72 74 20 77 69 74 68 20 63 6C 65 61 72 20 73 63 72 65 65 6E 3F Start with clear screen?
                    fcb       $00                 * 2770 00             .
CantOpen2           fcc       "Cannot open file"  * 2771 43 61 6E 6E 6F 74 20 6F 70 65 6E 20 66 69 6C 65 Cannot open file
                    fcb       $00                 * 2781 00             .
ReadFile            fcb       $0D                 * 2782 0D             .
                    fcc       "Read file to [O]utput buffer or [S]creen buffer" * 2783 52 65 61 64 20 66 69 6C 65 20 74 6F 20 5B 4F 5D 75 74 70 75 74 20 62 75 66 66 65 72 20 6F 72 20 5B 53 5D 63 72 65 65 6E 20 62 75 66 66 65 72 Read file to [O]utput buffer or [
                    fcb       $00                 * 27B2 00             .
AddLf               fcb       $0D                 * 27B3 0D             .
                    fcc       "Add line feeds to carriage returns?" * 27B4 41 64 64 20 6C 69 6E 65 20 66 65 65 64 73 20 74 6F 20 63 61 72 72 69 61 67 65 20 72 65 74 75 72 6E 73 3F Add line feeds to carriage returns?
                    fcb       $00                 * 27D7 00             .
Status              fcc       "X=%2d Y=%2d   Status:" * 27D8 58 3D 25 32 64 20 59 3D 25 32 64 20 20 20 53 74 61 74 75 73 3A X=%2d Y=%2d   Status:
                    fcb       $00                 * 27ED 00             .
Editing             fcc       "EDITING  "         * 27EE 45 44 49 54 49 4E 47 20 20 EDITING
                    fcb       $00                 * 27F7 00             .
Recording           fcc       "RECORDING"         * 27F8 52 45 43 4F 52 44 49 4E 47 RECORDING
                    fcb       $00                 * 2801 00             .
CharDump            fcc       "  Char:%1c"        * 2802 20 20 43 68 61 72 3A 25 31 63   Char:%1c
                    fcb       $00                 * 280C 00             .
Char                fcc       "  Char: "          * 280D 20 20 43 68 61 72 3A 20   Char:
                    fcb       $00                 * 2815 00             .
Attrs               fcc       "  Attrs:"          * 2816 20 20 41 74 74 72 73 3A   Attrs:
                    fcb       $00                 * 281E 00             .
L281F               fcc       "U"                 * 281F 55             U
                    fcb       $00                 * 2820 00             .
L2821               fcc       " "                 * 2821 20
                    fcb       $00                 * 2822 00             .
L2823               fcc       "L"                 * 2823 4C             L
                    fcb       $00                 * 2824 00             .
L2825               fcc       " "                 * 2825 20
                    fcb       $00                 * 2826 00             .
L2827               fcc       "V"                 * 2827 56             V
                    fcb       $00                 * 2828 00             .
L2829               fcc       " "                 * 2829 20
                    fcb       $00                 * 282A 00             .
L282B               fcc       "I"                 * 282B 49             I
                    fcb       $00                 * 282C 00             .
L282D               fcc       " "                 * 282D 20
                    fcb       $00                 * 282E 00             .
L282F               fcc       "O"                 * 282F 4F             O
                    fcb       $00                 * 2830 00             .
L2831               fcc       " "                 * 2831 20
                    fcb       $00                 * 2832 00             .
ColorsOn            fcc       " Colors:%7s on %7s" * 2833 20 43 6F 6C 6F 72 73 3A 25 37 73 20 6F 6E 20 25 37 73  Colors:%7s on %7s
                    fcb       $00                 * 2845 00             .
ColorsBW            fcc       " Colors:White   on Black  " * 2846 20 43 6F 6C 6F 72 73 3A 57 68 69 74 65 20 20 20 6F 6E 20 42 6C 61 63 6B 20 20  Colors:White   on Black
                    fcb       $00                 * 2860 00             .
Help                fcc       "           Ansi-Editor  Help" * 2861 20 20 20 20 20 20 20 20 20 20 20 41 6E 73 69 2D 45 64 69 74 6F 72 20 20 48 65 6C 70            Ansi-Editor  Help
                    fcb       $0D                 * 287D 0D             .
                    fcb       $00                 * 287E 00             .
Line                fcc       "--------------------------------------" * 287F 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D --------------------------------------
                    fcb       $0D                 * 28A5 0D             .
                    fcb       $00                 * 28A6 00             .
AltG                fcc       " [ALT][G] - Set graphics" * 28A7 20 5B 41 4C 54 5D 5B 47 5D 20 2D 20 53 65 74 20 67 72 61 70 68 69 63 73  [ALT][G] - Set graphics
                    fcb       $0D                 * 28BF 0D             .
                    fcb       $00                 * 28C0 00             .
AltR                fcc       " [ALT][R] - Record mode" * 28C1 20 5B 41 4C 54 5D 5B 52 5D 20 2D 20 52 65 63 6F 72 64 20 6D 6F 64 65  [ALT][R] - Record mode
                    fcb       $0D                 * 28D8 0D             .
                    fcb       $00                 * 28D9 00             .
AltE                fcc       " [ALT][E] - Edit mode" * 28DA 20 5B 41 4C 54 5D 5B 45 5D 20 2D 20 45 64 69 74 20 6D 6F 64 65  [ALT][E] - Edit mode
                    fcb       $0D                 * 28EF 0D             .
                    fcb       $00                 * 28F0 00             .
AltC                fcc       " [ALT][C] - Clear screen" * 28F1 20 5B 41 4C 54 5D 5B 43 5D 20 2D 20 43 6C 65 61 72 20 73 63 72 65 65 6E  [ALT][C] - Clear screen
                    fcb       $0D                 * 2909 0D             .
                    fcb       $00                 * 290A 00             .
AltN                fcc       " [ALT][N] - Clear to end of line" * 290B 20 5B 41 4C 54 5D 5B 4E 5D 20 2D 20 43 6C 65 61 72 20 74 6F 20 65 6E 64 20 6F 66 20 6C 69 6E 65  [ALT][N] - Clear to end of line
                    fcb       $0D                 * 292B 0D             .
                    fcb       $00                 * 292C 00             .
AltS                fcc       " [ALT][S] - Save cursor position" * 292D 20 5B 41 4C 54 5D 5B 53 5D 20 2D 20 53 61 76 65 20 63 75 72 73 6F 72 20 70 6F 73 69 74 69 6F 6E  [ALT][S] - Save cursor position
                    fcb       $0D                 * 294D 0D             .
                    fcb       $00                 * 294E 00             .
AltA                fcc       " [ALT][A] - Restore cursor position" * 294F 20 5B 41 4C 54 5D 5B 41 5D 20 2D 20 52 65 73 74 6F 72 65 20 63 75 72 73 6F 72 20 70 6F 73 69 74 69 6F 6E  [ALT][A] - Restore cursor position
                    fcb       $0D                 * 2972 0D             .
                    fcb       $00                 * 2973 00             .
AltP                fcc       " [ALT][P] - Put screen into buffer" * 2974 20 5B 41 4C 54 5D 5B 50 5D 20 2D 20 50 75 74 20 73 63 72 65 65 6E 20 69 6E 74 6F 20 62 75 66 66 65 72  [ALT][P] - Put screen into buffer
                    fcb       $0D                 * 2996 0D             .
                    fcb       $00                 * 2997 00             .
AltL                fcc       " [ALT][L] - Load from file" * 2998 20 5B 41 4C 54 5D 5B 4C 5D 20 2D 20 4C 6F 61 64 20 66 72 6F 6D 20 66 69 6C 65  [ALT][L] - Load from file
                    fcb       $0D                 * 29B2 0D             .
                    fcb       $00                 * 29B3 00             .
AltK                fcc       " [ALT][K] - Save to file" * 29B4 20 5B 41 4C 54 5D 5B 4B 5D 20 2D 20 53 61 76 65 20 74 6F 20 66 69 6C 65  [ALT][K] - Save to file
                    fcb       $0D                 * 29CC 0D             .
                    fcb       $00                 * 29CD 00             .
AltZ                fcc       " [ALT][Z] - Zap buffers" * 29CE 20 5B 41 4C 54 5D 5B 5A 5D 20 2D 20 5A 61 70 20 62 75 66 66 65 72 73  [ALT][Z] - Zap buffers
                    fcb       $0D                 * 29E5 0D             .
                    fcb       $00                 * 29E6 00             .
AltX                fcc       " [ALT][X] - Save & Exit" * 29E7 20 5B 41 4C 54 5D 5B 58 5D 20 2D 20 53 61 76 65 20 26 20 45 78 69 74  [ALT][X] - Save & Exit
                    fcb       $0D                 * 29FE 0D             .
                    fcb       $00                 * 29FF 00             .
AltQ                fcc       " [ALT][Q] - Quit without save" * 2A00 20 5B 41 4C 54 5D 5B 51 5D 20 2D 20 51 75 69 74 20 77 69 74 68 6F 75 74 20 73 61 76 65  [ALT][Q] - Quit without save
                    fcb       $0D                 * 2A1D 0D             .
                    fcb       $00                 * 2A1E 00             .
Sure                fcb       $0D                 * 2A1F 0D             .
                    fcc       "  Are you sure?"   * 2A20 20 20 41 72 65 20 79 6F 75 20 73 75 72 65 3F   Are you sure?
                    fcb       $00                 * 2A2F 00             .
Title2              fcc       "ANSI Graphics Editor, Version 1.0      " * 2A30 41 4E 53 49 20 47 72 61 70 68 69 63 73 20 45 64 69 74 6F 72 2C 20 56 65 72 73 69 6F 6E 20 31 2E 30 20 20 20 20 20 20 ANSI Graphics Editor, Version 1.0
                    fcb       $0D                 * 2A57 0D             .
                    fcb       $00                 * 2A58 00             .
CpyRite2            fcc       "Copyright (c) 1989, By Keith Alphonso  " * 2A59 43 6F 70 79 72 69 67 68 74 20 28 63 29 20 31 39 38 39 2C 20 42 79 20 4B 65 69 74 68 20 41 6C 70 68 6F 6E 73 6F 20 20 Copyright (c) 1989, By Keith Alphonso
                    fcb       $0D                 * 2A80 0D             .
                    fcb       $00                 * 2A81 00             .
License2            fcc       "Licensed to Alpha Software Technologies" * 2A82 4C 69 63 65 6E 73 65 64 20 74 6F 20 41 6C 70 68 61 20 53 6F 66 74 77 61 72 65 20 54 65 63 68 6E 6F 6C 6F 67 69 65 73 Licensed to Alpha Software Technologies
                    fcb       $0D                 * 2AA9 0D             .
                    fcb       $00                 * 2AAA 00             .
Rights2             fcc       "All rights reserved                    " * 2AAB 41 6C 6C 20 72 69 67 68 74 73 20 72 65 73 65 72 76 65 64 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 All rights reserved
                    fcb       $0D                 * 2AD2 0D             .
                    fcb       $00                 * 2AD3 00             .
LoadPrompt          fcb       $0D                 * 2AD4 0D             .
                    fcc       " Filename to load:" * 2AD5 20 46 69 6C 65 6E 61 6D 65 20 74 6F 20 6C 6F 61 64 3A  Filename to load:
                    fcb       $00                 * 2AE7 00             .
SavePrompt          fcb       $0D                 * 2AE8 0D             .
                    fcc       " Filename to save:" * 2AE9 20 46 69 6C 65 6E 61 6D 65 20 74 6F 20 73 61 76 65 3A  Filename to save:
                    fcb       $00                 * 2AFB 00             .
PosSaved            fcb       $0D                 * 2AFC 0D             .
                    fcc       "Position Saved!!"  * 2AFD 50 6F 73 69 74 69 6F 6E 20 53 61 76 65 64 21 21 Position Saved!!
                    fcb       $0D                 * 2B0D 0D             .
                    fcb       $00                 * 2B0E 00             .
PosRestrd           fcb       $0D                 * 2B0F 0D             .
                    fcc       "Position Restored" * 2B10 50 6F 73 69 74 69 6F 6E 20 52 65 73 74 6F 72 65 64 Position Restored
                    fcb       $0D                 * 2B21 0D             .
                    fcb       $00                 * 2B22 00             .
MovBuff             fcb       $0D                 * 2B23 0D             .
                    fcc       " Moving screen buffer..." * 2B24 20 4D 6F 76 69 6E 67 20 73 63 72 65 65 6E 20 62 75 66 66 65 72 2E 2E 2E  Moving screen buffer...
                    fcb       $0D                 * 2B3C 0D             .
                    fcb       $00                 * 2B3D 00             .
Zap                 fcb       $0D                 * 2B3E 0D             .
                    fcc       "Zap:   S> Screen Buffer" * 2B3F 5A 61 70 3A 20 20 20 53 3E 20 53 63 72 65 65 6E 20 42 75 66 66 65 72 Zap:   S> Screen Buffer
                    fcb       $0D                 * 2B56 0D             .
                    fcb       $00                 * 2B57 00             .
RecBuff             fcc       "       R> Record Buffer" * 2B58 20 20 20 20 20 20 20 52 3E 20 52 65 63 6F 72 64 20 42 75 66 66 65 72        R> Record Buffer
                    fcb       $0D                 * 2B6F 0D             .
                    fcb       $00                 * 2B70 00             .
BothBuffs           fcc       "       B> Both   buffers" * 2B71 20 20 20 20 20 20 20 42 3E 20 42 6F 74 68 20 20 20 62 75 66 66 65 72 73        B> Both   buffers
                    fcb       $0D                 * 2B89 0D             .
                    fcb       $00                 * 2B8A 00             .
ScrnChar            fcc       "       D> Screen Character" * 2B8B 20 20 20 20 20 20 20 44 3E 20 53 63 72 65 65 6E 20 43 68 61 72 61 63 74 65 72        D> Screen Character
                    fcb       $0D                 * 2BA5 0D             .
                    fcb       $00                 * 2BA6 00             .
RecChar             fcc       "       T> Record Character" * 2BA7 20 20 20 20 20 20 20 54 3E 20 52 65 63 6F 72 64 20 43 68 61 72 61 63 74 65 72        T> Record Character
                    fcb       $0D                 * 2BC1 0D             .
                    fcb       $00                 * 2BC2 00             .
Choose              fcc       "Your Choice:"      * 2BC3 59 6F 75 72 20 43 68 6F 69 63 65 3A Your Choice:
                    fcb       $00                 * 2BCF 00             .
Sure2               fcb       $0C                 * 2BD0 0C             .
                    fcb       $0D                 * 2BD1 0D             .
                    fcb       $0D                 * 2BD2 0D             .
                    fcc       "     Are you sure?" * 2BD3 20 20 20 20 20 41 72 65 20 79 6F 75 20 73 75 72 65 3F      Are you sure?
                    fcb       $00                 * 2BE5 00             .
L2BE6               fcc       " "                 * 2BE6 20
                    fcb       $00                 * 2BE7 00             .
L2BE8               fcc       " "                 * 2BE8 20
                    fcb       $00                 * 2BE9 00             .
SetGraphs           fcc       "             Set  Graphics" * 2BEA 20 20 20 20 20 20 20 20 20 20 20 20 20 53 65 74 20 20 47 72 61 70 68 69 63 73              Set  Graphics
                    fcb       $0D                 * 2C04 0D             .
                    fcb       $00                 * 2C05 00             .
Line2               fcc       "           -----------------" * 2C06 20 20 20 20 20 20 20 20 20 20 20 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D            -----------------
                    fcb       $0D                 * 2C22 0D             .
                    fcb       $0D                 * 2C23 0D             .
                    fcb       $00                 * 2C24 00             .
RestGraph           fcc       "[R] - Reset Graphics (white on black)" * 2C25 5B 52 5D 20 2D 20 52 65 73 65 74 20 47 72 61 70 68 69 63 73 20 28 77 68 69 74 65 20 6F 6E 20 62 6C 61 63 6B 29 [R] - Reset Graphics (white on black)
                    fcb       $0D                 * 2C4A 0D             .
                    fcb       $00                 * 2C4B 00             .
BoldOn              fcc       "[O] - Bold on"     * 2C4C 5B 4F 5D 20 2D 20 42 6F 6C 64 20 6F 6E [O] - Bold on
                    fcb       $0D                 * 2C59 0D             .
                    fcb       $00                 * 2C5A 00             .
UndrOn              fcc       "[U] - Underscore on" * 2C5B 5B 55 5D 20 2D 20 55 6E 64 65 72 73 63 6F 72 65 20 6F 6E [U] - Underscore on
                    fcb       $0D                 * 2C6E 0D             .
                    fcb       $00                 * 2C6F 00             .
BlnkOn              fcc       "[L] - Blink on"    * 2C70 5B 4C 5D 20 2D 20 42 6C 69 6E 6B 20 6F 6E [L] - Blink on
                    fcb       $0D                 * 2C7E 0D             .
                    fcb       $00                 * 2C7F 00             .
RevVidOn            fcc       "[V] - Reverse Video on" * 2C80 5B 56 5D 20 2D 20 52 65 76 65 72 73 65 20 56 69 64 65 6F 20 6F 6E [V] - Reverse Video on
                    fcb       $0D                 * 2C96 0D             .
                    fcb       $00                 * 2C97 00             .
InvisOn             fcc       "[I] - Invisible on" * 2C98 5B 49 5D 20 2D 20 49 6E 76 69 73 69 62 6C 65 20 6F 6E [I] - Invisible on
                    fcb       $0D                 * 2CAA 0D             .
                    fcb       $00                 * 2CAB 00             .
SetForClr           fcc       "[F] - Set foreground color" * 2CAC 5B 46 5D 20 2D 20 53 65 74 20 66 6F 72 65 67 72 6F 75 6E 64 20 63 6F 6C 6F 72 [F] - Set foreground color
                    fcb       $0D                 * 2CC6 0D             .
                    fcb       $00                 * 2CC7 00             .
SetBckClr           fcc       "[B] - Set background color" * 2CC8 5B 42 5D 20 2D 20 53 65 74 20 62 61 63 6B 67 72 6F 75 6E 64 20 63 6F 6C 6F 72 [B] - Set background color
                    fcb       $0D                 * 2CE2 0D             .
                    fcb       $00                 * 2CE3 00             .
Done                fcc       "[D] - Done"        * 2CE4 5B 44 5D 20 2D 20 44 6F 6E 65 [D] - Done
                    fcb       $0D                 * 2CEE 0D             .
                    fcb       $00                 * 2CEF 00             .
SelChoice           fcb       $0D                 * 2CF0 0D             .
                    fcc       "Select your choice:" * 2CF1 53 65 6C 65 63 74 20 79 6F 75 72 20 63 68 6F 69 63 65 3A Select your choice:
                    fcb       $00                 * 2D04 00             .
NumString           fcc       "%1d: %s"           * 2D05 25 31 64 3A 20 25 73 %1d: %s
                    fcb       $0D                 * 2D0C 0D             .
                    fcb       $00                 * 2D0D 00             .
ClrNum              fcb       $0D                 * 2D0E 0D             .
                    fcc       "Color #:"          * 2D0F 43 6F 6C 6F 72 20 23 3A Color #:
                    fcb       $00                 * 2D17 00             .
Spaces              fcc       "                    " * 2D18 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
                    fcb       $00                 * 2D2C 00             .
String              fcc       "%s"                * 2D2D 25 73          %s
                    fcb       $0D                 * 2D2F 0D             .
                    fcb       $00                 * 2D30 00             .
ErrNum              fcb       $0D                 * 2D31 0D             .
                    fcc       "               ERROR %03d" * 2D32 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 45 52 52 4F 52 20 25 30 33 64                ERROR %03d
                    fcb       $0D                 * 2D4B 0D             .
                    fcb       $00                 * 2D4C 00             .
printf              pshs      U                   * 2D4D 34 40          4@
                    leax      >U0049,Y            * 2D4F 30 A9 00 49    0).I
                    stx       >U37B5,Y            * 2D53 AF A9 37 B5    /)75
                    leax      $06,S               * 2D57 30 66          0f
                    pshs      X                   * 2D59 34 10          4.
                    ldd       $06,S               * 2D5B EC 66          lf
                    bra       L2D6D               * 2D5D 20 0E           .
                    pshs      U                   * 2D5F 34 40          4@
                    ldd       $04,S               * 2D61 EC 64          ld
                    std       >U37B5,Y            * 2D63 ED A9 37 B5    m)75
                    leax      $08,S               * 2D67 30 68          0h
                    pshs      X                   * 2D69 34 10          4.
                    ldd       $08,S               * 2D6B EC 68          lh
L2D6D               pshs      D                   * 2D6D 34 06          4.
                    leax      >L3225,PC           * 2D6F 30 8D 04 B2    0..2
                    pshs      X                   * 2D73 34 10          4.
                    bsr       L2D9F               * 2D75 8D 28          .(
                    leas      $06,S               * 2D77 32 66          2f
                    puls      PC,U                * 2D79 35 C0          5@
                    pshs      U                   * 2D7B 34 40          4@
                    ldd       $04,S               * 2D7D EC 64          ld
                    std       >U37B5,Y            * 2D7F ED A9 37 B5    m)75
                    leax      $08,S               * 2D83 30 68          0h
                    pshs      X                   * 2D85 34 10          4.
                    ldd       $08,S               * 2D87 EC 68          lh
                    pshs      D                   * 2D89 34 06          4.
                    leax      >L3238,PC           * 2D8B 30 8D 04 A9    0..)
                    pshs      X                   * 2D8F 34 10          4.
                    bsr       L2D9F               * 2D91 8D 0C          ..
                    leas      $06,S               * 2D93 32 66          2f
                    clra                          * 2D95 4F             O
                    clrb                          * 2D96 5F             _
                    stb       [>$37B5,Y]          * 2D97 E7 B9 37 B5    g975
                    ldd       $04,S               * 2D9B EC 64          ld
                    puls      PC,U                * 2D9D 35 C0          5@
L2D9F               pshs      U                   * 2D9F 34 40          4@
                    ldu       $06,S               * 2DA1 EE 66          nf
                    leas      -$0B,S              * 2DA3 32 75          2u
                    bra       L2DB7               * 2DA5 20 10           .
L2DA7               ldb       $08,S               * 2DA7 E6 68          fh
                    lbeq      L2FE8               * 2DA9 10 27 02 3B    .'.;
                    ldb       $08,S               * 2DAD E6 68          fh
                    sex                           * 2DAF 1D             .
                    pshs      D                   * 2DB0 34 06          4.
                    jsr       [<$11,S]            * 2DB2 AD F8 11       -x.
                    leas      $02,S               * 2DB5 32 62          2b
L2DB7               ldb       ,U+                 * 2DB7 E6 C0          f@
                    stb       $08,S               * 2DB9 E7 68          gh
                    cmpb      #37                 * 2DBB C1 25          A%
                    bne       L2DA7               * 2DBD 26 E8          &h
                    ldb       ,U+                 * 2DBF E6 C0          f@
                    stb       $08,S               * 2DC1 E7 68          gh
                    clra                          * 2DC3 4F             O
                    clrb                          * 2DC4 5F             _
                    std       $02,S               * 2DC5 ED 62          mb
                    std       $06,S               * 2DC7 ED 66          mf
                    ldb       $08,S               * 2DC9 E6 68          fh
                    cmpb      #45                 * 2DCB C1 2D          A-
                    bne       L2DDC               * 2DCD 26 0D          &.
                    ldd       #1                  * 2DCF CC 00 01       L..
                    std       >U37CB,Y            * 2DD2 ED A9 37 CB    m)7K
                    ldb       ,U+                 * 2DD6 E6 C0          f@
                    stb       $08,S               * 2DD8 E7 68          gh
                    bra       L2DE2               * 2DDA 20 06           .
L2DDC               clra                          * 2DDC 4F             O
                    clrb                          * 2DDD 5F             _
                    std       >U37CB,Y            * 2DDE ED A9 37 CB    m)7K
L2DE2               ldb       $08,S               * 2DE2 E6 68          fh
                    cmpb      #48                 * 2DE4 C1 30          A0
                    bne       L2DED               * 2DE6 26 05          &.
                    ldd       #48                 * 2DE8 CC 00 30       L.0
                    bra       L2DF0               * 2DEB 20 03           .
L2DED               ldd       #32                 * 2DED CC 00 20       L.
L2DF0               std       >U37CD,Y            * 2DF0 ED A9 37 CD    m)7M
                    bra       L2E10               * 2DF4 20 1A           .
L2DF6               ldd       $06,S               * 2DF6 EC 66          lf
                    pshs      D                   * 2DF8 34 06          4.
                    ldd       #10                 * 2DFA CC 00 0A       L..
                    lbsr      L365D               * 2DFD 17 08 5D       ..]
                    pshs      D                   * 2E00 34 06          4.
                    ldb       $0A,S               * 2E02 E6 6A          fj
                    sex                           * 2E04 1D             .
                    addd      #-48                * 2E05 C3 FF D0       C.P
                    addd      ,S++                * 2E08 E3 E1          ca
                    std       $06,S               * 2E0A ED 66          mf
                    ldb       ,U+                 * 2E0C E6 C0          f@
                    stb       $08,S               * 2E0E E7 68          gh
L2E10               ldb       $08,S               * 2E10 E6 68          fh
                    sex                           * 2E12 1D             .
                    leax      >U010D,Y            * 2E13 30 A9 01 0D    0)..
                    leax      D,X                 * 2E17 30 8B          0.
                    ldb       0,X                 * 2E19 E6 84          f.
                    clra                          * 2E1B 4F             O
                    andb      #8                  * 2E1C C4 08          D.
                    bne       L2DF6               * 2E1E 26 D6          &V
                    ldb       $08,S               * 2E20 E6 68          fh
                    cmpb      #46                 * 2E22 C1 2E          A.
                    bne       L2E59               * 2E24 26 33          &3
                    ldd       #1                  * 2E26 CC 00 01       L..
                    std       $04,S               * 2E29 ED 64          md
                    bra       L2E43               * 2E2B 20 16           .
L2E2D               ldd       $02,S               * 2E2D EC 62          lb
                    pshs      D                   * 2E2F 34 06          4.
                    ldd       #10                 * 2E31 CC 00 0A       L..
                    lbsr      L365D               * 2E34 17 08 26       ..&
                    pshs      D                   * 2E37 34 06          4.
                    ldb       $0A,S               * 2E39 E6 6A          fj
                    sex                           * 2E3B 1D             .
                    addd      #-48                * 2E3C C3 FF D0       C.P
                    addd      ,S++                * 2E3F E3 E1          ca
                    std       $02,S               * 2E41 ED 62          mb
L2E43               ldb       ,U+                 * 2E43 E6 C0          f@
                    stb       $08,S               * 2E45 E7 68          gh
                    ldb       $08,S               * 2E47 E6 68          fh
                    sex                           * 2E49 1D             .
                    leax      >U010D,Y            * 2E4A 30 A9 01 0D    0)..
                    leax      D,X                 * 2E4E 30 8B          0.
                    ldb       0,X                 * 2E50 E6 84          f.
                    clra                          * 2E52 4F             O
                    andb      #8                  * 2E53 C4 08          D.
                    bne       L2E2D               * 2E55 26 D6          &V
                    bra       L2E5D               * 2E57 20 04           .
L2E59               clra                          * 2E59 4F             O
                    clrb                          * 2E5A 5F             _
                    std       $04,S               * 2E5B ED 64          md
L2E5D               ldb       $08,S               * 2E5D E6 68          fh
                    sex                           * 2E5F 1D             .
                    tfr       D,X                 * 2E60 1F 01          ..
                    lbra      L2F8B               * 2E62 16 01 26       ..&
L2E65               ldd       $06,S               * 2E65 EC 66          lf
                    pshs      D                   * 2E67 34 06          4.
                    ldx       <$0015,S            * 2E69 AE E8 15       .h.
                    leax      $02,X               * 2E6C 30 02          0.
                    stx       <$0015,S            * 2E6E AF E8 15       /h.
                    ldd       -$02,X              * 2E71 EC 1E          l.
                    pshs      D                   * 2E73 34 06          4.
                    lbsr      L2FEC               * 2E75 17 01 74       ..t
                    bra       L2E8D               * 2E78 20 13           .
L2E7A               ldd       $06,S               * 2E7A EC 66          lf
                    pshs      D                   * 2E7C 34 06          4.
                    ldx       <$0015,S            * 2E7E AE E8 15       .h.
                    leax      $02,X               * 2E81 30 02          0.
                    stx       <$0015,S            * 2E83 AF E8 15       /h.
                    ldd       -$02,X              * 2E86 EC 1E          l.
                    pshs      D                   * 2E88 34 06          4.
                    lbsr      L30A9               * 2E8A 17 02 1C       ...
L2E8D               std       0,S                 * 2E8D ED E4          md
                    lbra      L2F71               * 2E8F 16 00 DF       .._
L2E92               ldd       $06,S               * 2E92 EC 66          lf
                    pshs      D                   * 2E94 34 06          4.
                    ldb       $0A,S               * 2E96 E6 6A          fj
                    sex                           * 2E98 1D             .
                    leax      >U010D,Y            * 2E99 30 A9 01 0D    0)..
                    leax      D,X                 * 2E9D 30 8B          0.
                    ldb       0,X                 * 2E9F E6 84          f.
                    clra                          * 2EA1 4F             O
                    andb      #2                  * 2EA2 C4 02          D.
                    pshs      D                   * 2EA4 34 06          4.
                    ldx       <$0017,S            * 2EA6 AE E8 17       .h.
                    leax      $02,X               * 2EA9 30 02          0.
                    stx       <$0017,S            * 2EAB AF E8 17       /h.
                    ldd       -$02,X              * 2EAE EC 1E          l.
                    pshs      D                   * 2EB0 34 06          4.
                    lbsr      L30F1               * 2EB2 17 02 3C       ..<
                    lbra      L2F6D               * 2EB5 16 00 B5       ..5
L2EB8               ldd       $06,S               * 2EB8 EC 66          lf
                    pshs      D                   * 2EBA 34 06          4.
                    ldx       <$0015,S            * 2EBC AE E8 15       .h.
                    leax      $02,X               * 2EBF 30 02          0.
                    stx       <$0015,S            * 2EC1 AF E8 15       /h.
                    ldd       -$02,X              * 2EC4 EC 1E          l.
                    pshs      D                   * 2EC6 34 06          4.
                    leax      >U37B7,Y            * 2EC8 30 A9 37 B7    0)77
                    pshs      X                   * 2ECC 34 10          4.
                    lbsr      L3030               * 2ECE 17 01 5F       .._
                    lbra      L2F6D               * 2ED1 16 00 99       ...
L2ED4               ldd       $04,S               * 2ED4 EC 64          ld
                    bne       L2EDD               * 2ED6 26 05          &.
                    ldd       #6                  * 2ED8 CC 00 06       L..
                    std       $02,S               * 2EDB ED 62          mb
L2EDD               ldd       $06,S               * 2EDD EC 66          lf
                    pshs      D                   * 2EDF 34 06          4.
                    leax      <$0015,S            * 2EE1 30 E8 15       0h.
                    pshs      X                   * 2EE4 34 10          4.
                    ldd       $06,S               * 2EE6 EC 66          lf
                    pshs      D                   * 2EE8 34 06          4.
                    ldb       $0E,S               * 2EEA E6 6E          fn
                    sex                           * 2EEC 1D             .
                    pshs      D                   * 2EED 34 06          4.
                    lbsr      L353A               * 2EEF 17 06 48       ..H
                    leas      $06,S               * 2EF2 32 66          2f
                    lbra      L2F6F               * 2EF4 16 00 78       ..x
L2EF7               ldx       <$0013,S            * 2EF7 AE E8 13       .h.
                    leax      $02,X               * 2EFA 30 02          0.
                    stx       <$0013,S            * 2EFC AF E8 13       /h.
                    ldd       -$02,X              * 2EFF EC 1E          l.
                    lbra      L2F81               * 2F01 16 00 7D       ..}
L2F04               ldx       <$0013,S            * 2F04 AE E8 13       .h.
                    leax      $02,X               * 2F07 30 02          0.
                    stx       <$0013,S            * 2F09 AF E8 13       /h.
                    ldd       -$02,X              * 2F0C EC 1E          l.
                    std       $09,S               * 2F0E ED 69          mi
                    ldd       $04,S               * 2F10 EC 64          ld
                    beq       L2F4C               * 2F12 27 38          '8
                    ldd       $09,S               * 2F14 EC 69          li
                    std       $04,S               * 2F16 ED 64          md
                    bra       L2F26               * 2F18 20 0C           .
L2F1A               ldb       [<$09,S]            * 2F1A E6 F8 09       fx.
                    beq       L2F32               * 2F1D 27 13          '.
                    ldd       $09,S               * 2F1F EC 69          li
                    addd      #1                  * 2F21 C3 00 01       C..
                    std       $09,S               * 2F24 ED 69          mi
L2F26               ldd       $02,S               * 2F26 EC 62          lb
                    addd      #-1                 * 2F28 C3 FF FF       C..
                    std       $02,S               * 2F2B ED 62          mb
                    subd      #-1                 * 2F2D 83 FF FF       ...
                    bne       L2F1A               * 2F30 26 E8          &h
L2F32               ldd       $06,S               * 2F32 EC 66          lf
                    pshs      D                   * 2F34 34 06          4.
                    ldd       $0B,S               * 2F36 EC 6B          lk
                    subd      $06,S               * 2F38 A3 66          #f
                    pshs      D                   * 2F3A 34 06          4.
                    ldd       $08,S               * 2F3C EC 68          lh
                    pshs      D                   * 2F3E 34 06          4.
                    ldd       <$0015,S            * 2F40 EC E8 15       lh.
                    pshs      D                   * 2F43 34 06          4.
                    lbsr      L315C               * 2F45 17 02 14       ...
                    leas      $08,S               * 2F48 32 68          2h
                    bra       L2F7B               * 2F4A 20 2F           /
L2F4C               ldd       $06,S               * 2F4C EC 66          lf
                    pshs      D                   * 2F4E 34 06          4.
                    ldd       $0B,S               * 2F50 EC 6B          lk
                    bra       L2F6F               * 2F52 20 1B           .
L2F54               ldb       ,U+                 * 2F54 E6 C0          f@
                    stb       $08,S               * 2F56 E7 68          gh
                    bra       L2F5C               * 2F58 20 02           .
                    leas      -$0B,X              * 2F5A 32 15          2.
L2F5C               ldd       $06,S               * 2F5C EC 66          lf
                    pshs      D                   * 2F5E 34 06          4.
                    leax      <$0015,S            * 2F60 30 E8 15       0h.
                    pshs      X                   * 2F63 34 10          4.
                    ldb       $0C,S               * 2F65 E6 6C          fl
                    sex                           * 2F67 1D             .
                    pshs      D                   * 2F68 34 06          4.
                    lbsr      L34FC               * 2F6A 17 05 8F       ...
L2F6D               leas      $04,S               * 2F6D 32 64          2d
L2F6F               pshs      D                   * 2F6F 34 06          4.
L2F71               ldd       <$0013,S            * 2F71 EC E8 13       lh.
                    pshs      D                   * 2F74 34 06          4.
                    lbsr      L31BE               * 2F76 17 02 45       ..E
                    leas      $06,S               * 2F79 32 66          2f
L2F7B               lbra      L2DB7               * 2F7B 16 FE 39       .~9
L2F7E               ldb       $08,S               * 2F7E E6 68          fh
                    sex                           * 2F80 1D             .
L2F81               pshs      D                   * 2F81 34 06          4.
                    jsr       [<$11,S]            * 2F83 AD F8 11       -x.
                    leas      $02,S               * 2F86 32 62          2b
                    lbra      L2DB7               * 2F88 16 FE 2C       .~,
L2F8B               cmpx      #100                * 2F8B 8C 00 64       ..d
                    lbeq      L2E65               * 2F8E 10 27 FE D3    .'~S
                    cmpx      #111                * 2F92 8C 00 6F       ..o
                    lbeq      L2E7A               * 2F95 10 27 FE E1    .'~a
                    cmpx      #120                * 2F99 8C 00 78       ..x
                    lbeq      L2E92               * 2F9C 10 27 FE F2    .'~r
                    cmpx      #88                 * 2FA0 8C 00 58       ..X
                    lbeq      L2E92               * 2FA3 10 27 FE EB    .'~k
                    cmpx      #117                * 2FA7 8C 00 75       ..u
                    lbeq      L2EB8               * 2FAA 10 27 FF 0A    .'..
                    cmpx      #102                * 2FAE 8C 00 66       ..f
                    lbeq      L2ED4               * 2FB1 10 27 FF 1F    .'..
                    cmpx      #101                * 2FB5 8C 00 65       ..e
                    lbeq      L2ED4               * 2FB8 10 27 FF 18    .'..
                    cmpx      #103                * 2FBC 8C 00 67       ..g
                    lbeq      L2ED4               * 2FBF 10 27 FF 11    .'..
                    cmpx      #69                 * 2FC3 8C 00 45       ..E
                    lbeq      L2ED4               * 2FC6 10 27 FF 0A    .'..
                    cmpx      #71                 * 2FCA 8C 00 47       ..G
                    lbeq      L2ED4               * 2FCD 10 27 FF 03    .'..
                    cmpx      #99                 * 2FD1 8C 00 63       ..c
                    lbeq      L2EF7               * 2FD4 10 27 FF 1F    .'..
                    cmpx      #115                * 2FD8 8C 00 73       ..s
                    lbeq      L2F04               * 2FDB 10 27 FF 25    .'.%
                    cmpx      #108                * 2FDF 8C 00 6C       ..l
                    lbeq      L2F54               * 2FE2 10 27 FF 6E    .'.n
                    bra       L2F7E               * 2FE6 20 96           .
L2FE8               leas      $0B,S               * 2FE8 32 6B          2k
                    puls      PC,U                * 2FEA 35 C0          5@
L2FEC               pshs      U,D                 * 2FEC 34 46          4F
                    leax      >U37B7,Y            * 2FEE 30 A9 37 B7    0)77
                    stx       0,S                 * 2FF2 AF E4          /d
                    ldd       $06,S               * 2FF4 EC 66          lf
                    bge       L3021               * 2FF6 2C 29          ,)
                    ldd       $06,S               * 2FF8 EC 66          lf
                    nega                          * 2FFA 40             @
                    negb                          * 2FFB 50             P
                    sbca      #0                  * 2FFC 82 00          ..
                    std       $06,S               * 2FFE ED 66          mf
                    bge       L3016               * 3000 2C 14          ,.
                    leax      >L324A,PC           * 3002 30 8D 02 44    0..D
                    pshs      X                   * 3006 34 10          4.
                    leax      >U37B7,Y            * 3008 30 A9 37 B7    0)77
                    pshs      X                   * 300C 34 10          4.
                    lbsr      L3556               * 300E 17 05 45       ..E
                    leas      $04,S               * 3011 32 64          2d
                    lbra      L30ED               * 3013 16 00 D7       ..W
L3016               ldd       #45                 * 3016 CC 00 2D       L.-
                    ldx       0,S                 * 3019 AE E4          .d
                    leax      $01,X               * 301B 30 01          0.
                    stx       0,S                 * 301D AF E4          /d
                    stb       -$01,X              * 301F E7 1F          g.
L3021               ldd       $06,S               * 3021 EC 66          lf
                    pshs      D                   * 3023 34 06          4.
                    ldd       $02,S               * 3025 EC 62          lb
                    pshs      D                   * 3027 34 06          4.
                    bsr       L3030               * 3029 8D 05          ..
                    leas      $04,S               * 302B 32 64          2d
                    lbra      L30E7               * 302D 16 00 B7       ..7
L3030               pshs      U,Y,X,D             * 3030 34 76          4v
                    ldu       $0A,S               * 3032 EE 6A          nj
                    clra                          * 3034 4F             O
                    clrb                          * 3035 5F             _
                    std       $02,S               * 3036 ED 62          mb
                    clra                          * 3038 4F             O
                    clrb                          * 3039 5F             _
                    std       0,S                 * 303A ED E4          md
                    bra       L304D               * 303C 20 0F           .
L303E               ldd       0,S                 * 303E EC E4          ld
                    addd      #1                  * 3040 C3 00 01       C..
                    std       0,S                 * 3043 ED E4          md
                    ldd       $0C,S               * 3045 EC 6C          ll
                    subd      >U002F,Y            * 3047 A3 A9 00 2F    #)./
                    std       $0C,S               * 304B ED 6C          ml
L304D               ldd       $0C,S               * 304D EC 6C          ll
                    blt       L303E               * 304F 2D ED          -m
                    leax      >U002F,Y            * 3051 30 A9 00 2F    0)./
                    stx       $04,S               * 3055 AF 64          /d
                    bra       L308F               * 3057 20 36           6
L3059               ldd       0,S                 * 3059 EC E4          ld
                    addd      #1                  * 305B C3 00 01       C..
                    std       0,S                 * 305E ED E4          md
L3060               ldd       $0C,S               * 3060 EC 6C          ll
                    subd      [<$04,S]            * 3062 A3 F8 04       #x.
                    std       $0C,S               * 3065 ED 6C          ml
                    bge       L3059               * 3067 2C F0          ,p
                    ldd       $0C,S               * 3069 EC 6C          ll
                    addd      [<$04,S]            * 306B E3 F8 04       cx.
                    std       $0C,S               * 306E ED 6C          ml
                    ldd       0,S                 * 3070 EC E4          ld
                    beq       L3079               * 3072 27 05          '.
                    ldd       #1                  * 3074 CC 00 01       L..
                    std       $02,S               * 3077 ED 62          mb
L3079               ldd       $02,S               * 3079 EC 62          lb
                    beq       L3084               * 307B 27 07          '.
                    ldd       0,S                 * 307D EC E4          ld
                    addd      #48                 * 307F C3 00 30       C.0
                    stb       ,U+                 * 3082 E7 C0          g@
L3084               clra                          * 3084 4F             O
                    clrb                          * 3085 5F             _
                    std       0,S                 * 3086 ED E4          md
                    ldd       $04,S               * 3088 EC 64          ld
                    addd      #2                  * 308A C3 00 02       C..
                    std       $04,S               * 308D ED 64          md
L308F               ldd       $04,S               * 308F EC 64          ld
                    cmpd      >U0037,Y            * 3091 10 A3 A9 00 37 .#).7
                    bne       L3060               * 3096 26 C8          &H
                    ldd       $0C,S               * 3098 EC 6C          ll
                    addd      #48                 * 309A C3 00 30       C.0
                    stb       ,U+                 * 309D E7 C0          g@
                    clra                          * 309F 4F             O
                    clrb                          * 30A0 5F             _
                    stb       U0000,U             * 30A1 E7 C4          gD
                    ldd       $0A,S               * 30A3 EC 6A          lj
                    leas      $06,S               * 30A5 32 66          2f
                    puls      PC,U                * 30A7 35 C0          5@
L30A9               pshs      U,D                 * 30A9 34 46          4F
                    leax      >U37B7,Y            * 30AB 30 A9 37 B7    0)77
                    stx       0,S                 * 30AF AF E4          /d
                    leau      >U37C1,Y            * 30B1 33 A9 37 C1    3)7A
L30B5               ldd       $06,S               * 30B5 EC 66          lf
                    clra                          * 30B7 4F             O
                    andb      #7                  * 30B8 C4 07          D.
                    addd      #48                 * 30BA C3 00 30       C.0
                    stb       ,U+                 * 30BD E7 C0          g@
                    ldd       $06,S               * 30BF EC 66          lf
                    lsra                          * 30C1 44             D
                    rorb                          * 30C2 56             V
                    lsra                          * 30C3 44             D
                    rorb                          * 30C4 56             V
                    lsra                          * 30C5 44             D
                    rorb                          * 30C6 56             V
                    std       $06,S               * 30C7 ED 66          mf
                    bne       L30B5               * 30C9 26 EA          &j
                    bra       L30D7               * 30CB 20 0A           .
L30CD               ldb       U0000,U             * 30CD E6 C4          fD
                    ldx       0,S                 * 30CF AE E4          .d
                    leax      $01,X               * 30D1 30 01          0.
                    stx       0,S                 * 30D3 AF E4          /d
                    stb       -$01,X              * 30D5 E7 1F          g.
L30D7               leau      -$01,U              * 30D7 33 5F          3_
                    pshs      U                   * 30D9 34 40          4@
                    leax      >U37C1,Y            * 30DB 30 A9 37 C1    0)7A
                    cmpx      ,S++                * 30DF AC E1          ,a
                    bls       L30CD               * 30E1 23 EA          #j
                    clra                          * 30E3 4F             O
                    clrb                          * 30E4 5F             _
                    stb       [,S]                * 30E5 E7 F4          gt
L30E7               leax      >U37B7,Y            * 30E7 30 A9 37 B7    0)77
                    tfr       X,D                 * 30EB 1F 10          ..
L30ED               leas      $02,S               * 30ED 32 62          2b
                    puls      PC,U                * 30EF 35 C0          5@
L30F1               pshs      U,X,D               * 30F1 34 56          4V
                    leax      >U37B7,Y            * 30F3 30 A9 37 B7    0)77
                    stx       $02,S               * 30F7 AF 62          /b
                    leau      >U37C1,Y            * 30F9 33 A9 37 C1    3)7A
L30FD               ldd       $08,S               * 30FD EC 68          lh
                    clra                          * 30FF 4F             O
                    andb      #15                 * 3100 C4 0F          D.
                    std       0,S                 * 3102 ED E4          md
                    pshs      D                   * 3104 34 06          4.
                    ldd       $02,S               * 3106 EC 62          lb
                    cmpd      #9                  * 3108 10 83 00 09    ....
                    ble       L311F               * 310C 2F 11          /.
                    ldd       $0C,S               * 310E EC 6C          ll
                    beq       L3117               * 3110 27 05          '.
                    ldd       #65                 * 3112 CC 00 41       L.A
                    bra       L311A               * 3115 20 03           .
L3117               ldd       #97                 * 3117 CC 00 61       L.a
L311A               addd      #-10                * 311A C3 FF F6       C.v
                    bra       L3122               * 311D 20 03           .
L311F               ldd       #48                 * 311F CC 00 30       L.0
L3122               addd      ,S++                * 3122 E3 E1          ca
                    stb       ,U+                 * 3124 E7 C0          g@
                    ldd       $08,S               * 3126 EC 68          lh
                    lsra                          * 3128 44             D
                    rorb                          * 3129 56             V
                    lsra                          * 312A 44             D
                    rorb                          * 312B 56             V
                    lsra                          * 312C 44             D
                    rorb                          * 312D 56             V
                    lsra                          * 312E 44             D
                    rorb                          * 312F 56             V
                    anda      #15                 * 3130 84 0F          ..
                    std       $08,S               * 3132 ED 68          mh
                    bne       L30FD               * 3134 26 C7          &G
                    bra       L3142               * 3136 20 0A           .
L3138               ldb       U0000,U             * 3138 E6 C4          fD
                    ldx       $02,S               * 313A AE 62          .b
                    leax      $01,X               * 313C 30 01          0.
                    stx       $02,S               * 313E AF 62          /b
                    stb       -$01,X              * 3140 E7 1F          g.
L3142               leau      -$01,U              * 3142 33 5F          3_
                    pshs      U                   * 3144 34 40          4@
                    leax      >U37C1,Y            * 3146 30 A9 37 C1    0)7A
                    cmpx      ,S++                * 314A AC E1          ,a
                    bls       L3138               * 314C 23 EA          #j
                    clra                          * 314E 4F             O
                    clrb                          * 314F 5F             _
                    stb       [<$02,S]            * 3150 E7 F8 02       gx.
                    leax      >U37B7,Y            * 3153 30 A9 37 B7    0)77
                    tfr       X,D                 * 3157 1F 10          ..
                    lbra      L3234               * 3159 16 00 D8       ..X
L315C               pshs      U                   * 315C 34 40          4@
                    ldu       $06,S               * 315E EE 66          nf
                    ldd       $0A,S               * 3160 EC 6A          lj
                    subd      $08,S               * 3162 A3 68          #h
                    std       $0A,S               * 3164 ED 6A          mj
                    ldd       >U37CB,Y            * 3166 EC A9 37 CB    l)7K
                    bne       L3191               * 316A 26 25          &%
                    bra       L3179               * 316C 20 0B           .
L316E               ldd       >U37CD,Y            * 316E EC A9 37 CD    l)7M
                    pshs      D                   * 3172 34 06          4.
                    jsr       [<$06,S]            * 3174 AD F8 06       -x.
                    leas      $02,S               * 3177 32 62          2b
L3179               ldd       $0A,S               * 3179 EC 6A          lj
                    addd      #-1                 * 317B C3 FF FF       C..
                    std       $0A,S               * 317E ED 6A          mj
                    subd      #-1                 * 3180 83 FF FF       ...
                    bgt       L316E               * 3183 2E E9          .i
                    bra       L3191               * 3185 20 0A           .
L3187               ldb       ,U+                 * 3187 E6 C0          f@
                    sex                           * 3189 1D             .
                    pshs      D                   * 318A 34 06          4.
                    jsr       [<$06,S]            * 318C AD F8 06       -x.
                    leas      $02,S               * 318F 32 62          2b
L3191               ldd       $08,S               * 3191 EC 68          lh
                    addd      #-1                 * 3193 C3 FF FF       C..
                    std       $08,S               * 3196 ED 68          mh
                    subd      #-1                 * 3198 83 FF FF       ...
                    bne       L3187               * 319B 26 EA          &j
                    ldd       >U37CB,Y            * 319D EC A9 37 CB    l)7K
                    beq       L31BC               * 31A1 27 19          '.
                    bra       L31B0               * 31A3 20 0B           .
L31A5               ldd       >U37CD,Y            * 31A5 EC A9 37 CD    l)7M
                    pshs      D                   * 31A9 34 06          4.
                    jsr       [<$06,S]            * 31AB AD F8 06       -x.
                    leas      $02,S               * 31AE 32 62          2b
L31B0               ldd       $0A,S               * 31B0 EC 6A          lj
                    addd      #-1                 * 31B2 C3 FF FF       C..
                    std       $0A,S               * 31B5 ED 6A          mj
                    subd      #-1                 * 31B7 83 FF FF       ...
                    bgt       L31A5               * 31BA 2E E9          .i
L31BC               puls      PC,U                * 31BC 35 C0          5@
L31BE               pshs      U                   * 31BE 34 40          4@
                    ldu       $06,S               * 31C0 EE 66          nf
                    ldd       $08,S               * 31C2 EC 68          lh
                    pshs      D                   * 31C4 34 06          4.
                    pshs      U                   * 31C6 34 40          4@
                    lbsr      L3545               * 31C8 17 03 7A       ..z
                    leas      $02,S               * 31CB 32 62          2b
                    nega                          * 31CD 40             @
                    negb                          * 31CE 50             P
                    sbca      #0                  * 31CF 82 00          ..
                    addd      ,S++                * 31D1 E3 E1          ca
                    std       $08,S               * 31D3 ED 68          mh
                    ldd       >U37CB,Y            * 31D5 EC A9 37 CB    l)7K
                    bne       L3200               * 31D9 26 25          &%
                    bra       L31E8               * 31DB 20 0B           .
L31DD               ldd       >U37CD,Y            * 31DD EC A9 37 CD    l)7M
                    pshs      D                   * 31E1 34 06          4.
                    jsr       [<$06,S]            * 31E3 AD F8 06       -x.
                    leas      $02,S               * 31E6 32 62          2b
L31E8               ldd       $08,S               * 31E8 EC 68          lh
                    addd      #-1                 * 31EA C3 FF FF       C..
                    std       $08,S               * 31ED ED 68          mh
                    subd      #-1                 * 31EF 83 FF FF       ...
                    bgt       L31DD               * 31F2 2E E9          .i
                    bra       L3200               * 31F4 20 0A           .
L31F6               ldb       ,U+                 * 31F6 E6 C0          f@
                    sex                           * 31F8 1D             .
                    pshs      D                   * 31F9 34 06          4.
                    jsr       [<$06,S]            * 31FB AD F8 06       -x.
                    leas      $02,S               * 31FE 32 62          2b
L3200               ldb       U0000,U             * 3200 E6 C4          fD
                    bne       L31F6               * 3202 26 F2          &r
                    ldd       >U37CB,Y            * 3204 EC A9 37 CB    l)7K
                    beq       L3223               * 3208 27 19          '.
                    bra       L3217               * 320A 20 0B           .
L320C               ldd       >U37CD,Y            * 320C EC A9 37 CD    l)7M
                    pshs      D                   * 3210 34 06          4.
                    jsr       [<$06,S]            * 3212 AD F8 06       -x.
                    leas      $02,S               * 3215 32 62          2b
L3217               ldd       $08,S               * 3217 EC 68          lh
                    addd      #-1                 * 3219 C3 FF FF       C..
                    std       $08,S               * 321C ED 68          mh
                    subd      #-1                 * 321E 83 FF FF       ...
                    bgt       L320C               * 3221 2E E9          .i
L3223               puls      PC,U                * 3223 35 C0          5@
L3225               pshs      U                   * 3225 34 40          4@
                    ldd       >U37B5,Y            * 3227 EC A9 37 B5    l)75
                    pshs      D                   * 322B 34 06          4.
                    ldd       $06,S               * 322D EC 66          lf
                    pshs      D                   * 322F 34 06          4.
                    lbsr      L3251               * 3231 17 00 1D       ...
L3234               leas      $04,S               * 3234 32 64          2d
                    puls      PC,U                * 3236 35 C0          5@
L3238               pshs      U                   * 3238 34 40          4@
                    ldd       $04,S               * 323A EC 64          ld
                    ldx       >U37B5,Y            * 323C AE A9 37 B5    .)75
                    leax      $01,X               * 3240 30 01          0.
                    stx       >U37B5,Y            * 3242 AF A9 37 B5    /)75
                    stb       -$01,X              * 3246 E7 1F          g.
                    puls      PC,U                * 3248 35 C0          5@
L324A               fcc       "-32768"            * 324A 2D 33 32 37 36 38 -32768
                    fcb       $00                 * 3250 00             .
L3251               pshs      U                   * 3251 34 40          4@
                    ldu       $06,S               * 3253 EE 66          nf
                    ldd       U0006,U             * 3255 EC 46          lF
                    anda      #128                * 3257 84 80          ..
                    andb      #34                 * 3259 C4 22          D"
                    cmpd      #-32766             * 325B 10 83 80 02    ....
                    beq       L3275               * 325F 27 14          '.
                    ldd       U0006,U             * 3261 EC 46          lF
                    clra                          * 3263 4F             O
                    andb      #34                 * 3264 C4 22          D"
                    cmpd      #2                  * 3266 10 83 00 02    ....
                    lbne      L338D               * 326A 10 26 01 1F    .&..
                    pshs      U                   * 326E 34 40          4@
                    lbsr      L346C               * 3270 17 01 F9       ..y
                    leas      $02,S               * 3273 32 62          2b
L3275               ldd       U0006,U             * 3275 EC 46          lF
                    clra                          * 3277 4F             O
                    andb      #4                  * 3278 C4 04          D.
                    beq       L32B1               * 327A 27 35          '5
                    ldd       #1                  * 327C CC 00 01       L..
                    pshs      D                   * 327F 34 06          4.
                    leax      $07,S               * 3281 30 67          0g
                    pshs      X                   * 3283 34 10          4.
                    ldd       U0008,U             * 3285 EC 48          lH
                    pshs      D                   * 3287 34 06          4.
                    ldd       U0006,U             * 3289 EC 46          lF
                    clra                          * 328B 4F             O
                    andb      #64                 * 328C C4 40          D@
                    beq       L3296               * 328E 27 06          '.
                    leax      >writln,PC          * 3290 30 8D 06 5A    0..Z
                    bra       L329A               * 3294 20 04           .
L3296               leax      >write,PC           * 3296 30 8D 06 3B    0..;
L329A               tfr       X,D                 * 329A 1F 10          ..
                    tfr       D,X                 * 329C 1F 01          ..
                    jsr       0,X                 * 329E AD 84          -.
                    leas      $06,S               * 32A0 32 66          2f
                    cmpd      #-1                 * 32A2 10 83 FF FF    ....
                    bne       L32F2               * 32A6 26 4A          &J
                    ldd       U0006,U             * 32A8 EC 46          lF
                    orb       #32                 * 32AA CA 20          J
                    std       U0006,U             * 32AC ED 46          mF
                    lbra      L338D               * 32AE 16 00 DC       ..\
L32B1               ldd       U0006,U             * 32B1 EC 46          lF
                    anda      #1                  * 32B3 84 01          ..
                    clrb                          * 32B5 5F             _
                    std       -$02,S              * 32B6 ED 7E          m~
                    bne       L32C1               * 32B8 26 07          &.
                    pshs      U                   * 32BA 34 40          4@
                    lbsr      L33AA               * 32BC 17 00 EB       ..k
                    leas      $02,S               * 32BF 32 62          2b
L32C1               ldd       U0000,U             * 32C1 EC C4          lD
                    addd      #1                  * 32C3 C3 00 01       C..
                    std       U0000,U             * 32C6 ED C4          mD
                    subd      #1                  * 32C8 83 00 01       ...
                    tfr       D,X                 * 32CB 1F 01          ..
                    ldd       $04,S               * 32CD EC 64          ld
                    stb       0,X                 * 32CF E7 84          g.
                    ldd       U0000,U             * 32D1 EC C4          lD
                    cmpd      U0004,U             * 32D3 10 A3 44       .#D
                    bcc       L32E7               * 32D6 24 0F          $.
                    ldd       U0006,U             * 32D8 EC 46          lF
                    clra                          * 32DA 4F             O
                    andb      #64                 * 32DB C4 40          D@
                    beq       L32F2               * 32DD 27 13          '.
                    ldd       $04,S               * 32DF EC 64          ld
                    cmpd      #13                 * 32E1 10 83 00 0D    ....
                    bne       L32F2               * 32E5 26 0B          &.
L32E7               pshs      U                   * 32E7 34 40          4@
                    lbsr      L33AA               * 32E9 17 00 BE       ..>
                    std       ,S++                * 32EC ED E1          ma
                    lbne      L338D               * 32EE 10 26 00 9B    .&..
L32F2               ldd       $04,S               * 32F2 EC 64          ld
                    puls      PC,U                * 32F4 35 C0          5@
                    pshs      U                   * 32F6 34 40          4@
                    ldu       $04,S               * 32F8 EE 64          nd
                    ldd       $06,S               * 32FA EC 66          lf
                    pshs      D                   * 32FC 34 06          4.
                    pshs      U                   * 32FE 34 40          4@
                    ldd       #8                  * 3300 CC 00 08       L..
                    lbsr      L3787               * 3303 17 04 81       ...
                    pshs      D                   * 3306 34 06          4.
                    lbsr      L3251               * 3308 17 FF 46       ..F
                    leas      $04,S               * 330B 32 64          2d
                    ldd       $06,S               * 330D EC 66          lf
                    pshs      D                   * 330F 34 06          4.
                    pshs      U                   * 3311 34 40          4@
                    lbsr      L3251               * 3313 17 FF 3B       ..;
                    lbra      L3464               * 3316 16 01 4B       ..K
L3319               pshs      U,D                 * 3319 34 46          4F
                    leau      >U003C,Y            * 331B 33 A9 00 3C    3).<
                    clra                          * 331F 4F             O
                    clrb                          * 3320 5F             _
                    std       0,S                 * 3321 ED E4          md
                    bra       L332F               * 3323 20 0A           .
L3325               tfr       U,D                 * 3325 1F 30          .0
                    leau      U000D,U             * 3327 33 4D          3M
                    pshs      D                   * 3329 34 06          4.
                    bsr       L3342               * 332B 8D 15          ..
                    leas      $02,S               * 332D 32 62          2b
L332F               ldd       0,S                 * 332F EC E4          ld
                    addd      #1                  * 3331 C3 00 01       C..
                    std       0,S                 * 3334 ED E4          md
                    subd      #1                  * 3336 83 00 01       ...
                    cmpd      #16                 * 3339 10 83 00 10    ....
                    blt       L3325               * 333D 2D E6          -f
                    lbra      L33A6               * 333F 16 00 64       ..d
L3342               pshs      U                   * 3342 34 40          4@
                    ldu       $04,S               * 3344 EE 64          nd
                    leas      -$02,S              * 3346 32 7E          2~
                    cmpu      #0                  * 3348 11 83 00 00    ....
                    beq       L3352               * 334C 27 04          '.
                    ldd       U0006,U             * 334E EC 46          lF
                    bne       L3358               * 3350 26 06          &.
L3352               ldd       #-1                 * 3352 CC FF FF       L..
                    lbra      L33A6               * 3355 16 00 4E       ..N
L3358               ldd       U0006,U             * 3358 EC 46          lF
                    clra                          * 335A 4F             O
                    andb      #2                  * 335B C4 02          D.
                    beq       L3367               * 335D 27 08          '.
                    pshs      U                   * 335F 34 40          4@
                    bsr       L337C               * 3361 8D 19          ..
                    leas      $02,S               * 3363 32 62          2b
                    bra       L3369               * 3365 20 02           .
L3367               clra                          * 3367 4F             O
                    clrb                          * 3368 5F             _
L3369               std       0,S                 * 3369 ED E4          md
                    ldd       U0008,U             * 336B EC 48          lH
                    pshs      D                   * 336D 34 06          4.
                    lbsr      close               * 336F 17 04 C5       ..E
                    leas      $02,S               * 3372 32 62          2b
                    clra                          * 3374 4F             O
                    clrb                          * 3375 5F             _
                    std       U0006,U             * 3376 ED 46          mF
                    ldd       0,S                 * 3378 EC E4          ld
                    bra       L33A6               * 337A 20 2A           *
L337C               pshs      U                   * 337C 34 40          4@
                    ldu       $04,S               * 337E EE 64          nd
                    beq       L338D               * 3380 27 0B          '.
                    ldd       U0006,U             * 3382 EC 46          lF
                    clra                          * 3384 4F             O
                    andb      #34                 * 3385 C4 22          D"
                    cmpd      #2                  * 3387 10 83 00 02    ....
                    beq       L3392               * 338B 27 05          '.
L338D               ldd       #-1                 * 338D CC FF FF       L..
                    puls      PC,U                * 3390 35 C0          5@
L3392               ldd       U0006,U             * 3392 EC 46          lF
                    anda      #128                * 3394 84 80          ..
                    clrb                          * 3396 5F             _
                    std       -$02,S              * 3397 ED 7E          m~
                    bne       L33A2               * 3399 26 07          &.
                    pshs      U                   * 339B 34 40          4@
                    lbsr      L346C               * 339D 17 00 CC       ..L
                    leas      $02,S               * 33A0 32 62          2b
L33A2               pshs      U                   * 33A2 34 40          4@
                    bsr       L33AA               * 33A4 8D 04          ..
L33A6               leas      $02,S               * 33A6 32 62          2b
                    puls      PC,U                * 33A8 35 C0          5@
L33AA               pshs      U                   * 33AA 34 40          4@
                    ldu       $04,S               * 33AC EE 64          nd
                    leas      -$04,S              * 33AE 32 7C          2|
                    ldd       U0006,U             * 33B0 EC 46          lF
                    anda      #1                  * 33B2 84 01          ..
                    clrb                          * 33B4 5F             _
                    std       -$02,S              * 33B5 ED 7E          m~
                    bne       L33DC               * 33B7 26 23          &#
                    ldd       U0000,U             * 33B9 EC C4          lD
                    cmpd      U0004,U             * 33BB 10 A3 44       .#D
                    beq       L33DC               * 33BE 27 1C          '.
                    clra                          * 33C0 4F             O
                    clrb                          * 33C1 5F             _
                    pshs      D                   * 33C2 34 06          4.
                    pshs      U                   * 33C4 34 40          4@
                    lbsr      L3468               * 33C6 17 00 9F       ...
                    leas      $02,S               * 33C9 32 62          2b
                    ldd       $02,X               * 33CB EC 02          l.
                    pshs      D                   * 33CD 34 06          4.
                    ldd       0,X                 * 33CF EC 84          l.
                    pshs      D                   * 33D1 34 06          4.
                    ldd       U0008,U             * 33D3 EC 48          lH
                    pshs      D                   * 33D5 34 06          4.
                    lbsr      L38FE               * 33D7 17 05 24       ..$
                    leas      $08,S               * 33DA 32 68          2h
L33DC               ldd       U0000,U             * 33DC EC C4          lD
                    subd      U0002,U             * 33DE A3 42          #B
                    std       $02,S               * 33E0 ED 62          mb
                    lbeq      L3454               * 33E2 10 27 00 6E    .'.n
                    ldd       U0006,U             * 33E6 EC 46          lF
                    anda      #1                  * 33E8 84 01          ..
                    clrb                          * 33EA 5F             _
                    std       -$02,S              * 33EB ED 7E          m~
                    lbeq      L3454               * 33ED 10 27 00 63    .'.c
                    ldd       U0006,U             * 33F1 EC 46          lF
                    clra                          * 33F3 4F             O
                    andb      #64                 * 33F4 C4 40          D@
                    beq       L342B               * 33F6 27 33          '3
                    ldd       U0002,U             * 33F8 EC 42          lB
                    bra       L3423               * 33FA 20 27           '
L33FC               ldd       $02,S               * 33FC EC 62          lb
                    pshs      D                   * 33FE 34 06          4.
                    ldd       U0000,U             * 3400 EC C4          lD
                    pshs      D                   * 3402 34 06          4.
                    ldd       U0008,U             * 3404 EC 48          lH
                    pshs      D                   * 3406 34 06          4.
                    lbsr      writln              * 3408 17 04 E3       ..c
                    leas      $06,S               * 340B 32 66          2f
                    std       0,S                 * 340D ED E4          md
                    cmpd      #-1                 * 340F 10 83 FF FF    ....
                    bne       L3419               * 3413 26 04          &.
                    leax      $04,S               * 3415 30 64          0d
                    bra       L3443               * 3417 20 2A           *
L3419               ldd       $02,S               * 3419 EC 62          lb
                    subd      0,S                 * 341B A3 E4          #d
                    std       $02,S               * 341D ED 62          mb
                    ldd       U0000,U             * 341F EC C4          lD
                    addd      0,S                 * 3421 E3 E4          cd
L3423               std       U0000,U             * 3423 ED C4          mD
                    ldd       $02,S               * 3425 EC 62          lb
                    bne       L33FC               * 3427 26 D3          &S
                    bra       L3454               * 3429 20 29           )
L342B               ldd       $02,S               * 342B EC 62          lb
                    pshs      D                   * 342D 34 06          4.
                    ldd       U0002,U             * 342F EC 42          lB
                    pshs      D                   * 3431 34 06          4.
                    ldd       U0008,U             * 3433 EC 48          lH
                    pshs      D                   * 3435 34 06          4.
                    lbsr      write               * 3437 17 04 9B       ...
                    leas      $06,S               * 343A 32 66          2f
                    cmpd      $02,S               * 343C 10 A3 62       .#b
                    beq       L3454               * 343F 27 13          '.
                    bra       L3445               * 3441 20 02           .
L3443               leas      -$04,X              * 3443 32 1C          2.
L3445               ldd       U0006,U             * 3445 EC 46          lF
                    orb       #32                 * 3447 CA 20          J
                    std       U0006,U             * 3449 ED 46          mF
                    ldd       U0004,U             * 344B EC 44          lD
                    std       U0000,U             * 344D ED C4          mD
                    ldd       #-1                 * 344F CC FF FF       L..
                    bra       L3464               * 3452 20 10           .
L3454               ldd       U0006,U             * 3454 EC 46          lF
                    ora       #1                  * 3456 8A 01          ..
                    std       U0006,U             * 3458 ED 46          mF
                    ldd       U0002,U             * 345A EC 42          lB
                    std       U0000,U             * 345C ED C4          mD
                    addd      U000B,U             * 345E E3 4B          cK
                    std       U0004,U             * 3460 ED 44          mD
                    clra                          * 3462 4F             O
                    clrb                          * 3463 5F             _
L3464               leas      $04,S               * 3464 32 64          2d
                    puls      PC,U                * 3466 35 C0          5@
L3468               pshs      U                   * 3468 34 40          4@
                    puls      PC,U                * 346A 35 C0          5@
L346C               pshs      U                   * 346C 34 40          4@
                    ldu       $04,S               * 346E EE 64          nd
                    ldd       U0006,U             * 3470 EC 46          lF
                    clra                          * 3472 4F             O
                    andb      #192                * 3473 C4 C0          D@
                    bne       L34A4               * 3475 26 2D          &-
                    leas      -$20,S              * 3477 32 E8 E0       2h`
                    leax      0,S                 * 347A 30 E4          0d
                    pshs      X                   * 347C 34 10          4.
                    ldd       U0008,U             * 347E EC 48          lH
                    pshs      D                   * 3480 34 06          4.
                    clra                          * 3482 4F             O
                    clrb                          * 3483 5F             _
                    pshs      D                   * 3484 34 06          4.
                    lbsr      L37B9               * 3486 17 03 30       ..0
                    leas      $06,S               * 3489 32 66          2f
                    ldd       U0006,U             * 348B EC 46          lF
                    pshs      D                   * 348D 34 06          4.
                    ldb       $02,S               * 348F E6 62          fb
                    bne       L3498               * 3491 26 05          &.
                    ldd       #64                 * 3493 CC 00 40       L.@
                    bra       L349B               * 3496 20 03           .
L3498               ldd       #128                * 3498 CC 00 80       L..
L349B               ora       ,S+                 * 349B AA E0          *`
                    orb       ,S+                 * 349D EA E0          j`
                    std       U0006,U             * 349F ED 46          mF
                    leas      <$0020,S            * 34A1 32 E8 20       2h
L34A4               ldd       U0006,U             * 34A4 EC 46          lF
                    ora       #128                * 34A6 8A 80          ..
                    std       U0006,U             * 34A8 ED 46          mF
                    clra                          * 34AA 4F             O
                    andb      #12                 * 34AB C4 0C          D.
                    beq       L34B1               * 34AD 27 02          '.
                    puls      PC,U                * 34AF 35 C0          5@
L34B1               ldd       U000B,U             * 34B1 EC 4B          lK
                    bne       L34C6               * 34B3 26 11          &.
                    ldd       U0006,U             * 34B5 EC 46          lF
                    clra                          * 34B7 4F             O
                    andb      #64                 * 34B8 C4 40          D@
                    beq       L34C1               * 34BA 27 05          '.
                    ldd       #128                * 34BC CC 00 80       L..
                    bra       L34C4               * 34BF 20 03           .
L34C1               ldd       #256                * 34C1 CC 01 00       L..
L34C4               std       U000B,U             * 34C4 ED 4B          mK
L34C6               ldd       U0002,U             * 34C6 EC 42          lB
                    bne       L34DB               * 34C8 26 11          &.
                    ldd       U000B,U             * 34CA EC 4B          lK
                    pshs      D                   * 34CC 34 06          4.
                    lbsr      L39EE               * 34CE 17 05 1D       ...
                    leas      $02,S               * 34D1 32 62          2b
                    std       U0002,U             * 34D3 ED 42          mB
                    cmpd      #-1                 * 34D5 10 83 FF FF    ....
                    beq       L34E3               * 34D9 27 08          '.
L34DB               ldd       U0006,U             * 34DB EC 46          lF
                    orb       #8                  * 34DD CA 08          J.
                    std       U0006,U             * 34DF ED 46          mF
                    bra       L34F2               * 34E1 20 0F           .
L34E3               ldd       U0006,U             * 34E3 EC 46          lF
                    orb       #4                  * 34E5 CA 04          J.
                    std       U0006,U             * 34E7 ED 46          mF
                    leax      U000A,U             * 34E9 30 4A          0J
                    stx       U0002,U             * 34EB AF 42          /B
                    ldd       #1                  * 34ED CC 00 01       L..
                    std       U000B,U             * 34F0 ED 4B          mK
L34F2               ldd       U0002,U             * 34F2 EC 42          lB
                    addd      U000B,U             * 34F4 E3 4B          cK
                    std       U0004,U             * 34F6 ED 44          mD
                    std       U0000,U             * 34F8 ED C4          mD
                    puls      PC,U                * 34FA 35 C0          5@
L34FC               pshs      U                   * 34FC 34 40          4@
                    ldb       $05,S               * 34FE E6 65          fe
                    sex                           * 3500 1D             .
                    tfr       D,X                 * 3501 1F 01          ..
                    bra       L3522               * 3503 20 1D           .
L3505               ldd       [<$06,S]            * 3505 EC F8 06       lx.
                    addd      #4                  * 3508 C3 00 04       C..
                    std       [<$06,S]            * 350B ED F8 06       mx.
                    leax      >L3539,PC           * 350E 30 8D 00 27    0..'
                    bra       L351E               * 3512 20 0A           .
L3514               ldb       $05,S               * 3514 E6 65          fe
                    stb       >U003A,Y            * 3516 E7 A9 00 3A    g).:
                    leax      >U0039,Y            * 351A 30 A9 00 39    0).9
L351E               tfr       X,D                 * 351E 1F 10          ..
                    puls      PC,U                * 3520 35 C0          5@
L3522               cmpx      #100                * 3522 8C 00 64       ..d
                    beq       L3505               * 3525 27 DE          '^
                    cmpx      #111                * 3527 8C 00 6F       ..o
                    lbeq      L3505               * 352A 10 27 FF D7    .'.W
                    cmpx      #120                * 352E 8C 00 78       ..x
                    lbeq      L3505               * 3531 10 27 FF D0    .'.P
                    bra       L3514               * 3535 20 DD           ]
                    puls      PC,U                * 3537 35 C0          5@
L3539               fcb       $00                 * 3539 00             .
L353A               pshs      U                   * 353A 34 40          4@
                    leax      >L3544,PC           * 353C 30 8D 00 04    0...
                    tfr       X,D                 * 3540 1F 10          ..
                    puls      PC,U                * 3542 35 C0          5@
L3544               fcb       $00                 * 3544 00             .
L3545               pshs      U                   * 3545 34 40          4@
                    ldu       $04,S               * 3547 EE 64          nd
L3549               ldb       ,U+                 * 3549 E6 C0          f@
                    bne       L3549               * 354B 26 FC          &|
                    tfr       U,D                 * 354D 1F 30          .0
                    subd      $04,S               * 354F A3 64          #d
                    addd      #-1                 * 3551 C3 FF FF       C..
                    puls      PC,U                * 3554 35 C0          5@
L3556               pshs      U                   * 3556 34 40          4@
                    ldu       $06,S               * 3558 EE 66          nf
                    leas      -$02,S              * 355A 32 7E          2~
                    ldd       $06,S               * 355C EC 66          lf
                    std       0,S                 * 355E ED E4          md
L3560               ldb       ,U+                 * 3560 E6 C0          f@
                    ldx       0,S                 * 3562 AE E4          .d
                    leax      $01,X               * 3564 30 01          0.
                    stx       0,S                 * 3566 AF E4          /d
                    stb       -$01,X              * 3568 E7 1F          g.
                    bne       L3560               * 356A 26 F4          &t
                    bra       L3595               * 356C 20 27           '
                    pshs      U                   * 356E 34 40          4@
                    ldu       $06,S               * 3570 EE 66          nf
                    leas      -$02,S              * 3572 32 7E          2~
                    ldd       $06,S               * 3574 EC 66          lf
                    std       0,S                 * 3576 ED E4          md
L3578               ldx       0,S                 * 3578 AE E4          .d
                    leax      $01,X               * 357A 30 01          0.
                    stx       0,S                 * 357C AF E4          /d
                    ldb       -$01,X              * 357E E6 1F          f.
                    bne       L3578               * 3580 26 F6          &v
                    ldd       0,S                 * 3582 EC E4          ld
                    addd      #-1                 * 3584 C3 FF FF       C..
                    std       0,S                 * 3587 ED E4          md
L3589               ldb       ,U+                 * 3589 E6 C0          f@
                    ldx       0,S                 * 358B AE E4          .d
                    leax      $01,X               * 358D 30 01          0.
                    stx       0,S                 * 358F AF E4          /d
                    stb       -$01,X              * 3591 E7 1F          g.
                    bne       L3589               * 3593 26 F4          &t
L3595               ldd       $06,S               * 3595 EC 66          lf
                    leas      $02,S               * 3597 32 62          2b
                    puls      PC,U                * 3599 35 C0          5@
                    pshs      U                   * 359B 34 40          4@
                    ldu       $04,S               * 359D EE 64          nd
                    bra       L35B1               * 359F 20 10           .
L35A1               ldx       $06,S               * 35A1 AE 66          .f
                    leax      $01,X               * 35A3 30 01          0.
                    stx       $06,S               * 35A5 AF 66          /f
                    ldb       -$01,X              * 35A7 E6 1F          f.
                    bne       L35AF               * 35A9 26 04          &.
                    clra                          * 35AB 4F             O
                    clrb                          * 35AC 5F             _
                    puls      PC,U                * 35AD 35 C0          5@
L35AF               leau      dpsiz,U             * 35AF 33 41          3A
L35B1               ldb       U0000,U             * 35B1 E6 C4          fD
                    sex                           * 35B3 1D             .
                    pshs      D                   * 35B4 34 06          4.
                    ldb       [<$08,S]            * 35B6 E6 F8 08       fx.
                    sex                           * 35B9 1D             .
                    cmpd      ,S++                * 35BA 10 A3 E1       .#a
                    beq       L35A1               * 35BD 27 E2          'b
                    ldb       [<$06,S]            * 35BF E6 F8 06       fx.
                    sex                           * 35C2 1D             .
                    pshs      D                   * 35C3 34 06          4.
                    ldb       U0000,U             * 35C5 E6 C4          fD
                    sex                           * 35C7 1D             .
                    subd      ,S++                * 35C8 A3 E1          #a
                    puls      PC,U                * 35CA 35 C0          5@
L35CC               pshs      U                   * 35CC 34 40          4@
                    ldu       $04,S               * 35CE EE 64          nd
                    leas      -$05,S              * 35D0 32 7B          2{
                    clra                          * 35D2 4F             O
                    clrb                          * 35D3 5F             _
                    std       $01,S               * 35D4 ED 61          ma
L35D6               ldb       ,U+                 * 35D6 E6 C0          f@
                    stb       0,S                 * 35D8 E7 E4          gd
                    cmpb      #32                 * 35DA C1 20          A
                    beq       L35D6               * 35DC 27 F8          'x
                    ldb       0,S                 * 35DE E6 E4          fd
                    cmpb      #9                  * 35E0 C1 09          A.
                    lbeq      L35D6               * 35E2 10 27 FF F0    .'.p
                    ldb       0,S                 * 35E6 E6 E4          fd
                    cmpb      #45                 * 35E8 C1 2D          A-
                    bne       L35F1               * 35EA 26 05          &.
                    ldd       #1                  * 35EC CC 00 01       L..
                    bra       L35F3               * 35EF 20 02           .
L35F1               clra                          * 35F1 4F             O
                    clrb                          * 35F2 5F             _
L35F3               std       $03,S               * 35F3 ED 63          mc
                    ldb       0,S                 * 35F5 E6 E4          fd
                    cmpb      #45                 * 35F7 C1 2D          A-
                    beq       L3619               * 35F9 27 1E          '.
                    ldb       0,S                 * 35FB E6 E4          fd
                    cmpb      #43                 * 35FD C1 2B          A+
                    bne       L361D               * 35FF 26 1C          &.
                    bra       L3619               * 3601 20 16           .
L3603               ldd       $01,S               * 3603 EC 61          la
                    pshs      D                   * 3605 34 06          4.
                    ldd       #10                 * 3607 CC 00 0A       L..
                    lbsr      L365D               * 360A 17 00 50       ..P
                    pshs      D                   * 360D 34 06          4.
                    ldb       $02,S               * 360F E6 62          fb
                    sex                           * 3611 1D             .
                    addd      ,S++                * 3612 E3 E1          ca
                    addd      #-48                * 3614 C3 FF D0       C.P
                    std       $01,S               * 3617 ED 61          ma
L3619               ldb       ,U+                 * 3619 E6 C0          f@
                    stb       0,S                 * 361B E7 E4          gd
L361D               ldb       0,S                 * 361D E6 E4          fd
                    sex                           * 361F 1D             .
                    leax      >U010D,Y            * 3620 30 A9 01 0D    0)..
                    leax      D,X                 * 3624 30 8B          0.
                    ldb       0,X                 * 3626 E6 84          f.
                    clra                          * 3628 4F             O
                    andb      #8                  * 3629 C4 08          D.
                    bne       L3603               * 362B 26 D6          &V
                    ldd       $03,S               * 362D EC 63          lc
                    beq       L3639               * 362F 27 08          '.
                    ldd       $01,S               * 3631 EC 61          la
                    nega                          * 3633 40             @
                    negb                          * 3634 50             P
                    sbca      #0                  * 3635 82 00          ..
                    bra       L363B               * 3637 20 02           .
L3639               ldd       $01,S               * 3639 EC 61          la
L363B               leas      $05,S               * 363B 32 65          2e
                    puls      PC,U                * 363D 35 C0          5@
L363F               pshs      U                   * 363F 34 40          4@
                    ldd       $04,S               * 3641 EC 64          ld
                    beq       L3651               * 3643 27 0C          '.
                    ldd       $04,S               * 3645 EC 64          ld
                    pshs      D                   * 3647 34 06          4.
                    ldd       #10                 * 3649 CC 00 0A       L..
                    lbsr      L365D               * 364C 17 00 0E       ...
                    bra       L3654               * 364F 20 03           .
L3651               ldd       #1                  * 3651 CC 00 01       L..
L3654               pshs      D                   * 3654 34 06          4.
                    lbsr      sleep               * 3656 17 03 32       ..2
                    leas      $02,S               * 3659 32 62          2b
                    puls      PC,U                * 365B 35 C0          5@
L365D               tsta                          * 365D 4D             M
                    bne       L3672               * 365E 26 12          &.
                    tst       $02,S               * 3660 6D 62          mb
                    bne       L3672               * 3662 26 0E          &.
                    lda       $03,S               * 3664 A6 63          &c
                    mul                           * 3666 3D             =
                    ldx       0,S                 * 3667 AE E4          .d
                    stx       $02,S               * 3669 AF 62          /b
                    ldx       #0                  * 366B 8E 00 00       ...
                    std       0,S                 * 366E ED E4          md
                    puls      PC,D                * 3670 35 86          5.
L3672               pshs      D                   * 3672 34 06          4.
                    ldd       #0                  * 3674 CC 00 00       L..
                    pshs      D                   * 3677 34 06          4.
                    pshs      D                   * 3679 34 06          4.
                    lda       $05,S               * 367B A6 65          &e
                    ldb       $09,S               * 367D E6 69          fi
                    mul                           * 367F 3D             =
                    std       $02,S               * 3680 ED 62          mb
                    lda       $05,S               * 3682 A6 65          &e
                    ldb       $08,S               * 3684 E6 68          fh
                    mul                           * 3686 3D             =
                    addd      $01,S               * 3687 E3 61          ca
                    std       $01,S               * 3689 ED 61          ma
                    bcc       L368F               * 368B 24 02          $.
                    inc       0,S                 * 368D 6C E4          ld
L368F               lda       $04,S               * 368F A6 64          &d
                    ldb       $09,S               * 3691 E6 69          fi
                    mul                           * 3693 3D             =
                    addd      $01,S               * 3694 E3 61          ca
                    std       $01,S               * 3696 ED 61          ma
                    bcc       L369C               * 3698 24 02          $.
                    inc       0,S                 * 369A 6C E4          ld
L369C               lda       $04,S               * 369C A6 64          &d
                    ldb       $08,S               * 369E E6 68          fh
                    mul                           * 36A0 3D             =
                    addd      0,S                 * 36A1 E3 E4          cd
                    std       0,S                 * 36A3 ED E4          md
                    ldx       $06,S               * 36A5 AE 66          .f
                    stx       $08,S               * 36A7 AF 68          /h
                    ldx       0,S                 * 36A9 AE E4          .d
                    ldd       $02,S               * 36AB EC 62          lb
                    leas      $08,S               * 36AD 32 68          2h
                    rts                           * 36AF 39             9
                    clr       >U37CF,Y            * 36B0 6F A9 37 CF    o)7O
                    leax      >L36F8,PC           * 36B4 30 8D 00 40    0..@
                    stx       >U37D0,Y            * 36B8 AF A9 37 D0    /)7P
                    bra       L36D2               * 36BC 20 14           .
L36BE               leax      >L3711,PC           * 36BE 30 8D 00 4F    0..O
                    stx       >U37D0,Y            * 36C2 AF A9 37 D0    /)7P
                    clr       >U37CF,Y            * 36C6 6F A9 37 CF    o)7O
                    tst       $02,S               * 36CA 6D 62          mb
                    bpl       L36D2               * 36CC 2A 04          *.
                    inc       >U37CF,Y            * 36CE 6C A9 37 CF    l)7O
L36D2               subd      #0                  * 36D2 83 00 00       ...
                    bne       L36DD               * 36D5 26 06          &.
                    puls      X                   * 36D7 35 10          5.
                    ldd       ,S++                * 36D9 EC E1          la
                    jmp       0,X                 * 36DB 6E 84          n.
L36DD               ldx       $02,S               * 36DD AE 62          .b
                    pshs      X                   * 36DF 34 10          4.
                    jsr       [>$37D0,Y]          * 36E1 AD B9 37 D0    -97P
                    ldd       0,S                 * 36E5 EC E4          ld
                    std       $02,S               * 36E7 ED 62          mb
                    tfr       X,D                 * 36E9 1F 10          ..
                    tst       >U37CF,Y            * 36EB 6D A9 37 CF    m)7O
                    beq       L36F5               * 36EF 27 04          '.
                    nega                          * 36F1 40             @
                    negb                          * 36F2 50             P
                    sbca      #0                  * 36F3 82 00          ..
L36F5               std       ,S++                * 36F5 ED E1          ma
                    rts                           * 36F7 39             9
L36F8               subd      #0                  * 36F8 83 00 00       ...
                    beq       L3707               * 36FB 27 0A          '.
                    pshs      D                   * 36FD 34 06          4.
                    leas      -$02,S              * 36FF 32 7E          2~
                    clr       0,S                 * 3701 6F E4          od
                    clr       $01,S               * 3703 6F 61          oa
                    bra       L3735               * 3705 20 2E           .
L3707               puls      D                   * 3707 35 06          5.
                    std       0,S                 * 3709 ED E4          md
                    ldd       #45                 * 370B CC 00 2D       L.-
                    lbra      send                * 370E 16 00 99       ...
L3711               subd      #0                  * 3711 83 00 00       ...
                    beq       L3707               * 3714 27 F1          'q
                    pshs      D                   * 3716 34 06          4.
                    leas      -$02,S              * 3718 32 7E          2~
                    clr       0,S                 * 371A 6F E4          od
                    clr       $01,S               * 371C 6F 61          oa
                    tsta                          * 371E 4D             M
                    bpl       L3729               * 371F 2A 08          *.
                    nega                          * 3721 40             @
                    negb                          * 3722 50             P
                    sbca      #0                  * 3723 82 00          ..
                    inc       $01,S               * 3725 6C 61          la
                    std       $02,S               * 3727 ED 62          mb
L3729               ldd       $06,S               * 3729 EC 66          lf
                    bpl       L3735               * 372B 2A 08          *.
                    nega                          * 372D 40             @
                    negb                          * 372E 50             P
                    sbca      #0                  * 372F 82 00          ..
                    com       $01,S               * 3731 63 61          ca
                    std       $06,S               * 3733 ED 66          mf
L3735               lda       #1                  * 3735 86 01          ..
L3737               inca                          * 3737 4C             L
                    asl       $03,S               * 3738 68 63          hc
                    rol       $02,S               * 373A 69 62          ib
                    bpl       L3737               * 373C 2A F9          *y
                    sta       0,S                 * 373E A7 E4          'd
                    ldd       $06,S               * 3740 EC 66          lf
                    clr       $06,S               * 3742 6F 66          of
                    clr       $07,S               * 3744 6F 67          og
L3746               subd      $02,S               * 3746 A3 62          #b
                    bcc       L3750               * 3748 24 06          $.
                    addd      $02,S               * 374A E3 62          cb
                    andcc     #254                * 374C 1C FE          .~
                    bra       L3752               * 374E 20 02           .
L3750               orcc      #1                  * 3750 1A 01          ..
L3752               rol       $07,S               * 3752 69 67          ig
                    rol       $06,S               * 3754 69 66          if
                    lsr       $02,S               * 3756 64 62          db
                    ror       $03,S               * 3758 66 63          fc
                    dec       0,S                 * 375A 6A E4          jd
                    bne       L3746               * 375C 26 E8          &h
                    std       $02,S               * 375E ED 62          mb
                    tst       $01,S               * 3760 6D 61          ma
                    beq       L376C               * 3762 27 08          '.
                    ldd       $06,S               * 3764 EC 66          lf
                    nega                          * 3766 40             @
                    negb                          * 3767 50             P
                    sbca      #0                  * 3768 82 00          ..
                    std       $06,S               * 376A ED 66          mf
L376C               ldx       $04,S               * 376C AE 64          .d
                    ldd       $06,S               * 376E EC 66          lf
                    std       $04,S               * 3770 ED 64          md
                    stx       $06,S               * 3772 AF 66          /f
                    ldx       $02,S               * 3774 AE 62          .b
                    ldd       $04,S               * 3776 EC 64          ld
                    leas      $06,S               * 3778 32 66          2f
                    rts                           * 377A 39             9
                    tstb                          * 377B 5D             ]
                    beq       L3791               * 377C 27 13          '.
L377E               asr       $02,S               * 377E 67 62          gb
                    ror       $03,S               * 3780 66 63          fc
                    decb                          * 3782 5A             Z
                    bne       L377E               * 3783 26 F9          &y
                    bra       L3791               * 3785 20 0A           .
L3787               tstb                          * 3787 5D             ]
                    beq       L3791               * 3788 27 07          '.
L378A               lsr       $02,S               * 378A 64 62          db
                    ror       $03,S               * 378C 66 63          fc
                    decb                          * 378E 5A             Z
                    bne       L378A               * 378F 26 F9          &y
L3791               ldd       $02,S               * 3791 EC 62          lb
                    pshs      D                   * 3793 34 06          4.
                    ldd       $02,S               * 3795 EC 62          lb
                    std       $04,S               * 3797 ED 64          md
                    ldd       0,S                 * 3799 EC E4          ld
                    leas      $04,S               * 379B 32 64          2d
                    rts                           * 379D 39             9
                    tstb                          * 379E 5D             ]
                    beq       L3791               * 379F 27 F0          'p
L37A1               asl       $03,S               * 37A1 68 63          hc
                    rol       $02,S               * 37A3 69 62          ib
                    decb                          * 37A5 5A             Z
                    bne       L37A1               * 37A6 26 F9          &y
                    bra       L3791               * 37A8 20 E7           g
send                std       >U01DB,Y            * 37AA ED A9 01 DB    m).[
                    pshs      Y,B                 * 37AE 34 24          4$
                    os9       F$ID                * 37B0 10 3F 0C       .?.
                    puls      Y,B                 * 37B3 35 24          5$
                    os9       F$Send              * 37B5 10 3F 08       .?.
                    rts                           * 37B8 39             9
L37B9               lda       $05,S               * 37B9 A6 65          &e
                    ldb       $03,S               * 37BB E6 63          fc
                    beq       L37EC               * 37BD 27 2D          '-
                    cmpb      #1                  * 37BF C1 01          A.
                    beq       L37EE               * 37C1 27 2B          '+
                    cmpb      #6                  * 37C3 C1 06          A.
                    beq       L37EE               * 37C5 27 27          ''
                    cmpb      #2                  * 37C7 C1 02          A.
                    beq       L37D4               * 37C9 27 09          '.
                    cmpb      #5                  * 37CB C1 05          A.
                    beq       L37D4               * 37CD 27 05          '.
                    ldb       #208                * 37CF C6 D0          FP
                    lbra      L3A1B               * 37D1 16 02 47       ..G
L37D4               pshs      U                   * 37D4 34 40          4@
                    os9       I$GetStt            * 37D6 10 3F 8D       .?.
                    bcc       L37E0               * 37D9 24 05          $.
                    puls      U                   * 37DB 35 40          5@
                    lbra      L3A1B               * 37DD 16 02 3B       ..;
L37E0               stx       [<$08,S]            * 37E0 AF F8 08       /x.
                    ldx       $08,S               * 37E3 AE 68          .h
                    stu       $02,X               * 37E5 EF 02          o.
                    puls      U                   * 37E7 35 40          5@
                    clra                          * 37E9 4F             O
                    clrb                          * 37EA 5F             _
                    rts                           * 37EB 39             9
L37EC               ldx       $06,S               * 37EC AE 66          .f
L37EE               os9       I$GetStt            * 37EE 10 3F 8D       .?.
                    lbra      L3A24               * 37F1 16 02 30       ..0
L37F4               lda       $05,S               * 37F4 A6 65          &e
                    ldb       $03,S               * 37F6 E6 63          fc
                    beq       L3803               * 37F8 27 09          '.
                    cmpb      #2                  * 37FA C1 02          A.
                    beq       L380B               * 37FC 27 0D          '.
                    ldb       #208                * 37FE C6 D0          FP
                    lbra      L3A1B               * 3800 16 02 18       ...
L3803               ldx       $06,S               * 3803 AE 66          .f
                    os9       I$SetStt            * 3805 10 3F 8E       .?.
                    lbra      L3A24               * 3808 16 02 19       ...
L380B               pshs      U                   * 380B 34 40          4@
                    ldx       $08,S               * 380D AE 68          .h
                    ldu       $0A,S               * 380F EE 6A          nj
                    os9       I$SetStt            * 3811 10 3F 8E       .?.
                    puls      U                   * 3814 35 40          5@
                    lbra      L3A24               * 3816 16 02 0B       ...
                    ldx       $02,S               * 3819 AE 62          .b
                    lda       $05,S               * 381B A6 65          &e
                    os9       I$Open              * 381D 10 3F 84       .?.
                    bcs       L3825               * 3820 25 03          %.
                    os9       I$Close             * 3822 10 3F 8F       .?.
L3825               lbra      L3A24               * 3825 16 01 FC       ..|
open                ldx       $02,S               * 3828 AE 62          .b
                    lda       $05,S               * 382A A6 65          &e
                    os9       I$Open              * 382C 10 3F 84       .?.
                    lbcs      L3A1B               * 382F 10 25 01 E8    .%.h
                    tfr       A,B                 * 3833 1F 89          ..
                    clra                          * 3835 4F             O
                    rts                           * 3836 39             9
close               lda       $03,S               * 3837 A6 63          &c
                    os9       I$Close             * 3839 10 3F 8F       .?.
                    lbra      L3A24               * 383C 16 01 E5       ..e
                    ldx       $02,S               * 383F AE 62          .b
                    ldb       $05,S               * 3841 E6 65          fe
                    os9       I$MakDir            * 3843 10 3F 85       .?.
                    lbra      L3A24               * 3846 16 01 DB       ..[
creat               ldx       $02,S               * 3849 AE 62          .b
                    lda       $05,S               * 384B A6 65          &e
                    tfr       A,B                 * 384D 1F 89          ..
                    andb      #36                 * 384F C4 24          D$
                    orb       #11                 * 3851 CA 0B          J.
                    os9       I$Create            * 3853 10 3F 83       .?.
                    bcs       L385C               * 3856 25 04          %.
L3858               tfr       A,B                 * 3858 1F 89          ..
                    clra                          * 385A 4F             O
                    rts                           * 385B 39             9
L385C               cmpb      #218                * 385C C1 DA          AZ
                    lbne      L3A1B               * 385E 10 26 01 B9    .&.9
                    lda       $05,S               * 3862 A6 65          &e
                    bita      #128                * 3864 85 80          ..
                    lbne      L3A1B               * 3866 10 26 01 B1    .&.1
                    anda      #7                  * 386A 84 07          ..
                    ldx       $02,S               * 386C AE 62          .b
                    os9       I$Open              * 386E 10 3F 84       .?.
                    lbcs      L3A1B               * 3871 10 25 01 A6    .%.&
                    pshs      U,A                 * 3875 34 42          4B
                    ldx       #0                  * 3877 8E 00 00       ...
                    leau      0,X                 * 387A 33 84          3.
                    ldb       #2                  * 387C C6 02          F.
                    os9       I$SetStt            * 387E 10 3F 8E       .?.
                    puls      U,A                 * 3881 35 42          5B
                    bcc       L3858               * 3883 24 D3          $S
                    pshs      B                   * 3885 34 04          4.
                    os9       I$Close             * 3887 10 3F 8F       .?.
                    puls      B                   * 388A 35 04          5.
                    lbra      L3A1B               * 388C 16 01 8C       ...
                    ldx       $02,S               * 388F AE 62          .b
                    os9       I$Delete            * 3891 10 3F 87       .?.
                    lbra      L3A24               * 3894 16 01 8D       ...
                    lda       $03,S               * 3897 A6 63          &c
                    os9       I$Dup               * 3899 10 3F 82       .?.
                    lbcs      L3A1B               * 389C 10 25 01 7B    .%.{
                    tfr       A,B                 * 38A0 1F 89          ..
                    clra                          * 38A2 4F             O
                    rts                           * 38A3 39             9
read                pshs      Y                   * 38A4 34 20          4
                    ldx       $06,S               * 38A6 AE 66          .f
                    lda       $05,S               * 38A8 A6 65          &e
                    ldy       $08,S               * 38AA 10 AE 68       ..h
                    pshs      Y                   * 38AD 34 20          4
                    os9       I$Read              * 38AF 10 3F 89       .?.
L38B2               bcc       L38C1               * 38B2 24 0D          $.
                    cmpb      #211                * 38B4 C1 D3          AS
                    bne       L38BC               * 38B6 26 04          &.
                    clra                          * 38B8 4F             O
                    clrb                          * 38B9 5F             _
                    puls      PC,Y,X              * 38BA 35 B0          50
L38BC               puls      Y,X                 * 38BC 35 30          50
                    lbra      L3A1B               * 38BE 16 01 5A       ..Z
L38C1               tfr       Y,D                 * 38C1 1F 20          .
                    puls      PC,Y,X              * 38C3 35 B0          50
readln              pshs      Y                   * 38C5 34 20          4
                    lda       $05,S               * 38C7 A6 65          &e
                    ldx       $06,S               * 38C9 AE 66          .f
                    ldy       $08,S               * 38CB 10 AE 68       ..h
                    pshs      Y                   * 38CE 34 20          4
                    os9       I$ReadLn            * 38D0 10 3F 8B       .?.
                    bra       L38B2               * 38D3 20 DD           ]
write               pshs      Y                   * 38D5 34 20          4
                    ldy       $08,S               * 38D7 10 AE 68       ..h
                    beq       L38EA               * 38DA 27 0E          '.
                    lda       $05,S               * 38DC A6 65          &e
                    ldx       $06,S               * 38DE AE 66          .f
                    os9       I$Write             * 38E0 10 3F 8A       .?.
L38E3               bcc       L38EA               * 38E3 24 05          $.
                    puls      Y                   * 38E5 35 20          5
                    lbra      L3A1B               * 38E7 16 01 31       ..1
L38EA               tfr       Y,D                 * 38EA 1F 20          .
                    puls      PC,Y                * 38EC 35 A0          5
writln              pshs      Y                   * 38EE 34 20          4
                    ldy       $08,S               * 38F0 10 AE 68       ..h
                    beq       L38EA               * 38F3 27 F5          'u
                    lda       $05,S               * 38F5 A6 65          &e
                    ldx       $06,S               * 38F7 AE 66          .f
                    os9       I$WritLn            * 38F9 10 3F 8C       .?.
                    bra       L38E3               * 38FC 20 E5           e
L38FE               pshs      U                   * 38FE 34 40          4@
                    ldd       $0A,S               * 3900 EC 6A          lj
                    bne       L390C               * 3902 26 08          &.
                    ldu       #0                  * 3904 CE 00 00       N..
                    ldx       #0                  * 3907 8E 00 00       ...
                    bra       L3940               * 390A 20 34           4
L390C               cmpd      #1                  * 390C 10 83 00 01    ....
                    beq       L3937               * 3910 27 25          '%
                    cmpd      #2                  * 3912 10 83 00 02    ....
                    beq       getstat             * 3916 27 14          '.
                    ldb       #247                * 3918 C6 F7          Fw
L391A               clra                          * 391A 4F             O
                    std       >U01DB,Y            * 391B ED A9 01 DB    m).[
                    ldd       #-1                 * 391F CC FF FF       L..
                    leax      >U01CF,Y            * 3922 30 A9 01 CF    0).O
                    std       0,X                 * 3926 ED 84          m.
                    std       $02,X               * 3928 ED 02          m.
                    puls      PC,U                * 392A 35 C0          5@
getstat             lda       $05,S               * 392C A6 65          &e
                    ldb       #2                  * 392E C6 02          F.
                    os9       I$GetStt            * 3930 10 3F 8D       .?.
                    bcs       L391A               * 3933 25 E5          %e
                    bra       L3940               * 3935 20 09           .
L3937               lda       $05,S               * 3937 A6 65          &e
                    ldb       #5                  * 3939 C6 05          F.
                    os9       I$GetStt            * 393B 10 3F 8D       .?.
                    bcs       L391A               * 393E 25 DA          %Z
L3940               tfr       U,D                 * 3940 1F 30          .0
                    addd      $08,S               * 3942 E3 68          ch
                    std       >U01D1,Y            * 3944 ED A9 01 D1    m).Q
                    tfr       D,U                 * 3948 1F 03          ..
                    tfr       X,D                 * 394A 1F 10          ..
                    adcb      $07,S               * 394C E9 67          ig
                    adca      $06,S               * 394E A9 66          )f
                    bmi       L391A               * 3950 2B C8          +H
                    tfr       D,X                 * 3952 1F 01          ..
                    std       >U01CF,Y            * 3954 ED A9 01 CF    m).O
                    lda       $05,S               * 3958 A6 65          &e
                    os9       I$Seek              * 395A 10 3F 88       .?.
                    bcs       L391A               * 395D 25 BB          %;
                    leax      >U01CF,Y            * 395F 30 A9 01 CF    0).O
                    puls      PC,U                * 3963 35 C0          5@
                    rts                           * 3965 39             9
                    ldx       #0                  * 3966 8E 00 00       ...
                    clrb                          * 3969 5F             _
                    os9       F$Sleep             * 396A 10 3F 0A       .?.
                    lbra      L3A1B               * 396D 16 00 AB       ..+
                    rts                           * 3970 39             9
                    pshs      U,Y                 * 3971 34 60          4`
                    ldx       $06,S               * 3973 AE 66          .f
                    ldy       $08,S               * 3975 10 AE 68       ..h
                    ldu       $0A,S               * 3978 EE 6A          nj
                    os9       F$CRC               * 397A 10 3F 17       .?.
                    puls      PC,U,Y              * 397D 35 E0          5`
                    lda       $03,S               * 397F A6 63          &c
                    ldb       $05,S               * 3981 E6 65          fe
                    os9       F$PErr              * 3983 10 3F 0F       .?.
                    lbcs      L3A1B               * 3986 10 25 00 91    .%..
                    rts                           * 398A 39             9
sleep               ldx       $02,S               * 398B AE 62          .b
                    os9       F$Sleep             * 398D 10 3F 0A       .?.
                    lbcs      L3A1B               * 3990 10 25 00 87    .%..
                    tfr       X,D                 * 3994 1F 10          ..
                    rts                           * 3996 39             9
                    ldd       >memend,Y           * 3997 EC A9 01 CD    l).M
                    pshs      D                   * 399B 34 06          4.
                    ldd       $04,S               * 399D EC 64          ld
                    cmpd      >U37D2,Y            * 399F 10 A3 A9 37 D2 .#)7R
                    bcs       L39CB               * 39A4 25 25          %%
                    addd      >memend,Y           * 39A6 E3 A9 01 CD    c).M
                    pshs      Y                   * 39AA 34 20          4
                    subd      0,S                 * 39AC A3 E4          #d
                    os9       F$Mem               * 39AE 10 3F 07       .?.
                    tfr       Y,D                 * 39B1 1F 20          .
                    puls      Y                   * 39B3 35 20          5
                    bcc       L39BD               * 39B5 24 06          $.
                    ldd       #-1                 * 39B7 CC FF FF       L..
                    leas      $02,S               * 39BA 32 62          2b
                    rts                           * 39BC 39             9
L39BD               std       >memend,Y           * 39BD ED A9 01 CD    m).M
                    addd      >U37D2,Y            * 39C1 E3 A9 37 D2    c)7R
                    subd      0,S                 * 39C5 A3 E4          #d
                    std       >U37D2,Y            * 39C7 ED A9 37 D2    m)7R
L39CB               leas      $02,S               * 39CB 32 62          2b
                    ldd       >U37D2,Y            * 39CD EC A9 37 D2    l)7R
                    pshs      D                   * 39D1 34 06          4.
                    subd      $04,S               * 39D3 A3 64          #d
                    std       >U37D2,Y            * 39D5 ED A9 37 D2    m)7R
                    ldd       >memend,Y           * 39D9 EC A9 01 CD    l).M
                    subd      ,S++                * 39DD A3 E1          #a
                    pshs      D                   * 39DF 34 06          4.
                    clra                          * 39E1 4F             O
                    ldx       0,S                 * 39E2 AE E4          .d
L39E4               sta       ,X+                 * 39E4 A7 80          '.
                    cmpx      >memend,Y           * 39E6 AC A9 01 CD    ,).M
                    bcs       L39E4               * 39EA 25 F8          %x
                    puls      PC,D                * 39EC 35 86          5.
L39EE               ldd       $02,S               * 39EE EC 62          lb
                    addd      >_mtop,Y            * 39F0 E3 A9 01 D7    c).W
                    bcs       L3A17               * 39F4 25 21          %!
                    cmpd      >_stbot,Y           * 39F6 10 A3 A9 01 D9 .#).Y
                    bcc       L3A17               * 39FB 24 1A          $.
                    pshs      D                   * 39FD 34 06          4.
                    ldx       >_mtop,Y            * 39FF AE A9 01 D7    .).W
                    clra                          * 3A03 4F             O
L3A04               cmpx      0,S                 * 3A04 AC E4          ,d
                    bcc       L3A0C               * 3A06 24 04          $.
                    sta       ,X+                 * 3A08 A7 80          '.
                    bra       L3A04               * 3A0A 20 F8           x
L3A0C               ldd       >_mtop,Y            * 3A0C EC A9 01 D7    l).W
                    puls      X                   * 3A10 35 10          5.
                    stx       >_mtop,Y            * 3A12 AF A9 01 D7    /).W
                    rts                           * 3A16 39             9
L3A17               ldd       #-1                 * 3A17 CC FF FF       L..
                    rts                           * 3A1A 39             9
L3A1B               clra                          * 3A1B 4F             O
                    std       >U01DB,Y            * 3A1C ED A9 01 DB    m).[
                    ldd       #-1                 * 3A20 CC FF FF       L..
                    rts                           * 3A23 39             9
L3A24               bcs       L3A1B               * 3A24 25 F5          %u
                    clra                          * 3A26 4F             O
                    clrb                          * 3A27 5F             _
                    rts                           * 3A28 39             9
exit                lbsr      L3A34               * 3A29 17 00 08       ...
                    lbsr      L3319               * 3A2C 17 F8 EA       .xj
_exit               ldd       $02,S               * 3A2F EC 62          lb
                    os9       F$Exit              * 3A31 10 3F 06       .?.
L3A34               rts                           * 3A34 39             9
L3A35               lda       $03,S               * 3A35 A6 63          &c
                    ldb       #1                  * 3A37 C6 01          F.
                    os9       I$GetStt            * 3A39 10 3F 8D       .?.
                    lbcs      L3A1B               * 3A3C 10 25 FF DB    .%.[
                    clra                          * 3A40 4F             O
                    rts                           * 3A41 39             9
                    ldd       #6944               * 3A42 CC 1B 20       L.
                    bsr       L3A5B               * 3A45 8D 14          ..
                    ldb       #9                  * 3A47 C6 09          F.
                    tst       $05,S               * 3A49 6D 65          me
                    ble       L3A4F               * 3A4B 2F 02          /.
                    ldb       #10                 * 3A4D C6 0A          F.
L3A4F               lbra      L3B43               * 3A4F 16 00 F1       ..q
L3A52               ldd       #6946               * 3A52 CC 1B 22       L."
                    bsr       L3A5B               * 3A55 8D 04          ..
                    ldb       #9                  * 3A57 C6 09          F.
                    bra       L3A4F               * 3A59 20 F4           t
L3A5B               leax      >U37D4,Y            * 3A5B 30 A9 37 D4    0)7T
                    std       ,X++                * 3A5F ED 81          m.
                    lda       $07,S               * 3A61 A6 67          &g
                    ldb       $09,S               * 3A63 E6 69          fi
                    std       ,X++                * 3A65 ED 81          m.
                    lda       $0B,S               * 3A67 A6 6B          &k
                    ldb       $0D,S               * 3A69 E6 6D          fm
                    std       ,X++                * 3A6B ED 81          m.
                    lda       $0F,S               * 3A6D A6 6F          &o
                    ldb       <$0011,S            * 3A6F E6 E8 11       fh.
                    std       ,X++                * 3A72 ED 81          m.
                    lda       <$0013,S            * 3A74 A6 E8 13       &h.
                    ldb       <$0015,S            * 3A77 E6 E8 15       fh.
                    std       0,X                 * 3A7A ED 84          m.
                    rts                           * 3A7C 39             9
                    ldd       #6948               * 3A7D CC 1B 24       L.$
                    bra       L3A8A               * 3A80 20 08           .
L3A82               ldd       #6947               * 3A82 CC 1B 23       L.#
                    bra       L3A8A               * 3A85 20 03           .
                    ldd       #6945               * 3A87 CC 1B 21       L.!
L3A8A               std       >U37D4,Y            * 3A8A ED A9 37 D4    m)7T
                    ldb       #2                  * 3A8E C6 02          F.
                    lbra      L3B43               * 3A90 16 00 B0       ..0
                    ldd       #6960               * 3A93 CC 1B 30       L.0
                    std       >U37D4,Y            * 3A96 ED A9 37 D4    m)7T
                    ldb       #2                  * 3A9A C6 02          F.
                    lbra      L3B43               * 3A9C 16 00 A4       ..$
L3A9F               ldb       #50                 * 3A9F C6 32          F2
                    bra       L3AAD               * 3AA1 20 0A           .
L3AA3               ldb       #51                 * 3AA3 C6 33          F3
                    bra       L3AAD               * 3AA5 20 06           .
                    ldb       #52                 * 3AA7 C6 34          F4
                    bra       L3AAD               * 3AA9 20 02           .
                    ldb       #47                 * 3AAB C6 2F          F/
L3AAD               lda       #27                 * 3AAD 86 1B          ..
                    std       >U37D4,Y            * 3AAF ED A9 37 D4    m)7T
                    ldb       $05,S               * 3AB3 E6 65          fe
                    stb       >U37D6,Y            * 3AB5 E7 A9 37 D6    g)7V
                    ldb       #3                  * 3AB9 C6 03          F.
                    lbra      L3B43               * 3ABB 16 00 85       ...
                    ldb       #1                  * 3ABE C6 01          F.
                    bra       L3AF2               * 3AC0 20 30           0
                    ldb       #3                  * 3AC2 C6 03          F.
                    bra       L3AF2               * 3AC4 20 2C           ,
L3AC6               ldb       #4                  * 3AC6 C6 04          F.
                    bra       L3AF2               * 3AC8 20 28           (
L3ACA               ldd       #1312               * 3ACA CC 05 20       L.
                    bra       L3B21               * 3ACD 20 52           R
L3ACF               ldd       #1313               * 3ACF CC 05 21       L.!
                    bra       L3B21               * 3AD2 20 4D           M
L3AD4               ldb       #6                  * 3AD4 C6 06          F.
                    bra       L3AF2               * 3AD6 20 1A           .
L3AD8               ldb       #7                  * 3AD8 C6 07          F.
                    bra       L3AF2               * 3ADA 20 16           .
L3ADC               ldb       #8                  * 3ADC C6 08          F.
                    bra       L3AF2               * 3ADE 20 12           .
L3AE0               ldb       #9                  * 3AE0 C6 09          F.
                    bra       L3AF2               * 3AE2 20 0E           .
L3AE4               ldb       #10                 * 3AE4 C6 0A          F.
                    bra       L3AF2               * 3AE6 20 0A           .
                    ldb       #11                 * 3AE8 C6 0B          F.
                    bra       L3AF2               * 3AEA 20 06           .
L3AEC               ldb       #12                 * 3AEC C6 0C          F.
                    bra       L3AF2               * 3AEE 20 02           .
                    ldb       #13                 * 3AF0 C6 0D          F.
L3AF2               stb       >U37D4,Y            * 3AF2 E7 A9 37 D4    g)7T
                    ldb       #1                  * 3AF6 C6 01          F.
                    lbra      L3B43               * 3AF8 16 00 48       ..H
L3AFB               ldd       #7968               * 3AFB CC 1F 20       L.
                    bra       L3B21               * 3AFE 20 21           !
L3B00               ldd       #7969               * 3B00 CC 1F 21       L.!
                    bra       L3B21               * 3B03 20 1C           .
L3B05               ldd       #7970               * 3B05 CC 1F 22       L."
                    bra       L3B21               * 3B08 20 17           .
L3B0A               ldd       #7971               * 3B0A CC 1F 23       L.#
                    bra       L3B21               * 3B0D 20 12           .
L3B0F               ldd       #7972               * 3B0F CC 1F 24       L.$
                    bra       L3B21               * 3B12 20 0D           .
L3B14               ldd       #7973               * 3B14 CC 1F 25       L.%
                    bra       L3B21               * 3B17 20 08           .
                    ldd       #7984               * 3B19 CC 1F 30       L.0
                    bra       L3B21               * 3B1C 20 03           .
                    ldd       #7985               * 3B1E CC 1F 31       L.1
L3B21               std       >U37D4,Y            * 3B21 ED A9 37 D4    m)7T
                    ldb       #2                  * 3B25 C6 02          F.
                    lbra      L3B43               * 3B27 16 00 19       ...
L3B2A               leax      >U37D4,Y            * 3B2A 30 A9 37 D4    0)7T
                    ldb       #2                  * 3B2E C6 02          F.
                    stb       ,X+                 * 3B30 E7 80          g.
                    ldd       $04,S               * 3B32 EC 64          ld
                    addb      #32                 * 3B34 CB 20          K
                    stb       ,X+                 * 3B36 E7 80          g.
                    ldd       $06,S               * 3B38 EC 66          lf
                    addb      #32                 * 3B3A CB 20          K
                    stb       ,X+                 * 3B3C E7 80          g.
                    ldb       #3                  * 3B3E C6 03          F.
                    lbra      L3B43               * 3B40 16 00 00       ...
L3B43               clra                          * 3B43 4F             O
                    leax      >U37D4,Y            * 3B44 30 A9 37 D4    0)7T
                    pshs      Y                   * 3B48 34 20          4
                    tfr       D,Y                 * 3B4A 1F 02          ..
                    lda       $05,S               * 3B4C A6 65          &e
                    os9       I$Write             * 3B4E 10 3F 8A       .?.
                    puls      Y                   * 3B51 35 20          5
                    bcs       L3B58               * 3B53 25 03          %.
                    clra                          * 3B55 4F             O
                    clrb                          * 3B56 5F             _
                    rts                           * 3B57 39             9
L3B58               clra                          * 3B58 4F             O
                    std       >U01DB,Y            * 3B59 ED A9 01 DB    m).[
                    ldd       #-1                 * 3B5D CC FF FF       L..
                    rts                           * 3B60 39             9

* initialization data

etext               fcb       $00                 * 3B61 00             .
                    fcb       $01                 * 3B62 01             .
                    fcb       $00                 * 3B63 00             .
                    fcb       $01                 * 3B64 01             .
                    fcb       $8C                 * 3B65 8C             .
                    fcb       $00                 * 3B66 00             .
                    fcb       $00                 * 3B67 00             .
                    fcb       $00                 * 3B68 00             .
                    fcb       $00                 * 3B69 00             .
                    fcb       $00                 * 3B6A 00             .
                    fcb       $00                 * 3B6B 00             .
                    fcb       $00                 * 3B6C 00             .
                    fcb       $00                 * 3B6D 00             .
                    fcb       $00                 * 3B6E 00             .
                    fcb       $00                 * 3B6F 00             .
                    fcb       $00                 * 3B70 00             .
                    fcb       $00                 * 3B71 00             .
                    fcb       $00                 * 3B72 00             .
                    fcb       $00                 * 3B73 00             .
                    fcb       $00                 * 3B74 00             .
                    fcb       $02                 * 3B75 02             .
                    fcb       $00                 * 3B76 00             .
                    fcb       $04                 * 3B77 04             .
                    fcb       $00                 * 3B78 00             .
                    fcb       $03                 * 3B79 03             .
                    fcb       $00                 * 3B7A 00             .
                    fcb       $05                 * 3B7B 05             .
                    fcb       $00                 * 3B7C 00             .
                    fcb       $01                 * 3B7D 01             .
                    fcb       $00                 * 3B7E 00             .
                    fcb       $06                 * 3B7F 06             .
                    fcb       $00                 * 3B80 00             .
                    fcb       $07                 * 3B81 07             .
                    fcb       $00                 * 3B82 00             .
                    fcb       $00                 * 3B83 00             .
                    fcc       "&?&E&I&O&V&[&c&h'" * 3B84 26 3F 26 45 26 49 26 4F 26 56 26 5B 26 63 26 68 27 &?&E&I&O&V&[&c&h'
                    fcb       $10                 * 3B95 10             .
                    fcb       $03                 * 3B96 03             .
                    fcb       $E8                 * 3B97 E8             h
                    fcb       $00                 * 3B98 00             .
                    fcb       $64                 * 3B99 64             d
                    fcb       $00                 * 3B9A 00             .
                    fcb       $0A                 * 3B9B 0A             .
                    fcb       $00                 * 3B9C 00             .
                    fcc       "7lx"               * 3B9D 37 6C 78       7lx
                    fcb       $00                 * 3BA0 00             .
                    fcb       $00                 * 3BA1 00             .
                    fcb       $00                 * 3BA2 00             .
                    fcb       $00                 * 3BA3 00             .
                    fcb       $00                 * 3BA4 00             .
                    fcb       $00                 * 3BA5 00             .
                    fcb       $00                 * 3BA6 00             .
                    fcb       $00                 * 3BA7 00             .
                    fcb       $01                 * 3BA8 01             .
                    fcb       $00                 * 3BA9 00             .
                    fcb       $00                 * 3BAA 00             .
                    fcb       $00                 * 3BAB 00             .
                    fcb       $00                 * 3BAC 00             .
                    fcb       $00                 * 3BAD 00             .
                    fcb       $00                 * 3BAE 00             .
                    fcb       $00                 * 3BAF 00             .
                    fcb       $00                 * 3BB0 00             .
                    fcb       $00                 * 3BB1 00             .
                    fcb       $00                 * 3BB2 00             .
                    fcb       $00                 * 3BB3 00             .
                    fcb       $00                 * 3BB4 00             .
                    fcb       $02                 * 3BB5 02             .
                    fcb       $00                 * 3BB6 00             .
                    fcb       $01                 * 3BB7 01             .
                    fcb       $00                 * 3BB8 00             .
                    fcb       $00                 * 3BB9 00             .
                    fcb       $00                 * 3BBA 00             .
                    fcb       $00                 * 3BBB 00             .
                    fcb       $00                 * 3BBC 00             .
                    fcb       $00                 * 3BBD 00             .
                    fcb       $00                 * 3BBE 00             .
                    fcb       $00                 * 3BBF 00             .
                    fcb       $00                 * 3BC0 00             .
                    fcb       $00                 * 3BC1 00             .
                    fcb       $42                 * 3BC2 42             B
                    fcb       $00                 * 3BC3 00             .
                    fcb       $02                 * 3BC4 02             .
                    fcb       $00                 * 3BC5 00             .
                    fcb       $00                 * 3BC6 00             .
                    fcb       $00                 * 3BC7 00             .
                    fcb       $00                 * 3BC8 00             .
                    fcb       $00                 * 3BC9 00             .
                    fcb       $00                 * 3BCA 00             .
                    fcb       $00                 * 3BCB 00             .
                    fcb       $00                 * 3BCC 00             .
                    fcb       $00                 * 3BCD 00             .
                    fcb       $00                 * 3BCE 00             .
                    fcb       $00                 * 3BCF 00             .
                    fcb       $00                 * 3BD0 00             .
                    fcb       $00                 * 3BD1 00             .
                    fcb       $00                 * 3BD2 00             .
                    fcb       $00                 * 3BD3 00             .
                    fcb       $00                 * 3BD4 00             .
                    fcb       $00                 * 3BD5 00             .
                    fcb       $00                 * 3BD6 00             .
                    fcb       $00                 * 3BD7 00             .
                    fcb       $00                 * 3BD8 00             .
                    fcb       $00                 * 3BD9 00             .
                    fcb       $00                 * 3BDA 00             .
                    fcb       $00                 * 3BDB 00             .
                    fcb       $00                 * 3BDC 00             .
                    fcb       $00                 * 3BDD 00             .
                    fcb       $00                 * 3BDE 00             .
                    fcb       $00                 * 3BDF 00             .
                    fcb       $00                 * 3BE0 00             .
                    fcb       $00                 * 3BE1 00             .
                    fcb       $00                 * 3BE2 00             .
                    fcb       $00                 * 3BE3 00             .
                    fcb       $00                 * 3BE4 00             .
                    fcb       $00                 * 3BE5 00             .
                    fcb       $00                 * 3BE6 00             .
                    fcb       $00                 * 3BE7 00             .
                    fcb       $00                 * 3BE8 00             .
                    fcb       $00                 * 3BE9 00             .
                    fcb       $00                 * 3BEA 00             .
                    fcb       $00                 * 3BEB 00             .
                    fcb       $00                 * 3BEC 00             .
                    fcb       $00                 * 3BED 00             .
                    fcb       $00                 * 3BEE 00             .
                    fcb       $00                 * 3BEF 00             .
                    fcb       $00                 * 3BF0 00             .
                    fcb       $00                 * 3BF1 00             .
                    fcb       $00                 * 3BF2 00             .
                    fcb       $00                 * 3BF3 00             .
                    fcb       $00                 * 3BF4 00             .
                    fcb       $00                 * 3BF5 00             .
                    fcb       $00                 * 3BF6 00             .
                    fcb       $00                 * 3BF7 00             .
                    fcb       $00                 * 3BF8 00             .
                    fcb       $00                 * 3BF9 00             .
                    fcb       $00                 * 3BFA 00             .
                    fcb       $00                 * 3BFB 00             .
                    fcb       $00                 * 3BFC 00             .
                    fcb       $00                 * 3BFD 00             .
                    fcb       $00                 * 3BFE 00             .
                    fcb       $00                 * 3BFF 00             .
                    fcb       $00                 * 3C00 00             .
                    fcb       $00                 * 3C01 00             .
                    fcb       $00                 * 3C02 00             .
                    fcb       $00                 * 3C03 00             .
                    fcb       $00                 * 3C04 00             .
                    fcb       $00                 * 3C05 00             .
                    fcb       $00                 * 3C06 00             .
                    fcb       $00                 * 3C07 00             .
                    fcb       $00                 * 3C08 00             .
                    fcb       $00                 * 3C09 00             .
                    fcb       $00                 * 3C0A 00             .
                    fcb       $00                 * 3C0B 00             .
                    fcb       $00                 * 3C0C 00             .
                    fcb       $00                 * 3C0D 00             .
                    fcb       $00                 * 3C0E 00             .
                    fcb       $00                 * 3C0F 00             .
                    fcb       $00                 * 3C10 00             .
                    fcb       $00                 * 3C11 00             .
                    fcb       $00                 * 3C12 00             .
                    fcb       $00                 * 3C13 00             .
                    fcb       $00                 * 3C14 00             .
                    fcb       $00                 * 3C15 00             .
                    fcb       $00                 * 3C16 00             .
                    fcb       $00                 * 3C17 00             .
                    fcb       $00                 * 3C18 00             .
                    fcb       $00                 * 3C19 00             .
                    fcb       $00                 * 3C1A 00             .
                    fcb       $00                 * 3C1B 00             .
                    fcb       $00                 * 3C1C 00             .
                    fcb       $00                 * 3C1D 00             .
                    fcb       $00                 * 3C1E 00             .
                    fcb       $00                 * 3C1F 00             .
                    fcb       $00                 * 3C20 00             .
                    fcb       $00                 * 3C21 00             .
                    fcb       $00                 * 3C22 00             .
                    fcb       $00                 * 3C23 00             .
                    fcb       $00                 * 3C24 00             .
                    fcb       $00                 * 3C25 00             .
                    fcb       $00                 * 3C26 00             .
                    fcb       $00                 * 3C27 00             .
                    fcb       $00                 * 3C28 00             .
                    fcb       $00                 * 3C29 00             .
                    fcb       $00                 * 3C2A 00             .
                    fcb       $00                 * 3C2B 00             .
                    fcb       $00                 * 3C2C 00             .
                    fcb       $00                 * 3C2D 00             .
                    fcb       $00                 * 3C2E 00             .
                    fcb       $00                 * 3C2F 00             .
                    fcb       $00                 * 3C30 00             .
                    fcb       $00                 * 3C31 00             .
                    fcb       $00                 * 3C32 00             .
                    fcb       $00                 * 3C33 00             .
                    fcb       $00                 * 3C34 00             .
                    fcb       $00                 * 3C35 00             .
                    fcb       $00                 * 3C36 00             .
                    fcb       $00                 * 3C37 00             .
                    fcb       $00                 * 3C38 00             .
                    fcb       $00                 * 3C39 00             .
                    fcb       $00                 * 3C3A 00             .
                    fcb       $00                 * 3C3B 00             .
                    fcb       $00                 * 3C3C 00             .
                    fcb       $00                 * 3C3D 00             .
                    fcb       $00                 * 3C3E 00             .
                    fcb       $00                 * 3C3F 00             .
                    fcb       $00                 * 3C40 00             .
                    fcb       $00                 * 3C41 00             .
                    fcb       $00                 * 3C42 00             .
                    fcb       $00                 * 3C43 00             .
                    fcb       $00                 * 3C44 00             .
                    fcb       $00                 * 3C45 00             .
                    fcb       $00                 * 3C46 00             .
                    fcb       $00                 * 3C47 00             .
                    fcb       $00                 * 3C48 00             .
                    fcb       $00                 * 3C49 00             .
                    fcb       $00                 * 3C4A 00             .
                    fcb       $00                 * 3C4B 00             .
                    fcb       $00                 * 3C4C 00             .
                    fcb       $00                 * 3C4D 00             .
                    fcb       $00                 * 3C4E 00             .
                    fcb       $00                 * 3C4F 00             .
                    fcb       $00                 * 3C50 00             .
                    fcb       $00                 * 3C51 00             .
                    fcb       $00                 * 3C52 00             .
                    fcb       $00                 * 3C53 00             .
                    fcb       $00                 * 3C54 00             .
                    fcb       $00                 * 3C55 00             .
                    fcb       $00                 * 3C56 00             .
                    fcb       $00                 * 3C57 00             .
                    fcb       $00                 * 3C58 00             .
                    fcb       $00                 * 3C59 00             .
                    fcb       $00                 * 3C5A 00             .
                    fcb       $00                 * 3C5B 00             .
                    fcb       $00                 * 3C5C 00             .
                    fcb       $00                 * 3C5D 00             .
                    fcb       $00                 * 3C5E 00             .
                    fcb       $00                 * 3C5F 00             .
                    fcb       $00                 * 3C60 00             .
                    fcb       $00                 * 3C61 00             .
                    fcb       $00                 * 3C62 00             .
                    fcb       $00                 * 3C63 00             .
                    fcb       $00                 * 3C64 00             .
                    fcb       $00                 * 3C65 00             .
                    fcb       $00                 * 3C66 00             .
                    fcb       $00                 * 3C67 00             .
                    fcb       $00                 * 3C68 00             .
                    fcb       $00                 * 3C69 00             .
                    fcb       $00                 * 3C6A 00             .
                    fcb       $00                 * 3C6B 00             .
                    fcb       $00                 * 3C6C 00             .
                    fcb       $00                 * 3C6D 00             .
                    fcb       $00                 * 3C6E 00             .
                    fcb       $00                 * 3C6F 00             .
                    fcb       $00                 * 3C70 00             .
                    fcb       $00                 * 3C71 00             .
                    fcb       $01                 * 3C72 01             .
                    fcb       $01                 * 3C73 01             .
                    fcb       $01                 * 3C74 01             .
                    fcb       $01                 * 3C75 01             .
                    fcb       $01                 * 3C76 01             .
                    fcb       $01                 * 3C77 01             .
                    fcb       $01                 * 3C78 01             .
                    fcb       $01                 * 3C79 01             .
                    fcb       $01                 * 3C7A 01             .
                    fcb       $11                 * 3C7B 11             .
                    fcb       $11                 * 3C7C 11             .
                    fcb       $01                 * 3C7D 01             .
                    fcb       $11                 * 3C7E 11             .
                    fcb       $11                 * 3C7F 11             .
                    fcb       $01                 * 3C80 01             .
                    fcb       $01                 * 3C81 01             .
                    fcb       $01                 * 3C82 01             .
                    fcb       $01                 * 3C83 01             .
                    fcb       $01                 * 3C84 01             .
                    fcb       $01                 * 3C85 01             .
                    fcb       $01                 * 3C86 01             .
                    fcb       $01                 * 3C87 01             .
                    fcb       $01                 * 3C88 01             .
                    fcb       $01                 * 3C89 01             .
                    fcb       $01                 * 3C8A 01             .
                    fcb       $01                 * 3C8B 01             .
                    fcb       $01                 * 3C8C 01             .
                    fcb       $01                 * 3C8D 01             .
                    fcb       $01                 * 3C8E 01             .
                    fcb       $01                 * 3C8F 01             .
                    fcb       $01                 * 3C90 01             .
                    fcb       $01                 * 3C91 01             .
                    fcc       "0               HHHHHHHHHH       BBBBBB" * 3C92 30 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 48 48 48 48 48 48 48 48 48 48 20 20 20 20 20 20 20 42 42 42 42 42 42 0               HHHHHHHHHH       BBBBBB
                    fcb       $02                 * 3CB9 02             .
                    fcb       $02                 * 3CBA 02             .
                    fcb       $02                 * 3CBB 02             .
                    fcb       $02                 * 3CBC 02             .
                    fcb       $02                 * 3CBD 02             .
                    fcb       $02                 * 3CBE 02             .
                    fcb       $02                 * 3CBF 02             .
                    fcb       $02                 * 3CC0 02             .
                    fcb       $02                 * 3CC1 02             .
                    fcb       $02                 * 3CC2 02             .
                    fcb       $02                 * 3CC3 02             .
                    fcb       $02                 * 3CC4 02             .
                    fcb       $02                 * 3CC5 02             .
                    fcb       $02                 * 3CC6 02             .
                    fcb       $02                 * 3CC7 02             .
                    fcb       $02                 * 3CC8 02             .
                    fcb       $02                 * 3CC9 02             .
                    fcb       $02                 * 3CCA 02             .
                    fcb       $02                 * 3CCB 02             .
                    fcb       $02                 * 3CCC 02             .
                    fcc       "      DDDDDD"      * 3CCD 20 20 20 20 20 20 44 44 44 44 44 44       DDDDDD
                    fcb       $04                 * 3CD9 04             .
                    fcb       $04                 * 3CDA 04             .
                    fcb       $04                 * 3CDB 04             .
                    fcb       $04                 * 3CDC 04             .
                    fcb       $04                 * 3CDD 04             .
                    fcb       $04                 * 3CDE 04             .
                    fcb       $04                 * 3CDF 04             .
                    fcb       $04                 * 3CE0 04             .
                    fcb       $04                 * 3CE1 04             .
                    fcb       $04                 * 3CE2 04             .
                    fcb       $04                 * 3CE3 04             .
                    fcb       $04                 * 3CE4 04             .
                    fcb       $04                 * 3CE5 04             .
                    fcb       $04                 * 3CE6 04             .
                    fcb       $04                 * 3CE7 04             .
                    fcb       $04                 * 3CE8 04             .
                    fcb       $04                 * 3CE9 04             .
                    fcb       $04                 * 3CEA 04             .
                    fcb       $04                 * 3CEB 04             .
                    fcb       $04                 * 3CEC 04             .
                    fcc       "    "              * 3CED 20 20 20 20
                    fcb       $01                 * 3CF1 01             .
                    fcb       $00                 * 3CF2 00             .
                    fcb       $08                 * 3CF3 08             .
                    fcb       $00                 * 3CF4 00             .
                    fcb       $1F                 * 3CF5 1F             .
                    fcb       $00                 * 3CF6 00             .
                    fcb       $2D                 * 3CF7 2D             -
                    fcb       $00                 * 3CF8 00             .
                    fcb       $2B                 * 3CF9 2B             +
                    fcb       $00                 * 3CFA 00             .
                    fcb       $29                 * 3CFB 29             )
                    fcb       $00                 * 3CFC 00             .
                    fcb       $27                 * 3CFD 27             '
                    fcb       $00                 * 3CFE 00             .
                    fcb       $25                 * 3CFF 25             %
                    fcb       $00                 * 3D00 00             .
                    fcb       $23                 * 3D01 23             #
                    fcb       $00                 * 3D02 00             .
                    fcb       $21                 * 3D03 21             !
                    fcb       $00                 * 3D04 00             .
                    fcb       $01                 * 3D05 01             .
                    fcb       $00                 * 3D06 00             .
                    fcc       "7AnsiEd"           * 3D07 37 41 6E 73 69 45 64 7AnsiEd
                    fcb       $00                 * 3D0E 00             .

                    emod
eom                 equ       *
                    end
