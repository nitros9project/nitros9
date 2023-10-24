
                    nam       MAIN
                    ttl       Main pacman routine

*     Program segment to be compiled using Level II RMA
*           This is the mainline program segment
*                 Written by Larry Olson

                    ifp1
*         use    /dd/defs/os9defs.a
                    endc

                    section   __os9
TYPE                equ       $11                 Prgrm($10)+Objct($01)
ATTR                equ       $80                 REEntrent
REV                 equ       $01                 Revision level
EDITION             equ       2                   EDITION #2
                    endsect

STACK               equ       500
UPDAT               equ       3

                    section   bss

*    Local and global variables

ARRAY               export
ARREND              export
BONBUF              export
BONCNT              export
BONFLG              export
BONTAB              export
BONTIM              export
BONTMP              export
BONUSX              export
BONUSY              export
BRDNUM              export
BRDTMP              export
BTEMP               export
BUFF                export
BUTTON              export
CYCLE               export
DOTTMP              export
DOTTOT              export
EXTPAC              export
EXTPC2              export
G1OFST              export
G2OFST              export
G3OFST              export
G4OFST              export
GCOUNT              export
GHTABL              export
GHTHIT              export
HITFLG              export
HSCASC              export
JOYSTX              export
JOYSTY              export
MOVFLG              export
PACMAN              export
PACMN1              export
PACMN2              export
PALBT1              export
PATH2               export
PATH                export
PBFN                export
PCBFN               export
PCXLOC              export
PCYLOC              export
PDBFN               export
PDXLOC              export
PDYLOC              export
PGBFN               export
PGXLOC              export
PGYLOC              export
PLAYRS              export
PLCRNT              export
POFSET              export
POINTS              export
PORT                export
POWFLG              export
PROCID              export
PUTGHS              export
PUTPACM             export
PXLOC               export
PXNEW               export
PYLOC               export
PYNEW               export
RESPON              export
SCNFLG              export
SCNNUM              export
SCNTOT              export
SCRASC              export
SCRBCD              export
SCRPO2              export
SCRPOS              export
SHCNT               export
SNDPR1              export
SNDPR2              export
STRING              export
STRLGH              export
TABLE1              export
TABLE2              export

SIGCODE             rmb       1                   Intercept signal RMB
PATH                rmb       1                   Screen path number
PATH2               rmb       1                   Second screen path number
WINDOW              rmb       1                   Holds 0 or 2 to keep track
*                          of which window is being used
PROCID              rmb       1                   Holds process id
RESPON              rmb       2                   Holds response bytes


PORT                rmb       2                   Joystick port (0=right,1=left)
BUTTON              rmb       1                   Joystick button status
JOYSTX              rmb       2                   Joystick X value
JOYSTY              rmb       2                   Joystick Y value

PLAYRS              rmb       1                   Holds 0 or 1 (for 1 or 2 players)

PACMN1              rmb       1                   Holds number of pacmen left(player1)
PACMN2              rmb       1                   Holds number of pacmen left(player2)
PLCRNT              rmb       1                   Holds current player number(1 or 2)
PACMAN              rmb       1                   Holds current number of men left
*                         this will be either PACMN1 or PACMN2

PXNEW               rmb       2                   New pacman X position
PYNEW               rmb       2                   New pacman Y position
POFSET              rmb       2                   Pacman offset from start of array
BUFF                rmb       1                   Holds current pacman buffer #

CYCLE               rmb       1                   Used to cycle between buffers

HITFLG              rmb       1                   A 1 here = pacman caught
GHTHIT              rmb       1                   Ghost hit flag
POWFLG              rmb       1                   When pacman eats a power pill then
*                         this location holds a timer value

BONFLG              rmb       1                   Bonus on screen flag
BONTIM              rmb       1                   Bonus timer
BONBUF              rmb       1                   Current bonus buffer
BONUSX              rmb       2                   Bonus X location at bottom of scrn
BONUSY              rmb       2                   Bonus Y location at bottom of scrn
BONCNT              rmb       1                   Bonus counter
BONTAB              rmb       10                  Bonus item table

BONTMP              rmb       2                   Temporary storage
BTEMP               rmb       15                  Used to hold BONUSX,BONUSY,BONCNT
*                          and BONTAB  for 2 player mode
SNDPR1              rmb       2
SNDPR2              rmb       2

*     Ghost tables, One 20 byte table for each ghost

G1OFST              rmb       2                   Ghost position offset from start of array
G1XNEW              rmb       2                   Screen X location of ghost
G1YNEW              rmb       2                   Screen Y location of ghost
G1XOLD              rmb       2                   Pseudo scrn X location of ghost
G1YOLD              rmb       2                   Pseudo scrn Y location of ghost
G1STAT              rmb       1                   Status flag for ghost
*                          -2 = Eyes are caged,timer not run out
*                          -1 = Ghost caged,timer not run out
*                           0 = Ghost still in cage but moving out
*                           1 = Ghost is free of cage,can move around
*                           2 = Ghost has been turned into eyes
G1BUFF              rmb       1                   Holds current buffer # for ghost
G1TIME              rmb       1                   Ghost time out counter
TIMVAL              rmb       1                   Ghost initial time out value
G1DIR               rmb       1                   Ghost dir. (0=up,1=lf,2=rt,3=dn)
DIROFF              rmb       1                   Direction offset (-69,-1,1,69)
G1UPDT              rmb       1                   Holds update value to be count down
UPDATE              rmb       1                   Initial update value
                    rmb       2                   Extra bytes

