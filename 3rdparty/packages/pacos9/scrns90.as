

                    nam       SCRNS
                    ttl       Screen handling routines

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

ERSCRN              fcb       2,32,33,$0B

SETCOL              fcb       $1b,$32,10

DELPAC              lda       PLAYRS              Check for 1 or 2 players
                    bne       CHKTWO
                    lda       PACMAN              Get # of pacmen
                    deca                          Subtract 1
                    sta       PACMAN              Save new player count
                    lbeq      GAMOVR              If 0 then END GAME
                    lbra      NEWSC1

*    2 players, so check who's up

CHKTWO              lda       PLCRNT              Get current player
                    cmpa      #1                  Is it player #1 ?
                    bne       PLAY2
*    Player 1 was up so kill one of his pacmen
                    lda       PACMN1              Get number of pacmen
                    deca                          Subtract 1
                    sta       PACMN1              Save new total
                    bne       TFRTWO
                    lbsr      GAMOV2              Game over for player 1

*    Transfer player2 variables
TFRTWO              lda       PACMN2              Get player 2 pacmen total
                    sta       PACMAN              Put it in current pacman
                    lda       #2
                    sta       PLCRNT              Set current player to 2
                    leax      SCR2,pcr            Point arrow at player 2
                    bra       TFRSCR              Go transfer score & run NEWSCREEN

PLAY2               lda       PACMN2              Get player 2 pacmen
                    deca                          Subtract 1
                    sta       PACMN2              Save new pacmen count
                    lbeq      GAMOVR              Game over
                    lda       PACMN1              Get player 1 pacmen
                    sta       PACMAN              Put it in current pacman
                    lda       #1
                    sta       PLCRNT              Set current player to 1
                    leax      SCR1,pcr            Point arrow at player 1

*    Transfer score variables

TFRSCR              ldy       #18                 Output 18 characters to screen
                    lbsr      OUTSTR              Go output arrow
                    leax      SCRPOS,U            Point to score string
                    leay      SCRPO2,U            Point to score save area
                    ldb       #12                 Set count to 12 bytes
                    stb       DOTCNT              Save counter
SRLOOP              lda       ,X
                    ldb       ,Y
                    sta       ,Y+
                    stb       ,X+
                    dec       DOTCNT
                    bne       SRLOOP              Loop till 12 bytes done

                    ldd       EXTPAC,U
                    pshs      d
                    ldd       EXTPC2,U
                    std       EXTPAC,U
                    puls      D
                    std       EXTPC2,U

*    Transfer board variables

                    leax      DOTTOT,U
                    leay      DOTTMP,U
                    ldb       #6                  Transfer 6 bytes
                    stb       DOTCNT              Save counter
SBLOOP              lda       ,X
                    ldb       ,Y
                    sta       ,Y+
                    stb       ,X+
                    dec       DOTCNT
                    bne       SBLOOP

******************************
NEWSC1              leax      SELECT,pcr          *---- Remark out for testing
                    ldy       #2                  *
                    lbsr      OUTST2              *
******************************

                    ldx       #75
                    lbsr      WAIT
                    lda       PLAYRS              Check for 1 or 2 players
                    beq       ONEPLR
                    lbsr      BELL
                    leax      GETRD1,pcr
                    lda       PLCRNT              Get current player
                    cmpa      #1
                    beq       PUTPLR
                    leax      GETRD2,pcr
PUTPLR              ldy       #29                 Output 29 bytes
                    lbsr      POPUP
                    bra       NEWSC2

                    ldx       #75
                    lbsr      WAIT

                    lbsr      BELL

ONEPLR              leax      GETRDY,pcr
                    ldy       #12
                    lbsr      POPUP               Do popup and output GETRDY

NEWSC2              bsr       NEWSCN              Erase ghosts & pacman
                    lda       PLAYRS              Check for 1 or 2 players
                    beq       SKIPTR

                    lbsr      TRANSF              Transfer table to array

SKIPTR              nop
                    ldx       #50
                    lbsr      WAIT

                    lbsr      BELL

                    leax      SELECT,pcr
                    ldy       #2
                    lbsr      OUTSTR

                    leax      POPEND,pcr
                    ldy       #15
                    lbsr      OUTST2

                    lbra      MAIN

*   New screen routines

NEWSCN              ldd       PXNEW               First erase pacman
                    std       PXLOC
                    ldd       PYNEW
                    std       PYLOC
                    lda       #37                 Blank round pacman
                    sta       PBFN
                    lbsr      PUTBLK
*   Now erase ghosts
                    lda       #1
                    sta       PGBFN
                    lda       #80
                    sta       GCOUNT
GHRSET              lda       GCOUNT
                    suba      #20
                    bmi       GHRST2
                    sta       GCOUNT
                    leax      G1OFST,U
                    leax      A,X
                    ldd       2,X
                    std       PGXLOC
                    ldd       4,X
                    std       PGYLOC
                    lbsr      PUTGHT
                    bra       GHRSET
