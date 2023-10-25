
                    nam       Score
                    ttl       Routines to handle high score recording

*     Program segment to be compiled using Level II RMA
*          This is not a mainline program segment
*                 Written by Larry Olson

                    ifp1
*         use   /dd/defs/os9defs.a
                    endc

STACK               equ       100

                    section   bss

*     Local Variables

FPATH               rmb       1                   File path number
FSCORE              rmb       126                 Names & scores put here
PNAME               rmb       15                  Players name
NAMLGH              rmb       2                   Number of characters in name
ENTCNT              rmb       1                   Entry counter
ENTPNT              rmb       2                   Pointer to start of entry
COUNT               rmb       1
SAVEX               rmb       2
CURPOS              rmb       3

                    rmb       STACK

                    endsect

                    section   code

FILLST              fcc       '/dd/sys/pac_scores'

WRTNBY              fcb       2,37,33,87,114,105,116,116
                    fcb       101,110,32,66,121,$1b,$32,1,2
                    fcb       35,36,76,97,114,114,121,32
                    fcb       69,46,32,79,108,115,111,110

LDGSCR              fcb       2,33,34,76,111,97,100,105,110
                    fcb       103,32,72,105,103,104,32,83
                    fcb       99,111,114,101,115

ENTNAM              fcb       $1b,$32,1,$1b,$33,0,$0c,2,33,33
                    fcb       80,76,69,65,83,69,32
                    fcb       69,78,84,69,82,32,89,79
                    fcb       85,82,32,78,65,77,69,32

ARROW               fcb       $1b,$32,2,2,34,35,45,45,62
                    fcb       32,$1b,$32,3,95,2,38,35

QUESTN              fcb       $1b,$32,9,2,32,35,32,73,115,32
                    fcb       78,97,109,101,32,67,111,114,114
                    fcb       101,99,116,32,40,89,47,78,41,32,63
                    fcb       2,55,35

CONGRT              fcb       2,37,33,$1b,$32,2,67,79,78
                    fcb       71,82,65,84,85,76,65,84,73
                    fcb       79,78,83,$1b,$32,4,2,38,35

NOTFND              fcb       $0c,$1b,$32,4,2,37,32,83,99,111
                    fcb       114,101,32,70,105,108,101,$1b,$32
                    fcb       2,2,34,34,47,100,100,47,115,121
                    fcb       115,47,112,97,99,95,115,99,111
                    fcb       114,101,115,$1b,$32,4,2,38,36
                    fcb       78,79,84,32,70,79,85,78,68

CREATE              fcb       2,38,36,32,32,32,32,32,32,32,32
                    fcb       32,2,37,36,67,114,101,97,116
                    fcb       105,110,103,32,73,116

CHGWK1              fcb       $1b,$25,0,0,40,24
                    fcb       $1b,$33,7

CHGWK2              fcb       $1b,$25,8,9,22,7,2,32,32

CRLF                fcb       $0d,$0a

CLRSCN              fcb       $0c

CURXY1              fcb       2,32,32

CURXY2              fcb       $0c,2,38,33,$1b,$32,4

CLNORM              fcb       $1b,$32,2,$1b,$33,0

CLINVT              fcb       $1b,$32,4,$1b,$33,0

CLNRM2              fcb       $1b,$32,2,$1b,$33,0


SBEGIN              leax      SCRBOX,pcr
                    ldy       #39
                    lbsr      OUTST2
                    leax      WRTNBY,pcr
                    ldy       #33
                    lbsr      OUTST2
                    ldx       #200
                    lbsr      WAIT
                    leax      CLRSCN,pcr
                    ldy       #1
                    lbsr      OUTST2
                    leax      LDGSCR,pcr
                    ldy       #22
                    lbsr      OUTST2
                    ldx       #75
                    lbsr      WAIT