G2OFST              rmb       20                  Table for ghost #2

G3OFST              rmb       20                  Table for ghost #3

G4OFST              rmb       20                  Table for ghost #4

GCOUNT              rmb       1                   Holds num (0,20,40,60) of current ghost

SCRPOS              rmb       3                   Player 1 score xy print position
SCRASC              rmb       6                   Score ascii characters put here
SCRBCD              rmb       3                   Contains score in BCD
POINTS              rmb       3                   Points that will be added to score
SHCNT               rmb       1                   Temporary loop counter

***********  These are used in 2 player mode  ***********

SCRPO2              rmb       3                   Player 2 score xy print position
SCRAS2              rmb       6                   Score ascii characters put here
SCRBC2              rmb       3                   Contains score in BCD

DOTTOT              rmb       2                   Dot eaten total, used to show when
*                          screen has been cleared
SCNTOT              rmb       2                   Total number of dots for
*                           The current screen
BRDNUM              rmb       1                   Holds # of current board(starts at 1)
SCNFLG              rmb       1                   Screen flag, starts at 2, is decremented
*                          when a scrn is cleared. When 0 a new
DOTTMP              rmb       2                   Holds dot eaten total in 2 player mode
SCTOT2              rmb       2                   Holds scrn dot total in 2 player mode
*                          screen is issued.
BRDTMP              rmb       1                   Holds board # in 2 player mode
SCFTMP              rmb       1                   Holds screen flag in 2 player mode

DOTCNT              rmb       2                   Dot counter in transfer routine

RANNUM              rmb       1                   Random number variable
ADDEND              rmb       1                   Used in random number generator
SAVEX               rmb       2                   Save X reg. in random routine

RSFLAG              rmb       1                   Restart game flag

PUTPACM             rmb       2                   $1b,$2d will be put here
PCGBN               rmb       1                   Group buff#, Process ID put here
PCBFN               rmb       1                   Buffer number
PCXLOC              rmb       2                   Putpacm X location
PCYLOC              rmb       2                   Putpacm Y location

PUTCODE             rmb       2                   $1b,$2d will be put here
PGBN                rmb       1                   Group buff#, Process ID put here
PBFN                rmb       1                   Buffer number
PXLOC               rmb       2                   Putblk X location
PYLOC               rmb       2                   Putblk Y location

PUTGHS              rmb       2                   $1b,$2d will be put here
PGGBN               rmb       1                   Group buff#, Process ID +1 put here
PGBFN               rmb       1                   Buffer number
PGXLOC              rmb       2                   PUTGHS X location
PGYLOC              rmb       2                   PUTGHS Y location

DOTCODE             rmb       2                   $1b,$2d will be put here
PDGBN               rmb       1                   Group buff#, Process ID put here
PDBFN               rmb       1                   Buffer number
PDXLOC              rmb       2                   Putdot X location
PDYLOC              rmb       2                   Putdot Y location

XSAVE               rmb       2                   Temp. storage for X reg.

STRLGH              rmb       1                   Length of palette set string to send
STRING              rmb       16                  Build palette set string here

PALBT1              rmb       4
PALBT2              rmb       4

HISPOS              rmb       3                   High score screen print position
HSCASC              rmb       6                   High score ascii characters

KILBUF              rmb       4                   $1b,$2a,procid,0 will be put here
KILBF2              rmb       4                   $1b,$2a,procid +1,0 will be put here

MOVFLG              rmb       1                   Delay flag used in movpac

EXTPAC              rmb       1                   Extra pacman match number

EXTPC2              rmb       1                   Holds match number in 2 player mode

*   32 byte area for SS.Mouse packet
*   only used for Pt.Valid info
MOUSE               rmb       1                   Pt. Valid
                    rmb       31                  not used

GHTABL              rmb       80                  Duplicate ghost data table

TABLE1              rmb       612                 Used to save screen info for
*                          player 1 in 2 player mode
TABLE2              rmb       612                 Used to save screen info for
*                          player 2 in 2 player mode.
SCNNUM              rmb       12                  Screen number


                    rmb       150

ARRAY               rmb       3726
ARREND              rmb       4
                    rmb       150

                    rmb       STACK

                    endsect

                    section   code

PTHLST              fcs       "/W"
DWSET               fcb       $1B,$20,08,00,00,40,24,01,02,02
DWEND               fcb       $1B,$24
SELECT              fcb       $1b,$21
CLEAR               fcb       $0C
CLREND              fcb       $0b
CUROFF              fcb       $05,$20
BOLDSW              fcb       $1b,$3d,1
BELCOD              fcb       $07
PLLST1              fcb       $1b,$31,7,7,$1b,$33,7,$1b,$34,7
PLLST2              fcb       $1b,$31,6,25,$1b,$31,14,25
SCNRST              fcb       $1b,$25,0,0,40,24
POPWIN              fcb       $07,$1b,$25,7,8,24,9,$1b,$22
                    fcb       1,0,0,22,7,2,0,$0c

