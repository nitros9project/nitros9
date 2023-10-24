
                    nam       Ghosts
                    ttl       Routines to move Ghosts

*     Program segment to be compiled using Level II RMA
*          This is not a mainline program segment
*                 Written by Larry Olson

                    ifp1
*         use   /dd/defs/os9defs.a
                    endc

STACK               equ       250

                    section   bss

*     Lcoal Variables

                    rmb       STACK


                    endsect

                    section   code

*     Subtract 20 from ghost counter
*     Then check ghost status to determine what action
*     is to be preformed on ghost.

GHCHCK              lda       GCOUNT              Get ghost counter
                    suba      #20                 Subtract 20 from it
                    bpl       CKSTAT              If =>0 then check status
                    lda       #60                 Reset counter to zero
CKSTAT              sta       GCOUNT              Save ghost counter
                    leax      G1OFST,U            Point to start of tables
                    leax      A,X                 Move to current ghost table
                    lda       10,X                Get ghost status
                    lbeq      MOVING              If so then move it again
                    lbmi      CAGED               Check caged status

GHMOVE              leay      ARRAY,U             Point to start of array
                    ldd       ,X                  Get ghost array offset
                    leay      D,Y                 Move to that spot in array
                    lda       ,Y                  Get the byte there
                    bita      #1                  Check for intersection
                    beq       NOWALL              If = then no intersection

                    lda       10,X                Check status
                    cmpa      #1                  Are we chasing pacman?
                    beq       NORUN
                    lbsr      RUN                 If not, then run
                    bra       NOWALL
NORUN               ldd       ,X
                    lbsr      HUNT                At intersection, so go hunt

*      This routine is used to calc and add the offsets and
*      fill the PUTBLK string, in order to move the ghosts
*      Old ghost will be erased when new ghost is put on
*      the screen.

NOWALL              lda       14,X                Get direction flag
                    bne       LEFT
*     Move ghost up screen
UP                  ldd       ,X                  Get ghost array offset
                    cmpd      #33                 At top of screen?
                    bne       STGH1

                    pshs      X                   Save X reg.

                    lda       #1                  Set for blank ghost
                    sta       PGBFN
                    ldd       #300
                    std       PGXLOC
                    ldd       #10
                    std       PGYLOC
                    lbsr      PUTGHT

                    puls      X                   Restore X reg.

                    ldd       #317                Set new X screen location
                    std       2,X
                    std       6,X
                    std       PGXLOC
                    ldd       #169                Set new Y screen location
                    std       4,X
                    std       8,X
                    std       PGYLOC
                    ldd       #3692               Set new array location
                    std       ,X
                    ldb       11,X
                    stb       PGBFN
                    lbra      PUTGH

STGH1               subd      #69                 Move up one space in array
                    std       ,X                  Save new array location
                    ldd       2,X                 Get NEW scrn X location
                    std       6,X                 G1XOLD = G1XNEW
                    std       PGXLOC              Put it in PUTGHT string
                    ldd       4,X                 Get NEW scrn Y location
                    subd      #3                  Move up 3 scrn lines
                    std       4,X                 Save new scrn Y location
                    std       8,X                 G1YOLD = G1YNEW
                    std       PGYLOC              Also put it in PUTGHS
                    ldb       11,X                Get ghost buffer #
                    stb       PGBFN               Put it in PUTGHS string
                    lbra      PUTGH               Go put ghost back on scrn
*     Move ghost left on screen
LEFT                deca                          Decrement direction flag
                    bne       RIGHT
                    ldd       ,X                  Get ghost array offset

                    cmpd      #1725               Off screen to left ?
                    bne       STGH2

                    pshs      X                   Save X reg.

                    lda       #1                  Set for blank ghost
                    sta       PGBFN
                    ldd       #37
                    std       PGXLOC
                    ldd       #85
                    std       PGYLOC
                    lbsr      PUTGHT

                    puls      X                   Restore X reg.

                    ldd       #581
                    std       2,X
                    std       6,X
                    std       PGXLOC
                    ldd       #1793
                    std       ,X
                    lda       11,X
                    adda      #1
                    sta       PGBFN
                    lbra      PUTGH

