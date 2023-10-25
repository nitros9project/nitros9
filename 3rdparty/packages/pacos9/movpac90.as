
                    nam       MOVPAC
                    ttl       Move pacman routines

*     Program segment to be compiled using Level II RMA
*           This is not a mainline program segment
*                 Written by Larry Olson

                    ifp1
*         use    /dd/defs/os9defs.a
                    endc


STACK               equ       100


                    section   bss

*    Local variables

                    rmb       STACK

                    endsect

                    section   code

MVPAC               nop

*      Read joystick

JOY                 lda       PATH                Set path to window
                    ldb       #$13                Setup for SS.Joy
                    ldx       PORT,U              Get selected port
                    os9       I$GetStt
                    lbcs      ERR1
                    stx       JOYSTX
                    sty       JOYSTY
                    sta       BUTTON
*    Cycle is used to animate pacman

CYC                 dec       CYCLE               Decrement cycle counter
                    bpl       MVRT                If >0 continue
                    lda       #2                  Reset counter to 2
                    sta       CYCLE

                    clra
                    sta       MOVFLG,U

*    Check direction of joystick & move pacman

MVRT                leay      ARRAY,U             Point to start of array
                    ldd       POFSET              Get pacman offset in array
                    leax      D,Y
*    X reg now points to pacman position in array
                    ldd       JOYSTX              Get joystick X value
                    cmpd      #37                 Is it greater than 37 ?
                    blo       MVLFT               Go to move left

                    inc       MOVFLG,U

                    lda       1,X                 Get adjacent byte from array
                    lbmi      MVDWN               If wall then go check for down
                    ldd       PCXLOC              GET pseudo screen X location
                    cmpd      PXNEW               Is it equal to actual location?
                    beq       SKIPR
                    addd      #8
                    std       PCXLOC
SKIPR               ldd       PXNEW               Get actual screen X location
                    addd      #8                  Add 8 to it
                    std       PXNEW               Put it back
                    ldd       PYNEW               Get screen Y location
                    std       PCYLOC              Set pyold = pynew
                    ldd       POFSET              Get pacman array offset
                    addd      #1                  Increment it
                    cmpd      #1793               Is it off screen to the right ?
                    bne       STBUF1
*   Erase pacman on right side of screen
*   Before moving pacman to left side
                    lda       #37                 Set for blank pacman
                    sta       PBFN                Put it in putblk code
                    ldd       #572
                    std       PXLOC
                    ldd       #85
                    std       PYLOC
                    lbsr      PUTBLK              Go erase pacman

                    ldd       #44
                    std       PXNEW               Reset pac screen X to 36
                    subd      #8                  Set pseudo X location
                    std       PCXLOC
                    lda       #1
                    ldd       #1726               Move pacman to left side
STBUF1              std       POFSET              Store pacman array offset
                    leax      D,Y                 Point to pacman position in array
                    lda       #25                 Set pacman direction buffer
                    sta       BUFF                for right facing pacman
                    ldb       #1
                    lda       B,X                 Get the byte at this spot
                    bmi       MVPAC1              Branch if wall
                    bita      #6                  Check for a dot or pill
                    beq       MVPAC1
                    lbsr      ERPILL              Go erase pill or dot
                    bra       MVPAC1
MVLFT               ldd       JOYSTX              Get joystick X value
                    cmpd      #27
                    bhi       MVDWN
                    inc       MOVFLG,U
                    lda       -1,X                Get byte 1 move to the left
                    bmi       MVDWN               Branch if wall
                    ldd       PXNEW               Get new pac position
                    subd      #8                  Subtract 8 from it
                    std       PXNEW               Put it back
                    std       PCXLOC              Set pxold = pxnew
                    ldd       PYNEW
                    std       PCYLOC              Set pyold = pynew
                    ldd       POFSET              Get pacman array offset
                    subd      #1                  Decrement it
                    cmpd      #1725               Is it off left side of screen ?
                    bne       STBUF2              If not then store hcount
*   Erase pacman on left side of screen
*   Before moving pacman to right side
                    lda       #37                 Set for blank pacman
                    sta       PBFN                Put it in PUTBLK code
                    ldd       #44
                    std       PXLOC
                    ldd       #85
                    std       PYLOC
                    lbsr      PUTBLK              Go erase pacman

                    ldd       #572
                    std       PXNEW               Update screen location too.
                    std       PCXLOC
                    ldd       #1792               Move pacman to right side
STBUF2              std       POFSET              Store pacman array offset
                    leax      D,Y                 X holds pacman position in array
                    lda       #28                 Set pacman direction buffer
                    sta       BUFF                for left facing pacman
                    ldb       #-1
                    lda       B,X                 Get byte from array
                    bmi       MVPAC1              Branch if wall
                    bita      #6                  Check for dot or pill
                    beq       MVPAC1
                    lbsr      ERPILL              Go erase pill or dot
MVPAC1              lda       BUFF
                    adda      CYCLE
                    sta       PCBFN
                    leax      PUTPACM,U
                    ldy       #8
                    lda       PATH
                    os9       I$Write
                    lbcs      ERR1