POPEND              fcb       $07,$1b,$23,$1b,$25,8,9,22,7
                    fcb       $1b,$32,1,$1b,$33,0

BOTWIN              fcb       $1b,$25,0,0,40,24,$07
                    fcb       $1b,$22,1,5,15,28,8,0,2,$0c
                    fcb       $1b,$25,1,1,27,7,$1b,$33,2,$0c
                    fcb       $1b,$25,0,0,27,7,$1b,$33,4,$0c
                    fcb       $1b,$25,1,1,25,5,$1b,$33,0,$0c

BOTEND              fcb       7,$1b,$23,$1b,$25,8,9,23,8
                    fcb       $1b,$32,1,$1b,$33,0

TITLE               fcb       $1b,$33,2,$1b,$25,13,1,11,5
                    fcb       $0c,$1b,$33,1,$1b,$25,12,0,11
                    fcb       5,$0c,$1b,$32,2,$1b,$33,0,$1b
                    fcb       $25,13,1,9,3,$0c,2,33,33,80
                    fcb       65,67,45,79,83,57

SCRBOX              fcb       $1b,$33,2,$1b,$25,7,8,25,10,$0c
                    fcb       $1b,$33,1,$1b,$25,6,7,25,10,$0c
                    fcb       $1b,$32,2,$1b,$33,0,$1b,$25,7,8
                    fcb       23,8,$0c,$1b,$25,8,9,22,7

*    Select Start Screen # ?
STRSCN              fcb       2,35,36,83,116,97,114,116,32
                    fcb       83,99,114,101,101,110,32,35
                    fcb       32,63,2,50,36
*    Select Joystick Port
*     (L)eft or (R)ight --> ?
SELJOY              fcb       2,33,33,83,101,108,101,99,116,32
                    fcb       74,111,121,115,116,105,99,107,32
                    fcb       80,111,114,116,2,34,35,66,121,32
                    fcb       80,114,101,115,115,105,110,103,32
                    fcb       66,117,116,116,111,110

*    LEFT
LFTSTR              fcb       $1b,$32,4,2,34,37,76,69,70,84,32
                    fcb       80,79,82,84,32
*    RIGHT
RGTSTR              fcb       $1b,$32,4,2,34,37,82,73,71,72,84
                    fcb       32,80,79,82,84
SLCTED              fcb       $1b,$32,2,2,44,37,83,101
                    fcb       108,101,99,116,101,100

*    Number of players
*      (1 or 2) ?
PLYSTR              fcb       2,34,33,78,117,109,98,101,114,32
                    fcb       111,102,32,80,108,97,121,101,114,115
                    fcb       $1b,$32,3,2,33,34,40,106,111,121,115
                    fcb       116,105,99,107,32,77,111,118,101,115
                    fcb       32,66,111,120,41,$1b,$32,4,2,38,36
                    fcb       49,2,47,36,50,$1b,$32,1,2,34,38,83
                    fcb       101,108,101,99,116,32,87,105,116
                    fcb       104,32,66,117,116,116,111,110

CURXY               fcb       2,62,54

CURXY1              fcb       2,61,54

CURXY2              fcb       2,47,50

CURXY3              fcb       2,37,23

CURXY4              fcb       2,60,55

CURXY5              fcb       2,38,52
*    Player #1
PL1                 fcb       $1b,$32,4,2,47,50,80,76,65,89,69,82,32,35,49
*    Player #2
PL2                 fcb       $1b,$32,4,2,47,50,80,76,65,89,69,82,32,35,50
*   ** Pause **
PAUSE               fcb       $1b,$22,1,14,23,13,1,0,10,32
                    fcb       42,42,32,80,65,85,83,69,32,42,42
*    Close pause overlay or Hiscore overlay
PAUEND              fcb       $1b,$23
*    Get Ready
GETRDY              fcb       2,39,36,71,69,84,32,82,69,65,68,89
*    Get Ready Player 1
GETRD1              fcb       2,39,34,$1b,$32,1,80,108,97,121,101
                    fcb       114,32,49,$1b,$32,2,2,39,36,71,69
                    fcb       84,32,82,69,65,68,89
*    Get ready Player 2
GETRD2              fcb       2,39,34,$1b,$32,1,80,108,97,121,101
                    fcb       114,32,50,$1b,$32,2,2,39,36,71,69
                    fcb       84,32,82,69,65,68,89
*    Game Over
GMOVER              fcb       $1b,$22,1,13,8,14,5,10,2,$0c,2,34
                    fcb       34,71,65,77,69,32,32,79,86,69,82
*    Play Again (y/n) ?
PLYAGN              fcb       $1b,$32,4,2,35,34,80,76,65,89,32,65
                    fcb       71,65,73,78,32,40,89,47,78,41,32,63
                    fcb       2,52,34
