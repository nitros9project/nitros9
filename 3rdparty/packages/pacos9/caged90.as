
                    nam       Caged
                    ttl       Routines to Cage and Uncage Ghosts

*     Program segment to be compiled using Level II RMA
*          This is not a mainline program segment
*                 Written by Larry Olson

                    ifp1
*         use   /dd/defs/os9defs.a
                    endc


STACK               equ       100

                    section   bss

*     Lcoal Variables

XSAVE               rmb       2
                    rmb       STACK


*********************************
*     Global Variables          *
*                               *
*        ARRAY     ---   MAIN   *
*                               *
*     Ghost tables. One table   *
*         for each ghost        *
*        located in MAIN        *
*                               *
*        G1OFST    ---   MAIN   *
*        G1XNEW    ---   MAIN   *
*        G1YNEW    ---   MAIN   *
*        G1XOLD    ---   MAIN   *
*        G1YOLD    ---   MAIN   *
*        G1STAT    ---   MAIN   *
*        G1BUFF    ---   MAIN   *
*        G1TIME    ---   MAIN   *
*        TIMVAL    ---   MAIN   *
*        G1DIR     ---   MAIN   *
*        DIROFF    ---   MAIN   *
*        G1UPDT    ---   MAIN   *
*        UPDATE    ---   MAIN   *
*                               *
*        GCOUNT    ---   MAIN   *
*                               *
*        PBFN      ---   MAIN   *
*                               *
*        PXLOC     ---   MAIN   *
*        PYLOC     ---   MAIN   *
*        POFSET    ---   MAIN   *
*                               *
*     Global Labels             *
*                               *
*        PUTBLK    ---   MAIN   *
*        ERR1      ---   MAIN   *
*        GHMOVE    ---   GHOSTS *
*        HUNT      ---   GHOSTS *
*********************************


                    endsect

                    section   code

*     Ghost is caged, so check timer value

CAGED               ldb       10,X                Check status
                    cmpb      #-3                 Are eyes free of cage?
                    lbeq      MVEYES              Go move eyes
                    ldb       12,X                Get timer value for ghost
                    decb                          Decrement it
                    stb       12,X                Put it back
                    beq       MOVOUT              Start moving ghost out
                    cmpb      #10                 Are we close to zero?
                    bls       GHFLSH              Go flash ghost

                    ldx       #2
                    os9       F$Sleep
                    lbcs      ERR1

                    rts                           If not, return to MAIN

*     Ghost is caged and close to coming out so blink it
*       or if status=-2 then go blink eyes
*     X reg points to start of current ghost table
*     A reg contains current ghost status byte

GHFLSH              cmpb      #-2                 Is ghost dead? Only eyes?
                    lbeq      EYFLSH              If so, then go flash eyes
                    ldd       2,X                 Get ghost scrn X location
                    std       PGXLOC              Put it in PUTGHT string
                    ldd       4,X                 Get ghost scrn Y location
                    std       PGYLOC              Put it in PUTGHT string
                    ldb       #1                  Buffer # for blank ghost
                    stb       PGBFN               Put it in PUTGHT string
                    stx       XSAVE               Save X register
                    lbsr      PUTGHT              Go erase ghost
                    ldx       XSAVE               Restore X register
                    ldb       11,X                Get ghost buffer #
                    stb       PGBFN               Put it in PUTGHT string
                    lbsr      PUTGHT              Put ghost back on screen
                    lbra      RETURN              Return to MAIN

*     Ghost is available to come out, so set status
*     flags and open cage door
*             X reg. points to start of ghost table
*             A reg. contains ghost status byte
*             B reg. contains ghost timer value

MOVOUT              clra                          0=Caged but moving out
                    sta       10,X                Save new ghost status
                    ldb       #22                 22=Buff # for blank door
                    stb       PBFN                Put it in PUTBLK string
                    ldd       #307                X location of door
                    std       PXLOC               Put it in PUTBLK string
                    ldd       #78                 Y location of door
                    std       PYLOC               Put it in PUTBLK string
                    lbsr      PUTBLK              Go erase door
                    lbra      RETURN              Return to MAIN

*     Check for direction to move ghost
*             X reg. points to start of current ghost table
*             A reg. contains current ghost status