GHRST2              lbsr      GHDATA
*    Reset palette registers
                    leax      PALST1,pcr
                    ldy       #16
                    lbsr      OUTSTR

*    Clear and setup array
*    Only clear array and dot total at start of game

                    ldd       DOTTOT              Check dot total
                    cmpd      SCNTOT              Cleared screen ?
                    beq       NEWBRD

                    lda       PLAYRS              Check for 2 player mode
                    beq       PTDOTS

                    lda       BRDNUM
                    cmpa      BRDTMP              Are players on same board?
                    beq       SETVR2

                    leax      ERSCRN,pcr          Erase scrn, leave score
                    ldy       #4                  Output 4 bytes
                    lbsr      OUTSTR
                    lbsr      BOARDB              Go draw players board
                    leax      SETCOL,pcr          Reset foreground color
                    ldy       #3                  Output 3 bytes
                    lbsr      OUTSTR
                    bra       SETVR2

NEWBRD              dec       SCNFLG
                    bne       NEWBR2
                    lda       #2
                    sta       SCNFLG              Reset screen flag to 2
                    lda       BRDNUM              Get board number
                    inca
                    cmpa      #9                  Only 8 boards
                    bne       GETBRD
                    lda       #1                  Reset board to #1
GETBRD              sta       BRDNUM              Save new board number
                    leax      ERSCRN,pcr          Erase scrn, leave score
                    ldy       #4                  Output 4 bytes
                    lbsr      OUTSTR
                    lbsr      BOARDB              Go draw new board
                    leax      SETCOL,pcr          Reset forgroung color
                    ldy       #3
                    lbsr      OUTSTR
NEWBR2              lbsr      CLRARR              Clear array, fill with dots
                    ldd       #0
                    std       DOTTOT              Reset dot total

*    Redraw DOTS and PILLS that may have been
*     partially erased by ghosts or pacman

PTDOTS              lbsr      PDOTS

RSTBON              lbsr      RESBON              Go reset bonus

*    Reset pacman variables
SETVR2              ldd       #308
                    std       PXNEW
                    std       PCXLOC
                    std       PXLOC,U
                    ldd       #94
                    std       PYNEW
                    std       PCYLOC
                    std       PYLOC,U
                    lda       #28
                    sta       BUFF
                    sta       PBFN,U
                    lbsr      PUTBLK              Put starting pacman
                    ldd       #1966
                    std       POFSET
                    lda       #3
                    sta       CYCLE
                    lda       #80
                    sta       GCOUNT
                    clr       HITFLG
                    clr       POWFLG

RETURN              rts                           Return to  main loop

*   Transfer player table to array & array to table
*   Used to save one players screen when switching
*   to second player.


TRANSF              leay      TABLE1,U            Point to player 1 table
                    lda       PLCRNT,U
                    cmpa      #2                  Is new player #2 ?
                    beq       TRFPUT
                    leay      TABLE2,U            Point to player 2 table
TRFPUT              leax      ARRAY,U             Point to start of array
                    leax      70,X                Move to first dot location
                    clr       DOTCNT
TRLOOP              inc       DOTCNT              Bump dot counter
                    lda       ,X                  Get a byte from array
                    ldb       ,Y                  Get a byte from table
                    sta       ,Y+                 Put array byte in table
                    stb       ,X++                Put byte in array,bump pointer
                    lda       DOTCNT              Get dot counter
                    cmpa      #34                 Done 34 yet?
                    bne       TRLOOP
                    cmpx      #ARREND-69          Are we done?
                    bge       TRCLR
                    leax      139,X               Move down 2 lines in array
                    clr       DOTCNT
                    bra       TRLOOP

TRCLR               lbsr      CLRARR              Go clear and setup array

                    leay      TABLE1,U            Point to player 1 table
                    lda       PLCRNT,U
                    cmpa      #1                  Is new player #1 ?
                    beq       TFRPT2
                    leay      TABLE2,U            Point to player 2 table
TFRPT2              leax      ARRAY,U             Point to start of array
                    leax      70,X
                    clr       DOTCNT
TRLOP2              inc       DOTCNT
                    lda       ,X
                    ldb       ,Y
                    sta       ,Y+
                    stb       ,X++
                    lda       DOTCNT
                    cmpa      #34
                    bne       TRLOP2
                    cmpx      #ARREND-69
                    bge       TRDONE
                    leax      139,X
                    clr       DOTCNT
                    bra       TRLOP2

TRDONE              lbsr      PDOTS               Go put dots on screen

*    Transfer players bonus variables (2 player mode only)
*     Erase last players bonus items from screen

TRFBON              lda       #69                 Blank Bonus
                    sta       PBFN,U
                    ldd       BONUSX              Get scrn x value
                    std       PXLOC,U
                    ldd       BONUSY              Get scrn Y value
                    std       PYLOC,U
                    lda       BONCNT              Get count of items
                    inca
                    sta       BONTMP