MVDWN               leay      ARRAY,U             Point to start of array
                    ldd       POFSET              Get pacman array offset
                    leax      D,Y                 X holds pacman array position
                    ldd       JOYSTY              Get joystick Y value
                    cmpd      #27                 Is it greater than 27 ?
                    bhi       MVUP                If not, then check for up move
                    inc       MOVFLG,U
                    lda       69,X                Look at byte one line down
                    lbmi      LEAVE               Branch if wall
                    ldd       PCYLOC              Get pseudo screen Y location
                    cmpd      PYNEW               Are they the same ?
                    beq       SKIPD
                    addd      #3                  Add 3 to it
                    std       PCYLOC
SKIPD               ldd       PYNEW               Get actual screen Y location
                    addd      #3                  Add 3 to it
                    std       PYNEW               Put it back
                    ldd       PXNEW
                    std       PCXLOC
SKIPD2              ldd       POFSET              Get location in array
                    addd      #69                 Move down 1 line
                    cmpd      #3692               Off screen at bottom?
                    bne       STBUF3

                    lda       #37                 Blank pacman buffer
                    sta       PBFN
                    ldd       #316
                    std       PXLOC
                    ldd       #166
                    std       PYLOC
                    lbsr      PUTBLK              Go erase pacman at bottom

                    ldd       #300
                    std       PXNEW
                    std       PCXLOC
                    ldd       #07                 New Y scrn location
                    std       PCYLOC
                    addd      #3
                    std       PYNEW
                    ldd       #33                 Move to top of array
STBUF3              std       POFSET
                    leax      D,Y
                    lda       #34                 Set pacman direction buffer
                    sta       BUFF                for down facing pacman
                    ldb       #69                 Look one line down
                    lda       B,X                 Get byte at this spot
                    bmi       MVPAC2              Branch if wall
                    bita      #6                  Check for dot(2) or pill(4)
                    beq       MVPAC2              Go move pacman
                    lbsr      ERPILL              Go erase pill or dot
                    bra       MVPAC2              Go move pacman

MVUP                ldd       JOYSTY              Get joystick Y value
                    cmpd      #37                 Is it less than 37 ?
                    lblo      LEAVE
                    inc       MOVFLG,U
                    lda       -69,X               Get byte from array, 1 line up
                    bmi       LEAVE               Branch if wall
                    ldd       PYNEW               Get pac screen Y location
                    subd      #3                  Subtract 3 from it
                    std       PYNEW               Put it back
                    std       PCYLOC              Set pyold = pynew
                    ldd       PXNEW
                    std       PCXLOC              Set pxold = pxnew
                    lda       #31                 Set direction buffer
                    sta       BUFF                to up facing pacman
                    ldd       POFSET              Get pacman array offset
                    subd      #69                 Move up one line
                    cmpd      #33                 At top of screen?
                    bne       STBUF4

                    lda       #37                 Blank pacman buffer #
                    sta       PBFN
                    ldd       #300
                    std       PXLOC
                    ldd       #13
                    std       PYLOC
                    lbsr      PUTBLK              Erase pacman at top

                    ldd       #316
                    std       PXNEW
                    std       PCXLOC
                    ldd       #169
                    std       PYNEW
                    std       PCYLOC
                    ldd       #3692
STBUF4              std       POFSET              Put it back
                    leax      D,Y                 X holds pacman array position
                    ldb       #-69
                    lda       B,X                 Get byte at this spot
                    bmi       MVPAC2              Branch if wall
                    bita      #6                  Check for dot(2) or pill(4)
                    beq       MVPAC2              Go move pacman
                    lbsr      ERPILL              Go erase pill or dot
MVPAC2              lda       BUFF                Get current pac buffer
                    adda      CYCLE               Add cycle count
                    sta       PCBFN               Set putblk buffer
                    leax      PUTPACM,U
                    ldy       #8
                    lda       PATH
                    os9       I$Write
                    lbcs      ERR1

LEAVE               lda       MOVFLG,U
                    bne       EXTCHK
                    ldx       #2
                    lbsr      WAIT

EXTCHK              ldb       PACMAN              Get # of pacmen left
                    cmpb      #6                  Only a total of 6 allowed
                    beq       MVDONE              If already 6, then exit
                    lda       SCRBCD,U
                    anda      #15                 %00001111 strip high
                    cmpa      EXTPAC,U            Compare it with goal
                    blo       MVDONE              If not =, then exit
                    incb                          If =, then give bonus-
                    stb       PACMAN              pacman to player
                    inc       EXTPAC,U            Increment goal
                    ldd       #181
                    std       PYLOC,U
                    lda       #28
                    sta       PBFN,U
                    lda       #30
                    ldb       PACMAN
                    subb      #1
                    mul
                    std       PXLOC,U
                    ldd       #600
                    subd      PXLOC,U
                    std       PXLOC,U
                    lbsr      PUTBLK

MVDONE              rts                           Return to MAIN