*    QUIT PROGRAM (Y/N) ?
BRKKEY              fcb       $1b,$32,10,$1b,$22,1,8,9,24,3
                    fcb       10,2,2,34,33,81,85,73,84,32
                    fcb       80,82,79,71,82,65,77,32
                    fcb       40,89,47,78,41,32,63
*    Close
*  break overlay
BRKEND              fcb       $1b,$23
*    SCREEN BONUS
*    1000  POINTS
SCNBON              fcb       $1b,$32,10,$1b,$22,1,12,9,16,4,10
                    fcb       2,2,34,33,83,67,82,69,69,78,32
                    fcb       66,79,78,85,83,2,34,34,49,48
                    fcb       48,48,32,32,80,79,73,78,84,83
*    Close Screen bonus overlay
SCBEND              fcb       $1b,$23
*    100   High   Score   0
HSTRING             fcb       $1b,$32,10
HSTRG2              fcb       2,34,32,32,32,49,48,48,48
SCOR1               fcb       $1b,$32,10
                    fcb       2,43,32,72,73,71,72,2,55,32
                    fcb       83,67,79,82,69,2,69,32,48
*    0  Player #1   <-UP    Player #2       0
SCOR2               fcb       $1b,$32,10,2,32,32,32,32,32
                    fcb       32,32,48,32,80,76,65,89,69
                    fcb       82,32,35,49,32,$1b,$32,12,60
                    fcb       45,$1b,$32,9,85,80,32,32,32
                    fcb       $1b,$32,10,80,76,65,89,69,82
                    fcb       32,35,50,32,32,32,32,32,32,48
*      This will print  <-UP
SCR1                fcb       $1b,$32,12,2,49,32,60,45,$1b
                    fcb       $32,9,85,80,32,32,$1b,$32,10
*      This will print    UP->
SCR2                fcb       $1b,$32,9,2,49,32,32,32,85,80
                    fcb       $1b,$32,12,45,62,$1b,$32,10


__start             export
__start
*    Open window #1
PAC                 lda       #UPDAT              Set for OPEN with UPDATE
                    leax      PTHLST,pcr          Point to addr of Path list
                    os9       I$Open              Open path to window
                    lbcs      ERR2
                    sta       PATH                Save path number
                    leax      DWSET,pcr           Point to DWSET code
                    ldy       #10                 Output 10 bytes
                    lda       PATH                Get path number
                    os9       I$Write             Output DWSET code
                    lbcs      ERR2

*    Open window #2

                    lda       #UPDAT              Set for OPEN with UPDATE
                    leax      PTHLST,pcr          Point to addr of Path list
                    os9       I$Open              Open path to window
                    lbcs      ERR2                Branch if any errors
                    sta       PATH2               Save path number 2
                    leax      DWSET,pcr           Point to DWSET code
                    ldy       #10                 Output 10 bytes
                    lda       PATH2               Get path number
                    os9       I$Write             Output DWSET code
                    lbcs      ERR2                Branch if any errors
*    Setup window #2
                    leax      BOLDSW,pcr
                    ldy       #3
                    lbsr      OUTST2
                    leax      CUROFF,pcr          Point to cursor OFF code
                    ldy       #2                  Output 2 bytes
                    lbsr      OUTST2              Output cursor off string
                    leax      PLLST1,pcr          Set grey background
                    ldy       #10
                    lbsr      OUTST2
                    leax      CLEAR,pcr           Point to clear screen code
                    ldy       #1                  Output 1 byte
                    lbsr      OUTST2              Output clear screen string
*   Select Window #2
                    lda       PATH2               Get path number
                    leax      SELECT,pcr          Point to SELECT code
                    ldy       #2                  Output 2 bytes
                    os9       I$Write             Output select code
                    lbcs      ERR1
                    lda       #2
                    sta       WINDOW              Selecting window #2

                    leax      TITLE,pcr           Put title on screen
                    ldy       #43
                    lbsr      OUTST2

                    leax      SCNRST,pcr          Reset screen to 40,24
                    ldy       #6
                    lbsr      OUTST2

*    Setup window #1
                    leax      BOLDSW,pcr
                    ldy       #3
                    lbsr      OUTSTR
                    leax      CUROFF,pcr          Point to cursor OFF code
                    ldy       #2                  Output 2 bytes
                    lbsr      OUTSTR              Output cursor off string
                    leax      CLEAR,pcr           Point to clear screen code
                    ldy       #1                  Output 1 byte
                    lbsr      OUTSTR              Output clear screen code

GETID               os9       F$ID                Get process ID
                    sta       PROCID              Will be used for GBN

*    Get system time and use the seconds value to
*        seed the random number generator.
*    The 2 bytes for the seconds will be put in
*             RANNUM and ADDEND

SEEDER              leax      PALBT2,U            Put time bytes here
                    os9       F$Time              Go get time bytes
                    lbcs      ERR1                Branch if any errors

***   Set trap for BREAK key   ***

KEYTRAP             leax      TRAP,pcr
                    os9       F$Icpt
                    lbcs      ERR1
                    bra       FILSTR