STGH2               subd      #1                  Move left 1 space in array
                    std       ,X                  Save new array location
                    ldd       2,X                 Get NEW scrn X location
                    subd      #8                  Move 8 pixels left on scrn
                    std       2,X                 Save NEW scrn X location
                    std       6,X                 G1XOLD = G1XNEW
                    std       PGXLOC              Also put it in PUTGHT
                    ldd       4,X                 Get ghost scrn Y location
                    std       8,X                 G1YOLD = G1YNEW
                    std       PGYLOC              Put it in PUTGHT string
                    ldb       11,X                Get ghost buffer #
                    addb      #1                  Add direction offset
                    stb       PGBFN               Put it in PUTGHT string
                    lbra      PUTGH               Go put ghost back on scrn
*     Move ghost right on screen
RIGHT               deca                          Decrement direction flag
                    bne       DOWN
                    ldd       ,X                  Get ghost array offset

                    cmpd      #1793               Off screen to right ?
                    bne       STGH3               If not, continue

                    pshs      X                   Save X reg.

                    lda       #1                  Set for blank ghost
                    sta       PGBFN
                    ldd       #581
                    std       PGXLOC
                    ldd       #85
                    std       PGYLOC
                    lbsr      PUTGHT

                    puls      X                   Restore X reg.

                    ldd       #37
                    std       2,X
                    subd      #8
                    std       6,X
                    std       PGXLOC
                    ldd       #1725
                    std       ,X
                    lda       11,X
                    adda      #2
                    sta       PGBFN
                    lbra      PUTGH

STGH3               addd      #1                  Move 1 space right in array
                    std       ,X                  Save new array location
                    ldd       6,X                 Get OLD scrn X location
                    cmpd      2,X                 Compare it to NEW
                    beq       SKIPRT
                    addd      #8                  Add 8 to it
                    std       6,X                 Save in OLD scrn x location
SKIPRT              ldd       2,X                 Get NEW scrn X location
                    addd      #8                  Move 8 pixels right on scrn
                    std       2,X                 Save NEW scrn X location
                    ldd       6,X                 Get OLD scrn X location
                    std       PGXLOC              Also put it in PUTGHT
                    ldd       4,X                 Get ghost scrn Y location
                    std       8,X                 G1YOLD = G1YNEW
                    std       PGYLOC              Put it in PUTGHT string
                    ldb       11,X                Get ghost buffer #
                    addb      #2                  Add direction offset
                    stb       PGBFN               Put it in PUTGHT string
                    bra       PUTGH               Go put ghost back on scrn
*     Move ghost down on screen
DOWN                ldd       ,X                  Get ghost array offset
                    cmpd      #3692               At bottom of screen?
                    bne       STGH4

                    pshs      X                   Save X reg.

                    lda       #1
                    sta       PGBFN
                    ldd       #317
                    std       PGXLOC
                    ldd       #169
                    std       PGYLOC
                    lbsr      PUTGHT

                    puls      X                   Restore X reg.

                    ldd       #301
                    std       2,X
                    std       6,X
                    std       PGXLOC
                    ldd       #07
                    std       8,X
                    std       PGYLOC
                    addd      #3
                    std       4,X
                    ldd       #33
                    std       ,X
                    ldb       11,X
                    addb      #3
                    stb       PGBFN
                    bra       PUTGH

STGH4               addd      #69                 Move 1 line down in array
                    std       ,X                  Save new array location
                    ldd       8,X                 Get OLD Y location
                    cmpd      4,X                 Compare it to NEW Y
                    beq       SKIPDN
                    addd      #3                  Add 3 to it
                    std       8,X                 Put result back in OLD Y
SKIPDN              ldd       4,X                 Get NEW Y location
                    addd      #3                  Add 3 to it
                    std       4,X                 Put result back in NEW Y
                    ldd       8,X                 Get OLD scrn Y location
                    std       PGYLOC              Also put it in PUTGHT
                    ldd       2,X                 Get ghost scrn X location
                    std       6,X                 G1XOLD = G1XNEW
                    std       PGXLOC              Put it in PUTGHT string
                    ldb       11,X                Get ghost buffer #
                    addb      #3                  Add direction offset
                    stb       PGBFN               Put it in PUTGHT string