MOVING              ldd       0,X                 Get array offset for ghost
                    cmpd      #1552               Are we moving up?
                    lbls      MUP                 If so, then keep moving up
                    cmpd      #1621               Are we on center line?
                    lbeq      MUP                 If so, then go move up
                    blo       MRIGHT              If lower, then move right
                    subd      #1                  Move 1 position left in array
                    std       0,X                 Save new offset position
                    ldd       2,X                 Get ghost scrn X location
                    subd      #8                  Move 8 pixels to the left
                    std       2,X                 Save new scrn X location
                    std       6,X                 Also save in OLD X location
                    std       PGXLOC              Also put it in PUTGHT
                    ldd       4,X                 Get ghost scrn Y location
                    std       8,X                 Also put it in OLD Y location
                    std       PGYLOC              Put it in PUTGHT
                    lda       11,X                Get current ghost buffer#
                    adda      #1                  Add 1 for left facing ghost
                    sta       PGBFN               Put it in PUTGHT string
                    lbsr      PUTGHT              Put ghost back on screen
                    lbra      RETURN              Return to MAIN

*     Ghost is left of center so move to the right
*           X reg. points to start of current ghost table
*           D reg. contains array position offset of ghost

MRIGHT              addd      #1                  Move 1 position to right
                    std       0,X                 Save new offset position
                    ldd       6,X                 Get G1XOLD
                    cmpd      2,X                 Compare it with G1XNEW
                    beq       SKIPMR
                    addd      #8                  Add 8 to OLD location
                    std       6,X                 Put result back in G1XOLD
SKIPMR              ldd       2,X                 Get new scrn X location
                    addd      #8                  Move 8 pixels to the right
                    std       2,X                 Save new scrn X location
                    ldd       6,X                 Get OLD scrn X location
                    std       PGXLOC              Also put it in PUTGHT
                    ldd       4,X                 Get NEW scrn Y location
                    std       8,X                 G1YOLD=G1YNEW
                    std       PGYLOC              Also put it in PUTGHT
                    lda       11,X                Get current ghost buffer #
                    adda      #2                  Add 2,for right facing ghost
                    sta       PGBFN               Put it in PUTGHT string
                    lbsr      PUTGHT              Put ghost back on screen
                    lbra      RETURN              Return to MAIN

*     Ghost is on center line so move up
*            X reg. points to start of current ghost table
*            D reg. contains array position offset of ghost

MUP                 cmpd      #1345               Are we out of cage?
                    beq       FREEGH              Yes? go set ghost free flags
                    subd      #69                 Move 1 position up in array
                    std       0,X                 Save new array offset
                    ldd       4,X                 in the up direction
                    subd      #3                  Move up 3 pixels
                    std       4,X                 Save new scrn Y location
                    std       8,X                 Also put it in OLD Y
                    std       PGYLOC              Also load PUTGHT string
                    ldd       2,X                 Get G1XNEW
                    std       6,X                 G1XOLD=G1XNEW
                    std       PGXLOC              Also put it in PUTGHT
                    lda       11,X                Get current ghost buffer#
                    sta       PGBFN               Put it in PUTGHT string
                    lbsr      PUTGHT              Go put ghost on screen
                    lbra      RETURN              Return to MAIN

*     Ghost is out of cage, so close door and set flags
*             X reg. points to start of current ghost table
*             D reg. contains ghost array position offset

FREEGH              ldb       #1                  1=Free ghost
                    stb       10,X                Update status for this ghost

                    leay      ARRAY,U             Point to start of array
                    ldd       0,X                 Get ghost array ofset
                    leay      D,Y                 Move Y reg. to that spot

                    bsr       HUNT                Go find direction of pacman

                    ldb       #23                 23=Buffer# for cage door
                    stb       PGBFN               Put it in PUTGHT string
                    ldd       #307                307=Scrn X location of door
                    std       PGXLOC              Put it in PUTGHT string
                    ldd       #78                 78=Scrn Y location of door
                    std       PGYLOC              Put it in PUTGHT string
                    lbsr      PUTGHT              Go draw cage door
RETURN              rts



EYFLSH              rts

*     This routine is used to compare the ghosts
*     location to pacman's location and then set
*     the ghost direction pointers to move away
*     from pacman.
*     ON ENTRY:
*       X reg. points to top of current ghost table

RUN                 ldd       0,X                 Get ghost array offset
                    addd      #69                 Move down 1 line
                    cmpd      POFSET              Compare ghost to pacman offset
                    lblo      HUNTUP              Pacman is down or to right
                    subd      #69
                    cmpd      POFSET
                    blo       HUNTLF
                    subd      #69
                    cmpd      POFSET
                    lbhi      HUNTDN
                    bra       HUNTRT

*     This routine is used to compare the ghosts
*     location to pacman's location and then set
*     the ghost direction pointers to move toward
*     pacman.
*     ON ENTRY:
*       X reg. points to top of current ghost table
*     First run random number generator