TRAP                stb       SIGCODE,U
                    rti                           Return from interrupt


*    Preload Dotcode, Putcode and Getcode strings

FILSTR              ldd       #$1b2d              Code for PUTBLK
                    std       PUTPACM
                    std       PUTGHS
                    std       PUTCODE             Put it in Putblk string
                    std       DOTCODE             Put it in Putblk string
                    lda       PROCID              Get Process I.D.
                    sta       PCGBN
                    sta       PGBN                Set Group Buffer #
                    sta       PDGBN               Set Group Buffer #
                    sta       PGGBN               Set Group Buffer #

                    leax      KILBUF,U            Point to KILBUF string
                    ldd       #$1b2a              Kill buffer code
                    std       ,X++
                    lda       PROCID              Get process I.D.
                    sta       ,X+
                    lda       #$00
                    sta       ,X
                    ldd       #$1b31
                    std       PALBT1,U
                    std       PALBT2,U

                    leax      HSTRG2,pcr
                    leay      HISPOS,U
                    ldb       #9
HSLOOP              lda       ,X+
                    sta       ,Y+
                    decb
                    bne       HSLOOP

                    clr       RSFLAG
                    clr       SIGCODE
                    clr       BUTTON

                    lbsr      SBEGIN              Read & display high scores

RESTART             nop       Come                here to restart game

*    Setupb will fill all object buffers
**************************************
*         For testing
*   To see all the objects that are put
*   into the buffers, remove the REM's
*   at locations #1, #2 and change the
*   PATH2 to PATH at location #3

**************************************
*         leax   SELECT,pcr      #1
*         ldy    #$0002          #1
*         lbsr   OUTSTR          #1
*         clr    WINDOW          #1
**************************************

SETBUF              lda       #1                  Set board # to 1
                    sta       BRDNUM
                    sta       BRDTMP

SKPCL2              lda       #2                  Set screen count flag to 2
                    sta       SCNFLG
                    sta       SCFTMP

                    tst       RSFLAG              Check restart flag
                    bne       SETBF2              If no restart then
                    lbsr      SETUPB              go draw objects

SETBF2              lbsr      SETUPC

                    ldd       SCNTOT              Get screen dot total
                    std       SCTOT2              Copy to temporary

**************************************
*         lda    PATH            #2
*         leax   RESPON,U        #2
*         ldy    #1              #2
*         os9    I$Read          #2
*         lbcs   ERR1            #2
**************************************
CLSCRN              leax      CLEAR,pcr           Point to clear screen code
                    ldy       #1                  Output 1 char.
                    lbsr      OUTSTR              Go output clear screen code

                    lda       RSFLAG              Check restart flag
                    lbne      SETVR1              Branch if restarting

                    leax      SELJOY,pcr          Point to joystick select
                    ldy       #44                 Output 44 bytes
                    lbsr      POPUP               Do popup and output SELJOY

JYLOOP              lda       PATH2,U
                    ldb       #$13
                    ldx       #0
                    os9       I$GetStt
                    lbcs      ERR1
                    ldb       #0
                    cmpa      #0
                    bne       PUTPRT
                    lda       PATH2,U
                    ldb       #$13
                    ldx       #1
                    os9       I$GetStt
                    lbcs      ERR1
                    ldb       #1
                    cmpa      #0
                    beq       JYLOOP

PUTPRT              clra
                    std       PORT,U              Put value in PORT
                    leax      LFTSTR,pcr
                    ldy       #16
                    cmpd      #0
                    bne       PTDSPL
                    leax      RGTSTR,pcr
PTDSPL              lbsr      OUTST2
                    leax      SLCTED,pcr
                    ldy       #14
                    lbsr      OUTST2

                    ldx       #100
                    lbsr      WAIT                Pause for 50 ticks

                    leax      PAUEND,pcr
                    ldy       #2
                    lbsr      OUTST2

                    ldx       #75
                    lbsr      WAIT

                    leax      PLYSTR,pcr          Point to players string
                    ldy       #81                 Output 81 bytes
                    lbsr      POPUP               Do popup and output PLYSTR

*   Put square
PUTSQR              ldd       #$1b32
                    std       STRING,U
                    lda       #1
                    sta       STRING+2,U
                    ldd       #$1b40
                    std       STRING+3,U
                    ldd       #168
                    std       STRING+5,U
                    ldd       #100
                    std       STRING+7,U
                    ldd       #$1b48
                    std       STRING+9,U
                    ldd       #208
                    std       STRING+11,U
                    ldd       #143
                    std       STRING+13,U
                    leax      STRING,U
                    ldy       #15
                    lbsr      OUTST2

                    lda       #0                  Default = 1 player
                    sta       JOYSTY

NUMLOP              lda       PATH2
                    ldb       #$13
                    ldx       PORT,U
                    os9       I$GetStt
                    lbcs      ERR1
                    stx       JOYSTX
                    sta       BUTTON
                    bne       GOTBUT
                    tfr       X,D
                    lda       #1
                    cmpb      #42
                    bge       PUTNUM
                    lda       #0