*     Before we put ghost back on screen we first
*     check to see if we got pacman, if so, set flag
*     put any dots back on screen that were erased
*     by the ghost when it moved

PUTGH               ldd       2,X                 Get ghost scrn X location
                    addd      #20
                    cmpd      PXNEW               Compare to left side of pman
                    ble       GOLOOK
                    ldd       PXNEW               Get pacman scrn X location
                    addd      #22
                    cmpd      2,X                 Compare to left side of ghost
                    ble       GOLOOK
                    ldd       4,X                 Get ghost scrn Y location
                    addd      #10
                    cmpd      PYNEW               Compare to top of pacman
                    ble       GOLOOK
                    ldd       PYNEW               Get pacman scrn Y location
                    addd      #10
                    cmpd      4,X                 Compare to top of ghost
                    ble       GOLOOK

                    lda       #1
                    sta       HITFLG              Set HIT FLAG
                    ldb       10,X                Check status
                    cmpb      #1
                    beq       GOLOOK
                    lda       #-1
                    sta       HITFLG
                    lda       GCOUNT
                    sta       GHTHIT

GOLOOK              ldd       ,X
                    cmpd      #33
                    ble       SKIPDT
                    cmpd      #3692
                    bge       SKIPDT
                    bsr       LOOK                Go look for dots to restore
                    cmpa      #0                  A will be >0 if dot found
                    beq       SKIPDT              Branch if no dot to put back
                    sta       PDBFN               Put dot buff# in PUTDOT

*     Put both dot(or pill) and ghost
*     This routine will output both DOTCODE & PUTCODE

                    leax      PUTGHS,U            Point to Putghost's rmb's
                    ldy       #16                 8 for dot & 8 for ghost
                    lda       PATH                Set output path
                    os9       I$Write             Output PUTBLK code
                    lbcs      ERR1                Branch if any errors
                    rts                           Return to MAIN

SKIPDT              lbsr      PUTGHT              Go put ghost back on screen
MAINRT              rts                           Return to MAIN

*     The following routines look for any dots to
*          replace after ghosts move on.

LOOK                leay      ARRAY,U             Point to start of array
                    lda       14,X                Get direction flag
                    lbeq      LOOKDN              Ghost moving up, look down
                    deca
                    lbeq      LOOKRT              Ghost moving left, look right
                    deca
                    lbeq      LOOKLF              Ghost moving right, look left
*     Moving DOWN, so look UP
LOOKUP              ldd       ,X                  Get ghost array offset
                    subd      #69                 Move up 1 space in array
                    leay      D,Y                 Point Y reg. here
                    ldb       ,Y                  Look at byte there
                    lbmi      NODOT
                    ldb       -69,Y               Look at byte 1 line up
                    lbmi      NODOT
                    cmpb      #1                  Check for intersection
                    ble       LOOKU3              Go look 3 spaces up
                    cmpb      #3                  Is it a power dot?
                    bhi       POWU2
                    ldd       2,X                 Get ghost scrn X location
                    addd      #7                  Move right 7 pixels
                    std       PDXLOC              Put result in PUTDOT
                    ldd       4,X                 Get ghost scrn Y location
                    subd      #3                  Move 3 pixel up
                    std       PDYLOC              Put result in PUTDOT
                    lda       #42                 Set flag(Buff# for dot)
                    rts                           Return to PUTGH
POWU2               ldd       2,X                 Get ghost scrn X location
                    addd      #5
                    std       PDXLOC              Put result in PUTDOT
                    ldd       4,X                 Get ghost scrn Y location
                    subd      #3
                    std       PDYLOC              Put result in PUTDOT
                    lda       #52                 Set flag(Buff# for power dot)
                    rts                           Return to PUTGH