OPENFL              lda       #1                  Set for read
                    leax      FILLST,pcr          Point to pathlist
                    os9       I$Open              Open file
                    lbcs      OPNERR              Go handle any errors
                    sta       FPATH,U
READFL              leax      FSCORE,U            Point to data storage area
                    ldy       #126                Read entire file (126 bytes)
                    os9       I$Read              Go do read
                    lbcs      REDERR              Go handle any errors
*    Close file
                    lda       FPATH,U
                    os9       I$Close
                    lbcs      ERR1

                    leax      CLRSCN,pcr
                    ldy       #1
                    lbsr      OUTST2

                    lbsr      PRFIL2              Print score data
                    leax      CHGWK1,pcr          Reset screen 0,0,40,24
                    ldy       #9
                    lbsr      OUTST2
                    rts

SCEND               lda       #0
                    sta       ENTCNT,U
                    lda       #2
                    sta       CURPOS,U
                    lda       #32
                    sta       CURPOS+1,U

                    lbsr      SCRCMP              Compare players score
                    lda       ENTCNT,U
                    cmpa      #-1
                    beq       SCRTN

OPNFL2              lda       #2                  Set to write
                    leax      FILLST,pcr
                    os9       I$Open
                    lbcs      ERR1
                    sta       FPATH,U
WRITFL              leax      FSCORE,U
                    ldy       #126
                    os9       I$Write
                    lbcs      ERR1
                    lda       FPATH,U
                    os9       I$Close
                    lbcs      ERR1

                    ldx       #100
                    lbsr      WAIT
SCRTN               rts

*   File data has been put in memory
*   now print it on screen
*   This is used for path2
PRFIL2              leax      CLNRM2,pcr
                    ldy       #6
                    lbsr      OUTST2
                    leax      CURXY1,pcr
                    ldy       #3
                    lbsr      OUTST2
                    leax      FSCORE,U
                    leax      -21,X
                    ldb       #7
                    pshs      B,X
PLOOP2              puls      B,X
                    decb
                    beq       PDONE2
                    leax      21,X
                    pshs      B,X
                    ldy       #21
                    lbsr      OUTST2
                    leax      CRLF,pcr
                    ldy       #2
                    lbsr      OUTST2
                    bra       PLOOP2

PDONE2              rts

SCRCMP              lda       #0                  Set entry count to zero
                    ldb       #0
                    sta       ENTCNT,U            Save it
                    std       ENTPNT,U            Set entry pointer
                    leay      FSCORE,U            Point to start of data
SCLOOP              leay      15,Y                Move to first score
                    leax      SCRASC-1,U          Point to players score -1
                    ldb       #7                  Set byte counter
SCLOP2              decb                          Decrement counter
                    beq       NEXTCK              If =, go get next score
                    lda       ,Y+                 Get hi-score byte
                    leax      1,X                 Bump player score pointer
                    cmpa      ,X                  Compare them
                    beq       SCLOP2              If =, go check next byte
                    blo       MOVE                If <, insert players name

NEXTCK              lda       ENTCNT,U            Get entry counter
                    inca                          Bump it
                    cmpa      #6                  Done 6 yet ?
                    bne       NEXT                Score not higher, Print old data
                    lda       #-1
                    sta       ENTCNT,U
                    bra       PRFILE

NEXT                sta       ENTCNT,U            Save count
                    leay      FSCORE,U
                    ldb       #21
                    mul
                    leay      D,Y
                    std       ENTPNT,U
                    bra       SCLOOP

*        This routine is used to insert the
*        player's score into the hi-scores
*   Move name & score data down to allow player's
*   name & score to be inserted. This will remove
*   the last item from the list

MOVE                lda       #5                  Set constant
                    suba      ENTCNT,U            Subtract entry counter
                    ldb       #21                 Set multiplier
                    mul                           B reg. holds loop counter
                    leax      FSCORE,U            Point to start of data
                    leax      126,X               Move to last byte entry 6 +1
                    leay      FSCORE,U
                    leay      105,Y               Move to last byte entry 5 +1
                    cmpd      #0                  If on bottom, then don't
                    beq       PUTIT               move any down