PUTNUM              sta       JOYSTY
                    lda       #0
                    sta       STRING+2,U
                    leax      STRING,U
                    ldy       #15
                    lbsr      OUTST2

                    lda       JOYSTY
                    cmpa      #0
                    bne       PUTLFT
                    ldd       #168
                    std       STRING+5,U
                    ldd       #208
                    std       STRING+11,U
                    bra       DRWSQR
PUTLFT              ldd       #432
                    std       STRING+5,U
                    ldd       #472
                    std       STRING+11,U
DRWSQR              lda       #1
                    sta       STRING+2,U
                    leax      STRING,U
                    ldy       #15
                    lbsr      OUTST2
                    bra       NUMLOP

GOTBUT              lda       JOYSTY
                    sta       PLAYRS

                    ldx       #100
                    lbsr      WAIT

                    leax      PAUEND,pcr
                    ldy       #2
                    lbsr      OUTST2

SETVR1              ldd       #308
                    std       PXNEW               Pacman starting X location
                    std       PCXLOC
                    ldd       #94
                    std       PYNEW               Pacman starting Y location
                    std       PCYLOC
                    ldd       #1966               Set initial pacman array offset
                    std       POFSET
                    lda       #3
                    sta       CYCLE               Set cycle to 3
                    lda       #28
                    sta       BUFF                Set starting pacman buffer
                    lda       #80                 Setup ghost counter value
                    sta       GCOUNT
                    clr       HITFLG              Pacman hit flag
                    clr       POWFLG              Power pill flag
                    lda       #3
                    sta       PACMN1              Set # of players to 3
                    sta       PACMN2              Set # of players to 3
                    sta       PACMAN              Set current pacman to 3
                    lda       #1
                    sta       PLCRNT              Set current player to #1
                    sta       EXTPAC,U            Extra pacman goal byte
                    sta       EXTPC2,U            Goal for player 2
                    ldd       #0
                    std       DOTTOT              Dot and pill total
                    std       DOTTMP              Dot & pill total, player2

                    lda       #69
                    sta       BONBUF
                    clr       BONFLG
                    lda       #150
                    sta       BONTIM
                    leax      BTEMP,U
                    ldd       #8
                    std       BONUSX              Set X starting location
                    std       ,X++
                    ldd       #181
                    std       BONUSY              Set Y starting location
                    std       ,X++
                    clr       BONCNT              Clear bonus counter
                    clr       ,X

                    lda       PLAYRS              Check flag
                    beq       GRDY                If 0 then only 1 player
                    lbsr      BELL
                    leax      GETRD1,pcr
                    ldy       #29
                    lbsr      POPUP
                    bra       DRWBRD
GRDY                lbsr      BELL
                    leax      GETRDY,pcr          Print GET READY
                    ldy       #12
                    lbsr      POPUP               Do popup and output GETRDY

*    Now draw board and place objects

DRWBRD              lbsr      BOARDC


*    Select approprite header for 1 or 2 player mode

HEADER              lda       PLAYRS              Check for 1 or 2 players
                    bne       HEADR2
                    leax      SCOR1,pcr           Point to 1 player header
                    ldy       #22                 Output 22 bytes
                    lbsr      OUTSTR
                    leax      HSTRING,pcr         Position curser
                    ldy       #3                  Output 3 bytes
                    lbsr      OUTSTR
                    leax      HISPOS,U            Point to HIGH score
                    ldy       #9                  output 9 bytes
                    lbsr      OUTSTR
                    bra       SELSCN
HEADR2              leax      SCRPOS,U            Point to score string
                    lda       #32
                    sta       1,X                 Set curser X location
                    leax      SCOR2,pcr           Point to 2 player header
                    ldy       #55                 Output 55 bytes
                    lbsr      OUTSTR

*    Now select playing screen

SELSCN              lbsr      BELL

                    leax      SELECT,pcr          Point to select code
                    ldy       #2                  Output 2 bytes
                    lbsr      OUTSTR              Go to output routine
                    clr       WINDOW              Flag for window 0

                    leax      POPEND,pcr
                    ldy       #15
                    lbsr      OUTST2

*     Main program loop
*
MAIN                lbra      CHECKS              Go check & move ghosts
MAIN1               lbsr      MVPAC               Go move pacman

*     Check for signals (break key)

                    ldb       SIGCODE,U
                    cmpb      #2                  Was it the break key ?
                    bne       NOBRK
                    leax      BRKKEY,pcr          Point to string
                    ldy       #35                 Output 35 bytes
                    lbsr      OUTSTR
                    clr       RESPON,U

                    lbsr      READ                Flush input buffer

                    lbsr      READ                Go get input

                    leax      BRKEND,pcr          Erase BRKKEY prompt
                    ldy       #2                  Output 2 bytes
                    lbsr      OUTSTR
                    clr       SIGCODE,U           Clear signal flag

                    lda       RESPON,U            Check input
                    cmpa      #89                 Was it a Y ?
                    beq       YESBRK
                    cmpa      #121                Was it a y ?
                    bne       NOBRK

