
                    nam       Check
                    ttl       Routines to check & react to status

*     Program segment to be compiled using Level II RMA
*          This is not a mainline program segment
*                 Written by Larry Olson

                    ifp1
*         use   /dd/defs/os9defs.a
                    endc

STACK               equ       100

                    section   bss

*     Lcoal Variables


                    rmb       STACK


                    endsect

                    section   code

PALST1              fcb       $1b,$31,3,18
                    fcb       $1b,$31,4,36
                    fcb       $1b,$31,5,63
                    fcb       $1b,$31,6,25

PALST2              fcb       $1b,$31,3,53
                    fcb       $1b,$31,4,53
                    fcb       $1b,$31,5,53
                    fcb       $1b,$31,6,53


CHECKS              lda       HITFLG              Check hit flag
                    lbeq      CHKGH               If 0 the continue
                    lbpl      KILPAC              Pacman is hit, so kill him

*    Kill ghost routine
*    Make noise
                    ldd       #1550               Set starting frequency
                    std       SNDPR2              Save it in variable
KLOOP               ldx       #$3201              Set amplitude & duration
                    ldd       SNDPR2
                    addd      #250
                    cmpd      #4050               Are we done yet?
                    beq       KILGHT
                    std       SNDPR2              Save new value
                    tfr       D,Y                 Put value in Y reg.
                    lbsr      SND                 Go make noise
                    bra       KLOOP

KILGHT              leax      G1OFST,U            Point to ghost tables
                    lda       GHTHIT              Get # of ghost destroyed
                    leax      A,X                 Move to that ghosts table
                    stx       XSAVE               Save ghost table pointer
                    ldb       #-3
                    stb       10,X                Set status -3(killed)
*    Erase ghost
                    ldd       2,X                 Get ghost scrn X location
                    std       PGXLOC              Give it to PUTGHT
                    ldd       4,X                 Get ghost scrn Y location
                    std       PGYLOC              Give it to PUTGHT
                    lda       #1
                    sta       PGBFN               Set buff# to blank ghost
                    lbsr      PUTGHT              Go erase ghost
*    Reset ghost table
                    lda       GHTHIT              Get ghost counter
                    leay      GHTABL,U            Point to backup tables
                    leay      A,Y                 Use current ghost data
                    ldx       XSAVE               Restore X reg.
                    ldb       #20                 Transfer 20 bytes
RSLOOP              lda       ,Y+                 Get a byte
                    sta       ,X+                 Transfer it
                    decb                          Decrement counter
                    bne       RSLOOP              Loop till 20 are done
*    Reset palette for ghost
                    ldx       XSAVE               Point X reg. to ghost table
                    ldd       18,X                Get palette number & color
                    std       PALBT1+2            Put them in string
                    leax      PALBT1,U            Point to bytes to output
                    ldy       #4                  Output 4 bytes
                    lbsr      OUTSTR              Go output them
*    Draw ghost in cage
                    ldx       XSAVE               Point X reg. to ghost table
                    ldd       2,X                 Get ghost scrn X location
                    std       PGXLOC              Put it in PUTGHT string
                    ldd       4,X                 Get ghost scrn Y location
                    std       PGYLOC              Put it in PUTGHT string
                    lda       11,X                Get ghost buffer number
                    sta       PGBFN               Put it in PUTGHT string
                    lbsr      PUTGHT              Go put buffer to screen
*    Reset hit flag
                    clr       HITFLG              Reset hit flag
*    Add points to score
                    lda       #50                 50 points for ghost
                    sta       POINTS+2
                    lbsr      ADDUP               Go add to score
                    lbra      MAIN1               Return to main

KILPAC              ldx       #$3209              Set amplitude & duration
                    ldy       #2000               Set frequency
                    lbsr      SND                 Go make sound
                    ldd       PXNEW               Get pacman scrn X location
                    std       PXLOC               Give it to PUTBLK
                    ldd       PYNEW               Get pacman scrn Y location
                    std       PYLOC               Give it to PUTBLK
                    lda       #59                 Starting buffer -1
                    sta       PBFN                Give it to PUTBLK
                    ldd       #4050               Set frequency
                    std       SNDPR1
HLOOP               inc       PBFN                Increment buffer number
                    lbsr      PUTBLK              Put object on screen
                    ldx       #$3205              Set amplitude & duration
                    ldd       SNDPR1              Get frequency
                    subd      #150                Subtract 150 from it
                    std       SNDPR1              Put it back
                    tfr       D,Y                 Also put it in Y reg.
                    lbsr      SND                 Go make sound
                    lda       PBFN                Check buffer number
                    cmpa      #67                 Are we done ?
                    bne       HLOOP               If not, then keep looking
                    lda       #37                 37 = Blank pacman
                    sta       PBFN                Give it to PUTBLK
                    lbsr      PUTBLK              Put it on screen

*    Go to delete pacman routines in MAIN

                    lbra      DELPAC              Go delete pacman


*    Check if current ghost can be moved, if so then move it
*     Two ghost moves will be made for each pacman move
*      so the ghosts will be half as slow as pacman.
*    If we made 4 ghost moves for each pacman move then the
*     ghosts would move at the same speed as pacman.

CHKGH               lda       POWFLG              Check power pill flag
                    lbeq      MOVGH
                    deca                          Decrement flag (counter)
                    sta       POWFLG              Put it back
                    lbeq      PALRST              If 0 then reset palettes