PALCHG              clrb
                    stb       STRLGH              Save counter
                    leay      STRING,U            String to output
                    leax      G1OFST,U            Point to ghost tables
                    lda       10,X                Get #1 ghost status
                    cmpa      #1
                    bne       TEST2
                    ldd       #$1b31              Palette set code
                    std       ,Y++                Put it in string
                    ldd       #$043d
                    std       ,Y++                Put it in string
                    inc       STRLGH
                    lda       #2
                    sta       10,X                Make ghost run from pacman
TEST2               lda       30,X                Get #2 ghost status
                    cmpa      #1
                    bne       TEST3
                    ldd       #$1b31              Palette set code
                    std       ,Y++                Put it in string
                    ldd       #$063d
                    std       ,Y++                Put it in string
                    inc       STRLGH
                    lda       #2
                    sta       30,X                Make ghost run from pacman
TEST3               lda       50,X                Get #3 ghost status
                    cmpa      #1
                    bne       TEST4
                    ldd       #$1b31              Palette set code
                    std       ,Y++
                    ldd       #$053d
                    std       ,Y++                Put it in string
                    inc       STRLGH
                    lda       #2
                    sta       50,X                Make ghost run from pacman
TEST4               lda       70,X                Get #4 ghost status
                    cmpa      #1
                    bne       TESTCK
                    ldd       #$1b31              Palette set code
                    std       ,Y++
                    ldd       #$033d
                    std       ,Y
                    inc       STRLGH
                    lda       #2
                    sta       70,X                Make ghost run from pacman
TESTCK              ldb       STRLGH
                    beq       OTDONE
                    lda       #4
                    mul
                    tfr       D,Y
                    leax      STRING,U
                    lbsr      OUTSTR
OTDONE              rts

*           erase pill subroutine
*        Erases DOT or PILL from array
*             and updates score
*    On entry, X reg points to spot in array
*    B reg holds 1 byte offset 1,-1,96 or -96
*    A reg holds byte at that point in array

ERPILL              cmpa      #6                  Was it a bonus ?
                    beq       ERBON
                    bita      #4                  Was it a power dot ?
                    beq       ERDOT
                    anda      #1
                    sta       B,X                 Erase power pill from array
                    lda       #32                 Add 20 to score
                    sta       POINTS+2

                    ldd       DOTTOT
                    addd      #1
                    std       DOTTOT

                    lda       #100                Set timeout counter
                    sta       POWFLG
                    lbsr      PALCHG              Go change color of ghosts
                    bra       ADDUP

ERBON               clra
                    sta       B,X
                    lbsr      SETBON              Go to Bonus Routines(in SCRNS)
                    lda       #154                Add 100 to score
                    sta       POINTS+2
                    bra       ADDUP

ERDOT               anda      #1
                    sta       B,X                 Erase dot from array
                    lda       #1                  Add 1 point to score
                    sta       POINTS+2            Put it back

                    ldd       DOTTOT
                    addd      #1
                    std       DOTTOT

*    Add points to score

ADDUP               leax      SCRBCD+3,U
                    leay      POINTS+3,U
                    ldb       #3                  Set loop counter to 3
                    andcc     #%11111110          Clear carry
ADLOOP              lda       ,-X                 Decrement X and get a byte
                    adca      ,-Y                 Add new points
                    daa                           Decimal adjust bytes
                    sta       ,X                  Put result back in score byte
                    decb                          Decrement loop counter
                    bne       ADLOOP              Loop till done

SHIFT               leay      SCRASC,U            Point to asc string
                    leax      SCRBCD,U            Point to score bytes
                    ldb       #3                  Set loop counter to 3
                    stb       SHCNT               Set loop counter to 3
                    clrb                          Clear leading zero flag
SFLOOP              lda       ,X                  Get a byte of score, bump pointer
                    lsra
                    lsra                          Shift high nibble to low
                    lsra
                    lsra
                    beq       TSTFG1
                    incb                          Set leading zero flag
TSTFG1              tstb                          Is leading zero flag set ?
                    bne       ASCSET1
                    lda       #-16                48-16 = ascii space
ASCSET1             adda      #48                 Add ascii offset for number
                    sta       ,Y+                 Put result in score string
                    lda       ,X+                 Get bcd score byte again
                    anda      #15                 Mask off high nibble
                    beq       TSTFG2
                    incb
TSTFG2              tstb
                    bne       ASCSET2
                    lda       #-16
ASCSET2             adda      #48
                    sta       ,Y+
                    dec       SHCNT
                    bne       SFLOOP              Loop 3 times

JUST1               leax      SCRPOS,U            Point to score string
                    ldy       #9                  Output 9 characters
                    lbsr      OUTSTR              Go output string

                    rts

*     Noise maker when pacman eats a dot


*WOCWOC   lda    PATH
*         ldb    #$98
*         ldx    #$3202
*         ldy    #3000
*         os9    I$SetStt

*         ldy    #2000
*         os9    I$GetStt

*     Return to MAIN

*SCDONE   rts


                    endsect