INLOOP              lda       ,-Y                 Get a byte
                    sta       ,-X                 Move it
                    decb                          Decrement counter
                    bne       INLOOP

*   Now zero(underline) out previous entry at this location

PUTIT               ldb       #15                 Set byte counter
                    lda       #95                 ASCII underline chacarter
PUTLOP              decb                          Decrement counter
                    beq       PUTSCR
                    sta       ,Y+                 Store a '_' character
                    bra       PUTLOP              Loop till 15 are done
*   Now transfer players score
PUTSCR              lda       #32                 Space character
                    sta       ,Y+
                    ldb       #7                  Set transfer byte counter
                    leax      SCRASC,U            Point to players ascii score
PLOOP               decb                          Decrement counter
                    beq       PRFILE              If 0, then exit
                    lda       ,X+                 Get byte & increment X
                    sta       ,Y+                 Put byte & increment Y
                    bra       PLOOP
*   File data has been put in memory
*   now print it on screen
*   This is used for path
PRFILE              leax      CLNORM,pcr
                    ldy       #6
                    lbsr      OUTST2
                    leax      CHGWK2,pcr
                    ldy       #9
                    lbsr      OUTST2
                    leax      FSCORE,U
                    leax      -21,X
                    lda       #-1
                    ldb       #7
                    pshs      D,X
PRLOOP              puls      D,X
                    decb
                    beq       PRDONE
                    leax      21,X                Point to line to print
                    inca                          Increment compare count
                    pshs      D,X
                    cmpa      ENTCNT,U            Are we on the new line ?
                    bne       NORMPR
                    stx       SAVEX,U             Save X register
                    leax      CLINVT,pcr          Invert screen colors
                    ldy       #6
                    lbsr      OUTST2
                    ldx       SAVEX,U             Get X register value
                    ldy       #21                 Output 21 bytes
                    lbsr      OUTST2
                    leax      CRLF,pcr            Do a carriage return
                    ldy       #2                  and a line feed
                    lbsr      OUTST2
                    leax      CLNORM,pcr          Reset screen colors
                    ldy       #6
                    lbsr      OUTST2
                    bra       PRLOOP

NORMPR              ldy       #21
                    lbsr      OUTST2
                    leax      CRLF,pcr
                    ldy       #2
                    lbsr      OUTST2
                    bra       PRLOOP

PRDONE              lda       ENTCNT,U
                    cmpa      #-1
                    lbeq      RDDONE

OPNBOT              ldx       #100
                    lbsr      WAIT
                    leax      BOTWIN,pcr
                    ldy       #47
                    lbsr      OUTST2

PNAMLP              leax      ENTNAM,pcr          Print 'Please enter your name'
                    ldy       #33                 Output 34 bytes
                    lbsr      OUTST2

                    leax      ARROW,pcr           Print '-->_'
                    ldy       #17
                    lbsr      OUTST2

*   Now get players name

GETNAM              leax      PNAME,U             Fill name storage
                    lda       #32                 with spaces
                    ldb       #15
PNLOOP              sta       ,X+
                    decb
                    bne       PNLOOP

RDNAME              leax      PNAME,U             Get name from player
                    ldy       #15                 14 + CR
                    lda       PATH2,U
                    os9       I$ReadLn
                    lbcs      ERR1
                    tfr       Y,D

                    leax      PNAME,U
                    subd      #1
                    leax      D,X
                    std       NAMLGH,U
                    lda       #32
                    sta       ,X                  Remove CR

NAMEOK              ldd       NAMLGH,U
                    cmpd      #0
                    beq       NAMASK

                    leax      CURXY2,pcr          Clear screen, Move to XY
                    ldy       #7                  location 6,0
                    lbsr      OUTST2              and set color

                    leax      PNAME,U
                    ldy       NAMLGH,U
                    lbsr      OUTST2