TIMCHK              cmpa      #25                 Are we close to zero?
                    lbhi      MOVGH               If not, go move ghost
                    leax      PALST1,pcr          Point to palette reset string
                    ldy       #16                 Output 16 bytes
                    lbsr      OUTSTR              Go output code bytes

                    clrb
                    stb       STRLGH              Set string length to 0
                    leax      STRING,U            Point to where string goes
                    leay      G1OFST,U            Move to top of ghost tables
                    lda       10,Y                Get status for #1 ghost
                    cmpa      #2                  Is ghost chasing ?
                    bne       PLCHG2              If so then branch
                    ldd       #$1b31
                    std       ,X++                PUT 2 bytes in string
                    ldd       #$043d
                    std       ,X++                Put 2 bytes in string
                    inc       STRLGH              Increment counter
PLCHG2              lda       30,Y                Get status for ghost #2
                    cmpa      #2                  Is ghost chasing ?
                    bne       PLCHG3              If so then branch
                    ldd       #$1b31
                    std       ,X++                Put 2 bytes in string
                    ldd       #$063d
                    std       ,X++                Put 2 bytes in string
                    inc       STRLGH              Increment counter
PLCHG3              lda       50,Y                Get status for ghost #3
                    cmpa      #2                  Is ghost chasing ?
                    bne       PLCHG4              If so then branch
                    ldd       #$1b31
                    std       ,X++                Put 2 bytes in string
                    ldd       #$053d
                    std       ,X++                Put 2 bytes in string
                    inc       STRLGH              Increment counter
PLCHG4              lda       70,Y                Get status for ghost #4
                    cmpa      #2                  Is it chasing ?
                    bne       PLTEST              If so then branch
                    ldd       #$1b31
                    std       ,X++                Put 2 bytes in string
                    ldd       #$033d
                    std       ,X                  Put 2 bytes in string
                    inc       STRLGH              Increment counter
PLTEST              ldb       STRLGH              Get counter value
                    beq       PLDONE              If 0 then we're done
                    lda       #4                  Set multiplier
                    mul                           Mul. 4 x STRLGH
                    tfr       D,Y                 Put result in Y reg.
                    leax      STRING,U            Point to start of string
                    lbsr      OUTSTR              Go output string
PLDONE              bra       MOVGH


PALRST              leax      PALST1,pcr          Point to palette reset bytes
                    ldy       #16                 Output 16 bytes
                    lbsr      OUTSTR              Go output bytes
*    Now reset ghosts status from running to chasing
                    leax      G1OFST,U
                    ldb       #1
                    lda       10,X
                    cmpa      #2                  Is ghost running?
                    bne       STRST2
                    stb       10,X                Set to chasing
STRST2              lda       30,X
                    cmpa      #2                  Is ghost running?
                    bne       STRST3
                    stb       30,X                Set to chasing
STRST3              lda       50,X
                    cmpa      #2                  Is ghost running?
                    bne       STRST4
                    stb       50,X                Set to chasing
STRST4              lda       70,X
                    cmpa      #2                  Is ghost running?
                    bne       MOVGH
                    stb       70,X                Set to chasing

*    Make 3 ghost moves for each pacman move
*    This means that the 4 ghosts will be a
*    little slower on the screen than pacman

MOVGH               lbsr      GHCHCK              Go check for ghost move
                    lbsr      GHCHCK              Do it again

*    Bonus Routines
BONUS               lda       BONFLG              Check bonus flag
                    beq       PUTBON              Go put bonus on screen
                    dec       BONTIM              Decrement bonus timer
                    bne       MOVGH2
*    Erase bonus from screen
ERSBON              ldd       #310
                    std       PXLOC
                    ldd       #95
                    std       PYLOC
                    lda       #69
                    sta       PBFN
                    lbsr      PUTBLK              Go erase bonus
                    leax      ARRAY,U
                    ldd       #1966
                    leax      D,X
                    clr       ,X                  Erase bonus from array
                    clr       BONFLG              Reset bonus flag
                    lda       #150
                    sta       BONTIM              Reset bonus timer
                    bra       LEAVE

*    Put bonus on screen
*
PUTBON              lda       BONCNT              Check counter
                    cmpa      #10                 Has player got 10 yet ?
                    beq       MOVGH2              If so, then no more
                    dec       BONTIM              Decrement timer
                    bne       MOVGH2
                    lbsr      RANDNM              Go pick random number
                    cmpa      #200
                    bhi       LEAVE
                    lda       BONBUF              Get bonus buffer #
                    inca
                    cmpa      #73
                    bne       PUTBN2
                    lda       #70
PUTBN2              sta       BONBUF
                    sta       PBFN
                    ldd       #310
                    std       PXLOC
                    ldd       #95
                    std       PYLOC
                    lbsr      PUTBLK              Put bonus on screen
                    leax      ARRAY,U
                    ldd       #1966
                    leax      D,X
                    lda       #6
                    sta       ,X                  Put bonus in array
                    lda       #50
                    sta       BONTIM              Set bonus timer
                    inc       BONFLG              Set bonus flag
                    bra       LEAVE

*  If power pill flag is set then slow ghosts down

MOVGH2              lbsr      GHCHCK              One more time
*         tst   POWFLG
*         bne   LEAVE
*         lbsr  GHCHCK     One more time

*    Go return to main loop

LEAVE               lbra      MAIN1               Return to MAIN loop


                    endsect