YESBRK              leax      SELECT,pcr
                    ldy       #2
                    lbsr      OUTST2

                    lbsr      SCEND
                    ldx       #50
                    lbsr      WAIT                Sleep for 50 ticks
                    lbra      EXIT                Quit program

NOBRK               ldd       DOTTOT              Get dot total
                    cmpd      SCNTOT              Cleared the screen yet?
                    lbne      CHKBUT

                    ldx       #80
                    lbsr      WAIT                Pause for 80 ticks
*   Display SCREEN BONUS
                    leax      SCNBON,pcr
                    ldy       #42
                    lbsr      OUTSTR
*   Make noise
                    ldx       #$3f06
                    ldy       #3000
                    lbsr      SND
                    ldy       #2000
                    lbsr      SND
                    ldy       #3000
                    lbsr      SND
                    ldy       #2000
                    lbsr      SND
*   Pause a few more seconds
                    ldx       #150
                    lbsr      WAIT
*   Close SCREEN BONUS overlay
                    leax      SCBEND,pcr
                    ldy       #2
                    lbsr      OUTSTR
*   Add 1000 points to score for clearing screen
                    lda       #16
                    sta       POINTS+1
                    clr       POINTS+2
                    lbsr      ADDUP
                    clr       POINTS+1
*   Pause some more
                    ldx       #150
                    lbsr      WAIT
*   Add up bonus items at bottom of screen

                    lbsr      CNTBON

*   Select comment window

                    leax      SELECT,pcr
                    ldy       #2
                    lbsr      OUTST2

                    ldx       #300
                    lbsr      WAIT

                    ldb       PLAYRS              Get # of players(1=0,2=1)
                    beq       GTRDY               Only one player
                    lbsr      BELL
                    leax      GETRD1,pcr          Point player 1 string
                    ldy       #29                 Output 29 bytes
                    ldb       PLCRNT              Get current pacman number
                    cmpb      #2                  Is it player #2 ?
                    beq       PLNUM2
                    bra       PLOUT

PLNUM2              leax      GETRD2,pcr          Point to player #2 string
PLOUT               lbsr      POPUP               Go output string
                    bra       DOREST
GTRDY               lbsr      BELL

                    leax      GETRDY,pcr          Point to GET READY string
                    ldy       #12                 Output 12 bytes
                    lbsr      POPUP               Do popup and output GETRDY

*   Reset screen

DOREST              lbsr      NEWSCN

                    ldx       #150
                    lbsr      WAIT

                    lbsr      BELL

*   Select game window

                    leax      SELECT,pcr
                    ldy       #2
                    lbsr      OUTSTR

                    leax      POPEND,pcr
                    ldy       #15
                    lbsr      OUTST2

*    The following routines are run once
*    for every three times pacman moves
*
*    First check to see if pacman screen is the
*        screen currently being displayed.
*         If not, then sleep for 2 ticks.


CHKBUT              lda       CYCLE               Check for CYCLE=2
                    cmpa      #2
                    lbne      MAIN

*    Update Mouse packet

CHKBT1              lda       PATH
                    ldb       #$89
                    leax      MOUSE,U
                    ldy       #0
                    os9       I$GetStt            Do a SS.MOUSE call
                    lbcs      ERR1
                    lda       MOUSE               Get Pt.Valid byte
                    bne       CHKBT2
                    ldx       #2
                    lbsr      WAIT                Sleep for 2 ticks
                    bra       CHKBT1              Loop till valid

CHKBT2              lda       BUTTON              Check for button
                    lbeq      MAIN                Loop till button is pushed
                    leax      PAUSE,pcr           Point to pause string
                    ldy       #21                 Output 21 bytes
                    lbsr      OUTSTR

PAUBUT              ldx       #6                  Sleep for 6 ticks
                    lbsr      WAIT
*    Get joystick data using SS.JOY
                    lda       PATH
                    ldb       #$13
                    ldx       PORT,U
                    os9       I$GetStt
                    lbcs      ERR1
                    sta       BUTTON

                    ldb       BUTTON              Check button
                    beq       PAUBUT
                    clr       BUTTON

                    leax      PAUEND,pcr          Point to pause end
                    ldy       #2
                    lbsr      OUTSTR

                    lbra      MAIN


WAIT4               lbsr      READ                Go wait for keypress
                    rts

*****  Game over  *****
*   Used for 1 player mode and for
*   player 2 in two player mode
*   Ask player if they want to play again

GAMOVR              leax      GMOVER,pcr          Point to GAME OVER string
                    ldy       #23                 Output 23 bytes
                    lbsr      OUTSTR

                    ldx       #100
                    lbsr      WAIT                Sleep for 100 ticks
                    leax      PAUEND,pcr
                    ldy       #2
                    lbsr      OUTSTR

                    leax      SELECT,pcr
                    ldy       #2
                    lbsr      OUTST2

                    lbsr      SCEND               Display high scores

                    leax      BOTWIN,pcr
                    ldy       #47
                    lbsr      OUTST2

                    leax      PLYAGN,pcr          Point to PLAY AGAIN
                    ldy       #27                 Output 27 bytes
                    lbsr      OUTST2              Go output string

                    lbsr      READ2               Go get response

                    clrb                          Clear reset flag
                    lda       RESPON
                    cmpa      #89                 Was it a Y ?
                    bne       CKLOW
                    incb                          Set flag