TBLOOP              dec       BONTMP
                    beq       TRBON2              Leave routine if 0
                    lbsr      PUTBLK              Go erase item
                    ldd       PXLOC,U
                    subd      #28
                    std       PXLOC,U
                    bra       TBLOOP

*    Now transfer bonus variables

TRBON2              lda       #15                 Transfer 15 bytes
                    sta       BONTMP
                    leax      BONUSX,U            Point to first block
                    leay      BTEMP,U             Point to second block
TLOOP2              lda       ,X
                    ldb       ,Y
                    sta       ,Y+
                    stb       ,X+
                    dec       BONTMP
                    bne       TLOOP2

*    Now put new players bonus items on screen

PBONUS              ldd       #8
                    std       PXLOC,U
                    ldd       #181
                    std       PYLOC,U
                    leax      BONTAB,U            Point to table
                    stx       BONTMP              Save table pointer
                    lda       BONCNT
                    beq       PBDONE
PBLOOP              pshs      A                   Save count
                    ldd       PXLOC,U
                    addd      #28
                    std       PXLOC,U
                    ldx       BONTMP              Get pointer
                    ldb       ,X+                 Get next table item
                    stb       PBFN,U
                    stx       BONTMP              Save pointer
                    lbsr      PUTBLK              Go put item on screen
                    puls      A
                    deca                          Decrement counter
                    bne       PBLOOP

*  Pacman may have to be put back on screen here

PBDONE              rts

*   Reset bonus variables

RESBON              lda       BONFLG              Check flag
                    beq       RESBN2              If 0, bonus not on screen
                    ldd       #310
                    std       PXLOC
                    ldd       #95
                    std       PYLOC
                    lda       #69
                    sta       PBFN
                    lbsr      PUTBLK              Erase bonus from screen
                    leax      ARRAY,U
                    ldd       #1966
                    leax      D,X
                    clr       ,X                  Erase bonus from array
                    clr       BONFLG
RESBN2              lda       #69
                    sta       BONBUF              Reset bonus buffer #
                    lda       #250
                    sta       BONTIM              Reset bonus timer
                    rts

*    Bonus was eaten by pacman, so erase it
*    and put it at bottom of screen

SETBON              ldd       #310                X scrn location of bonus
                    std       PXLOC,U
                    ldd       #95                 Y scrn location of bonus
                    std       PYLOC,U
                    lda       #69                 Number for blank bonus
                    sta       PBFN,U
                    lbsr      PUTBLK              Go erase bonus
*    Restore pacman (if erased)
                    leax      PUTPACM,U
                    ldy       #8
                    lda       PATH
                    os9       I$Write
                    lbcs      ERR1
*    Make noise

                    ldx       #$3f01
                    ldy       #3850
                    lbsr      SND
                    ldx       #$3401
                    ldy       #4000
                    lbsr      SND

                    leax      BONTAB,U            Point to item table
                    lda       BONCNT
                    leax      A,X                 Move to next table location
                    ldb       BONBUF              Get buffer number
                    stb       ,X                  Put it in table

                    ldd       BONUSX
                    addd      #28                 Move to next location
                    std       BONUSX              Save new location
                    std       PXLOC,U
                    ldd       BONUSY
                    std       PYLOC,U
                    lda       BONBUF              Get Bonus buffer number
                    sta       PBFN,U
                    lbsr      PUTBLK              Put bonus at bottom of scrn
                    inc       BONCNT              Bump bonus counter
                    rts

*    When screen has been cleared, give an additional
*    100 points for each bonus at bottom of screen.
*    Erase bonus item at bottom as it is added up.

CNTBON              lda       BONCNT              Check for 0 bonus's
                    beq       CTRTS               If zero, then return
                    ldd       BONUSY
                    std       PYLOC,U
                    lda       #69                 Blank Bonus
                    sta       PBFN,U
                    ldd       BONUSX
                    std       PXLOC,U
CTLOOP              lbsr      PUTBLK              Go erase bonus item

*     Make noise

                    ldx       #$3f02
                    ldy       #4000
                    lbsr      SND
                    ldx       #$3f03
                    ldy       #3800
                    lbsr      SND
                    ldx       #$3f02
                    ldy       #4000
                    lbsr      SND

*     Bump score

                    lda       #1                  Add 100 points to score
                    sta       POINTS+1
                    clr       POINTS+2
                    lbsr      ADDUP
                    dec       BONCNT              Decrement bonus counter
                    beq       CTDONE
                    ldd       PXLOC,U
                    subd      #28                 Move to next item
                    std       PXLOC,U
                    bra       CTLOOP

CTDONE              clr       POINTS+1
                    ldd       #8
                    std       BONUSX

CTRTS               rts



                    endsect