HUNT                lbsr      RANDNM              Go pick random number
                    cmpa      #30
                    bhi       HUNT2

                    ldd       0,X                 Get ghost array offset
                    addd      #69                 Move down 1 line
                    cmpd      POFSET              Compare ghost to pacman offset
                    lblo      HUNTUP              Pacman is down move up
                    subd      #69                 Move back to offset location
                    cmpd      POFSET              Compare ghost to pacman offset
                    blo       HUNTLF              Pacman to right, move left
                    subd      #69                 Move up 1 line
                    cmpd      POFSET              Compare ghost to pacman offset
                    bhi       HUNTDN              Pacman is up, move down
                    bra       HUNTRT              go move right

HUNT2               ldd       0,X                 Get ghost array offset
                    addd      #69                 Move down 1 line
                    cmpd      POFSET              Compare ghost to pacman offset
                    blo       HUNTDN              Pacman is down or to right
                    subd      #69                 Move back to offset location
                    cmpd      POFSET              Compare ghost to pacman offset
                    blo       HUNTRT              Pacman is to right of ghost
                    subd      #69                 Move up 1 line
                    cmpd      POFSET              Compare ghost to pacman offset
                    bhi       HUNTUP              Pacman is above the ghost

HUNTLF              ldb       #1
                    cmpb      15,X                Did we go right last time?
                    beq       HLFUP
                    lda       #1                  Set dir. LEFT
                    ldb       -1,Y
                    bpl       SETDIR
HLFUP               lda       #0                  Set dir. UP
                    ldb       -69,Y
                    bpl       SETDIR
                    lda       #3                  SET dir. DOWN
                    ldb       69,Y
                    bpl       SETDIR
                    lda       #2                  SET dir. RIGHT
                    bra       SETDIR

HUNTRT              ldb       #-1
                    cmpb      15,X                Did we go left last time?
                    beq       HRTDN
                    lda       #2                  Set dir.offset to right
                    ldb       1,Y                 Look 1 space to right in array
                    bpl       SETDIR              Found move, Go set direction
HRTDN               lda       #3                  Set dir. DOWN
                    ldb       69,Y                Look 1 line down in array
                    bpl       SETDIR              Found move, Go set direction
                    lda       #0                  Set dir. offset to UP
                    ldb       -69,Y               Look 1 line up in array
                    bpl       SETDIR              Found a move, go set direction
                    lda       #1                  Set dir. offset to left
                    bra       SETDIR              Go set direction
*     Look UP,LEFT,RIGHT and DOWN
HUNTUP              ldb       #69
                    cmpb      15,X                Did we go down last time?
                    beq       HUPLF
                    lda       #0                  Direction offset (UP)
                    ldb       -69,Y               Look 1 line up in array
                    bpl       SETDIR              Found move,Go set direction
HUPLF               lda       #1                  Direction offset (LEFT)
                    ldb       -1,Y                Look 1 space to left in array
                    bpl       SETDIR              Found move, Go set direction
                    lda       #2                  Direction offset (RIGHT)
                    ldb       1,Y                 Look 1 space to right in array
                    bpl       SETDIR              Found move, Go set direction
                    lda       #3                  Only dir. left (DOWN)
                    bra       SETDIR              Go set direction
*     Look DOWN,LEFT,RIGHT and UP
HUNTDN              ldb       #-69
                    cmpb      15,X                Did we go up last time?
                    beq       HDNRT
                    lda       #3                  Direction offset (DOWN)
                    ldb       69,Y                Look 1 space down in array
                    bpl       SETDIR              Found move, Go set direction
HDNRT               lda       #2                  Direction offset (RIGHT)
                    ldb       1,Y                 Look 1 space to right in array
                    bpl       SETDIR              Found move, Go set direction
                    lda       #1                  Direction offset (LEFT)
                    ldb       -1,Y                Look 1 space to left in array
                    bpl       SETDIR              Found move, Go set direction
                    lda       #0                  Only dir. left (UP)
*     Move found, So set direction flags
SETDIR              sta       14,X                Save dir.# (0,1,2,3)
                    bne       SETD2
                    ldb       #-69                -69
                    stb       15,X                Put it in GARDIR
                    bra       DONE

SETD2               deca
                    bne       SETD3
                    ldb       #-1                 -1
                    stb       15,X                Put it in GARDIR
                    bra       DONE

SETD3               deca
                    bne       SETD4
                    ldb       #1                  +1
                    stb       15,X                Put it in GARDIR
                    bra       DONE

SETD4               ldb       #69                 +69
                    stb       15,X                Put it in GARDIR

DONE                rts

*    Move ghost eyes

MVEYES              rts


                    endsect