NAMASK              leax      QUESTN,pcr
                    ldy       #33
                    lbsr      OUTST2

                    lbsr      READ2
                    lda       RESPON,U
                    cmpa      #89
                    beq       PUTNAM
                    cmpa      #121
                    beq       PUTNAM
                    leax      CLRSCN,pcr
                    ldy       #1
                    lbsr      OUTST2

                    lbra      PNAMLP

PUTNAM              leax      BOTEND,pcr
                    ldy       #15
                    lbsr      OUTST2

                    leax      PNAME,U
                    leay      FSCORE,U
                    ldd       ENTPNT,U
                    leay      D,Y
                    ldb       #14
PUTNML              lda       ,X+
                    sta       ,Y+
                    decb
                    bne       PUTNML

                    lda       ENTCNT,U
                    adda      #32
                    sta       CURPOS+2,U

                    leax      CURPOS,U
                    ldy       #3
                    lbsr      OUTST2

                    leax      FSCORE,U
                    ldd       ENTPNT,U
                    leax      D,X
                    ldy       #21
                    lbsr      OUTST2

                    leax      BOTWIN,pcr
                    ldy       #47
                    lbsr      OUTST2

                    leax      CONGRT,pcr
                    ldy       #27
                    lbsr      OUTST2

                    leax      PNAME,U
                    ldy       NAMLGH,U
                    lbsr      OUTST2

RDDONE              ldx       #200
                    lda       ENTCNT,U
                    cmpa      #-1
                    beq       RDWAIT
                    ldx       #150
RDWAIT              lbsr      WAIT                Sleep for 150 or 200 ticks
                    lda       ENTCNT,U
                    cmpa      #-1
                    beq       RDEXIT

                    leax      BOTEND,pcr
                    ldy       #15
                    lbsr      OUTST2
RDEXIT              rts

*   Handle file errors here
*   214- no permission
*   216- path name not found
*

OPNERR              cmpb      #216                Is it PATH NAME NOT FOUND ?
                    lbne      ERR1
*   Print Creating score file
                    leax      NOTFND,pcr
                    ldy       #56
                    lbsr      OUTST2
                    ldx       #75
                    lbsr      WAIT
FILLSC              leax      FSCORE,U            Point to data area
                    ldb       #7                  Set counter
                    stb       COUNT,U
DMLOOP              lda       COUNT,U
                    deca
                    beq       CRFILE
                    sta       COUNT,U             Save new count
                    ldb       #15
                    lda       #46                 '.'
DLOOP2              decb
                    beq       SPACE
                    sta       ,X+                 Put 14 '.' in data area
                    bra       DLOOP2
SPACE               lda       #32                 ' '
                    sta       ,X+                 Put a space in data area
                    lda       #32                 Space
                    ldb       #6
DLOOP3              decb
                    beq       DZERO
                    sta       ,X+                 Put 5 spaces in data area
                    bra       DLOOP3
DZERO               lda       #48                 '0'
                    sta       ,X+
                    bra       DMLOOP

*   File doesn't exist, so create it

CRFILE              leax      CREATE,pcr
                    ldy       #26
                    lbsr      OUTST2
                    leax      FILLST,pcr          Point to path list
                    lda       #2                  Access mode (2=write)
                    ldb       #47                 Attributes (00101111)
                    os9       I$Create            Go create file
                    lbcs      ERR1
                    sta       FPATH,U             Save path #
*   Write data to file
WRTFIL              leax      FSCORE,U            Point to data
                    ldy       #126                Write 126 bytes
                    lda       FPATH,U             Set path #
                    os9       I$Write             Do write
                    lbcs      ERR1
*   Now close file
CLSFIL              lda       FPATH,U
                    os9       I$Close
                    lbcs      ERR1
                    ldx       #75
                    lbsr      WAIT

                    rts

REDERR              lbra      ERR1


                    endsect