CKLOW               cmpa      #121                Was it a y ?
                    bne       CKFLAG
                    incb                          Set flag
CKFLAG              cmpb      #0                  Is flag clear ?
                    bne       NOEX
                    leax      BOTEND,pcr
                    ldy       #15
                    lbsr      OUTST2
                    ldb       #0
                    lbra      EXIT

NOEX                leax      BOTEND,pcr
                    ldy       #15
                    lbsr      OUTST2

                    leax      CLEAR,pcr           Clear board screen
                    ldy       #1
                    lbsr      OUTSTR

*   Compare Players score to High score

COMHGH              ldb       #7                  Set loop counter to 7
                    leay      HSCASC,U            Point to High ascii
                    leax      SCRASC-1,U          Point to Player ascii -1
CMLOOP              decb                          Decrement loop counter
                    beq       COMEND              Exit loop
                    lda       ,Y+
                    leax      1,X
                    cmpa      ,X
                    beq       CMLOOP
                    bhi       COMEND

                    ldb       #6                  Set new loop counter
                    leax      HSCASC,U
                    leay      SCRASC,U
C2LOOP              lda       ,Y+
                    sta       ,X+
                    decb
                    bne       C2LOOP

COMEND              ldb       #1                  Set restart flag
                    stb       RSFLAG
                    lbra      RESTART             Go restart

GAMOV2              leax      GMOVER,pcr          Point to GAME OVER string
                    ldy       #23                 Output 23 bytes
                    lbsr      OUTSTR

                    ldx       #150
                    lbsr      WAIT                Sleep for 100 ticks
                    leax      PAUEND,pcr          Kill overlay window
                    ldy       #2
                    lbsr      OUTSTR

                    leax      SELECT,pcr
                    ldy       #2
                    lbsr      OUTST2

                    lbsr      SCEND               Display high scores

                    rts

EXIT                nop
                    leax      KILBUF,U
                    ldy       #4                  Output 4 bytes
                    lbsr      OUTSTR              Go kill buffers
                    leax      DWEND,pcr
                    ldy       #2
                    bsr       OUTSTR              End the game screen
                    ldb       #0
QUIT                os9       F$Exit              Exit program

*    Do READ from PATH
READ                lda       PATH
                    leax      RESPON,U            Put read char. here
                    ldy       #1                  Get 1 char.
                    os9       I$Read              Go do read
                    lbcs      ERR1
                    rts

*    Do READ from PATH2
READ2               lda       PATH2
                    leax      RESPON,U
                    ldy       #1                  Get 1 char.
                    os9       I$Read              Go do read
                    lbcs      ERR1
                    rts

OUTSTR              lda       PATH                Get path number
                    os9       I$Write             Output string till CR
                    lbcs      ERR1
OTDONE              rts

POPUP               pshs      X
                    pshs      Y
                    leax      POPWIN,pcr
                    ldy       #17
                    bsr       OUTST2
                    puls      Y
                    puls      X
OUTST2              lda       PATH2
                    os9       I$Write
                    lbcs      ERR1
                    rts

*     This routine is used to sleep for
*     a while. On entry the X reg. holds
*     the number of ticks to sleep

WAIT                os9       F$Sleep
                    lbcs      ERR1
                    rts

PUTBLK              pshs      X,Y
                    leax      PUTCODE,U           Point to putblk code rmb's
                    ldy       #8                  Output 8 bytes
                    lda       PATH                Set output path
                    os9       I$Write             Output putblk code bytes
                    lbcs      ERR1                Branch if any errors
                    puls      X,Y
                    rts                           Return to calling routine

PUTGHT              leax      PUTGHS,U            Point to putghs code rmb's
                    ldy       #8                  Output 8 bytes
                    lda       PATH                Set output path
                    os9       I$Write             Output putghs code bytes
                    lbcs      ERR1                Branch if any errors
                    rts                           Return to calling routine

*   Sound routines
*    On entry X & Y regs. are already
*    loaded with sound data

SND                 lda       PATH
                    ldb       #$98
                    os9       I$SetStt
                    rts

*   Random number routine
*    Will return random number in A reg.

RANDNM              stx       SAVEX               Save X reg.
                    leax      RANNUM,U            Point to random number
                    lda       ,X
                    rola
                    eora      ,X
                    rora
                    inc       1,X
                    adda      1,X
                    bvc       RDSKIP
                    inc       1,X
RDSKIP              sta       ,X
                    ldx       SAVEX               Restore X reg.
                    rts                           Return, A reg. holds number

*   Ring the bell
BELL                leax      BELCOD,pcr
                    ldy       #1
                    lbsr      OUTST2
                    rts

ERR1                lbra      EXIT                Do select and dwend
ERR2                lbra      QUIT                Dont do select or dwend



                    endsect