LOOKU3              ldb       -138,Y              Get byte there
                    cmpb      #1
                    lble      NODOT
                    cmpb      #3                  Is it a wall?
                    bhi       POWU3
                    ldd       2,X                 Get ghost scrn X location
                    addd      #7                  Add offset to dot location
                    std       PDXLOC              Put result in PUTDOT string
                    ldd       4,X                 Get ghost scrn Y location
                    subd      #6                  Subtract offset
                    std       PDYLOC              Put result in PUTDOT string
                    lda       #40                 Set flag (Also Buff #)
                    rts

POWU3               ldd       2,X                 Get ghost scrn X location
                    addd      #5                  Add offset to dot location
                    std       PDXLOC              Put result in PUTDOT string
                    ldd       4,X                 Get ghost scrn Y location
                    subd      #6                  Subtract offset
                    std       PDYLOC              Put result in PUTDOT string
                    lda       #50                 Set flag (Also Buff #)
                    rts

*    The following routines are not commented because
*    they are all identical to the LOOKUP routines
*    except for the use of different buffer numbers
*    and different offset values.
*
*   Moving UP, so look down

LOOKDN              ldd       ,X
                    addd      #69
                    leay      D,Y
                    ldb       ,Y
                    lbmi      NODOT
                    ldb       69,Y
                    lbmi      NODOT
                    cmpb      #1
                    ble       LOOKD3
                    cmpb      #3
                    bhi       POWD2
                    ldd       2,X
                    addd      #7
                    std       PDXLOC
                    ldd       4,X
                    addd      #9
                    std       PDYLOC
                    lda       #43
                    rts

POWD2               ldd       2,X
                    addd      #5
                    std       PDXLOC
                    ldd       4,X
                    addd      #9
                    std       PDYLOC
                    lda       #53
                    rts

LOOKD3              ldb       138,Y
                    cmpb      #1
                    lble      NODOT
                    cmpb      #3
                    bhi       POWD3
                    ldd       2,X
                    addd      #7
                    std       PDXLOC
                    ldd       4,X
                    addd      #12
                    std       PDYLOC
                    lda       #40
                    rts

POWD3               ldd       2,X
                    addd      #5
                    std       PDXLOC
                    ldd       4,X
                    addd      #12
                    std       PDYLOC
                    lda       #50
                    rts

*    Moving LEFT, so look right

LOOKRT              ldd       ,X
                    leay      D,Y
                    ldb       1,Y
                    lbmi      NODOT
                    ldb       2,Y
                    cmpb      #1
                    lble      NODOT
                    cmpb      #3
                    bhi       POWR2
                    ldd       2,X
                    addd      #23
                    std       PDXLOC
                    ldd       4,X
                    addd      #3
                    std       PDYLOC
                    lda       #40
                    rts

POWR2               cmpb      #6
                    beq       BONR2
                    ldd       2,X
                    addd      #21
                    std       PDXLOC
                    ldd       4,X
                    addd      #3
                    std       PDYLOC
                    lda       #50
                    rts

BONR2               ldd       2,X
                    addd      #15
                    std       PDXLOC
                    ldd       4,X
                    addd      #1
                    std       PDYLOC
                    lda       BONBUF
                    rts

*    Moving RIGHT, so look left

LOOKLF              ldd       ,X
                    leay      D,Y
                    ldb       -1,Y
                    bmi       NODOT
                    ldb       -2,Y
                    cmpb      #1
                    ble       NODOT
                    cmpb      #3
                    bhi       POWL2
                    ldd       2,X
                    subd      #9
                    std       PDXLOC
                    ldd       4,X
                    addd      #3
                    std       PDYLOC
                    lda       #40
                    rts

POWL2               cmpb      #6
                    beq       BONL2
                    ldd       2,X
                    subd      #11
                    std       PDXLOC
                    ldd       4,X
                    addd      #3
                    std       PDYLOC
                    lda       #50
                    rts

BONL2               ldd       2,X
                    subd      #17
                    std       PDXLOC
                    ldd       4,X
                    addd      #1
                    std       PDYLOC
                    lda       BONBUF
                    rts

*    This is the common exit for all the LOOK
*    routines if no dot was found to replace.
*    Clearing the A reg. is a flag for the
*    PUTGH routine to let it know that no dot
*    needs to be put back on the screen

NODOT               clra                          Clear flag
                    rts


                    endsect


